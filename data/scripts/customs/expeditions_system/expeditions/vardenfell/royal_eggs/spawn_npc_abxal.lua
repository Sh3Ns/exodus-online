local npc1Position = Position(31574, 31348, 6)
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

    local npc = Game.createNpc("Abxal", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Find Royal Vulture Eggs")
    end
end

local spawnTimes = {
    "00:39:00",
    "02:49:00",
    "04:19:00",
    "06:29:00",
    "08:39:00",
    "11:49:00",
    "13:19:00",
    "16:29:00",
    "18:39:00",
    "20:49:00",
    "22:19:00",
}

for i, time in ipairs(spawnTimes) do
    local AbxalExpedition = GlobalEvent("AbxalExpedition" .. i)

    function AbxalExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Abxal has spawned on Vardenfell island.", MESSAGE_EVENT_ADVANCE)
        return true
    end

    AbxalExpedition:time(time)
    AbxalExpedition:register()
end