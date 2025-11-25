local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)
local MathUtil = require(ReplicatedFirst.Nexsys.Common.MathUtil)

--- @class PopUp_ : table
local PopUp_ = {}
PopUp_.__index = PopUp_
----------------------------------------------------------------------------------------------------
-- getDefaultPopUpText
function PopUp_.getPopUpTextLabel(popType)
	local gui: ScreenGui = PlayerGui:WaitForChild("PopUpGui")
	if not gui then
		return
	end

	local textName = "PopUpText"
	if popType then
		local customTextLabel = gui:FindFirstChild(textName .."_"..popType, true)
		if customTextLabel then
			return customTextLabel
		end
	end

	local baseTextLabel = gui[textName]
	return baseTextLabel
end
----------------------------------------------------------------------------------------------------
-- getPopUpFrame
function PopUp_.getPopUpFrame(popType) : Frame
	local gui: ScreenGui = PlayerGui:WaitForChild("PopUpGui")
	if not gui then
		return
	end

	local frameName = "Popup"
	if popType then
		local customFrame = gui:FindFirstChild(frameName .."_"..popType, true)
		if customFrame then
			return customFrame
		end
	end

	local baseFrame = gui:FindFirstChild(frameName, true)
	return baseFrame
end

----------------------------------------------------------------------------------------------------
-- 生成関数
----------------------------------------------------------------------------------------------------
function PopUp_.newBase(str, baseText: TextLabel, udim2Pos: UDim2, param: SystemTypes.PopUpParam?)
	local self = setmetatable({}, PopUp_)
	if param and param.IsScatterAnim then
		self:ExecuteRSCAnimation(str, baseText, udim2Pos, param)
	else
		self:Execute(str, baseText, udim2Pos, param)
	end
	return self
end
----------------------------------------------------------------------------------------------------
--
function PopUp_.newFromScreenPos(str, screenPos: Vector2, popType, param: SystemTypes.PopUpParam)
	local udim2Pos = UDim2.fromOffset(screenPos.X, screenPos.Y)
	local frame = PopUp_.getPopUpFrame(popType)

	return PopUp_.newBase(str, frame, udim2Pos, param)
end
----------------------------------------------------------------------------------------------------
-- fromWorldPosition
function PopUp_.newFromWorldPosition(str, worldPosition: Vector3, popType, param: SystemTypes.PopUpParam?)
	local camera = workspace.CurrentCamera
	local screenPosition = camera:WorldToScreenPoint(worldPosition)
	-- 画面内強制表示テスト
	-- if screenPosition.Y < 0 then
	-- 	screenPosition = Vector2.new(screenPosition.X, 30)
	-- end
	local udim2Pos = UDim2.fromOffset(screenPosition.X, screenPosition.Y)
	local popUpText = PopUp_.getPopUpFrame(popType)

	return PopUp_.newBase(str, popUpText, udim2Pos, param)
end
----------------------------------------------------------------------------------------------------
-- newFromBillboardGui
function PopUp_.newFromBillboardGui(str, billboardGui : BillboardGui, param : SystemTypes.PopUpParam)
	if not billboardGui then
		warn("PopUp_.newFromBillboardGui billboardGui not set", str)
		return
	end
	local frame = billboardGui:FindFirstChildWhichIsA("Frame", true)
	if not frame then
		warn("PopUp_.newFromBillboardGui frame not found")
		return
	end
	PopUp_.newFromFrame(str, frame, param)
end
----------------------------------------------------------------------------------------------------
-- TextLabelのパラメータそのまま利用する、BillboardGuiのTextLabelなどで使用
function PopUp_.newFromFrame(str, frame : TextLabel, param : SystemTypes.PopUpParam)
	return PopUp_.newBase(str, frame, frame.Position, param)
end
----------------------------------------------------------------------------------------------------
-- 
function PopUp_.newFromPopType(str, popType, param)
	local popupFrame = PopUp_.getPopUpFrame(popType)
	PopUp_.newBase(str, popupFrame, popupFrame.Position, param)
end

