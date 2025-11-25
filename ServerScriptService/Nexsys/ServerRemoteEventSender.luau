local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- @class ServerRemoteEventSender : table
local ServerRemoteEventSender = {}

function ServerRemoteEventSender.Send(player : Player, eventType, ...)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireClient(player, eventType, ...)
end

function ServerRemoteEventSender.SendToAll(eventType, ...)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireAllClients(eventType, ...)
end

return ServerRemoteEventSender