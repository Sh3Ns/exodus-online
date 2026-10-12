local LoginEvent = CreatureEvent("IncrementsItemsLogin")

function LoginEvent.onLogin(player)
    local head = player:getSlotItem(CONST_SLOT_HEAD)
    local armor = player:getSlotItem(CONST_SLOT_ARMOR)
    local legs = player:getSlotItem(CONST_SLOT_LEGS)
    local feet = player:getSlotItem(CONST_SLOT_FEET)
    local weapon = player:getSlotItem(CONST_SLOT_LEFT)


    -- Increments Armor --
    if armor and armor:getId() == 30113 then
        player:addSpecializedMagicLevel(COMBAT_ENERGYDAMAGE, 6)
        player:addSpecializedMagicLevel(COMBAT_FIREDAMAGE, 3)
    elseif armor and armor:getId() == 30114 then
        player:addSpecializedMagicLevel(COMBAT_EARTHDAMAGE, 6)
        player:addSpecializedMagicLevel(COMBAT_HEALTHDAMAGE, 3)
    end

    -- Increment Helmets --
    if head and head:getId() == 30121 then
        player:addSpecializedMagicLevel(COMBAT_FIREDAMAGE, 2)
    end
  return true
end

LoginEvent:type("login")
LoginEvent:register()