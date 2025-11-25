--- @class TransformUtil : table
local TransformUtil = {}

----------------------------------------------------------------------------------------------------
-- SetRotation
function TransformUtil.SetRotationRad(instance : PVInstance, rotation : Vector3)
	local cf = CFrame.Angles(rotation.X, rotation.Y, rotation.Z) + instance:GetPivot().Position
	instance:PivotTo(cf)
end

return TransformUtil