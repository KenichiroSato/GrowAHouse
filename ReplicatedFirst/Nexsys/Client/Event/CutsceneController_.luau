local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local CutscenePlayer_ = require(ReplicatedFirst.Nexsys.Client.CutscenePlayer_)
local CutsceneController_ = {}
CutsceneController_.__index = CutsceneController_

----------------------------------------------------------------------
-- 全PlayerへのCut再生のためのもの
----------------------------------------------------------------------
function CutsceneController_.new(...)
	local self = setmetatable({}, CutsceneController_)
	CutsceneController_.Init(self, ...)
	return self
end

function CutsceneController_:Init(...)
end

function CutsceneController_:IsEnd()
	return not CutscenePlayer_.IsPlaying()
end

function CutsceneController_:Start(cutName, eventParam)
	CutscenePlayer_.Play(cutName, eventParam)
end

return CutsceneController_
