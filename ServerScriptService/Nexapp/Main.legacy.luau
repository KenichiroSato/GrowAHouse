print("Server Start. ServerId:", game.JobId)
local startTime = tick()

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
-- 最初に初期化が必要
local GameDataProviderImpl = require(ReplicatedFirst.Nexapp.Common.System.GameDataProviderImpl)
local PlayerManager = require(ServerScriptService.Nexapp.Player.PlayerManager)
local ColorMaterialStore = require(ServerScriptService.Nexapp.Player.ColorMaterialStore)
local ServerInstanceManager = require(ServerScriptService.Nexapp.System.ServerInstanceManager)

print("Server ModuleLoad end. time:", tick() - startTime)

local HouseBuilder = require(ServerScriptService.Nexapp.House.HouseBuilder)
local ItemManager = require(ServerScriptService.Nexapp.House.ItemManager)
local ObjectRemover = require(ServerScriptService.Nexapp.House.ObjectRemover)
local ShopItemServer = require(ServerScriptService.Nexapp.Shop.ShopItemServer)
local PlayerTeleporter = require(ServerScriptService.Nexapp.Player.PlayerTeleporter)


-- 初期化
ServerInstanceManager.Init()
PlayerManager.Start()
ServerInstanceManager.Setup()
ShopItemServer.Start()
PlayerTeleporter.Start()

HouseBuilder.bindEvents()

ItemManager.bindEvents()

ObjectRemover.bindEvents()

ColorMaterialStore.Start()