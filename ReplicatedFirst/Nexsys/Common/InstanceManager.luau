local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)

local isServer_ = RunService:IsServer()
local isClient_ = RunService:IsClient()
local sysCompFolder_
if isServer_ then
	sysCompFolder_ = game.ServerScriptService.Nexsys.Component
elseif isClient_ then
	sysCompFolder_ = game.ReplicatedFirst.Nexsys.Client.Component
end

----------------------------------------------------------------------
-- インスタンス管理、サーバークライアント共通
----------------------------------------------------------------------

---@class InstanceManager : table
local InstanceManager = {}
InstanceManager.__index = InstanceManager
----------------------------------------------------------------------
-- Component持ちインスタンスのコンテナ
----------------------------------------------------------------------
local CompInstances = {}

InstanceManager.IsLogDestroyInstance = nil
InstanceManager.IsLogRemoveInstance = nil

InstanceManager.IsAutoInitComponentAll = false

InstanceManager.CompDependency = {}
----------------------------------------------------------------------------------------------------
-- 
local function getSystemComponentFolder() : Folder?
	return sysCompFolder_
end

----------------------------------------------------------------------------------------------------
-- Init
function InstanceManager.Init(enableLog : boolean?)
	if enableLog then
		InstanceManager.IsLogDestroyInstance = true
		InstanceManager.IsLogRemoveInstance = true
	end
end
----------------------------------------------------------------------------------------------------
-- SetLogEnable
function InstanceManager.SetLogEnable(enableLog : boolean)
	InstanceManager.IsLogDestroyInstance = enableLog
	InstanceManager.IsLogRemoveInstance = enableLog
end
----------------------------------------------------------------------------------------------------
-- SetAutoInitComponentAll
function InstanceManager.SetAutoInitComponentAll(enable : boolean)
	InstanceManager.IsAutoInitComponentAll = enable
end
----------------------------------------------------------------------------------------------------
-- SetCompDependency
function InstanceManager.SetCompDependency(compName : string, dependencyCompNames : { string })
	InstanceManager.CompDependency[compName] = dependencyCompNames
end
----------------------------------------------------------------------------------------------------
-- SetupModelStremaingModeAtomic
function InstanceManager.SetupModelStremaingModeAtomic()
	if not workspace.StreamingEnabled then
		return
	end

	-- Clientで使うComponentはAtomic化
	local models = CollectionService:GetTagged("_InitLocal")
	for _index, model : Model in ipairs(models) do
		if model:IsA("Model") and model.ModelStreamingMode == Enum.ModelStreamingMode.Default then
			model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			warn("Set ModelStreamingMode from Default to Atomic", model:GetFullName())
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 特定のタグがあるInstanceに InitTag をつける
function InstanceManager.AddInitTags(tags : { string })
	local initTag = isServer_ and "_InitServer" or "_InitLocal"
	for _, tag in tags do
		CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance : Instance)
			instance:AddTag(initTag)
		end)
		local instances = CollectionService:GetTagged(tag)
		for _, instance : Instance in instances do
			instance:AddTag(initTag)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- Componentフォルダーたにあるものを自動的に InitTag をつける
function InstanceManager.SetupInitInstanceTag()
	local compFolder = GameDataProvider:GetComponentFolder()
	local folders = { compFolder, sysCompFolder_ }

	local initTag = isServer_ and "_InitServer" or "_InitLocal"
	for _, folder in folders do
		local comps = folder:GetChildren()
		for _, comp : Instance in comps do
			local tag = comp.Name
			CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance : Instance)
				instance:AddTag(initTag)
			end)
			local instances = CollectionService:GetTagged(tag)
			for _, instance : Instance in instances do
				instance:AddTag(initTag)
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function InstanceManager.Setup()
	if isServer_ then
		InstanceManager.SetupAttachScripts()
	end

	if InstanceManager.IsAutoInitComponentAll then
		InstanceManager.SetupInitInstanceTag()
	end

	if isServer_ then
		-- InitTag
		InstanceManager.SetupModelStremaingModeAtomic()
	end

	-- 時間がかかるので非同期で実行
	task.spawn(function()
		-- これ以降追加されたものはHook
		if isServer_ then
			CollectionService:GetInstanceAddedSignal("_InitServer"):Connect(InstanceManager.OnInitInstance)
			CollectionService:GetInstanceRemovedSignal("_InitServer"):Connect(InstanceManager.OnRemoveInstance)
		elseif isClient_ then
			CollectionService:GetInstanceAddedSignal("_InitLocal"):Connect(InstanceManager.OnInitInstance)
			CollectionService:GetInstanceRemovedSignal("_InitLocal"):Connect(InstanceManager.OnRemoveInstance)
		end

		print("InstanceManager.SetupWorkspaceInstances start")
		-- 現在あるものは全部設定
		local setupStart = tick()
		InstanceManager.SetupWorkspaceInstancesAsync()

		local setupTime = tick() - setupStart
		print("InstanceManager.SetupWorkspaceInstances Done, setup time", setupTime)
	end)

	RunService.Stepped:Connect(function(time, deltaTime)
		InstanceManager.OnStepped(time, deltaTime)
	end)
