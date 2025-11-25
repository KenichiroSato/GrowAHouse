--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local ViewportFrameCreator = require(ReplicatedFirst.Nexsys.Client.ViewportFrameCreator_)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--- @class ShopGui_ : BaseGui_
local ColorSelectMenu_ = {}
ColorSelectMenu_.__index = ColorSelectMenu_
setmetatable(ColorSelectMenu_, BaseGui_)
ColorSelectMenu_.instance = nil

local Colors = {
	BrickColor.new("White"),
	BrickColor.new("Pastel light blue"),
	BrickColor.new("Pastel orange"),
	BrickColor.new("Pastel violet"),
	BrickColor.new("Pastel green"),
	BrickColor.new("Pastel yellow"),
	BrickColor.new("Pastel brown"),
	BrickColor.new("Bright yellow"),
	BrickColor.new("Bright orange"),
	--BrickColor.new("Deep orange"),
	BrickColor.new("Really red"),
	--BrickColor.new("Dark  red"),
	BrickColor.new("Pink"),
	BrickColor.new("Bright purple"),
	BrickColor.new("Royal purple"),
	BrickColor.new("Earth blue"),
	BrickColor.new("Dark blue"),
	BrickColor.new("Light blue"),
	BrickColor.new("Forest green"),
	--BrickColor.new("Medium green"),
	--BrickColor.new("Tr. Brown"),
	BrickColor.new("Brown"),
	BrickColor.new("Reddish brown"),
	--BrickColor.new("Fawn brown"),
	BrickColor.new("Light stone grey"),
	BrickColor.new("Grey"),
	BrickColor.new("Dark grey"),
	BrickColor.new("Black"),
	--BrickColor.new("Really black"),
}

local COLOR_NUM_PER_COLUMN = 7
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function ColorSelectMenu_.GetInstance() : Types.ColorSelectMenu
	return ColorSelectMenu_.instance :: Types.ColorSelectMenu
end

function ShowColorList(self)
	for i,Color in Colors do
		local Clone = self.colorTemplate:Clone() :: TextButton
		Clone.BackgroundColor3 = Color.Color
		Clone.Parent = self.colorContainer
		Clone.Name = Color.Name
		Clone.Visible = true
		
		Clone.MouseButton1Click:Connect(function()
			self.lastColor = Color.Color
			self.doneEvent:Fire()
			self:SetShowHide(false)
		end)
	end
end

local function Init(self, gui : ScreenGui)
	print("coinGui init")
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	self:SetFlyInShowHide(false)
	
	self.viewportFrameCreator = ViewportFrameCreator.new()

	local colorFrame:Frame = gui:WaitForChild("ColorFrame") :: Frame
	
	self.doneEvent = Instance.new("BindableEvent") :: BindableEvent
	
	self.lastColor = Color3.fromRGB(255,255,255)
			
	self.applyButtonHandler = self:SetupButtonByName("Apply", function()
		self.doneEvent:Fire()
		self:SetShowHide(false)
	end)
	self.cancelButtonHandler = self:SetupButtonByName("CloseButton", function()
		self:Cancel()
	end)
	
	--ColorFrame
	self.colorFrame = gui:WaitForChild("ColorFrame")
	self.colorContainer = self.colorFrame:WaitForChild("ColorContainer")
	self.colorTemplate = self.colorContainer:WaitForChild("ColorTemplate")
	
	self:SetShowHide(false)
end


local function HideList(self)	
	for _, child in ipairs(self.colorContainer:GetChildren()) do
		if child:IsA("GuiObject") and child ~= self.template then
			child:Destroy()
		end
	end
end

--========================
-- public method
--========================

function ColorSelectMenu_.new(...)
	local self = setmetatable(BaseGui_.new(...), ColorSelectMenu_)
	Init(self, ...)
	ColorSelectMenu_.instance = self
	return self
end

function ColorSelectMenu_:LastColor(): Color3
	return self.lastColor
end

function ColorSelectMenu_:ShowAsync(): Color3?
	self:SetShowHide(true)
	self.doneEvent.Event:Wait()
	return self.lastColor
end

function ColorSelectMenu_:Cancel()
	self.doneEvent:Fire()
	self:SetShowHide(false)
end

function ColorSelectMenu_:OnShow()
	ShowColorList(self)
end

function ColorSelectMenu_:OnHide()
	HideList(self)
end
--========================
return ColorSelectMenu_
