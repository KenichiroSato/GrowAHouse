local data = {}

data.Keys = {
	BuildingParts = "BuildingParts",
	Furnitures = "Furnitures",
	LastColorMaterials = "LastColorMaterials",
	PlayTime = "PlayTime",
	PurchasedItems = "PurchasedItems",
	LastLoginTime = "LastLoginTime",
	StayBonusClaimedList = "StayBonusClaimedList",
	Coin = "Coin",
	ProgressFlags = "ProgressFlags",
	LoginBonusGotDay = "LoginBonusGotDay",
	LastLoginBonusTime = "LastLoginBonusTime",
}

data.SubKeys = {
	Status = "Status",
	Level = "Level",
}

data.ResetVersion = 20250526

data.Template = {
	Version = 20250526,
	[data.Keys.BuildingParts] = {
		-- {id="ChairA", rel = { -- BaseCF座標系
		--   px=0, py=0, pz=0, rx=0, ry=90, rz=0
		-- }, s=1}
	},
	[data.Keys.Furnitures] = {
		
	},
	[data.Keys.LastColorMaterials] = {
		--["Wall"] =  {
		--	["color"] = {
		--		["ColorB"] = 255,
		--		["ColorG"] = 221,
		--		["ColorR"] = 175
		--	},
		--	["material"] = "Rock"
		--}
	},
	[data.Keys.PlayTime] = 0,
	[data.Keys.PurchasedItems] = {
		--"Sofa" = 1,
	},
	
	[data.Keys.LastLoginTime] = 0,
	[data.Keys.StayBonusClaimedList] = {
		-- [Level] = true,
	},
	[data.Keys.Coin] = 500,
	[data.Keys.ProgressFlags] = {
		-- [FlagKey] = true,
	},
	[data.Keys.LoginBonusGotDay] = 0,
	[data.Keys.LastLoginBonusTime] = 0,

}

return data