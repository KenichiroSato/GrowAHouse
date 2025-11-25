local RunService = game:GetService("RunService")
--- @class CountUp : table
local CountUp = {}
CountUp.__index = CountUp

function CountUp.new(...)
	local self = setmetatable({}, CountUp)
	CountUp.Init(self, ...)
	return self
end

function CountUp:Init()
	self.updateConnection = RunService.Stepped:Connect(function(time, deltaTime)
		self:Update(deltaTime)
	end)
end

----------------------------------------------------------------------------------------------------
-- Delete
function CountUp:Delete()
	if self.updateConnection then
		self.updateConnection:Disconnect()
	end
end
----------------------------------------------------------------------------------------------------
-- 
function CountUp:Start(startNum, endNum, duration, callback)
	if startNum == endNum then
		return
	end

	self.step = 1
	self.startNum = startNum
	self.endNum = endNum
	self.count = startNum
	self.duration = duration
	self.stepTime = duration / (endNum - startNum)
	self.timer = 0
	self.isEnd = false
	self.callback = callback
end
----------------------------------------------------------------------------------------------------
-- IsActive
function CountUp:IsActive()
	return self.startNum and (not self.isEnd)
end
----------------------------------------------------------------------------------------------------
-- Update
function CountUp:Update(dt)
	if not self:IsActive() then
		return
	end

	self.timer = self.timer + dt
	if self.timer >= self.stepTime then
		self.count = self.count + self.step
		self.timer = 0
	end

	if self.count >= self.endNum then
		self.count = self.endNum
		self.isEnd = true
	end

	self.callback(self.count)
end

return CountUp