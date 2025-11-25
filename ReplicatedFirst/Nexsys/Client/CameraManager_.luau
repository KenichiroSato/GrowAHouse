local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Timer = require(ReplicatedFirst.Nexsys.Common.Timer)
local Player = Players.LocalPlayer
local CameraManager_ = {}

local DEFAULT_ITPO_TIME = 2

local cameraInfo_ = {
	cameraCf = nil,
	focusCf = nil,
}

local followPart_ = nil
local followDist_ = 40
local isCameraShake_ = false
local shakePower_ = 30
local shakeTimer_ = Timer.new()

function CameraManager_.Init()
	RunService.Stepped:Connect(CameraManager_.Update)
	RunService.RenderStepped:Connect(CameraManager_.OnRenderStepped)
end

----------------------------------------------------------------------------------------------------
-- SaveCurrentCameraInfo
function CameraManager_.SaveCurrentCameraInfo()
	local camera = workspace.CurrentCamera
	cameraInfo_.cameraCf = camera.CFrame
	cameraInfo_.focusCf = camera.Focus
end
----------------------------------------------------------------------------------------------------
-- GetSavedCameraInfoDistance
function CameraManager_.GetSavedCameraInfoDistance()
	if cameraInfo_.cameraCf then
		local dist = cameraInfo_.cameraCf.Position - cameraInfo_.focusCf.Position
		return dist.Magnitude
	end
