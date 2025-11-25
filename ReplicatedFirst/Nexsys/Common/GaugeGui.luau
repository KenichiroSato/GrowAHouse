--- @class GaugeGui : table
local GaugeGui = {}
GaugeGui.__index = GaugeGui
----------------------------------------------------------------------------------------------------
-- 
function GaugeGui.new(...)
	local self = setmetatable({}, GaugeGui)
	GaugeGui.Init(self, ...)
	return self
end

function GaugeGui:Init(frame : Frame)
	self.frame = frame
	self.gauge = frame:FindFirstChild("Gauge", true) :: Frame
end

----------------------------------------------------------------------------------------------------
-- SetGaugeRate
function GaugeGui:SetGaugeRate(rate : number)
	self.gauge.Size = UDim2.fromScale(rate, 1)
end

return GaugeGui