local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIManager = require(ReplicatedFirst.Nexsys.Client.UIManager_)
local AnimationModule = require(ReplicatedFirst.Nexsys.Common.AnimationModule)
local ModelUtil = require(ReplicatedFirst.Nexsys.Common.ModelUtil)
local CameraManager_ = require(ReplicatedFirst.Nexsys.Client.CameraManager_)

local DEFAULT_ITPO_TIME = 1
local DEFAULT_FADE_TIME = 1

local CutscenePlayer = {}
local playingCutName = nil
----------------------------------------------------------------------
--
function CutscenePlayer.Play(cutName, _eventParam)
	local cutFolder = ReplicatedStorage.Cutscene:WaitForChild(cutName)
	if not cutFolder then
		warn("cutscene[" .. cutName .. "] not found!!")
		CutscenePlayer.OnEndCutscene()
		return
	end

	print("Cutscene ["..cutName.."] Played.")

	-- workspaceに移してキャラも表示
	cutFolder.Parent = workspace
	playingCutName = cutName
	eventParam = _eventParam

	-- 補間のWaitなどBlock系の処理もあるのでtask処理
	task.spawn(function()
		CutscenePlayer.playRigAnimations(cutFolder)
		CutscenePlayer.playCameraAnimation(cutFolder)
		CutscenePlayer.playCFrameAnimations(cutFolder)
	end)
end
----------------------------------------------------------------------------------------------------
-- Cutsceneがプレイ中か
function CutscenePlayer.IsPlaying()
	return playingCutName ~= nil
end
----------------------------------------------------------------------
--
function CutscenePlayer.getCameraStartPos(cutFolder: Folder)
	local refPart = nil
	local refSetting = cutFolder.Settings:FindFirstChild("Reference")
	if refSetting then
		-- local name = refSetting.Value
		refPart = refSetting.Value
	end

	local startCF = cutFolder.Frames["0"].Value
	if refPart then
		startCF = refPart.CFrame * startCF
	end

	return startCF
