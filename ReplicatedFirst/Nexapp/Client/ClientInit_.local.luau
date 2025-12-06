local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
-- 初期化用
local GameDataProviderImpl = require(ReplicatedFirst.Nexapp.Common.System.GameDataProviderImpl)

local UIManager_ = require(ReplicatedFirst.Nexsys.Client.UIManager_)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local ClientInitializer_ = require(ReplicatedFirst.Nexapp.Client.System.ClientInitializer_)
-- 初期化用
local _PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local _LocalPlayer_ = require(ReplicatedFirst.Nexapp.Client.Player.LocalPlayerIns_)

-- Trace作成
_G.trace = function(...)
	if RunService:IsStudio() then
		print(...)
	end
end

-- Fadeから開始
UIManager_.Init()
ClientInitializer_.StartInit()

ClientInitializer_.StartLoadingScreen()

BaseGui_.SetDefaultZoomShowHide(true)

workspace.PersistentLoaded:Connect(function(player)
	SystemDataModule_.OnPersitentLoaded()
end)


-- 参考情報
local cur = tick()
workspace.PersistentLoaded:Wait()
print("persistent loaded, time", tick() - cur)
