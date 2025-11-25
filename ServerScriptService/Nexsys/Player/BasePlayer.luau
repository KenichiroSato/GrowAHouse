local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterPlayer = game:GetService("StarterPlayer")
local AnalyticsService = game:GetService("AnalyticsService")
local PlayerCommon = require(ReplicatedFirst.Nexsys.Common.Player.PlayerCommon)
local SystemDefine = require(ReplicatedFirst.Nexsys.Common.SystemDefine)
local Timer = require(ReplicatedFirst.Nexsys.Common.Timer)
local InstanceManager = require(ReplicatedFirst.Nexsys.Common.InstanceManager)
local ServerRemoteEventSender = require(ServerScriptService.Nexsys.ServerRemoteEventSender)
local ServerRemoteSender = require(ServerScriptService.Nexsys.ServerRemoteSender)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local ModelUtil = require(ReplicatedFirst.Nexsys.Common.ModelUtil)
local LogModule = require(ReplicatedFirst.Nexsys.Common.LogModule)
local PlayerSaveData = require(ServerScriptService.Nexsys.Player.PlayerSaveData)

--- @class BasePlayer : PlayerCommon
local BasePlayer = {}
BasePlayer.__index = BasePlayer
setmetatable(BasePlayer, PlayerCommon)

----------------------------------------------------------------------
-- Game用のServer処理Player管理クラス
-- PlayerAddedから生成されてPlayerが抜けるまでインスタンスとして存在する
-- 主にPlayerが持ちたい、処理用のクラスインスタンスなどを管理
----------------------------------------------------------------------
function BasePlayer.new(player : Player)
	local self = setmetatable(PlayerCommon.new(player), BasePlayer)
	BasePlayer.Init(self, player)
	return self
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:Init(player : Player)
	self.Player = player
	self.InSensors = {}
	self.HitIntervals = {}
	-- 状態管理：なんかうまくまとめたい
	self.CharacterAdded = false
	self.isInited = false
	self.dashTimer = Timer.new()
	self.dashRecastTimer = Timer.new()
	self.isDash = false
	self.isSitCallback = false

	-- Charaリセットでリセットするパラメータはこちらの中↓に追加
	self:ResetCharaResetParam()

	--self.Player.RespawnLocation = workspace.SpawnLocation_0

	self:SendStarterGuiInfo()

	local HttpService = game:GetService("HttpService")
	self.sessionId = HttpService:GenerateGUID()
end
----------------------------------------------------------------------------------------------------
-- Terminate
function BasePlayer:Terminate(player : Player)
	if self.onTerminate then
		self:onTerminate(player)
	end
end
----------------------------------------------------------------------------------------------------
-- LoadSaveData
function BasePlayer:LoadSaveData()
	-- セーブデータロード処理
	task.spawn(function()
		-- ここでブロックがかかる
		self.saveData = PlayerSaveData.new(self.Player)
		self.saveData:LoadDataAsync()
		self:OnSaveDataLoaded()
	end)
end
----------------------------------------------------------------------------------------------------
-- TerminateSaveData
function BasePlayer:TerminateSaveData()
	if self.saveData then
		-- Release自体がSaveを呼ぶ。これを呼ぶとスロットリングが発生しやすくなる。
		-- self.saveData:SaveManually()
		self.saveData:ReleaseData()
		local name = self.Player and self.Player.Name
		print("PlayerSaveData released", name)
	end
end
----------------------------------------------------------------------------------------------------
-- OnSaveDataLoaded
function BasePlayer:OnSaveDataLoaded()
	if self.onSaveDataLoaded then
		self:onSaveDataLoaded(self.saveData)
	else
		-- 現状基本必須想定
		warn("onSaveDataLoaded is not defined")
	end
end
----------------------------------------------------------------------------------------------------
-- IsSaveDataLoaded
function BasePlayer:IsSaveDataLoaded()
	return self.saveData and self.saveData:IsLoaded()
end
----------------------------------------------------------------------------------------------------
-- GetSaveData
--- @return PlayerSaveData
function BasePlayer:GetSaveData()
	return self.saveData
end
----------------------------------------------------------------------------------------------------
-- SaveManually
function BasePlayer:SaveManually()
	if self.saveData then
		self.saveData:SaveManually()
	end
