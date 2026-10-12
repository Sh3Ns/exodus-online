local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITBYFIRE)
combat:setArea(createCombatArea(AREA_WAVE4, AREADIAGONAL_WAVE4))

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
	if player:getStorageValue(mentorStorage) == 1 and not player:isDruid() then
		return -12, -15
	else
		return -11, -14
	end
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "fire_2.ogg")
	return combat:execute(creature, variant)
end
