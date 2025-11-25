-- !strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportToShopEvent = ReplicatedStorage.RemoteEvent.TeleportToShopEvent

local PlayerTeleporter = {}

local function TeleportToShop(player, shopName: string)
	local positionName = shopName .. "ShopSpawnPosition"
	local position = workspace:FindFirstChild(positionName, true):: BasePart
	local character = player.Character
	if not character then return end

	character:PivotTo(position.CFrame)
end

function PlayerTeleporter.Start()
	TeleportToShopEvent.OnServerEvent:Connect(function(player, shopName:string)
		TeleportToShop(player, shopName)
	end)
end

return PlayerTeleporter
