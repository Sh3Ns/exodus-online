
local doubleExp = Action()


function doubleExp.onUse(player, item)
    local playerStorage = player:getStorageValue(6000)
    if player:getStorageValue(6000) < os.time() then
        player:setStorageValue(6000, os.time() + 3600)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have received 1 hour of double Exp, type: !exp to show the remaining time.")
        item:remove(1)
        playSoundPlayer(player, "stamina_potion.ogg")
    elseif player:getStorageValue(6000) > os.time() then
        player:setStorageValue(6000, playerStorage + 3600)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You added +1 hour of double Exp, type: !exp to show the remaining time.")
        item:remove(1)
        playSoundPlayer(player, "stamina_potion.ogg")
    end
end

doubleExp:id(28095)
doubleExp:register()

