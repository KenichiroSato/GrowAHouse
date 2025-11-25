local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerUtil = {}
----------------------------------------------------------------------------------------------------
-- 
function PlayerUtil.GetPlayer()
	return Player
end

----------------------------------------------------------------------------------------------------
-- Wait(Yeild)ありでCharacter取得
function PlayerUtil.GetPlayerCharacterSync()
	local character = Player.Character or Player.CharacterAdded:Wait()
	return character
end

function PlayerUtil.GetPlayerCharacter() : Model?
	return Player.Character
end
--====================================================================
function PlayerUtil.GetPlayerGui()
	local PlayerGui = Player:WaitForChild("PlayerGui")
	return PlayerGui
end

function PlayerUtil.GetPlayerMass()
	if not Player.Character then
		print("player chara not found")
		return 0
	end

	local mass = 0
	for _, part in ipairs(Player.Character:GetChildren()) do
		if part:IsA("Part") or part:IsA("MeshPart") then
			mass += part.Mass
		end
	end
	return mass
end

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerUtil.GetToolByName(toolName)
	if not Player.Character then
		return nil
	end

	local equipTool : Tool = Player.Character:FindFirstChild(toolName)
	if equipTool and equipTool.Name == toolName then
		return equipTool
	end

	local backpack = Player.Backpack
	local tools = backpack:GetChildren()
	for index, tool in tools do
		if tool.Name == toolName then
			return tool
		end
	end

	return nil
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function PlayerUtil.AdjustCameraToBack()
	local Camera = workspace.Camera
	local curCf = Camera.CFrame
	local cameraRot = curCf.Rotation

	local pcRotCf = Player.Character:GetPivot().Rotation
	-- local orient = player.Character.PrimaryPart.Orientation
	-- print("pcRotY="..pcRot.Y..", ori="..orient.Y)
	-- print(pcRot)

	-- local newRot = Vector3.new(cameraRot.X, pcRot.Y, 0)
	-- Camera.CFrame = CFrame.new(curCf.Position) * CFrame.fromEulerAnglesXYZ(newRot.X, newRot.Y, newRot.Z)
	Camera.CFrame = CFrame.new(curCf.Position) * pcRotCf
end

return PlayerUtil

