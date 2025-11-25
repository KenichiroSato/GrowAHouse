local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Types = require(ReplicatedFirst.Nexapp.Common.Types)
local TableUtil = require(ReplicatedFirst.Nexsys.Common.Utility.TableUtil)
local TextUtil = require(ReplicatedFirst.Nexsys.Common.Utility.TextUtil)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)

--- @class GameUtil : table
local GameUtil = {}

local tamaCharaTypeMaxCountCache_ = nil

----------------------------------------------------------------------------------------------------
-- GetCoinText
function GameUtil.GetCoinText(coin : number) : string
	-- 3桁カンマ区切りなどもいれる
	return TextUtil.FormatNumberWithCommas(coin)
end
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------
-- Server用
if RunService:IsServer() then
----------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Server用終わり
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------
-- Client用
if RunService:IsClient() then
----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Client用終わり
end
----------------------------------------------------------------------------------------------------

return GameUtil