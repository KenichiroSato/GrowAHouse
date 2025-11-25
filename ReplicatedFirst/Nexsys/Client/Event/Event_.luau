local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FadeController_ = require(ReplicatedFirst.Nexsys.Client.Event.FadeController_)
local WaitEvent_ = require(ReplicatedFirst.Nexsys.Client.Event.WaitEvent_)
local CutsceneController_ = require(ReplicatedFirst.Nexsys.Client.Event.CutsceneController_)
local CameraManager_ = require(ReplicatedFirst.Nexsys.Client.CameraManager_)
local UIManager_ = require(ReplicatedFirst.Nexsys.Client.UIManager_)
local TalkSequencer_ = require(ReplicatedFirst.Nexsys.Client.Event.TalkSequencer_)
local EventInstType = require(ReplicatedFirst.Nexsys.Common.Data.EventInstType)
local ModelUtil = require(ReplicatedFirst.Nexsys.Common.ModelUtil)
local RemoteSender_ = require(ReplicatedFirst.Nexsys.Client.RemoteSender_)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)

local Event_ = {}
Event_.__index = Event_

local gameEventTaskHandler_ = nil

----------------------------------------------------------------------
--　クライアントイベント処理
----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- クラス実装
----------------------------------------------------------------------------------------------------
function Event_.new(...)
	local self = setmetatable({}, Event_)
	Event_.Init(self, ...)
	return self
end
----------------------------------------------------------------------------------------------------
-- 
function Event_.newFromEventData(eventData : table, param : SystemTypes.EventParam?)
	local self = setmetatable({}, Event_)
	Event_.InitFromEventData(self, eventData, param)
	return self
end
----------------------------------------------------------------------------------------------------
-- SetGameEventHandler : ゲームイベントハンドラーを設定
function Event_.SetGameEventTaskHandler(gameEventHandler)
	gameEventTaskHandler_ = gameEventHandler
end
----------------------------------------------------------------------------------------------------
-- GetEventData
function Event_.GetEventData(eventKey)
	local EventData = require(GameDataProvider:GetDataFolder().EventData)
	return EventData[eventKey]
end

----------------------------------------------------------------------------------------------------
-- メンバ実装
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function Event_:Init(eventKey, param : SystemTypes.EventParam?)
	local data = Event_.GetEventData(eventKey)
	if not data then
		error("event " .. eventKey .. " not found")
	end

	self:InitFromEventData(data, param)
end
----------------------------------------------------------------------------------------------------
-- InitFromEventData
function Event_:InitFromEventData(eventData : table, param : SystemTypes.EventParam?)
	self.eventData = eventData
	self.isEnd = false
	self.param = param

	self:startEventTask(1)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function Event_:Update()
	local isNext = false

	-- タスクの終了チェック
	if self.eventTask then
		if self.eventTask:IsEnd() then
			isNext = true
		end
	else
		isNext = true
	end

	-- 次開始 or 終了
	if isNext then
		if self.eventTaskIndex == #self.eventData then
			-- イベント全体終了
			self.isEnd = true
		else
			self:startEventTask(self.eventTaskIndex + 1)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function Event_:IsEnd()
	return self.isEnd
end
----------------------------------------------------------------------------------------------------
-- GetEventParam
function Event_:GetEventParam()
	return self.param
end
----------------------------------------------------------------------------------------------------
-- GetTalker
function Event_:GetTalker()
	return self.param and self.param.Talker
