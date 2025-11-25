local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)
local ModelUtil = require(ReplicatedFirst.Nexsys.Common.ModelUtil)

--- @class ModelComp : ComponentBase
local ModelComp = {}
ModelComp.__index = ModelComp
setmetatable(ModelComp, ComponentBase)

----------------------------------------------------------------------------------------------------
-- 
function ModelComp.new(...)
	local self = setmetatable(ComponentBase.new(...), ModelComp)
	ModelComp.Init(self, ...)
	return self
end

function ModelComp:Init(ins : Model)
	self.instance = ins
	self.isVisible = true
	self.isActive = true
	self.childrenInfo = {}
	self.tweenScale = nil
	self.tweenScaleValue = Instance.new("NumberValue")

	self:SetSteppedActive(true)
end
----------------------------------------------------------------------------------------------------
-- SetVisible : BasePartの透明度を変更しての表示非表示
function ModelComp:SetVisible(visible)
	if self.isVisible == visible then
		return
	end

	self.isVisible = visible
	if visible == false then
		self:RecordChildrenInfo()
	end

	local descs = self.instance:GetDescendants()
	for index, child : BasePart in descs do
		if child:IsA("BasePart") or child:IsA("Decal") then
			if visible then
				if self.childrenInfo[child] then
					child.Transparency = self.childrenInfo[child].Transparency
				end
			else
				child.Transparency = 1
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetModelActive : VisbleとCanCollide両方を切り替える
function ModelComp:SetModelActive(active)
	if self.isActive == active then
		return
	end

	self.isActive = active
	if active == false then
		self:RecordChildrenInfo()
	end

	local descs = self.instance:GetDescendants()
	for index, child : BasePart in descs do
		if child:IsA("BasePart") then
			if active then
				if self.childrenInfo[child] then
					child.Transparency = self.childrenInfo[child].Transparency
					child.CanCollide = self.childrenInfo[child].CanCollide
				end
			else
				child.Transparency = 1
				child.CanCollide = false
			end
		elseif child:IsA("Decal") then
			if active then
				child.Transparency = self.childrenInfo[child].Transparency
			else
				child.Transparency = 1
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
-- SetScale
function ModelComp:SetScale(scale)
	self.instance:ScaleTo(scale)
end
----------------------------------------------------------------------------------------------------
-- RecordChildrenInfo
function ModelComp:RecordChildrenInfo()
	local descs = self.instance:GetDescendants()
	for index, child : Instance in descs do
		if child:IsA("BasePart") or child:IsA("Decal") then
			local canCollide = child:IsA("BasePart") and child.CanCollide or false
			self.childrenInfo[child] = {
				Transparency = child.Transparency,
				CanCollide = canCollide,
			}
		end
	end
end
----------------------------------------------------------------------------------------------------
-- Update
function ModelComp:OnStepped(dt)
	if self.tweenScale then
		self.instance:ScaleTo(self.tweenScaleValue.Value)
		if self.tweenScale.PlaybackState == Enum.PlaybackState.Completed then
			self.tweenScale:Destroy()
			self.tweenScale = nil
		end
	end
end
----------------------------------------------------------------------------------------------------
-- FlashModel
function ModelComp:FlashModel(color : Color3, flashTime : number?)
	task.spawn(function()
		-- warn("ModelComp:FlashModel")

		local copy = Instance.new("Model")
		
		-- 不透明のパーツだけコピーしたモデルを作成
		local descs = self.instance:GetDescendants()
		for index, child : BasePart in descs do
			if child:IsA("BasePart") and child.Transparency <= 0.3 then
				local clone = child:Clone()
				clone.Parent = copy
				clone.CFrame = child.CFrame
				clone.Anchored = true
				clone.Material = Enum.Material.Neon
				clone.Transparency = 0
				clone.Size = child.Size * 1.01
				clone.Color = color
				clone.CanCollide = false
				clone.CanTouch = false
				if child:IsA("UnionOperation") then
					clone.UsePartColor = true
				end

				-- コピーでついてきた子供は削除(Descsでとれてるはずだし、Weldが邪魔するなどもある)
				for _, cloneChild : Instance in clone:GetChildren() do
					-- SpecialMeshだけは形状のために残す
					if not cloneChild:IsA("SpecialMesh") then
						cloneChild:Destroy()
					end
				end
			end
		end

		-- ModelUtil.SetPhysicsAll(copy, false)
		local FADE_TIME = flashTime and flashTime / 2 or 0.2
		copy.Parent = self.instance
		ModelUtil.FadeOut(copy, 0)
		ModelUtil.FadeIn(copy, FADE_TIME, 0.2)
		task.wait(FADE_TIME)
		ModelUtil.FadeOut(copy, FADE_TIME)
		task.wait(FADE_TIME)
		copy:Destroy()
	end)
end
----------------------------------------------------------------------------------------------------
-- TweenScale
function ModelComp:TweenScale(
	targetScale: number,
	itpoTime,
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?,
	repeatCount: number,
	reverse: boolean?
)
	if self.tweenScale then
		self.tweenScale:Cancel()
		self.tweenScale:Destroy()
		self.tweenScale = nil
	end

	self.tweenScaleValue.Value = self.instance:GetScale()
	local es = style or Enum.EasingStyle.Linear
	local ed = direction or Enum.EasingDirection.InOut
	local rc = repeatCount or 0
	local rv = reverse or false
	local tweenInfo = TweenInfo.new(itpoTime, es, ed, rc, rv)
	local goal = { Value = targetScale }
	self.tweenScale = TweenService:Create(self.tweenScaleValue, tweenInfo, goal)
	self.tweenScale:Play()
	-- while true do
	-- 	self.instance:ScaleTo(numVal.Value)
	-- 	if self.tweenScale.PlaybackState == Enum.PlaybackState.Completed then
	-- 		break
	-- 	end
	-- 	task.wait()
	-- end
end
----------------------------------------------------------------------------------------------------
-- FadeOut
function ModelComp:FadeOut(fadeTime)
	self:RecordChildrenInfo()
	ModelUtil.FadeOut(self.instance, fadeTime)
	self.isVisible = false
end
----------------------------------------------------------------------------------------------------
-- FadeOutDestroy
function ModelComp:FadeOutDestroy(fadeTime)
	self:FadeOut(fadeTime)
	task.delay(fadeTime, function()
		self.instance:Destroy()
	end)
end
----------------------------------------------------------------------------------------------------
-- FadeIn
function ModelComp:FadeIn(fadeTime)
	local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	
	local descs = self.instance:GetDescendants()
	for _index, child : BasePart in descs do
		if child:IsA("BasePart") or child:IsA("Decal") then
			if self.childrenInfo[child] then
				local transp = self.childrenInfo[child].Transparency
				local goal = { Transparency = transp }
				local tween = TweenService:Create(child, tweenInfo, goal)
				tween:Play()
			else
				warn("ModelComp:FadeIn: No childrenInfo", child.Name)
			end
		end
	end
end


return ModelComp