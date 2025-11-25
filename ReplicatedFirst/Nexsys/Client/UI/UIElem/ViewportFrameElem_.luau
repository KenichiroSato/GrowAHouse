local ReplicatedFirst = game:GetService("ReplicatedFirst")
local GuiObject_ = require(ReplicatedFirst.Nexsys.Client.UI.UIElem.GuiObject_)

--- @class ViewportFrameElem_ : GuiObject_
local ViewportFrameElem_ = {}
ViewportFrameElem_.__index = ViewportFrameElem_
setmetatable(ViewportFrameElem_, GuiObject_)

----------------------------------------------------------------------------------------------------
-- 
function ViewportFrameElem_.new(viewportFrame : ViewportFrame)
	local self = setmetatable(GuiObject_.new(viewportFrame), ViewportFrameElem_)
	ViewportFrameElem_.Init(self, viewportFrame)
	return self
end

function ViewportFrameElem_:Init(viewportFrame : ViewportFrame)
	self.viewportFrame = viewportFrame
	-- worldModelを使うのを基本とする(不要なことがでるならオプション化)
	self.worldModel = viewportFrame:FindFirstChildOfClass("WorldModel")
	if not self.worldModel then
		self.worldModel = Instance.new("WorldModel")
		self.worldModel.Parent = viewportFrame
	end
	self.modelParent = self.worldModel

	local camera = viewportFrame:FindFirstChildOfClass("Camera")
	if not camera then
		camera = Instance.new("Camera")
		camera.Parent = viewportFrame
		camera.CFrame = CFrame.new(Vector3.new(0, 1, -3), Vector3.new(0, 0, 0))
		camera.Focus = CFrame.new()
		-- camera.FieldOfView = 70
	end

	-- local cf = CFrame.new(Vector3.new(0, 1, 3), Vector3.new(0, 0, 0))
	-- local focus = CFrame.new()
	-- self:SetCamera(cf, focus)
	self.viewportFrame.CurrentCamera = camera
end
----------------------------------------------------------------------------------------------------
-- GetViewportFrame
function ViewportFrameElem_:GetViewportFrame()
	return self.viewportFrame
end
----------------------------------------------------------------------------------------------------
-- GetFirstModel
function ViewportFrameElem_:GetFirstModel() : Model?
	local children = self.modelParent:GetChildren()
	for _, child in children do
		if child:IsA("Model") then
			return child
		end
	end
	return nil
end
----------------------------------------------------------------------------------------------------
-- SetAutoAdjustActive
function ViewportFrameElem_:SetAutoAdjustModelActive(val : boolean)
	self.isAutoAdjustModel = val
end
----------------------------------------------------------------------------------------------------
-- SetModelCenterlize
function ViewportFrameElem_:SetModelCenterlize(centerize : boolean)
	self.isModelCenterize = centerize
end
----------------------------------------------------------------------------------------------------
-- SetModelOrientation
function ViewportFrameElem_:SetModelOrientation(orientation : Vector3)
	self.modelOrientation = orientation
end
----------------------------------------------------------------------------------------------------
-- SetCamera
function ViewportFrameElem_:SetCamera(camraCFrame : CFrame, focus : CFrame)
	local camera = self.viewportFrame.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Fixed
		camera.CFrame = camraCFrame
		camera.Focus = focus
	end
end
----------------------------------------------------------------------------------------------------
-- SetCameraFromPosition
function ViewportFrameElem_:SetCameraFromPosition(position : Vector3, focus : Vector3)
	local camera = self.viewportFrame.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Fixed
		camera.CFrame = CFrame.new(position, focus)
		camera.Focus = CFrame.new(focus)
	end
end
----------------------------------------------------------------------------------------------------
-- ClearModel
function ViewportFrameElem_:ClearAllChildren()
	self.modelParent:ClearAllChildren()
end
----------------------------------------------------------------------------------------------------
-- ClearAllModel
function ViewportFrameElem_:ClearAllModel()
	local children = self.modelParent:GetChildren()
	for _, child in children do
		if child:IsA("Model") or child:IsA("BasePart") then
			child:Destroy()
		end
	end
end
----------------------------------------------------------------------------------------------------
-- ViewportにModel追加(自動的にCloneされる)
function ViewportFrameElem_:AddModel(model : Model, noClone : boolean)
	local viewModel = noClone and model or model:Clone()
	-- Modelは先に親は移してからPivotいじったほうがよい
	viewModel.Parent = self.modelParent

	-- 位置調整
	local posOfs = model:GetAttribute("ViewPos")
	local cf = CFrame.new()
	if posOfs then
		viewModel:PivotTo(cf + posOfs)
	elseif self.isModelCenterize then
		-- BBの中心を0になるように移動する : 未検証
		local centerCf, size = model:GetBoundingBox()
		local diff = viewModel:GetPivot().Position - centerCf.Position
		viewModel:PivotTo(cf + diff)
	else
		viewModel:PivotTo(cf)
	end

	local scale = model:GetAttribute("ViewScale")
	if scale and scale > 0 then
		viewModel:ScaleTo(scale)
	end
	local ori = model:GetAttribute("ViewOrientation")
	if not ori and self.modelOrientation then
		ori = self.modelOrientation
	end
	if ori then
		local rotCf = CFrame.fromOrientation(math.rad(ori.X), math.rad(ori.Y), math.rad(ori.Z))
		local rotedCf = viewModel:GetPivot() * rotCf
		viewModel:PivotTo(rotedCf)
	end

	if self.isAutoAdjustModel then
		self:AutoAdjustModel(viewModel)
	end
end
----------------------------------------------------------------------------------------------------
-- AdjustModelAndCamera
function ViewportFrameElem_:AutoAdjustModel(model : Model)
	local centerCf, size = model:GetBoundingBox()

	-- 指定がない場合に、サイズを収まるくらいにする
	local scaleParam = model:GetAttribute("ViewScale")
	if not scaleParam then
		local TARGET_SIZE = 2
		-- TargetSize Studs に収まるようにする
		local maxSize = math.max(size.X, size.Y, size.Z)
		local scale = TARGET_SIZE / maxSize
		local curScale = model:GetScale()
		model:ScaleTo(scale * curScale)
		centerCf, size = model:GetBoundingBox()
	end

	-- 中央に配置
	local diff = model:GetPivot().Position - centerCf.Position
	model:PivotTo(model:GetPivot() + diff)
end

return ViewportFrameElem_