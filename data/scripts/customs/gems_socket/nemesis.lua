-- Nemesis hidden altar bosses.
-- Hidden altars are spread across configured regions. Only players with the
-- required Nemesis Gem level can see/use them, and spawned bosses inherit the
-- same visibility rules.

local HiddenAltarBosses = {
    gemKey = "nemesis",
    altarItemId = 30665,
    debug = false,
    refreshInterval = 30 * 60 * 1000,
    maxAttemptsPerAltar = 450,
    minDistanceBetweenAltars = 120,
    requiredClearDistance = 1,
    bossSpawnMinDistance = 2,
    bossSpawnMaxDistance = 5,
    bossLifetimeSeconds = 15 * 60,

    scaling = {
        healthPerLevel = 0.12,
        damagePerLevel = 0.08,
        speedPerLevel = 0.02,
    },
    bosses = {
        [1] = { "Sir Baeloc", "Sir Nictros", "Vladrukh", "The Paleworm", "The Dreadmaiden", "Mazzinor", "Apocalypse", "Hellgorak" },
        [2] = { "Orshabaal", "Deathstrike", "Morgaroth", "Plagirath", "Candy Fairy", "Chagorz", "Sugar Daddy", "Gaffir" },
        [3] = { "Ferumbras", "Ghazbaran", "Prince Drazzak", "Vemiath", "Prince Skeletal", "The Rootkraken", "The Fear Feaster" },
        [4] = { "Goshnar's Malice", "Omrafir", "Gaz'haragoth", "The Scourge of Oblivion", "Feroxa", "Bragrumol", "King Zelos" },
        [5] = { "Lord Azaram", "Urmahlullu The Weakened", "Ghulosh", "Gravexon The Devourer", "Azazel the Infernal Seraph", "The Rootkraken", "Zorgrath the Carrion" },
        [6] = { "Bakragore", "Goshnar's Megalomania", "Forbidden Chevalier", "Kraxxis the Corruptor", "Dreadbone the Eternal", "Mortis the sovereign", "Thalador Stormbringer", "Gravexon The Devourer", "Feroxa", "Omrafir", "Gaz'haragoth", "Prince Drazzak", "Vemiath", "Morgaroth", "Orshabaal", "Ferumbras", "The Fear Feaster", "Apocalypse", "The Scourge of Oblivion", "King Zelos"},
    },

    regions = {
        {
            name = "Thais big Part",
            fromPos = Position(32177, 31968, 7),
            toPos = Position(33139, 32341, 7),
            quantity = 4,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Second Big Zone",
            fromPos = Position(32936, 30997, 7),
            toPos = Position(34094, 32126, 7),
            quantity = 10,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Another Big Zone",
            fromPos = Position(32492, 32220, 7),
            toPos = Position(33287, 32932, 7),
            quantity = 9,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Isles",
            fromPos = Position(30694, 30910, 7),
            toPos = Position(31663, 31449, 7),
            quantity = 5,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Main Land",
            fromPos = Position(30693, 30914, 7),
            toPos = Position(33902, 33629, 7),
            quantity = 30,
            minLevel = 2,
            maxLevel = 6,
        },
        {
            name = "Thais big Part",
            fromPos = Position(32177, 31968, 8),
            toPos = Position(33139, 32341, 8),
            quantity = 4,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Second Big Zone",
            fromPos = Position(32936, 30997, 8),
            toPos = Position(34094, 32126, 8),
            quantity = 4,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Another Big Zone",
            fromPos = Position(32492, 32220, 9),
            toPos = Position(33287, 32932, 9),
            quantity = 4,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Isles",
            fromPos = Position(30694, 30910, 8),
            toPos = Position(31663, 31449, 8),
            quantity = 2,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Main Land",
            fromPos = Position(30693, 30914, 10),
            toPos = Position(33902, 33629, 10),
            quantity = 10,
            minLevel = 2,
            maxLevel = 6,
        },
    },

    forbiddenItemIds = {
        [30651] = true,
        [30671] = true,

        -- Existing profession resource ids, so altars do not stack with them.
        [26405] = true, [26406] = true, [26407] = true, [26408] = true, [26409] = true, [26410] = true, [26411] = true,
        [26604] = true, [26605] = true, [26606] = true, [26607] = true, [26608] = true, [26609] = true, [26610] = true,
        [26611] = true, [26612] = true, [26613] = true, [26614] = true, [26615] = true, [26634] = true, [26635] = true, [26636] = true,
        [26717] = true, [26718] = true, [26719] = true, [26720] = true, [26721] = true, [26722] = true, [26723] = true, [26724] = true,
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

local altarState = {
    nextId = 1,
    altars = {},
    activeBosses = {},
    playerLevels = {},
}

local warnedLegacyVisibility = false

local function debugPrint(message)
    if HiddenAltarBosses.debug then
        print(message)
    end
end

local function warnLegacyVisibility()
    if warnedLegacyVisibility then
        return
    end

    warnedLegacyVisibility = true
    print("[HiddenAltarBosses] Keyed visibility Lua methods are unavailable on this server binary. Falling back to generic gem visibility until the server is rebuilt.")
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

local function refreshVisibilityTileCompat(player, position)
    if player and player.refreshVisibilityTile then
        player:refreshVisibilityTile(position)
    else
        warnLegacyVisibility()
    end
end

local function applyVisibilityGemKey(creature, gemKey)
    if creature and creature.setVisibilityGemKey then
        creature:setVisibilityGemKey(gemKey)
    else
        warnLegacyVisibility()
    end
end

debugPrint("[HiddenAltarBosses] Script loaded.")

local function clampNumber(value, minValue, maxValue)
    value = tonumber(value) or minValue or 0
    if minValue and value < minValue then
        value = minValue
    end
    if maxValue and value > maxValue then
        value = maxValue
    end
    return value
end

local function getSocketGemLevel(item, socketIndex)
    if type(_G.GemsSocket_getSocketGemLevel) == "function" then
        return _G.GemsSocket_getSocketGemLevel(item, socketIndex)
    end

    return math.max(1, clampNumber(item:getCustomAttribute(string.format("socket_%d_level", socketIndex)), 1))
end

local function getHighestNemesisLevel(player)
    if not player or not player:isPlayer() then
        return 0
    end

    if type(_G.GemsSocket_getEquippedGemMaxLevel) == "function" then
        return _G.GemsSocket_getEquippedGemMaxLevel(player, HiddenAltarBosses.gemKey)
    end

    local highestLevel = 0
    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            local socketCount = clampNumber(item:getCustomAttribute("socket_count"), 0)
            for socketIndex = 1, socketCount do
                if item:getCustomAttribute(string.format("socket_%d_gem", socketIndex)) == HiddenAltarBosses.gemKey then
                    highestLevel = math.max(highestLevel, getSocketGemLevel(item, socketIndex))
                end
            end
        end
    end

    return highestLevel
end

local function syncActiveBossVisibility(player)
    for monsterId in pairs(altarState.activeBosses) do
        local monster = Monster(monsterId)
        if monster and not monster:isRemoved() then
            player:syncCreatureVisibility(monster, false, true)
        end
    end
end

local function refreshPlayerVisibilityState(player)
    if not player or not player:isPlayer() then
        return 0
    end

    local level = getHighestNemesisLevel(player)
    setPlayerVisibilityGemLevelCompat(player, HiddenAltarBosses.gemKey, level)

    local playerGuid = player:getGuid()
    if altarState.playerLevels[playerGuid] ~= level then
        altarState.playerLevels[playerGuid] = level
        for _, altar in pairs(altarState.altars) do
            if altar.position then
                refreshVisibilityTileCompat(player, altar.position)
            end
        end
        syncActiveBossVisibility(player)
    end

    return level
end

function _G.HiddenAltarBosses_refreshPlayerVisibilityState(player)
    return refreshPlayerVisibilityState(player)
end

local function tileHasForbiddenItem(tile)
    for _, item in ipairs(tile:getItems() or {}) do
        if HiddenAltarBosses.forbiddenItemIds[item:getId()] then
            return true
        end
    end
    return false
end

local function getClearTileBlockReason(pos)
    local tile = Tile(pos)
    if not tile or not tile:getGround() then
        return "no ground"
    end

    if tile:getHouse() then
        return "house"
    end

    if tile:hasFlag(TILESTATE_PROTECTIONZONE)
        or tile:hasFlag(TILESTATE_TELEPORT)
        or tile:hasFlag(TILESTATE_FLOORCHANGE)
        or tile:hasFlag(TILESTATE_DEPOT)
        or tile:hasFlag(TILESTATE_BLOCKSOLID)
        or tile:hasFlag(TILESTATE_BLOCKPATH)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKSOLID)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKPATH) then
        return "tile flag blocked"
    end

    local info = getTileInfo(pos)
    if not info then
        return "missing tile info"
    end
    if info.creatures > 0 then
        return "creature on tile"
    end
    if info.items > 0 then
        return "item on tile"
    end

    if tileHasForbiddenItem(tile) then
        return "forbidden item"
    end

    return nil
