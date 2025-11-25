local Util = {}
----------------------------------------------------------------------
-- 共通雑多Utility
----------------------------------------------------------------------
function Util.MbSubString(text, endPos)
	-- local byteData = { string.byte(text, 1, #text) }

	-- if byteData[endPos] < 128 then
	-- 	return
	-- end

	local endByte = utf8.offset(text, endPos + 1)
	return string.sub(text, 1, endByte - 1)
end
----------------------------------------------------------------------------------------------------
--
function Util.GetSplitedString(input, delimiter): { string }
	local result = {}
	for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
		if match ~= "" then -- 空の要素をスキップ
			table.insert(result, match)
		end
	end
	return result
end
----------------------------------------------------------------------------------------------------
-- GetSplitedStringByPunctuation
function Util.GetSplitedStringByPunctuation(text): { string }
	local sentences = {}
	-- パターン: 「.」「!」「。」「！」で文章を分割し、それぞれの文章をtrim
	for sentence in string.gmatch(text, "([^.!。！]+)[.!。！]?") do
		sentence = sentence:gsub("^%s+", ""):gsub("%s+$", "") -- 先頭と末尾の空白を削除
		if sentence ~= "" then
			table.insert(sentences, sentence)
		end
	end
	return sentences
end
----------------------------------------------------------------------------------------------------
-- 
function Util.GetSplitedStringByPunctuationUTF8(text)
	local sentences = {}
	local sentence = ""

	for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
		sentence = sentence .. uchar
		-- 「.」「!」「。」「！」で文章を区切る
		if uchar == "." or uchar == "!" or uchar == "。" or uchar == "！" then
			sentence = sentence:gsub("^%s+", ""):gsub("%s+$", "") -- 先頭と末尾の空白を削除
			if sentence ~= "" then
				table.insert(sentences, sentence)
			end
			sentence = ""
		end
	end

	-- 最後の文章を追加
	sentence = sentence:gsub("^%s+", ""):gsub("%s+$", "")
	if sentence ~= "" then
		table.insert(sentences, sentence)
	end

	return sentences
end
----------------------------------------------------------------------------------------------------
-- path_arrayを1つの文字列に変換
function Util.GetPathString(path_array): string
	local path = ""
	for i, v in ipairs(path_array) do
		if i == 1 then
			path = v
		else
			path = path .. "." .. v
		end
	end
	return path
end

----------------------------------------------------------------------------------------------------
-- TableDeepCopy
function Util.MakeTableDeepCopy(t): table
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = Util.MakeTableDeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end
----------------------------------------------------------------------------------------------------
-- TableClear
-- 参照を維持したまま中身を空にする(table = {}では参照アドレスが変わってしまう)
function Util.TableClear(t): table
	for k, _ in pairs(t) do
		t[k] = nil
	end
	return t
end
----------------------------------------------------------------------------------------------------
-- TableDeepCopy
function Util.TableDeepCopy(from, to): table
	for k, v in pairs(from) do
		if type(v) == "table" then
			to[k] = Util.MakeTableDeepCopy(v)
		else
			to[k] = v
		end
	end
	return to
end
----------------------------------------------------------------------------------------------------
-- ShuffleTable
function Util.ShuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end
----------------------------------------------------------------------------------------------------
-- GetMapTableSize
function Util.GetMapTableSize(t): number
	local count = 0
	for _, _ in pairs(t) do
		count = count + 1
	end
	return count
end

return Util
