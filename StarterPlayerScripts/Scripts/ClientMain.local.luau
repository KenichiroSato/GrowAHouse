local ReplicatedFirst = game:GetService("ReplicatedFirst")
local LocalPlayer_ = require(ReplicatedFirst.Nexapp.Client.Player.LocalPlayerIns_)
local ClientInitializer_ = require(ReplicatedFirst.Nexapp.Client.System.ClientInitializer_)
local BGMManager_ = require(ReplicatedFirst.Nexsys.Client.BGMManager_)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
local RemoteSender_ = require(ReplicatedFirst.Nexsys.Client.RemoteSender_)

local StartPlayer = game:GetService("StarterPlayer")
local ShopItemClient_ = require(StartPlayer.StarterPlayerScripts.Scripts.ShopItemClient_)
local CommonMessageHandler_ = require(StartPlayer.StarterPlayerScripts.Scripts.CommonMessageHandler_)
-- local EventManager_ = require(ReplicatedFirst.Nexsys.Client.Event.EventManager_)

ClientInitializer_.StartMain()
LocalPlayer_:Start()
-- GameUIManager_.Setup()
----------------------------------------------------------------------------------------------------
-- アプリ用の初期化実装
----------------------------------------------------------------------------------------------------

local UIManager_ = require(ReplicatedFirst.Nexsys.Client.UIManager_)
UIManager_.Setup()

ShopItemClient_.Start()
CommonMessageHandler_.Start()
----------------------------------------------------------------------------------------------------
-- ローディング画面終了後処理
SystemDataModule_.WaitUntilLoadingScreenEnded()
RemoteSender_.SendEvent("OnClientGameStarted")

-- BGM開始
--BGMManager_.Init("Land", true)