end
----------------------------------------------------------------------
-- カメラアニメ(フェード処理、終了処理も含む)
----------------------------------------------------------------------
function CutscenePlayer.playCameraAnimation(cutFolder: Folder, param)
	local cameraFolder = cutFolder:FindFirstChild("Camera")
	if not cameraFolder then
		warn("cutscene camera not found")
		return
	end

	local CurrentCameraCFrame = workspace.CurrentCamera.CFrame
	local FrameTime = 0
	local Connection

	local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	Character.Humanoid.AutoRotate = false

	local Camera = workspace.Camera
	Camera.CameraType = Enum.CameraType.Scriptable

	-- 補間時間
	local cameraInItpoTime = DEFAULT_ITPO_TIME
	local cameraOutItpoTime = DEFAULT_ITPO_TIME
	local startCF = cameraFolder.Frames["0"].Value
	local isStartFade = false
	local isEndFade = false
	local isLetterBox = false
	local isNoResetCamera = false

	-- コンフィグ解釈
	local configFolder = cutFolder:FindFirstChild("Config")
	if configFolder then
		local inItpo: NumberValue = configFolder:FindFirstChild("CameraInItpo")
		if inItpo then
			cameraInItpoTime = inItpo.Value
		end
		local outItpo: NumberValue = configFolder:FindFirstChild("CameraOutItpo")
		if outItpo then
			cameraOutItpoTime = outItpo.Value
		end
		local startFade = configFolder:FindFirstChild("StartFade")
		if startFade and startFade.Value then
			isStartFade = true
		end
		local endFade = configFolder:FindFirstChild("EndFade")
		if endFade and endFade.Value then
			isEndFade = true
		end
		local letterBox = configFolder:FindFirstChild("LetterBox")
		if letterBox and letterBox.Value then
			isLetterBox = true
		end
		local noResetCamera = configFolder:FindFirstChild("NoResetCamera")
		if noResetCamera and noResetCamera.Value then
			isNoResetCamera = true
		end
	end

	-- 参照パーツ
	local refPart = nil
	local refSetting = cameraFolder.Settings:FindFirstChild("Reference")
	if refSetting then
		refPart = refSetting.Value
	end
	if refPart then
		startCF = refPart.CFrame * startCF
	end

	-- 開始フェードが必要ならフェード
	if isStartFade then
		-- フェードイン処理
		UIManager.StartScreenFadeOut(DEFAULT_FADE_TIME)
		task.wait(DEFAULT_FADE_TIME)
		-- カメラは暗転中に移動
		CutscenePlayer.InterpolateCameraStartPosition(startCF, 0)
		-- レターボックス表示
		if isLetterBox then
			UIManager.SetEnableGui("LetterBoxGui", true)
		end
		UIManager.StartScreenFadeIn(DEFAULT_FADE_TIME)
		task.wait(DEFAULT_FADE_TIME)
	else
		-- カメラ補間移動
		CutscenePlayer.InterpolateCameraStartPosition(startCF, cameraInItpoTime)
	end

	-- 更新処理。LastFrameはMarker用で0始まり。0のマーカー処理もされるように-1開始
	local lastFrameNum = -1
	Connection = RunService.RenderStepped:Connect(function(DT)
		FrameTime += (DT * 60)
		local frameNum = math.ceil(FrameTime)
		local NeededFrame = cameraFolder.Frames:FindFirstChild(frameNum)

		-- print("CutPlaying : frame="..frameNum..", lastFrame="..lastFrameNum..", FrameTime="..FrameTime)

		-- マーカー処理(終了処理などの前にやる)
		-- local markerTrack = cutFolder:FindFirstChild("MarkerTrack")
		local cutData = cutFolder:FindFirstChild(cutFolder.Name)
		-- 一旦仮で1をカメラ固定で処理
		local cameraDataFolder = cutData and cutData:FindFirstChild("1")
		local markerTrack = cameraDataFolder and cameraDataFolder:FindFirstChild("MarkerTrack")
		if markerTrack then
			-- print("CutMarkerCheck : frame="..frameNum..", lastFrame="..lastFrameNum..", FrameTime="..FrameTime)
			if lastFrameNum < frameNum then
				-- ここで1フレ以上の場合向けにループで処理
				for checkFrame = lastFrameNum + 1, frameNum do
					-- print("MarkerCheck : checkFrame="..checkFrame)
					local frameMarkerFolder = markerTrack:FindFirstChild(checkFrame)
					if frameMarkerFolder then
						CutscenePlayer.TriggerMarker(frameMarkerFolder.name.Value, cutFolder)
					end
				end
			end
		end

		if NeededFrame then
			if refPart then
				Camera.CFrame = refPart.CFrame * NeededFrame.Value
			else
				Camera.CFrame = NeededFrame.Value
			end
		else
			print("Cutscene ["..cutFolder.Name.."] play Ended, frame=", frameNum)
			-- 終了処理
			Connection:Disconnect()
			-- Rigを消したりもしたいので、フェードの前にカット情報は削除
			cutFolder.Parent = ReplicatedStorage.Cutscene
			-- 終了補間(ブロック処理)
			if isEndFade then
				-- フェード処理
				UIManager.StartScreenFadeOut(DEFAULT_FADE_TIME)
				task.wait(DEFAULT_FADE_TIME)
				-- カメラは暗転中に移動
				-- CutscenePlayer.InterpolateCameraStartPosition(CurrentCameraCFrame, 0)
				CameraManager_.ResetToCustomCamera(true)
				-- 黒帯消し
				if isLetterBox then
					UIManager.SetEnableGui("LetterBoxGui", false)
				end
				UIManager.StartScreenFadeIn(DEFAULT_FADE_TIME)
				task.wait(DEFAULT_FADE_TIME)
			else
				-- 元の位置にカメラを戻す通常のカメラ補間移動
				if not isNoResetCamera then
					CameraManager_.ResetToCustomCamera(false)
				end
			end
			-- 片付け
			Character.Humanoid.AutoRotate = true
			CutscenePlayer.OnEndCutscene()
		end

		lastFrameNum = frameNum
	end)
