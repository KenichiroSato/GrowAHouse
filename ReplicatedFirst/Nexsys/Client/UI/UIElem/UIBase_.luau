local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ButtonUI_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.ButtonUI_)
local RemoteSender_ = require(ReplicatedFirst.Nexsys.Client.RemoteSender_)
local LocalizeModule_ = require(ReplicatedFirst.Nexsys.Client.LocalizeModule_)
local GameSystemUtil = require(ReplicatedFirst.Nexsys.Common.GameSystemUtil)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
--- @class UIBase_ : table
local UIBase_ = {}
UIBase_.__index = UIBase_

----------------------------------------------------------------------------------------------------
-- 
function UIBase_.new(instance: GuiBase)
	local self = setmetatable({}, UIBase_)
	UIBase_.Init(self, instance)
	return self
end

function UIBase_:Init(instance: GuiBase)
	self.instance = instance
end
----------------------------------------------------------------------------------------------------
-- WaitForSaveDataLoaded
function UIBase_:WaitForSaveDataLoaded()
	SystemDataModule_.WaitUntilSaveDataLoaded()
end
----------------------------------------------------------------------------------------------------
-- FindFirstChild
function UIBase_:FindFirstChild(name : string) : GuiObject
	return self.instance:FindFirstChild(name)
end
----------------------------------------------------------------------------------------------------
-- 
function UIBase_:FindFirstChildText(name : string) : TextLabel
	return self.instance:FindFirstChild(name)
end
----------------------------------------------------------------------------------------------------
-- FindFirstChildImage
function UIBase_:FindFirstChildImage(name : string) : ImageLabel
	return self.instance:FindFirstChild(name)
end
----------------------------------------------------------------------------------------------------
-- Find
function UIBase_:FindDescendant(name : string) : GuiObject
	return self.instance:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- 
function UIBase_:FindDescendantText(name : string) : TextLabel
	return self.instance:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- 
function UIBase_:FindDescendantFrame(name : string) : Frame
	return self.instance:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- FindDescendantImage
function UIBase_:FindDescendantImage(name : string) : ImageLabel
	return self.instance:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- Find
function UIBase_:FindDescendantFrom(ancestor : GuiObject, name : string) : GuiObject
	return ancestor:FindFirstChild(name, true)
end
----------------------------------------------------------------------------------------------------
-- SetupButton
--- @return ButtonUI_
function UIBase_:SetupButton(button : GuiButton, onActivatedFunc, buttonParam)
	return ButtonUI_.new(button, onActivatedFunc, buttonParam)
end
----------------------------------------------------------------------------------------------------
-- SetupButton
--- @return ButtonUI_
function UIBase_:SetupButtonByName(name : string, onActivatedFunc, buttonParam)
	local button = self:FindDescendant(name)
	if not button then
		warn("UIBase_.SetupButtonByName, button not found", name)
		return nil
	end
	return self:SetupButton(button, onActivatedFunc, buttonParam)
end
----------------------------------------------------------------------------------------------------
-- InitList
--- listとtemplateを返す
--- @return GuiObject, GuiObject
function UIBase_:InitItemList() : (GuiObject, GuiObject)
	return self:InitListFromFirstGuiObject("ItemList")
end
----------------------------------------------------------------------------------------------------
-- InitList
--- @return Frame, Frame
function UIBase_:InitList(listName, templateName) : (Frame, Frame)
	local list = self:FindDescendant(listName)
	local template = list:FindFirstChild(templateName) :: Frame
	template.Visible = false
	template.Parent = self.instance

	-- 中身をクリア
	self:ClearList(list)

	return list, template
end
----------------------------------------------------------------------------------------------------
--- @return GuiObject, GuiObject
function UIBase_:InitListWithFirstChild(listName) : (GuiObject, GuiObject)
	local list = self:FindDescendant(listName) :: GuiObject
	local template = list:FindFirstChildWhichIsA("GuiObject") :: GuiObject
	template:SetAttribute("ListItem", true)
	template.Visible = false
	template.Parent = self.instance

	-- 中身をクリア
	self:ClearList(list)

	return list, template
end
----------------------------------------------------------------------------------------------------
-- ClearList
function UIBase_:ClearList(list : Frame)
	local children = list:GetChildren()
	for _, child in ipairs(children) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- GetLocalizedDataText
function UIBase_:GetLocalizedData(data : table, key : string, replaceStrs : {string}?)
	return LocalizeModule_.GetLocalizedData(data, key, replaceStrs)
end
----------------------------------------------------------------------------------------------------
-- GetLocalizedArrayData
function UIBase_:GetLocalizedArrayData(data : table, key : string, index : number, replaceStrs : {string}?)
	return LocalizeModule_.GetLocalizedArrayData(data, key, index, replaceStrs)
end
----------------------------------------------------------------------------------------------------
-- GetLocalizedTextData
function UIBase_:GetLocalizedTextData(key : string, ...)
	return LocalizeModule_.GetLocalizedTextData(key, ...)
end
----------------------------------------------------------------------------------------------------
-- GetFormattedNumber
function UIBase_:GetFormattedNumber(number : number)
	-- 3桁ごとにカンマをいれた文字列に

	-- @TODO
	
	return string.format("%d", number)
end
----------------------------------------------------------------------------------------------------
-- GetAssetIdTextFromId
function UIBase_:GetAssetIdTextFromId(id : number)
	return GameSystemUtil.MakeAssetIdTextFromId(id)
end
----------------------------------------------------------------------------------------------------
-- PlaySEByName
function UIBase_:PlaySEByName(name : string, interval : number?)
	local SoundManager_ = require(ReplicatedFirst.Nexsys.Client.SoundManager_)
	SoundManager_.PlaySEByName(name, interval)
end
----------------------------------------------------------------------------------------------------
-- StopSEByName
function UIBase_:StopSEByName(name : string)
	local SoundManager_ = require(ReplicatedFirst.Nexsys.Client.SoundManager_)
	SoundManager_.StopSEByName(name)
end
----------------------------------------------------------------------------------------------------
-- SendRemoteEvent
function UIBase_:SendRemoteEvent(eventName : string, ...)
	RemoteSender_.SendEvent(eventName, ...)
end
----------------------------------------------------------------------------------------------------
-- SendRemoteFunctionOnce
function UIBase_:SendRemoteFunctionOnce(eventName : string, ...)
	return RemoteSender_.SendFunctionOnceNoLog(eventName, ...)
end
----------------------------------------------------------------------------------------------------
-- 開発者製品購入
function UIBase_:PromptProductPurchase(productId : number)
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, productId)
end
----------------------------------------------------------------------------------------------------
-- アセット(UGC)購入
function UIBase_:PromptPurchase(assetId : number)
	MarketplaceService:PromptPurchase(game.Players.LocalPlayer, assetId)
end
----------------------------------------------------------------------------------------------------
-- @param ... 置換文字列 str1, str2
function UIBase_:ShowAnnounce(textKey : string, showTime : number?, ...)
	local AnnounceGui_ = require(script.Parent.Parent.AnnounceGui_)
	AnnounceGui_.GetInstance():ShowAnnounce(textKey, showTime, ...)
end
return UIBase_