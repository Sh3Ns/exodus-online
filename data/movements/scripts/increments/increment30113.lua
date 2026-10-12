function onEquip(player, item, slot)
    player:addSpecializedMagicLevel(COMBAT_ENERGYDAMAGE, 6)
    player:addSpecializedMagicLevel(COMBAT_FIREDAMAGE, 3)
    return true
end

function onDeEquip(player, item, slot)
    player:removeSpecializedMagicLevel(COMBAT_ENERGYDAMAGE, 6)
    player:removeSpecializedMagicLevel(COMBAT_FIREDAMAGE, 3)
    return true
end