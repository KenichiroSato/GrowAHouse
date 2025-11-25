--!strict
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")

--[=[
	ユーザー情報の取得とキャッシュを管理するシングルトンマネージャー。
]=]
---@class UserInfoManager
local UserInfoManager = {}
UserInfoManager.__index = UserInfoManager

-- キャッシュの有効期間（秒）
local CACHE_DURATION_SECONDS = 24 * 60 * 60 -- 1日

type UserInfo = {
	Id: number,
	Username: string,
	DisplayName: string,
	HasVerifiedBadge: boolean,
}

type CacheEntry = {
	info: UserInfo,
	cachedAt: number,
}

type UserInfoCache = { [number]: CacheEntry }

---@type UserInfoManager
local _instance = nil

--[=[
	Constructs a new UserInfoManager. This should only be called by the singleton accessor.
	@return UserInfoManager
]=]
function UserInfoManager.new()
	local self = setmetatable({}, UserInfoManager)
	self._cache = {} :: UserInfoCache
	return self
end

--[=[
	指定されたユーザーIDのリストに対応するUserInfoオブジェクトのリストを非同期で取得します。
	結果はキャッシュから提供されるか、必要に応じてUsersServiceからフェッチされます。

	@param userIds {number} - 情報を取得するユーザーIDのリスト。
	@return {UserInfo} - 要求されたユーザーIDに対応するUserInfoオブジェクトのリスト。順序は入力リストと同じです。取得できなかった場合はnilが含まれます。
]=]
function UserInfoManager:GetUserInfosAsync(userIds: {number}): {UserInfo?}
	local userIdsToFetch = {}
	local now = os.time()

	-- キャッシュを確認し、フェッチが必要なIDをリストアップ（重複排除）
	local uniqueUserIds = {}
	local seen = {}
	for _, id in ipairs(userIds) do
		if not seen[id] then
			table.insert(uniqueUserIds, id)
			seen[id] = true
		end
	end

	for _, userId in ipairs(uniqueUserIds) do
		local cachedData = self._cache[userId]
		if not cachedData or (now - cachedData.cachedAt >= CACHE_DURATION_SECONDS) then
			table.insert(userIdsToFetch, userId)
		end
	end

	-- フェッチが必要なIDがある場合
	if #userIdsToFetch > 0 then
		-- UsersService:GetUserInfosByUserIdsAsync は一度に100件までしか取得できないため、100件ごとに分割してリクエストします
		for i = 1, #userIdsToFetch, 100 do
			local chunk = {}
			for j = i, math.min(i + 99, #userIdsToFetch) do
				table.insert(chunk, userIdsToFetch[j])
			end

			local success, result = pcall(function()
				-- 429エラー(250件/分)オーバー対処向け計測用
				if RunService:IsStudio() then
					print("UserInfoManager:GetUserInfosAsync called: request count:", #chunk)
				end
				return UserService:GetUserInfosByUserIdsAsync(chunk)
			end)

			if success then
				for _, userInfo in ipairs(result) do
					-- バラけるようにcache時間にジッターをかけるといいかも
					local jitter = math.random(0, 1000)
					self._cache[userInfo.Id] = { info = userInfo, cachedAt = now + jitter }
				end
			else
				warn(("[UserInfoManager] Failed to fetch user infos. Error: %s"):format(tostring(result)))
			end
		end
	end

	-- 元の `userIds` の順序で結果を構築
	local finalResults = {}
	for _, userId in ipairs(userIds) do
		local cachedData = self._cache[userId]
		if cachedData then
			table.insert(finalResults, cachedData.info)
		else
			table.insert(finalResults, nil)
		end
	end

	return finalResults
end

--[=[
	単一のユーザーIDに対応するUserInfoオブジェクトを非同期で取得します。

	@param userId number - 情報を取得するユーザーID。
	@return UserInfo? - 要求されたユーザーIDに対応するUserInfoオブジェクト。取得できなかった場合はnil。
]=]
function UserInfoManager:GetUserInfoAsync(userId: number): UserInfo?
	local results = self:GetUserInfosAsync({ userId })
	return results[1]
end

-- return (function()
-- 	if not _instance then
-- 		_instance = UserInfoManager.new()
-- 	end
-- 	return _instance
-- end)()

----------------------------------------------------------------------------------------------------
if _instance == nil then
	_instance = UserInfoManager.new()
end
return _instance