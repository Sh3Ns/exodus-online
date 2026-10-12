local retroBoxOutfit = Action()

local outfits = {
    [1] = {name = "Retro Warrior", male = 1240, female = 1241, storage = Battlepass.retroBoxOutfitWarrior},
    [2] = {name = "Retro Summoner", male = 1242, female = 1243, storage = Battlepass.retroBoxOutfitSummoner},
    [3] = {name = "Retro Nobleman", male = 1244, female = 1245, storage = Battlepass.retroBoxOutfitNobleman},
    [4] = {name = "Retro Mage", male = 1246, female = 1247, storage = Battlepass.retroBoxOutfitMage},
    [5] = {name = "Retro Knight", male = 1248, female = 1249, storage = Battlepass.retroBoxOutfitKnight},
    [6] = {name = "Retro Hunter", male = 1250, female = 1251, storage = Battlepass.retroBoxOutfitHunter},
    [7] = {name = "Retro Citizen", male = 1252, female = 1253, storage = Battlepass.retroBoxOutfitCitizen},
}

function retroBoxOutfit.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local availableOutfits = {}
    for i, outfit in ipairs(outfits) do
        if player:getStorageValue(outfit.storage) ~= 1 then
            table.insert(availableOutfits, outfit)
        end
    end
    
    if #availableOutfits > 0 then
        local randomIndex = math.random(1, #availableOutfits)
        local selectedOutfit = availableOutfits[randomIndex]
        player:setStorageValue(selectedOutfit.storage, 1)
        player:addOutfit(selectedOutfit.male)
        player:addOutfit(selectedOutfit.female)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have obtained the " .. selectedOutfit.name .. " outfit.")
        item:remove(1)
        playSound(player, "success.ogg")
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You already have all available outfits.")
        playSound(player, "fail.ogg")
    end

    return true
end

retroBoxOutfit:id(28094)
retroBoxOutfit:register()
