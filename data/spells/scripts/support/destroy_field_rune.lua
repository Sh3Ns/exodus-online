local DESTROY_FIELD_RUNE_ID = 2261

function onCastSpell(creature, variant, isHotkey)
    local player = Player(creature)
    if not player then
        return false
    end

    local position = variant:getPosition()
    local tile = Tile(position)
    local field = tile and tile:getItemByType(ITEM_TYPE_MAGICFIELD)

    if field and table.contains(FIELDS, field:getId()) then
        field:remove()
        position:sendMagicEffect(CONST_ME_POFF)
        playSound(creature, "destroy_rune.ogg")

        player:removeItem(DESTROY_FIELD_RUNE_ID, 1)

        return true
    end

    creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
    creature:getPosition():sendMagicEffect(CONST_ME_POFF)
    return false
end