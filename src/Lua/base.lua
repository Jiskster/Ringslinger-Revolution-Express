-- Ringslinger Revolution - Base Scripts

local folder = "base"

local dofolder = function(file)
	dofile(folder.."/"..file)
end

dofolder("globals.lua")
dofolder("utilities.lua")
dofolder("mobj.lua")
dofolder("mobjinfo.lua")
