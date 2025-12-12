--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ProgressFlagData = require(ReplicatedFirst.Nexapp.Data.ProgressFlagData)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

--- @class TutorialController
local TutorialController = {}
TutorialController.__index = TutorialController

function TutorialController.new(gamePlayer: Types.GamePlayer)
	local self = setmetatable({}, TutorialController)
	self.gamePlayer = gamePlayer
	self.isInitialTutorialChecked = false
	return self
end

function TutorialController:CheckToShowInitialTutorial()
	if self.isInitialTutorialChecked then
		return
	end
	if self.gamePlayer.isClientGameStarted and self.gamePlayer.playerData:IsSaveDataLoaded() then
		self.isInitialTutorialChecked = true
		if self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstTalkEnd) then
			return
		end
		self.gamePlayer:SendRemoteEvent("CutSceneFirstTalk")
	end
end

function TutorialController:OnFirstTalkEnd()
	self.gamePlayer.playerData:SetProgressFlag(ProgressFlagData.Flag_FirstTalkEnd)
end

return TutorialController
