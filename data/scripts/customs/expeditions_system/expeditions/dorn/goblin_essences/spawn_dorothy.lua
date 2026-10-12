local npc1Position = Position(31008, 30994, 7)
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

    local npc = Game.createNpc("Dorothy", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Goblin Essences")
    end
end

local spawnTimes = {
    "03:50:30",
    "06:22:30",
    "08:22:30",
    "10:22:30",
    "12:22:30",
    "14:22:30",
    "16:22:30",
    "18:22:30",
    "20:22:30",
    "22:22:30",
    "00:40:30",
    "02:22:30"
}

for i, time in ipairs(spawnTimes) do
    local DorothyExpedition = GlobalEvent("DorothyExpedition" .. i)
    function DorothyExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Dorothy has spawned on Dorn island.", MESSAGE_EVENT_ADVANCE)
        return true
    end
    DorothyExpedition:time(time)
    DorothyExpedition:register()
end