local npcPosition = Position(31167, 31239, 7)

local areaFromPos = Position(31109, 31199, 7)
local areaToPos   = Position(31279, 31268, 7)

local itemsFromPos = Position(31149, 31238, 7)
local itemsToPos   = Position(31261, 31263, 7)

local monsterGroups = {
    {monsterTypes = {"Thief Goblin"}, maxCount = 35},
}

local spawnInterval = 120 * 1000
local eventDuration = 60 * 60 * 1000

local itemIdToSummon = 29338
local transformedItemId = 29337
local newItemId = 29343
local maxItems = 12
local newItemCount = 8

local npcs = {}
local spawnedMonsters = {}
local spawnedItems = {}
local expeditionActive = false

local function removeNpc(npcId)
    if npcs[npcId] then
        local npc = Npc(npcs[npcId])
        if npc then npc:remove() end
        npcs[npcId] = nil
    end
end

local function spawnNpc(npcId, position)
    if npcs[npcId] then
        local existing = Npc(npcs[npcId])
        if existing then return end
        npcs[npcId] = nil
    end

    local npc = Game.createNpc("Hotharn", position)
    if npc then
        npcs[npcId] = npc:getId()
    end
end

local function spawnItem(itemId, pos)
    local item = Game.createItem(itemId, 1, pos)
    if item then
        table.insert(spawnedItems, item:getId())
    end
end

local function summonItems()
    local count = 0
    local attempts = 0

    while count < maxItems and attempts < maxItems * 10 do
        attempts = attempts + 1
        local pos = Position(
            math.random(itemsFromPos.x, itemsToPos.x),
            math.random(itemsFromPos.y, itemsToPos.y),
            itemsFromPos.z
        )

        local tile = Tile(pos)
        if tile then
            local info = getTileInfo(pos)
            if info.items == 0 and info.creatures == 0 then
                addEvent(spawnItem, 1000, itemIdToSummon, pos)
                count = count + 1
            end
        end
    end

    for i = 1, newItemCount do
        local pos = Position(
            math.random(itemsFromPos.x, itemsToPos.x),
            math.random(itemsFromPos.y, itemsToPos.y),
            itemsFromPos.z
        )
        local tile = Tile(pos)
        if tile then
            local info = getTileInfo(pos)
            if info.items == 0 and info.creatures == 0 then
                addEvent(spawnItem, 1000, newItemId, pos)
            end
        end
    end
end

local function spawnMonsters()
    for _, group in ipairs(monsterGroups) do
        for i = 1, group.maxCount do
            local pos = Position(
                math.random(areaFromPos.x, areaToPos.x),
                math.random(areaFromPos.y, areaToPos.y),
                areaFromPos.z
            )
            local monster = Game.createMonster(group.monsterTypes[1], pos)
            if monster then
                table.insert(spawnedMonsters, monster:getId())
            end
        end
    end
end

local function cleanup()
    expeditionActive = false

    for _, id in ipairs(spawnedMonsters) do
        local monster = Monster(id)
        if monster then monster:remove() end
    end
    spawnedMonsters = {}

    for _, id in ipairs(spawnedItems) do
        local item = Item(id)
        if item then item:remove() end
    end
    spawnedItems = {}

    removeNpc(1)
end

local function onThink()
    if not expeditionActive then return end
    spawnMonsters()
    addEvent(onThink, spawnInterval)
end

local function notifyPlayers()
    local spectators = Game.getSpectators(npcPosition, false, true, 60, 60, 60, 60)
    for _, player in ipairs(spectators) do
        playSoundPlayer(player, "expedition.ogg")
        player:addMapMark(npcPosition, 22, "Expedition: Eagle Eggs")
    end
end

local spawnTimes = {
    "10:00:00","12:00:00","14:00:00","16:00:00","19:00:00",
    "21:00:00","23:00:00","01:00:00","03:00:00","05:00:00"
}

for i, time in ipairs(spawnTimes) do
    local event = GlobalEvent("SummonEagleNests" .. i)

    function event.onTime()
        if expeditionActive then return true end
        expeditionActive = true

        spawnNpc(1, npcPosition)
        summonItems()
        spawnMonsters()

        addEvent(onThink, spawnInterval)
        addEvent(cleanup, eventDuration)

        notifyPlayers()
        Game.broadcastMessage(
            "Hotharn Has Spawned in the middle of Vyrsk Island.",
            MESSAGE_EVENT_ADVANCE
        )
        return true
    end

    event:time(time)
    event:register()
end