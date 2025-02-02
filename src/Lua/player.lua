-- Ringslinger Revolution - Player

local folder = "player"

local dofolder = function(file)
	dofile(folder.."/"..file)
end

dofolder("chasecam.lua")

dofolder("damage.lua")
dofolder("weaponchoice.lua")
dofolder("starpost.lua")
dofolder("powerups.lua")
dofolder("homing.lua")

dofolder("screenfade.lua")

local RSR = RingslingerRev

RSR.PlayerWeaponsInit = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	
	local rsrinfo = player.rsrinfo
	
	rsrinfo.weapons = {}
	for i = RSR.WEAPON_NONE + 1, RSR.WEAPON_MAX - 1 do
		rsrinfo.weapons[i] = false
	end
	
	rsrinfo.ammo = {}
	for i = RSR.AMMO_BASIC, RSR.AMMO_MAX do
		rsrinfo.ammo[i] = 0
	end
	
	rsrinfo.readyWeapon = RSR.WEAPON_NONE
	rsrinfo.pendingWeapon = -1
	
	rsrinfo.weaponDelay = 0
	rsrinfo.weaponDelayOrig = 0
end

RSR.PlayerInit = function(player)
	if not Valid(player) then return end
	
	if not player.rsrinfo then
		player.rsrinfo = {}
	end
	
	local rsrinfo = player.rsrinfo
	rsrinfo.lastbuttons = player.lastbuttons
	
	RSR.PlayerHealthInit(player)
	RSR.PlayerWeaponsInit(player)
	RSR.PlayerPowerupsInit(player)
	
	RSR.PlayerStarpostDataInit(player)
-- 	rsrinfo.lastshield = player.powers[pw_shield] & SH_NOSTACK
	
	rsrinfo.bob = {x = 0, y = 0}
	
	RSR.PlayerScreenFadeInit(player)
	
	RSR.PlayerPSpritesInit(player)
	RSR.PlayerPSpritesReset(player)
	
	-- Use our own homing variable for homing onto players,
	-- since SRB2 automatically sets player.homing to 0 if the player isn't targetting an enemy
	rsrinfo.homing = 0
	rsrinfo.homingThreshold = 0
	
	RSR.PlayerSetChasecam(player, false)
end

RSR.PlayerDeinit = function(player)
	if not Valid(player) then return end
	
	player.rsrinfo = nil
end

RSR.PlayerSpawn = function(player)
	if not RSR.GamemodeActive() then return end
	
	RSR.PlayerInit(player)
	RSR.PlayerStarpostDataSpawn(player)
end

RSR.PlayerThink = function(player)
	if not (Valid(player) and Valid(player.mo)) then return end
	
	-- Don't run this hook unless we're in the Ringslinger gamemode
	if not RSR.GamemodeActive() then
		if player.rsrinfo then RSR.PlayerDeinit(player) end
		return
	end
	
	if player.playerstate == PST_LIVE then
		RSR.PlayerHomingThink(player)
		RSR.PlayerWeaponChoiceTick(player)
	end
	
	local bobAngle = FixedDiv((leveltime%45)*FRACUNIT, 45*FRACUNIT/2) * 360
	local bobAmount = FixedDiv(player.bob, player.mo.scale)
	player.rsrinfo.bob.y = FixedMul(bobAmount, sin(FixedAngle(-bobAngle))/2) + bobAmount/2
	
	RSR.TickPSpritesBegin(player)
	
	RSR.PlayerDamageTick(player)
	RSR.PlayerPowerupsTick(player)
	
	RSR.TickPSprites(player)
	RSR.ScreenFadeTick(player)
	
	RSR.PlayerStarpostDataTick(player)
	
	if player.rsrinfo.weaponDelay > 0 then
		player.rsrinfo.weaponDelay = $-1
		RSR.WEAPON_STATE_ACTIONS.A_SetWeaponOffset(player, {}) -- TODO: There's probably a better way to do this
	end
	
-- 	player.rsrinfo.lastshield = player.powers[pw_shield] & SH_NOSTACK
	player.rsrinfo.lastbuttons = player.cmd.buttons
	
	-- Override the default weapons controls
	player.weapondelay = 1
	player.cmd.buttons = $ & ~(BT_WEAPONNEXT|BT_WEAPONPREV|BT_WEAPONMASK)
end

addHook("PlayerSpawn", RSR.PlayerSpawn)
addHook("PlayerThink", RSR.PlayerThink)
addHook("ShieldSpecial", RSR.PlayerShieldSpecial)
addHook("AbilitySpecial", RSR.PlayerAbilitySpecial)
addHook("MobjDamage", RSR.PlayerDamage, MT_PLAYER)
addHook("ShouldDamage", RSR.PlayerShouldDamage, MT_PLAYER)
addHook("MobjCollide", RSR.PlayerMelee, MT_PLAYER)
addHook("MobjMoveCollide", RSR.PlayerMelee, MT_PLAYER)
addHook("MobjDeath", RSR.PlayerDeath, MT_PLAYER)

-- Override HurtMsg in favor of the killfeed
addHook("HurtMsg", do
	if RSR.GamemodeActive() then return true end
end)
