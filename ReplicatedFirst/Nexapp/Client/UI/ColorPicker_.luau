--!strict
local mouse = game.Players.LocalPlayer:GetMouse()
local UIS = game:GetService("UserInputService")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local ViewportFrameCreator = require(ReplicatedFirst.Nexsys.Client.ViewportFrameCreator_)
local SamplePartName = "ColorPickSamplePart"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaterialConverter = require(ReplicatedStorage.Script.MaterialConverter)

--- @class ShopGui_ : BaseGui_
local ColorPicker_ = {}
ColorPicker_.__index = ColorPicker_
setmetatable(ColorPicker_, BaseGui_)
ColorPicker_.instance = nil

local coinText: TextLabel

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return ShopGui_
function ColorPicker_.GetInstance()
	return ColorPicker_.instance
end

--========================
-- private method
--========================

function UpdateCrosshair(self)
	local hue,s,v = Color3.toHSV(self.currentcolor)
	local plane = CFrame.new(Vector3.new(0,0,0))*CFrame.Angles(0,math.rad((180+(hue*360))%360),0)*CFrame.new(0,0,-s/2)
	local p = Vector2.new(plane.X,plane.Z)
	self.crosshair.Position = UDim2.new(0.5-p.Y,0,0.5+p.X,0)
end

local function IsOnPalette(self)
	local p = Vector2.new(mouse.X,mouse.Y)
	local onp = p-self.palette.AbsolutePosition
	local monp = onp-(self.palette.AbsoluteSize/2)

	local mid = self.palette.AbsolutePosition+(self.palette.AbsoluteSize/2)
	local distFromMid = (mid-p).Magnitude

	if distFromMid>self.palette.AbsoluteSize.X/2 then 
		return false
	else
		return true
	end
end

local function IsOnBar(self)
	local p = Vector2.new(mouse.X,mouse.Y)
	if p.X> self.bar.AbsolutePosition.X and p.X<self.bar.AbsolutePosition.X+ self.bar.AbsoluteSize.X and p.Y> self.bar.AbsolutePosition.Y and p.Y< self.bar.AbsolutePosition.Y+ self.bar.AbsoluteSize.Y then
		return true
	else
		return false
	end
end

local function ConvertToFull(ang)
	local ang = math.deg(ang)
	local min = -180
	local dist = math.abs(ang-min)
	return 360-dist
end

local function UpdateLabels(self)
	for i,v in pairs(self.labels)do
		v.Text = tostring(math.floor(self.currentcolor[i]*255))
	end
end

local function Update(self)
	local p = Vector2.new(mouse.X,mouse.Y)
	local onp = p- self.palette.AbsolutePosition
	local monp = onp-( self.palette.AbsoluteSize/2)

	local mid = self.palette.AbsolutePosition+(self.palette.AbsoluteSize/2)
	local distFromMid = (mid-p).Magnitude

	if distFromMid> self.palette.AbsoluteSize.X/2 then return end -- Mouse outside the palette reach

	local value = self.barval
	local saturation = distFromMid/(self.palette.AbsoluteSize.X/2)
	local hue = ConvertToFull(math.atan2(monp.Y,monp.X))/360

	self.display.BackgroundColor3 = Color3.fromHSV(hue,saturation,value)
	self.currentcolor = Color3.fromHSV(hue,saturation,value)
	self.viewportFrameCreator:SetColor(self.ViewportFrame, self.currentcolor)
	self.Value.Color = ColorSequence.new(Color3.fromHSV(hue,saturation,1),Color3.new(0,0,0))
	UpdateCrosshair(self)
end

local function ListenUserInput(self)
	self.InputConnection = UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if IsOnPalette(self) then
				local v = Instance.new("BindableEvent")

				local b = mouse.Move:Connect(function()
					v:Fire()
				end)
				local b2 = UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						v:Fire()
					end
				end)
				repeat Update(self) UpdateLabels(self) v.Event:Wait() until not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
				b:Disconnect()
				b2:Disconnect()
			elseif IsOnBar(self) then
				while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local mpos = mouse.Y-self.Value.Parent.AbsolutePosition.Y
					local y = mpos/ self.Value.Parent.AbsoluteSize.Y
					y = math.clamp(y,0,1)
					self.bar.Position = UDim2.new(0.5,0,y,0)
					self.barval = 1-y
					local h,s,v = Color3.toHSV(self.currentcolor)
					self.currentcolor = Color3.fromHSV(h,s,self.barval)
					self.display.BackgroundColor3 = self.currentcolor
					self.viewportFrameCreator:SetColor(self.ViewportFrame, self.currentcolor)
					UpdateLabels(self)
					game:GetService("RunService").RenderStepped:Wait()
				end
			end
		end
	end)
