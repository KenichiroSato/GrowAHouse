local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Define = {}


Define.BuildingPartFolder = ReplicatedStorage:WaitForChild("BuildingParts")

-- サーバーへのRemoteEvent
Define.CommonServerEvent = {
	StartDashMode = 10,
	EndDashMode = 11,
	AreaStreamingRequest = 20,
	ModelPersitantRequest = 22,
}

Define.PopUpType = {
	Coin = "Coin",
}

Define.LeaderstatsName = {
	Coin = "Coin",
}

Define.LOGIN_BONUS_MAX_DAY = 30
Define.LOGIN_BONUS_INTERVAL_TIME = 60 * 60 * 24

Define.MAX_PLACED_ITEMS_NUM = 400

return Define