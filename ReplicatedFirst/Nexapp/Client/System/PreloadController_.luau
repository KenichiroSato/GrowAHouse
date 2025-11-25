local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
--- @class PreloadController_ : table
local PreloadController_ = {}
PreloadController_.__index = PreloadController_
PreloadController_.instance = nil

----------------------------------------------------------------------------------------------------
-- クラス関数
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return PreloadController_
function PreloadController_.GetInstance()
	return PreloadController_.instance
end

function PreloadController_.new(...)
	local self = setmetatable({}, PreloadController_)
	PreloadController_.Init(self, ...)
	PreloadController_.instance = self
	return self
end

----------------------------------------------------------------------------------------------------
-- メンバ関数
----------------------------------------------------------------------------------------------------
function PreloadController_:Init(...)
	self.loadRate = 0
	self.saveDataLoadRate = 0
end
----------------------------------------------------------------------------------------------------
-- WaitUntilPreloadEnded
function PreloadController_:WaitUntilPreloadEnded()
end
----------------------------------------------------------------------------------------------------
-- プリロード開始
function PreloadController_:StartPreload()
	self:startCheckSaveDataLoaded()

	local assets, targetMap = self:CollectAssets()

	local total = #assets
	local loaded = 0

	print("StartPreload start")
	local start = tick()

	ContentProvider:PreloadAsync(assets, function(assetId, status)
		-- if status == Enum.AssetFetchStatus.Success then

		loaded += 1
		self.loadRate = loaded / total
		targetMap[assetId] = 1

		-- print("assetId", assetId, "status", status)
	end)
	print("StartPreload end", tick() - start)
	SystemDataModule_.SetPreloadLoaded()

	-- 確認用
	-- print("targetMap", targetMap)
end
----------------------------------------------------------------------------------------------------
-- checkSaveDataLoaded
function PreloadController_:startCheckSaveDataLoaded()
	-- ロード率を少しずつ増やす
	task.spawn(function()
		SystemDataModule_.WaitUntilSaveDataLoaded()
		for i = 1, 10 do
			self.saveDataLoadRate = i / 10
			task.wait(0.05)
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- ロード率取得
function PreloadController_:GetLoadRate()
	-- セーブデータのロードが済んでるかを10%計上
	local rate = self.loadRate * 0.9 + self.saveDataLoadRate * 0.1
	return rate
end
----------------------------------------------------------------------------------------------------
-- CollectAssets
function PreloadController_:CollectAssets()
	print("CollectAssets start")
	local start = tick()
	local targets = {}

	local targetMap = {}

	local function addAsset(assetId)
		if assetId == "" then
			return
		end
		table.insert(targets, assetId)
		targetMap[assetId] = 0
	end

	-- 優先度の高いものがから撮る
	local services = {
		game.ReplicatedFirst,
		game.Workspace,
		game.ReplicatedStorage,
		game.SoundService,
		game.StarterGui,
	}

	local instancesNum = 0
	for _, service in ipairs(services) do
		local instances = service:GetDescendants()
		instancesNum += #instances
		for _, inst in ipairs(instances) do
			-- print(inst:GetFullName())
			if inst:IsA("Decal") then
				addAsset(inst.Texture)
			elseif inst:IsA("Texture") then
				addAsset(inst.Texture)
			elseif inst:IsA("ImageLabel") then
				addAsset(inst.Image)
			elseif inst:IsA("ImageButton") then
				addAsset(inst.Image)
			elseif inst:IsA("MeshPart") then
				addAsset(inst.MeshId)
			elseif inst:IsA("Sound") then
				addAsset(inst.SoundId)
			elseif inst:IsA("Animation") then
				addAsset(inst.AnimationId)
			end
		end
	end

	print("CollectAssets end", tick() - start, "targetNum", #targets, "instanceNum", instancesNum)
	return targets, targetMap
end
----------------------------------------------------------------------------------------------------
if PreloadController_.instance == nil then
	PreloadController_.new()
end
return PreloadController_.instance
