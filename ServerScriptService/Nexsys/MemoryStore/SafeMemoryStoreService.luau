local ServerScriptService = game:GetService("ServerScriptService")
local SafeMemoryStoreHashMap = require(ServerScriptService.Nexsys.MemoryStore.SafeMemoryStoreHashMap)
local SafeMemoryStoreSortedMap = require(ServerScriptService.Nexsys.MemoryStore.SafeMemoryStoreSortedMap)
--- @class SafeMemoryStoreService : table
local SafeMemoryStoreService = {}
SafeMemoryStoreService.__index = SafeMemoryStoreService
SafeMemoryStoreService.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return SafeMemoryStoreService
function SafeMemoryStoreService.GetInstance()
	return SafeMemoryStoreService.instance
end

function SafeMemoryStoreService.new(...)
	local self = setmetatable({}, SafeMemoryStoreService)
	SafeMemoryStoreService.Init(self, ...)
	SafeMemoryStoreService.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function SafeMemoryStoreService:Init(...)
	self.safeSortedMaps = {}
	self.safeHashMaps = {}
end
----------------------------------------------------------------------------------------------------
-- GetSortedMap
--- @return SafeMemoryStoreSortedMap
function SafeMemoryStoreService:GetSortedMap(name : string)
	if not self.safeSortedMaps[name] then
		self.safeSortedMaps[name] = SafeMemoryStoreSortedMap.new(name)
	end
	return self.safeSortedMaps[name]
end
----------------------------------------------------------------------------------------------------
-- GetHashMap
--- @return SafeMemoryStoreHashMap
function SafeMemoryStoreService:GetHashMap(name : string)
	if not self.safeHashMaps[name] then
		self.safeHashMaps[name] = SafeMemoryStoreHashMap.new(name)
	end
	return self.safeHashMaps[name]
end

----------------------------------------------------------------------------------------------------
if SafeMemoryStoreService.instance == nil then
	SafeMemoryStoreService.new()
end
return SafeMemoryStoreService.instance