local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local OrderedSaveData = require(ServerScriptService.Nexsys.OrderedSaveData)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
--- @class OrderedSaveDataManager : table
local OrderedSaveDataManager = {}

local osds_ = {}

----------------------------------------------------------------------------------------------------
-- Init
function OrderedSaveDataManager.InitFromRankingInfos(rankingInfos : {SystemTypes.RankingInfo})
	for _, rankingInfo in rankingInfos do
		local osdInfo : SystemTypes.OrderedSaveDataInfo = {
			Key = rankingInfo.Key,
			DBName = rankingInfo.DBName,
			IsAscending = rankingInfo.IsAscending,
			GetNum = rankingInfo.GetNum,
			StartDelay = rankingInfo.StartDelay,
			UpdateInterval = rankingInfo.UpdateInterval,
		}
		osds_[rankingInfo.Key] = OrderedSaveData.new(osdInfo)
	end
end
----------------------------------------------------------------------------------------------------
-- GetOrderedSaveData
function OrderedSaveDataManager.GetOrderedSaveData(key)
	return osds_[key]
end

return OrderedSaveDataManager