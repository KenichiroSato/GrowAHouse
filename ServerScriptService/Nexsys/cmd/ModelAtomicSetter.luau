local ReplicatedFirst = game:GetService("ReplicatedFirst")
local InstanceManager = require(ReplicatedFirst.Nexsys.Common.InstanceManager)
return function(isRuntime)
	if not isRuntime then
		game:GetService("ChangeHistoryService"):SetWaypoint("BuildingCopy")
	end

	InstanceManager.SetupModelStremaingModeAtomic()
	print("ModelAtomicSetter Completed")
end

