-- Ringslinger Revolution - Weapons

local folder = "weapon"

local dofolder = function(file)
	dofile(folder.."/"..file)
end

local RSR = RingslingerRev

-- Initialize weapons, ammo, and psprites
-- RSR.AddEnum("WEAPON", "NONE", true)

RSR.AddEnum("PS", "WEAPON")

RSR.LOWER_OFFSET = 128*FRACUNIT
RSR.UPPER_OFFSET = 0
RSR.RAISE_SPEED = 12*FRACUNIT

if not RSR.CLASS_TO_WEAPON then
	RSR.CLASS_TO_WEAPON = {}
	for i = 1, 7 do
		RSR.CLASS_TO_WEAPON[i] = {}
	end
end

-- Used for co-op respawning
if not RSR.AMMO_INFO then
	RSR.AMMO_INFO = {}
end

RSR.AddAmmo = function(name, info)
	if not (name and info) then
		print("WARNING: Unable to add ammo "..tostring(name).."!")
		return
	end
	
	RSR.AddEnum("AMMO", name)
	local ammo = RSR["AMMO_"..name]
	RSR.AMMO_INFO[ammo] = info
end

RSR.AddAmmo("BASIC", {
	amount = 40,
	maxAmount = 320,
	motype = MT_RSR_PICKUP_BASIC
})
RSR.AddAmmo("SCATTER", {
	amount = 20,
	maxAmount = 50,
	motype = MT_RSR_PICKUP_SCATTER
})
RSR.AddAmmo("AUTO", {
	amount = 80,
	maxAmount = 800,
	motype = MT_RSR_PICKUP_AUTO
})
RSR.AddAmmo("BOUNCE", {
	amount = 16,
	maxAmount = 160,
	motype = MT_RSR_PICKUP_BOUNCE
})
RSR.AddAmmo("GRENADE", {
	amount = 10,
	maxAmount = 100,
	motype = MT_RSR_PICKUP_GRENADE
})
RSR.AddAmmo("BOMB", {
	amount = 10,
	maxAmount = 100,
	motype = MT_RSR_PICKUP_BOMB
})
RSR.AddAmmo("HOMING", {
	amount = 10,
	maxAmount = 50,
	motype = MT_RSR_PICKUP_HOMING
})
RSR.AddAmmo("RAIL", {
	amount = 1,
	maxAmount = 10,
	motype = MT_RSR_PICKUP_RAIL
})

if not RSR.WEAPON_INFO then
	RSR.WEAPON_INFO = {}
end

-- Info Guide for weapons

-- ammoType - Type of ammo to use for weapons (use RSR.AddAmmo to add a new type)
-- ammoAmount - Amount of ammo to give 
-- canBePanel - Determines whether the weapon can be a panel or not (Default is true)
-- class - Determines class of the weapon (Only 1 through 7)
-- classpriority - Determines which weapon in its class gets chosen first (lower number equals higher priority)
-- delay - Recovery time for the weapon (should match its recover state)
-- delayspeed - Recovery time for the weapon while player has super sneakers (should match its recoverspeed state)
-- icon - Graphic to use for the weapon bar on the HUD
-- motype - Pickup object for the weapon
-- powerweapon - Prevents the weapon from showing up on the HUD if the player has no ammo for it (Default is false)
-- states - Should be a table with the following
--     draw - State for bringing up the weapon
--     ready - Idle state
--     holster - State for lowering the weapon (UNUSED)
--     attack - Attack state
--     recoverspeed - Recover state if player has super sneakers

RSR.AddWeapon = function(name, info)
	if not (name and info) then
		print("WARNING: Unable to add weapon "..tostring(name).."!")
		return
	end
	
	RSR.AddEnum("WEAPON", name, true)
	local weapon = RSR["WEAPON_"..name]
	RSR.WEAPON_INFO[weapon] = info
	if info.class then
		if not RSR.CLASS_TO_WEAPON[info.class] then RSR.CLASS_TO_WEAPON[info.class] = {} end
		local classTable = RSR.CLASS_TO_WEAPON[info.class]
		table.insert(classTable, weapon)
		table.sort(classTable, function(a, b)
			return ((info.classpriority or 0) > (RSR.WEAPON_INFO[b].classpriority or 0))
		end)
		
		for tSlot, tWeapon in ipairs(classTable) do
			RSR.WEAPON_INFO[tWeapon].slot = tSlot
		end
	end