end
----------------------------------------------------------------------------------------------------
-- SetupAttachScripts
function InstanceManager.SetupAttachScripts()
	local attachers = CollectionService:GetTagged("AttachScript")
	for _index, attacher : ObjectValue in ipairs(attachers) do
		local scr = attacher.Value
		scr:Clone().Parent = attacher.Parent
	end
end

----------------------------------------------------------------------
--
----------------------------------------------------------------------
function InstanceManager.SetupWorkspaceInstances()
	local instances
	if isServer_ then
		instances = CollectionService:GetTagged("_InitServer")
	elseif isClient_ then
		instances = CollectionService:GetTagged("_InitLocal")
	end
	for index, instance: PVInstance in instances do
		if instance:IsDescendantOf(game.Workspace) then
			InstanceManager.CreateComponentInstance(instance, nil, true)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function InstanceManager.SetupWorkspaceInstancesAsync()
	local instances
	if isServer_ then
		instances = CollectionService:GetTagged("_InitServer")
	elseif isClient_ then
		instances = CollectionService:GetTagged("_InitLocal")
	end
	for index, instance: PVInstance in instances do
		if instance:IsDescendantOf(game.Workspace) then
			task.spawn(function()
				InstanceManager.CreateComponentInstance(instance, nil, true)
			end)
		end
	end
end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function InstanceManager.OnInitInstance(instance : Instance)
	-- print("OnInitInstance", instance:GetFullName())
	InstanceManager.CreateComponentInstance(instance, nil, true)
end
----------------------------------------------------------------------------------------------------
-- OnRemoveInstance
-- InstanceがDataModelから除外されたとき、指定タグが除外されたとき、に来るコールバック
-- Instance自体は存在していてもParentがnilになって、DataModelから除外されたときに来るのがOnDestroyInstanceと異なる
----------------------------------------------------------------------------------------------------
function InstanceManager.OnRemoveInstance(instance : PVInstance)
	-- RemoveはInstance破棄などでは来ない
	if InstanceManager.IsLogRemoveInstance then
		print("OnRemoveInstance", instance.Parent, instance.Name)
	end

	local comps = CompInstances[instance]
	if comps then
		for _index, comp in comps do
			if comp.OnRemoveInstance then
				comp:OnRemoveInstance()
			end
		end
	end

	InstanceManager.RemoveComponents(instance)
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function InstanceManager.CreateToolCloneByName(toolName: string) : Tool
	local ServerStorage = game:GetService("ServerStorage")
	local tool = ServerStorage.Tool:FindFirstChild(toolName)
	if not tool then
		error("tool[" .. toolName .. "] not found")
		return
	end

	local toolClone = tool:Clone()
	InstanceManager.CreateComponentInstance(toolClone)
	return toolClone
end
----------------------------------------------------------------------------------------------------
-- Instanceに対してTagに基づくComponentを生成・付与する
-- このIFで生成することで、Componentがつき、Instance破棄時にComponent破棄も行われる
----------------------------------------------------------------------
function InstanceManager.CreateComponentInstance(instance: Instance, createParam, isInit) : table
	local curComps = CompInstances[instance]
	if curComps then
		-- Streaming Atomicのやつだと OnInitInstance が2回呼ばれるようになっているので正常系としてログ一時スルー
		if not isInit then
			warn("DEBUG: CreateComponentInstance skip", instance:GetFullName(), debug.traceback("call stack"), tostring(instance))
		end
		return
	end

	local comps = {}
	-- 依存Componentタグを付与
	local origTags = CollectionService:GetTags(instance)
	for _, tag in origTags do
		local depends = InstanceManager.CompDependency[tag]
		if not depends then
			continue
		end
		for _, dependencyCompName in depends do
			-- しばらく確認のため
			if RunService:IsStudio() then
				--warn("CompDependency AddTag", dependencyCompName)
			end
			CollectionService:AddTag(instance, dependencyCompName)
		end
	end

	local tags = CollectionService:GetTags(instance)
	for _, tag in tags do
		if tag:sub(1,1) == "_" then
			continue
		end
		local comp = InstanceManager.CreateAndAppendComponent(tag, instance, createParam)
		if comp then
			table.insert(comps, comp)
		end
	end
	-- if RunService:IsClient() then
	-- 	local clientInit = instance:FindFirstChild("ClientInit")
	-- 	if clientInit then
	-- 		local compNames = clientInit:GetChildren()
	-- 		for index, compNameIns in compNames do
	-- 			local comp = InstanceManager.CreateAndAppendComponent(compNameIns.Name, instance)
	-- 			if comp then
	-- 				table.insert(comps, comp)
	-- 			end
	-- 		end
	-- 	end
	-- end

	if #comps > 0 then
		-- instanceをキーにComponentsを抱える
		CompInstances[instance] = comps
		-- table.insert(CompInstances, { instance = comps } )
		instance.Destroying:Connect(function()
			InstanceManager.OnDestroyInstance(instance)
		end)

		for index, comp in comps do
			-- Instanceへの一通りのComponent生成完了コールバック
			if comp.OnCreated then
				comp:OnCreated()
			end
		end

		return comps
	end
