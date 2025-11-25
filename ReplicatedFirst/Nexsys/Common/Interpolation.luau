local Interpolation = {}

Interpolation.Type = {
	Linear = 1,
	QuadBezier = 2,
	CubicBezier = 3,
	Spline = 4,
}

local function lerp(a, b, t)
	return a + (b-a)*t
end

function Interpolation.Lerp(a, b, t)
	return lerp(a, b, t)
end

function Interpolation.EaseIn(a, b, t)
	
end

function Interpolation.EaseOut(a, b, t)
	
end

function Interpolation.EaseInOut(a, b, t)
	
end


function Interpolation.QuadBezier(a, b, c, t)
	local l1 = lerp(a, b, t)
	local l2 = lerp(b, c, t)
	local result = lerp(l1, l2, t)
	return result
end

function Interpolation.CubicBezier(a, b, c, d, t)
	local l1 = Interpolation.QuadBezier(a, b, c, t)
	local l2 = Interpolation.QuadBezier(b, c, d, t)
	local result = lerp(l1, l2, t)
	return result
end

function Interpolation.Spline(a, b, c, d, t)
	local array = {a, b, c, d}
	return Interpolation.Spline(array, t)
end

function Interpolation.SplineWithArray(p, t)
	return p[2] + 0.5 * t*(p[3] - p[1] + t*(2.0*p[1] - 5.0*p[2] + 4.0*p[3] - p[4] + t*(3.0*(p[2] - p[3]) + p[4] - p[1])))
end

----------------------------------------------------------------------
-- インスタンスとして
----------------------------------------------------------------------
Interpolation.__index = Interpolation

function Interpolation.new(...)
	local self = setmetatable({}, Interpolation)
	Interpolation.Init(self, ...)
	return self
end

function Interpolation:Init(type, x0, x1, total)
	self.type = type
	self.x0 = x0
	self.x1 = x1
	self.total = total
	self.current = 0
end

function Interpolation:Update(dt)
	if self.current < self.total then
		self.current += dt
	end
end

function Interpolation:Get()
	local rate = math.max(0, math.min(1, self.current / self.total))
	if self.type == Interpolation.Type.Linear then
		return Interpolation.Lerp(self.x0, self.x1, rate)
	end
end

return Interpolation
