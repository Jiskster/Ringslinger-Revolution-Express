-- Ringslinger Revolution - Mobj Functions

local RSR = RingslingerRev

RSR.Explode = function(mo, bombDist, thrustDist, bombDamage, fullDist)
	if not Valid(mo) then return end
	if bombDist == nil then bombDist = 128*FRACUNIT end
	if thrustDist == nil then thrustDist = 6*bombDist/5 end
	if not bombDamage then bombDamage = 90 end
	if fullDist == nil then fullDist = 3*bombDist/8 end

	bombDist = FixedMul($, mo.scale)
	thrustDist = FixedMul($, mo.scale)
	fullDist = FixedMul($, mo.scale)

	mo.rsrProjectile = nil
	mo.rsrRealDamage = true

	searchBlockmap("objects", function(bomb, enemy)
		if not (Valid(bomb) and Valid(enemy)) then return end
		if enemy.health <= 0 then return end
		if not (enemy.flags & MF_SHOOTABLE) then return end

		local distXY = FixedHypot(enemy.x - bomb.x, enemy.y - bomb.y)
		local distZ = (enemy.z + enemy.height/2) - (bomb.z + bomb.height/2)
		local dist = max(0, FixedHypot(distXY, distZ)) -- TODO: Consider subtracting enemy.radius?
-- 		if dist < 0 then dist = 0 end
-- 		if dist >= bombDist then return end
		
		-- Make an exception for MT_BLASTEXECUTOR so the breakable wall in Jade Valley works
		if enemy.type ~= MT_BLASTEXECUTOR and not P_CheckSight(bomb, enemy) then return end
		local source = bomb.target
		local damagetype = 0
		if enemy == bomb.target then source = nil end
		-- TODO: Uncomment this when I figure out how to undo score from hurting yourself
		-- (This is not an exaggeration, you can literally give yourself points by hurting yourself in Match with DMG_CANHURTSELF)
-- 		if enemy == bomb.target then damagetype = $|DMG_CANHURTSELF end

		-- Don't destroy monitors with splash damage
		if not (enemy.info.flags & MF_MONITOR)
			if dist <= bombDist then
				local damage = bombDamage * min(FixedDiv(bombDist - dist, max(bombDist - fullDist, mo.scale)), FRACUNIT) / FRACUNIT
				if damage > 0 then
					P_DamageMobj(enemy, bomb, source, damage, damagetype)
				end
			end
		end

		if not Valid(enemy) return end

		if dist <= thrustDist then
			local angle = R_PointToAngle2(bomb.x, bomb.y, enemy.x, enemy.y)
			local pitch = R_PointToAngle2(0, bomb.z + bomb.height/2, distXY, enemy.z + enemy.height/2)

			local enemyAngle = enemy.angle
			local enemyPitch = enemy.pitch
			if Valid(enemy.player) then
				enemyPitch = enemy.player.cmd.aiming<<16
			end
			local aheadX = enemy.x + FixedMul(cos(enemyAngle), cos(enemyPitch))
			local aheadY = enemy.y + FixedMul(sin(enemyAngle), cos(enemyPitch))
			local aheadZ = enemy.z + enemy.height/2 + sin(enemyPitch)

			-- Assume the player fired point blank at a wall
			if dist <= 2*bomb.radius then
				angle = R_PointToAngle2(aheadX, aheadY, enemy.x, enemy.y)
				pitch = R_PointToAngle2(0, aheadZ, FixedHypot(aheadX - enemy.x, aheadY - enemy.y), enemy.z + enemy.height/2)
			end

			-- enemy.flags wasn't working with gold monitors, so we check enemy.info.flags instead
			if not (enemy.info.flags & (MF_BOSS|MF_MONITOR)) then -- Don't thrust bosses or monitors
				local thrust = 20 * FixedDiv(thrustDist - dist, thrustDist)

				-- Don't fling the enemy horizontally, if the player fired right under them
				if FixedHypot(aheadX - enemy.x, aheadY - enemy.y) > 0 then
					enemy.momx = $ + FixedMul(thrust, FixedMul(cos(angle), cos(pitch)))
					enemy.momy = $ + FixedMul(thrust, FixedMul(sin(angle), cos(pitch)))

					-- Fixes a bug where the player doesn't get thrusted while standing still
					if Valid(enemy.player) then
						enemy.player.rmomx = enemy.momx + enemy.player.cmomx
						enemy.player.rmomy = enemy.momy + enemy.player.cmomy
					end
				end

				enemy.momz = $ + FixedMul(thrust, sin(pitch))
			end
		end
	end, mo, mo.x - bombDist, mo.x + bombDist, mo.y - bombDist, mo.y + bombDist)

	mo.rsrRealDamage = nil
end

RSR.GetArmageddonDamage = function(target, inflictor)
	if not (Valid(target) and Valid(inflictor)) then return end

	local dist = FixedHypot(FixedHypot(target.x - inflictor.x, target.y - inflictor.y), target.z - inflictor.z)
	local bombDist = 1536*inflictor.scale -- 1536*FRACUNIT is what the Armageddon Shield uses for its blast radius
	local fullDist = bombDist/4 -- TODO: Nerf this?? (Seems fine -Evertone)
	if dist <= bombDist then
		local bombDamage = 50 * min(FixedDiv(bombDist - dist, max(bombDist - fullDist, inflictor.scale)), FRACUNIT) / FRACUNIT
		if bombDamage > 0 then
			return bombDamage
		end
	end

	return 0
end

-- Based off of A_RingExplode
RSR.A_RingExplode = function(mo, var1, var2)
	if not Valid(mo) then return end

	local sparkleState = S_NULL
	if Valid(mo.target) and Valid(mo.target.player) and mo.target.player.ctfteam then
		local ctfTeam = mo.target.player.ctfteam
		if ctfTeam == 1 then
			sparkleState = S_NIGHTSPARKLESUPER1 -- Red
		end
	elseif mo.type == MT_RSR_PROJECTILE_GRENADE then
		sparkleState = S_RSR_NIGHTSPARKLE_GRENADE -- Moss
	elseif mo.type == MT_RSR_PROJECTILE_BOMB then
		sparkleState = S_RSR_NIGHTSPARKLE_BOMB -- Jet
	end

	for d = 0, 15 do
		P_SpawnParaloop(
			mo.x,
			mo.y,
			mo.z + mo.height/2,
			FixedMul(mo.info.painchance, mo.scale),
			16,
			MT_NIGHTSPARKLE,
			d * ANGLE_22h,
			sparkleState,
			true
		)
	end
	S_StartSound(mo, sfx_prloop)

	RSR.Explode(mo, mo.info.painchance, nil, mo.info.reactiontime)
end

states[S_RSR_RINGEXPLODE] =	{SPR_NULL,	0,	0,	RSR.A_RingExplode,	0,	0,	S_XPLD1}

states[S_RSR_NIGHTSPARKLE_GRENADE] =	{SPR_NULL,	0,	0,	A_Dye,	0,	SKINCOLOR_MOSS,	S_NIGHTSPARKLE1}
states[S_RSR_NIGHTSPARKLE_BOMB] =		{SPR_NULL,	0,	0,	A_Dye,	0,	SKINCOLOR_JET,	S_NIGHTSPARKLE1}
