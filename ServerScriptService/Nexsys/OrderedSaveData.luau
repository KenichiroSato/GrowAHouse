local DataStoreService = game:GetService("DataStoreService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")
local UserThumbnailCache = require(ReplicatedFirst.Nexsys.Common.UserThumbnailCache)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)

--- @class OrderedSaveData : table
local OrderedSaveData = {}
OrderedSaveData.__index = OrderedSaveData

----------------------------------------------------------------------------------------------------
-- OrderedSaveData
-- 自分でソートしてキャッシュしたほうがいい気はする
----------------------------------------------------------------------------------------------------
-- 
function OrderedSaveData.new(osdInfo : SystemTypes.OrderedSaveDataInfo)
	local self = setmetatable({}, OrderedSaveData)
	OrderedSaveData.Init(self, osdInfo)
	return self
end

function OrderedSaveData:Init(osdInfo : SystemTypes.OrderedSaveDataInfo)
	self.ods = DataStoreService:GetOrderedDataStore(osdInfo.DBName)
	self.key = osdInfo.Key
	self.dataStoreName = osdInfo.DBName
	self.getNum = osdInfo.GetNum or 20
	self.isAscending = osdInfo.IsAscending or false

	self.updatedEvent = Instance.new("BindableEvent")

	self.cacheData = nil :: { SystemTypes.OrderedDataStoreData }

	-- 便利用よく使う詳細まで含むキャッシュデータ
	self.detailedData = nil

	-- 定期更新
	if osdInfo.UpdateInterval then
		self.updateInterval = osdInfo.UpdateInterval
		-- 更新間隔がずれないように更新の間隔は固定(API回数を散らすように)
		self.lastUpdateCacheTimeFromUpdate = 0
		task.spawn(function()
			if osdInfo.StartDelay then
				task.wait(osdInfo.StartDelay)
			end
			print("OrderedSaveData:Update start", self.dataStoreName)
			RunService.Heartbeat:Connect(function()
				self:Update()
			end)
		end)
	end
end
----------------------------------------------------------------------------------------------------
-- Update
function OrderedSaveData:Update()
	if not self.updateInterval then
		return
	end

	if os.time() - self.lastUpdateCacheTimeFromUpdate < self.updateInterval then
		return
	end

	task.spawn(function()
		-- print("OrderedSaveData:UpdateCacheDataAsync", self.dataStoreName)
		self.lastUpdateCacheTimeFromUpdate = os.time()
		self:UpdateCacheDataAsync()
		self.updatedEvent:Fire()
	end)
end
----------------------------------------------------------------------------------------------------
-- SetData
function OrderedSaveData:SetDataAsync(userId, value) : boolean
	local success, _result = pcall(function()
		self.ods:SetAsync(userId, value)
	end)

	if not success then
		warn("Osd:SetAsync failed", _result)
		return false
	end

	-- print("Osd:SetAsync success", self.dataStoreName, value)

	-- キャッシュからランクインしたかを確認
	if self:CheckRankIn(userId, value) then
		print("Osd:SetAsync rank in", self.dataStoreName, value)
		if self.updatedTask then
			task.cancel(self.updatedTask)
		end

		-- ランクインした場合更新と通知
		self.updatedTask = task.spawn(function()
			-- 他のプレイヤーのSetも同時に起こりやすいことを考慮して一定時間後に更新
			task.wait(3)

			self:UpdateCacheDataAsync()
			self.updatedEvent:Fire()
			-- 必要ならメッセージ送信も行うか
			self.updatedTask = nil
		end)
	end

	return success
end
----------------------------------------------------------------------------------------------------
-- SetDataSync
function OrderedSaveData:SetDataSync(userId, value)
	task.spawn(function()
		self:SetDataAsync(userId, value)
	end)
end

----------------------------------------------------------------------------------------------------
-- ClearData
function OrderedSaveData:ClearData(userId)
	local success, result = pcall(function()
		self.ods:RemoveAsync(userId)
	end)
