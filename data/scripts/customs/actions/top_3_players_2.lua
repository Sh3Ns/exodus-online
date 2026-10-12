local testtexttopplayers = GlobalEvent("textfloat2")

local positions = {
    {pos = Position(32369, 32246, 7), effect = 257},
    {pos = Position(32367, 32247, 7), effect = 254},
    {pos = Position(32371, 32247, 7), effect = 256}
}

function testtexttopplayers.onThink(interval)
    local getTopPlayers = function(amount)
        local query = string.format("SELECT `name`, `level`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons` FROM `players` ORDER BY `level` DESC, `experience` DESC LIMIT %d", amount)
        local resultId = db.storeQuery(query)
        local players = {}
        if resultId then
            repeat
                local name = result.getDataString(resultId, "name")
                local level = result.getDataInt(resultId, "level")
                local outfit = {
                    lookBody = result.getDataInt(resultId, "lookbody"),
                    lookFeet = result.getDataInt(resultId, "lookfeet"),
                    lookHead = result.getDataInt(resultId, "lookhead"),
                    lookLegs = result.getDataInt(resultId, "looklegs"),
                    lookType = result.getDataInt(resultId, "looktype"),
                    lookAddons = result.getDataInt(resultId, "lookaddons")
                }
                table.insert(players, {name = name, level = level, outfit = outfit})
            until not result.next(resultId)
            result.free(resultId)
        end
        return players
    end

    local topPlayers = getTopPlayers(3)

    for i, positionData in ipairs(positions) do
        local topPlayer = topPlayers[i]
        local pos = positionData.pos
        local effect = positionData.effect
        local tile = Tile(pos)
        if tile then
            local topCreature = tile:getTopCreature()
            if topCreature and topCreature:isMonster() and topCreature:getName():lower() == "rat" then
                topCreature:remove()
            end
        end

        if topPlayer then
            local message = string.format("Top Level %d: %s [%d]", i, topPlayer.name, topPlayer.level)
            local spectators = Game.getSpectators(pos, false, true, 7, 7, 5, 5)
            for _, spectator in ipairs(spectators) do
                if spectator:isPlayer() then
                    spectator:say(message, TALKTYPE_MONSTER_SAY, false, spectator, pos)
                end
            end

            local dummy = Game.createMonster("rat", pos, false, true)
            if dummy then
                dummy:setOutfit(topPlayer.outfit)
                dummy:rename(topPlayer.name)

                local dummyId = dummy:getId()
                addEvent(function()
                    local d = Monster(dummyId)
                    if d then
                        d:remove()
                    end
                end, 5000)
            end

            pos:sendMagicEffect(effect)
        else
            local message = string.format("Top Level %d: None", i)
            local spectators = Game.getSpectators(pos, false, true, 7, 7, 5, 5)
            for _, spectator in ipairs(spectators) do
                if spectator:isPlayer() then
                    spectator:say(message, TALKTYPE_MONSTER_SAY, false, spectator, pos)
                end
            end
            pos:sendMagicEffect(effect)
        end
    end

    return true
end

testtexttopplayers:interval(30000)
testtexttopplayers:register()
