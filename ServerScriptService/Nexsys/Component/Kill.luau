local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)

--- @class Kill : ComponentBase
local Kill = {}
Kill.__index = Kill
setmetatable(Kill, ComponentBase)

----------------------------------------------------------------------------------------------------
-- 
function Kill.new(...)
	local self = setmetatable(ComponentBase.new(...), Kill)
	Kill.Init(self, ...)
	return self
end

function Kill:Init(ins : Instance)
	-- 自分と子供のパーツをkillBlockにする
	local parts = ins:GetDescendants()
	table.insert(parts, ins)
	for _, part : BasePart in parts do
		if part:IsA("BasePart") and part.CanTouch then
			part.Touched:Connect(function(hit : BasePart)
				self:onTouch(hit)
			end)
		end
	end
end

----------------------------------------------------------------------------------------------------
-- onTouch
function Kill:onTouch(part : BasePart)
	local hum = part.Parent:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Health = 0
	end
end

return Kill