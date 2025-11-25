local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunctionSender = function(eventType, ...)
	return ReplicatedStorage.RemoteEvent.CommonServerFunction:InvokeServer(eventType, ...)
end

return RemoteFunctionSender
