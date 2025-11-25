local DataStoreService = game:GetService("DataStoreService")
local ds = DataStoreService:GetDataStore("PlayerSave")

--- @class PlayerSaveDataModule : table
local PlayerSaveDataModule = {}
PlayerSaveDataModule.__index = PlayerSaveDataModule
PlayerSaveDataModule.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return PlayerSaveDataModule
function PlayerSaveDataModule.GetInstance()
	return PlayerSaveDataModule.instance
end

function PlayerSaveDataModule.new(...)
	local self = setmetatable({}, PlayerSaveDataModule)
	PlayerSaveDataModule.Init(self, ...)
	PlayerSaveDataModule.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function PlayerSaveDataModule:Init()
end

----------------------------------------------------------------------------------------------------
-- RemoveSaveData
function PlayerSaveDataModule:RemoveSaveData(userId)
	if not userId then
		warn("RemoveSaveData: userId is nil")
		return
	end

	local key = "Player_" .. userId
	local result = pcall(function()
		ds:RemoveAsync(key)
	end)
	local userName = game.Players:GetNameFromUserIdAsync(tonumber(userId))
	print("RemoveSaveData done. result", result, "key", key, userName)
end

----------------------------------------------------------------------------------------------------
-- ResetSaveDataAll
function PlayerSaveDataModule:RemoveSaveDataAll()
	print("RemoveSaveDataAll start....")
	local pages = ds:ListKeysAsync()

	-- Players#GetFriendsAsync のドキュメントの処理
	local function iterPageItems(_pages)
		return coroutine.wrap(function()
			local pagenum = 1
			while true do
				for _, item in ipairs(_pages:GetCurrentPage()) do
					coroutine.yield(item, pagenum)
				end
				if _pages.IsFinished then
					break
				end
				_pages:AdvanceToNextPageAsync()
				pagenum = pagenum + 1
			end
		end)
	end

	local infos = {}
	for item, _pageNo in iterPageItems(pages) do
		item = item :: DataStoreKey
		table.insert(infos, item)

		local saveData = ds:GetAsync(item.KeyName)
		if not saveData then
			warn("RemoveSaveDataAll: saveData GetAsync faild", item.KeyName)
			continue
		end
		local data = saveData.Data
		print(item.KeyName, data)
		-- Player_1234567890 のKeyからUserIdのみに分解
		local userId = item.KeyName:match("Player_(%d+)")
		if not userId then
			warn("RemoveSaveDataAll: userId get failed", item.KeyName)
			continue
		end
		self:RemoveSaveData(userId)

		task.wait(1)
	end

	print("RemoveSaveDataAll completed.")
end

----------------------------------------------------------------------------------------------------
--
function PlayerSaveDataModule:DumpDataStore()
	print("DumpDataStore start....")
	local pages = ds:ListKeysAsync()

	-- Players#GetFriendsAsync のドキュメントの処理
	local function iterPageItems(_pages)
		return coroutine.wrap(function()
			local pagenum = 1
			while true do
				for _, item in ipairs(_pages:GetCurrentPage()) do
					coroutine.yield(item, pagenum)
				end
				if _pages.IsFinished then
					break
				end
				_pages:AdvanceToNextPageAsync()
				pagenum = pagenum + 1
			end
		end)
	end

	local infos = {}
	for item, _pageNo in iterPageItems(pages) do
		item = item :: DataStoreKey
		table.insert(infos, item)

		local data = ds:GetAsync(item.KeyName).Data
		print(item.KeyName, data)
		-- Player_1234567890 のKeyからUserIdのみに分解
		local userId = item.KeyName:match("Player_(%d+)")
		local userName = game.Players:GetNameFromUserIdAsync(tonumber(userId))
		print("name", userId, userName)

		task.wait(1)
	end

	print("DumpDataStore end")
	print(infos)
	return infos
end

----------------------------------------------------------------------------------------------------
if PlayerSaveDataModule.instance == nil then
	PlayerSaveDataModule.new()
end
return PlayerSaveDataModule.instance