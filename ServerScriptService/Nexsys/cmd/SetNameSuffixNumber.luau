-- How to Call
-- require(game.ServerScriptService.Nexsys.cmd.SetNameSuffixNumber)(workspace.Map.TreasureChest)

return function(targetFolder : Folder)
	game:GetService("ChangeHistoryService"):SetWaypoint("SetNameSuffixNumber")

	local children = targetFolder:GetChildren()
	for index, child in children do
		child.Name = child.Name .. "_" .. index
	end
end
