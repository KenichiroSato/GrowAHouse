local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

--- @class TeleportPlaceModule : table
local TeleportPlaceModule = {}

----------------------------------------------------------------------------------------------------
-- テレポート関数
function TeleportPlaceModule.TeleportPlayer(placeId, player : Player)
	local players = {player}
	return TeleportPlaceModule.TeleportPlayersAsync(placeId, players)
end
----------------------------------------------------------------------------------------------------
-- パーティでテレポート
function TeleportPlaceModule.TeleportPlayersAsync(placeId, players : {Player}, teleportOptions : TeleportOptions?) : (boolean, string?)
	local success, errorMessage = pcall(function()
		-- TeleportPartyAsyncを使うと、飛べないキャラが出たり、非推奨でもあるのでそちらは使わない
		TeleportService:TeleportAsync(placeId, players, teleportOptions)
	end)

	if not success then
		warn("TeleportPlayersAsync failed: ", errorMessage)
		-- エラーをプレイヤーに通知する処理をここに追加できます
	end
	return success, errorMessage
end
----------------------------------------------------------------------------------------------------
-- 
function TeleportPlaceModule.TeleportPlayersToNewServerAsync(placeId, players : {Player}, userData : table?, teleportOptions : TeleportOptions?)
	local success, errorMessage = pcall(function()
		local option = teleportOptions or Instance.new("TeleportOptions")
		option.ShouldReserveServer = true
		if userData then
			option:SetTeleportData(userData)
		end
		return TeleportService:TeleportAsync(placeId, players, option)
	end)

	if not success then
		warn("TeleportPlayersToNewServerAsync failed: ", errorMessage)
		-- エラーをプレイヤーに通知する処理をここに追加できます
	end
	return success, errorMessage
end
----------------------------------------------------------------------------------------------------
-- ReserveServerAsync
function TeleportPlaceModule.ReserveServer(placeId) : string
	local success, reserveAccessCode = pcall(function()
		return TeleportService:ReserveServer(placeId)
	end)
	if not success then
		warn("ReserveServer failed: ", reserveAccessCode)
		return nil
	end

	return reserveAccessCode
end
----------------------------------------------------------------------------------------------------
-- TeleportToReservedServerAsync
function TeleportPlaceModule.TeleportToReservedServerAsync(placeId, players : {Player}, reserveAccessCode : string, userData : table)
	print("TeleportToReservedServerAsync", placeId, reserveAccessCode, players)

	local success, resultOrError = pcall(function()
		if RunService:IsStudio() then
			warn("TeleportToReservedServerAsync: Studio not supported")
			return false
		end
		local option = Instance.new("TeleportOptions")
		option.ReservedServerAccessCode = reserveAccessCode
		option:SetTeleportData(userData)
		local result = TeleportPlaceModule.TeleportPlayersAsync(placeId, players, option)
		return result
	end)

	if RunService:IsStudio() then
		success = false
	end

	if not success then
		warn("TeleportToReservedServerAsync failed:", resultOrError)
		-- エラーをプレイヤーに通知する処理をここに追加できます
	end
	return success, resultOrError
end
---------------------------------------------------------------------------------------------------
-- オプション：全プレイヤーをテレポートする関数
function TeleportPlaceModule.TeleportAllPlayers(placeId, shouldReserveServer : boolean?, serverId : string?)
	local players = Players:GetPlayers()
	local teleportOptions = Instance.new("TeleportOptions")
	if shouldReserveServer then
		teleportOptions.ShouldReserveServer = true
	end
	if serverId then
		teleportOptions.ServerInstanceId = serverId
	end

	local success, groupId = pcall(function()
		return TeleportService:TeleportAsync(placeId, players, teleportOptions)
	end)

	if not success then
		warn("グループテレポートに失敗しました: " .. tostring(groupId))
	else
		print("グループテレポート成功。GroupId: " .. groupId)
	end
end

return TeleportPlaceModule