local TextUtil = {}
----------------------------------------------------------------------------------------------------
-- @brief {str1} {str2} のようなテキストを置換
function TextUtil.ReplaceStrsText(text : string, strs : table) : string
	for i, str in ipairs(strs) do
		text = string.gsub(text, "{str" .. i .. "}", str)
	end
	return text
end
----------------------------------------------------------------------------------------------------
-- @brief strsに自分で置換したい文字列をマップでいれて置換
function TextUtil.ReplaceStrsMapText(text: string, strs: {string} )
	for key, value in pairs(strs) do
		text = string.gsub(text, key, value)
	end
	return text
end
----------------------------------------------------------------------------------------------------
-- @brief 数字の3桁ごとにカンマを挿入
function TextUtil.FormatNumberWithCommas(num : number) : string
	local numStr = tostring(num)
	local len = string.len(numStr)
	local ret = ""
	local cnt = 0
	for i = len, 1, -1 do
		ret = string.sub(numStr, i, i) .. ret
		cnt = cnt + 1
		if cnt % 3 == 0 and i > 1 then
			ret = "," .. ret
		end
	end
	return ret
end
----------------------------------------------------------------------------------------------------
-- @brief 数字を 1k, 1M, 1B, 1T などの表記に変換
function TextUtil.FormatNumberWithUnit(num : number) : string
	-- 単位区切りのN倍まではそのまま表示
	local stayRate = 100
	if num < 1000  * stayRate then
		return tostring(math.round(num))
	end
	if num < 10000 * stayRate then
		return string.format("%.1fK", num / 1000)
	end
	if num < 10000000 * stayRate then
		return string.format("%.1fM", num / 1000000)
	end
	if num < 10000000000 * stayRate then
		return string.format("%.1fB", num / 1000000000)
	end
	return string.format("%.1fT", num / 1000000000000)
end

return TextUtil