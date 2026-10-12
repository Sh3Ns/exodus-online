local monsterPosition = Position(31035, 31012, 8)
local monsterType = "Ashseer Dravok"

local eventDuration = 60 * 60 * 1000
local islandName = "Dorn Island"

local spectatorRange = 35

local function announceSpawn()
    local spectators = Game.getSpectators(
        monsterPosition,
        false,
        true, 
        spectatorRange,
        spectatorRange,
        spectatorRange,
        spectatorRange
    )

    if #spectators > 0 then
        for _, player in ipairs(spectators) do
            playSoundPlayer(player, "expedition.ogg")
            player:addMapMark(monsterPosition, 23, "Boss: " .. monsterType)
        end

        Game.broadcastMessage(
            "The Boss " .. monsterType .. " has spawned on " .. islandName .. ".",
            MESSAGE_EVENT_ADVANCE
        )
    end
end

local function summonBoss()
    local tile = Tile(monsterPosition)
    if not tile then
        return
    end

    local creature = tile:getTopCreature()
    if creature and creature:isMonster() then
        return
    end

    local monster = Game.createMonster(monsterType, monsterPosition)
    if monster then
        announceSpawn()
    end
end

local function removeBoss()
    local tile = Tile(monsterPosition)
    if not tile then
        return
    end

    local creature = tile:getTopCreature()
    if creature and creature:isMonster() and creature:getName():lower() == monsterType:lower() then
        creature:remove()

        Game.broadcastMessage(
            "The Boss " .. monsterType .. " has vanished from " .. islandName .. ".",
            MESSAGE_EVENT_ADVANCE
        )
    end
end

local spawnTimes = {
    "08:00:00",
    "16:00:00",
}

for i, time in ipairs(spawnTimes) do
    local monsterEvent = GlobalEvent("SummonAshseerDravok_" .. i)

    function monsterEvent.onTime(interval)
        summonBoss()
        addEvent(removeBoss, eventDuration)
        return true
    end

    monsterEvent:time(time)
    monsterEvent:register()
end