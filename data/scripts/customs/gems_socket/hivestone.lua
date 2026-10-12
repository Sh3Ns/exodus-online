-- Hive Stone hidden altars.
-- Similar to Nemesis altars, but altars release timed monster waves instead of a boss.

local HiddenHiveStone = {
    gemKey = "hivestone",
    altarItemId = 30664,
    debug = false,
    refreshInterval = 30 * 60 * 1000,
    encounterDurationSeconds = 15 * 60,
    minDistanceBetweenAltars = 100,
    maxAttemptsPerAltar = 350,

    waves = {
        [1] = {
            { delay = 0, monsters = { "Alpha Demon", "Aberration of the Depths", "Azure Guard" } },
            { delay = 30, monsters = { "Black Dragon", "Brontosaurus", "Butcher Ogre" } },
            { delay = 60, monsters = { "Colossal Ice Monkey", "Demon of the Depths", "Giant Hornet" } },
            { delay = 90, monsters = { "Netheria Dragon", "Reflect Spider", "Rhino of the Depths" } },
            { delay = 120, monsters = { "Ruthless Spider", "Skullcrusher Demon", "Venom Spider" } },
            { delay = 150, monsters = { "Venom Spider", "Alpha Demon", "Demon of the Depths", "Giant Hornet", "Reflect Spider", "Rhino of the Depths" } },
        },
        [2] = {
            { delay = 0, monsters = { "Cobra Assassin", "Falcon Knight", "Cursed Prospector" } },
            { delay = 30, monsters = { "Cobra Scout", "Falcon Paladin", "Evil Prospector" } },
            { delay = 60, monsters = { "Cobra Vizier", "Falcon Knight", "Falcon Paladin", "Flimsy Lost Soul" } },
            { delay = 90, monsters = { "Perceptor Lazare", "Custodian", "Cobra Scout", "Falcon Knight" } },
            { delay = 120, monsters = { "Flimsy Lost Soul", "Freakish Lost Soul", "Cursed Prospector", "Evil Prospector" } },
            { delay = 150, monsters = { "Falcon Knight", "Falcon Paladin", "Freakish Lost Soul", "Cobra Scout", "Cobra Vizier", "Cobra Assassin", "Evil Prospector" } },
        },
        [3] = {
            { delay = 0, monsters = { "Bulltauren Alchemist", "Mega Dragon", "Mitmah Vanguard" } },
            { delay = 30, monsters = { "Tauren Herk", "Wardragon", "Bulltauren Brute" } },
            { delay = 60, monsters = { "Bulltauren Forgepriest", "Mega Dragon", "Tauren Herk" } },
            { delay = 90, monsters = { "Bone Mage", "Bulltauren Alchemist", "Bone Ruthless", "Bone Slicer", "Bone Warrior", "Bone Scarvenger" } },
            { delay = 120, monsters = { "Bone Knight", "Bone Mage", "Bulltauren Brute", "Mitmah Vanguard", "Mega Dragon", "Wardragon" } },
            { delay = 150, monsters = { "Bone Master", "Bone Knight", "Bone Berserker", "Bulltauren Forgepriest", "Wardragon", "Bone Slicer" } },
        },
        [4] = {
            { delay = 0, monsters = { "Burning Book", "Cursed Book", "Icecold Book" } },
            { delay = 30, monsters = { "Brain Squid", "Energetic Book", "Rage Squid" } },
            { delay = 60, monsters = { "Guardin of Tales", "Energuardian of Tales", "Burning Book" } },
            { delay = 90, monsters = { "Squid Warden", "Rage Squid", "Brain Squid", "Floating Savant" } },
            { delay = 120, monsters = { "Animated Feather", "Brain Squid", "Rage Squid", "Floating Savant", "Cursed Book" } },
            { delay = 150, monsters = { "Knowledge Elemental", "Guardin of Tales", "Brain Squid", "Rage Squid", "Squid Warden", "Icecold Book" } },
        },
        [5] = {
            { delay = 0, monsters = { "Bony Sea Devil", "Branchy Crawler", "Courage Leech" } },
            { delay = 30, monsters = { "Druid's Apparition", "Monk's Apparition", "Paladin's Apparition" } },
            { delay = 60, monsters = { "Rotten Golem", "Turbulent Elemental", "Cloak of Terror" } },
            { delay = 90, monsters = { "Capricious Phantom", "Distorted Phantom", "Hazardous Phantom", "Infernal Phantom", "Mould Phantom", "Vibrant Phantom" } },
            { delay = 120, monsters = { "Infernal Demon", "Many Faces", "Sorcerer's Apparition", "Infernal Demon", "Knight's Apparition", "Illusionist's Apparition" } },
            { delay = 150, monsters = { "Infernal Phantom", "Infernal Demon", "Many Faces", "Cloak of Terror", "Rotten Golem", "Branchy Crawler", "Turbulent Elemental", "Bony Sea Devil" } },
        },
        [6] = {
            { delay = 0, monsters = { "Ancient Root Tyrant", "Cinderheart Abomination", "Ironburrow Devourer" } },
            { delay = 30, monsters = { "Hive Widow", "Magmafang Incinerator", "Stonehide Ravager" } },
            { delay = 60, monsters = { "Venomcoil Automaton", "Void Ooze", "Dreadhorn Ravager" } },
            { delay = 90, monsters = { "Blacksteel Brute", "Arcaneseer Djinn", "Necroflame Idol", "Shardback Behemoth" } },
            { delay = 120, monsters = { "Stormfang Ravager", "Verdant Rootwalker", "Eldritch Devourer", "Dunestalker Hunter"  } },
            { delay = 150, monsters = { "Abyssal Nightreaver", "Ancient Moss Guardian", "Ashen Hellhound", "Cursed Voidcaller", "Emberflame Conjurer" } },
        },
    },

    regions = {
        {
            name = "Thais big Part",
            fromPos = Position(32177, 31968, 7),
            toPos = Position(33139, 32341, 7),
            quantity = 8,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Second Big Zone",
            fromPos = Position(32936, 30997, 7),
            toPos = Position(34094, 32126, 7),
            quantity = 18,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Another Big Zone",
            fromPos = Position(32492, 32220, 7),
            toPos = Position(33287, 32932, 7),
            quantity = 14,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Isles",
            fromPos = Position(30694, 30910, 7),
            toPos = Position(31663, 31449, 7),
            quantity = 10,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Main Land",
            fromPos = Position(30693, 30914, 7),
            toPos = Position(33902, 33629, 7),
            quantity = 40,
            minLevel = 2,
            maxLevel = 6,
        },
        {
            name = "Thais big Part",
            fromPos = Position(32177, 31968, 8),
            toPos = Position(33139, 32341, 8),
            quantity = 8,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Second Big Zone",
            fromPos = Position(32936, 30997, 10),
            toPos = Position(34094, 32126, 10),
            quantity = 10,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Another Big Zone",
            fromPos = Position(32492, 32220, 4),
            toPos = Position(33287, 32932, 4),
            quantity = 7,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Isles",
            fromPos = Position(30694, 30910, 8),
            toPos = Position(31663, 31449, 8),
            quantity = 7,
            minLevel = 1,
            maxLevel = 6,
        },
        {
            name = "Main Land",
            fromPos = Position(30693, 30914, 9),
            toPos = Position(33902, 33629, 9),
            quantity = 20,
            minLevel = 2,
            maxLevel = 6,
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

local state = {
    nextId = 1,
    altars = {},
    encounters = {},
    playerLevels = {},
}

local warnedLegacyVisibility = false

local function debugPrint(message)
    if HiddenHiveStone.debug then
        print(message)
    end
end

local function warnLegacyVisibility()
    if warnedLegacyVisibility then
        return
    end

    warnedLegacyVisibility = true
    print("[HiddenHiveStone] Keyed visibility Lua methods are unavailable on this server binary. Falling back to generic gem visibility until the server is rebuilt.")
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

local function getHighestHiveLevel(player)
    if not player or not player:isPlayer() then
        return 0
    end

    if type(_G.GemsSocket_getEquippedGemMaxLevel) == "function" then
        return _G.GemsSocket_getEquippedGemMaxLevel(player, HiddenHiveStone.gemKey)
    end

    local highest = 0
    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            local socketCount = clampNumber(item:getCustomAttribute("socket_count"), 0)
            for socketIndex = 1, socketCount do
                if item:getCustomAttribute(string.format("socket_%d_gem", socketIndex)) == HiddenHiveStone.gemKey then
                    highest = math.max(highest, getSocketGemLevel(item, socketIndex))
                end
            end
        end
    end
    return highest
end

local function refreshPlayerVisibilityState(player)
    if not player or not player:isPlayer() then
        return 0
    end

    local level = getHighestHiveLevel(player)
    setPlayerVisibilityGemLevelCompat(player, HiddenHiveStone.gemKey, level)

    local playerGuid = player:getGuid()
    if state.playerLevels[playerGuid] ~= level then
        state.playerLevels[playerGuid] = level
        for _, altar in pairs(state.altars) do
            if altar.position then
                refreshVisibilityTileCompat(player, altar.position)
            end
        end
        for _, encounter in pairs(state.encounters) do
            for monsterId in pairs(encounter.monsters or {}) do
                local monster = Monster(monsterId)
                if monster and not monster:isRemoved() then
                    player:syncCreatureVisibility(monster, false, true)
                end
            end
        end
    end
    return level
end

function _G.HiddenHiveStone_refreshPlayerVisibilityState(player)
    return refreshPlayerVisibilityState(player)
end

local function isClearTile(pos)
    local tile = Tile(pos)
    if not tile or tile:hasFlag(TILESTATE_BLOCKSOLID) or tile:getTopCreature() then
        return false
    end

    for _, item in ipairs(tile:getItems() or {}) do
        if item:getId() == HiddenHiveStone.altarItemId
            or item:getId() == 30651
            or item:getCustomAttribute("hidden_hive_altar_id")
            or item:getCustomAttribute("hidden_altar_id") then
            return false
        end
    end
    return true
end

local function hasEnoughCardinalClearance(pos)
    local checks = {
        Position(pos.x + 2, pos.y, pos.z),
        Position(pos.x - 2, pos.y, pos.z),
        Position(pos.x, pos.y + 2, pos.z),
        Position(pos.x, pos.y - 2, pos.z),
    }
    for _, checkPos in ipairs(checks) do
        if not isClearTile(checkPos) then
            return false
        end
    end
    return true
end

local function isFarFromOtherAltars(pos)
    for _, altar in pairs(state.altars) do
        if altar.position and altar.position.z == pos.z and altar.position:getDistance(pos) < HiddenHiveStone.minDistanceBetweenAltars then
            return false
        end
    end
    return true
end

local function createAltar(region, level, pos)
    local item = Game.createItem(HiddenHiveStone.altarItemId, 1, pos)
    if not item then
        return false
    end

    local altarId = state.nextId
    state.nextId = state.nextId + 1
    item:setCustomAttribute("hidden_hive_altar_id", altarId)
    item:setCustomAttribute("visibility_requires_gem", true)
    item:setCustomAttribute("visibility_gem_key", HiddenHiveStone.gemKey)
    item:setCustomAttribute("visibility_tier", level)

    state.altars[altarId] = {
        id = altarId,
        regionName = region.name,
        level = level,
        position = pos,
        encounterId = 0,
    }
    debugPrint(string.format("[HiddenHiveStone] Spawned altar %d level %d at %d,%d,%d", altarId, level, pos.x, pos.y, pos.z))
    return true
end

local function spawnRegionAltars(region)
    local spawned = 0
    local quantity = clampNumber(region.quantity, 0)
    for _ = 1, HiddenHiveStone.maxAttemptsPerAltar do
        if spawned >= quantity then
            break
        end

        local pos = Position(
            math.random(math.min(region.fromPos.x, region.toPos.x), math.max(region.fromPos.x, region.toPos.x)),
            math.random(math.min(region.fromPos.y, region.toPos.y), math.max(region.fromPos.y, region.toPos.y)),
            region.fromPos.z
        )
        local level = math.random(clampNumber(region.minLevel, 1), clampNumber(region.maxLevel, 1))
        if isClearTile(pos) and hasEnoughCardinalClearance(pos) and isFarFromOtherAltars(pos) and createAltar(region, level, pos) then
            spawned = spawned + 1
        end
    end
end

local function cleanupMissingAltars()
    for altarId, altar in pairs(state.altars) do
        local found = false
        local tile = altar.position and Tile(altar.position)
        if tile then
            for _, item in ipairs(tile:getItems() or {}) do
                if item:getId() == HiddenHiveStone.altarItemId and tonumber(item:getCustomAttribute("hidden_hive_altar_id")) == altarId then
                    found = true
                    break
                end
            end
        end
        if not found and (tonumber(altar.encounterId) or 0) <= 0 then
            state.altars[altarId] = nil
        end
    end
end

local function ensureAltars()
    cleanupMissingAltars()
    local activeByRegion = {}
    for _, altar in pairs(state.altars) do
        activeByRegion[altar.regionName] = (activeByRegion[altar.regionName] or 0) + 1
    end

    for _, region in ipairs(HiddenHiveStone.regions) do
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

local function findMonsterSpawnPosition(center)
    for radius = 1, 5 do
        local candidates = {}
        for x = -radius, radius do
            for y = -radius, radius do
                if math.max(math.abs(x), math.abs(y)) == radius then
                    candidates[#candidates + 1] = Position(center.x + x, center.y + y, center.z)
                end
            end
        end
        for i = #candidates, 2, -1 do
            local j = math.random(i)
            candidates[i], candidates[j] = candidates[j], candidates[i]
        end
        for _, pos in ipairs(candidates) do
            if isClearTile(pos) then
                return pos
            end
        end
    end
    return center
end

local function removeEncounter(encounterId)
    local encounter = state.encounters[encounterId]
    if not encounter then
        return
    end

    for monsterId in pairs(encounter.monsters) do
        local monster = Monster(monsterId)
        if monster then
            monster:remove()
        end
    end
    state.encounters[encounterId] = nil
    if encounter.altarId and state.altars[encounter.altarId] then
        state.altars[encounter.altarId] = nil
    end
end

local function syncSpawnedMonsterVisibility(monster)
    if type(_G.GemsSocketVisibilitySyncQueue) == "table" then
        _G.GemsSocketVisibilitySyncQueue.enqueueMonster(monster)
        return
    end
    for _, player in ipairs(Game.getPlayers()) do
        player:syncCreatureVisibility(monster, false, true)
    end
end

local function spawnWave(encounterId, wave)
    local encounter = state.encounters[encounterId]
    if not encounter or os.time() > encounter.expiresAt then
        return
    end

    for _, monsterName in ipairs(wave.monsters or {}) do
        local pos = findMonsterSpawnPosition(encounter.position)
        local monster = Game.createMonster(monsterName, pos, true, true)
        if monster then
            monster:setVisibilityRestricted(true)
            monster:setVisibilityRequiresGem(true)
            applyVisibilityGemKey(monster, HiddenHiveStone.gemKey)
            monster:setVisibilityProgressionTier(encounter.level)
            encounter.monsters[monster:getId()] = true
            syncSpawnedMonsterVisibility(monster)
            pos:sendMagicEffect(CONST_ME_TELEPORT)
        end
    end
end

local function getAltarByItem(item)
    if not item or item:getId() ~= HiddenHiveStone.altarItemId then
        return nil
    end
    local altarId = tonumber(item:getCustomAttribute("hidden_hive_altar_id")) or 0
    return altarId > 0 and state.altars[altarId] or nil
end

local function activateHive(player, altar, item)
    local waves = HiddenHiveStone.waves[altar.level] or HiddenHiveStone.waves[1]
    if not waves or #waves == 0 then
        player:sendCancelMessage("This hive altar has no waves configured.")
        return false
    end

    local encounterId = altar.id
    altar.encounterId = encounterId
    state.encounters[encounterId] = {
        altarId = altar.id,
        ownerGuid = player:getGuid(),
        level = altar.level,
        position = altar.position,
        expiresAt = os.time() + HiddenHiveStone.encounterDurationSeconds,
        monsters = {},
    }

    item:remove()
    altar.position:sendMagicEffect(CONST_ME_POISONAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "The hidden hive opens. Waves are coming.")
    for _, wave in ipairs(waves) do
        addEvent(spawnWave, math.max(0, tonumber(wave.delay) or 0) * 1000, encounterId, wave)
    end
    addEvent(removeEncounter, HiddenHiveStone.encounterDurationSeconds * 1000, encounterId)
    return true
end

local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local altar = getAltarByItem(item)
    if not altar then
        return false
    end

    local level = getHighestHiveLevel(player)
    if level < altar.level then
        player:sendCancelMessage(string.format("Hive Stone level %d is required.", altar.level))
        return true
    end

    if (tonumber(altar.encounterId) or 0) > 0 and state.encounters[altar.encounterId] then
        player:sendCancelMessage("This hive is already awake.")
        return true
    end

    activateHive(player, altar, item)
    return true
end

action:id(HiddenHiveStone.altarItemId)
action:register()

local login = CreatureEvent("HiddenHiveStoneLogin")

function login.onLogin(player)
    refreshPlayerVisibilityState(player)
    return true
end

login:type("login")
login:register()

local hiveItemMoved = EventCallback

function hiveItemMoved.onItemMoved(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    if type(_G.GemsSocket_refreshPlayerBonuses) ~= "function"
        and (type(_G.GemsSocket_isEquipmentPosition) ~= "function"
            or _G.GemsSocket_isEquipmentPosition(fromPosition)
            or _G.GemsSocket_isEquipmentPosition(toPosition)) then
        refreshPlayerVisibilityState(player)
    end
end

hiveItemMoved:register()

local global = GlobalEvent("HiddenHiveStoneStartup")

function global.onStartup()
    ensureAltars()
    addEvent(ensureAltars, 5000)
    return true
end

global:register()

local refresh = GlobalEvent("HiddenHiveStoneRefresh")

function refresh.onThink(interval)
    for _, player in ipairs(Game.getPlayers()) do
        refreshPlayerVisibilityState(player)
    end
    ensureAltars()
    return true
end

refresh:interval(HiddenHiveStone.refreshInterval)
refresh:register()
