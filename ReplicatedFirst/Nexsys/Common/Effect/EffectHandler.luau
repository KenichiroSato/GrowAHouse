local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local InstanceHandler = require(ReplicatedFirst.Nexsys.Common.Instance.InstanceHandler)

--- @class EffectHandler : InstanceHandler
local EffectHandler = {}
EffectHandler.__index = EffectHandler
setmetatable(EffectHandler, InstanceHandler)

----------------------------------------------------------------------------------------------------
-- 
function EffectHandler.new(effect : Model)
	local self = setmetatable(InstanceHandler.new(effect), EffectHandler)
	EffectHandler.Init(self, effect)
	return self
end

function EffectHandler:Init(instance)
end
----------------------------------------------------------------------------------------------------
--- Terminate
function EffectHandler:Terminate()
	self.instance:Destroy()
end
----------------------------------------------------------------------------------------------------
--- 
function EffectHandler:PlayEffect(playSpan : number?)
	self.startTime = tick()
	self.playSpan = playSpan
end
----------------------------------------------------------------------------------------------------
--- IsPlaySpanEnd
function EffectHandler:IsPlaySpanEnd()
	if not self.playSpan then
		return false
	end

	return tick() - self.startTime >= self.playSpan
end

----------------------------------------------------------------------------------------------------
--- SetEnabled
function EffectHandler:SetEnabled(enabled : boolean)
	for _, child in self.instance:GetDescendants() do
		if child:IsA("ParticleEmitter") then
			child.Enabled = enabled
		end
	end
end

return EffectHandler