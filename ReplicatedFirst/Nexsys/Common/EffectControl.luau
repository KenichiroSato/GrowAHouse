local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
--- @class EffectControl : table
local EffectControl = {}
EffectControl.__index = EffectControl
----------------------------------------------------------------------------------------------------
-- 特殊なエフェクト再生系は派生クラス作成のイメージ

----------------------------------------------------------------------------------------------------
-- 
function EffectControl.new(...)
	local self = setmetatable({}, EffectControl)
	EffectControl.Init(self, ...)
	return self
end

function EffectControl:Init(param : SystemTypes.EffectParam)
	self.param = param
end

----------------------------------------------------------------------------------------------------
-- PlayEffect
function EffectControl:PlayEffect()
	local effects = ReplicatedStorage:FindFirstChild("Effects")
	local effectPart : Part = effects:FindFirstChild(self.param.EffectName)
	if not effectPart then
		warn("EffectControl:PlayEffect effect not found", self.param.EffectName)
		return
	end

	local ep = effectPart:Clone()
	ep.Position = self.param.Position
	ep.Parent = workspace
	local descs = ep:GetDescendants()
	for _, desc : ParticleEmitter in ipairs(descs) do
		if desc:IsA("ParticleEmitter") then
			desc:Emit(self.param.EmitNum)
		end
		if desc:IsA("Sound") then
			if self.param.SEName then
				if desc.Name == self.param.SEName then
					desc:Play()
				end
			else
				desc:Play()
			end
		end
	end

	Debris:AddItem(ep, self.param.DestroyTime)
end

return EffectControl