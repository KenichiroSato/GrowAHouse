local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
--- @class SafeMemoryStoreSortedMap : table
local SafeMemoryStoreSortedMap = {}
SafeMemoryStoreSortedMap.__index = SafeMemoryStoreSortedMap

----------------------------------------------------------------------------------------------------
-- 
function SafeMemoryStoreSortedMap.new(storeName : string)
	local self = setmetatable({}, SafeMemoryStoreSortedMap)
	SafeMemoryStoreSortedMap.Init(self, storeName)
	return self
end

function SafeMemoryStoreSortedMap:Init(storeName : string)
	self.store = MemoryStoreService:GetSortedMap(storeName)
end

----------------------------------------------------------------------------------------------------
-- GetAsync
function SafeMemoryStoreSortedMap:GetAsync(key : string, retryCount : number?, retryInterval : number?) : (any?, string?)
	local tryCount = if retryCount then retryCount + 1 else 1
	local interval = if retryInterval then retryInterval else 1
	for i = 1, tryCount do
		local success, result = pcall(function()
			return self.store:GetAsync(key)
		end)
		if success then
			return result
		end
		warn("SafeMemoryStoreSortedMap:GetAsync failed:", result)
		task.wait(interval)
	end
	return nil
end
----------------------------------------------------------------------------------------------------
-- GetRangeAsync
function SafeMemoryStoreSortedMap:GetRangeAsync(
	direction : Enum.SortDirection, count : number, exclusiveLowerBound, exclusiveUpperBound, retryCount : number?, retryInterval : number?
) : {SystemTypes.MemoryStoreGetRangeItem}
	local tryCount = if retryCount then retryCount + 1 else 1
	local interval = if retryInterval then retryInterval else 1
	for i = 1, tryCount do
		local success, result = pcall(function()
			return self.store:GetRangeAsync(direction, count, exclusiveLowerBound, exclusiveUpperBound)
		end)
		if success then
			return result
		end
		warn("SafeMemoryStoreSortedMap:GetRangeAsync failed:", result)
		task.wait(interval)
	end
	return {}
end
----------------------------------------------------------------------------------------------------
-- RemoveAsync
function SafeMemoryStoreSortedMap:RemoveAsync(key : string, retryCount : number?, retryInterval : number?) : boolean
	local tryCount = if retryCount then retryCount + 1 else 1
	local interval = if retryInterval then retryInterval else 1
	for i = 1, tryCount do
		local success, result = pcall(function()
			return self.store:RemoveAsync(key)
		end)
		if success then
			return true
		end
		warn("SafeMemoryStoreSortedMap:RemoveAsync failed:", result)
		task.wait(interval)
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- GetWithRetryAsync
function SafeMemoryStoreSortedMap:SetAsync(key : string, value : any, expiration : number, sortKey : any, retryCount : number?, retryInterval : number?) : boolean
	local tryCount = if retryCount then retryCount + 1 else 1
	local interval = if retryInterval then retryInterval else 1
	for i = 1, tryCount do
		local success, result = pcall(function()
			return self.store:SetAsync(key, value, expiration, sortKey)
		end)
		if success then
			return true
		end
		warn("SafeMemoryStoreSortedMap:SetAsync failed:", result)
		task.wait(interval)
	end
	return false
end

return SafeMemoryStoreSortedMap