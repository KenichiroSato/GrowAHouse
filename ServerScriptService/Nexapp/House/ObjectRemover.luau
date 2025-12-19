--!strict

local CollectionService = game:GetService("CollectionService")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvent")
local deleteEvent = remoteEventFolder:WaitForChild("HouseDeleteEvent")
local ItemMoveEvent = remoteEventFolder:WaitForChild("ItemMoveEvent") :: RemoteEvent
local STR = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("Strings"))
local ScreenRayExecutor = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("ScreenRayExecutor"))

local ServerScriptService = game:GetService("ServerScriptService")
local HouseBaseManager = require(ServerScriptService.Nexapp.House.HouseBaseManager)
local PlayerManager: Types.PlayerManager = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("Player"):WaitForChild("PlayerManager"))


local ObjectRemover = {}
ObjectRemover.__index = ObjectRemover


function ObjectRemover.bindEvents()
	deleteEvent.OnServerEvent:Connect(function(player, ray: Ray, isMove: boolean)
		local houseAreaHideBeam = HouseBaseManager.GetHouseAreaVolume(player, "HouseAreaHideBeam")
		local houseAreaVolume = HouseBaseManager.GetHouseAreaVolume(player, "HouseAreaVolume")
		local excludes = {player.Character, houseAreaVolume, houseAreaHideBeam}
		
		local deletable = ScreenRayExecutor.FindPlayerOwnedInstance(player, ray, excludes)
		if not deletable then return end
		
		local gamePlayer = PlayerManager.GetGamePlayer(player)
		if not gamePlayer then return end
		--家具か建築素材かは分からないので、両方Remove呼ぶ
		if deletable:HasTag(STR.TAG_Building) then
			gamePlayer:RemoveBuildingPart(deletable:GetAttribute(STR.InstanceId))
		elseif deletable:HasTag(STR.TAG_Furniture) then
			--家具の場合はアイテムリストに戻す
			gamePlayer:AddPurchasedItem(deletable.Name)
			gamePlayer:RemoveFurniture(deletable:GetAttribute(STR.InstanceId))
			if isMove then
				ItemMoveEvent:FireClient(player, deletable.Name)
			end
		end
		deletable:Destroy()
	end)
end

return ObjectRemover

