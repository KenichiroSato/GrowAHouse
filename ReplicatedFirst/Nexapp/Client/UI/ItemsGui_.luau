--!strict

local ItemsGui_ = {}

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)

local ViewportFrameCreator = require(ReplicatedFirst.Nexsys.Client.ViewportFrameCreator_)
local ItemPlacer = require(game.StarterPlayer.StarterPlayerScripts.Scripts:WaitForChild("ItemPlacer_"))

--- @class ShopGui_ : BaseGui_
local ItemsGui_ = {}
ItemsGui_.__index = ItemsGui_
setmetatable(ItemsGui_, BaseGui_)
ItemsGui_.instance = nil
--[[
local items = {
	"Vending_Machine",
	"Locker",
	"Chair1",
	"Table1",
	"Sofa1",
	"Chair_red",
	"CounterEnd",
	"Ads_Board",
	"Plant_Pot",
	"Long Potted Plants", 
	"Grand Piano",
	"Trampoline",
	"Toilet",
	"Washing Machine",
	
}
]]
local items = {}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function ItemsGui_.GetInstance()
	return ItemsGui_.instance
end

--========================
-- private method
--========================

local function collectModelsRecursive(folder, result)
	result = result or {}

	for _, child in ipairs(folder:GetChildren()) do
		-- 子がModelなら追加
		if child:IsA("Model") or child:IsA("BasePart") then
			table.insert(result, child)
		end
		-- 子がさらにフォルダやモデルを持つ可能性があるので再帰呼び出し
		if child:IsA("Folder") then
			collectModelsRecursive(child, result)
		end
	end

	return result
end

local function InitItems()
	items = {}
	local itemsFolder = workspace:FindFirstChild("Items") 
	if itemsFolder then
		local models = collectModelsRecursive(itemsFolder)
		for _, model in models do
			if model:IsA("Model")  or child:IsA("BasePart") then
				table.insert(items, model.Name)
			end
		end
	end
end

local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()

	self:SetShowHide(false)
	self:SetExcludeShow(true)
	
	self.frame = gui:WaitForChild("Frame")
	self.scrollingFrame = self.frame:WaitForChild("ScrollingFrame")
	self.template = self.scrollingFrame:WaitForChild("Template")
	self.viewportFrameCreator = ViewportFrameCreator.new()
	
	self.cancelButtonHandler = self:SetupButtonByName("CloseButton", function()
		self:SetShowHide(false)
	end)
	InitItems()
end

local function ShowList(self)
	items = PlayerData:GetPurchasedItems() :: {[string]: number}
	for key:string, value:number in pairs(items) do
		local row = self.template:Clone()
		row.Name = "Item_" .. key
		row.Visible = true
		row.Parent = self.scrollingFrame
		row.CountLabel.Text = value > 1 and "×"..tostring(value).." " or ""
		self.viewportFrameCreator:createViewport(row.ViewportFrame, key)
		self.viewportFrameCreator:setSpin(row.ViewportFrame, 30)

		-- クリックイベント
		row.MouseButton1Click:Connect(function()
			print("Clicked:", key)
			self:SetShowHide(false)
			ItemPlacer.Start(key)
		end)
	end
end

local function HideList(self)
	self.viewportFrameCreator:destroy()
	for _, child in ipairs(self.scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") and child ~= self.template then
			child:Destroy()
		end
	end
end

--========================
-- public method
--========================

function ItemsGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), ItemsGui_)
	Init(self, ...)
	ItemsGui_.instance = self
	return self
end

function ItemsGui_:OnShow()
	ShowList(self)
end

function ItemsGui_:OnHide()
	HideList(self)
end

return ItemsGui_
