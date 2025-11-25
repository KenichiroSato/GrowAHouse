local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local ModelUtil = require(ReplicatedFirst.Nexsys.Common.ModelUtil)
--- @class PlayerCommon : table
local PlayerCommon = {}
PlayerCommon.__index = PlayerCommon

----------------------------------------------------------------------------------------------------
-- Playerのクライアント/サーバー共通処理
-- Playerインスタンスに関してから解決できる処理のみを実装想定
function PlayerCommon.new(player : Player)
	local self = setmetatable({}, PlayerCommon)
	PlayerCommon.Init(self, player)
	return self
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerCommon:Init(player : Player)
	self.player = player
	self.thumbnailx100 = nil
end
----------------------------------------------------------------------------------------------------
-- GetPlayer
function PlayerCommon:GetPlayer() : Player
	return self.player
end
----------------------------------------------------------------------------------------------------
-- IsPlayer
function PlayerCommon:IsPlayer(player : Player)
	if self.player == player then
		return true
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- GetUserId
function PlayerCommon:GetUserId()
	return self.player.UserId
end
--
function PlayerCommon:GetUserIdString()
	return tostring(self:GetUserId())
end
----------------------------------------------------------------------------------------------------
-- GetName
function PlayerCommon:GetName()
	return self.player.Name
end
----------------------------------------------------------------------------------------------------
-- GetDisplayName
function PlayerCommon:GetDisplayName()
	return self.player.DisplayName
end
----------------------------------------------------------------------------------------------------
-- SetAttribute
function PlayerCommon:SetAttribute(attrName, value)
	self.player:SetAttribute(attrName, value)
end
----------------------------------------------------------------------------------------------------
-- GetAttribute
function PlayerCommon:GetAttribute(attrName)
	return self.player:GetAttribute(attrName)
end
----------------------------------------------------------------------------------------------------
-- キャラクターからFindFirstChild
function PlayerCommon:FindFirstChildOnCharacter(name)
	local chara = self:GetCharacter()
	if chara then
		return chara:FindFirstChild(name)
	end
end
----------------------------------------------------------------------------------------------------
-- GetCharacter
function PlayerCommon:GetCharacter() : Model?
	return self.player.Character
end
----------------------------------------------------------------------------------------------------
-- WaitForCharacter
function PlayerCommon:WaitForCharacter() : Model
	return self.player.Character or self.player.CharacterAdded:Wait()
end
----------------------------------------------------------------------------------------------------
-- GetCharacterAsync
function PlayerCommon:GetCharacterAsync() : Model
	return self:WaitForCharacter()
end
----------------------------------------------------------------------------------------------------
-- IsValidChara
function PlayerCommon:IsValidChara()
	local hum = self:GetHumanoid()
	if hum then
		return true
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerCommon:GetHumanoid() : Humanoid?
	if self.player.Character then
		local hum = self.player.Character:FindFirstChildOfClass("Humanoid")
		return hum
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerCommon:GetHumanoidRootPart() : Part?
	local hum = self:GetHumanoid()
	if hum then
		return hum.RootPart
	end
end
----------------------------------------------------------------------------------------------------
-- GetHeadPart
function PlayerCommon:GetHeadPart() : Part
	local chara = self:GetCharacter()
	if chara then
		return chara:FindFirstChild("Head")
	end
end
----------------------------------------------------------------------------------------------------
-- GetRootHeight
function PlayerCommon:GetRootHeight() : number
	local hipHeight = self:GetHipHeight()
	local hrp = self:GetHumanoidRootPart()
	if hipHeight and hrp then
		return hrp.Size.Y * 0.5 + hipHeight
	end
	return 0
end
----------------------------------------------------------------------------------------------------
-- GetHipHeight
function PlayerCommon:GetHipHeight() : number
	local hum = self:GetHumanoid()
	if hum then
		return hum.HipHeight
	end
	return 0
end
----------------------------------------------------------------------------------------------------
-- GetPosition
function PlayerCommon:GetPosition() : Vector3?
	local pv = self:GetPivot()
	if pv then
		return pv.Position
	end
end
----------------------------------------------------------------------------------------------------
-- GetPivot
function PlayerCommon:GetPivot() : CFrame?
	if self.player.Character then
		return self.player.Character:GetPivot()
	end
