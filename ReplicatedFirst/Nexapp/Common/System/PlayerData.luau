local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local BasePlayerData = require(ReplicatedFirst.Nexsys.Common.BasePlayerData)
local PlayerSaveTable = require(ReplicatedFirst.Nexapp.Common.System.PlayerSaveTable)
local PlayerSyncParamsTable = require(ReplicatedFirst.Nexapp.Common.System.PlayerSyncParamsTable)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local ConfigData = require(ReplicatedFirst.Exdata.ConfigData)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PriceProvider = require(ReplicatedStorage.Script.PriceProvider)

--- @class PlayerData : BasePlayerData
local PlayerData = {}
PlayerData.__index = PlayerData
setmetatable(PlayerData, BasePlayerData)

----------------------------------------------------------------------------------------------------
--
function PlayerData.new(...)
	local self = setmetatable(BasePlayerData.new(...), PlayerData)
	PlayerData.Init(self, ...)
	if RunService:IsClient() then
		BasePlayerData.SetInstance(self)
	end
	return self
end

function PlayerData:Init(player: Player)
	self.player = player
	if RunService:IsServer() then
		self:CreateSyncParam(PlayerSyncParamsTable.Template)
	end
	-- ClientはReplicaが使えるタイミングで明示的に StartOnClient を呼ぶ
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerData:StartOnClient()
	self:CreateSyncParam(PlayerSyncParamsTable.Template)
	self:CreateSaveReplicaParams(PlayerSaveTable.Template)
	task.spawn(function()
		local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
		SystemDataModule_.WaitUntilSaveDataLoaded()
		self:StartListenToSaveDataChanged()
	end)
end
----------------------------------------------------------------------------------------------------
-- Destroy
function PlayerData:Destroy()
	BasePlayerData.Destroy(self)
	if self.syncParamIns then
		self.syncParamIns:Destroy()
	end
end

----------------------------------------------------------------------------------------------------
-- SyncTable系
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- SetPlayerLoginTime
function PlayerData:SetPlayerLoginTime()
	self:SetAttribute("PlayerLoginTime", os.time())
end
----------------------------------------------------------------------------------------------------
-- GetPlayerLoginTime
function PlayerData:GetPlayerLoginTime()
	return self:GetAttribute("PlayerLoginTime")
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerData:GetPlayerSessionPlayTime()
	local loginTime = self:GetLastLoginTime()
	local now = os.time()
	local diff = now - loginTime
	return diff
end

----------------------------------------------------------------------------------------------------
-- 
function PlayerData:HasCanClaimStayBonus()
	local StayBonusData = require(ReplicatedFirst.Exdata.StayBonusData)
	local sessionPlayTime = self:GetPlayerSessionPlayTime()
	local claimedList = self:GetStayBonusClaimedList()
	local isEnable = false
	for index, data in StayBonusData do
		if not claimedList[index] and sessionPlayTime >= data.Time then
			isEnable = true
			break
		end
	end
	return isEnable
end
----------------------------------------------------------------------------------------------------
--- IsDevMode
function PlayerData:IsDevMode() : boolean?
	return self:GetAttribute("DevMode")
end
----------------------------------------------------------------------------------------------------
--- SetDevMode
function PlayerData:SetDevMode(val : boolean)
	self:SetAttribute("DevMode", val)
end
----------------------------------------------------------------------------------------------------
-- GetDashMode
function PlayerData:IsDashMode()
	return self:GetSyncParamKey(PlayerSyncParamsTable.Keys.DashMode)
end
--
function PlayerData:SetDashMode(val)
	self:SetSyncParamKey(PlayerSyncParamsTable.Keys.DashMode, val)
end

----------------------------------------------------------------------------------------------------
-- セーブ系IF
----------------------------------------------------------------------------------------------------
-- GetPlayTime
function PlayerData:GetPlayTime()
	return self:GetSaveDataKey(PlayerSaveTable.Keys.PlayTime) or 0
end
-- SetPlayTime
function PlayerData:SetPlayTime(val: number)
	self:SetSaveDataKey(PlayerSaveTable.Keys.PlayTime, val)
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerData:GetLastLoginTime()
	return self:GetSaveDataKey(PlayerSaveTable.Keys.LastLoginTime)
end
-- 
function PlayerData:SetLastLoginTime(val: number)
	self:SetSaveDataKey(PlayerSaveTable.Keys.LastLoginTime, val)
