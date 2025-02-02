-- RingSlinger Revolution - Globals

if not RingslingerRev then
	rawset(_G, "RingslingerRev", {})
end

local RSR = RingslingerRev

RSR.MAX_HEALTH = 100
RSR.MAX_ARMOR = 100

RSR.MAX_HEALTH_BONUS = 200
RSR.MAX_ARMOR_BONUS = 200

RSR.GamemodeActive = do
	if not mapheaderinfo[gamemap].ringslingerrev then return false end
	return true
end

RSR.AddEnum = function(prefix, name, startAtZero)
	if not (prefix and name) then
		print("ERROR: Unable to add enum with missing prefix and/or name!")
		return
	end
	
	-- Make sure the max value exists before adding an enum
	if not RSR[prefix.."_MAX"] then
		RSR[prefix.."_MAX"] = 0
	end
	
	RSR[prefix.."_MAX"] = $+1
	
	if startAtZero then
		RSR[prefix.."_"..name] = RSR[prefix.."_MAX"] - 1
		return
	end
	
	RSR[prefix.."_"..name] = RSR[prefix.."_MAX"]
end

-- Store weapon states/animations in a table
if not RSR.WEAPON_STATES then
	RSR.WEAPON_STATES = {}
end

-- WeaponNull (There should be at least one state already in the weapon table)
RSR.WEAPON_STATES["S_NONE"] =			{nil,	nil,	-1,	nil,				{},	"S_NONE"}
RSR.WEAPON_STATES["S_NONE_READY"] =		{nil,	nil,	1,	"A_WeaponReady",	{},	"S_NONE_READY"}
RSR.WEAPON_STATES["S_NONE_HOLSTER"] =	{nil,	nil,	1,	"A_WeaponHolster",	{},	"S_NONE_HOLSTER"}

-- Store HUD actions in a table of strings to keep them netsafe
if not RSR.WEAPON_STATE_ACTIONS then
	RSR.WEAPON_STATE_ACTIONS = {}
end
