local ReplicatedFirst = game:GetService("ReplicatedFirst")
local InstanceManager = require(ReplicatedFirst.Nexsys.Common.InstanceManager)
--- @class ServerInstanceManager_ : InstanceManager
local ServerInstanceManager_ = {}
ServerInstanceManager_.__index = ServerInstanceManager_
setmetatable(ServerInstanceManager_, InstanceManager)

function ServerInstanceManager_.Init()
	-- System側で使うComponentは明示
	-- ServerInstanceManager_.AddInitTags({"LineMover", "Spinning"})

	ServerInstanceManager_.SetAutoInitComponentAll(true)

	-- Component付与したあとによぶ
	InstanceManager.Init()

	-- 特定のTagのものを _LocalInitInstance 化
	-- local instances = CollectionService:GetTagged("AutoJump_")
	-- for _, ins : Instance in instances do
	-- 	warn("LocalInstanceManager_.Init", ins)
	-- 	ins:AddTag("_LocalInitInstance")
	-- end
end

return ServerInstanceManager_
