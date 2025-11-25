local SystemTypes = {}

export type JoinData = {
	SourceGameId : number,			-- テレポート元のGameId
	SourcePlaceId : number,			-- テレポート元のPlaceId
	ReferredByPlayerId : number,	-- 招待したプレイヤーのPlayerId
	Members : { number },			-- メンバーのUserId配列
	TeleportData : any,				-- テレポートデータ
	LaunchData : string,			-- 起動データ
	GameJoinContext : table,		-- ゲーム参加コンテキスト
}

export type MemoryStoreGetRangeItem = {
	key : string,
	value : any,
	sortKey : any,
}

export type OrderedDataStoreData = {
	key : string,
	value : number,
}

export type EventParam = {
	Talker : Model,
	TalkEndTime : number,
}

export type TalkParam = {
	TextKey : string,
	Text : string,
	TalkerModel : Model,
	Image : string,
	Name : string,
	IsWaitInput : boolean,
	TalkTime : number,
	AutoDistanceHide : boolean,
}

export type SimpleTalkParam = {
	TalkerModel : Model?,
	EndTime : number?,
}

export type FriendInfo = {
	DisplayName : string,
	Id : number,
	IsOnline : boolean,
	Username : string,
}

export type FriendInfos = {
	Friends : { FriendInfo },
}

export type PopUpParam = {
	Color : Color3,
	IsBold : boolean,
	Scale : number,
	OffsetRange : Vector2,
	OffsetScaleRangeMinMax : { Vector2 }, -- min, maxを設定
	PopType : number,
	ImageId : string,

	-- 散らばりアニメ演出
	IsScatterAnim : boolean,
	ScatterAnimTargetPos : Vector2,
}

export type EffectParam = {
	EffectName : string,
	Position : Vector3,
	EmitNum : number,
	DestroyTime : number,
	SEName : string,
}

export type TalkParam = {
	ShowTime : number,
	StreamingTime : number,
}

-- ランキングリーダーボード用データ定義
export type RankingInfo = {
	Key : string,
	DBName : string,
	IsAscending : boolean?,
	RankTitle : string,
	RankNum : number?,
	GetNum : number?,
	StartDelay : number?,
	UpdateInterval : number?,
}

-- オーダードデータストア用データ定義
export type OrderedSaveDataInfo = {
	Key : string,
	DBName : string,
	IsAscending : boolean?,
	GetNum : number?,
	StartDelay : number?,
	UpdateInterval : number?,
}

export type FunnelData = {
	Step : number,
	StepName : string,
}

export type OnBoardingFunnelData = {
	Step : number,
	StepName : string,
}

export type FunnelStepData = {
	FunnelName : string,
	Step : number,
	StepName : string,
}

export type CustomEventData = {
	Name : string,
	Value : number,
	CustomField01 : string,
	CustomField02 : string,
	CustomField03 : string,
}

export type TabGuiInfo = {
	Frame : Frame,
	Button : GuiButton?,
	IsPrimary : boolean?,
	-- GuiObject_継承の実装クラス(Optional)
	FrameHandler : table?,
}

return SystemTypes
