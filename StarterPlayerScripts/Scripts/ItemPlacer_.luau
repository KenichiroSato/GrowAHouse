--!strict
-- ModuleScript: ItemPlacer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer :: Player
local Camera = Workspace.CurrentCamera :: Camera

local remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvent")
local ItemPlaceEvent = remoteEventFolder:WaitForChild("ItemPlaceEvent") :: RemoteEvent

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SysTypes = require(ReplicatedFirst.Nexsys.Common.Types)
local SingleTapDetector_: SysTypes.SingleTapDetector_ = require(ReplicatedFirst.Nexsys.Client.SingleTapDetector_)

local ItemPlaceGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ItemPlaceGui") :: ScreenGui
local Frame = ItemPlaceGui:WaitForChild("Frame")
local UpButton = Frame:WaitForChild("UpButton") :: ImageButton
local DownButton = Frame:WaitForChild("DownButton"):: ImageButton
local TurnLeftButton = Frame:WaitForChild("TurnLeftButton") :: ImageButton
local TurnRightButton = Frame:WaitForChild("TurnRightButton") :: ImageButton
local CancelButton = Frame:WaitForChild("CancelButton") :: ImageButton

local Y_OFFSET_UNIT = 1
local yOffset = 0
local ROTATE_OFFSET_UNIT = 45
local rotateOffset = 0

UpButton.Activated:Connect(function()
	print("UpButton")
	yOffset += Y_OFFSET_UNIT
end)
DownButton.Activated:Connect(function()
	print("DownButton")
	yOffset -= Y_OFFSET_UNIT
end)
TurnLeftButton.Activated:Connect(function()
	print("TurnLeftButton")
	rotateOffset -= ROTATE_OFFSET_UNIT
end)
TurnRightButton.Activated:Connect(function()
	rotateOffset += ROTATE_OFFSET_UNIT
end)

local ItemPlacer_ = {}

-- 内部状態
local _ghost : Model? = nil
local _connRender : RBXScriptConnection? = nil
local _connInputBegan : RBXScriptConnection? = nil
local _connInputEnded : RBXScriptConnection? = nil
local _placingModelName : string? = nil
local _touchStartPos : Vector3? = nil

-- 追従設定
local FORWARD_DISTANCE = 8        -- プレイヤー前方オフセット
local RAY_DOWN_DISTANCE = 200     -- 地面検出のための下向きレイ長
local TOUCH_TAP_THRESHOLD = 10    -- タップ/スワイプ判定（ピクセル）

local singleTapDetector = SingleTapDetector_.new()

-- BasePart 群の半透明＆非衝突化（ゴースト用）
local function makeGhostLook(model: Model)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			-- クライアント限定で見た目だけ半透明（既存透明度は保持しつつ）
			d.LocalTransparencyModifier = 0.5
		elseif d:IsA("Decal") or d:IsA("Texture") then
			-- 見やすくするため薄めに
			d.Transparency = math.clamp((d.Transparency or 0) + 0.5, 0, 1)
		end
	end
end

-- Model を CFrame へ（PivotTo で一括）
local function pivotModel(model: Model, cf: CFrame)
	model:PivotTo(cf)
end

-- カメラ向きの水平 Yaw を取得
local function getCameraYaw(): number
	local look = Camera.CFrame.LookVector
	return math.atan2(-look.Z, look.X) -- Y軸ラジアン
end

-- プレイヤーの HRP を取得
local function getHRP(): BasePart?
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	return char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- 前方位置を算出し、地面に落とす
local function computeGhostCFrame(model: Model): CFrame
	local hrp = getHRP()
	if not hrp then
		return CFrame.new(Camera.CFrame.Position) -- フォールバック
	end

	-- 前方基準点
	local yaw = getCameraYaw()
	local forward = Vector3.new(math.cos(yaw), 0, -math.sin(yaw))
	local aheadPos = hrp.Position + forward * FORWARD_DISTANCE + Vector3.new(0, 5, 0) -- 少し上から

	-- 下向きレイで地面検出
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character :: Instance, _ghost }

	local result = Workspace:Raycast(aheadPos, Vector3.new(0, -RAY_DOWN_DISTANCE, 0), params)
	local placePos = result and result.Position or (hrp.Position + forward * FORWARD_DISTANCE)
	--local placePos =  (hrp.Position + forward * FORWARD_DISTANCE)

	-- 水平向きはカメラ Yaw に合わせる
	local rot = CFrame.Angles(0, yaw, 0)
	-- モデルの現在ピボットからの相対は不要：常にその場にピボットで置く
	local rotOffset = CFrame.Angles(0, math.rad(rotateOffset), 0)
	return CFrame.new(placePos) * rot * rotOffset + Vector3.new(0, yOffset, 0)
end

local function cleanupGhost()
	if _connRender then _connRender:Disconnect(); _connRender = nil end
	if _connInputBegan then _connInputBegan:Disconnect(); _connInputBegan = nil end
	if _connInputEnded then _connInputEnded:Disconnect(); _connInputEnded = nil end

	if _ghost then
		_ghost:Destroy()
		_ghost = nil
	end
	_placingModelName = nil
	_touchStartPos = nil
end


local function ResetOffset()
	ItemPlaceGui.Enabled = false
	yOffset = 0
	rotateOffset = 0
end

-- ========== 公開 API ==========

-- ゴースト開始：modelName を workspace/Items から探して半透明で追従表示
function ItemPlacer_.Start(modelName: string)
	-- 既存があればクリーン
	cleanupGhost()
	ItemPlaceGui.Enabled = true

	local itemsFolder = ReplicatedStorage:FindFirstChild("Shops")
	if not itemsFolder then
		warn("workspace/Items が見つかりません")
		return
	end

	local template = itemsFolder:FindFirstChild(modelName, true)
	if not template or not template:IsA("Model") then
		warn(("Items から Model '%s' が見つかりません"):format(modelName))
		return
	end

	local ghost = template:Clone()
	_ghost = ghost
	_placingModelName = modelName
	ghost.Parent = Workspace -- クライアント側表示用

	makeGhostLook(ghost)
	pivotModel(ghost, computeGhostCFrame(ghost))

	-- 追従（毎フレーム）
	_connRender = RunService.RenderStepped:Connect(function()
		if _ghost then
			pivotModel(_ghost, computeGhostCFrame(_ghost))
		end
	end)
	singleTapDetector:Start(function(input)
		-- 送信：modelName と 位置情報（CFrame）
		local cf = _ghost:GetPivot()
		ItemPlaceEvent:FireServer(_placingModelName, cf)

		-- ゴースト破棄
		cleanupGhost()
		ResetOffset()
		singleTapDetector:Stop()
	end)
end

-- 手動キャンセル
function ItemPlacer_.Cancel()
	ResetOffset()
	singleTapDetector:Stop()
	cleanupGhost()
end

-- いま配置中か？
function ItemPlacer_.IsPlacing(): boolean
	return _ghost ~= nil
end

CancelButton.Activated:Connect(function()
	ItemPlacer_.Cancel()
end)

return ItemPlacer_