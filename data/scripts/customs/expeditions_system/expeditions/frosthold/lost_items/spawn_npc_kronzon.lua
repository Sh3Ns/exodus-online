local npcPosition = Position(30786, 31205, 7)
local npcDuration = 60 * 60 * 1000 -- 1 hour
local npcs = {}

local detectionRadius = 50

local function removeNpcAfterDuration(npcId)
    local npcUid = npcs[npcId]
    if not npcUid then return end

    local npc = Npc(npcUid)
    if npc then
        npc:remove()
    end

    npcs[npcId] = nil
end

local function spawnNpc(npcId, position)
    local existingUid = npcs[npcId]
    if existingUid then
        local existingNpc = Npc(existingUid)
        if existingNpc then
            return
        end
        npcs[npcId] = nil
    end

    local npc = Game.createNpc("Kronzon", position)
    if npc then
        npcs[npcId] = npc:getId()
        addEvent(removeNpcAfterDuration, npcDuration, npcId)
    end
end

local function announceToNearbyPlayers()
    local spectators = Game.getSpectators(
        npcPosition,
        false,
        true,
        detectionRadius, detectionRadius,
        detectionRadius, detectionRadius
    )

    for _, player in ipairs(spectators) do
        playSoundPlayer(player, "expedition.ogg")
        player:addMapMark(npcPosition, 22, "Expedition: Find Lost Items")
    end
end

local spawnTimes = {
    "07:45:00", "09:45:00", "11:45:00",
    "13:45:00", "15:45:00", "17:45:00",
    "19:45:00", "21:45:00", "23:45:00"
}

for i, time in ipairs(spawnTimes) do
    local kronzonEvent = GlobalEvent("KronzonExpedition" .. i)

    function kronzonEvent.onTime(interval)
        spawnNpc(i, npcPosition)
        Game.broadcastMessage("Kronzon has spawned on Frosthold Island.", MESSAGE_EVENT_ADVANCE)
        announceToNearbyPlayers()

        return true
    end

    kronzonEvent:time(time)
    kronzonEvent:register()
end