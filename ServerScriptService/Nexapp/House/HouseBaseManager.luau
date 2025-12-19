--!strict
-- ServerScriptService/HouseBaseManager.lua

local Rep = game:GetService("ReplicatedStorage")
local teleportToHomeEvent = Rep.RemoteEvent.TeleportHomeFunction
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

local function TeleportToHouse(player: Player): boolean
	local baseModel = assignedBases[player]
	local spawnPosition = baseModel:FindFirstChild("SpawnPosition"):: BasePart
	local character = player.Character
	if not character then return false end
	
	character:PivotTo(spawnPosition.CFrame)
	return true
end

local function setPlayerInfoOnBase(baseModel: Model, player: Player)
	local imageLabel = baseModel:FindFirstChild("playerImage", true)
	local nameLabel = baseModel:FindFirstChild("playerName", true)

	if imageLabel and imageLabel:IsA("ImageLabel") then
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and thumb then
			imageLabel.Image = thumb
		else
			warn(("Failed to get thumbnail for %s"):format(player.Name))
		end
	end

	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = player.Name
	end
end

local function clearPlayerInfoOnBase(baseModel: Model)
	local imageLabel = baseModel:FindFirstChild("playerImage", true)
	local nameLabel = baseModel:FindFirstChild("playerName", true)

	if imageLabel and imageLabel:IsA("ImageLabel") then
		imageLabel.Image = ""
	end
	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = ""
	end
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

	-- Base にプレイヤー情報を設定
	setPlayerInfoOnBase(baseModel, player)


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
		-- Base のプレイヤー情報をクリア
		clearPlayerInfoOnBase(baseModel)

		-- PrimaryPart の子要素をすべて削除（存在する場合）
		local primary = baseModel.PrimaryPart
		if primary then
			for _, child in ipairs(primary:GetChildren()) do
				pcall(function()
					child:Destroy()
				end)
			end
		end

		assignedBases[player] = nil
		table.insert(availableBases, baseModel)
	end
end

--- プレイヤーに割り当てられているBasePartを取得
function HouseBaseManager.GetBase(player: Player): BasePart
	return assignedBases[player].PrimaryPart :: BasePart
end

local function GetHouseAreaVolume(player: Player, name:string): BasePart
	local part = assignedBases[player]:WaitForChild(name) :: BasePart
	return part
end

-- プレイヤー退室時に自動解放
Players.PlayerRemoving:Connect(function(player)
	HouseBaseManager.Release(player)
end)

teleportToHomeEvent.OnServerInvoke = TeleportToHouse

getHouseBaseFunction.OnServerInvoke = GetHouseAreaVolume

return HouseBaseManager