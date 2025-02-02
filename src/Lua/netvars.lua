-- Ringslinger Revolution - NetVars

local RSR = RingslingerRev

addHook("NetVars", function(network)
	RSR.ENEMY_THINKERS = network($)
	RSR.WEAPON_STATES = network($) -- TODO: Figure out why these are causing netsync issues when not in NetVars
	RSR.CURRENT_BOSS = network($)
end)
