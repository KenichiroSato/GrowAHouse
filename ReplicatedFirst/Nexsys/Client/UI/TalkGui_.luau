local ContextActionService = game:GetService("ContextActionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local BaseGui_ = require(ReplicatedFirst.Nexsys.Client.BaseGui_)
local SystemDefine = require(ReplicatedFirst.Nexsys.Common.SystemDefine)
local RichText = require(ReplicatedFirst.Nexsys.Lib.RichText)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)

--- @class TalkGui_ : BaseGui_
local TalkGui_ = {}
TalkGui_.__index = TalkGui_
setmetatable(TalkGui_, BaseGui_)
TalkGui_.instance = nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- GetInstance
--- @return TalkGui_
function TalkGui_.GetInstance()
	return TalkGui_.instance
end
----------------------------------------------------------------------------------------------------

function TalkGui_.new(...)
	local self = setmetatable(BaseGui_.new(...), TalkGui_)
	TalkGui_.Init(self, ...)
	TalkGui_.instance = self
	return self
end

function TalkGui_:Init(gui : ScreenGui)
	self:WaitForLoaded(gui)
	self:SetPromptDisableOnShowing(true)
	self:SetFlyInShowHide(true, 0.4)
	
	self.talkText = self:FindDescendant("TalkText") :: TextLabel
	self.talkText.Visible = false
	self.talkTextFrame = self:FindDescendant("TalkTextFrame") :: Frame
	self.talkerImage = self:FindDescendant("TalkerImage") :: ImageLabel
	self.talkerName = self:FindDescendant("TalkerName") :: TextLabel
	self.isAllTextShown = false
	self.isTalkEnd = false
	self.talkerVpf = self:FindDescendant("TalkerImageViewport") :: ViewportFrame

	self.nextMark = self:FindDescendant("NextMark") :: Frame
	if self.nextMark then
		self.nextMark.Visible = false
		self.nextMarkOrginalPos = self.nextMark.Position
	else
		warn("TalkGui, NextMark is not found")
	end

	local buttonParam = {
		DisableAnimation = true,
	}
	self.skipButoon = self:SetupButtonByName("SkipButton", function()
		self:onSkipButtonPushed()
	end, buttonParam)
end
----------------------------------------------------------------------------------------------------
-- onShow
function TalkGui_:onShow()
	-- パッドAボタンでの会話送りと、その間のジャンプ無効化
	local function onPadJumpButton(actionName, inputState, inputObject)
		if self:IsShow() then
			if inputState == Enum.UserInputState.Begin then
				self:onSkipButtonPushed()
			end
			return Enum.ContextActionResult.Sink
		end
	end
	ContextActionService:BindActionAtPriority("DisableJump", onPadJumpButton, false, 3000, Enum.KeyCode.ButtonA)
end
----------------------------------------------------------------------------------------------------
-- onHide
function TalkGui_:onHide()
	ContextActionService:UnbindAction("DisableJump")
	self:setTextShown(false)

	-- ちゃんと確認できてない
	-- if self.talkTask then
	-- 	task.cancel(self.talkTask)
	-- 	self.talkTask = nil
	-- end
end
----------------------------------------------------------------------------------------------------
-- onSkipButtonPushed
function TalkGui_:onSkipButtonPushed()
	if self.textObj then
		if self.isAllTextShown then
			self.isTalkEnd = true
		else
			self.textObj:Show()
			self:setTextShown(true)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- setTextShown
function TalkGui_:setTextShown(val)
	self.isAllTextShown = val
	self.nextMark.Visible = val

	if self.nextMarkTween then
		self.nextMarkTween:Cancel()
		self.nextMarkTween = nil
	end

	if val then
		-- マークをTweenで上下移動
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
		self.nextMark.Position = self.nextMarkOrginalPos
		local goal = { Position = self.nextMarkOrginalPos + UDim2.fromScale(0, 0.05) }
		self.nextMarkTween = TweenService:Create(self.nextMark, tweenInfo, goal)
		self.nextMarkTween:Play()
	end
