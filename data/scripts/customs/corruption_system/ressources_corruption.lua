local spawnTree = GlobalEvent("ressourcesSpawnCorruption")

--- This script Creates resources based on Ground ID, if tile is empty and exclude some ground id.
--- By ground id we added resources to the type of ground, to be more rpg. Spawn resources by chance, and randomly on tiles to not be each time on same positions. If you want find an isle, check the table Zone.
local forbiddenSpawn = {
    [6216] = true,[6217] = true,[6218] = true,[6219] = true,
    [3613] = true,[3650] = true,[3610] = true,
    [26405] = true,[26406] = true,[26407] = true,[26408] = true,
    [26409] = true,[26410] = true,[26411] = true,
    [26604] = true,[26605] = true,[26606] = true,[26607] = true,
    [26608] = true,[26609] = true,[26610] = true,[26611] = true,
    [26612] = true,[26613] = true,[26614] = true,[26615] = true,
    [26634] = true,[26635] = true,[26636] = true,
    [26717] = true,[26718] = true,[26719] = true,[26720] = true,
    [26721] = true,[26722] = true,[26723] = true,[26724] = true,
    [10740] = true,[10741] = true,[10742] = true,
    [8223] = true,[8221]  = true,[8222] = true,
    [8393] = true,[8399] = true,
}

local groundSpawnTable = {
    -- Herbacea Ground
    [29237] = {[30143] = true, [30158] = true, [30160] = true, [30162] = true, [30170] = true, [30182] = true, [30183] = true, [30184] = true, [30185] = true, [30186] = true, [30187] = true, [30212] = true, [30214] = true, [30218] = true, [30220] = true},
    [29238] = {[30143] = true, [30158] = true, [30160] = true, [30162] = true, [30170] = true, [30182] = true, [30183] = true, [30184] = true, [30185] = true, [30186] = true, [30187] = true, [30212] = true, [30214] = true, [30218] = true, [30220] = true},
    [29239] = {[30143] = true, [30158] = true, [30160] = true, [30162] = true, [30170] = true, [30182] = true, [30183] = true, [30184] = true, [30185] = true, [30186] = true, [30187] = true, [30212] = true, [30214] = true, [30218] = true, [30220] = true, [30174] = true,},

    -- Desertic Ground
    [29178] = {[30142] = true, [30145] = true, [30147] = true, [30149] = true, [30152] = true, [30156] = true, [30164] = true, [30166] = true, [30168] = true, [30198] = true, [30170] = true, [30141] = true,},

    -- Terrea Ground
    [29018] = {[30172] = true, [30174] = true, [30176] = true, [30178] = true, [30180] = true},

    -- Galva Ground
    [29140] = {[30143] = true, [30142] = true, [30152] = true, [30212] = true, [30214] = true, [30218] = true, [30216] = true, [30195] = true, [30180] = true, [30141] = true,},

    -- Mountain Ground
    [30427] = {[30142] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true},
    [30428] = {[30142] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true},
    [30429] = {[30142] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30195] = true,},

    -- Pestiferous ground
    [29153] = {[30182] = true, [30183] = true, [30174] = true, [30184] = true, [30185] = true, [30186] = true, [30187] = true, [30212] = true, [30214] = true, [30218] = true, [30220] = true, [30196] = true, [30197] = true, [30200] = true, [30143] = true},


    -- Rock Ground - Others
    [7062] = {[30142] = true, [30152] = true, [30184] = true, [30183] = true, [30195] = true, [30196] = true, [30197] = true, [30198] = true, [30199] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30156] = true, [30180] = true},
    [7066] = {[30142] = true, [30152] = true, [30184] = true, [30183] = true, [30195] = true, [30196] = true, [30197] = true, [30198] = true, [30199] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30156] = true, [30180] = true},
    [11506] = {[30142] = true, [30152] = true, [30184] = true, [30183] = true, [30195] = true, [30196] = true, [30197] = true, [30198] = true, [30199] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30156] = true, [30180] = true},
    [11507] = {[30142] = true, [30152] = true, [30184] = true, [30183] = true, [30195] = true, [30196] = true, [30197] = true, [30198] = true, [30199] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30156] = true, [30180] = true},
    [17626] = {[30142] = true, [30152] = true, [30184] = true, [30183] = true, [30195] = true, [30196] = true, [30197] = true, [30198] = true, [30199] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30156] = true, [30180] = true},
    [17627] = {[30142] = true, [30152] = true, [30184] = true, [30183] = true, [30195] = true, [30196] = true, [30197] = true, [30198] = true, [30199] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30156] = true, [30180] = true},
    [17628] = {[30142] = true, [30152] = true, [30184] = true, [30183] = true, [30195] = true, [30196] = true, [30197] = true, [30198] = true, [30199] = true, [30200] = true, [30201] = true, [30202] = true, [30203] = true, [30204] = true, [30156] = true, [30180] = true},
    
}

