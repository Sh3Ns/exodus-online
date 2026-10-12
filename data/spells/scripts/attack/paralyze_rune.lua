local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)

local condition = Condition(CONDITION_PARALYZE)
condition:setParameter(CONDITION_PARAM_TICKS, 20000)
condition:setFormula(-1, 80, -1, 80)
combat:addCondition(condition)

local PARALYZE_RUNE_ID = 2278

function onCastSpell(creature, variant, isHotkey)
    local player = Player(creature)
    if not player then
        return false
    end

    if not combat:execute(creature, variant) then
        return false
    end

    creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    playSound(creature, "paralyse.ogg")

    player:removeItem(PARALYZE_RUNE_ID, 1)

    return true
end