end

local function DIsconnectUserInput(self)
	if self.InputConnection then
		self.InputConnection:Disconnect()
		self.InputConnection = nil
	end
end

local function Init(self, gui : ScreenGui)
	print("coinGui init")
	self:WaitForLoaded(gui)
	self:WaitForSaveDataLoaded()
	self:SetFlyInShowHide(false)
	
	self.viewportFrameCreator = ViewportFrameCreator.new()

	local frame:Frame = gui:WaitForChild("Frame") :: Frame
	
	self.doneEvent = Instance.new("BindableEvent") :: BindableEvent
	
	self.lastColor = Color3.fromRGB(255,255,255)
	self.lastMaterial = Enum.Material.Plastic
	
	self.palette = frame:WaitForChild("Palette")
	self.display = frame:WaitForChild("Display")
	self.crosshair = self.palette:WaitForChild("Crosshair")
	self.Value = frame:WaitForChild("Value"):WaitForChild("UIGradient")
	self.ViewportFrame = self.display:WaitForChild("ViewportFrame")
	local ColorPickSamplePart: BasePart = workspace:WaitForChild(SamplePartName)

	self.currentcolor = Color3.new(1,1,1)
	self.bar = frame:WaitForChild("Value"):WaitForChild("bar")
	self.barval = 1
	
	self.labels = {}
	self.labels.R = frame:WaitForChild("R") :: TextBox
	self.labels.G = frame:WaitForChild("G") :: TextBox
	self.labels.B = frame:WaitForChild("B") :: TextBox
	
	for i,v in pairs(self.labels)do
		local otherlabels = {unpack(self.labels)}
		otherlabels[i] = nil
		v.FocusLost:Connect(function(enter)
			if enter then else UpdateLabels() return end
			local c = tonumber(v.Text)
			c = math.clamp(c,0,255)
			v.Text = tostring(c)
			self.currentcolor = Color3.fromRGB(tonumber(self.labels.R.Text),tonumber(self.labels.G.Text),tonumber(self.labels.B.Text))
			local h,s,v = Color3.toHSV(self.currentcolor)
			self.barval = v
			self.bar.Position = UDim2.new(0.5,0,1-math.clamp(self.barval,0,1),0)
			self.Value.Color = ColorSequence.new(Color3.fromHSV(h,s,1),Color3.new(0,0,0))
			self.display.BackgroundColor3 = self.currentcolor
			self.viewportFrameCreator:SetColor(self.ViewportFrame, self.currentcolor)
			UpdateCrosshair(self)
		end)
	end
	
	UpdateCrosshair(self)
	UpdateLabels(self)
	
	self.applyButtonHandler = self:SetupButtonByName("Apply", function()
		local r = self.labels.R.Text :: number
		local g = self.labels.G.Text :: number
		local b = self.labels.B.Text :: number
		local color = Color3.fromRGB(r, g, b)
		self.doneEvent:Fire(color)
		self:SetShowHide(false)
	end)
	self.cancelButtonHandler = self:SetupButtonByName("Cancel", function()
		self.doneEvent:Fire(nil)
		self:SetShowHide(false)
	end)
	
	--MaterialList
	self.materialFrame = gui:WaitForChild("MaterialFrame")
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
				self.viewportFrameCreator:SetMaterial(self.ViewportFrame, newMat)
			end
			--self:SetShowHide(false)
		end)
	end
end

local function ShowSampleViewport(self)
	self.viewportFrameCreator:createViewport(self.ViewportFrame, SamplePartName, workspace, Vector3.new(0.55, 0, 0), 120)
	self.viewportFrameCreator:SetColor(self.ViewportFrame, self.lastColor)
	self.viewportFrameCreator:SetMaterial(self.ViewportFrame, self.lastMaterial)
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

function ColorPicker_.new(...)
	local self = setmetatable(BaseGui_.new(...), ColorPicker_)
	Init(self, ...)
	ColorPicker_.instance = self
	return self
end

function ColorPicker_:LastColor(): Color3
	return self.lastColor
end

function ColorPicker_:LastMaterial(): Enum.Material
	return self.lastMaterial
end

function ColorPicker_:ShowAsync(): (Color3?, Enum.Material)
	self:SetShowHide(true)
	local picked: Color3?, mat: Enum.Material = self.doneEvent.Event:Wait()
	if picked then
		self.lastColor = picked
	end
	if mat then
		self.lastMaterial = mat
	end
	return picked, self.lastMaterial
end

function ColorPicker_:OnShow()
	ShowMaterialList(self)
	ShowSampleViewport(self)
	ListenUserInput(self)
end

function ColorPicker_:OnHide()
	HideList(self)
	DIsconnectUserInput(self)
end

return ColorPicker_
