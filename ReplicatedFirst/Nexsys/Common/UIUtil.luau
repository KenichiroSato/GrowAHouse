local TweenService = game:GetService("TweenService")
--- @class UIUtil : table
local UIUtil = {}

----------------------------------------------------------------------------------------------------
-- GetScaledSize
function UIUtil.GetScaledSize(size: UDim2, scale)
	return UDim2.new(size.X.Scale * scale, size.X.Offset * scale, size.Y.Scale * scale, size.Y.Offset * scale)
end
----------------------------------------------------------------------------------------------------
-- GetAbsoluteCenterPosition
function UIUtil.GetAbsoluteCenterPosition(elem: GuiObject)
	return elem.AbsolutePosition + Vector2.new(elem.AbsoluteSize.X / 2, elem.AbsoluteSize.Y / 2)
end
----------------------------------------------------------------------------------------------------
-- FadeInGui
function UIUtil.FadeInGui(gui: GuiObject, fadeTime: number)
	local fadeFunc = function(elem : GuiObject)
		local tweenInfo = TweenInfo.new(fadeTime)
		if elem:HasTag("NoFadeIn") then
			return
		end

		local propName = nil
		if elem:IsA("Frame") then
			propName = "BackgroundTransparency"
		elseif elem:IsA("TextLabel") then
			propName = "TextTransparency"
		elseif elem:IsA("ImageLabel") then
			propName = "ImageTransparency"
		elseif elem:IsA("UIStroke") then
			propName = "Transparency"
		end

		if propName then
			-- FadeInは共通で透明開始で問題ないはず
			elem[propName] = 1
			local goalProp = { [propName] = 0 }
			local tween = TweenService:Create(elem, tweenInfo, goalProp)
			tween:Play()
		end
	end

	-- Tweenでフェード
	for _index, elem in gui:GetDescendants() do
		fadeFunc(elem)
	end
	fadeFunc(gui)
end
----------------------------------------------------------------------------------------------------
-- FadeOutGui
function UIUtil.FadeOutGui(gui: GuiObject, fadeTime: number)
	local fadeFunc = function(elem : GuiObject)
		local tweenInfo = TweenInfo.new(fadeTime)
		local propName = nil
		if elem:IsA("Frame") then
			propName = "BackgroundTransparency"
		elseif elem:IsA("TextLabel") then
			propName = "TextTransparency"
		elseif elem:IsA("ImageLabel") then
			propName = "ImageTransparency"
		elseif elem:IsA("UIStroke") then
			propName = "Transparency"
		end
		if propName then
			local goalProp = { [propName] = 1 }
			local tween = TweenService:Create(elem, tweenInfo, goalProp)
			tween:Play()
		end
	end

	-- Tweenでフェード
	for _index, elem in gui:GetDescendants() do
		fadeFunc(elem)
	end
	fadeFunc(gui)
end
----------------------------------------------------------------------------------------------------
-- SetUIGradientExclusive
-- elemの子どものUIGradientを指定のNameのものだけ残して他を無効化する
function UIUtil.SetUIGradientExclusive(parentElem, elemName : string)
	for _, elem in ipairs(parentElem:GetChildren()) do
		if elem:IsA("UIGradient") then
			elem.Enabled = elem.Name == elemName
		end
	end
end
----------------------------------------------------------------------------------------------------
-- 
function UIUtil.AnimateUIMove(elem, startPos, goalPos, animTime, style : Enum.EasingStyle?, dir : Enum.EasingDirection?)
	task.spawn(function()
		local tweenInfo = TweenInfo.new(animTime, style or Enum.EasingStyle.Linear, dir or Enum.EasingDirection.In)
		local goalProp = { Position = goalPos }
		local tween = TweenService:Create(elem, tweenInfo, goalProp)
		elem.Position = startPos
		tween:Play()

		--warn("AnimateUIMove", startPos, goalPos, self:IsShow())
		task.wait(animTime)
		elem.Position = goalPos
	end)
end
----------------------------------------------------------------------------------------------------
-- ReplaceText
function UIUtil.ReplaceStrsText(text: string, strs: {string} )
	for i, str in ipairs(strs) do
		text = string.gsub(text, "{str" .. i .. "}", str)
	end
	return text
end
----------------------------------------------------------------------------------------------------
-- ReplaceStrText
function UIUtil.ReplaceStrText(text: string, str: string)
	return string.gsub(text, "{str1}", str)
end
----------------------------------------------------------------------------------------------------
-- GetMinutesSecTextFromSec
function UIUtil.GetMinutesSecTextFromSec(_sec: number)
	local min = math.floor(_sec / 60)
	local sec = _sec % 60
	return string.format("%02d:%02d", min, sec)
end
----------------------------------------------------------------------------------------------------
-- 
function UIUtil.GetHourMinutesSecTextFromSec(_sec: number)
	local hour = math.floor(_sec / 3600)
	local min = math.floor(_sec % 3600 / 60)
	local sec = _sec % 60
	return string.format("%02d:%02d:%02d", hour, min, sec)
end

return UIUtil
