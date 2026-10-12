local npcPosition = Position(31257, 31286, 7)
local npcDuration = 60 * 60 * 1000

local areaFromPos = Position(31202, 31201, 7)
local areaToPos   = Position(31275, 31307, 7)

local monsterType = "Island Eagle"
local maxMonsters = 35

local npcs = {}
local spawnedMonsters = {}
local expeditionActive = false

local function randomPosition(fromPos, toPos)
    return Position(
        math.random(fromPos.x, toPos.x),
        math.random(fromPos.y, toPos.y),
        fromPos.z
    )
end

local function removeExpedition(npcId)
    expeditionActive = false

    for _, cid in ipairs(spawnedMonsters) do
        local m = Monster(cid)
        if m then
            m:remove()
        end
    end
    spawnedMonsters = {}

    if npcs[npcId] then
        local npc = Npc(npcs[npcId])
        if npc then
            npc:remove()
        end
        npcs[npcId] = nil
    end
end

local function spawnExpedition(npcId)
    if expeditionActive then
        return
    end
    expeditionActive = true

    if npcs[npcId] then
        local existing = Npc(npcs[npcId])
        if existing then
            return
        end
        npcs[npcId] = nil
    end

    local npc = Game.createNpc("Rakka", npcPosition)
    if npc then
        npcs[npcId] = npc:getId()
    end

    for i = 1, maxMonsters do
        local pos = randomPosition(areaFromPos, areaToPos)
        local m = Game.createMonster(monsterType, pos, true, true)
        if m then
            table.insert(spawnedMonsters, m:getId())
        end
    end

    addEvent(removeExpedition, npcDuration, npcId)
end

local function notifyPlayers()
    local spectators = Game.getSpectators(npcPosition, false, true, 60, 60, 60, 60)
    for _, player in ipairs(spectators) do
        playSoundPlayer(player, "expedition.ogg")
        player:addMapMark(npcPosition, 22, "Expedition: Island Eagles")
    end
end

local spawnTimes = {
    "09:00:00",
    "11:00:00",
    "13:00:00",
    "15:00:00",
    "18:00:00",
    "20:00:00"
}

for i, time in ipairs(spawnTimes) do
    local rakkaExpedition = GlobalEvent("RakkaEagleExpedition" .. i)

    function rakkaExpedition.onTime(interval)
        spawnExpedition(1)
        notifyPlayers()
        Game.broadcastMessage("Rakka has spawned on Vyrsk Island.", MESSAGE_EVENT_ADVANCE)
        return true
    end

    rakkaExpedition:time(time)
    rakkaExpedition:register()
end