local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)

--- @class SinAnimGui_ : ComponentBase
local SinAnimGui_ = {}
SinAnimGui_.__index = SinAnimGui_
setmetatable(SinAnimGui_, ComponentBase)

----------------------------------------------------------------------------------------------------
-- 
function SinAnimGui_.new(...)
	local self = setmetatable(ComponentBase.new(...), SinAnimGui_)
	SinAnimGui_.Init(self, ...)
	return self
end

function SinAnimGui_:Init(ins : GuiObject)
	-- warn("SinAnimGui:Init")

	self.instance = ins

	local time = ins:GetAttribute("SinAnimTime") or 2
	local moveScale = ins:GetAttribute("SinAnimMoveScale") or 1
	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

	-- 今の位置を中心に動くためずらす
	ins.Position += UDim2.fromScale(0, -moveScale / 2)
	local targetPos = ins.Position + UDim2.fromScale(0, moveScale)
	local tween = TweenService:Create(self.instance, tweenInfo, {Position = targetPos})
	tween:Play()
	self.tween = tween
end

----------------------------------------------------------------------------------------------------
-- CancelAnimation
function SinAnimGui_:CancelAnimation()
	self.tween:Cancel()
end

return SinAnimGui_