end

RSR.AddWeapon("NONE", {
	states = {
		draw = "S_NONE_READY",
		ready = "S_NONE_READY",
		holster = "S_NONE_HOLSTER"
	}
})

-- RSR.WEAPON_INFO[RSR.WEAPON_NONE] = {
-- 	states = {
-- 		draw = "S_NONE_READY",
-- 		ready = "S_NONE_READY",
-- 		holster = "S_NONE_HOLSTER"
-- 	}
-- }

RSR.GetAmmoInfoFromWeapon = function(weapon)
	if not weapon then return end
	if not (RSR.WEAPON_INFO[weapon] and RSR.WEAPON_INFO[weapon].ammoType) then return end
	local ammoType = RSR.WEAPON_INFO[weapon].ammoType
	
	return RSR.AMMO_INFO[ammoType]
end

RSR.GiveAmmo = function(player, amount, ammoType)
	if not (Valid(player) and player.rsrinfo) then return end
	amount = $ or 0
	
	local rsrinfo = player.rsrinfo
	
	if not RSR.AMMO_INFO[ammoType] then return end
	local ammoMax = RSR.AMMO_INFO[ammoType].maxAmount
	if ammoMax == nil then
		print("WARNING: Maximum ammo for "..tostring(ammoType).." could not be determined! Defaulting to 50...")
		ammoMax = 50
	end
	rsrinfo.ammo[ammoType] = min(ammoMax, $ + amount)
end

RSR.TakeAmmo = function(player, amount, ammoType)
	if not (Valid(player) and player.rsrinfo) then return end
	if RSR.HasPowerup(player, RSR.POWERUP_INFINITY) then return end -- Don't deplete ammo if the player has the infinity powerup
	amount = $ or 0
	
	local rsrinfo = player.rsrinfo
	
	rsrinfo.ammo[ammoType] = max(0, $ - amount)
end

RSR.TakeAmmoFromReadyWeapon = function(player, amount)
	if not (Valid(player) and player.rsrinfo) then return end
	
	RSR.TakeAmmo(player, amount or 0, RSR.WEAPON_INFO[player.rsrinfo.readyWeapon].ammoType)
end

RSR.GiveWeapon = function(player, weapon, newAmount)
	if not (Valid(player) and player.rsrinfo) then return end
	
	local rsrinfo = player.rsrinfo
-- 	local hadWeapon = rsrinfo.weapons[weapon]
	local hadWeapon = false
	for _, hasWeapon in ipairs(rsrinfo.weapons) do
		if not hasWeapon then continue end
		
		-- If the player has a weapon at all, don't switch weapons
		hadWeapon = true
		break
	end
	local switchWeapon = player.rsrinfo.readyWeapon == weapon and not RSR.CheckAmmo(player)
	
	rsrinfo.weapons[weapon] = true
	local weaponInfo = RSR.WEAPON_INFO[weapon]
	if weaponInfo and weaponInfo.ammoType then
		local ammoInfo = RSR.AMMO_INFO[weaponInfo.ammoType]
		local ammoAmount = 0
		if newAmount ~= nil then
			ammoAmount = newAmount
		elseif ammoInfo and ammoInfo.amount then
			ammoAmount = ammoInfo.amount
		end
		RSR.GiveAmmo(player, ammoAmount, weaponInfo.ammoType)
	end
	if not hadWeapon then -- Switch the player's weapon if they didn't have any weapons
		rsrinfo.pendingWeapon = weapon
	elseif switchWeapon then -- Switch the player's weapon if they didn't have any ammo for their currently held one
		RSR.DrawWeapon(player, weapon)
	end
end

RSR.GetWeaponDelay = function(weapon, speed)
	if weapon == nil then return 1 end
	
	local info = RSR.WEAPON_INFO[weapon]
	if not (info and info.delay ~= nil) then return 1 end
	
	if speed and info.delayspeed ~= nil then return info.delayspeed end
	return info.delay
end

RSR.ProjectileSpawn = function(mo)
	if not Valid(mo) then return end
	mo.shadowscale = 2*FRACUNIT/3
	mo.rsrProjectile = true
end

RSR.ProjectileMoveCollide = function(tmthing, thing)
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
	
	local damage = tmthing.info.damage
	if tmthing.rsrDamage then damage = tmthing.rsrDamage end
	P_DamageMobj(thing, tmthing, tmthing.target, damage)
	if Valid(tmthing) then P_ExplodeMissile(tmthing) end
	return false
