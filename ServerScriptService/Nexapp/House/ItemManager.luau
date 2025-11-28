--!strict


local ItemManager = {}

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local STR = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("Strings"))
local remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvent")
local ItemPlaceEvent = remoteEventFolder:WaitForChild("ItemPlaceEvent") :: RemoteEvent
local SaveDataLoadedEvent = ReplicatedStorage:WaitForChild("BindableEvent"):WaitForChild("SaveDataLoadedEvent")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

local ServerScriptService = game:GetService("ServerScriptService")
local LocalCordinateHelper = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("House"):WaitForChild("LocalCordinateHelper"))
local PlayerManager = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("Player"):WaitForChild("PlayerManager"))
local HouseBaseManager = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("House"):WaitForChild("HouseBaseManager"))
local commonMessageEvent = remoteEventFolder:WaitForChild("CommonMessageEvent")

--========================
-- private method
--========================
-- 置く前にモデルの物理・見た目を通常化
local function normalizePlacedModel(model: Model)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true               -- 基本は固定推奨
			--d.CanCollide = true
			d.CanQuery = true
			-- クライアント側 LocalTransparencyModifier の影響は受けないが、
			-- 念のため Transparency を戻す処理が必要なら独自に（ここでは何もしない）
		end
	end
end

local function SpawnItem(player: Player, modelName: string, pivotCFrame: CFrame): Instance?
	-- バリデーション
	if typeof(modelName) ~= "string" or typeof(pivotCFrame) ~= "CFrame" then
		return nil
	end

	local itemsFolder = ReplicatedStorage:FindFirstChild("Shops")
	if not itemsFolder then
		warn("workspace/Items フォルダが見つかりません")
		return nil
	end

	local template = itemsFolder:FindFirstChild(modelName, true)
	if not template or not template:IsA("Model") then
		warn(("Items から Model '%s' が見つかりません"):format(modelName))
		return nil
	end

	-- 配置
	local placed = template:Clone()
	placed.Parent = Workspace
	placed:PivotTo(pivotCFrame)
	normalizePlacedModel(placed)

	placed:SetAttribute(STR.OwnerUserId, player.UserId)
	CollectionService:AddTag(placed, STR.TAG_Deletable)
	CollectionService:AddTag(placed, STR.TAG_Furniture)
	return placed
end

local function IsInTheProperty(player: Player, position: Vector3): boolean
	local basePart = HouseBaseManager.GetBase(player)
	local basePosition = basePart.Position
	local baseSize = basePart.Size
	return basePosition.X - baseSize.X/2 <= position.X and 
		basePosition.X + baseSize.X/2 >= position.X and
		basePosition.Z - baseSize.Z/2 <= position.Z and
		basePosition.Z + baseSize.Z/2 >= position.Z
end


local function ReloadFurnitures(player: Player)
	local gamePlayer = PlayerManager.GetGamePlayer(player)
	if gamePlayer then
		local furnitureParts = gamePlayer:GetFurnitures()
		local BuildItems: {Types.BuildItem} = LocalCordinateHelper.ChangeToWorldCordinates(player, furnitureParts)
		for _, buildItem: Types.BuildItem in pairs(BuildItems) do
			local rotation = CFrame.Angles(0, buildItem.YawRadian, 0)
			local cf = CFrame.new(buildItem.Position) * rotation
			local item = SpawnItem(player, buildItem.Name, cf)
			if item then
				item:SetAttribute(STR.InstanceId, buildItem.Id)
			end
		end
	end
end

--========================
-- public method
--========================
function ItemManager.bindEvents()
	
	--セーブデータロード時の家復元
	SaveDataLoadedEvent.Event:Connect(function(player: Player)
		ReloadFurnitures(player)
	end)
	
	ItemPlaceEvent.OnServerEvent:Connect(function(player: Player, modelName: string, pivotCFrame: CFrame)
		local position = pivotCFrame.Position
		if (not IsInTheProperty(player, position)) then
			print("not in the property")
			commonMessageEvent:FireClient(player, STR.STR_OUT_OF_PROPERTY)
			return
		end
		local placedItem = SpawnItem(player, modelName, pivotCFrame)
		if placedItem then
			local instanceId = HttpService:GenerateGUID(false)
			placedItem:SetAttribute(STR.InstanceId, instanceId)
			local relCords = LocalCordinateHelper.GetRelativeCordinates(player, placedItem)
			local housePart: Types.HousePart = {
				Id = instanceId,
				ModelName = modelName,
				Rel = relCords
			}
			local gamePlayer = PlayerManager.GetGamePlayer(player)
			if housePart and gamePlayer then
				gamePlayer:AddFurniture(housePart)
				gamePlayer:RemovePurchasedItem(modelName)
			end
		end
	end)
end

return ItemManager
