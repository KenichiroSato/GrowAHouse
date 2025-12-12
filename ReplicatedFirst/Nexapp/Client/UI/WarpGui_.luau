--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local teleportToHomeEvent = ReplicatedStorage.RemoteEvent.TeleportToHomeEvent
local teleportToShopEvent = ReplicatedStorage.RemoteEvent.TeleportToShopEvent
local PointingUIElem_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.PointingUIElem_)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
local ProgressFlagData = require(ReplicatedFirst.Nexapp.Data.ProgressFlagData)

--- @class ShopGui_ : BaseGui_
local WarpGui_ = {}
WarpGui_.__index = WarpGui_
setmetatable(WarpGui_, BaseGui_)
WarpGui_.instance = nil

local coinText: TextLabel
local isFurnitureButtonPlaced = false
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function WarpGui_.GetInstance()
	return WarpGui_.instance
end

--========================
-- private method
--========================

local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	local frame = gui:WaitForChild("Frame")
	
	self.homeButtonHandler = self:SetupButtonByName("HomeButton", function()
		print("Home pressed")
		teleportToHomeEvent:FireServer()
	end)
	self.furnitureButtonHandler = self:SetupButtonByName("FurnitureButton", function()
		isFurnitureButtonPlaced = true
		teleportToShopEvent:FireServer("Furniture")
	end)
	self.toyButtonHandler = self:SetupButtonByName("ToyButton", function()
		teleportToShopEvent:FireServer("Toy")
	end)
	self.plantButtonHandler = self:SetupButtonByName("PlantButton", function()
		teleportToShopEvent:FireServer("Plant")
	end)
	self.brainrotButtonHandler = self:SetupButtonByName("BrainrotButton", function()
		teleportToShopEvent:FireServer("Brainrot")
	end)
	
	local indicatorArrowFurniture = gui:FindFirstChild("FurnitureArrow", true) :: GuiObject
	self.indicatorArrowFurnitureHandler = PointingUIElem_.new(indicatorArrowFurniture, UDim2.fromScale(0, 0.4))
	local indicatorArrowHome = gui:FindFirstChild("HomeArrow", true) :: GuiObject
	self.indicatorArrowHomeHandler = PointingUIElem_.new(indicatorArrowHome, UDim2.fromScale(0, 0.4))
	
	SystemDataModule_.WaitUntilLoadingScreenEnded()
	self:SetUpdate(true)
end

local function ShouldShowFurnitureArrow(self): boolean
	if isFurnitureButtonPlaced then
		return false
	end
	if PlayerData:IsProgressFlag(ProgressFlagData.Flag_FirstBuildComplete) and 
		not PlayerData:IsProgressFlag(ProgressFlagData.Flag_FirstPurchaseComplete)
	then
		return true
	end
	return false
end
--========================
-- public method
--========================

function WarpGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), WarpGui_)
	Init(self, ...)
	WarpGui_.instance = self
	return self
end

function WarpGui_:onUpdate(dt: number)
	self.indicatorArrowFurnitureHandler:SetActive(ShouldShowFurnitureArrow(self))
	self.indicatorArrowHomeHandler:SetActive(false)
end

return WarpGui_
