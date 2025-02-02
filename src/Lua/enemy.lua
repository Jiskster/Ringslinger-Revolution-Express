-- Ringslinger Revolution - Base Scripts

local folder = "enemy"

local dofolder = function(file)
	dofile(folder.."/"..file)
end

dofolder("thinkers.lua")
dofolder("damage.lua")
dofolder("cybrak2016.lua")
