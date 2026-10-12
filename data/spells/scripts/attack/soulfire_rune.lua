local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITBYFIRE)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)

local mentorStorage = 405906
local FIRE_RUNE_ID = 2308

function onCastSpell(creature, variant, isHotkey)
    local player = Player(creature)
    if not player then
        return false
    end

    playSound(creature, "fire_rune.ogg")

    local result = combat:execute(creature, variant)
    if not result then
        return false
    end

    local min = (creature:getLevel() / 80) + (creature:getMagicLevel() * 0.3) + 2
    local max = (creature:getLevel() / 80) + (creature:getMagicLevel() * 0.6) + 4

    if creature:getStorageValue(mentorStorage) == 1 and not creature:isDruid() then
        min = math.floor(min * 1.05)
        max = math.floor(max * 1.05)
    end

    local rounds = math.random(math.floor(min), math.floor(max))

    for _, target in ipairs(combat:getTargets(creature, variant)) do
        creature:addDamageCondition(
            target,
            CONDITION_FIRE,
            DAMAGELIST_VARYING_PERIOD,
            target:isPlayer() and 5 or 10,
            {8, 10},
            rounds
        )
    end

    player:removeItem(FIRE_RUNE_ID, 1)

    return true
end