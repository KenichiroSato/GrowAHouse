local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicaParams = require(ReplicatedFirst.Nexsys.Common.ReplicaParams.ReplicaParams)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)

--- @class PlayerSaveReplica : ReplicaParams
local PlayerSaveReplica = {}
PlayerSaveReplica.__index = PlayerSaveReplica
setmetatable(PlayerSaveReplica, ReplicaParams)

function PlayerSaveReplica.new(dataTable : table, player : Player)
	local self = setmetatable(ReplicaParams.new("PlayerSaveReplica", dataTable, player), PlayerSaveReplica)
	return self
end
----------------------------------------------------------------------------------------------------
-- onReplicaCreated
function PlayerSaveReplica:onReplicaCreated()
	SystemDataModule_.OnSaveDataLoaded()
end

return PlayerSaveReplica

