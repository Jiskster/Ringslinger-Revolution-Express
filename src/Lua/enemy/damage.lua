-- Ringslinger Revolution - Enemy Damage

local RSR = RingslingerRev

-- *** IMPORTANT ***
-- Keep this consistent with the enemies in MOBJ_INFO
RSR.ENEMY_LIST = {
	MT_BLUECRAWLA,
	MT_REDCRAWLA,
	MT_GFZFISH,
	MT_GOLDBUZZ,
	MT_REDBUZZ,
	MT_DETON,
	MT_POPUPTURRET,
	MT_SPRINGSHELL,
	MT_YELLOWSHELL,
	MT_SKIM,
	MT_JETJAW,
	MT_CRUSHSTACEAN,
	MT_BANPYURA,
	MT_ROBOHOOD,
	MT_FACESTABBER,
	MT_EGGGUARD,
	MT_VULTURE,
	MT_GSNAPPER,
	MT_MINUS,
	MT_CANARIVORE,
	MT_UNIDUS,
	MT_PTERABYTE,
	MT_PYREFLY,
	MT_DRAGONBOMBER,
	MT_JETTBOMBER,
	MT_JETTGUNNER,
	MT_SPINCUSHION,
	MT_SNAILER,
	MT_PENGUINATOR,
	MT_POPHAT,
	MT_CRAWLACOMMANDER,
	MT_SPINBOBERT,
	MT_CACOLANTERN,
	MT_HANGSTER,
	MT_HIVEELEMENTAL,
	MT_BUMBLEBORE,
	MT_BUGGLE,
	MT_POINTY,
	MT_EGGMOBILE,
	MT_EGGMOBILE2,
	MT_EGGMOBILE3,
	MT_EGGMOBILE4,
	MT_FANG,
	MT_METALSONIC_BATTLE,
	MT_BLACKEGGMAN,
 	MT_CYBRAKDEMON,
	MT_CYBRAK2016
}

RSR.EnemySetBlink = function(mo, timer)
	if not Valid(mo) then return end
	if timer == nil then timer = TICRATE/3 end
	
	if not mo.rsrIsThinker then
		table.insert(RSR.ENEMY_THINKERS, mo)
	end
	mo.rsrIsThinker = true
	mo.rsrEnemyBlink = timer
end

RSR.EnemySetHealth = function(target, inflictor, source, damage, damagetype)
	if not Valid(target) then return end
	if not damage then return end
	
	local healthScale = 30
	local enemyHealth = RSR.MOBJ_INFO[target.type].health
	if enemyHealth ~= nil then
		healthScale = (enemyHealth / target.info.spawnhealth)
	end
	
	-- Handles enemies that regenerate their health
	if not target.rsrHealth and target.health then
		target.rsrHealth = target.health*healthScale
		target.rsrSpawnHealth = target.rsrHealth
		target.rsrKilled = nil
	end
	
	if target.rsrHealth > target.health * healthScale then
		target.rsrHealth = target.health * healthScale
	end
	
	target.rsrHealth = max(0, $ - damage)
	
	local currentHealth = target.health
	local triggerPainState = false
	
	-- Decrease the target's health until it matches its snapHealth divided by its health scale
	while FixedCeil((target.rsrHealth * FRACUNIT) / healthScale) < currentHealth * FRACUNIT do
		currentHealth = $ - 1
		triggerPainState = true
	end
	
	target.health = currentHealth
	
	if target.health < 1 or target.rsrHealth < 1 then
		target.snapKilled = true
		if (target.flags & MF_MISSILE) then
			P_ExplodeMissile(target)
		else
			P_KillMobj(target, inflictor, source, damagetype)
		end
	else
		RSR.EnemySetBlink(target)
		S_StartSound(target, sfx_dmpain)
		
-- 		if not Valid(target.target) and Valid(source) and target.info.seestate then
		if not Valid(target.target) and Valid(source) then
