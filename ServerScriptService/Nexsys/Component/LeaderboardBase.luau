local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local UserService = game:GetService("UserService")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)
local OrderedSaveDataManager = require(ServerScriptService.Nexsys.OrderedSaveDataManager)
local UserThumbnailCache = require(ReplicatedFirst.Nexsys.Common.UserThumbnailCache)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)

--- @class LeaderboardBase : ComponentBase
local LeaderboardBase = {}
LeaderboardBase.__index = LeaderboardBase
setmetatable(LeaderboardBase, ComponentBase)

local RANK_COLORS = {
	Color3.fromRGB(253, 192, 11),
	Color3.fromRGB(149, 208, 221),
	Color3.fromRGB(167, 98, 49),
}

function LeaderboardBase.new(...)
	local self = setmetatable(ComponentBase.new(...), LeaderboardBase)
	-- LeaderboardBase.Init(self, ...)
	return self
end

function LeaderboardBase:SetupLeaderboard(ins : Model, rankingInfo : SystemTypes.RankingInfo) : boolean
	self.instance = ins
	self.rankNum = 10

	local rankType = ins:GetAttribute("RankType")
	if not rankingInfo then
		warn("LeaderBoard Init failed dbInfo not found", rankType)
		return false
	end
	self.osdName = rankingInfo.Key
	self.osd = OrderedSaveDataManager.GetOrderedSaveData(self.osdName)
	if not self.osd then
		warn("LeaderBoard Init failed osdName="..self.osdName)
		return false
	end

	self.updatedConnection = self.osd:SetListener(function()
		self:OnDataUpdated()
	end)

	self.lastUpdateRequestTime = 0
	self.lastUpdatedTime = 0
	self.updateInterval = 5

	self.rankGui = self.instance:FindFirstChild("RankingGui", true) :: SurfaceGui
	self.listFrame = self.rankGui:FindFirstChild("ItemList", true) :: Frame
	self.rankElemTemplate = self.listFrame:FindFirstChild("Template", true) :: Frame
	self.rankElemTemplate.Visible = false
	self.rankElemTemplate.Parent = self.rankGui.Parent

	local rankingTitleText = self.instance:FindFirstChild("RankingTitleText", true) :: TextLabel
	if rankingTitleText then
		rankingTitleText.Text = rankingInfo.RankTitle
	end

	-- 初開更新
	self:UpdateLeaderBoard()

	return true
end
----------------------------------------------------------------------------------------------------
-- OnDataUpdated
function LeaderboardBase:OnDataUpdated()
	self:UpdateLeaderBoard()
end
----------------------------------------------------------------------------------------------------
-- GetUpdateElapsedTime
function LeaderboardBase:GetUpdateElapsedTime()
	return tick() - self.lastUpdatedTime
end
----------------------------------------------------------------------------------------------------
-- GetUpdateRequestElapsedTime
function LeaderboardBase:GetUpdateRequestElapsedTime()
	return tick() - self.lastUpdateRequestTime
end
----------------------------------------------------------------------------------------------------
-- SetUpdateInterval
function LeaderboardBase:SetUpdateInterval(interval : number)
	self.updateInterval = interval
end
----------------------------------------------------------------------------------------------------
-- ボード上のGUIを現在取得できるデータに基づき更新
function LeaderboardBase:UpdateLeaderBoard()
	self.lastUpdateRequestTime = tick()

	local elapTime = self:GetUpdateElapsedTime()
	-- 一定時間以内は更新スルー
	if elapTime <= self.updateInterval then
		print("LeaderboardManager:UpdateLeaderboards in short span called, skipped")
		return
	end

	print("Update Leaderboard start", self.instance.Name, self.osdName)

	local updateResult = true
	-- DBデータ取得
	local success, topPlayers = self.osd:GetOrderedData(self.rankNum)
	if not success then
		return false
	end

	-- User情報をまとめて取得
	local userIds = {}
	for index = 1, #topPlayers do
		userIds[index] = tonumber(topPlayers[index].key)
	end

	local userInfoSuccess, userInfos = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync(userIds)
	end)
	if not userInfoSuccess then
		print("GetUserInfosByUserIdsAsync failed")
		updateResult = false
	end

	-- サムネを先に取得してからボード更新
	for index = 1, #topPlayers do
		if index > self.rankNum then
			break
		end

		local data = topPlayers[index]
		local userId = tonumber(data.key)
		local img = UserThumbnailCache.GetUserThumbnailHeadShotAsync(userId)
		-- あとはキャッシュにのってる
	end

	-- ボード更新
	-- 古いデータ削除
	local children = self.listFrame:GetChildren()
	for _, child in children do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for index = 1, #topPlayers do
		if index > self.rankNum then
			break
		end

		local data = topPlayers[index]
		local userId = tonumber(data.key)
		local score = data.value
		if score <= 0 then
			break
		end

		local rank = index
		local name = "none"
		if userId and userId > 0 then
			-- UserInfoはテストキャラなどは抜けるのでIndexがずれうるのでFindする
			if userInfoSuccess then
				for _, userInfo in userInfos do
					if userInfo.Id == userId then
						name = userInfo.DisplayName
						break
					end
				end
			end
		else
			-- テストの場合Webアクセスで取ろうとすると取れない
			name = "Player"..math.abs(userId)
		end

		local elemFrame : Frame = self.rankElemTemplate:Clone()
		elemFrame.RankText.Text = rank
		elemFrame.NameText.Text = name
		elemFrame.ScoreText.Text = score

		local playerImage = elemFrame:FindFirstChild("PlayerImage") :: ImageLabel
		if playerImage then
			local img = UserThumbnailCache.GetUserThumbnailFromCache(userId)
			if img then
				playerImage.Image = img
			end
		end

		if RANK_COLORS[index] then
			elemFrame.RankText.TextColor3 = RANK_COLORS[index]
		end
		elemFrame.Visible = true
		elemFrame.Parent = self.listFrame
	end

	self.lastUpdatedTime = tick()

	return updateResult
end

return LeaderboardBase