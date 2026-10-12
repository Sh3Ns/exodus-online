local firePantherMount = Action()

function firePantherMount.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	
    if player:getStorageValue(Battlepass.firePanther) == -1 or player:getStorageValue(Battlepass.firePanther) == 0 then
        player:setStorageValue(Battlepass.firePanther)
        player:addMount(122)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have obtained Fire Panther Mount.")
        item:remove(1)
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You already have Fire Panther Mount.")
    end

	return true
end

firePantherMount:id(28097)
firePantherMount:register()