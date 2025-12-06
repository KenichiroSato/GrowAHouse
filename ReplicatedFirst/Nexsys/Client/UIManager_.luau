local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UIUtil = require(ReplicatedFirst.Nexsys.Common.UIUtil)
local GameDataProvider = require(ReplicatedFirst.Nexsys.Common.GameDataProvider.GameDataProvider)

--- @class UIManager_ : table
local UIManager_ = {}
UIManager_.__index = UIManager_

local DEFAULT_FADE_TIME = 2
local selfImageUrl_ = nil
local proximityPromptDisableFlags_ = {}
--- @type table<BaseGui_, BaseGui_>
local excludeShowGuis_ = {}

local function WaitGetGui(guiName): ScreenGui
	local gui: ScreenGui = PlayerGui:WaitForChild(guiName)
	return gui
end

----------------------------------------------------------------------------------------------------
-- Init : ReplicatedFirstで呼ばれる初期化
function UIManager_.Init()
	-- 初期化対象Module処理のフック準備
	PlayerGui.ChildAdded:Connect(function(gui : ScreenGui)
		if gui:IsA("ScreenGui") then
			local uiModuleFolder = GameDataProvider:GetUIModuleFolder()
			local moduleIns = uiModuleFolder:FindFirstChild(gui.Name.."_")
			if not moduleIns then
				moduleIns = ReplicatedFirst.Nexsys.Client.UI:FindFirstChild(gui.Name.."_")
			end
			if not moduleIns then
				if RunService:IsStudio() then
					print("UI Module not found", gui.Name)
				end
				return
			end
			local guiModule = require(moduleIns)
			if guiModule and guiModule.new then
				task.spawn(function()
					guiModule.new(gui)
				end)
			end
		end
	end)

	UIManager_.SetupInitGui()
end

----------------------------------------------------------------------------------------------------
-- Setup : ClientMainで呼ばれるインゲーム用初期化
function UIManager_.Setup()
	RunService.Heartbeat:Connect(function(deltaTime)
		UIManager_.OnHeartbeat(deltaTime)
	end)
end
----------------------------------------------------------------------------------------------------
-- SetupHoverAnimations
function UIManager_.SetupHoverAnimInstances()
	CollectionService:GetInstanceAddedSignal("HoverAnim"):Connect(UIManager_.SetupHoverAnim)
	local instances = CollectionService:GetTagged("HoverAnim")
	for index, instance: PVInstance in instances do
		if instance:IsDescendantOf(PlayerGui) then
			UIManager_.SetupHoverAnim(instance)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetupHoverAnim
function UIManager_.SetupHoverAnim(elem: UIBase)
	-- ボタンスケールテスト
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = elem

	local function onMouseEnter()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		local goalProp = { Scale = 1.1 }
		local tween = TweenService:Create(uiScale, tweenInfo, goalProp)
		tween:Play()
	end

	local function onMouseLeave()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		local goalProp = { Scale = 1 }
		local tween = TweenService:Create(uiScale, tweenInfo, goalProp)
		tween:Play()
	end

	elem.MouseEnter:Connect(onMouseEnter)
	elem.MouseLeave:Connect(onMouseLeave)
end
----------------------------------------------------------------------------------------------------
-- OnStepped
function UIManager_.OnHeartbeat(time, deltaTime)
	-- プロキシプロンプトの無効化
	ProximityPromptService.Enabled = true
	for key, val in proximityPromptDisableFlags_ do
		if val then
			ProximityPromptService.Enabled = false
		end
	end
end
----------------------------------------------------------------------------------------------------
-- IsTouchEnabled
function UIManager_.IsTouchEnabled()
	return UserInputService.TouchEnabled
end
----------------------------------------------------------------------------------------------------
-- IsPadEnabled
function UIManager_.IsPadEnabled()
	return UserInputService.GamepadEnabled
end
----------------------------------------------------------------------------------------------------
-- IsPadActive
function UIManager_.IsPadActive()
	local lastInputType = UserInputService:GetLastInputType()
	if lastInputType == Enum.UserInputType.Gamepad1 then
		return true
	end
	return false
	-- return UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1).Connected
end
----------------------------------------------------------------------------------------------------
-- SetEnableHUD
function UIManager_.SetEnableHUD(val)
	local hudGuis = {
		"LeftSideGui",
		"MobilityPowerGui",
		"SkillButtonsGui",
	}
	for index, name in hudGuis do
		local gui = WaitGetGui(name)
		if gui then
			gui.Enabled = val
		end
	end
