local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedFirst.Nexsys.Common.Util)

--- @class ReplicaParams : table
local ReplicaParams = {}
ReplicaParams.__index = ReplicaParams

----------------------------------------------------------------------------------------------------
-- 
function ReplicaParams.new(tokenName, dataTable, player : Player?)
	local self = setmetatable({}, ReplicaParams)
	if RunService:IsServer() then
		ReplicaParams.InitOnServer(self, tokenName, dataTable, player)
	elseif RunService:IsClient() then
		ReplicaParams.InitOnClient(self, tokenName)
	end
	return self
end

----------------------------------------------------------------------------------------------------
-- Destroy
function ReplicaParams:Destroy()
	if self.replica then
		self.replica:Destroy()
	end
end

----------------------------------------------------------------------------------------------------
-- サーバー実装開始
if RunService:IsServer() then
----------------------------------------------------------------------------------------------------
-- 
local tokens = {}
----------------------------------------------------------------------------------------------------
--
function ReplicaParams:InitOnServer(tokenName, dataTable, player : Player?)
	local ServerScriptService = game:GetService("ServerScriptService")
	local ReplicaService = require(ServerScriptService.Nexsys.ReplicaService)

	local token = tokens[tokenName]
	if not token then
		token = ReplicaService.NewClassToken(tokenName)
		tokens[tokenName] = token
	end

	if player then
		if RunService:IsStudio() then
			print("ReplicaParams Created on Server: " .. tokenName, dataTable, player)
		end
		self.replica = ReplicaService.NewReplica({
			ClassToken = token,
			Tags = {Player = player},
			Data = dataTable,
			Replication = player,
		})
	else
		if RunService:IsStudio() then
			print("ReplicaParams Created on Server: " .. tokenName, dataTable)
		end
		self.replica = ReplicaService.NewReplica({
			ClassToken = token,
			Data = dataTable,
			Replication = "All",
		})
	end
end
----------------------------------------------------------------------------------------------------
-- 
function ReplicaParams:ForceSyncToClient()
	-- 同期メソッドがないので再設定で同期
	local data = self:GetRawData()
	for key, val in data do
		self.replica:SetValue({key}, val)
	end
end

----------------------------------------------------------------------------------------------------
end
-- サーバー実装終わり
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- クライアント実装開始
if RunService:IsClient() then
----------------------------------------------------------------------------------------------------
--
function ReplicaParams:InitOnClient(tokenName)
	print("ReplicaParams : InitOnClient")
	local ReplicaController = require(ReplicatedStorage.Nexsys.Replica.ReplicaController)
	local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)

	assert(not SystemDataModule_.IsReplicaRequested(), "ReplicaParams cannot be created after ReplicaRequested")

	ReplicaController.ReplicaOfClassCreated(tokenName, function(replica)
		print("ReplicaOfClassCreated")
		self.replica = replica
		-- print("ReplicaParams Created on Client: " .. tokenName, replica)

		if self.onReplicaCreated then
			self:onReplicaCreated()
		end

		if RunService:IsStudio() then
			replica:ListenToRaw(function(_action_name, path_array, params)
				local path = Util.GetPathString(path_array)
				if path == "Coin" then return end
				print("["..tokenName.."]", path, params, self.replica.Data)
			end)
		end
	end)
end
----------------------------------------------------------------------------------------------------
--- IsReplicaLoaded
function ReplicaParams:IsReplicaLoaded()
	return self.replica ~= nil
end
----------------------------------------------------------------------------------------------------
end
-- クライアント実装終わり
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 
function ReplicaParams:GetRawData()
	if self.replica then
		return self.replica.Data
	end
	return nil
end

----------------------------------------------------------------------------------------------------
-- Set系メソッド
-- サーバーのみで初期化時点でインスタンス存在保証される
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- SetParam
function ReplicaParams:SetParam(key, value)
	if RunService:IsClient() then
		warn("ReplicaParams:SetParam() failed; Client cannot set param")
		return
	end

	self.replica:SetValue({key}, value)
