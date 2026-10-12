local npc1Position = Position(31597, 31395, 7)
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

    local npc = Game.createNpc("Myrianus", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Find Lost Objects")
    end
end

local spawnTimes = {
    "06:17:00",
    "09:17:00",
    "11:17:00",
    "13:17:00",
    "15:17:00",
    "17:17:00",
    "19:17:00",
    "21:17:00",
    "23:17:00",
    "02:17:00",
    "04:17:00",
}

for i, time in ipairs(spawnTimes) do
    local MyrianusExpedition = GlobalEvent("MyrianusExpedition" .. i)

    function MyrianusExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Myrianus has spawned on Vardenfell island.", MESSAGE_EVENT_ADVANCE)
        return true
    end

    MyrianusExpedition:time(time)
    MyrianusExpedition:register()
end