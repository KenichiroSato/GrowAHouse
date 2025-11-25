--- @class GaugeUI_ : table
local GaugeUI_ = {}
GaugeUI_.__index = GaugeUI_

----------------------------------------------------------------------------------------------------
-- 
function GaugeUI_.new(...)
	local self = setmetatable({}, GaugeUI_)
	GaugeUI_.Init(self, ...)
	return self
end

function GaugeUI_:Init(frame : Frame)
	self.gauge = frame:FindFirstChild("Gauge", true) :: Frame
	self.gaugeText = frame:FindFirstChild("GaugeText", true) :: TextLabel
end
----------------------------------------------------------------------------------------------------
-- SetGaugeRate
function GaugeUI_:SetGaugeRate(rate : number)
	self.gauge.Size = UDim2.fromScale(rate, 1)
end
----------------------------------------------------------------------------------------------------
-- SetGaugeColor
function GaugeUI_:SetGaugeColor(color : Color3)
	self.gauge.BackgroundColor3 = color
end
----------------------------------------------------------------------------------------------------
-- SetGaugeText
function GaugeUI_:SetGaugeText(text : string)
	if self.gaugeText then
		self.gaugeText.Text = text
	end
end

return GaugeUI_