end
----------------------------------------------------------------------------------------------------
-- CloseAllGui : 閉じることができるUIが対象
function UIManager_.CloseAllWindows()
	local guis = {
		"ProgressWindowGui",
		"ReturnHomeGui",
	}
	for index, name in guis do
		local gui = WaitGetGui(name)
		if gui then
			gui.Enabled = false
		end
	end
end
----------------------------------------------------------------------------------------------------
-- SetBlurActive
function UIManager_.SetBlurActive(val)
	local blur = Lighting.Blur
	blur.Enabled = val
	task.spawn(function()
		if val then
			blur.Size = 0
			for i = 1, 12 do
				blur.Size = i
				task.wait(0.1)
			end
		else
			for i = 12, 0, -1 do
				blur.Size = i
				task.wait(0.1)
			end
		end
	end)
end

----------------------------------------------------------------------
--
----------------------------------------------------------------------
function UIManager_.SetupInitGui()
	local uiFolder : Folder = ReplicatedFirst:FindFirstChild("UI")
	if not uiFolder then
		warn("UI Folder not found")
		return
	end
	local guis = uiFolder:GetChildren()
	for _, gui in guis do
		gui.Parent = PlayerGui
	end
end
----------------------------------------------------------------------------------------------------
-- StartLoadingGui
function UIManager_.SetEnableLoadingGui(enable)
	local loadingGui = WaitGetGui("LoadingGui")
	if loadingGui then
		loadingGui.Enabled = enable
		-- 制御はお任せ
	end
end
----------------------------------------------------------------------
-- フェードアウト(暗転)
----------------------------------------------------------------------
function UIManager_.StartScreenFadeOut(fadeTime, isWhite: boolean?)
	task.spawn(function()
		UIManager_.StartScreenFadeOutSync(fadeTime, isWhite)
	end)
end
----------------------------------------------------------------------------------------------------
-- 
function UIManager_.StartScreenFadeOutSync(fadeTime, isWhite: boolean?)
	local fadeGui = PlayerGui:FindFirstChild("FadeGui")
	if not fadeGui then
		error("FadeGui not loaded")
		return
	end

	if not fadeTime then
		fadeTime = DEFAULT_FADE_TIME
	end

	fadeGui.Frame.BackgroundTransparency = 1
	--fadeGui.Frame.BackgroundColor3 = isWhite and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	UIManager_.FadeInGuiSync(fadeGui, fadeTime)
end
----------------------------------------------------------------------------------------------------
-- 
function UIManager_.StartScreenFadeIn(fadeTime, isWhite: boolean?)
	local fadeGui = PlayerGui:FindFirstChild("FadeGui")
	if not fadeGui then
		error("FadeGui not loaded")
		return
	end

	if not fadeTime then
		fadeTime = DEFAULT_FADE_TIME
	end

	fadeGui.Frame.BackgroundTransparency = 0
	--fadeGui.Frame.BackgroundColor3 = isWhite and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	UIManager_.FadeOutDisableGui(fadeGui, fadeTime)
end
----------------------------------------------------------------------
-- Guiをまとめてフェードアウトさせる
----------------------------------------------------------------------
function UIManager_.FadeOutDestroyGui(gui: ScreenGui, fadeOutTime)
	UIManager_.FadeOutGui(gui, fadeOutTime, true)
end

function UIManager_.FadeOutDisableGui(gui: ScreenGui, fadeOutTime)
	UIManager_.FadeOutGui(gui, fadeOutTime, false, true)
end

function UIManager_.FadeOutGuiByName(guiName, fadeOutTime, destroy, disable)
	local gui = WaitGetGui(guiName)
	if gui then
		UIManager_.FadeOutGui(gui, fadeOutTime, destroy, disable)
	end
end

function UIManager_.FadeOutGui(gui: ScreenGui, fadeOutTime, destroy, disable)
	task.spawn(function()
		UIUtil.FadeOutGui(gui, fadeOutTime)

		-- Tween終わり待ち
		task.wait(fadeOutTime)

		-- 後処理
		if destroy then
			gui:Destroy()
		elseif disable then
			gui.Enabled = false
		end
	end)
end

function UIManager_.FadeInGuiByName(guiName: string, fadeInTime)
	local gui = WaitGetGui(guiName)
	if gui then
		UIManager_.FadeInGui(gui, fadeInTime)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function UIManager_.FadeInGui(gui: ScreenGui, fadeInTime)
	task.spawn(function()
		UIManager_.FadeInGuiSync(gui, fadeInTime)
	end)
