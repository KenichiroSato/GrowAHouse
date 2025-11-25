local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PlayerCommon = require(ReplicatedFirst.Nexsys.Common.Player.PlayerCommon)
--- @class LocalBasePlayerIns_ : PlayerCommon
local LocalBasePlayerIns_ = {}
LocalBasePlayerIns_.__index = LocalBasePlayerIns_
setmetatable(LocalBasePlayerIns_, PlayerCommon)

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return LocalBasePlayerIns_
function LocalBasePlayerIns_.GetInstance()
	return LocalBasePlayerIns_.instance
end
----------------------------------------------------------------------------------------------------
-- SetInstance
function LocalBasePlayerIns_.SetInstance(ins)
	LocalBasePlayerIns_.instance = ins
end
----------------------------------------------------------------------------------------------------
-- 通常のnew、SingletonInstanceはSetInstanceでセットする
function LocalBasePlayerIns_.new(player : Player)
	local self = setmetatable(PlayerCommon.new(player), LocalBasePlayerIns_)
	LocalBasePlayerIns_.Init(self, player)
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function LocalBasePlayerIns_:Init(player : Player)
	game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
		if self.onCharacterAdded then
			self:onCharacterAdded(character)
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- ここは実装のためにクラステーブルを返す
-- Instanceを使う場合明示的にGetInstance()を呼ぶ
return LocalBasePlayerIns_