-- Ringslinger Revolution - Bounce Weapon

local RSR = RingslingerRev

RSR.AddWeapon("BOUNCE", {
	ammoType = RSR.AMMO_BOUNCE,
	ammoAmount = 16,
	class = 4,
	delay = 7,
	delayspeed = 4,
	icon = "RSRBNCEI",
	motype = MT_RSR_PICKUP_BOUNCE,
	states = {
		draw = "S_BOUNCE_DRAW",
		ready = "S_BOUNCE_READY",
		holster = "S_BOUNCE_HOSLTER",
		attack = "S_BOUNCE_ATTACK",
		recoverspeed = "S_BOUNCE_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_BOUNCE] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_BOUNCE,
	seesound = sfx_boncfr,
-- 	reactiontime = 2*TICRATE,
	painchance = 9,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	speed = 65*FRACUNIT,
	radius = 22*FRACUNIT,
	height = 22*FRACUNIT,
	damage = 17,
	activesound = sfx_bnce1,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY|MF_BOUNCE|MF_GRENADEBOUNCE
}

states[S_RSR_PROJECTILE_BOUNCE] =	{SPR_RSWB,	FF_ANIMATE|FF_FULLBRIGHT,	-1,	nil,	15,	1,	S_NULL}

RSR.BounceIncrementCount = function(mo)
	if not Valid(mo) then return end
	
	-- Use threshold as a "bounce count" of sorts
	mo.threshold = $+1
	mo.rsrDamage = max(1, $-2) -- Don't let the damage value go lower than 1
	if mo.threshold > mo.info.painchance then
		P_ExplodeMissile(mo)
		return
	end
	
	S_StartSound(mo, mo.info.activesound)
end

addHook("MobjSpawn", function(mo)
	if not Valid(mo) then return end
	RSR.ProjectileSpawn(mo)
	mo.rsrDamage = mo.info.damage
end, MT_RSR_PROJECTILE_BOUNCE)
addHook("MobjThinker", function(mo)
	if not Valid(mo) then return end
	if not (mo.flags & MF_MISSILE) then return end
	
	if mo.rsrBounced then
		mo.rsrBounced = $-1
	end
	
	-- SRB2 has a hardcoded hack specifically for grenade rings (and Brak's napalm bombs)
	-- to make them stop when they hit the ground while their vertical momentum is less than their scale.
	-- This code attempts to prevent that from happening by setting the bounce ring's momentum to its previous momentum.
	-- A hack to prevent another hack. How interesting...
	if not (mo.momx or mo.momy or mo.momz) then
		mo.momx = mo.rsrBounceMomX
		mo.momy = mo.rsrBounceMomY
		mo.momz = mo.rsrBounceMomZ
	end
	
	local hitFloor = mo.z + mo.momz <= mo.floorz
	local hitCeiling = mo.z + mo.height + mo.momz >= mo.ceilingz
	if hitFloor or hitCeiling then
		RSR.BounceIncrementCount(mo)
		
		if P_MobjFlip(mo)*mo.momz < 0 then
			mo.momz = $*2 -- Try to cancel out the division by 2 done on MF_GRENADEBOUNCE objects
		end
		
		if Valid(mo.subsector) and Valid(mo.subsector.sector) then
			local curSector = mo.subsector.sector
			if (hitFloor and curSector.floorpic == "F_SKY1" and curSector.floorheight == mo.floorz)
			or (hitCeiling and curSector.ceilingpic == "F_SKY1" and curSector.ceilingheight == mo.ceilingz) then
				P_RemoveMobj(mo)
				return
			end
		end
	end
	
	mo.rsrBounceMomX = mo.momx
	mo.rsrBounceMomY = mo.momy
	mo.rsrBounceMomZ = mo.momz
end, MT_RSR_PROJECTILE_BOUNCE)
-- addHook("MobjFuse", function(mo)
-- 	if not Valid(mo) then return end
	
-- 	P_ExplodeMissile(mo)
-- 	return true
-- end, MT_RSR_PROJECTILE_BOUNCE)
addHook("MobjMoveCollide", function(tmthing, thing)
	if not (Valid(tmthing) and Valid(thing)) then return end
	if not (tmthing.flags & MF_MISSILE) then return end
	
	-- Don't run collision code if the projectile flew over or under the target
	if tmthing.z > thing.z + thing.height
	or thing.z > tmthing.z + tmthing.height then
		return
	end
	
	if Valid(tmthing.target) then
		-- Don't hit the source of the projectile
		if thing == tmthing.target then
			return
		end
	end
	
	-- Go through players (only in co-op and non-friendlyfire modes) and bots
	if Valid(thing.player) then
		if (gametyperules & GTR_FRIENDLY) then return false end
		if Valid(tmthing.target) and Valid(tmthing.target.player) and RSR.PlayersAreTeammates(tmthing.target.player, thing.player) 
		and not (CV_FindVar("friendlyfire").value or (gametyperules & GTR_FRIENDLYFIRE)) then
			return false
		end
		
		if thing.player.bot then
			local bot = thing.player.bot
			
			-- Pass through 2-player bots
			if bot == BOT_2PAI or bot == BOT_2PHUMAN then
				return false
			end
		end
	end
	
	if not (thing.flags & MF_SHOOTABLE) then return end
	
	if tmthing.rsrBounced then
		return false
	end
	
	P_DamageMobj(thing, tmthing, tmthing.target, tmthing.rsrDamage)	
	tmthing.momx = -$
	tmthing.momy = -$
	tmthing.rsrBounced = 4 -- Add a timer so the bounce ring doesn't get stuck on an object
	
	RSR.BounceIncrementCount(mo)
	return false
end, MT_RSR_PROJECTILE_BOUNCE)
addHook("MobjMoveBlocked", function(mo)
	if not Valid(mo) then return end
	
	-- Make sure the bounce ring maintains the same speed it had before it bounced off the wall
	local oldSpeed = FixedHypot(FixedHypot(mo.momx, mo.momy), mo.momz)
	P_BounceMove(mo)
	local newSpeed = FixedHypot(FixedHypot(mo.momx, mo.momy), mo.momz)
	
	if oldSpeed and newSpeed then
		local scale = FixedDiv(oldSpeed, newSpeed)
		
		mo.momx = FixedMul($, scale)
		mo.momy = FixedMul($, scale)
		mo.momz = FixedMul($, scale)
	end
	
	RSR.BounceIncrementCount(mo)
	return true
end, MT_RSR_PROJECTILE_BOUNCE)

mobjinfo[MT_RSR_PICKUP_BOUNCE] = {
	--$Name Bounce Pickup
	--$Sprite RSWBA0
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
	doomednum = 343,
	spawnstate = S_RSR_PICKUP_BOUNCE,
	seestate = S_RSR_PICKUP_BOUNCE_PANEL,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_BOUNCE] =		{SPR_RSWB,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	15,	3,	S_NULL}
states[S_RSR_PICKUP_BOUNCE_PANEL] =	{SPR_RSWB,	Q|FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_BOUNCE)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_BOUNCE)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_BOUNCE)
end, MT_RSR_PICKUP_BOUNCE)
addHook("MobjFuse", RSR.WeaponMobjFuse, MT_RSR_PICKUP_BOUNCE)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_BOUNCE)

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_BounceAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo)) then return end
	
	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end
	local missile = RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_BOUNCE, player.mo.angle, player.cmd.aiming<<16)
