local WaitEvent_ = {}
WaitEvent_.__index = WaitEvent_

function WaitEvent_.new(...)
	local self = setmetatable({}, WaitEvent_)
	WaitEvent_.Init(self, ...)
	return self
end

function WaitEvent_:Init(waitTime)
	self.isEnd = false

	task.spawn(function()
		task.wait(waitTime)
		self.isEnd = true
	end)
end

function WaitEvent_:IsEnd()
	return self.isEnd
end

return WaitEvent_