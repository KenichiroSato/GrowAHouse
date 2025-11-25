local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterPlayer = game:GetService("StarterPlayer")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local Timer = require(ReplicatedFirst.Nexsys.Common.Timer)
local AnimationModule = require(ReplicatedFirst.Nexsys.Common.AnimationModule)

local Player = game.Players.LocalPlayer
local playingAnimTrack_ = nil

local function GetHumanoid()
	if Player.Character then
		return Player.Character:FindFirstChildOfClass("Humanoid")
	end
end

--- @class LocalBasePlayer_ : table
local LocalBasePlayer_ = {}
LocalBasePlayer_.__index = LocalBasePlayer_
LocalBasePlayer_.instance = nil

LocalBasePlayer_.JumpTriggeredEvent = Instance.new("BindableEvent")
LocalBasePlayer_.LastPosition = nil
LocalBasePlayer_.CurrentPosition = nil

local railMove_
local railMoveIntervalTimer_ = Timer.new()
local railMoveAnimTrack_

----------------------------------------------------------------------------------------------------
-- 
function LocalBasePlayer_.new(...)
	local self = setmetatable({}, LocalBasePlayer_)
	LocalBasePlayer_.Init(self, ...)

	assert(not LocalBasePlayer_.instance, "LocalBasePlayer_ is singleton")
	LocalBasePlayer_.instance = self

	return self
end

function LocalBasePlayer_:Init(...)
end

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_:Start()
	print("LocalBasePlayer_ Start")

	-- CharacterAddedはStarterCharacterScriptsから呼ぶことで漏れない＆多重にならないように

	-- 入力検出
	UserInputService.JumpRequest:Connect(function()
		LocalBasePlayer_.JumpTriggeredEvent:Fire()
		-- SoundService.SE.jump:Play()
	end)

	-- UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	-- 	-- ダッシュ
	-- 	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftShift then
	-- 		ReplicatedStorage.RemoteEvent.CommonServerEvent:FireServer(Define.CommonServerEvent.StartDashMode)
	-- 	end
	-- end)
	-- UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	-- 	-- ダッシュ
	-- 	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftShift then
	-- 		ReplicatedStorage.RemoteEvent.CommonServerEvent:FireServer(Define.CommonServerEvent.EndDashMode)
	-- 	end
	-- end)
end
----------------------------------------------------------------------
-- Update
----------------------------------------------------------------------
function LocalBasePlayer_.UpdatePrePhysics()
	local chara = Player.Character
	if chara then
		LocalBasePlayer_.LastPosition = LocalBasePlayer_.CurrentPosition
		LocalBasePlayer_.CurrentPosition = chara:GetPivot().Position
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.UpdateRailMove()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not railMove_ or not hum then
		return
	end

	if railMove_:IsEnd() or hum.Jump then
		LocalBasePlayer_.StopRailMove()
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.OnPlayAnimation(anim : Animation)
	local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
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
	-- ひとまず今使ってるやつ全般が遅いので
	animTrack:AdjustSpeed(1.3)

	-- -- If a named event was defined for the animation, connect it to "GetMarkerReachedSignal()"
	-- animTrack:GetMarkerReachedSignal("Controllable"):Connect(function(paramString)
	-- 	print("Controllable ActionEvent : ".. paramString)

	-- 	local gp = PlayerManager.GetGamePlayerByCharacter(chara)
	-- 	if paramString == "0" then
	-- 		gp:SetControllable(false)
	-- 	else
	-- 		animTrack:AdjustWeight(0.1, 0.3)
	-- 		gp:SetControllable(true)
	-- 	end
	-- end)
end
----------------------------------------------------------------------------------------------------
-- PlayDefaultAnimation : Animateスクリプトの下にあるアニメーションを再生
function LocalBasePlayer_.PlayDefaultAnimation(animName : string)
	local chara = LocalBasePlayer_.GetCharacterAsync()
	if not chara then
		return
	end

	local anim
	local animate = chara:FindFirstChild("Animate")
	if animate then
		local animStr = animate:FindFirstChild(animName)
		if animStr then
			anim = animStr:FindFirstChildOfClass("Animation")
		end
	end
	if not anim then
		warn("PlayDefaultAnimation : "..animName.." is not found")
		return
	end

	playingAnimTrack_ = AnimationModule.PlayAnimationWithModel(chara, anim)