local itemQuotas = { -- Means Quantity maximum created (Based on Multiplier and max total per isle)
   [30141] = 10, -- Aether Vein
   [30143] = 10, -- Verdant Tree
   [30145] = 10, -- Twilight Flower
   [30149] = 10, -- Moonsang Cocoon
   [30152] = 10, -- Verdant Vein
   [30156] = 10, -- Umbrapetal Mushroom
   [30158] = 10, -- Sanguibloom Flower
   [30160] = 10, -- Aetherblossom Flower
   [30162] = 10, -- Noctilume Flower
   [30164] = 10, -- Thornveil Herb
   [30166] = 10, -- Heliara Herb
   [30168] = 10, -- Zaphyra Herb
   [30170] = 10, -- Rotcap Fungus
   [30172] = 10, -- Grimwood Trunk
   [30174] = 10, -- Duskwillow trunk
   [30176] = 10, -- Gildedheart trunk
   [30178] = 10, -- Cinderbark Trunk
   [30180] = 10, -- Frostpine Trunk
   [30182] = 10, -- Colybis Fungus
   [30183] = 10, -- Agrocybe Fungus
   [30184] = 10, -- Psyliota Mushroom
   [30185] = 10, -- Laccaria Fungus
   [30186] = 10, -- Virelia Plant
   [30187] = 10, -- Auralis Plant
   [30195] = 10, -- Cryth Vein
   [30196] = 10, -- Obryx Vein
   [30197] = 10, -- Drazium Vein
   [30198] = 10, -- Redsyl Vein
   [30200] = 10, -- Voidslag Crystal
   [30201] = 10, -- Aqualith Crystal
   [30202] = 10, -- Umbralyte Crystal
   [30203] = 10, -- Solvex Crystal
   [30204] = 10, -- Crimsyx Crystal
   [30212] = 10, -- Verdwood Trunk
   [30214] = 10, -- Sylvan Trunk
   [30216] = 10, -- Aurawood Trunk
   [30218] = 10, -- Umbrabloom Trunk
   [30220] = 10, -- Bloodwood Trunk

}

local itemChances = {
   [30141] = 100, -- Aether Vein
   [30143] = 100, -- Verdant Tree
   [30145] = 100, -- Twilight Flower
   [30149] = 100, -- Moonsang Cocoon
   [30152] = 100, -- Verdant Vein
   [30156] = 100, -- Umbrapetal Mushroom
   [30158] = 100, -- Sanguibloom Flower
   [30160] = 100, -- Aetherblossom Flower
   [30162] = 100, -- Noctilume Flower
   [30164] = 100, -- Thornveil Herb
   [30166] = 100, -- Heliara Herb
   [30168] = 100, -- Zaphyra Herb
   [30170] = 100, -- Rotcap Fungus
   [30172] = 100, -- Grimwood Trunk
   [30174] = 100, -- Duskwillow trunk
   [30176] = 100, -- Gildedheart trunk
   [30178] = 100, -- Cinderbark Trunk
   [30180] = 100, -- Frostpine Trunk
   [30182] = 100, -- Colybis Fungus
   [30183] = 100, -- Agrocybe Fungus
   [30184] = 100, -- Psyliota Mushroom
   [30185] = 100, -- Laccaria Fungus
   [30186] = 100, -- Virelia Plant
   [30187] = 100, -- Auralis Plant
   [30195] = 100, -- Cryth Vein
   [30196] = 100, -- Obryx Vein
   [30197] = 100, -- Drazium Vein
   [30198] = 100, -- Redsyl Vein
   [30200] = 100, -- Voidslag Crystal
   [30201] = 100, -- Aqualith Crystal
   [30202] = 100, -- Umbralyte Crystal
   [30203] = 100, -- Solvex Crystal
   [30204] = 100, -- Crimsyx Crystal
   [30212] = 100, -- Verdwood Trunk
   [30214] = 100, -- Sylvan Trunk
   [30216] = 100, -- Aurawood Trunk
   [30218] = 100, -- Umbrabloom Trunk
   [30220] = 100, -- Bloodwood Trunk
}

local function rollChance(percent)
    if percent == nil then
        return false
    end
    if percent <= 0 then return false end
    if percent >= 100 then return true end
    return math.random(100) <= percent
end

local function buildEnabledItemsForZone()
    local enabled = {}
    for itemId, _ in pairs(itemQuotas) do
        if rollChance(itemChances[itemId]) then
            enabled[itemId] = true
        end
    end
    return enabled
end

local groundCycleIndex = {}

