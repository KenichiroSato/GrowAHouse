local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicaParams = require(ReplicatedFirst.Nexsys.Common.ReplicaParams.ReplicaParams)

--- @class GameReplicaParams : ReplicaParams
local GameReplicaParams = {}
GameReplicaParams.__index = GameReplicaParams
setmetatable(GameReplicaParams, ReplicaParams)

function GameReplicaParams.new(dataTable : table)
	local self = setmetatable(ReplicaParams.new("GameReplicaParams", dataTable), GameReplicaParams)
	return self
end

return GameReplicaParams