--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)

local BuildGui_ = require(ReplicatedFirst.Nexapp.Client.UI.HouseBuildGui_)
local EditGui_ = require(ReplicatedFirst.Nexapp.Client.UI.EditGui_)
local ItemsGui_ = require(ReplicatedFirst.Nexapp.Client.UI.ItemsGui_)

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
	local frame = gui:WaitForChild("Frame")
	local BuildButton = frame:WaitForChild("BuildButton")
	local ItemsButton = frame:WaitForChild("ItemsButton")
	local EditButton = frame:WaitForChild("EditButton")
	
	self.buildButtonHandler = self:SetupButtonByName("BuildButton", function()
		OnBuildButtonPressed(self)
	end)
	self.itemsButtonHandler = self:SetupButtonByName("ItemsButton", function()
		OnItemsButtonPressed(self)
	end)
	self.editButtonHandler = self:SetupButtonByName("EditButton", function()
		OnEditButtonPressed(self)
	end)
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


return MainMenuGui_