end
----------------------------------------------------------------------------------------------------
-- ResetSaveData
function BasePlayer:ResetSaveData()
	if self.saveData then
		self.saveData:ResetSaveData()
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:ResetCharaResetParam()
	self.isCutscenePlaying = false
	self.canControl = true
	self.curEvent = nil
end
----------------------------------------------------------------------------------------------------
-- SetLeaderstatsParam
function BasePlayer:SetLeaderstatsParam(paramName, value)
	local leaderstats = self.Player:FindFirstChild("leaderstats")
	if leaderstats then
		local param = leaderstats:FindFirstChild(paramName)
		if param then
			param.Value = value
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:Update(dt)
	self:UpdateEvent(dt)

	if self.isDash then
		if self.dashTimer:IsEnd() then
			self:OnEndDashMode()
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:UpdateEvent(dt)
	if self.curEvent then
		self.curEvent:Update(dt)

		if self.curEvent:IsEnd() then
			self.curEvent = nil
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:OnCharacterAdded(_player : Player, character : Model)
	self.CharacterAdded = true
	self:ResetCharaResetParam()

	if self.onCharacterAdded then
		self:onCharacterAdded(character)
	end

	if self.isSitCallback then
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Seated:Connect(function(active: boolean, seat: BasePart)
				if active then
					if self.onSitToSeat then
						self:onSitToSeat(seat)
					end
				else
					if self.onStandUpFromSeat then
						-- seatはnilになってるのでややこしいので送らない
						self:onStandUpFromSeat()
					end
				end
			end)
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:OnCharacterAppearanceLoaded(player : Player, chara : Model)
	if self.onCharacterAppearanceLoaded then
		self:onCharacterAppearanceLoaded(chara)
	end
	-- 自動回復はなしに
	-- local regeneHealth = chara:FindFirstChild("Health")
	-- if (regeneHealth and regeneHealth:IsA("Script")) then
	-- 	regeneHealth:Destroy()
	-- end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:OnReadyClient()
	print("OnReadyClient userId=", self:GetUserId())

	-- 一回通ったら初期化済み
	self.isInited = true
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:SitToSeat(seat : Seat)
	local hum = self:GetHumanoid()
	if not hum then
		return
	end
	if seat and hum then
		seat:Sit(hum)
	end
end
----------------------------------------------------------------------
-- 死亡時
----------------------------------------------------------------------
function BasePlayer:OnPlayerDied(player : Player)
	self.CharacterAdded = false

	-- AutoLoad オフの場合ここで復帰が必要

	-- ReplicatedStorage.RemoteEvent.CommonRemoteEvent:FireClient(self.Player, Define.CommonClientEvent.PlayerDied)
end
----------------------------------------------------------------------
-- ゲームを抜けるとき
----------------------------------------------------------------------
function BasePlayer:OnPlayerRemoving(player : Player)
	-- print("BasePlayer:OnPlayerRemoving")
	if self.Terminate then
		self:Terminate(player)
	end
end
----------------------------------------------------------------------
-- センサー処理
----------------------------------------------------------------------
function BasePlayer:OnSensorIn(sensorRange, hitPart : Part, humChara : Model)
	-- RootPartで入ってるレンジ管理
	if hitPart.Name == "HumanoidRootPart" then
		local sensorPart : Part = sensorRange.Part
		local type = sensorPart:GetAttribute("Type")

		if type == "Event" then
			local eventType = sensorRange:GetEventType()
			if eventType then
				local EventManger = require(ServerScriptService.Event.EventManager)
				EventManger.StartEvent(eventType, nil, self.Player)
			end
			-- EventTypeは起動後は再起動しないようにTouchオフ
			sensorPart.CanTouch = false
		elseif type == "ToolDrop" then
			self:RemoveToolAll()
		elseif sensorPart:HasTag("SwimRange") then
			self:StartSwimMode()
		end

		-- 汎用レンジインサウンド
		local inSound = sensorPart:GetAttribute("InSound")
		if inSound then
			if inSound then
				local se = SoundService.SE[inSound]
				if se then
					ReplicatedStorage.RemoteEvent.PlaySoundEvent:FireClient(self.Player, se)
				end
			end
		end
	end
end

