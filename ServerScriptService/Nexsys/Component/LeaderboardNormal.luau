local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local LeaderboardBase = require(ServerScriptService.Nexsys.Component.LeaderboardBase)
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)

--- @class LeaderboardNormal : LeaderboardBase
local LeaderboardNormal = {}
LeaderboardNormal.__index = LeaderboardNormal
setmetatable(LeaderboardNormal, LeaderboardBase)

----------------------------------------------------------------------------------------------------
-- 
function LeaderboardNormal.new(...)
	local self = setmetatable(LeaderboardBase.new(...), LeaderboardNormal)
	LeaderboardNormal.Init(self, ...)
	return self
end

function LeaderboardNormal:Init(ins : Model)
	self.instance = ins
	local rankType = ins:GetAttribute("RankType")
	print("LeaderboardNormal:Init", ins, rankType)

	local infos = GameDataProvider:GetOrderedSaveDataInfos()
	local rankInfo = infos[rankType]
	assert(rankInfo, "LeaderboardNormal:Init rankInfo is nil, rankType="..rankType)
	local isSuccess = self:SetupLeaderboard(ins, rankInfo)
	if isSuccess then
		self:SetSteppedActive(true)
	else
		warn("LeaderboardNormal:Init failed, rankType="..rankType)
	end
end

----------------------------------------------------------------------------------------------------
-- OnStepped
function LeaderboardNormal:OnStepped(dt : number)
	-- サーバー内で1分更新リクエストしてないなら更新
	local elapTime = self:GetUpdateRequestElapsedTime()
	if elapTime < 60 then
		return
	end

	print("LeaderboardNormal:OnStepped UpdateLeaderBoard", self.instance:GetAttribute("RankType"))
	self:UpdateLeaderBoard()
end

return LeaderboardNormal