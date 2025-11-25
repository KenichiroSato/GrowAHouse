local TweenService = game:GetService("TweenService")

--- @class PointingUIElem_ : table
local PointingUIElem_ = {}
PointingUIElem_.__index = PointingUIElem_

----------------------------------------------------------------------------------------------------
-- 
function PointingUIElem_.new(uiObject : GuiObject, moveOfs : UDim2)
	local self = setmetatable({}, PointingUIElem_)
	PointingUIElem_.Init(self, uiObject, moveOfs)
	return self
end

function PointingUIElem_:Init(uiObject : GuiObject, moveOfs : UDim2)
	self.uiObject = uiObject
	self.basePos = uiObject.Position
	self.ofs = moveOfs
	self.uiObject.Visible = false
end

----------------------------------------------------------------------------------------------------
-- PlayAnim
function PointingUIElem_:PlayAnimation()
	-- self:StopAnimation()

	-- 2回ちょんちょんする動き
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 1, true)
	local targetPos = self.basePos + self.ofs
	self.uiObject.Position = self.basePos
	self.tween = TweenService:Create(self.uiObject, tweenInfo, {Position = targetPos})
	self.tween:Play()
	-- 繰り返し処理 : CompletedはCancel時にも来るので注意
	self.tween.Completed:Connect(function(playbackState : Enum.PlaybackState)
		task.wait(1.5)
		if self:IsActive() then
			self:PlayAnimation()
		end
	end)
end

----------------------------------------------------------------------------------------------------
-- StopAnim
function PointingUIElem_:StopAnimation()
	if self.tween then
		self.tween:Cancel()
	end
end
----------------------------------------------------------------------------------------------------
-- SetActive
function PointingUIElem_:SetActive(isActive : boolean)
	if isActive == self:IsActive() then
		return
	end

	self.uiObject.Visible = isActive
	if isActive then
		self:PlayAnimation()
	else
		self:StopAnimation()
	end
end
----------------------------------------------------------------------------------------------------
-- IsActive
function PointingUIElem_:IsActive()
	return self.uiObject.Visible
end

return PointingUIElem_