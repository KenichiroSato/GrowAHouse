local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventSender_ = function(eventType, ...)
	print("SendCommonServerEvent", eventType, ...)

	ReplicatedStorage.RemoteEvent.CommonServerEvent:FireServer(eventType, ...)
end

return RemoteEventSender_