function BasePlayer:OnSensorOut(sensorRange, hitPart : Part, humChara : Model)
	-- RootPartで入ってるレンジ管理
	if hitPart.Name == "HumanoidRootPart" then
		local type = sensorRange:GetAttribute("Type")
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:PlayAnimationByAnimationId(animId)
	local animation = Instance.new("Animation")
	animation.AnimationId = "http://www.roblox.com/asset/?id="..animId 
	self:PlayAnimation(animation)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:PlayAnimation(anim : Animation) : AnimationTrack
	local humanoid = self:GetHumanoid()
	if not humanoid then
		return
	end

	-- Ensure that the character's humanoid contains an "Animator" object
	local animator : Animator = humanoid:WaitForChild("Animator")
	-- Load the animation onto the animator
	local animTrack = animator:LoadAnimation(anim)
	-- サーバーだけでやっても効かないっぽい(データでループじゃなくするのが一番確実かつ正しい)
	-- animTrack.Looped = false

	-- Play the animation track
	animTrack:Play()

	return animTrack
end
----------------------------------------------------------------------------------------------------
-- PlayAnimationWithSpan
function BasePlayer:PlayAnimationWithSpan(anim : Animation, span : number) : AnimationTrack
	local animTrack = self:PlayAnimation(anim)
	task.spawn(function()
		task.wait(span)
		animTrack:Stop()
	end)
	return animTrack
end
----------------------------------------------------------------------------------------------------
-- PlayCharacterDefaultAnimation
function BasePlayer:PlayCharacterDefaultAnimation(animName, index : number?) : AnimationTrack
	local idx = index or 1
	local CharacterDefaultAnimData = require(ReplicatedFirst.Data.CharacterDefaultAnimData)
	local anim = Instance.new("Animation")
	anim.AnimationId = CharacterDefaultAnimData[animName][idx].id
	return self:PlayAnimation(anim)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:PlayAnimationOnClient(anim : Animation)
	ReplicatedStorage.RemoteEvent.PlayAnimationRemoteEvent:FireClient(self.Player, anim)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:Announce(textKey, showTime, ...)
	-- ServerRemoteSender.SendEvent(self.Player, SystemDefine.CommonClientEvent.Announce, textKey, showTime)
	-- いったんゲーム的なパケットに移行
	ServerRemoteSender.SendEvent(self.Player, "RSC_Announce", textKey, showTime, ...)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:AnnounceTalk(str, talkerImage, nameText)
	ServerRemoteSender.SendEvent(self.Player,
		SystemDefine.CommonClientEvent.AnnounceTalk, str, talkerImage, nameText)
end
----------------------------------------------------------------------------------------------------
-- SendDevNotification
function BasePlayer:SendDevNotification(text : string)
	ServerRemoteSender.SendEvent(self.Player, SystemDefine.CommonClientEvent.DevNotification, text)
