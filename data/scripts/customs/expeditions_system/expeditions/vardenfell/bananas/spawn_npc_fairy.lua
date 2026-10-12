local npc1Position = Position(31560, 31427, 7)
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

    local npc = Game.createNpc("Fairy", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Collect Bananas")
    end
end

local spawnTimes = {
    "01:24:00",
    "03:24:00",
    "05:24:00",
    "07:24:00",
    "09:24:00",
    "12:24:00",
    "15:24:00",
    "16:24:00",
    "19:24:00",
    "21:24:00",
    "23:24:00",
}

for i, time in ipairs(spawnTimes) do
    local FairyExpedition = GlobalEvent("FairyExpedition" .. i)

    function FairyExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage(
            "Fairy has spawned on Vardenfell island.",
            MESSAGE_EVENT_ADVANCE
        )
        return true
    end

    FairyExpedition:time(time)
    FairyExpedition:register()
end