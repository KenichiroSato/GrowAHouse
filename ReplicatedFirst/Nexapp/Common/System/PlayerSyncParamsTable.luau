local data = {}

data.Keys = {
	DashMode = "DashMode",
	NoAutoMatchingMode = "NoAutoMatchingMode",
	StayBonusClaimedList = "StayBonusClaimedList",
}

data.Template = {
	[data.Keys.DashMode] = false,
	[data.Keys.NoAutoMatchingMode] = false,
	[data.Keys.StayBonusClaimedList] = {},
}

return data