GemsSocketBonusCache = GemsSocketBonusCache or {}

local cache = GemsSocketBonusCache
local playerCache = {}
local playersByGem = {}
local bonusKeyList = nil
local metricsStartedAt = os.time()
local metrics = {}
local pendingDisplayRefreshes = {}

function cache.bumpMetric(name, amount)
    if GemsSocket and GemsSocket.PERFORMANCE and GemsSocket.PERFORMANCE.enableMetrics == false then
        return
    end
    metrics[name] = (metrics[name] or 0) + (tonumber(amount) or 1)
end

function cache.getMetrics(reset)
    local snapshot = { elapsed = math.max(1, os.time() - metricsStartedAt) }
    for name, value in pairs(metrics) do
        snapshot[name] = value
    end
    if reset then
        metrics = {}
        metricsStartedAt = os.time()
    end
    return snapshot
end

local function runDisplayRefresh(playerId, itemUid)
    pendingDisplayRefreshes[itemUid] = nil
    local player = Player(playerId)
    local item = player and player:getItem(itemUid) or nil
    if item and type(item.refresh) == "function" then
        cache.bumpMetric("display_refreshes")
        item:refresh()
    end
end

function cache.queueDisplayRefresh(item, delayMs)
    if not item or not item.isItem or not item:isItem() then
        return false
    end
    local topParent = type(item.getTopParent) == "function" and item:getTopParent() or nil
    local itemUid = type(item.getRealUID) == "function" and item:getRealUID() or 0
    if not topParent or not topParent.isPlayer or not topParent:isPlayer() or itemUid <= 0 then
        if type(item.refresh) == "function" then
            cache.bumpMetric("display_refreshes")
            item:refresh()
            return true
        end
        return false
    end
    if pendingDisplayRefreshes[itemUid] then
        cache.bumpMetric("display_refreshes_coalesced")
        return true
    end
    pendingDisplayRefreshes[itemUid] = true
    addEvent(runDisplayRefresh, math.max(1, tonumber(delayMs) or 250), topParent:getId(), itemUid)
    return true
end

local function getBonusKeyList()
    if bonusKeyList then
        return bonusKeyList
    end

    local byKey = {}
    for _, gemData in pairs(GemsSocket.GEMS or {}) do
        if type(gemData.bonuses) == "table" then
            for bonusKey in pairs(gemData.bonuses) do
                byKey[bonusKey] = true
            end
        end
        if type(gemData.tiers) == "table" then
            for _, tierData in pairs(gemData.tiers) do
                if type(tierData) == "table" and type(tierData.bonuses) == "table" then
                    for bonusKey in pairs(tierData.bonuses) do
                        byKey[bonusKey] = true
                    end
                end
            end
        end
    end

    bonusKeyList = {}
    for bonusKey in pairs(byKey) do
        bonusKeyList[#bonusKeyList + 1] = bonusKey
    end
    return bonusKeyList
end

local function encodeKeys(totals)
    local keys = {}
    for bonusKey in pairs(totals or {}) do
        keys[#keys + 1] = bonusKey
    end
    table.sort(keys)
    return table.concat(keys, ";")
end

local function decodeKeys(encoded)
    if type(encoded) ~= "string" or encoded == "" then
        return nil
    end
    if encoded == "-" then
        return {}
    end

    local keys = {}
    for key in encoded:gmatch("[^;]+") do
        keys[#keys + 1] = key
    end
    return keys
end

local function getItemBonusKeys(item)
    return decodeKeys(item and item:getCustomAttribute("socket_bonus_keys"))
end

local function getPlayerId(playerOrId)
    if type(playerOrId) == "number" then
        return playerOrId
    end
    if playerOrId and playerOrId.getId then
        return playerOrId:getId()
    end
    return nil
end

function cache.invalidatePlayer(playerOrId)
    local playerId = getPlayerId(playerOrId)
    if playerId then
        cache.bumpMetric("invalidations")
        local oldCache = playerCache[playerId]
        if oldCache and oldCache.gemsByKey then
            for gemKey in pairs(oldCache.gemsByKey) do
                local players = playersByGem[gemKey]
                if players then
                    players[playerId] = nil
                    if not next(players) then
                        playersByGem[gemKey] = nil
                    end
                end
            end
        end
        playerCache[playerId] = nil
    end
end

function cache.invalidateItemOwner(item)
    if not item or not item.isItem or not item:isItem() or type(item.getTopParent) ~= "function" then
        return
    end

    local topParent = item:getTopParent()
    if topParent and topParent.isPlayer and topParent:isPlayer() then
        for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS or {}) do
            local equippedItem = topParent:getSlotItem(slot)
            if equippedItem and (equippedItem == item
                or type(equippedItem.getRealUID) == "function" and type(item.getRealUID) == "function"
                    and equippedItem:getRealUID() == item:getRealUID()) then
                cache.invalidatePlayer(topParent)
                return
            end
        end
    end
end

function cache.legacyTotal(player, bonusKey)
    if not player or type(bonusKey) ~= "string" or bonusKey == "" then
        return 0
    end

    cache.bumpMetric("legacy_total_scans")
    local total = 0
    local attributeKey = "socket_bonus_" .. bonusKey
    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS or {}) do
        local equippedItem = player:getSlotItem(slot)
        if equippedItem then
            total = total + (tonumber(equippedItem:getCustomAttribute(attributeKey) or 0) or 0)
        end
    end
    return total
end

function cache.legacyMax(player, bonusKey)
    if not player or type(bonusKey) ~= "string" or bonusKey == "" then
        return 0
    end

    local highest = 0
    local attributeKey = "socket_bonus_" .. bonusKey
    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS or {}) do
        local equippedItem = player:getSlotItem(slot)
        if equippedItem then
            highest = math.max(highest, tonumber(equippedItem:getCustomAttribute(attributeKey) or 0) or 0)
        end
    end
    return highest