-- 			print("Snuck up from behind!")
-- 			target.target = source
-- 			target.state = target.info.seestate
			target.angle = R_PointToAngle2(target.x, target.y, source.x, source.y)
			target.target = source
			
			local searchRadius = 1024*target.scale
			
			searchBlockmap("objects", function(targetMo, enemyMo)
				if not (Valid(targetMo) and Valid(enemyMo)) then return end
				-- TODO: There is a bug where enemies that fired at a TNT barrel face nearby exploded enemies
				-- The ideal solution would be to check if enemyMo == source, but "source" is the TNT barrel
				-- Figure out how to prevent that, eventually
				if (enemyMo.flags & (MF_ENEMY|MF_SHOOTABLE)) ~= (MF_ENEMY|MF_SHOOTABLE) then return end
				if Valid(enemyMo.target) then return end
				
				local distXY = FixedHypot(enemyMo.x - targetMo.x, enemyMo.y - targetMo.y)
				local dist = FixedHypot(distXY, enemyMo.z - targetMo.z)
				
				if dist > searchRadius then return end
				
				enemyMo.angle = R_PointToAngle2(enemyMo.x, enemyMo.y, targetMo.x, targetMo.y)
-- 				enemyMo.target = source
			end, target, target.x - searchRadius, target.x + searchRadius, target.y - searchRadius, target.y + searchRadius)
		end
		
		if (target.flags & MF_BOSS) then
			if triggerPainState and target.info.painstate then
				target.state = target.info.painstate
				target.flags2 = $|MF2_FRET
			end
		end
	end
end

RSR.EnemyShouldDamage = function(target, inflictor, source, damage, damagetype)
	if not RSR.GamemodeActive() then return end -- Only run this code in Ringslinger Revolution maps
	if not (Valid(target) and (target.flags & (MF_ENEMY|MF_BOSS))) then return end
	
	-- Don't override the player's ShouldDamage hook
	if Valid(target.player) then return end
	
	local rsrDamage = false
	local inflictorIsPlayer = false
	
	if Valid(inflictor) then
		if Valid(inflictor.player) then
			inflictorIsPlayer = true
		end
		
		if inflictor.rsrProjectile or inflictor.rsrDamage or inflictor.rsrRealDamage then
			rsrDamage = true
		end
	end
	
	if not rsrDamage then
		damage = 10
		
		if damagetype ~= DMG_NUKE then
			if target.rsrEnemyBlink then
				return false
			end
		end
		
		if inflictorIsPlayer then
			-- Fixes a bug where using an Armageddon Shield makes the player bounce off of the air
			if damagetype == DMG_NUKE then
				damage = RSR.GetArmageddonDamage(target, inflictor)
			elseif RSR.HasPowerup(inflictor.player, RSR.POWERUP_INVINCIBILITY) then
				damage = RSR.MOBJ_INFO[target.type].health / target.info.spawnhealth
			end
		else
			return
		end
	end
	
	RSR.EnemySetHealth(target, inflictor, source, damage, damagetype)
	
	return false
end

RSR.EnemyTouchSpecial = function(special, toucher)
	if not RSR.GamemodeActive() then return end -- Only run this code in Ringslinger Revolution maps
	if not (Valid(special) and Valid(toucher)) then return end
	
	local player = toucher.player
	if not Valid(player) then return end
	
	-- Fixes a bug where the player can get stuck in an enemy while jumping/spinning into it
	if (special.flags & (MF_ENEMY|MF_BOSS)) and (special.rsrEnemyBlink) then return true end
	
	if P_PlayerCanDamage(player, special) then
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_ATTRACT and (player.pflags & PF_SHIELDABILITY) then
			player.pflags = $ & ~PF_SHIELDABILITY -- Make the Attraction Shield chainable
			player.secondjump = UINT8_MAX
		end
		player.homing = 0 -- Make the Attraction Shield not constantly lock on to the enemy
		
		if special.info.spawnhealth < 2 then
			toucher.momx = -$
			toucher.momy = -$
			if player.charability == CA_FLY and player.panim == PA_ABILITY then
				toucher.momz = -$/2
			elseif (player.pflags & PF_GLIDING) and not P_IsObjectOnGround(toucher) then
				player.pflags = $ & ~(PF_GLIDING|PF_JUMPED|PF_NOJUMPDAMAGE)
				toucher.state = S_PLAY_FALL
				toucher.momz = $ + (P_MobjFlip(toucher) * (player.speed / 8))
				toucher.momx = 7*$/8
				toucher.momy = 7*$/8
			elseif player.dashmode >= DASHMODE_THRESHOLD and (player.charflags & (SF_DASHMODE|SF_MACHINE)) == (SF_DASHMODE|SF_MACHINE)
			and player.panim == PA_DASH then
				P_DoPlayerPain(player, special, special)
			end
		end
	end
end

for _, enemyType in ipairs(RSR.ENEMY_LIST) do
	addHook("ShouldDamage", RSR.EnemyShouldDamage, enemyType)
-- 	addHook("MobjMoveCollide", RSR.EnemyMobjMoveCollide, enemyType)
	addHook("TouchSpecial", RSR.EnemyTouchSpecial, enemyType)
end
