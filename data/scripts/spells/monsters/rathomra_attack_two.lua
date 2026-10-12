local areas = {
    [DIRECTION_NORTH] = {
        startX = 0,
        startY = 4,
        stepX = 0,
        stepY = -1
    },
    [DIRECTION_SOUTH] = {
        startX = 0,
        startY = -4,
        stepX = 0,
        stepY = 1
    },
    [DIRECTION_EAST] = {
        startX = -4,
        startY = 0,
        stepX = 1,
        stepY = 0
    },
    [DIRECTION_WEST] = {
        startX = 4,
        startY = 0,
        stepX = -1,
        stepY = 0
    }
}

local function doWave(creatureId, bossPos, direction, currentStep)
    local creature = Creature(creatureId)
    if not creature then
        return
    end

    local config = areas[direction]
    if not config then
        return
    end

    local centerX = bossPos.x + config.startX + (config.stepX * currentStep)
    local centerY = bossPos.y + config.startY + (config.stepY * currentStep)

    for i = -2, 2 do
        local posX = centerX
        local posY = centerY

        if direction == DIRECTION_NORTH or direction == DIRECTION_SOUTH then
            posX = posX + i
        else
            posY = posY + i
        end

        local targetPos = Position(posX, posY, bossPos.z)
        targetPos:sendMagicEffect(393)

        local tile = Tile(targetPos)
        if tile then
            local creatures = tile:getCreatures()
            if creatures then
                for _, target in ipairs(creatures) do
                    if target and target:isCreature() and target ~= creature then
                        doTargetCombatHealth(creature, target, COMBAT_ARCANEDAMAGE, -3500, -6000, CONST_ME_NONE)
                    end
                end
            end
        end
    end
end

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    local bossPos = creature:getPosition()
    local direction = creature:getDirection()
    local creatureId = creature:getId()

    creature:say("Rathmora unleashes a wave of corruption!", TALKTYPE_MONSTER_SAY)

    for step = 0, 8 do
        addEvent(doWave, step * 650, creatureId, bossPos, direction, step)
    end

    return true
end

spell:name("rathmora attack agressive")
spell:words("###1138")
spell:isAggressive(true)
spell:blockWalls(true)
spell:needDirection(false)
spell:needLearn(false)
spell:register()