end
----------------------------------------------------------------------
-- 攻撃ヒット時
----------------------------------------------------------------------
function BasePlayer:OnHitAttack(attackCol : Part, damage : number)
	if not self:CanHit(attackCol) then
		return
	end

	self:TakeDamage(damage)
	-- ひとまず固定で3秒あたらないように
	self:RegisterHitInterval(attackCol, 3)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:TakeDamage(damage, hitSe)
	if not self:IsValidChara() then return end

	local hum = self.Player.Character.Humanoid
	if hum then
		hum:TakeDamage(damage)

		-- ダメージリアクション
		-- self:PlayDamageReaction()

		-- if not hitSe then
		-- 	hitSe = SoundService.SE.Hit["Big Blood Damage 1"]
		-- end
		if hitSe then
			ReplicatedStorage.RemoteEvent.PlaySoundEvent:FireClient(self.Player, hitSe)
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:PlayDamageReaction()
	local humanoid = self.Player.Character.Humanoid
	if not humanoid then
		return
	end

	-- Animation再生はモジュールなどにまとめたいが、Clip処理をどうやるか考え中
	-- clipごとのfunctionを作って、それを渡すとか

	-- Ensure that the character's humanoid contains an "Animator" object
	local animator : Animator = humanoid:WaitForChild("Animator")
	-- Load the animation onto the animator
	local anim : Animation = ServerStorage.Animation["LeftLightDamage"]
	local animTrack = animator:LoadAnimation(anim)
	-- サーバーだけでやっても効かないっぽい(データでループじゃなくするのが一番確実かつ正しい)
	animTrack.Looped = false

	-- Play the animation track
	animTrack:Play()
	-- animTrack:AdjustSpeed(5)

	-- If a named event was defined for the animation, connect it to "GetMarkerReachedSignal()"
	animTrack:GetMarkerReachedSignal("Controllable"):Connect(function(paramString)
		print("Controllable ActionEvent : ".. paramString)

		if paramString == "0" then
			humanoid.WalkSpeed = 0
		else
			animTrack:AdjustWeight(0.1, 0.3)
			humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
		end
	end)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:CanHit(collision)
	local intervalTimer = self.HitIntervals[collision]
	if intervalTimer then
		if intervalTimer:IsActive() then
			return false
		else
			return true
		end
	end
	return true
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:RegisterHitInterval(collision, interval)
	local timer = Timer.new()
	timer:StartWithSpan(interval)
	self.HitIntervals[collision] = timer
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:AddToolByName(toolName : string, noAutoEquip : boolean?, addStarterGear : boolean?)
	local myTool : Tool = self:GetToolByName(toolName)
	if not myTool then
		local tool = InstanceManager.CreateToolCloneByName(toolName)
		local chara = self:GetCharacter()
		local hasEquipedTool = chara and chara:FindFirstChildOfClass("Tool")
		if noAutoEquip or hasEquipedTool then
			-- 装備中はBackpackへ追加
			tool.Parent = self.Player.Backpack
		else
			-- 何も装備してない場合装備までする
			tool.Parent = chara
		end

		myTool = tool
	else
		-- もってるならスルー
		warn("already has tool added.", toolName)
	end

	if addStarterGear and myTool then
		self:AddToStarterGear(myTool)
	end
end
----------------------------------------------------------------------------------------------------
-- AddToStarterGear
function BasePlayer:AddToStarterGear(tool : Tool)
	print("AddToStarterGear", tool.Name)
	local clone : Tool = tool:Clone()
	if clone then
		clone.Parent = self.Player.StarterGear
	end
end
----------------------------------------------------------------------------------------------------
-- RemoveToolByName
function BasePlayer:RemoveToolByName(toolName : string, removeFromStarterGear : boolean?)
	local tool = self:GetToolByName(toolName)
	if tool then
		tool:Destroy()
	end

	if removeFromStarterGear then
		self:RemoveToolFromStarterGear(toolName)
	end
end
----------------------------------------------------------------------------------------------------
-- RemoveToolFromStarterGear
function BasePlayer:RemoveToolFromStarterGear(toolName : string)
	print("RemoveToolFromStarterGear", toolName)
	local starterGear = self.Player.StarterGear
	local tool = starterGear and starterGear:FindFirstChild(toolName)
	if tool then
		tool:Destroy()
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:RemoveToolAll()
	if not self:IsValidChara() then return end

	local equipTool : Tool = self.Player.Character:FindFirstChildOfClass("Tool")
	if equipTool then
		equipTool:Destroy()
	end

	local backpack = self:GetBackpack()
	local tools = backpack:GetChildren()
	for index, tool in tools do
		if tool and tool:IsA("Tool") then
			tool:Destroy()
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:UseToolItem(tool : Tool)
	if not self:IsValidChara() then return end

	-- 回復ポーション使用
	if tool.Name == "HealingPotion" then
		local playerChara : Model = self.Player.Character
		if tool.Count.Value >= 1  then
			local humanoid : Humanoid = playerChara.Humanoid
			if humanoid then
				-- 回復
				humanoid.Health = math.min(100, humanoid.Health + 50)

				-- SE
				local se = SoundService.SE.Heal["Success_Sound"]
				ReplicatedStorage.RemoteEvent.PlaySoundEvent:FireClient(self.Player, se)

				-- スタックを減らす
				-- Backpack側に適用
				tool.Count.Value -= 1
				-- SaveData側に適用
				-- ツール自体を削除
				if tool.Count.Value <= 0 then
					tool:Destroy()
				end
			end
		else
			warn("Use Potion failed, no stack")
		end
	end
end
----------------------------------------------------------------------------------------------------
-- UnequipTool
function BasePlayer:UnequipTools()
	local hum = self:GetHumanoid()
	if hum then
		hum:UnequipTools()
	end
