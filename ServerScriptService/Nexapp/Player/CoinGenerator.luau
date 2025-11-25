--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

local CoinGenerator = {}
CoinGenerator.__index = CoinGenerator

local function GetCoinPerSec(self)
	return self._gp:GetPlayerData():GetCoinPerSec()
end


function CoinGenerator.new(gp: Types.GamePlayer, amountPerTick: number, interval: number): Types.CoinGenerator
	-- 実体は内部型で構築
	local self = setmetatable({}, CoinGenerator)
	self._gp = gp
	self._amountPerTick = amountPerTick
	self._interval = interval
	self._running = false
	self._thread = nil

	-- 公開型に“上位キャスト”して返す（privateは型上見えなくなる）
	return (self :: any) :: Types.CoinGenerator
end

function CoinGenerator:Start()
	if self._running then return end
	self._running = true

	self._thread = task.spawn(function()
		while self._running do
			self._gp:AddCoin(GetCoinPerSec(self))
			task.wait(self._interval)
		end
	end)
end

function CoinGenerator:Stop()
	self._running = false
end

return CoinGenerator