end
----------------------------------------------------------------------------------------------------
-- PlayEmoteAnimation : 
function LocalBasePlayer_.PlayEmoteAnimation(animName : string)
	LocalBasePlayer_.PlayDefaultAnimation(animName)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.TeleportPosition(cf : CFrame)
	if Player.Character then
		Player.Character:PivotTo(cf)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.SetMoveEnable(val)
	local hum = LocalBasePlayer_.GetHumanoid()
	if hum then
		hum.WalkSpeed = val and StarterPlayer.CharacterWalkSpeed or 0
	end
end

function LocalBasePlayer_.ChangeHumanoidState(state : Enum.HumanoidStateType)
	local hum = LocalBasePlayer_.GetHumanoid()
	if hum then
		hum:ChangeState(state)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.StartRailMove(railPart : Part)
	local RailMove = require(ReplicatedFirst.Nexsys.Common.RailMove)
	railMove_ = RailMove.new(Player.Character, railPart.Parent)
	-- railMove_.yOfs = LocalBasePlayer_.GetHipHeight()
	railMove_:StartWithPart(railPart)
	LocalBasePlayer_.SetMoveEnable(false)
	local hum = LocalBasePlayer_.GetHumanoid()
	if hum then
		railMoveAnimTrack_ = AnimationModule.PlayAnimationByAnimationId(hum, 14878267239, true)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.StopRailMove()
	railMove_:Stop()
	railMove_ = nil
	LocalBasePlayer_.SetMoveEnable(true)
	railMoveIntervalTimer_:StartWithSpan(0.5)

	if railMoveAnimTrack_ then
		railMoveAnimTrack_:Stop()
		railMoveAnimTrack_ = nil
	end
end
----------------------------------------------------------------------
-- func StartAttachToPart
function LocalBasePlayer_.StartAttachToPart(part : Part, isPlatformStanding : boolean)
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end

	local weld = Instance.new("WeldConstraint", hum.RootPart)
	weld.Part0 = part
	weld.Part1 = hum.RootPart
	weld.Name = "AttachToPart"

	-- if isPlatformStanding then
	-- 	-- hum.PlatformStand = true

	-- 	hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	-- 	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	-- 	-- hum:SetStateEnabled(Enum.HumanoidStateType., false)
	-- end

	-- local attach = Instance.new("Attachment")
	-- attach.Parent = part
	-- local attach2 = Instance.new("Attachment")
	-- attach2.Parent = hum.RootPart

	-- local joint = Instance.new("BallSocketConstraint")
	-- joint.Parent = part
	-- joint.Attachment0 = attach
	-- joint.Attachment1 = attach2
	-- joint.LimitsEnabled = true
	-- joint.TwistLimitsEnabled = true
	-- joint.TwistLowerAngle = -30
	-- joint.TwistUpperAngle = 30
	-- joint.UpperAngle = 30
	-- joint.LowerAngle = -30
end
function LocalBasePlayer_.EndAttachToPart()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end

	local weld = hum.RootPart:FindFirstChildOfClass("WeldConstraint")
	if weld and weld.Name == "AttachToPart" then
		weld:Destroy()
	end
end
----------------------------------------------------------------------------------------------------
-- 
function LocalBasePlayer_.SetEnableFalling(val : boolean)
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end

	hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, val)
end

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.OnTouchedToMoveRail(hitPart : Part, railPart : Part)
	-- すでにレール移動中
	if railMove_ then
		return
	end
	if railMoveIntervalTimer_:IsActive() then
		-- warn("railmove interval")
		return
	end

	LocalBasePlayer_.StartRailMove(railPart)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.IsRailMoving()
	if railMove_ then
		return true
	end
end
----------------------------------------------------------------------------------------------------
-- Characterを同期で取得
function LocalBasePlayer_.GetCharacterAsync() : Model
	return Player.Character or Player.CharacterAdded:Wait()
end
----------------------------------------------------------------------------------------------------
-- IsCharacter()
function LocalBasePlayer_.IsCharacter()
	return Player.Character ~= nil
