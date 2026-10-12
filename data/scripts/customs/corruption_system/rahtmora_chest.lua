local rewards = {
    { id = 30621, name = "rathmora head" , count = 1},
    { id = 30615, name = "rathmora heart" , count = 1},
    { id = 30618, name = "masterpiece armor shard" , count = 10},
    { id = 30625, name = "rathmora eye" , count = 2},
    { id = 30622, name = "blazing leaf" , count = 15},
    { id = 30628, name = "vessel spirit essence" , count = 3},
    { id = 30620, name = "spirit vessel" , count = 2},
    { id = 30616, name = "electrical device" , count = 1},
}

local rathmoraChest = Action()

function rathmoraChest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not target or target:getId() ~= 30630 then
        player:sendCancelMessage("You need to use this key on the rathmora chest.")
        return true
    end

    local rewardItem = rewards[math.random(#rewards)]

    local createdItem = Game.createItem(rewardItem.id, rewardItem.count)
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
    target:remove(1)

    player:sendTextMessage(MESSAGE_INFO_DESCR, "You received " .. rewardItem.count .. "x " .. rewardItem.name .. ".")
    playSoundPlayer(player, "open_bag.ogg")
    return true
end

rathmoraChest:id(30631)
rathmoraChest:register()