end

function cache.rebuildPlayer(player)
    if not player or not player:isPlayer() then
        return nil
    end

    cache.invalidatePlayer(player)
    cache.bumpMetric("rebuilds")

    local totals = {}
    local maximums = {}
    local gemsByKey = {}
    local socketCount = 0
    local fallbackKeys = getBonusKeyList()

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS or {}) do
        local equippedItem = player:getSlotItem(slot)
        if equippedItem then
            local keys = getItemBonusKeys(equippedItem) or fallbackKeys
            for _, bonusKey in ipairs(keys) do
                local amount = tonumber(equippedItem:getCustomAttribute("socket_bonus_" .. bonusKey) or 0) or 0
                if amount ~= 0 then
                    totals[bonusKey] = (totals[bonusKey] or 0) + amount
                    maximums[bonusKey] = math.max(maximums[bonusKey] or 0, amount)
                end
            end

            local count = math.max(0, tonumber(equippedItem:getCustomAttribute("socket_count")) or 0)
            for socketIndex = 1, count do
                local gemKey = equippedItem:getCustomAttribute(string.format("socket_%d_gem", socketIndex))
                if type(gemKey) == "string" and gemKey ~= "" then
                    local entries = gemsByKey[gemKey]
                    if not entries then
                        entries = {}
                        gemsByKey[gemKey] = entries
                    end
                    entries[#entries + 1] = {
                        item = equippedItem,
                        socketIndex = socketIndex,
                        slot = slot,
                        level = math.max(1, tonumber(equippedItem:getCustomAttribute(string.format("socket_%d_level", socketIndex))) or 1),
                    }
                    socketCount = socketCount + 1
                end
            end
        end
    end

    local playerId = player:getId()
    playerCache[playerId] = {
        totals = totals,
        maximums = maximums,
        gemsByKey = gemsByKey,
        socketCount = socketCount,
    }
    for gemKey in pairs(gemsByKey) do
        playersByGem[gemKey] = playersByGem[gemKey] or {}
        playersByGem[gemKey][playerId] = true
    end
    return playerCache[playerId]
end

function cache.getPlayerCache(player)
    if not player or not player:isPlayer() then
        return nil
    end
    local existing = playerCache[player:getId()]
    if existing then
        cache.bumpMetric("cache_hits")
        return existing
    end
    cache.bumpMetric("cache_misses")
    return cache.rebuildPlayer(player)
end

function cache.total(player, bonusKey)
    local playerBonusCache = cache.getPlayerCache(player)
    if playerBonusCache then
        return tonumber(playerBonusCache.totals[bonusKey]) or 0
    end
    return cache.legacyTotal(player, bonusKey)
end

function cache.max(player, bonusKey)
    local playerBonusCache = cache.getPlayerCache(player)
    if playerBonusCache then
        return tonumber(playerBonusCache.maximums[bonusKey]) or 0
    end
    return cache.legacyMax(player, bonusKey)
end

function cache.hasGem(player, gemKey)
    local playerBonusCache = cache.getPlayerCache(player)
    return playerBonusCache ~= nil
        and type(playerBonusCache.gemsByKey[gemKey]) == "table"
        and #playerBonusCache.gemsByKey[gemKey] > 0
end

function cache.hasAnyGem(player, gemKeys)
    local playerBonusCache = cache.getPlayerCache(player)
    if not playerBonusCache then
        return false
    end
    if gemKeys == nil then
        return (playerBonusCache.socketCount or 0) > 0
    end
    for gemKey in pairs(gemKeys) do
        local entries = playerBonusCache.gemsByKey[gemKey]
        if entries and #entries > 0 then
            return true
        end
    end
    return false
end

function cache.forEachCachedGemSocket(playerBonusCache, gemKey, callback, allowedSlots)
    if type(callback) ~= "function" then
        return 0
    end
    local entries = playerBonusCache and playerBonusCache.gemsByKey[gemKey] or nil
    if not entries then
        return 0
    end

    local visited = 0
    for _, entry in ipairs(entries) do
        if not allowedSlots or allowedSlots[entry.slot] then
            callback(entry.item, entry.socketIndex, gemKey, entry)
            visited = visited + 1
        end
    end
    cache.bumpMetric("indexed_socket_visits", visited)
    return visited
