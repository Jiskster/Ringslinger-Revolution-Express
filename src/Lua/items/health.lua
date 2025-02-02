-- Ringslinger Revolution - Health and Shield Pickups
-- Sprites are heavily inspired by Samsara's health pickup sprites

local RSR = RingslingerRev

RSR.GiveHealth = function(player, health, isBonus)
	if not (Valid(player) and player.rsrinfo) then return end
	if health == nil then health = 1 end
	
	if not isBonus and player.rsrinfo.health >= RSR.MAX_HEALTH then return end
	
	local maxHealth = RSR.MAX_HEALTH
	if isBonus then maxHealth = RSR.MAX_HEALTH_BONUS end
	
	player.rsrinfo.health = min($ + health, maxHealth)
	return true
end

RSR.GiveArmor = function(player, armor, isBonus)
	if not (Valid(player) and player.rsrinfo) then return end
	if armor == nil then armor = 1 end
	
	if not isBonus and player.rsrinfo.armor >= RSR.MAX_ARMOR then return end
	
	local maxArmor = RSR.MAX_HEALTH
	if isBonus then maxArmor = RSR.MAX_ARMOR_BONUS end
	
	player.rsrinfo.armor = min($ + armor, maxArmor)
	return true
end

RSR.HealthMobjSpawn = function(mo)
	if not Valid(mo) then return end
	
	mo.rsrFloatOffset = FixedAngle(P_RandomKey(360)*FRACUNIT)
	mo.rsrPickup = true
	
	if not (netgame or multiplayer) then
		mo.flags2 = $|MF2_DONTRESPAWN
	end
end

RSR.HealthTouchSpecial = function(special, toucher, health)
	if not (Valid(special) and Valid(toucher)) then return end
	
	local player = toucher.player
	if not (Valid(player) and player.rsrinfo) then return end
	
	if not RSR.GiveHealth(player, health) then
		return true
	end
	
	RSR.BonusFade(player)
	
	RSR.SetItemFuse(special)
end

RSR.ArmorTouchSpecial = function(special, toucher, armor)
	if not (Valid(special) and Valid(toucher)) then return end
	
	local player = toucher.player
	if not (Valid(player) and player.rsrinfo) then return end
	
	if not RSR.GiveArmor(player, armor) then
		return true
	end
	
	RSR.BonusFade(player)
	
	RSR.SetItemFuse(special)
end

mobjinfo[MT_RSR_HEALTH_SMALL] = {
	--$Name Small Health
	--$Sprite RSHTA0
	--$Category Ringslinger Revolution
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 350,
	spawnstate = S_RSR_HEALTH_SMALL,
	deathstate = S_RSR_ITEM_DEATH,
	deathsound = sfx_ncitem,
	radius = 16*FRACUNIT,
	height = 24*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_HEALTH_SMALL] =	{SPR_RSHT,	A|FF_ADD,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", RSR.HealthMobjSpawn, MT_RSR_HEALTH_SMALL)
addHook("MapThingSpawn", RSR.ItemMapThingSpawn, MT_RSR_HEALTH_SMALL)
addHook("MobjThinker", RSR.ItemFloatThinker, MT_RSR_HEALTH_SMALL)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_HEALTH_SMALL)
addHook("TouchSpecial", function(special, toucher)
	return RSR.HealthTouchSpecial(special, toucher, 10)
end, MT_RSR_HEALTH_SMALL)

mobjinfo[MT_RSR_HEALTH] = {
	--$Name Medium Health
	--$Sprite RSHTB0
	--$Category Ringslinger Revolution
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 351,
	spawnstate = S_RSR_HEALTH,
	deathstate = S_RSR_ITEM_DEATH,
	deathsound = sfx_ncitem,
	radius = 16*FRACUNIT,
	height = 24*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_HEALTH] =	{SPR_RSHT,	B|FF_ADD,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", RSR.HealthMobjSpawn, MT_RSR_HEALTH)
addHook("MapThingSpawn", RSR.ItemMapThingSpawn, MT_RSR_HEALTH)
addHook("MobjThinker", RSR.ItemFloatThinker, MT_RSR_HEALTH)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_HEALTH)
addHook("TouchSpecial", function(special, toucher)
	return RSR.HealthTouchSpecial(special, toucher, 25)
end, MT_RSR_HEALTH)

