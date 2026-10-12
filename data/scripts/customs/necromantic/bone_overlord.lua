local config = {
    actionId = 42655,
    bossName = "Bone Overlord",
    bossPosition = Position(31737, 30924, 11),
    extraMonsters = {
    {name = "Elyrax's Spirit",      position = Position(31732, 30922, 11)},
    {name = "Myzareth's Spirit",    position = Position(31736, 30919, 11)},
    {name = "Scarith's Spirit",     position = Position(31740, 30923, 11)},
    {name = "Zharvorin's Spirit",   position = Position(31736, 30926, 11)},
    },
    soulcages = {
    {name = "Elyrax's Soulcage",    position = Position(31732, 30927, 11)},
    {name = "Myzareth's Soulcage",  position = Position(31739, 30927, 11)},
    {name = "Scarith's Soulcage",   position = Position(31739, 30918, 11)},
    {name = "Zharvorin's Soulcage", position = Position(31732, 30918, 11)},
    },
    phylactery = {
        name = "Bonelord's Phylactery",
        position = Position(31736, 30926, 11)
    },
    boneBarrier = {
        name = "Bone Barrier",
        position = Position(31748, 30939, 11),
        respawnInterval = 150, -- 150
    },
    playerBarrierPos = Position(31748, 30943, 11),
    teleportPlayersInterval = 180, -- 180
    soulcageDelay = 20, -- 20
    soulcageHealInterval = 300, -- 300
    soulcageHealMaxTimes = 2, 
    respawnInterval = 120, -- 120
    bossArea = {
        fromPos = Position(31721, 30912, 11),
        toPos = Position(31757, 30948, 11),
        entrancePos = Position(31735, 30932, 11),
        exitPosition = Position(31697, 31034, 7)
    },
    participantsAllowAnyCount = true, 
    participantsPos = {
        Position(31736, 30986, 11),
        Position(31736, 30987, 11),
        Position(31736, 30988, 11),
        Position(31736, 30989, 11),
    },
    attempts = {
        level = 100, -- 500
        storage = 720185,
        seconds = 2 -- 600
    },
    createTeleportPos = Position(31732, 30915, 11),
    teleportToPosition = Position(31697, 31034, 7),
    teleportRemoveSeconds = 60,
    kickParticipantAfterSeconds = 60 * 30,
    leverIds = {1945, 1946}
}

local soulcagesRemaining = 0
local soulcageHealCount = 0
local boneBarrierEventId = nil
local teleportPlayersEventId = nil

local function getSpectators()
    if not config.centerPosition then
        config.diffX = math.ceil((config.bossArea.toPos.x - config.bossArea.fromPos.x) / 2)
        config.diffY = math.ceil((config.bossArea.toPos.y - config.bossArea.fromPos.y) / 2)
        config.centerPosition = config.bossArea.fromPos + Position(config.diffX, config.diffY, 0)
    end
    return Game.getSpectators(config.centerPosition, false, false, config.diffX, config.diffX, config.diffY, config.diffY)
end

local function hasPlayersInArena()
    local spectators = getSpectators()
    for _, spec in pairs(spectators) do
        if spec:isPlayer() then
            return true
        end
    end
    return false
end

local function respawnLoop()
    if not hasPlayersInArena() then
        return
    end

    if config.extraMonsters then
        for _, m in pairs(config.extraMonsters) do
            local tile = Tile(m.position)
            local found = false

            if tile then
                for _, thing in pairs(tile:getCreatures() or {}) do
                    if thing:isMonster() and thing:getName() == m.name then
                        found = true
                        break
                    end
                end
            end

            if not found then
                local mon = Game.createMonster(m.name, m.position)
                if not mon then
                    print("Could not respawn " .. m.name)
                end
            end
        end
    end
    config.respawnEventId = addEvent(respawnLoop, config.respawnInterval * 1000)
end

