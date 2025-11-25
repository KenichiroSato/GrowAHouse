local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ListUI_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.ListUI_)

--- @class SingleSelectList_ : ListUI_
local SingleSelectList_ = {}
SingleSelectList_.__index = SingleSelectList_
setmetatable(SingleSelectList_, ListUI_)

----------------------------------------------------------------------------------------------------
-- 
function SingleSelectList_.new(list : Frame, templateName : string?)
	local self = setmetatable(ListUI_.new(list, templateName), SingleSelectList_)
	SingleSelectList_.Init(self, list, templateName)
	return self
end

function SingleSelectList_:Init(list : Frame, templateName : string?)
	self.selectedElem = nil
end
----------------------------------------------------------------------------------------------------
-- SelectByElemName
function SingleSelectList_:SelectByElemName(name : string)
	local elems = self.list:GetChildren()
	for i, elem in ipairs(elems) do
		if not elem:IsA("GuiObject") then
			continue
		end

		self:SelectElem(elem, elem.Name == name)
	end
end
----------------------------------------------------------------------------------------------------
-- SelectByElem
function SingleSelectList_:SelectByElem(elem : Frame)
	local elems = self.list:GetChildren()
	for i, e in ipairs(elems) do
		if not e:IsA("GuiObject") then
			continue
		end

		self:SelectElem(e, e == elem)
	end
end
----------------------------------------------------------------------------------------------------
-- SelectFirstLayoutOrderElem
function ListUI_:SelectFirstLayoutOrderElem()
	local lowLayoutOrder = 1000000
	local lowElem = nil
	local children = self.list:GetChildren()
	for _, elem : GuiObject in ipairs(children) do
		if elem:IsA("GuiObject") then
			self:SelectElem(elem, false)
			if elem.LayoutOrder < lowLayoutOrder then
				lowLayoutOrder = elem.LayoutOrder
				lowElem = elem
			end
		end
	end
	self:SelectElem(lowElem, true)
end
----------------------------------------------------------------------------------------------------
-- SelectElem
function SingleSelectList_:SelectElem(elem : Frame, isSelected)
	ListUI_.SelectElem(self, elem, isSelected)
	if isSelected then
		self.selectedElem = elem
	end
end
----------------------------------------------------------------------------------------------------
-- GetSelectedElem
function SingleSelectList_:GetSelectedElem() : Frame
	return self.selectedElem
end
----------------------------------------------------------------------------------------------------
-- ClearSelectAll
function SingleSelectList_:ClearSelectAll()
	ListUI_.ClearSelectAll(self)
	self.selectedElem = nil
end

return SingleSelectList_
