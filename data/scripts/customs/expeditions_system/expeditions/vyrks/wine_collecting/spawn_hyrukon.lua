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

    local npc = Game.createNpc("Hyrukon", position)
    if npc then
        npcs[npcId] = npc:getId()
        addEvent(removeNpcAfterDuration, npcDuration, npcId)
    end
end

local function notifyPlayers()
    local spectators = Game.getSpectators(npcPosition, false, true, 80, 80, 80, 80)
    for _, player in ipairs(spectators) do
        playSoundPlayer(player, "expedition.ogg")
        player:addMapMark(Position(31272, 31263, 6), 22, "Expedition: Collect Wine for Pirate Fest.")
        player:addMapMark(Position(31272, 31263, 7), 22, "Expedition: Collect Wine for Pirate Fest.")
    end
end

local spawnTimes = {
    "03:20:00",
    "05:20:00",
    "09:20:00",
    "11:20:00",
    "15:20:00",
    "17:20:00",
    "19:20:00",
    "21:20:00",
    "00:20:00",
    "01:50:00",
}

for i, time in ipairs(spawnTimes) do
    local hyrukonExpedition = GlobalEvent("HyrukonExpedition" .. i)

    function hyrukonExpedition.onTime(interval)
        spawnNpc(1, npcPosition)
        notifyPlayers()
        Game.broadcastMessage("Hyrukon has appeared on Vyrsk Island.", MESSAGE_EVENT_ADVANCE)
        return true
    end

    hyrukonExpedition:time(time)
    hyrukonExpedition:register()
end