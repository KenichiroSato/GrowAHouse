local GuiService = game:GetService("GuiService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local UIBase_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.UIBase_)
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)
local UIManager_ = require(ReplicatedFirst.Nexsys.Client.UIManager_)
local LocalBasePlayer_ = require(ReplicatedFirst.Nexsys.Client.LocalBasePlayer_)
local Timer = require(ReplicatedFirst.Nexsys.Common.Timer)

--- @class BaseGui_ : UIBase_
local BaseGui_ = {}
BaseGui_.__index = BaseGui_
setmetatable(BaseGui_, UIBase_)

BaseGui_.FlyMoveDir = {
	Up = 1,
	Down = 2,
	Left = 3,
	Right = 4,
}

local State = {
	Hide = 0,
	Show = 1,
	Hiding = 2,
}

----------------------------------------------------------------------------------------------------
-- クラス設定
----------------------------------------------------------------------------------------------------
BaseGui_.customCloseSeName = nil
BaseGui_.defaultZoomShowHide = false
BaseGui_.defaultFlyInShowHide = true
BaseGui_.blurTask = nil

-- SetCloseSeName
function BaseGui_.SetCustomCloseSeName(seName : string)
	BaseGui_.customCloseSeName = seName
end
function BaseGui_.SetDefaultZoomShowHide(val)
	BaseGui_.defaultZoomShowHide = val
end

----------------------------------------------------------------------------------------------------
-- 
function BaseGui_.new(...)
	local self = setmetatable(UIBase_.new(...), BaseGui_)
	BaseGui_.Init(self, ...)
	return self
end

function BaseGui_:Init(gui : ScreenGui)
	self.gui = gui
	self.isShowUpdate = false
	self.isZoomShowHide = false
	self.distanceAutoHideBasePos = nil
	-- ProximityPromptがデフォルト10なのでそれより広くしておく
	self.distanceAutoHideDistance = 15
	self.isPromptDisableOnShowing = false
	self.animTime = 0.2
	self.uiScale = nil
	self.showTimer = Timer.new()

	self.isBlurUse = gui:HasTag("BackBlur")

	self.state = State.Hide
	self:setGuiEnabled(gui.Enabled)

	local frame = gui:FindFirstChildOfClass("Frame")
	if frame then
		self.mainFrame = frame
		self.framePos = frame.Position
		self.frameSize = frame.Size
	end

	if BaseGui_.defaultZoomShowHide then
		self:SetZoomShowHide(true)
	end
	if BaseGui_.defaultFlyInShowHide then
		self:SetFlyInShowHide(true)
	end

	-- デフォルト選択範囲制限ありでやってみる
	if self.mainFrame then
		self:SetSelectionGroupStop(true)
	end

	self:SetupCloseButton()

	-- self.gui.ResetOnSpawn = false
	if gui.ResetOnSpawn then
		-- プログラムでオフでは意味がなさそうなので警告
		warn("ResetOnSpawn is Active", gui.Name)
	end
	gui.IgnoreGuiInset = true
end
----------------------------------------------------------------------------------------------------
-- 
function BaseGui_:Terminate()
	if self.onUpdateConnection then
		self.onUpdateConnection:Disconnect()
		self.onUpdateConnection = nil
	end
	if self.sigConnect then
		self.sigConnect:Disconnect()
		self.sigConnect = nil
	end
	if self.onTerminate then
		self:onTerminate()
	end
end
----------------------------------------------------------------------------------------------------
-- 
function BaseGui_:WaitForLoaded(gui : ScreenGui)
	local curDescsNum = 0
	local needNum = 0
	repeat
		local info = SystemDataModule_.GetGuiSetupInfo()
		if not info then
			-- print("BaseGuiModule_.Setup, SystemDataModule_.GetGuiSetupInfo() is nil")
			task.wait()
			continue
		end

		needNum = info[gui.Name]
		curDescsNum = #gui:GetDescendants()
		-- print("BaseGuiModule_.Setup waiting", gui.Name, needNum, curDescsNum)
		task.wait()
	until needNum > 0 and curDescsNum >= needNum

	-- print("BaseGuiModule_.Setup loaded", gui.Name)
