local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGYBALL)
combat:setParameter(COMBAT_PARAM_CREATEITEM, ITEM_ENERGYFIELD_PVP)
combat:setArea(createCombatArea(AREA_SQUARE1X1))

local ENERGYBOMB_RUNE_ID = 2262

function onCastSpell(creature, variant, isHotkey)
    local player = Player(creature)
    if not player then
        return false
    end

    playSound(creature, "bomb_rune.ogg")

    local result = combat:execute(creature, variant)
    if not result then
        return false
    end

    player:removeItem(ENERGYBOMB_RUNE_ID, 1)

    return true
end