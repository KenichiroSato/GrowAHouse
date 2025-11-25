--!strict

local HouseBuilder_ = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SysTypes = require(ReplicatedFirst.Nexsys.Common.Types)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local ColorMaterialSetter: SysTypes.ColorMaterialSetter = require(ReplicatedFirst.Nexsys.Common.ColorMaterialSetter)

local InstanceMover = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("InstanceMover"))
local SingleTapDetector_: SysTypes.SingleTapDetector_ = require(ReplicatedFirst.Nexsys.Client.SingleTapDetector_)

local placeEvent = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("HousePlaceEvent")
local player = Players.LocalPlayer :: Player
local camera = Workspace.CurrentCamera :: Camera

local STR = require(ReplicatedStorage.Script.Strings)

local gridSize = 16
local maxDistance = 15

-- 👻 ゴーストパーツ作成
local ghostConn: RBXScriptConnection? = nil
local ghostPart: Instance = Instance.new("Part")
local currentPartName: string
local singleTapDetector = SingleTapDetector_.new()
local color: Color3
local material: Enum.Material

--------------------------------------
--       private method
--------------------------------------
-- 角度スナップ
local function snapYaw(yawDegrees: number)
	return math.floor((yawDegrees + 45) / 90) * 90 % 360
end

local function roundToGrid(value: number, grid: number)
	return math.round((value ) / grid) * grid
end

local function ceilToGrid(value: number, grid: number)
	return math.ceil((value - grid/4) / grid) * grid
end


local function snapVector3ToGrid(vec:Vector3)
	return Vector3.new(
		roundToGrid(vec.X, gridSize),
		ceilToGrid(vec.Y, gridSize),
		roundToGrid(vec.Z, gridSize)
	)
end

-- 現在の設置予定位置と角度(radian)を取得
local function getPlacementInfo(): (Vector3, number)
	local character = player.Character :: Model
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
	local origin = camera.CFrame.Position
	if character and rootPart then
		origin = rootPart.Position
	end
	local direction = camera.CFrame.LookVector * maxDistance

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character, ghostPart}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = Workspace:Raycast(origin, direction, raycastParams)
	local hitPos = result and result.Position or (origin + direction)

	local lookVector = camera.CFrame.LookVector
	local yaw = math.atan2(-lookVector.Z, lookVector.X)
	local yawDegrees = math.deg(yaw)
	local snappedYaw = snapYaw(yawDegrees+90)

	local snappedPos = snapVector3ToGrid(hitPos)
	return snappedPos, math.rad(snappedYaw)
end

--  ゴーストパーツを更新
local function updateGhost()
	local newPos, yawRad = getPlacementInfo()
	InstanceMover.movePart(ghostPart, newPos, yawRad )	
end

local function setGhostParams()
	local function setParams(part: BasePart)
		part.Anchored = true
		part.CanCollide = false
		if part.Transparency ~= 1.0 then
			part.Transparency = 0.5
		end
	end
	if ghostPart:IsA("BasePart") then
		setParams(ghostPart)
	elseif ghostPart:IsA("Model") then
		for _, part in ipairs(ghostPart:GetDescendants()) do
			if part:IsA("BasePart") then
				setParams(part)
			end
		end
	end
	ghostPart.Parent = workspace
end

local function requestBuildEvent()
	if currentPartName == "" then return end
	local pos, yawRad = getPlacementInfo()
	if pos and yawRad then
		placeEvent:FireServer(currentPartName, pos, yawRad, color, material)
	end
end

--------------------------------------
--       public method
--------------------------------------

function HouseBuilder_.setBuildingPart(partName: string)
	print("part name=".. partName)
	if ghostPart then
		ghostPart:Destroy()
	end
	currentPartName = partName
	
	if (currentPartName ~= "") then
		ghostPart = Define.BuildingPartFolder:WaitForChild(currentPartName):Clone()
		setGhostParams()
	end
end

function HouseBuilder_.SetColor(newColor: Color3)
	color = newColor
	ColorMaterialSetter.Set(ghostPart, newColor, material, STR.TAG_IgnoreColor)
end

function HouseBuilder_.SetMaterial(newMaterial: Enum.Material)
	material = newMaterial
	ColorMaterialSetter.Set(ghostPart, color, newMaterial, STR.TAG_IgnoreColor)
end

function HouseBuilder_.Start()
	singleTapDetector:Start(function(input)
		requestBuildEvent()
	end)

	-- フレーム毎にゴースト位置を更新
	ghostConn = RunService.RenderStepped:Connect(updateGhost)
end

function HouseBuilder_.Stop()
	if ghostConn then
		ghostConn:Disconnect()
		ghostConn = nil
	end
	if ghostPart then
		ghostPart:Destroy()
	end
	currentPartName = ""
	singleTapDetector:Stop()
end

--------------------------------------
--       require 時の処理 
--------------------------------------


return HouseBuilder_
