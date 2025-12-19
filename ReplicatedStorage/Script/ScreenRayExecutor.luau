
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local STR = require(ReplicatedStorage:WaitForChild("Script"):WaitForChild("Strings"))

local ScreenRayExecutor = {}

local function getHitRoot(hit: Instance): Instance?
	if not hit then return nil end
	local parent = hit.Parent
	if hit:IsA("BasePart") and 
		parent and 
		parent:IsA("Model") and 
		parent.Name ~= "Workspace" 
	then
		return hit.Parent
	end
	return hit
end

local function findDeletableAncestor(root: Instance): Instance?
	local cur = root
	while cur and cur ~= workspace do
		if CollectionService:HasTag(cur, STR.TAG_Deletable) then
			return cur
		end
		cur = cur.Parent
	end
	return nil
end

local function isOwnedByPlayer(root: Instance, player: Player): boolean
	local cur = root
	while cur and cur ~= workspace do
		local owner = cur:GetAttribute(STR.OwnerUserId)
		if owner ~= nil then
			return tonumber(owner) == player.UserId
		end
		cur = cur.Parent
	end
	return false
end

function ScreenRayExecutor.FindPlayerOwnedInstance(player: Player, ray: Ray, excludes: {}): Instance?
	local origin = ray.Origin--camera.CFrame.Position
	local direction = ray.Direction * 500 --camera.CFrame.LookVector * 100

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = excludes
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, params)

	if result and result.Instance then
		local root = getHitRoot(result.Instance)
		if not root then return nil end

		local deletable = findDeletableAncestor(root)
		if not deletable then return nil end

		if not isOwnedByPlayer(deletable, player) then return nil end
		return deletable
	end
	return nil
end


return ScreenRayExecutor
