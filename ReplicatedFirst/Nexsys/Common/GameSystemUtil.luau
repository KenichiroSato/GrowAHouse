local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
--- @class GameSystemUtil : table
local GameSystemUtil = {}

----------------------------------------------------------------------------------------------------
-- MakeAssetIdTextFromId
function GameSystemUtil.MakeAssetIdTextFromId(assetId : number) : string
	return "rbxassetid://" .. assetId
end
----------------------------------------------------------------------------------------------------
-- WwaitTimeがある場合常に検索なので負荷は高めなのに注意
-- WaitTimeがない場合ブロックしっぱなしになりえるのに注意
-- 基本的には非推奨メソッドとなる、ancestorのAtomic + FindFistChild が推奨
function GameSystemUtil.WaitForDescendant(ancestor : Instance, name : string, waitTime : number?) : Instance
	if waitTime then
		local startTime = os.clock()
		
		while true do
			local obj = ancestor:FindFirstChild(name, true)
			if obj then
				return obj
			end
			
			if waitTime and (os.clock() - startTime >= waitTime) then
				warn("WaitForDescendant timeout", ancestor.Name, name, waitTime)
				return nil
			end
			
			-- 短い間隔で定期的にチェック
			task.wait(0.1)
		end
	else
		-- 非推奨なのでwarn
		warn("WaitForDescendant is deprecated", ancestor.Name, name)

		local obj = ancestor:FindFirstChild(name, true)
		while not obj do
			ancestor.DescendantAdded:Wait()
			obj = ancestor:FindFirstChild(name, true)
		end
		return obj
	end
end
----------------------------------------------------------------------------------------------------
-- FindInstanceFromPath
function GameSystemUtil.FindInstanceFromPath(path : string) : Instance
	local parts = string.split(path, ".")
	local current = game
	
	for _, part in ipairs(parts) do
		current = current:FindFirstChild(part)
		if not current then
			return nil
		end
	end
	
	return current
end
----------------------------------------------------------------------------------------------------
-- FindFirstTaggedChild
function GameSystemUtil.FindFirstTaggedChild(ancestor : Instance, tag : string) : Instance
	for _, child in ipairs(ancestor:GetChildren()) do
		if child:HasTag(tag) then
			return child
		end
	end
	return nil
end
----------------------------------------------------------------------------------------------------
-- GetTaggedChildren
function GameSystemUtil.GetTaggedChildren(ancestor : Instance, tag : string) : {Instance}
	local children = {}
	for _, child in ipairs(ancestor:GetChildren()) do
		if child:HasTag(tag) then
			table.insert(children, child)
		end
	end
	return children
end
----------------------------------------------------------------------------------------------------
-- PlayTween
function GameSystemUtil.PlayTween(ins : Instance, sapn : number, goalParam : table, easingStyle : Enum.EasingStyle?, easingDirection : Enum.EasingDirection?, repeatCount : number?, reverse : boolean?)
	local tweenInfo = TweenInfo.new(sapn, easingStyle or Enum.EasingStyle.Linear, easingDirection or Enum.EasingDirection.Out, repeatCount or 0, reverse or false)
	local tween = TweenService:Create(ins, tweenInfo, goalParam)
	tween:Play()
end

----------------------------------------------------------------------------------------------------
-- マーカーとして利用するだけのパーツ(Attachment代わり)としてセットアップ
function GameSystemUtil.SetToMarkerPart(part : BasePart)
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Massless = true
	part.Anchored = true
	part:AddTag("NoFadeIn")
end
----------------------------------------------------------------------------------------------------
--- Modelの中心に ProximityPromptを作成
--- アンカーされてない場合位置がずれるのに注意
function GameSystemUtil.MakePromptOnModelPivot(model : Model, offset : Vector3?, withWeld : boolean?) : ProximityPrompt
	local part = Instance.new("Part")
	GameSystemUtil.SetToMarkerPart(part)
	part.Name = "SystemPromptPart"
	local cf = model:GetPivot()
	if offset then
		cf = cf + offset
	end
	part:PivotTo(cf)
	part.Parent = model
	return GameSystemUtil.MakePromptOnPart(part)
end
----------------------------------------------------------------------------------------------------
-- MakePromptOnPart
function GameSystemUtil.MakePromptOnPart(part : Part) : ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	return prompt
end
----------------------------------------------------------------------------------------------------
-- 
function GameSystemUtil.MakeAttachmentOnModelPivot(model : Model, offset : Vector3?, attachName : string?) : Attachment
	local part = Instance.new("Part", model)
	GameSystemUtil.SetToMarkerPart(part)
	part.Name = "SystemAttachPart"
	local cf = model:GetPivot()
	if offset then
		cf = cf + offset
	end
	part:PivotTo(cf)
	local attach = Instance.new("Attachment", part)
	attach.Name = attachName or "PivotAttach"
	return attach, part
