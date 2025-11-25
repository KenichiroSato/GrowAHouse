local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local InstanceManager = require(ReplicatedFirst.Script.InstanceManager)
local ModelController_ = require(ReplicatedFirst.Client.ModelController_)
--- @class CharacterManager : table
local CharacterManager = {}

local isHideAllChara_ = false

----------------------------------------------------------------------------------------------------
-- Init
function CharacterManager.Init()
	-- Player追加時フック、自分は初めからいるので明示的にコール
	Players.PlayerAdded:Connect(function(player)
		CharacterManager.onPlayerAdded(player)
	end)
	CharacterManager.onPlayerAdded(Players.LocalPlayer)
end

----------------------------------------------------------------------------------------------------
-- onPlayerAdded
function CharacterManager.onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		-- print("Player Init Componet", character.Name)
		-- ModelComponentの付与のためのコール
		InstanceManager.CreateComponentInstance(character)

		if isHideAllChara_ then
			local modelComp = InstanceManager.GetModelComponent(character)
			if modelComp then
				modelComp:SetVisible(false)
			end
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- HideAllCharacters
function CharacterManager.HideAllCharacters(excludeMe)
	ModelController_.HideAllCharacters(excludeMe)
	isHideAllChara_ = true
end
----------------------------------------------------------------------------------------------------
-- ShowAllCharacters
function CharacterManager.ShowAllCharacters(excludeMe)
	ModelController_.ShowAllCharacters(excludeMe)
	isHideAllChara_ = false
end

return CharacterManager