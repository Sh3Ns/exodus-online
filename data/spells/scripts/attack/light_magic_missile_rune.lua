local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 0.4) + 3
	local max = (level / 5) + (magicLevel * 0.8) + 5
	if player:getStorageValue(mentorStorage) == 1 and not player:isDruid() then
		min = math.floor(min * 1.05)
		max = math.floor(max * 1.05)
	end
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local LIGHTMAGICMISSILE_RUNE_ID = 2287

function onCastSpell(creature, variant, isHotkey)
	local player = Player(creature)
    if not player then
        return false
    end
	playSound(creature, "energy_rune.ogg")
	local result = combat:execute(creature, variant)
    if not result then
        return false
    end

    player:removeItem(LIGHTMAGICMISSILE_RUNE_ID, 1)
	return true
end