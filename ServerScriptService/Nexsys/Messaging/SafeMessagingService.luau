local MessagingService = game:GetService("MessagingService")
--- @class SafeMessagingService : table
local SafeMessagingService = {}
SafeMessagingService.__index = SafeMessagingService
SafeMessagingService.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return SafeMessagingService
function SafeMessagingService.GetInstance()
	return SafeMessagingService.instance
end

function SafeMessagingService.new(...)
	local self = setmetatable({}, SafeMessagingService)
	SafeMessagingService.Init(self, ...)
	SafeMessagingService.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function SafeMessagingService:Init(...)
end
----------------------------------------------------------------------------------------------------
-- リトライ付き購読
function SafeMessagingService:SafeSubscribeAsync(messageKey : string, callback : (message : any) -> ()) : RBXScriptConnection?
	local success, connection = pcall(function()
		return MessagingService:SubscribeAsync(messageKey, callback)
	end)
	if not success then
		return
	end
	return connection
end
----------------------------------------------------------------------------------------------------
-- リトライ付きSubscribe
-- リトライ時間は徐々に伸びていく(1, 2, 4, 8, 16, 32, 64, 128, 256)
function SafeMessagingService:SafeSubscribeWithRetryAsync(messageKey : string, callback : (message : any) -> ()) : RBXScriptConnection?
	local connection = nil
	local tryCount = 10
	local interval = 1
	for i = 1, tryCount do
		local conn = self:SafeSubscribeAsync(messageKey, callback)
		if conn then
			connection = conn
			break
		end
		warn("SafeMessagingService:SafeSubscribe failed, retry. messageKey: " .. messageKey)
		task.wait(interval)
		interval = interval * 2
	end

	-- リトライ含めて失敗した場合エラー
	if not connection then
		error("SafeMessagingService:SafeSubscribeWithRetry failed, messageKey: " .. messageKey .. " tryCount: " .. tryCount)
	end
	return connection
end
----------------------------------------------------------------------------------------------------
-- 
-- function SafeMessagingService:SafePublishAsync(channel : string, message : any)
-- end

----------------------------------------------------------------------------------------------------
if SafeMessagingService.instance == nil then
	SafeMessagingService.new()
end
return SafeMessagingService.instance