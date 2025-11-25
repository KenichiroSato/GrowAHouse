local MathUtil = {}

-- Vector3のFuzzyEqと同じ
MathUtil.EPSILON = 1e-5
----------------------------------------------------------------------
-- 基本
----------------------------------------------------------------------
function MathUtil.GetVectorRotationY(v : Vector3)
	return math.atan2(v.X, v.Z)
end

function MathUtil.GetVectorRotationX(v : Vector3)
	local xzVec = Vector2.new(v.X, v.Z)
	local xzLen = xzVec.Magnitude
	return math.atan2(v.Y, xzLen)
end
----------------------------------------------------------------------
-- 
function MathUtil.GetRotationYVector(rotY) : Vector3
	return Vector3.new(math.sin(rotY), 0, math.cos(rotY))
end
----------------------------------------------------------------------
-- 
function MathUtil.GetYRotatedVector(vec : Vector3, rotDeg)
	local newVec = CFrame.fromEulerAnglesXYZ(0, math.rad(rotDeg), 0) * vec
	return newVec

	-- local origin = Vector3.new(0, 0, 0)
	-- local vectorToRotate = Vector3.new(1, 0, 0) -- 例として、X軸方向のベクトルを使います
	-- local rotationAxis = Vector3.new(0, 1, 0) -- Y軸を中心とする回転
	-- local rotationAngle = math.rad(90) -- 90度回転させる

	-- local rotatedVector = (CFrame.new(origin) * CFrame.fromAxisAngle(rotationAxis, rotationAngle) * CFrame.new(vectorToRotate)).Position
end
----------------------------------------------------------------------------------------------------
-- 2つのベクトルの間の角度を取得
-- @param v1 ベクトル1
-- @param v2 ベクトル2
-- @return ラジアン角度
----------------------------------------------------------------------------------------------------
function MathUtil.GetAngleBetweenVectors(v1 : Vector3, v2 : Vector3)
	local dot = v1:Dot(v2)
	local len1 = v1.Magnitude
	local len2 = v2.Magnitude
	local cos = dot / (len1 * len2)
	local rad = math.acos(cos)
	return rad
end
----------------------------------------------------------------------------------------------------
-- NormalizeAngle
function MathUtil.NormalizeAngle(angle)
	return (angle + math.pi) % (2 * math.pi) - math.pi
end

----------------------------------------------------------------------
-- targetPosからoffset手前の位置を取得
function MathUtil.GetOffsetTargetPosition(targetPos : Vector3, fromPos : Vector3, offset) : Vector3
	local dir = targetPos - fromPos
	local offsetPos = targetPos - dir.Unit * offset
	return offsetPos
end
----------------------------------------------------------------------
-- 
function MathUtil.IsZeroVector3(v : Vector3)
	if math.abs(v.X) < MathUtil.EPSILON and 
		math.abs(v.Y) < MathUtil.EPSILON and 
		math.abs(v.Z) < MathUtil.EPSILON then
		return true
	end
end
----------------------------------------------------------------------------------------------------
-- Vector3SafeUnit
function MathUtil.SafeUnitVector3(v : Vector3)
	if MathUtil.IsZeroVector3(v) then
		return Vector3.zero
	end
	return v.Unit
end
----------------------------------------------------------------------------------------------------
-- GetXZVector3
function MathUtil.GetXZVector3(v : Vector3)
	return Vector3.new(v.X, 0, v.Z)
end
----------------------------------------------------------------------------------------------------
-- GetUnitXZVector3
function MathUtil.GetUnitXZVector3(v : Vector3)
	return Vector3.new(v.X, 0, v.Z).Unit
end
----------------------------------------------------------------------------------------------------
-- GetSafeUnitXZVector3
function MathUtil.GetSafeUnitXZVector3(v : Vector3)
	return MathUtil.SafeUnitVector3(Vector3.new(v.X, 0, v.Z))
end
----------------------------------------------------------------------------------------------------
-- GetVector3LengthXZ
function MathUtil.GetVector3LengthXZ(v : Vector3)
	return Vector2.new(v.X, v.Z).Magnitude
end
----------------------------------------------------------------------
-- CFrameが一致しているかチェック
function MathUtil.IsSameCFrame(cf1 : CFrame, cf2 : CFrame, epsilon) : boolean
	-- 誤差が出やすいので少し大き目のEpsilonで
	-- epsilon = epsilon or 0.0001
	epsilon = epsilon or MathUtil.EPSILON

	local posResult = cf1.Position:FuzzyEq(cf2.Position, epsilon)
	if not posResult then
		return false
	end

	local rotResult = cf1.LookVector:FuzzyEq(cf2.LookVector, epsilon)
	if not rotResult then
		return false
	end

	return true
end
----------------------------------------------------------------------------------------------------
-- 小数点以下の桁数を指定した値を取得
function MathUtil.Round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end
----------------------------------------------------------------------------------------------------
-- 小数点以下の桁数を指定したVector3を取得
function MathUtil.RoundVector3(v : Vector3, idp)
	return Vector3.new(
		MathUtil.Round(v.X, idp),
		MathUtil.Round(v.Y, idp),
		MathUtil.Round(v.Z, idp)
	)
end
----------------------------------------------------------------------------------------------------
-- 小数点数の数字の乱数を取得
function MathUtil.GetRandomFloat(min, max)
	return min + math.random() * (max - min)
end

return MathUtil