local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TalkGui_ = require(ReplicatedFirst.Nexsys.Client.UI.TalkGui_)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)
local LocalizeModule_ = require(ReplicatedFirst.Nexsys.Client.LocalizeModule_)
local GameSystemUtil = require(ReplicatedFirst.Nexsys.Common.GameSystemUtil)

--- @class TalkSequencer_ : table
local TalkSequencer_ = {}
TalkSequencer_.__index = TalkSequencer_
TalkSequencer_.instance = nil

function TalkSequencer_.new(...)
	local self = setmetatable({}, TalkSequencer_)
	TalkSequencer_.Init(self, ...)
	TalkSequencer_.instance = self
	return self
end

function TalkSequencer_:Init()
end

function TalkSequencer_:IsEnd()
	return self.isEnd
end

function TalkSequencer_:Start(talkDataKey : string, talker : Model?, talkEndTime : number?)
	if self.thread then
		self:Cancel()
	end

	self.isEnd = false
	self.talker = talker
	self.talkEndTime = talkEndTime

	local TalkData = require(GameDataProvider:GetExdataFolder().TalkData)
	local talkSeqData = TalkData[talkDataKey]
	if not talkSeqData then
		warn("talk data not found. talkDataKey="..talkDataKey)
		return
	end
	self.thread = task.spawn(function()
		for index, talkData in talkSeqData do
			-- local playTime = talkData[3] or SystemDefine.DEFAULT_TALK_TIME
			self:playTalk(talkData)
		end
		-- 終了
		local talkGui = TalkGui_.GetInstance()
		if talkGui then
			talkGui:Hide()
		end
		self.isEnd = true
		self.thread = nil
	end)
end
----------------------------------------------------------------------------------------------------
--- 現在のトークシーケンス処理をキャンセル
function TalkSequencer_:Cancel()
	if self.thread then
		task.cancel(self.thread)
		self.thread = nil
		self.isEnd = true
	end
end
----------------------------------------------------------------------------------------------------
-- 
function TalkSequencer_:playTalk(talkData)
	local text = LocalizeModule_.GetLocalizedData(talkData, "Text")
	local talkTime = self.talkEndTime
	local isWaitInput = talkData.IsWaitInput or true

	local talker = self.talker
	if talkData.TalkerPath then
		local pathTalker = GameSystemUtil.FindInstanceFromPath(talkData.TalkerPath)
		if pathTalker then
			talker = pathTalker
		else
			warn("talkerPath talker not found: " .. talkData.TalkerPath)
		end
	end
	if not talkTime and talkData.TalkEndTime then
		talkTime = talkData.TalkEndTime
	end

	local talkParam : SystemTypes.TalkParam = {
		Text = text,
		TalkerModel = talker,
		Image = nil,
		Name = nil,
		IsWaitInput = isWaitInput,
		TalkTime = talkTime,
		AutoDistanceHide = not talkData.NoDistanceHide,
	}

	local talkGui = TalkGui_.GetInstance()
	if talkGui then
		talkGui:PlayTalkAsync(talkParam)
		if isWaitInput then
			talkGui:WaitForTalkEnd()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function TalkSequencer_:getThumbnailAndName(talkerType)
	-- いったんModelPreviewが基本なのでつかってない。

	if talkerType == "Player" then
		local player : Player = game.Players.LocalPlayer
		-- Asyncなんで最初取れないかも
		local imageUrl, isReady = game.Players:GetUserThumbnailAsync(
			player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		return imageUrl, player.DisplayName
	-- elseif talkerType == "Npc" then
	-- 	local npcData = NpcData[talkerData.NpcKey]
	-- 	local npcThumb = "rbxthumb://type=Asset&id="..npcData.AssetId.."&w=150&h=150"
	-- 	return npcThumb, npcData.Name
	-- elseif talkerType == "Object" then
	-- 	return talkerData.ImageId, talkerData.Name
	else
		warn("talker data not resolved. talkerType="..talkerType)
		return nil, nil
	end
end

----------------------------------------------------------------------------------------------------
if TalkSequencer_.instance == nil then
	TalkSequencer_.new()
end
return TalkSequencer_.instance