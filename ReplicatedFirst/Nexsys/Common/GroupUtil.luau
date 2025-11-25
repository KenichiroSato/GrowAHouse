--- @class GroupUtil : table
local GroupUtil = {}

----------------------------------------------------------------------------------------------------
-- Folder, Modelなどのグループ配下のInstanceをまとめて扱うためのUtility
-- Folderに限らずPartの子どもとかでも良い想定
----------------------------------------------------------------------------------------------------
-- SetTransparency
function GroupUtil.SetTransparency(group : Instance, transparency : number)
	for _, obj in group:GetChildren() do
		if obj:IsA("BasePart") then
			obj.Transparency = transparency
		elseif obj:IsA("Folder") or obj:IsA("Model") then
			GroupUtil.SetTransparency(obj, transparency)
		end
	end
end

return GroupUtil