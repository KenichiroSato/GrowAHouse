local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UIManager = require(ReplicatedFirst.Nexsys.Client.UIManager_)
local SystemDefine = require(ReplicatedFirst.Nexsys.Common.SystemDefine)

local FadeController_ = {}
FadeController_.__index = FadeController_

----------------------------------------------------------------------
-- クライアント プレイヤーへのフェードイン・アウト制御
----------------------------------------------------------------------
function FadeController_.new(...)
	local self = setmetatable({}, FadeController_)
	FadeController_.Init(self, ...)
	return self
end

function FadeController_:Init(...)
	self.isEnd = false
end

function FadeController_:IsEnd()
	return self.isEnd
end

function FadeController_:StartFadeOut(fadeTime)
	if not fadeTime then
		fadeTime = SystemDefine.DEFAULT_FADE_TIME
	end
	UIManager.StartScreenFadeOut(fadeTime)
	task.spawn(function()
		task.wait(fadeTime)
		self.isEnd = true
	end)
end

function FadeController_:StartFadeIn(fadeTime)
	if not fadeTime then
		fadeTime = SystemDefine.DEFAULT_FADE_TIME
	end
	UIManager.StartScreenFadeIn(fadeTime)
	task.spawn(function()
		task.wait(fadeTime)
		self.isEnd = true
	end)
end

return FadeController_