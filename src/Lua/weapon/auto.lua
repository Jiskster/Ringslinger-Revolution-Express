-- Ringslinger Revolution - Automatic Weapon

local RSR = RingslingerRev

RSR.AddWeapon("AUTO", {
	ammoType = RSR.AMMO_AUTO,
	ammoAmount = 80,
	class = 3,
	delay = 2,
	delayspeed = 2,
	icon = "RSRAUTOI",
	motype = MT_RSR_PICKUP_AUTO,
	states = {
		draw = "S_AUTO_DRAW",
		ready = "S_AUTO_READY",
		holster = "S_AUTO_HOSLTER",
		attack = "S_AUTO_ATTACK",
		recoverspeed = "S_AUTO_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_AUTO] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_AUTO,
	seesound = sfx_autofr,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	speed = 70*FRACUNIT,
	radius = 22*FRACUNIT,
	height = 22*FRACUNIT,
	damage = 14,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_RSR_PROJECTILE_AUTO] =	{SPR_RSBA,	FF_ANIMATE|FF_FULLBRIGHT,	-1,	nil,	6,	1,	S_NULL}

addHook("MobjSpawn", RSR.ProjectileSpawn, MT_RSR_PROJECTILE_AUTO)
addHook("MobjMoveCollide", RSR.ProjectileMoveCollide, MT_RSR_PROJECTILE_AUTO)

mobjinfo[MT_RSR_PICKUP_AUTO] = {
	--$Name Automatic Pickup
	--$Sprite RSWAA0
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
	doomednum = 342,
	spawnstate = S_RSR_PICKUP_AUTO,
	seestate = S_RSR_PICKUP_AUTO_PANEL,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_AUTO] =			{SPR_RSWA,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}
states[S_RSR_PICKUP_AUTO_PANEL] =	{SPR_RSWA,	I|FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_AUTO)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_AUTO)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_AUTO)
end, MT_RSR_PICKUP_AUTO)
addHook("MobjFuse", RSR.WeaponMobjFuse, MT_RSR_PICKUP_AUTO)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_AUTO)

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_AutoAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo) and player.rsrinfo) then return end

	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end
	RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_AUTO, player.mo.angle, player.cmd.aiming<<16)
	RSR.TakeAmmoFromReadyWeapon(player, 1)

	if wsactions.A_CheckAmmo(player, {}) then return end

	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_AUTO_DRAW"] =	{"RSRAUTO",	"A",	1,	"A_WeaponDraw",		{},	"S_AUTO_DRAW"}
-- Holster
wstates["S_AUTO_HOLSTER"] =	{"RSRAUTO",	"A",	1,	"A_WeaponHolster",	{},	"S_AUTO_HOLSTER"}
-- Ready
wstates["S_AUTO_READY"] =	{"RSRAUTO",	"A",	1,	"A_WeaponReady",	{},	"S_AUTO_READY"}
-- Attack
wstates["S_AUTO_ATTACK"] =			{"RSRAUTO",	"A",	0,	"A_AutoAttack",	{},	"S_AUTO_RECOVER"}
wstates["S_AUTO_RECOVER"] =			{"RSRAUTO", "A",	2,	nil,			{},	"S_AUTO_READY"}
wstates["S_AUTO_RECOVER_SPEED"] =	{"RSRAUTO", "A",	1,	nil,			{},	"S_AUTO_READY"}
-- wstates["S_AUTO_RECOVER"] =		{"RSRAUTO",	"AAA",	1,	"A_SetWeaponOffset",	{},	"S_AUTO_RECOVER2"}
-- wstates["S_AUTO_RECOVER_END"] =	{"RSRAUTO",	"A",	0,	"A_SetWeaponOffset",	{},	"S_AUTO_READY"}
