-- Ringslinger Revolution - Player Health System

local RSR = RingslingerRev

RSR.HOMING_THRESHOLD_THOK = 40
RSR.HOMING_THRESHOLD_ATTRACT = 60

RSR.HITSOUND_TO_SFX = {
	[1] = sfx_s3k96,
	[2] = sfx_hoop3
}

-- Helper function for checking friendly fire
RSR.CheckFriendlyFire = do
	return (CV_FindVar("friendlyfire").value or (gametyperules & GTR_FRIENDLYFIRE))
end

RSR.PlayerHealthInit = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	local rsrinfo = player.rsrinfo
	
	rsrinfo.health = RSR.MAX_HEALTH
-- 	rsrinfo.health = 1 -- For testing purposes only
	rsrinfo.armor = 0
	
	rsrinfo.hurtByEnemy = 0
	rsrinfo.hurtByMelee = 0
	rsrinfo.hurtByMap = false
	rsrinfo.attackKnockback = false
	rsrinfo.hitSound = 0
	
	if G_RingSlingerGametype() then -- Replaces the Pity Shield with a "pity armour start" feature
		if (player.powers[pw_shield] & SH_NOSTACK) then
			rsrinfo.armor = $ + 25
			P_RemoveShield(player) -- Don't spawn with a shield in deathmatch
		end
	end
end

RSR.PlayerDamageTick = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	local rsrinfo = player.rsrinfo
	
	if rsrinfo.hurtByEnemy > 0 then rsrinfo.hurtByEnemy = max(0, $-1) end
	if rsrinfo.hurtByMelee > 0 then rsrinfo.hurtByMelee = max(0, $-1) end
	if rsrinfo.hurtByMap then rsrinfo.hurtByMap = false end
	if rsrinfo.attackKnockback then rsrinfo.attackKnockback = false end
	if rsrinfo.hitSound then
		if RSR.HITSOUND_TO_SFX[rsrinfo.hitSound] then
			S_StartSound(nil, RSR.HITSOUND_TO_SFX[rsrinfo.hitSound], player)
		end
		rsrinfo.hitSound = 0
	end
end

RSR.PlayerDamage = function(target, inflictor, source, damage, damagetype)
	if not RSR.GamemodeActive() then return end
	if not Valid(target) then return end
	if target.health <= 0 then return end
	local player = target.player
	
	-- Don't run this code if DMG_DEATHMASK is in effect
	if ((damagetype or 0) & DMG_DEATHMASK) then return end
	
	local knockbackScale = FRACUNIT
	local couldAttack = false
	
	local hurtByEnemy = false
	local hurtByMelee = false
	if Valid(inflictor) then
		local infInfo = RSR.MOBJ_INFO[inflictor.type]
		
		if inflictor.rsrProjectile then
			-- ProjectileMoveCollide already sets the damage value, but we'll do it again just in case
			if not inflictor.rsrDamage then -- rsrDamage is used by the bounce ring to determine how much damage is dealt, so don't override it
				damage = inflictor.info.damage -- Maybe use MOBJ_INFO damage here???
			end
		elseif Valid(inflictor.player) then
			if damagetype == DMG_NUKE then
				damage = RSR.GetArmageddonDamage(target, inflictor)
			else
				hurtByMelee = true
			end
		elseif not inflictor.rsrRealDamage then
			if infInfo and infInfo.damage ~= nil then
				damage = infInfo.damage
			else
				damage = 15
			end
			
			hurtByEnemy = true
		end
		
		if infInfo and infInfo.knockback ~= nil then
			knockbackScale = infInfo.knockback
		end
	end
	
	if not (Valid(player) and player.rsrinfo) then return end
	
	if hurtByEnemy then player.rsrinfo.hurtByEnemy = TICRATE end
	if hurtByMelee then player.rsrinfo.hurtByMelee = TICRATE end
	
	local saved = 0
	local rsrinfo = player.rsrinfo
	local hurtSound = sfx_s3k5d
	
	local shield = (player.powers[pw_shield] & SH_NOSTACK)
	
	-- Handles Attraction Shield homing break
	if player.rsrinfo.homing then
		-- Tracks how much damage you've accumulated through your lock-on
		player.rsrinfo.homingThreshold = $ + damage
		
		-- If you exceed the break threshold, revokes Maxwell's equations for electromagnetism, plays a sound to let everyone nearby know of that, and cancels your melee hurtbox 
		if shield == SH_ATTRACT and (player.pflags & PF_SHIELDABILITY) then
			if (player.rsrinfo.homingThreshold > RSR.HOMING_THRESHOLD_ATTRACT) or (player.rsrinfo.armor < 1) then
				P_ResetPlayer(player)
				player.rsrinfo.homing = 0
				S_StartSound(player.mo, sfx_s3ka6)
				player.state = S_PLAY_PAIN
				P_SetObjectMomZ(player.mo, 8*FRACUNIT)
			end
		elseif player.charability == CA_HOMINGTHOK then
			if player.rsrinfo.homingThreshold > RSR.HOMING_THRESHOLD_THOK then
				P_ResetPlayer(player)
				player.rsrinfo.homing = 0
				S_StartSound(player.mo, sfx_s3k90)
				player.state = S_PLAY_PAIN
				P_SetObjectMomZ(player.mo, 4*FRACUNIT)
			end
		end
	end

	-- Health saving while you have armour
	if rsrinfo.armor then
		saved = damage/2
		
		-- Force Shield is less affected by armour loss than other shields (it still only saves the same amount of health though)
		if (player.powers[pw_shield] & SH_FORCE) then
			saved = $ * 3 / 4
		end
		
		saved = min($, rsrinfo.armor)
		
		rsrinfo.armor = max($ - saved, 0) -- Make sure armor doesn't go below 0
		damage = $ - saved
	end
	
	-- Use this for giving armor to players who manually detonated their Armageddon Shield
	local damageReal = min(damage, rsrinfo.health)
