local ReplicatedFirst = game:GetService("ReplicatedFirst")
local MathUtil = require(ReplicatedFirst.Nexsys.Common.MathUtil)
--- @class TurnController : table
local TurnController = {}
TurnController.__index = TurnController

local END_DIFF_RAD = math.rad(5)

----------------------------------------------------------------------------------------------------
--
function TurnController.new(...)
	local self = setmetatable({}, TurnController)
	TurnController.Init(self, ...)
	return self
end

function TurnController:Init(model: Model)
	self.model = model
	self.targetRotY = nil
	self.rotPerSec = math.rad(360)
end
----------------------------------------------------------------------------------------------------
-- UpdateTurn
function TurnController:UpdateTurn(dt: number)
	if not self.targetRotY then
		return
	end


	local curCf = self.model:GetPivot()
	local _, rotY, _ = curCf:ToOrientation()
	local diff = MathUtil.NormalizeAngle(self.targetRotY - rotY)

	if math.abs(diff) < END_DIFF_RAD then
		self.targetRotY = nil
		return
	end

	-- warn("cur", rotY, "target", self.targetRotY, "diff", diff)

	local rot = self.rotPerSec * dt
	if diff < 0 then
		rot = -rot
	end
	self.model:PivotTo(curCf * CFrame.Angles(0, rot, 0))
end
----------------------------------------------------------------------------------------------------
-- SetTargetRotY
function TurnController:SetTargetRotY(rotY: number)
	self.targetRotY = rotY
end
----------------------------------------------------------------------------------------------------
-- 
function TurnController:SetModelTargetRotY(rotY: number)
	-- モデルの向きは-Zが正面なので、Y軸回転を反転
	self.targetRotY = MathUtil.NormalizeAngle(rotY + math.pi)
end

return TurnController
