local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Interpolation = require(ReplicatedFirst.Nexsys.Common.Interpolation)

local CurveCalculator = {}
CurveCalculator.__index = CurveCalculator
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveCalculator.new(...)
	local self = setmetatable({}, CurveCalculator)
	CurveCalculator.Init(self, ...)
	return self
end

function CurveCalculator:Init(points : {}, isLoop)
	self.points = points
	self.speed = 30
	self.value = 0
	self.isLoop = isLoop
	self.curIndex = 1
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveCalculator:SetLoop(val)
	self.isLoop = val
end
function CurveCalculator:SetCurrentIndex(index)
	self.curIndex = index
end
function CurveCalculator:SetSpeed(speed)
	self.speed = speed
end
----------------------------------------------------------------------
-- 現在位置更新
----------------------------------------------------------------------
function CurveCalculator:Update(dt)
	if self:IsEnd() or dt <= 0 then
		return
	end

	local dist = self:GetCurrentDistance()
	local advance = dt * self.speed
	local curValue = self.value + advance

	if curValue >= dist then
		local usedDist = dist - self.value
		local usedRate = usedDist / advance
		local remainDt = dt * (1 - usedRate)

		self:AdvanceControlPointIndex()
		self:Update(remainDt)
	else
		self.value = curValue
	end
end
----------------------------------------------------------------------
-- 現在の位置を取得
----------------------------------------------------------------------
function CurveCalculator:GetCurrentPoint()
	local points = {}
	self:GetUseControlPoints(self.curIndex, points)

	-- for index, p in points do
	-- 	if not p then
	-- 		warn("point not get")
	-- 	end
	-- end
	-- print(points)
	if #points <= 3 then
		warn("point 3")
		local ps = {}
		self:GetUseControlPoints(self.curIndex, ps)
	end

	local t = self:GetCurrentSplineRate()
	local curPoint = Interpolation.SplineWithArray(points, t)
	return curPoint
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveCalculator:GetCurrentSplineRate()
	if self:IsEnd() then
		return 0
	end

	local dist = self:GetCurrentDistance()
	local t = self.value / dist
	return t
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveCalculator:IsEnd()
	if self.isLoop then
		return false
	else
		return self.curIndex >= #self.points
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveCalculator:GetUseControlPoints(targetKey, points)
	local pointNum = #self.points
	if pointNum <= 3 then
		error("not implemented for under 3 points curve")
		return
	end
	if targetKey > pointNum then
		error("index over")
		return
	end

	if self.isLoop then
		for i = -1, 2, 1 do
			local index = targetKey + i
			if index > pointNum then
				-- index == pointNum で剰余取らないように注意
				index = index % pointNum
			end
			if index == 0 then
				index = pointNum
			end
			points[i + 2] = self.points[index]
		end
	else
		if targetKey <= 1 then
			points[1] = self.points[1]
			points[2] = self.points[1]
			points[3] = self.points[2]
			points[4] = self.points[3]
		elseif targetKey == pointNum - 1 then
			points[1] = self.points[pointNum - 2]
			points[2] = self.points[pointNum - 1]
			points[3] = self.points[pointNum]
			points[4] = self.points[pointNum]
		elseif targetKey == pointNum then
			points[1] = self.points[pointNum - 1]
			points[2] = self.points[pointNum]
			points[3] = self.points[pointNum]
			points[4] = self.points[pointNum]
		else
			for i = -1, 2, 1 do
				-- local index = (targetKey + i) % pointNum
				local index = targetKey + i
				points[i + 2] = self.points[index]
			end
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveCalculator:AdvanceControlPointIndex()
	self.value = 0
	local num = #self.points
	if self.isLoop then
		self.curIndex = self.curIndex % num + 1
	else
		if self.curIndex < num then
			self.curIndex += 1
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function CurveCalculator:GetCurrentDistance()
	if self:IsEnd() then
		return 0
	end

	local ci = self.curIndex
	local ni = ci + 1

	if ci >= #self.points then
		if self.isLoop then
			ni = 1
		else
			return math.huge
		end
	end
	
	if self.points[ni] == nil then
		print(ni)
	end
	if self.points[ci] == nil then
		print(ci)
	end

	local dist : Vector3 = self.points[ni] - self.points[ci]
	return dist.Magnitude
end


return CurveCalculator