--!strict
-- ReplicatedStorage/Modules/ShopItemClient_.lua
-- ProximityPrompt(PromptShown/Hidden) をローカルで拾って本人だけハイライト表示

local ShopItemClient_ = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer:: Player
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SHOP_ROOT: Instance = workspace:WaitForChild("Shops")
local PROMPT_NAME = "ShopProximityPrompt"
local HIGHLIGHT_FOLDER_NAME = "_ShopHighlights"

local started = false
local conns: { RBXScriptConnection } = {}
local highlightFolder: Folder? = nil

-- Model -> Highlight（ローカル専用: PlayerGui配下）
local modelToHighlight: { [Model]: Highlight } = {}

local function getOrCreateLocalHighlight(model: Model): Highlight
	local existing = modelToHighlight[model]
	if existing and existing.Parent then
		return existing
	end

	if not highlightFolder or not highlightFolder.Parent then
		local folder = PlayerGui:FindFirstChild(HIGHLIGHT_FOLDER_NAME)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = HIGHLIGHT_FOLDER_NAME
			folder.Parent = PlayerGui
		end
		highlightFolder = folder :: Folder
	end

	local hl = Instance.new("Highlight")
	hl.Name = ("HL_%s"):format(model.Name)
	hl.Adornee = model
	hl.Enabled = false
	hl.Parent = highlightFolder
	-- 見た目は必要に応じて調整
	hl.FillTransparency = 1
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.Occluded

	modelToHighlight[model] = hl

	-- モデルが破棄されたらクリーンアップ
	model.Destroying:Once(function()
		local h = modelToHighlight[model]
		if h then
			h:Destroy()
			modelToHighlight[model] = nil
		end
	end)

	return hl
end

local function connectPrompt(prompt: ProximityPrompt)
	-- サーバ側で付与済みの印（属性 or 名前）でフィルタ
	if prompt:GetAttribute("IsShopPrompt") ~= true and prompt.Name ~= PROMPT_NAME then
		return
	end

	local parentPart = prompt.Parent
	if not (parentPart and parentPart:IsA("BasePart")) then return end

	local model = parentPart:FindFirstAncestorOfClass("Model")
	if not model then return end

	-- 近づいた本人にだけハイライト
	table.insert(conns, prompt.PromptShown:Connect(function()
		local hl = getOrCreateLocalHighlight(model)
		hl.Enabled = true
	end))

	table.insert(conns, prompt.PromptHidden:Connect(function()
		local hl = modelToHighlight[model]
		if hl then hl.Enabled = false end
	end))
end

local function scanAll()
	for _, d in ipairs(SHOP_ROOT:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			connectPrompt(d)
		end
	end
end

local function onDescendantAdded(inst: Instance)
	if inst:IsA("ProximityPrompt") then
		connectPrompt(inst)
	end
end

local function onDescendantRemoving(inst: Instance)
	-- Promptのイベントは削除時に自動解放されるので特に処理不要
end

function ShopItemClient_.Start()
	if started then return end
	started = true

	scanAll()
	table.insert(conns, SHOP_ROOT.DescendantAdded:Connect(onDescendantAdded))
	table.insert(conns, SHOP_ROOT.DescendantRemoving:Connect(onDescendantRemoving))
end

function ShopItemClient_.Stop()
	if not started then return end
	started = false

	for _, c in ipairs(conns) do
		c:Disconnect()
	end
	table.clear(conns)

	-- すべてのローカルハイライトをOFF（必要なら Destroy に変更）
	for _, hl in pairs(modelToHighlight) do
		if hl.Parent then hl.Enabled = false end
	end
end

return ShopItemClient_