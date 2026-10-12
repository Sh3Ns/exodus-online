local npc1Position = Position(31329, 31046, 7)
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

    local npc = Game.createNpc("Rinling", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Repair Small Machines")
    end
end

local spawnTimes = {
    "05:14:00",
    "08:14:00",
    "10:14:00",
    "12:14:00",
    "14:14:00",
    "16:14:00",
    "18:14:00",
    "20:14:00",
    "22:14:00",
    "01:14:00",
    "03:14:00",
}

for i, time in ipairs(spawnTimes) do
    local RinlingExpedition = GlobalEvent("RinlingExpedition" .. i)
    function RinlingExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Rinling has spawned on Hallowfall island.", MESSAGE_EVENT_ADVANCE)
        return true
    end
    RinlingExpedition:time(time)
    RinlingExpedition:register()
end