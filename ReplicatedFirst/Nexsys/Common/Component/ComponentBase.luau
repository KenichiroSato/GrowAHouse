local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local GameSystemUtil = require(ReplicatedFirst.Nexsys.Common.GameSystemUtil)
local RemoteSender_ = require(ReplicatedFirst.Nexsys.Client.RemoteSender_)

--- @class ComponentBase : table
local ComponentBase = {}
ComponentBase.__index = ComponentBase

----------------------------------------------------------------------------------------------------
-- 
function ComponentBase.new(...)
	local self = setmetatable({}, ComponentBase)
	ComponentBase.Init(self, ...)
	return self
end

function ComponentBase:Init(ins : PVInstance)
	self.instance = ins
	-- warn("ComponentBase:Init", ins.Name, debug.traceback())
	if RunService:IsStudio() and RunService:IsClient() and workspace.StreamingEnabled then
		if ins:IsA("Model") and ins.ModelStreamingMode == Enum.ModelStreamingMode.Default then
			warn("ModelStreamingMode is Default", ins:GetFullName())
		end
	end
end
----------------------------------------------------------------------------------------------------
--- Terminate
function ComponentBase:Terminate()
	if self.onTerminate then
		self:onTerminate()
	end
end
----------------------------------------------------------------------------------------------------
-- GetInstance
function ComponentBase:GetInstance()
	return self.instance
end
----------------------------------------------------------------------------------------------------
-- GetInstanceName
function ComponentBase:GetInstanceName() : string?
	return self.instance and self.instance.Name
end

----------------------------------------------------------------------------------------------------
-- DestroyInstance
function ComponentBase:DestroyInstance()
	if self.instance then
		self.instance:Destroy()
		self.instance = nil
	end
end
----------------------------------------------------------------------------------------------------
-- GetPosition
function ComponentBase:GetInstancePosition() : Vector3
	return self.instance:GetPivot().Position
end
----------------------------------------------------------------------------------------------------
-- FindDescendant
function ComponentBase:FindDescendant(name : string) : Instance
	return self.instance:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- FindDescendantFrom
function ComponentBase:FindDescendantFrom(ancestor : Instance, name : string) : Instance
	return ancestor:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- SetSteppedActive
function ComponentBase:SetSteppedActive(isActive : boolean)
	if isActive then
		if not self.onSteppedConnection then
			self.onSteppedConnection = RunService.Stepped:Connect(function(time, dt)
				if self.OnStepped then
					self:OnStepped(dt)
				end
			end)
		end
	else
		if self.onSteppedConnection then
			-- print("SetSteppedActive", self.instance.Name, "Disconnect")
			self.onSteppedConnection:Disconnect()
			self.onSteppedConnection = nil
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetHeartbeatActive
function ComponentBase:SetHeartbeatActive(isActive : boolean)
	if isActive then
		if not self.onHeartbeatConnection then
			self.onHeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if self.onHeartbeat then
					self:onHeartbeat(dt)
				end
			end)
		end
	else
		if self.onHeartbeatConnection then
			self.onHeartbeatConnection:Disconnect()
			self.onHeartbeatConnection = nil
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 明示的なDestroyコール時
function ComponentBase:OnDestroyInstance()
	-- warn("ComponentBase:OnDestroyInstance", self.instance.Name)
	self:SetSteppedActive(false)
	self:SetHeartbeatActive(false)
	if self.onDestroyInstance then
		self:onDestroyInstance()
	end
	self:Terminate()
end
----------------------------------------------------------------------------------------------------
-- Instance削除時
function ComponentBase:OnRemoveInstance()
	-- warn("ComponentBase:OnRemoveInstance", self.instance.Name)
	self:SetSteppedActive(false)
	self:SetHeartbeatActive(false)
	if self.onRemoveInstance then
		self:onRemoveInstance()
	end
	self:Terminate()
end
----------------------------------------------------------------------------------------------------
-- MakePromptOnModelPivot
function ComponentBase:MakePromptOnModelPivot(model : Model, offset: Vector3?) : ProximityPrompt
	return GameSystemUtil.MakePromptOnModelPivot(model, offset)
end
----------------------------------------------------------------------------------------------------
-- 
function ComponentBase:MakePromptOnPart(part : BasePart) : ProximityPrompt
	return GameSystemUtil.MakePromptOnPart(part)
end
----------------------------------------------------------------------------------------------------
-- SetSEOnModelPivot
function ComponentBase:SetSEOnModelPivot(model : Model, se : Sound, offset: Vector3?)
	return GameSystemUtil.SetSEOnModelPivot(model, se, offset)
end
----------------------------------------------------------------------------------------------------
-- 
function ComponentBase:SetSEArrayOnModelPivot(model : Model, seArray : {Sound}, offset: Vector3?)
	return GameSystemUtil.SetSoundEffectsOnModelPivot(model, seArray, offset)
end
----------------------------------------------------------------------------------------------------
-- 
function ComponentBase:SetSEArrayByNameOnModelPivot(model : Model, seNames : {string}, offset: Vector3?)
	return GameSystemUtil.SetSoundEffectsByNameOnModelPivot(model, seNames, offset)
end
----------------------------------------------------------------------------------------------------
-- サーバー用関数
----------------------------------------------------------------------------------------------------
if RunService:IsServer() then
local ServerRemoteSender = require(game.ServerScriptService.Nexsys.ServerRemoteSender)
----------------------------------------------------------------------------------------------------
-- SendRemoteEventToClient
function ComponentBase:SendRemoteEventToClient(player : Player, eventType, ...)
	return ServerRemoteSender.SendEvent(player, eventType, ...)
end
----------------------------------------------------------------------------------------------------
-- サーバー用関数終わり
----------------------------------------------------------------------------------------------------
end
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- クライアント用関数
----------------------------------------------------------------------------------------------------
if RunService:IsClient() then
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)

----------------------------------------------------------------------------------------------------
-- 
function ComponentBase:WaitForSaveDataLoaded()
	SystemDataModule_.WaitUntilSaveDataLoaded()
end
----------------------------------------------------------------------------------------------------
-- WaitForDescendant
function ComponentBase:WaitForDescendant(name : string) : Instance
	return GameSystemUtil.WaitForDescendant(self.instance, name)
end
----------------------------------------------------------------------------------------------------
-- SendRemoteFunction
function ComponentBase:SendRemoteFunctionToServer(funcName : string, ...)
	return RemoteSender_.SendFunction(funcName, ...)
end
----------------------------------------------------------------------------------------------------
-- SendRemoteFunction
function ComponentBase:SendRemoteFunctionOnceToServer(funcName : string, ...)
	return RemoteSender_.SendFunctionOnceNoLog(funcName, ...)
end
----------------------------------------------------------------------------------------------------
-- SendRemoteEvent
function ComponentBase:SendRemoteEventToServer(eventName : string, ...)
	return RemoteSender_.SendEvent(eventName, ...)
end
----------------------------------------------------------------------------------------------------
-- 
function ComponentBase:SendRemoteEventToServerWithInterval(eventName : string, interval, ...)
	return RemoteSender_.SendEventWithInterval(eventName, interval, ...)
end

----------------------------------------------------------------------------------------------------
-- クライアント用関数終わり
----------------------------------------------------------------------------------------------------
end
----------------------------------------------------------------------------------------------------

return ComponentBase