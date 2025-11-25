local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local AnnounceElem_ = require(script.Parent.UIElem.AnnounceElem_)

--- @class AnnounceGui_ : BaseGui_
local AnnounceGui_ = {}
AnnounceGui_.__index = AnnounceGui_
setmetatable(AnnounceGui_, BaseGui_)
AnnounceGui_.instance = nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return AnnounceGui_
function AnnounceGui_.GetInstance()
	return AnnounceGui_.instance
end
----------------------------------------------------------------------------------------------------

function AnnounceGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), AnnounceGui_)
	AnnounceGui_.Init(self, ...)
	AnnounceGui_.instance = self
	return self
end

function AnnounceGui_:Init(gui : ScreenGui)
	self:WaitForLoaded(gui)

	gui.Enabled = true
	self.frame = gui:FindFirstChildWhichIsA("Frame", true) :: Frame
	self.frame.Visible = false
end

----------------------------------------------------------------------------------------------------
-- ShowAnnounce
-- Frame要素を複製していくつも出せる
function AnnounceGui_:ShowAnnounce(textKey, showTime : number?, str1, str2)
	local elem = AnnounceElem_.new(self.frame)
	elem:PlayAnnounce(textKey, showTime, str1, str2)
end

return AnnounceGui_