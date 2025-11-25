--- @class SelectableList_ : table
local SelectableList_ = {}
SelectableList_.__index = SelectableList_

----------------------------------------------------------------------------------------------------
-- 
function SelectableList_.new(...)
	local self = setmetatable({}, SelectableList_)
	SelectableList_.Init(self, ...)
	return self
end
----------------------------------------------------------------------------------------------------
-- 
function SelectableList_:Init(list : Frame)
	self.list = list
	self.selectedElemName = "Selected"
	self.selectedElem = nil
end
----------------------------------------------------------------------------------------------------
-- SetSelectedElementName
function SelectableList_:SetSelectedElemName(name : string)
	self.selectedElemName = name
end
----------------------------------------------------------------------------------------------------
-- ClearList
function SelectableList_:ClearList()
	self:ClearSelect()

	local children = self.list:GetChildren()
	for _, child in ipairs(children) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function SelectableList_:InitItemList() : Frame
	local template = self.list:FindFirstChild("Template") :: Frame
	template.Visible = false
	template.Parent = game.Players.LocalPlayer.PlayerGui

	-- 中身をクリア
	self:ClearList()

	return template
end

----------------------------------------------------------------------------------------------------
-- SelectByIndex
-- list:GetChildrenはソートオーダー順に入っているわけでもないので使いにくい、非推奨
function SelectableList_:SelectByIndex(index : number)
	local elems = self.list:GetChildren()
	local elemIndex = 0
	for i, elem in ipairs(elems) do
		if not elem:IsA("GuiObject") then
			continue
		end

		elemIndex += 1
		self:SelectElem(elem, elemIndex == index)
	end
end
----------------------------------------------------------------------------------------------------
-- SelectByElemName
function SelectableList_:SelectByElemName(name : string)
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
function SelectableList_:SelectByElem(elem : Frame)
	local elems = self.list:GetChildren()
	for i, e in ipairs(elems) do
		if not e:IsA("GuiObject") then
			continue
		end

		self:SelectElem(e, e == elem)
	end
end
----------------------------------------------------------------------------------------------------
-- SelectElem
function SelectableList_:SelectElem(elem : Frame, isSelected)
	local selectedElem = elem:FindFirstChild(self.selectedElemName, true)
	if selectedElem then
		if selectedElem:IsA("UIStroke") then
			selectedElem.Enabled = isSelected
		elseif selectedElem:IsA("GuiObject") then
			selectedElem.Visible = isSelected
		else
			warn("SelectableList_::SelectElem unknown selectedElem", selectedElem)
		end
	end

	if isSelected then
		self.selectedElem = elem
	end
end
----------------------------------------------------------------------------------------------------
-- GetSelectedElem
function SelectableList_:GetSelectedElem() : Frame
	return self.selectedElem
end
----------------------------------------------------------------------------------------------------
-- ClearSelect
function SelectableList_:ClearSelect()
	self.selectedElem = nil
	self:SelectByElem(nil)
end

return SelectableList_