end
----------------------------------------------------------------------------------------------------
-- SetStayBonusClaimed
function PlayerData:SetStayBonusClaimed(level)
	self:SetSaveDataKey2(PlayerSaveTable.Keys.StayBonusClaimedList, level, true)
end
----------------------------------------------------------------------------------------------------
-- ClearStayBonusClaimedList
function PlayerData:ClearStayBonusClaimedList()
	self:SetSaveDataKey(PlayerSaveTable.Keys.StayBonusClaimedList, {})
end
----------------------------------------------------------------------------------------------------
-- GetStayBonusClaimedList
function PlayerData:GetStayBonusClaimedList()
	return self:GetSaveDataKey(PlayerSaveTable.Keys.StayBonusClaimedList)
end
----------------------------------------------------------------------------------------------------
-- GetCoin
function PlayerData:GetCoin()
	return self:GetSaveDataKey(PlayerSaveTable.Keys.Coin)
end
-- SetCoin
function PlayerData:SetCoin(val: number)
	self:SetSaveDataKey(PlayerSaveTable.Keys.Coin, val)
end
-- GetCoinText
function PlayerData:GetCoinText()
	local GameUtil = require(ReplicatedFirst.Nexapp.Common.System.GameUtil)
	return GameUtil.GetCoinText(self:GetCoin())
end
----------------------------------------------------------------------------------------------------
function PlayerData:SetBuildingParts(parts: Types.BuildingPartArray)
	self:SetSaveDataKey(PlayerSaveTable.Keys.BuildingParts, parts)
end

function PlayerData:GetBuildingParts() : Types.BuildingPartArray
	return self:GetSaveDataKey(PlayerSaveTable.Keys.BuildingParts)
end

function PlayerData:GetBuildingPartsNum() : number
	return #self:GetSaveDataKey(PlayerSaveTable.Keys.BuildingParts)
end

function PlayerData:ResetBuildingParts()
	self:SetSaveDataKey(PlayerSaveTable.Keys.BuildingParts, {})
end

local function findBuildingPartIndexByInstanceId(items: Types.BuildingPartArray, instanceId: string): number?
	for i, item in ipairs(items) do
		if item.HousePart.Id == instanceId then
			return i -- 見つかったら配列インデックスを返す
		end
	end
	return nil -- 見つからなかったらnil
end

function PlayerData:RemoveBuildingPart(instanceId: string): boolean
	print("RemoveBuildingPart " .. instanceId)
	local BuildingParts:Types.BuildingPartArray = self:GetBuildingParts()
	local index = findBuildingPartIndexByInstanceId(BuildingParts, instanceId)
	if index then
		table.remove(BuildingParts, index)
		self:SetBuildingParts(BuildingParts)
		return true
	else
		return false
	end
end
----------------------------------------------------------------------------------------------------
function PlayerData:SetFurnitures(parts: Types.HousePartArray)
	self:SetSaveDataKey(PlayerSaveTable.Keys.Furnitures, parts)
	self:UpdateCoinPerSec()
end

function PlayerData:GetFurnitures() : Types.HousePartArray
	return self:GetSaveDataKey(PlayerSaveTable.Keys.Furnitures)
end

function PlayerData:GetFurnituresNum() : Types.HousePartArray
	return #self:GetSaveDataKey(PlayerSaveTable.Keys.Furnitures)
end

function PlayerData:ResetFurnitures()
	self:SetFurnitures({})
end

function PlayerData:GetPlacedItemNum(): number
	return self:GetBuildingPartsNum() + self:GetFurnituresNum()
end

----------------------------------------------------------------------------------------------------
function PlayerData:UpdateCoinPerSec(): number
	local coinPerSec = 0
	for _, housePart:Types.HousePart in self:GetFurnitures() do
		local itemsFolder = ReplicatedStorage:FindFirstChild("Shops")
		local model = itemsFolder:FindFirstChild(housePart.ModelName, true)
		if not model then
			warn("CoinGenerator model not fount")
			continue
		end
		coinPerSec += PriceProvider.GetMoneyRate(model)
	end
	print("coinPerSec=", coinPerSec)
	self:SetAttribute("CoinPerSec", coinPerSec)
	return coinPerSec
end

function PlayerData:GetCoinPerSec():number
	local coinPerSec = self:GetAttribute("CoinPerSec")
	if coinPerSec then
		return coinPerSec
	else
		return self:UpdateCoinPerSec()
	end
end


