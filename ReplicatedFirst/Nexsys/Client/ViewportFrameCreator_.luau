--!strict
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SysTypes = require(ReplicatedFirst.Nexsys.Common.Types)

-- ViewportFrameCreator_.lua
-- ViewportFrame に Workspace のモデル/パーツを複製表示するクラス
-- 公開API: createViewport, destroy（clearは内部専用）

export type Type = {
	createViewport: (self: Type, viewport: ViewportFrame, modelName: string) -> (),
	destroy: (self: Type) -> (),
	setSpin: (self: Type, viewport: ViewportFrame, degPerSec: number?, axis: Vector3?) -> (),
}

type Bucket = {
	camera: Camera?,
	clones: {Model},
	spinConn: RBXScriptConnection?,
}

local ViewportFrameCreator_ = {}
ViewportFrameCreator_.__index = ViewportFrameCreator_

-- 内部状態: ViewportFrame -> {camera, clones}
type State = {[ViewportFrame]: Bucket}

local ColorMaterialSetter: SysTypes.ColorMaterialSetter = require(ReplicatedFirst.Nexsys.Common.ColorMaterialSetter)

-- ===== 内部専用: ビューポートの中身とカメラを掃除 =====
local function clear(self: { _state: State }, viewport: ViewportFrame)
	local bucket = self._state[viewport]
	if not bucket then return end
	
	-- 回転停止
	if bucket.spinConn then
		pcall(function() bucket.spinConn:Disconnect() end)
	end

	-- クローン破棄
	for i = #bucket.clones, 1, -1 do
		local inst = bucket.clones[i]
		if inst and inst.Destroy then
			pcall(function() inst:Destroy() end)
		end
		bucket.clones[i] = nil
	end

	-- カメラ破棄
	if bucket.camera and bucket.camera.Destroy then
		pcall(function() bucket.camera:Destroy() end)
	end
	viewport.CurrentCamera = nil

	self._state[viewport] = nil
end

-- ===== コンストラクタ =====
function ViewportFrameCreator_.new(): Type
	local self = setmetatable({
		_state = {} :: State,
	}, ViewportFrameCreator_)
	return self :: any
end

-- ===== 公開: 指定Viewportに modelName を描画 =====
function ViewportFrameCreator_:createViewport(viewport: ViewportFrame, modelName: string, rootFoloder: Folder, scale: Vector3, fov: number, distance: Vector3)
	-- 前回の残骸を安全に掃除（毎回作り直す設計）
	clear(self, viewport)

	-- カメラ作成
	local camera = Instance.new("Camera")
	camera.FieldOfView = fov and fov or 70
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	local root = rootFoloder or workspace

	-- Workspace から取得（Descendants含む）
	local target = root:FindFirstChild(modelName, true)
	if not target then
		warn("Model not found: " .. modelName)
		return
	end

	-- target must be Model or BasePart
	if not (target:IsA("Model") or target:IsA("BasePart")) then
		warn("Target is not a Model or BasePart: " .. modelName)
		return
	end

	-- クローンして ViewportFrame 配下へ
	local clone = target:Clone() :: Model
	clone.Parent = viewport
	-- 状態を保持
	self._state[viewport] = {
		camera = camera,
		clones = { clone },
	}

	-- カメラ位置をモデルサイズに応じて調整
	local cf: CFrame, size: Vector3
	if clone:IsA("Model") then
		--if clone.PrimaryPart then
	--		cf, size = clone.PrimaryPart.CFrame, clone.PrimaryPart.Size
		--else
			cf, size =  clone:GetBoundingBox()
		--end
	elseif clone:IsA("BasePart") then
		cf, size = clone.CFrame, clone.Size
	elseif (clone :: any).GetPivot ~= nil then
		cf = (clone :: any):GetPivot()
		size = Vector3.new(8, 8, 8)
	else
		cf = CFrame.new(0, 0, 0)
		size = Vector3.new(8, 8, 8)
	end
	
	local XYZScale = scale and scale or Vector3.new(1, 0.5, 1)
	local cameraDistance = distance and distance or Vector3.new(size.X/2 + 1, size.Y/2 + 0.5, size.Z/2 +1)

	-- 元コードの比率を踏襲（X*2, Y*0.5, Z*-1）
	camera.CFrame = CFrame.new(
		--cf.Position + Vector3.new(-size.X * 3, size.Y * 0.5, size.Z * 1),
		cf.Position + cameraDistance,
		cf.Position
	)
end

function ViewportFrameCreator_:SetColor(viewport: ViewportFrame, color: Color3, ignoreTag: string?)
	local b = self._state[viewport] :: Bucket
	if not b then return end
	for _ , model in pairs(b.clones) do
		ColorMaterialSetter.Set(model, color, nil, ignoreTag)
	end
end

function ViewportFrameCreator_:SetMaterial(viewport: ViewportFrame, material: Enum.Material, ignoreTag: string?)
	local b = self._state[viewport] :: Bucket
	if not b then return end
	for _ , model in pairs(b.clones) do
		ColorMaterialSetter.Set(model, nil, material, ignoreTag)
	end
end

-- 追記: 公開API 回転の開始/停止
function ViewportFrameCreator_:setSpin(viewport: ViewportFrame, degPerSec: number?, axis: Vector3?)
	local b = self._state[viewport] :: Bucket
	if not b then return end

	-- 既存回転を止める
	if b.spinConn then
		b.spinConn:Disconnect()
		b.spinConn = nil
	end

	-- 0 や nil を渡したら停止だけ
	if not degPerSec or degPerSec == 0 then return end

	axis = axis or Vector3.yAxis
	local radPerSec = math.rad(degPerSec)

	-- 代表クローン（先頭）を回す
	local clone = b.clones[1] :: Model
	if not clone then return end

	b.spinConn = RunService.RenderStepped:Connect(function(dt)
		local rot = CFrame.fromAxisAngle(axis, radPerSec * dt)

		if clone:IsA("Model") then
			if clone.PrimaryPart then
				-- deprecatedだが、PrimaryPart中心で回転させたいのでこれを使う
				clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame * rot)
			else
				local pv = clone:GetPivot()
				clone:PivotTo(pv * rot)        -- モデルを自分のピボットで回転
			end
		elseif clone:IsA("BasePart") then
			clone.CFrame = clone.CFrame * rot
		else
			-- GetPivot/PivotTo を持つ場合の汎用フォールバック
			local getPivot = clone.GetPivot
			local pivotTo = clone.PivotTo
			if getPivot and pivotTo then
				local pv = clone:GetPivot()
				clone:PivotTo(pv * rot)
			end
		end
	end)
end

-- ===== 公開: 全Viewportを掃除（インスタンス破棄時に呼ぶ） =====
function ViewportFrameCreator_:destroy()
	for viewport, _ in pairs(self._state) do
		clear(self, viewport:: ViewportFrame)
	end
end

return ViewportFrameCreator_