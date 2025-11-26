--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local teleportToHomeEvent = ReplicatedStorage.RemoteEvent.TeleportToHomeEvent
local teleportToShopEvent = ReplicatedStorage.RemoteEvent.TeleportToShopEvent

--- @class ShopGui_ : BaseGui_
local WarpGui_ = {}
WarpGui_.__index = WarpGui_
setmetatable(WarpGui_, BaseGui_)
WarpGui_.instance = nil

local coinText: TextLabel

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
	print("coinGui init")
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	local frame = gui:WaitForChild("Frame")
	
	self.homeButtonHandler = self:SetupButtonByName("HomeButton", function()
		print("Home pressed")
		teleportToHomeEvent:FireServer()
	end)
	self.furnitureButtonHandler = self:SetupButtonByName("FurnitureButton", function()
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
	coinText.Text = "$" .. PlayerData:GetCoin()
end

return WarpGui_
