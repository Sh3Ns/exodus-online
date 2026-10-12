local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_POISON)
combat:setParameter(COMBAT_PARAM_TARGETCASTERORTOPMOST, true)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local CURE_RUNE_ID = 2266

function onCastSpell(creature, variant, isHotkey)
	playSound(creature, "cure.ogg")
	local player = Player(creature)
    if not player then
        return false
    end
	playSound(creature, "cure.ogg")
	local result = combat:execute(creature, variant)
    if not result then
        return false
    end

    player:removeItem(CURE_RUNE_ID, 1)
	return true
end