-- 	if damageReal > rsrinfo.health then damageReal = rsrinfo.health end
	
	rsrinfo.health = max($ - damage, 0) -- Make sure health doesn't go below 0
	
	rsrinfo.attacker = source
	
	if Valid(source) and Valid(source.player) then
		-- Give the source player an armor boost if the damage was from a manually detonated Armageddon Blast
		if damagetype == DMG_NUKE and (source.player.pflags & PF_SHIELDABILITY) and source.player.rsrinfo.armor > 0 then
			RSR.GiveArmor(source.player, damageReal)
			RSR.BonusFade(source.player)
			S_StartSound(nil, sfx_shield, source.player)
		end
	end
	
	-- Tiered damage fades based on severity of damage taken
	if damage < 16 then -- Hit by "standard" ring/melee attack
		RSR.SetScreenFade(player, 35, FRACUNIT/4, TICRATE/4)
	elseif damage < 49 then -- Hit by "empowered" ring/melee attack
		RSR.SetScreenFade(player, 35, FRACUNIT/3, TICRATE/3)
	elseif damage < 100 then -- Exploded
		RSR.SetScreenFade(player, 35, FRACUNIT/2, TICRATE/2)
	else -- Something has gone terribly, terribly wrong
		RSR.SetScreenFade(player, 35, FRACUNIT, TICRATE/2)
	end
	
	if shield then
		-- Reflect projectiles if the player has a Force Shield (also causes homing rings to rebel against their master)
		if (player.powers[pw_shield] & SH_FORCE) and Valid(inflictor) and (inflictor.flags & MF_MISSILE) 
		and not (inflictor.rsrExplosiveRing or (inflictor.flags & (MF_ENEMY|MF_GRENADEBOUNCE))) then
			if not inflictor.rsrForceReflected then
				local missile
				if inflictor.rsrProjectile then
					if inflictor.rsrRailRing then
						missile = RSR.SpawnRailRing(target, inflictor.angle + ANGLE_180, -inflictor.pitch, true)
					else
						missile = RSR.SpawnPlayerMissile(target, inflictor.type, inflictor.angle + ANGLE_180, -inflictor.pitch, true)
					end
				else
					missile = P_SpawnPlayerMissile(target, inflictor.type, inflictor.flags2)
				end
				
				if Valid(missile) then
					P_SetOrigin(missile, inflictor.x, inflictor.y, inflictor.z)
					missile.scale = inflictor.scale
					missile.momx = -inflictor.momx
					missile.momy = -inflictor.momy
					missile.momz = -inflictor.momz
					if Valid(source) and (Valid(inflictor.tracer) and inflictor.tracer ~= source) then
						inflictor.tracer = source
					end
					missile.color = inflictor.color
					missile.colorized = inflictor.colorized
					missile.rsrProjectile = inflictor.rsrProjectile
					missile.rsrRealDamage = inflictor.rsrRealDamage
				end
				
				-- Don't let the missile explode in your face
				P_RemoveMobj(inflictor)
			end
		end
		
		-- Reduce knockback if the player has a Whirlwind Shield
		if shield == SH_WHIRLWIND and Valid(inflictor) and (inflictor.flags & MF_MISSILE) 
		and not (inflictor.rsrExplosiveRing) then
			knockbackScale = $/2 -- TODO: Maybe extend this to the other weapon rings and explosions?
		end
		
		-- Remove shields and auto-det Armageddon when shields or health fall below 1
		if rsrinfo.armor < 1 or rsrinfo.health < 1 then
			if (player.powers[pw_shield] & SH_FORCEHP) then
				player.powers[pw_shield] = $ & ~SH_FORCEHP
			end
			if shield == SH_ARMAGEDDON then
				P_BlackOw(player)
			end
			P_RemoveShield(player)
			hurtSound = sfx_shldls
		end
	end
	
	-- TODO: Insert code for rumble support here when it gets exposed to Lua
	
	if rsrinfo.health <= 0 then
		player.powers[pw_shield] = SH_NONE
		player.rings = 0
		return
	end
	
	if Valid(inflictor) and not inflictor.rsrDontThrust and not player.rsrinfo.homing then
		local ang = R_PointToAngle2(inflictor.x, inflictor.y, target.x, target.y)
		if FixedHypot(FixedHypot(inflictor.x - target.x, inflictor.y - target.y), inflictor.z - target.z) < FRACUNIT then
			ang = target.angle + ANGLE_180
		end
		local thrust = damage * (FRACUNIT / (2^3)) * 100 / 100 -- Originally divided by target.info.mass
		
		P_Thrust(target, ang, FixedMul(knockbackScale, thrust))
		
		-- Knock the player into the air if they were melee'd by another player
		if Valid(inflictor.player) and damagetype ~= DMG_NUKE then
			P_ResetPlayer(player)
			target.z = $+P_MobjFlip(target)
			target.state = S_PLAY_PAIN
			if shield == SH_WHIRLWIND then -- Whirlwind melee knockback halving
				P_SetObjectMomZ(target, 4*FRACUNIT)
			else
				P_SetObjectMomZ(target, 8*FRACUNIT)
			end
			if player.rsrinfo.attackKnockback then
				target.momx = -$/2
				target.momy = -$/2
				player.rsrinfo.attackKnockback = false
			else
				local meleeMom = FixedHypot(inflictor.momx, inflictor.momy)
				if shield == SH_WHIRLWIND then -- Whirlwind melee knockback halving
					P_Thrust(target, ang, FixedMul(knockbackScale/2, meleeMom/4))
				else
					P_Thrust(target, ang, FixedMul(knockbackScale, meleeMom/2))
				end
			end
		end
		
		-- Do this to prevent the player from standing still when thrusted while not moving
		player.rmomx = target.momx + player.cmomx
		player.rmomy = target.momy + player.cmomy
	end
	
	S_StartSound(target, hurtSound)
	if Valid(source) and Valid(source.player) and source.player.rsrinfo
	and source.player ~= player and not RSR.PlayersAreTeammates(player, source.player) then
		source.player.rsrinfo.hitSound = 1
	end
	return true
