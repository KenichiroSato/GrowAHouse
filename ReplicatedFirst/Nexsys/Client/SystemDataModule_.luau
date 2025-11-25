local RunService = game:GetService("RunService")
--- @class SystemDataModule_ : table
local SystemDataModule_ = {}

local saveDataLoadedEvent_ = Instance.new("BindableEvent")
local isSaveDataLoaded_ = false

local preloadEndedEvent_ = Instance.new("BindableEvent")
local isPreloadEnded_ = false

local persistentLoadedEvent_ = Instance.new("BindableEvent")
local persistentLoaded_ = false

local loadingScreenEndedEvent_ = Instance.new("BindableEvent")
local isLoadingScreenEnded_ = false

local replicaRequested_ = false
local guiSetupInfo_ = nil

----------------------------------------------------------------------------------------------------
-- AddCallbackToSaveLoadedEvent
function SystemDataModule_.AddCallbackToSaveLoadedEvent(callback)
	if isSaveDataLoaded_ then
		callback()
	else
		saveDataLoadedEvent_.Event:Connect(callback)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function SystemDataModule_.OnSaveDataLoaded()
	print("====== player save data loaded ======")
	saveDataLoadedEvent_:Fire()
	isSaveDataLoaded_ = true
end
----------------------------------------------------------------------------------------------------
-- IsSaveDataLoaded
function SystemDataModule_.IsSaveDataLoaded()
	return isSaveDataLoaded_
end
----------------------------------------------------------------------------------------------------
-- WaitUntilSaveDataLoaded
function SystemDataModule_.WaitUntilSaveDataLoaded()
	if isSaveDataLoaded_ then
		return
	end
	saveDataLoadedEvent_.Event:Wait()
end

----------------------------------------------------------------------------------------------------
-- AddCallbackToLoadingScreenEndedEvent
function SystemDataModule_.AddCallbackToLoadingScreenEndedEvent(callback)
	if isLoadingScreenEnded_ then
		callback()
	else
		loadingScreenEndedEvent_.Event:Connect(callback)
	end
end
----------------------------------------------------------------------------------------------------
-- OnLoadingScreenEnded
function SystemDataModule_.OnLoadingScreenEnded()
	loadingScreenEndedEvent_:Fire()
	isLoadingScreenEnded_ = true
end
----------------------------------------------------------------------------------------------------
-- IsLoadingScreenEnded
function SystemDataModule_.IsLoadingScreenEnded()
	return isLoadingScreenEnded_
end
----------------------------------------------------------------------------------------------------
-- WaitUntilLoadingScreenEnded
function SystemDataModule_.WaitUntilLoadingScreenEnded()
	if isLoadingScreenEnded_ then
		return
	end
	loadingScreenEndedEvent_.Event:Wait()
end

----------------------------------------------------------------------------------------------------
-- SetPreloadLoaded
function SystemDataModule_.SetPreloadLoaded()
	preloadEndedEvent_:Fire()
	isPreloadEnded_ = true
end
----------------------------------------------------------------------------------------------------
-- IsPreloadLoaded
function SystemDataModule_.IsPreloadLoaded()
	return isPreloadEnded_
end
----------------------------------------------------------------------------------------------------
-- WaitUntilPreloadEnded
function SystemDataModule_.WaitUntilPreloadEnded()
	if isPreloadEnded_ then
		return
	end
	preloadEndedEvent_.Event:Wait()
end
----------------------------------------------------------------------------------------------------
-- AddCallbackToSaveLoadedEvent
function SystemDataModule_.AddCallbackToPersistentLoadedEvent(callback)
	persistentLoadedEvent_.Event:Connect(callback)
end
----------------------------------------------------------------------------------------------------
-- SetPersitentLoaded
function SystemDataModule_.OnPersitentLoaded()
	print("====== persistent loaded ======")
	persistentLoadedEvent_:Fire()
	persistentLoaded_ = true
end
----------------------------------------------------------------------------------------------------
-- IsPersitentLoaded
function SystemDataModule_.IsPersitentLoaded()
	return persistentLoaded_
end
----------------------------------------------------------------------------------------------------
--- 
function SystemDataModule_.WaitUntilPersitentLoaded()
	if persistentLoaded_ then
		return
	end
	persistentLoadedEvent_.Event:Wait()
end
----------------------------------------------------------------------------------------------------
-- OnReplicaRequested
function SystemDataModule_.OnReplicaRequested()
	print("====== Replica requested ======")
	replicaRequested_ = true
end
----------------------------------------------------------------------------------------------------
-- IsReplicaRequested
function SystemDataModule_.IsReplicaRequested()
	return replicaRequested_
end
----------------------------------------------------------------------------------------------------
-- OnReceiveGuiSetupInfo
function SystemDataModule_.OnReceiveGuiSetupInfo(guiSetupInfo)
	if RunService:IsStudio() then
		print("====== GuiSetupInfo received ======", guiSetupInfo)
	end
	guiSetupInfo_ = guiSetupInfo
end
----------------------------------------------------------------------------------------------------
-- GetGuiSetupInfo
function SystemDataModule_.GetGuiSetupInfo()
	return guiSetupInfo_
end

return SystemDataModule_