local function healSoulcagesLoop()
    if soulcageHealCount >= config.soulcageHealMaxTimes then
        return
    end

    if not hasPlayersInArena() then
        return
    end

    local spectators = getSpectators()

    local healed = false

    for _, creature in pairs(spectators) do
        if creature:isMonster() then
            local name = creature:getName()

            for _, s in pairs(config.soulcages) do
                if name == s.name then
                    local maxHealth = creature:getMaxHealth()
                    creature:addHealth("arcane", maxHealth)
                    healed = true
                end
            end
        end
    end

    if healed then
        soulcageHealCount = soulcageHealCount + 1
        print("[Soulcage Heal] Refilled (x" .. soulcageHealCount .. ")")
    end

    config.healSoulcagesEventId = addEvent(healSoulcagesLoop, config.soulcageHealInterval * 1000)
end

local function spawnBoneBarrierLoop()
    if not hasPlayersInArena() then
        return
    end

    local tile = Tile(config.boneBarrier.position)
    local found = false

    if tile then
        for _, c in pairs(tile:getCreatures() or {}) do
            if c:isMonster() and c:getName() == config.boneBarrier.name then
                found = true
                break
            end
        end
    end

    if not found then
        Game.createMonster(config.boneBarrier.name, config.boneBarrier.position)
    end

    boneBarrierEventId = addEvent(spawnBoneBarrierLoop, config.boneBarrier.respawnInterval * 1000)
end

local function getPlayersInCombatRoom()
    local list = {}
    for x = 31724, 31747 do
        for y = 30912, 30934 do
            local tile = Tile(Position(x, y, 11))
            if tile then
                local creatures = tile:getCreatures() or {}
                for _, c in pairs(creatures) do
                    if c:isPlayer() then
                        table.insert(list, c)
                    end
                end
            end
        end
    end
    return list
end

