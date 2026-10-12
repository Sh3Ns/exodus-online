local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local storage_sustain = 405902
local storageDouble = 405905
local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
	level = math.min(level, 20)
	magicLevel = math.min(magicLevel, 20)
	local min = (level / 5) + (magicLevel * 0.6) + 3
	local max = (level / 5) + magicLevel + 6
	if player:getStorageValue(storageDouble) == 1 then
		min = math.floor(min * 1.70)
		max = math.floor(max * 1.70)
	elseif player:getStorageValue(storage_sustain) == 1 then
        min = math.floor(min * 1.35)
        max = math.floor(max * 1.35)
    end
	if player:getStorageValue(mentorStorage) == 1 and player:isDruid() then
		min = math.floor(min * 1.05)
		max = math.floor(max * 1.05)
	end
	return min, max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "heal.ogg")
	return combat:execute(creature, variant)
end