end
----------------------------------------------------------------------------------------------------
-- Toolやアクセサリーなど、Charaモデル直下のアイテムが装備されているか
function BasePlayer:IsEquipItem(itemName : string) : boolean
	local chara = self:GetCharacter()
	if chara then
		local item = chara:FindFirstChild(itemName)
		if item then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayer:StartSwimMode()
	warn("StartSwimMode")

	local hum = self:GetHumanoid()
	hum:SetStateEnabled("GettingUp", false)
	hum:ChangeState("Swimming")
end
----------------------------------------------------------------------------------------------------
-- 個人サーバーイベント : 通常はクライアントイベントを使う想定
function BasePlayer:StartServerEvent(eventKey, param)
	local Event = require(ServerScriptService.Event.Event)
	self.curEvent = Event.new(eventKey, param, self.Player, self)
end
----------------------------------------------------------------------------------------------------
-- 個人クライアントイベント
function BasePlayer:PlayEventOnClient(eventKey, param)
	ServerRemoteSender.SendEvent(self.Player, SystemDefine.CommonClientEvent.PlayEvent, eventKey, param)
end
----------------------------------------------------------------------------------------------------
-- 個人クライアントイベント、イベント終わりの戻りつき
function BasePlayer:PlayEventOnClientCallback(eventKey, param) : boolean
	local success, eventResult = pcall(function()
		return ServerRemoteSender.SendFunction(self.Player, SystemDefine.CommonClientEvent.PlayEventCallback, eventKey, param)
	end)
	print("PlayEventOnClientCallback success="..tostring(success))

	if not success then
		warn("PlayEventOnClientCallback failed, eventKey="..eventKey)
		return false
	end

	return eventResult
end
----------------------------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:StartSimpleTalkOnClient(talkKey : string, simpleTalkParam : SystemTypes.SimpleTalkParam)
	ServerRemoteSender.SendEvent(self.Player, SystemDefine.CommonClientEvent.StartSimpleTalk, talkKey, simpleTalkParam)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:PlayCutscene(cutName, eventParam)
	if not self:IsValidChara() then
		 return end

	print("Cutscene ".. cutName .. " play start!!.")
	self.isCutscenePlaying = true
	ReplicatedStorage.RemoteEvent.PlayCutsceneRemoteEvent:FireClient(self.Player, cutName, eventParam)
	local hum = self:GetHumanoid()
	if hum then
		-- 移動禁止
		hum.WalkSpeed = 0
	end
end

function BasePlayer:OnCutsceneEnded()
	self.isCutscenePlaying = false
	local hum = self:GetHumanoid()
	if hum then
		hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
	end
end

function BasePlayer:IsCutscenePlaying()
	return self.isCutscenePlaying
end
----------------------------------------------------------------------------------------------------
-- StartScreenFadeOut
function BasePlayer:StartScreenFadeOut(fadeTime, isWhite)
	ServerRemoteEventSender.Send(self.Player, SystemDefine.CommonClientEvent.FadeOut, fadeTime, isWhite)
end
----------------------------------------------------------------------------------------------------
-- StartScreenFadeIn
function BasePlayer:StartScreenFadeIn(fadeTime, isWhite)
	ServerRemoteEventSender.Send(self.Player, SystemDefine.CommonClientEvent.FadeIn, fadeTime, isWhite)
end
----------------------------------------------------------------------------------------------------
--- StartBGMFadeOut
function BasePlayer:StartBGMFadeOut(fadeTime, isStop)
	ServerRemoteEventSender.Send(self.Player, SystemDefine.CommonClientEvent.BGMFadeOut, fadeTime, isStop)
end
----------------------------------------------------------------------------------------------------
--- StartBGMFadeIn
function BasePlayer:StartBGMFadeIn(fadeTime, isPlay)
	ServerRemoteEventSender.Send(self.Player, SystemDefine.CommonClientEvent.BGMFadeIn, fadeTime, isPlay)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function BasePlayer:SetControllable(val)
	-- これをHumの子どもで管理したほうがよさそう
	self.canControl = val

	local hum = self:GetHumanoid()
	if hum then
		if val then
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
			hum.JumpPower = StarterPlayer.CharacterJumpPower
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight
		else
			hum.WalkSpeed = 0
			hum.JumpPower = 0
			hum.JumpHeight = 0
		end
	end
end

function BasePlayer:CanControl()
	return self.canControl