----------------------------------------------------------------------------------------------------
-- 再生
-- 基本は
----------------------------------------------------------------------------------------------------
-- Execute
function PopUp_:Execute(str, baseFrame: Frame, udim2Pos: UDim2, param: SystemTypes.PopUpParam)
	local frame = baseFrame:Clone()
	frame.Visible = true
	frame.Position = udim2Pos

	local text : TextLabel = frame:FindFirstChildWhichIsA("TextLabel", true)
	text.Text = str

	if param and param.ImageId then
		local image = frame:FindFirstChildWhichIsA("ImageLabel", true)
		image.Image = param.ImageId
	end

	if param and param.OffsetRange then
		local randX = math.random(-param.OffsetRange.X, param.OffsetRange.X)
		local randY = math.random(-param.OffsetRange.Y, param.OffsetRange.Y)
		frame.Position = UDim2.fromOffset(udim2Pos.X.Offset + randX, udim2Pos.Y.Offset + randY)
	end
	if param and param.OffsetScaleRangeMinMax then
		local min = param.OffsetScaleRangeMinMax[1]
		local max = param.OffsetScaleRangeMinMax[2]
		local scaleOfsX = MathUtil.GetRandomFloat(min.X, max.X)
		local scaleOfsY = MathUtil.GetRandomFloat(min.Y, max.Y)
		frame.Position = frame.Position + UDim2.fromScale(scaleOfsX, scaleOfsY)
	end
	if param and param.FixedOffset then
		-- 固定の OffsetPos での位置調整
		local basePos = frame.Position
		frame.Position = UDim2.new(
			basePos.X.Scale,
			basePos.X.Offset + param.FixedOffset.X,
			basePos.Y.Scale,
			basePos.Y.Offset + param.FixedOffset.Y
		)
	end
	if param and param.Color then
		text.TextColor3 = param.Color
	end
	if param and param.IsBold then
		text.FontFace.Bold = true
	end
	if param and param.Scale then
		frame.Size = UDim2.new(
			frame.Size.X.Scale * param.Scale,
			frame.Size.X.Offset * param.Scale,
			frame.Size.Y.Scale * param.Scale,
			frame.Size.Y.Offset * param.Scale
		)
	end
	local SHOW_TIME = 2
	if param and param.ShowTime then
		SHOW_TIME = param.ShowTime
	end

	local PopUpGui = PlayerGui:WaitForChild("PopUpGui")
	if not PopUpGui.Enabled then
		warn("PopUpGui not enabled, set Enabled")
		PopUpGui.Enabled = true
	end

	if param and param.IsSetGuiParent then
		frame.Parent = PopUpGui
	else
		frame.Parent = baseFrame.Parent
	end

	if param and param.IsFadeOut then
		self:playTweenWithFadeOut(frame, SHOW_TIME)
	else
		task.spawn(function()
			local tweenInfo = TweenInfo.new(SHOW_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local goalOfs = param and param.GoalOffsetUdim2
			if not goalOfs then
				if frame:IsDescendantOf(PlayerGui) then
					-- ScreenGui想定、例外があればパラメータで指定
					goalOfs = UDim2.fromOffset(0, -60)
				else
					-- 主にBillboardGuiの場合はスケールでやる、じゃないと範囲外に出て切れる
					goalOfs = UDim2.fromScale(0, -0.3)
				end
			end

			local goal = { Position = frame.Position + goalOfs }
			local tween = TweenService:Create(frame, tweenInfo, goal)
			tween:Play()

			task.wait(SHOW_TIME)
			if param and param.MoveToPos then
				local MOVE_TIME = 0.6
				local moveTweenInfo = TweenInfo.new(MOVE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local goal = { Position = UDim2.fromOffset(param.MoveToPos.X, param.MoveToPos.Y) }
				local tween = TweenService:Create(frame, moveTweenInfo, goal)
				tween:Play()
				task.wait(MOVE_TIME)
			end
			frame:Destroy()
		end)
	end
end
----------------------------------------------------------------------------------------------------
-- playWithFadeOut
function PopUp_:playTweenWithFadeOut(frame: Frame, showTime)
	-- フェードアウト用
	task.spawn(function()
		local FADE_TIME = 0.5
		task.wait(showTime - FADE_TIME)
		local elems = frame:GetDescendants()
		elems[#elems + 1] = frame
		for _, elem in ipairs(elems) do
			local propName = nil
			-- UIGradientはNumberSequenceなので特殊対応
			if elem:IsA("UIGradient") then
				elem = elem :: UIGradient
				local valIns = Instance.new("NumberValue")
				valIns.Value = elem.Transparency.Keypoints[1].Value
				valIns.Changed:Connect(function()
					elem.Transparency = NumberSequence.new(valIns.Value)
				end)
				local tweenInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				local goal = { Value = 1 }
				local tween = TweenService:Create(valIns, tweenInfo, goal)
				tween:Play()
			else
				if elem:IsA("TextLabel") then
					propName = "TextTransparency"
				elseif elem:IsA("UIStroke") then
					propName = "Transparency"
				end

				if propName then
					local tweenInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
					local goal = { [propName] = 1 }
					local tween = TweenService:Create(frame, tweenInfo, goal)
					tween:Play()
				else
					warn("not impl popup fadeout elem", elem)
				end
			end
		end
	end)
end
----------------------------------------------------------------------------------------------------
-- 
function PopUp_:ExecuteRSCAnimation(str, baseFrame: Frame, udim2Pos: UDim2, param: SystemTypes.PopUpParam)
	local targetAbsolutePos = param.ScatterAnimTargetPos
	local clones = {}
	local SHOW_TIME = 0.7
	local MOVE_TIME = 1
	local parent = baseFrame.Parent

	for i = 1, 20 do
		local cframe = baseFrame:Clone()
		cframe.Visible = true
		cframe.Position = udim2Pos
		cframe.Parent = parent
		table.insert(clones, cframe)
	end


	local relativePosition = targetAbsolutePos - parent.AbsolutePosition
	local targetPos = UDim2.fromOffset(relativePosition.X, relativePosition.Y)

	for _, frame in ipairs(clones) do

		task.spawn(function()
			PopUp_:moveInCircle(frame, baseFrame, math.random(10, 200), math.random(-7 , 7))
			task.wait(SHOW_TIME)

			local tweenInfo = TweenInfo.new(MOVE_TIME,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out)

			local goal = { Position = targetPos }
			local tween = TweenService:Create(frame, tweenInfo, goal)
			tween:Play()

			task.wait(MOVE_TIME)
			frame:Destroy()
		end)
	end
end

-- Function to move the part in a circle around the center part
function PopUp_:moveInCircle(uiElement, center, radius, angle)
	local centerX = center.AbsolutePosition.X + center.AbsoluteSize.X / 2
	local centerY = center.AbsolutePosition.Y + center.AbsoluteSize.Y / 2
	local x = centerX + radius * math.cos(angle) - uiElement.AbsoluteSize.X / 2
	local y = centerY + radius * math.sin(angle) - uiElement.AbsoluteSize.Y / 2
	--uiElement.Position = UDim2.new(0, x, 0, y)
	local tweenInfo = TweenInfo.new(0.2,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out)

	local goal = { Position = UDim2.new(0, x, 0, y) }
	local tween = TweenService:Create(uiElement, tweenInfo, goal)
	tween:Play()
end

return PopUp_