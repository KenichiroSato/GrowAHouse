local ReplicatedFirst = game:GetService("ReplicatedFirst")
local AnimationModule = require(ReplicatedFirst.Nexsys.Common.AnimationModule)
local MathUtil = require(ReplicatedFirst.Nexsys.Common.MathUtil)
--- @class CustomPrompt : table
local CustomPrompt = {}
CustomPrompt.__index = CustomPrompt

export type Param = {
	HoldingAnimation : Animation,
}

----------------------------------------------------------------------------------------------------
-- 
function CustomPrompt.new(...)
	local self = setmetatable({}, CustomPrompt)
	CustomPrompt.Init(self, ...)
	return self
end

function CustomPrompt:Init(prompt : ProximityPrompt, param : Param)
	self.prompt = prompt
	self.param = param

	self.holdBeganConnection = self.prompt.PromptButtonHoldBegan:Connect(function(player)
		self:OnPromptButtonHoldBegan(player)
	end)
	self.holdEndedConnection = self.prompt.PromptButtonHoldEnded:Connect(function(player)
		self:OnPromptButtonHoldEnded(player)
	end)
end
----------------------------------------------------------------------------------------------------
-- Destroy
function CustomPrompt:Destroy()
	if self.holdBeganConnection then
		self.holdBeganConnection:Disconnect()
		self.holdBeganConnection = nil
	end
	if self.holdEndedConnection then
		self.holdEndedConnection:Disconnect()
		self.holdEndedConnection = nil
	end

	if self.holdingAnimTrack then
		self.holdingAnimTrack:Stop()
		self.holdingAnimTrack = nil
	end
end
----------------------------------------------------------------------------------------------------
-- OnPromptButtonHoldBegan
function CustomPrompt:OnPromptButtonHoldBegan(player : Player)
	if self.param.HoldingAnimation then
		self.holdingAnimTrack = AnimationModule.PlayAnimationWithModel(player.Character, self.param.HoldingAnimation)
	end
	if self.param.IsRotToTarget then
		local char = player.Character
		local charPos = char and char:GetPivot().Position
		if charPos then
			local dir = self.prompt.Parent:GetPivot().Position - charPos
			local dirXZ = MathUtil.GetXZVector3(dir).Unit
			local newCf = CFrame.new(charPos, charPos + dirXZ)
			char:PivotTo(newCf)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- OnPromptButtonHoldEnded
function CustomPrompt:OnPromptButtonHoldEnded(player : Player)
	if self.holdingAnimTrack then
		self.holdingAnimTrack:Stop()
		self.holdingAnimTrack = nil
	end
end

return CustomPrompt