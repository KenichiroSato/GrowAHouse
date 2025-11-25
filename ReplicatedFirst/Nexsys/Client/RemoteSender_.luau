local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--- @class RemoteSender : table
local RemoteSender_ = {}

local sendingFunctions_ = {}
local intervals_ = {}

----------------------------------------------------------------------------------------------------
-- 
function RemoteSender_.SendEvent(eventType, ...) : boolean
	if intervals_[eventType] then
		local interval, lastTime = unpack(intervals_[eventType])
		if tick() - lastTime < interval then
			if RunService:IsStudio() then
				print("SendRemoteEvent interval failed", eventType)
			end
			return false
		end
	end
	ReplicatedStorage.RemoteEvent.CommonServerEvent:FireServer(eventType, ...)
	return true
end
----------------------------------------------------------------------------------------------------
-- 
function RemoteSender_.SendEventWithInterval(eventType, interval, ...)
	local result = RemoteSender_.SendEvent(eventType, ...)
	if result then
		intervals_[eventType] = { interval, tick() }
	end
end
----------------------------------------------------------------------------------------------------
-- 
function RemoteSender_.SendFunction(eventType, ...)
	sendingFunctions_[eventType] = true

	-- 可変長戻り値処理用
	local resultProcessFunc = function(...)
		sendingFunctions_[eventType] = nil
		return ...
	end
	return resultProcessFunc(ReplicatedStorage.RemoteEvent.CommonServerFunction:InvokeServer(eventType, ...))
end
----------------------------------------------------------------------------------------------------
-- SendFunctionOnce
function RemoteSender_.SendFunctionOnce(eventType, ...)
	if RemoteSender_.IsSending(eventType) then
		warn("SendFunction [" .. eventType .. "] is already in progress.")
		return false
	end
	return RemoteSender_.SendFunction(eventType, ...)
end
----------------------------------------------------------------------------------------------------
-- 
function RemoteSender_.SendFunctionOnceNoLog(eventType, ...)
	if RemoteSender_.IsSending(eventType) then
		return false
	end
	return RemoteSender_.SendFunction(eventType, ...)
end
----------------------------------------------------------------------------------------------------
-- CanSendFunction
function RemoteSender_.IsSending(eventType)
	return sendingFunctions_[eventType]
end
----------------------------------------------------------------------------------------------------
-- BoardcastEventExculeMe
function RemoteSender_.BoardcastEventExculeMe(eventType, ...)
	RemoteSender_.SendEvent("RCS_BroadcastEventExculeMe", eventType, ...)
end
----------------------------------------------------------------------------------------------------
-- 便利系
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- SendDestroyInstance
function RemoteSender_.SendDestroyInstance(ins)
	RemoteSender_.SendEvent("RCS_DestroyInstance", ins)
end
----------------------------------------------------------------------------------------------------
-- SendReplicateSoundEffect
function RemoteSender_.SendReplicateSoundEffect(seIns : Sound)
	RemoteSender_.SendEvent("RCS_BroadcastEventExculeMe", "RSC_ReplicateSoundEffect", seIns)
end
----------------------------------------------------------------------------------------------------
-- SendReplicateEffect
function RemoteSender_.SendReplicateEffect(effectParam)
	RemoteSender_.SendEvent("RCS_BroadcastEventExculeMe", "RSC_ReplicateEffect", effectParam)
end

return RemoteSender_