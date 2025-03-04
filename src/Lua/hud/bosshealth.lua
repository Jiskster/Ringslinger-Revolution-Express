-- Ringslinger Revolution - Boss Health HUD
-- Special Thanks to Othius for suggesting this, and Evertone for feedback!

local RSR = RingslingerRev

RSR.CURRENT_BOSS = nil
RSR.DISPLAY_BOSS_HEALTH = false
RSR.DISPLAY_BOSS_TIMER_MAX = 2*TICRATE/3
RSR.DISPLAY_BOSS_TIMER = 0

RSR.HUDBossHealth = function(v, player)
	if not (v and Valid(player)) then return end
	if not Valid(RSR.CURRENT_BOSS) then return end
	
	local bossMo = RSR.CURRENT_BOSS
-- 	if bossMo.health <= 0 then return end
	if not (RSR.DISPLAY_BOSS_HEALTH or RSR.DISPLAY_BOSS_TIMER) then return end
	if not (RSR.MOBJ_INFO[bossMo.type] and RSR.MOBJ_INFO[bossMo.type].health) then return end
	local maxHealth = RSR.MOBJ_INFO[bossMo.type].health
	
	local barWidth = 240
	local barHeight = 4
	local barX = (barWidth - 160) / 2
	local barY = 7
	if RSR.DISPLAY_BOSS_TIMER > 0 then
		local easeScale = ease.inback(RSR.DISPLAY_BOSS_TIMER*FRACUNIT/RSR.DISPLAY_BOSS_TIMER_MAX)
		if RSR.DISPLAY_BOSS_HEALTH then
			barY = $ - (($ + barHeight + 8) * easeScale)/FRACUNIT
		else
			barY = -(barHeight + 8) + (2*$ * easeScale)/FRACUNIT
		end
	end
	local vFlags = V_SNAPTOTOP|V_PERPLAYER
	
	v.drawFill(barX - 2, barY - 2, barWidth + 4, barHeight + 4, 0|vFlags)
	v.drawFill(barX - 1, barY - 1, barWidth + 2, barHeight + 2, 31|vFlags)
	
	local healthScale = FixedDiv(bossMo.health, bossMo.info.spawnhealth)
	if bossMo.rsrHealth then
		healthScale = FixedDiv(bossMo.rsrHealth, maxHealth)
	end
	
	local curHealth = bossMo.health
	if bossMo.rsrHealth ~= nil then
		curHealth = bossMo.rsrHealth
	else
		curHealth = maxHealth
	end
	
	v.drawFill(barX, barY, barWidth*healthScale/FRACUNIT, barHeight, 35|vFlags)
	
	-- RSR doesn't really need a number for the boss's health
	-- drawNum always right-aligns the text, so adjust it to make it centered
-- 	local healthNumXOffset = 8*tostring(curHealth):len()/2
	
-- 	v.drawNum(160 + healthNumXOffset, barY + (barHeight/2) - 6, curHealth, vFlags)
end

-- TODO: Merge these into the other MapChange and ThinkFrame hooks eventually

addHook("MapChange", function(mapnum)
	RSR.CURRENT_BOSS = nil
	RSR.DISPLAY_BOSS_HEALTH = false
	RSR.DISPLAY_BOSS_TIMER = 0
end)

RSR.HUDBossHealthThinkFrame = do
	if not RSR.GamemodeActive() then return end -- This hook should only run in RSR
	if not Valid(RSR.CURRENT_BOSS) then return end
	local bossMo = RSR.CURRENT_BOSS
-- 	if not (RSR.MOBJ_INFO[bossMo.type] and RSR.MOBJ_INFO[bossMo.type].health) then return end
	
	if RSR.DISPLAY_BOSS_TIMER > 0 then
		RSR.DISPLAY_BOSS_TIMER = $-1
	end
	
	if (bossMo.health and not RSR.DISPLAY_BOSS_HEALTH)
	or (bossMo.health <= 0 and RSR.DISPLAY_BOSS_HEALTH) then
		RSR.DISPLAY_BOSS_HEALTH = not $ -- TODO: Make sure this doesn't cause issues
		RSR.DISPLAY_BOSS_TIMER = RSR.DISPLAY_BOSS_TIMER_MAX
	end
end
