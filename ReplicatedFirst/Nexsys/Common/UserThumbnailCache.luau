--- @class UserThumbnailCache : table
local UserThumbnailCache = {}

local cacheTable = {}

function UserThumbnailCache.GetUserThumbnailHeadShotAsync(userId)
	if cacheTable[userId] then
		return cacheTable[userId]
	end

	local success, result = pcall(function()
		local image, isReady = game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		if isReady then
			cacheTable[userId] = image
		else
			-- リトライにしても変わらないっぽい（というか取れててもfalseになるっぽい）のでなしに
			-- warn("Leaderboard get userThumbnail failed userId="..playerId)
			-- updateResult = false
		end
	end)

	return cacheTable[userId]
end
----------------------------------------------------------------------------------------------------
-- GetUserThumbnailFromCache
function UserThumbnailCache.GetUserThumbnailFromCache(userId)
	return cacheTable[userId]
end

return UserThumbnailCache