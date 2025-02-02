-- Ringslinger Revolution - Utility Functions

local RSR = RingslingerRev

if not Valid then
	rawset(_G, "Valid", function(thing)
		return (thing and thing.valid)
	end)
end

if not P_RandomFixedRange then
	rawset(_G, "P_RandomFixedRange", function(a, b)
		local diff = b - a
		local result = FixedMul(diff, P_RandomFixed()) + a
		
		return result
	end)
end

RSR.DeepCopy = function(table)
	local newTable = {}
	for k, v in ipairs(table) do
		if type(v) == "table" then
			newTable[k] = SN.DeepCopy(v)
			continue
		end
		
		newTable[k] = v
	end
	return newTable
end

-- Based off of Snap's code
RSR.AngleTowardsAngle = function(angle, destAngle, maxTurn)
	angle = $ or 0
	destAngle = $ or 0
	if maxTurn == nil then maxTurn = ANGLE_22h end
	maxTurn = AngleFixed($)
	if maxTurn > 180*FRACUNIT then
		maxTurn = $ - 360*FRACUNIT
	end
	
	local delta = AngleFixed(angle - destAngle)
	if delta > 180*FRACUNIT then
		delta = $ - 360*FRACUNIT
	end
	
	if maxTurn < abs(delta) then
		if delta > 0 then
			angle = $ - FixedAngle(maxTurn)
		else
			angle = $ + FixedAngle(maxTurn)
		end
	else
		angle = destAngle
	end
	
	return angle
end

RSR.MoveMissile = function(missile, angle, slope)
	if not Valid(missile) then return end
	missile.angle = angle
	
	missile.momx = P_ReturnThrustX(missile, angle, FixedMul(missile.scale, missile.info.speed))
	missile.momy = P_ReturnThrustY(missile, angle, FixedMul(missile.scale, missile.info.speed))
	
	if slope then
		missile.momx = FixedMul($, cos(slope))
		missile.momy = FixedMul($, cos(slope))
		
		P_SetObjectMomZ(missile, FixedMul(missile.info.speed, P_MobjFlip(missile)*sin(slope)))
	end
end

RSR.ColorTeamMissile = function(missile, player)
	if not (Valid(missile) and Valid(player)) then return end
	if not G_GametypeHasTeams() then return end
	
	if player.ctfteam == 2 then
		missile.translation = "RSRTeamBlue"
	elseif player.ctfteam == 1 then
		missile.translation = "RSRTeamRed"
	end
end

RSR.SpawnPlayerMissile = function(source, missileType, angle, slope, reflected)
	if not Valid(source) then return end
	missileType = $ or MT_JETTBULLET
	angle = $ or source.angle
	slope = $ or 0
	
	local spawnHeight = 41*FixedDiv(source.height, source.scale)/48 - (mobjinfo[missileType].height/2)
	local missile = P_SpawnMobjFromMobj(source, 0, 0, spawnHeight, missileType)
	if not Valid(missile) then return end
	if missile.info.seesound then
		S_StartSound(source, missile.info.seesound)
	end
	
	missile.target = source
	if reflected then missile.rsrForceReflected = true end
	RSR.ColorTeamMissile(missile, source.player)
	-- This causes a bug where explosion rings spawn at the top of a wall if the player is on the ground and shoots downwards against it
	-- TODO: Figure out why I was doing this before...
-- 	P_SetOrigin(missile, missile.x, missile.y, missile.z)
-- 	if not Valid(missile) then return end -- Prevents a bug where Force Shield reflected projectiles can remove the original projectile here
	missile.angle = angle
	missile.pitch = slope
	missile.rsrProjectile = true
	RSR.MoveMissile(missile, angle, slope)
	
	if not Valid(missile) then return end
	-- Make sure the player can't outrun their projectiles
	local missileSpeed = FixedMul(missile.info.speed, missile.scale)
	local angleOffset = source.angle - R_PointToAngle2(0, 0, source.momx, source.momy)
	
	-- Based off of Snap's code
	local fracOffset = AngleFixed(angleOffset)
	if fracOffset > 180*FRACUNIT then fracOffset = $ - 360*FRACUNIT end
	
	if fracOffset > -90*FRACUNIT and fracOffset < 90*FRACUNIT then
		local sourceSpeed = FixedMul(
			FixedHypot(FixedHypot(source.momx, source.momy), source.momz),
			abs(cos(angleOffset))
		)
		local speedScale = FixedDiv(sourceSpeed + missileSpeed, missileSpeed)
		missile.momx = FixedMul($, speedScale)
		missile.momy = FixedMul($, speedScale)
		missile.momz = FixedMul($, speedScale)
	end
	
	return missile
end

RSR.PlayersAreTeammates = function(player, player2)
	if not (Valid(player) and Valid(player2)) then return end
	
	-- If both players have a ctfteam value greater than 0 and are equal, they are teammates
	if player.ctfteam and player2.ctfteam and player.ctfteam == player2.ctfteam then return true end
	
	-- Otherwise, they are NOT teammates
	return false
end
