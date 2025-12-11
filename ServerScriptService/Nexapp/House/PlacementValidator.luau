--!strict

local PlacementValidator = {}

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Define = require(ReplicatedFirst.Nexapp.Common.Define)

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerManager = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("Player"):WaitForChild("PlayerManager"))
local HouseBaseManager = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("House"):WaitForChild("HouseBaseManager"))
local ServerRemoteSender = require(ServerScriptService.Nexsys.ServerRemoteSender)

--========================
-- Private Functions
--========================

local function IsInTheProperty(player: Player, position: Vector3): boolean
	local basePart = HouseBaseManager.GetBase(player)
	if not basePart then
		-- Base might not be loaded yet or error case
		return false 
	end
	
	local basePosition = basePart.Position
	local baseSize = basePart.Size
	return basePosition.X - baseSize.X/2 <= position.X and 
		basePosition.X + baseSize.X/2 >= position.X and
		basePosition.Z - baseSize.Z/2 <= position.Z and
		basePosition.Z + baseSize.Z/2 >= position.Z
end

local function CanPlaceMore(player: Player): boolean
	local gamePlayer = PlayerManager.GetGamePlayer(player)
	if not gamePlayer then
		return false
	end	
	local placedCount = gamePlayer:GetPlayerData():GetPlacedItemNum()
	return placedCount < Define.MAX_PLACED_ITEMS_NUM
end

--========================
-- Public Methods
--========================

function PlacementValidator.Validate(player: Player, position: Vector3): boolean
	-- Check if player can place more items
	if not CanPlaceMore(player) then
		ServerRemoteSender.SendAnnounce(player, "CantPutAnymore")
		return false
	end
	
	-- Check if position is in the property
	if (not IsInTheProperty(player, position)) then
		print("not in the property")
		ServerRemoteSender.SendAnnounce(player, "OutOfProperty")
		return false
	end
	
	return true
end

return PlacementValidator
