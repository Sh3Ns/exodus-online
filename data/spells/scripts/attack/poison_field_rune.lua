local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
combat:setParameter(COMBAT_PARAM_CREATEITEM, ITEM_POISONFIELD_PVP)

local POISONFIELD_RUNE_ID = 2285

function onCastSpell(creature, variant, isHotkey)
	local player = Player(creature)
    if not player then
        return false
    end
	playSound(creature, "poison_rune.ogg")
	local result = combat:execute(creature, variant)
    if not result then
        return false
    end

    player:removeItem(POISONFIELD_RUNE_ID, 1)
	return true
end
