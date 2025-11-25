local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SelfieMode = require(ReplicatedStorage:WaitForChild("SelfieMode"))

--- @class SelfieModeModule_ : table
local SelfieModeModule_ = {}

----------------------------------------------------------------------------------------------------
-- OpenSelfieMode
function SelfieModeModule_.OpenSelfieMode()
	SelfieMode.openSelfieMode()
end

----------------------------------------------------------------------------------------------------
-- CloseSelfieMode
function SelfieModeModule_.CloseSelfieMode()
	SelfieMode.closeSelfieMode()
end

----------------------------------------------------------------------------------------------------
-- SetHudButtonEnabled
function SelfieModeModule_.SetHudButtonEnabled(enabled : boolean)
	SelfieMode.setHudButtonEnabled(enabled)
end
----------------------------------------------------------------------------------------------------
-- IsSelfieModeOpen()
function SelfieModeModule_.IsSelfieModeOpen()
	return SelfieMode.isSelfieModeOpen()
end

----------------------------------------------------------------------------------------------------
-- SetHudButtonPosition、とかを実装予定

return SelfieModeModule_