end
----------------------------------------------------------------------------------------------------
-- SetPivot
function PlayerCommon:SetPivot(cframe : CFrame)
	local chara = self:GetCharacter()
	if chara then
		chara:PivotTo(cframe)
	end
end
----------------------------------------------------------------------------------------------------
-- GetRootAttachment
function PlayerCommon:GetRootAttachment() : Attachment?
	local rootPart = self:GetHumanoidRootPart()
	if rootPart then
		return rootPart:FindFirstChild("RootAttachment")
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerCommon:WaitForRootAttachment() : Attachment
	local chara = self:WaitForCharacter()
	local rootPart = chara:WaitForChild("HumanoidRootPart")
	if rootPart then
		return rootPart:WaitForChild("RootAttachment")
	end
end
----------------------------------------------------------------------------------------------------
-- GetFloorPosition()
function PlayerCommon:GetFloorPosition() : Vector3 | nil
	local pos = self:GetPosition()
	if pos then
		return pos - Vector3.new(0, self:GetRootHeight(), 0)
	end
end
----------------------------------------------------------------------------------------------------
-- GetVelocity
function PlayerCommon:GetVelocity() : Vector3
	local hrp = self:GetHumanoidRootPart()
	if hrp then
		return hrp.AssemblyLinearVelocity
	end
	return Vector3.zero
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerCommon:GetBackpack() : Backpack
	return self.player.Backpack
end
----------------------------------------------------------------------------------------------------
-- IsAlive
function PlayerCommon:IsAlive()
	if self:IsValidChara() then
		if not self:IsDead() then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- IsDead()
function PlayerCommon:IsDead()
	local hum = self:GetHumanoid()
	if hum then
		if hum:GetState() == Enum.HumanoidStateType.Dead then
			return true
		end
		if hum.Health <= 0 then
			return true
		end
	end
end
----------------------------------------------------------------------------------------------------
-- HasForceField
function PlayerCommon:HasForceField() : boolean
	local chara = self:GetCharacter()
	if chara then
		if chara:FindFirstChildOfClass("ForceField") then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- IsInAir
function PlayerCommon:IsInAir()
	local hum = self:GetHumanoid()
	if not hum then
		return
	end

	return hum:GetState() == Enum.HumanoidStateType.Freefall