mobjinfo[MT_RSR_HEALTH_BIG] = {
	--$Name Big Health
	--$Sprite RSHTC0
	--$Category Ringslinger Revolution
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 352,
	spawnstate = S_RSR_HEALTH_BIG,
	deathstate = S_RSR_ITEM_DEATH,
	deathsound = sfx_ncitem,
	radius = 16*FRACUNIT,
	height = 24*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_HEALTH_BIG] =	{SPR_RSHT,	C|FF_ADD,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", RSR.HealthMobjSpawn, MT_RSR_HEALTH_BIG)
addHook("MapThingSpawn", RSR.ItemMapThingSpawn, MT_RSR_HEALTH_BIG)
addHook("MobjThinker", RSR.ItemFloatThinker, MT_RSR_HEALTH_BIG)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_HEALTH_BIG)
addHook("TouchSpecial", function(special, toucher)
	return RSR.HealthTouchSpecial(special, toucher, 50)
end, MT_RSR_HEALTH_BIG)

mobjinfo[MT_RSR_ARMOR_SMALL] = {
	--$Name Small Armor
	--$Sprite RSHTD0
	--$Category Ringslinger Revolution
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 353,
	spawnstate = S_RSR_ARMOR_SMALL,
	deathstate = S_RSR_ITEM_DEATH,
	deathsound = sfx_shield,
	radius = 16*FRACUNIT,
	height = 24*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_ARMOR_SMALL] =	{SPR_RSHT,	D|FF_ADD,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", RSR.HealthMobjSpawn, MT_RSR_ARMOR_SMALL)
addHook("MapThingSpawn", RSR.ItemMapThingSpawn, MT_RSR_ARMOR_SMALL)
addHook("MobjThinker", RSR.ItemFloatThinker, MT_RSR_ARMOR_SMALL)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_ARMOR_SMALL)
addHook("TouchSpecial", function(special, toucher)
	return RSR.ArmorTouchSpecial(special, toucher, 10)
end, MT_RSR_ARMOR_SMALL)

mobjinfo[MT_RSR_ARMOR] = {
	--$Name Medium Armor
	--$Sprite RSHTE0
	--$Category Ringslinger Revolution
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 354,
	spawnstate = S_RSR_ARMOR,
	deathstate = S_RSR_ITEM_DEATH,
	deathsound = sfx_shield,
	radius = 16*FRACUNIT,
	height = 24*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_ARMOR] =	{SPR_RSHT,	E|FF_ADD,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", RSR.HealthMobjSpawn, MT_RSR_ARMOR)
addHook("MapThingSpawn", RSR.ItemMapThingSpawn, MT_RSR_ARMOR)
addHook("MobjThinker", RSR.ItemFloatThinker, MT_RSR_ARMOR)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_ARMOR)
addHook("TouchSpecial", function(special, toucher)
	return RSR.ArmorTouchSpecial(special, toucher, 25)
end, MT_RSR_ARMOR)

mobjinfo[MT_RSR_ARMOR_BIG] = {
	--$Name Big Armor
	--$Sprite RSHTF0
	--$Category Ringslinger Revolution
	--$Arg0 "Float?"
	--$Arg0Tooltip "This raises the object by 24 fracunits."
	--$Arg0Type 11
	--$Arg0Enum yesno
	doomednum = 355,
	spawnstate = S_RSR_ARMOR_BIG,
	deathstate = S_RSR_ITEM_DEATH,
	deathsound = sfx_shield,
	radius = 16*FRACUNIT,
	height = 24*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_RSR_ARMOR_BIG] =	{SPR_RSHT,	F|FF_ADD,	-1,	nil,	0,	0,	S_NULL}

addHook("MobjSpawn", RSR.HealthMobjSpawn, MT_RSR_ARMOR_BIG)
addHook("MapThingSpawn", RSR.ItemMapThingSpawn, MT_RSR_ARMOR_BIG)
addHook("MobjThinker", RSR.ItemFloatThinker, MT_RSR_ARMOR_BIG)
addHook("MobjFuse", RSR.ItemMobjFuse, MT_RSR_ARMOR_BIG)
addHook("TouchSpecial", function(special, toucher)
	return RSR.ArmorTouchSpecial(special, toucher, 50)
end, MT_RSR_ARMOR_BIG)
