-- PivotがInstanceの中心でない場合でも、Pivotを中心に回転させてInstanceを配置させるためのModule

local InstanceMover = {}

function InstanceMover.movePart(instance: Instance, newPos: Vector3, yawRad: number)
	if instance:IsA("Model") or instance:IsA("PVInstance") then
		
		local pivot = instance:GetPivot()

		-- 新しいピボットの CFrame（位置だけ更新、回転は一旦なし）
		local newPivot = CFrame.new(newPos)

		-- 回転を適用（Y軸だけ）
		local rotation = CFrame.Angles(0, yawRad, 0)

		-- 回転後の世界空間CFrameを計算
		local finalCFrame = newPivot * rotation

		-- 適用
		instance:PivotTo(finalCFrame)
	end
end


return InstanceMover
