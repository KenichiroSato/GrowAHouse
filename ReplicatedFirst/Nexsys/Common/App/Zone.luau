local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local zoneplus = require(ReplicatedStorage.Packages.zoneplus)

--- @class Zone : table
local Zone = {}
Zone.__index = Zone

Zone.LocalPlayerEntered = Instance.new("BindableEvent")

----------------------------------------------------------------------------------------------------
-- 
function Zone.new(container)
	local self = setmetatable({}, Zone)
	Zone.Init(self, container)
	return self
end

function Zone:Init(container)
	self.zone = zoneplus.new(container)
end

----------------------------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------------------------
if RunService:IsClient() then
----------------------------------------------------------------------------------------------------
-- 
function Zone:ConnectLocalPlayerEntered(func) : RBXScriptConnection
	local connection = self.zone.playerEntered:Connect(function(player)
		if player == game.Players.LocalPlayer then
			func(player)
		end
	end)
	return connection
end
----------------------------------------------------------------------------------------------------
-- 
function Zone:ConnectLocalPlayerExited(func) : RBXScriptConnection
	local connection = self.zone.playerExited:Connect(function(player)
		if player == game.Players.LocalPlayer then
			func(player)
		end
	end)
	return connection
end
----------------------------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------------------------
end

return Zone