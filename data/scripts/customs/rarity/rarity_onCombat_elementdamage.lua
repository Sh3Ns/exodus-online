local creatureEvent = CreatureEvent("rarity_onHealthChangeDamage")

function creatureEvent.onHealthChange(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not source or not source:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if origin ~= ORIGIN_MELEE and origin ~= ORIGIN_RANGED then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local weapon = source:getSlotItem(CONST_SLOT_RIGHT) or source:getSlotItem(CONST_SLOT_LEFT)
    if not weapon then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local itemType = weapon:getType()
    local baseElement = itemType and itemType:getElementDamage() or 0
    local baseElementType = itemType and itemType:getElementType() or COMBAT_NONE


    local elementTypes = {
        {combatType = COMBAT_FIREDAMAGE,   storage = 977554, name = "Fire"},
        {combatType = COMBAT_ICEDAMAGE,    storage = 977555, name = "Ice"},
        {combatType = COMBAT_ENERGYDAMAGE, storage = 977556, name = "Energy"},
        {combatType = COMBAT_EARTHDAMAGE,  storage = 977557, name = "Earth"},
        {combatType = COMBAT_DEATHDAMAGE,  storage = 977558, name = "Death"},
        {combatType = COMBAT_WATERDAMAGE,  storage = 977559, name = "Water"},
        {combatType = COMBAT_HOLYDAMAGE,   storage = 977560, name = "Holy"},
        {combatType = COMBAT_ARCANEDAMAGE, storage = 977561, name = "Arcane"},
    }

    local totalBonus = 0
    local chosenBonusType = COMBAT_NONE

    for _, elemData in ipairs(elementTypes) do
        local bonusValue = source:getStorageValue(elemData.storage) or 0
        if bonusValue > 0 then
            totalBonus = totalBonus + bonusValue
            if chosenBonusType == COMBAT_NONE then
                chosenBonusType = elemData.combatType
            elseif chosenBonusType ~= elemData.combatType then
                return
            end
        end
    end

    local finalElementType = (baseElementType ~= COMBAT_NONE) and baseElementType or chosenBonusType
    local elementPercent = baseElement + totalBonus


    if elementPercent <= 0 or finalElementType == COMBAT_NONE then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local mainPhysical = 0
    if primaryDamage < 0 then
        mainPhysical = -primaryDamage
    end

    local newElementalDamage = math.floor((mainPhysical * elementPercent) / 133)
    newElementalDamage = -newElementalDamage

    if newElementalDamage >= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    if secondaryType ~= COMBAT_NONE and secondaryDamage < 0 and secondaryType ~= finalElementType then
        secondaryDamage = secondaryDamage + newElementalDamage
    else
        secondaryType = finalElementType
        if secondaryDamage < 0 then
            secondaryDamage = secondaryDamage + newElementalDamage
        else
            secondaryDamage = newElementalDamage
        end
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

creatureEvent:register()


local creatureEvent = CreatureEvent("rarity_onManaChangeDamage")

function creatureEvent.onManaChange(target, source, manaChange, origin)
    if not source or not source:isPlayer() then
        return manaChange
    end

    if origin ~= ORIGIN_MELEE and origin ~= ORIGIN_RANGED then
        return manaChange
    end

    local weapon = source:getSlotItem(CONST_SLOT_RIGHT) or source:getSlotItem(CONST_SLOT_LEFT)
    if not weapon then
        return manaChange
    end

    local itemType = weapon:getType()
    local baseElement = itemType and itemType:getElementDamage() or 0
    local baseElementType = itemType and itemType:getElementType() or COMBAT_NONE

    local elementTypes = {
        {combatType = COMBAT_FIREDAMAGE,   storage = 977554},
        {combatType = COMBAT_ICEDAMAGE,    storage = 977555},
        {combatType = COMBAT_ENERGYDAMAGE, storage = 977556},
        {combatType = COMBAT_EARTHDAMAGE,  storage = 977557},
        {combatType = COMBAT_DEATHDAMAGE,  storage = 977558},
        {combatType = COMBAT_WATERDAMAGE,  storage = 977559},
        {combatType = COMBAT_HOLYDAMAGE,   storage = 977560},
        {combatType = COMBAT_ARCANEDAMAGE, storage = 977561},
    }

    local totalBonus = 0
    local chosenBonusType = COMBAT_NONE

    for _, elemData in ipairs(elementTypes) do
        local bonusValue = source:getStorageValue(elemData.storage) or 0
        if bonusValue > 0 then
            totalBonus = totalBonus + bonusValue
            if chosenBonusType == COMBAT_NONE then
                chosenBonusType = elemData.combatType
            elseif chosenBonusType ~= elemData.combatType then
                return manaChange
            end
        end
    end

    local finalElementType = (baseElementType ~= COMBAT_NONE) and baseElementType or chosenBonusType
    local elementPercent = baseElement + totalBonus

    if elementPercent <= 0 or finalElementType == COMBAT_NONE then
        return manaChange
    end

    if manaChange < 0 then
        local manaLoss = -manaChange
        local newElementalDamage = math.floor((manaLoss * elementPercent) / 133)
        manaChange = manaChange - newElementalDamage
    end

    return manaChange
end

creatureEvent:register()


local ec = EventCallback
function ec.onTargetCombat(creature, target)
    if creature and target and creature:isPlayer() then
        target:registerEvent("rarity_onHealthChangeDamage")
		target:registerEvent("rarity_onManaChangeDamage")
    end
    return RETURNVALUE_NOERROR
end
ec:register(7)
