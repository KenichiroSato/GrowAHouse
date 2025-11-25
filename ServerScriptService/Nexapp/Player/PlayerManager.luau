local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptService = game:GetService("ServerScriptService")
local GamePlayer = require(ServerScriptService.Nexapp.Player.GamePlayer)
local BadgeManager = require(ServerScriptService.Nexsys.BadgeManager)
local HouseBaseManager = require(ServerScriptService.Nexapp.House.HouseBaseManager)

local PlayerManager = {}
---@type table<number, GamePlayer>
PlayerManager.GamePlayers = {}

-- センサーインのコールバック
PlayerManager.PlayerSernsorInEvent = Instance.new("BindableEvent")
----------------------------------------------------------------------------------------------------
-- 
function PlayerManager.Start()
	Players.PlayerAdded:Connect(PlayerManager.OnPlayerAdded)
	Players.PlayerRemoving:Connect(PlayerManager.OnPlayerRemoving)
	RunService.Stepped:Connect(PlayerManager.OnUpdate)
	RunService.Heartbeat:Connect(PlayerManager.OnHeartbeat)

	local players = game.Players:GetPlayers()
	for _, player in ipairs(players) do
		PlayerManager.OnPlayerAdded(player)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerManager.OnUpdate(elapsedTime, deltaTime)
	for index, gp in PlayerManager.GamePlayers do
		gp:Update(deltaTime)
	end
end
----------------------------------------------------------------------------------------------------
-- OnHeartbeat
function PlayerManager.OnHeartbeat(dt)
	for index, gp in PlayerManager.GamePlayers do
		gp:OnHeartbeat(dt)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerManager.OnPlayerAdded(player : Player)
	print("PlayerManager.OnPlayerAdded :", player.Name, player.UserId)

	-- LoadCharacter前に設定が必要
	player.CharacterAdded:Connect(function(character)
		PlayerManager.OnCharacterAdded(player, character)
	end)
	player.CharacterAppearanceLoaded:Connect(function(character)
		PlayerManager.OnCharacterAppearanceLoaded(player, character)
	end)

	local cp = GamePlayer.new(player)
	PlayerManager.GamePlayers[player.UserId] = cp
	local base = HouseBaseManager.Assign(player)
	if base then
		print(player.Name, "に", base.Name, "を割り当てました")
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerManager.OnCharacterAdded(player : Player, character : Model)
	-- print("PlayerManager.OnCharacterAdded :", player.Name, player.UserId)

	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			PlayerManager.OnPlayerDied(player)
		end)
	end

	local gp = PlayerManager.GetGamePlayer(player)
	if gp then
		gp:OnCharacterAdded(player, character)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerManager.OnCharacterAppearanceLoaded(player : Player, character)
	-- print("PlayerManager.OnCharacterAppearanceLoaded :", player.Name, player.UserId)

	local gp = PlayerManager.GetGamePlayer(player)
	if gp then
		gp:OnCharacterAppearanceLoaded(player, character)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerManager.OnPlayerDied(player : Player)
	local gp = PlayerManager.GetGamePlayer(player)
	if gp then
		gp:OnPlayerDied(player)
	end

	-- 死んだときは3秒まってから復帰するように
	-- wait(3)
	-- 死ぬのは現状はミニゲームのはずなので、センターに戻す
	-- player.RespawnLocation = workspace.CenterSpawn
	-- player:LoadCharacter()
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerManager.OnPlayerRemoving(player : Player)
	print("PlayerManager.OnPlayerRemoving : player.UserId="..player.UserId)

	local gp = PlayerManager.GetGamePlayer(player)
	if gp then
		gp:OnPlayerRemoving(player)
	end

	-- GamePlayer削除
	PlayerManager.GamePlayers[player.UserId] = nil
	HouseBaseManager.Release(player)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.OnSensorIn(sensorRange, humPart : Part)
	local humChara = humPart.Parent
	local gp = PlayerManager.GetGamePlayerByCharacter(humChara)
	if not gp then return end

	gp:OnSensorIn(sensorRange, humPart, humChara)

	-- コールバック(コールバックはObjectは渡さない。コピーで渡るため想定外挙動を避けるため)
	local sensorType = sensorRange:GetSensorType()
	PlayerManager.PlayerSernsorInEvent:Fire(gp.Player, sensorType)


	-- local hum : Humanoid = humChara.Humanoid
	-- hum.JumpPower = 0
	-- hum.HipHeight = hum.HipHeight + 5