end

local function isClearTile(pos)
    return getClearTileBlockReason(pos) == nil
end

local function getCardinalClearanceBlockReason(pos, distance)
    local offsets = {
        { x = 0, y = -1 },
        { x = 0, y = 1 },
        { x = -1, y = 0 },
        { x = 1, y = 0 },
    }

    for _, offset in ipairs(offsets) do
        for step = 1, distance do
            local checkPos = Position(pos.x + (offset.x * step), pos.y + (offset.y * step), pos.z)
            local reason = getClearTileBlockReason(checkPos)
            if reason then
                return string.format("clearance %s at %d,%d,%d", reason, checkPos.x, checkPos.y, checkPos.z)
            end
        end
    end
    return nil
end

local function hasCardinalClearance(pos, distance)
    return getCardinalClearanceBlockReason(pos, distance) == nil
end

local function isValidAltarPosition(pos)
    return isClearTile(pos) and hasCardinalClearance(pos, HiddenAltarBosses.requiredClearDistance)
end

local function getAltarPositionBlockReason(pos)
    local reason = getClearTileBlockReason(pos)
    if reason then
        return reason
    end

    return getCardinalClearanceBlockReason(pos, HiddenAltarBosses.requiredClearDistance)
end

local function getDistance2d(first, second)
    return math.max(math.abs(first.x - second.x), math.abs(first.y - second.y))
