local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local PlayerSaveTable = require(ReplicatedFirst.Nexapp.Common.System.PlayerSaveTable)
local InstanceManager = require(ReplicatedFirst.Nexsys.Common.InstanceManager)
local GameUtil = require(ReplicatedFirst.Nexapp.Common.System.GameUtil)
local ComponentManager = require(ReplicatedFirst.Nexapp.Common.System.ComponentManager)
local ConfigData = require(ReplicatedFirst.Exdata.ConfigData)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

local ServerScriptService = game:GetService("ServerScriptService")
local BasePlayer = require(ServerScriptService.Nexsys.Player.BasePlayer)
local LoginBonus = require(ServerScriptService.Nexapp.System.LoginBonus)
local StayBonus = require(ServerScriptService.Nexapp.System.StayBonus)
local OrderedSaveDataManager = require(ServerScriptService.Nexsys.OrderedSaveDataManager)
local CoinGenerator = require(ServerScriptService.Nexapp.Player.CoinGenerator)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaveDataLoadedEvent = ReplicatedStorage:WaitForChild("BindableEvent"):WaitForChild("SaveDataLoadedEvent")
local remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvent")

local function StartCutScene(self, player: Player)
	-- Play a short property overview cutscene on the client (3 seconds)
	local success, basePart = pcall(function()
		local HouseBaseManager = require(ServerScriptService:WaitForChild("Nexapp"):WaitForChild("House"):WaitForChild("HouseBaseManager"))
		return HouseBaseManager.GetBase(player)
	end)
	if success and basePart then
		self:SendRemoteEvent("CutSceneFirstTalk")
	end
end

--- @class GamePlayer : BasePlayer
local GamePlayer = {}
GamePlayer.__index = GamePlayer
setmetatable(GamePlayer, BasePlayer)
----------------------------------------------------------------------------------------------------
--
function GamePlayer.new(player: Player)
	local self = setmetatable(BasePlayer.new(player), GamePlayer)
	GamePlayer.Init(self, player)
	return self
end

function GamePlayer:Init(player: Player)

	self.playerData = PlayerData.new(player)
	self.saveLoadStartTime = tick()
	self:LoadSaveData()

	--self:SetRespawnPoint(workspace.Map.SpawnLocation)

	self.startTime = os.time()

	local loginBonus = LoginBonus.new(self)
	self.loginBonus = loginBonus
	---@type StayBonus
	self.stayBonus = StayBonus.new(self)
	
	self.coinGenerator = CoinGenerator.new(self, 10, 1) :: Types.CoinGenerator

	player.Chatted:Connect(function(message, recipient)
		local DebugCommand = require(ServerScriptService.Nexapp.Debug.DebugCommand)
		DebugCommand.Process(player, message, recipient)
	end)

end
----------------------------------------------------------------------------------------------------
-- Terminate
function GamePlayer:onTerminate(player : Player)
	self:RecordPlayTime()


	if RunService:IsStudio() then
		-- 終了が遅くなるのでスキップ
		warn("GamePlayer:Terminate skipped on studio", player)
		return
	end

	self:TerminateSaveData()
end
----------------------------------------------------------------------------------------------------
-- onCharacterAdded
function GamePlayer:onCharacterAdded(_chara: Model)
	-- print("GamePlayer:onCharacterAdded", self.Player)
	-- _chara:AddTag("ModelComp")

	InstanceManager.CreateComponentInstance(_chara)
	self:SetCollisionGroup("Character")

end
----------------------------------------------------------------------------------------------------
-- onCharacterAppearanceLoaded
function GamePlayer:onCharacterAppearanceLoaded(_char: Model) end
----------------------------------------------------------------------------------------------------
--- @param saveDataIns PlayerSaveData
function GamePlayer:onSaveDataLoaded(saveDataIns)
	local loadTime = tick() - self.saveLoadStartTime
	print("onSaveDataLoaded", self:GetName(), loadTime)
	local player = self:GetPlayer()
	self.playerData:SetSaveDataIns(saveDataIns)

	-- セーブデータResetVersionより前ならリセット
	local curVer = self.playerData:GetSaveDataVersion()
	if curVer then
		if tonumber(curVer) < PlayerSaveTable.ResetVersion then
			warn("SaveData Reset", player, curVer, PlayerSaveTable.ResetVersion)
			self:SendDevNotification("SaveData Reset, Please relogin")
			self:ResetSaveData()
			task.wait(3)
			self.Player:Kick("SaveData Reset, Please relogin")
			return
		end
	else
		warn("SaveData Version not set", player, curVer)
	end

	-- パラメータ初期化
	self:SetCoin(self.playerData:GetCoin())

	self.playerData:SetLastLoginTime(os.time())
	self.playerData:ClearStayBonusClaimedList()
	--self.playerData:ResetBuildingParts()
	--self.playerData:ResetFurnitures()
	--self.playerData:ResetPurchasedItem()
	SaveDataLoadedEvent:Fire(player)
	
	self.coinGenerator:Start()

	StartCutScene(self, player)