end
----------------------------------------------------------------------------------------------------
-- 
function UIManager_.FadeInGuiSync(gui: ScreenGui, fadeInTime)
	gui.Enabled = true
	UIUtil.FadeInGui(gui, fadeInTime)
	-- Tween終わり待ち
	task.wait(fadeInTime)
end
----------------------------------------------------------------------
-- UI要素単位でのフェードアウト
----------------------------------------------------------------------
function UIManager_.FadeOutUIElem(elem, fadeOutTime, destroy, disable)
	task.spawn(function()
		-- Tweenでフェード
		local tweenInfo = TweenInfo.new(fadeOutTime)
		local goalProp = nil
		if elem:IsA("Frame") then
			goalProp = { BackgroundTransparency = 1 }
		elseif elem:IsA("TextLabel") then
			goalProp = { TextTransparency = 1 }
		elseif elem:IsA("UIStroke") then
			goalProp = { Transparency = 1 }
		end
		-- Tweenは自動破棄される
		if goalProp then
			local tween = TweenService:Create(elem, tweenInfo, goalProp)
			tween:Play()
		end

		-- Tween終わり待ち
		task.wait(fadeOutTime)

		-- 後処理
		if destroy then
			elem:Destroy()
		elseif disable then
			-- disableはUI要素は透明のみでよしとしてみる
		end
	end)
end
----------------------------------------------------------------------
-- UI要素単位でのフェードイン
----------------------------------------------------------------------
function UIManager_.FadeInUIElem(elem, fadeOutTime)
	task.spawn(function()
		-- Tweenでフェード
		local tweenInfo = TweenInfo.new(fadeOutTime)
		local goalProp = nil
		if elem:IsA("Frame") then
			goalProp = { BackgroundTransparency = 0 }
		elseif elem:IsA("TextLabel") then
			goalProp = { TextTransparency = 0 }
		elseif elem:IsA("UIStroke") then
			goalProp = { Transparency = 0 }
		end
		-- Tweenは自動破棄される
		if goalProp then
			local tween = TweenService:Create(elem, tweenInfo, goalProp)
			tween:Play()
		end

		-- Tween終わり待ち
		task.wait(fadeOutTime)
	end)
end
----------------------------------------------------------------------------------------------------
-- FlyInUIElem
function UIManager_.FlyInUIElemFromBottom(elem: UIBase, goalPos: UDim2, flyTime)
	task.spawn(function()
		local startPos = UDim2.fromScale(elem.Position.X.Scale, 1.5)
		local tweenInfo = TweenInfo.new(flyTime)
		local goalProp = { Position = goalPos }
		local tween = TweenService:Create(elem, tweenInfo, goalProp)
		elem.Position = startPos
		tween:Play()
		task.wait(flyTime)
		elem.Position = goalPos
	end)
end
----------------------------------------------------------------------------------------------------
-- FlyOutUIElem
function UIManager_.FlyOutUIElemToBottom(elem: UIBase, flyTime)
	task.spawn(function()
		local goalPos = UDim2.fromScale(elem.Position.X.Scale, 1.5)
		local tweenInfo = TweenInfo.new(flyTime)
		local goalProp = { Position = goalPos }
		local tween = TweenService:Create(elem, tweenInfo, goalProp)
		tween:Play()
		task.wait(flyTime)
		elem.Position = goalPos
	end)
end
----------------------------------------------------------------------------------------------------
-- FlyOutUIElem
function UIManager_.FlyOutUIElemToTop(elem: UIBase, flyTime)
	task.spawn(function()
		local goalPos = UDim2.fromScale(elem.Position.X.Scale, -0.5)
		local tweenInfo = TweenInfo.new(flyTime)
		local goalProp = { Position = goalPos }
		local tween = TweenService:Create(elem, tweenInfo, goalProp)
		tween:Play()
		task.wait(flyTime)
		elem.Position = goalPos
	end)
end
----------------------------------------------------------------------------------------------------
-- ZoomInUIElem
function UIManager_.ZoomInUIElem(elem: UIBase, startScale: UDim2, goalScale: UDim2, zoomTime, _style : Enum.EasingStyle?, _direction : Enum.EasingDirection?)
	task.spawn(function()
		local style = _style or Enum.EasingStyle.Quart
		local direction = _direction or Enum.EasingDirection.Out
		local tweenInfo = TweenInfo.new(zoomTime, style, direction)
		local goalProp = { Size = goalScale }
		local tween = TweenService:Create(elem, tweenInfo, goalProp)
		elem.Size = startScale
		tween:Play()
		task.wait(zoomTime)
		elem.Size = goalScale
	end)
