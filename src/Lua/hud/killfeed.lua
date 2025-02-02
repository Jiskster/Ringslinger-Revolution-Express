-- Ringslinger Revolution - HUD Killfeed

local RSR = RingslingerRev

RSR.KILLFEED_MESSAGES = {}
RSR.KILLFEED_OFFSET = 0
RSR.KILLFEED_HEIGHT = 18 -- TODO: Change this until it's juuust right
RSR.KILLFEED_FADE_TIMER = TICRATE/2
RSR.KILLFEED_TICS = 4*TICRATE -- Change this to 8*TICRATE for debugging

-- TODO: Not needed since RSR.SHIELD_TO_ICON exists
--[[
RSR.KILLFEED_SHIELD_TO_ICON = {
	[SH_ATTRACT] = "RSRATTRI",
	[SH_FLAMEAURA] = "RSRFLAMI",
	[SH_BUBBLEWRAP] = "RSRBUBLI",
	[SH_ELEMENTAL] = "RSRELEMI"
}
]]

RSR.KILLFEED_DMG_TO_ICON = {
	-- TODO: Add more damagetype conversions here
	[DMG_WATER] = "RSRELEMI",
	[DMG_FIRE] = "RSRFLAMI",
	[DMG_ELECTRIC] = "RSRTHNDI",
	[DMG_NUKE] = "RSRARMAI",
	[DMG_DROWNED] = "RSRBUBLI",
	[DMG_SPACEDROWN] = "RSRBUBLI",
	[DMG_DEATHPIT] = "RSRPIT",
	[DMG_CRUSHED] = "RSRCRUSH"
}

RSR.KILLFEED_MOBJ_TO_ICON = {
	[MT_RSR_PROJECTILE_BASIC] = "RSRBASCI",
	[MT_RSR_PROJECTILE_SCATTER] = "RSRSCTRI",
	[MT_RSR_PROJECTILE_AUTO] = "RSRAUTOI",
	[MT_RSR_PROJECTILE_BOUNCE] = "RSRBNCEI",
	[MT_RSR_PROJECTILE_GRENADE] = "RSRGRNDI",
	[MT_RSR_PROJECTILE_BOMB] = "RSRBOMBI",
	[MT_RSR_PROJECTILE_HOMING] = "RSRHOMGI",
	[MT_RSR_PROJECTILE_RAIL] = "RSRRAILI"
}

local RSR_CHATCOLOR_TO_TEXTCOLOR = {
	[V_MAGENTAMAP] =	"\x81",
	[V_YELLOWMAP] =		"\x82",
	[V_GREENMAP] =		"\x83",
	[V_BLUEMAP] =		"\x84",
	[V_REDMAP] =		"\x85",
	[V_GRAYMAP] =		"\x86",
	[V_ORANGEMAP] =		"\x87",
	[V_SKYMAP] =		"\x88",
	[V_PURPLEMAP] =		"\x89",
	[V_AQUAMAP] =		"\x8A",
	[V_PERIDOTMAP] =	"\x8B",
	[V_AZUREMAP] =		"\x8C",
	[V_BROWNMAP] =		"\x8D",
	[V_ROSYMAP] =		"\x8E",
	[V_INVERTMAP] =		"\x8F",
}

-- The following two functions are based off of CTFTEAMCODE and CTFTEAMENDCODE from SRB2's C code
local RSR_CHATCOLORCODE = function(pl)
	if not Valid(pl) then return "" end
	
	if pl.ctfteam then
		if pl.ctfteam == 1 then return "\x85" end
		return "\x84"
	elseif pl.skincolor and skincolors[pl.skincolor].chatcolor then
		return RSR_CHATCOLOR_TO_TEXTCOLOR[skincolors[pl.skincolor].chatcolor] or ""
	end
	
	return ""
end

local RSR_CHATCOLORENDCODE = function(pl)
	if not Valid(pl) then return "" end
	
	if pl.ctfteam or (pl.skincolor and skincolors[pl.skincolor].chatcolor) then
		return "\x80"
	end
	
	return ""
end

