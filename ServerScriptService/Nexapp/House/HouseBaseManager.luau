--!strict
-- ServerScriptService/HouseBaseManager.lua

local Rep = game:GetService("ReplicatedStorage")
local teleportToHomeEvent = Rep.RemoteEvent.TeleportToHomeEvent
local getHouseBaseFunction = Rep.RemoteEvent.GetHouseBaseFunction
local Players = game:GetService("Players")

local HouseBaseManager = {}
HouseBaseManager.__index = HouseBaseManager

-- 土台置き場（あらかじめWorkspaceに置いておく）
local BASE_FOLDER = workspace:WaitForChild("HouseBases")

-- 内部状態
local availableBases: {Model} = {}
local assignedBases: {[Player]: Model} = {}

-- 初期化
local function init()
	-- HouseBases配下のBasePartを全て収集
	for _, obj in ipairs(BASE_FOLDER:GetChildren()) do
		if obj:IsA("Model") then
			table.insert(availableBases, obj)
		end
	end
end
init()

local function TeleportToHouse(player: Player)
	local baseModel = assignedBases[player]
	local spawnPosition = baseModel:FindFirstChild("SpawnPosition"):: BasePart
	local character = player.Character
	if not character then return end
	
	character:PivotTo(spawnPosition.CFrame)
end

--- プレイヤーに土台を割り当てる
-- @return BasePart 割り当てられた土台のBasePart
function HouseBaseManager.Assign(player: Player): Model?
	-- 既に割り当て済みならそれを返す
	if assignedBases[player] then
		return assignedBases[player]
	end
	-- 空きがあるか？
	local baseModel = table.remove(availableBases, 1)
	if not baseModel then
		warn(("No available house base for %s"):format(player.Name))
		return nil
	end
	assignedBases[player] = baseModel
	
	TeleportToHouse(player)
	player.CharacterAdded:Connect(function(character)
		TeleportToHouse(player)
	end)
	return baseModel
end

--- プレイヤーから土台割り当てを解除
function HouseBaseManager.Release(player: Player)
	local baseModel = assignedBases[player]
	if baseModel then
		assignedBases[player] = nil
		table.insert(availableBases, baseModel)
	end
end

--- プレイヤーに割り当てられているBasePartを取得
function HouseBaseManager.GetBase(player: Player): BasePart
	return assignedBases[player].PrimaryPart :: BasePart
end

local function GetHouseAreaVolume(player: Player): BasePart
	local part = assignedBases[player]:WaitForChild("HouseAreaVolume") :: BasePart
	return part
end

-- プレイヤー退室時に自動解放
Players.PlayerRemoving:Connect(function(player)
	HouseBaseManager.Release(player)
end)

teleportToHomeEvent.OnServerEvent:Connect(TeleportToHouse)

getHouseBaseFunction.OnServerInvoke = GetHouseAreaVolume

return HouseBaseManager