end
----------------------------------------------------------------------------------------------------
-- PreloadAllAssets
function BaseGui_:PreloadAllAssets()
	task.spawn(function()
		self:PreloadAllAssetsAsync()
	end)
end
----------------------------------------------------------------------------------------------------
-- Gui配下のアセット(Image)をプリロードして待つ
function BaseGui_:PreloadAllAssetsAsync()
	local objects = self.gui:GetDescendants()
	local keyAssets = {}
	for _, object in objects do
		if object:IsA("ImageLabel") or object:IsA("ImageButton") then
			local assetId = object.Image
			if assetId then
				table.insert(keyAssets, assetId)
			end
		end
	end
	ContentProvider:PreloadAsync(keyAssets)
end
----------------------------------------------------------------------------------------------------
-- SetUpdate
function BaseGui_:SetUpdate(isUpdate : boolean)
	if isUpdate then
		if not self.onUpdateConnection then
			self.onUpdateConnection = game:GetService("RunService").Stepped:Connect(function(time, dt)
				self:onUpdate(dt)
			end)
		end
	else
		if self.onUpdateConnection then
			self.onUpdateConnection:Disconnect()
			self.onUpdateConnection = nil
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetReceiveSignal
function BaseGui_:SetReceiveSignal(isReceive : boolean)
	local GlobalSignal = require(ReplicatedFirst.Nexsys.Common.GlobalSignal)
	if isReceive then
		if not self.sigConnect then
			self.sigConnect = GlobalSignal.ConnectSignal("Signal_OpenGui", function(event, guiName, ...)
				if guiName == self.gui.Name then
					self:Show(...)
				end
			end)
		end
	else
		if self.sigConnect then
			self.sigConnect:Disconnect()
			self.sigConnect = nil
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetInteractable
function BaseGui_:SetInteractable(isInteractable : boolean)
	if self.mainFrame then
		self.mainFrame.Interactable = isInteractable
	end
end
----------------------------------------------------------------------------------------------------
-- SetShowUpdate
function BaseGui_:SetShowUpdate(isShowUpdate : boolean)
	self.isShowUpdate = isShowUpdate
end
----------------------------------------------------------------------------------------------------
-- SetZoomShowHide
function BaseGui_:SetZoomShowHide(isZoomShowHide : boolean, zoomTime : number?)
	self.animTime = zoomTime or 0.3

	if self.isZoomShowHide == isZoomShowHide then
		return
	end
	self.isZoomShowHide = isZoomShowHide

	if self.mainFrame and not self.uiScale then
		self.uiScale = Instance.new("UIScale")
		self.uiScale.Parent = self.mainFrame
	end
end
----------------------------------------------------------------------------------------------------
-- SetFlyInShowHide(isActive : boolean, flyInTime : number?)
function BaseGui_:SetFlyInShowHide(isActive : boolean, flyInTime : number?, dir : number?)
	-- 他のアニメを無効化
	if isActive then
		self:SetZoomShowHide(false)
	end

	self.isFlyInShowHide = isActive
	self.flyMoveDir = dir or BaseGui_.FlyMoveDir.Down
	self.animTime = flyInTime or 0.5
end
----------------------------------------------------------------------------------------------------
-- SetShowHide
function BaseGui_:SetShowHide(isShow : boolean)
	if self.gui.Enabled == isShow then
		return
	end

	if isShow then
		self:Show()
	else
		self:Hide()
	end
end
----------------------------------------------------------------------------------------------------
-- setGuiEnabled
function BaseGui_:setGuiEnabled(isEnabled : boolean)
	self.gui.Enabled = isEnabled
	self.state = isEnabled and State.Show or State.Hide
end
----------------------------------------------------------------------------------------------------
-- ToggleShowHide
function BaseGui_:ToggleShowHide()
	self:SetShowHide(not self:IsShow())