end
----------------------------------------------------------------------
-- 基本系
----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetBaseInfoStr
function BasePlayer:GetBaseInfoStr()
	local str = "name="..self:GetName()..", userId="..self:GetUserId()
	return str
end

function BasePlayer:PlaySound(se : Sound)
	if se then
		ReplicatedStorage.RemoteEvent.PlaySoundEvent:FireClient(self.Player, se)
	end
end

function BasePlayer:PlayBGM(bgm : Sound)
	if bgm then
		ReplicatedStorage.RemoteEvent.PlaySoundEvent:FireClient(self.Player, bgm, true)
	else
		error("bgm"..bgm.Name.." not found")
	end
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayer:SetRespawnPoint(point : SpawnLocation)
	self.Player.RespawnLocation = point
end
----------------------------------------------------------------------------------------------------
-- SetHeadScale
function BasePlayer:SetHeadScale(scale)
	local hum = self:GetHumanoid()
	if hum then
		local desc = hum:GetAppliedDescription()
		desc.HeadScale = scale
		hum:ApplyDescription(desc)
	end
end

----------------------------------------------------------------------------------------------------
-- SpawnCharacterAsync
function BasePlayer:SpawnCharacterAsync()
	task.spawn(function()
		print("SpawnCharacter ", self.Player)
		self.Player:LoadCharacter()
	end)
end
----------------------------------------------------------------------------------------------------
-- プレイヤーのキャラクターモデル変更
function BasePlayer:ChangeCharacter(templateChara : Model) : Model
	local oldChara = self.Player.Character
	local newChara = workspace.Map.Book.Book:Clone()
	newChara.Name = self.player.Name

	-- この順で処理するのが大事
	self.player.Character = newChara
	newChara.Parent = workspace

	if oldChara then
		newChara:PivotTo(oldChara:GetPivot())
		oldChara:Destroy()
	end

	-- 浮く場合、HumanoidのHipHeightの調整が必要かも
	-- アンカーされてるなら外すなどは必要

	return newChara
end

----------------------------------------------------------------------------------------------------
-- OnAreaStreamingRequest
function BasePlayer:OnAreaStreamingRequest(targetPos : Vector3, keepTime)
	print("OnAreaStreamingRequest start", targetPos, keepTime)
	self.Player:RequestStreamAroundAsync(targetPos)
	task.spawn(function()
		if keepTime then
			local start = tick()
			while true do
				self.Player:RequestStreamAroundAsync(targetPos)
				task.wait()
				if tick() - start > keepTime then
					break
				end
			end
		end
		print("OnAreaStreamingRequest End", targetPos)
	end)
end
----------------------------------------------------------------------------------------------------
-- OnModelPersitantRequest
function BasePlayer:OnModelPersitantRequest(model : Model, keepTime)
	print("OnModelPersitantRequest start", model, keepTime)
	if model then
		model:AddPersistentPlayer(self.Player)
		if keepTime then
			task.spawn(function()
				task.wait(keepTime)
				model:RemovePersistentPlayer(self.Player)
				print("OnModelPersitantRequest End", model)
			end)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SendStarterGuiInfo
function BasePlayer:SendStarterGuiInfo()
	local guis = game.StarterGui:GetChildren()
	local info = {}
	for index, gui in guis do
		info[gui.Name] = #gui:GetDescendants()
	end
	-- print("SendStarterGuiInfo", info)
	ServerRemoteEventSender.Send(self.Player, SystemDefine.CommonClientEvent.GuiSetupData, info)
end
----------------------------------------------------------------------------------------------------
-- PlaySEByName
function BasePlayer:PlaySEByName(seName, interval)
	ServerRemoteEventSender.Send(self.Player, SystemDefine.CommonClientEvent.PlaySEByName, seName, interval)
end
----------------------------------------------------------------------------------------------------
-- SendRemoteEvent
function BasePlayer:SendRemoteEvent(eventKey, ...)
	ServerRemoteSender.SendEvent(self.Player, eventKey, ...)
end
----------------------------------------------------------------------------------------------------
-- SetSitCallbackActive
function BasePlayer:SetSitCallbackActive(val)
	self.isSitCallback = val
end
----------------------------------------------------------------------------------------------------
-- PlayPopUp
function BasePlayer:PlayPopUp(str, popUpType)
	ServerRemoteEventSender.Send(self.Player, "RSC_PlayerPopUp", str, popUpType)