end
----------------------------------------------------------------------------------------------------
-- GetUserId
function LocalBasePlayer_.GetUserId()
	return Player.UserId
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.GetHumanoid()
	if Player.Character then
		local hum = Player.Character:FindFirstChildOfClass("Humanoid")
		return hum
	end
end

function LocalBasePlayer_.GetHumanoidRootPart() : Part
	local hum = LocalBasePlayer_.GetHumanoid()
	if hum then
		return hum.RootPart
	end
end
----------------------------------------------------------------------------------------------------
-- GetRootHeight
function LocalBasePlayer_.GetRootHeight()
	local hipHeight = LocalBasePlayer_.GetHipHeight()
	local hrp = LocalBasePlayer_.GetHumanoidRootPart()
	if hipHeight and hrp then
		return hrp.Size.Y * 0.5 + hipHeight
	end
	return 0
end

----------------------------------------------------------------------------------------------------
-- GetHipHeight
function LocalBasePlayer_.GetHipHeight()
	local hum = LocalBasePlayer_.GetHumanoid()
	if hum then
		return hum.HipHeight
	end
	return 0
end
----------------------------------------------------------------------------------------------------
-- GetPosition
function LocalBasePlayer_.GetPosition()
	if Player.Character then
		return Player.Character:GetPivot().Position
	end
end
----------------------------------------------------------------------------------------------------
-- GetPivot
function LocalBasePlayer_.GetPivot() : Part
	if Player.Character then
		return Player.Character:GetPivot()
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.GetRootAttachmentAsync() : Attachment
	local chara = LocalBasePlayer_.GetCharacterAsync()
	local rootPart = chara:WaitForChild("HumanoidRootPart")
	if rootPart then
		return rootPart:WaitForChild("RootAttachment")
	end
end
----------------------------------------------------------------------------------------------------
-- IsAlive
function LocalBasePlayer_.IsAlive()
	if LocalBasePlayer_.IsDead() then
		return false
	end
	return true
end
----------------------------------------------------------------------------------------------------
-- IsDead()
function LocalBasePlayer_.IsDead()
	local hum = LocalBasePlayer_.GetHumanoid()
	if hum then
		if hum:GetState() == Enum.HumanoidStateType.Dead then
			return true
		end
		if hum.Health <= 0 then
			return true
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.GetLastMove() : Vector3
	if LocalBasePlayer_.LastPosition and LocalBasePlayer_.CurrentPosition then
		return LocalBasePlayer_.CurrentPosition - LocalBasePlayer_.LastPosition
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.SetCFrame(cf : CFrame)
	if Player.Character then
		Player.Character:PivotTo(cf)
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.ApplyImpulse(impulse : Vector3)
	if Player.Character then
		Player.Character.HumanoidRootPart:ApplyImpulse(impulse)
	end
end
----------------------------------------------------------------------------------------------------
-- ApplyImpulseByAccelaration
function LocalBasePlayer_.ApplyImpulseByAccelaration(accel : Vector3)
	local mass = LocalBasePlayer_.GetMass()
	LocalBasePlayer_.ApplyImpulse(accel * mass)
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function LocalBasePlayer_.OnTeleportPosition(cf : CFrame)
	if LocalBasePlayer_.IsRailMoving() then
		LocalBasePlayer_.StopRailMove()
	end

	local chara = Player.Character
	if chara then
		chara:PivotTo(cf)
	end
end
----------------------------------------------------------------------------------------------------
-- onSeatActiveChanged
function LocalBasePlayer_.onSeatActiveChanged(active, seat : Seat | VehicleSeat)
end
----------------------------------------------------------------------------------------------------
-- onStartSeating
function LocalBasePlayer_.onStartSeating(seat : Seat | VehicleSeat)
	-- 明示的なパケットフローでやる


	-- if seat:IsA("VehicleSeat") then
	-- 	local vehicleModel = seat.Parent :: Model
	-- 	local controlType 
	-- 	if seat:HasTag("Flying") then
	-- 		FlyingVehicleController_.StartControl(vehicleModel, seat)
	-- 	elseif seat:HasTag("Hover") then
	-- 		HoverVehicleController_.StartControl(vehicleModel, seat)
	-- 	else
	-- 		HoverVehicleController_.StartControl(vehicleModel, seat)
	-- 	end
	-- end
