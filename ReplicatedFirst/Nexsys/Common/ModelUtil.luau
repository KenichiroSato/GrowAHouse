local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ModelUtil = {}

----------------------------------------------------------------------------------------------------
-- ModelのVisilbe管理
-- InvisibleはReplicatedStorageへの配置で行う
-- ModelUtilによるVisible管理をされた場合、Parentの情報をInstanceでもつ
-- 戻るときはそのParent情報をもとに戻す
----------------------------------------------------------------------------------------------------
-- SetModelVisible
function ModelUtil.SetModelVisible(model : Model, visible)
	if visible then
		-- というのを考え中
	end
end
----------------------------------------------------------------------------------------------------
-- IsVisibleModel
function ModelUtil.IsModelVisible(model : Model)

	return false
end

----------------------------------------------------------------------------------------------------
-- SetPositionAndRotation
function ModelUtil.SetPositionAndRotation(model : Model, pos : Vector3, rot : Vector3)
	-- local cf = CFrame.new(pos, rot)
	-- model:SetPrimaryPartCFrame(CFrame.new(pos, rot))
end

----------------------------------------------------------------------------------------------------
-- 
function ModelUtil.PlayTween(model, tweenInfo, goal)
	if model:IsA("BasePart") then
		local tween = TweenService:Create(model, tweenInfo, goal)
		tween:Play()
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				local tween = TweenService:Create(part, tweenInfo, goal)
				tween:Play()
			end
		end
	end	
