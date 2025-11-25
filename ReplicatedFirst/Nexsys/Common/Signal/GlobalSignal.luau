local ReplicatedStorage = game:GetService("ReplicatedStorage")
local goodsignal = require(ReplicatedStorage.Packages.goodsignal)
--- @class GlobalSignal : table
local GlobalSignal = {}

local signals_ = {}

----------------------------------------------------------------------------------------------------
-- Globalなシグナル
-- ConnectSignalで接続するだけでListenできる
----------------------------------------------------------------------------------------------------

function GlobalSignal.CreateSignal(eventName)
	if not signals_[eventName] then
		signals_[eventName] = goodsignal.new()
	end
end

function GlobalSignal.ConnectSignal(eventName, fn)
	if not signals_[eventName] then
		GlobalSignal.CreateSignal(eventName)
	end

	if signals_[eventName] then
		return signals_[eventName]:Connect(fn)
	else
		warn("Event not found: " .. eventName)
		return nil
	end
end

function GlobalSignal.DisconnectSignal(connect)
	if connect then
		connect:Disconnect()
		connect = nil
	end
end

function GlobalSignal.FireSignal(eventName, ...)
	if signals_[eventName] then
		signals_[eventName]:Fire(...)
	else
		warn("GlobalSignal not found, then no Listener: " .. eventName)
	end
end

return GlobalSignal