end
----------------------------------------------------------------------------------------------------
-- SetSEOnModelPivot
function GameSystemUtil.SetSEOnModelPivot(model : Model, seName : string, offset : Vector3?)
	local seOrg : Sound = SoundService:FindFirstChild(seName, true)
	if not seOrg then
		warn("SetSEOnModelPivot se not found", seName)
		return
	end

	local part = Instance.new("Part", model)
	GameSystemUtil.SetToMarkerPart(part)
	part.Name = "SystemSEPart"
	local cf = model:GetPivot()
	if offset then
		cf = cf + offset
	end
	part:PivotTo(cf)
	local se = seOrg:Clone()
	se.Parent = part
	return se
end
----------------------------------------------------------------------------------------------------
-- SetSEOnModelPivot
function GameSystemUtil.SetSoundEffectsOnModelPivot(model : Model, ses : {Sound}, offset : Vector3?)
	local part = Instance.new("Part", model)
	GameSystemUtil.SetToMarkerPart(part)
	part.Name = "SystemSEPart"
	local cf = model:GetPivot()
	if offset then
		cf = cf + offset
	end
	part:PivotTo(cf)

	local clones = {}
	for _, seOrg in ipairs(ses) do
		local se = seOrg:Clone()
		se.Parent = part
		clones[se.Name] = se
	end
	return clones
end
----------------------------------------------------------------------------------------------------
-- SetSEOnModelPivot
function GameSystemUtil.SetSoundEffectsByNameOnModelPivot(model : Model, seNames : {string}, offset : Vector3?)
	local part = Instance.new("Part", model)
	GameSystemUtil.SetToMarkerPart(part)
	part.Name = "SystemSEPart"
	local cf = model:GetPivot()
	if offset then
		cf = cf + offset
	end
	part:PivotTo(cf)

	local ses = {}
	for _, seName in ipairs(seNames) do
		local seOrg : Sound = SoundService:FindFirstChild(seName, true)
		local se = seOrg:Clone()
		se.Parent = part
		ses[seName] = se
	end
	return ses
end
----------------------------------------------------------------------------------------------------
-- GetNearestInstance
function GameSystemUtil.GetNearestInstance(pos : Vector3, instances : {PVInstance}) : (Instance?, number?)
	local nearest = nil
	local minDist = math.huge
	for _, ins in ipairs(instances) do
		local dist = (ins:GetPivot().Position - pos).Magnitude
		if dist < minDist then
			minDist = dist
			nearest = ins
		end
	end
	return nearest, minDist
end
----------------------------------------------------------------------------------------------------
-- GetToolOwnerCharacter
function GameSystemUtil.GetToolOwnerCharacter(tool : Tool) : Model?
	local owner = tool.Parent
	if not owner then
		return nil
	end
	if owner:IsA("Model") then
		return owner
	elseif owner:IsA("Backpack") then
		local player : Player = owner.Parent
		if player then
			return player.Character
		end
	end
	return nil
end
----------------------------------------------------------------------------------------------------
-- R6のパーツ名から対応するR15のパーツ名取得
function GameSystemUtil.GetR15PartNameFromR6PartName(r6PartName : string) : string
	if r6PartName == "Torso" then
		-- return "UpperTorso"
		return "HumanoidRootPart"
	elseif r6PartName == "Left Arm" then
		return "LeftLowerArm"
	elseif r6PartName == "Right Arm" then
		return "RightLowerArm"
	elseif r6PartName == "Left Leg" then
		return "LeftLowerLeg"
	elseif r6PartName == "Right Leg" then
		return "RightLowerLeg"
	end

	return r6PartName
end
----------------------------------------------------------------------------------------------------
-- WeldToPart
function GameSystemUtil.WeldToPart(parentPart : BasePart, weldPart : BasePart)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = parentPart
	weld.Part1 = weldPart
	weld.Parent = weldPart
end
----------------------------------------------------------------------------------------------------
-- DeleteAllWeldConstraints
function GameSystemUtil.DeleteAllWeldConstraints(ins : Instance)
	for _, child in ins:GetChildren() do
		if child:IsA("ManualWeld") or child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("Snap") then
			child:Destroy()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- PopUpWithBillboard_Broadcast
function GameSystemUtil.PopUpWithBillboard_Broadcast(billboardGui : BillboardGui, str : string)
	local ServerScriptService = game:GetService("ServerScriptService")
	local ServerRemoteSender = require(ServerScriptService.Nexsys.ServerRemoteSender)
	ServerRemoteSender.SendEventToAll("RSC_Sys_PopUpWithBillboard", billboardGui, str)
end

return GameSystemUtil