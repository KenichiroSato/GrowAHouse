local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
local Timer = require(ReplicatedFirst.Nexsys.Common.Timer)
local PreloadController_ = require(ReplicatedFirst.Nexsys.Client.PreloadController_)

--- @class LoadingGui_ : BaseGui_
local LoadingGui_ = {}
LoadingGui_.__index = LoadingGui_
setmetatable(LoadingGui_, BaseGui_)
LoadingGui_.instance = nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return LoadingGui_
function LoadingGui_.GetInstance()
	return LoadingGui_.instance
end

function LoadingGui_.WaitForInstance()
	while not LoadingGui_.instance do
		task.wait(0.1)
	end
	return LoadingGui_.instance
end
----------------------------------------------------------------------------------------------------

function LoadingGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), LoadingGui_)
	LoadingGui_.Init(self, ...)
	LoadingGui_.instance = self
	return self
end

function LoadingGui_:Init(gui : ScreenGui)
	gui.Enabled = false
	self:SetupButtonByName("StartButton", function()
		self:onStartButtonPressed()
	end)

	self.image1 = self:FindDescendant("Image1")
	self.image2 = self:FindDescendant("Image2")
	self.imageChangeTimer = Timer.new()
	self.imageChangeTimer:SetSpan(0.5)
	self.percentText = self:FindDescendantText("Percent")
	self:SetShowUpdate(true)
end
----------------------------------------------------------------------------------------------------
-- onShowUpdate
function LoadingGui_:onShowUpdate()
	if not self.imageChangeTimer:IsActive() then
		self.image1.Visible = not self.image1.Visible
		self.image2.Visible = not self.image2.Visible
		self.imageChangeTimer:RestartSpan()
	end

	local rate = PreloadController_:GetLoadRate()
	self.percentText.Text = string.format("%d%%", rate * 100)
end
----------------------------------------------------------------------------------------------------
-- onStartButtonPressed
function LoadingGui_:onStartButtonPressed()
	self:Hide()
	SystemDataModule_.OnLoadingScreenEnded()
end
----------------------------------------------------------------------------------------------------

return LoadingGui_