local function findHousePartIndexByInstanceId(items: Types.HousePartArray, instanceId: string): number?
	for i, item in ipairs(items) do
		if item.Id == instanceId then
			return i -- 見つかったら配列インデックスを返す
		end
	end
	return nil -- 見つからなかったらnil
end

function PlayerData:RemoveFurniture(instanceId: string): boolean
	print("RemoveFurniture " .. instanceId)
	local furnitures:Types.HousePartArray = self:GetFurnitures()
	local index = findHousePartIndexByInstanceId(furnitures, instanceId)
	if index then
		table.remove(furnitures, index)
		self:SetFurnitures(furnitures)
		return true
	else
		return false
	end
end
----------------------------------------------------------------------------------------------------
function PlayerData:GetLastPartColor(partName: string): Color3?
	local RGB = self:GetSaveDataKey3(PlayerSaveTable.Keys.LastColorMaterials, partName, "color")
	if RGB then
		return Color3.fromRGB(RGB.ColorR, RGB.ColorG, RGB.ColorB)
	else
		return nil
	end
end

function PlayerData:SetLastPartColor(partName: string, color: Color3)
	local RGB = {
		ColorR = math.floor(color.R*255),
		ColorG = math.floor(color.G*255),
		ColorB = math.floor(color.B*255),
	}
	self:SetSaveDataKey3(PlayerSaveTable.Keys.LastColorMaterials, partName, "color", RGB)
end

function PlayerData:GetLastPartMaterial(partName: string): string?
	return self:GetSaveDataKey3(PlayerSaveTable.Keys.LastColorMaterials, partName, "material")
end

function PlayerData:SetLastPartMaterial(partName: string, material: string)
	self:SetSaveDataKey3(PlayerSaveTable.Keys.LastColorMaterials, partName, "material", material)
end

----------------------------------------------------------------------------------------------------
function PlayerData:GetPurchasedItems(): {[string]: number}
	return self:GetSaveDataKey(PlayerSaveTable.Keys.PurchasedItems)
end


-- アイテムを追加（個数を1増やす）
function PlayerData:AddPurchasedItem(name: string)
	local items = self:GetPurchasedItems()

	-- nil の場合は新しいテーブルを作る
	if not items then
		items = {}
	end

	-- 個数を1増やす（存在しなければ0から）
	items[name] = (items[name] or 0) + 1

	self:SetSaveDataKey(PlayerSaveTable.Keys.PurchasedItems, items)
end


-- アイテムを削除（個数を1減らす）
function PlayerData:RemovePurchasedItem(name: string)
	local items = self:GetPurchasedItems()
	if not items then
		return
	end

	if items[name] then
		items[name] -= 1

		-- 個数が0以下になったら削除
		if items[name] <= 0 then
			items[name] = nil
		end

		self:SetSaveDataKey(PlayerSaveTable.Keys.PurchasedItems, items)
	end
end

function PlayerData:ResetPurchasedItem()
	self:SetSaveDataKey(PlayerSaveTable.Keys.PurchasedItems, {})
end
----------------------------------------------------------------------------------------------------
function PlayerData:SetProgressFlag(flagKey)
	self:SetSaveDataKey2(PlayerSaveTable.Keys.ProgressFlags, flagKey, true)
end

function PlayerData:ResetProgressFlag(flagKey)
	self:SetSaveDataKey2(PlayerSaveTable.Keys.ProgressFlags, flagKey, nil)
end

function PlayerData:IsProgressFlag(flagKey)
	return self:GetSaveDataKey2(PlayerSaveTable.Keys.ProgressFlags, flagKey)
end

----------------------------------------------------------------------------------------------------
-- GetLoginBonusDays
function PlayerData:GetLoginBonusGotDay()
	return self:GetSaveDataKey(PlayerSaveTable.Keys.LoginBonusGotDay)
end
-- SetLoginBonusGotDay
function PlayerData:SetLoginBonusGotDay(day)
	self:SetSaveDataKey(PlayerSaveTable.Keys.LoginBonusGotDay, day)
end
-- GetLastLoginBonusTime
function PlayerData:GetLastLoginBonusTime()
	return self:GetSaveDataKey(PlayerSaveTable.Keys.LastLoginBonusTime)
end
-- SetLastLoginBonusTime
function PlayerData:SetLastLoginBonusTime(time)
	self:SetSaveDataKey(PlayerSaveTable.Keys.LastLoginBonusTime, time)
