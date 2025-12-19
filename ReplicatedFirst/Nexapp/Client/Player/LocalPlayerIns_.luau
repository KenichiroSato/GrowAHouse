local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local LocalBasePlayerIns_ = require(ReplicatedFirst.Nexsys.Client.Player.LocalBasePlayerIns_)
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local ConfigData = require(ReplicatedFirst.Exdata.ConfigData)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
local Define = require(ReplicatedFirst.Nexapp.Common.Define)
local RemoteSender_ = require(ReplicatedFirst.Nexsys.Client.RemoteSender_)
local ComponentManager = require(ReplicatedFirst.Nexapp.Common.System.ComponentManager)
local ProgressFlagData = require(ReplicatedFirst.Nexapp.Data.ProgressFlagData)
local getHouseBaseFunction = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("GetHouseBaseFunction")
local zoneplus = require(ReplicatedStorage.Packages.zoneplus)
local BeamManager_ = require(ReplicatedFirst.Nexsys.Client.Beam.IndicatorBeamManager_)
local RemoteSender_ = require(ReplicatedFirst.Nexsys.Client.RemoteSender_)

--- @class LocalPlayerIns_ : LocalBasePlayerIns_
local LocalPlayerIns_ = {}
LocalPlayerIns_.__index = LocalPlayerIns_
setmetatable(LocalPlayerIns_, LocalBasePlayerIns_)

----------------------------------------------------------------------------------------------------
-- 
function LocalPlayerIns_.new()
	local player = game.Players.LocalPlayer
	local self = setmetatable(LocalBasePlayerIns_.new(player), LocalPlayerIns_)
	LocalBasePlayerIns_.SetInstance(self)
	return self
end

function LocalPlayerIns_:Init(player : Player)
end
----------------------------------------------------------------------------------------------------
local function ShowWelcomePositionIndicatorIfNeed()
	SystemDataModule_.WaitUntilPreloadEnded()
	SystemDataModule_.WaitUntilSaveDataLoaded()
	if not PlayerData:IsProgressFlag(ProgressFlagData.Flag_FirstTalkEnd) then
		local houseBase = getHouseBaseFunction:InvokeServer("HouseAreaHideBeam")
		local manager = BeamManager_.new()
		local attachment = houseBase:WaitForChild("Attachment")

		local beam = manager:CreateBeam(attachment)
		beam:SetBeamColor(Color3.fromRGB(99, 21, 255))

		local zone = zoneplus.new(houseBase)
		zone.localPlayerEntered:Connect(function(player)
			print("sato TutorialBeamDisplay_.Hide")
			manager:DestroyBeam(beam)
			RemoteSender_.SendEvent("OnPlayerEnteredWelcomeMessagePosition")
		end)
	end
end
----------------------------------------------------------------------------------------------------
-- Start
function LocalPlayerIns_:Start()
	-- 物理処理前に実行したいもの
	RunService.Stepped:Connect(function(time, deltaTime)
		self:OnStepped(time, deltaTime)
	end)

	-- 物理処理後に実行したいもの
	RunService.Heartbeat:Connect(function(dt)
		self:OnHeartbeat(dt)
	end)
	
	task.spawn(ShowWelcomePositionIndicatorIfNeed)
end
----------------------------------------------------------------------------------------------------
-- OnCharacterAdded
function LocalPlayerIns_:onCharacterAdded(character : Model)
	print("Client onCharacterAdded")

	local CameraManager_ = require(ReplicatedFirst.Nexsys.Client.CameraManager_)
	CameraManager_.AlignCameraToCharacter(character)

end
----------------------------------------------------------------------------------------------------
-- Update
function LocalPlayerIns_:OnStepped(time : number, dt : number)
	self:UpdateWalkSpeed()
end
----------------------------------------------------------------------------------------------------
-- OnHeartbeat
function LocalPlayerIns_:OnHeartbeat(dt : number)
end
----------------------------------------------------------------------------------------------------
-- UpdateWalkSpeed
function LocalPlayerIns_:UpdateWalkSpeed()
	local hum = self:GetHumanoid()
	if not hum then
		return
	end

	if not SystemDataModule_.IsLoadingScreenEnded() then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		return
	end
	hum.JumpPower = StarterPlayer.CharacterJumpPower

	if PlayerData:IsDashMode() then
		hum.WalkSpeed = ConfigData.DashSpeed
	else
		hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
	end
end

----------------------------------------------------------------------------------------------------
-- ここはInstanceを直接取得可能
if not LocalBasePlayerIns_.GetInstance() then
	LocalPlayerIns_.new()
end

return LocalBasePlayerIns_.GetInstance()
