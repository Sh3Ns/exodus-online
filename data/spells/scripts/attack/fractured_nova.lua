local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 377)
combat:setArea(createCombatArea(AREA_RING1_BURST3))

local function hasFracturedMelee(player)
    local left = player:getSlotItem(CONST_SLOT_LEFT)
    local right = player:getSlotItem(CONST_SLOT_RIGHT)

    for _, weapon in ipairs({left, right}) do
        if weapon then
            local attr = weapon:getCustomAttribute("fractured_magic")
            if attr == true or attr == 1 or attr == "true" then
                return true
            end
        end
    end

    return false
end

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.72) + 45
	local max = (level / 5) + (magicLevel * 8.14) + 65
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then return false end

    if not hasFracturedMelee(player) then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You need a Fractured magic weapon equipped to cast this spell.")
        return false
    end

    playSound(player, "thunder.ogg")
    return combat:execute(player, variant)
end