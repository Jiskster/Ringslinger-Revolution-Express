-- Ringslinger Revolution - Screen Fade System

local RSR = RingslingerRev

RSR.PlayerScreenFadeInit = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	
	player.rsrinfo.screenFade = {
		tics = 0,
		origTics = 0,
		color = 0,
		strength = 0
	}
end

RSR.SetScreenFade = function(player, color, strength, tics)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.screenFade) then return end
	if color == nil or strength == nil or tics == nil then return end
	
	local screenFade = player.rsrinfo.screenFade
	screenFade.color = color
	screenFade.strength = strength
	screenFade.origTics = tics
	screenFade.tics = tics
end

RSR.ScreenFadeTick = function(player)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.screenFade) then return end
	
	if player.rsrinfo.screenFade.tics > 0 then
		player.rsrinfo.screenFade.tics = $-1
	end
end
