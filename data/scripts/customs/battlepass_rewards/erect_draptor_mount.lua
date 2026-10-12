local erectDraptor = Action()

function erectDraptor.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	
    if player:getStorageValue(Battlepass.erectDraptor) == -1 or player:getStorageValue(Battlepass.erectDraptor) == 0 then
        player:setStorageValue(Battlepass.erectDraptor)
        player:addMount(123)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have obtained Erect Draptor Mount.")
        item:remove(1)
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You already have Erect Draptor Mount.")
    end

	return true
end

erectDraptor:id(28093)
erectDraptor:register()