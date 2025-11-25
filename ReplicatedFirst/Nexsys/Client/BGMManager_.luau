--!native

local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local LocalBasePlayer_ = require(ReplicatedFirst.Nexsys.Client.LocalBasePlayer_)
local GameSystemUtil = require(ReplicatedFirst.Nexsys.Common.GameSystemUtil)

--- @class BGMManager_ : table
local BGMManager_ = {}

local BGM_FADE_TIME = 2
local BGM_DEFAULT_VOLUME = 0.5
local lastBGM_ = nil
local currentBGM_ = nil
local defaultBGM_ = nil
local isBGMFadeOut_ = false
-- ひとまず強いやつ1つ、増えたらレイヤー管理を作る
local forceBGM_ = nil
local bgmSoundGroup_ = nil
local defaultBGMGroupVolume_ = 0.5
local lastCheckRangePos_ = Vector3.new(0, 0, 0)

----------------------------------------------------------------------------------------------------
-- PlayBGM
-- function BGMManager_.PlayBGM(bgm : Sound)
-- 	if currentBGM_ then
-- 		currentBGM_:Stop()
-- 	end
-- 	currentBGM_ = bgm
-- 	currentBGM_:Play()
-- end
----------------------------------------------------------------------------------------------------
-- Init
function BGMManager_.Init(defaultBGMName : string?, doUpdate : boolean?)
	if doUpdate then
		RunService.Heartbeat:Connect(function(dt)
			BGMManager_.OnUpdate(dt)
		end)
	end

	task.spawn(function()
		bgmSoundGroup_ = SoundService:WaitForChild("BGM", 3)
		if not bgmSoundGroup_ then
			warn("BGMManager_.Init, bgmSoundGroup_ not found")
			return
		end

		-- グループ設定
		bgmSoundGroup_.ChildAdded:Connect(function(child : Sound)
			if child:IsA("Sound") then
				child.SoundGroup = bgmSoundGroup_
			end
		end)
		local bgms = bgmSoundGroup_:GetChildren()
		for _, bgm in bgms do
			bgm.SoundGroup = bgmSoundGroup_
		end

		defaultBGMGroupVolume_ = bgmSoundGroup_.Volume

		if defaultBGMName then
			defaultBGM_ = bgmSoundGroup_:WaitForChild(defaultBGMName, 3)
			BGMManager_.PlayBGM(defaultBGM_)
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- OnStepped
function BGMManager_.OnUpdate(deltaTime)
	BGMManager_.CheckBGMRange()
end

----------------------------------------------------------------------------------------------------
-- PlayBGMByName
function BGMManager_.PlayBGMByName(bgmName: string, fadeTime : number?)
	task.spawn(function()
		if not bgmSoundGroup_ then
			bgmSoundGroup_ = SoundService:WaitForChild("BGM", 3)
		end
		if not bgmSoundGroup_ then
			warn("BGMManager_.PlayBGMByName, bgmSoundGroup_ not found")
			return
		end
		local bgm = bgmSoundGroup_:WaitForChild(bgmName, 3)
		if not bgm then
			warn("BGMManager_.PlayBGMByName, bgm not found", bgmName)
			return
		end
		BGMManager_.PlayBGM(bgm, fadeTime)
	end)
end
----------------------------------------------------------------------------------------------------
-- 
function BGMManager_.PlayBGM(sound: Sound, _fadeTime : number?)
	if not sound then
		warn("BGMManager_.PlayBGM, sound is invalid")
		return
	end

	if currentBGM_ == sound then
		return
	end

	local fadeTime = _fadeTime or BGM_FADE_TIME

	sound.Looped = true
	if currentBGM_ and currentBGM_ ~= sound then
		-- warn("BGMManager_.PlayBGM, last fadeout", sound.Name, currentBGM_.Name)

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
		-- print("BGMManager_.PlayBGM Direct", sound.Name)
		sound.Volume = BGM_DEFAULT_VOLUME
		sound:Play()
	end

	currentBGM_ = sound
end
----------------------------------------------------------------------------------------------------
-- PlayForceBGM
function BGMManager_.PlayForceBGM(sound: Sound, fadeTime : number?)
	BGMManager_.PlayBGM(sound, fadeTime)
	forceBGM_ = sound
end
function BGMManager_.PlayForceBGMByName(soundName: string, fadeTime : number?)
	local sound = SoundService.BGM:FindFirstChild(soundName, true)
	if sound then
		BGMManager_.PlayForceBGM(sound, fadeTime)
	else
		warn("BGMManager_.PlayForceBGMByName, BGM not found", soundName)
	end
end
----------------------------------------------------------------------------------------------------
-- EndForceBGM
function BGMManager_.EndForceBGM()
	if forceBGM_ then
		forceBGM_ = nil
		-- あとはCheckBGMRangeで切り替わる
	end
end
----------------------------------------------------------------------------------------------------
-- StopBGM
function BGMManager_.StopBGM()
	if currentBGM_ then
		currentBGM_:Stop()
		currentBGM_ = nil
	end
end
----------------------------------------------------------------------------------------------------
-- 
function BGMManager_.FadeOutBGM(fadeTime, isStop : boolean?)
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
function BGMManager_.FadeInBGM(fadeTime, isPlay : boolean?)
	if currentBGM_ then
		if isPlay then
			currentBGM_:Play()
		end
		-- フェードイン
		local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(currentBGM_, tweenInfo, { Volume = BGM_DEFAULT_VOLUME })
		tween:Play()
	end
end
----------------------------------------------------------------------------------------------------
-- CheckBGMRange
function BGMManager_.CheckBGMRange()
	if forceBGM_ then
		return
	end

	local bgmRanges = CollectionService:GetTagged("BGMRange")
	if #bgmRanges == 0 then
		return
	end

	local chara = LocalBasePlayer_ .GetCharacterAsync()
	local hrp = chara and chara:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	-- あまり移動してないならチェックしない
	if (hrp.Position - lastCheckRangePos_).Magnitude < 1 then
		return
	end

	lastCheckRangePos_ = hrp.CFrame.Position
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { hrp }
	for _, bgmRange : Part in bgmRanges do
		if not bgmRange:IsDescendantOf(workspace) then
			continue
		end

		local dist = (bgmRange.Position - hrp.Position)
		local lenXZ = Vector3.new(dist.X, 0, dist.Z).Magnitude
		local bgmRangeXZLen = Vector3.new(bgmRange.Size.X / 2, 0, bgmRange.Size.Z / 2).Magnitude
		-- ざっくり距離の中にいるか(円形になるので少し外でも入ってる扱いになる)
		if lenXZ > bgmRangeXZLen then
			continue
		end
		if (hrp.Position.Y < bgmRange.Position.Y - bgmRange.Size.Y / 2) or (hrp.Position.Y > bgmRange.Position.Y + bgmRange.Size.Y / 2) then
			continue
		end

		-- local parts = workspace:GetPartBoundsInBox(bgmRange.CFrame, bgmRange.Size, overlapParams)
		local parts = workspace:GetPartsInPart(bgmRange, overlapParams)
		if #parts > 0 then
			local bgmName = bgmRange:GetAttribute("BGM")
			local bgm = SoundService.BGM:FindFirstChild(bgmName)
			if bgm then
				if currentBGM_ ~= bgm then
					BGMManager_.PlayBGM(bgm)
				end
				-- 決定終了
				return
			else
				warn("BGMManager_.CheckBGMRange, BGM not found", bgmName)
			end
		end
	end

	-- 何にも入ってないならデフォルトへ
	if currentBGM_ ~= defaultBGM_ then
		BGMManager_.PlayBGM(defaultBGM_)
	end
end
----------------------------------------------------------------------------------------------------
-- SetEnableBGMVolume
function BGMManager_.SetEnableBGMVolume(enable)
	print("BGMManager_.SetEnableBGMVolume", enable)
	SoundService.BGM.Volume = enable and defaultBGMGroupVolume_ or 0
end
----------------------------------------------------------------------------------------------------
-- SetBGMFadeTime
function BGMManager_.SetBGMFadeTime(fadeTime)
	BGM_FADE_TIME = fadeTime
end
----------------------------------------------------------------------------------------------------
--- SetBGMVolume
function BGMManager_.SetBGMVolumeRate(volumeRate)
	if bgmSoundGroup_ then
		bgmSoundGroup_.Volume = defaultBGMGroupVolume_ * volumeRate
	end
end

return BGMManager_