local npc1Position = Position(30878, 30970, 7)
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

    local npc = Game.createNpc("Murik", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Tombs")
    end
end

local spawnTimes = {
    "06:25:00",
    "08:25:00",
    "10:25:00",
    "12:25:00",
    "14:25:00",
    "16:25:00",
    "18:25:00",
    "20:25:00",
    "22:25:00",
    "01:25:00",
    "03:25:00",
    "05:25:00"
}

for i, time in ipairs(spawnTimes) do
    local MuricExpedition = GlobalEvent("MuricExpedition" .. i)
    function MuricExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Muric has spawned on Dorn island.", MESSAGE_EVENT_ADVANCE)
        return true
    end
    MuricExpedition:time(time)
    MuricExpedition:register()
end