local function teleportRandomPlayersLoop()
    if not hasPlayersInArena() then
        return
    end

    local players = getPlayersInCombatRoom()

    if #players == 0 then
        return
    end

    local amount = math.random(1, math.min(2, #players))

    for i = 1, amount do
        local index = math.random(#players)
        local chosen = table.remove(players, index)

        if chosen then
            chosen:getPosition():sendMagicEffect(CONST_ME_POFF)
            chosen:teleportTo(config.playerBarrierPos, false)
            config.playerBarrierPos:sendMagicEffect(CONST_ME_TELEPORT)
            chosen:sendTextMessage(MESSAGE_INFO_DESCR, "A powerful force drags you away!")
        end
    end

    teleportPlayersEventId = addEvent(teleportRandomPlayersLoop, config.teleportPlayersInterval * 1000)
end

local boneOverlord = Action()

function boneOverlord.onUse(player, item, fromPos, target, toPos, isHotkey)
    local participants = {}
    for index, pos in pairs(config.participantsPos) do
        local tile = Tile(pos)
        if not tile then error("[Warning - Tile not found]") end
        local participant = tile:getTopVisibleCreature(player)
        if participant and participant:isPlayer() then
            if index == 1 and participant ~= player then
                player:sendCancelMessage("Only the first participant can pull the lever.")
                return true
            end

            if participant:getStorageValue(config.attempts.storage) >= os.time() then
                local cooldown = (participant:getStorageValue(config.attempts.storage) - os.time()) / 60
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, (string.format("The player "..participant:getName().." must wait "..math.floor(cooldown).." minutes before being able to enter again.")))
                return true
            elseif participant:getLevel() < config.attempts.level then
                player:sendCancelMessage(string.format("The player %s is not level %d.", participant:getName(), config.attempts.level))
                return true
            end
            participants[#participants +1] = participant    
        end
    end

    local spectators = getSpectators()
    for _, spectator in pairs(spectators) do
        if spectator:isPlayer() then
            player:sendCancelMessage("At this time the room is occupied, please try again later.")
            return true
        end
    end

    for _, spectator in pairs(spectators) do spectator:remove() end
    local boss = Game.createMonster(config.bossName, config.bossPosition)
    if not boss then error(Game.getReturnMessage(RETURNVALUE_NOTENOUGHROOM)) end
    if config.extraMonsters then
        for _, m in pairs(config.extraMonsters) do
            local mon = Game.createMonster(m.name, m.position)
            if mon then
            else
                print("WARNING: Could not spawn monster: "..m.name)
            end
        end
    end
    if config.soulcages then
        addEvent(function()
            soulcagesRemaining = #config.soulcages
            for _, s in pairs(config.soulcages) do
                local mon = Game.createMonster(s.name, s.position)
                if mon then
                    mon:registerEvent("soulcageDeath")
                else
                    print("WARNING: Could not spawn soulcage: " .. s.name)
                end
            end
        end, config.soulcageDelay * 1000)
    end
    soulcageHealCount = 0
    config.healSoulcagesEventId = addEvent(healSoulcagesLoop, config.soulcageHealInterval * 1000)
    config.respawnEventId = addEvent(respawnLoop, config.respawnInterval * 1000)
    boneBarrierEventId = addEvent(spawnBoneBarrierLoop, config.boneBarrier.respawnInterval * 1000)
    teleportPlayersEventId = addEvent(teleportRandomPlayersLoop, config.teleportPlayersInterval * 1000)
    for index, participant in pairs(participants) do
        config.participantsPos[index]:sendMagicEffect(CONST_ME_POFF)
        participant:teleportTo(config.bossArea.entrancePos, false)
        config.bossArea.entrancePos:sendMagicEffect(CONST_ME_TELEPORT)
        participant:setStorageValue(config.attempts.storage, os.time() + config.attempts.seconds)
    end

    config.kickEventId = addEvent(function ()
        for _, spectator in pairs(getSpectators()) do
            if spectator:isPlayer() then
                playSound(player, "lever.ogg")
                spectator:getPosition():sendMagicEffect(CONST_ME_POFF)
                spectator:teleportTo(config.bossArea.exitPosition, false)
                config.bossArea.exitPosition:sendMagicEffect(CONST_ME_TELEPORT)
                spectator:sendTextMessage(MESSAGE_INFO_DESCR, "It's been a long time and you haven't managed to defeat the boss.")
            else
                spectator:remove()
            end
        end
    end, config.kickParticipantAfterSeconds * 1000)

    item:transform(item:getId() == config.leverIds[1] and config.leverIds[2] or config.leverIds[1])
    return true
end

boneOverlord:aid(config.actionId)
boneOverlord:register()

local creatureEvent = CreatureEvent("boneOverlordDeath")

function creatureEvent.onDeath()
    stopEvent(config.kickEventId)
    stopEvent(config.respawnEventId)
    stopEvent(config.healSoulcagesEventId)
    stopEvent(boneBarrierEventId)
    stopEvent(teleportPlayersEventId)

    local teleport = Game.createItem(1387, 1, config.createTeleportPos)
    if teleport then
        teleport:setDestination(config.teleportToPosition)
        addEvent(function ()
            local tile = Tile(config.createTeleportPos)
            if tile then
                local teleport = tile:getItemById(1387)
                if teleport then
                    teleport:remove()
                    config.teleportToPosition:sendMagicEffect(CONST_ME_POFF)
                end
            end

            for _, spectator in pairs(getSpectators()) do
                if spectator:isPlayer() then
                    spectator:getPosition():sendMagicEffect(CONST_ME_POFF)
                    spectator:teleportTo(config.teleportToPosition, false)
                    config.teleportToPosition:sendMagicEffect(CONST_ME_TELEPORT)
                end
            end
        end, config.teleportRemoveSeconds * 1000)
    end
    return true
end

creatureEvent:register()


local soulcageEvent = CreatureEvent("soulcageDeath")

function soulcageEvent.onDeath(creature)
    soulcagesRemaining = soulcagesRemaining - 1

    if soulcagesRemaining <= 0 then
        local phy = Game.createMonster(config.phylactery.name, config.phylactery.position)
        if phy then
            phy:registerEvent("boneOverlordDeath")
        else
            print("WARNING: Failed to spawn Bonelord's Phylactery.")
        end
    end

    return true
end

soulcageEvent:register()