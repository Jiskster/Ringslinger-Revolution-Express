-- Ringslinger Revolution - PSprites HUD

local RSR = RingslingerRev

--[[
RSR.BLENDMODE_TO_VFLAG = {
	[AST_ADD] = V_ADD,
	[AST_SUBTRACT] = V_SUBTRACT,
	[AST_REVERSESUBTRACT] = V_REVERSESUBTRACT,
	[AST_MODULATE] = V_MODULATE
}
]]

RSR.DrawHUDSprites = function(v, player, camera, xyScale)
	if not (v and Valid(player) and Valid(player.mo) and player.rsrinfo and camera) then return end
	if not (not camera.chase and player.rsrinfo.psprites) then return end
	xyScale = $ or FRACUNIT
	
	local flags = V_SNAPTOBOTTOM|V_PERPLAYER
	
	for _, pspr in ipairs(player.rsrinfo.psprites) do
		if not pspr then continue end
		
		if not pspr.state then continue end
		local x, y, sprite = 0, 0, nil
		local yOffset = 32*FRACUNIT
		
		x = pspr.x or 0
		y = pspr.y or 0
		
		if player.rsrinfo.bob then
			x = $ + player.rsrinfo.bob.x
			y = $ + player.rsrinfo.bob.y
		end
		
		if pspr.sprite and pspr.frame then
			sprite = pspr.sprite..pspr.frame
		end
		
		-- TODO: Add more features to frameargs in the future???
		local framebright = false
		if pspr.frameargs then framebright = true end
		
		if not sprite then continue end
		
		local coords = RSR.GetHUDSpriteCoords(v, x, y + yOffset, xyScale, yOffset)
		if coords == nil then coords = {x = 0, y = 0} end
		local patch = v.cachePatch(sprite)
		
		local skin = TC_DEFAULT
		local color = SKINCOLOR_NONE
		local transmap = nil
		
		if G_GametypeHasTeams() then
			if player.ctfteam == 2 then
				transmap = "RSRTeamBlue"
			-- The red ring is already red, so don't bother recoloring it
			elseif player.ctfteam == 1 and (pspr.sprite and pspr.sprite ~= "RSRBASC") then
				transmap = "RSRTeamRed"
			end
		end
		
		-- TODO: Revive my old MR adding translation map support to v.getSectorColormap so I can use it here
		local colormap = v.getColormap(skin, color, transmap)
		
		-- drawCropped automatically crops the bottom of the patch for splitscreen, so use it instead of drawStretched
		v.drawCropped(
			coords.x,
			coords.y,
			xyScale,
			xyScale,
			patch,
			V_SNAPTOBOTTOM|V_PERPLAYER,
			colormap,
			0,
			0,
			patch.width*FRACUNIT,
			patch.height*FRACUNIT
		)
	end
end
