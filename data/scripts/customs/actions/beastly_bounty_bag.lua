local rewards = {
    { id = 27893, name = "Heart's Desire" },
    { id = 27894, name = "Sea Cavalier Standard" },
    { id = 27895, name = "Fortune Sack"},
    { id = 27896, name = "Ancient Script Leaf"},
    { id = 27898, name = "Smoldering Stone"},
    { id = 27899, name = "Pirate's Fortune Map"},
    { id = 27900, name = "Aurous Aquatic Jewel"},
    { id = 27901, name = "Buccaneer's Bauble"},
    { id = 27902, name = "Golden Mariner"},
}


local beastlyBag = Action ()

function beastlyBag.onUse(player, item, fromPosition, target, toPosition, isHotkey)
        local randId = math.random(1, #rewards)
        local rewardItem = rewards[randId]   

        local createdItem = Game.createItem(rewardItem.id, 1)
        if not createdItem then
            player:sendCancelMessage("The reward could not be created.")
            return true
        end

        if player:addItemEx(createdItem) ~= RETURNVALUE_NOERROR then
            createdItem:remove()
            player:sendCancelMessage("You don't have enough space for the reward.")
            return true
        end

        item:remove(1)
        toPosition:sendMagicEffect(CONST_ME_FIREAREA)
        player:sendTextMessage(MESSAGE_INFO_DESCR, 'You obtained x1 ' .. rewardItem.name .. '.')
        playSoundPlayer(player, "open_bag.ogg")
        return true
end

beastlyBag:id(27896)
beastlyBag:register()
