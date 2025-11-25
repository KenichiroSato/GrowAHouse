local ColorMaterialSetter = {}

local CollectionService = game:GetService("CollectionService")

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SysTypes = require(ReplicatedFirst.Nexsys.Common.Types)

function ColorMaterialSetter.Set(instance: Instance, color: Color3?, material: Enum.Material?, ignoreTag: string? )
	local logStr = ignoreTag and ignoreTag or "nil"
	print("ColorMaterialSetter.Set:".. logStr)
	local function DoSet(part: BasePart, newColor: Color3?, newMaterial: Enum.Material?, ignoreTag: string?)
		if ignoreTag and CollectionService:HasTag(part, ignoreTag) then
			return
		end
		if newColor then
			part.Color = newColor
		end
		if newMaterial then
			part.Material = newMaterial
		end
	end
	if instance:IsA("BasePart") then
		DoSet(instance, color, material, ignoreTag)
	elseif instance:IsA("Model") then
		for _, part in ipairs(instance:GetDescendants()) do
			if part:IsA("BasePart") then
				DoSet(part, color, material, ignoreTag)
			end
		end
	end
end

return ColorMaterialSetter :: SysTypes.ColorMaterialSetter
