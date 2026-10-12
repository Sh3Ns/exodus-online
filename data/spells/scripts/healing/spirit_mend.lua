local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local storage_sustain = 405902
local storageDouble = 405905

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 3.4) + 22
	local max = (level / 5) + (magicLevel * 6.9) + 38
	if player:getStorageValue(storageDouble) == 1 then
		min = math.floor(min * 1.70)
		max = math.floor(max * 1.70)
	elseif player:getStorageValue(storage_sustain) == 1 then
        min = math.floor(min * 1.35)
        max = math.floor(max * 1.35)
    end

	local armor = player:getSlotItem(CONST_SLOT_ARMOR)
    if armor and armor:getId() == 29992 then
        min = math.floor(min * 1.08)
        max = math.floor(max * 1.08)
    end
	return min, max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "heal_7.ogg")
    return combat:execute(creature, variant)
end
