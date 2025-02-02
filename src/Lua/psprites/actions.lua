-- Ringslinger Revolution - PSprite Base Actions

local RSR = RingslingerRev

RSR.IsPSpritesValid = function(player)
	return (Valid(player) and player.rsrinfo and player.rsrinfo.psprites)
end

RSR.CheckAmmo = function(player, ammoType)
	if not (Valid(player) and player.rsrinfo) then return end
	
	if ammoType == nil then
		if not player.rsrinfo.readyWeapon then return end
		ammoType = RSR.WEAPON_INFO[player.rsrinfo.readyWeapon].ammoType
	end
	
	if player.rsrinfo.ammo[ammoType] > 0 then
		return true
	end
	
	return false
end

RSR.DrawWeapon = function(player, weapon)
	if not (Valid(player) and player.rsrinfo) then return end
	
	local newstate = "S_NONE"
	
	local psprite = RSR.GetPSprite(player, RSR.PS_WEAPON)
	if not psprite then return end
	
	if weapon == nil then weapon = player.rsrinfo.pendingWeapon end
	newstate = RSR.WEAPON_INFO[weapon].states.draw
	
	player.rsrinfo.pendingWeapon = -1
	psprite.y = RSR.LOWER_OFFSET
	
	RSR.SetPSpriteState(player, RSR.PS_WEAPON, newstate)
end

RSR.FireWeapon = function(player)
	if not (RSR.IsPSpritesValid(player) and Valid(player.mo)) then return end
	
	if not RSR.CheckAmmo(player) then return end
	if RSR.WEAPON_INFO[player.rsrinfo.readyWeapon].states.attack == nil then return end
	
	RSR.SetPSpriteState(player, RSR.PS_WEAPON, RSR.WEAPON_INFO[player.rsrinfo.readyWeapon].states.attack)
	player.drawangle = player.mo.angle
end

RSR.CheckPendingWeapon = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	
	if player.rsrinfo.pendingWeapon ~= -1 then
		local psprite = RSR.GetPSprite(player, RSR.PS_WEAPON)
		if psprite then
			psprite.y = RSR.LOWER_OFFSET
		end
		
		player.rsrinfo.readyWeapon = player.rsrinfo.pendingWeapon
		RSR.DrawWeapon(player)
		return true
	end
end

RSR.SetSneakersRecoverState = function(player)
	if not (RSR.IsPSpritesValid(player) and player.powers[pw_sneakers]) then return end
	
	if RSR.WEAPON_INFO[player.rsrinfo.readyWeapon].states.recoverspeed == nil then return end
	
	RSR.SetPSpriteState(player, RSR.PS_WEAPON, RSR.WEAPON_INFO[player.rsrinfo.readyWeapon].states.recoverspeed)
end

local wsactions = RSR.WEAPON_STATE_ACTIONS

wsactions.A_StartSound = function(player, args)
	if not (Valid(player) and Valid(player.mo)) then return end
	
	S_StartSound(player.mo, args[1])
end

wsactions.A_LayerOffset = function(player, args)
	if not RSR.IsPSpritesValid(player) then return end
	
	local psprite = RSR.GetPSprite(player, args[1])
	if not psprite then return end
	
	local x = args[2] or 0
	local y = args[3] or 0
	
	local relative = args[4] or false
	
	if relative then
		psprite.x = $ + x
		psprite.y = $ + y
		return
	end
	
	psprite.x = x
	psprite.y = y
end

wsactions.A_WeaponHolster = function(player, args)
	if not RSR.IsPSpritesValid(player) then return end
	
	local psprite = RSR.GetPSprite(player, RSR.PS_WEAPON)
	if not psprite then return end
	
	psprite.y = $ + RSR.RAISE_SPEED
	if psprite.y < RSR.LOWER_OFFSET then return end
	
	psprite.y = RSR.LOWER_OFFSET
	
	player.rsrinfo.readyWeapon = player.rsrinfo.pendingWeapon
	RSR.DrawWeapon(player)
end

wsactions.A_WeaponDraw = function(player, args)
	if not RSR.IsPSpritesValid(player) then return end
	
	if RSR.CheckPendingWeapon(player) then return end
	
	local psprite = RSR.GetPSprite(player, RSR.PS_WEAPON)
	if not psprite then return end
	
	psprite.y = $ - RSR.RAISE_SPEED
	if psprite.y > RSR.UPPER_OFFSET then return end
	
	psprite.y = RSR.UPPER_OFFSET
	RSR.SetPSpriteState(player, RSR.PS_WEAPON, RSR.WEAPON_INFO[player.rsrinfo.readyWeapon].states.ready)
end

wsactions.A_WeaponReady = function(player, args)
	if not RSR.IsPSpritesValid(player) then return end
	
	if RSR.CheckPendingWeapon(player) then return end
	
	if (player.cmd.buttons & BT_ATTACK) then
		RSR.FireWeapon(player)
		return
	end
end

wsactions.A_CheckAmmo = function(player, args)
	if not RSR.IsPSpritesValid(player) then return end
	
	if RSR.CheckAmmo(player) then return end
	
	player.weaponDelayOrig = 0
	player.weaponDelay = 0
	
	RSR.SetPSpriteState(player, RSR.PS_WEAPON, "S_NONE_READY")
	return true
end

wsactions.A_SetWeaponOffset = function(player, args)
	if not RSR.IsPSpritesValid(player) then return end
	
	local psprite = RSR.GetPSprite(player, RSR.PS_WEAPON)
	if not psprite then return end
	
	local rsrinfo = player.rsrinfo
	
	if rsrinfo.weaponDelayOrig <= 0 then
		psprite.y = 0
		return
	end
-- 	psprite.y = 128*FixedDiv(player.rsrinfo.weaponDelay, player.rsrinfo.weaponDelayOrig)
-- 	psprite.y = 128*ease.inquad(player.rsrinfo.weaponDelay*FRACUNIT, player.rsrinfo.weaponDelayOrig)
	psprite.y = 128 * ease.inquad(rsrinfo.weaponDelay*FRACUNIT/rsrinfo.weaponDelayOrig)
end
