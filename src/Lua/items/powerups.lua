-- Ringslinger Revolution - Powerups

local RSR = RingslingerRev

RSR.GivePowerup = function(player, powerup)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.powerups and powerup) then return end
	
	if not RSR.POWERUP_INFO[powerup] then return end
	
	local powerups = player.rsrinfo.powerups
	local hasPowerup, key = RSR.HasPowerup(player, powerup)
	
	if hasPowerup then
		table.remove(powerups, key)
	end
	
	table.insert(powerups, {
		powerup = powerup,
		tics = RSR.POWERUP_INFO[powerup].tics or 20*TICRATE -- Make sure tics is never nil
	})
end

RSR.PowerupTouchSpecial = function(special, toucher, powerup)
	if not (Valid(special) and Valid(toucher)) then return end
	
	local player = toucher.player
	if not (Valid(player) and player.rsrinfo) then return end
	
	RSR.GivePowerup(player, powerup)
	RSR.BonusFade(player)
	
	RSR.SetItemFuse(special)
end

RSR.AddEnum("POWERUP", "INFINITY")
RSR.AddEnum("POWERUP", "SPEED")
RSR.AddEnum("POWERUP", "INVINCIBILITY")

if not RSR.POWERUP_INFO then
	RSR.POWERUP_INFO = {}
end

RSR.POWERUP_INFO[RSR.POWERUP_INFINITY] = {
	icon = "RSRINFNI",
	tics = 15*TICRATE
}

RSR.POWERUP_INFO[RSR.POWERUP_SPEED] = {
	icon = "RSRSPEDI",
	tics = 20*TICRATE
}

RSR.POWERUP_INFO[RSR.POWERUP_INVINCIBILITY] = {
	icon = "RSRINVNI",
	tics = 20*TICRATE
}

mobjinfo[MT_RSR_POWERUP_INFINITY] = {
	--$Name Infinity Powerup
	--$Sprite RSPIA0
	--$Category Ringslinger Revolution/Powerups
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 356,
	spawnstate = S_RSR_POWERUP_INFINITY,
	deathstate = S_RSR_ITEM_DEATH,
	deathsound = sfx_ncitem,
	radius = 16*FRACUNIT,
	height = 28*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_POWERUP_INFINITY] =	{SPR_RSPI,	FF_ANIMATE|FF_GLOBALANIM,	-1,	nil,	15,	3,	S_NULL}

addHook("MobjSpawn", RSR.HealthMobjSpawn, MT_RSR_POWERUP_INFINITY)
addHook("MapThingSpawn", RSR.ItemMapThingSpawn, MT_RSR_POWERUP_INFINITY)
addHook("MobjThinker", RSR.ItemFloatThinker, MT_RSR_POWERUP_INFINITY)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_POWERUP_INFINITY)
addHook("TouchSpecial", function(special, toucher)
	return RSR.PowerupTouchSpecial(special, toucher, RSR.POWERUP_INFINITY)
end, MT_RSR_POWERUP_INFINITY)
