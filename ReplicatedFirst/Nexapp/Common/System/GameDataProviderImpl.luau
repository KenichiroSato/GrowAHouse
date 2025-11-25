local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local IGameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.IGameDataProvider)

--- @class GameDataProvider : IGameDataProvider
local GameDataProviderImpl = {}
GameDataProviderImpl.__index = GameDataProviderImpl
setmetatable(GameDataProviderImpl, IGameDataProvider)

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
function GameDataProviderImpl.new(...)
	local self = setmetatable(IGameDataProvider.new(...), GameDataProviderImpl)
	IGameDataProvider.SetInstance(self)
	return self
end

----------------------------------------------------------------------------------------------------
-- 実装インターフェース : 共通
----------------------------------------------------------------------------------------------------
function GameDataProviderImpl:GetTextData()
	return require(self:GetExdataFolder().TextData)
end

function GameDataProviderImpl:GetDataFolder() : Folder
	return ReplicatedFirst.Nexapp.Data
end

function GameDataProviderImpl:GetExdataFolder() : Folder
	return ReplicatedFirst.Exdata
end
----------------------------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------------------------
-- 実装インターフェース : サーバー用
----------------------------------------------------------------------------------------------------
if RunService:IsServer() then
local ServerScriptService = game:GetService("ServerScriptService")

function GameDataProviderImpl:GetPlayerSaveDataTemplate()
	local PlayerSaveTable = require(ReplicatedFirst.Nexapp.Common.System.PlayerSaveTable)
	return PlayerSaveTable.Template
end

function GameDataProviderImpl:GetComponentFolder() : Folder
	return ServerScriptService.Nexapp.Component
end

function GameDataProviderImpl:GetOrderedSaveDataInfos() : table
	return require(ServerScriptService.Nexapp.Data.OrderedSaveDataInfos)
end

----------------------------------------------------------------------------------------------------
-- 実装インターフェース : クライアント用
----------------------------------------------------------------------------------------------------
elseif RunService:IsClient() then
function GameDataProviderImpl:GetUIModuleFolder()
	return ReplicatedFirst.Nexapp.Client.UI
end

function GameDataProviderImpl:GetComponentFolder() : Folder
	return ReplicatedFirst.Nexapp.Client.Component
end
----------------------------------------------------------------------------------------------------
-- 実装インターフェース終わり
----------------------------------------------------------------------------------------------------
end

----------------------------------------------------------------------------------------------------
if GameDataProviderImpl.instance == nil then
	GameDataProviderImpl.new()
end
return GameDataProviderImpl.instance