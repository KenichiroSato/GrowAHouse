--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HouseBaseManager = require(ServerScriptService.Nexapp.House.HouseBaseManager)
local Types = require(ReplicatedFirst.Nexapp.Common.Types)

local LocalCordinateHelper = {}

-- 家の建築素材や家具の位置を、家の土台に対する相対座標で保存するためのヘルパークラス

----------------------------------------------
--          Private Method
----------------------------------------------

local function round(n:number, d:number) return math.round(n*10^d)/10^d end

local function toEulerDeg(cf:CFrame)
	local rx, ry, rz = cf:ToOrientation()          -- rad
	return math.deg(rx), math.deg(ry), math.deg(rz)   -- deg
end

local function fromEulerDeg(px,py,pz, rx,ry,rz)
	return CFrame.new(px,py,pz) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
end

-- 相対 ←→ 絶対 変換
local function worldToLocal(baseCF:CFrame, itemCF:CFrame): CFrame
	return baseCF:ToObjectSpace(itemCF)
end

local function localToWorld(baseCF:CFrame, relCF:CFrame): CFrame
	return baseCF * relCF
end

local function getWorldCFrame(target: Instance): CFrame
	if target:IsA("BasePart") then
		--return (target :: BasePart).CFrame
		return (target :: BasePart):GetPivot()
	elseif target:IsA("Model") then
		-- Pivotベース（PrimaryPart未設定でもOK）
		return (target :: Model):GetPivot()
	elseif target:IsA("Attachment") then
		return (target :: Attachment).WorldCFrame
	else
		error("Unsupported target type: " .. target.ClassName)
	end
end
----------------------------------------------
--          Public Method
----------------------------------------------
-- 土台からの相対座標を返す
function LocalCordinateHelper.GetRelativeCordinates(player: Player, instance: Instance): Types.RelativeCoordinates
	local base = HouseBaseManager.GetBase(player)
	local baseCF = getWorldCFrame(base)
	local itemCF = getWorldCFrame(instance)
	local relCF = worldToLocal(baseCF, itemCF)
	local rx, ry, rz = toEulerDeg(relCF)
	local px, py, pz = relCF.Position.X, relCF.Position.Y, relCF.Position.Z
	return {
		px = round(px, 3),
		py = round(py, 3),
		pz = round(pz, 3),
		rx = round(rx, 2),
		ry = round(ry, 2),
		rz = round(rz, 2),
	}
end

function LocalCordinateHelper.ChangeToWorldCordinates(player: Player, houseParts: Types.HousePartArray): {Types.BuildItem}
	local retVal: {Types.BuildItem} = {}
	local base = HouseBaseManager.GetBase(player)
	if not base then return retVal end
	local baseCF = getWorldCFrame(base)
	for _, part in pairs(houseParts) do
		local relCF = fromEulerDeg(part.Rel.px, part.Rel.py, part.Rel.pz, part.Rel.rx, part.Rel.ry, part.Rel.rz)
		local itemCF = localToWorld(baseCF, relCF)
		local lookVector = itemCF.LookVector
		local pitch, yaw, roll = itemCF:ToOrientation()
		local buildItem: Types.BuildItem = {
			Id = part.Id,
			Name = part.ModelName,
			Position = itemCF.Position,
			YawRadian = yaw
		} 
		table.insert(retVal, buildItem)
	end
	return retVal
end

return LocalCordinateHelper
