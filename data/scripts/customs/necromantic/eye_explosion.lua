local deathExplosion = CreatureEvent("EyeDeathExplosion")

local function delayedExplosion(positions)
    for _, p in ipairs(positions) do
        local pos = Position(p.x, p.y, p.z)

        pos:sendMagicEffect(218)

        local tile = Tile(pos)
        if tile then
            local creatures = tile:getCreatures()
            if creatures then
                for _, c in ipairs(creatures) do
                    if c:isPlayer() or c:isMonster() then
                        doTargetCombatHealth(0, c,
                            COMBAT_ARCANEDAMAGE, -1000, -2000, CONST_ME_NONE)
                    end
                end
            end
        end
    end
end

function deathExplosion.onDeath(monster)
    local pos = monster:getPosition()
    local list = {}
    
    for x = -1, 1 do
        for y = -1, 1 do
            table.insert(list, {
                x = pos.x + x,
                y = pos.y + y,
                z = pos.z
            })
        end
    end

    addEvent(delayedExplosion, 2000, list)

    return true
end

deathExplosion:register()
