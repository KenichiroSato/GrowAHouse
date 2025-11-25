local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local RemoteSender_ = require(ReplicatedFirst.Nexsys.Client.RemoteSender_)

--- @class LogModule : table
local LogModule = {}
LogModule.__index = LogModule
LogModule.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return LogModule
function LogModule.GetInstance()
	return LogModule.instance
end

function LogModule.new(...)
	local self = setmetatable({}, LogModule)
	LogModule.Init(self, ...)
	LogModule.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function LogModule:Init()
end
----------------------------------------------------------------------------------------------------
-- LogFunnelEventWithParams
----------------------------------------------------------------------------------------------------
-- 汎用全パラメータ型
function LogModule:LogOnboardingFunnelStepEvent(player : Player, funnelData : SystemTypes.FunnelData, param1, param2, param3)
	local customFields = nil
	if param1 or param2 or param3 then
		customFields = {
			[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = param1,
			[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = param2,
			[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = param3,
		}
	end
	AnalyticsService:LogOnboardingFunnelStepEvent(player, funnelData.Step, funnelData.StepName, customFields)
end
----------------------------------------------------------------------------------------------------
-- 
function LogModule:LogFunnelStepEvent(player : Player, sessionId, funnelData : SystemTypes.FunnelStepData, param1, param2, param3)
	local customFields = nil
	if param1 or param2 or param3 then
		customFields = {
			[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = param1,
			[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = param2,
			[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = param3,
		}
	end
	AnalyticsService:LogFunnelStepEvent(player, funnelData.FunnelName, sessionId, funnelData.Step, funnelData.StepName, customFields)
end
----------------------------------------------------------------------------------------------------
-- 
function LogModule:LogCustomEvent(player : Player, eventName : string, param1, _value : number?)
	local customFields = {
		[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = param1,
	}
	AnalyticsService:LogCustomEvent(player, eventName, _value, customFields)
end
----------------------------------------------------------------------------------------------------
--- ゲーム内リソース取得イベント
function LogModule:LogEconomySourceEvent(player : Player, currencyType : string, getAmount : number, currentAmount : number, sku : string?, param1 : string?, param2 : string?, param3 : string?)
	if not currentAmount or not getAmount or not currentAmount then
		warn("LogEconomySourceEvent invalid params", currencyType, getAmount, currentAmount)
		return
	end

	local customFields = {
		[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = param1,
		[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = param2,
		[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = param3,
	}
	AnalyticsService:LogEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Source, currencyType, 
		getAmount, currentAmount, Enum.AnalyticsEconomyTransactionType.Gameplay.Name, sku, customFields)
end
----------------------------------------------------------------------------------------------------
--- ゲーム内リソース消費イベント
function LogModule:LogEconomySinkEvent(player : Player, currencyType : string, useAmount : number, currentAmount : number, sku : string?, param1 : string?, param2 : string?, param3 : string?)
	if not currentAmount or not useAmount or not currentAmount then
		warn("LogEconomySinkEvent invalid params", currencyType, useAmount, currentAmount)
		return
	end

	local customFields = {
		[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = param1,
		[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = param2,
		[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = param3,
	}
	AnalyticsService:LogEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Sink, currencyType, 
		useAmount, currentAmount, Enum.AnalyticsEconomyTransactionType.Gameplay.Name, sku, customFields)
end
----------------------------------------------------------------------------------------------------
-- サーバー実装開始
----------------------------------------------------------------------------------------------------
if RunService:IsServer() then
----------------------------------------------------------------------------------------------------
-- 汎用全パラメータ型
function LogModule:LogCustomEventWithParams(player : Player, eventName : string, param1, param2, param3, _value : number?)
	local customFields = {
		[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = param1,
		[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = param2,
		[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = param3,
	}
	AnalyticsService:LogCustomEvent(player, eventName, _value, customFields)
end
----------------------------------------------------------------------------------------------------
-- サーバー実装終了
----------------------------------------------------------------------------------------------------
elseif RunService:IsClient() then
----------------------------------------------------------------------------------------------------
-- クライアント実装開始
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 
function LogModule:LogCustomEventWithParams(eventName : string, param1, param2, param3, _value : number?)
	RemoteSender_.SendEvent("LogCustomEventWithParams", eventName, param1, param2, param3, _value)
end
----------------------------------------------------------------------------------------------------
-- クライアント実装終了
----------------------------------------------------------------------------------------------------
end

----------------------------------------------------------------------------------------------------
if LogModule.instance == nil then
	LogModule.new()
end
return LogModule.instance