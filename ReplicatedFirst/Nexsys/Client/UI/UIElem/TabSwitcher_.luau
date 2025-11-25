local ReplicatedFirst = game:GetService("ReplicatedFirst")
local GuiObject_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.GuiObject_)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)

--- @class TabSwitcher_ : GuiObject_
local TabSwitcher_ = {}
TabSwitcher_.__index = TabSwitcher_
setmetatable(TabSwitcher_, GuiObject_)

----------------------------------------------------------------------------------------------------
-- 
function TabSwitcher_.new()
	local self = setmetatable(GuiObject_.new(), TabSwitcher_)
	TabSwitcher_.Init(self)
	return self
end

function TabSwitcher_:Init()
	self.tabInfos = {}
end
----------------------------------------------------------------------------------------------------
-- AddTabInfo
function TabSwitcher_:AddTabInfo(tabInfo : SystemTypes.TabGuiInfo)
	if tabInfo.Button then
		local btnHandler = self:SetupButton(tabInfo.Button, function(button : GuiButton)
			self:SetTabByButtonName(button.Name)
		end)
		tabInfo.ButtonHandler = btnHandler
	end

	self.tabInfos[tabInfo.Frame.Name] = tabInfo
	tabInfo.Frame.Visible = tabInfo.IsPrimary == true
end
----------------------------------------------------------------------------------------------------
-- Frameだけを追加
function TabSwitcher_:AddFrame(frame : Frame, isPrimary : boolean?)
	self.tabInfos[frame.Name] = { Frame = frame, IsPrimary = isPrimary }
	frame.Visible = isPrimary == true
end
----------------------------------------------------------------------------------------------------
-- SetButtonZIndex
function TabSwitcher_:SetButtonZIndex(activeZIndex : number, inactiveZIndex : number)
	self.activeZIndex = activeZIndex
	self.inactiveZIndex = inactiveZIndex
end
----------------------------------------------------------------------------------------------------
-- ResetToPrimary
function TabSwitcher_:ResetToPrimaryTab()
	for frameName, tabInfo in self.tabInfos do
		if tabInfo.IsPrimary then
			self:SetTabByFrameName(frameName)
			break
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetTabByFrameName
function TabSwitcher_:SetTabByFrameName(frameName : string)
	for tabFrameName, tabInfo in self.tabInfos do
		if tabFrameName == frameName then
			if tabInfo.FrameHandler then
				tabInfo.FrameHandler:Show()
			else
				tabInfo.Frame.Visible = true
			end

			if self.activeZIndex then
				tabInfo.Button.ZIndex = self.activeZIndex
			end

			if tabInfo.Button then
				tabInfo.ButtonHandler:SetSelected(true)
			end
		else
			if tabInfo.FrameHandler then
				tabInfo.FrameHandler:Hide()
			else
				tabInfo.Frame.Visible = false
			end

			if self.inactiveZIndex then
				tabInfo.Button.ZIndex = self.inactiveZIndex
			end

			if tabInfo.Button then
				tabInfo.ButtonHandler:SetSelected(false)
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetTabByButtonName
function TabSwitcher_:SetTabByButtonName(buttonName : string)
	for frameName, tabInfo in self.tabInfos do
		if tabInfo.Button.Name == buttonName then
			self:SetTabByFrameName(frameName)
			break
		end
	end
end

return TabSwitcher_