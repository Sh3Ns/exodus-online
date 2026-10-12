local npcPosition = Position(31193, 31242, 8)
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

    local npc = Game.createNpc("Lyot", position)
    if npc then
        npcs[npcId] = npc:getId()
        addEvent(removeNpcAfterDuration, npcDuration, npcId)
    end
end

local function notifyPlayers()
    local spectators = Game.getSpectators(npcPosition, false, true, 80, 80, 80, 80)
    for _, player in ipairs(spectators) do
        playSoundPlayer(player, "expedition.ogg")
        player:addMapMark(npcPosition, 22, "Expedition: Mechanic Goblins")
        player:addMapMark(Position(31167, 31264, 7), 22, "Expedition: Mechanic Goblins, Near Boat on Vyrsk Caves.")
    end
end

local spawnTimes = {
    "01:45:00",
    "03:45:00",
    "05:45:00",
    "07:15:00",
    "08:45:00",
    "09:55:00",
    "13:45:00",
    "15:45:00",
    "17:45:00",
    "19:45:00",
    "21:45:00",
    "09:46:10"
}

for i, time in ipairs(spawnTimes) do
    local lyotExpedition = GlobalEvent("LyotExpedition" .. i)

    function lyotExpedition.onTime(interval)
        spawnNpc(1, npcPosition)
        notifyPlayers()
        Game.broadcastMessage("Lyot has appeared in the Vyrsk Caves.", MESSAGE_EVENT_ADVANCE)
        return true
    end

    lyotExpedition:time(time)
    lyotExpedition:register()
end