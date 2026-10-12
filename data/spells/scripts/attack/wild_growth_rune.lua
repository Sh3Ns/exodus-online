local combat = Combat()
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
combat:setParameter(COMBAT_PARAM_CREATEITEM, ITEM_WILDGROWTH)

local WILD_GROWTH_RUNE_ID = 2269

function onCastSpell(creature, variant, isHotkey)
	local player = Player(creature)
    if not player then
        return false
    end
	playSound(creature, "grow_rune.ogg")
	local result = combat:execute(creature, variant)
    if not result then
        return false
    end

    player:removeItem(WILD_GROWTH_RUNE_ID, 1)
	return true
end