local DataStoreService = game:GetService("DataStoreService")
--- @class DataStoreDumper : table
local DataStoreDumper = {}
DataStoreDumper.__index = DataStoreDumper
DataStoreDumper.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return DataStoreDumper
function DataStoreDumper.GetInstance()
	return DataStoreDumper.instance
end

function DataStoreDumper.new(...)
	local self = setmetatable({}, DataStoreDumper)
	DataStoreDumper.Init(self, ...)
	DataStoreDumper.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function DataStoreDumper:Init()
end

function DataStoreDumper:DumpDataStore()
	print("DumpDataStore start....")
	local ds = DataStoreService:GetDataStore("PlayerSave")
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

if not DataStoreDumper.instance then
	DataStoreDumper.new()
end

return DataStoreDumper.instance