end
----------------------------------------------------------------------
-- 補間Transform
----------------------------------------------------------------------
function ModelUtil.TweenPrimaryPart(model : Model, cf : CFrame, itpoTime)
	if not model.PrimaryPart then
		warn("model primary part not set")
		return
	end

	local tweenInfo = TweenInfo.new(itpoTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local goal = {}
	goal.CFrame  = cf
	local tween = TweenService:Create(model.PrimaryPart, tweenInfo, goal)
	tween:Play()
end
----------------------------------------------------------------------
-- Pivotで補間
----------------------------------------------------------------------
function ModelUtil.TweenPivot(instance : PVInstance, cf : CFrame, itpoTime)
	task.spawn(function()
		ModelUtil.TweenPivotSync(instance, cf, itpoTime)
	end)
end
----------------------------------------------------------------------------------------------------
-- 同期(ブロック)でTween
function ModelUtil.TweenPivotSync(instance : PVInstance, cf : CFrame, itpoTime, style : Enum.EasingStyle?, direction : Enum.EasingDirection?)
	local cfVal = Instance.new("CFrameValue")
	cfVal.Value = instance:GetPivot()
	local es = style or Enum.EasingStyle.Linear
	local ed = direction or Enum.EasingDirection.InOut
	local tweenInfo = TweenInfo.new(itpoTime, es, ed)
	local goal = {}
	goal.Value = cf
	local tween = TweenService:Create(cfVal, tweenInfo, goal)
	tween:Play()
	while true do
		instance:PivotTo(cfVal.Value)
		if tween.PlaybackState == Enum.PlaybackState.Completed then
			-- warn("Tween comp")
			break
		end
		task.wait()
	end
end
----------------------------------------------------------------------
-- 補間カラー
----------------------------------------------------------------------
function ModelUtil.TweenModelColor(model : Model, color : Color3, itpoTime)
	print("ModelUtil.TweenModelColor")
	local tweenInfo = TweenInfo.new(itpoTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local goal = {}
	goal.Color = color

	ModelUtil.PlayTween(model, tweenInfo, goal)
end
----------------------------------------------------------------------------------------------------
-- 補間透明度
function ModelUtil.TweenModelTransparency(model : Model, transparency : number, itpoTime)
	local tweenInfo = TweenInfo.new(itpoTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local goal = {}
	goal.Transparency = transparency

	ModelUtil.PlayTween(model, tweenInfo, goal)
end
----------------------------------------------------------------------------------------------------
-- TweenScaleRawParts
function ModelUtil.TweenScaleRawParts(
	model : Model,
	startScale: number,
	targetScale: number,
	itpoTime,
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?,
	repeatCount: number?,
	reverse: boolean?
)
	local es = style or Enum.EasingStyle.Linear
	local ed = direction or Enum.EasingDirection.InOut
	local rc = repeatCount or 0
	local rv = reverse or false
	local tweenInfo = TweenInfo.new(itpoTime, es, ed, rc, rv)

	local descs = model:GetDescendants()
	for index, child : BasePart in descs do
		if child:IsA("BasePart") then
			local goal = { Size = child.Size * targetScale }
			child.Size = child.Size * startScale
			local tween = TweenService:Create(child, tweenInfo, goal)
			tween:Play()
		end
	end
end

----------------------------------------------------------------------------------------------------
-- SetModelFade
function ModelUtil.SetModelFade(model : Model, isFadein, fadeTime)
	if isFadein then
		ModelUtil.FadeIn(model, fadeTime)
	else
		ModelUtil.FadeOut(model, fadeTime)
	end
end

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.FadeIn(model : Model, fadeTime, goalTransparency : number?, useModelTransparency : boolean?)
	local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local goal = {}
	goal.Transparency = goalTransparency or 0
	
	-- 透明から現在のTransparecyへ遷移させる
	if model:IsA("BasePart") then
		if model:HasTag("NoFadeIn") then
			return
		end

		if useModelTransparency then
			goal.Transparency = model.Transparency
		end

		model.Transparency = 1
		local tween = TweenService:Create(model, tweenInfo, goal)
		tween:Play()
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				if part:HasTag("NoFadeIn") then
					continue
				end

				if useModelTransparency then
					goal.Transparency = part.Transparency
				end

				part.Transparency = 1
				local tween = TweenService:Create(part, tweenInfo, goal)
				tween:Play()
			end
		end
	end	
end
----------------------------------------------------------------------------------------------------
-- 
function ModelUtil.FadeOut(model : Model, fadeTime)
	local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	
	if model:IsA("BasePart") then
		local goal = {}
		goal.Transparency = 1
		local tween = TweenService:Create(model, tweenInfo, goal)
		tween:Play()
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				local goal = {}
				goal.Transparency = 1
				local tween = TweenService:Create(part, tweenInfo, goal)
				tween:Play()
			end
		end
	end	
end
----------------------------------------------------------------------------------------------------
-- FadeOutAndDestroy
function ModelUtil.FadeOutAndDestroy(model : Model, fadeTime)
	task.spawn(function()
		ModelUtil.FadeOut(model, fadeTime)
		task.wait(fadeTime)
		model:Destroy()
	end)
end
----------------------------------------------------------------------------------------------------
-- SetVisible
function ModelUtil.SetVisible(model : Model, visible)
	if visible then
		ModelUtil.ShowModel(model)
	else
		ModelUtil.HideModel(model)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.HideModel(model : Model)
	if model:IsA("BasePart") then
		model.Transparency = 1
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 1
			elseif part:IsA("SurfaceGui") then
				part.Enabled = false
			end
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.ShowModel(model : Model)
	if model:IsA("BasePart") then
		if model:HasTag("NoFadeIn") then
			return
		end

		model.Transparency = 0
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:HasTag("NoFadeIn") then
				continue
			end

			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 0
			elseif part:IsA("SurfaceGui") then
				part.Enabled = true
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetModelActive
function ModelUtil.SetModelActive(model : Model, active : boolean, fadeTime : number?)
	if active then
		if fadeTime then
			ModelUtil.FadeIn(model, fadeTime)
		else
			ModelUtil.ShowModel(model)
		end
		ModelUtil.SetCanCollide(model, true)
		ModelUtil.SetCanTouch(model, true)
	else
		if fadeTime then
			ModelUtil.FadeOut(model, fadeTime)
		else
			ModelUtil.HideModel(model)
		end
		ModelUtil.SetCanCollide(model, false)
		ModelUtil.SetCanTouch(model, false)
	end
end

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.SetTransparency(model, val)
	ModelUtil.SetProperty(model, "Transparency", val)
end

function ModelUtil.SetTransparencyAll(model, val)
	ModelUtil.SetPropertyAll(model, "Transparency", val)
end

function ModelUtil.SetMaterial(model, material)
	ModelUtil.SetProperty(model, "Material", material)
end

function ModelUtil.SetColor(model, color : Color3)
	ModelUtil.SetProperty(model, "Color", color)
end

function ModelUtil.SetCanTouch(model, val)
	ModelUtil.SetProperty(model, "CanTouch", val)
end

function ModelUtil.SetCanCollide(model, val)
	ModelUtil.SetProperty(model, "CanCollide", val)
end

function ModelUtil.SetCollisionGroup(model, val)
	ModelUtil.SetProperty(model, "CollisionGroup", val)
end

function ModelUtil.SetProperty(model, propName, val)
	if model:IsA("BasePart") or model:IsA("MeshPart") then
		model[propName] = val
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part[propName] = val
			end
		end
	end	
end

----------------------------------------------------------------------------------------------------
-- SetNetworkOwner
function ModelUtil.SetNetworkOwner(model : Model, player : Player)
	if model:IsA("BasePart") then
		model:SetNetworkOwner(player)
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part:SetNetworkOwner(player)
			end
		end
	end	
end

-- タイプを限定しないでプロパティのあるやつに全適用
function ModelUtil.SetPropertyAll(model, propName, val)
	for _, part in ipairs(model:GetDescendants()) do
		pcall(function()
			part[propName] = val
		end)
		
		--local hasProp = pcall(function()
		--	local propVal = part[propName]
		--end)
		--if hasProp then
		--	part[propName] = val
		--end
	end
end

-- エフェクト付与(ParticleEmitter、Sparkleなど)
function ModelUtil.AddParticleEffect(model, particle)
	if model:IsA("BasePart") then
		particle.Parent = model
	else
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				local clone = particle:Clone()
				clone.Parent = part
			end
		end
	end	

end

function ModelUtil.FindFirstChildOfAttrribute(model, attrName, attrVal)
	for _, model in ipairs(model:GetDescendants()) do
		if model:GetAttribute(attrName) == attrVal then
			return model
		end
	end
	return nil
end

function ModelUtil.FindChildrenOfAttrribute(model, attrName, attrVal)
	local models = {}
	for _, model in ipairs(model:GetDescendants()) do
		if model:GetAttribute(attrName) == attrVal then
			table.insert(models, model)
		end
	end
	return models
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.OpenGateTransform(wall : Model, openTime)
	-- 開放
	local tweenInfo = TweenInfo.new(openTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local goal = {}
	goal.Size = Vector3.new(wall.Size.X, 0.01, wall.Size.Z)
	goal.Position = wall.Position + Vector3.new(0, wall.Size.Y / 2, 0)
	local tween = TweenService:Create(wall, tweenInfo, goal)
	tween:Play()
	wall.CanCollide = false
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.AddVectorForceToCharacter(chara : Model, force : Vector3, forceTime, fallTime)
	local humanoid : Humanoid = chara:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local hrp = chara.HumanoidRootPart
	local att = Instance.new("Attachment", hrp)
	local vectorForce = Instance.new("VectorForce", hrp)
	vectorForce.Attachment0 = att
	vectorForce.Force = force
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	humanoid.PlatformStand = true
	Debris:AddItem(vectorForce, forceTime)
	Debris:AddItem(att, forceTime)
	wait(fallTime)
	humanoid.PlatformStand = false
end
----------------------------------------------------------------------
-- ぶっとび移動適用
----------------------------------------------------------------------
function ModelUtil.StartBlownMove(chara : Model)
	
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.AddAwayMove(chara : Model, moveDir : Vector3)
	local humanoid : Humanoid = chara:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local hrp = chara.HumanoidRootPart
	if hrp:FindFirstChild("AwayMove") then
		return
	end

	local att = Instance.new("Attachment", hrp)
	att.Name = "AwayMoveAttach"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "AwayMove"
	linearVelocity.Parent = hrp
	linearVelocity.Attachment0 = att
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	linearVelocity.LineDirection = moveDir
	-- linearVelocity.LineVelocity = 30
	linearVelocity.LineVelocity = 10
	linearVelocity.MaxForce = math.huge
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World

	task.spawn(function()
		-- task.wait(1)
		task.wait(0.3)
		linearVelocity:Destroy()
		att:Destroy()
	end)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function ModelUtil.AddUpAndFallMove(chara : Model, force : Vector3, forceTime, fallTime)
	local humanoid : Humanoid = chara:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local hrp = chara.HumanoidRootPart
	if hrp:FindFirstChild("BrownMove") then
		return
	end

	local att = Instance.new("Attachment", hrp)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "BrownMove"
	linearVelocity.Parent = hrp
	linearVelocity.Attachment0 = att
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	linearVelocity.LineDirection = Vector3.new(0, 1, 0)
	linearVelocity.LineVelocity = 50
	linearVelocity.MaxForce = math.huge
	-- linearVelocity.VectorVelocity = Vector3.new(0, 20, 0)
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World

	local GRAVITY = -200
	task.spawn(function()
		while true do
			local dt = wait()
			local dv = dt * GRAVITY
			linearVelocity.LineVelocity += dv
			-- print("====== linearVelocity.LineVelocity = "..linearVelocity.LineVelocity)
			if linearVelocity.LineVelocity < -10 then
				break
			end
		end
		linearVelocity:Destroy()
		att:Destroy()
	end)

	-- humanoid.PlatformStand = true
	-- Debris:AddItem(linearVelocity, forceTime)
	-- Debris:AddItem(att, forceTime)
	-- wait(fallTime)
	-- humanoid.PlatformStand = false
end

function ModelUtil.AddUpAndFallMoveByMove(chara : Model, force : Vector3, forceTime, fallTime)
	-- 普通に動かしてみる
end

-- Playerルートパーツか
function ModelUtil.IsHumanoidRootPart(part : Part)
	if part.Name == "HumanoidRootPart" and part.Parent:FindFirstChild("Humanoid") then
		return true
	end
	return false
end

function ModelUtil.IsHumanoidPart(part : Part)
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		return true
	end
	return false
end

function ModelUtil.FindParentCharacter(part : Part) : Model
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		return part.Parent
	end
	return nil
end

function ModelUtil.FindSiblingHumanoid(part : Part) : Humanoid
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		return part.Parent.Humanoid
	end
	return nil
end

function ModelUtil.FindPrimaryPart(model : Instance)
	if model:IsA("BasePart") then
		return model
	else
		return model.PrimaryPart
	end
end

----------------------------------------------------------------------------------------------------
-- FlashModel
function ModelUtil.FlashModel(model : Model, color : Color3, flashTime : number?)
	task.spawn(function()
		-- warn("ModelComp:FlashModel")

		local copy = Instance.new("Model")
		
		-- 不透明のパーツだけコピーしたモデルを作成
		local descs = model:GetDescendants()
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
		copy.Parent = model
		ModelUtil.FadeOut(copy, 0)
		ModelUtil.FadeIn(copy, FADE_TIME, 0.2)
		task.wait(FADE_TIME)
		ModelUtil.FadeOut(copy, FADE_TIME)
		task.wait(FADE_TIME)
		copy:Destroy()
	end)
end
----------------------------------------------------------------------------------------------------
-- MakeToWeldedToPrimaryPart
function ModelUtil.MakeToWeldedToPrimaryPart(model : Model)
	local primaryPart = model.PrimaryPart
	if not primaryPart then
		warn("ModelUtil.MakeToWeldedToPrimaryPart: PrimaryPart not set")
		return
	end

	for _, part : BasePart in model:GetDescendants() do
		if part:IsA("BasePart") and part ~= primaryPart then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = primaryPart
			weld.Part1 = part
			weld.Parent = part
			part.Anchored = false
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function ModelUtil.GetLargestPart(model : Model) : BasePart
	local largestPart
	local largestSize = 0
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local size = part.Size.X + part.Size.Y + part.Size.Z
			if size > largestSize then
				largestSize = size
				largestPart = part
			end
		end
	end
	return largestPart
end
----------------------------------------------------------------------------------------------------
-- GetMainPart
function ModelUtil.GetMainPart(ins : Model) : BasePart
	local part
	if ins:IsA("Model") then
		part = ins.PrimaryPart
		if not part then
			part = ModelUtil.GetLargestPart(ins)
		end
	elseif ins:IsA("BasePart") then
		part = ins
	else
		warn("ModelUtil.GetMainPart: ins is not BasePart or Model")
	end
	return part
end
----------------------------------------------------------------------------------------------------
-- SetHighlight
function ModelUtil.SetHighlight(model : Model, isActive : boolean, fillColor : Color3?, fillTransparency : number?)
	if isActive then
		local oldHighlight = model:FindFirstChild("ModelHighlight")
		if oldHighlight then
			oldHighlight:Destroy()
		end
		local highlight = Instance.new("Highlight")
		highlight.Name = "ModelHighlight"
		highlight.Parent = model
		highlight.FillTransparency = fillTransparency or 0.7
		highlight.FillColor = fillColor or Color3.fromRGB(255, 255, 255)
	else
		local highlight = model:FindFirstChild("ModelHighlight")
		if highlight then
			highlight:Destroy()
		end
	end
end


return ModelUtil

