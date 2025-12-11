--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local ServerScriptService = game:GetService("ServerScriptService")
local HouseBaseManager = require(ServerScriptService.Nexapp.House.HouseBaseManager)
local ServerRemoteSender = require(ServerScriptService.Nexsys.ServerRemoteSender)

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local SysTypes = require(ReplicatedFirst.Nexsys.Common.Types)
local ColorMaterialSetter: SysTypes.ColorMaterialSetter = require(ReplicatedFirst.Nexsys.Common.ColorMaterialSetter)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InstanceMover = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("InstanceMover"))
local remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvent")
local STR = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("Strings"))
local placeEvent = remoteEventFolder:WaitForChild("HousePlaceEvent")
local MaterialConverter = require(ReplicatedStorage.Script.MaterialConverter)

local PlayerManager: Types.PlayerManager = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("Player"):WaitForChild("PlayerManager"))
local LocalCordinateHelper = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("House"):WaitForChild("LocalCordinateHelper"))
local PlacementValidator = require(ServerScriptService.Nexapp.House.PlacementValidator)
local SaveDataLoadedEvent = ReplicatedStorage:WaitForChild("BindableEvent"):WaitForChild("SaveDataLoadedEvent")

local HouseBuilder = {}
HouseBuilder.__index = HouseBuilder

--========================
-- 内部関数
--========================
local function setParams(player: Player, buildItem: Instance)
	local function applyToPart(part: BasePart)
		part.Anchored = true
		part.CanCollide = true
	end
	if buildItem:IsA("BasePart") then
		applyToPart(buildItem)
	elseif buildItem:IsA("Model") then
		for _, part in ipairs(buildItem:GetDescendants()) do
			if part:IsA("BasePart") then
				applyToPart(part)
			end
		end
	end
	buildItem.Parent = workspace
	buildItem:SetAttribute(STR.OwnerUserId, player.UserId)
	CollectionService:AddTag(buildItem, STR.TAG_Deletable)
	CollectionService:AddTag(buildItem, STR.TAG_Building)

	local instanceId = HttpService:GenerateGUID(false)
	buildItem:SetAttribute(STR.InstanceId, instanceId)
end

local function SetColorAndMaterial(buildItem: Instance, color: Color3, material: Enum.Material)
	local mat = material or Enum.Material.Plastic
	ColorMaterialSetter.Set(buildItem, color, mat, STR.TAG_IgnoreColor)
end

local function Create(player: Player, partName: string, position: Vector3, yawRadian: number, color: Color3, material: Enum.Material): Instance
	--print("create: ".. player.Name, partName, position, yawRadian)
	local buildItem = Define.BuildingPartFolder:WaitForChild(partName):Clone()
	setParams(player, buildItem)
	SetColorAndMaterial(buildItem, color, material)
	InstanceMover.movePart(buildItem, position, yawRadian)
	return buildItem
end



local function RebuildHouse(player: Player)
	local gamePlayer: Types.GamePlayer = PlayerManager.GetGamePlayer(player)
	if gamePlayer then
		local buildingParts: Types.BuildingPartArray = gamePlayer:GetBuildingParts()
		local colors: {Color3} = {}
		local materials: {string} = {}
		local houseParts: Types.HousePartArray = {}
		for _, part in ipairs(buildingParts) do
			table.insert(houseParts, part.HousePart)
			table.insert(materials, part.Material)
			table.insert(colors, Color3.fromRGB(part.ColorR, part.ColorG, part.ColorB))
		end
		local BuildItems: {Types.BuildItem} = LocalCordinateHelper.ChangeToWorldCordinates(player, houseParts)
		for i, buildItem: Types.BuildItem in pairs(BuildItems) do
			local color = colors[i]
			local material = MaterialConverter.FromStringToEnum(materials[i])
			local item = Create(player, buildItem.Name, buildItem.Position, buildItem.YawRadian, color, material)
			item:SetAttribute(STR.InstanceId, buildItem.Id)
		end
	end
end

--========================
-- public method
--========================

function HouseBuilder.bindEvents()
	
	--セーブデータロード時の家復元
	SaveDataLoadedEvent.Event:Connect(function(player: Player)
		RebuildHouse(player)
	end)
	
	-- 配置イベント
	placeEvent.OnServerEvent:Connect(function(player: Player, partName: string, position: Vector3, yawRadian: number, color: Color3, material: Enum.Material)
		if typeof(position) == "Vector3" and typeof(yawRadian) == "number" then
			
			if not PlacementValidator.Validate(player, position) then
				return
			end
			
			local buildItem = Create(player, partName, position, yawRadian, color, material)
			local instanceId = HttpService:GenerateGUID(false)
			buildItem:SetAttribute(STR.InstanceId, instanceId)
			
			local relCords = LocalCordinateHelper.GetRelativeCordinates(player, buildItem)
			local housePart: Types.HousePart = {
				Id = instanceId,
				ModelName = partName,
				Rel = relCords
			}
			local buildingPart: Types.BuildingPart = {
				HousePart = housePart,
				ColorR = math.floor(color.R*255),
				ColorG = math.floor(color.G*255),
				ColorB = math.floor(color.B*255),
				Material = MaterialConverter.FromEnumToString(material),
			}
			local gamePlayer = PlayerManager.GetGamePlayer(player)
			if housePart and gamePlayer then
				gamePlayer:AddBuildingPart(buildingPart)
			end
		end
	end)
end


return HouseBuilder

