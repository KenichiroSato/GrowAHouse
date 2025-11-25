local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UIBase_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.UIBase_)

--- @class GuiObject_ : UIBase_
local GuiObject_ = {}
GuiObject_.__index = GuiObject_
setmetatable(GuiObject_, UIBase_)

----------------------------------------------------------------------------------------------------
-- 
function GuiObject_.new(guiObject : GuiObject)
	local self = setmetatable(UIBase_.new(guiObject), GuiObject_)
	GuiObject_.Init(self, guiObject)
	return self
end

function GuiObject_:Init(guiObject : GuiObject)
	self.guiObject = guiObject
end
----------------------------------------------------------------------------------------------------
-- SetVisibleChangedCallbackActive
function GuiObject_:SetVisibleChangedCallbackActive(active : boolean)
	self.guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.guiObject.Visible and self.onShow then
			-- onVisible に変えようか
			self:onShow()
		end
		if not self.guiObject.Visible and self.onHide then
			self:onHide()
		end
	end)
end
----------------------------------------------------------------------------------------------------
--
function GuiObject_:Show(...)
	self.guiObject.Visible = true
	-- コールバックはPropertyChangedSignalでやる

	-- 明示的なものもほしい、Visibleと別に使い分けるか検討中
	if self.onShow then
		self:onShow(...)
	end
end
----------------------------------------------------------------------------------------------------
-- Hide
function GuiObject_:Hide()
	self.guiObject.Visible = false
	-- コールバックはPropertyChangedSignalでやる

	-- 明示的なものもほしい、Visibleと別に使い分けるか検討中
	if self.onHide then
		self:onHide()
	end
end
----------------------------------------------------------------------------------------------------
-- ToggleShowHide
function GuiObject_:ToggleShowHide()
	if self:IsShow() then
		self:Hide()
	else
		self:Show()
	end
end
----------------------------------------------------------------------------------------------------
-- IsVisible
function GuiObject_:IsVisible()
	return self.guiObject.Visible
end
----------------------------------------------------------------------------------------------------
-- IsShow
function GuiObject_:IsShow()
	return self:IsVisible()
end
----------------------------------------------------------------------------------------------------
-- SetVisible
-- Visible を直接セットする
function GuiObject_:SetVisible(visible : boolean)
	self.guiObject.Visible = visible
end
----------------------------------------------------------------------------------------------------
-- SetInteractable
function GuiObject_:SetInteractable(interactable : boolean)
	self.guiObject.Interactable = interactable
end
----------------------------------------------------------------------------------------------------
-- IsInteractable
function GuiObject_:IsInteractable()
	return self.guiObject.Interactable
end

return GuiObject_