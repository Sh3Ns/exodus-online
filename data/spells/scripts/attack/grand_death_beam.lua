local mentorStorage = 405906

function onGetFormulaValues(player, level, maglevel)
    local min = (level / 5) + (maglevel * 5.5)
    local max = (level / 5) + (maglevel * 9)
    if player:getStorageValue(mentorStorage) == 1 then
        min = math.floor(min * 1.05)
        max = math.floor(max * 1.05)
    end
    local armor = player:getSlotItem(CONST_SLOT_LEGS)
    if armor and armor:getId() == 30023 then
        min = math.floor(min * 1.07)
        max = math.floor(max * 1.07)
    end
    return -min, -max
end

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
combat:setArea(createCombatArea(AREA_BEAM8))
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, var)
    if not creature or not creature:isPlayer() then
        return false
    end

    local executed = combat:execute(creature, var)

    if executed then
        playSound(creature, "mort_2.ogg")
        return true
    end

    return false
end