end

local function isFarEnoughFromAltars(pos)
    for _, altar in pairs(altarState.altars) do
        if altar.position and altar.position.z == pos.z and getDistance2d(altar.position, pos) < HiddenAltarBosses.minDistanceBetweenAltars then
            return false
        end
    end
    return true
end

local function shuffle(list)
    for index = #list, 2, -1 do
        local swapIndex = math.random(index)
        list[index], list[swapIndex] = list[swapIndex], list[index]
    end
end

local function buildSectorCandidates(region, count)
    local candidates = {}
    local fromPos = region.fromPos
    local toPos = region.toPos
    local columns = math.max(1, math.ceil(math.sqrt(count)))
    local rows = math.max(1, math.ceil(count / columns))
    local width = math.max(1, toPos.x - fromPos.x + 1)
    local height = math.max(1, toPos.y - fromPos.y + 1)

    for row = 0, rows - 1 do
        for column = 0, columns - 1 do
            candidates[#candidates + 1] = {
                fromX = fromPos.x + math.floor((width * column) / columns),
                toX = fromPos.x + math.floor((width * (column + 1)) / columns) - 1,
                fromY = fromPos.y + math.floor((height * row) / rows),
                toY = fromPos.y + math.floor((height * (row + 1)) / rows) - 1,
                z = fromPos.z,
            }
        end
    end

    shuffle(candidates)
    return candidates
end

