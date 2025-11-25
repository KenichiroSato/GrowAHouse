--!strict

local BuildGui_ = {}

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local houseBuilder = require(game.StarterPlayer.StarterPlayerScripts.Scripts:WaitForChild("HouseBuilder_"))


--- @class ShopGui_ : BaseGui_
local BuildGui_ = {}
BuildGui_.__index = BuildGui_
setmetatable(BuildGui_, BaseGui_)
BuildGui_.instance = nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function BuildGui_.GetInstance()
	return BuildGui_.instance
end
----------------------------------------------------------------------------------------------------

--========================
-- private method
--========================


local function OnBuildButtonPressed()
	print("OnBuildBUttonPressed")
end

local function SetBuildPart(self, name: string)
	houseBuilder.setBuildingPart(name)
end


local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	
	self:SetShowHide(false)
	self:SetExcludeShow(true)
	
	self.wallButtonHandler = self:SetupButtonByName("WallButton", function()
		SetBuildPart(self, "Wall_Window1")
	end)
	self.foorButtonHandler = self:SetupButtonByName("FloorButton", function()
		SetBuildPart(self, "Floor")
	end)
	self.stairsButtonHandler = self:SetupButtonByName("StairsButton", function()
		SetBuildPart(self, "Stairs")
	end)
	self.noneButtonHandler = self:SetupButtonByName("NoneButton", function()
		SetBuildPart(self, "")
	end)
end


--========================
-- public method
--========================

function BuildGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), BuildGui_)
	Init(self, ...)
	BuildGui_.instance = self
	return self
end

function BuildGui_:OnShow()
	houseBuilder.Start()
end

function BuildGui_:OnHide()
	houseBuilder.Stop()
end

return BuildGui_