local RunService = game:GetService("RunService")
local PathMove = {}
PathMove.__index = PathMove

----------------------------------------------------------------------------------------------------
function PathMove.new(...)
	local self = setmetatable({}, PathMove)
	PathMove.Init(self, ...)
	return self
end

function PathMove:Init(ins : PVInstance, pathPoints : table, isLoop, speed, posOffset : Vector3)
	-- self.pointFolder = pathFolder
	self.pathPoints = pathPoints
	self.moveIns = ins
	self.isLoop = isLoop
	self.moveSpeed = speed
	self.connectUpdate = nil
	self.posOffset = posOffset
	self.isEnd = false

	self.pointNum = #pathPoints
end
----------------------------------------------------------------------------------------------------
-- Destroy
function PathMove:Destroy()
	self:Stop()
end
----------------------------------------------------------------------------------------------------
-- GetPathPoints
function PathMove:GetPathPoints()
	return self.pathPoints
end
----------------------------------------------------------------------------------------------------
function PathMove:Start()
	self.currentIndex = 1

	if self.connectUpdate then
		self.connectUpdate:Disconnect()
	end

	self.connectUpdate = RunService.Stepped:Connect(function(time, deltaTime)
		self:Update(deltaTime)
	end)
end
----------------------------------------------------------------------------------------------------
function PathMove:Stop()
	if self.connectUpdate then
		self.connectUpdate:Disconnect()
	end
end
----------------------------------------------------------------------------------------------------
function PathMove:GetNextIndex()
	if self.isLoop then
		return self.currentIndex % self.pointNum + 1
	else
		if self.currentIndex >= self.pointNum then
			return self.currentIndex
		else
			return self.currentIndex + 1
		end
	end
end
----------------------------------------------------------------------------------------------------
-- IsEnd
function PathMove:IsEnd()
	if self.isLoop then
		return false
	else
		return self.isEnd
	end
end
----------------------------------------------------------------------------------------------------
-- Restart
function PathMove:Restart()
	self.currentIndex = 1
	self.isEnd = false
	self:Start()
	local cf = self:GetCurrentTargetCFrame()
	self.moveIns:PivotTo(cf)
end
----------------------------------------------------------------------------------------------------
function PathMove:Update(dt)
	local targetPos = self:GetCurrentTargetPos()
	local diff = targetPos - self.moveIns:GetPivot().Position

	-- Waypoint到達
	if diff.Magnitude <= 0.1 then
		if self.currentIndex >= self.pointNum then
			self.isEnd = true
			self:Stop()
			return
		end

		self.currentIndex = self:GetNextIndex()
		targetPos = self:GetCurrentTargetPos()
		diff = targetPos - self.moveIns:GetPivot().Position
	end

	local move = diff.Unit * self.moveSpeed * dt
	local newPos = self.moveIns:GetPivot().Position + move

	local lookAt = newPos + diff
	local lookAtXZ = Vector3.new(lookAt.X, self.moveIns:GetPivot().Position.Y, lookAt.Z)
	local newCf = CFrame.new(newPos, lookAtXZ)
	self.moveIns:PivotTo(newCf)
end
----------------------------------------------------------------------------------------------------
-- GetCurrentTargetPos
function PathMove:GetCurrentTargetPos()
	local pos = self.pathPoints[self.currentIndex].Position
	if self.posOffset then
		pos = pos + self.posOffset
	end
	return pos
end
----------------------------------------------------------------------------------------------------
-- GetCurrentTargetCFrame
function PathMove:GetCurrentTargetCFrame()
	local cf = self.pathPoints[self.currentIndex].CFrame
	if self.posOffset then
		cf = cf + self.posOffset
	end
	return cf
end
----------------------------------------------------------------------------------------------------

return PathMove