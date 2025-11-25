local DataStoreService = game:GetService("DataStoreService")
--- @class SafeDataStore : table
local SafeDataStore = {}
SafeDataStore.__index = SafeDataStore

----------------------------------------------------------------------------------------------------
-- 
function SafeDataStore.new(...)
	local self = setmetatable({}, SafeDataStore)
	SafeDataStore.Init(self, ...)
	return self
end

function SafeDataStore:Init(storeName : string)
	self.store = DataStoreService:GetDataStore(storeName)
end
----------------------------------------------------------------------------------------------------
--- GetAsync
function SafeDataStore:GetAsync(key : string) : any
	local success, result = pcall(function()
		return self.store:GetAsync(key)
	end)
	return success, result
end
----------------------------------------------------------------------------------------------------
--- GetAsyncWithRetry
function SafeDataStore:GetAsyncWithRetry(key : string, retryCount : number?, retryInterval : number?) : (boolean, any?)
	local tryCount = if retryCount then retryCount + 1 else 5
	local interval = if retryInterval then retryInterval else 0.2
	for i = 1, tryCount do
		local success, result = pcall(function()
			return self.store:GetAsync(key)
		end)
		if success then
			return true, result
		end
		warn("GetAsyncWithRetry failed", result, " interval:", interval)
		task.wait(interval)
		interval = interval * 2
	end
	return false
end

----------------------------------------------------------------------------------------------------
--- UpdateAsync
function SafeDataStore:UpdateAsync(key : string, callback : (any) -> any) : (boolean, any?)
	local success, result = pcall(function()
		return self.store:UpdateAsync(key, callback)
	end)
	return success, result
end

----------------------------------------------------------------------------------------------------
--- UpdateAsyncWithRetry
function SafeDataStore:UpdateAsyncWithRetry(key : string, callback : (any) -> any, retryCount : number?, retryInterval : number?) : (boolean, any?)
	local tryCount = if retryCount then retryCount + 1 else 5
	local interval = if retryInterval then retryInterval else 0.2
	for i = 1, tryCount do
		local success, result = pcall(function()
			return self.store:UpdateAsync(key, callback)
		end)
		if success then
			return true, result
		end
		warn("UpdateAsyncWithRetry failed", result, " interval:", interval)
		task.wait(interval)
		interval = interval * 2
	end
	return false
end

----------------------------------------------------------------------------------------------------
return SafeDataStore