--- @class LocalizeModule : table
local LocalizeModule = {}

----------------------------------------------------------------------------------------------------
-- GetLocaleId
function LocalizeModule.GetLocaleId(player : Player)
	return player.LocaleId
end

----------------------------------------------------------------------------------------------------
-- IsJp
function LocalizeModule.IsJp(player : Player)
	return LocalizeModule.GetLocaleId(player) == "ja-jp"
end
----------------------------------------------------------------------------------------------------
-- GetLocalizedData
function LocalizeModule.GetLocalizedData(player : Player, data : table, key : string)
	local localeId = LocalizeModule.GetLocaleId(player)
	if localeId == "ja-jp" then
		if data[key.."JP"] then
			return data[key.."JP"]
		end
	end
	return data[key]
end

return LocalizeModule