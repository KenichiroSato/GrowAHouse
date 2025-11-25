local MemoryStoreService = game:GetService("MemoryStoreService")

--- @class SafeMemoryStoreHashMap : table
local SafeMemoryStoreHashMap = {}
SafeMemoryStoreHashMap.__index = SafeMemoryStoreHashMap

----------------------------------------------------------------------------------------------------
-- 
function SafeMemoryStoreHashMap.new(...)
	local self = setmetatable({}, SafeMemoryStoreHashMap)
	SafeMemoryStoreHashMap.Init(self, ...)
	return self
end

function SafeMemoryStoreHashMap:Init(storeName : string)
	self.store = MemoryStoreService:GetHashMap(storeName)
	-- 今回向けにセーフティでデフォは1時間
	self.expirationTime = 60 * 60
end
----------------------------------------------------------------------------------------------------
-- 
function SafeMemoryStoreHashMap:SetAsync(key : string, value : any, expirationTime : number?) : (boolean, string?)
	local expTime = expirationTime or self.expirationTime
	local success, result = pcall(function()
		return self.store:SetAsync(key, value, expTime)
	end)
	return success, result
end
----------------------------------------------------------------------------------------------------
-- 
function SafeMemoryStoreHashMap:SetWithRetryAsync(key : string, value : any, expirationTime : number?, retryInterval : number?) : (boolean, string?)
	local expTime = expirationTime or self.expirationTime
	local interval = retryInterval or 1
	local errorLog
	for i = 1, 10 do
		local success, result = pcall(function()
			return self.store:SetAsync(key, value, expTime)
		end)
		if success and result then
			return true
		end

		-- 失敗 : 通常起きないはずで検出用
		errorLog = result
		warn("SetWithRetryAsync failed", success, errorLog)
		task.wait(interval)
	end
	return false, errorLog
end
----------------------------------------------------------------------------------------------------
-- GetRange
function SafeMemoryStoreHashMap:GetRangeAsync() : any
	local success, result = pcall(function()
		return self.store:GetRangeAsync()
	end)
end
----------------------------------------------------------------------------------------------------
--- GetAsync
function SafeMemoryStoreHashMap:GetAsync(key : string) : (boolean, any)
	local success, result = pcall(function()
		return self.store:GetAsync(key)
	end)
	return success, result
end
----------------------------------------------------------------------------------------------------
-- GetWithRetryAsync
function SafeMemoryStoreHashMap:GetWithRetryAsync(key : string) : any
	for i = 1, 10 do
		local success, result = pcall(function()
			return self.store:GetAsync(key)
		end)
		if success then
			return result
		end
		warn("GetWithRetryAsync failed", success, result)
		task.wait(1)
	end
	return nil
end
----------------------------------------------------------------------------------------------------
-- RemoveWithRetryAsync
function SafeMemoryStoreHashMap:RemoveWithRetryAsync(key : string) : boolean
	for i = 1, 10 do
		local success, result = pcall(function()
			self.store:RemoveAsync(key)
		end)
		if success then
			return true
		end
		warn("RemoveWithRetryAsync failed", success, result)
		task.wait(1)
	end
	return false
end

return SafeMemoryStoreHashMap