end

RSR.PlayerSourceShouldDamage = function(player, source)
	if not (Valid(player) and Valid(source)) then return end
	
	if Valid(source.player) and RSR.PlayersAreTeammates(player, source.player)
		if player ~= source.player and not RSR.CheckFriendlyFire() then -- If the player is not damaging themselves and friendly fire is not enabled, don't deal damage
			return false
		else -- Otherwise, force damage and (possibly) death
			return true
		end
	end
end

RSR.PlayerShouldDamage = function(target, inflictor, source, damage, damagetype)
	if not RSR.GamemodeActive() then return end
	if not Valid(target) then return end
	
	local player = target.player
	if not (Valid(player) and player.rsrinfo) then return end
	local rsrinfo = player.rsrinfo
	
	if ((damagetype or 0) & DMG_DEATHMASK)
	or (player.pflags & PF_GODMODE)
	or player.exiting then
		return
	end
	
	if player.powers[pw_flashing]
	or player.powers[pw_invulnerability]
	or player.powers[pw_super] 
	or (player.powers[pw_strong] & STR_GUARD) then
		return
	end
	
	if player.powers[pw_carry] == CR_NIGHTSMODE
	or player.powers[pw_carry] == CR_NIGHTSFALL then
		return
	end
	
	local shield = player.powers[pw_shield]
	if damagetype == DMG_FIRE and (shield & SH_PROTECTFIRE) then return end
	if damagetype == DMG_WATER and (shield & SH_PROTECTWATER) then return end
	if damagetype == DMG_ELECTRIC and (shield & SH_PROTECTELECTRIC) then return end
	if damagetype == DMG_SPIKE and (shield & SH_PROTECTSPIKE) then return end
	
	if RSR.HasPowerup(player, RSR.POWERUP_INVINCIBILITY) then
		if Valid(inflictor) and (inflictor.flags & MF_SHOOTABLE) and not inflictor.rsrEnemyBlink
		and not Valid(inflictor.player) then -- This code was meant for enemies only
			P_DamageMobj(inflictor, target, target, 1)
		end
		return false
	end
	
	if Valid(inflictor) then
		if not (inflictor.rsrProjectile or inflictor.rsrRealDamage or Valid(inflictor.player)) and rsrinfo.hurtByEnemy then return false end
		if Valid(inflictor.player) then
			if rsrinfo.hurtByMelee then return false end
			if RSR.PlayersAreTeammates(player, inflictor.player) and not RSR.CheckFriendlyFire() then return false end
		end
		if inflictor.rsrEnemyBlink then return false end
		return RSR.PlayerSourceShouldDamage(player, source)
	end
	
	if Valid(source) then
		return RSR.PlayerSourceShouldDamage(player, source)
	end
	
	if not ((leveltime & 0x1f) or rsrinfo.hurtByMap) then
		RSR.PlayerDamage(target, inflictor, source, 10, damagetype)
		rsrinfo.hurtByMap = true
	end
	
	if rsrinfo.health <= 0 then return end
	
	return false
