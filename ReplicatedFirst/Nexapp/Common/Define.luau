local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Define = {}

Define.Versions = {
	Version_1_0 = 20250527,
	Version_1_1 = 20250616,
	Version_1_2 = 20250630,
}

Define.Version = Define.Versions.Version_1_1

Define.BuildingPartFolder = ReplicatedStorage:WaitForChild("BuildingParts")

-- クライアントへのRemoteEvent
-- SystemDefineへ移行
Define.CommonClientEvent = {
	AnnounceTalk = 1,
	Announce = 2,
	ChatTalk = 3,
	FadeOut = 10,
	FadeIn = 11,
	FadeInUI = 13,
	FadeInScreenGUI = 14,
	AdjustCameraToBack = 20,
	TeleportPosition = 25,

	PlayEvent = 30,

	PlayerDied = 40,
	ApplyImpulseByAccelaration = 45,
	OnTouchedToRailPart = 50,

	GuiSetupData = 60,
	HideCoreUIAll = 70,

	LocalEnabledChange = 75,

	PlaySE = 84,
	PlaySEByName = 85,

	SyncSaveData = 90,
	SaveDataLoaded = 99,


	-- RemoteFunction
	PlayEventCallback = 1001,
}

-- サーバーへのRemoteEvent
Define.CommonServerEvent = {
	StartDashMode = 10,
	EndDashMode = 11,
	AreaStreamingRequest = 20,
	ModelPersitantRequest = 22,
}

Define.EventCallbackType = {
	OnEndEvent = 1,
	OnEndCutscene = 10,
	OnStartFadeOut = 20,
}

Define.DEFAULT_FADE_TIME = 2

Define.POP_FADE_TIME = 0.6

Define.SKILL_NUM = 2
Define.MAX_SKILL_LEVEL = 5

Define.SKILL_TYPE_NUM = 5

Define.PET_EQUIP_NUM_MAX = 3

Define.PopUpType = {
	Coin = "Coin",
}

Define.LeaderstatsName = {
	Coin = "Coin",
}

Define.IsTestMode = true
-- Define.IsTestMode = RunService:IsStudio()

Define.MatchingState = {
	SelectMatchingQueue = "SelectMatchingQueue",
	Teleporting = "Teleporting",
}

Define.EquipItemType = {
	Head = "Head",
	Face = "Face",
	Back = "Back",
	Egg = "Egg",
}

Define.SortTypeIndex = {
	Level = 1,
	Name = 2,
	Generation = 3,
}
Define.SortTypeArray = {
	{ Key = "Level", Name = "Level", Index = 1 },
	{ Key = "Name", Name = "Name", Index = 2 },
	{ Key = "Generation", Name = "Generation", Index = 3 },
}

Define.MissionStatus = {
	NotAchieved = 1,
	CanClaim = 2,
	Claimed = 3,
}

-- スキルレベルの確率
Define.SkillLevelRateTable = {
	70, 20, 6, 3, 1

	-- test用 高いものがでやすい版
	-- 1, 3, 6, 20, 70
}
-- レアリティグレードしきい値(出るレート値に合わせてグレードを決める)
Define.RarityGradeRateTh = {
	28,
	1.4,
	0.36,
	0.06,
	0.01,
}

Define.MergePetCoins = {
	0, 
	150, -- 合計Lv2
	300, -- 合計Lv3
	500, -- 合計Lv4
	1000, -- 合計Lv5
	3000, -- 合計Lv6
	10000, -- 合計Lv7
	30000, -- 合計Lv8
	50000, -- 合計Lv9
}

-- ミニゲーム報酬コイン（ランク順）
Define.MiniGameRewards = {
	150, 90, 80, 70, 60, 50, 40, 30, 20, 10
	-- 一時的に倍
	-- 300, 180, 160, 140, 120, 100, 80, 60, 40, 20
}
-- 2025/08/01 00:00:00 (UTC+0)
Define.MiniGameRateUpEndData = 1754006400

Define.GROUP_ID = 35794055
Define.CoinImageId = "rbxassetid://130632497056705"
Define.CoinName = "Coin"

Define.NORMAL_COLOR = Color3.fromRGB(255, 255, 255)
Define.UNKOWN_IMAGE_COLOR = Color3.fromRGB(107, 208, 255)

Define.LOGIN_BONUS_MAX_DAY = 30
Define.LOGIN_BONUS_INTERVAL_TIME = 60 * 60 * 24
-- Define.LOGIN_BONUS_INTERVAL_TIME = 30  -- テスト用

Define.UNDER_WATER_HEIGHT = -16

Define.LimitedMissionWinCounts = {
	1, 30, 100,
}
Define.LimitedMissionItemStockMax = {
	0,
	2500,
	2500,
}
Define.LimitedMissionDecoAuras = {
	"EggItem01", -- くちぱっち通常
	"EggItem56", -- おやすみ(ふわふわ)オーラ
	"EggItem54", -- にじいろオーラ
}
Define.LimitedMissionUGCAssetIds = {
	0,
	-- テストで既存のやつ
	-- 101135963075183,
	-- 134461267378191,

	-- @TODO
	-- 本番
	108632442724036,
	130985813584010,
}

-- 投票系
Define.VotingKeys = {
	Vote_1 = "Vote_1",
	Vote_2 = "Vote_2",
}

-- 一回だけ投票状態
Define.IsOnceVote = true
-- 一回だけ投票: 6/18以降の投票済みなら不可とする
Define.OnceVoteStartTime = 1750172400

Define.PlaceNames = {
	[83948716312312] = "Tokyo Claw Machine",
}

----------------------------------------------------------------------------------------------------
-- マッチング用パラメータ系
Define.MATCHING_CHECK_INTERVAL = 10			-- マッチングキューをチェックしてパーティ構築する間隔
Define.MEMORY_STORE_LOCKER_EXPIRE_TIME = Define.MATCHING_CHECK_INTERVAL + 3 -- Lockの有効時間(チェックより長くして同サーバーがLock維持)
Define.MATCHING_GET_RANGE_NUM = 50			-- マッチングキューから1度に取得する数
Define.MATCHED_PARTY_EXPIRE_TIME = 5		-- マッチパーティのメモリ保持時間
Define.MATCHED_PARTY_CHECK_INTERVAL = 4		-- マッチパーティをチェックする間隔 : ↑の保持期間より短いサイクルで見ないと意味がない
Define.MATCHED_PARTY_CHECKER_GET_RANGE_NUM = 10	-- マッチパーティチェッカーが一度に取得する数
Define.GAME_PLAY_INFO_STORE_EXPIRE_TIME = 60 * 2 -- ゲームプレイ情報のメモリ保持時間
Define.MATCHING_QUEUE_NUM_CHECK_INTERVAL = 6	-- マッチングキュー人数チェック間隔
Define.MATCHING_QUEUE_NUM_EXPIRE_TIME = Define.MATCHING_CHECK_INTERVAL * 2 -- マッチングキュー人数チェックの保持時間
Define.VOTING_COUNT_UPDATE_INTERVAL = 10 -- 投票数更新間隔

Define.IsMatchingDetailLog = false

Define.MemoryStoreVersionStr = "_v2"
Define.MatchingQueueStorePrefix = "MatchingQueue_"
Define.MatchedPartyStorePrefix = "MatchedParty_"

Define.ObbyNames = {
	Obby01 = "Obby01",
	Obby02 = "Obby02",
}

if RunService:IsStudio() then
	-- Define.IsDeactiveCheckMatching = true
	-- Define.IsSingleSelectMatching = true
end

return Define