end
----------------------------------------------------------------------------------------------------
-- GetDataAsync
function OrderedSaveData:GetDataAsync(userId)
	local success, result = pcall(function()
		return self.ods:GetAsync(userId)
	end)
	if not success then
		-- 失敗時はresultはエラーメッセージが入っている
		warn(result)
		return success, {}
	end

	return success, result
end
----------------------------------------------------------------------------------------------------
-- IsDataReady
function OrderedSaveData:IsDataReady()
	return self.cacheData ~= nil
end
----------------------------------------------------------------------------------------------------
-- 
function OrderedSaveData:GetOrderedData() : { SystemTypes.OrderedDataStoreData }
	if not self.cacheData then
		self:UpdateCacheDataAsync()
	end

	return table.clone(self.cacheData)
end
----------------------------------------------------------------------------------------------------
-- キャッシュで即時取得
function OrderedSaveData:GetOrderedDataInstant() : { SystemTypes.OrderedDataStoreData }?
	if not self.cacheData then
		return nil
	end
	return table.clone(self.cacheData)
end

----------------------------------------------------------------------------------------------------
-- キャッシュ更新、DataStoreからのデータ取得本体
function OrderedSaveData:UpdateCacheDataAsync() : (boolean, { SystemTypes.OrderedDataStoreData })
	-- print("OrderedSaveData:UpdateCacheDataAsync", self.dataStoreName)
	local success, result = pcall(function()
		return self.ods:GetSortedAsync(self.isAscending, self.getNum)
	end)
	if not success then
		warn("Osd:UpdateCacheDataAsync failed", result)
		return success
	end

	local topsData = result:GetCurrentPage()
	self.cacheData = topsData
	return success, topsData
end

----------------------------------------------------------------------------------------------------
-- SetListener
function OrderedSaveData:SetListener(callback) : RBXScriptConnection
	local connection = self.updatedEvent.Event:Connect(callback)
	return connection
end
----------------------------------------------------------------------------------------------------
-- CheckBadget
function OrderedSaveData:CheckRequestBudget()
	local budget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetSortedAsync)
	print("GetSortedAsync budget", budget)
	return budget
end

----------------------------------------------------------------------------------------------------
-- キャッシュからランクインしたかを確認
function OrderedSaveData:CheckRankIn(userId, value)
	if not self.cacheData then
		warn("OrderedSaveData:CheckRankIn cacheData is nil")
		return false
	end
	
	local lastData = self.cacheData[self.getNum]
	if not lastData then
		return true
	end

	if self.isAscending then
		if lastData.value < value then
			return true
		end
	else
		if lastData.value > value then
			return true
		end
	end

	return false
end
----------------------------------------------------------------------------------------------------
-- UpdateDetailedData
function OrderedSaveData:UpdateDetailedDataAsync(dataNum)
	-- Cacheを元に詳細データを更新
	if not self.cacheData then
		return
	end

	local updateResult = true
	local topPlayers = self.cacheData
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

	-- サムネを取得
	for index = 1, #topPlayers do
		if index > dataNum then
			break
		end

		local data = topPlayers[index]
		local userId = tonumber(data.key)
		local img = UserThumbnailCache.GetUserThumbnailHeadShotAsync(userId)
		-- あとはキャッシュにのってる
	end

	self.detailedData = {}
	for index = 1, #topPlayers do
		if index > dataNum then
			break
		end

		local data = topPlayers[index]
		local userId = tonumber(data.key)
		local score = data.value
		if score <= 0 then
			break
		end

		local rank = index
		-- RobloxWebアクセスになる
		local name = "none"
		if userId and userId > 0 then
			-- UserInfoはテストキャラなどは抜けるのでIndexがずれうるのでFindする
			if userInfoSuccess then
				for index, userInfo in userInfos do
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
		local img = UserThumbnailCache.GetUserThumbnailFromCache(userId)

		self.detailedData[index] = {
			UserId = userId,
			DisplayName = name,
			ImageId = img,
			Score = score,
			Rank = rank,
		}
	end

	self.lastUpdatedTime = tick()
end

return OrderedSaveData