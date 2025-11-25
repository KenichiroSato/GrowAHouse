local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)

--- @class TransformComp : ComponentBase
local TransformComp = {}
TransformComp.__index = TransformComp
setmetatable(TransformComp, ComponentBase)

-----------------------------------------------------------------------------------------------------
-- 
function TransformComp.new(...)
	local self = setmetatable(ComponentBase.new(...), TransformComp)
	TransformComp.Init(self, ...)
	return self
end

function TransformComp:Init(ins : Model)
	self.instance = ins
end
----------------------------------------------------------------------------------------------------
-- SetPosition
function TransformComp:SetPosition(pos : Vector3)
	self.instance:PivotTo(self.instance:GetPivot().Rotation + pos)
end
----------------------------------------------------------------------------------------------------
-- SetRotation
function TransformComp:SetRotationXYZ(rx, ry, rz)
	self.instance:PivotTo(CFrame.fromEulerAnglesXYZ(rx, ry, rz) + self.instance:GetPivot().Position)
end

return TransformComp