local ReplicatedFirst = game:GetService("ReplicatedFirst")
local GuiObject_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.GuiObject_)

--- @class ListUI_ : GuiObject_
local ListUI_ = {}
ListUI_.__index = ListUI_
setmetatable(ListUI_, GuiObject_)

----------------------------------------------------------------------------------------------------
-- 
function ListUI_.new(list : GuiObject, templateName : string?)
	local self = setmetatable(GuiObject_.new(list), ListUI_)
	ListUI_.Init(self, list, templateName)
	return self
end

function ListUI_:Init(list : GuiObject, templateName : string?)
	self.list = list
	self.selectedElemName = "Selected"
	self.buttonHandlers = {}

	local template
	if templateName then
		template = list:FindFirstChild(templateName) :: Frame
	else
		template = list:FindFirstChildWhichIsA("GuiObject") :: GuiObject
	end
	if not template then
		warn("ListUI_:Init Template Elem not found", list.Name, templateName)
		return
	end
	template.Visible = false

	self.template = template :: GuiObject
	self:SelectElem(self.template, false)

	-- TepmplateはFolderに入れて直下のGuiObjectで拾われないように
	local templateFolder = Instance.new("Folder")
	templateFolder.Name = "Template"
	templateFolder.Parent = list
	template.Parent = templateFolder

	-- 中身をクリア
	self:RemoveAll()
end
----------------------------------------------------------------------------------------------------
-- SetSelectedElementName
function ListUI_:SetSelectedElemName(name : string)
	self.selectedElemName = name
end
----------------------------------------------------------------------------------------------------
--- GetItemByName
function ListUI_:GetItemByName(name : string) : GuiObject?
	return self.list:FindFirstChild(name)
end
----------------------------------------------------------------------------------------------------
-- GetChildren
function ListUI_:GetChildren() : { GuiObject }
	return self.list:GetChildren()
end
----------------------------------------------------------------------------------------------------
-- CloneElem
function ListUI_:CreateElem() : GuiObject
	return self:AddItem()
end
----------------------------------------------------------------------
-- AddItem
function ListUI_:AddItem() : GuiObject
	local elem = self.template:Clone()
	elem.Visible = true
	elem:SetAttribute("ListItem", true)
	elem.Parent = self.list
	return elem
end
----------------------------------------------------------------------------------------------------
-- IsListElem
function ListUI_:IsListElem(elem : GuiObject) : boolean
	return elem:GetAttribute("ListItem")
end
----------------------------------------------------------------------------------------------------
-- SetButtonHandler
function ListUI_:SetButtonHandler(key : string, handler)
	self.buttonHandlers[key] = handler
end
----------------------------------------------------------------------------------------------------
--- @return ButtonUI_
function ListUI_:GetButtonHandler(key : string)
	return self.buttonHandlers[key]
end
----------------------------------------------------------------------------------------------------
-- ClearAll
function ListUI_:ClearAll()
	self:RemoveAll()
	self:ClearSelectAll()
end
----------------------------------------------------------------------------------------------------
-- ClearList
function ListUI_:RemoveAll()
	local children = self.list:GetChildren()
	for _, child in ipairs(children) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- ClearSelectAll
function ListUI_:ClearSelectAll()
	local children = self.list:GetChildren()
	for _, child in ipairs(children) do
		if not child:IsA("GuiObject") then
			continue
		end
		self:SelectElem(child, false)
	end
end
----------------------------------------------------------------------------------------------------
-- FindElemByName
function ListUI_:FindElemByName(name : string) : GuiObject?
	local children = self.list:GetChildren()
	for _, child in ipairs(children) do
		if child.Name == name then
			return child
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SelectElem
function ListUI_:SelectElem(elem : Frame, isSelected)
	local selectedElem = elem:FindFirstChild(self.selectedElemName, true)
	if selectedElem then
		if selectedElem:IsA("UIStroke") then
			selectedElem.Enabled = isSelected
		elseif selectedElem:IsA("GuiObject") then
			selectedElem.Visible = isSelected
		else
			warn("ListUI_::SelectElem unknown selectedElem", selectedElem)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- ToggleSelectElem
function ListUI_:ToggleSelectElem(elem : Frame)
	self:SelectElem(elem, not self:IsSelectedElem(elem))
end
----------------------------------------------------------------------------------------------------
-- IsSelected
function ListUI_:IsSelectedElem(elem : GuiObject) : boolean
	if not elem:IsA("GuiObject") then
		return false
	end

	local selectedElem = elem:FindFirstChild(self.selectedElemName, true)
	if not selectedElem then
		warn("ListUI_:IsSelectedElem selectedElem not found", elem.Name, self.selectedElemName)
		return false
	end

	if selectedElem:IsA("UIStroke") then
		return selectedElem.Enabled
	elseif selectedElem:IsA("GuiObject") then
		return selectedElem.Visible
	else
		warn("ListUI_:IsSelectedElem unknown selectedElem", selectedElem)
		return false
	end
end

return ListUI_