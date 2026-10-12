local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_WATERDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_NONE)
combat:setArea(createCombatArea(AREA_WAVE_WATER))

function onGetFormulaValues(player, skill, attack, factor)
    local min = (player:getLevel() / 5) + (skill * attack * 0.15) + 19
	local max = (player:getLevel() / 5) + (skill * attack * 0.30) + 34
    return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local function hasFracturedMagic(player)
    local left = player:getSlotItem(CONST_SLOT_LEFT)
    local right = player:getSlotItem(CONST_SLOT_RIGHT)

    for _, weapon in ipairs({left, right}) do
        if weapon then
            local attr = weapon:getCustomAttribute("fractured_melee")
            if attr == true or attr == 1 or attr == "true" then
                return true
            end
        end
    end
    return false
end

local function getWaveFrontPosition(creature)
    local pos = creature:getPosition()
    local dir = creature:getDirection()

    if dir == DIRECTION_NORTH then
        return Position(pos.x, pos.y, pos.z)
    elseif dir == DIRECTION_SOUTH then
        return Position(pos.x, pos.y + 3, pos.z)
    elseif dir == DIRECTION_EAST then
        return Position(pos.x + 3, pos.y, pos.z)
    elseif dir == DIRECTION_WEST then
        return Position(pos.x, pos.y, pos.z)
    end

    return pos
end

local function sendDirectionalEffect(creature)
    local pos = getWaveFrontPosition(creature)
    local dir = creature:getDirection()
    local extra = 1

    if dir == DIRECTION_NORTH then
        pos.y = pos.y - extra
        pos:sendMagicEffect(379)
    elseif dir == DIRECTION_SOUTH then
        pos.y = pos.y + extra
        pos:sendMagicEffect(380)
    elseif dir == DIRECTION_EAST then
        pos.x = pos.x + extra
        pos:sendMagicEffect(378)
    elseif dir == DIRECTION_WEST then
        pos.x = pos.x - extra
        pos:sendMagicEffect(381)
    end
end

function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then return false end

    if not hasFracturedMagic(player) then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You need a Fractured melee weapon equipped to cast this spell.")
        return false
    end
    playSound(player, "energy_3.ogg")
    sendDirectionalEffect(creature)

    return combat:execute(creature, variant)
end