end
----------------------------------------------------------------------------------------------------
-- HasCanClaimLoginBonus
function PlayerData:HasCanClaimLoginBonus()
	local lastBonusTime = self:GetLastLoginBonusTime()
	if lastBonusTime == nil then
		return true
	end
	local gotDay = self:GetLoginBonusGotDay()
	if gotDay >= Define.LOGIN_BONUS_MAX_DAY then
		return false
	end

	-- 前回のログインボーナス受け取りから24時間以上経過しているか
	local currentTime = os.time()
	if (currentTime - lastBonusTime) >= Define.LOGIN_BONUS_INTERVAL_TIME then
		return true
	else
		return false
	end
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerData:ListenToLoginBonusGotDayChanged(func)
	self:ListenToSaveDataParam1Changed(PlayerSaveTable.Keys.LoginBonusGotDay, func)
end
----------------------------------------------------------------------------------------------------
-- 
function PlayerData:ListenToMissionStatusListChanged(func)
	self:ListenToSaveDataParam1Changed(PlayerSaveTable.Keys.MissionStatusList, func)
end

----------------------------------------------------------------------------------------------------
-- 
function PlayerData:SetTreasureChestOpenTime(treasureChestName, openTime)
	self:SetSaveDataKey2(PlayerSaveTable.Keys.TreasureChestOpenTimes, treasureChestName, openTime)
end
----------------------------------------------------------------------------------------------------
-- GetTreasureChestOpenTime
function PlayerData:GetTreasureChestOpenTime(treasureChestName)
	return self:GetSaveDataKey2(PlayerSaveTable.Keys.TreasureChestOpenTimes, treasureChestName)
end
----------------------------------------------------------------------------------------------------
-- CanOpenTreasureChest
function PlayerData:CanOpenTreasureChest(treasureChestName)
	local openTime = self:GetTreasureChestOpenTime(treasureChestName)
	if not openTime then
		return true
	end

	local now = os.time()
	local diff = now - openTime
	if diff > ConfigData.TreasureChestInterval then
		return true
	end

	return false
end

----------------------------------------------------------------------------------------------------
-- ミッション向け
----------------------------------------------------------------------------------------------------
-- GetMissionStatus
function PlayerData:GetMissionStatus(key)
	return self:GetSaveDataKey3(PlayerSaveTable.Keys.MissionStatusList, key, PlayerSaveTable.SubKeys.Status)
end
----------------------------------------------------------------------------------------------------
-- SetMissionStatus
function PlayerData:SetMissionStatus(missionKey, status)
	self:SetSaveDataKey3(PlayerSaveTable.Keys.MissionStatusList, missionKey, PlayerSaveTable.SubKeys.Status, status)
end
----------------------------------------------------------------------------------------------------
-- GetMissionLevel
function PlayerData:GetMissionLevel(key)
	return self:GetSaveDataKey3(PlayerSaveTable.Keys.MissionStatusList, key, PlayerSaveTable.SubKeys.Level) or 1
end
----------------------------------------------------------------------------------------------------
-- SetMissionLevel
function PlayerData:SetMissionLevel(missionKey, level)
	self:SetSaveDataKey3(PlayerSaveTable.Keys.MissionStatusList, missionKey, PlayerSaveTable.SubKeys.Level, level)
end
----------------------------------------------------------------------------------------------------
-- HasCanClaimMission
function PlayerData:HasCanClaimMission()
	local missionData = require(ReplicatedFirst.Exdata.MissionData)
	for missionKey, data in pairs(missionData) do
		local status = self:GetMissionStatus(missionKey)
		if status == Define.MissionStatus.CanClaim then
			return true
		end
	end
	return false
end

----------------------------------------------------------------------------------------------------
-- Util系
----------------------------------------------------------------------------------------------------
-- 
function PlayerData:GetCurrentPlayTime()
	local curPlayTime = self:GetPlayerSessionPlayTime()
	local lastPlayTime = self:GetSaveDataKey(PlayerSaveTable.Keys.PlayTime) or 0
	return lastPlayTime + curPlayTime
end
----------------------------------------------------------------------------------------------------
-- Client用Singleton処理
----------------------------------------------------------------------------------------------------
if RunService:IsClient() then
	local ins = BasePlayerData.Get()
	if not ins then
		return PlayerData.new(game.Players.LocalPlayer) :: Types.PlayerData
	end
	return ins
else
	return PlayerData :: Types.PlayerData
end