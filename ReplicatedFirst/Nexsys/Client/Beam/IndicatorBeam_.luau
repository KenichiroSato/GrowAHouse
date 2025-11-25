local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalBasePlayer_ = require(ReplicatedFirst.Nexsys.Client.LocalBasePlayer_)

--- @class IndicatorBeam_ : table
local IndicatorBeam_ = {}
IndicatorBeam_.__index = IndicatorBeam_

----------------------------------------------------------------------------------------------------
-- プレイヤーから目標物へのビームを描画する
function IndicatorBeam_.new(targetAttachment : Attachment?)
	local self = setmetatable({}, IndicatorBeam_)
	IndicatorBeam_.Init(self, targetAttachment)
	return self
end

function IndicatorBeam_:Init(targetAttachment : Attachment?)
	local effectFolder : Folder = ReplicatedStorage:FindFirstChild("Effect")
	local beam = effectFolder and effectFolder:FindFirstChild("IndicatorBeam")
	if not beam then
		warn("IndicatorBeam not found")
		return
	end
	self.beam = beam:Clone() :: Beam
	self.beam.Parent = workspace

	local rootAttachment = LocalBasePlayer_.GetRootAttachmentAsync()
	self.beam.Attachment0 = targetAttachment
	self.beam.Attachment1 = rootAttachment

	game.Players.LocalPlayer.CharacterAdded:Connect(function()
		-- 一応少しまって取る(RootAttachmentはAsyncで基本取得できるが)
		task.wait(0.1)
		self.beam.Attachment1 = LocalBasePlayer_.GetRootAttachmentAsync()
	end)
end
----------------------------------------------------------------------------------------------------
-- Destroy
function IndicatorBeam_:Destroy()
	if self.beam then
		self.beam:Destroy()
		self.beam = nil
	end
end
----------------------------------------------------------------------------------------------------
-- SetTargetAttachment
function IndicatorBeam_:SetTargetAttachment(targetAttachment : Attachment)
	self.beam.Attachment0 = targetAttachment
end
----------------------------------------------------------------------------------------------------
-- GetTargetAttachment
function IndicatorBeam_:GetTargetAttachment() : Attachment?
	return self.beam.Attachment0
end
----------------------------------------------------------------------------------------------------
-- SetBeamColorColor
function IndicatorBeam_:SetBeamColor(color : Color3)
	-- ColorSequence
	self.beam.Color = ColorSequence.new(color)
end
----------------------------------------------------------------------------------------------------
-- SetEnabled
function IndicatorBeam_:SetEnabled(enabled : boolean)
	self.beam.Enabled = enabled
end
----------------------------------------------------------------------------------------------------
-- IsEnabled
function IndicatorBeam_:IsEnabled()
	return self.beam.Enabled
end

return IndicatorBeam_