local SystemDefine = {}

-- クライアントへのRemoteEvent
SystemDefine.CommonClientEvent = {
	AnnounceTalk = 1, --done
	Announce = 2, --done
	DevNotification = 3,

	FadeOut = 10, --done
	FadeIn = 11, --done
	FadeInUI = 13, --done
	FadeInScreenGUI = 14, --done
	AdjustCameraToBack = 20,
	TeleportPosition = 25, --done

	PlayEvent = 30, --done
	StartSimpleTalk = 31, --done

	PlayerDied = 40,
	ApplyImpulseByAccelaration = 45,
	OnTouchedToRailPart = 50, --done

	StartPopUpWithWorldPos = 54,
	PlayPlayerPopUp = 55, --done
	PlayPopUp = 56,

	GuiSetupData = 60, -- done
	HideCoreUIAll = 70,

	LocalEnabledChange = 75, --done

	SyncParams = 80, --done
	GameSyncParams = 82,

	PlaySE = 84, --done
	PlaySEByName = 85, --done
	BGMFadeOut = 86,
	BGMFadeIn = 87,

	SyncSaveData = 90, --done
	SaveDataLoaded = 99, --done

	----------------------------------------------------------------------------------------------------
	-- RemoteFunction
	PlayEventCallback = 1001, --done
}

SystemDefine.DEFAULT_FADE_TIME = 2
SystemDefine.DEFAULT_TALK_TIME = 4

SystemDefine.TalkerType = {
	Player = "Player",
	Npc = "Npc",
}

return SystemDefine