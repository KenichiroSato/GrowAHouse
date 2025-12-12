--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ProgressFlagData = require(ReplicatedFirst.Nexapp.Data.ProgressFlagData)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

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

local function CheckToShowBuildTutorial(self): boolean
	if not self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstTalkEnd) then
		return false
	end
	if self.isBuildTutorialChecked then
		return false
	end
	local function ShouldShowBuildTutorial(): boolean
		local buildNum = #self.gamePlayer:GetPlayerData():GetBuildingParts() :: Types.BuildingPartArray or 0
		local flag = self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstBuildComplete)
		if not self.gamePlayer.playerData:IsProgressFlag(ProgressFlagData.Flag_FirstBuildComplete) and buildNum == 0 then
			return true
		end
		return false
	end
	
	if self.gamePlayer.isClientGameStarted and self.gamePlayer.playerData:IsSaveDataLoaded() then
		self.isBuildTutorialChecked = true
		if ShouldShowBuildTutorial() then
			self.gamePlayer:SendRemoteEvent("Event_FirstBuild")
			return true
		end
	end
	return false
end


function TutorialController:Check()
	if CheckToShowInitialTutorial(self) then
		return
	end
	if CheckToShowBuildTutorial(self) then
		return
	end
end

function TutorialController:OnFirstTalkEnd()
	self.gamePlayer.playerData:SetProgressFlag(ProgressFlagData.Flag_FirstTalkEnd)
end

return TutorialController
