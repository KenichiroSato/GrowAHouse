local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseComponentManager = require(ReplicatedFirst.Nexsys.Common.BaseComponentManager)
local InstanceManager = require(ReplicatedFirst.Nexsys.Common.InstanceManager)

--- @class ComponentManager : BaseComponentManager
local ComponentManager = {}
ComponentManager.__index = ComponentManager
setmetatable(ComponentManager, BaseComponentManager)

----------------------------------------------------------------------------------------------------
--- @return PlayerVehicle
function ComponentManager.GetPlayerVehicle(instance : PVInstance)
	return InstanceManager.GetComponentByInstance("PlayerVehicle", instance)
end
----------------------------------------------------------------------------------------------------
--- @return PartyPlayRange
function ComponentManager.GetPartyPlayRange(instance : Model)
	return InstanceManager.GetComponentByInstance("PartyPlayRange", instance)
end
----------------------------------------------------------------------------------------------------
-- Client用
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--- @return AreaUnlocker_
function ComponentManager.GetAreaUnlocker_(instance : Model)
	return InstanceManager.GetComponentByInstance("AreaUnlocker_", instance)
end
----------------------------------------------------------------------------------------------------
--- @return ObbyArea_
function ComponentManager.GetObbyArea_(instance : Model)
	return InstanceManager.GetComponentByInstance("ObbyArea_", instance)
end
----------------------------------------------------------------------------------------------------
--- @return UGCGetter_
function ComponentManager.GetUGCGetter_(instance : Model)
	return InstanceManager.GetComponentByInstance("UGCGetter_", instance)
end

return ComponentManager