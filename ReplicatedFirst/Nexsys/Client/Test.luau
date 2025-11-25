--- @class Test : table
local Test = {}
Test.__index = Test
Test.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return Test
function Test.GetInstance()
	return Test.instance
end

function Test.new(...)
	local self = setmetatable({}, Test)
	Test.Init(self, ...)
	Test.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function Test:Init(...)
	-- branch test
end

return Test