local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- @class ServerRemoteFunctionSender : table
local ServerRemoteFunctionSender = {}

function ServerRemoteFunctionSender.Send(player : Player, eventType, ...)
	return ReplicatedStorage.RemoteEvent.CommonClientFunction:InvokeClient(player, eventType, ...)
end

return ServerRemoteFunctionSender