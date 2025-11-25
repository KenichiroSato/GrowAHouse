local ReplicatedFirst = game:GetService("ReplicatedFirst")
local LoginBonusData = require(ReplicatedFirst.Exdata.LoginBonusData)
local GameUtil = require(ReplicatedFirst.Nexapp.Common.System.GameUtil)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
--- @class LoginBonus : table
local LoginBonus = {}
LoginBonus.__index = LoginBonus

----------------------------------------------------------------------------------------------------
-- @return LoginBonus
function LoginBonus.new(...)
	local self = setmetatable({}, LoginBonus)
	LoginBonus.Init(self, ...)
	return self
end

---@param gp GamePlayer
function LoginBonus:Init(gp)
	self.gp = gp
end
----------------------------------------------------------------------------------------------------
-- もらえるかどうか
function LoginBonus:CanGetBonus()
	local playerData = self.gp:GetPlayerData()
	local lastBonusTime = playerData:GetLastLoginBonusTime()
	if lastBonusTime == nil then
		return true
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
-- GetNextRemainTime
function LoginBonus:GetNextRemainTime()
	local playerData = self.gp:GetPlayerData()
	local lastBonusTime = playerData:GetLastLoginBonusTime()
	-- 未取得は初回なので待ち時間0
	if lastBonusTime == nil then
		return 0
	end

	-- すべて取得済みならもうないので0
	local gotDay = playerData:GetLoginBonusGotDay()
	if gotDay >= #LoginBonusData then
		return 0
	end

	-- 前回のログインボーナス受け取りからの経過時間で残り時間算出
	local currentTime = os.time()
	local remainTime = math.max(0, Define.LOGIN_BONUS_INTERVAL_TIME - (currentTime - lastBonusTime))
	return remainTime
end
----------------------------------------------------------------------------------------------------
-- OnGetLoginBonus
function LoginBonus:OnGetLoginBonus()
	if not self:CanGetBonus() then
		print("Can't get LoginBonus yet")
		self.gp:Announce("DailyRewadNotYet")
		return false
	end

	local playerData = self.gp:GetPlayerData()
	local getDay = playerData:GetLoginBonusGotDay() + 1

	local data = LoginBonusData[getDay]
	if not data then
		warn("LoginBonusData is nil", getDay)
		return false
	end

	print("Get LoginBonus", getDay, data.BonusType, data.Value)

	if data.BonusType == "Coin" then
		self.gp:AddCoin(data.Value)
		self.gp:LogEconomySourceEvent("Coin", data.Value, self.gp:GetCoin(), nil, "LoginBonus", "Login Day" .. getDay)
	else
		local itemType = data.BonusType
		local itemKey = data.Value
		local itemDataSheet = GameUtil.GetEquipItemDataFromItemType(itemType)
		local itemData = itemDataSheet[itemKey]
		if not itemData then
			warn("LoginBonus itemData not found", getDay, itemType, itemKey)
			return false
		end
		self.gp:GetPlayerData():SetOwnedEquipItems(itemType, itemKey, true)
	end

	playerData:SetLastLoginBonusTime(os.time())
	playerData:SetLoginBonusGotDay(getDay)
	print("Get LoginBonus success: ", getDay, data.BonusType, data.Value)

	return true
end

return LoginBonus