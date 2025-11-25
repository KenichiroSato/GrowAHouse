local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileService = require(ServerScriptService.Nexsys.ProfileService)
local Util = require(ReplicatedFirst.Nexsys.Common.Util)
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)

local PlayerSaveTemplate = GameDataProvider:GetPlayerSaveDataTemplate()
--- @class PlayerProfile : table
local PlayerProfile = {}
local ProfileStore = ProfileService.GetProfileStore(
    "PlayerSave",
	PlayerSaveTemplate
)

local Profiles = {}

----------------------------------------------------------------------------------------------------
-- LoadProfile
-- 基本は公式Wikiのサンプルをコピーしたもの
function PlayerProfile.LoadProfileAsync(player : Player)
	if Profiles[player] ~= nil then
		warn("Profile already loaded for player, loadProfile skipped : "..player.Name, player.UserId)
		return Profiles[player]
	end

	local profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId)
	if profile == nil then
		warn("Failed to load profile for player: "..player.Name, player.UserId)
		player:Kick("save data load failed")
		return nil
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		Profiles[player] = nil
		-- The profile could've been loaded on another Roblox server:
		player:Kick()
	end)
	if player:IsDescendantOf(Players) == true then
		Profiles[player] = profile
		-- A profile has been successfully loaded:
		-- DoSomethingWithALoadedProfile(player, profile)
	else
		-- Player left before the profile loaded:
		profile:Release()
	end

	Profiles[player.UserId] = profile
	return profile
end
----------------------------------------------------------------------------------------------------
-- ReleaseProfile
function PlayerProfile.ReleaseProfile(player : Player)
	local profile = Profiles[player]
	if profile == nil then
		return
	end
	profile:Release()
end
----------------------------------------------------------------------------------------------------
-- GetData
function PlayerProfile.GetProfileData(player : Player)
	local profile = Profiles[player]
	if profile == nil then
		return nil
	end
	return profile.Data
end
----------------------------------------------------------------------------------------------------
-- ResetData
function PlayerProfile.ResetProfileData(player : Player)
	local profile = Profiles[player]
	if profile == nil then
		return
	end

	-- 一度空にして、nil値や、古いKeyのものを削除
	-- profile.Data = {}
	-- 一度参照を維持したまま中身を空にする
	Util.TableClear(profile.Data)

	-- テーブル丸コピーは参照になってしまうので値をちゃんといれる
	Util.TableDeepCopy(PlayerSaveTemplate, profile.Data)

	-- nilのものはTableコピーではできないのでKeyですべて設定し直し
	-- for _idx, key in PlayerSaveTable.Keys do
	-- 	local val = PlayerSaveTable.Template[key]
	-- 	if type(val) == "table" then
	-- 		Util.TableDeepCopy(val, profile.Data[key])
	-- 	else
	-- 		profile.Data[key] = val
	-- 	end
	-- end
end
----------------------------------------------------------------------------------------------------
-- SaveProfileAsync
function PlayerProfile.SaveProfileAsync(player : Player)
	local profile = Profiles[player]
	if profile == nil then
		return
	end
	if profile:IsActive() == false then
		return
	end
	profile:Save()
	print("Save PlayerProfile manually done", player.Name, profile.Data)
end
----------------------------------------------------------------------------------------------------
-- GetDataValue
function PlayerProfile.GetDataValue(player : Player, key)
	local profile = Profiles[player]
	if profile == nil then
		return nil
	end
	return profile.Data[key]
end

----------------------------------------------------------------------------------------------------
-- SetDataValue
function PlayerProfile.SetDataValue(player : Player, key, value)
	local profile = Profiles[player]
	if profile == nil then
		return
	end
	profile.Data[key] = value
end
----------------------------------------------------------------------------------------------------
-- SetDataValueKey2
function PlayerProfile.SetDataValueKey2(player : Player, key1, key2, value)
	local profile = Profiles[player]
	if profile == nil then
		return
	end
	profile.Data[key1][key2] = value
end
----------------------------------------------------------------------------------------------------
-- SetDataValueKey3
function PlayerProfile.SetDataValueKey3(player : Player, key1, key2, key3, value)
	local profile = Profiles[player]
	if profile == nil then
		return
	end
	profile.Data[key1][key2][key3] = value
end

return PlayerProfile
