-- Ringslinger Revolution - Monitor Fuse Think
-- Special thanks to Evertone for coming up with the randomization values

local RSR = RingslingerRev

RSR.MONITOR_TYPES = {
	MT_RING_BOX,
	MT_PITY_BOX,
	MT_FORCE_BOX,
	MT_WHIRLWIND_BOX,
	MT_ELEMENTAL_BOX,
	MT_RECYCLER_BOX,
	MT_MIXUP_BOX,
	MT_SNEAKERS_BOX,
	MT_1UP_BOX,
	MT_INVULN_BOX,
	MT_ARMAGEDDON_BOX,
	MT_ATTRACT_BOX
}

-- Basically a Lua port of P_MonitorFuseThink using special values for RSR
RSR.MonitorFuseThink = function(mo)
	if not RSR.GamemodeActive() then return end
	if not Valid(mo) then return end
	
	local newmobj
	
	if not G_CoopGametype() and mo.info.speed ~= 0
	and (mo.flags2 & (MF2_AMBUSH|MF2_STRONGBOX)) then
		local spawnchance = {}
		local numchoices = 0
		local i = 0
		
		local function SETMONITORCHANCES(boxtype, strongboxamt, weakboxamt)
			local boxamt = weakboxamt
			if (mo.flags2 & MF2_STRONGBOX) then boxamt = strongboxamt end
			
			for i = boxamt, 1, -1
				spawnchance[numchoices] = boxtype
				numchoices = $+1
			end
		end
		
		--				  Type				  SRM WRM
		SETMONITORCHANCES(MT_RING_BOX,			0,	4) -- Super Ring
		SETMONITORCHANCES(MT_PITY_BOX,			0,	4) -- Pity Shield
		SETMONITORCHANCES(MT_FORCE_BOX,			0,	6) -- Force Shield
		SETMONITORCHANCES(MT_WHIRLWIND_BOX,		0,	6) -- Whirlwind Shield
		SETMONITORCHANCES(MT_ELEMENTAL_BOX,		0,	6) -- Elemental Shield
		SETMONITORCHANCES(MT_RECYCLER_BOX,		0,	1) -- Recycler
		SETMONITORCHANCES(MT_MIXUP_BOX,			0,	2) -- Teleporters
		SETMONITORCHANCES(MT_SNEAKERS_BOX,		0,	3) -- Super Sneakers
		SETMONITORCHANCES(MT_1UP_BOX,			4,	0) -- 1-Up
		SETMONITORCHANCES(MT_INVULN_BOX,		2,	0) -- Invincibility
		SETMONITORCHANCES(MT_ARMAGEDDON_BOX,	5,	0) -- Armageddon Shield
		SETMONITORCHANCES(MT_ATTRACT_BOX,		5,	0) -- Attraction Shield
		-- ==========================================
		-- 				  Total				   16  32
		
		i = P_RandomKey(numchoices)
		newmobj = P_SpawnMobjFromMobj(mo, 0, 0, 0, spawnchance[i])
	else
		return -- Use the regular P_MonitorFuseThink instead
	end
	
	if Valid(newmobj) then newmobj.flags2 = mo.flags2 end
	P_RemoveMobj(mo)
	
	return true
end

for _, motype in ipairs(RSR.MONITOR_TYPES) do
	addHook("MobjFuse", RSR.MonitorFuseThink, motype)
end
