--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local PointingUIElem_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.PointingUIElem_)
local ProgressFlagData = require(ReplicatedFirst.Nexapp.Data.ProgressFlagData)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)

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

local isInHouse = false
--========================
-- private method
--========================


local function OnBuildButtonPressed(self)
	self.IndicatorArrowBuildHandler:SetActive(false)
	local buildGui_ = BuildGui_.GetInstance()
	buildGui_:ToggleShowHide()
end

local function OnItemsButtonPressed(self)
	self.IndicatorArrowItemsHandler:SetActive(false)
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
		isInHouse = true
	end)
	self.zone.playerExited:Connect(function(player)
		isInHouse = false
	end)
	
	self.placedItemsText = gui:FindFirstChild("PlacedItemsLabel", true) :: TextLabel
	self.placedItemsTextOriginal = self.placedItemsText.Text
	
	local indicatorArrowBuild = gui:FindFirstChild("IndicatorArrowBuild", true) :: GuiObject
	self.IndicatorArrowBuildHandler = PointingUIElem_.new(indicatorArrowBuild, UDim2.fromScale(0, 0.04))
	local indicatorArrowItems = gui:FindFirstChild("IndicatorArrowItems", true) :: GuiObject
	self.IndicatorArrowItemsHandler = PointingUIElem_.new(indicatorArrowItems, UDim2.fromScale(0, 0.04))
	
	SystemDataModule_.WaitUntilLoadingScreenEnded()
	self:SetUpdate(true)
end

local function HideAll(self)
	self:SetShowHide(false)
	BuildGui_.GetInstance():SetShowHide(false)
	ItemsGui_.GetInstance():SetShowHide(false)
	EditGui_.GetInstance():SetShowHide(false)
end

local function CanShow(self): boolean
	if not isInHouse then
		return false
	end
	if not PlayerData:IsProgressFlag(ProgressFlagData.Flag_FirstTalkEnd) then
		return false
	end
	return true
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

function MainMenuGui_:OnShow()
	self.IndicatorArrowBuildHandler:SetActive(true)
	self.IndicatorArrowItemsHandler:SetActive(true)
end

function MainMenuGui_:onUpdate(dt: number)
	if CanShow(self) then
		self:SetShowHide(true)
		local num = PlayerData:GetPlacedItemNum()
		self.placedItemsText.Text = TextUtil.ReplaceNumbersText(self.placedItemsTextOriginal, {num, Define.MAX_PLACED_ITEMS_NUM})
	else
		HideAll(self)
	end
end


return MainMenuGui_
