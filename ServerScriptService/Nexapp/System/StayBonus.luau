local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StayBonusData = require(ReplicatedFirst.Exdata.StayBonusData)
local GameUtil = require(ReplicatedFirst.Nexapp.Common.System.GameUtil)
--- @class StayBonus : table
local StayBonus = {}
StayBonus.__index = StayBonus

----------------------------------------------------------------------------------------------------
-- 
function StayBonus.new(...)
	local self = setmetatable({}, StayBonus)
	StayBonus.Init(self, ...)
	return self
end

function StayBonus:Init(gp)
	--- @type GamePlayer
	self.gp = gp
end
----------------------------------------------------------------------------------------------------
-- OnClaim
function StayBonus:OnClaim(level)
	local data = StayBonusData[level]
	if not data then
		warn("StayBonusData not found", level)
		return
	end

	if not self.gp:IsSaveDataLoaded() then
		warn("StayBonus:OnClaim: not savedata loaded", self.gp:GetName())
		return
	end

	local playerData = self.gp:GetPlayerData()
	local listRef = playerData:GetStayBonusClaimedList()

	if listRef[level] then
		warn("Already claimed", level)
		return
	end

	local joinTime = playerData:GetLastLoginTime()
	local elapsed = os.time() - joinTime
	local remainTime = data.Time - elapsed
	if remainTime > 0 then
		warn("Not yet StayBonus Time, cheat?", level, remainTime, self.gp:GetBaseInfoStr())
		return
	end

	local bonus = data.Value
	if data.BonusType == "Coin" then
		self.gp:AddCoin(bonus)
		self.gp:LogEconomySourceEvent("Coin", bonus, self.gp:GetCoin(), nil, "TimeBonus", "TimeBonus Level" .. level)
	else
		local itemType = data.BonusType
		local itemKey = data.Value
		local itemDataSheet = GameUtil.GetEquipItemDataFromItemType(itemType)
		local itemData = itemDataSheet[itemKey]
		if not itemData then
			warn("StayBonus itemData not found", level, itemType, itemKey)
			return false
		end
		self.gp:GetPlayerData():SetOwnedEquipItems(itemType, itemKey, true)
	end

	print("StayBonus Claimed success", level, bonus)

	-- listRef[level] = true
	-- 同期
	playerData:SetStayBonusClaimed(level)

	return true
end

return StayBonus