local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PlayerReplicaParams = require(ReplicatedFirst.Nexsys.Common.ReplicaParams.PlayerReplicaParams)
local PlayerSaveReplica = require(ReplicatedFirst.Nexsys.Common.ReplicaParams.PlayerSaveReplica)

--- @class BasePlayerData : table
local BasePlayerData = {}
BasePlayerData.__index = BasePlayerData

----------------------------------------------------------------------------------------------------
-- 共通のPlayerDataアクセサ
function BasePlayerData.new(...)
	local self = setmetatable({}, BasePlayerData)
	BasePlayerData.Init(self, ...)
	return self
end

function BasePlayerData:Init(player : Player)
	self.player = player

	-- サーバーのセット用
	--- @type PlayerSaveData
	self.saveDataIns = nil

	-- 
	self.saveReplicaParams = nil

	-- Client用
	self.paramChangedEvent_ = Instance.new("BindableEvent")
	self.saveDataParam1ChangeCallbacks = {}
	self.syncParamChangeCallbacks = {}
	-- Client用終わり
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayerData:Destroy()
	if self.replicaParams then
		self.replicaParams:Destroy()
		self.replicaParams = nil
	end
end
----------------------------------------------------------------------------------------------------
--- @param saveData PlayerSaveData
function BasePlayerData:SetSaveDataIns(saveData)
	self.saveDataIns = saveData
	self:SetSaveReplicaParams(saveData:GetReplicaParams())
end
----------------------------------------------------------------------------------------------------
-- CreateSyncParam
function BasePlayerData:CreateSyncParam(tableTemplate : table)
	self.replicaParams = PlayerReplicaParams.new(tableTemplate, self.player)
end
----------------------------------------------------------------------------------------------------
-- SetSaveReplicaParams
function BasePlayerData:SetSaveReplicaParams(replicaParams)
	self.saveReplicaParams = replicaParams
end
----------------------------------------------------------------------------------------------------
-- CreateSaveReplicaParams
function BasePlayerData:CreateSaveReplicaParams(dataTable)
	self.saveReplicaParams = PlayerSaveReplica.new(dataTable, self.player)
end
----------------------------------------------------------------------------------------------------
-- GetPlayer
function BasePlayerData:GetPlayer()
	return self.player
end
----------------------------------------------------------------------------------------------------
-- IsSaveDataLoaded
function BasePlayerData:IsSaveDataLoaded()
	if RunService:IsServer() then
		return self.saveDataIns ~= nil
	else
		return self.saveReplicaParams and self.saveReplicaParams:IsReplicaLoaded()
	end
end

----------------------------------------------------------------------------------------------------
-- サーバー用実装 開始
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- サーバー用実装 終わり
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- クライアント用実装
----------------------------------------------------------------------------------------------------
if RunService:IsClient() then

BasePlayerData.instance__ = nil
----------------------------------------------------------------------------------------------------
--- @return BasePlayerData
function BasePlayerData.Get()
	return BasePlayerData.instance__
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayerData.SetInstance(instance)
	assert(BasePlayerData.instance__ == nil, "BasePlayerData is singleton")
	BasePlayerData.instance__ = instance
end
----------------------------------------------------------------------------------------------------
-- ConnectParamChanged
function BasePlayerData:ConnectParamChanged(paramName, callback)
	local connection = self.paramChangedEvent_.Event:Connect(function(lastTable, syncedTable)
		local lastVal = lastTable[paramName]
		local curVal = syncedTable[paramName]
		if  lastVal ~= curVal  then
			-- Value.Changedと同じ感じで使えるように、まずは現在値を渡す
			callback(curVal, lastVal)
		end
	end)

	return connection
end
----------------------------------------------------------------------------------------------------
-- ConnectSyncParamChanged
function BasePlayerData:ConnectSyncParamChanged(paramName, callback)
	local connection = self.replicaParams:ListenParamChanged(function(action_name, path_array, params)
		if path_array[1] == paramName then
			callback(params)
		end
	end)
	return connection
end
----------------------------------------------------------------------------------------------------
-- ConnectSaveDataChanged
function BasePlayerData:ConnectSaveDataChanged(paramName, callback)
	warn("ConnectSaveDataChanged deprecated, use ListenToSaveDataChanged instead")
	local connection = self.saveReplicaParams:ListenParamChanged(function(action_name, path_array, params)
		if path_array[1] == paramName then
			callback(params)
		end
	end)
	return connection
