--!strict
-- ServerScriptService/ShopItemServer.lua

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local SystemDefine = require(ReplicatedFirst.Nexsys.Common.SystemDefine)

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local priceTemplateBillboard = ServerStorage.PriceTemplateBillboardGui
local PlayerManager: Types.PlayerManager = require(ServerScriptService.Nexapp.Player.PlayerManager)
local PriceProvider = require(ReplicatedStorage.Script.PriceProvider)
local ServerRemoteSender = require(ServerScriptService.Nexsys.ServerRemoteSender)
local TextUtil = require(ReplicatedFirst.Nexsys.Common.Utility.TextUtil)

local ShopItemServer = {}
local SHOP_ROOT: Instance = workspace:WaitForChild("Shops")
local PROMPT_NAME = "ShopProximityPrompt"
local MODEL_ATTR = "ShopPromptAdded"
local BILLBOARD_NAME = "_ShopNameBillboard"

local DEFAULT_PROMPT = {
	ActionText = "Buy",
	ObjectText = "",
	MaxActivationDistance = 12,
	RequiresLineOfSight = false,
	Enabled = true,
	HoldDuration = 0.5,
	Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton,
	GamepadKeyCode = Enum.KeyCode.ButtonX,
	KeyboardKeyCode = Enum.KeyCode.E,
}

local started = false
local conns: {RBXScriptConnection} = {}

-- ===== Util =====
local function getTargetPartForPrompt(model: Model): BasePart?
	local bboxCF, bboxSize = model:GetBoundingBox()

	-- 透明パートのサイズ：X/Z はモデルと同じ（余白つき）、Y は thickness
	local partSize = Vector3.new(bboxSize.X, 0.2, bboxSize.Z	)

	local p = Instance.new("Part")
	p.Name = "TopExtentMarker"
	p.Size = partSize
	p.Transparency = 1 -- 完全透明
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CFrame = bboxCF --BBox中心
	p.Parent = model
	return p
end

local function findExistingPrompt(model: Model): ProximityPrompt?
	for _, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("ProximityPrompt") and inst.Name == PROMPT_NAME then
			return inst
		end
	end
	return nil
end

local function GetPrice(model: Model): number
	return PriceProvider.GetPrice(model)
end

local function GetMoneyRate(model: Model): number
	return PriceProvider.GetMoneyRate(model)
end

local function ensureBillboard(model: Model, adornee: BasePart?)
	if model:FindFirstChild(BILLBOARD_NAME) then return end
	if not adornee then return end

	local billboard = priceTemplateBillboard:Clone()--Instance.new("BillboardGui")
	billboard.Name = BILLBOARD_NAME
	billboard.Adornee = adornee
	--billboard.Size = UDim2.new(6, 0, 2, 0)
	local MAX_OFFSET = 4
	local offSetY = model:GetExtentsSize().Y/2 + 2
	if offSetY > MAX_OFFSET then
		offSetY = MAX_OFFSET
	end
	billboard.StudsOffset = Vector3.new(0, offSetY, 0) -- パーツの上にオフセット
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 30
	billboard.Parent = model
	
	local nameLabel = billboard:FindFirstChild("NameLabel", true)
	nameLabel.Text = model.Name
	local priceLabel = billboard:FindFirstChild("PriceLabel", true)
	priceLabel.Text = "$" .. TextUtil.FormatNumberWithUnit(GetPrice(model))--tostring(GetPrice(model))
	local rateLabel = billboard:FindFirstChild("RateLabel", true)
	rateLabel.Text = "$"..tostring(GetMoneyRate(model)).. "/s"

	
end

local function TryPurchase(gamePlayer: Types.GamePlayer, price: number): boolean
	local coins = gamePlayer:GetCoin() or 0
	if coins >= price then
		gamePlayer:SubCoin(price)
		return true
	end
	return false
end

-- ===== Core =====
function ShopItemServer._ensurePrompt(model: Model)
	if not model:IsA("Model") then return end
	if model:GetAttribute(MODEL_ATTR) then return end

	local targetPart = getTargetPartForPrompt(model)
	if not targetPart then
		warn("[ShopItemServer] BasePartなし: " .. model:GetFullName())
		return
	end

	-- ProximityPrompt
	local prompt = findExistingPrompt(model) :: ProximityPrompt
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = PROMPT_NAME
		for k, v in pairs(DEFAULT_PROMPT) do (prompt :: any)[k] = v end
		prompt.Parent = targetPart
	end
	prompt:SetAttribute("IsShopPrompt", true)
	
	prompt.Triggered:Connect(function(player:Player)
		local gamePlayer: Types.GamePlayer = PlayerManager.GetGamePlayer(player)
		if gamePlayer then
			local purchased = TryPurchase(gamePlayer, GetPrice(model))
			if purchased then
				gamePlayer:AddPurchasedItem(model.Name)
				ServerRemoteSender.SendEvent(player, SystemDefine.CommonClientEvent.PlaySEByName, "Purchase")
				print(player.Name .. "が" .. model.Name .. "を購入")
			else
				ServerRemoteSender.SendAnnounce(player, "NotEnoughMoney")
				print(player.Name .. "がお金が足りません")
			end
		end
	end)

	-- BillboardGui
	ensureBillboard(model, targetPart)
	
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	model:SetAttribute(MODEL_ATTR, true)
end

function ShopItemServer._processItemsFolder(folder: Folder)
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Model") then
			ShopItemServer._ensurePrompt(child)
		end
	end
end

function ShopItemServer._scanAll()
	for _, d in ipairs(SHOP_ROOT:GetDescendants()) do
		if d:IsA("Folder") and d.Name == "Items" then
			ShopItemServer._processItemsFolder(d)
		end
	end
end

function ShopItemServer._onDescendantAdded(inst: Instance)
	if inst:IsA("Folder") and inst.Name == "Items" then
		ShopItemServer._processItemsFolder(inst)
	elseif inst:IsA("Model") and inst.Parent and inst.Parent:IsA("Folder") and inst.Parent.Name == "Items" then
		ShopItemServer._ensurePrompt(inst)
	end
end

function ShopItemServer.Start()
	if started then return end
	started = true
	ShopItemServer._scanAll()
	table.insert(conns, SHOP_ROOT.DescendantAdded:Connect(ShopItemServer._onDescendantAdded))
end

function ShopItemServer.Stop()
	if not started then return end
	started = false
	for _, c in ipairs(conns) do c:Disconnect() end
	table.clear(conns)
end

return ShopItemServer