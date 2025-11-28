local ReplicatedFirst = game:GetService("ReplicatedFirst")
local EventInstType = require(ReplicatedFirst.Nexsys.Common.Data.EventInstType)
local TalkData = require(ReplicatedFirst.Exdata.TalkData)

return {
	Event_FirstPetTalk = {
		-- { EventInstType.PlaySEByName, "WorkerGreeting" },
		{ EventInstType.TalkSequence, "FirstPetTalk" },
		{ EventInstType.SendSignal, "OnFirstPetTalkEnd" },
	},
	Event_FirstTalk = {
		{ EventInstType.DisableProximityPrompt },
		{ EventInstType.LockPlayer },
		{ EventInstType.TalkSequence, "FirstTalk" },
		{ EventInstType.CameraMoveTo, "TalkStartCameraPos", 1.5 },
		{ EventInstType.Wait, 2 },
		{ EventInstType.CameraMoveTo, "UnlockWaterCameraPos", 1.5 },
		{ EventInstType.Wait, 1.5 },
		{ EventInstType.ResetCamera },
		{ EventInstType.UnlockPlayer },
		{ EventInstType.EnableProximityPrompt },
		--{ EventInstType.SendCSRemoteEvent, "OnUnlockWaterZoneTalkEnd" },
	},
}