local npc1Position = Position(31388, 31048, 7)
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

    local npc = Game.createNpc("Zidormi", position)
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
        player:addMapMark(npc1Position, 22, "Expedition: Repair the Machines")
    end
end

local spawnTimes = {
    "07:07:00",
    "09:07:00",
    "11:07:00",
    "13:07:00",
    "15:07:00",
    "17:07:00",
    "19:07:00",
    "21:07:00",
    "23:07:00",
    "02:07:00",
    "04:07:00",
}

for i, time in ipairs(spawnTimes) do
    local ZidormiExpedition = GlobalEvent("ZidormiExpedition" .. i)

    function ZidormiExpedition.onTime(interval)
        spawnNpc(1, npc1Position)
        notifyPlayers()
        Game.broadcastMessage(
            "Zidormi has spawned on Hallowfall island.",
            MESSAGE_EVENT_ADVANCE
        )
        return true
    end

    ZidormiExpedition:time(time)
    ZidormiExpedition:register()
end