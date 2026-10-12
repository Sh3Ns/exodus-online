local npc1Position = Position(30947, 31028, 6)
local npcDuration = 1 * 60 * 60 * 1000
local npcs = {}

local function removeNpcAfterDuration(npcId)
    if npcs[npcId] then
        local npc = Npc(npcs[npcId])
        if npc then
            npc:remove()
        end
        npcs[npcId] = nil
    end
end

local function spawnNpc(npcId, position)
    if npcs[npcId] then
        local existing = Npc(npcs[npcId])
        if existing then
            return
        end
        npcs[npcId] = nil
    end

    local npc = Game.createNpc("Shalva", position)
    if npc then
        npcs[npcId] = npc:getId()
        addEvent(removeNpcAfterDuration, npcDuration, npcId)
    end
end

local function notifyPlayers()
    local spectators = Game.getSpectators(
        npc1Position,
        false,
        true,
        60, 60,
        60, 60
    )
    for _, player in ipairs(spectators) do
        playSoundPlayer(player, "expedition.ogg")
        player:addMapMark(npc1Position, 22, "Expedition: Survivors")
        player:addMapMark(Position(30936, 31038, 7), 22, "Expedition: Survivors")
    end
end

local spawnTimes = {
    "07:05:00",
    "09:05:00",
    "11:05:00",
    "13:05:00",
    "15:05:00",
    "17:05:00",
    "19:05:00",
    "21:05:00",
    "23:05:00",
    "02:05:00",
    "04:05:00",
}

for i, time in ipairs(spawnTimes) do
    local ShalvaExpedition = GlobalEvent("ShalvaExpedition" .. i)
    function ShalvaExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Shalva has spawned on Dorn Island.", MESSAGE_EVENT_ADVANCE)
        return true
    end
    ShalvaExpedition:time(time)
    ShalvaExpedition:register()
end