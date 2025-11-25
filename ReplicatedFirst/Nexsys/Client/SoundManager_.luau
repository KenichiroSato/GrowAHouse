local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local SoundManager_ = {}

local lastBGM_ = nil
local currentBGM_ = nil
local isBGMFadeOut_ = false
local intervalSEs_ = {}

local BGM_FADE_TIME = 3
local BGM_DEFAULT_VOLUME = 0.2
----------------------------------------------------------------------------------------------------
-- 
function SoundManager_.Start()
	ReplicatedStorage.RemoteEvent.PlaySoundEvent.OnClientEvent:Connect(SoundManager_.OnPlayEvent)
end
----------------------------------------------------------------------------------------------------
-- 
function SoundManager_.PlayDefaultBGM()
	-- 初期BGM
	local sound = SoundService:WaitForChild("BGMGroup"):WaitForChild("10-MainTheme")
	SoundManager_.PlayBGM(sound)
end
----------------------------------------------------------------------------------------------------
-- PlayBGMByName
function SoundManager_.PlayBGMByName(bgmName: string, fadeTime : number?)
	local sound = SoundService:WaitForChild("BGMGroup"):WaitForChild(bgmName)
	SoundManager_.PlayBGM(sound, fadeTime)
end
----------------------------------------------------------------------------------------------------
-- 
function SoundManager_.OnPlayEvent(sound: Sound, isBGM)
	if not sound then
		return
	end

	if isBGM then
		SoundManager_.PlayBGM(sound)
	else
		sound:Play()
	end
end
----------------------------------------------------------------------------------------------------
-- FadeOutBGM
function SoundManager_.FadeOutBGM(fadeTime, isStop)
	if currentBGM_ then
		-- フェードアウト
		local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(currentBGM_, tweenInfo, { Volume = 0 })
		tween:Play()

		isBGMFadeOut_ = true
		tween.Completed:Connect(function()
			isBGMFadeOut_ = false
			if isStop then
				currentBGM_:Stop()
			end
		end)
	end
end
----------------------------------------------------------------------------------------------------
-- FadeInBGM
function SoundManager_.FadeInBGM(fadeTime)
	if currentBGM_ then
		-- フェードイン
		local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(currentBGM_, tweenInfo, { Volume = BGM_DEFAULT_VOLUME })
		tween:Play()
	end
end
----------------------------------------------------------------------------------------------------
-- ChangeBGM
function SoundManager_.PlayBGM(sound: Sound, fadeTime : number?)
	local fadeTime = fadeTime or BGM_FADE_TIME

	sound.Looped = true
	if currentBGM_ then
		lastBGM_ = currentBGM_
		-- フェードアウト
		local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(lastBGM_, tweenInfo, { Volume = 0 })
		tween:Play()
		task.delay(fadeTime, function()
			lastBGM_:Stop()
		end)
		sound.Volume = 0
		sound:Play()

		-- フェードイン
		local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(sound, tweenInfo, { Volume = BGM_DEFAULT_VOLUME })
		tween:Play()
	else
		sound.Volume = BGM_DEFAULT_VOLUME
		sound:Play()
	end
	currentBGM_ = sound
end
----------------------------------------------------------------------------------------------------
-- StopBGM
function SoundManager_.StopBGM()
	if currentBGM_ then
		currentBGM_:Stop()
	end
end
----------------------------------------------------------------------------------------------------
-- SetBGMVolumeRate
function SoundManager_.SetBGMVolumeRate(rate)
	-- フェードアウトだけ優先するHPP用の暫定対処
	if isBGMFadeOut_ then
		return
	end

	if currentBGM_ then
		currentBGM_.Volume = BGM_DEFAULT_VOLUME * rate
	end
end
----------------------------------------------------------------------------------------------------
-- PlaySE
function SoundManager_.PlaySEByName(seName, interval : number?)
	local seGroup = SoundService:FindFirstChild("SE")
	local sound : Sound = seGroup and seGroup:FindFirstChild(seName)
	if sound then
		if intervalSEs_[seName] then
			return
		end
		sound:Play()

		if interval then
			intervalSEs_[seName] = true
			task.delay(interval, function()
				intervalSEs_[seName] = nil
			end)
		end
	else
		warn("Not found SE: " .. seName)
	end
end
----------------------------------------------------------------------------------------------------
-- PlaySEByNameWithGroup
function SoundManager_.PlaySEByNameWithGroup(seName, groupName)
	local group : SoundGroup = SoundService:FindFirstChild(groupName)
	if not group then
		warn("Not found SE group: " .. groupName)
		return
	end

	local sound : Sound = group:FindFirstChild(seName, 1)
	if sound then
		sound:Play()
	else
		warn("Not found SE: " .. seName)
	end
end
----------------------------------------------------------------------------------------------------
-- StopSEByName
function SoundManager_.StopSEByName(seName)
	local seGroup = SoundService:FindFirstChild("SE")
	local sound : Sound = seGroup and seGroup:FindFirstChild(seName)
	if sound then
		sound:Stop()
	end
end
----------------------------------------------------------------------------------------------------
-- OnPlaySE
function SoundManager_.OnPlaySE(sound : Sound)
	sound:Play()
end
----------------------------------------------------------------------------------------------------
-- FadeOutSE
-- やってもいいが、再度再生すると、Tweenの残りが影響するとか、結構バグりやすい処理。検討。
-- function SoundManager_.FadeOutSE(seName, _fadeTime)
-- 	local sound = SoundService:WaitForChild("SE"):WaitForChild(seName, 1)
-- 	if sound then
-- 		local fadeTime = _fadeTime or 1
-- 		local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
-- 		local tween = TweenService:Create(sound, tweenInfo, { Volume = 0 })
-- 		tween:Play()
-- 	end
-- end

return SoundManager_
