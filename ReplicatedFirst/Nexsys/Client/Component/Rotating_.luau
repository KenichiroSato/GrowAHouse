local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)

--[[
]]

--- @class Rotating_ : ComponentBase
local Rotating_ = {}
Rotating_.__index = Rotating_
setmetatable(Rotating_, ComponentBase)

----------------------------------------------------------------------------------------------------
-- 
function Rotating_.new(...)
	local self = setmetatable(ComponentBase.new(...), Rotating_)
	Rotating_.Init(self, ...)
	return self
end

function Rotating_:Init(ins : PVInstance)
	self.axisType = ins:GetAttribute("AxisType") or "Y"
	self.speed = ins:GetAttribute("Speed") or 1

	self:SetHeartbeatActive(true)
end

----------------------------------------------------------------------------------------------------
-- 
function Rotating_:onHeartbeat(dt : number)
	local speed = self.speed * dt
	if self.axisType == "X" then
		self.instance.CFrame *= CFrame.Angles(speed, 0, 0)
	elseif self.axisType == "Y" then
		self.instance.CFrame *= CFrame.Angles(0, speed, 0)
	elseif self.axisType == "Z" then
		self.instance.CFrame *= CFrame.Angles(0, 0, speed)
	end
end

return Rotating_