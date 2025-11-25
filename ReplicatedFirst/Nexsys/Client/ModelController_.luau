local ReplicatedFirst = game:GetService("ReplicatedFirst")
local InstanceManager = require(ReplicatedFirst.Script.InstanceManager)
local ModelUtil = require(ReplicatedFirst.Script.ModelUtil)
--- @class ModelController : table
local ModelController = {}

----------------------------------------------------------------------------------------------------
-- HideAllCharacters
function ModelController.HideAllCharacters(excludeMe : boolean?)
	local players = game.Players:GetPlayers()
	for index, player in players do
		if excludeMe and player == game.Players.LocalPlayer then
			continue
		end
		if player.Character then
			local modelComp = InstanceManager.GetModelComponent(player.Character)
			if modelComp then
				modelComp:SetVisible(false)
			end

			-- 今回はFollowerも消す
			local followerSet : Folder = workspace.Followers:FindFirstChild("fs_"..player.Name)
			if followerSet then
				local followerModel : Model = followerSet:FindFirstChild("Follower")
				if followerModel then
					ModelUtil.HideModel(followerModel, true)
				end
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
-- ShowAllCharacters
function ModelController.ShowAllCharacters(excludeMe : boolean?)
	local players = game.Players:GetPlayers()
	for index, player in players do
		if excludeMe and player == game.Players.LocalPlayer then
			continue
		end
		if player.Character then
			local modelComp = InstanceManager.GetModelComponent(player.Character)
			if modelComp then
				modelComp:SetVisible(true)
			end

			-- Followerも戻す
			local followerSet : Folder = workspace.Followers:FindFirstChild("fs_"..player.Name)
			if followerSet then
				local followerModel : Model = followerSet:FindFirstChild("Follower")
				if followerModel then
					ModelUtil.ShowModel(followerModel)
				end
			end
		end
	end
end

return ModelController