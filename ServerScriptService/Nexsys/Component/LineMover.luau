local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)

--- @class LineMover : ComponentBase
local LineMover = {}
LineMover.__index = LineMover
setmetatable(LineMover, ComponentBase)

----------------------------------------------------------------------------------------------------
-- 
function LineMover.new(...)
	local self = setmetatable(ComponentBase.new(...), LineMover)
	LineMover.Init(self, ...)
	return self
end

function LineMover:Init(ins : Model)
	-- print("LineMover:Init")

	self.instance = ins
	self:SetSteppedActive(true)
	self.speed = ins:GetAttribute("Speed") or 10

	local mover : BasePart = ins:FindFirstChild("Mover")
	mover.Anchored = false
	-- サーバー管理固定
	mover:SetNetworkOwner(nil)

	local p1 : BasePart = ins:FindFirstChild("P1")
	p1.Anchored = true
	p1.CanCollide = false
	p1.Transparency = 1

	local p2 = ins:FindFirstChild("P2")
	p2.Anchored = true
	p2.CanCollide = false
	p2.Transparency = 1

	local p1p2Dir = (p2.Position - p1.Position)
	self.p1p2Len = p1p2Dir.Magnitude
	p1p2Dir = p1p2Dir.Unit

	local moverAttach = Instance.new("Attachment")
	moverAttach.Parent = mover
	moverAttach.WorldAxis = p1p2Dir
	moverAttach.WorldSecondaryAxis = Vector3.new(0, 1, 0)
	self.mover = mover

	local p1Attach = Instance.new("Attachment")
	p1Attach.Parent = p1
	p1Attach.WorldAxis = p1p2Dir
	p1Attach.WorldSecondaryAxis = Vector3.new(0, 1, 0)
	self.p1 = p1

	local p2Attach = Instance.new("Attachment")
	p2Attach.Parent = p2
	p2Attach.WorldAxis = p1p2Dir
	p2Attach.WorldSecondaryAxis = Vector3.new(0, 1, 0)
	self.p2 = p2

	local prisma = Instance.new("PrismaticConstraint")
	prisma.Attachment0 = p1Attach
	prisma.Attachment1 = moverAttach
	prisma.ActuatorType = Enum.ActuatorType.Motor
	prisma.MotorMaxAcceleration = 1000000000
	prisma.MotorMaxForce = 1000000000
	prisma.Velocity = -self.speed
	prisma.Parent = ins
	self.prisma = prisma
end
----------------------------------------------------------------------------------------------------
-- OnStepped
function LineMover:OnStepped(_dt : number)
	local isP1Moving = self.prisma.Attachment0 == self.p1:FindFirstChildOfClass("Attachment")
	local target : Part = isP1Moving and self.p1 or self.p2
	local other : Part = isP1Moving and self.p2 or self.p1
	
	local diff : Vector3 = target.Position - self.mover.Position
	local diffToOther : Vector3 = other.Position - self.mover.Position
	-- print("linemover diffLen", diff.Magnitude, "diff", diff)
	-- print("linemover diffToOtherLen", diffToOther.Magnitude, "diffToOther", diffToOther)
	if diff.Magnitude < 0.1 or diffToOther.Magnitude > self.p1p2Len then
		self.prisma.Velocity = 0
		task.wait(0.5)
		self.prisma.Attachment0 = other:FindFirstChildOfClass("Attachment")
		self.prisma.Velocity = isP1Moving and self.speed or -self.speed
	end
end

return LineMover