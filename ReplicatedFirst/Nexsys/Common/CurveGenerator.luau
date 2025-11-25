local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Interpolation = require(ReplicatedFirst.Nexsys.Common.Interpolation)
local MathUtil = require(ReplicatedFirst.Nexsys.Common.MathUtil)
local ModelUtil = require(ReplicatedFirst.Nexsys.Common.ModelUtil)

local CurveGenerator = {}
CurveGenerator.__index = CurveGenerator
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function CurveGenerator.new(...)
	local self = setmetatable({}, CurveGenerator)
	CurveGenerator.Init(self, ...)
	return self
end

function CurveGenerator:Init(pointsFolder: Folder, outputFolder: Folder, isLoop, onTouchFunc)
	self.pointsFolder = pointsFolder
	self.outputFolder = outputFolder
	self.isLoop = isLoop
	self.onTouchFunc = onTouchFunc
	self.lastPos = nil
	self.count = 1
	self.isGenerated = false

	-- 分割数を割り切れる数字にしないと
	self.CREATE_PER_FRAME = 2
end

----------------------------------------------------------------------
-- 最後まで生成
----------------------------------------------------------------------
function CurveGenerator:GenerateAll(isReverse)
	if self.isGenerated then
		warn("CurveGenerator:GenerateAll already isGenerated")
		return
	end

	task.spawn(function()
		local folder = self.pointsFolder
		local pointParts = folder:GetChildren()
		local pointNum = #pointParts

		if pointNum <= 2 then
			return
		end

		-- 0を使って、1からの生成ができるように
		-- local part0 : Part = folder[1]:Clone()
		-- part0.Parent = folder
		-- part0.Name = "0"

		if self.isLoop then
			print("=== CurveGenerator loop ===")
			-- 実際には i+1からの生成
			for i = 1, pointNum do
				local idx1 = i
				local idx2 = i % pointNum + 1
				local idx3 = i + 2 > pointNum and i + 2 - pointNum or i + 2
				local idx4 = i + 3 > pointNum and i + 3 - pointNum or i + 3
				self:GenerateCurveWithParts(folder[idx1], folder[idx2], folder[idx3], folder[idx4])
			end
		else
			print("=== CurveGenerator NON loop ===")

			if isReverse then
				self:GenerateCurveWithParts(folder[pointNum], folder[pointNum], folder[pointNum - 1], folder[pointNum - 2])
				for i = 1, pointNum - 3 do
					self:GenerateCurveWithParts(folder[pointNum - i + 1], folder[pointNum - i], folder[pointNum - i - 1], folder[pointNum - i - 2])
				end
				self:GenerateCurveWithParts(folder[3], folder[2], folder[1], folder[1])
			else
				-- 最初は進行方向
				self:GenerateCurveWithParts(folder[1], folder[1], folder[2], folder[3])
				-- 実際には i+1からの生成
				for i = 1, pointNum - 3 do
					self:GenerateCurveWithParts(folder[i], folder[i + 1], folder[i + 2], folder[i + 3])
				end
				-- 最後
				self:GenerateCurveWithParts(folder[pointNum - 2], folder[pointNum - 1], folder[pointNum], folder[pointNum])
			end
		end
		self.isGenerated = true
	end)
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function CurveGenerator:GenerateCurveWithParts(a: Part, b: Part, c: Part, d: Part)
	local pointPosArray = {
		a.Position,
		b.Position,
		c.Position,
		d.Position,
	}

	-- 実際はbとcの距離を見て分割具合を変えたほうがいいかな
	-- for t = 0, 1, 0.025 do
	local waitCount = 0
	for t = 0, 1, 0.1 do
		local newPos = Interpolation.SplineWithArray(pointPosArray, t)

		if self.lastPos then
			self:CreateCurvePart(self.lastPos, newPos)

			waitCount += 1
			if waitCount >= self.CREATE_PER_FRAME then
				waitCount = 0
				task.wait()
			end
		end
		self.lastPos = newPos

		-- task.wait()
	end
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function CurveGenerator:CreateCurvePart(pos1: Vector3, pos2: Vector3)
	local part = Instance.new("Part")
	part.Parent = self.outputFolder
	part.Position = pos2 + Vector3.new(0, 0.5, 0)

	part.Color = Color3.fromRGB(97, 97, 97)
	part.Material = Enum.Material.Metal
	part.Reflectance = 1
	-- オフにするとキャラの場合重力影響が積まれるとカーブに沿わない
	-- part.CanCollide = false
	-- part.CanTouch = true
	-- part.CanQuery = false
	part.Anchored = true
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
	part.Name = tostring(self.count)

	local diff = pos2 - pos1
	local angleY = math.deg(math.atan2(diff.X, diff.Z))
	local angleX = math.deg(MathUtil.GetVectorRotationX(diff))

	-- 円柱版
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(diff.Magnitude + 0.2, 0.5, 0.5) -- 少しOverlapさせる
	part.Orientation = Vector3.new(0, angleY + 90, -angleX)

	-- 移動床化
	-- part.AssemblyLinearVelocity = -part.CFrame.LookVector * 20

	self.count += 1

	if self.onTouchFunc then
		part.Touched:Connect(function(otherPart)
			self.onTouchFunc(otherPart, part)
		end)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveGenerator:DeleteAll()
	local children = self.outputFolder:GetChildren()
	for index, part in children do
		part:Destroy()
	end

	-- Generate前の初期値に戻す
	self.lastPos = nil
	self.count = 1
	self.isGenerated = false
end
----------------------------------------------------------------------------------------------------
-- FadeOutDestroy
function CurveGenerator:FadeOutDestroyAll(fadeOutTime)
	local children = self.outputFolder:GetChildren()
	for index, part in children do
		ModelUtil.FadeOut(part, fadeOutTime)
	end

	task.spawn(function()
		task.wait(fadeOutTime)
		self:DeleteAll()
		self.isGenerated = false
	end)
end

return CurveGenerator
