local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local InstanceHandler = require(ReplicatedFirst.Nexsys.Common.Instance.InstanceHandler)

--- @class ModelHandler : InstanceHandler
local ModelHandler = {}
ModelHandler.__index = ModelHandler
setmetatable(ModelHandler, InstanceHandler)

----------------------------------------------------------------------------------------------------
-- 
function ModelHandler.new(model : Model)
	local self = setmetatable(InstanceHandler.new(model), ModelHandler)
	ModelHandler.Init(self, model)
	return self
end

function ModelHandler:Init(instance : Model)
	self.instance = instance :: Model
end
----------------------------------------------------------------------------------------------------
-- 
function ModelHandler:HideModel()
	self.originalParent = self.instance.Parent
	self.instance.Parent = nil
end

function ModelHandler:ShowModel()
	if self.originalParent then
		self.instance.Parent = self.originalParent
	else
		warn("No original parent found for model")
	end
end
----------------------------------------------------------------------------------------------------
-- TweeenPivot
function ModelHandler:TweenPivot(targetCf : CFrame, itpoTime, style : Enum.EasingStyle?, direction : Enum.EasingDirection?, repeatCount : number?, reverses : boolean?)
	local cfVal = Instance.new("CFrameValue")
	cfVal.Value = self.instance:GetPivot()
	cfVal.Parent = self.instance
	local es = style or Enum.EasingStyle.Linear
	local ed = direction or Enum.EasingDirection.InOut
	local tweenInfo = TweenInfo.new(itpoTime, es, ed, repeatCount, reverses)
	local goal = {}
	goal.Value = targetCf
	local tween = TweenService:Create(cfVal, tweenInfo, goal)
	tween:Play()
	local connection = cfVal.Changed:Connect(function(value)
		self.instance:PivotTo(value)
	end)
	tween.Completed:Connect(function()
		connection:Disconnect()
		cfVal:Destroy()
	end)
end

return ModelHandler