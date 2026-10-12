local npcPosition = Position(30843, 31287, 7)

local monsterGroups = {
    {monsterTypes = {"Small Lursk Spider"}, maxCount = 20},
    {monsterTypes = {"Giant Lursk Spider"}, maxCount = 20}
}

local spawnInterval  = 120 * 1000
local eventDuration  = 60 * 60 * 1000
local MAX_MONSTERS   = 200

local expeditionActive = false
local npcs            = {}
local spawnedMonsters = {}

local function isWalkable(pos)
    local tile = Tile(pos)
    if not tile then
        return false
    end

    if tile:hasFlag(TILESTATE_BLOCKSOLID) or tile:hasFlag(TILESTATE_BLOCKPATH) then
        return false
    end

    if not tile:getGround() then
        return false
    end

    local top = tile:getTopCreature()
    if top and (top:isPlayer() or top:isMonster()) then
        return false
    end

    return true
end

local function cleanupDeadMonsters()
    local alive = {}
    for _, id in ipairs(spawnedMonsters) do
        local m = Monster(id)
        if m then
            table.insert(alive, id)
        end
    end
    spawnedMonsters = alive
end

local function getAliveMonsterCount()
    cleanupDeadMonsters()
    return #spawnedMonsters
end

local function spawnGroup(monsterTypes, maxCount, center, remaining)
    local spawned = 0

    for i = 1, maxCount do
        if remaining <= 0 then
            break
        end

        local pos
        for _ = 1, 10 do
            local tryPos = Position(
                center.x + math.random(-10, 10),
                center.y + math.random(-10, 10),
                center.z
            )
            if isWalkable(tryPos) then
                pos = tryPos
                break
            end
        end

        if pos then
            local name = monsterTypes[math.random(#monsterTypes)]
            local monster = Game.createMonster(name, pos, true, true)
            if monster then
                table.insert(spawnedMonsters, monster:getId())
                spawned  = spawned + 1
                remaining = remaining - 1
            end
        end
    end

    return spawned
end

local function summonAllMonstersInArea(monsterGroups)
    if not expeditionActive then
        return
    end

    local current   = getAliveMonsterCount()
    local remaining = MAX_MONSTERS - current
    if remaining <= 0 then
        return
    end

    for _, group in ipairs(monsterGroups) do
        if remaining <= 0 then
            break
        end
        local spawned = spawnGroup(group.monsterTypes, group.maxCount, npcPosition, remaining)
        remaining = remaining - spawned
    end
end

local function removeMonstersAndNPC(npcId)
    for _, monsterId in ipairs(spawnedMonsters) do
        local monster = Monster(monsterId)
        if monster then
            monster:remove()
        end
    end
    spawnedMonsters = {}

    local npc_id = npcs[npcId]
    if npc_id then
        local npc = Npc(npc_id)
        if npc then
            npc:remove()
        end
        npcs[npcId] = nil
    end

    expeditionActive = false
end

local function onThinkEvent(npcId, monsterGroups)
    if not expeditionActive then
        return
    end

    local npc_id = npcs[npcId]
    if npc_id and Npc(npc_id) then
        summonAllMonstersInArea(monsterGroups)
        addEvent(onThinkEvent, spawnInterval, npcId, monsterGroups)
    end
end

local spawnTimes = {
    "10:40:00",
    "12:40:00",
    "14:40:00",
    "17:30:00",
    "20:30:00",
    "22:00:00",
    "23:30:00",
    "02:30:00"
}

for i, time in ipairs(spawnTimes) do
    local yordaExpedition = GlobalEvent("YordaExpedition" .. i)

    function yordaExpedition.onTime(interval)
        if expeditionActive then
            return true
        end

        expeditionActive = true
        local npc = Game.createNpc("Yorda", npcPosition)
        if npc then
            npcs[1] = npc:getId()
        else
            expeditionActive = false
            return true
        end

        summonAllMonstersInArea(monsterGroups)
        addEvent(onThinkEvent, spawnInterval, 1, monsterGroups)
        addEvent(removeMonstersAndNPC, eventDuration, 1)

        for _, player in ipairs(Game.getPlayers()) do
            playSoundPlayer(player, "expedition.ogg")
            player:addMapMark(npcPosition, 22, "Expedition: Lursks Spiders")
        end

        Game.broadcastMessage(
            "Yorda Has Spawned at East of Frosthold.",
            MESSAGE_EVENT_ADVANCE
        )
        return true
    end

    yordaExpedition:time(time)
    yordaExpedition:register()
end