end
----------------------------------------------------------------------------------------------------
-- LoadUserThumbnail
function PlayerCommon:LoadUserThumbnail()
	task.spawn(function()
		pcall(function()
			local imageUrl, isReady = game.Players:GetUserThumbnailAsync(
				self:GetUserId(), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			if imageUrl then
				self.thumbnailx100 = imageUrl
			end
			if not isReady then
				error("GetUserThumbnailAsync failed, userId="..self:GetUserId())
			end
		end)
	end)
end
----------------------------------------------------------------------------------------------------
-- GetUserThumbnailAsync
function PlayerCommon:GetUserThumbnailAsync()
	if self.thumbnailx100 then
		return self.thumbnailx100
	end

	local imageUrl, isReady = game.Players:GetUserThumbnailAsync(
		self:GetUserId(), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	if imageUrl then
		self.thumbnailx100 = imageUrl
	end
	return imageUrl, isReady
end
----------------------------------------------------------------------------------------------------
-- GetToolByName
function PlayerCommon:GetToolByName(toolName) : Tool?
	local chara = self:GetCharacter()
	if not chara then 
		return nil
	end

	local equipTool : Tool = chara:FindFirstChild(toolName)
	if equipTool and equipTool.Name == toolName then
		return equipTool
	end

	local backpack = self:GetBackpack()
	local tools = backpack:GetChildren()
	for index, tool in tools do
		if tool.Name == toolName then
			return tool
		end
	end

	return nil
end

----------------------------------------------------------------------------------------------------
-- GetEquipTool
function PlayerCommon:GetEquipTool() : Tool
	local chara = self:GetCharacter()
	if not chara then 
		return nil
	end

	local equipTool : Tool = chara:FindFirstChildOfClass("Tool")
	return equipTool
end
----------------------------------------------------------------------------------------------------
-- HasTool
function PlayerCommon:HasTool(toolName) : boolean
	if self:GetToolByName(toolName) then
		return true
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- SetAnchored
function PlayerCommon:SetAnchored(val)
	local hrp = self:GetHumanoidRootPart()
	if hrp then
		hrp.Anchored = val
	end
end
----------------------------------------------------------------------------------------------------
-- IsAnchored
function PlayerCommon:IsAnchored() : boolean
	local hrp = self:GetHumanoidRootPart()
	if hrp then
		return hrp.Anchored
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- GetCollisionGroup
function PlayerCommon:GetCollisionGroup() : string
	local hrp = self:GetHumanoidRootPart()
	if hrp then
		return hrp.CollisionGroup
	end
end
----------------------------------------------------------------------------------------------------
-- SetCollisionGroup
function PlayerCommon:SetCollisionGroup(groupName : string)
	if self:GetCollisionGroup() == groupName then
		return
	end

	local chara = self:GetCharacter()
	if chara then
		ModelUtil.SetCollisionGroup(chara, groupName)
	end
end
----------------------------------------------------------------------------------------------------
-- IsSitting
function PlayerCommon:IsSitting() : boolean
	local hum = self:GetHumanoid()
	if hum then
		return hum.Sit
	end
end
----------------------------------------------------------------------------------------------------
-- GetSittingSeat
function PlayerCommon:GetSittingSeat() : Seat?
	local hum = self:GetHumanoid()
	if hum then
		return hum.SeatPart
	end
end
----------------------------------------------------------------------------------------------------
-- CreateCharacterModel
function PlayerCommon:CreateCharacterModelAsync() : Model?
	local success, createdChara = pcall(function()
		return game.Players:CreateHumanoidModelFromUserId(self:GetUserId())
	end)
	if not success then
		warn("CreateHumanoidModelFromUserId failed", self:GetUserId())
		return nil
	end
	return createdChara
end
----------------------------------------------------------------------------------------------------
-- StandUp
function PlayerCommon:StandUp()
	local chara = self:GetCharacter()
	if chara then
		local hum = chara.Humanoid :: Humanoid
		if hum and hum.Sit then
			hum.Sit = false
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerCommon:TeleportToPart(part : BasePart, usePartRot : boolean?)
	if not part then
		warn("TeleportToPart part is nil")
		return
	end

	task.spawn(function()
		local chara = self:GetCharacter()
		if chara then
			if self:IsSitting()	then
				-- 座ってる場合立たせないとSeatまでワープしてしまう
				self:StandUp()
				task.wait(0.1)
			end

			local ofsY = self:GetHipHeight() + part.Size.Y / 2
			local cf
			if usePartRot then
				cf = part.CFrame + Vector3.new(0, ofsY, 0)
			else
				cf = CFrame.new(part:GetPivot().Position + Vector3.new(0, ofsY, 0)) * chara:GetPivot().Rotation
			end
			chara:PivotTo(cf)
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- TeleportToPosition
function PlayerCommon:TeleportToPosition(pos : Vector3)
	if not pos then
		warn("TeleportToPosition pos is nil")
		return
	end

	task.spawn(function()
		local chara = self:GetCharacter()
		if chara then
			if self:IsSitting()	then
				-- 座ってる場合立たせないとSeatまでワープしてしまう
				self:StandUp()
				task.wait(0.1)
			end

			local ofsY = self:GetHipHeight()
			local cf = CFrame.new(pos + Vector3.new(0, ofsY, 0))
			chara:PivotTo(cf)
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- GetFriendsAsync
function PlayerCommon:GetFriendsInfoAsync() : { SystemTypes.FriendInfo }
	-- Players#GetFriendsAsync のドキュメントの処理

	local function iterPageItems(pages)
		return coroutine.wrap(function()
			local pagenum = 1
			while true do
				for _, item in ipairs(pages:GetCurrentPage()) do
					coroutine.yield(item, pagenum)
				end
				if pages.IsFinished then
					break
				end
				pages:AdvanceToNextPageAsync()
				pagenum = pagenum + 1
			end
		end)
	end

	-- テスト用キャラなどでは取れない
	if self.player.UserId <= 0 then
		return {}
	end

	local friendPages = Players:GetFriendsAsync(self.player.UserId)
	local infos = {}
	for item, _pageNo in iterPageItems(friendPages) do
		table.insert(infos, item)
	end
	return infos
end

return PlayerCommon
