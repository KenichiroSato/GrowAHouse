local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local PopUp = {}
PopUp.__index = PopUp
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PopUp.fromTextLabel(str, textLabel : TextLabel)
	local self = setmetatable({}, PopUp)
	PopUp.Execute(self, str, textLabel, textLabel.Position)
	return self
end

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PopUp:Execute(str, baseText : TextLabel, udimPos)
	local text = baseText:Clone()

	text.Visible = true
	text.Text = str
	text.Position = udimPos
	text.Parent = baseText.Parent

	task.spawn(function()
		local SHOW_TIME = 2
		-- part名を入力して動かす
		local tweenInfo = TweenInfo.new(SHOW_TIME, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local goal = { Position = text.Position + UDim2.fromOffset(0, -60) }
		local tween = TweenService:Create(text, tweenInfo, goal)
		tween:Play()
		Debris:AddItem(text, SHOW_TIME + 0.5)
	end)
end

return PopUp