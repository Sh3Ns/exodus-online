local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREATTACK)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
	if player:getStorageValue(mentorStorage) == 1 and not player:isDruid() then
		return -15, -30
	else
		return -10, -20
	end
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "fire.ogg")
	return combat:execute(creature, variant)
end
