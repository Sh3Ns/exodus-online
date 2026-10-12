local npc1Position = Position(31587, 31376, 6)
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

    local npc = Game.createNpc("Varshan", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Monstrosity")
    end
end

local spawnTimes = {
    "00:50:30",
    "02:45:30",
    "04:40:30",
    "06:35:30",
    "08:30:30",
    "10:25:30",
    "12:15:30",
    "15:10:30",
    "17:05:30",
    "19:00:30",
    "21:55:30",
    "23:15:30",
}

for i, time in ipairs(spawnTimes) do
    local VarshaExpedition = GlobalEvent("VarshaExpedition" .. i)

    function VarshaExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Varshan has spawned on Vardenfell island.", MESSAGE_EVENT_ADVANCE)
        return true
    end

    VarshaExpedition:time(time)
    VarshaExpedition:register()
end