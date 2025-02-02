-- Ringslinger Revolution - Starpost Data System

local RSR = RingslingerRev

RSR.PlayerStarpostDataInit = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	
	if not player.rsrinfo.starpostData or (not G_CoopGametype() and player.starpostnum == 0) then
		player.rsrinfo.starpostData = {}
	end
	
	player.rsrinfo.starpostNum = player.starpostnum
end

RSR.PlayerStarpostDataSpawn = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	local rsrinfo = player.rsrinfo
	
	if not rsrinfo.starpostData then return end
	
	local data = rsrinfo.starpostData
-- 	if data.health ~= nil then rsrinfo.health = data.health end
-- 	if data.armor ~= nil then rsrinfo.armor = data.armor end
	if data.ammo ~= nil then rsrinfo.ammo = RSR.DeepCopy(data.ammo) end
	if (multiplayer or netgame) and G_CoopGametype() then
		for ammo, amount in ipairs(rsrinfo.ammo) do
			if not (RSR.AMMO_INFO[ammo] and RSR.AMMO_INFO[ammo].amount) then continue end
			if amount <= RSR.AMMO_INFO[ammo].amount then continue end -- Make sure the player already had ammo in their inventory
			
			rsrinfo.ammo[ammo] = RSR.AMMO_INFO[ammo].amount
		end
	end
	if data.weapons ~= nil then rsrinfo.weapons = RSR.DeepCopy(data.weapons) end
	if data.readyWeapon ~= nil then
		rsrinfo.readyWeapon = data.readyWeapon
		RSR.SetPSpriteState(player, RSR.PS_WEAPON, RSR.WEAPON_INFO[rsrinfo.readyWeapon].states.ready)
	end
	if data.shields ~= nil then
-- 		player.powers[pw_shield] = data.shields
		P_SwitchShield(player, data.shields)
	end
end

RSR.PlayerStarpostDataTick = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	local rsrinfo = player.rsrinfo
	
	if player.starpostnum ~= rsrinfo.starpostNum then
		rsrinfo.starpostNum = player.starpostnum
		
		local data = rsrinfo.starpostData
		
		data.ammo = RSR.DeepCopy(rsrinfo.ammo)
		data.weapons = RSR.DeepCopy(rsrinfo.weapons)
		data.readyWeapon = rsrinfo.readyWeapon
		data.shields = player.powers[pw_shield] or nil
	end
end