end
----------------------------------------------------------------------------------------------------
-- 
function Event_:startEventTask(taskIndex)
	self.eventTaskIndex = taskIndex
	self.eventTaskData = self.eventData[taskIndex]

	local eventTaskType = self.eventTaskData[1]
	if not eventTaskType then
		error("eventTaskType is nil")
	end

	if eventTaskType == EventInstType.TalkSequence then
		-- トーク
		local talker = self.param and self.param.Talker
		local talkEndTime = self.param and self.param.TalkEndTime
		TalkSequencer_:Start(self.eventTaskData[2], talker, talkEndTime)
		self.eventTask = TalkSequencer_
	elseif eventTaskType == EventInstType.CutScene then
		-- カット用処理
		local cutController = CutsceneController_.new()
		cutController:Start(self.eventTaskData[2], self.param)
		self.eventTask = cutController
	elseif eventTaskType == EventInstType.FadeOut then
		-- フェードアウト
		local fadeController = FadeController_.new()
		fadeController:StartFadeOut(self.eventTaskData[2])
		self.eventTask = fadeController
	elseif eventTaskType == EventInstType.FadeIn then
		-- フェードイン
		local fadeController = FadeController_.new()
		fadeController:StartFadeIn(self.eventTaskData[2])
		self.eventTask = fadeController
	-- elseif eventTaskType == EventInstType.WarpPlayers then
	-- 	-- 全プレイヤーワープ
	-- 	local warpEvent = WarpPlayrsEvent.new()
	-- 	warpEvent:Warp(self.eventTaskData[2])
	-- 	self.eventTask = warpEvent
	elseif eventTaskType == EventInstType.Wait then
		local waitEvent = WaitEvent_.new(self.eventTaskData[2])
		self.eventTask = waitEvent
	elseif eventTaskType == EventInstType.CameraMoveTo then
		local targetCfVal : CFrameValue = ReplicatedStorage.CameraPoints:FindFirstChild(self.eventTaskData[2])
		if targetCfVal then
			local itpoTime = self.eventTaskData[3]
			CameraManager_.MoveToCameraPos(targetCfVal.Value, itpoTime)
			-- EventTaskとしては即時終了扱いで、まちたい場合Waitを直後にはさむ
		else
			warn("CameraMoveTo: targetCf not found")
		end
	elseif eventTaskType == EventInstType.ResetCamera then
		-- カメラリセット
		CameraManager_.ResetToCustomCamera(true)
	elseif eventTaskType == EventInstType.LetterBoxOff then
		UIManager_.SetEnableGui("LetterBoxGui", false)
	elseif eventTaskType == EventInstType.FadeOutTalker then
		local talker : Model = self.param and self.param.Talker
		if talker then
			local prompt = talker:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt then
				prompt.Enabled = false
			end
			local fadeTime = self.eventTaskData[2] or 1
			ModelUtil.FadeOut(talker, fadeTime)
			task.delay(fadeTime, function()
				talker:Destroy()
			end)
		else
			warn("FadeOutTalker: talker not found")
		end
	elseif eventTaskType == EventInstType.SendCSRemoteEvent then
		RemoteSender_.SendEvent(self.eventTaskData[2], self.eventTaskData[3])
	elseif eventTaskType == EventInstType.SendSignal then
		local GlobalSignal = require(ReplicatedFirst.Nexsys.Common.Signal.GlobalSignal)
		GlobalSignal.FireSignal(self.eventTaskData[2], self, self.eventTaskData[3])
	elseif eventTaskType == EventInstType.PlaySEByName then
		local SoundManager_ = require(ReplicatedFirst.Nexsys.Client.SoundManager_)
		SoundManager_.PlaySEByName(self.eventTaskData[2])
	elseif eventTaskType == EventInstType.PlayAnimation then
		local AnimationModule = require(ReplicatedFirst.Nexsys.Common.AnimationModule)
		-- 今回はEventModelがある前提
		if self.param.EventModel then
			local animId = self.eventTaskData[2]
			if animId then
				self.eventAnim = AnimationModule.PlayAnimationByAnimationIdWithModel(self.param.EventModel, animId, true)
			end
		end
	elseif eventTaskType == EventInstType.StopAnimation then
		if self.eventAnim then
			self.eventAnim:Stop()
		end
	elseif eventTaskType == EventInstType.DisableProximityPrompt then
		UIManager_.SetProximityPromptDisableFlag("Event", true)
	elseif eventTaskType == EventInstType.EnableProximityPrompt then
		UIManager_.SetProximityPromptDisableFlag("Event", false)
	elseif eventTaskType == EventInstType.LockPlayer then
		local chara = game.Players.LocalPlayer.Character
		local hrp = chara and chara.PrimaryPart
		if hrp then
			hrp.Anchored = true
		end
	elseif eventTaskType == EventInstType.UnlockPlayer then	
		local chara = game.Players.LocalPlayer.Character
		local hrp = chara and chara.PrimaryPart
		if hrp then
			hrp.Anchored = false
		end
	elseif eventTaskType >= 100 then
		if gameEventTaskHandler_ then
			gameEventTaskHandler_(eventTaskType, self.eventTaskData, self.param)
		else
			warn("gameEventHandler_ not found")
		end
	end
	-- elseif eventTaskType == EventInstType.LockPlayers then
	-- 	-- taskなしで即時命令で終了
	-- 	PlayerManager.LockPlayers()
	-- elseif eventTaskType == EventInstType.UnlockPlayers then
	-- 	-- taskなしで即時命令で終了
	-- 	PlayerManager.UnlockPlayers()
	-- elseif eventTaskType == EventInstType.SitToSeatPlayers then
	-- 	-- taskなしで即時命令で終了
	-- 	PlayerManager.SitToSeatAll()
	-- elseif eventTaskType == EventInstType.ChangeBGMAll then
	-- 	-- taskなしで即時命令で終了
	-- 	PlayerManager.ChangeBGMAllPlayers(self.eventTaskData[2])
	-- elseif eventTaskType == EventInstType.ChangeRespawnPoint then
	-- 	PlayerManager.ChangeRespawnPointAllPlayers(self.eventTaskData[2])
	-- elseif eventTaskType == EventInstType.TeleportPlace then
	-- 	PlayerManager.TeleportPlaceAllPlayers()
	-- end
end

return Event_