end

RSR.PlayerDeath = function(target, inflictor, source, damagetype)
	if not RSR.GamemodeActive() then return end
	if not Valid(target) then return end
	
	local player = target.player
	if not (Valid(player) and player.rsrinfo) then return end
	
	local rsrinfo = player.rsrinfo
	
	-- Don't let the player's lives counter go down
	if player.lives ~= INFLIVES then
		player.lives = $+1
	end
	
	rsrinfo.pendingWeapon = RSR.WEAPON_NONE
	RSR.PlayerSetChasecam(player, true)
	
	-- Only run this code in multiplayer gamemodes
	if multiplayer or netgame then
		if G_RingSlingerGametype() then
			local sourcePlayer = Valid(source) and source.player
			RSR.KillfeedAdd(target.player, inflictor, sourcePlayer, damagetype) -- TODO: Make sure this doesn't cause errors
			
			-- Melee attacks always have the player object be the inflictor
			if Valid(inflictor) and Valid(inflictor.player) and inflictor.player.rsrinfo then
				if (inflictor.player.powers[pw_shield] & SH_NOSTACK) == SH_ATTRACT -- Player has an Attraction Shield
				and (inflictor.player.pflags & PF_SHIELDABILITY) -- Player is using the Attraction Shield
				and inflictor.player.rsrinfo.homing -- Player is homing
				and (Valid(inflictor.tracer) and inflictor.tracer == target) then -- Player is targetting us
					RSR.GiveArmor(inflictor.player, 100)
					-- Give the player an indicator that they just got armor
					RSR.BonusFade(inflictor.player)
					S_StartSound(nil, sfx_attrsg, inflictor.player)
				end
			end
			
			if Valid(source) and Valid(source.player) and source.player.rsrinfo
			and source.player ~= player and not RSR.PlayersAreTeammates(player, source.player) then
				source.player.rsrinfo.hitSound = 2
			end
		end
		
		-- Let players keep their weapons and some of their ammo when dying in co-op
		if G_CoopGametype() and rsrinfo.starpostData then
			local starpostData = rsrinfo.starpostData
			starpostData.weapons = RSR.DeepCopy(rsrinfo.weapons)
			starpostData.ammo = RSR.DeepCopy(rsrinfo.ammo)
			starpostData.readyWeapon = rsrinfo.readyWeapon
			
			for ammoType, ammoAmount in ipairs(rsrinfo.ammo) do
				local newAmount = RSR.AMMO_INFO[ammoType].amount
				if starpostData.ammo[ammoType] <= newAmount then continue end
				starpostData.ammo[ammoType] = newAmount
			end
		end
		
		for weapon, inInventory in ipairs(rsrinfo.weapons) do
			if not inInventory then continue end
			local weaponInfo = RSR.WEAPON_INFO[weapon]
			if not (weaponInfo and weaponInfo.motype) then continue end
			local ammoInfo = RSR.AMMO_INFO[weaponInfo.ammoType]
			local ammoAmount = rsrinfo.ammo[weaponInfo.ammoType]
			if (G_CoopGametype() or G_RingSlingerGametype()) and ammoAmount <= ammoInfo.amount then continue end
			
			local angle = FixedAngle(weapon * (360*FRACUNIT / #rsrinfo.weapons))
			
			local pickup = P_SpawnMobjFromMobj(target, 0, 0, FRACUNIT, weaponInfo.motype)
			if Valid(pickup) then
				if G_CoopGametype() or G_RingSlingerGametype() then
					pickup.rsrAmmoAmount = ammoAmount - ammoInfo.amount
				else
					pickup.rsrAmmoAmount = ammoAmount
				end
				if pickup.info.seestate then pickup.state = pickup.info.seestate end
				pickup.flags = $ & ~(MF_NOGRAVITY|MF_NOCLIPHEIGHT)
				pickup.flags2 = $|MF2_DONTRESPAWN
				pickup.fuse = 12*TICRATE -- Don't linger forever
				P_SetObjectMomZ(pickup, 3*FRACUNIT)
				P_InstaThrust(pickup, angle, 3*pickup.scale)
			end
		end
	end
end

RSR.PlayerMelee = function(pmo, pmo2)
	if not RSR.GamemodeActive() then return end
	if not G_RingSlingerGametype() then return end -- Only works in deathmatch and CTF
	if not (Valid(pmo) and Valid(pmo2)) then return end
	
	-- Height check
	if not (pmo.z <= pmo2.z + pmo2.height
	and pmo2.z <= pmo.z + pmo.height) then
		return
	end
	
	if not (Valid(pmo.player) and pmo.player.rsrinfo and Valid(pmo2.player) and pmo2.player.rsrinfo) then return end -- Only for players
	
	local player = pmo.player
	local player2 = pmo2.player
	
	if RSR.PlayersAreTeammates(player, player2) and not RSR.CheckFriendlyFire() then return end -- Don't hurt teammates unless friendlyfire is on
	
	local meleeBaseDamage = 15
	local meleeBaseDamage2 = 15
	local meleeMult = 1
	local meleeMult2 = 1
	
	local shield = (player.powers[pw_shield] & SH_NOSTACK)
	local shield2 = (player2.powers[pw_shield] & SH_NOSTACK)
	
	-- This big chunk of elifs sets melee damage to use in the interaction based on the players' shields and powerups
	-- -Evertone
	if (shield == SH_ELEMENTAL or shield == SH_FLAMEAURA or shield == SH_BUBBLEWRAP) and (player.pflags & PF_SHIELDABILITY) then
		meleeBaseDamage = 30
	elseif shield == SH_ATTRACT and (player.pflags & PF_SHIELDABILITY) and player.rsrinfo.homing then
		meleeBaseDamage = 20
	end
	
	if (shield2 == SH_ELEMENTAL or shield2 == SH_FLAMEAURA or shield2 == SH_BUBBLEWRAP) and (player2.pflags & PF_SHIELDABILITY) then
		meleeBaseDamage2 = 30
	elseif shield2 == SH_ATTRACT and (player2.pflags & PF_SHIELDABILITY) and player2.rsrinfo.homing then
		meleeBaseDamage2 = 20
	end
	
	if RSR.HasPowerup(player, RSR.POWERUP_INVINCIBILITY) or player.powers[pw_invulnerability] then -- Second check is for if the player has all emeralds
		meleeMult = 3
	else
		meleeMult = 1
	end
	
	if RSR.HasPowerup(player2, RSR.POWERUP_INVINCIBILITY) or player2.powers[pw_invulnerability] then -- Second check is for if the player has all emeralds
		meleeMult2 = 3
	else
		meleeMult2 = 1
	end
	
	local playerDamage = meleeBaseDamage * meleeMult
	local playerDamage2 = meleeBaseDamage2 * meleeMult2

	-- Handle cases where players can harm each other
	if P_PlayerCanDamage(player, pmo2) and P_PlayerCanDamage(player2, pmo) then
		player.rsrinfo.attackKnockback = true
		player2.rsrinfo.attackKnockback = true
		if not player2.rsrinfo.hurtByMelee then
			P_DamageMobj(pmo2, pmo, pmo, playerDamage/2)
		end
		if not player.rsrinfo.hurtByMelee then
			P_DamageMobj(pmo, pmo2, pmo2, playerDamage2/2)
		end
		return
	end
	
	if P_PlayerCanDamage(player, pmo2) and not player2.rsrinfo.hurtByMelee then
		P_DamageMobj(pmo2, pmo, pmo, playerDamage)
	end
	
	if P_PlayerCanDamage(player2, pmo2) and not player.rsrinfo.hurtByMelee then
		P_DamageMobj(pmo, pmo2, pmo2, playerDamage2)
	end
end
