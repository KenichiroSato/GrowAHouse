local CircleGaugeUIModule_ = {}
CircleGaugeUIModule_.__index = CircleGaugeUIModule_

-- local colorSequenceColor = ColorSequence.new({ColorSequenceKeypoint.new(0,percentValue.ColorOfPercentPart.Value),ColorSequenceKeypoint.new(0.5,percentValue.ColorOfPercentPart.Value),ColorSequenceKeypoint.new(0.501,percentValue.ColorOfMissingPart.Value),ColorSequenceKeypoint.new(1,percentValue.ColorOfMissingPart.Value)})
-- local numberSequenceTrans = NumberSequence.new({NumberSequenceKeypoint.new(0,percentValue.TransOfPercentPart.Value),NumberSequenceKeypoint.new(0.5,percentValue.TransOfPercentPart.Value),NumberSequenceKeypoint.new(0.501,percentValue.TransOfMissingPart.Value),NumberSequenceKeypoint.new(1,percentValue.TransOfMissingPart.Value)})

function CircleGaugeUIModule_.new(...)
	local self = setmetatable({}, CircleGaugeUIModule_)
	CircleGaugeUIModule_.Init(self, ...)
	return self
end

function CircleGaugeUIModule_:Init(frame : Frame)
	self.totalFrame = frame
end

function CircleGaugeUIModule_:SetValue(percent)
	local rotPercentNum = math.clamp(percent * 3.6,0,360)

	local F1 = self.totalFrame.Frame1.ImageLabel
	local F2 = self.totalFrame.Frame2.ImageLabel
	
	F1.UIGradient.Rotation = math.clamp(rotPercentNum,180,360)
	F2.UIGradient.Rotation = math.clamp(rotPercentNum,0,180)

	-- F1.ImageColor3 = percentValue.ImageColor.Value
	-- F2.ImageColor3 = percentValue.ImageColor.Value
	-- F1.ImageTransparency = percentValue.ImageTrans.Value
	-- F2.ImageTransparency = percentValue.ImageTrans.Value
	-- F1.Image = "rbxassetid://" .. percentValue.ImageId.Value
	-- F2.Image = "rbxassetid://" .. percentValue.ImageId.Value

	-- local setType = "Color"
	-- if setType == "Color" then
	-- 	F1.UIGradient.Color = colorSequenceColor
	-- 	F2.UIGradient.Color = colorSequenceColor
	-- 	F1.UIGradient.Transparency = NumberSequence.new(0)
	-- 	F2.UIGradient.Transparency = NumberSequence.new(0)
	-- elseif setType == "Trans" then
	-- 	F1.UIGradient.Transparency = numberSequenceTrans
	-- 	F2.UIGradient.Transparency = numberSequenceTrans
	-- 	F1.UIGradient.Color = ColorSequence.new(Color3.new(1,1,1))
	-- 	F2.UIGradient.Color = ColorSequence.new(Color3.new(1,1,1))
	-- elseif setType == "TransAndColor" then
	-- 	F1.UIGradient.Transparency = numberSequenceTrans
	-- 	F2.UIGradient.Transparency = numberSequenceTrans
	-- 	F1.UIGradient.Color = colorSequenceColor
	-- 	F2.UIGradient.Color = colorSequenceColor
	-- else
	-- 	-- percentValue.MissingPartType.Value = "Trans"
	-- 	error("Unknown Type. Only 3 available: “Trans”, “Color” and “TransAndColor”, changing to “Trans”.")
	-- end
end

return CircleGaugeUIModule_