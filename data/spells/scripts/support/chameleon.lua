local condition = Condition(CONDITION_OUTFIT)
condition:setTicks(200000)

local CHAMELEON_RUNE_ID = 2291

function onCastSpell(creature, variant, isHotkey)
    local player = Player(creature)
    if not player then
        return false
    end

    local position, item = variant:getPosition()
    if position.x == CONTAINER_POSITION then
        local container = creature:getContainerById(position.y - 64)
        if container then
            item = container:getItem(position.z)
        else
            item = creature:getSlotItem(position.y)
        end
    else
        local tile = Tile(position)
        item = tile and tile:getTopDownItem() or nil
    end

    if not item or item.itemid == 0 or not isMoveable(item.uid) then
        creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
        creature:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    playSound(creature, "chamaleon.ogg")
    condition:setOutfit({ lookTypeEx = item.itemid })
    creature:addCondition(condition)
    creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
    player:removeItem(CHAMELEON_RUNE_ID, 1)

    return true
end