local Types = {}

export type PlayerManager = {
	GetGamePlayer: (player: Player) -> GamePlayer
}

export type PlayerData = {
	GetCoin: (self: PlayerData) -> number,
	GetPurchasedItems:(self: PlayerData) -> {string},
	GetLastPartColor:(partName: string) -> Color3?,
	GetLastPartMaterial:(partName: string) -> string?,
	GetCoinPerSec:(self: PlayerData) -> number,
}

export type GamePlayer = {
	AddCoin: (self: GamePlayer, val: number) -> (),
	GetCoin: (self: GamePlayer) -> number,
	SubCoin: (self: GamePlayer, val: number) -> boolean,
	
	GetBuildingParts:(self: GamePlayer) -> Types.BuildingPartArray,
	AddBuildingPart:(self: GamePlayer, part: Types.BuildingPart) -> (),
	RemoveBuildingPart: (self: GamePlayer, instanceId: string) -> (),
	AddFurniture: (self: GamePlayer, part: Types.HousePart) -> (),
	GetFurnitures:(self: GamePlayer) -> Types.HousePartArray,
	RemoveFurniture: (self: GamePlayer, instanceId: string) -> (),
	
	GetPurchasedItems:(self:GamePlayer) -> {[string]: number},
	AddPurchasedItem:(self:GamePlayer,name:string) -> (),
	RemovePurchasedItem:(self:GamePlayer,name: string) -> (),
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
	Rel: Types.RelativeCorrdinates,
}

export type HousePartArray = { Types.HousePart }

export type BuildingPart = {
	HousePart: Types.HousePart,
	ColorR: number,
	ColorG: number,
	ColorB: number,
	Material: string,
}

export type BuildingPartArray = { Types.BuildingPart }

export type PopUpParam = {
	Color : Color3,
	IsBold : boolean,
	Scale : number,
	OffsetRange : Vector2,
	PopType : number,
	WorldPos : Vector3,
}

export type TalkParam = {
	ShowTime : number,
	StreamingTime : number,
}

export type PetData = {
	PetKey : string,
	SkillTypes : { string }, 
	SkillLevels : { number },
}

export type SortedPetData = {
	PetId : string,
	PetKey : string,
}

export type MatchingInfo = {
	UserId : number,
	JobId : string,
	Time : number,
	-- Partyの場合のみ
	PartyUserIds : { number },
}

export type PlayerMatchingInfo = {
	MatchingKey : number,
	MatchingGameKey : string,
	MatchingState : number,
}

-- MemoryStoreLockerのロック取得時の情報
export type MemoryStoreLockerInfo = {
	ServerId : string,
	Expiry : number,
}

export type SortedMapItem = {
	key : string,
	sortKey : string,
	value : MatchingInfo,
}

export type MatchedPartyInfo = {
	PartyId : string,
	UserIds : { number },
	JobId : string,
	ReserveServerCode : string,
}


return Types