end
----------------------------------------------------------------------------------------------------
--
function GamePlayer:OnPlayerDied(player: Player)
	BasePlayer.OnPlayerDied(self, player)
	if not Players.CharacterAutoLoads then
		self:SpawnCharacterAsync()
	end
end
----------------------------------------------------------------------------------------------------
-- RecordPlayTime
function GamePlayer:RecordPlayTime()
	local curPlayTime = os.time() - self.startTime
	local totalPlayTime = self.playerData:GetPlayTime() + curPlayTime
	self.playerData:SetPlayTime(totalPlayTime)
end
----------------------------------------------------------------------------------------------------
-- Update
function GamePlayer:Update(dt)
	BasePlayer.Update(self, dt)

	-- self:UpdateDebugInfo()
end
----------------------------------------------------------------------------------------------------
-- OnHeartbeat
function GamePlayer:OnHeartbeat(dt)
end
----------------------------------------------------------------------------------------------------
-- GetPlayerData
function GamePlayer:GetPlayerData()
	return self.playerData
end

----------------------------------------------------------------------------------------------------
-- 以下コンテンツ実装系
----------------------------------------------------------------------------------------------------
-- SetCoin
function GamePlayer:SetCoin(val: number)
	self.playerData:SetCoin(val)
	self:SetLeaderstatsParam(Define.LeaderstatsName.Coin, val)
end
-- GetCoin
function GamePlayer:GetCoin()
	return self.playerData:GetCoin()
end
-- AddCoin
function GamePlayer:AddCoin(val: number)
	local newVal = self:GetCoin() + val
	self:SetCoin(newVal)
	--[[
	if val > 0 then
		self:PlaySEByName("CoinGet")

		local coinText = GameUtil.GetCoinText(val)
		self:PlayGamePopup("+"..coinText, Define.PopUpType.Coin)
	end
	]]
end
-- SubCoin
function GamePlayer:SubCoin(val: number) : boolean
	local curVal = self:GetCoin()
	if curVal < val then
		return false
	end
	local newVal = curVal - val
	self:SetCoin(newVal)
	return true
end
----------------------------------------------------------------------------------------------------

function GamePlayer:AddBuildingPart(part: Types.BuildingPart)
	local currentParts = self:GetBuildingParts()
	table.insert(currentParts, part)
	self.playerData:SetBuildingParts(currentParts)
end

function GamePlayer:GetBuildingParts(): Types.BuildingPartArray
	return self.playerData:GetBuildingParts()
end

function GamePlayer:RemoveBuildingPart(instanceId: string)
	local removed = self.playerData:RemoveBuildingPart(instanceId)
end
----------------------------------------------------------------------------------------------------

function GamePlayer:AddFurniture(part: Types.HousePart)
	local currentParts = self:GetFurnitures()
	table.insert(currentParts, part)
	self.playerData:SetFurnitures(currentParts)
end

function GamePlayer:GetFurnitures(): Types.HousePartArray
	return self.playerData:GetFurnitures()
end

function GamePlayer:RemoveFurniture(instanceId: string)
	local removed = self.playerData:RemoveFurniture(instanceId)
end
----------------------------------------------------------------------------------------------------

function GamePlayer:GetPurchasedItems(): {string}
	return self.playerData:GetPurchasedItems()
end

function GamePlayer:AddPurchasedItem(name:string)
	self.playerData:AddPurchasedItem(name)
end

function GamePlayer:RemovePurchasedItem(name: string)
	self.playerData:RemovePurchasedItem(name)
end

----------------------------------------------------------------------------------------------------
-- 以下コンテンツコールバック系実装
----------------------------------------------------------------------------------------------------
-- OnDashChanged
function GamePlayer:OnDashChanged()
	-- print("OnDashChanged")
	self.playerData:SetDashMode(not self.playerData:IsDashMode())
end

----------------------------------------------------------------------------------------------------
-- OnLoginBonusClaimed
function GamePlayer:OnLoginBonusClaimed()
	-- print("OnLoginBonusClaimed")

	local result = self.loginBonus:OnGetLoginBonus()
	return result
end
----------------------------------------------------------------------------------------------------
-- OnTimeBonusClaim
function GamePlayer:OnTimeBonusClaim(level)
	-- print("OnTimeBonusClaim", self:GetName())

	return self.stayBonus:OnClaim(level)
end
----------------------------------------------------------------------------------------------------

return GamePlayer