end

RSR.WeaponTouchSpecial = function(special, toucher, weaponType)
	if not (Valid(special) and Valid(toucher) and weaponType) then return end
	
	local player = toucher.player
	if not (Valid(player) and player.rsrinfo) then return end
	
	local rsrinfo = player.rsrinfo
	
	-- Don't pick up the weapon if the player already has it
	local coopMode = false
	if ((multiplayer or netgame) and G_CoopGametype()) and special.rsrDontDespawn then
		if rsrinfo.weapons[weaponType] then return true end
		coopMode = true
	end
	
	-- Don't pick up the weapon if the player has the maximum amount of ammo
	local ammoInfo = RSR.GetAmmoInfoFromWeapon(weaponType)
	local ammoType = RSR.WEAPON_INFO[weaponType].ammoType
	if ammoInfo and ammoInfo.maxAmount and rsrinfo.ammo[ammoType] >= ammoInfo.maxAmount then return true end
	
	local isPanel = special.rsrIsPanel or false
	if not isPanel and RSR.WEAPON_INFO[weaponType].canBePanel == false then
		isPanel = true
	end
	
	local ammoAmount = nil
	if special.rsrAmmoAmount then -- Used in co-op and match when the player spills their ammo
		ammoAmount = special.rsrAmmoAmount
	elseif not isPanel then
		ammoAmount = (RSR.WEAPON_INFO[weaponType].ammoAmount or 0) / 2
	end
	RSR.GiveWeapon(player, weaponType, ammoAmount)
	
	if coopMode then
		S_StartSound(special, special.info.deathsound)
		return true
	end
	
	RSR.SetItemFuse(special)
end

RSR.WeaponMapThingSpawn = function(mo, mthing)
	if not (Valid(mo) and Valid(mthing)) then return end
	
	RSR.ItemMapThingSpawn(mo, mthing)
	
	if mthing.args[1] then
		mo.rsrDontDespawn = true
	end
	
	if not mthing.args[2] and mo.info.seestate ~= S_NULL then
		mo.state = mo.info.seestate
		mo.rsrIsPanel = true
	end
end

RSR.WeaponPickupThinker = function(mo)
	if not Valid(mo) then return end
	
	-- Make the pickup flicker to show the player it's about to disappear
	if mo.fuse and mo.fuse < 2*TICRATE and (mo.flags2 & MF2_DONTRESPAWN) then
		-- Only flicker if the pickup hasn't been picked up
		if mo.health then
			mo.flags2 = $ ^^ MF2_DONTDRAW
		else
			mo.flags2 = $ & ~MF2_DONTDRAW
		end
	end
	
	if multiplayer and G_CoopGametype() then
		if (leveltime % 4) == 0 and mo.rsrDontDespawn then
			local ghost = P_SpawnGhostMobj(mo)
			if Valid(ghost) then
				ghost.momx = P_RandomRange(-2, 2)*mo.scale
				ghost.momy = P_RandomRange(-2, 2)*mo.scale
				ghost.momz = P_RandomRange(-2, 2)*mo.scale
				ghost.fuse = TICRATE/4
				ghost.blendmode = AST_ADD
-- 				ghost.destscale = 2*mo.scale
			end
		end
	end
end

RSR.WeaponMobjFuse = function(mo)
	if not Valid(mo) then return end
	if (mo.flags2 & MF2_DONTRESPAWN) then return end
	
	local itemType = mo.type
	
	local newItem = P_SpawnMobjFromMobj(mo, 0, 0, 0, itemType)
	if Valid(newItem) then
		newItem.flags2 = mo.flags2
		newItem.spawnpoint = mo.spawnpoint
		newItem.shadowscale = mo.shadowscale
		newItem.rsrIsPanel = mo.rsrIsPanel
		newItem.rsrPickup = mo.rsrPickup
		
		if newItem.rsrIsPanel and mo.info.seestate ~= S_NULL then
			newItem.state = newItem.info.seestate
		end
	end
	
	P_RemoveMobj(mo)
end

dofolder("basic.lua")
dofolder("scatter.lua")
dofolder("auto.lua")
dofolder("bounce.lua")
dofolder("grenade.lua")
dofolder("bomb.lua")
dofolder("homing.lua")
dofolder("rail.lua")
