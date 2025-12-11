--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)

local BuildGui_ = require(ReplicatedFirst.Nexapp.Client.UI.HouseBuildGui_)
local EditGui_ = require(ReplicatedFirst.Nexapp.Client.UI.EditGui_)
local ItemsGui_ = require(ReplicatedFirst.Nexapp.Client.UI.ItemsGui_)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getHouseBaseFunction = ReplicatedStorage.RemoteEvent.GetHouseBaseFunction
local zoneplus = require(ReplicatedStorage.Packages.zoneplus)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local TextUtil = require(ReplicatedFirst.Nexsys.Common.Utility.TextUtil)

--- @class ShopGui_ : BaseGui_
local MainMenuGui_ = {}
MainMenuGui_.__index = MainMenuGui_
setmetatable(MainMenuGui_, BaseGui_)
MainMenuGui_.instance = nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function MainMenuGui_.GetInstance()
	return MainMenuGui_.instance
end
----------------------------------------------------------------------------------------------------

--========================
-- private method
--========================


local function OnBuildButtonPressed(self)
	print("OnBuildBUttonPressed")
	local buildGui_ = BuildGui_.GetInstance()
	buildGui_:ToggleShowHide()
end

local function OnItemsButtonPressed(self)
	print("OnItemsButtonPressed")
	local ItemsGui_ = ItemsGui_.GetInstance()
	ItemsGui_:ToggleShowHide()
end

local function OnEditButtonPressed(self)
	print("OnEditButtonPressed")
	local editGui_ = EditGui_.GetInstance()
	editGui_:ToggleShowHide()
end


local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	local BuildButton = gui:FindFirstChild("BuildButton", true)
	local ItemsButton = gui:FindFirstChild("ItemsButton", true)
	local EditButton = gui:FindFirstChild("EditButton", true)
	
	self.buildButtonHandler = self:SetupButtonByName("BuildButton", function()
		OnBuildButtonPressed(self)
	end)
	self.itemsButtonHandler = self:SetupButtonByName("ItemsButton", function()
		OnItemsButtonPressed(self)
	end)
	self.editButtonHandler = self:SetupButtonByName("EditButton", function()
		OnEditButtonPressed(self)
	end)
	
	local houseBase = getHouseBaseFunction:InvokeServer(game.Players.LocalPlayer)
	self.zone = zoneplus.new(houseBase)
	self.zone.localPlayerEntered:Connect(function(player)
		self:SetEnabled(true)
	end)
	self.zone.playerExited:Connect(function(player)
		self:SetEnabled(false)
	end)
	
	self.placedItemsText = gui:FindFirstChild("PlacedItemsLabel", true) :: TextLabel
	self.placedItemsTextOriginal = self.placedItemsText.Text
	
	self:SetUpdate(true)
end

--========================
-- public method
--========================
function MainMenuGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), MainMenuGui_)
	Init(self, ...)
	MainMenuGui_.instance = self
	return self
end

function MainMenuGui_:onUpdate(dt: number)
	local num = PlayerData:GetPlacedItemNum()
	self.placedItemsText.Text = TextUtil.ReplaceNumbersText(self.placedItemsTextOriginal, {num, Define.MAX_PLACED_ITEMS_NUM})
end


return MainMenuGui_
