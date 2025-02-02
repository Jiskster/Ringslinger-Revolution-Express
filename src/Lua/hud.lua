-- Ringslinger Revolution - Heads-Up Display

local folder = "hud"

local dofolder = function(file)
	dofile(folder.."/"..file)
end

dofolder("functions.lua")
dofolder("powerups.lua")
dofolder("psprites.lua")
dofolder("screenfade.lua")
dofolder("weaponbar.lua")
dofolder("bosshealth.lua")
dofolder("killfeed.lua")

local RSR = RingslingerRev

RSR.DisabledHUDItems = {
	"score",
	"time",
	"rings",
	"lives",
	"powerups",
	"weaponrings"
}

-- Check for enabling the HUD ONCE
-- This should not need to be synced with NetVars since it's only used by the HUD...
RSR.GAMEMODE_WAS_ACTIVE = false

RSR.ToggleHUDItems = do
	-- TODO: There has to be a better way to disable the vanilla HUD...
	for _, huditem in ipairs(RSR.DisabledHUDItems) do
		if RSR.GamemodeActive() then
			hud.disable(huditem)
		elseif RSR.GAMEMODE_WAS_ACTIVE then
			hud.enable(huditem)
		end
	end
	
	RSR.GAMEMODE_WAS_ACTIVE = RSR.GamemodeActive()
end

addHook("MapLoad", RSR.ToggleHUDItems)
addHook("PlayerSpawn", RSR.ToggleHUDItems) -- Originally, players that joined mid-game would have overlapping HUDS; Not anymore!

RSR.SHIELD_TO_ICON = {
	[SH_WHIRLWIND] = "RSRWINDI",
	[SH_ARMAGEDDON] = "RSRARMAI",
	[SH_ELEMENTAL] = "RSRELEMI",
	[SH_ATTRACT] = "RSRATTRI",
	[SH_FLAMEAURA] = "RSRFLAMI",
	[SH_BUBBLEWRAP] = "RSRBUBLI",
	[SH_THUNDERCOIN] = "RSRTHNDI",
	[SH_FORCE] = "RSRFORCI"
}

RSR.DrawHUD = function(v, player, camera)
	if not (v and Valid(player)) then return end
	
	RSR.ToggleHUDItems()
	
	if not RSR.GamemodeActive() then
		return
	end
	
	if not player.rsrinfo then return end
	local rsrinfo = player.rsrinfo
	
	local xyScale = ((v.height() / v.dupy()) * FRACUNIT) / (200)
	
	RSR.DrawHUDSprites(v, player, camera, xyScale)
	
	RSR.HUDPowerups(v, player)
	RSR.HUDWeaponBar(v, player)
	
	local healthFlags = V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS|V_PERPLAYER
	
	v.draw(6, 186, v.cachePatch("RSRHLTH"), healthFlags)
	v.drawNum(48, 186, rsrinfo.health, healthFlags)
	
	local armorIcon = "RSRARMR"
	local shield = player.powers[pw_shield] & SH_NOSTACK
	if (shield & SH_FORCE) then shield = SH_FORCE end
	if shield and RSR.SHIELD_TO_ICON[shield] then
		armorIcon = RSR.SHIELD_TO_ICON[shield]
	end
	local armorPatch = v.cachePatch(armorIcon)
	
	if Valid(armorPatch) then
		local armorXOffset = -((armorPatch.width - 11)/2)
		local armorYOffset = -((armorPatch.height - 11)/2)
		v.draw(6 + armorXOffset, 170 + armorYOffset, armorPatch, healthFlags)
	end
	v.drawNum(48, 170, rsrinfo.armor, healthFlags)
	
	RSR.HUDBossHealth(v, player)
	RSR.HUDKillfeed(v)
	
	RSR.HUDScreenFade(v, player)
end

addHook("HUD", RSR.DrawHUD, "game")
addHook("ThinkFrame", do
	if not RSR.GamemodeActive() then return end
	
	RSR.HUDBossHealthThinkFrame()
	RSR.HUDKillfeedThinkFrame()
end)
