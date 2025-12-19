local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TextChatService = game:GetService("TextChatService")
local LocalizationService = game:GetService("LocalizationService")
local SystemDefine = require(ReplicatedFirst.Nexsys.Common.SystemDefine)
local UIManager_ = require(ReplicatedFirst.Nexsys.Client.UIManager_)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
local SoundManager_ = require(ReplicatedFirst.Nexsys.Client.SoundManager_)
local PopUp_ = require(ReplicatedFirst.Nexsys.Client.PopUp_)
local EventManager_ = require(ReplicatedFirst.Nexsys.Client.Event.EventManager_)
local LocalBasePlayer_ = require(ReplicatedFirst.Nexsys.Client.LocalBasePlayer_)

-- Systemから除外すべき項目
local EffectControl = require(ReplicatedFirst.Nexsys.Common.EffectControl)
local AnnounceGui_ = require(ReplicatedFirst.Nexsys.Client.UI.AnnounceGui_)
local BGMManager_ = require(ReplicatedFirst.Nexsys.Client.BGMManager_)

local SystemRemoteEventHandler_ = {}

----------------------------------------------------------------------------------------------------
function SystemRemoteEventHandler_.onCommonEvent(eventType, ...)
	----------------------------------------------------------------------------------------------------
	-- LoadData系
	if eventType == SystemDefine.CommonClientEvent.GuiSetupData then
		SystemDataModule_.OnReceiveGuiSetupInfo(...)
	----------------------------------------------------------------------------------------------------
	-- System系
	elseif eventType == SystemDefine.CommonClientEvent.LocalEnabledChange then
		local f = function(instance : Instance, val)
			if instance:IsDescendantOf(workspace) then
				warn(instance, val)
				instance.Enabled = val
			else
				warn("not descendant of workspace", instance)
			end
		end
		f(...)
	----------------------------------------------------------------------------------------------------
	-- UI系
	elseif eventType == SystemDefine.CommonClientEvent.AnnounceTalk then
		UIManager_.AnnounceTalk(...)
	elseif eventType == "RSC_Announce" then
		SoundManager_.PlaySEByName("Beep")
		local gui = AnnounceGui_.GetInstance()
		if gui then
			gui:ShowAnnounce(...)
		end
	elseif eventType == "RSC_PlayerPopUp" then
		local pos = LocalBasePlayer_.GetPosition()
		local str, popType, param = ...
		PopUp_.newFromWorldPosition(str, pos,popType, param)
	elseif eventType == "RSC_Sys_PopUpWithBillboard" then
		local billboardGui, str = ...
		PopUp_.newFromBillboardGui(str, billboardGui)
	elseif eventType == SystemDefine.CommonClientEvent.FadeOut then
		print("CommonRemoteEvent.FadeOut")
		UIManager_.StartScreenFadeOut(...)
	elseif eventType == SystemDefine.CommonClientEvent.FadeIn then
		print("CommonRemoteEvent.FadeIn")
		UIManager_.StartScreenFadeIn(...)
	elseif eventType == SystemDefine.CommonClientEvent.FadeInUI then
		UIManager_.FadeInUIElem(...)
	elseif eventType == SystemDefine.CommonClientEvent.FadeInScreenGUI then
		UIManager_.OnFadeInScreenGui(...)
	elseif eventType == SystemDefine.CommonClientEvent.BGMFadeOut then
		BGMManager_.FadeOutBGM(...)
	elseif eventType == SystemDefine.CommonClientEvent.BGMFadeIn then
		BGMManager_.FadeInBGM(...)
	elseif eventType == SystemDefine.CommonClientEvent.DevNotification then
		local text = ...
		game.StarterGui:SetCore("SendNotification", {
			Title = "Dev Notify", -- Notification title
			Text = text, -- Notification text
			Duration = 5, -- Duration of the notification (optional, may be overridden if more than 3 notifs appear)
		})
	----------------------------------------------------------------------------------------------------
	-- Event系
	elseif eventType == SystemDefine.CommonClientEvent.PlayEvent
	or eventType == "RSC_Debug_PlayEvent" then
		EventManager_.StartEvent(...)
	elseif eventType == "RSC_PlayBubbleTalk" then
		local f = function(chara, text)
			-- 翻訳がかからないので自前で対応
			local res, translator = pcall(function()
				return LocalizationService:GetTranslatorForPlayerAsync(game.Players.LocalPlayer)
			end)
			if res then
				text = translator:Translate(game, text)
			end
			TextChatService:DisplayBubble(chara, text)
		end
		-- chara, text できている想定
		f(...)
	elseif eventType == SystemDefine.CommonClientEvent.StartSimpleTalk then
		local talkKey, simpleTalkParam = ...
		EventManager_.StartSimpleTalkEventWithParam(talkKey, simpleTalkParam)
	----------------------------------------------------------------------------------------------------
	-- Sound系
	elseif eventType == SystemDefine.CommonClientEvent.PlaySE then
		SoundManager_.OnPlaySE(...)
	elseif eventType == SystemDefine.CommonClientEvent.PlaySEByName then
		SoundManager_.PlaySEByName(...)
	elseif eventType == "RSC_ReplicateSoundEffect" then
		local f = function(soundIns : Sound)
			if soundIns then
				soundIns:Play()
			end
		end
		f(...)
	----------------------------------------------------------------------------------------------------
	-- Effect系
	elseif eventType == "RSC_ReplicateEffect" then
		EffectControl.new(...):PlayEffect()
	----------------------------------------------------------------------------------------------------
	-- Player系
	elseif eventType == SystemDefine.CommonClientEvent.TeleportPosition then
		LocalBasePlayer_.OnTeleportPosition(...)
	elseif eventType == SystemDefine.CommonClientEvent.OnTouchedToRailPart then
		LocalBasePlayer_.OnTouchedToMoveRail(...)
	elseif eventType == "RSC_ApplyImpulse" then
		LocalBasePlayer_.ApplyImpulse(...)
	elseif eventType == "RSC_ApplyImpulseByAccelaration" then
		LocalBasePlayer_.ApplyImpulseByAccelaration(...)
	----------------------------------------------------------------------------------------------------
	-- RemoteFunction系
	elseif eventType == SystemDefine.CommonClientEvent.PlayEventCallback then
		local result = EventManager_.StartEventSync(...)
		return result
	else
		warn("not implemented event", eventType)
	end

	return nil
end
----------------------------------------------------------------------------------------------------
-- onCommonFunction
local function onCommonFunction(eventType, ...)
	if eventType == SystemDefine.CommonClientEvent.PlayEventCallback then
		local result = EventManager_.StartEventSync(...)
		return result
	else
		warn("not implemented event", eventType)
		return nil
	end
	return nil
end

----------------------------------------------------------------------------------------------------
-- 
-- function RemoteEventHandler_.Init()
-- 	ReplicatedStorage.RemoteEvent.CommonRemoteEvent.OnClientEvent:Connect(onCommonEvent)

-- 	ReplicatedStorage.RemoteEvent.CommonClientFunction.OnClientInvoke = onCommonFunction
-- end

return SystemRemoteEventHandler_