end
----------------------------------------------------------------------------------------------------
-- IsShow
function BaseGui_:IsShow()
	return self.state == State.Show
end
----------------------------------------------------------------------------------------------------
-- IsHiding
function BaseGui_:IsHiding()
	return self.state == State.Hiding
end
----------------------------------------------------------------------------------------------------
-- GetShowTime
function BaseGui_:GetShowTime()
	return self.showTimer:GetTime()
end
----------------------------------------------------------------------------------------------------
--- SetEnabled
function BaseGui_:SetEnabled(isEnabled : boolean)
	self:setGuiEnabled(isEnabled)
end
----------------------------------------------------------------------------------------------------
--- IsEnabled
function BaseGui_:IsEnabled()
	return self.gui.Enabled
end
----------------------------------------------------------------------------------------------------
-- Show
function BaseGui_:Show(...)
	if self.onBeforeShow then
		self:onBeforeShow(...)
	end

	if self.gui then
		self:setGuiEnabled(true)
	end

	if self.isZoomShowHide and self.frameSize then
		self:ZoomInUIElem(self.mainFrame, UDim2.fromScale(0, 0), self.frameSize, self.animTime)
	elseif self.isFlyInShowHide and self.framePos then
		self:FlyInUIMove()
	end

	if self.isPromptDisableOnShowing then
		UIManager_.SetProximityPromptDisableFlag(self.gui.Name, true)
	end

	if self.isExcludeShow then
		UIManager_.HideExcludeGui(self)
	end

	self.showTimer:Start()
	if self.OnShow then
		self:OnShow(...)
	end

	if self.isBlurUse then
		self:SetBlur(true)
	end

	if self.isShowUpdate then
		if not self.onShowUpdateConnection then
			self.onShowUpdateConnection = game:GetService("RunService").Stepped:Connect(function(time, dt)
				self:OnShowUpdate(dt)
			end)
		end
	end

	-- 今回はバーチャルカーソルなのでなし : Mode見て分岐がいい？
	-- if not game.StarterGui.VirtualCursorMode == Enum.VirtualCursorMode.Enabled then
	-- 	self:setFirstSelected()
	-- end
end
----------------------------------------------------------------------------------------------------
-- Hide
function BaseGui_:Hide(isInstant)

	if (not isInstant) and self.isZoomShowHide and self.frameSize then
		self:HideWithZoomOut()
	elseif (not isInstant) and self.isFlyInShowHide and self.framePos then
		self:HideWithFlyOutUIMove()
	else
		self:setGuiEnabled(false)
	end

	if self.onShowUpdateConnection then
		self.onShowUpdateConnection:Disconnect()
		self.onShowUpdateConnection = nil
	end

	if self.isPromptDisableOnShowing then
		UIManager_.SetProximityPromptDisableFlag(self.gui.Name, false)
	end

	if self.isBlurUse then
		self:SetBlur(false)
	end

	GuiService.SelectedObject = nil

	if self.OnHide then
		self:OnHide()
	end
end
----------------------------------------------------------------------------------------------------
-- OnShowUpdate
function BaseGui_:OnShowUpdate(dt)
	if self.onShowUpdate then
		self:onShowUpdate(dt)
	end

	self:checkDistanceAutoHide()
	self:checkNoSitAutoHide()
end
----------------------------------------------------------------------------------------------------
-- 自動距離非表示
function BaseGui_:checkDistanceAutoHide()
	if self.distanceAutoHideBasePos then
		local chara = game.Players.LocalPlayer.Character
		local pcPos = chara and chara:GetPivot().Position
		if pcPos then
			local distance = (pcPos - self.distanceAutoHideBasePos).Magnitude
			if distance > self.distanceAutoHideDistance then
				self:Hide()
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
-- checkNoSitAutoHide
function BaseGui_:checkNoSitAutoHide()
	if self.noSitAutoHide and self:GetShowTime() > 0.5 then
		if not LocalBasePlayer_.IsSitting() then
			self:Hide()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetupCloseButton
function BaseGui_:SetupCloseButton()
	local button = self:FindDescendant("CloseButton")
	if not button then
		button = self:FindDescendant("CloseButton_SmallDlg")
	end
	if not button then
		return
	end

	self.closeButton = self:SetupButton(button, function()
		self:Hide()
	end)
	if BaseGui_.customCloseSeName then
		self.closeButton:SetClickSEName(BaseGui_.customCloseSeName)
	end

	if self.closeButton then
		self.closeButton:GetButton().SelectionOrder = 10
		self:SetCloseByPadCancel()
	end
end
----------------------------------------------------------------------------------------------------
-- GetCloseButton
function BaseGui_:GetCloseButton() : GuiButton
	return self.closeButton and self.closeButton:GetButton()
end
----------------------------------------------------------------------------------------------------
-- SetupAutoDistanceHide
function BaseGui_:SetupAutoDistanceHide(basePos : Vector3, hideDist : number?)
	self.distanceAutoHideBasePos = basePos
	if hideDist then
		self.distanceAutoHideDistance = hideDist
	end
	self:SetShowUpdate(true)
end
----------------------------------------------------------------------------------------------------
-- ClearAutoDistanceHide
function BaseGui_:ClearAutoDistanceHide()
	self.distanceAutoHideBasePos = nil
end
----------------------------------------------------------------------------------------------------
-- SetNoSitAutoHide
function BaseGui_:SetNoSitAutoHide(isAutoHide : boolean)
	self.noSitAutoHide = isAutoHide
	self:SetShowUpdate(true)
end
----------------------------------------------------------------------------------------------------
-- SetPromptDisableOnShowing
function BaseGui_:SetPromptDisableOnShowing(isDisable : boolean)
	self.isPromptDisableOnShowing = isDisable