end
----------------------------------------------------------------------------------------------------
-- onEndSeating
function LocalBasePlayer_.onEndSeating(seat : Seat | VehicleSeat)
	print("onEndSeating")
end
----------------------------------------------------------------------------------------------------
-- IsInAir
function LocalBasePlayer_.IsInAir()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end

	return hum:GetState() == Enum.HumanoidStateType.Freefall
end
----------------------------------------------------------------------------------------------------
-- IsMovingState
function LocalBasePlayer_.IsRunning()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end

	return hum:GetState() == Enum.HumanoidStateType.Running
end
----------------------------------------------------------------------------------------------------
-- IsMoving
function LocalBasePlayer_.IsMoving()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end

	local state = hum:GetState()
	return state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Walking or state == Enum.HumanoidStateType.Freefall
end
----------------------------------------------------------------------------------------------------
-- IsEquipTool
function LocalBasePlayer_.IsEquipTool(toolName : string)
	local chara = Player.Character
	if not chara then
		return false
	end
	local equipTool : Tool = chara:FindFirstChild(toolName)
	if equipTool and equipTool.Name == toolName then
		return true
	end
	return false
end
----------------------------------------------------------------------------------------------------
-- GetEquipTool
function LocalBasePlayer_.GetEquipTool(toolName : string) : Tool
	local chara = Player.Character
	if not chara then
		return nil
	end
	return chara:FindFirstChild(toolName)
end
----------------------------------------------------------------------------------------------------
-- UnequipTool
function LocalBasePlayer_.UnequipTool()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end
	hum:UnequipTools()
end
----------------------------------------------------------------------------------------------------
-- IsSitting
function LocalBasePlayer_.IsSitting()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end
	return hum.Sit
end
----------------------------------------------------------------------------------------------------
-- GetSittingSeat
function LocalBasePlayer_.GetSittingSeat() : Seat
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end
	return hum.SeatPart
end
----------------------------------------------------------------------------------------------------
-- StandUp
function LocalBasePlayer_.StandUp()
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end
	hum.Sit = false
end
----------------------------------------------------------------------------------------------------
-- GetDistanceLength
function LocalBasePlayer_.GetDistanceLength(pos : Vector3)
	local pcPos = LocalBasePlayer_.GetPosition()
	if not pcPos then
		return math.huge
	end
	return (pcPos - pos).Magnitude
end
----------------------------------------------------------------------------------------------------
-- CreateCharacterModel
function LocalBasePlayer_.CreateCharacterModelAsync() : Model?
	local success, createdChara = pcall(function()
		return game.Players:CreateHumanoidModelFromUserId(LocalBasePlayer_.GetUserId())
	end)
	if not success then
		warn("CreateHumanoidModelFromUserId failed", LocalBasePlayer_.GetUserId())
		return nil
	end
	return createdChara
end
----------------------------------------------------------------------------------------------------
-- GetMass
function LocalBasePlayer_.GetMass()
	local hrp = LocalBasePlayer_.GetHumanoidRootPart()
	if not hrp then
		return 0
	end
	return hrp.AssemblyMass
end
----------------------------------------------------------------------------------------------------
-- 
function LocalBasePlayer_.SetJumpEnable(val)
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end
	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, val)
end
----------------------------------------------------------------------------------------------------
-- 
function LocalBasePlayer_.SetSitEnable(val)
	local hum = LocalBasePlayer_.GetHumanoid()
	if not hum then
		return
	end
	hum:SetStateEnabled(Enum.HumanoidStateType.Seated, val)
end
----------------------------------------------------------------------------------------------------
-- SetCollisionGroup
function LocalBasePlayer_.SetCollisionGroup(group : string)
	local chara = LocalBasePlayer_.GetCharacterAsync()
	if not chara then
		return
	end
	for _, part in chara:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = group
		end
	end
end
----------------------------------------------------------------------------------------------------
-- PlayBubbleTalk
function LocalBasePlayer_.PlayBubbleTalk(str)
	local chara = LocalBasePlayer_.GetCharacterAsync()
	if chara then
		TextChatService:DisplayBubble(chara, str)
	end
end


return LocalBasePlayer_