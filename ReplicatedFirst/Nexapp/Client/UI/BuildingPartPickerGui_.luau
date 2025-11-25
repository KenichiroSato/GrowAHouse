--!strict

local BuildingPartPickerGui_ = {}

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ViewportFrameCreator = require(ReplicatedFirst.Nexsys.Client.ViewportFrameCreator_)

--- @class ShopGui_ : BaseGui_
local BuildingPartPickerGui_ = {}
BuildingPartPickerGui_.__index = BuildingPartPickerGui_
setmetatable(BuildingPartPickerGui_, BaseGui_)
BuildingPartPickerGui_.instance = nil
local items : {PVInstance} = {}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function BuildingPartPickerGui_.GetInstance()
	return BuildingPartPickerGui_.instance
end

--========================
-- private method
--========================

local function InitItems()
	local itemsFolder = ReplicatedStorage:FindFirstChild("BuildingParts") 
	for _, child in ipairs(itemsFolder:GetChildren()) do
		if child:IsA("Model")  or child:IsA("BasePart") then
			table.insert(items, child)
		end
	end
end

local function Init(self, gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()

	self:SetShowHide(false)
	self:SetExcludeShow(false)
	self:SetFlyInShowHide(false)
	
	self.doneEvent = Instance.new("BindableEvent") :: BindableEvent
	
	self.lastPartName = "Wall"
	self.frame = gui:WaitForChild("Frame")
	self.scrollingFrame = self.frame:WaitForChild("ScrollingFrame")
	self.template = self.scrollingFrame:WaitForChild("Template")
	self.viewportFrameCreator = ViewportFrameCreator.new()
	InitItems()
	
	self.cancelButtonHandler = self:SetupButtonByName("CloseButton", function()
		self:Cancel()
	end)
end

local function ShowList(self)
	for i, item in ipairs(items) do
		local row = self.template:Clone()
		row.Name = "Item_" .. i
		--row.Text = item.Name
		row.Visible = true
		row.Parent = self.scrollingFrame
		self.viewportFrameCreator:createViewport(row.ViewportFrame, item.Name, Define.BuildingPartFolder, nil, 60, Vector3.new(14, 6, 14))
		self.viewportFrameCreator:setSpin(row.ViewportFrame, 30)

		-- クリックイベント
		row.MouseButton1Click:Connect(function()
			print("Clicked:", item)
			self.doneEvent:Fire(item.Name)
			self:SetShowHide(false)
		end)
	end
end

local function HideList(self)
	self.viewportFrameCreator:destroy()
	for _, child in ipairs(self.scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") and child ~= self.template then
			child:Destroy()
		end
	end
end

--========================
-- public method
--========================

function BuildingPartPickerGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), BuildingPartPickerGui_)
	Init(self, ...)
	BuildingPartPickerGui_.instance = self
	return self
end

function BuildingPartPickerGui_:ShowAsync(): string?
	self:SetShowHide(true)
	local partName = self.doneEvent.Event:Wait()
	if partName then
		self.lastPartName = partName
	end
	return partName
end

function BuildingPartPickerGui_:Cancel()
	self.doneEvent:Fire()
	self:SetShowHide(false)
end

function BuildingPartPickerGui_:LastPartName(): string
	return self.lastPartName
end

function BuildingPartPickerGui_:OnShow()
	ShowList(self)
end

function BuildingPartPickerGui_:OnHide()
	HideList(self)
end

return BuildingPartPickerGui_
