local RunService = game:GetService("RunService")
local HumanoidPathMove = {}
HumanoidPathMove.__index = HumanoidPathMove

----------------------------------------------------------------------------------------------------
function HumanoidPathMove.new(...)
	local self = setmetatable({}, HumanoidPathMove)
	HumanoidPathMove.Init(self, ...)
	return self
end

function HumanoidPathMove:Init(ins : Model, pathFolder : Folder, isLoop, isCheckXZDistOnly : boolean?)
	self.pointFolder = pathFolder
	self.moveIns = ins
	self.isLoop = isLoop
	self.connectUpdate = nil
	self.FinishedEvent = Instance.new("BindableEvent")
	self.isCheckXZDistOnly = isCheckXZDistOnly
	-- 距離による移動完了判定距離(最低1くらいは必要、1でMoveFinishedイベント発火と同じくらいなので、セーフティならそれより大きく)
	self.moveFinishedLen = 1.5

	self.pointNum = #pathFolder:GetChildren()
end
----------------------------------------------------------------------------------------------------
function HumanoidPathMove:Start()
	self.currentIndex = 1

	self.connectUpdate = RunService.Stepped:Connect(function(time, deltaTime)
		self:Update(deltaTime)
	end)

	self.finishedConnect = self.moveIns.Humanoid.MoveToFinished:Connect(function(reached)
		-- print("changeToNext by Finished Event")
		self:changeToNext()
	end)
end
----------------------------------------------------------------------------------------------------
function HumanoidPathMove:Stop()
	if self.connectUpdate then
		self.connectUpdate:Disconnect()
		self.connectUpdate = nil
	end
	if self.finishedConnect then
		self.finishedConnect:Disconnect()
		self.finishedConnect = nil
	end
end
----------------------------------------------------------------------------------------------------
-- IsActive
function HumanoidPathMove:IsActive()
	return self.connectUpdate ~= nil
end
----------------------------------------------------------------------------------------------------
function HumanoidPathMove:GetNextIndex()
	if self.isLoop then
		return self.currentIndex % self.pointNum + 1 
	else
		return math.min(self.currentIndex + 1, self.pointNum)
	end
end
----------------------------------------------------------------------------------------------------
function HumanoidPathMove:Update(_dt)
	local hum = self.moveIns:FindFirstChildOfClass("Humanoid")
	if not hum then
		warn("HumanoidPathMove: hum is nil, stop")
		self:Stop()
		return
	end
	local rootHeight = hum.HipHeight + hum.RootPart.Size.Y / 2
	local rootPos = self.moveIns:GetPivot().Position - Vector3.new(0, rootHeight, 0)
	local targetPart : Part = self.pointFolder[tostring(self.currentIndex)]
	local diff = targetPart.Position - rootPos
	if self.isCheckXZDistOnly then
		diff = Vector3.new(diff.X, 0, diff.Z)
	end

	-- print("path len", diff.Magnitude, diff)
	if diff.Magnitude <= self.moveFinishedLen then
		-- print("changeToNext by length")
		self:changeToNext()
		-- 次に更新
		if self:IsActive() then
			targetPart = self.pointFolder[tostring(self.currentIndex)]
		end
	end

	if self:IsActive() then
		hum:MoveTo(targetPart.Position)
	end
end
----------------------------------------------------------------------------------------------------
-- checkNext
function HumanoidPathMove:changeToNext()
	local lastIndex = self.currentIndex
	self.currentIndex = self:GetNextIndex()
	if lastIndex == self.currentIndex then
		-- 終了
		self.FinishedEvent:Fire()
		self:Stop()
	end
end

----------------------------------------------------------------------------------------------------

return HumanoidPathMove
