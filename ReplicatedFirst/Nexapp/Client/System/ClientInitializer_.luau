local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local PlayerData = require(ReplicatedFirst.Nexapp.Common.System.PlayerData)
local LocalInstanceManager_ = require(ReplicatedFirst.Nexapp.Client.System.LocalInstanceManager_)
local BGMManager_ = require(ReplicatedFirst.Nexsys.Client.BGMManager_)
local PreloadController_ = require(ReplicatedFirst.Nexsys.Client.PreloadController_)
--- @class ClientInitializer_ : table
local ClientInitializer_ = {}

local loadingRate_ = 0

----------------------------------------------------------------------------------------------------
-- 
function ClientInitializer_.Preload()
	
end
----------------------------------------------------------------------
-- StartInit
function ClientInitializer_.StartInit()
	LocalInstanceManager_.Init()

	-- 今回はアニメなし
	local ButtonUI_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.ButtonUI_)
	ButtonUI_.SetButtonAnimationInactive()
end
----------------------------------------------------------------------------------------------------
-- ローディングGuiを表示して必要なアセットのプリロードと割合を保持する
function ClientInitializer_.StartLoadingScreen()
	-- 最低表示する時間
	local SHOW_TIME_MIN = 5

	-- ローディング画面の表示
	task.spawn(function()
		local start = tick()
		local guiHandler

		local useTitleBGM = true
		-- Teleportdata, JoinDataはこのタイミングではとれないらしい(テスト結果)、ArrivingTeleportGui処理のみ行う
		local customLoadingScreen = TeleportService:GetArrivingTeleportGui()
		if customLoadingScreen and customLoadingScreen.Name == "LobbyCustomLoadingGui" then
			print("========== customLoadingScreen", customLoadingScreen.Name, "start ==========")
			-- カスタムローディングを検出しても実際にはロビーにあるScreenGuiを使用する(UI更新をミニゲームへ反映せずとも問題ないように)
			local ReturnLoadingGui_ = require(ReplicatedFirst.Nexapp.Client.UI.ReturnLoadingGui_)
			guiHandler = ReturnLoadingGui_.GetInstance()
			useTitleBGM = false
		else
			local LoadingGui_ = require(ReplicatedFirst.Nexapp.Client.UI.LoadingGui_)
			guiHandler = LoadingGui_.WaitForInstance()
		end

		-- ローディング画面をロードしてからデフォルトロード仮面から切替え
		guiHandler:PreloadAllAssets()
		guiHandler:Show()
		ReplicatedFirst:RemoveDefaultLoadingScreen()

		-- タイトルBGM
		if useTitleBGM then
			local bgm = ReplicatedFirst.Sound.Title
			BGMManager_.PlayBGM(bgm, 0)
		else
			BGMManager_.PlayBGMByName("Land", 0)
		end

		-- ゲームの基本ロード待ち
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
		-- プリロード開始
		PreloadController_:StartPreload()

		-- local assets = workspace:GetDescendants()
		-- print("Loading start")
		-- ContentProvider:PreloadAsync(assets, function(assetId, status)
		-- 	-- print("PreloadAsync", assetId, status)
		-- end)
		-- print("Loading end")
		-- local endTime = tick()
		-- if endTime - start < SHOW_TIME_MIN then
		-- 	local remainTime = SHOW_TIME_MIN - (endTime - start)
		-- 	print("Loading time is too short, wait for...", remainTime)
		-- 	task.wait(remainTime)
		-- end
	end)
end
----------------------------------------------------------------------------------------------------
-- StartMain
function ClientInitializer_.StartMain()
	-- 開始時必須の初期化処理
	-- System系のモジュールなど、毎回必ず使うもののみを初期化する
	-- RemoteEventはReplicatedStorage配置のためgameLoaded後に有効化(ClientInitではできない)
	local GameRemoteEventHandler_ = require(ReplicatedFirst.Nexapp.Client.System.GameRemoteEventHandler_)
	GameRemoteEventHandler_.Init()
	
	ClientInitializer_.StartSyncParam()
	LocalInstanceManager_.Setup()

end
----------------------------------------------------------------------------------------------------
-- StartSyncParam
function ClientInitializer_.StartSyncParam()
	-- 初期化用
	-- local _GameData = require(ReplicatedFirst.Nexapp.Common.GameData)

	PlayerData:StartOnClient()
	local ReplicaController = require(ReplicatedStorage.Nexsys.Replica.ReplicaController)
	ReplicaController.RequestData()
end

return ClientInitializer_