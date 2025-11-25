local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UIUtil = require(ReplicatedFirst.Nexsys.Common.UIUtil)
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)
local LocalizeModule_ = require(ReplicatedFirst.Nexsys.Client.LocalizeModule_)
--- @class AnnounceElem_ : table
local AnnounceElem_ = {}
AnnounceElem_.__index = AnnounceElem_

local ANNOUNCE_SHOW_TIME = 3
local ANNOUNCE_FADE_OUT_TIME = 1

----------------------------------------------------------------------------------------------------
-- 
function AnnounceElem_.new(...)
	local self = setmetatable({}, AnnounceElem_)
	AnnounceElem_.Init(self, ...)
	return self
end

function AnnounceElem_:Init(frame : Frame)
	self.frame = frame:Clone()
	self.frame.Parent = frame.Parent
end

----------------------------------------------------------------------------------------------------
-- PlayAnnounce
function AnnounceElem_:PlayAnnounce(textKey, showTime : number?, str1, str2)
	task.spawn(function()
		local TextData = GameDataProvider:GetTextData()
		-- 内容設定
		local textData = TextData[textKey]
		if not textData then
			warn("AnnounceElem_::PlayAnnounce: textData is nil. textKey = " .. textKey)
			return
		end

		local text = LocalizeModule_.GetLocalizedTextData(textKey, {str1, str2})
		local textLabel = self.frame:FindFirstChildWhichIsA("TextLabel", true) :: TextLabel
		textLabel.Text = text

		-- 表示開始
		self.frame.Visible = true
		local outPos = UDim2.fromScale(self.frame.Position.X.Scale, -0.5)
		local inPos = self.frame.Position
		UIUtil.AnimateUIMove(self.frame, outPos, inPos, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		-- 表示待ち
		local announceShowTime = showTime or ANNOUNCE_SHOW_TIME
		task.wait(announceShowTime)

		UIUtil.FadeOutGui(self.frame, ANNOUNCE_FADE_OUT_TIME)

		-- フェードアウト完了待ち
		task.wait(ANNOUNCE_FADE_OUT_TIME)
		self.frame:Destroy()
	end)
end

return AnnounceElem_