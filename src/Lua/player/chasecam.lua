-- Ringslinger Revolution - Player Chasecam Function(s)

local RSR = RingslingerRev

-- Helper function for setting the player's chasecam
RSR.PlayerSetChasecam = function(player, toggle)
	if not Valid(player) then return end
	if toggle == nil then toggle = false end
	
	-- Only set chasecam for local players
	if player == secondarydisplayplayer then
		camera2.chase = toggle
	elseif player == consoleplayer then
		camera.chase = toggle
	end
end
