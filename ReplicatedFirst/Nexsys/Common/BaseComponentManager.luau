local ReplicatedFirst = game:GetService("ReplicatedFirst")
local InstanceManager = require(ReplicatedFirst.Nexsys.Common.InstanceManager)

--- @class BaseComponentManager : table
local BaseComponentManager = {}
BaseComponentManager.__index = BaseComponentManager

----------------------------------------------------------------------------------------------------
-- WaitForComponent
function BaseComponentManager.WaitForComponent(instance : PVInstance, componentName : string, timeout : number?)
	local component = InstanceManager.GetComponentByInstance(componentName, instance)
	if component then
		return component
	end

	local startTime = tick()
	while tick() - startTime < (timeout or 5) do
		component = InstanceManager.GetComponentByInstance(componentName, instance)
		if component then
			return component
		end
		task.wait()
	end

	warn("ComponentManager.WaitForComponent - Timeout", componentName, instance:GetFullName())
	return nil
end
----------------------------------------------------------------------------------------------------
-- GetComponents
function BaseComponentManager.GetComponents(componentName : string)
	local result = {}
	local instances = InstanceManager.GetComponentInstances(componentName)
	for _, instance in ipairs(instances) do
		table.insert(result, InstanceManager.GetComponentByInstance(componentName, instance))
	end
	return result
end

----------------------------------------------------------------------------------------------------
-- GetTransformComponent
--- @return TransformComp
function BaseComponentManager.GetTransformComponent(instance : PVInstance)
	return InstanceManager.GetComponentByInstance("TransformComp", instance)
end
----------------------------------------------------------------------------------------------------
-- GetModelComponent
--- @return ModelComp
function BaseComponentManager.GetModelComponent(instance : PVInstance)
	return InstanceManager.GetComponentByInstance("ModelComp", instance)
end
----------------------------------------------------------------------------------------------------
-- GetAnimationComponent
--- @return AnimationComp
function BaseComponentManager.GetAnimationComponent(instance : PVInstance)
	return InstanceManager.GetComponentByInstance("AnimationComp", instance)
end

return BaseComponentManager