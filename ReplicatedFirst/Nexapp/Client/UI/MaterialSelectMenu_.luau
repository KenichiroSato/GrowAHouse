--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local ViewportFrameCreator = require(ReplicatedFirst.Nexsys.Client.ViewportFrameCreator_)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaterialConverter = require(ReplicatedStorage.Script.MaterialConverter)

--- @class ShopGui_ : BaseGui_
local MaterialSelectMenu_ = {}
MaterialSelectMenu_.__index = MaterialSelectMenu_
setmetatable(MaterialSelectMenu_, BaseGui_)
MaterialSelectMenu_.instance = nil

----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function MaterialSelectMenu_.GetInstance() : Types.MaterialSelectMenu
	return MaterialSelectMenu_.instance :: Types.MaterialSelectMenu
end

local function Init(self, gui : ScreenGui)
	print("coinGui init")
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	self:SetFlyInShowHide(false)
	
	self.viewportFrameCreator = ViewportFrameCreator.new()
	
	self.doneEvent = Instance.new("BindableEvent") :: BindableEvent
	
	self.lastMaterial = Enum.Material.Plastic
		
		--BackFrame
	self.backFrame = gui:WaitForChild("BackFrame")
	
	self.applyButtonHandler = self:SetupButtonByName("Apply", function()
		self.doneEvent:Fire()
		self:SetShowHide(false)
	end)
	self.cancelButtonHandler = self:SetupButtonByName("CloseButton", function()
		self:Cancel()
	end)
		
	--MaterialList
	self.materialFrame = self.backFrame:WaitForChild("MaterialFrame")
	self.scrollingFrame = self.materialFrame:WaitForChild("ScrollingFrame")
	self.template = self.scrollingFrame:WaitForChild("Template")

	self:SetShowHide(false)
end


local function ShowMaterialList(self)
	local samples = workspace:WaitForChild("MaterialSamples")
	for i, item in samples:GetDescendants() do
		local row = self.template:Clone()
		row.Name = "Item_" .. i
		row.Text = item.Name
		row.Visible = true
		row.Parent = self.scrollingFrame
		self.viewportFrameCreator:createViewport(row.ViewportFrame, item.Name, samples, Vector3.new(0.55, 0, 0), 120)

		-- クリックイベント
		row.MouseButton1Click:Connect(function()
			local newMat = MaterialConverter.Materials[item.Name] 
			if newMat then
				print("Clicked:", item.Name)
				self.lastMaterial = newMat
				self.doneEvent:Fire()
				self:SetShowHide(false)
			end
			--self:SetShowHide(false)
		end)
	end
end

local function HideList(self)
	for _, child in ipairs(self.scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") and child ~= self.template then
			child:Destroy()
		end
	end	
end

--========================
-- public method
--========================

function MaterialSelectMenu_.new(...)
	local self = setmetatable(BaseGui_.new(...), MaterialSelectMenu_)
	Init(self, ...)
	MaterialSelectMenu_.instance = self
	return self
end

function MaterialSelectMenu_:LastMaterial(): Enum.Material
	return self.lastMaterial
end

function MaterialSelectMenu_:ShowAsync():  Enum.Material
	self:SetShowHide(true)
	self.doneEvent.Event:Wait()
	return  self.lastMaterial
end

function MaterialSelectMenu_:Cancel()
	self.doneEvent:Fire()
	self:SetShowHide(false)
end

function MaterialSelectMenu_:OnShow()
	ShowMaterialList(self)
end

function MaterialSelectMenu_:OnHide()
	HideList(self)
end
--========================
return MaterialSelectMenu_