end
----------------------------------------------------------------------
-- componentを生成して返す
----------------------------------------------------------------------
function InstanceManager.CreateAndAppendComponent(compName, instance, createParam)
	-- 自動的にサーバー/クライアント側のフォルダをとる
	local compFolder = GameDataProvider:GetComponentFolder()
	local compScript = compFolder:FindFirstChild(compName)

	if not compScript then
		if sysCompFolder_ then
			compScript = sysCompFolder_:FindFirstChild(compName)
		end
	end

	-- Commonはサーバー、クライアント解決が難しいので探さない。必ず各実装を、クライアント・サーバーに作る
	-- クライアント・サーバー側にない場合はCommonを探す
	-- if not compScript then
	-- 	-- 共通ComponentはClientかどうかはCompNameの末尾で決める
	-- 	local lastChar = string.sub(compName, -1)
	-- 	if (isClient_ and lastChar == "_") or (isServer_ and lastChar ~= "_") then
	-- 		compScript = ReplicatedFirst.Nexsys.Common.Component:FindFirstChild(compName)
	-- 	end
	-- end

	if compScript then
		local compModule = require(compScript)
		compModule.CompName = compName
		local comp = compModule.new(instance, createParam)
		return comp
	else
		-- warn("Component not created. tag["..compName.."] is not component.")
		return nil
	end
end
----------------------------------------------------------------------------------------------------
-- 
function InstanceManager.CreateAndAppendComponentByScript(compScript : Script, instance)
	if compScript then
		local compModule = require(compScript)
		compModule.CompName = compScript.Name
		local comp = compModule.new(instance)
		return comp
	else
		error("Component not created. tag["..compScript.Name.."] is not component.")
		return nil
	end

end
----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
function InstanceManager.RemoveComponents(instance : PVInstance)
	CompInstances[instance] = nil
	-- print("component removed : "..instance.Name)
end
----------------------------------------------------------------------------------------------------
-- GetComponentInstances : compNameをもつInstanceの配列
function InstanceManager.GetComponentInstances(compName)
	return CollectionService:GetTagged(compName)
end

----------------------------------------------------------------------
--
----------------------------------------------------------------------
function InstanceManager.GetComponentsByInstance(instance)
	return CompInstances[instance]
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function InstanceManager.GetComponentByInstance(compName, instance)
	local comps = CompInstances[instance]
	if not comps then
		return nil
	end
	for index, comp in comps do
		if comp.CompName == compName then
			return comp
		end
	end
	return nil
end
----------------------------------------------------------------------------------------------------
-- WaitGetComponentByInstance
function InstanceManager.WaitGetComponentByInstance(compName, instance, waitTime)
	local comp = InstanceManager.GetComponentByInstance(compName, instance)
	if comp then
		return comp
	end

	waitTime = waitTime or 5
	local start = tick()
	repeat
		task.wait()
		comp = InstanceManager.GetComponentByInstance(compName, instance)
		if tick() - start >= waitTime then
			break
		end
	until comp

	return comp
end

----------------------------------------------------------------------
-- Componentに更新が必要ならここでCompInstanceで回す
----------------------------------------------------------------------
function InstanceManager.OnStepped(time, dt)
	-- 各ComponentでSetSteppedActive登録へ移行

	-- for ins, comps in CompInstances do
	-- 	for _, comp in comps do
	-- 		if comp and comp.OnStepped then
	-- 			comp:OnStepped(dt)
	-- 		end
	-- 	end
	-- end
end

----------------------------------------------------------------------------------------------------
-- Instanceの破棄が行われたとき
----------------------------------------------------------------------------------------------------
function InstanceManager.OnDestroyInstance(instance: PVInstance)
	if InstanceManager.IsLogDestroyInstance then
		print("instance destroyed!! name=" .. instance.Name .. ", class=" .. instance.ClassName)
	end

	local comps = CompInstances[instance]
	if comps then
		for _index, comp in comps do
			if comp.OnDestroyInstance then
				comp:OnDestroyInstance()
			end
		end
	end

	InstanceManager.RemoveComponents(instance)
end
----------------------------------------------------------------------------------------------------
-- DestroyInstanceImmediately
function InstanceManager.DestroyInstanceImmediately(instance: PVInstance)
	if instance then
		instance:Destroy()
		InstanceManager.OnDestroyInstance(instance)
	end
end

return InstanceManager
