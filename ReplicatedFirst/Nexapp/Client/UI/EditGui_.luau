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

--========================
-- private method
--========================
local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()

	self:SetShowHide(false)
	self:SetExcludeShow(true)
	
	self.crossHair = gui:WaitForChild("CrossHair") :: ImageLabel
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
