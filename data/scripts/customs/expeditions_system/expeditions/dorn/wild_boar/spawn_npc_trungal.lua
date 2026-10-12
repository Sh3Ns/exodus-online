local npc1Position = Position(30944, 30975, 7)
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

    local npc = Game.createNpc("Trungal", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Were Boar Traps")
    end
end

local spawnTimes = {
    "07:55:00",
    "09:55:00",
    "11:55:00",
    "13:55:00",
    "15:55:00",
    "17:55:00",
    "19:55:00",
    "21:55:00",
    "23:55:00",
    "02:55:00",
    "05:55:00",
}

for i, time in ipairs(spawnTimes) do
    local trungalExpedition = GlobalEvent("TrungalExpedition" .. i)
    function trungalExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage("Trungal has spawned on Dorn Island.", MESSAGE_EVENT_ADVANCE)
        return true
    end
    trungalExpedition:time(time)
    trungalExpedition:register()
end