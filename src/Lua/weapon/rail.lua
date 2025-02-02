-- Ringslinger Revolution - Rail Weapon

local RSR = RingslingerRev

RSR.AddWeapon("RAIL", {
	ammoType = RSR.AMMO_RAIL,
	ammoAmount = 1,
	canBePanel = false,
	class = 1,
	classpriority = 2,
	delay = 60,
	delayspeed = 30,
	icon = "RSRRAILI",
	motype = MT_RSR_PICKUP_RAIL,
	powerweapon = true,
	states = {
		draw = "S_RAIL_DRAW",
		ready = "S_RAIL_READY",
		holster = "S_RAIL_HOSLTER",
		attack = "S_RAIL_ATTACK",
		recoverspeed = "S_RAIL_RECOVER_SPEED"
	}
})

mobjinfo[MT_RSR_PROJECTILE_RAIL] = {
	doomednum = -1,
	spawnstate = S_RSR_PROJECTILE_RAIL,
	seesound = sfx_railfr,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	speed = 60*FRACUNIT,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	damage = 250, -- Might be too OP in deathmatch... (It wasn't. It's PEAK comedy. -Evertone)
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_RSR_PROJECTILE_RAIL] =	{SPR_RSWS,	FF_FULLBRIGHT,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", function(mo)
	if not Valid(mo) then return end

	RSR.ProjectileSpawn(mo)
	mo.rsrRailHitList = {}
end, MT_RSR_PROJECTILE_RAIL)
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

	-- TODO: Make sure this doesn't cause issues in netgames
	if not tmthing.rsrRailHitList[thing] then
		P_DamageMobj(thing, tmthing, tmthing.target, tmthing.info.damage)
		if not (Valid(tmthing) and Valid(thing)) then return false end
		tmthing.rsrRailHitList[thing] = true
	end
	return false
end, MT_RSR_PROJECTILE_RAIL)
addHook("MobjThinker", function(mo)
	if not Valid(mo) then return end

	-- Reset the hit list every frame
	mo.rsrRailHitList = {}
end, MT_RSR_PROJECTILE_RAIL)

mobjinfo[MT_RSR_PICKUP_RAIL] = {
	--$Name Rail Pickup
	--$Sprite RSWIA0
	--$Category Ringslinger Revolution/Weapons
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	--$Arg1 "Don't despawn in co-op"
	--$Arg1Type 11
	--$Arg1Enum offon
	doomednum = 347,
	spawnstate = S_RSR_PICKUP_RAIL,
	deathstate = S_RSR_SPARK,
	deathsound = sfx_itemup,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_PICKUP_RAIL] =	{SPR_RSWI,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	15,	3,	S_NULL}

addHook("MobjSpawn", RSR.ItemMobjSpawn, MT_RSR_PICKUP_RAIL)
addHook("MapThingSpawn", RSR.WeaponMapThingSpawn, MT_RSR_PICKUP_RAIL)
addHook("TouchSpecial", function(special, toucher)
	return RSR.WeaponTouchSpecial(special, toucher, RSR.WEAPON_RAIL)
end, MT_RSR_PICKUP_RAIL)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_PICKUP_RAIL)
addHook("MobjThinker", RSR.WeaponPickupThinker, MT_RSR_PICKUP_RAIL)

RSR.SpawnRailRing = function(mo, angle, pitch, reflected)
	if not Valid(mo) then return end
	local rail = RSR.SpawnPlayerMissile(mo, MT_RSR_PROJECTILE_RAIL, angle, pitch)
	if Valid(rail) then
		rail.rsrRailRing = true
		if reflected then rail.rsrForceReflected = true end
	end
	for i = 1, 256 do
		if not Valid(rail) then
			break
		end

		if (i & 1) then
			local spark = P_SpawnMobjFromMobj(rail, 0, 0, 0, MT_UNKNOWN)
			if Valid(spark) then
				spark.state = S_RSR_SPARK
				RSR.ColorTeamMissile(spark, mo.player)
			end
		end

		if P_RailThinker(rail) then
			break
		end
	end

	if Valid(rail) then
		S_StartSound(rail, sfx_rail2)
	end

	return rail
end

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_RailAttack = function(player, args)
	if not (Valid(player) and Valid(player.mo) and player.rsrinfo) then return end

	if player.rsrinfo then
		player.rsrinfo.weaponDelay = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
		player.rsrinfo.weaponDelayOrig = RSR.GetWeaponDelay(player.rsrinfo.readyWeapon, player.powers[pw_sneakers])
	end
	RSR.SpawnRailRing(player.mo, player.mo.angle, player.cmd.aiming<<16)

	RSR.TakeAmmoFromReadyWeapon(player, 1)

	if wsactions.A_CheckAmmo(player, {}) then return end

	RSR.SetSneakersRecoverState(player)
end

local wstates = RSR.WEAPON_STATES

-- Draw
wstates["S_RAIL_DRAW"] =	{"RSRRAIL",	"A",	1,	"A_WeaponDraw",		{},	"S_RAIL_DRAW"}
-- Holster
wstates["S_RAIL_HOLSTER"] =	{"RSRRAIL",	"A",	1,	"A_WeaponHolster",	{},	"S_RAIL_HOLSTER"}
-- Ready
wstates["S_RAIL_READY"] =	{"RSRRAIL",	"A",	1,	"A_WeaponReady",	{},	"S_RAIL_READY"}
-- Attack
wstates["S_RAIL_ATTACK"] =			{"RSRRAIL",	"A",	0,	"A_RailAttack",	{},	"S_RAIL_RECOVER"}
wstates["S_RAIL_RECOVER"] =			{"RSRRAIL",	"A",	60,	nil,			{},	"S_RAIL_READY"}
wstates["S_RAIL_RECOVER_SPEED"] =	{"RSRRAIL",	"A",	30,	nil,			{},	"S_RAIL_READY"}
-- wstates["S_RAIL_RECOVER"] =		{"RSRRAIL",	"A",	1,	"A_SetWeaponOffset",	{},	"S_RAIL_RECOVER2"}
-- wstates["S_RAIL_RECOVER2"] =	{"RSRRAIL",	"A",	0,	"A_SetWeaponOffset",	{},	"S_RAIL_READY"}

-- for i = 2, 60 do
-- 	wstates["S_RAIL_RECOVER"][2] = $.."A"
-- end