RSR.KillfeedAdd = function(victim, inflictor, attacker, damagetype)
	if not Valid(victim) then return end
	
	if #RSR.KILLFEED_MESSAGES >= 4 then
		table.remove(RSR.KILLFEED_MESSAGES, 1)
	end
	
	local victimName = string.format("%s%s%s", RSR_CHATCOLORCODE(victim), victim.name, RSR_CHATCOLORENDCODE(victim))
	local inflictorPatch = "RSREGGM" -- Always show Eggman for unknown causes of death
	local infReflected = false
	local attackerName = nil
	local skincolor = nil
	
	if not Valid(inflictor) then
		if damagetype then
			damagetype = $ & ~(DMG_CANHURTSELF)
			if RSR.KILLFEED_DMG_TO_ICON[damagetype] then
				inflictorPatch = RSR.KILLFEED_DMG_TO_ICON[damagetype]
			end
		end
	else
		if RSR.KILLFEED_MOBJ_TO_ICON[inflictor.type] then
			inflictorPatch = RSR.KILLFEED_MOBJ_TO_ICON[inflictor.type]
			if inflictor.rsrForceReflected then
				infReflected = true
			end
		elseif damagetype then
			damagetype = $ & ~(DMG_CANHURTSELF)
			if RSR.KILLFEED_DMG_TO_ICON[damagetype] then
				inflictorPatch = RSR.KILLFEED_DMG_TO_ICON[damagetype]
			end
		elseif Valid(inflictor.player) and inflictor.player.rsrinfo then
			local infShield = (inflictor.player.powers[pw_shield] & SH_NOSTACK)
			if infShield and RSR.SHIELD_TO_ICON[infShield]
			and (inflictor.player.pflags & PF_SHIELDABILITY) and not (infShield == SH_ATTRACT and not inflictor.player.rsrinfo.homing) then
				inflictorPatch = RSR.SHIELD_TO_ICON[infShield]
			elseif RSR.HasPowerup(inflictor.player, RSR.POWERUP_INVINCIBILITY) or inflictor.player.powers[pw_invulnerability] then
				inflictorPatch = "RSRINVNI"
			else
				inflictorPatch = "RSRMELEE"
				skincolor = inflictor.player.skincolor
			end
		end
	end
	
	if Valid(attacker) then
		attackerName = string.format("%s%s%s", RSR_CHATCOLORCODE(attacker), attacker.name, RSR_CHATCOLORENDCODE(attacker))
	end
	
	table.insert(RSR.KILLFEED_MESSAGES, {
		victim = victimName,
		inflictor = inflictorPatch,
		infReflected = infReflected,
		attacker = attackerName,
		skincolor = skincolor,
		tics = RSR.KILLFEED_TICS
	})
end

RSR.HUDKillfeed = function(v)
	if not v then return end
	
	-- Go through each killfeed message and draw them to the screen
	for key, info in ipairs(RSR.KILLFEED_MESSAGES) do
		if not info then continue end
		
		local inflictorPatch = v.cachePatch(info.inflictor)
		local patchWidth = 16
		local patchHeight = 16
		
		if Valid(inflictorPatch) then
			patchWidth = inflictorPatch.width
			patchHeight = inflictorPatch.height
		end
		
		local x = 318
		local y = 2 + ((key - 1) * RSR.KILLFEED_HEIGHT) + RSR.KILLFEED_OFFSET
		local flags = V_SNAPTOTOP|V_SNAPTORIGHT
		
		if info.tics <= RSR.KILLFEED_FADE_TIMER then
			local transMap = (10*abs(info.tics - RSR.KILLFEED_FADE_TIMER)/RSR.KILLFEED_FADE_TIMER)<<V_ALPHASHIFT
			if transMap>>V_ALPHASHIFT > 9 then transMap = 0 end
			flags = $|transMap
		end
		
		local colormap = nil
		if info.skincolor then colormap = v.getColormap(TC_DEFAULT, info.skincolor) end
		
		v.drawString(x, y + patchHeight/4, info.victim, flags|V_ALLOWLOWERCASE, "thin-right") -- Show the victim
		x = $ - v.stringWidth(info.victim, 0, "thin") - patchWidth - 2
		v.draw(x, y, inflictorPatch, flags, colormap) -- Show the inflictor: Player, projectile, or otherwise
		if info.infReflected then -- Show if the projectile was reflected
			x = $ - patchWidth - 2
			v.draw(x, y, v.cachePatch("RSRFORCI"), flags, colormap)
		end
		if info.attacker then -- Show the attacker, if there was one
			x = $ - 2
			v.drawString(x, y + patchHeight/4, info.attacker, flags|V_ALLOWLOWERCASE, "thin-right")
		end
	end
end

RSR.HUDKillfeedThinkFrame = do
	local key = 1
	
	while key <= #RSR.KILLFEED_MESSAGES do
		local info = RSR.KILLFEED_MESSAGES[key]
		if not info then key = $+1; continue end
		
		info.tics = $-1
		if info.tics <= 0 then
			table.remove(RSR.KILLFEED_MESSAGES, key)
			if #RSR.KILLFEED_MESSAGES > 0 then
				RSR.KILLFEED_OFFSET = $ + RSR.KILLFEED_HEIGHT
			end
			continue
		end
		
		key = $+1
	end
	
	if RSR.KILLFEED_OFFSET > 0 then RSR.KILLFEED_OFFSET = $-1 end
end

-- Reset the killfeed when the map changes
addHook("MapChange", do
	RSR.KILLFEED_MESSAGES = {}
end)
