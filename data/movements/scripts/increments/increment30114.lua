function onEquip(player, item, slot)
    player:addSpecializedMagicLevel(COMBAT_EARTHDAMAGE, 6)
    player:addSpecializedMagicLevel(COMBAT_HEALTHDAMAGE, 3)
    return true
end

function onDeEquip(player, item, slot)
    player:removeSpecializedMagicLevel(COMBAT_EARTHDAMAGE, 6)
    player:removeSpecializedMagicLevel(COMBAT_HEALTHDAMAGE, 3)
    return true
end