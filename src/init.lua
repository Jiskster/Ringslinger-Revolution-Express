-- Ringslinger Revolution - init.lua
-- This script is required for loading the mod's Lua scripts in the right order
-- DO NOT REMOVE THIS FILE

local folder 
local function dofolder(file)
	dofile(folder.."/"..file)
end

dofile("freeslots.lua")
dofile("base.lua")
dofile("psprites.lua")
dofile("items.lua")
dofile("enemy.lua")
dofile("weapon.lua")
dofile("player.lua")
dofile("hud.lua")
dofile("netvars.lua")
