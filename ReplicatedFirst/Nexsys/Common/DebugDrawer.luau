local Debris = game:GetService("Debris")
local DebugDrawer = {}

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function DebugDrawer.DrawArrow(originPos : Vector3, targetPos : Vector3, drawTime)
	local line = Instance.new("Part")
	line.Parent = workspace.Debug
	line.Shape = Enum.PartType.Block
	local dist = targetPos - originPos
	local pos = originPos + dist/2
	line.Size = Vector3.new(1, 1, dist.Magnitude)
	line.CFrame = CFrame.lookAt(pos, targetPos)
	line.Anchored = true
	line.CanCollide = false
	line.Transparency = 0.8
	line.BrickColor = BrickColor.Blue()

	local head = Instance.new("Part")
	head.Parent = workspace.Debug
	head.Shape = Enum.PartType.Ball
	head.CFrame = CFrame.new(targetPos)
	head.Size = Vector3.new(3, 3, 3)
	head.Anchored = true
	head.CanCollide = false
	head.Transparency = 0.8
	head.BrickColor = BrickColor.Blue()

	if drawTime then
		Debris:AddItem(line, drawTime)
		Debris:AddItem(head, drawTime)
	end
end

return DebugDrawer