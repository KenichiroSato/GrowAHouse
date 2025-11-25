local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserService = game:GetService("UserService")
local ServerScriptService = game:GetService("ServerScriptService")
local OrderedSaveDataManager = require(ServerScriptService.Nexsys.OrderedSaveDataManager)
local UserThumbnailCache = require(ReplicatedFirst.Nexsys.Common.UserThumbnailCache)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local InstanceHandler = require(ReplicatedFirst.Nexsys.Common.Instance.InstanceHandler)
local UserInfoManager = require(ServerScriptService.Nexsys.User.UserInfoManager)

--- @class LeaderboardHandler : InstanceHandler
local LeaderboardHandler = {}
LeaderboardHandler.__index = LeaderboardHandler
setmetatable(LeaderboardHandler, InstanceHandler)

----------------------------------------------------------------------------------------------------
-- 
local RANK_COLORS = {
	Color3.fromRGB(253, 192, 11),
	Color3.fromRGB(149, 208, 221),
	Color3.fromRGB(167, 98, 49),
}

----------------------------------------------------------------------------------------------------
-- 
function LeaderboardHandler.new(ins : Instance)
	local self = setmetatable(InstanceHandler.new(ins), LeaderboardHandler)
	LeaderboardHandler.Init(self)
	return self
end

function LeaderboardHandler:Init()
	self.updateEvent = Instance.new("BindableEvent")
end
----------------------------------------------------------------------------------------------------
--- Terminate
function LeaderboardHandler:Terminate()
	self.updateEvent:Destroy()
	self.updateEvent = nil
end
----------------------------------------------------------------------------------------------------
--- ConnectUpdateEvent
function LeaderboardHandler:ConnectUpdateEvent(callback : () -> ())
	self.updateEvent.Event:Connect(callback)
end
----------------------------------------------------------------------------------------------------
--- DisconnectUpdateEvent
function LeaderboardHandler:DisconnectUpdateEvent(callback : () -> ())
	self.updateEvent.Event:Disconnect(callback)
end
----------------------------------------------------------------------------------------------------
--- SetScoreFunction
function LeaderboardHandler:SetScoreFunction(scoreFunction : (score : number) -> (string))
	self.scoreFunction = scoreFunction
end
----------------------------------------------------------------------------------------------------
--- SetupLeaderboard
function LeaderboardHandler:SetupLeaderboard(rankingInfo : SystemTypes.RankingInfo) : boolean
	self.rankNum = 10
	self.osdName = rankingInfo.Key
	self.osd = OrderedSaveDataManager.GetOrderedSaveData(self.osdName)
	if not self.osd then
		warn("LeaderBoard Init failed, osd not found, osdName="..self.osdName)
		return false
	end

	self.updatedConnection = self.osd:SetListener(function(orderedData : { SystemTypes.OrderedDataStoreData })
		self:OnDataUpdated(orderedData)
	end)

	self.lastUpdateRequestTime = 0
	self.lastUpdatedTime = 0
	self.isUpdateDoing = false
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

	-- 初開更新 : DataUpdatedまかせ
	-- self:UpdateLeaderboard()

	-- 初回の更新
	while true do
		-- 別経路で更新済み
		if self.lastUpdatedTime > 0 then
			break
		end

		-- キャッシュがあればそれで更新
		if self.osd:IsDataReady() then
			self:UpdateLeaderboard()
			break
		end
		print("LeaderboardHandler:SetupLeaderboard wait for osd data...")
		task.wait(3)
	end

	return true
end
----------------------------------------------------------------------------------------------------
-- データ更新通知
function LeaderboardHandler:OnDataUpdated(orderedData : { SystemTypes.OrderedDataStoreData })
	self:UpdateLeaderboard(orderedData)
end
----------------------------------------------------------------------------------------------------
-- GetUpdateElapsedTime
function LeaderboardHandler:GetUpdateElapsedTime()
	return tick() - self.lastUpdatedTime
end
----------------------------------------------------------------------------------------------------
-- GetUpdateRequestElapsedTime
function LeaderboardHandler:GetUpdateRequestElapsedTime()
	return tick() - self.lastUpdateRequestTime
end
----------------------------------------------------------------------------------------------------
-- SetUpdateInterval
function LeaderboardHandler:SetUpdateInterval(interval : number)
	self.updateInterval = interval
end
----------------------------------------------------------------------------------------------------
-- ボード上のGUIを現在取得できるデータに基づき更新
function LeaderboardHandler:UpdateLeaderboard()
	if self.isUpdateDoing then
		print("LeaderboardHandler:UpdateLeaderboard isUpdateDoing, skipped", self.osdName)
		return
	end

	self.isUpdateDoing = true
	self:_updateLeaderboardCore()
	self.isUpdateDoing = false
end
----------------------------------------------------------------------------------------------------
--- 
function LeaderboardHandler:_updateLeaderboardCore()
	-- OrderedDataStoreのデータが取得されている場合のみ更新
	local orderedData = self.osd:GetOrderedDataInstant()
	if not orderedData then
		print("LeaderboardHandler:UpdateLeaderboard orderedData is nil, skipped", self.osdName)
		return false
	end

	print("Update Leaderboard start", self.instance.Name, self.osdName)

	local updateResult = true
	-- DBデータ取得

	-- User情報をまとめて取得
	local userIds = {}
	for index = 1, #orderedData do
		userIds[index] = tonumber(orderedData[index].key)
	end

	local userInfoSuccess, userInfos = pcall(function()
		-- print("GetUserInfosByUserIdsAsync start", #userIds, self.osdName)
		-- return UserService:GetUserInfosByUserIdsAsync(userIds)
		return UserInfoManager:GetUserInfosAsync(userIds)
	end)
	if not userInfoSuccess then
		warn("GetUserInfosByUserIdsAsync failed.", self.osdName, "error:", userInfos)
		updateResult = false
	end

	-- サムネを先に取得してからボード更新
	for index = 1, #orderedData do
		if index > self.rankNum then
			break
		end

		local data = orderedData[index]
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

	local rank = 1
	for index = 1, #orderedData do
		if rank > self.rankNum then
			break
		end

		local data = orderedData[index]
		local userId = tonumber(data.key)
		local score = data.value
		-- score0は除外
		if score <= 0 then
			continue
		end

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
		if self.scoreFunction then
			elemFrame.ScoreText.Text = self.scoreFunction(score)
		else
			elemFrame.ScoreText.Text = score
		end

		local playerImage = elemFrame:FindFirstChild("PlayerImage") :: ImageLabel
		if playerImage then
			local img = UserThumbnailCache.GetUserThumbnailFromCache(userId)
			if img then
				playerImage.Image = img
			end
		end

		if RANK_COLORS[rank] then
			elemFrame.RankText.TextColor3 = RANK_COLORS[rank]
		end
		elemFrame.Visible = true
		elemFrame.Parent = self.listFrame

		rank += 1
	end

	self.lastUpdatedTime = tick()

	self.updateEvent:Fire()

	return updateResult
end

return LeaderboardHandler