end
----------------------------------------------------------------------------------------------------
-- FlyInUIMove
function BaseGui_:FlyInUIMove()
	self:AnimateUIMove(self:getAnimMoveOutPos(), self.framePos, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end
----------------------------------------------------------------------------------------------------
-- FlyOutUIMove
function BaseGui_:HideWithFlyOutUIMove()
	self.state = State.Hiding
	self:AnimateUIMove(self.framePos, self:getAnimMoveOutPos(), Enum.EasingStyle.Back, Enum.EasingDirection.In)
	task.spawn(function()
		task.wait(self.animTime)
		self:setGuiEnabled(false)
	end)
end
----------------------------------------------------------------------------------------------------
-- FlyInUIElemFromBottom
function BaseGui_:AnimateUIMove(startPos, goalPos, style : Enum.EasingStyle?, dir : Enum.EasingDirection?)
	task.spawn(function()
		local tweenInfo = TweenInfo.new(self.animTime, style or Enum.EasingStyle.Linear, dir or Enum.EasingDirection.In)
		local goalProp = { Position = goalPos }
		local tween = TweenService:Create(self.mainFrame, tweenInfo, goalProp)
		self.mainFrame.Position = startPos
		tween:Play()

		--warn("AnimateUIMove", startPos, goalPos, self:IsShow())
		task.wait(self.animTime)
		self.mainFrame.Position = goalPos
	end)
end
----------------------------------------------------------------------------------------------------
-- HideWithZoomOut
function BaseGui_:HideWithZoomOut()
	self.state = State.Hiding
	self:ZoomOutUIElem(self.mainFrame, self.frameSize, UDim2.fromScale(0, 0), self.animTime)
	task.spawn(function()
		task.wait(self.animTime)
		self:setGuiEnabled(false)
	end)
end
----------------------------------------------------------------------------------------------------
-- ZoomInUIElem
function BaseGui_:ZoomInUIElem(elem : Frame, startSize, goalSize, animTime)
	if not self.uiScale then
		return
	end

	task.spawn(function()
		self.uiScale.Scale = 0
		local tweenInfo = TweenInfo.new(self.animTime, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local goalProp = { Scale = 1 }
		local tween = TweenService:Create(self.uiScale, tweenInfo, goalProp)
		tween:Play()

		task.wait(self.animTime)
		self.uiScale.Scale = 1
	end)
end
----------------------------------------------------------------------------------------------------
-- ZoomOutUIElem
function BaseGui_:ZoomOutUIElem(elem : Frame, startSize, goalSize, animTime)
	task.spawn(function()
		local tweenInfo = TweenInfo.new(self.animTime, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local goalProp = { Scale = 0 }
		local tween = TweenService:Create(self.uiScale, tweenInfo, goalProp)
		tween:Play()

		task.wait(self.animTime)
		self.uiScale.Scale = 1
	end)
end
----------------------------------------------------------------------------------------------------
-- getAnimMoveOutPos
function BaseGui_:getAnimMoveOutPos()
	if self.flyMoveDir == BaseGui_.FlyMoveDir.Up then
		return UDim2.fromScale(self.framePos.X.Scale, -1)
	else
		return UDim2.fromScale(self.framePos.X.Scale, 2)
	end
end
----------------------------------------------------------------------------------------------------
-- SetCloseByPadCancel
function BaseGui_:SetCloseByPadCancel()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if self:IsShow() and (not gameProcessed) then
			if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonB then
				self:Hide()
			end
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- このGUIの中だけの選択とする
function BaseGui_:SetSelectionGroupStop(isActive : boolean)
	if not self.mainFrame then
		warn("BaseGui_.SetSelectionGroupActive, mainFrame is nil")
		return
	end

	self.mainFrame.SelectionGroup = isActive

	local val = isActive and Enum.SelectionBehavior.Stop or Enum.SelectionBehavior.Escape
	self.mainFrame.SelectionBehaviorDown = val
	self.mainFrame.SelectionBehaviorUp = val
	self.mainFrame.SelectionBehaviorLeft = val
	self.mainFrame.SelectionBehaviorRight = val
end
----------------------------------------------------------------------------------------------------
-- SetFirstSelectedObject
function BaseGui_:SetFirstSelectedObject(guiObj : GuiObject)
	self.firstSelectedObject = guiObj
end
----------------------------------------------------------------------------------------------------
-- SetBlur
function BaseGui_:SetBlur(active : boolean)
	local blur = game.Lighting:FindFirstChild("GuiBackBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Parent = game.Lighting
		blur.Name = "GuiBackBlur"
	end

	if BaseGui_.blurTask then
		task.cancel(BaseGui_.blurTask)
		BaseGui_.blurTask = nil
	end

	if active then
		BaseGui_.blurTask = task.spawn(function()
			local start = 1
			if blur.Enabled then
				start = blur.Size
			end
			for i = start, 20 do
				blur.Size = i
				-- Disableと同時などでEnabledが上書きされないように都度設定
				blur.Enabled = true
				task.wait()
			end
			BaseGui_.blurTask = nil
		end)
	else
		BaseGui_.blurTask = task.spawn(function()
			for i = 20, 1, -1 do
				blur.Size = i
				task.wait()
			end
			blur.Enabled = false
			BaseGui_.blurTask = nil
		end)
	end
end
----------------------------------------------------------------------------------------------------
--- SetExcludeShow
function BaseGui_:SetExcludeShow(isExclude : boolean)
	self.isExcludeShow = isExclude
	UIManager_.SetExcludeShowGui(self)
end
----------------------------------------------------------------------------------------------------
-- setFirstSelected
function BaseGui_:setFirstSelected()
	-- if not self.firstSelectedObject then
	-- 	return
	-- end
	if not UIManager_.IsPadActive() then
		return
	end

	task.defer(function()
		if self.animTime then
			task.wait(self.animTime)
		else
			task.wait()
		end

		if self:IsShow() then
			if self.firstSelectedObject then
				GuiService.SelectedObject = self.firstSelectedObject
			else
				-- 自動的な選択に任せる(SelectionOrderでコントロール想定)
				GuiService:Select(self.gui)
			end
		end
	end)
end

return BaseGui_