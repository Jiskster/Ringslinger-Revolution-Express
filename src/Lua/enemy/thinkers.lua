-- Ringslinger Rev - Enemy Thinker Table

local RSR = RingslingerRev

RSR.ENEMY_THINKERS = {}

-- Reset the thinkers table every map change
addHook("MapChange", function(mapnum)
	RSR.ENEMY_THINKERS = {}
end)

addHook("ThinkFrame", do
	if not RSR.GamemodeActive() then return end -- This hook should only run in RSR
	
	local key = 1
	
	while key <= #RSR.ENEMY_THINKERS do
		local enemy = RSR.ENEMY_THINKERS[key]
		if not (Valid(enemy) and enemy.health > 0) then
			enemy.flags2 = $ & ~MF2_DONTDRAW
			table.remove(RSR.ENEMY_THINKERS, key)
			continue
		end
		
		if enemy.rsrEnemyBlink then
			enemy.flags2 = $ ^^ MF2_DONTDRAW
			enemy.rsrEnemyBlink = $-1
			
			if enemy.rsrEnemyBlink <= 0 then
				enemy.flags2 = $ & ~MF2_DONTDRAW
				enemy.rsrEnemyBlink = nil
				enemy.rsrIsThinker = nil
				table.remove(RSR.ENEMY_THINKERS, key)
				continue
			end
		else
			enemy.flags2 = $ & ~MF2_DONTDRAW
			enemy.rsrEnemyBlink = nil
			enemy.rsrIsThinker = nil
			table.remove(RSR.ENEMY_THINKERS, key)
		end
		
		key = $+1
	end
end)
