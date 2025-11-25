local RunService = game:GetService("RunService")
--[=[
	@within Timer
	@type CallbackFn () -> ()
	Callback function.
]=]
type CallbackFn = () -> nil

--- @class Timer
local Timer = {}
Timer.__index = Timer

function Timer.new(endCallback : CallbackFn?)
	local obj = setmetatable({}, Timer)
	obj._StartTime = os.clock()
	obj.Span = nil
	obj.isStarted = false
	obj.endCallback = endCallback
	return obj
end

function Timer:Start()
	self._StartTime = os.clock()
	self.isStarted = true

	if self.Span and self.endCallback then
		local connection
		connection = RunService.Heartbeat:Connect(function(deltaTime)
			if not self:IsActive() then
				connection:Disconnect()
				if self.endCallback then
					self.endCallback()
				end
			end	
		end)
	end
end

function Timer:StartWithSpan(span)
	if not span then
		error("span invalid")
	end
	self.Span = span
	self:Start()
end

function Timer:RestartSpan()
	self:StartWithSpan(self.Span)
end

function Timer:GetTime()
	return os.clock() - self._StartTime
end

function Timer:GetTimeSec()
	return math.floor(self:GetTime())
end

function Timer:GetRemainingTime()
	if self.Span then
		local time = self:GetTime()
		if time <= self.Span then
			return self.Span - time
		end
	end
	return 0
end

function Timer:GetRemainingTimeSec()
	return math.floor(self:GetRemainingTime())
end

function Timer:GetRate()
	if self.Span then
		return math.min(self:GetTime() / self.Span, 1)
	else
		return 0
	end
end

function Timer:GetSpan()
	return self.Span
end

function Timer:SetSpan(span)
	self.Span = span
end

function Timer:HasSpan()
	return self.Span ~= nil
end

function Timer:Clear()
	self.Span = nil
	self.isStarted = false
end

function Timer:IsStarted()
	return self.isStarted
end

function Timer:IsEnd()
	if self.Span then
		return self:GetTime() >= self.Span
	else
		return false
	end
end

function Timer:IsActive()
	if self.Span then
		return self:GetTime() < self.Span
	else
		return self.isStarted
	end
end

return Timer