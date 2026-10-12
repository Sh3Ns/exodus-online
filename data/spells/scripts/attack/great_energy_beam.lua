local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
combat:setArea(createCombatArea(AREA_BEAM8))

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 3.6) + 22
	local max = (level / 5) + (magicLevel * 6) + 37
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

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "energy_2.ogg")
	return combat:execute(creature, variant)
end
