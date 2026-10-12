local npcPosition = Position(30890, 31209, 7)
local eventDuration = 60 * 60 * 1000
local npcs = {}

local detectionRadius = 50

local function removeNPC(npcId)
    if npcs[npcId] then
        local npc = Npc(npcs[npcId])
        if npc then
            npc:remove()
        end
        npcs[npcId] = nil
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

    local npc = Game.createNpc("Ziriak", position)
    if npc then
        npcs[npcId] = npc:getId()
        addEvent(removeNPC, eventDuration, npcId)
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
        player:addMapMark(npcPosition, 22, "Expedition: Frosted Monsters")
    end
end

local spawnTimes = {
    "06:30:00","09:15:00","11:15:00","13:15:00","15:15:00",
    "17:15:00","19:15:00","21:15:00","23:15:00","01:15:00",
    "03:15:00","05:15:00"
}

for i, time in ipairs(spawnTimes) do
    local ziriakEvent = GlobalEvent("ZiriakExpedition" .. i)

    function ziriakEvent.onTime(interval)
        spawnNPC(1, npcPosition)

        Game.broadcastMessage(
            "Ziriak has spawned at East of Frosthold.",
            MESSAGE_EVENT_ADVANCE
        )

        announceToNearbyPlayers()
        return true
    end

    ziriakEvent:time(time)
    ziriakEvent:register()
end