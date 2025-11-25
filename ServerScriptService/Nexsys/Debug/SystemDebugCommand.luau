local ServerScriptService = game:GetService("ServerScriptService")
local ServerRemoteSender = require(ServerScriptService.Nexsys.ServerRemoteSender)
--- @class SystemDebugCommand : table
local SystemDebugCommand = {}

----------------------------------------------------------------------------------------------------
-- Process
function SystemDebugCommand.Process(player : Player, message : string, recipient)
	-- if not ServerStorage.DevConfig.EnableDebugCommand.Value then
	-- 	warn("DebugCommand is disabled")
	-- 	return
	-- end

	print("SystemDebugCommand Process", message)

	-- ひとまずStudioに閉じておく
	if not game:GetService("RunService"):IsStudio() then
		warn("SystemDebugCommand is disabled, Studio only")
		return
	end

	local beginIdx, endIdx = string.find(message, "/dc")
	if beginIdx and beginIdx >= 1 then
		local args = string.split(message, " ")
		local command = args[2]
		if command == "ev" or command == "event" then
			local eventName = args[3]
			ServerRemoteSender.SendEvent(player, "RSC_Debug_PlayEvent", eventName)
		-- elseif command == "rs" or command == "resetsave" then
		-- 	gp:ResetSaveData()
		end
	end
end

return SystemDebugCommand