end
----------------------------------------------------------------------------------------------------
-- SetParamKey2
function ReplicaParams:SetParamKey2(key1, key2, value)
	if RunService:IsClient() then
		warn("ReplicaParams:SetParam() failed; Client cannot set param")
		return
	end

	local data = self.replica.Data
	if data[key1] == nil then
		self.replica:SetValue({key1}, {})
	end
	self.replica:SetValue({key1, key2}, value)
end
----------------------------------------------------------------------------------------------------
-- SetParamKey3
function ReplicaParams:SetParamKey3(key1, key2, key3, value)
	if RunService:IsClient() then
		warn("ReplicaParams:SetParam() failed; Client cannot set param")
		return
	end

	local data = self.replica.Data
	if data[key1] == nil then
		self.replica:SetValue({key1}, {})
	end
	if data[key1][key2] == nil then
		self.replica:SetValue({key1, key2}, {})
	end
	self.replica:SetValue({key1, key2, key3}, value)
end
----------------------------------------------------------------------------------------------------
-- 
function ReplicaParams:SetParamTable(key, table : table)
	if RunService:IsClient() then
		warn("ReplicaParams:SetParamArray() failed; Client cannot set param")
		return
	end

	self.replica:SetValues({key}, table)
end
----------------------------------------------------------------------------------------------------
-- ArrayInsert
function ReplicaParams:ArrayInsert(key, value)
	if RunService:IsClient() then
		warn("ReplicaParams:ArrayInsert() failed; Client cannot set param")
		return
	end

	local data = self.replica.Data
	if data[key] == nil then
		self.replica:SetValue({key}, {})
	end
	self.replica:ArrayInsert({key}, value)
end
----------------------------------------------------------------------------------------------------
-- ArrayRemove
function ReplicaParams:ArrayRemove(key, index)
	if RunService:IsClient() then
		warn("ReplicaParams:ArrayRemove() failed; Client cannot set param")
		return
	end

	local data = self:GetRawData()
	if data[key] == nil then
		return
	end
	self.replica:ArrayRemove({key}, index)
end
----------------------------------------------------------------------------------------------------
-- ArrayRemoveByIndexes
function ReplicaParams:ArrayRemoveByIndexes(key : string, indexes : {number})
	if RunService:IsClient() then
		warn("ReplicaParams:ArrayRemoveByIndexes() failed; Client cannot set param")
		return
	end

	local data = self:GetRawData()
	if data[key] == nil then
		return
	end
	-- 一応sortして、後ろから削除することでずれないように
	table.sort(indexes)
	for i = #indexes, 1, -1 do
		self.replica:ArrayRemove({key}, indexes[i])
	end
end
----------------------------------------------------------------------------------------------------
-- Get系メソッド
-- クライアントでは初回同期されるまでdataはnilとなる
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetParam
function ReplicaParams:GetParam(key)
	local data = self:GetRawData()
	if not data then
		return nil
	end
	return data[key]
end
----------------------------------------------------------------------------------------------------
-- GetParamKey2
function ReplicaParams:GetParamKey2(key1, key2)
	local data = self:GetRawData()
	if not data then
		return nil
	end
	if data[key1] == nil then
		return nil
	end
	return data[key1][key2]
end
----------------------------------------------------------------------------------------------------
-- GetParamKey3
function ReplicaParams:GetParamKey3(key1, key2, key3)
	local data = self:GetRawData()
	if not data then
		return nil
	end
	if data[key1] == nil then
		return nil
	end
	if data[key1][key2] == nil then
		return nil
	end
	return data[key1][key2][key3]
end

----------------------------------------------------------------------------------------------------
-- ListenParamChanged
--- @param callback fun(action_name: string, path_array: table, params: table)
function ReplicaParams:ListenParamChanged(callback)
	if not self.replica then
		warn("ReplicaParams:ListenParamChanged() failed; Replica not initialized")
		return nil
	end

	local connection = self.replica:ListenToRaw(callback)
	return connection
end

return ReplicaParams