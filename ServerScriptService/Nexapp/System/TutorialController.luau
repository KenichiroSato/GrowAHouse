--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local ProgressFlagData = require(ReplicatedFirst.Nexapp.Data.ProgressFlagData)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local LogDefine = require(ServerScriptService.Nexapp.System.LogDefine)

--- @class TutorialController
local TutorialController = {}
TutorialController.__index = TutorialController

function TutorialController.new(gamePlayer: Types.GamePlayer)
	local self = setmetatable({}, TutorialController)
	self.gamePlayer = gamePlayer :: Types.GamePlayer
	self.isInitialTutorialChecked = false
	return self
end

local function CheckToShowInitialTutorial(self): boolean
	if self.isInitialTutorialChecked then
		return false
	end
	if self.gamePlayer.isClientGameStarted and self.gamePlayer.playerData:IsSaveDataLoaded() then
		self.isInitialTutorialChecked = true
		if self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstTalkEnd) then
			return false
		end
		self.gamePlayer:SendRemoteEvent("Event_FirstTalk")
		return true
	end
	return false
end

local function CheckToShowPurchaseTutorial(self): boolean
	if self.isPurchaseTutorialChecked then
		return false
	end
	if not self.gamePlayer.isClientGameStarted then
		return false
	end
	if not self.gamePlayer.playerData:IsSaveDataLoaded() then
		return false
	end
	if not self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstBuildComplete) then
		return false
	end	
	self.isPurchaseTutorialChecked = true
	if not self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstPurchaseComplete) then
		self.gamePlayer:SendRemoteEvent("Event_FirstPurchase")
		return true
	end
	return false
end

local function CheckToShowLetsHomeTutorial(self): boolean
	if self.isLetsHomeTutorialChecked then
		return false
	end
	if not self.gamePlayer.isClientGameStarted then
		return false
	end
	if not self.gamePlayer.playerData:IsSaveDataLoaded() then
		return false
	end
	if not self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstPurchaseComplete) then
		return false
	end	
	self.isLetsHomeTutorialChecked = true
	if not self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstItemPlaceComplete) and
		self.gamePlayer.playerData:GetPurchasedItemsNum() > 0
	then
		self.gamePlayer:SendRemoteEvent("Event_LetsGoHome")
		return true
	end
	return false
end


function TutorialController:Check()
	if CheckToShowInitialTutorial(self) then
		return
	end
	if CheckToShowPurchaseTutorial(self) then
		return
	end
	if CheckToShowLetsHomeTutorial(self) then
		return
	end
end

return TutorialController
