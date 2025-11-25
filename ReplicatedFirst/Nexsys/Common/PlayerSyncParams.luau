local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local SyncParams = require(ReplicatedFirst.Nexsys.Common.SyncParams)

--- @class PlayerSyncParams : SyncParams
local PlayerSyncParams = {}
PlayerSyncParams.__index = PlayerSyncParams
setmetatable(PlayerSyncParams, SyncParams)

function PlayerSyncParams.new(...)
	local self = setmetatable(SyncParams.new(...), PlayerSyncParams)
	PlayerSyncParams.Init(self, ...)
	return self
end

function PlayerSyncParams:Init(...)
	self.paramChangedEvent = Instance.new("BindableEvent")
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Cient処理
if RunService:IsClient() then
----------------------------------------------------------------------------------------------------
-- onSyncToClient
function PlayerSyncParams:onSyncedToClient(lastTable, syncedTable)
	self.paramChangedEvent:Fire(lastTable, syncedTable)
end
----------------------------------------------------------------------------------------------------
-- ConnectParamChanged
function PlayerSyncParams:ConnectParamChanged(paramName, callback)
	local connection = self.paramChangedEvent.Event:Connect(function(lastTable, syncedTable)
		if lastTable[paramName] ~= syncedTable[paramName]  then
			callback(syncedTable[paramName])
		end
	end)

	return connection
end

----------------------------------------------------------------------------------------------------
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

return PlayerSyncParams