end
----------------------------------------------------------------------------------------------------
-- Game層で実装しているポップアップ表示発行
function BasePlayer:PlayGamePopup(str, popupType, param : SystemTypes.PopUpParam?)
	ServerRemoteSender.SendEvent(self.Player, "OnGamePopup", str, popupType, param)
end
----------------------------------------------------------------------------------------------------
-- PlayBubbleTalk
function BasePlayer:PlayBubbleTalk(text)
	local chara = self:GetCharacter()
	if chara then
		ServerRemoteSender.SendEventToAll("RSC_PlayBubbleTalk", chara, text)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayer:ApplyImpulse(impulse : Vector3)
	ServerRemoteSender.SendEvent(self.Player, "RSC_ApplyImpulse", impulse)
end
----------------------------------------------------------------------------------------------------
-- MassによらないImpulseを与える、ので基本こっちが推奨
function BasePlayer:ApplyImpulseByAccelaration(accel : Vector3)
	ServerRemoteSender.SendEvent(self.Player, "RSC_ApplyImpulseByAccelaration", accel)
end
----------------------------------------------------------------------------------------------------
-- HasGamePassAsync
function BasePlayer:HasGamePassAsync(gamePassId : number) : boolean
	local success, hasGamePass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(self:GetUserId(), gamePassId)
	end)
	if not success then
		warn("UserOwnsGamePassAsync failed", self:GetUserId(), gamePassId)
		return false
	end
	return hasGamePass
end
----------------------------------------------------------------------------------------------------
--- ランダム課金要素があるかの制限チェック
function BasePlayer:HasPaidRandomRestriction()
	local PolicyService = game:GetService("PolicyService")
    local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, self.player)
    if not ok then
        warn("HasPaidRandomRestriction check failed", info)
		-- 変に失敗したものはいったん制限なし扱い
		return false
    end
    return info.ArePaidRandomItemsRestricted
end

----------------------------------------------------------------------------------------------------
-- LogFunnelStepEvent
-- function BasePlayer:LogFunnelStepEvent(stepName : string, param)
-- 	AnalyticsService:LogFunnelStepEvent(self.Player, stepName, "", 1, blockName, {CurCost=curCost, MaxCost=maxCost})
-- end
----------------------------------------------------------------------------------------------------
-- LogOnboardingFunnelStepEvent
function BasePlayer:LogOnboardingFunnelStepEvent(funnelData : SystemTypes.FunnelData, param1, param2, param3)
	LogModule:LogOnboardingFunnelStepEvent(self.Player, funnelData, param1, param2, param3)
end
----------------------------------------------------------------------------------------------------
-- 
function BasePlayer:LogFunnelStepEvent(funnelData : SystemTypes.FunnelStepData, param1, param2, param3)
	LogModule:LogFunnelStepEvent(self.Player, self.sessionId, funnelData, param1, param2, param3)
end
----------------------------------------------------------------------------------------------------
-- LogCustomEvent
function BasePlayer:LogCustomEvent(eventName : string, param1, value : number?)
	LogModule:LogCustomEvent(self.Player, eventName, param1, value)
end
----------------------------------------------------------------------------------------------------
-- LogCustomEventWithParam
function BasePlayer:LogCustomEventWithParams(eventName, param1, param2, param3, _value : number?)
	LogModule:LogCustomEventWithParams(self.Player, eventName, param1, param2, param3, _value)
end
----------------------------------------------------------------------------------------------------
-- LogEconomySourceEvent
function BasePlayer:LogEconomySourceEvent(currencyType : string, getAmount : number, currentAmount : number, sku : string?, param1 : string?, param2 : string?, param3 : string?)
	LogModule:LogEconomySourceEvent(self.Player, currencyType, getAmount, currentAmount, sku, param1, param2, param3)
end
----------------------------------------------------------------------------------------------------
-- LogEconomySinkEvent
function BasePlayer:LogEconomySinkEvent(currencyType : string, useAmount : number, currentAmount : number, sku : string?, param1 : string?, param2 : string?, param3 : string?)
	LogModule:LogEconomySinkEvent(self.Player, currencyType, useAmount, currentAmount, sku, param1, param2, param3)
end

return BasePlayer