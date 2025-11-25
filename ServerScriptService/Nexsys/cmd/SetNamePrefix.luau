-- How to Call
-- require(game.ServerStorage.cmd.SetNamePrefix)(workspace.Layout.Piano.Keys["3"], "3_")

return function(targetFolder : Folder, prefix : string)
	local children = targetFolder:GetChildren()
	for index, child in children do
		child.Name = prefix .. child.Name
	end
end
