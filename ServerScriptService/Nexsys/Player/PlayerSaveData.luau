local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerProfile = require(ServerScriptService.Nexsys.Player.PlayerProfile)
local PlayerSaveReplica = require(ReplicatedFirst.Nexsys.Common.ReplicaParams.PlayerSaveReplica)
----------------------------------------------------------------------------------------------------
-- PlayerのSaveData、システムモジュールのラッパー
-- 現在はProfileを使っているが代替可能に
-- SyncはReplica依存
----------------------------------------------------------------------------------------------------
--- @class PlayerSaveData : table
local PlayerSaveData = {}
PlayerSaveData.__index = PlayerSaveData

function PlayerSaveData.new(...)
	local self = setmetatable({}, PlayerSaveData)
	PlayerSaveData.Init(self, ...)
	return self
end

function PlayerSaveData:Init(player : Player)
	self.player = player
end
----------------------------------------------------------------------------------------------------
-- LoadDataAsync
function PlayerSaveData:LoadDataAsync()
	self.profile = PlayerProfile.LoadProfileAsync(self.player)
	print("PlayerSaveData:LoadDataAsync done", self.player.Name, self.profile.Data)

	self.replicaParams = PlayerSaveReplica.new(self.profile.Data, self.player)
end
----------------------------------------------------------------------------------------------------
-- ReleaseData
function PlayerSaveData:ReleaseData()
	if self.profile then
		PlayerProfile.ReleaseProfile(self.player)
		self.profile = nil
	end

	-- ReplicaのDestroy
	if self.replicaParams then
		self.replicaParams:Destroy()
		self.replicaParams = nil
	end
end
----------------------------------------------------------------------------------------------------
-- ResetSaveData
function PlayerSaveData:ResetSaveData()
	warn("PlayerSaveData:ResetSaveData", self.player.Name)
	PlayerProfile.ResetProfileData(self.player)

	if self.replicaParams then
		self.replicaParams:ForceSyncToClient()
	end
end
----------------------------------------------------------------------------------------------------
-- IsLoaded
function PlayerSaveData:IsLoaded()
	return self.profile ~= nil
end
----------------------------------------------------------------------------------------------------
-- SaveManually
function PlayerSaveData:SaveManually()
	task.spawn(function()
		PlayerProfile.SaveProfileAsync(self.player)
	end)
end
----------------------------------------------------------------------------------------------------
-- GetData
function PlayerSaveData:GetRawData()
	if self.profile == nil then
		return nil
	end
	return self.profile.Data
end
----------------------------------------------------------------------------------------------------
-- GetReplicaParams
function PlayerSaveData:GetReplicaParams()
	return self.replicaParams
end
----------------------------------------------------------------------------------------------------
-- SetDataValue
function PlayerSaveData:SetDataValue(key : string, value)
	if not self.profile then
		return
	end
	-- replicaにAPI経由で設定することで同期が走る
	-- 参照テーブルは同じなので、replicaに設定でprofileも更新される
	self.replicaParams:SetParam(key, value)
end
----------------------------------------------------------------------------------------------------
-- SetDataValueKey2
function PlayerSaveData:SetDataValueKey2(key1 : string, key2 : string, value)
	if not self.profile then
		return
	end

	self.replicaParams:SetParamKey2(key1, key2, value)
end
----------------------------------------------------------------------------------------------------
-- SetDataValueKey3
function PlayerSaveData:SetDataValueKey3(key1 : string, key2 : string, key3 : string, value, noSync)
	if not self.profile then
		return
	end

	self.replicaParams:SetParamKey3(key1, key2, key3, value)
end
----------------------------------------------------------------------------------------------------
-- AddDataArrayKey
function PlayerSaveData:AddDataArrayKey(key : string, value)
	if not self.profile then
		return
	end

	self.replicaParams:ArrayInsert(key, value)
end
----------------------------------------------------------------------------------------------------
-- RemoveDataArrayKeyByIndex
function PlayerSaveData:RemoveDataArrayKeyByIndex(key : string, index : number)
	if not self.profile then
		return
	end

	self.replicaParams:ArrayRemove(key, index)
end
----------------------------------------------------------------------------------------------------
-- RemoveDataArrayKeyByIndexes
function PlayerSaveData:RemoveDataArrayKeyByIndexes(key : string, indexes : {number})
	if not self.profile then
		return
	end

	self.replicaParams:ArrayRemoveByIndexes(key, indexes)
end

----------------------------------------------------------------------------------------------------
-- GetDataValue
function PlayerSaveData:GetDataValue(key : string)
	if not self.profile then
		return nil
	end

	return self.profile.Data[key]
end
----------------------------------------------------------------------------------------------------
-- GetDataValueKey2
function PlayerSaveData:GetDataValueKey2(key1 : string, key2 : string)
	if not self.profile then
		return nil
	end

	if self.profile.Data[key1] == nil then
		return nil
	end
	return self.profile.Data[key1][key2]
end
----------------------------------------------------------------------------------------------------
-- GetDataValueKey3
function PlayerSaveData:GetDataValueKey3(key1 : string, key2 : string, key3 : string)
	if not self.profile then
		return nil
	end

	if self.profile.Data[key1] == nil then
		return nil
	end
	if self.profile.Data[key1][key2] == nil then
		return nil
	end
	return self.profile.Data[key1][key2][key3]
end
----------------------------------------------------------------------------------------------------
-- GetDataArrayKeyByIndex
function PlayerSaveData:GetDataArrayKeyByIndex(key : string, index : number)
	if not self.profile then
		return nil
	end

	if self.profile.Data[key] == nil then
		return nil
	end
	return self.profile.Data[key][index]
end

----------------------------------------------------------------------------------------------------
-- ゲーム用API → PlayerDataでのみ実装する方針
----------------------------------------------------------------------------------------------------

return PlayerSaveData