local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREATTACK)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
    local handWeapon = player:getSlotItem(CONST_SLOT_RIGHT)
    local itemMultipliers = {
        [28688] = 1.33,
    }
    local min = (level / 5) + (magicLevel * 4.5) + 35
	local max = (level / 5) + (magicLevel * 7.3) + 55
    local multiplier = 1.0
    if handWeapon and itemMultipliers[handWeapon.itemid] then 
        multiplier = multiplier * itemMultipliers[handWeapon.itemid] end
    if player:getStorageValue(mentorStorage) == 1 then 
        multiplier = multiplier * 1.05
    end
 
    min = math.floor(min * multiplier) 
    max = math.floor(max * multiplier) 
    return -min, -max 
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant) 
	playSound(creature, "fire.ogg")
	return combat:execute(creature, variant)
end
