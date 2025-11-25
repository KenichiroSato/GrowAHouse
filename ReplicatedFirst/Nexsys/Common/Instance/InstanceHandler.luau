--- @class InstanceHandler : table
local InstanceHandler = {}
InstanceHandler.__index = InstanceHandler

----------------------------------------------------------------------------------------------------
-- 
function InstanceHandler.new(...)
	local self = setmetatable({}, InstanceHandler)
	InstanceHandler.Init(self, ...)
	return self
end

function InstanceHandler:Init(instance : Instance)
	self.instance = instance
end

function InstanceHandler:GetInstance()
	return self.instance
end

function InstanceHandler:FindDescendant(name : string)
	return self.instance:FindFirstChild(name, true)
end

return InstanceHandler