local function pickWeightedItemForGround(groundId, enabledItems)
    local allowed = groundSpawnTable[groundId]
    if not allowed then
        return nil
    end

    local candidates = {}
    for itemId, _ in pairs(allowed) do
        if enabledItems[itemId] then
            candidates[#candidates + 1] = itemId
        end
    end

    if #candidates == 0 then
        return nil
    end

    if not groundCycleIndex[groundId] then
        groundCycleIndex[groundId] = 1
    end

    local index = groundCycleIndex[groundId]
    local itemId = candidates[index]
    if math.random(100) <= 20 then
        itemId = candidates[math.random(#candidates)]
    end

    groundCycleIndex[groundId] = index + 1
    if groundCycleIndex[groundId] > #candidates then
        groundCycleIndex[groundId] = 1
    end

    return itemId
end

local function tileHasForbidden(tile)
    for _, thing in ipairs(tile:getItems() or {}) do
        if forbiddenSpawn[thing:getId()] then
            return true
        end
    end
    return false
end

-- The Script works with zones, selecting a fromPos toPos an isle and floors about it, if space then, depending the allowed item on allowed ground it will be spawned if tile is empty (no grass, no stone , etc).
--- Floors: Means how many floors has the isle
--- Multiplier: 1.0 is normal quantity of items on the isle , so if isle is small just make for example 0.5 , will be 10 ressources of each one , if possible and ground is allowed. Example 0.1 = 2, 0.5 = 10, 1.0 = 20, 2.0 = 40.
local zones = {
    {
        from = {x=32330, y=31868},
        to = {x=32406, y=31927},
        floors = {5,6,7},
        multiplier = 1.0,
        maxTotal = 30
    },
    {
        from = {x=33318, y=32148},
        to = {x=33495, y=32288},
        floors = {7,8,9},
        multiplier = 1.0,
        maxTotal = 100
    },
    {
        from = {x=32430, y=32533},
        to = {x=32542, y=32636},
        floors = {6,7},
        multiplier = 1.3,
        maxTotal = 70
    },
    {
        from = {x=33303, y=32535},
        to = {x=33387, y=32595},
        floors = {3,4,5,6,7},
        multiplier = 1.3,
        maxTotal = 70
    },
    {
        from = {x=32459, y=32351},
        to = {x=32512, y=32396},
        floors = {7,8},
        multiplier = 1.0,
        maxTotal = 20
    },
    {
        from = {x=33108, y=32266},
        to = {x=33167, y=32316},
        floors = {7},
        multiplier = 1.0,
        maxTotal = 25
    },
    {
        from = {x=32708, y=30901},
        to = {x=32820, y=30990},
        floors = {7,8,9},
        multiplier = 1.3,
        maxTotal = 70
    },
    {
        from = {x=32217, y=32973},
        to = {x=32331, y=33094},
        floors = {5,6,7,8,9},
        multiplier = 1.3,
        maxTotal = 80
    },
    {
        from = {x=33432, y=31372},
        to = {x=33509, y=31534},
        floors = {8,9,10},
        multiplier = 1.3,
        maxTotal = 40
    },
}

local STARTUP = {}
local spawnedCount = {}

STARTUP[#STARTUP + 1] = {
    action = function()
        for _, zone in ipairs(zones) do
            groundCycleIndex = {}
            local floorSpawned = {}

            for _, z in ipairs(zone.floors) do
                floorSpawned[z] = {}
                for itemId, _ in pairs(itemQuotas) do
                    floorSpawned[z][itemId] = 0
                end
            end
            local targetTotal = math.floor((zone.maxTotal or 0) * (zone.multiplier or 1.0))
            if targetTotal <= 0 then
                targetTotal = 0
            end

            local enabledItems = buildEnabledItemsForZone()

            local placed = 0
            local attempts = 0
            local maxAttempts = math.max(2000, targetTotal * 200)

            while placed < targetTotal and attempts < maxAttempts do
                attempts = attempts + 1

                local floorIndex = math.random(1, #zone.floors + 1)
                if floorIndex > #zone.floors then
                    floorIndex = #zone.floors
                end

                local pos = {
                    x = math.random(zone.from.x, zone.to.x),
                    y = math.random(zone.from.y, zone.to.y),
                    z = zone.floors[floorIndex]
                }

                local tile = Tile(pos)
                if tile then
                    local ground = tile:getGround()
                    if ground then
                        local groundId = ground:getId()

                        if not tileHasForbidden(tile) then
                            local tileInfo = getTileInfo(pos)
                            if tileInfo.items == 0 and tileInfo.creatures == 0 then
                                local itemId = pickWeightedItemForGround(groundId, enabledItems)
                                if itemId then
                                    doCreateItem(itemId, 1, pos)
                                    placed = placed + 1
                                    spawnedCount[itemId] = (spawnedCount[itemId] or 0) + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
}


function spawnTree.onStartup()
    for _, cmd in pairs(STARTUP) do
        cmd.action()
    end

    addEvent(function()
        print("[Corruption Resources Spawn] ===== Corruption Resources =====")
        for itemId, count in pairs(spawnedCount) do
            local name = ItemType(itemId):getName()
            print(string.format(
                "[Corruption Resources Spawn] %s (%d) spawned: %d",
                name,
                itemId,
                count
            ))
        end
        print("[Corruption Resources Spawn] =========================")
    end, 2500)

    STARTUP = nil
    return true
end

spawnTree:register()