local npc1Position = Position(31270, 31001, 7)
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

    local npc = Game.createNpc("Caesper", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Repair Broken Generators")
    end
end

local spawnTimes = {
    "00:51:00",
    "03:51:00",
    "06:51:00",
    "09:51:00",
    "12:51:00",
    "15:51:00",
    "18:51:00",
    "21:51:00",
    "22:51:00"
}

for i, time in ipairs(spawnTimes) do
    local CaesperExpedition = GlobalEvent("CaesperExpedition" .. i)

    function CaesperExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage(
            "Caesper has spawned on Hallowfall island.",
            MESSAGE_EVENT_ADVANCE
        )
        return true
    end

    CaesperExpedition:time(time)
    CaesperExpedition:register()
end