-- Ringslinger Revolution - Grenade Weapon
-- TODO: Make this use a custom bouncing function??

local RSR = RingslingerRev

RSR.AddWeapon("GRENADE", {
	ammoType = RSR.AMMO_GRENADE,
	ammoAmount = 10,
	class = 5,
	delay = 10,
	delayspeed = 5,
	icon = "RSRGRNDI",
	motype = MT_RSR_PICKUP_GRENADE,
	states = {
		draw = "S_GRENADE_DRAW",
		ready = "S_GRENADE_READY",
		holster = "S_GRENADE_HOSLTER",
		attack = "S_GRENADE_ATTACK",
		recoverspeed = "S_GRENADE_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_GRENADE] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_GRENADE,
	seesound = sfx_grndfr,
-- 	reactiontime = 2*TICRATE + 2,
	reactiontime = 55,
	attacksound = sfx_gbeep,
	painchance = 144*FRACUNIT,
	deathstate = S_RSR_RINGEXPLODE,
	deathsound = sfx_pop,
	speed = 35*FRACUNIT,
	radius = 22*FRACUNIT,
	height = 22*FRACUNIT,
	damage = 25,
	activesound = sfx_s3k5d,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_BOUNCE|MF_GRENADEBOUNCE
}

states[S_RSR_PROJECTILE_GRENADE] =	{SPR_RSBG,	FF_ANIMATE|FF_FULLBRIGHT,	-1,	nil,	17,	2,	S_NULL}

addHook("MobjSpawn", RSR.ProjectileSpawn, MT_RSR_PROJECTILE_GRENADE)
addHook("MobjThinker", function(mo)
	if not Valid(mo) then return end
	if mo.health <= 0 then return end
	if not (mo.flags & MF_MISSILE) then return end

	if (leveltime % 4 == 0) then
		P_SpawnMobjFromMobj(
			mo,
			P_RandomFixedRange(-mo.info.radius, mo.info.radius),
			P_RandomFixedRange(-mo.info.radius, mo.info.radius),
			P_RandomFixedRange(0, mo.info.height),
			MT_SMOKE
		)
	end

	if mo.fuse % TICRATE == 0 then
		S_StartSound(mo, mo.info.attacksound)
	end

	if mo.threshold < 3 then
		if (mo.z + mo.momz <= mo.floorz and P_MobjFlip(mo) > 0)
		or (mo.z + mo.height + mo.momz >= mo.ceilingz and P_MobjFlip(mo) < 0) then
			mo.threshold = $+1

			mo.momx = 3*$/5
			mo.momy = 3*$/5
-- 			mo.momz = -2*$/3
		end

		return
	elseif mo.threshold < 4 then
		mo.threshold = $+1
		mo.momx = 0
		mo.momy = 0
		mo.momz = 0
		return
	end
end, MT_RSR_PROJECTILE_GRENADE)
addHook("MobjFuse", function(mo)
	if not Valid(mo) then return end

	P_ExplodeMissile(mo)
	return true
end, MT_RSR_PROJECTILE_GRENADE)
addHook("MobjMoveCollide", RSR.ProjectileMoveCollide, MT_RSR_PROJECTILE_GRENADE)

mobjinfo[MT_RSR_PICKUP_GRENADE] = {
	--$Name Grenade Pickup
	--$Sprite RSWGA0
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
	doomednum = 344,
	spawnstate = S_RSR_PICKUP_GRENADE,
	seestate = S_RSR_PICKUP_GRENADE_PANEL,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_GRENADE] =			{SPR_RSWG,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}
states[S_RSR_PICKUP_GRENADE_PANEL] =	{SPR_RSWG,	I|FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_GRENADE)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_GRENADE)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_GRENADE)
end, MT_RSR_PICKUP_GRENADE)
addHook("MobjFuse", RSR.WeaponMobjFuse, MT_RSR_PICKUP_GRENADE)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_GRENADE)

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_GrenadeAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo)) then return end

	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end
	local missile = RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_GRENADE, player.mo.angle, player.cmd.aiming<<16)
	if Valid(missile) then
-- 		missile.rsrExplosiveRing = true -- Let the grenade ring deal knockback to the player on top of explosion knockback
		P_SetObjectMomZ(missile, FRACUNIT, true)
-- 		missile.fuse = missile.info.reactiontime
		-- Reaction time is being used for splash damage
		missile.fuse = 2*TICRATE + 2
	end
	RSR.TakeAmmoFromReadyWeapon(player, 1)

	if wsactions.A_CheckAmmo(player, {}) then return end

	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_GRENADE_DRAW"] =	{"RSRGRND",	"A",	1,	"A_WeaponDraw",		{},	"S_GRENADE_DRAW"}
-- Holster
wstates["S_GRENADE_HOLSTER"] =	{"RSRGRND",	"A",	1,	"A_WeaponHolster",	{},	"S_GRENADE_HOLSTER"}
-- Ready
wstates["S_GRENADE_READY"] =	{"RSRGRND",	"A",	1,	"A_WeaponReady",	{},	"S_GRENADE_READY"}
-- Attack
wstates["S_GRENADE_ATTACK"] =			{"RSRGRND",	"A",	0,	"A_GrenadeAttack",	{},	"S_GRENADE_RECOVER"}
wstates["S_GRENADE_RECOVER"] =			{"RSRGRND",	"A",	10,	nil,				{},	"S_GRENADE_READY"}
wstates["S_GRENADE_RECOVER_SPEED"] =	{"RSRGRND",	"A",	5,	nil,				{},	"S_GRENADE_READY"}
-- wstates["S_GRENADE_RECOVER"] =	{"RSRGRND",	"AAAAAAAAAA",	1,	"A_SetWeaponOffset",	{},	"S_GRENADE_RECOVER2"}
-- wstates["S_GRENADE_RECOVER2"] =	{"RSRGRND",	"A",			0,	"A_SetWeaponOffset",	{},	"S_GRENADE_READY"}
