-- Ringslinger Revolution - HUD Functions

local RSR = RingslingerRev

RSR.GetHUDSpriteCoords = function(v, hudx, hudy, scale, yOffset, flags, scaleScale)
	if not hudx then hudx = 0 end
	if not hudy then hudy = 0 end
	if not scale then scale = FRACUNIT end
	if not scaleScale then scaleScale = FRACUNIT end
	if not yOffset then yOffset = 0 end
	if not flags then flags = 0 end
	
	local properScale = FixedMul(scale, scaleScale)
	local x = hudx + ((320*FRACUNIT - FixedMul(320*properScale, FRACUNIT))/2)
	if (flags & V_SNAPTOLEFT) then
		x = hudx
	elseif (flags & V_SNAPTORIGHT)
		x = hudx + (320*FRACUNIT - FixedMul(320*properScale, FRACUNIT))
	end
	local y = FixedMul(hudy, scale) - ((v.height()/v.dupy() + (yOffset/FRACUNIT - 32)) - (200 - (yOffset/FRACUNIT - 32)))*FRACUNIT
	
	return {x = x, y = y}
end
