--!strict

local UserInputService = game:GetService("UserInputService")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SysTypes = require(ReplicatedFirst.Nexsys.Common.Types)

local SingleTapDetector_ = {}
SingleTapDetector_.__index = SingleTapDetector_

local TOUCH_TAP_THRESHOLD = 10 -- ピクセル移動量のしきい値

-- ユーティリティ: 任意の Gamepad? を判定
local function isGamepadInputType(inputType: Enum.UserInputType): boolean
	return inputType.Value >= Enum.UserInputType.Gamepad1.Value
		and inputType.Value <= Enum.UserInputType.Gamepad8.Value
end

-- 「決定」相当として扱うキー（必要に応じて拡張可）
local GAMEPAD_CONFIRM_KEYS: {Enum.KeyCode} = {
	Enum.KeyCode.ButtonR2, -- Xbox/Nintendo系の決定/X(PSでは×がマップされてButtonA相当)
}

local function isConfirmKeycode(keyCode: Enum.KeyCode): boolean
	for _, k in ipairs(GAMEPAD_CONFIRM_KEYS) do
		if keyCode == k then
			return true
		end
	end
	return false
end

-- インスタンス生成
function SingleTapDetector_.new() : SysTypes.SingleTapDetector_
	local self = setmetatable({}, SingleTapDetector_)
	self._tapCallback = nil :: ((InputObject) -> ())?
	self._touchStartPos = nil :: Vector3?
	self._inputBeganConn = nil :: RBXScriptConnection?
	self._inputEndedConn = nil :: RBXScriptConnection?
	self._inputBegan = false
	return self :: SysTypes.SingleTapDetector_
end

function SingleTapDetector_:Start(callback: (InputObject) -> ())
	self:Stop() -- すでに動いてたら一度解除

	self._tapCallback = callback

	self._inputBeganConn = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		-- タッチの開始位置を記録
		if gameProcessed then return end
		self._inputBegan = true
		if input.UserInputType == Enum.UserInputType.Touch then
			self._touchStartPos = input.Position
		end
	end)

	self._inputEndedConn = UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then return end

		local inputType = input.UserInputType
		local isClick = inputType == Enum.UserInputType.MouseButton1
		local isTouch = inputType == Enum.UserInputType.Touch
		local isGamepad = isGamepadInputType(inputType)

		-- マウス：左クリックの離しで発火
		if self._inputBegan and isClick and self._tapCallback then
			self._tapCallback(input)
			self._inputBegan = false
			return
		end

		-- タッチ：移動距離がしきい値未満ならタップとして発火
		if self._inputBegan and isTouch and self._touchStartPos then
			local endPos = input.Position
			local distance = (endPos - self._touchStartPos).Magnitude
			if distance < TOUCH_TAP_THRESHOLD and self._tapCallback then
				self._tapCallback(input)
			end
			self._touchStartPos = nil
			self._inputBegan = false
			return
		end

		-- ゲームパッド：決定キー（ButtonAなど）の離しで発火
		if self._inputBegan and isGamepad and isConfirmKeycode(input.KeyCode) and self._tapCallback then
			self._tapCallback(input)
			self._inputBegan = false
			return
		end
	end)
end

function SingleTapDetector_:Stop()
	if self._inputBeganConn then
		self._inputBeganConn:Disconnect()
		self._inputBeganConn = nil
	end
	if self._inputEndedConn then
		self._inputEndedConn:Disconnect()
		self._inputEndedConn = nil
	end
	self._tapCallback = nil
	self._touchStartPos = nil
	self._inputBegan = false
end

return SingleTapDetector_ :: SysTypes.SingleTapDetector_