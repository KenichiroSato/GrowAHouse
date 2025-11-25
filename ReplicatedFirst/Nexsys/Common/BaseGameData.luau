local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameReplicaParams = require(ReplicatedFirst.Nexsys.Common.ReplicaParams.GameReplicaParams)

--- @class BaseGameData : table
local BaseGameData = {}
BaseGameData.__index = BaseGameData

----------------------------------------------------------------------------------------------------
-- 共通のPlayerDataアクセサ
function BaseGameData.new(...)
	local self = setmetatable({}, BaseGameData)
	BaseGameData.Init(self, ...)
	return self
end

function BaseGameData:Init()
	--- @type GameReplicaParams
	self.replicaParams = nil

	-- Client用
	self.paramChangedEvent_ = Instance.new("BindableEvent")
end
----------------------------------------------------------------------------------------------------
-- 
function BaseGameData:Destroy()
	if self.replicaParams then
		self.replicaParams:Destroy()
		self.replicaParams = nil
	end
end
----------------------------------------------------------------------------------------------------
-- 
function BaseGameData:CreateSyncParam(dataTable : table)
	self.replicaParams = GameReplicaParams.new(dataTable)
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

BaseGameData.instance__ = nil
----------------------------------------------------------------------------------------------------
--- @return BaseGameData
function BaseGameData.Get()
	return BaseGameData.instance__
end
----------------------------------------------------------------------------------------------------
-- 
function BaseGameData.SetInstance(instance)
	assert(BaseGameData.instance__ == nil, "BaseGameData is singleton")
	BaseGameData.instance__ = instance
end

----------------------------------------------------------------------------------------------------
-- ConnectParamChanged
function BaseGameData:ConnectParamChanged(paramName, callback)
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
end
----------------------------------------------------------------------------------------------------
-- クライアント用実装終わり
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- サーバー用セッター
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--- SetAttribute
function BaseGameData:SetAttribute(key, val)
	ReplicatedStorage:SetAttribute(key, val)
end
----------------------------------------------------------------------------------------------------
-- SetSyncParamKey
function BaseGameData:SetSyncParamKey(key, val)
	if self.replicaParams == nil then
		warn("BaseGameData:SetSyncParamKey : replicaParams is nil", key, val)
		return
	end
	if RunService:IsClient() then
		warn("BaseGameData:SetSyncParam called in client, only usable on server!", key, val)
		return
	end

	self.replicaParams:SetParam(key, val)
end
----------------------------------------------------------------------------------------------------
-- ArrayInsert
function BaseGameData:ArrayInsert(key, val)
	if self.replicaParams == nil then
		warn("BaseGameData:ArrayInsert : replicaParams is nil", key, val)
		return
	end
	if RunService:IsClient() then
		warn("BaseGameData:ArrayInsert called in client, only usable on server!", key, val)
		return
	end
	self.replicaParams:ArrayInsert(key, val)
end
----------------------------------------------------------------------------------------------------
-- SetParamTable
function BaseGameData:SetParamTable(key, table : table)
	if self.replicaParams == nil then
		warn("BaseGameData:SetParamTable : replicaParams is nil", key, table)
		return
	end
	if RunService:IsClient() then
		warn("BaseGameData:SetParamTable called in client, only usable on server!", key, table)
		return
	end
	self.replicaParams:SetParamTable(key, table)
end
-- サーバー用セッター 終わり
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 共通アクセサ 
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--- GetAttribute
function BaseGameData:GetAttribute(key)
	return ReplicatedStorage:GetAttribute(key)
end
----------------------------------------------------------------------------------------------------
-- GetSyncParamKey
function BaseGameData:GetSyncParamKey(key)
	if self.replicaParams == nil then
		warn("BaseGameData:GetSyncParamKey : syncParam is nil", key)
		return nil
	end
	return self.replicaParams:GetParam(key)
end
----------------------------------------------------------------------------------------------------
-- SetSyncParamKey2
function BaseGameData:SetSyncParamKey2(key1, key2, val)
	if self.replicaParams == nil then
		warn("BaseGameData:SetSyncParamKey2 : syncParam is nil", key1, key2, val)
		return
	end
	if RunService:IsClient() then
		warn("BaseGameData:SetSyncParam called in client, only usable on server!", key1, key2, val)
		return
	end

	self.replicaParams:SetParamKey2(key1, key2, val)
end
----------------------------------------------------------------------------------------------------
-- GetSyncParamKey2
function BaseGameData:GetSyncParamKey2(key1, key2)
	if self.replicaParams == nil then
		warn("BaseGameData:GetSyncParamKey2 : syncParam is nil", key1, key2)
		return nil
	end
	return self.replicaParams:GetParamKey2(key1, key2)
end

----------------------------------------------------------------------------------------------------
-- ListenParamChanged
function BaseGameData:ListenParamChanged(callback)
	if self.replicaParams == nil then
		warn("BaseGameData:ListenParamChanged : syncParam is nil")
		return
	end

	local connection = self.replicaParams:ListenParamChanged(callback)
	return connection
end
----------------------------------------------------------------------------------------------------
--- ListenAttributeChanged
function BaseGameData:ListenAttributeChanged(key, callback)
	ReplicatedStorage:GetAttributeChangedSignal(key):Connect(callback)
end

return BaseGameData
