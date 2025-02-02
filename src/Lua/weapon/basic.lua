-- Ringslinger Revolution - Basic Weapon

local RSR = RingslingerRev

RSR.AddWeapon("BASIC", {
	ammoType = RSR.AMMO_BASIC,
	ammoAmount = 40,
	canBePanel = false,
	class = 1,
	classpriority = 1,
	delay = 7,
	delayspeed = 4,
	icon = "RSRBASCI",
	motype = MT_RSR_PICKUP_BASIC,
	states = {
		draw = "S_BASIC_DRAW",
		ready = "S_BASIC_READY",
		holster = "S_BASIC_HOSLTER",
		attack = "S_BASIC_ATTACK",
		recoverspeed = "S_BASIC_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_BASIC] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_BASIC,
	seesound = sfx_redfir,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	speed = 65*FRACUNIT,
	radius = 22*FRACUNIT,
	height = 22*FRACUNIT,
	damage = 15,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_RSR_PROJECTILE_BASIC] =	{SPR_RSBR,	FF_ANIMATE|FF_FULLBRIGHT,	-1,	nil,	7,	1,	S_NULL}

addHook("MobjSpawn", RSR.ProjectileSpawn, MT_RSR_PROJECTILE_BASIC)
addHook("MobjMoveCollide", RSR.ProjectileMoveCollide, MT_RSR_PROJECTILE_BASIC)

mobjinfo[MT_RSR_PICKUP_BASIC] = {
	--$Name Basic Pickup
	--$Sprite RSWRA0
	--$Category Ringslinger Revolution/Weapons
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	--$Arg1 "Don't despawn in co-op"
	--$Arg1Type 11
	--$Arg1Enum offon
	doomednum = 340,
	spawnstate = S_RSR_PICKUP_BASIC,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_BASIC] =	{SPR_RSWR,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_BASIC)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_BASIC)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_BASIC)
end, MT_RSR_PICKUP_BASIC)
addHook("MobjFuse", RSR.WeaponMobjFuse, MT_RSR_PICKUP_BASIC)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_BASIC)

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_BasicAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo)) then return end

	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end

	local missile = RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_BASIC, player.mo.angle, player.cmd.aiming<<16)
	if Valid(missile) and not (missile.color or missile.translation) then
		missile.color = SKINCOLOR_RED
	end
	RSR.TakeAmmoFromReadyWeapon(player, 1)

	if wsactions.A_CheckAmmo(player, {}) then return end

	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_BASIC_DRAW"] =	{"RSRBASC",	"A",	1,	"A_WeaponDraw",	{},	"S_BASIC_DRAW"}
-- Holster
wstates["S_BASIC_HOLSTER"] =	{"RSRBASC",	"A",	1,	"A_WeaponHolster",	{},	"S_BASIC_HOLSTER"}
-- Ready
wstates["S_BASIC_READY"] =	{"RSRBASC",	"A",	1,	"A_WeaponReady",	{},	"S_BASIC_READY"}
-- Attack
wstates["S_BASIC_ATTACK"] =			{"RSRBASC",	"A",	0,	"A_BasicAttack",	{},	"S_BASIC_RECOVER"}
wstates["S_BASIC_RECOVER"] =		{"RSRBASC",	"A",	7,	nil,				{},	"S_BASIC_READY"}
wstates["S_BASIC_RECOVER_SPEED"] =	{"RSRBASC",	"A",	4,	nil,				{},	"S_BASIC_READY"}
-- wstates["S_BASIC_RECOVER"] =	{"RSRBASC",	"AAAAAAAAAAAA",	1,	"A_SetWeaponOffset",	{},	"S_BASIC_RECOVER2"}
-- wstates["S_BASIC_RECOVER2"] =	{"RSRBASC",	"A",			0,	"A_SetWeaponOffset",	{},	"S_BASIC_READY"}
