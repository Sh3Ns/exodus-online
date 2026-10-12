local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_STONES)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_EARTH)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + magicLevel + 6
	local max = (level / 5) + (magicLevel * 2.6) + 16
	if player:getStorageValue(mentorStorage) == 1 and not player:isDruid() then
		min = math.floor(min * 1.05)
		max = math.floor(max * 1.05)
	end
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local STONE_SHOWER_RUNE_ID = 2288

function onCastSpell(creature, variant, isHotkey)
	local player = Player(creature)
    if not player then
        return false
    end
	playSound(creature, "earth_rune.ogg")
	local result = combat:execute(creature, variant)
    if not result then
        return false
    end

    player:removeItem(STONE_SHOWER_RUNE_ID, 1)
	return true
end