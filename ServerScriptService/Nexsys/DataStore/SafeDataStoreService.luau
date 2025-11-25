local ServerScriptService = game:GetService("ServerScriptService")
local SafeDataStore = require(ServerScriptService.Nexsys.DataStore.SafeDataStore)

--- @class SafeDataStoreService : table
local SafeDataStoreService = {}
SafeDataStoreService.__index = SafeDataStoreService
SafeDataStoreService.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return SafeDataStoreService
function SafeDataStoreService.GetInstance()
	return SafeDataStoreService.instance
end

function SafeDataStoreService.new(...)
	local self = setmetatable({}, SafeDataStoreService)
	SafeDataStoreService.Init(self, ...)
	SafeDataStoreService.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function SafeDataStoreService:Init(...)
	self.safeDataStores = {}
end
----------------------------------------------------------------------------------------------------
--- @return SafeDataStore
function SafeDataStoreService:GetDataStore(name : string) : table
	if not self.safeDataStores[name] then
		self.safeDataStores[name] = SafeDataStore.new(name)
	end
	return self.safeDataStores[name]
end

----------------------------------------------------------------------------------------------------
if SafeDataStoreService.instance == nil then
	SafeDataStoreService.new()
end
return SafeDataStoreService.instance