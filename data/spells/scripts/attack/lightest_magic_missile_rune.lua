local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
	if player:getStorageValue(mentorStorage) == 1 and not player:isDruid() then
		return -5, -9
	else
		return -3, -7
	end
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local LIGHTESTMAGIC_MISSILE_RUNE_ID = 19392

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

    player:removeItem(LIGHTESTMAGIC_MISSILE_RUNE_ID, 1)
	return true
end