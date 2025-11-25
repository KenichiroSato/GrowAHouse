local BadgeService = game:GetService("BadgeService")

local BadgeManager = {}
BadgeManager.__index = BadgeManager

function BadgeManager.AwardBadge(player: Player, badgeId)
	print("AwardBadge called", player.UserId, badgeId)
	-- Fetch Badge information
	local success, badgeInfo = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, badgeId)
	if success then
		-- Confirm that badge can be awarded
		if badgeInfo.IsEnabled then
			-- Award badge
			local awarded, errorMessage = pcall(BadgeService.AwardBadge, BadgeService, player.UserId, badgeId)
			if awarded then
				print("Badge awarded:", player.UserId, badgeId)
			else
				warn("Error while awarding Badge:", errorMessage)
			end
		else
			warn("Badge is not enabled", badgeId)
		end
	else
		warn("Error while fetching Badge info!")
	end
end

return BadgeManager