end
----------------------------------------------------------------------------------------------------
-- ListenToSaveDataChanged
function BasePlayerData:StartListenToSaveDataChanged()
	if self.saveDataChangedConnection then
		print("BasePlayerData:StartListenToSaveDataChanged : already listening")
		self.saveDataChangedConnection:Disconnect()
		self.saveDataChangedConnection = nil
	end

	self.saveDataChangedConnection = self.saveReplicaParams:ListenParamChanged(function(action_name, path_array, params)
		-- print("SaveDataChanged", path_array[1], action_name, path_array, params)
		for paramName, callbacks in pairs(self.saveDataParam1ChangeCallbacks) do
			if path_array[1] == paramName then
				for _, callback in ipairs(callbacks) do
					callback(params, path_array)
				end
			end
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- ListenToSaveDataChanged
function BasePlayerData:ListenToSaveDataParam1Changed(paramName, callback)
	if not self.saveDataParam1ChangeCallbacks[paramName] then
		self.saveDataParam1ChangeCallbacks[paramName] = {}
	end
	table.insert(self.saveDataParam1ChangeCallbacks[paramName], callback)
	return callback
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayerData:UnlistenToSaveDataParam1Changed(paramName, callback)
	local callbacks = self.saveDataParam1ChangeCallbacks[paramName]
	if callbacks then
		table.remove(callbacks, table.find(callbacks, callback))
	end
end

----------------------------------------------------------------------------------------------------
-- 
function BasePlayerData:StartListenToSyncParamChanged()
	if self.syncParamChangedConnection then
		print("BasePlayerData:StartListenToSyncParamChanged : already listening")
		self.syncParamChangedConnection:Disconnect()
		self.syncParamChangedConnection = nil
	end

	self.syncParamChangedConnection = self.replicaParams:ListenParamChanged(function(action_name, path_array, params)
		-- print("SaveDataChanged", path_array[1], action_name, path_array, params)
		for paramName, callbacks in pairs(self.syncParamChangeCallbacks) do
			if path_array[1] == paramName then
				for _, callback in ipairs(callbacks) do
					callback(params, path_array)
				end
			end
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- ListenToSyncParamChanged
function BasePlayerData:ListenToSyncParamChanged(paramName, callback)
	if not self.syncParamChangeCallbacks[paramName] then
		self.syncParamChangeCallbacks[paramName] = {}
	end
	table.insert(self.syncParamChangeCallbacks[paramName], callback)
	return callback
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayerData:UnlistenToSyncParamChanged(paramName, callback)
	local callbacks = self.syncParamChangeCallbacks[paramName]
	if callbacks then
		table.remove(callbacks, table.find(callbacks, callback))
	end
end

----------------------------------------------------------------------------------------------------
end
----------------------------------------------------------------------------------------------------
-- クライアント用実装終わり
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 共通アクセサ 
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetSaveDataVersion
function BasePlayerData:GetSaveDataVersion()
	return self:GetSaveDataKey("Version")
end
----------------------------------------------------------------------------------------------------
-- GetSaveDataKey
function BasePlayerData:GetSaveDataKey(key)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:GetSaveDataKey : saveData is nil", key)
		return nil
	end
	return self.saveReplicaParams:GetParam(key)
end
----------------------------------------------------------------------------------------------------
-- GetSaveDataKey2
function BasePlayerData:GetSaveDataKey2(key1, key2)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:GetSaveDataKey : saveData is nil", key1, key2)
		return nil
	end
	return self.saveReplicaParams:GetParamKey2(key1, key2)
end
----------------------------------------------------------------------------------------------------
-- GetSaveDataKey3
function BasePlayerData:GetSaveDataKey3(key1, key2, key3)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:GetSaveDataKey : saveData is nil", key1, key2, key3)
		return nil
	end
	return self.saveReplicaParams:GetParamKey3(key1, key2, key3)
end
----------------------------------------------------------------------------------------------------
-- SetSaveDataKey(サーバー用)
function BasePlayerData:SetSaveDataKey(key, val)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:SetSaveDataKey : saveData is nil", key, val)
		return
	end

	self.saveReplicaParams:SetParam(key, val)
end
----------------------------------------------------------------------------------------------------
-- SetSaveDataKey2
function BasePlayerData:SetSaveDataKey2(key1, key2, val)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:SetSaveDataKey2 : saveData is nil", key1, key2, val)
		return
	end
	self.saveReplicaParams:SetParamKey2(key1, key2, val)
end
----------------------------------------------------------------------------------------------------
-- SetSaveDataKey3
function BasePlayerData:SetSaveDataKey3(key1, key2, key3, val, notSync)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:SetSaveDataKey3 : saveData is nil", key1, key2, key3, val)
		return
	end
	self.saveReplicaParams:SetParamKey3(key1, key2, key3, val, notSync)
end
----------------------------------------------------------------------------------------------------
-- AddSaveDataArray
function BasePlayerData:AddSaveDataArrayKey(key, val)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:AddSaveDataArray : saveData is nil", key, val)
		return
	end
	self.saveReplicaParams:ArrayInsert(key, val)
end
----------------------------------------------------------------------------------------------------
-- RemoveSaveDataArrayKey
function BasePlayerData:RemoveSaveDataArrayKey(key, val)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:RemoveSaveDataArrayKeyByIndex : saveData is nil", key, index)
		return
	end
	local arrayData = self:GetSaveDataKey(key)
	local index = table.find(arrayData, val)
	if index then
		self.saveReplicaParams:ArrayRemove(key, index)
	else
		warn("BasePlayerData:RemoveSaveDataArrayKey : not found", key, val)
	end
end
----------------------------------------------------------------------------------------------------
-- RemoveSaveDataArrayKeyByIndex
function BasePlayerData:RemoveSaveDataArrayKeyByIndex(key, index)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:RemoveSaveDataArrayKeyByIndex : saveData is nil", key, index)
		return
	end
	self.saveReplicaParams:ArrayRemove(key, index)
end
----------------------------------------------------------------------------------------------------
-- RemoveSaveDataArrayKeyByIndexes
function BasePlayerData:RemoveSaveDataArrayKeyByIndexes(key, indexes)
	if self.saveReplicaParams == nil then
		warn("BasePlayerData:RemoveSaveDataArrayKeyByIndexes : saveData is nil", key, indexes)
		return
	end
	self.saveReplicaParams:ArrayRemoveByIndexes(key, indexes)
end
----------------------------------------------------------------------------------------------------
-- SetSyncParamKey
function BasePlayerData:SetSyncParamKey(key, val)
	if self.replicaParams == nil then
		warn("BasePlayerData:SetSyncParamKey : replicaParams is nil", key, val)
		return
	end
	if RunService:IsClient() then
		warn("BasePlayerData:SetSyncParam called in client, only usable on server!", key, val)
		return
	end

	self.replicaParams:SetParam(key, val)
end
----------------------------------------------------------------------------------------------------
-- GetSyncParamKey
function BasePlayerData:GetSyncParamKey(key)
	if self.replicaParams == nil then
		warn("BasePlayerData:GetSyncParamKey : syncParam is nil", key)
		return nil
	end
	return self.replicaParams:GetParam(key)
end
----------------------------------------------------------------------------------------------------
-- SetSyncParamKey2
function BasePlayerData:SetSyncParamKey2(key1, key2, val)
	if self.replicaParams == nil then
		warn("BasePlayerData:SetSyncParamKey2 : replicaParams is nil", key1, key2, val)
		return
	end
	if RunService:IsClient() then
		warn("BasePlayerData:SetSyncParam called in client, only usable on server!", key1, key2, val)
		return
	end

	self.replicaParams:SetParamKey2(key1, key2, val)
end
----------------------------------------------------------------------------------------------------
-- GetSyncParamKey2
function BasePlayerData:GetSyncParamKey2(key1, key2)
	if self.replicaParams == nil then
		warn("BasePlayerData:GetSyncParamKey2 : replicaParams is nil", key1, key2)
		return nil
	end

	return self.replicaParams:GetParamKey2(key1, key2)
end
----------------------------------------------------------------------------------------------------
-- SetAttribute
function BasePlayerData:SetAttribute(attrName, value)
	self.player:SetAttribute(attrName, value)
end
----------------------------------------------------------------------------------------------------
-- GetAttribute
function BasePlayerData:GetAttribute(attrName)
	return self.player:GetAttribute(attrName)
end
----------------------------------------------------------------------------------------------------
-- キャラにつけるObjectValue(キャラリセでリセットしたいパラメータ)
function BasePlayerData:SetCharacterObjectValue(name, object : Instance)
	if not self.player.Character then
		warn("BasePlayerData:SetCharacterObjectValue : character is nil", name, object)
		return
	end

	local character = self.player.Character
	local objectValue : ObjectValue = character:FindFirstChild(name)
	if not objectValue then
		objectValue = Instance.new("ObjectValue")
		objectValue.Parent = character
	end
	objectValue.Name = name
	objectValue.Value = object
end
----------------------------------------------------------------------------------------------------
-- GetCharacterObjectValue	
function BasePlayerData:GetCharacterObjectValue(name) : Instance?
	if not self.player.Character then
		return nil
	end

	local character = self.player.Character
	local objectValue : ObjectValue = character:FindFirstChild(name)
	if not objectValue then
		return nil
	end
	return objectValue.Value
end


return BasePlayerData