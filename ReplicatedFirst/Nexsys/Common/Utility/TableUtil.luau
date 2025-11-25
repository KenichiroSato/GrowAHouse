local TableUtil = {}

----------------------------------------------------------------------------------------------------
-- TableDeepCopy
function TableUtil.MakeTableDeepCopy(t): table
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = TableUtil.MakeTableDeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end
----------------------------------------------------------------------------------------------------
-- TableDeepCopy
function TableUtil.TableDeepCopy(from, to): table
	for k, v in pairs(from) do
		if type(v) == "table" then
			to[k] = TableUtil.MakeTableDeepCopy(v)
		else
			to[k] = v
		end
	end
	return to
end
----------------------------------------------------------------------------------------------------
-- ShuffleTable
function TableUtil.ShuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end
----------------------------------------------------------------------------------------------------
-- TableClear
-- 参照を維持したまま中身を空にする(table = {}では参照アドレスが変わってしまう)
function TableUtil.TableClear(t): table
	for k, _ in pairs(t) do
		t[k] = nil
	end
	return t
end
----------------------------------------------------------------------------------------------------
-- GetMapTableSize
function TableUtil.GetMapTableSize(t): number
	local count = 0
	for _, _ in pairs(t) do
		count = count + 1
	end
	return count
end
----------------------------------------------------------------------------------------------------
-- 要素がないか
function TableUtil.IsEmpty(t)
	return next(t) == nil
end
----------------------------------------------------------------------------------------------------
-- 要素があるか
function TableUtil.HasElements(t)
	return next(t) ~= nil
end
----------------------------------------------------------------------------------------------------
-- DumpTable
function TableUtil.DumpTable(t, recursive : boolean)
	if not recursive then
		print("===== DumpTable start =====")
	end

	if not t then
		print("===== table is nil, DumpTable end =====")
		return
	end

	for k, v in t do
		if type(v) == "table" then
			TableUtil.DumpTable(v, true)
		else
			print(k, v)
		end
	end

	if not recursive then
		print("===== DumpTable end =====")
	end
end

return TableUtil
