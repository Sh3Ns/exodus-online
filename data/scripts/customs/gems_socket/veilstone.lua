-- NOT RECOMENDED and NOT TESTED, because is not the goal: Diferents Levels on SAME fromPos toPOS, avoid this because on many same tiles, can give probably errors.
local HiddenVeilstone = {
    gemKey = "veilstone",
    debug = false,
    monsterPacks = {
        {
            name = "Lower Roshamuul",
            requiredLevel = 1,
            createOnStartup = true,
            monsterNames = {
                "Frazzlemaw",
                "Silencer",
                "Guzzlemaw",
                "Retching Horror",
            },
            amount = 30,
            fromPos = Position(33585, 32472, 7),
            toPos = Position(33682, 32531, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "Upper Roshamuul",
            requiredLevel = 1,
            createOnStartup = true,
            monsterNames = {
                "Choking Fear",
                "Silencer",
                "Retching Horror",
            },
            amount = 45,
            fromPos = Position(33517, 32278, 7),
            toPos = Position(33725, 32442, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "Flimsys",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Flimsy Lost Soul",
                "Freakish Lost Soul",
                "Evil Prospector",
                "Cursed Prospector"
            },
            amount = 25,
            fromPos = Position(34076, 31288, 8),
            toPos = Position(34242, 31392, 8),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "Flimsys2",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Flimsy Lost Soul",
                "Freakish Lost Soul",
                "Evil Prospector",
                "Cursed Prospector"
            },
            amount = 25,
            fromPos = Position(34084, 31279, 9),
            toPos = Position(34219, 31390, 9),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "Flimsy3",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Flimsy Lost Soul",
                "Freakish Lost Soul",
                "Evil Prospector",
                "Cursed Prospector"
            },
            amount = 25,
            fromPos = Position(34095, 31299, 10),
            toPos = Position(34214, 31408, 10),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "AzurePalace1",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Hellspawn",
                "Dawnfire Asura",
                "Midnight Asura",
            },
            amount = 12,
            fromPos = Position(32933, 32670, 7),
            toPos = Position(32965, 32687, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "AzurePalace2",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Hellspawn",
                "Dawnfire Asura",
                "Midnight Asura",
            },
            amount = 14,
            fromPos = Position(32933, 32670, 6),
            toPos = Position(32965, 32687, 6),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "AzurePalace3",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Hellspawn",
                "Dawnfire Asura",
                "Midnight Asura",
            },
            amount = 14,
            fromPos = Position(32933, 32673, 5),
            toPos = Position(32965, 32687, 5),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "AzurePalace4",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Hellspawn",
                "Dawnfire Asura",
                "Midnight Asura",
            },
            amount = 12,
            fromPos = Position(32933, 32670, 4),
            toPos = Position(32965, 32687, 4),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "AzurePalace5",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Hellspawn",
                "Dawnfire Asura",
                "Midnight Asura",
            },
            amount = 10,
            fromPos = Position(32936, 32673, 3),
            toPos = Position(32962, 32685, 3),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "AzurePalace6",
            requiredLevel = 2,
            createOnStartup = true,
            monsterNames = {
                "Hellspawn",
                "Dawnfire Asura",
                "Midnight Asura",
            },
            amount = 8,
            fromPos = Position(32936, 32675, 2),
            toPos = Position(32960, 32685, 2),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "ExpeditionIsle1",
            requiredLevel = 3,
            createOnStartup = true,
            monsterNames = {
                "Swamp Monster",
                "Mountain Goblin",
                "Enforced Mountain Goblin",
                "Armored Giant",
                "Hooded Colossus",
                "Spiked Enforcer",
                "Axebringer Fiend"
            },
            amount = 25,
            fromPos = Position(32936, 32675, 2),
            toPos = Position(32960, 32685, 2),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "ExpeditionIsle2",
            requiredLevel = 3,
            createOnStartup = true,
            monsterNames = {
                "Sunfang Croaker",
                "Bloodthirst Bulgeye",
                "Mossblade Hopper",
                "Mystic Baguemage",
            },
            amount = 25,
            fromPos = Position(31203, 30939, 7),
            toPos = Position(31419, 31089, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "ExpeditionIsle3",
            requiredLevel = 3,
            createOnStartup = true,
            monsterNames = {
                "Frost Larva",
                "Frost Hydra",
                "Frosted Dragon",
            },
            amount = 25,
            fromPos = Position(30748, 31178, 7),
            toPos = Position(30964, 31343, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "ExpeditionIsle4",
            requiredLevel = 3,
            createOnStartup = true,
            monsterNames = {
                "Arbaziloth",
                "Broodrider Inferniarch",
                "Brinebrute Inferniarch",
                "Hellhunter Inferniarch",
                "Sineater Inferniarch",
                "Spellreaper Inferniarch",
            },
            amount = 50,
            fromPos = Position(31447, 31228, 6),
            toPos = Position(31695, 31287, 6),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap1",
            requiredLevel = 4,
            createOnStartup = true,
            monsterNames = {
                "Armorcoil",
                "Voidwagner",
                "Blazefang",
                "Gorgulith",
                "Sineater Inferniarch",
                "Spellreaper Inferniarch",
            },
            amount = 20,
            fromPos = Position(33314, 33066, 8),
            toPos = Position(33606, 33178, 8),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap1-1",
            requiredLevel = 4,
            createOnStartup = true,
            monsterNames = {
                "Armorcoil",
                "Voidwagner",
                "Blazefang",
                "Gorgulith",
                "Sineater Inferniarch",
                "Spellreaper Inferniarch",
            },
            amount = 30,
            fromPos = Position(32848, 33353, 7),
            toPos = Position(33096, 33506, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap2",
            requiredLevel = 4,
            createOnStartup = true,
            monsterNames = {
                "Toxic Mauler",
                "Pyroquill",
                "Gloomstinger",
                "Aegis Sentinel",
                "Flarevein Wyrm",
            },
            amount = 25,
            fromPos = Position(33294, 32984, 7),
            toPos = Position(33463, 33140, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap2-2",
            requiredLevel = 4,
            createOnStartup = true,
            monsterNames = {
                "Toxic Mauler",
                "Pyroquill",
                "Gloomstinger",
                "Aegis Sentinel",
                "Flarevein Wyrm",
            },
            amount = 25,
            fromPos = Position(33100, 33083, 8),
            toPos = Position(33281, 33215, 8),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap3",
            requiredLevel = 5,
            createOnStartup = true,
            monsterNames = {
                "Ashfang Wyrm",
                "Bloodspark Adept",
                "Nightfang Widow",
                "Shadowcrystal Widow",
                "Glacial Hellcharger",
            },
            amount = 35,
            fromPos = Position(32847, 33173, 7),
            toPos = Position(33067, 33294, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap3-3",
            requiredLevel = 5,
            createOnStartup = true,
            monsterNames = {
                "Ashfang Wyrm",
                "Bloodspark Adept",
                "Nightfang Widow",
                "Shadowcrystal Widow",
                "Glacial Hellcharger",
            },
            amount = 25,
            fromPos = Position(32911, 33044, 8),
            toPos = Position(33073, 33241, 8),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap4",
            requiredLevel = 5,
            createOnStartup = true,
            monsterNames = {
                "Shadowvein Wyrm",
                "Umbral Arcanist",
                "Duskhorn Drake",
                "Blooshade Reaper",
                "Nightflare Dreadknight",
            },
            amount = 25,
            fromPos = Position(33112, 33168, 7),
            toPos = Position(33303, 33308, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap4-4",
            requiredLevel = 5,
            createOnStartup = true,
            monsterNames = {
                "Shadowvein Wyrm",
                "Umbral Arcanist",
                "Duskhorn Drake",
                "Blooshade Reaper",
                "Nightflare Dreadknight",
            },
            amount = 25,
            fromPos = Position(33156, 33305, 8),
            toPos = Position(33349, 33453, 8),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap5",
            requiredLevel = 6,
            createOnStartup = true,
            monsterNames = {
                "Hellmaw Brute",
                "Viridscale Wyrm",
                "Plague Warbringer",
                "Mirethorn Hexer",
                "Mossfang Drake",
            },
            amount = 25,
            fromPos = Position(33351, 33170, 7),
            toPos = Position(33556, 33356, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap5-5",
            requiredLevel = 6,
            createOnStartup = true,
            monsterNames = {
                "Hellmaw Brute",
                "Viridscale Wyrm",
                "Plague Warbringer",
                "Mirethorn Hexer",
                "Mossfang Drake",
            },
            amount = 25,
            fromPos = Position(32930, 32960, 7),
            toPos = Position(33245, 33129, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap6",
            requiredLevel = 6,
            createOnStartup = true,
            monsterNames = {
                "Stormvein Wyrm",
                "Waterglow Conjurer",
                "Embermaw Archon",
                "Pitlord Incarnate",
                "Inferno Juggernaut",
            },
            amount = 25,
            fromPos = Position(32890, 33257, 8),
            toPos = Position(33107, 33437, 8),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
        {
            name = "WaystoneMap6-6",
            requiredLevel = 6,
            createOnStartup = true,
            monsterNames = {
                "Stormvein Wyrm",
                "Waterglow Conjurer",
                "Embermaw Archon",
                "Pitlord Incarnate",
                "Inferno Juggernaut",
            },
            amount = 25,
            fromPos = Position(33124, 33376, 7),
            toPos = Position(33395, 33582, 7),
            maxPerRow = 2,
            shuffleRows = true,
            extendedSpawn = false,
            forceSpawn = true,
            spawnInterval = 60000,
        },
    },
}

local EQUIPPED_SLOTS = {
    CONST_SLOT_HEAD,
    CONST_SLOT_NECKLACE,
    CONST_SLOT_BACKPACK,
    CONST_SLOT_ARMOR,
    CONST_SLOT_RIGHT,
    CONST_SLOT_LEFT,
    CONST_SLOT_LEGS,
    CONST_SLOT_FEET,
    CONST_SLOT_RING,
    CONST_SLOT_AMMO,
    CONST_SLOT_DECK,
    CONST_SLOT_BADGE,
    CONST_SLOT_SHIP,
    CONST_SLOT_BELT,
    CONST_SLOT_GLOVES,
}

local hiddenVeilstoneState = hiddenVeilstoneState or {
    monstersByPlayer = {},
    monsterIdsByPack = {},
    nextSpawnAtByPack = {},
}
hiddenVeilstoneState.monstersByPlayer = hiddenVeilstoneState.monstersByPlayer or {}
hiddenVeilstoneState.monsterIdsByPack = hiddenVeilstoneState.monsterIdsByPack or {}
hiddenVeilstoneState.nextSpawnAtByPack = hiddenVeilstoneState.nextSpawnAtByPack or {}
if type(hiddenVeilstoneState.monsterIds) == "table" and #hiddenVeilstoneState.monsterIds > 0 and #hiddenVeilstoneState.monsterIdsByPack == 0 then
    hiddenVeilstoneState.monsterIdsByPack[1] = hiddenVeilstoneState.monsterIds
end
hiddenVeilstoneState.monsterIds = nil

local warnedMissingMonster = false
local warnedLegacyVisibility = false

local function debugPrint(message)
    if HiddenVeilstone.debug then
        print(message)
    end
end

local function clampNumber(value, fallback)
    value = tonumber(value)
    if not value then
        return fallback
    end
    return value
end

local function warnLegacyVisibility()
    if warnedLegacyVisibility then
        return
    end

    warnedLegacyVisibility = true
    print("[HiddenVeilstone] Keyed visibility Lua methods are unavailable on this server binary. Falling back to generic gem visibility until the server is rebuilt.")
end

local function applyVisibilityGemKey(creature, gemKey)
    if creature and creature.setVisibilityGemKey then
        creature:setVisibilityGemKey(gemKey)
    else
        warnLegacyVisibility()
    end
end

local function setPlayerVisibilityGemLevelCompat(player, gemKey, level)
    if player and player.setVisibilityGemLevel then
        player:setVisibilityGemLevel(gemKey, level)
    else
        warnLegacyVisibility()
        player:setVisibilityGem(level > 0)
        player:setVisibilityProgressionTier(level)
    end
end

local function getMonsterPacks()
    if type(HiddenVeilstone.monsterPacks) == "table" and #HiddenVeilstone.monsterPacks > 0 then
        return HiddenVeilstone.monsterPacks
    end

    if type(HiddenVeilstone.monsters) == "table" then
        return { HiddenVeilstone.monsters }
    end

    return {}
end

local function getConfiguredMonsterNames(config)
    local names = {}

    if type(config) == "table" and type(config.monsterNames) == "table" then
        for _, name in ipairs(config.monsterNames) do
            if type(name) == "string" and name ~= "" then
                names[#names + 1] = name
            end
        end
    end

    if #names == 0 and type(config) == "table" and type(config.monsterName) == "string" and config.monsterName ~= "" then
        names[1] = config.monsterName
    end

    return names
end

local function getRandomConfiguredMonsterName(config)
    local names = getConfiguredMonsterNames(config)
    if #names == 0 then
        return nil
    end

    return names[math.random(#names)]
end

local function getShortestSpawnInterval()
    local shortest = 30000
    for _, config in ipairs(getMonsterPacks()) do
        if type(config) == "table" and config.createOnStartup ~= false then
            local interval = math.max(1000, clampNumber(config.spawnInterval, 30000))
            shortest = math.min(shortest, interval)
        end
    end
    return shortest
end

local function getSocketGemLevel(item, socketIndex)
    if type(_G.GemsSocket_getSocketGemLevel) == "function" then
        return _G.GemsSocket_getSocketGemLevel(item, socketIndex)
    end

    return math.max(1, clampNumber(item:getCustomAttribute(string.format("socket_%d_level", socketIndex)), 1))
end

local function getHighestVeilstoneLevel(player)
    if not player or not player:isPlayer() then
        return 0
    end

    if type(_G.GemsSocket_getEquippedGemMaxLevel) == "function" then
        return _G.GemsSocket_getEquippedGemMaxLevel(player, HiddenVeilstone.gemKey)
    end

    local highestLevel = 0
    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            local socketCount = clampNumber(item:getCustomAttribute("socket_count"), 0)
            for socketIndex = 1, socketCount do
                if item:getCustomAttribute(string.format("socket_%d_gem", socketIndex)) == HiddenVeilstone.gemKey then
                    highestLevel = math.max(highestLevel, getSocketGemLevel(item, socketIndex))
                end
            end
        end
    end

    return highestLevel
end

local function getAreaPositions(fromPos, toPos)
    local positions = {}
    local minX = math.min(fromPos.x, toPos.x)
    local maxX = math.max(fromPos.x, toPos.x)
    local minY = math.min(fromPos.y, toPos.y)
    local maxY = math.max(fromPos.y, toPos.y)
    local z = fromPos.z

    for x = minX, maxX do
        for y = minY, maxY do
            positions[#positions + 1] = Position(x, y, z)
        end
    end

    return positions
end

local function shuffleArray(values)
    for i = #values, 2, -1 do
        local j = math.random(i)
        values[i], values[j] = values[j], values[i]
    end
    return values
end

local function getAreaRows(fromPos, toPos)
    local rows = {}
    local minX = math.min(fromPos.x, toPos.x)
    local maxX = math.max(fromPos.x, toPos.x)
    local minY = math.min(fromPos.y, toPos.y)
    local maxY = math.max(fromPos.y, toPos.y)
    local z = fromPos.z

    for y = minY, maxY do
        local row = {}
        for x = minX, maxX do
            row[#row + 1] = Position(x, y, z)
        end
        rows[#rows + 1] = row
    end

    return rows
end

local function isSpawnableMonsterTile(position)
    local tile = Tile(position)
    if not tile then
        return false
    end

    if not tile:getGround() then
        return false
    end

    if tile:hasFlag(TILESTATE_BLOCKSOLID) or tile:hasFlag(TILESTATE_BLOCKPATH) then
        return false
    end

    if tile:getTopCreature() then
        return false
    end

    return true
end

local function ensureHiddenMonsters(allowSpawn, forceSpawnNow)
    local monsters = {}
    local spawnedAny = false
    local now = os.time()

    for packIndex, config in ipairs(getMonsterPacks()) do
        if type(config) == "table" then
            hiddenVeilstoneState.monsterIdsByPack[packIndex] = hiddenVeilstoneState.monsterIdsByPack[packIndex] or {}

            local requiredLevel = math.max(1, clampNumber(config.requiredLevel, 2))
            local keptIds = {}
            local packMonsters = {}

            for _, monsterId in ipairs(hiddenVeilstoneState.monsterIdsByPack[packIndex]) do
                local monster = Monster(monsterId)
                if monster and not monster:isRemoved() then
                    monster:setVisibilityRestricted(true)
                    monster:setVisibilityRequiresGem(true)
                    applyVisibilityGemKey(monster, HiddenVeilstone.gemKey)
                    monster:setVisibilityProgressionTier(requiredLevel)
                    keptIds[#keptIds + 1] = monsterId
                    packMonsters[#packMonsters + 1] = monster
                    monsters[#monsters + 1] = {
                        monster = monster,
                        requiredLevel = requiredLevel,
                    }
                end
            end

            hiddenVeilstoneState.monsterIdsByPack[packIndex] = keptIds

            local spawnIntervalSeconds = math.max(1, math.ceil(clampNumber(config.spawnInterval, 30000) / 1000))
            local nextSpawnAt = tonumber(hiddenVeilstoneState.nextSpawnAtByPack[packIndex]) or 0
            local canSpawnByTime = forceSpawnNow or now >= nextSpawnAt

            if allowSpawn and config.createOnStartup ~= false and canSpawnByTime then
                local missingCount = math.max(0, clampNumber(config.amount, 0) - #packMonsters)

                if missingCount > 0 then
                    local rows = getAreaRows(config.fromPos, config.toPos)
                    if config.shuffleRows ~= false then
                        shuffleArray(rows)
                    end

                    local maxPerRow = math.max(1, clampNumber(config.maxPerRow, 2))

                    while missingCount > 0 do
                        local spawnedThisPass = false

                        for _, row in ipairs(rows) do
                            if missingCount <= 0 then
                                break
                            end

                            local positions = {}
                            for _, position in ipairs(row) do
                                positions[#positions + 1] = position
                            end
                            shuffleArray(positions)

                            local rowSpawned = 0
                            for _, position in ipairs(positions) do
                                if missingCount <= 0 or rowSpawned >= maxPerRow then
                                    break
                                end

                                if isSpawnableMonsterTile(position) then
                                    local monsterName = getRandomConfiguredMonsterName(config)
                                    if not monsterName then
                                        if not warnedMissingMonster then
                                            debugPrint("[HiddenVeilstone] No hidden monster names configured.")
                                            warnedMissingMonster = true
                                        end
                                        return monsters, spawnedAny
                                    end

                                    local monster = Game.createMonster(
                                        monsterName,
                                        position,
                                        config.extendedSpawn == true,
                                        config.forceSpawn ~= false
                                    )
                                    if monster then
                                        monster:setVisibilityRestricted(true)
                                        monster:setVisibilityRequiresGem(true)
                                        applyVisibilityGemKey(monster, HiddenVeilstone.gemKey)
                                        monster:setVisibilityProgressionTier(requiredLevel)
                                        hiddenVeilstoneState.monsterIdsByPack[packIndex][#hiddenVeilstoneState.monsterIdsByPack[packIndex] + 1] = monster:getId()
                                        packMonsters[#packMonsters + 1] = monster
                                        monsters[#monsters + 1] = {
                                            monster = monster,
                                            requiredLevel = requiredLevel,
                                        }
                                        missingCount = missingCount - 1
                                        rowSpawned = rowSpawned + 1
                                        spawnedThisPass = true
                                        spawnedAny = true
                                    end
                                end
                            end
                        end

                        if not spawnedThisPass then
                            break
                        end
                    end
                end

                hiddenVeilstoneState.nextSpawnAtByPack[packIndex] = now + spawnIntervalSeconds
            end
        end
    end

    return monsters, spawnedAny
end

local function syncCreatureAccessForPlayer(player, creature, shouldEnable, stateTable)
    if not player or not creature then
        return
    end

    local playerId = player:getId()
    stateTable[playerId] = stateTable[playerId] or {}
    local previous = stateTable[playerId][creature:getId()] == true

    if shouldEnable then
        creature:addSeenByPlayer(player)
        player:addSeenCreature(creature)
        stateTable[playerId][creature:getId()] = true
    else
        creature:removeSeenByPlayer(player)
        player:removeSeenCreature(creature)
        stateTable[playerId][creature:getId()] = nil
        if not next(stateTable[playerId]) then
            stateTable[playerId] = nil
        end
        player:syncCreatureVisibility(creature, false, true)
    end

    if previous ~= shouldEnable and shouldEnable then
        player:syncCreatureVisibility(creature, false)
    end
end

local function refreshMonsterAccess(player, veilstoneLevel)
    local monsters = ensureHiddenMonsters(false)

    local playerState = hiddenVeilstoneState.monstersByPlayer[player:getId()]
    local seenNow = {}

    for _, entry in ipairs(monsters) do
        local monster = entry.monster
        if monster and not monster:isRemoved() then
            seenNow[monster:getId()] = true
            syncCreatureAccessForPlayer(
                player,
                monster,
                veilstoneLevel >= clampNumber(entry.requiredLevel, 2),
                hiddenVeilstoneState.monstersByPlayer
            )
        end
    end

    if playerState then
        for monsterId in pairs(playerState) do
            if not seenNow[monsterId] then
                playerState[monsterId] = nil
            end
        end
        if not next(playerState) then
            hiddenVeilstoneState.monstersByPlayer[player:getId()] = nil
        end
    end
end

local function refreshPlayerAccess(player)
    if not player or not player:isPlayer() then
        return
    end

    local veilstoneLevel = getHighestVeilstoneLevel(player)
    setPlayerVisibilityGemLevelCompat(player, HiddenVeilstone.gemKey, veilstoneLevel)
    refreshMonsterAccess(player, veilstoneLevel)
end

function _G.GemsSocket_refreshHiddenVeilstoneUnlocks(player)
    refreshPlayerAccess(player)
    return true
end

function _G.GemsSocket_refreshHiddenNpcUnlocks(player)
    return _G.GemsSocket_refreshHiddenVeilstoneUnlocks(player)
end

local hiddenVeilstoneStartup = GlobalEvent("GemsSocketHiddenVeilstoneStartup")

function hiddenVeilstoneStartup.onStartup()
    ensureHiddenMonsters(true, true)
    return true
end

hiddenVeilstoneStartup:register()

local hiddenVeilstoneSpawner = GlobalEvent("GemsSocketHiddenVeilstoneSpawner")

function hiddenVeilstoneSpawner.onThink(interval)
    local _, spawnedAny = ensureHiddenMonsters(true)
    if spawnedAny then
        for _, player in ipairs(Game.getPlayers()) do
            refreshPlayerAccess(player)
        end
    end
    return true
end

hiddenVeilstoneSpawner:interval(getShortestSpawnInterval())
hiddenVeilstoneSpawner:register()

local hiddenVeilstoneLogin = CreatureEvent("GemsSocketHiddenVeilstoneLogin")

function hiddenVeilstoneLogin.onLogin(player)
    _G.GemsSocket_refreshHiddenVeilstoneUnlocks(player)
    return true
end

hiddenVeilstoneLogin:type("login")
hiddenVeilstoneLogin:register()

local hiddenVeilstoneItemMoved = EventCallback

function hiddenVeilstoneItemMoved.onItemMoved(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    if type(_G.GemsSocket_refreshPlayerBonuses) ~= "function"
        and (type(_G.GemsSocket_isEquipmentPosition) ~= "function"
            or _G.GemsSocket_isEquipmentPosition(fromPosition)
            or _G.GemsSocket_isEquipmentPosition(toPosition)) then
        _G.GemsSocket_refreshHiddenVeilstoneUnlocks(player)
    end
end

hiddenVeilstoneItemMoved:register()
