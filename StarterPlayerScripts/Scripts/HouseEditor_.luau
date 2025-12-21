local HouseEditor_ = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SysTypes = require(ReplicatedFirst.Nexsys.Common.Types)
local SingleTapDetector_: SysTypes.SingleTapDetector_ = require(ReplicatedFirst.Nexsys.Client.SingleTapDetector_)
local ScreenRayExecutor = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("ScreenRayExecutor"))
local STR = require(ReplicatedStorage.Script.Strings)
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local deleteRequestEvent = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("HouseDeleteEvent")
local getHouseBaseFunction = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("GetHouseBaseFunction")

local lastFire = 0
local COOLDOWN = 0.05

local singleTapDetector = SingleTapDetector_.new()

-- SelectionBox の作成
local selectionBox = Instance.new("SelectionBox")
selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
selectionBox.LineThickness = 0.15
selectionBox.SurfaceTransparency = 0.8
selectionBox.Visible = false
selectionBox.Parent = workspace

-- 内部状態
local lastTarget: Instance? = nil
local connection: RBXScriptConnection?

local isMoveMode = true
--------------------------------------
--       private method
--------------------------------------
local function fireRayFromScreen(x, y)
	if time() - lastFire < COOLDOWN then return end
	lastFire = time()

	local ray = camera:ScreenPointToRay(x, y)
	deleteRequestEvent:FireServer(ray, isMoveMode)
end

local function updateTarget(deletePosition: Vector2)
	if connection == nil then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local ray: Ray? = nil
	if UserInputService.GamepadEnabled then
		-- deletePosition is expected in screen pixels (X, Y)
		ray = cam:ScreenPointToRay(deletePosition.X, deletePosition.Y)
	elseif UserInputService.MouseEnabled then
		local mousePos = UserInputService:GetMouseLocation()
		-- Use pixel coordinates with ScreenPointToRay (ViewportPointToRay expects 0..1)
		ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	end
	if not ray then return end
	local houseAreaHideBeam = getHouseBaseFunction:InvokeServer("HouseAreaHideBeam")
	local houseAreaVolume = getHouseBaseFunction:InvokeServer("HouseAreaVolume")
	local excludes = {player.Character, houseAreaVolume, houseAreaHideBeam}
	local target = ScreenRayExecutor.FindPlayerOwnedInstance(player, ray, excludes)
	if target then
		if target ~= lastTarget and connection ~= nil then
			-- When in move mode, only allow selecting furniture-tagged targets
			local canSelect = true
			if isMoveMode then
				canSelect = target:HasTag(STR.TAG_Furniture) and true or false
			end
			if canSelect then
				selectionBox.Adornee = target
				selectionBox.Visible = true
				print("saot selectionBox.Visible = true")
				lastTarget = target
			else
				selectionBox.Visible = false
				lastTarget = nil
			end
		end
	else
		selectionBox.Visible = false
		lastTarget = nil
	end
end

--------------------------------------
--       public method
--------------------------------------
function HouseEditor_.SetMoveMode(isMove: boolean)
	isMoveMode = isMove
end

function HouseEditor_.StartEditMode(gamePadDeletePosition: Vector2, caller)
	print("StartEditMode")
	if connection ~= nil then return end
	
	if UserInputService.GamepadEnabled or UserInputService.MouseEnabled then
		connection = RunService.RenderStepped:Connect(function(dt)
			updateTarget(gamePadDeletePosition)
		end)
	end
	
	singleTapDetector:Start(function(input)
		if (input.UserInputType == Enum.UserInputType.Gamepad1) then
			print("gamepad input")
			fireRayFromScreen(gamePadDeletePosition.X, gamePadDeletePosition.Y)
		else
			fireRayFromScreen(input.Position.X, input.Position.Y)
		end
		if isMoveMode then
			if caller and type(caller.SetShowHide) == "function" then
				caller:SetShowHide(false)
			end	
			HouseEditor_.StopEditMode()
		end
	end)
end

function HouseEditor_.StopEditMode() 
	singleTapDetector:Stop()
	lastTarget = nil
	if connection then
		connection:Disconnect()
		connection = nil
	end
	selectionBox.Visible = false
end

return HouseEditor_