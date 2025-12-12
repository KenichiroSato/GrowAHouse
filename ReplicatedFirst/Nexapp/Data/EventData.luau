local ReplicatedFirst = game:GetService("ReplicatedFirst")
local EventInstType = require(ReplicatedFirst.Nexsys.Common.Data.EventInstType)
local TalkData = require(ReplicatedFirst.Exdata.TalkData)

local CAMERA1_DURATION = 8.0
local CAMERA2_DURATION = 7.0
local CAMERA_FADE_DURATION = 0.5

return {
	Event_FirstPetTalk = {
		-- { EventInstType.PlaySEByName, "WorkerGreeting" },
		{ EventInstType.TalkSequence, "FirstPetTalk" },
		{ EventInstType.SendSignal, "OnFirstPetTalkEnd" },
	},
	Event_FirstTalk = {
		{ EventInstType.DisableProximityPrompt },
		{ EventInstType.LockPlayer },
		{ EventInstType.HideScreenGUI},
		{ EventInstType.TalkSequence, "FirstTalkWelcome" },
		{ EventInstType.FadeOut, CAMERA_FADE_DURATION},
		{ EventInstType.CameraMoveTo, "TalkStartCameraPos", 0 },
		{ EventInstType.Wait, CAMERA_FADE_DURATION },
		{ EventInstType.FadeIn, CAMERA_FADE_DURATION},
		{ EventInstType.CameraMoveTo, "TalkEndCameraPos", CAMERA1_DURATION },
		{ EventInstType.TalkSequence, "FirstTalkYouCanBuild" },
		{ EventInstType.Wait, 1 },
		{ EventInstType.FadeOut, CAMERA_FADE_DURATION},
		{ EventInstType.CameraMoveTo, "TalkStartCameraPos2", 0 },
		{ EventInstType.Wait, CAMERA_FADE_DURATION },
		{ EventInstType.FadeIn, CAMERA_FADE_DURATION},
		{ EventInstType.CameraMoveTo, "TalkEndCameraPos2", CAMERA2_DURATION },
		{ EventInstType.TalkSequence, "FirstTalkDecolateHome" },
		{ EventInstType.Wait, 1 },
		{ EventInstType.FadeOut, CAMERA_FADE_DURATION},
		{ EventInstType.ResetCamera },
		{ EventInstType.Wait, CAMERA_FADE_DURATION },
		{ EventInstType.FadeIn, CAMERA_FADE_DURATION},
		{ EventInstType.UnlockPlayer },
		{ EventInstType.TalkSequence, "FirstBuild" },
		{ EventInstType.ShowScreenGUI},
		{ EventInstType.EnableProximityPrompt },
		{ EventInstType.Wait, 2 },
		{ EventInstType.SendCSRemoteEvent, "OnFirstTalkEnd" },
	},
	
	Event_FirstBuild = {
		{ EventInstType.DisableProximityPrompt },
		{ EventInstType.LockPlayer },
		{ EventInstType.HideScreenGUI},
		{ EventInstType.TalkSequence, "FirstBuild" },
		{ EventInstType.Wait, 3 },
		{ EventInstType.ShowScreenGUI},
		{ EventInstType.UnlockPlayer },
		{ EventInstType.EnableProximityPrompt },
	}
}