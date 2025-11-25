local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- @class ServerRemoteSender : table
local ServerRemoteSender = {}

function ServerRemoteSender.SendEvent(player : Player, eventType, ...)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireClient(player, eventType, ...)
end

function ServerRemoteSender.SendEventToAll(eventType, ...)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireAllClients(eventType, ...)
end

function ServerRemoteSender.SendFunction(player : Player, eventType, ...)
	return ReplicatedStorage.RemoteEvent.CommonClientFunction:InvokeClient(player, eventType, ...)
end

return ServerRemoteSender
