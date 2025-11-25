--!strict

local HouseBuildGui_ = {}

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local houseBuilder_ = require(game.StarterPlayer.StarterPlayerScripts.Scripts:WaitForChild("HouseBuilder_"))
local ColorSelectMenu = require(ReplicatedFirst.Nexapp.Client.UI.ColorSelectMenu_)
local MaterialSelectMenu = require(ReplicatedFirst.Nexapp.Client.UI.MaterialSelectMenu_)
local BuildingPartPickerGui_ = require(ReplicatedFirst.Nexapp.Client.UI.BuildingPartPickerGui_)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local ViewportFrameCreator = require(ReplicatedFirst.Nexsys.Client.ViewportFrameCreator_)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ColorMaterialChangeEvent = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("ColorMaterialChangeEvent")
--local MaterialConverter = ReplicatedStorage:WaitForChild("Script"):WaitForChild("MaterialConverter")
local MaterialConverter = require(ReplicatedStorage.Script.MaterialConverter)
local STR = require(ReplicatedStorage.Script.Strings)

--- @class ShopGui_ : BaseGui_
local HouseBuildGui_ = {}
HouseBuildGui_.__index = HouseBuildGui_
setmetatable(HouseBuildGui_, BaseGui_)
HouseBuildGui_.instance = nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function HouseBuildGui_.GetInstance()
	return HouseBuildGui_.instance
end
----------------------------------------------------------------------------------------------------

--========================
-- private method
--========================
local function OnBuildButtonPressed()
	print("OnBuildBUttonPressed")
end

local function LastPartName(): string
	return BuildingPartPickerGui_.GetInstance():LastPartName()
end

local function LastColor(partName: string): Color3
	local last = PlayerData:GetLastPartColor(partName)
	if last then
		return last
	else
		local colorSelectMenu = ColorSelectMenu.GetInstance()
		return 	colorSelectMenu:LastColor()
	end
end

local function LastMaterial(partName: string): Enum.Material
	local lastMatString = PlayerData:GetLastPartMaterial(partName)
	if lastMatString then
		return MaterialConverter.FromStringToEnum(lastMatString)
	else
		local materialSelectMenu = MaterialSelectMenu.GetInstance()
		return 	materialSelectMenu:LastMaterial()
	end
end

--[[
local function LastColorMaterial(self, partName: string): (Color3, Enum.Material)
	if (self.LastColorMaterial[partName]) then
		last = self.LastColorMaterial[partName]
		return last.color, last.material
	else
		local colorSelectMenu = ColorSelectMenu.GetInstance()
		return 	colorSelectMenu:LastColor(), colorSelectMenu:LastMaterial()
	end
end
]]

local function SetColor(self, newcolor: Color3)
	houseBuilder_.SetColor(newcolor)
	self.viewportFrameCreator:SetColor(self.partViewportFrame, newcolor, STR.TAG_IgnoreColor)
	ColorMaterialChangeEvent:FireServer(LastPartName(), newcolor)
end

local function SetMaterial(self,  newMaterial: Enum.Material)
	houseBuilder_.SetMaterial(newMaterial)
	self.viewportFrameCreator:SetMaterial(self.partViewportFrame, newMaterial, STR.TAG_IgnoreColor)
	ColorMaterialChangeEvent:FireServer(LastPartName(), newMaterial)
end

local function SetBuildPart(self, name: string)
	self.viewportFrameCreator:createViewport(self.partViewportFrame, name, Define.BuildingPartFolder, nil, 60, Vector3.new(14, 6, 14))
	self.viewportFrameCreator:setSpin(self.partViewportFrame, 30)	
	houseBuilder_.setBuildingPart(name)
	
	local lastColor = LastColor(name)
	local lastMaterial = LastMaterial(name)
	SetColor(self, lastColor)
	SetMaterial(self, lastMaterial)
end


local function ShowColorSelectMenu(self)
	MaterialSelectMenu.GetInstance():Cancel()
	BuildingPartPickerGui_.GetInstance():Cancel()
	local color: Color3? = ColorSelectMenu.GetInstance():ShowAsync()
	if color then
		SetColor(self, color)
	end
end

local function ShowMaterialSelectMenu(self)
	print("ShowMaterialSelectMenu")
	ColorSelectMenu.GetInstance():Cancel()
	BuildingPartPickerGui_.GetInstance():Cancel()
	local material: Enum.Material = MaterialSelectMenu.GetInstance():ShowAsync()
	if material then
		SetMaterial(self, material)
	end
end

local function ShowBuildingPartPicker(self)
	ColorSelectMenu.GetInstance():Cancel()
	MaterialSelectMenu.GetInstance():Cancel()
	local partName: string? = BuildingPartPickerGui_.GetInstance():ShowAsync()
	if partName then
		SetBuildPart(self, partName)
	end
end

local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	
	self:SetShowHide(false)
	self:SetExcludeShow(true)
		
	local frame = gui:WaitForChild("Frame")
	self.partViewportFrame = frame:WaitForChild("PartFrame"):WaitForChild("PartViewportFrame") :: ViewportFrame
	self.viewportFrameCreator = ViewportFrameCreator.new()
	
	self.partChangeButtonHandler = self:SetupButtonByName("PartChangeButton", function()
		ShowBuildingPartPicker(self)
	end)

	self.colorChangeButtonHandler = self:SetupButtonByName("ColorChangeButton", function()
		ShowColorSelectMenu(self)
	end)
	
	self.materialChangeButtonHandler = self:SetupButtonByName("MaterialChangeButton", function()
		ShowMaterialSelectMenu(self)
	end)
	
	self.LastColorMaterial = {}
end


--========================
-- public method
--========================

function HouseBuildGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), HouseBuildGui_)
	Init(self, ...)
	HouseBuildGui_.instance = self
	return self
end

function HouseBuildGui_:OnShow()
	SetBuildPart(self, LastPartName())
	houseBuilder_.Start()
end

function HouseBuildGui_:OnHide()
	BuildingPartPickerGui_.GetInstance():Cancel()
	ColorSelectMenu.GetInstance():Cancel()
	MaterialSelectMenu.GetInstance():Cancel()
	houseBuilder_.Stop()
end

return HouseBuildGui_