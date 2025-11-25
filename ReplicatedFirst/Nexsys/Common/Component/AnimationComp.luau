local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)
local AnimationModule = require(ReplicatedFirst.Nexsys.Common.AnimationModule)

--- @class AnimationComp : ComponentBase
local AnimationComp = {}
AnimationComp.__index = AnimationComp
setmetatable(AnimationComp, ComponentBase)

function AnimationComp.new(...)
	local self = setmetatable(ComponentBase.new(...), AnimationComp)
	AnimationComp.Init(self, ...)
	return self
end

function AnimationComp:Init(ins : Model)
	self.instance = ins
end
----------------------------------------------------------------------------------------------------
-- PlayAnimation
function AnimationComp:PlayAnimation(anim : Animation) : AnimationTrack?
	local opt : AnimationModule.PlayOption = {
		TargetModel = self.instance,
		Animation = anim,
	}
	local animTrack = AnimationModule.PlayAnimationByPlayOption(opt)
	return animTrack
end
----------------------------------------------------------------------------------------------------
-- PlayAnimation
function AnimationComp:PlayAnimationWithSpeed(anim : Animation, playSpeed) : AnimationTrack?
	local opt : AnimationModule.PlayOption = {
		TargetModel = self.instance,
		Animation = anim,
		PlaySpeed = playSpeed,
	}
	local animTrack = AnimationModule.PlayAnimationByPlayOption(opt)
	return animTrack
end

----------------------------------------------------------------------------------------------------
-- GetPlayingAnimations
function AnimationComp:GetPlayingAnimations() : {AnimationTrack}?
	local animator = self:GetAnimator()
	if animator then
		return animator:GetPlayingAnimationTracks()
	end
end
----------------------------------------------------------------------------------------------------
-- PrintPlayingAnimations
function AnimationComp:PrintPlayingAnimations()
	local anims = self:GetPlayingAnimations()
	if anims then
		print("=======")
		for _, anim in ipairs(anims) do
			print(anim.Name)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- GetAnimator
function AnimationComp:GetAnimator() : Animator?
	return AnimationModule.GetAnimatorFromModel(self.instance)
end

return AnimationComp