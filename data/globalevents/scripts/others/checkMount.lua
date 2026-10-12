local mountIds = {22, 25, 26}

function onThink(interval)
	local players = Game.getPlayers()
	if #players == 0 then
		return true
	end

	local player, outfit, rentedHorseTimer
	for i = 1, #players do
		player = players[i]
		rentedHorseTimer = player:getStorageValue(Storage.RentedHorseTimer)
		if rentedHorseTimer >= 1 and rentedHorseTimer < os.time() then
			outfit = player:getOutfit()
			if isInArray(mountIds, outfit.lookMount) then
				outfit.lookMount = nil
				player:setOutfit(outfit)
			end

			for m = 1, #mountIds do
				player:removeMount(mountIds[m])
			end

			player:setStorageValue(Storage.RentedHorseTimer, -1)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Your contract with your horse expired and it returned back to the horse station.')
		end
	end
	return true
end
