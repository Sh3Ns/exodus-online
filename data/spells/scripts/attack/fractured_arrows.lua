local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 383)
combat:setArea(createCombatArea(AREA_ARROW_FRACTURED))

function onGetFormulaValues(player, skill, attack, factor)
	local distanceSkill = player:getEffectiveSkillLevel(SKILL_DISTANCE)
	local min = (player:getLevel() / 5) + distanceSkill + 9
	local max = (player:getLevel() / 5) + (distanceSkill * 1.7) + 21
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local function hasFracturedMagic(player)
    local left = player:getSlotItem(CONST_SLOT_LEFT)
    local right = player:getSlotItem(CONST_SLOT_RIGHT)

    for _, weapon in ipairs({left, right}) do
        if weapon then
            local attr = weapon:getCustomAttribute("fractured_distance")
            if attr == true or attr == 1 or attr == "true" then
                return true
            end
        end
    end
    return false
end

function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then return false end

    if not hasFracturedMagic(player) then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You need a Fractured distance weapon equipped to cast this spell.")
        return false
    end
    playSound(player, "arrow_1.ogg")

    return combat:execute(creature, variant)
end