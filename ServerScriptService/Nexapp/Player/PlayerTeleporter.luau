-- !strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportFunction = ReplicatedStorage.RemoteEvent.TeleportFunction :: RemoteFunction

local PlayerTeleporter = {}

local function TeleportToShop(player, shopName: string): boolean
	local positionName = shopName .. "ShopSpawnPosition"
	local position = workspace:FindFirstChild(positionName, true) :: BasePart?
	local character = player.Character
	if not character or not position then
		return false
	end

	character:PivotTo(position.CFrame)
	return true
end

function PlayerTeleporter.Start()
	TeleportFunction.OnServerInvoke = TeleportToShop
end

return PlayerTeleporter
