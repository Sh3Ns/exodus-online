local rewards = {
    { id = 27985, name = "Easter Egg Basket" , chance = 20},
    { id = 27987, name = "Easter Egg" , chance = 50},
    { id = 27988, name = "Magical Easter Egg" , chance = 10},
    { id = 27989, name = "Easter Egg Nest" , chance = 20},
}

local totalChance = 0
for _, reward in ipairs(rewards) do
    totalChance = totalChance + reward.chance
end

local easterEgg = Action()

function easterEgg.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local randomChance = math.random(1, totalChance) 
    local cumulativeChance = 0
    for _, reward in ipairs(rewards) do
        cumulativeChance = cumulativeChance + reward.chance
        if randomChance <= cumulativeChance then
            local createdItem = Game.createItem(reward.id, 1)
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
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You received a ' .. reward.name .. '.')
            return true
        end
    end
end

easterEgg:id(27986)
easterEgg:register()