-- 	if Valid(missile) then
-- 		missile.fuse = missile.info.reactiontime
-- 	end
	RSR.TakeAmmoFromReadyWeapon(player, 1)
	
	if wsactions.A_CheckAmmo(player, {}) then return end
	
	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_BOUNCE_DRAW"] =	{"RSRBNCE",	"A",	1,	"A_WeaponDraw",		{},	"S_BOUNCE_DRAW"}
-- Holster
wstates["S_BOUNCE_HOLSTER"] =	{"RSRBNCE",	"A",	1,	"A_WeaponHolster",	{},	"S_BOUNCE_HOLSTER"}
-- Ready
wstates["S_BOUNCE_READY"] =	{"RSRBNCE",	"A",	1,	"A_WeaponReady",	{},	"S_BOUNCE_READY"}
-- Attack
wstates["S_BOUNCE_ATTACK"] =		{"RSRBNCE",	"A",	0,	"A_BounceAttack",	{},	"S_BOUNCE_RECOVER"}
wstates["S_BOUNCE_RECOVER"] =		{"RSRBNCE",	"A",	7,	nil,				{},	"S_BOUNCE_READY"}
wstates["S_BOUNCE_RECOVER_SPEED"] =	{"RSRBNCE",	"A",	4,	nil,				{},	"S_BOUNCE_READY"}
-- wstates["S_BOUNCE_RECOVER"] =	{"RSRBNCE",	"AAAAAAAAAAAA",	1,	"A_SetWeaponOffset",	{},	"S_BOUNCE_RECOVER2"}
-- wstates["S_BOUNCE_RECOVER2"] =	{"RSRBNCE",	"A",			0,	"A_SetWeaponOffset",	{},	"S_BOUNCE_READY"}