local function createHiddenAltar(pos, level, regionName)
    local item = Game.createItem(HiddenAltarBosses.altarItemId, 1, pos)
    if not item then
        debugPrint(string.format("[HiddenAltarBosses] Failed to create altar item %d at %d,%d,%d.", HiddenAltarBosses.altarItemId, pos.x, pos.y, pos.z))
        return false
    end

    local altarId = altarState.nextId
    altarState.nextId = altarState.nextId + 1

    item:setCustomAttribute("hidden_altar_id", altarId)
    item:setCustomAttribute("visibility_requires_gem", true)
    item:setCustomAttribute("visibility_gem_key", HiddenAltarBosses.gemKey)
    item:setCustomAttribute("visibility_tier", level)
    item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, string.format("A veiled altar hums with level %d energy.", level))

    altarState.altars[altarId] = {
        id = altarId,
        position = Position(pos.x, pos.y, pos.z),
        level = level,
        regionName = regionName,
        bossId = 0,
        respawnAt = 0,
    }
    return true
end

local function spawnRegionAltars(region)
    local targetQuantity = clampNumber(region.quantity, 0)
    local spawned = 0
    local sectors = buildSectorCandidates(region, targetQuantity)
    local rejectReasons = {}
    local distanceRejected = 0

    for _, sector in ipairs(sectors) do
        if spawned >= targetQuantity then
            break
        end

        for _ = 1, HiddenAltarBosses.maxAttemptsPerAltar do
            local pos = Position(math.random(sector.fromX, sector.toX), math.random(sector.fromY, sector.toY), sector.z)
            local blockReason = getAltarPositionBlockReason(pos)
            if blockReason then
                rejectReasons[blockReason] = (rejectReasons[blockReason] or 0) + 1
            elseif not isFarEnoughFromAltars(pos) then
                distanceRejected = distanceRejected + 1
            else
                local level = math.random(clampNumber(region.minLevel, 1), clampNumber(region.maxLevel, 1))
                if createHiddenAltar(pos, level, region.name or "Unknown") then
                    spawned = spawned + 1
                    debugPrint(string.format("[HiddenAltarBosses] Spawned altar level %d at %d,%d,%d in '%s'.", level, pos.x, pos.y, pos.z, tostring(region.name)))
                end
                break
            end
        end
    end

    debugPrint(string.format("[HiddenAltarBosses] %s spawned %d / %d altars.", tostring(region.name), spawned, targetQuantity))
    if spawned < targetQuantity then
        local summary = {}
        for reason, count in pairs(rejectReasons) do
            summary[#summary + 1] = string.format("%s=%d", reason, count)
        end
        if distanceRejected > 0 then
            summary[#summary + 1] = string.format("too close to another altar=%d", distanceRejected)
        end
    end
end

local function cleanupMissingAltars()
    for altarId, altar in pairs(altarState.altars) do
        local tile = altar.position and Tile(altar.position)
        local found = false
        if tile then
            for _, item in ipairs(tile:getItems() or {}) do
                if item:getId() == HiddenAltarBosses.altarItemId and tonumber(item:getCustomAttribute("hidden_altar_id")) == altarId then
                    found = true
                    break
                end
            end
        end

        if not found and (tonumber(altar.bossId) or 0) <= 0 then
            altarState.altars[altarId] = nil
        end
    end
end

local function ensureAltars()
    cleanupMissingAltars()

    local activeByRegion = {}
    for _, altar in pairs(altarState.altars) do
        activeByRegion[altar.regionName] = (activeByRegion[altar.regionName] or 0) + 1
    end

    for _, region in ipairs(HiddenAltarBosses.regions) do
        local missing = clampNumber(region.quantity, 0) - (activeByRegion[region.name] or 0)
        if missing > 0 then
            local copy = {}
            for key, value in pairs(region) do
                copy[key] = value
            end
            copy.quantity = missing
            spawnRegionAltars(copy)
        end
    end
end

local function chooseBossName(level)
    local bestLevel = 1
    for configuredLevel in pairs(HiddenAltarBosses.bosses) do
        if configuredLevel <= level and configuredLevel > bestLevel then
            bestLevel = configuredLevel
        end
    end

    local names = HiddenAltarBosses.bosses[level] or HiddenAltarBosses.bosses[bestLevel]
    if not names or #names == 0 then
        return nil
    end
    return names[math.random(#names)]
end

local function findBossSpawnPosition(center)
    local positions = {}
    for radius = HiddenAltarBosses.bossSpawnMinDistance, HiddenAltarBosses.bossSpawnMaxDistance do
        for x = -radius, radius do
            for y = -radius, radius do
                if math.max(math.abs(x), math.abs(y)) == radius then
                    positions[#positions + 1] = Position(center.x + x, center.y + y, center.z)
                end
            end
        end
    end

    shuffle(positions)
    for _, pos in ipairs(positions) do
        if isClearTile(pos) then
            return pos
        end
    end
    return nil
end

local function scaleBoss(monster, level)
    local scaling = HiddenAltarBosses.scaling
    local healthMultiplier = 1 + ((tonumber(scaling.healthPerLevel) or 0) * math.max(0, level - 1))
    local speedMultiplier = 1 + ((tonumber(scaling.speedPerLevel) or 0) * math.max(0, level - 1))

    local maxHealth = math.max(1, math.floor(monster:getMaxHealth() * healthMultiplier))
    monster:setMaxHealth(maxHealth)
    monster:setHealth(maxHealth)

    local currentSpeed = monster:getSpeed()
    local targetSpeed = math.max(1, math.floor(currentSpeed * speedMultiplier))
    if targetSpeed ~= currentSpeed then
        monster:changeSpeed(targetSpeed - currentSpeed)
    end
end

local function getAltarByItem(item)
    if not item or item:getId() ~= HiddenAltarBosses.altarItemId then
        return nil
    end

    local altarId = tonumber(item:getCustomAttribute("hidden_altar_id")) or 0
    return altarId > 0 and altarState.altars[altarId] or nil
end

local function removeAltarItem(item)
    if item then
        item:remove()
    end
end

local function despawnExpiredBoss(monsterId, expectedSpawnTime)
    local data = altarState.activeBosses[monsterId]
    if not data or data.spawnedAt ~= expectedSpawnTime then
        return
    end

    local monster = Monster(monsterId)
    if monster and not monster:isRemoved() then
        monster:remove()
    end

    altarState.activeBosses[monsterId] = nil
    if data.altarId and altarState.altars[data.altarId] then
        altarState.altars[data.altarId] = nil
    end
end

local function spawnAltarBoss(player, altar, item)
    local level = clampNumber(altar.level, 1)
    local bossName = chooseBossName(level)
    if not bossName then
        player:sendCancelMessage("This altar has no boss configured.")
        return false
    end

    local spawnPos = findBossSpawnPosition(altar.position)
    if not spawnPos then
        player:sendCancelMessage("The altar cannot find enough space to open.")
        return false
    end

    local boss = Game.createMonster(bossName, spawnPos, true, true)
    if not boss then
        player:sendCancelMessage("The altar fails to summon its guardian.")
        return false
    end

    boss:setVisibilityRestricted(true)
    boss:setVisibilityRequiresGem(true)
    applyVisibilityGemKey(boss, HiddenAltarBosses.gemKey)
    boss:setVisibilityProgressionTier(level)
    scaleBoss(boss, level)

    if type(_G.GemsSocketVisibilitySyncQueue) == "table" then
        _G.GemsSocketVisibilitySyncQueue.enqueueMonster(boss)
    else
        for _, onlinePlayer in ipairs(Game.getPlayers()) do
            onlinePlayer:syncCreatureVisibility(boss, false, true)
        end
    end

    local bossId = boss:getId()
    local now = os.time()
    altar.bossId = bossId
    altarState.activeBosses[bossId] = {
        altarId = altar.id,
        ownerGuid = player:getGuid(),
        level = level,
        damageMultiplier = 1 + ((tonumber(HiddenAltarBosses.scaling.damagePerLevel) or 0) * math.max(0, level - 1)),
        spawnedAt = now,
    }

    removeAltarItem(item)
    altar.position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
    spawnPos:sendMagicEffect(CONST_ME_TELEPORT)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("The hidden altar awakens %s.", bossName))

    addEvent(despawnExpiredBoss, HiddenAltarBosses.bossLifetimeSeconds * 1000, bossId, now)
    return true
end

local altarAction = Action()

function altarAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local altar = getAltarByItem(item)
    if not altar then
        return false
    end

    local level = getHighestNemesisLevel(player)
    if level < altar.level then
        player:sendCancelMessage(string.format("The altar remains veiled. Nemesis Gem level %d is required.", altar.level))
        return true
    end

    if (tonumber(altar.bossId) or 0) > 0 and Monster(altar.bossId) then
        player:sendCancelMessage("This altar has already awakened.")
        return true
    end

    spawnAltarBoss(player, altar, item)
    return true
end

altarAction:id(HiddenAltarBosses.altarItemId)
altarAction:register()

local bossDamage = CreatureEvent("HiddenAltarBossDamage")

function bossDamage.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not attacker then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local data = altarState.activeBosses[attacker:getId()]
    if not data then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local multiplier = math.max(1, tonumber(data.damageMultiplier) or 1)
    if (tonumber(primaryDamage) or 0) ~= 0 then
        local scaled = math.floor(math.abs(primaryDamage) * multiplier)
        primaryDamage = primaryDamage < 0 and -scaled or scaled
    end
    if (tonumber(secondaryDamage) or 0) ~= 0 then
        local scaled = math.floor(math.abs(secondaryDamage) * multiplier)
        secondaryDamage = secondaryDamage < 0 and -scaled or scaled
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

bossDamage:register()

local bossKill = CreatureEvent("HiddenAltarBossKill")

function bossKill.onKill(player, target, lastHit)
    if not target or not target:isMonster() then
        return true
    end

    local monsterId = target:getId()
    local data = altarState.activeBosses[monsterId]
    if not data then
        return true
    end

    altarState.activeBosses[monsterId] = nil
    if data.altarId and altarState.altars[data.altarId] then
        altarState.altars[data.altarId] = nil
    end
    return true
end

bossKill:register()

local playerLogin = CreatureEvent("HiddenAltarBossLogin")

function playerLogin.onLogin(player)
    refreshPlayerVisibilityState(player)
    player:registerEvent("HiddenAltarBossDamage")
    player:registerEvent("HiddenAltarBossKill")
    return true
end

playerLogin:type("login")
playerLogin:register()

local altarItemMoved = EventCallback

function altarItemMoved.onItemMoved(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    if type(_G.GemsSocket_refreshPlayerBonuses) ~= "function"
        and (type(_G.GemsSocket_isEquipmentPosition) ~= "function"
            or _G.GemsSocket_isEquipmentPosition(fromPosition)
            or _G.GemsSocket_isEquipmentPosition(toPosition)) then
        refreshPlayerVisibilityState(player)
    end
end

altarItemMoved:register()

local startup = GlobalEvent("HiddenAltarBossStartup")

local function validateBossConfig()
    for level, names in pairs(HiddenAltarBosses.bosses) do
        for _, bossName in ipairs(names) do
            local monsterType = MonsterType(bossName)
            if not monsterType then
                debugPrint(string.format("[HiddenAltarBosses][WARNING] Missing boss monster '%s' at level %d.", tostring(bossName), level))
            elseif monsterType.isRewardBoss and not monsterType:isRewardBoss() then
                debugPrint(string.format("[HiddenAltarBosses][WARNING] Boss '%s' is not marked isRewardBoss. Reward chest may not work.", tostring(bossName)))
            end
        end
    end
end

function startup.onStartup()
    debugPrint("[HiddenAltarBosses] Startup ensure started.")
    validateBossConfig()
    ensureAltars()
    return true
end

startup:register()

local think = GlobalEvent("HiddenAltarBossThink")

function think.onThink(interval)
    for _, player in ipairs(Game.getPlayers()) do
        refreshPlayerVisibilityState(player)
    end
    ensureAltars()
    return true
end

think:interval(HiddenAltarBosses.refreshInterval)
think:register()

addEvent(function()
    debugPrint("[HiddenAltarBosses] Delayed ensure started.")
    ensureAltars()
end, 5000)
