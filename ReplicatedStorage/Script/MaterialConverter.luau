local MaterialConverter = {}

MaterialConverter.Materials = {
	--Asphalt =  Enum.Material.Asphalt,
	Basalt  =  Enum.Material.Basalt, --岩
	Brick   =  Enum.Material.Brick,
	--Carpet  =  Enum.Material.Carpet,
	--CeramicTiles = Enum.Material.CeramicTiles,
	--ClayRoofTiles = Enum.Material.ClayRoofTiles,
	Cobblestone   = Enum.Material.Cobblestone,
	--Concrete      = Enum.Material.Concrete,
	--CorrodedMetal = Enum.Material.CorrodedMetal,
	CrackedLava   = Enum.Material.CrackedLava,
	--Fabric        = Enum.Material.Fabric,
	--Granite       = Enum.Material.Granite,
	Grass         = Enum.Material.Grass,
	--Limestone     = Enum.Material.Limestone,
	Marble        = Enum.Material.Marble,
	--Metal         = Enum.Material.Metal,
	Mud           = Enum.Material.Mud,
	Pavement      = Enum.Material.Pavement,
	Pebble        = Enum.Material.Pebble,
	Plastic       = Enum.Material.Plastic,
	--Rock          = Enum.Material.Rock,
	--RoofShingles  = Enum.Material.RoofShingles,
	--Salt          = Enum.Material.Salt,
	--Sand          = Enum.Material.Sand,
	--Sandstone     = Enum.Material.Sandstone,
	--Slate         = Enum.Material.Slate,
	Wood          = Enum.Material.Wood,
	WoodPlanks    = Enum.Material.WoodPlanks,
}

function MaterialConverter.FromStringToEnum(key: string) : Enum.Material
	return MaterialConverter.Materials[key]
end

function MaterialConverter.FromEnumToString(enum: Enum.Material): string
	for key, value in pairs(MaterialConverter.Materials) do
		if value == enum then
			return key
		end
	end
	return "Plastic"
end

return MaterialConverter
