local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicaParams = require(ReplicatedFirst.Nexsys.Common.ReplicaParams.ReplicaParams)

--- @class PlayerReplicaParams : ReplicaParams
local PlayerReplicaParams = {}
PlayerReplicaParams.__index = PlayerReplicaParams
setmetatable(PlayerReplicaParams, ReplicaParams)

function PlayerReplicaParams.new(templateTable : table, player : Player)
	local initTable = table.clone(templateTable)
	local self = setmetatable(ReplicaParams.new("PlayerReplicaParams", initTable, player), PlayerReplicaParams)
	return self
end

return PlayerReplicaParams
