local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ARCANEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 312)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

function onGetFormulaValues(player, level, magicLevel)
    local min = (level / 5) + (magicLevel * 4) + 75
    local max = (level / 5) + (magicLevel * 10) + 150
    return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local function removeClone(cloneId)
    local clone = Creature(cloneId)
    if clone then
        clone:remove()
    end
end

local function createClone(position, playerOutfit, playerName, player)
    local tile = Tile(position)
    if not tile or tile:hasFlag(TILESTATE_PROTECTIONZONE) or not tile:getGround() then
        return
    end
    if not tile:isWalkable() then
        return
    end

    local clone = Game.createMonster("Clone", position)
    if clone then
        clone:setOutfit(playerOutfit)
        clone:rename(playerName)
        clone:setMaster(player)
        addEvent(removeClone, 8000, clone:getId())
    end
end

local function setGhostModeFalse(playerId)
    local player = Player(playerId)
    if player then
        player:setGhostMode(false)
    else
        addEvent(setGhostModeFalse, 1000, playerId)
    end
end

function onCastSpell(creature, variant)
    local player = creature:getPlayer()
    if not player then
        return false
    end
    
    local position = player:getPosition()
    local tile = Tile(position)
    if not tile or tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    player:setGhostMode(true)
    addEvent(setGhostModeFalse, 8000, player:getId())
    combat:execute(player, variant)
    playSound(creature, "monster_summoned.ogg")
    playSound(creature, "arcane_6.ogg")

    local clonePositions = {
        {x = position.x,     y = position.y - 1, z = position.z}, -- North
        {x = position.x - 1, y = position.y,     z = position.z}, -- West
        {x = position.x + 1, y = position.y,     z = position.z}, -- East
        {x = position.x,     y = position.y + 1, z = position.z}, -- South
    }

    local playerOutfit = player:getOutfit()
    local playerName = player:getName()
    for _, pos in ipairs(clonePositions) do
        createClone(Position(pos.x, pos.y, pos.z), playerOutfit, playerName, player)
    end
    
    return true
end