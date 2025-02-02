-- Ringslinger Revolution - Explosion Weapon

local RSR = RingslingerRev

RSR.AddWeapon("BOMB", {
	ammoType = RSR.AMMO_BOMB,
	ammoAmount = 10,
	class = 6,
	delay = 36,
	delayspeed = 18,
	icon = "RSRBOMBI",
	motype = MT_RSR_PICKUP_BOMB,
	states = {
		draw = "S_BOMB_DRAW",
		ready = "S_BOMB_READY",
		holster = "S_BOMB_HOSLTER",
		attack = "S_BOMB_ATTACK",
		recoverspeed = "S_BOMB_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_BOMB] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_BOMB,
	seesound = sfx_bombfr,
	reactiontime = 70,
	painchance = 192*FRACUNIT,
	deathstate = S_RSR_RINGEXPLODE,
	deathsound = sfx_pop,
	speed = 60*FRACUNIT,
	radius = 22*FRACUNIT,
	height = 22*FRACUNIT,
	damage = 20,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_RSR_PROJECTILE_BOMB] =	{SPR_RSWE,	FF_ANIMATE|FF_FULLBRIGHT,	-1,	nil,	15,	1,	S_NULL}

addHook("MobjSpawn", RSR.ProjectileSpawn, MT_RSR_PROJECTILE_BOMB)
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
end, MT_RSR_PROJECTILE_BOMB)
addHook("MobjMoveCollide", RSR.ProjectileMoveCollide, MT_RSR_PROJECTILE_BOMB)

mobjinfo[MT_RSR_PICKUP_BOMB] = {
	--$Name Explosion Pickup
	--$Sprite RSWEA0
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
	doomednum = 345,
	spawnstate = S_RSR_PICKUP_BOMB,
	seestate = S_RSR_PICKUP_BOMB_PANEL,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_BOMB] =			{SPR_RSWE,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	15,	3,	S_NULL}
states[S_RSR_PICKUP_BOMB_PANEL] =	{SPR_RSWE,	Q|FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_BOMB)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_BOMB)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_BOMB)
end, MT_RSR_PICKUP_BOMB)
addHook("MobjFuse", RSR.WeaponMobjFuse, MT_RSR_PICKUP_BOMB)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_BOMB)

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_BombAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo) and player.rsrinfo) then return end

	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end
	local bomb = RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_BOMB, player.mo.angle, player.cmd.aiming<<16)
	if Valid(bomb) then
		bomb.rsrExplosiveRing = true
	end
	RSR.TakeAmmoFromReadyWeapon(player, 1)

	if wsactions.A_CheckAmmo(player, {}) then return end

	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_BOMB_DRAW"] =	{"RSRBOMB",	"A",	1,	"A_WeaponDraw",		{},	"S_BOMB_DRAW"}
-- Holster
wstates["S_BOMB_HOLSTER"] =	{"RSRBOMB",	"A",	1,	"A_WeaponHolster",	{},	"S_BOMB_HOLSTER"}
-- Ready
wstates["S_BOMB_READY"] =	{"RSRBOMB",	"A",	1,	"A_WeaponReady",	{},	"S_BOMB_READY"}
-- Attack
wstates["S_BOMB_ATTACK"] =			{"RSRBOMB",	"A",	0,	"A_BombAttack",	{},	"S_BOMB_RECOVER"}
wstates["S_BOMB_RECOVER"] =			{"RSRBOMB",	"A",	36,	nil,			{},	"S_BOMB_READY"}
wstates["S_BOMB_RECOVER_SPEED"] =	{"RSRBOMB",	"A",	18,	nil,			{},	"S_BOMB_READY"}
-- wstates["S_BOMB_RECOVER"] =		{"RSRBOMB",	"A",	1,	"A_SetWeaponOffset",	{},	"S_BOMB_RECOVER2"}
-- wstates["S_BOMB_RECOVER2"] =	{"RSRBOMB",	"A",	0,	"A_SetWeaponOffset",	{},	"S_BOMB_READY"}

-- for i = 2, 36 do
-- 	wstates["S_BOMB_RECOVER"][2] = $.."A"
-- end
