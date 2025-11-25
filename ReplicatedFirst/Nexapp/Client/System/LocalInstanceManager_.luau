local ReplicatedFirst = game:GetService("ReplicatedFirst")
local InstanceManager = require(ReplicatedFirst.Nexsys.Common.InstanceManager)
--- @class LocalInstanceManager_ : InstanceManager
local LocalInstanceManager_ = {}
LocalInstanceManager_.__index = LocalInstanceManager_
setmetatable(LocalInstanceManager_, InstanceManager)

function LocalInstanceManager_.Init()
	LocalInstanceManager_.SetAutoInitComponentAll(true)

	-- サーバー側タグ依存だと初期化もつけないと
	-- InstanceManager.AddInitTags({"GameLeaderboard"})
	-- InstanceManager.SetCompDependency("GameLeaderboard", {"GameLeaderboard_"})

	-- 特定のTagのものを _LocalInitInstance 化
	-- local instances = CollectionService:GetTagged("AutoJump_")
	-- for _, ins : Instance in instances do
	-- 	warn("LocalInstanceManager_.Init", ins)
	-- 	ins:AddTag("_LocalInitInstance")
	-- end
end

return LocalInstanceManager_