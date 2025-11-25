local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SoundManager_ = require(ReplicatedFirst.Nexsys.Client.SoundManager_)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
--- @class ButtonUI_ : table
local ButtonUI_ = {}
ButtonUI_.__index = ButtonUI_

----------------------------------------------------------------------------------------------------
-- 
function ButtonUI_.new(button : GuiButton, onActivatedFunc : (GuiButton), noAnim : boolean?)
	local self = setmetatable({}, ButtonUI_)
	ButtonUI_.Init(self, button, onActivatedFunc, noAnim)
	return self
end

function ButtonUI_.SetButtonAnimationInactive()
	ButtonUI_.animationInactive = true
end

function ButtonUI_:Init(button : GuiButton, onActivatedFunc : (GuiButton), noAnim : boolean?)
	self.button = button
	self.enabled = true
	self.enableSE = true
	self.clickSeName = "ClickOK"
	if button:GetAttribute("SE") then
		self.clickSeName = button:GetAttribute("SE")
	end
	self.clickNgSeName = "ClickNG"
	if button:GetAttribute("NG_SE") then
		self.clickNgSeName = button:GetAttribute("NG_SE")
	end

	self.button.Activated:Connect(function()
		if self.enabled then
			if self.enableSE then
				SoundManager_.PlaySEByName(self.clickSeName)
			end
			onActivatedFunc(self.button, self)
		else
			if self.enableSE then
				SoundManager_.PlaySEByName(self.clickNgSeName)
			end
		end
	end)
	local disabledObject = button:FindFirstChild("Disabled")
	if disabledObject and disabledObject:IsA("GuiObject") then
		self.disabledObject = disabledObject :: GuiObject
	end

	if not noAnim and not ButtonUI_.animationInactive then
		-- ボタンスケールアニメ
		local uiScale = Instance.new("UIScale")
		uiScale.Parent = button

		local function onMouseEnter()
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			local goalProp = { Scale = 1.1 }
			local tween = TweenService:Create(uiScale, tweenInfo, goalProp)
			tween:Play()
		end

		local function onMouseLeave()
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			local goalProp = { Scale = 1 }
			local tween = TweenService:Create(uiScale, tweenInfo, goalProp)
			tween:Play()
		end
		self.hoverStartConnect = button.MouseEnter:Connect(onMouseEnter)
		self.hoverEndConnect = button.MouseLeave:Connect(onMouseLeave)

		-- ボタン押したときアニメ
		button.MouseButton1Down:Connect(function()
			local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			local goalProp = { Scale = 0.9 }
			local tween = TweenService:Create(uiScale, tweenInfo, goalProp)
			tween:Play()
		end)
		button.MouseButton1Up:Connect(function()
			local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			local goalProp = { Scale = 1 }
			local tween = TweenService:Create(uiScale, tweenInfo, goalProp)
			tween:Play()
		end)
	end

	if not button.Active then
		warn("Button.Active is false", button.Name)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function ButtonUI_:SetEnabled(enabled : boolean)
	self.enabled = enabled
	if self.disabledObject then
		self.disabledObject.Visible = not enabled
	end
end
----------------------------------------------------------------------------------------------------
-- IsEnable
function ButtonUI_:IsEnabled() : boolean
	return self.enabled
end
----------------------------------------------------------------------------------------------------
-- SetEnableSE
function ButtonUI_:SetEnableSE(enableSE : boolean)
	self.enableSE = enableSE
end
----------------------------------------------------------------------------------------------------
-- SetVisible
function ButtonUI_:SetVisible(visible : boolean)
	self.button.Visible = visible
end
----------------------------------------------------------------------------------------------------
-- SetInteractable
function ButtonUI_:SetInteractable(interactable : boolean)
	self.button.Interactable = interactable
end
----------------------------------------------------------------------------------------------------
-- SetClickSEName
function ButtonUI_:SetClickSEName(clickSeName : string)
	self.clickSeName = clickSeName
end
----------------------------------------------------------------------------------------------------
-- SetClickNGSEName
function ButtonUI_:SetClickNGSEName(clickNgSeName : string)
	self.clickNgSeName = clickNgSeName
end
----------------------------------------------------------------------------------------------------
-- GetButton
function ButtonUI_:GetButton() : GuiButton
	return self.button
end
----------------------------------------------------------------------------------------------------
-- FindDescendant
function ButtonUI_:FindDescendant(name : string) : GuiObject?
	return self.button:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- FindFirstChild
function ButtonUI_:FindFirstChild(name : string) : GuiObject?
	return self.button:FindFirstChild(name)
end
----------------------------------------------------------------------------------------------------
-- SetSelected
function ButtonUI_:SetSelected(selected : boolean)
	local selectedObj = self:FindDescendant("Selected")
	if selectedObj then
		selectedObj.Visible = selected
	end
end
----------------------------------------------------------------------------------------------------
-- ToggleSelected
function ButtonUI_:ToggleSelected()
	local selected = self:FindDescendant("Selected")
	if selected then
		selected.Visible = not selected.Visible
	end
end

return ButtonUI_