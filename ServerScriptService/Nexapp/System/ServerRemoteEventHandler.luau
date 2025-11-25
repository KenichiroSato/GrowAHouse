local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local PlayerManager = require(ServerScriptService.Nexapp.Player.PlayerManager)
local SystemServerRemoteHandler = require(ServerScriptService.Nexsys.SystemServerRemoteHandler)
local ServerRemoteEventHandler = {}

----------------------------------------------------------------------------------------------------
local function onCommonServerEvent(player: Player, eventType, ...)
	local gp = PlayerManager.GetGamePlayer(player)
	if not gp then
		warn("onCommonServerEvent: not found gp", player, eventType)
		return
	end

	-- SystemServerRemoteHandlerへ移動予定
	if eventType == Define.CommonServerEvent.AreaStreamingRequest then
		return gp:OnAreaStreamingRequest(...)
	elseif eventType == Define.CommonServerEvent.ModelPersitantRequest then
		return gp:OnModelPersitantRequest(...)

	-- コンテンツ用
	else
		-- コンテンツ汎用
		-- RCS_funcName という形式想定で関数呼び出し
		if type(eventType) == "string" then
			if gp[eventType] then
				return gp[eventType](gp, ...)
			end

			local funcName = string.sub(eventType, 5)
			if gp[funcName] then
				return gp[funcName](gp, ...)
			end
		end
	end

	-- どこにもハンドリングされなかった場合システムへ
	return SystemServerRemoteHandler.onCommonServerEvent(player, eventType, ...)
end
----------------------------------------------------------------------------------------------------
--
function ServerRemoteEventHandler.Init()
	ReplicatedStorage.RemoteEvent.CommonServerEvent.OnServerEvent:Connect(onCommonServerEvent)

	ReplicatedStorage.RemoteEvent.CommonServerFunction.OnServerInvoke = onCommonServerEvent
end

return ServerRemoteEventHandler
