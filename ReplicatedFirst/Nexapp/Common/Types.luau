local Types = {}

export type PlayerManager = {
	GetGamePlayer: (player: Player) -> GamePlayer
}

export type PlayerData = {
	Init: (self: PlayerData, player: Player) -> (),
	StartOnClient: (self: PlayerData) -> (),
	Destroy: (self: PlayerData) -> (),
	SetPlayerLoginTime: (self: PlayerData) -> (),
	GetPlayerLoginTime: (self: PlayerData) -> number?,
	GetPlayerSessionPlayTime: (self: PlayerData) -> number,
	HasCanClaimStayBonus: (self: PlayerData) -> boolean,
	IsDevMode: (self: PlayerData) -> boolean?,
	SetDevMode: (self: PlayerData, val: boolean) -> (),
	IsDashMode: (self: PlayerData) -> boolean?,
	SetDashMode: (self: PlayerData, val: boolean) -> (),
	GetPlayTime: (self: PlayerData) -> number,
	SetPlayTime: (self: PlayerData, val: number) -> (),
	GetLastLoginTime: (self: PlayerData) -> number?,
	SetLastLoginTime: (self: PlayerData, val: number) -> (),
	SetStayBonusClaimed: (self: PlayerData, level: any) -> (),
	ClearStayBonusClaimedList: (self: PlayerData) -> (),
	GetStayBonusClaimedList: (self: PlayerData) -> any,
	GetCoin: (self: PlayerData) -> number,
	SetCoin: (self: PlayerData, val: number) -> (),
	GetCoinText: (self: PlayerData) -> string,
	SetBuildingParts: (self: PlayerData, parts: BuildingPartArray) -> (),
	GetBuildingParts: (self: PlayerData) -> BuildingPartArray,
	GetBuildingPartsNum: (self: PlayerData) -> number,
	ResetBuildingParts: (self: PlayerData) -> (),
	RemoveBuildingPart: (self: PlayerData, instanceId: string) -> boolean,
	SetFurnitures: (self: PlayerData, parts: HousePartArray) -> (),
	GetFurnitures: (self: PlayerData) -> HousePartArray,
	GetFurnituresNum: (self: PlayerData) -> number,
	ResetFurnitures: (self: PlayerData) -> (),
	GetPlacedItemNum: (self: PlayerData) -> number,
	UpdateCoinPerSec: (self: PlayerData) -> number,
	GetCoinPerSec: (self: PlayerData) -> number,
	RemoveFurniture: (self: PlayerData, instanceId: string) -> boolean,
	GetLastPartColor: (self: PlayerData, partName: string) -> Color3?,
	SetLastPartColor: (self: PlayerData, partName: string, color: Color3) -> (),
	GetLastPartMaterial: (self: PlayerData, partName: string) -> string?,
	SetLastPartMaterial: (self: PlayerData, partName: string, material: string) -> (),
	GetPurchasedItems: (self: PlayerData) -> {[string]: number},
	GetPurchasedItemsNum: (self: PlayerData) -> number,
	AddPurchasedItem: (self: PlayerData, name: string) -> (),
	RemovePurchasedItem: (self: PlayerData, name: string) -> (),
	ResetPurchasedItem: (self: PlayerData) -> (),
	SetProgressFlag: (self: PlayerData, flagKey: string) -> (),
	ResetProgressFlag: (self: PlayerData, flagKey: string) -> (),
	IsProgressFlag: (self: PlayerData, flagKey: string) -> any,
	GetLoginBonusGotDay: (self: PlayerData) -> any,
	SetLoginBonusGotDay: (self: PlayerData, day: any) -> (),
	GetLastLoginBonusTime: (self: PlayerData) -> any,
	SetLastLoginBonusTime: (self: PlayerData, time: any) -> (),
	HasCanClaimLoginBonus: (self: PlayerData) -> boolean,
	ListenToLoginBonusGotDayChanged: (self: PlayerData, func: (any) -> ()) -> (),
	ListenToMissionStatusListChanged: (self: PlayerData, func: (any) -> ()) -> (),
	SetTreasureChestOpenTime: (self: PlayerData, treasureChestName: string, openTime: number) -> (),
	GetTreasureChestOpenTime: (self: PlayerData, treasureChestName: string) -> number?,
	CanOpenTreasureChest: (self: PlayerData, treasureChestName: string) -> boolean,
	GetMissionStatus: (self: PlayerData, key: string) -> any,
	SetMissionStatus: (self: PlayerData, missionKey: string, status: any) -> (),
	GetMissionLevel: (self: PlayerData, key: string) -> number,
	SetMissionLevel: (self: PlayerData, missionKey: string, level: number) -> (),
	HasCanClaimMission: (self: PlayerData) -> boolean,
	GetCurrentPlayTime: (self: PlayerData) -> number,
}

export type GamePlayer = {
	AddCoin: (self: GamePlayer, val: number) -> (),
	GetCoin: (self: GamePlayer) -> number,
	SubCoin: (self: GamePlayer, val: number) -> boolean,
	
	GetBuildingParts:(self: GamePlayer) -> BuildingPartArray,
	AddBuildingPart:(self: GamePlayer, part: BuildingPart) -> (),
	RemoveBuildingPart: (self: GamePlayer, instanceId: string) -> (),
	AddFurniture: (self: GamePlayer, part: HousePart) -> (),
	GetFurnitures:(self: GamePlayer) -> HousePartArray,
	RemoveFurniture: (self: GamePlayer, instanceId: string) -> (),
	
	GetPurchasedItems:(self:GamePlayer) -> {[string]: number},
	AddPurchasedItem:(self:GamePlayer,name:string) -> (),
	RemovePurchasedItem:(self:GamePlayer,name: string) -> (),
	
	GetPlayerData:(self: GamePlayer) -> PlayerData,
}

export type ColorSelectMenu ={
	GetInstance:() -> ColorSelectMenu,
	ShowAsync:(self:ColorSelectMenu) -> Color3?,
	LastColor:(self:ColorSelectMenu) -> Color3,
	Cancel:(self:ColorSelectMenu) -> (),
}

export type MaterialSelectMenu = {
	GetInstance:() -> MaterialSelectMenu,
	ShowAsync:(self:MaterialSelectMenu) -> Enum.Material,
	LastMaterial:(self:MaterialSelectMenu) -> Enum.Material,
	Cancel:(self:MaterialSelectMenu) -> (),
}

export type CoinGenerator = {
	Start: (self: CoinGenerator) -> ()
}

export type BuildItem = {
	Id: string,
	Name: string, 
	Position: Vector3, 
	YawRadian: number,
}

export type RelativeCoordinates = {
	px:number,
	py:number,
	pz:number,
	rx:number, 
	ry:number,
	rz:number,
}

export type HousePart = {
	Id: string,
	ModelName: string,
	Rel: RelativeCoordinates,
}

export type HousePartArray = { HousePart }

export type BuildingPart = {
	HousePart: HousePart,
	ColorR: number,
	ColorG: number,
	ColorB: number,
	Material: string,
}

export type BuildingPartArray = { BuildingPart }


return Types