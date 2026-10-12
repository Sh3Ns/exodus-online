function onLogout(player)
	-- Never persist a temporary boat appearance as the player's regular outfit, boat system restore the previous outfit of player if logout
	if type(BoatNavigation) == "table" and type(BoatNavigation.restore) == "function" then
		BoatNavigation.restore(player, false)
	end

	local playerId = player:getGuid() -- get playerid
	saveDirtyPetProgress(player)
	if AntiMcState and AntiMcState.players then
		local trackedIp = AntiMcState.players[playerId]
		if trackedIp then
			local currentCount = AntiMcState.ipCounts[trackedIp] or 0
			if currentCount > 1 then
				AntiMcState.ipCounts[trackedIp] = currentCount - 1
			else
				AntiMcState.ipCounts[trackedIp] = nil
			end
			AntiMcState.players[playerId] = nil
		end
	end

    local outfit = player:getOutfit()  -- get player outfit
	if nextUseStaminaTime[playerId] then
		nextUseStaminaTime[playerId] = nil
	end
	local wingsClientId = outfit.lookWings or 0
    local shaderClientId = outfit.lookShader or 0 -- check lookShader
    local auraClientId = outfit.lookAura or 0    -- check lookAura

    local query = "UPDATE players SET wings_id = " .. wingsClientId .. ", shader_id = " .. shaderClientId .. ", aura_id = " .. auraClientId .. " WHERE id = " .. playerId
    db.query(query)

    local outfit = player:getOutfit()
    local storedLookType = outfit.lookType
    local storedLookAddons = outfit.lookAddons
    local storedLookWings = outfit.lookWings
    local storedLookAura = outfit.lookAura
    local storedLookShader = outfit.lookShader
    
    player:setStorageValue(709919, storedLookType)
    player:setStorageValue(709920, storedLookAddons)
    player:setStorageValue(709921, storedLookWings)
    player:setStorageValue(709922, storedLookAura)
    player:setStorageValue(709923, storedLookShader)

    return true
end
