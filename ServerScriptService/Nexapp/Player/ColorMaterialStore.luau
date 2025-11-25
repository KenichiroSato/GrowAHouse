local ColorMaterialStore = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage.RemoteEvent.ColorMaterialChangeEvent
local MaterialConverter = require(ReplicatedStorage.Script.MaterialConverter)

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerManager = require(ServerScriptService.Nexapp.Player.PlayerManager)

function ColorMaterialStore.Start() 
	Event.OnServerEvent:Connect(function(player: Player, modelName: string, value: any)
		local playerData = PlayerManager.GetPlayerData(player)
		if typeof(value) == "Color3" then
			playerData:SetLastPartColor(modelName, value)
		elseif typeof(value) == "EnumItem" then
			local matString = MaterialConverter.FromEnumToString(value)
			playerData:SetLastPartMaterial(modelName, matString)
		end
	end)
end

return ColorMaterialStore