end

function cache.forEachGemSocket(player, gemKey, callback, allowedSlots)
    return cache.forEachCachedGemSocket(cache.getPlayerCache(player), gemKey, callback, allowedSlots)
end

function cache.maxGemLevel(player, gemKey)
    local playerBonusCache = cache.getPlayerCache(player)
    local entries = playerBonusCache and playerBonusCache.gemsByKey[gemKey] or nil
    local highest = 0
    for _, entry in ipairs(entries or {}) do
        highest = math.max(highest, tonumber(entry.level) or 1)
    end
    return highest
end

function cache.forEachPlayerWithGem(gemKey, callback)
    if type(callback) ~= "function" then
        return 0
    end
    local playerIds = {}
    for playerId in pairs(playersByGem[gemKey] or {}) do
        playerIds[#playerIds + 1] = playerId
    end

    local visited = 0
    for _, playerId in ipairs(playerIds) do
        local player = Player(playerId)
        if player then
            callback(player)
            visited = visited + 1
        else
            local staleCache = playerCache[playerId]
            cache.invalidatePlayer(playerId)
            if not staleCache then
                local players = playersByGem[gemKey]
                if players then
                    players[playerId] = nil
                end
            end
        end
    end
    return visited
end

function cache.hasPlayersWithGem(gemKey)
    return next(playersByGem[gemKey] or {}) ~= nil
end

function cache.clearItemBonusAttributes(item)
    local keys = getItemBonusKeys(item) or getBonusKeyList()
    for _, bonusKey in ipairs(keys) do
        item:removeCustomAttribute("socket_bonus_" .. bonusKey)
    end
    item:removeCustomAttribute("socket_bonus_keys")
end

function cache.writeItemBonusKeys(item, totals)
    local encoded = encodeKeys(totals)
    item:setCustomAttribute("socket_bonus_keys", encoded ~= "" and encoded or "-")
end

function cache.replaceItemBonusAttributes(item, totals)
    totals = totals or {}
    local oldKeys = getItemBonusKeys(item)
    if oldKeys == nil then
        for _, bonusKey in ipairs(getBonusKeyList()) do
            item:removeCustomAttribute("socket_bonus_" .. bonusKey)
            cache.bumpMetric("bonus_attributes_removed")
        end
        oldKeys = {}
        cache.bumpMetric("legacy_item_migrations")
    end

    local newKeys = {}
    for bonusKey in pairs(totals) do
        newKeys[bonusKey] = true
    end
    for _, bonusKey in ipairs(oldKeys) do
        if not newKeys[bonusKey] then
            item:removeCustomAttribute("socket_bonus_" .. bonusKey)
            cache.bumpMetric("bonus_attributes_removed")
        end
    end

    for bonusKey, amount in pairs(totals) do
        local attributeKey = "socket_bonus_" .. bonusKey
        local current = tonumber(item:getCustomAttribute(attributeKey)) or 0
        if current ~= amount or item:getCustomAttribute(attributeKey) == nil then
            item:setCustomAttribute(attributeKey, amount)
            cache.bumpMetric("bonus_attributes_written")
        end
    end

    local encoded = encodeKeys(totals)
    encoded = encoded ~= "" and encoded or "-"
    if item:getCustomAttribute("socket_bonus_keys") ~= encoded then
        item:setCustomAttribute("socket_bonus_keys", encoded)
    end
end

function cache.debugCompare(player, requestedKey)
    if not player or not player:isPlayer() then
        return { ok = false, message = "Invalid player." }
    end

    cache.invalidatePlayer(player)
    local playerBonusCache = cache.rebuildPlayer(player)
    if not playerBonusCache then
        return { ok = false, message = "Could not rebuild cache." }
    end

    local keys = {}
    if type(requestedKey) == "string" and requestedKey ~= "" then
        keys[#keys + 1] = requestedKey
    else
        local seen = {}
        for _, key in ipairs(getBonusKeyList()) do
            seen[key] = true
            keys[#keys + 1] = key
        end
        for key in pairs(playerBonusCache.totals) do
            if not seen[key] then
                keys[#keys + 1] = key
            end
        end
    end

    local checked = 0
    local mismatches = {}
    for _, bonusKey in ipairs(keys) do
        local cached = tonumber(playerBonusCache.totals[bonusKey]) or 0
        local legacy = cache.legacyTotal(player, bonusKey)
        if cached ~= legacy then
            mismatches[#mismatches + 1] = { key = bonusKey, cached = cached, legacy = legacy }
        end
        checked = checked + 1
    end

    return {
        ok = #mismatches == 0,
        checked = checked,
        mismatches = mismatches,
        requestedKey = requestedKey,
        cached = keys[1] and (tonumber(playerBonusCache.totals[keys[1]]) or 0) or nil,
        legacy = keys[1] and cache.legacyTotal(player, keys[1]) or nil,
    }
end
