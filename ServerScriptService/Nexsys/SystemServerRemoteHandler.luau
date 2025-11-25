local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ServerRemoteSender = require(ServerScriptService.Nexsys.ServerRemoteSender)
--- @class SystemServerRemoteHandler : table
local SystemServerRemoteHandler = {}

----------------------------------------------------------------------------------------------------
function SystemServerRemoteHandler.onCommonServerEvent(player: Player, eventType, ...)
	if eventType == "RCS_DestroyInstance" then
		local f = function(ins : Instance)
			if ins then
				ins:Destroy()
			end
		end
		f(...)
	elseif eventType == "RCS_BroadcastEventExculeMe" then
		local players = Players:GetPlayers()
		for _, p in players do
			if p ~= player then
				print("broadcast to", p, ...)
				ServerRemoteSender.SendEvent(p, ...)
			end
		end
	else
		warn("not implemented event", eventType)
	end
	return nil
end

return SystemServerRemoteHandler