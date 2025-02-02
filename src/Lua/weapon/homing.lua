-- Ringslinger Revolution - Homing Weapon

local RSR = RingslingerRev

RSR.AddWeapon("HOMING", {
	ammoType = RSR.AMMO_HOMING,
	ammoAmount = 10,
	class = 7,
	delay = 12,
	delayspeed = 6,
	icon = "RSRHOMGI",
	motype = MT_RSR_PICKUP_HOMING,
	states = {
		draw = "S_HOMING_DRAW",
		ready = "S_HOMING_READY",
		holster = "S_HOMING_HOSLTER",
		attack = "S_HOMING_ATTACK",
		recoverspeed = "S_HOMING_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_HOMING] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_HOMING,
	seesound = sfx_homifr,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	speed = 40*FRACUNIT,
	radius = 22*FRACUNIT,
	height = 22*FRACUNIT,
	damage = 30,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_RSR_PROJECTILE_HOMING] =	{SPR_RSBH,	FF_ANIMATE|FF_FULLBRIGHT,	-1,	nil,	6,	2,	S_NULL}

RSR.HomingRingAngleCheck = function(missile, enemy)
	if not (Valid(missile) and Valid(enemy)) then return end
	
	-- Don't target enemies outside the missile's angle search!
	local angleTo = R_PointToAngle2(missile.x, missile.y, enemy.x, enemy.y)
	local distTo = R_PointToDist2(missile.x, missile.y, enemy.x, enemy.y)
	local pitchTo = R_PointToDist2(0, missile.z + missile.height/2, distTo, enemy.z + enemy.height/2)
	local angleDelta = AngleFixed(angleTo - missile.angle)
	local pitchDelta = AngleFixed(pitchTo - missile.pitch)
	
	if angleDelta > 180*FRACUNIT then angleDelta = $ - 360*FRACUNIT end
	if pitchDelta > 180*FRACUNIT then pitchDelta = $ - 360*FRACUNIT end
	
	if abs(angleDelta) > 30*FRACUNIT then return end
	if abs(pitchDelta) > 30*FRACUNIT then return end
	
	return true
end

addHook("MobjSpawn", RSR.ProjectileSpawn, MT_RSR_PROJECTILE_HOMING)
addHook("MobjThinker", function(mo)
	if not Valid(mo) then return end
	if not (mo.flags & MF_MISSILE) then return end
	
	local tracer = mo.tracer
	if not (Valid(tracer) and tracer.health > 0) then
		local radius = 512*mo.scale -- TODO: Make this bigger?
		local xShift = FixedMul(radius/2, cos(mo.angle))
		local yShift = FixedMul(radius/2, sin(mo.angle))
		local x1 = mo.x + xShift - radius
		local x2 = mo.x + xShift + radius
		local y1 = mo.y + yShift - radius
		local y2 = mo.y + yShift + radius
		
		local bestDist = 2*radius
		local bestTracer = nil
		local bestDistEnemy = 2*radius
		local bestTracerEnemy = nil
		
		searchBlockmap("objects", function(missile, enemy)
			if not (Valid(missile) and Valid(enemy) and enemy.health > 0) then return end
			if missile.target == enemy then return end -- Don't target the projectile's source
			if not (enemy.flags & MF_SHOOTABLE) then return end
-- 			if not Valid(enemy.player) then return end -- Only target players!
			
			if not P_CheckSight(missile, enemy) then return end -- Don't target enemies outside the missile's view!
			-- Don't target teammates
			if Valid(missile.target) and Valid(missile.target.player) and Valid(enemy.player) then
				if RSR.PlayersAreTeammates(missile.target.player, enemy.player) or (gametyperules & GTR_FRIENDLY) then return end
			end
			
			-- Don't target enemies outside the missile's distance search!
			local dist = FixedHypot(FixedHypot(enemy.x - missile.x, enemy.y - missile.y), enemy.z - missile.z)
			if dist <= bestDist and RSR.HomingRingAngleCheck(missile, enemy) then
				bestDist = dist
				bestTracer = enemy
			end
			
			if ((enemy.flags & MF_ENEMY) or Valid(enemy.player))
			and dist <= bestDistEnemy and RSR.HomingRingAngleCheck(missile, enemy) then
				bestDistEnemy = dist
				bestTracerEnemy = enemy
			end
		end, mo, x1, x2, y1, y2)
		-- Prioritize enemies and non-teammate players over other shootables
		if Valid(bestTracerEnemy) then
			mo.tracer = bestTracerEnemy
			return
		end
		mo.tracer = bestTracer
		return
	end
	
	local player = mo.tracer.player
	
	local angleTurn = ANGLE_22h
	if Valid(player) then
		angleTurn = FixedAngle(5*FRACUNIT)
	end
	local angleTo = R_PointToAngle2(mo.x, mo.y, tracer.x, tracer.y)
	local distTo = R_PointToDist2(mo.x, mo.y, tracer.x, tracer.y)
	local pitchTo = R_PointToAngle2(0, mo.z + mo.height/2, distTo, tracer.z + tracer.height/2)
	
	mo.angle = RSR.AngleTowardsAngle($, angleTo, angleTurn)
	mo.pitch = RSR.AngleTowardsAngle($, pitchTo, angleTurn)
	
	local curSpeed = FixedHypot(FixedHypot(mo.momx, mo.momy), mo.momz)
	local speed = mo.info.speed
	if Valid(player) then -- Try to catch up with players, similar to the Deton
		speed = 3*player.normalspeed/4
	end
	if curSpeed < speed then
		curSpeed = speed
	end
	
-- 	angleTo = mo.angle
	P_InstaThrust(mo, mo.angle, FixedMul(cos(mo.pitch), curSpeed))
-- 	mo.momx = FixedMul(speed, FixedMul(cos(mo.angle), cos(mo.pitch)))
-- 	mo.momy = FixedMul(speed, FixedMul(sin(mo.angle), cos(mo.pitch)))
-- 	mo.momz = FixedMul(speed, sin(mo.pitch))
	mo.momz = FixedMul(sin(mo.pitch), curSpeed)
end, MT_RSR_PROJECTILE_HOMING)
addHook("MobjMoveCollide", RSR.ProjectileMoveCollide, MT_RSR_PROJECTILE_HOMING)

mobjinfo[MT_RSR_PICKUP_HOMING] = {
	--$Name Homing Pickup
	--$Sprite RSWHA0
	--$Category Ringslinger Revolution/Weapons
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	--$Arg1 "Don't despawn in co-op"
	--$Arg1Type 11
	--$Arg1Enum offon
	--$Arg2 "Spawn as panel"
	--$Arg2Tooltip "Panels give the player more ammo."
	--$Arg2Type 11
	--$Arg2Enum yesno
	doomednum = 346,
	spawnstate = S_RSR_PICKUP_HOMING,
	seestate = S_RSR_PICKUP_HOMING_PANEL,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_HOMING] =		{SPR_RSWH,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}
states[S_RSR_PICKUP_HOMING_PANEL] =	{SPR_RSWH,	I|FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_HOMING)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_HOMING)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_HOMING)
end, MT_RSR_PICKUP_HOMING)
addHook("MobjFuse", RSR.WeaponMobjFuse, MT_RSR_PICKUP_HOMING)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_HOMING)

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_HomingAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo)) then return end
	
	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end
	RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_HOMING, player.mo.angle, player.cmd.aiming<<16)
	RSR.TakeAmmoFromReadyWeapon(player, 1)
	
	if wsactions.A_CheckAmmo(player, {}) then return end
	
	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_HOMING_DRAW"] =	{"RSRHOMG",	"A",	1,	"A_WeaponDraw",	{},	"S_HOMING_DRAW"}
-- Holster
wstates["S_HOMING_HOLSTER"] =	{"RSRHOMG",	"A",	1,	"A_WeaponHolster",	{},	"S_HOMING_HOLSTER"}
-- Ready
wstates["S_HOMING_READY"] =	{"RSRHOMG",	"A",	1,	"A_WeaponReady",	{},	"S_HOMING_READY"}
-- Attack
wstates["S_HOMING_ATTACK"] =		{"RSRHOMG",	"A",	0,	"A_HomingAttack",	{},	"S_HOMING_RECOVER"}
wstates["S_HOMING_RECOVER"] =		{"RSRHOMG",	"A",	12,	nil,				{},	"S_HOMING_READY"}
wstates["S_HOMING_RECOVER_SPEED"] =	{"RSRHOMG",	"A",	6,	nil,				{},	"S_HOMING_READY"}
-- wstates["S_HOMING_RECOVER"] =	{"RSRHOMG",	"AAAAAAAAAAAA",	1,	"A_SetWeaponOffset",	{},	"S_HOMING_RECOVER2"}
-- wstates["S_HOMING_RECOVER2"] =	{"RSRHOMG",	"A",			0,	"A_SetWeaponOffset",	{},	"S_HOMING_READY"}
