-- Ringslinger Revolution - Scatter Weapon

local RSR = RingslingerRev

RSR.AddWeapon("SCATTER", {
	ammoType = RSR.AMMO_SCATTER,
	ammoAmount = 20,
	class = 2,
	delay = 31,
	delayspeed = 16,
	icon = "RSRSCTRI",
	motype = MT_RSR_PICKUP_SCATTER,
	states = {
		draw = "S_SCATTER_DRAW",
		ready = "S_SCATTER_READY",
		holster = "S_SCATTER_HOSLTER",
		attack = "S_SCATTER_ATTACK",
		recoverspeed = "S_SCATTER_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_SCATTER] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_SCATTER,
	seesound = sfx_sctrfr,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	speed = 45*FRACUNIT,
	radius = 22*FRACUNIT,
	height = 22*FRACUNIT,
	damage = 16,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_RSR_PROJECTILE_SCATTER] =	{SPR_RSWS,	FF_FULLBRIGHT,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", RSR.ProjectileSpawn, MT_RSR_PROJECTILE_SCATTER)
addHook("MobjMoveCollide", RSR.ProjectileMoveCollide, MT_RSR_PROJECTILE_SCATTER)

mobjinfo[MT_RSR_PICKUP_SCATTER] = {
	--$Name Scatter Pickup
	--$Sprite RSWSA0
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
	doomednum = 341,
	spawnstate = S_RSR_PICKUP_SCATTER,
	seestate = S_RSR_PICKUP_SCATTER_PANEL,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_SCATTER] =			{SPR_RSWS,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}
states[S_RSR_PICKUP_SCATTER_PANEL] =	{SPR_RSWS,	I|FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	7,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_SCATTER)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_SCATTER)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_SCATTER)
end, MT_RSR_PICKUP_SCATTER)
addHook("MobjFuse", RSR.WeaponMobjFuse, MT_RSR_PICKUP_SCATTER)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_SCATTER)

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_ScatterAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo)) then return end
	
	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end
	
	local angle = player.mo.angle
	local pitch = player.cmd.aiming<<16
	
	local angleOffset = 2*ANG2
	local pitchOffset = 2*ANG2
	
	RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_SCATTER, angle, pitch)
	RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_SCATTER, angle + angleOffset, pitch)
	RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_SCATTER, angle, pitch + pitchOffset)
	RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_SCATTER, angle - angleOffset, pitch)
	RSR.SpawnPlayerMissile(player.mo, MT_RSR_PROJECTILE_SCATTER, angle, pitch - pitchOffset)
	RSR.TakeAmmoFromReadyWeapon(player, 1)
	
	if wsactions.A_CheckAmmo(player, {}) then return end
	
	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_SCATTER_DRAW"] =	{"RSRSCTR",	"A",	1,	"A_WeaponDraw",	{},	"S_SCATTER_DRAW"}
-- Holster
wstates["S_SCATTER_HOLSTER"] =	{"RSRSCTR",	"A",	1,	"A_WeaponHolster",	{},	"S_SCATTER_HOLSTER"}
-- Ready
wstates["S_SCATTER_READY"] =	{"RSRSCTR",	"A",	1,	"A_WeaponReady",	{},	"S_SCATTER_READY"}
-- Attack
wstates["S_SCATTER_ATTACK"] =			{"RSRSCTR",	"A",	0,	"A_ScatterAttack",	{},	"S_SCATTER_RECOVER"}
wstates["S_SCATTER_RECOVER"] =			{"RSRSCTR",	"A",	31,	nil,				{},	"S_SCATTER_READY"}
wstates["S_SCATTER_RECOVER_SPEED"] =	{"RSRSCTR",	"A",	16,	nil,				{},	"S_SCATTER_READY"}
-- wstates["S_SCATTER_RECOVER"] =	{"RSRSCTR",	"A",	1,	"A_SetWeaponOffset",	{},	"S_SCATTER_RECOVER2"}
-- wstates["S_SCATTER_RECOVER2"] =	{"RSRSCTR",	"A",	0,	"A_SetWeaponOffset",	{},	"S_SCATTER_READY"}

-- for i = 2, 31 do
-- 	wstates["S_SCATTER_RECOVER"][2] = $.."A"
-- end
