-- Ringslinger Revolution - Item Functions

local RSR = RingslingerRev

RSR.ItemMapThingSpawn = function(mo, mthing)
	if not (Valid(mo) and Valid(mthing)) then return end
	if mthing.args[0] then return end
	
	local flip = (mthing.options & MTF_OBJECTFLIP)
	local offset = 24*FRACUNIT
	
	if flip then
		mo.z = $ - offset
	else
		mo.z = $ + offset
	end
end

RSR.ItemFloatThinker = function(mo)
	if not Valid(mo) then return end
	
	mo.spriteyoffset = P_MobjFlip(mo)*8*sin((128*leveltime)<<19 + (mo.rsrFloatOffset or 0))
end

RSR.ItemMobjSpawn = function(mo)
	if not Valid(mo) then return end
	
	mo.rsrPickup = true
	
	if not (netgame or multiplayer) then
		mo.flags2 = $|MF2_DONTRESPAWN
	end
end

RSR.SetItemFuse = function(mo)
	if not Valid(mo) then return end
	
	if not (mo.flags2 & MF2_DONTRESPAWN) then
		mo.fuse = (CV_FindVar("respawnitemtime").value or 0)*TICRATE + 2
	end
end

RSR.ItemMobjFuse = function(mo)
	if not Valid(mo) then return end
	
	local itemType = mo.type
	-- TODO: Add powerup randomization code from Doomslinger here
	-- (if I ever add powerups to Ringslinger Revolution...)
	
	local newItem = P_SpawnMobjFromMobj(mo, 0, 0, 0, itemType)
	if Valid(newItem) then
		newItem.flags2 = mo.flags2
		newItem.spawnpoint = mo.spawnpoint
		newItem.shadowscale = mo.shadowscale
		newItem.rsrPickup = mo.rsrPickup
	end
	
	P_RemoveMobj(mo)
end
