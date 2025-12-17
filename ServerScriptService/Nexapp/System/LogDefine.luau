local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local LogDefine = {}

LogDefine.OnboardingFunnel = {
	PlayerLogin = { Step = 1, StepName = "Player Login" },
	FirstTalkEnd = { Step = 2, StepName = "First Talk" },
	FirstBuildComplete = { Step = 3, StepName = "FirstBuildComplete" },
	FirstPurchaseComplete = { Step = 4, StepName = "FirstPurchaseComplete" },
	FirstItemPlaceComplete = { Step = 5, StepName = "FirstItemPlaceComplete" },
}

return LogDefine