end
----------------------------------------------------------------------------------------------------
-- カメラを指定位置に補間移動
function CameraManager_.MoveToCameraPos(targetCf : CFrame, itpoTime : number?, isResetToCustom)
	task.spawn(function()
		local Camera = workspace.CurrentCamera
		Camera.CameraType = Enum.CameraType.Scriptable

		-- 補間時間
		local cameraInItpoTime = itpoTime or DEFAULT_ITPO_TIME

		-- カメラ補間移動
		CameraManager_.InterpolateCameraStartPosition(targetCf, cameraInItpoTime)

		if isResetToCustom then
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CFrame = targetCf
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- 
function CameraManager_.InterpolateCameraStartPosition(startCFrame: CFrame, itpoTime)
	-- part名を入力して動かす
	local tweenInfo = TweenInfo.new(itpoTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local goal = {}
	goal.CFrame = startCFrame
	local tween = TweenService:Create(workspace.Camera, tweenInfo, goal)
	tween:Play()

	task.wait(itpoTime)
end
----------------------------------------------------------------------------------------------------
-- 
local function resetToCustomCameraCore(isInstant, targetCf : CFrame)
	-- Subjectも戻す
	local hum = Player.Character:FindFirstChildOfClass("Humanoid")
	local Camera = workspace.CurrentCamera
	Camera.CameraSubject = hum

	if isInstant then
		Camera.CFrame = targetCf
		Camera.CameraType = Enum.CameraType.Custom
	else
		CameraManager_.MoveToCameraPos(targetCf, DEFAULT_ITPO_TIME, true)
	end

	cameraInfo_ = {
		cameraCf = nil,
		focusCf = nil,
	}
end
----------------------------------------------------------------------------------------------------
-- 
function CameraManager_.ResetToCustomCamera(isInstant)
	if not Player.Character then
		return
	end

	local dist = CameraManager_.GetSavedCameraInfoDistance() or 10
	local playerCf = Player.Character:GetPivot()
	local targetCf = playerCf + playerCf.LookVector * -dist
	--warn("ResetToCustomCamera", dist, targetCf.Position)
	resetToCustomCameraCore(isInstant, targetCf)
end
----------------------------------------------------------------------------------------------------
-- 
function CameraManager_.ResetToCustomCameraToLastPosition(isInstant)
	if not Player.Character then
		return
	end
	if not cameraInfo_.cameraCf then
		warn("cameraInfo_.cameraCf is nil")
		return
	end

	resetToCustomCameraCore(isInstant, cameraInfo_.cameraCf)
end
----------------------------------------------------------------------------------------------------
-- 
function CameraManager_.ResetToCustomCameraFront(isInstant)
	if not Player.Character then
		return
	end

	warn("ResetToCustomCameraFront")

	local playerCf = Player.Character:GetPivot()
	local targetCf = playerCf + playerCf.LookVector * 100
	warn(targetCf.Position)
	resetToCustomCameraCore(isInstant, targetCf)
end
----------------------------------------------------------------------------------------------------
-- StartFollowCameraMode
function CameraManager_.StartFollowCameraMode(targetPart : Part, itpoTime : number?)
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Attach
	camera.CameraSubject = targetPart

	-- camera.CFrame = targetPart.CFrame + Vector3.new(0, 0, -30)

	-- -- 最初は補完
	-- local itpo = itpoTime or 1
	-- CameraManager_.InterpolateCameraStartPosition(targetCf, itpo)
end
----------------------------------------------------------------------------------------------------
-- 特定のパーツをフォーカスするカメラ開始
function CameraManager_.StartFollowPartCamera(part : Part, itpoTime : number?)
	followPart_ = part
	local Camera = workspace.Camera
	Camera.CameraType = Enum.CameraType.Scriptable

	local targetCf = CameraManager_.GetFollowCameraCFrame()
	-- 最初は補完
	local itpo = itpoTime or 1
	CameraManager_.InterpolateCameraStartPosition(targetCf, itpo)
end

----------------------------------------------------------------------------------------------------
-- FollowCamera終了
function CameraManager_.EndFollowPartCamera(resetToCustom)
	followPart_ = nil
	if resetToCustom then
		local Camera = workspace.Camera
		Camera.CameraType = Enum.CameraType.Custom
	end
end
----------------------------------------------------------------------------------------------------
-- 
function CameraManager_.Update(time, dt)
	if followPart_ then
		local camera = workspace.Camera
		-- ほかから戻されるのを防ぐ
		camera.CameraType = Enum.CameraType.Scriptable
		-- followPart_をフォーカスし続ける
		-- camera.CFrame = CameraManager_.GetFollowCameraCFrame()

		CameraManager_.UpdateSpringMove(dt)
	end
end

function CameraManager_.UpdateSpringMove(dt)
	-- バネカメラ移動
	local camera = workspace.CurrentCamera
	local targetCf = CameraManager_.GetFollowCameraCFrame()
	local spring = 0.05
	local newCf = camera.CFrame:Lerp(targetCf, spring)
	camera.CFrame = newCf
end
----------------------------------------------------------------------------------------------------
-- 
function CameraManager_.OnRenderStepped(dt)
	CameraManager_.UpdateCameraShake(dt)
end
----------------------------------------------------------------------------------------------------
-- updateCameraShake
function CameraManager_.UpdateCameraShake(dt)
	if isCameraShake_ then
		if shakeTimer_:IsActive() then
			local camera = workspace.CurrentCamera
			local shakeX = math.random(-shakePower_, shakePower_) / 100
			local shakeY = math.random(-shakePower_, shakePower_) / 100
			local shakeZ = math.random(-shakePower_, shakePower_) / 100
			local shakeCf = camera.CFrame * CFrame.new(shakeX, shakeY, shakeZ)
			camera.CFrame = shakeCf
		else
			shakeTimer_:Clear()
			isCameraShake_ = false
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function CameraManager_.GetFollowCameraCFrame()
	local targetPos = followPart_.CFrame.Position
	local cameraPos = targetPos + Vector3.new(0, followDist_, -followDist_)
	local newCf = CFrame.new(cameraPos, targetPos)
	return newCf
end

----------------------------------------------------------------------------------------------------
-- ShakeCamera
function CameraManager_.ShakeCamera(shakeTime : number, shakePower : number, resetToCustom : boolean?)
	print("CameraManager_.ShakeCamera", shakeTime, shakePower)

	shakeTimer_:StartWithSpan(shakeTime)
	isCameraShake_ = true


	-- local camera = workspace.CurrentCamera
	-- camera.CameraType = Enum.CameraType.Scriptable
	-- -- local startCf = camera.CFrame
	-- local baseCf = camera.CFrame


	-- task.spawn(function()
	-- 	local t = 0
	-- 	local interval = ReplicatedFirst.DevConfig.ShakeInterval.Value
	-- 	-- shakePower = ReplicatedFirst.DevConfig.ShakeRate.Value
	-- 	while t < shakeTime do
	-- 		baseCf = camera.CFrame

	-- 		local shakeX = math.random(-shakePower, shakePower) / 100
	-- 		local shakeY = math.random(-shakePower, shakePower) / 100
	-- 		local shakeZ = math.random(-shakePower, shakePower) / 100
	-- 		local shakeCf = baseCf * CFrame.new(shakeX, shakeY, shakeZ)
	-- 		camera.CFrame = shakeCf
	-- 		t += task.wait(interval)
	-- 	end
	-- 	-- reset処理
	-- 	-- camera.CFrame = startCf

	-- 	if resetToCustom then
	-- 		camera.CameraType = Enum.CameraType.Custom
	-- 	end
	-- end)
end
----------------------------------------------------------------------------------------------------
-- StartFixCameraMode
function CameraManager_.StartFixedCameraMode(cameraCf : CFrame, focusCf : CFrame)
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Fixed
	camera.CFrame = cameraCf
	camera.Focus = focusCf
end
----------------------------------------------------------------------------------------------------
-- StartManualFixCamera
function CameraManager_.StartManualFixCamera(cameraCf : CFrame, focusCf : CFrame)
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cameraCf
	camera.Focus = focusCf
end
----------------------------------------------------------------------------------------------------
-- キャラクターにカメラを合わせる(主にスポーン時用)
-- ChatGPT生成処理
function CameraManager_.AlignCameraToCharacter(character : Model)
	-- print("CameraManager_.AlignCameraToCharacter", character)
	local cam       = workspace.CurrentCamera
	local root = character:WaitForChild("HumanoidRootPart")

    RunService.RenderStepped:Wait()           -- デフォルトカメラが初期化されるまで 1 フレーム待つ

    local dist   = (cam.CFrame.Position - root.Position).Magnitude -- 現在のズーム距離を保持
    local height = cam.CFrame.Y - root.Position.Y                  -- 高さオフセットも保持

    cam.CameraType = Enum.CameraType.Scriptable  -- 一時的にスクリプト制御
    local backPos  = root.Position
                    - root.CFrame.LookVector * dist
                    + Vector3.new(0, height, 0)
    cam.CFrame     = CFrame.new(backPos, root.Position) -- 同じ向きで見下ろす
    cam.CameraType = Enum.CameraType.Custom             -- 標準カメラへ戻す
    cam.CameraSubject = character:WaitForChild("Humanoid")
end

return CameraManager_