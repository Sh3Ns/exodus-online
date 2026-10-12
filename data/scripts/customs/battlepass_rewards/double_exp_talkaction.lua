local expCheck = TalkAction("!exp")


function expCheck.onSay(player, words)
 
    local exhaust = 6000
    local stor = player:getStorageValue(6000)
    if player:getStorageValue(exhaust) - os.time() > 0 then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Your extra exp will end on : "..os.date("%d %B %Y %X", stor).."")
        return false
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You didn't have any current Double EXP enhancement.")
    end
    return false
end

expCheck:separator(" ")
expCheck:register()