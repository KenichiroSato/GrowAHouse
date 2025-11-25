local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ListUI_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.ListUI_)

--- @class MultiSelectList_ : ListUI_
local MultiSelectList_ = {}
MultiSelectList_.__index = MultiSelectList_
setmetatable(MultiSelectList_, ListUI_)

----------------------------------------------------------------------------------------------------
-- 
function MultiSelectList_.new(list : Frame, templateName : string?)
	local self = setmetatable(ListUI_.new(list, templateName), MultiSelectList_)
	MultiSelectList_.Init(self, list, templateName)
	return self
end

function MultiSelectList_:Init(list : Frame, templateName : string?)

end
----------------------------------------------------------------------------------------------------
-- SelectByElemName
function MultiSelectList_:SelectByElemName(name : string, isSelected : boolean)
	local elem = self:FindElemByName(name)
	if not elem then
		warn("MultiSelectList_:SelectByElemName elem not found", name)
		return
	end
	self:SelectElem(elem, isSelected)
end
----------------------------------------------------------------------------------------------------
-- GetSelectedElems
function MultiSelectList_:GetSelectedElems() : { GuiObject }
	local selectedElems = {}
	for _, elem : GuiObject in ipairs(self.list:GetChildren()) do
		if not elem:IsA("GuiObject") then
			continue
		end

		if self:IsSelectedElem(elem) then
			table.insert(selectedElems, elem)
		end
	end
	return selectedElems
end

return MultiSelectList_