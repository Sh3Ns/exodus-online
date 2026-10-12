function onEquip(player, item, slot)
    player:addSpecializedMagicLevel(COMBAT_FIREDAMAGE, 2)
    return true
end

function onDeEquip(player, item, slot)
    player:removeSpecializedMagicLevel(COMBAT_FIREDAMAGE, 2)
    return true
end