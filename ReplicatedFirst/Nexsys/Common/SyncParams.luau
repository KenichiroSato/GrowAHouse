local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local SystemDefine = require(ReplicatedFirst.Nexsys.Common.SystemDefine)
local Util = require(ReplicatedFirst.Nexsys.Common.Util)
--- @class SyncParams : table
local SyncParams = {}
SyncParams.__index = SyncParams
----------------------------------------------------------------------------------------------------
--- @type SyncParams[]
local syncParamInstances_ = {}

if RunService:IsServer() then
	local updateConnection = RunService.Heartbeat:Connect(function()
		for index, syncParamIns in syncParamInstances_ do
			if syncParamIns.isDirty then
				syncParamIns:SyncToClient()
			end
		end
	end)
end

----------------------------------------------------------------------------------------------------
-- 
function SyncParams.new(...)
	local self = setmetatable({}, SyncParams)
	SyncParams.Init(self, ...)
	table.insert(syncParamInstances_, self)
	return self
end

function SyncParams:Init(player : Player?, initTable : {}?)
	self.player = player
	self.syncTable = {}
	if initTable then
		Util.TableDeepCopy(initTable, self.syncTable)
	end
	self.isDirty = false
end
----------------------------------------------------------------------------------------------------
-- Destroy
function SyncParams:Destroy()
	for index, syncParamIns in pairs(syncParamInstances_) do
		if syncParamIns == self then
			table.remove(syncParamInstances_, index)
			break
		end
	end
end
----------------------------------------------------------------------------------------------------
-- GetRawData
function SyncParams:GetRawData()
	return self.syncTable
end
----------------------------------------------------------------------------------------------------
-- SetParam
function SyncParams:SetParam(paramName, value)
	self.syncTable[paramName] = value
	self.isDirty = true
end
function SyncParams:SetParamSub(paramName, subParamName, value)
	self.syncTable[paramName][subParamName] = value
	self.isDirty = true
end
----------------------------------------------------------------------------------------------------
-- GetParam
function SyncParams:GetParam(paramName)
	return self.syncTable[paramName]
end

----------------------------------------------------------------------------------------------------
-- 以下サーバー処理
----------------------------------------------------------------------------------------------------
if RunService:IsServer() then
local ServerScriptService = game:GetService("ServerScriptService")
local ServerRemoteEventSender = require(ServerScriptService.Nexsys.ServerRemoteEventSender)
----------------------------------------------------------------------------------------------------
-- Sync(Server用)
function SyncParams:SyncToClient()
	print("SyncParams:SyncToClient", self.syncTable)
	-- Client同期
	if self.player then
		ServerRemoteEventSender.Send(self.player, SystemDefine.CommonClientEvent.SyncParams, self.syncTable)
	else
		ServerRemoteEventSender.SendToAll(SystemDefine.CommonClientEvent.GameSyncParams, self.syncTable)
	end

	self.isDirty = false
end
----------------------------------------------------------------------------------------------------
-- SyncToPlayer(Server用)
function SyncParams:SyncToPlayer(player : Player)
	-- print("GameSyncParamsBase:SyncToPlayer", player, self.syncTable)
	-- Client同期
	ServerRemoteEventSender.Send(player, SystemDefine.CommonClientEvent.GameSyncParams, self.syncTable)
end
----------------------------------------------------------------------------------------------------
-- 以下クライアント処理
----------------------------------------------------------------------------------------------------
elseif RunService:IsClient() then
----------------------------------------------------------------------------------------------------
-- OnSync(Cleint用)
function SyncParams:OnSyncToClient(syncTable)
	if RunService:IsStudio() then
		print("SyncParams:OnSyncToClient", syncTable)
	end

	local lastSyncTable = self.syncTable
	self.syncTable = syncTable
	if self.onSyncedToClient then
		self:onSyncedToClient(lastSyncTable, self.syncTable)
	end
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
end

return SyncParams