end
----------------------------------------------------------------------
-- キャラアニメ
-- カット専用配置のRigを探して、そのAnimationを再生
-- 本番はAnimationId登録が必要
----------------------------------------------------------------------
function CutscenePlayer.playRigAnimations(cutFolder: Folder)
	-- とりあえず再生、多分ブロックDelayが発生するからその辺対策が必要
	-- 効率化のために使ってないFOVフォルダーにカット専用Rigを置いている
	local rigsFolder = cutFolder:FindFirstChild("AnimRigs")
	if rigsFolder then
		for index, refModel in rigsFolder:GetChildren() do
			if refModel:IsA("Model") and refModel.Humanoid and refModel.Humanoid.Animator and refModel.Animations then
				local anim = refModel.Animations[cutFolder.Name]
				local animTrack = AnimationModule.PlayAnimationWithModel(refModel, anim)
				if animTrack then
					animTrack.Ended:Connect(function()
						print("anim Ended")
						-- そこで停止
						animTrack:AdjustSpeed(0)
					end)
					animTrack.Stopped:Connect(function()
						print("anim Stopped")
						-- そこで停止
						animTrack:AdjustSpeed(0)
					end)
				end

				-- テストプレイ用
				-- local keyFrameSeq: KeyframeSequence = model.AnimSaves:FindFirstChild("Untitled")
				-- local keyFrameSeq: KeyframeSequence = refModel.AnimSaves:FindFirstChild(cutFolder.Name)
				-- if keyFrameSeq then
				-- 	_G.Print("Cut Rig Anim Play")
				-- 	task.spawn(function()
				-- 		local hashId = KeyframeSequenceProvider:RegisterKeyframeSequence(keyFrameSeq)
				-- 		if hashId then
				-- 			local anim = Instance.new("Animation")
				-- 			anim.AnimationId = hashId
				-- 			local animTrack = refModel.Humanoid.Animator:LoadAnimation(anim)
				-- 			animTrack:Play()
				-- 		end
				-- 	end)
				-- end
			-- 配置モデル参照型
			elseif refModel:IsA("ObjectValue") then
				local model : Model = refModel.Value
				local animId = refModel:GetAttribute("AnimId")
				if model and animId then
					print("play cut ref anim")
					AnimationModule.PlayAnimationByAnimationIdWithModel(model, animId)
				end
			end
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CutscenePlayer.playCFrameAnimations(cutFolder: Folder)
	local cframesStringValue = cutFolder:FindFirstChildOfClass("StringValue")
	if not cframesStringValue then
		return
	end

	-- cframsFolder : [1][CFrame]などのフォルダ
	local function playCore(target : Instance, cframesFolder : Folder)
		-- 使ってないdefaultをソートに邪魔なので消す
		if cframesFolder:FindFirstChild("default") then
			cframesFolder.default:Destroy()
		end

		local cframeFrolders = cframesFolder:GetChildren()
		-- まずは番号順にソート
		table.sort(cframeFrolders, function(a, b)
			return tonumber(a.Name) < tonumber(b.Name)
		end)
		local tweenValues = {}
		for index, folder in cframeFrolders do
			if not folder:IsA("Folder") then
				continue
			end
			local cframeValue = folder["Values"]["0"]
			local startTime = 0.0166666 * tonumber(folder.Name)
			tweenValues[index] = { cframe = cframeValue.Value, startTime = startTime }
		end

		for index, value in tweenValues do
			local playTime = value.startTime - (index > 1 and tweenValues[index - 1].startTime or 0)
			-- 再生して完了まで待って次へ
			ModelUtil.TweenPivotSync(target, value.cframe, playTime)

			-- local tweenInfo = TweenInfo.new(playTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
			-- local goal = { CFrame = value.cframe }
			-- local part = target
			-- if target:IsA("Model") then
			-- 	part = target.PrimaryPart
			-- end
			-- if not part then
			-- 	warn("cutscene cframe part not found")
			-- 	return
			-- end
			-- local tween = TweenService:Create(part, tweenInfo, goal)
			-- tween:Play()
			-- tween.Completed:Wait()
		end
	end

	local HttpService = game:GetService("HttpService")
	local cframeTargetTable = HttpService:JSONDecode(cframesStringValue.Value)
	local cframeTargets = cframeTargetTable["Items"]
	for index, targetVal in cframeTargets do
		local pathNames = targetVal["Path"]["InstanceNames"]
		local target = game.Workspace
		for i = 3, #pathNames do
			target = target:FindFirstChild(pathNames[i])
			if not target then
				break
			end
		end

		if (not target) or (target.Name == "Camera") then
			continue
		end

		if target then
			-- test 1ならPlayerのCharaにする
			-- if index == 1 then
			-- 	local player = game.Players.LocalPlayer
			-- 	if player then
			-- 		target = player.Character
			-- 		target.PrimaryPart.Anchored = true
			-- 	end
			-- end

			local targetFolder : Folder = cframesStringValue[tostring(index)]
			local cframeFolder = targetFolder:FindFirstChild("CFrame")
			if cframeFolder then
				task.spawn(function()
					playCore(target, cframeFolder)
				end)
			end
		end
	end
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function CutscenePlayer.InterpolateCameraStartPosition(startCFrame: CFrame, itpoTime)
	-- part名を入力して動かす
	local tweenInfo = TweenInfo.new(itpoTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local goal = {}
	goal.CFrame = startCFrame
	local tween = TweenService:Create(workspace.Camera, tweenInfo, goal)
	tween:Play()

	task.wait(itpoTime)
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function CutscenePlayer.InterpolateCameraToGamePosition(goalCameraCFrame: CFrame, itpoTime)
	print("InterpolateCameraToGamePosition begin")

	-- part名を入力して動かす
	local tweenInfo = TweenInfo.new(itpoTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local goal = {}
	goal.CFrame = goalCameraCFrame
	local tween = TweenService:Create(workspace.Camera, tweenInfo, goal)
	tween:Play()

	task.wait(itpoTime)

	print("InterpolateCameraToGamePosition end")
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function CutscenePlayer.OnEndCutscene()
	eventParam = nil
	playingCutName = nil
	-- 終わりの合図
	ReplicatedStorage.RemoteEvent.PlayCutsceneRemoteEvent:FireServer()
end

----------------------------------------------------------------------
-- ActionEvent
----------------------------------------------------------------------
function CutscenePlayer.TriggerMarker(markerName, cutFolder)
	-- 何をするかわからないので、taskで処理
	task.spawn(function()
		print("Trigger FrameMarker marker=" .. markerName)

		if markerName == "FadeIn" then
			UIManager.StartScreenFadeIn()
		elseif markerName == "FadeOut" then
			UIManager.StartScreenFadeOut()
		-- 汎用のトーク
		elseif markerName == "TalkSeq" then
		elseif markerName == "SetPosition" then
		else
		end
	end)
end

return CutscenePlayer
