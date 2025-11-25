local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ComponentBase = require(ReplicatedFirst.Nexsys.Common.Component.ComponentBase)
local GameSystemUtil = require(ReplicatedFirst.Nexsys.Common.GameSystemUtil)

--- @class SpinMover : ComponentBase
local SpinMover = {}
SpinMover.__index = SpinMover
setmetatable(SpinMover, ComponentBase)

----------------------------------------------------------------------------------------------------
-- 
function SpinMover.new(...)
	local self = setmetatable(ComponentBase.new(...), SpinMover)
	SpinMover.Init(self, ...)
	return self
end

function SpinMover:Init(ins : BasePart)
	local part
	-- print("SpinPos", spinPos, ins:GetPivot())
	if ins:IsA("Model") then
		part = ins.PrimaryPart
		if not part then
			part = ins:FindFirstChildWhichIsA("BasePart")
		end
	elseif ins:IsA("BasePart") then
		part = ins
	else
		assert(false, "SpinMover:Init() invalid type")
	end

	if not part then
		warn("SpinMover:Init() not found part", ins:GetFullName())
		return
	end

	self.part = part
	part.Anchored = false
	-- サーバー管理固定
	part:SetNetworkOwner(nil)

	-- ヒンジ用のパーツとアタッチ
	local hingePart = Instance.new("Part")
	hingePart.Size = Vector3.new(0.1, 0.1, 0.1)
	hingePart.Position = part.Position
	hingePart.Orientation = part.Orientation
	-- hingePart:PivotTo(ins:GetPivot())
	GameSystemUtil.SetToMarkerPart(hingePart)
	hingePart.Massless = false
	hingePart.Parent = part

	local hingeAttach = Instance.new("Attachment")
	hingeAttach.Name = "BaseAttachment"
	-- hingeAttach.WorldAxis = Vector3.new(0, 1, 0)
	hingeAttach.Axis = Vector3.new(0, 1, 0)
	hingeAttach.SecondaryAxis = Vector3.new(-1, 0, 0)
	hingeAttach.Parent = hingePart


	-- local hingeAttach, part = GameSystemUtil.MakeAttachmentOnModelPivot(ins, Vector3.zero, "HingeAttach")
	-- hingeAttach.WorldAxis = Vector3.new(0, 1, 0)
	-- hingePart.Massless = false

	-- 自分のアタッチ
	local insAttach = Instance.new("Attachment")
	insAttach.Name = "InsAttachment"
	-- insAttach.WorldAxis = Vector3.new(0, 1, 0)
	-- 位置をヒンジの位置に合わせる
	-- insAttach.WorldCFrame = ins:GetPivot()
	insAttach.Axis = Vector3.new(0, 1, 0)
	insAttach.SecondaryAxis = Vector3.new(-1, 0, 0)
	insAttach.Parent = part

	-- ヒンジ作成
	local hinge = Instance.new("HingeConstraint")
	hinge.Attachment0 = hingeAttach
	hinge.Attachment1 = insAttach
	hinge.Parent = part

	-- AV作成
	local angVel = Instance.new("AngularVelocity")
	angVel.Attachment0 = insAttach
	angVel.MaxTorque = 1000000000
	angVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0

	local isReverse = ins:GetAttribute("Reverse")
	local speed = ins:GetAttribute("Speed") or 1
	local rotSpeed = isReverse and -speed or speed
	angVel.AngularVelocity = Vector3.new(rotSpeed, 0, 0)
	angVel.Enabled = true
	angVel.Parent = part
end

return SpinMover