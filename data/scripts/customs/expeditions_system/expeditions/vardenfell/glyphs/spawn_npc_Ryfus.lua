local npc1Position = Position(31572, 31368, 6)
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

    local npc = Game.createNpc("Ryfus", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Decrypt Glyphs")
    end
end

local spawnTimes = {
    "05:03:00",
    "08:03:00",
    "10:03:00",
    "12:03:00",
    "14:03:00",
    "16:03:00",
    "18:03:00",
    "20:03:00",
    "22:03:00",
    "01:03:00",
    "03:03:00",
}

for i, time in ipairs(spawnTimes) do
    local RyfusExpedition = GlobalEvent("RyfusExpedition" .. i)

    function RyfusExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Ryfus has spawned on Vardenfell island.", MESSAGE_EVENT_ADVANCE)
        return true
    end

    RyfusExpedition:time(time)
    RyfusExpedition:register()
end