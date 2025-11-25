local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local CurveCalculator = require(ReplicatedFirst.Nexsys.Common.CurveCalculator)
local MathUtil = require(ReplicatedFirst.Nexsys.Common.MathUtil)
local RailMove = {}
RailMove.__index = RailMove

local ALIGN_POS_INS_NAME = "RailMoveAlignPosition"
local TARGET_INS_NAME = "RailMoveTarget"
----------------------------------------------------------------------
-- AlignPositionでのレール移動
----------------------------------------------------------------------
function RailMove.new(...)
	local self = setmetatable({}, RailMove)
	RailMove.Init(self, ...)
	return self
end

function RailMove:Init(model : Model, curveFolder : Folder, isLoop, zRot, accel, speed, yOfs)
	self.pointFolder = curveFolder
	self.moveModel = model
	self.connectUpdate = nil
	self.isLoop = isLoop
	self.zRotOfs = zRot
	self.yOfs = yOfs
	self.moveSpeed = 40
	if speed then
		self.moveSpeed = speed
	end
	self.accel = accel
end
----------------------------------------------------------------------
-- 更新 : Start時点でconnectUpdateに入れる、終わると更新も解除される
----------------------------------------------------------------------
function RailMove:Update(dt)
	-- こっちに移行するならちゃんとコピーしてこないと


	-- if hum and (hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.Jumping) then
	-- 	break
	-- end
	if self.accel then
		self.moveSpeed += self.accel * dt
		self.curve:SetSpeed(self.moveSpeed)
	end

	self.curve:Update(dt)
	local curvePos : Vector3 = self.curve:GetCurrentPoint()
	if self.yOfs then
		curvePos += Vector3.new(0, self.yOfs, 0)
	end
	local myPos = self.moveModel:GetPivot().Position
	-- curPosに1フレでつくようなVelocityを発生させる
	local dist = curvePos - myPos
	if MathUtil.IsZeroVector3(dist) then
		print("zero vector")	
	else
		local dir = dist.Unit
		local rotY = MathUtil.GetVectorRotationY(dir)

		local degRotY = math.deg(rotY)
		-- print("deg="..degRotY..", rotY="..rotY..", dir=("..dir.X..", "..dir.Z..")")
		-- local rotZ = math.rad(-90)
		local rotZ = self.zRotOfs and math.rad(self.zRotOfs) or 0
		local cf = CFrame.new(curvePos) * CFrame.fromOrientation(0, rotY + math.pi, rotZ)
		self.moveModel:PivotTo(cf)
	end

	-- loopじゃない場合終わる
	if self.curve:IsEnd() then
		print("curve end")
		self:Stop()
		-- 慣性を与えて終了
		local primaryPart = self.moveModel.PrimaryPart
		if primaryPart then
			primaryPart.AssemblyLinearVelocity = primaryPart.CFrame.LookVector * self.moveSpeed * 0.7
		end
	end

	-- debug描画
	-- local drawer = Instance.new("Part")
	-- drawer.Parent = workspace
	-- drawer.Shape = Enum.PartType.Ball
	-- drawer.Position = curvePos
	-- drawer.Anchored = true
	-- drawer.CanCollide = false
	-- drawer.CanTouch = false
	-- drawer.CanQuery = false
	-- drawer.Transparency = 0.8
	-- drawer.BrickColor = BrickColor.Green()
	-- Debris:AddItem(drawer, 3)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function RailMove:StartByIndex(startIndex)
	local moveObj = self.moveModel
	local folder : Folder = self.pointFolder
	local positions = {}
	local isReverse = false

	local hum = moveObj:FindFirstChildOfClass("Humanoid")
	local rootHeight = 0
	if hum then
		local hipHeight = hum.HipHeight
		rootHeight = hipHeight + hum.RootPart.Size.Y / 2

		local startPart : Part = folder[tostring(startIndex)]
		-- シリンダーを横向きでやってるのでXVectorで考える
		local partDirXZ = -startPart.CFrame.XVector
		partDirXZ = (partDirXZ * Vector3.new(1, 0, 1)).Unit

		local charaDirXZ = hum.RootPart.CFrame.LookVector
		charaDirXZ = (charaDirXZ * Vector3.new(1, 0, 1)).Unit

		local diffRad = MathUtil.GetAngleBetweenVectors(partDirXZ, charaDirXZ)
		if diffRad > math.rad(90) then
			isReverse = true
		end

		print("diffDeg="..math.deg(diffRad))
		print(isReverse)
	end
	local num = #folder:GetChildren()
	-- reverseならpositionsに逆に入れる
	local curveStartIndex = startIndex
	if isReverse then
		for i = num, 1, -1 do
			local part = folder[tostring(i)]
			positions[num - i + 1] = part.Position + Vector3.new(0, part.Size.Y/2 + rootHeight, 0)
		end
		curveStartIndex = num - startIndex + 1
	else
		for i = 1, num do
			local part = folder[tostring(i)]
			positions[i] = part.Position + Vector3.new(0, part.Size.Y/2 + rootHeight, 0)
		end
	end


	-- print("CurvePointNum="..num)

	local curve = CurveCalculator.new(positions, self.isLoop)
	self.curve = curve
	curve:SetCurrentIndex(curveStartIndex)
	curve:SetSpeed(self.moveSpeed)

	self.connectUpdate = RunService.Stepped:Connect(function(time, deltaTime)
		self:Update(deltaTime)
	end)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function RailMove:StartWithPart(railPart : Part)
	local startIdx = tonumber(railPart.Name)
	-- self:StartByAlignPos(startIdx)
	self:StartByIndex(startIdx)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function RailMove:Stop()
	if self.connectUpdate then
		self.connectUpdate:Disconnect()
	end

	if self.curveMoveTask then
		task.cancel(self.curveMoveTask)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function RailMove:IsEnd()
	if not self.curve then
		return true
	end
	if self.curve:IsEnd() then
		return true
	end
end


return RailMove