local npcPosition = Position(30789, 31297, 7)

local itemsAreaFrom = Position(30749, 31185, 7)
local itemsAreaTo   = Position(30931, 31345, 7)

local eventDuration = 60 * 60 * 1000

local itemIdToSummon = 29345       -- normal crystal
local transformedItemId = 29346    -- transformed version
local maxItems = 25
local spawnedItems = {}
local newItemId = 29343
local newItemCount = 8

local npcs = {}

local function summonItemsInArea(fromPos, toPos)
    local spawnedNormal = 0
    local attempts = 0

    while spawnedNormal < maxItems and attempts < maxItems * 10 do
        attempts = attempts + 1

        local pos = Position(
            math.random(fromPos.x, toPos.x),
            math.random(fromPos.y, toPos.y),
            fromPos.z
        )

        local tile = Tile(pos)
        if tile then
            local tileInfo = getTileInfo(pos)
            local ground = tile:getGround()

            if ground and ground:getId() == 28919 and tileInfo.items == 0 and tileInfo.creatures == 0 then
                addEvent(function()
                    local item = Game.createItem(itemIdToSummon, 1, pos)
                    if item then
                        table.insert(spawnedItems, item:getId())
                    end
                end, 1000)
                spawnedNormal = spawnedNormal + 1
            end
        end
    end

    local newSpawned = 0
    local attempts2 = 0

    while newSpawned < newItemCount and attempts2 < newItemCount * 10 do
        attempts2 = attempts2 + 1

        local pos = Position(
            math.random(fromPos.x, toPos.x),
            math.random(fromPos.y, toPos.y),
            fromPos.z
        )

        local tile = Tile(pos)
        if tile then
            local tileInfo = getTileInfo(pos)
            if tileInfo.items == 0 and tileInfo.creatures == 0 then
                addEvent(Game.createItem, 1000, newItemId, 1, pos)
                newSpawned = newSpawned + 1
            end
        end
    end
end

local function cleanupExpedition(npcId)
    for _, itemId in ipairs(spawnedItems) do
        local item = Item(itemId)
        if item then
            item:remove()
        end
    end
    spawnedItems = {}

    if npcs[npcId] then
        local npc = Npc(npcs[npcId])
        if npc then
            npc:remove()
        end
        npcs[npcId] = nil
    end
end

local function notifyNearbyPlayers()
    local radius = 60

    local spectators = Game.getSpectators(
        npcPosition,
        false,
        true,
        radius, radius,
        radius, radius
    )

    for _, player in ipairs(spectators) do
        playSoundPlayer(player, "expedition.ogg")
        player:addMapMark(npcPosition, 22, "Expedition: Frosthold Crystals")
    end
end

local function spawnNPC(npcId, position)
    if npcs[npcId] then
        local existing = Npc(npcs[npcId])
        if existing then
            return
        end
        npcs[npcId] = nil
    end

    local npc = Game.createNpc("Kiatke", position)
    if npc then
        npcs[npcId] = npc:getId()
    end
end


local spawnTimes = {
    "12:00:00",
    "13:30:00",
    "16:00:00",
    "19:00:00",
    "23:00:00",
    "02:00:00",
    "05:00:00",
}

for i, time in ipairs(spawnTimes) do
    local event = GlobalEvent("KiatkeExpedition" .. i)

    function event.onTime()
        spawnNPC(1, npcPosition)

        summonItemsInArea(itemsAreaFrom, itemsAreaTo)
        addEvent(cleanupExpedition, eventDuration, 1)

        notifyNearbyPlayers()
        Game.broadcastMessage("Kiatke has spawned at South of Frosthold Island.", MESSAGE_EVENT_ADVANCE)

        return true
    end

    event:time(time)
    event:register()
end