end
----------------------------------------------------------------------------------------------------
-- setupTalkerViewportFrame
function TalkGui_:setupTalkerViewportFrame(talkerModel : Model)
	local oldCam = self.talkerVpf:FindFirstChild("VpfCamera")
	if oldCam then
		oldCam:Destroy()
		self.talkerVpf.CurrentCamera = nil
	end
	local oldModel = self.talkerVpf:FindFirstChild("Talker")
	if oldModel then
		oldModel:Destroy()
	end

	local hrp = talkerModel.PrimaryPart or talkerModel:FindFirstChild("HumanoidRootPart")
	local head = talkerModel:FindFirstChild("Head") or hrp
	if not head then
		warn("TalkGui_.setupTalkerViewportFrame, Head or PrimaryPart is not found")
		return
	end

	local camera = Instance.new("Camera")
	camera.Name = "VpfCamera"
	local lookVector = hrp:GetPivot().LookVector
	camera.CFrame = CFrame.new(head.Position + lookVector*2, head.Position)
	camera.Parent = self.talkerVpf
	self.talkerVpf.CurrentCamera = camera

	local model = talkerModel:Clone()
	model.Name = "Talker"
	model.Parent = self.talkerVpf
end
----------------------------------------------------------------------------------------------------
-- WaitForTalkEnd
function TalkGui_:WaitForTalkEnd()
	repeat
		task.wait()
	until self.isTalkEnd
end
----------------------------------------------------------------------------------------------------
-- SetText
function TalkGui_:PlayTalkAsync(talkParam : SystemTypes.TalkParam, isInstant : boolean)
	if isInstant then
		self:PlayTalkInstantAsync(talkParam)
	else
		self:PlayTalkStreamingAsync(talkParam)
	end
end
----------------------------------------------------------------------------------------------------
-- 
function TalkGui_:PlayTalk(text : string, talkTime, imageUrl, nameText, isInstant : boolean)
	if isInstant then
		self:PlayTalkInstant(text, talkTime, imageUrl, nameText)
	else
		self:PlayTalkStreaming(text, talkTime, imageUrl, nameText)
	end
end
----------------------------------------------------------------------------------------------------
-- PlayTalkInstant
function TalkGui_:PlayTalkInstant(text, talkTime, imageUrl, nameText)
	task.spawn(function()
		self:PlayTalkInstantAsync(text, talkTime, imageUrl, nameText)
	end)
end
----------------------------------------------------------------------------------------------------
-- 
function TalkGui_:PlayTalkInstantAsync(text, talkTime, imageUrl, nameText)
	self:Show()
	self.talkText.Text = text
	task.wait(SystemDefine.DEFAULT_TALK_TIME)
	self:Hide()
end
----------------------------------------------------------------------------------------------------
-- PlayTalkSequential
function TalkGui_:PlayTalkStreaming(text, _talkTime, imageUrl, nameText)
	task.spawn(function()
		self:PlayTalkStreamingAsync(text, _talkTime, imageUrl, nameText)
	end)
end
----------------------------------------------------------------------------------------------------
-- 
-- 
function TalkGui_:PlayTalkStreamingAsync(talkParam : SystemTypes.TalkParam)
	if self.talkTask then
		task.cancel(self.talkTask)
	end

	self.isTalkEnd = false
	self:setTextShown(false)
	if talkParam.TalkerModel then
		self:setupTalkerViewportFrame(talkParam.TalkerModel)
		-- 距離で自動閉じ
		if talkParam.AutoDistanceHide then
			self:SetupAutoDistanceHide(talkParam.TalkerModel:GetPivot().Position, 15)
		else
			self:ClearAutoDistanceHide()
		end
	end
	if self.talkerImage and talkParam.Image then
		self.talkerImage.Image = talkParam.Image or ""
	end
	if self.talkerName and talkParam.Name then
		self.talkerName.Text = talkParam.Name or ""
	end

	if not self:IsShow() then
		self:Show()
	end

	local props = {
		TextColor3 = "White",
		TextScale = 0.5,
		Font = "Roboto",
		-- FontFace = Font.new("rbxassetid://12187371324", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	}

	local text = talkParam.Text
	self.textObj = RichText:New(self.talkTextFrame, text, props)
	self.talkTask = task.spawn(function()
		self.textObj:Animate(true)
		self:setTextShown(true)
		if talkParam.TalkTime then
			task.wait(talkParam.TalkTime)
			self:Hide()
		end
	end)
	
	if talkParam.IsWaitInput or talkParam.TalkTime ~= nil then
		-- Hideしないで待機
	else
		self:Hide()
	end
end
----------------------------------------------------------------------------------------------------
-- Yeild
function TalkGui_:Yeild()
	self.yieldCo = coroutine.create(function()
		coroutine.yield()
	end)
end
----------------------------------------------------------------------------------------------------
-- Resume
function TalkGui_:Resume()
	if self.yieldCo then
		coroutine.resume(self.yieldCo)
	end
end

-- Resume
function TalkGui_:OnHide()
	self.isTalkEnd = true
end

return TalkGui_