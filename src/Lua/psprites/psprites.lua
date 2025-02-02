-- Ringslinger Revolution - Player Sprites

local RSR = RingslingerRev

if not RSR.WEAPON_STATES then
	RSR.WEAPON_STATES = {}
end
local wstates = RSR.WEAPON_STATES

if not RSR.WEAPON_STATE_ACTIONS then
	RSR.WEAPON_STATE_ACTIONS = {}
end
local wsactions = RSR.WEAPON_STATE_ACTIONS

RSR.PSpriteNew = do
	return {
		state = wstates["S_NONE"],
		sprite = nil,
		frame = nil,
		animframe = 0,
		x = 0,
		y = 0,
		tics = -1,
		processPending = true
	}
end

RSR.NewPSprite = function(player, id)
	if not (Valid(player) and player.rsrinfo) then return end
-- 	if not player.rsrinfo.psprites then
-- 		RSR.PlayerPspritesInit(player)
-- 	end
	
	player.rsrinfo.psprites[id] = RSR.PSpriteNew()
end

-- TODO: MAKE SURE TO RUN THIS AFTER RSR.PlayerPSpriteLayersInit!!!
RSR.PlayerPSpritesInit = function(player)
	if not (Valid(player) and player.rsrinfo) then return end
	
	player.rsrinfo.psprites = {}
	
	for i = 1, RSR.PS_MAX do
		RSR.NewPSprite(player, i)
	end
end

RSR.GetPSprite = function(player, id)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.psprites) then return end
	return player.rsrinfo.psprites[id]
end

RSR.SetPSpriteState = function(player, id, newState, pending)
	local psprite = RSR.GetPSprite(player, id)
	if psprite == nil then return end
	if pending == nil then pending = false end
	
	local stateName = newState
	if type(newState) == "string" then
		if not wstates[newState] then
			CONS_Printf(player, "ERROR: State "..tostring(newState).." not found!")
			return
		end
		
		newState = wstates[$]
	end
	
	if newState == nil then
		CONS_Printf(player, "ERROR: State "..tostring(newState).." not found!")
		return
	end
	
	psprite.processPending = pending
	
	-- This could result in an endless loop, so change this if necessary
	repeat
		if newState == nil then
			psprite.tics = -1
			break
		end
		psprite.state = newState
		
		-- Tics
		if newState.tics ~= nil then
			psprite.tics = newState.tics
		elseif newState[3] ~= nil then
			psprite.tics = newState[3]
		else
			psprite.tics = -1
		end
		
		local sprite
		
		-- Sprite
		if newState.sprite ~= nil then
			sprite = newState.sprite
		elseif newState[1] ~= nil then
			sprite = newState[1]
		else
			sprite = nil
		end
		
		-- Don't change the sprite if the state specifies not to
		if sprite ~= "####" then
			psprite.sprite = sprite
		end
		
		-- Frame
		local weaponframe = "A"
		
		psprite.frameargs = nil
		if newState.frame then
			if type(newState.frame) == "string" then
				weaponframe = newState.frame
			elseif type(newState.frame) == "table" then
				weaponframe = newState.frame[1]
				psprite.frameargs = newState.frame[2]
			end
		elseif newState[2] then
			if type(newState[2]) == "string"
				weaponframe = newState[2]
			elseif type(newState[2]) == "table"
				weaponframe = newState[2][1]
				psprite.frameargs = newState[2][2]
			end
		end
		
		-- Animation Frame
		if weaponframe:len() > 1 then
			psprite.animframe = $+1
			
			if psprite.animframe > weaponframe:len() - 1 then
				weaponframe = $:sub(psprite.animframe, psprite.animframe)
				psprite.animframe = 0
			else
				weaponframe = $:sub(psprite.animframe, psprite.animframe)
			end
		else
			psprite.animframe = 0
		end
		
		-- Don't change the animation frame if the state specifies not to
		if weaponframe ~= "#" then
			psprite.frame = weaponframe
		end
		
		-- Action
		local args = {}
		
		if newState.args then
			args = newState.args
		elseif newState[5] then
			args = newState[5]
		end
		
		if newState.action and wsactions[newState.action] then
			wsactions[newState.action](player, args)
		elseif newState[4] and wsactions[newState[4]] then
			wsactions[newState[4]](player, args)
		end
		
		if psprite.state == wstates["S_NONE"] then break end
		
		-- Next State
		if newState.nextstate then
			newState = wstates[newState.nextstate]
		elseif newState[6] then
			newState = wstates[newState[6]]
		else
			newState = wstates["S_NONE"]
		end
	until psprite.tics ~= 0
end


RSR.PlayerPSpritesReset = function(player)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.psprites) then return end
	
	for _, pspr in ipairs(player.rsrinfo.psprites) do
		pspr = RSR.PSpriteNew()
	end
	
	RSR.SetPSpriteState(player, RSR.PS_WEAPON, "S_NONE_READY")
end

RSR.PSpriteTick = function(player, id)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.psprites) then return end
	
	local psprite = RSR.GetPSprite(player, id)
	
	if psprite == nil then
		CONS_Printf("WARNING: PSprite with ID "..tostring(id).." not found!")
		return
	end
	
	if not psprite.processPending then return end
	if psprite.tics == -1 then return end
	
	psprite.tics = $-1
	if not psprite.tics then
		local nextState = "S_NONE"
		
		if psprite.animframe then
			nextState = psprite.state
		else
			if psprite.state.nextstate then
				nextState = wstates[psprite.state.nextstate]
			elseif psprite.state[6] then
				nextState = wstates[psprite.state[6]]
			end
		end
		
		RSR.SetPSpriteState(player, id, nextState)
	end
end

RSR.TickPSpritesBegin = function(player)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.psprites) then return end
	
	for _, pspr in ipairs(player.rsrinfo.psprites) do
		if not pspr then continue end
		pspr.processPending = true
	end
end

RSR.TickPSprites = function(player)
	if not (Valid(player) and player.rsrinfo and player.rsrinfo.psprites) then return end
	
	for id, pspr in ipairs(player.rsrinfo.psprites) do
		RSR.PSpriteTick(player, id)
	end
end
