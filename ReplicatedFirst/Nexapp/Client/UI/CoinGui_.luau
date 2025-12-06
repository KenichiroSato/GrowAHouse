--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)


--- @class ShopGui_ : BaseGui_
local CoinGui_ = {}
CoinGui_.__index = CoinGui_
setmetatable(CoinGui_, BaseGui_)
CoinGui_.instance = nil

local coinText: TextLabel
local perSecText: TextLabel

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function CoinGui_.GetInstance()
	return CoinGui_.instance
end

--========================
-- private method
--========================

local function Init(self, gui : ScreenGui)
	print("coinGui init")
	self:WaitForLoaded(gui)
	self:setGuiEnabled(false)
	self:WaitForSaveDataLoaded()
	local frame = gui:WaitForChild("Frame")
	coinText = frame:WaitForChild("CoinLabel") :: TextLabel
	
	perSecText = frame:WaitForChild("PerSecLabel") ::TextLabel
	
	SystemDataModule_.WaitUntilLoadingScreenEnded()
	self:setGuiEnabled(true)
	self:SetUpdate(true)
end

--========================
-- public method
--========================

function CoinGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), CoinGui_)
	Init(self, ...)
	CoinGui_.instance = self
	return self
end

function CoinGui_:onUpdate(dt: number)
	coinText.Text = "$" .. PlayerData:GetCoin()
	perSecText.Text = "$" .. PlayerData:GetCoinPerSec() .. "/s"
end

return CoinGui_
