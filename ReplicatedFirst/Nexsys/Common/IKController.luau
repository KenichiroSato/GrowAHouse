--- @class IKController : table
local IKController = {}
IKController.__index = IKController
----------------------------------------------------------------------------------------------------
-- 
function IKController.new(...)
	local self = setmetatable({}, IKController)
	IKController.Init(self, ...)
	return self
end

function IKController:Init(ins : Instance)
	self.instance = ins

	local animCtrl = ins:FindFirstChildOfClass("AnimationController")
	if not animCtrl then
		error("AnimationController not found")
		return
	end
	self.ikControl = animCtrl:FindFirstChildOfClass("IKControl")
	if not self.ikControl then
		error("IKControl not found")
		return
	end
end
----------------------------------------------------------------------------------------------------
-- SetupIKControl
function IKController:SetupIKControl(chainRootPart : BasePart, endEffectorPart : BasePart, ikControlType : Enum.IKControlType?)
	if not self.ikControl then
		return
	end

	self.ikControl.Type = ikControlType or Enum.IKControlType.Transform
	self.ikControl.ChainRoot = chainRootPart
	self.ikControl.EndEffector = endEffectorPart
	self.ikControl.Target = nil
	self.ikControl.Pole = nil -- optional part to indicate the bend of the elbowprint("Hello world!")
	self.ikControl.SmoothTime = 1
end
----------------------------------------------------------------------------------------------------
-- 
function IKController:SetTarget(target : BasePart | Attachment)
	self.ikControl.Target = target
end

return IKController