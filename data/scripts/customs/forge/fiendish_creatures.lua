-- Fiendish creatures

FiendishSystem = {
    config = {
        enabled = true,
        maxActive = 4,

        -- World-start monsters use the first chance. Normal later respawns use
        -- the second chance.
        startupChancePercent = 10.0,
        respawnChancePercent = 2.0,

        icon = CREATUREICON_FIENDISH,
        dustItemId = 30910,
        gemLoot = {
            { id = 27150, chance = 10000 }, -- Lesser Guardian Gem
            { id = 27153, chance = 10000 }, -- Lesser Marksman Gem
            { id = 27156, chance = 10000 }, -- Lesser Sage Gem
            { id = 27159, chance = 10000 }, -- Lesser Mystic Gem
            { id = 30913, chance = 10000 }, -- Lesser Spiritualist Gem
            { id = 27151, chance = 3000 }, -- Guardian Gem
            { id = 27154, chance = 3000 }, -- Marksman Gem
            { id = 27157, chance = 3000 }, -- Sage Gem
            { id = 27160, chance = 3000 }, -- Mystic Gem
            { id = 30914, chance = 3000 }, -- Spiritualist Gem
            { id = 27152, chance = 1000 }, -- Greater Guardian Gem
            { id = 27155, chance = 1000 }, -- Greater Marksman Gem
            { id = 27158, chance = 1000 }, -- Greater Sage Gem
            { id = 27161, chance = 1000 }, -- Greater Mystic Gem
            { id = 30915, chance = 1000 }, -- Greater Spiritualist Gem
        },

        -- Only normal hostile map spawns can become Fiendish.
        allowBosses = false,
        allowRewardBosses = false,
        allowSummons = false,
        allowArtificialSpawns = false,
    },

    stacks = {
        [1] = { healthPercent = 50, damagePercent = 35, experiencePercent = 10, dustMin = 1, dustMax = 3 },
        [2] = { healthPercent = 65, damagePercent = 45, experiencePercent = 20, dustMin = 2, dustMax = 6 },
        [3] = { healthPercent = 80, damagePercent = 55, experiencePercent = 30, dustMin = 3, dustMax = 9 },
        [4] = { healthPercent = 95, damagePercent = 65, experiencePercent = 40, dustMin = 4, dustMax = 12 },
    },

    active = {},
}

local system = FiendishSystem

local function rollPercent(chance)
    chance = math.max(0, math.min(100, tonumber(chance) or 0))
    return math.random(1, 10000) <= math.floor((chance * 100) + 0.5)
end

local function pruneActive()
    local count = 0
    for creatureId in pairs(system.active) do
        local monster = Monster(creatureId)
        if not monster or monster:isRemoved() or monster:getFiendishStack() == 0 then
            system.active[creatureId] = nil
        else
            count = count + 1
        end
    end
    return count
end

local function isEligible(monster, artificial)
    if not monster or monster:isRemoved() then
        return false
    end

    if not system.config.allowSummons and monster:getMaster() then
        return false
    end

    if not system.config.allowArtificialSpawns and artificial then
        return false
    end

    local monsterType = monster:getType()
    if not monsterType or not monsterType:isHostile() or monsterType:experience() <= 0 then
        return false
    end

    if not system.config.allowBosses and monsterType:isBoss() then
        return false
    end

    if not system.config.allowRewardBosses and monsterType:isRewardBoss() then
        return false
    end

    return true
end

function system.makeFiendish(monster, stack)
    if not monster or monster:isRemoved() then
        return false
    end

    stack = math.max(1, math.min(#system.stacks, math.floor(tonumber(stack) or 1)))
    local values = system.stacks[stack]
    if not values then
        return false
    end

    local maximumHealth = math.max(1,
        math.floor(monster:getMaxHealth() * (1 + (values.healthPercent / 100)) + 0.5))

    monster:setFiendishStack(stack)
    monster:setDamageMultiplier(1 + (values.damagePercent / 100))
    monster:setExperienceMultiplier(1 + (values.experiencePercent / 100))
    monster:setMaxHealth(maximumHealth)
    monster:setHealth(maximumHealth)
    monster:setIcon(system.config.icon)

    system.active[monster:getId()] = stack
    return true
end

function system.getActive()
    pruneActive()

    local monsters = {}
    for creatureId, stack in pairs(system.active) do
        local monster = Monster(creatureId)
        if monster then
            monsters[#monsters + 1] = { monster = monster, stack = stack }
        end
    end
    return monsters
end

local spawnCallback = EventCallback

function spawnCallback.onSpawn(monster, position, startup, artificial)
    if not system.config.enabled or not isEligible(monster, artificial) then
        return true
    end

    if pruneActive() >= system.config.maxActive then
        return true
    end

    local chance = startup and system.config.startupChancePercent or system.config.respawnChancePercent
    if not rollPercent(chance) then
        return true
    end

    system.makeFiendish(monster, math.random(1, #system.stacks))
    return true
end

spawnCallback:register(50)

local lootCallback = EventCallback

function lootCallback.onDropLoot(monster, corpse)
    local stack = monster and monster:getFiendishStack() or 0
    local values = system.stacks[stack]
    if not values then
        return
    end

    system.active[monster:getId()] = nil

    local amount = math.random(values.dustMin, values.dustMax)
    if not corpse:addItem(system.config.dustItemId, amount) then
        print(string.format(
            "[FiendishSystem] Could not add %d Forge Dust to the corpse of %s.",
            amount,
            monster:getName()
        ))
    end

    for _, loot in ipairs(system.config.gemLoot or {}) do
        if math.random(1, 100000) <= loot.chance then
            if not corpse:addItem(loot.id, 1) then
                print(string.format(
                    "[FiendishSystem] Could not add Wheel gem %d to the corpse of %s.",
                    loot.id,
                    monster:getName()
                ))
            end
        end
    end
end
lootCallback:register(-50)
