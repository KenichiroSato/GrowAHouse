--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local houseEditor = require(game.StarterPlayer.StarterPlayerScripts.Scripts:WaitForChild("HouseEditor_"))

--- @class ShopGui_ : BaseGui_
local EditGui_ = {}
EditGui_.__index = EditGui_
setmetatable(EditGui_, BaseGui_)
EditGui_.instance = nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function EditGui_.GetInstance()
	return EditGui_.instance
end

local SELECTED_THICKNESS = 0.1
local UNSELECTED_THICKNESS = 0
local SELECTED_TRANSPARENCY = 0
local UNSELECTED_TRANSPARENCY = 0.3

--========================
-- private method
--========================
local function OnMoveButtonPressed(self)
	self.moveButtonStroke.Thickness = SELECTED_THICKNESS
	self.moveButton.BackgroundTransparency = SELECTED_TRANSPARENCY
	self.putAwayButtonStroke.Thickness = UNSELECTED_THICKNESS
	self.putAwayButton.BackgroundTransparency = UNSELECTED_TRANSPARENCY
end
local function OnPutAwayButtonPressed(self)
	self.moveButtonStroke.Thickness = UNSELECTED_THICKNESS
	self.moveButton.BackgroundTransparency = UNSELECTED_TRANSPARENCY
	self.putAwayButton.BackgroundTransparency = SELECTED_TRANSPARENCY
	self.putAwayButtonStroke.Thickness = SELECTED_THICKNESS
end

local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()

	self:SetShowHide(false)
	self:SetExcludeShow(true)
	
	self.crossHair = gui:WaitForChild("CrossHair") :: ImageLabel
	local menuFrame = gui:WaitForChild("MenuFrame") :: Frame
	self.moveButton = menuFrame:WaitForChild("MoveButton")
	self.moveButtonStroke = self.moveButton:WaitForChild("UIStroke") :: UIStroke
	self.putAwayButton = menuFrame:WaitForChild("PutAwayButton")
	self.putAwayButtonStroke = self.putAwayButton:WaitForChild("UIStroke") :: UIStroke
	
	self.moveButtonHandler = self:SetupButtonByName("MoveButton", function()
		OnMoveButtonPressed(self)
	end)
	self.putAwayButtonHandler = self:SetupButtonByName("PutAwayButton", function()
		OnPutAwayButtonPressed(self)
	end)
	OnMoveButtonPressed(self)
end

--========================
-- public method
--========================

function EditGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), EditGui_)
	Init(self, ...)
	EditGui_.instance = self
	return self
end

function EditGui_:OnShow()
	local crossHairCenter: Vector2 = self.crossHair.AbsolutePosition + self.crossHair.AbsoluteSize/2
	houseEditor.StartDeleteMode(crossHairCenter)
end

function EditGui_:OnHide()
	houseEditor.StopDeleteMode()
end

return EditGui_
