local config = MakeBelieveQuestConfig
if not config then
    error("[Phosphorus challenge] 00_make_believe_config.lua was not loaded, verify if you edited the file!")
end

local states = {}
local creatureRoles = {}
local nextToken = 0
local activeRun = nil
local beginPhosphorusForm
local randomWalkablePositions

local function isConfiguredPosition(position)
    return position and (position.x ~= 0 or position.y ~= 0 or position.z ~= 0)
end

local function isInside(position, area)
    return position.z == area.from.z
        and position.x >= area.from.x and position.x <= area.to.x
        and position.y >= area.from.y and position.y <= area.to.y
end

local function roomCreatures(room)
    if not isConfiguredPosition(room.area.from) or not isConfiguredPosition(room.area.to) then
        return {}
    end

    local width = room.area.to.x - room.area.from.x
    local height = room.area.to.y - room.area.from.y
    local center = Position(room.area.from.x + math.floor(width / 2), room.area.from.y + math.floor(height / 2), room.area.from.z)
    local creatures = Game.getSpectators(center, false, false, math.ceil(width / 2), math.ceil(width / 2), math.ceil(height / 2), math.ceil(height / 2))
    local result = {}
    for _, creature in ipairs(creatures) do
        if isInside(creature:getPosition(), room.area) then
            result[#result + 1] = creature
        end
    end
    return result
end

local function roomPlayers(room)
    local players = {}
    for _, creature in ipairs(roomCreatures(room)) do
        local player = creature:getPlayer()
        if player then
            players[#players + 1] = player
        end
    end
    return players
end

local function broadcast(room, message)
    for _, player in ipairs(roomPlayers(room)) do
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
    end
end

local function schedule(roomKey, token, callback, delay)
    return addEvent(function()
        local state = states[roomKey]
        if state and state.active and state.token == token then
            callback(state, config.rooms[roomKey])
        end
    end, delay)
end

local function removeRole(creatureId)
    creatureRoles[creatureId] = nil
end

local function spawnMonster(roomKey, name, position, role)
    if not name or not isConfiguredPosition(position) then
        return nil
    end
    local monster = Game.createMonster(name, position, true, true)
    if monster then
        monster:registerEvent("MakeBelieveHealth")
        monster:registerEvent("MakeBelieveDeath")
        creatureRoles[monster:getId()] = { room = roomKey, role = role }
    end
    return monster
end

function MakeBelieveChangeForm(creature, replacementName)
    if not creature or not replacementName then
        return false
    end

    local creatureId = creature:getId()
    local role = creatureRoles[creatureId]
    local state = role and states[role.room]
    if not state or not state.active or state.invulnerable
        or role.role ~= "boss" or state.bossId ~= creatureId then
        return false
    end

    local position = creature:getPosition()
    if role.room == "phosphorus" then
        creature:say("PHOSPHORUS MANIFESTATION ESCAPED!", TALKTYPE_MONSTER_SAY)
    end
    removeRole(creatureId)
    state.bossId = nil
    creature:remove()

    local replacement = spawnMonster(role.room, replacementName, position, "boss")
    if not replacement then
        broadcast(config.rooms[role.room], "The next boss form could not be created: " .. replacementName)
        return false
    end

    state.bossId = replacement:getId()
    position:sendMagicEffect(CONST_ME_TELEPORT)
    if role.room == "phosphorus" and beginPhosphorusForm then
        beginPhosphorusForm(state, config.rooms.phosphorus, replacement)
    else
        state.invulnerable = false
    end
    if role.room == "domus" and config.rooms.domus.vulnerableBossEffect then
        replacement:getPosition():sendMagicEffect(config.rooms.domus.vulnerableBossEffect)
    end
    if role.room == "phosphorus" then
        broadcast(config.rooms.phosphorus, "Phosphorus Ascendant has appeared!")
    else
        broadcast(config.rooms[role.room], replacementName .. " reveals its true form!")
    end
    return true
end

local function cannonPosition(state, cannon, side)
    if isConfiguredPosition(cannon.position) then
        return cannon.position
    end
    return state and state.cannonPositions and state.cannonPositions[side] or nil
end

local function resetMimarCannons(state, room)
    if not room.cannons then
        return
    end
    for side, cannon in pairs(room.cannons) do
        local position = cannonPosition(state, cannon, side)
        local tile = position and Tile(position)
        local charged = tile and tile:getItemById(cannon.chargedItemId)
        if charged then
            charged:transform(cannon.itemId)
            charged:setActionId(cannon.actionId)
        end
    end
end

local function removeMechanicItems(room, state)
    resetMimarCannons(state, room)
    local traps = room.arcaneTraps
    if traps and traps.itemId and traps.itemId > 0 then
        for x = traps.area.from.x, traps.area.to.x do
            for y = traps.area.from.y, traps.area.to.y do
                local tile = Tile(Position(x, y, traps.area.from.z))
                local item = tile and tile:getItemById(traps.itemId)
                while item do
                    item:remove()
                    item = tile:getItemById(traps.itemId)
                end
            end
        end
    end
    local hazards = room.hazards
    if not hazards then
        return
    end
    for _, hazard in pairs({ hazards.rift, hazards.cloud }) do
        if hazard and hazard.itemId and hazard.itemId > 0 then
            for _, position in ipairs(hazard.positions or {}) do
                local tile = Tile(position)
                local item = tile and tile:getItemById(hazard.itemId)
                if item then
                    item:remove()
                end
            end
        end
    end
end

local function cleanupRoom(roomKey, teleportPlayers, message)
    local room = config.rooms[roomKey]
    local state = states[roomKey]
    if state then
        state.active = false
    end

    for _, creature in ipairs(roomCreatures(room)) do
        removeRole(creature:getId())
        local player = creature:getPlayer()
        if player then
            if teleportPlayers and isConfiguredPosition(room.exit) then
                player:teleportTo(room.exit, false)
                room.exit:sendMagicEffect(CONST_ME_TELEPORT)
                if message then
                    player:sendTextMessage(MESSAGE_INFO_DESCR, message)
                end
            end
        else
            creature:remove()
        end
    end
    removeMechanicItems(room, state)
    states[roomKey] = nil
end

local function createCompletionPortal(room)
    local portal = room.completionPortal
    if not portal or not isConfiguredPosition(portal.position) or not isConfiguredPosition(portal.destination) then
        return
    end
    local tile = Tile(portal.position)
    local old = tile and tile:getItemById(config.teleportItemId)
    if old then
        old:remove()
    end
    local item = Game.createItem(config.teleportItemId, 1, portal.position)
    if not item then
        return
    end
    item:setDestination(portal.destination)
    item:setActionId(portal.actionId)
    portal.position:sendMagicEffect(CONST_ME_TELEPORT)

    addEvent(function()
        local currentTile = Tile(portal.position)
        local currentPortal = currentTile and currentTile:getItemById(config.teleportItemId)
        if currentPortal and currentPortal:getActionId() == portal.actionId then
            currentPortal:remove()
            portal.position:sendMagicEffect(CONST_ME_POFF)
        end
    end, config.portalDurationSeconds * 1000)
end

local function completeRoom(roomKey)
    local room = config.rooms[roomKey]
    local players = roomPlayers(room)
    for _, player in ipairs(players) do
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The encounter is complete. Enter the portal to move the entire team.")
    end
    for _, creature in ipairs(roomCreatures(room)) do
        if not creature:isPlayer() then
            removeRole(creature:getId())
            creature:remove()
        end
    end
    createCompletionPortal(room)
    local state = states[roomKey]
    if state then
        state.active = false
    end
    if activeRun then
        activeRun.currentRoom = roomKey
    end
end

local function setInvulnerable(state, value, effect)
    state.invulnerable = value
    local boss = state.bossId and Monster(state.bossId)
    if boss then
        local bossEffect = effect
        if bossEffect == nil then
            bossEffect = value and CONST_ME_MAGIC_RED or CONST_ME_MAGIC_GREEN
        end
        if bossEffect then
            boss:getPosition():sendMagicEffect(bossEffect)
        end
    end
end

local function phosphorusBossSay(state, message)
    local boss = state.bossId and Monster(state.bossId)
    if boss then
        boss:say(message, TALKTYPE_MONSTER_SAY)
    end
end

local function applyPhosphorusFailureStacks(boss, state, room)
    local stacks = state.failedRivals or 0
    if stacks <= 0 then
        boss:setDamageMultiplier(1)
        return
    end

    local healthBonus = stacks * room.failureHealthBonus
    boss:setMaxHealth(boss:getMaxHealth() + healthBonus)
    boss:addHealth(healthBonus)
    boss:setDamageMultiplier(1 + ((stacks * room.failureDamagePercent) / 100))
end

local function addPhosphorusFailureStack(state, room)
    local boss = state.bossId and Monster(state.bossId)
    if not boss then
        return
    end

    state.failedRivals = (state.failedRivals or 0) + 1
    boss:setMaxHealth(boss:getMaxHealth() + room.failureHealthBonus)
    boss:addHealth(room.failureHealthBonus)
    boss:setDamageMultiplier(1 + ((state.failedRivals * room.failureDamagePercent) / 100))
end

local function removePhosphorusRivals()
    local rivalIds = {}
    for creatureId, role in pairs(creatureRoles) do
        if role.room == "phosphorus" and role.role == "rival" then
            rivalIds[#rivalIds + 1] = creatureId
        end
    end
    for _, creatureId in ipairs(rivalIds) do
        removeRole(creatureId)
        local rival = Monster(creatureId)
        if rival then
            rival:remove()
        end
    end
end

local function spawnPhosphorusRival(state, room, force)
    if state.vulnerabilityPhase then
        return
    end

    local now = os.time()
    if not force and state.nextRivalSpawnAt and now < state.nextRivalSpawnAt then
        return
    end
    state.nextRivalSpawnAt = now + room.rivalSpawnEverySeconds

    local boss = state.bossId and Monster(state.bossId)
    if not boss then
        return
    end

    local rivalIndex = math.random(#room.rivals)
    local rivalConfig = room.rivals[rivalIndex]
    local pedestalPosition = rivalConfig.pedestal.position
    boss:getPosition():sendMagicEffect(CONST_ME_POFF)
    boss:teleportTo(pedestalPosition, true)
    pedestalPosition:sendMagicEffect(CONST_ME_TELEPORT)
    boss:setMovementBlocked(true)

    local lockedBossId = boss:getId()
    schedule("phosphorus", state.token, function(current)
        if current.bossId == lockedBossId then
            local currentBoss = Monster(lockedBossId)
            if currentBoss then
                currentBoss:setMovementBlocked(false)
            end
        end
    end, room.bossPedestalHoldSeconds * 1000)

    local rival = spawnMonster("phosphorus", rivalConfig.name, room.rivalSpawnPosition, "rival")
    if not rival then
        boss:setMovementBlocked(false)
        broadcast(room, "The configured rival monster could not be created.")
        return
    end

    creatureRoles[rival:getId()].rivalIndex = rivalIndex
    broadcast(room, rivalConfig.name .. " has appeared. Kill it at the matching pedestal.")
end

local function startPhosphorusVulnerability(state, room)
    state.vulnerabilityPhase = true
    state.phaseSerial = (state.phaseSerial or 0) + 1
    state.nextRivalSpawnAt = nil
    removePhosphorusRivals()
    local boss = state.bossId and Monster(state.bossId)
    if boss then
        boss:setMovementBlocked(false)
    end
    setInvulnerable(state, false)
    phosphorusBossSay(state, "THE TEST BEGINS NOW!")

    local phaseSerial = state.phaseSerial
    local token = state.token
    schedule("phosphorus", token, function(current)
        if current.vulnerabilityPhase and current.phaseSerial == phaseSerial then
            phosphorusBossSay(current, "THE TEST IS NEARLY OVER")
        end
    end, 20000)
    schedule("phosphorus", token, function(current)
        if current.vulnerabilityPhase and current.phaseSerial == phaseSerial then
            phosphorusBossSay(current, "THE TEST ENDS NOW!")
        end
    end, 35000)
    schedule("phosphorus", token, function(current, currentRoom)
        if not current.vulnerabilityPhase or current.phaseSerial ~= phaseSerial then
            return
        end
        current.vulnerabilityPhase = false
        current.convertedRivals = 0
        setInvulnerable(current, true)
        phosphorusBossSay(current, "IT STARTS AGAIN!")
        spawnPhosphorusRival(current, currentRoom, true)
    end, room.vulnerableSeconds * 1000)
end

beginPhosphorusForm = function(state, room, boss)
    state.phaseSerial = (state.phaseSerial or 0) + 1
    state.vulnerabilityPhase = false
    state.convertedRivals = 0
    state.nextRivalSpawnAt = nil
    boss:setMovementBlocked(false)
    applyPhosphorusFailureStacks(boss, state, room)
    setInvulnerable(state, true)
    spawnPhosphorusRival(state, room, true)
end

local function spawnHazardItem(hazard)
    if not hazard or not hazard.itemId or hazard.itemId <= 0 or not hazard.positions or #hazard.positions == 0 then
        return nil
    end
    local position = hazard.positions[math.random(#hazard.positions)]
    if not isConfiguredPosition(position) then
        return nil
    end
    local tile = Tile(position)
    if tile and tile:getItemById(hazard.itemId) then
        return nil
    end
    local item = Game.createItem(hazard.itemId, 1, position)
    if item then
        item:setActionId(hazard.actionId)
        position:sendMagicEffect(CONST_ME_ENERGYAREA)
    end
    return item
end

local function startHazards(roomKey, state, room)
    local hazards = room.hazards
    if not hazards or not hazards.enabled then
        return
    end
    local token = state.token

    local function curseTick(current, currentRoom)
        local players = roomPlayers(currentRoom)
        if #players > 0 then
            local cursed = current.cursedPlayerId and Player(current.cursedPlayerId)
            if not cursed or not isInside(cursed:getPosition(), currentRoom.area) then
                cursed = players[math.random(#players)]
                current.cursedPlayerId = cursed:getId()
                current.curseStacks = 0
                cursed:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Phosphorus has marked you. Find the shimmering field!")
            end
            current.curseStacks = (current.curseStacks or 0) + 1
            local damage = current.curseStacks * hazards.curseDamagePerStack
            doTargetCombatHealth(0, cursed, hazards.curseCombatType, -damage, -damage, CONST_ME_MORTAREA)
            cursed:sendTextMessage(MESSAGE_STATUS_WARNING, "Agony charge " .. current.curseStacks .. ": " .. damage .. " damage.")
        end
        schedule(roomKey, token, curseTick, hazards.curseEverySeconds * 1000)
    end
    schedule(roomKey, token, curseTick, hazards.curseEverySeconds * 1000)

    local function riftTick(current, currentRoom)
        spawnHazardItem(currentRoom.hazards.rift)
        schedule(roomKey, token, riftTick, currentRoom.hazards.rift.spawnEverySeconds * 1000)
    end
    if hazards.rift then
        schedule(roomKey, token, riftTick, hazards.rift.spawnEverySeconds * 1000)
    end

    local function cloudTick(current, currentRoom)
        local item = spawnHazardItem(currentRoom.hazards.cloud)
        if item then
            local itemId = item:getId()
            local position = item:getPosition()
            addEvent(function()
                local tile = Tile(position)
                local cloud = tile and tile:getItemById(itemId)
                if cloud and cloud:getActionId() == currentRoom.hazards.cloud.actionId then
                    cloud:remove()
                end
            end, currentRoom.hazards.cloud.durationSeconds * 1000)
        end
        schedule(roomKey, token, cloudTick, currentRoom.hazards.cloud.spawnEverySeconds * 1000)
    end
    if hazards.cloud then
        schedule(roomKey, token, cloudTick, hazards.cloud.spawnEverySeconds * 1000)
    end
end

local function startMimar(state, room)
    state.charges = { left = 0, right = 0 }
    state.cannonPositions = {}
    state.charging = true
    setInvulnerable(state, true)
    resetMimarCannons(state, room)
    local token = state.token

    local function spawnMinerWave(current, currentRoom)
        if current.charging and current.bossId and Monster(current.bossId) then
            local spawned = 0
            local candidates = randomWalkablePositions(currentRoom.miners.spawnArea, 10000)
            for _, position in ipairs(candidates) do
                local tile = Tile(position)
                local reserved = position == currentRoom.boss.position
                for _, cannon in pairs(currentRoom.cannons) do
                    if position == cannon.position then
                        reserved = true
                        break
                    end
                end
                if not reserved and tile and not tile:getTopCreature()
                    and spawnMonster("mimar", currentRoom.miners.name, position, "miner") then
                    spawned = spawned + 1
                    if spawned >= currentRoom.miners.waveSize then
                        break
                    end
                end
            end
            if spawned > 0 then
                broadcast(currentRoom, "A wave of " .. spawned .. " Moonstone Miners enters the room.")
            end
            if spawned < currentRoom.miners.waveSize then
                print(string.format("[Phosphorus challenge] Moonstone Miner wave spawned %d/%d monsters.",
                    spawned, currentRoom.miners.waveSize))
            end
        end
        schedule("mimar", token, spawnMinerWave, currentRoom.miners.spawnEverySeconds * 1000)
    end

    spawnMinerWave(state, room)
end

local function forEachLinePosition(line, callback)
    local deltaX = line.toPosition.x - line.fromPosition.x
    local deltaY = line.toPosition.y - line.fromPosition.y
    local length = math.max(math.abs(deltaX), math.abs(deltaY))
    local stepX = deltaX == 0 and 0 or (deltaX > 0 and 1 or -1)
    local stepY = deltaY == 0 and 0 or (deltaY > 0 and 1 or -1)

    for offset = 0, length do
        callback(Position(
            line.fromPosition.x + (stepX * offset),
            line.fromPosition.y + (stepY * offset),
            line.fromPosition.z
        ))
    end
end

local function isOnLine(position, line)
    if position.z ~= line.fromPosition.z then
        return false
    end
    local minimumX = math.min(line.fromPosition.x, line.toPosition.x)
    local maximumX = math.max(line.fromPosition.x, line.toPosition.x)
    local minimumY = math.min(line.fromPosition.y, line.toPosition.y)
    local maximumY = math.max(line.fromPosition.y, line.toPosition.y)
    return position.x >= minimumX and position.x <= maximumX
        and position.y >= minimumY and position.y <= maximumY
end

local function drawLine(line, effect)
    forEachLinePosition(line, function(position)
        position:sendMagicEffect(effect)
    end)
end

local function damageLine(line)
    forEachLinePosition(line, function(position)
        position:sendMagicEffect(line.effect)
        local tile = Tile(position)
        local creature = tile and tile:getTopCreature()
        local player = creature and creature:getPlayer()
        if player then
            doTargetCombatHealth(0, player, line.combatType, line.minDamage, line.maxDamage, CONST_ME_NONE)
        end
    end)
end

randomWalkablePositions = function(area, count)
    local candidates = {}
    for x = area.from.x, area.to.x do
        for y = area.from.y, area.to.y do
            local position = Position(x, y, area.from.z)
            local tile = Tile(position)
            if tile and not tile:hasFlag(TILESTATE_BLOCKSOLID) and not tile:hasFlag(TILESTATE_BLOCKPATH) then
                candidates[#candidates + 1] = position
            end
        end
    end

    local selected = {}
    local selectionCount = math.min(count, #candidates)
    for index = 1, selectionCount do
        local randomIndex = math.random(index, #candidates)
        candidates[index], candidates[randomIndex] = candidates[randomIndex], candidates[index]
        selected[index] = candidates[index]
    end
    return selected
end

local function damageRandomTiles(positions, settings)
    for _, position in ipairs(positions) do
        local damage = settings.damagePool[math.random(#settings.damagePool)]
        position:sendMagicEffect(damage.effect)

        local tile = Tile(position)
        for _, creature in ipairs(tile and tile:getCreatures() or {}) do
            local player = creature:getPlayer()
            if player then
                doTargetCombatHealth(0, player, damage.combatType,
                    settings.minDamage, settings.maxDamage, CONST_ME_NONE)
            end
        end
    end
end

local function startDomus(state, room)
    setInvulnerable(state, true, room.invulnerableBossEffect)
    local token = state.token

    local function damageTick(current, currentRoom)
        for _, line in ipairs(currentRoom.lines) do
            damageLine(line)
        end
        schedule("domus", token, damageTick, currentRoom.damageEverySeconds * 1000)
    end
    schedule("domus", token, damageTick, room.damageEverySeconds * 1000)

    local function toggleTick(current, currentRoom)
        local line = currentRoom.lines[math.random(#currentRoom.lines)]
        drawLine(line, currentRoom.toggleLineEffect)

        local boss = current.bossId and Monster(current.bossId)
        if boss and isOnLine(boss:getPosition(), line) then
            if current.invulnerable then
                setInvulnerable(current, false, currentRoom.vulnerableBossEffect)
                broadcast(currentRoom, boss:getName() .. " is vulnerable!")
            else
                setInvulnerable(current, true, currentRoom.invulnerableBossEffect)
                broadcast(currentRoom, boss:getName() .. " is invulnerable!")
            end
        end
        schedule("domus", token, toggleTick, currentRoom.toggleEverySeconds * 1000)
    end
    schedule("domus", token, toggleTick, room.toggleEverySeconds * 1000)

    local function randomTileTick(current, currentRoom)
        local settings = currentRoom.randomTileDamage
        local positions = randomWalkablePositions(currentRoom.area, settings.tileCount)
        for _, position in ipairs(positions) do
            position:sendMagicEffect(settings.warningEffect)
        end

        schedule("domus", token, function(_, impactRoom)
            damageRandomTiles(positions, impactRoom.randomTileDamage)
        end, settings.warningSeconds * 1000)
        schedule("domus", token, randomTileTick, settings.everySeconds * 1000)
    end
    schedule("domus", token, randomTileTick, room.randomTileDamage.everySeconds * 1000)
end

local function spawnArcaneTraps(state, room)
    local settings = room.arcaneTraps
    local positions = randomWalkablePositions(settings.area, 10000)
    local spawned = 0
    for _, position in ipairs(positions) do
        local tile = Tile(position)
        if tile and not tile:getTopCreature() and not tile:getItemById(settings.itemId) then
            local item = Game.createItem(settings.itemId, 1, position)
            if item then
                spawned = spawned + 1
                item:setActionId(settings.actionId)
                addEvent(function()
                    local currentTile = Tile(position)
                    local currentItem = currentTile and currentTile:getItemById(settings.itemId)
                    if currentItem and currentItem:getActionId() == settings.actionId then
                        currentItem:remove()
                    end
                end, settings.durationSeconds * 1000)
            end
        end
        if spawned >= settings.count then
            break
        end
    end
end

local function spawnStorms(state, room)
    local settings = room.storms
    local players = roomPlayers(room)
    local candidates = randomWalkablePositions(room.area, 10000)
    local distant = {}
    local fallback = {}

    for _, position in ipairs(candidates) do
        local tile = Tile(position)
        if tile and not tile:getTopCreature() then
            fallback[#fallback + 1] = position
            local farEnough = true
            for _, player in ipairs(players) do
                if position:getDistance(player:getPosition()) < settings.minimumPlayerDistance then
                    farEnough = false
                    break
                end
            end
            if farEnough then
                distant[#distant + 1] = position
            end
        end
    end

    local positions = #distant >= settings.count and distant or fallback
    for index = 1, math.min(settings.count, #positions) do
        spawnMonster("phosphorus", settings.name, positions[index], "storm")
    end
end

local fearDirections = {
    { direction = NORTH, offsetX = 0, offsetY = -1 },
    { direction = EAST, offsetX = 1, offsetY = 0 },
    { direction = SOUTH, offsetX = 0, offsetY = 1 },
    { direction = WEST, offsetX = -1, offsetY = 0 }
}

local function fearStep(playerId, token, room, settings, remainingMilliseconds)
    local state = states.phosphorus
    local player = Player(playerId)
    if not state or not state.active or state.token ~= token or not player
        or not isInside(player:getPosition(), room.area) or remainingMilliseconds <= 0 then
        return
    end

    local position = player:getPosition()
    local validDirections = {}
    for _, direction in ipairs(fearDirections) do
        local destination = Position(
            position.x + direction.offsetX,
            position.y + direction.offsetY,
            position.z
        )
        local tile = Tile(destination)
        if tile and not tile:hasFlag(TILESTATE_PROTECTIONZONE)
            and queryTileAddThing(playerId, destination) == RETURNVALUE_NOERROR then
            validDirections[#validDirections + 1] = direction.direction
        end
    end

    if #validDirections > 0 then
        doMoveCreature(playerId, validDirections[math.random(#validDirections)])
    end
    player:getPosition():sendMagicEffect(settings.effect)

    local remaining = remainingMilliseconds - settings.stepIntervalMilliseconds
    if remaining > 0 then
        addEvent(function()
            fearStep(playerId, token, room, settings, remaining)
        end, settings.stepIntervalMilliseconds)
    end
end

local function castPhosphorusFear(state, room)
    local settings = room.fear
    local boss = state.bossId and Monster(state.bossId)
    if not boss then
        return
    end

    for _, player in ipairs(roomPlayers(room)) do
        if boss:getPosition():getDistance(player:getPosition()) <= settings.range then
            local muted = Condition(CONDITION_MUTED)
            muted:setParameter(CONDITION_PARAM_TICKS, settings.durationSeconds * 1000)
            player:addCondition(muted)
            fearStep(player:getId(), state.token, room, settings, settings.durationSeconds * 1000)
        end
    end
end

local function startPhosphorus(state, room)
    state.failedRivals = 0
    beginPhosphorusForm(state, room, Monster(state.bossId))
    local token = state.token

    local function rivalTick(current, currentRoom)
        spawnPhosphorusRival(current, currentRoom)
        schedule("phosphorus", token, rivalTick, currentRoom.rivalSpawnEverySeconds * 1000)
    end
    schedule("phosphorus", token, rivalTick, room.rivalSpawnEverySeconds * 1000)

    local function trapTick(current, currentRoom)
        spawnArcaneTraps(current, currentRoom)
        schedule("phosphorus", token, trapTick, currentRoom.arcaneTraps.spawnEverySeconds * 1000)
    end
    schedule("phosphorus", token, trapTick, room.arcaneTraps.spawnEverySeconds * 1000)

    local function fearTick(current, currentRoom)
        castPhosphorusFear(current, currentRoom)
        schedule("phosphorus", token, fearTick, currentRoom.fear.castEverySeconds * 1000)
    end
    schedule("phosphorus", token, fearTick, room.fear.castEverySeconds * 1000)

    schedule("phosphorus", token, spawnStorms, room.storms.spawnAfterSeconds * 1000)
    startHazards("phosphorus", state, room)
end

local function startRoomMechanics(roomKey, state, room)
    if roomKey == "mimar" then
        startMimar(state, room)
    elseif roomKey == "domus" then
        startDomus(state, room)
    elseif roomKey == "phosphorus" then
        startPhosphorus(state, room)
    end
end

local function participantList(player, room)
    local participants = {}
    local leaderIsFirst = false
    for index, position in ipairs(room.participants) do
        local tile = Tile(position)
        local creature = tile and tile:getTopVisibleCreature(player)
        local participant = creature and creature:getPlayer()
        if participant then
            if index == 1 and participant:getId() ~= player:getId() then
                return nil, "Only the first participant can pull the lever."
            end
            if index == 1 and participant:getId() == player:getId() then
                leaderIsFirst = true
            end
            participants[#participants + 1] = participant
        end
    end
    if not leaderIsFirst then
        return nil, "Stand on the first participant tile to pull the lever."
    end
    if #participants == 0 then
        return nil, "No participants are standing on the entry tiles."
    end
    if #participants > config.maximumPlayers then
        return nil, "This encounter allows at most " .. config.maximumPlayers .. " players."
    end
    return participants
end

local roomOrder = { "mimar", "domus", "phosphorus" }

local function cleanupRun(teleportPlayers, message)
    for _, roomKey in ipairs(roomOrder) do
        cleanupRoom(roomKey, teleportPlayers, message)
    end
    activeRun = nil
end

local function startEncounter(roomKey, participants)
    local room = config.rooms[roomKey]
    cleanupRoom(roomKey, false)
    nextToken = nextToken + 1
    local state = { active = true, token = nextToken, bossId = nil, invulnerable = false }
    states[roomKey] = state
    if activeRun then
        activeRun.currentRoom = roomKey
    end

    local boss = spawnMonster(roomKey, room.boss.name, room.boss.position, "boss")
    if not boss then
        states[roomKey] = nil
        return false, "Could not create boss: " .. room.boss.name
    end
    state.bossId = boss:getId()

    for _, participant in ipairs(participants) do
        participant:getPosition():sendMagicEffect(CONST_ME_POFF)
        participant:teleportTo(room.entrance, false)
        room.entrance:sendMagicEffect(CONST_ME_TELEPORT)
    end
    startRoomMechanics(roomKey, state, room)
    return true
end

local function startRun(player, lever)
    local room = config.rooms.mimar
    if not config.enabled then
        player:sendCancelMessage("The Phosphorus challenge rooms are not configured yet.")
        return true
    end
    if activeRun then
        player:sendCancelMessage("Another team is already progressing through the three Phosphorus challenge rooms.")
        return true
    end
    for _, roomKey in ipairs(roomOrder) do
        local inspectedRoom = config.rooms[roomKey]
        if not isConfiguredPosition(inspectedRoom.area.from) or not isConfiguredPosition(inspectedRoom.area.to)
            or not isConfiguredPosition(inspectedRoom.entrance) or not isConfiguredPosition(inspectedRoom.exit)
            or not isConfiguredPosition(inspectedRoom.completionPortal.position)
            or not isConfiguredPosition(inspectedRoom.completionPortal.destination) then
            player:sendCancelMessage("Room " .. roomKey .. " still has zero positions in its config.")
            return true
        end
        if #roomPlayers(inspectedRoom) > 0 then
            player:sendCancelMessage("A player is still inside the " .. roomKey .. " room.")
            return true
        end
    end

    local participants, reason = participantList(player, room)
    if not participants then
        player:sendCancelMessage(reason)
        return true
    end
    for _, participant in ipairs(participants) do
        if participant:getLevel() < config.minimumLevel then
            player:sendCancelMessage(participant:getName() .. " does not meet the level requirement.")
            return true
        end
        if participant:getStorageValue(config.entryCooldownStorage) > os.time() then
            player:sendCancelMessage(participant:getName() .. " is still on Phosphorus challenge cooldown.")
            return true
        end
    end

    for _, roomKey in ipairs(roomOrder) do
        cleanupRoom(roomKey, false)
    end
    nextToken = nextToken + 1
    local runToken = nextToken
    local playerIds = {}
    for _, participant in ipairs(participants) do
        playerIds[#playerIds + 1] = participant:getId()
    end
    activeRun = { token = runToken, playerIds = playerIds, currentRoom = "mimar" }

    local started, startError = startEncounter("mimar", participants)
    if not started then
        activeRun = nil
        player:sendCancelMessage(startError)
        return true
    end
    for _, participant in ipairs(participants) do
        participant:setStorageValue(config.entryCooldownStorage, os.time() + config.cooldownSeconds)
    end
    if lever and config.leverIds then
        lever:transform(lever:getId() == config.leverIds[1] and config.leverIds[2] or config.leverIds[1])
    end
    addEvent(function()
        if activeRun and activeRun.token == runToken then
            cleanupRun(true, "The Phosphorus challenge run time expired.")
        end
    end, config.runTimeSeconds * 1000)
    return true
end

local healthEvent = CreatureEvent("MakeBelieveHealth")
function healthEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    local role = creatureRoles[creature:getId()]
    local state = role and states[role.room]
    if state and role.role == "boss" and state.invulnerable
        and primaryType ~= COMBAT_HEALING and secondaryType ~= COMBAT_HEALING then
        return 0, primaryType, 0, secondaryType
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end
healthEvent:register()

local deathEvent = CreatureEvent("MakeBelieveDeath")
function deathEvent.onDeath(creature, corpse, killer, mostDamageKiller)
    local creatureId = creature:getId()
    local role = creatureRoles[creatureId]
    removeRole(creatureId)
    if not role then
        return true
    end
    local state = states[role.room]
    local room = config.rooms[role.room]
    if not state or not state.active then
        return true
    end

    if role.role == "boss" then
        if MakeBelieveGrantBossRewards then
            MakeBelieveGrantBossRewards(role.room, roomPlayers(room))
        end
        completeRoom(role.room)
        return true
    end

    if role.room == "phosphorus" and role.role == "rival" then
        local rival = role.rivalIndex and room.rivals[role.rivalIndex]
        if rival and creature:getPosition():getDistance(rival.pedestal.position) <= rival.pedestal.radius then
            state.convertedRivals = math.min(room.requiredRivalKills, (state.convertedRivals or 0) + 1)
            phosphorusBossSay(state, "YOU CONVERTED THE ENERGY!")
            broadcast(room, string.format("Rivals killed %d/%d", state.convertedRivals, room.requiredRivalKills))
            if state.convertedRivals >= room.requiredRivalKills then
                startPhosphorusVulnerability(state, room)
            end
        else
            phosphorusBossSay(state, "YOU FAILED TO CONVERT THE POWER, I WILL BECOME MORE STRONGER!")
            addPhosphorusFailureStack(state, room)
        end
    end
    return true
end
deathEvent:register()

local cannonActions = {}
local cannonItems = {}
for side, cannon in pairs(config.rooms.mimar.cannons) do
    cannonActions[cannon.actionId] = side
    cannonItems[cannon.itemId] = side
    cannonItems[cannon.chargedItemId] = side
end

local function getCannonSide(item)
    if not item then
        return nil
    end
    return cannonActions[item:getActionId()] or cannonItems[item:getId()]
end

local function sayCannonCharge(state, player, position, charge, target)
    local text = string.format("%d/%d charged", charge, target)
    local boss = state.bossId and Monster(state.bossId)
    if boss then
        boss:say(text, TALKTYPE_MONSTER_SAY, false, nil, position)
    else
        player:say(text, TALKTYPE_MONSTER_SAY, false, nil, position)
    end
end

local function chargeCannon(player, item)
    local side = getCannonSide(item)
    local state = states.mimar
    local room = config.rooms.mimar
    if not side or not state or not state.active or not isInside(player:getPosition(), room.area) then
        return true
    end
    local cannon = room.cannons[side]
    if not state.charging then
        player:sendCancelMessage("Both energy cannons are already charged.")
        return true
    end
    if item:getId() == cannon.chargedItemId or state.charges[side] >= room.chargeTarget then
        player:sendCancelMessage("This energy cannon is already fully charged.")
        return true
    end
    if item:getId() ~= cannon.itemId then
        player:sendCancelMessage("This item is not the configured energy cannon.")
        return true
    end
    if not player:removeItem(room.crystalItemId, 1) then
        player:sendCancelMessage("You need a Moonsilver crystal.")
        return true
    end

    state.cannonPositions[side] = item:getPosition()
    state.charges[side] = math.min(room.chargeTarget, state.charges[side] + room.chargePerCrystal)
    sayCannonCharge(state, player, item:getPosition(), state.charges[side], room.chargeTarget)
    broadcast(room, string.format("Energy cannons: left %d/%d, right %d/%d.",
        state.charges.left, room.chargeTarget, state.charges.right, room.chargeTarget))

    if state.charges[side] >= room.chargeTarget then
        item:transform(cannon.chargedItemId)
        item:setActionId(cannon.actionId)
        item:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
    end

    if state.charges.left >= room.chargeTarget and state.charges.right >= room.chargeTarget then
        state.charging = false
        setInvulnerable(state, false)
        broadcast(room, "Both cannons are fully charged. Mimar Haffar is vulnerable for 60 seconds!")
        schedule("mimar", state.token, function(current, currentRoom)
            if current.bossId and Monster(current.bossId) then
                current.charges.left = 0
                current.charges.right = 0
                current.charging = true
                resetMimarCannons(current, currentRoom)
                setInvulnerable(current, true)
                broadcast(currentRoom, "Mimar Haffar restored the shield. Recharge both cannons.")
            end
        end, room.vulnerableSeconds * 1000)
    end
    return true
end

local cannonAction = Action()
function cannonAction.onUse(player, item)
    return chargeCannon(player, item)
end
for actionId in pairs(cannonActions) do
    cannonAction:aid(actionId)
end
cannonAction:register()

local crystalAction = Action()
function crystalAction.onUse(player, item, fromPosition, target)
    if not getCannonSide(target) then
        player:sendCancelMessage("Use the Moonsilver crystal on an energy cannon.")
        return true
    end
    return chargeCannon(player, target)
end
crystalAction:id(config.rooms.mimar.crystalItemId)
crystalAction:register()

local hazardActions = {}
for roomKey, room in pairs(config.rooms) do
    if room.arcaneTraps then
        hazardActions[room.arcaneTraps.actionId] = { room = roomKey, type = "arcaneTrap" }
    end
    if room.hazards then
        if room.hazards.shimmeringField then
            hazardActions[room.hazards.shimmeringField.actionId] = { room = roomKey, type = "field" }
        end
        if room.hazards.rift then
            hazardActions[room.hazards.rift.actionId] = { room = roomKey, type = "rift" }
        end
        if room.hazards.cloud then
            hazardActions[room.hazards.cloud.actionId] = { room = roomKey, type = "cloud" }
        end
    end
end

local hazardMovement = MoveEvent()
function hazardMovement.onStepIn(creature, item)
    local player = creature:getPlayer()
    local hazard = hazardActions[item:getActionId()]
    if not player or not hazard then
        return true
    end
    local state = states[hazard.room]
    local room = config.rooms[hazard.room]
    if not state or not state.active or not isInside(player:getPosition(), room.area) then
        return true
    end
    if hazard.type == "field" then
        if state.cursedPlayerId == player:getId() then
            state.cursedPlayerId = nil
            state.curseStacks = 0
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The shimmering field removed the curse.")
        end
    elseif hazard.type == "rift" then
        local percent = room.hazards.rift.lifeLossPercent
        local damage = math.max(1, math.floor(player:getHealth() * percent / 100))
        doTargetCombatHealth(0, player, COMBAT_DEATHDAMAGE, -damage, -damage, CONST_ME_MORTAREA)
        item:remove()
    elseif hazard.type == "cloud" then
        local condition = Condition(CONDITION_PARALYZE)
        condition:setParameter(CONDITION_PARAM_TICKS, room.hazards.cloud.rootSeconds * 1000)
        condition:setParameter(CONDITION_PARAM_SPEED, -1000)
        player:addCondition(condition)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    elseif hazard.type == "arcaneTrap" then
        local settings = room.arcaneTraps
        local playerId = player:getId()
        local token = state.token
        item:remove()
        addEvent(function()
            local current = states[hazard.room]
            local target = Player(playerId)
            if current and current.active and current.token == token and target then
                doTargetCombatHealth(0, target, settings.combatType,
                    settings.minDamage, settings.maxDamage, settings.effect)
            end
        end, settings.damageDelaySeconds * 1000)
    end
    return true
end
hazardMovement:type("stepin")
for actionId in pairs(hazardActions) do
    hazardMovement:aid(actionId)
end
hazardMovement:register()

local transitionRooms = {}
for _, roomKey in ipairs(roomOrder) do
    transitionRooms[config.rooms[roomKey].completionPortal.actionId] = roomKey
end

local function isRunParticipant(playerId)
    if not activeRun then
        return false
    end
    for _, participantId in ipairs(activeRun.playerIds) do
        if participantId == playerId then
            return true
        end
    end
    return false
end

local function currentRunPlayers(triggerPlayer)
    local players = {}
    for _, playerId in ipairs(activeRun.playerIds) do
        local player = Player(playerId)
        if player then
            local inRunRoom = player:getId() == triggerPlayer:getId()
            if not inRunRoom then
                for _, roomKey in ipairs(roomOrder) do
                    if isInside(player:getPosition(), config.rooms[roomKey].area) then
                        inRunRoom = true
                        break
                    end
                end
            end
            if inRunRoom then
                players[#players + 1] = player
            end
        end
    end
    return players
end

local transitionMovement = MoveEvent()
function transitionMovement.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    local sourceRoomKey = transitionRooms[item:getActionId()]
    if not player or not sourceRoomKey or not activeRun then
        return true
    end
    if activeRun.currentRoom ~= sourceRoomKey or not isRunParticipant(player:getId()) then
        player:teleportTo(fromPosition, true)
        player:sendCancelMessage("This portal belongs to another Phosphorus challenge run.")
        return true
    end

    local participants = currentRunPlayers(player)
    cleanupRoom(sourceRoomKey, false)

    local sourceRoom = config.rooms[sourceRoomKey]
    if sourceRoomKey == "phosphorus" then
        for _, participant in ipairs(participants) do
            participant:setStorageValue(config.progressStorage, 3)
            participant:setStorageValue(config.completionStorage, 1)
            participant:teleportTo(sourceRoom.completionPortal.destination, false)
            sourceRoom.completionPortal.destination:sendMagicEffect(CONST_ME_TELEPORT)
            participant:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You completed the Phosphorus challenge.")
        end
        cleanupRun(false)
        return true
    end

    local nextRoomKey = roomOrder[config.rooms[sourceRoomKey].order + 1]
    local started, startError = startEncounter(nextRoomKey, participants)
    if not started then
        for _, participant in ipairs(participants) do
            participant:teleportTo(sourceRoom.exit, false)
            participant:sendTextMessage(MESSAGE_STATUS_WARNING, startError)
        end
        cleanupRun(false)
    end
    return true
end
transitionMovement:type("stepin")
for actionId in pairs(transitionRooms) do
    transitionMovement:aid(actionId)
end
transitionMovement:register()

local entryLever = Action()
function entryLever.onUse(player, item)
    return startRun(player, item)
end
entryLever:aid(config.entryLeverActionId)
entryLever:register()