end
----------------------------------------------------------------------------------------------------
-- GetGamePlayer
--- @return GamePlayer
function PlayerManager.GetGamePlayer(player : Player)
	return PlayerManager.GamePlayers[player.UserId]
end
----------------------------------------------------------------------------------------------------
-- GetGamePlayerByUserId
function PlayerManager.GetGamePlayerByUserId(userId : number)
	if typeof(userId) == "string" then
		userId = tonumber(userId)
	end

	return PlayerManager.GamePlayers[userId]
end

function PlayerManager.GetGamePlayerByCharacter(chara : Model)
	local player : Player = Players:GetPlayerFromCharacter(chara)
	if player then
		return PlayerManager.GamePlayers[player.UserId]
	end
	return nil
end

function PlayerManager.GetAllGamePlayers()
	return PlayerManager.GamePlayers
end

function PlayerManager.GetPlayerData(player: Player)
	return PlayerManager.GetGamePlayer(player):GetPlayerData()
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.GetPlayerOfPart(part)
	if part.Parent:FindFirstChild("Humanoid") then
		local player = Players:GetPlayerFromCharacter(part.Parent)
		return player
	end
	return nil
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.GetPlayerFromCharacter(chara : Model) : Player
	local player : Player = Players:GetPlayerFromCharacter(chara)
	return player
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.GetPlayers()
	return Players:GetPlayers()
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.GetPlayersInRange(range)
	local players = {}
	local overlapResults = workspace:GetPartsInPart(range)
	
	for _, part in ipairs(overlapResults) do
		if part.Name == "HumanoidRootPart" then
			local player = Players:GetPlayerFromCharacter(part.Parent)
			if player then
				table.insert(players, player)
			end
		end
	end	
	return players
end
----------------------------------------------------------------------------------------------------
-- ExecFunctionToAll
function PlayerManager.ExecFunctionToAll(func)
	for _index, gp in PlayerManager.GamePlayers do
		func(gp)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.AnnouceTalkToAll(str, talkerImage, nameText)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireAllClients(
		Define.CommonClientEvent.AnnounceTalk, str, talkerImage, nameText)
end
----------------------------------------------------------------------------------------------------
-- AnnounceToAll
function PlayerManager.AnnounceToAll(textKey, ...)
	--- @type GamePlayer
	for _index, gp in PlayerManager.GamePlayers do
		gp:Announce(textKey, ...)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.ScreenFadeOutAll(fadeTime)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireAllClients(
		Define.CommonClientEvent.FadeOut, fadeTime)
end
function PlayerManager.ScreenFadeInAll(fadeTime)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireAllClients(
		Define.CommonClientEvent.FadeIn, fadeTime)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.FadeInUIAll(uiElem, fadeTime)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireAllClients(
		Define.CommonClientEvent.FadeInUI, uiElem, fadeTime)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.FadeInScreenGUIAll(guiName, fadeTime)
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireAllClients(
		Define.CommonClientEvent.FadeInScreenGUI, guiName, fadeTime)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.SitToSeatAll()
	for index, gp in PlayerManager.GamePlayers do
		gp:SitToSeat()
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.LockPlayers()
	for index, gp in PlayerManager.GamePlayers do
		gp:SetControllable(false)
	end
end

function PlayerManager.UnlockPlayers()
	for index, gp in PlayerManager.GamePlayers do
		gp:SetControllable(true)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.ChangeBGMAllPlayers(bgm)
	for index, gp in PlayerManager.GamePlayers do
		gp:PlayBGM(bgm)
	end
end
function PlayerManager.ChangeRespawnPointAllPlayers(point : Part)
	for index, gp in PlayerManager.GamePlayers do
		gp:SetRespawnPoint(point)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerManager.TeleportPlaceAllPlayers()
	for index, gp in PlayerManager.GamePlayers do
		if gp then
			gp:TeleportPlace()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
---@return table<number, GamePlayer>
function PlayerManager.GetAutoMatchingActivePlayers() 
	local activePlayers = {}
	for index, gp in PlayerManager.GamePlayers do
		if gp then
			if not gp:IsNoAutoMatchingMode() and not gp:IsSelectMatching() then
				table.insert(activePlayers, gp)
			end
		end
	end
	return activePlayers
end

return PlayerManager :: Types.PlayerManager

