local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SystemRemoteEventHandler_ = require(ReplicatedFirst.Nexsys.Client.SystemRemoteEventHandler_)
local EventManager_ = require(ReplicatedFirst.Nexsys.Client.Event.EventManager_)
local EventData = require(ReplicatedFirst.Nexapp.Data.EventData)
--local PopUpModule_ = require(ReplicatedFirst.Nexapp.Client.System.PopUpModule_)
--local GameRemoteProcessor_ = require(ReplicatedFirst.Nexapp.Client.System.GameRemoteProcessor_)

--- @class GameRemoteEventHandler_ : table
local GameRemoteEventHandler_ = {}

----------------------------------------------------------------------------------------------------
-- RemoteEvent、RemoteFunction共通のイベントハンドラ
local function onCommonEvent(eventType, ...)
	--チュートリアル関係
	for key, velue in EventData do
		if key == eventType then
			print("sato EventManager_.StartEvent(key)", key)
			EventManager_.StartEvent(key)
			return
		end
	end
	
	return SystemRemoteEventHandler_.onCommonEvent(eventType, ...)
	-- システムに移行したい検討中
	--[[
	if eventType == "RSC_PlayPopUp" then
		PopUpModule_.PlayWithPopUpType(...)
	else
		-- コンテンツ処理はGameRemoteProcessor_に移動
		local procFunc = GameRemoteProcessor_[eventType]
		if procFunc then
			return procFunc(...)
		-- システムに流れる
		else
			return SystemRemoteEventHandler_.onCommonEvent(eventType, ...)
		end
	end
	return nil
	]]
end
----------------------------------------------------------------------------------------------------
-- 
function GameRemoteEventHandler_.Init()
	ReplicatedStorage.RemoteEvent.CommonRemoteEvent.OnClientEvent:Connect(onCommonEvent)

	ReplicatedStorage.RemoteEvent.CommonClientFunction.OnClientInvoke = onCommonEvent
end
return GameRemoteEventHandler_