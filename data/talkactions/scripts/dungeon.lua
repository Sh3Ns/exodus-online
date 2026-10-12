

function onSay(player, words, param)
    local playerPoints = player:getStorageValue(PlayerStorageKeys.challengePoints)
    local text = '               Dungeon Information               \n\n - Dungeon Challenge Points: '..playerPoints..'.'
    return false,  player:popupFYI(text)
end