end
----------------------------------------------------------------------------------------------------
-- ZoomInUIElem
function UIManager_.ZoomInOutUIElem(elem: UIBase, startSize: UDim2, scale, zoomTime, _style : Enum.EasingStyle?, _direction : Enum.EasingDirection?)
	task.spawn(function()
		local style = _style or Enum.EasingStyle.Quart
		local direction = _direction or Enum.EasingDirection.Out
		local tweenInfo = TweenInfo.new(zoomTime, style, direction, 0, true)
		local goalSize = UIUtil.GetScaledSize(startSize, scale)
		local goalProp = { Size = goalSize }
		local tween = TweenService:Create(elem, tweenInfo, goalProp)
		elem.Size = startSize
		tween:Play()
		task.wait(zoomTime * 2)
		elem.Size = startSize
	end)
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function UIManager_.OnFadeInScreenGui(guiName, fadeTime)
	local gui = WaitGetGui(guiName)
	if gui then
		UIManager_.FadeInGui(gui, fadeTime)
	end
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function UIManager_.AnnounceTalk(text, imageUrl, nameText, locTextId)
	local gui = WaitGetGui("AnnounceTalkGui")
	if not gui then
		return
	end

	-- 特殊系imageUrlを解決
	if imageUrl == "myself" then
		imageUrl = selfImageUrl_
	end
	if nameText == "myself" then
		nameText = Player.DisplayName
	end

	-- gui.Frame.FrameTalk.TextLabel.TextColor3 = Color3.fromRGB(250, 250, 250)

	if text == "[end]" then
		gui.Enabled = false
	else
		gui.Enabled = true
		gui.Frame.FrameTalker.FrameTalkerName.NameText.Text = nameText and nameText or " "
		gui.Frame.FrameTalk.TextLabel.Text = text
		gui.Frame.FrameTalker.ImageLabel.Image = imageUrl
		-- gui.Frame.FrameTalker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

		-- 文字送りテキスト表示
		-- task.spawn(function()
		-- 	local sound = SoundService.SE:FindFirstChild("text")
		-- 	local textLen = utf8.len(text)
		-- 	for i = 1, textLen do
		-- 		-- print(text[i])
		-- 		-- gui.Frame.FrameTalk.TextLabel.Text = string.sub(text, 1, i)
		-- 		-- print(string.sub(text, 1, i))
		-- 		-- print(Util.MbSubString(text, i))
		-- 		gui.Frame.FrameTalk.TextLabel.Text = Util.MbSubString(text, i)
		-- 		sound:Play()
		-- 		task.wait(0.066666)
		-- 	end
		-- end)
	end
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function UIManager_.SetEnableGui(guiName, val)
	local gui = WaitGetGui(guiName)
	if not gui then
		return
	end

	gui.Enabled = val
end
----------------------------------------------------------------------------------------------------
--
function UIManager_.ToggleEnableGui(guiName)
	local gui = WaitGetGui(guiName)
	if not gui then
		return
	end

	gui.Enabled = not gui.Enabled
end
----------------------------------------------------------------------
--
----------------------------------------------------------------------
function UIManager_.IsEnableGui(guiName)
	local gui = WaitGetGui(guiName)
	if not gui then
		return false
	end

	return gui.Enabled
end
----------------------------------------------------------------------------------------------------
-- SetEnableCoreUI
function UIManager_.SetEnableCoreUI(val)
	print("SetEnableCoreUI", val)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, val)
end
----------------------------------------------------------------------------------------------------
-- SetCoreGuiEnabled
function UIManager_.SetCoreGuiEnabled(coreGuiType : Enum.CoreGuiType, val)
	StarterGui:SetCoreGuiEnabled(coreGuiType, val)
end
----------------------------------------------------------------------------------------------------
-- SetProximityPromptDisableFlag
function UIManager_.SetProximityPromptDisableFlag(key, val : boolean)
	proximityPromptDisableFlags_[key] = val
end
----------------------------------------------------------------------------------------------------
--- @brief 除外表示のGUIを設定する
--- @param guiHandler BaseGui_
function UIManager_.SetExcludeShowGui(guiHandler)
	excludeShowGuis_[guiHandler] = guiHandler
end
----------------------------------------------------------------------------------------------------
--- @brief 除外表示のGUIを全て非表示にする
--- @param showGuiHandler BaseGui_
function UIManager_.HideExcludeGui(showGuiHandler)
	for guiHandler, _ in excludeShowGuis_ do
		if guiHandler ~= showGuiHandler then
			if guiHandler:IsShow() then
				guiHandler:Hide()
			end
		end
	end
end


return UIManager_
