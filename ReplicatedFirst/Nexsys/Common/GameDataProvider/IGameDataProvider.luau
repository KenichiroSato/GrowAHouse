local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
--- @class IGameDataProvider : table
local IGameDataProvider = {}
IGameDataProvider.__index = IGameDataProvider
---@type IGameDataProvider
IGameDataProvider.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return IGameDataProvider
function IGameDataProvider.SetInstance(ins)
	if IGameDataProvider.instance then
		error("IGameDataProvider instance is already set")
	end

	IGameDataProvider.instance = ins
end

function IGameDataProvider.new(...)
	local self = setmetatable({}, IGameDataProvider)
	return self
end
----------------------------------------------------------------------------------------------------
-- 実装インターフェース : 共通
----------------------------------------------------------------------------------------------------
function IGameDataProvider:GetTextData() : table end
function IGameDataProvider:GetDataFolder() : table end
function IGameDataProvider:GetExdataFolder() : table end
----------------------------------------------------------------------------------------------------
-- 実装インターフェース : サーバー用
----------------------------------------------------------------------------------------------------
if RunService:IsServer() then
function IGameDataProvider:GetPlayerSaveDataTemplate() : table end
function IGameDataProvider:GetComponentFolder() : Folder end
function IGameDataProvider:GetOrderedSaveDataInfos() : table
	assert(false, "GetOrderedSaveDataInfos is not implemented")
end
----------------------------------------------------------------------------------------------------
-- 実装インターフェース : クライアント用
----------------------------------------------------------------------------------------------------
elseif RunService:IsClient() then
function IGameDataProvider:GetUIModuleFolder() : Folder end
function IGameDataProvider:GetComponentFolder() : Folder end
----------------------------------------------------------------------------------------------------
-- 実装インターフェース終わり
----------------------------------------------------------------------------------------------------
end

----------------------------------------------------------------------------------------------------
return IGameDataProvider