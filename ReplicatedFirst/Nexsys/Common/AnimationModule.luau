---@typecheck mode: strict

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local StarterPlayer = game:GetService("StarterPlayer")

local AnimationModule = {}

export type PlayOption = {
	-- どちらか必須
	Animator: Animator?,
	TargetModel: Model?,
	-- どちらか必須
	AnimationId: number?,
	Animation: Animation?,
	-- オプション
	FreezeOnLastPose: boolean?,
	KeepPrevAnim: boolean?,
	PlayFadeTime: number?,
	PrevStopFadeTime: number?,
}
----------------------------------------------------------------------------------------------------
-- ModelからAnimatorを取得
function AnimationModule.GetAnimatorFromModel(model: Model): Animator?
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		return hum:FindFirstChildOfClass("Animator")
	else
		local animController = model:FindFirstChildOfClass("AnimationController")
		return animController and animController:FindFirstChildOfClass("Animator") or nil
	end
end
----------------------------------------------------------------------------------------------------
-- AnimationIdからAnimationを取得
function AnimationModule.GetAnimationFromId(animId: number): Animation?
	local anim = Instance.new("Animation")
	anim.AnimationId = "http://www.roblox.com/asset/?id=" .. animId
	return anim
end
----------------------------------------------------------------------------------------------------
--
function AnimationModule.PlayAnimationByAnimationIdWithModel(model: Model, animId, keepPrev : boolean?): AnimationTrack?
	local animator = AnimationModule.GetAnimatorFromModel(model)
	if animator then
		return AnimationModule.PlayAnimationByAnimationId(animator, animId, keepPrev)
	else
		warn("animator not found : model=" .. model.Name)
		return nil
	end
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function AnimationModule.PlayAnimationWithModel(model: Model, anim: Animation, keepPrev : boolean?): AnimationTrack?
	local animator = AnimationModule.GetAnimatorFromModel(model)
	if animator then
		return AnimationModule.PlayAnimation(animator, anim, keepPrev)
	else
		warn("animator not found : model=" .. model.Name)
		return nil
	end
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function AnimationModule.PlayAnimationByAnimationId(animator: Animator, animId, keepPrev): AnimationTrack
	local animation = AnimationModule.GetAnimationFromId(animId)

	-- PlayAnimationByPlayOptionに挿げ替えテスト
	local opt: PlayOption = {}
	opt.Animator = animator
	opt.Animation = animation
	opt.KeepPrevAnim = keepPrev

	return AnimationModule.PlayAnimationByPlayOption(opt)
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function AnimationModule.PlayAnimation(animator: Animator, anim: Animation, keepPrevAnim): AnimationTrack
	local opt: PlayOption = {}
	opt.Animator = animator
	opt.Animation = anim
	opt.KeepPrevAnim = keepPrevAnim

	return AnimationModule.PlayAnimationByPlayOption(opt)
end
----------------------------------------------------------------------------------------------------
-- Animation再生のコアAPI。最終的にこれで再生する
function AnimationModule.PlayAnimationByPlayOption(option: PlayOption): AnimationTrack
	-- Animatorを確保
	local animator = option.Animator
	if not animator then
		animator = AnimationModule.GetAnimatorFromModel(option.TargetModel)
	end
	if not animator then
		error("animator not found")
	end

	-- Animationを確保
	local anim = option.Animation
	if not anim then
		anim = Instance.new("Animation")
		anim.AnimationId = "http://www.roblox.com/asset/?id=" .. option.AnimationId
	end
	if not anim then
		error("anim not found")
	end

	local playFadeTime = option.PlayFadeTime or 0.1
	-- 通常は前のAnimationはフェードアウト
	if not option.KeepPrevAnim then
		local prevTracks = animator:GetPlayingAnimationTracks()
		if prevTracks then
			task.spawn(function()
				-- ちょっと待ってからフェードアウトしないと、クロスフェードにならない
				task.wait(playFadeTime + 0.1)
				for index, prev in ipairs(prevTracks) do
					prev:Stop(option.PrevStopFadeTime)
				end
			end)
		end
	end

	-- Load the animation onto the animator
	local animTrack = animator:LoadAnimation(anim)
	local playSpeed = option.PlaySpeed or 1
	animTrack:Play(playFadeTime, 1, playSpeed)

	-- 最後のポーズで止める
	if option.FreezeOnLastPose then
		animTrack.Stopped:Connect(function()
			warn("anim track freeze on last pose")
			animTrack:Play(0, 1, 0)
			animTrack.TimePosition = animTrack.Length - 0.0001
		end)
	end

	return animTrack
end
----------------------------------------------------------------------------------------------------
-- StopAllAnimationFromModel
function AnimationModule.StopAllAnimationsFromModel(model: Model)
	local animator = AnimationModule.GetAnimatorFromModel(model)
	if animator then
		AnimationModule.StopAllAnimations(animator)
	end
end
----------------------------------------------------------------------------------------------------
-- StopAllAnimation
function AnimationModule.StopAllAnimations(animator: Animator)
	local anims = animator:GetPlayingAnimationTracks()
	if anims then
		for _, anim in ipairs(anims) do
			anim:Stop()
		end
	end
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function AnimationModule.PoseAnimationWithModel(model: Model, anim: Animation): AnimationTrack
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		return AnimationModule.PoseAnimation(hum, anim)
	end
end

function AnimationModule.PoseAnimation(humanoid: Humanoid, anim: Animation): AnimationTrack
	-- Ensure that the character's humanoid contains an "Animator" object
	local animator: Animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		error("animator not found : chara=" .. humanoid.Parent.Name)
	end

	-- 通常は前のAnimationはフェードアウト
	-- local prevTracks = animator:GetPlayingAnimationTracks()
	-- if prevTracks then
	-- 	for index, prev in prevTracks do
	-- 		prev:Stop()
	-- 	end
	-- end

	print("pose anim")
	-- Load the animation onto the animator
	local animTrack = animator:LoadAnimation(anim)
	animTrack:Play()
	animTrack:AdjustSpeed(0)

	return animTrack
end
----------------------------------------------------------------------
-- 先読み用
----------------------------------------------------------------------
function AnimationModule.LoadAnimation(humanoid: Humanoid, anim: Animation)
	local animator: Animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		error("animator not found : chara=" .. humanoid.Parent.Name)
	end

	animator:LoadAnimation(anim)
end
----------------------------------------------------------------------
-- Studio確認用
----------------------------------------------------------------------
function AnimationModule.CreateAnimationByKeyFrameSequence(keyframeSequence)
	local hashId = KeyframeSequenceProvider:RegisterKeyframeSequence(keyframeSequence)
	if hashId then
		local Animation = Instance.new("Animation")
		Animation.AnimationId = hashId
		return Animation
	end
end
----------------------------------------------------------------------------------------------------
-- GetPlayingAnimations
function AnimationModule.GetPlayingAnimations(animator: Animator): {AnimationTrack}?
	return animator:GetPlayingAnimationTracks()
end
----------------------------------------------------------------------------------------------------
-- PrintPlayingAnimations
function AnimationModule.PrintPlayingAnimationsFromModel(model : Model)
	local animator = AnimationModule.GetAnimatorFromModel(model)
	local anims = animator:GetPlayingAnimationTracks()
	if anims then
		print("=======")
		for _, anim in ipairs(anims) do
			print(anim.Name)
		end
	end
end

return AnimationModule
