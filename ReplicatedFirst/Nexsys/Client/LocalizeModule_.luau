local LocalizationService = game:GetService("LocalizationService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local UIUtil = require(ReplicatedFirst.Nexsys.Common.UIUtil)
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)

--- @class LocalizeModule_ : table
local LocalizeModule_ = {}
local Player = game.Players.LocalPlayer
local s_translator = nil

----------------------------------------------------------------------------------------------------
-- 初期化処理 : Asyncだから阻害しないにしないと
-- local translator
-- if not translator then
-- 	local res, t = pcall(function()
-- 		return LocalizationService:GetTranslatorForPlayerAsync(Player)
-- 	end)
-- 	if res then
-- 		warn("LocalizeModule_ :Init", t.LocaleId)
-- 		translator = t
-- 		translator:GetPropertyChangedSignal("LocaleId"):Connect(function()
-- 			print("Player LocaleId changed", translator.LocaleId)
-- 		end)
-- 	end
-- end

----------------------------------------------------------------------------------------------------
-- GetLocaleId
function LocalizeModule_.GetLocaleId()
	return Player.LocaleId
end
----------------------------------------------------------------------------------------------------
-- GetTranslator
function LocalizeModule_.GetTranslatorAsync()
	if s_translator then
		return s_translator
	end

	local res, t = pcall(function()
		return LocalizationService:GetTranslatorForPlayerAsync(Player)
	end)
	if res and t then
		s_translator = t
		s_translator:GetPropertyChangedSignal("LocaleId"):Connect(function()
			print("Player LocaleId changed, translator reset", s_translator.LocaleId)
			s_translator = nil
			-- 必要なときに取り直すのまかせにしてみる
		end)
		return s_translator
	end
	return nil
end

----------------------------------------------------------------------------------------------------
-- IsJp
function LocalizeModule_.IsJp()
	return LocalizeModule_.GetLocaleId() == "ja-jp"
end
----------------------------------------------------------------------------------------------------
-- GetLocalizedData
function LocalizeModule_.GetLocalizedData(data : table, key : string, replaceStrs : {string}?)
	local localeId = LocalizeModule_.GetLocaleId()

	local text
	-- 日本語はデータがあればそちらを優先
	if localeId == "ja-jp" and data[key.."JP"] then
		text = data[key.."JP"]
		if replaceStrs then
			local jpReplcaeStrs = {}
			for k, v in replaceStrs do
				jpReplcaeStrs[k] = LocalizeModule_.GetTranslatorTextAsync(v)
			end
			replaceStrs = jpReplcaeStrs
		end
	end
	if not text then
		text = LocalizeModule_.GetTranslatorTextAsync(data[key])
	end

	if not text then
		text = data[key]
		if not text and data[key.."JP"] then
			warn("Text set only JP, ".. key .. "JP Used: ", data[key.."JP"])
			text = data[key.."JP"]
		end
	end

	if replaceStrs then
		text = UIUtil.ReplaceStrsText(text, replaceStrs)
	end

	return text
end
----------------------------------------------------------------------------------------------------
-- GetLocalizedData
function LocalizeModule_.GetLocalizedArrayData(data : table, key : string, index : number, replaceStrs : {string}?)
	local localeId = LocalizeModule_.GetLocaleId()

	local array
	-- 日本語はデータがあればそちらを優先
	if localeId == "ja-jp" and data[key.."JP"] then
		array = data[key.."JP"]
		if replaceStrs then
			local jpReplcaeStrs = {}
			for k, v in replaceStrs do
				jpReplcaeStrs[k] = LocalizeModule_.GetTranslatorTextAsync(v)
			end
			replaceStrs = jpReplcaeStrs
		end
	end

	if not array then
		array = data[key]
		if not array and data[key.."JP"] then
			warn("Text set only JP, ".. key .. "JP Used: ", data[key.."JP"])
			array = data[key.."JP"]
		end
	end

	local text = array[index]
	if replaceStrs then
		text = UIUtil.ReplaceStrsText(text, replaceStrs)
	end

	return text
end
----------------------------------------------------------------------------------------------------
-- GetLocalizedTextData
function LocalizeModule_.GetLocalizedTextData(textDataKey, strs : table?)
	local TextData = GameDataProvider:GetTextData()
	if not TextData then
		return
	end

	local data = TextData[textDataKey]
	local text = LocalizeModule_.GetLocalizedData(data, "Text", strs)
	return text
end
----------------------------------------------------------------------------------------------------
-- GetTranslatorText
function LocalizeModule_.GetTranslatorTextAsync(text)
	if not text then
		return nil
	end
	-- BubbleTalkは翻訳されない？ようなので翻訳手動適用
	local translator = LocalizeModule_.GetTranslatorAsync()
	if translator then
		return translator:Translate(game, text)
	else
		warn("GetTranslatorTextAsync failed: ", text)
	end
end

return LocalizeModule_