print(">> [Exaltation Forge] Loaded")
local FORGE_OPCODE = 235
local FORGE_TIER_ATTRIBUTE = 'forge_tier'
local MAX_FORGE_TIER = 10
local CLASSIFICATION_MAX_TIER = { [1] = 1, [2] = 2, [3] = 3, [4] = 10 }
local FUSION_PRICES = {
    [1] = { [0] = 25000 },
    [2] = { [0] = 125000, [1] = 500000 },
    [3] = { [0] = 350000, [1] = 750000, [2] = 1300000 },
    [4] = { [0] = 1500000, [1] = 1950000, [2] = 2350000, [3] = 2950000,
        [4] = 3850000, [5] = 5500000, [6] = 7850000, [7] = 9500000,
        [8] = 15450000, [9] = 30000000 }
}
local TRANSFER_PRICES = {
    [2] = { [1] = 5000000 },
    [3] = { [1] = 10000000, [2] = 20000000 },
    [4] = {
        [1] = 20000000, [2] = 40000000, [3] = 65000000,
        [4] = 100000000, [5] = 250000000, [6] = 750000000,
        [7] = 2500000000, [8] = 8000000000, [9] = 15000000000
    }
}
local TRANSFER_CORE_COSTS = {
    [1] = 1, [2] = 2, [3] = 5, [4] = 10, [5] = 15,
    [6] = 25, [7] = 35, [8] = 50, [9] = 60
}
local CONVERGENCE_TRANSFER_PRICES = {
    [1] = 65000000, [2] = 165000000, [3] = 375000000,
    [4] = 800000000, [5] = 2000000000, [6] = 5250000000,
    [7] = 14500000000, [8] = 42500000000, [9] = 100000000000,
    [10] = 300000000000
}
local CONVERGENCE_TRANSFER_CORE_COSTS = {
    [1] = 1, [2] = 2, [3] = 5, [4] = 10, [5] = 15,
    [6] = 25, [7] = 35, [8] = 50, [9] = 60, [10] = 85
}
local FUSION_DUST_COSTS = { [1] = 150, [2] = 190, [3] = 230, [4] = 285, [5] = 345,
    [6] = 450, [7] = 600, [8] = 800, [9] = 1150, [10] = 1500 }
local IMPROVE_CORE_COSTS = { [1] = 2, [2] = 5, [3] = 13, [4] = 30, [5] = 70, [6] = 160, [7] = 365, [8] = 450, [9] = 600, [10] = 850 }
local LOSS_CORE_COSTS = { [1] = 2, [2] = 7, [3] = 19, [4] = 49, [5] = 125, [6] = 311, [7] = 450, [8] = 600, [9] = 850, [10] = 1000 }
local ITEM_FORGE_DUST = 30910
local ITEM_FORGE_SLIVER = 30911
local ITEM_EXALTED_CORE = 30912
local FORGE_ITEMS_PER_PAGE = 12
local FORGE_INVENTORY_SLOTS = {
    [CONST_SLOT_HEAD] = true, [CONST_SLOT_NECKLACE] = true, [CONST_SLOT_BACKPACK] = true,
    [CONST_SLOT_ARMOR] = true, [CONST_SLOT_RIGHT] = true, [CONST_SLOT_LEFT] = true,
    [CONST_SLOT_LEGS] = true, [CONST_SLOT_FEET] = true, [CONST_SLOT_RING] = true,
    [CONST_SLOT_AMMO] = true, [CONST_SLOT_DECK] = true, [CONST_SLOT_BADGE] = true,
    [CONST_SLOT_SHIP] = true, [CONST_SLOT_BELT] = true, [CONST_SLOT_GLOVES] = true
}
local ForgeItems = dofile('data/scripts/customs/forge/forge_items.lua')

local ForgeSystem = {
    history = {}
}
local getConvergenceInventory
local getTransferInventory

local function getBalances(player)
    return {
        dust = player:getItemCount(ITEM_FORGE_DUST),
        slivers = player:getItemCount(ITEM_FORGE_SLIVER),
        cores = player:getItemCount(ITEM_EXALTED_CORE),
        gold = player:getMoney()
    }
end

local function sendBalances(player)
    player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
        action = 'balances',
        data = { balances = getBalances(player) }
    }))
end

local function getConfig(player)
    return {
        currencyClientIds = {
            dust = ItemType(ITEM_FORGE_DUST):getClientId(),
            sliver = ItemType(ITEM_FORGE_SLIVER):getClientId(),
            core = ItemType(ITEM_EXALTED_CORE):getClientId()
        },
        classPrices = (function()
            local result = {}
            for classId, tiers in pairs(FUSION_PRICES) do
                local prices = {}
                for tier, price in pairs(tiers) do prices[#prices + 1] = { tier = tier, price = price } end
                table.sort(prices, function(a, b) return a.tier < b.tier end)
                result[#result + 1] = { classId = classId, tiers = prices }
            end
            table.sort(result, function(a, b) return a.classId < b.classId end)
            return result
        end)(),
        transferPrices = (function()
            local result = {}
            for classId, tiers in pairs(TRANSFER_PRICES) do
                local prices = {}
                for tier, price in pairs(tiers) do
                    prices[#prices + 1] = { tier = tier, price = price }
                end
                table.sort(prices, function(a, b) return a.tier < b.tier end)
                result[#result + 1] = { classId = classId, tiers = prices }
            end
            table.sort(result, function(a, b) return a.classId < b.classId end)
            return result
        end)(),
        convergenceFusionPrices = (function()
            local result = {}
            for targetTier, price in pairs(CONVERGENCE_TRANSFER_PRICES) do
                result[#result + 1] = { tier = targetTier, price = price }
            end
            table.sort(result, function(a, b) return a.tier < b.tier end)
            return result
        end)(),
        convergenceTransferPrices = (function()
            local result = {}
            for targetTier, price in pairs(CONVERGENCE_TRANSFER_PRICES) do
                result[#result + 1] = { tier = targetTier, price = price }
            end
            table.sort(result, function(a, b) return a.tier < b.tier end)
            return result
        end)(),
        fusionGrades = (function()
            local result = {}
            for tier, cores in pairs(TRANSFER_CORE_COSTS) do
                result[#result + 1] = { tier = tier, exaltedCores = cores }
            end
            table.sort(result, function(a, b) return a.tier < b.tier end)
            return result
        end)(),
        improveCoreCosts = IMPROVE_CORE_COSTS,
        lossCoreCosts = LOSS_CORE_COSTS,
        fusionDustCosts = FUSION_DUST_COSTS,
        convergenceFusionDust = 160,
        normalDustFusion = 100,
        fusionReduceTierLoss = 50,
        fusionChanceImproved = 15,
        fusionChanceBase = 50,
        convergenceDustTransfer = 160,
        normalDustTransfer = 100,
        hasConvergence = true,
        dustToSilver = 3,
        sliverToCore = 50
    }
end

local function getForgeInventory(player, requestedPage, requestedClassification)
    local fusionItems = {}
    local fusionItemsByKey = {}
    local entriesById = {}
    local classification = tonumber(requestedClassification) or 0
    if classification < 0 or classification > 4 then classification = 0 end
    for _, entry in ipairs(ForgeItems.getEntries()) do
        if classification == 0 or entry.classification == classification then
            entriesById[entry.id] = entry
            local key = string.format('%d:%d', entry.id, 0)
            fusionItemsByKey[key] = {
                id = entry.id,
                clientId = entry.clientId,
                count = 0,
                tier = 0,
                classification = entry.classification,
                maxTier = CLASSIFICATION_MAX_TIER[entry.classification] or 1,
                requiredCopies = 1
            }
        end
    end

    local visited = {}
    local function visit(item)
        if not item then return end

        local uid = tonumber(item:getRealUID()) or 0
        if uid > 0 then
            if visited[uid] then return end
            visited[uid] = true
        end

        if item:isItem() and not item:isContainer() then
            local itemType = item:getType()
            local itemId = item:getId()
            local entry = entriesById[itemId]
            if entry and ForgeItems.isAllowedType(itemType) then
                local tier = math.max(0, math.min(MAX_FORGE_TIER,
                    tonumber(item:getCustomAttribute(FORGE_TIER_ATTRIBUTE)) or 0))
                local itemClassification = ForgeItems.getClassification(itemType)
                local maxTier = CLASSIFICATION_MAX_TIER[itemClassification] or 1
                if tier < maxTier then
                    local key = string.format('%d:%d', itemId, tier)
                    local fusionItem = fusionItemsByKey[key]
                    if not fusionItem then
                        fusionItem = {
                            id = itemId,
                            clientId = itemType:getClientId(),
                            count = 0,
                            tier = tier,
                            classification = itemClassification,
                            maxTier = maxTier,
                            requiredCopies = tier == 0 and 1 or 2
                        }
                        fusionItemsByKey[key] = fusionItem
                    end
                    fusionItem.count = fusionItem.count + 1
                    fusionItem.requiredCopies = tier == 0 and 1 or 2
                end
            end
        end

        if item:isContainer() then
            for index = 0, item:getSize() - 1 do
                visit(item:getItem(index))
            end
        end
    end

    for slot in pairs(FORGE_INVENTORY_SLOTS) do
        visit(player:getSlotItem(slot))
    end

    for _, item in pairs(fusionItemsByKey) do
        fusionItems[#fusionItems + 1] = item
    end

    table.sort(fusionItems, function(a, b)
        local aOwned = a.count > 0
        local bOwned = b.count > 0
        if aOwned ~= bOwned then return aOwned end
        if a.tier ~= b.tier then return a.tier > b.tier end
        return a.id < b.id
    end)
    local totalItems = #fusionItems
    local totalPages = math.max(1, math.ceil(totalItems / FORGE_ITEMS_PER_PAGE))
    local page = math.max(1, math.min(totalPages, math.floor(tonumber(requestedPage) or 1)))
    local firstIndex = ((page - 1) * FORGE_ITEMS_PER_PAGE) + 1
    local lastIndex = math.min(totalItems, firstIndex + FORGE_ITEMS_PER_PAGE - 1)
    local pageItems = {}
    for index = firstIndex, lastIndex do
        pageItems[#pageItems + 1] = fusionItems[index]
    end

    return {
        page = page,
        totalPages = totalPages,
        totalItems = totalItems,
        itemsPerPage = FORGE_ITEMS_PER_PAGE,
        classification = classification,
        fusionItems = pageItems,
        convergenceFusion = getConvergenceInventory and getConvergenceInventory(player) or {},
        transfers = getTransferInventory and getTransferInventory(player) or {},
        convergenceTransfers = {}
    }
end

local function sendState(player, requestedPage, requestedClassification)
    player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
        action = 'open',
        data = {
            balances = getBalances(player),
            config = getConfig(player),
            forge = getForgeInventory(player, requestedPage, requestedClassification)
        }
    }))
end

local function sendHistory(player, requestedPage)
    local page = math.max(1, tonumber(requestedPage) or 1)
    local guid = player:getGuid()
    local entries = ForgeSystem.history[guid] or {}
    player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
        action = 'history',
        data = {
            page = page,
            lastPage = 1,
            currentCount = #entries,
            list = entries
        }
    }))
end

local function addHistory(player, actionType, description)
    local guid = player:getGuid()
    ForgeSystem.history[guid] = ForgeSystem.history[guid] or {}
    table.insert(ForgeSystem.history[guid], 1, {
        createdAt = os.time(),
        actionType = actionType,
        description = description
    })
    while #ForgeSystem.history[guid] > 50 do
        table.remove(ForgeSystem.history[guid])
    end
end

local function convert(player, conversionType)
    local balances = getBalances(player)

    local converted = false
    if conversionType == 2 and balances.dust >= 60 then
        player:removeItem(ITEM_FORGE_DUST, 60)
        player:addItem(ITEM_FORGE_SLIVER, 3)
        addHistory(player, 2, 'Converted 60 forge dust into 3 forge slivers')
        converted = true
    elseif conversionType == 3 and balances.slivers >= 50 then
        player:removeItem(ITEM_FORGE_SLIVER, 50)
        player:addItem(ITEM_EXALTED_CORE, 1)
        addHistory(player, 2, 'Converted 50 forge slivers into 1 forge core')
        converted = true
    end

    if converted then
        sendState(player)
    else
        player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
            action = 'error',
            data = { message = 'You do not have the resources required for that conversion.' }
        }))
    end
end


local sendForgeError
local function isEquipableItem(item)
    if not item or not item:isItem() or item:isContainer() then return false end
    local itemType = item:getType()
    if not ForgeItems.isAllowedType(itemType) then return false end
    return ForgeItems.getEquipmentKind(itemType) ~= nil
end

local function resolveTargetItem(player, target)
    local position = type(target) == 'table' and target.position or nil
    if type(position) ~= 'table' or tonumber(position.x) ~= 65535 then return nil end

    local positionY = tonumber(position.y) or 0
    local isContainerSlot = bit.band(positionY, 0x40) ~= 0
    if not isContainerSlot and not FORGE_INVENTORY_SLOTS[positionY] then return nil end

    return player:getItem({
        x = tonumber(position.x) or 0,
        y = tonumber(position.y) or 0,
        z = tonumber(position.z) or 0,
        stackpos = tonumber(position.stackpos) or 0
    })
end

local function getForgeTier(item)
    return math.max(0, math.min(MAX_FORGE_TIER, tonumber(item:getCustomAttribute(FORGE_TIER_ATTRIBUTE)) or 0))
end

local function visitInventoryItems(player, visitor)
    local visited = {}

    local function visit(item)
        if not item then return nil end

        local uid = tonumber(item:getRealUID()) or 0
        if uid > 0 then
            if visited[uid] then return nil end
            visited[uid] = true
        end

        if visitor(item) then return item end
        if item:isContainer() then
            for index = 0, item:getSize() - 1 do
                local found = visit(item:getItem(index))
                if found then return found end
            end
        end
        return nil
    end

    for slot in pairs(FORGE_INVENTORY_SLOTS) do
        local found = visit(player:getSlotItem(slot))
        if found then return found end
    end
    return nil
end

local function countIdenticalTierItems(player, itemId, tier)
    local count = 0
    visitInventoryItems(player, function(item)
        if item:getId() == itemId and getForgeTier(item) == tier then
            count = count + 1
        end
        return false
    end)
    return count
end

local function findFusionPartner(player, targetItem, tier)
    local targetUid = targetItem:getRealUID()
    return visitInventoryItems(player, function(item)
        return item:getRealUID() ~= targetUid and
            item:getId() == targetItem:getId() and
            getForgeTier(item) == tier
    end)
end

local function findFusionSourceItem(player, itemId, tier)
    itemId = tonumber(itemId) or 0
    tier = tonumber(tier) or 0
    if itemId <= 0 then return nil end

    return visitInventoryItems(player, function(item)
        return item:getId() == itemId and getForgeTier(item) == tier and isEquipableItem(item)
    end)
end

local function findInventoryItemByUid(player, uid)
    uid = tonumber(uid) or 0
    if uid <= 0 then return nil end
    return visitInventoryItems(player, function(item)
        return item:getRealUID() == uid
    end)
end

local function getConvergenceTargets(player, sourceItem)
    local targets = {}
    if not sourceItem or not isEquipableItem(sourceItem) then return targets end

    local sourceType = sourceItem:getType()
    local sourceTier = getForgeTier(sourceItem)
    local sourceUid = sourceItem:getRealUID()
    if ForgeItems.getClassification(sourceType) ~= 4 or sourceTier <= 0 then
        return targets
    end

    visitInventoryItems(player, function(item)
        if item:getRealUID() ~= sourceUid and isEquipableItem(item) and getForgeTier(item) == 0 then
            local itemType = item:getType()
            if ForgeItems.getClassification(itemType) == 4 then
                local itemKind = ForgeItems.getEquipmentKind(itemType)
                targets[#targets + 1] = {
                    id = item:getId(),
                    clientId = itemType:getClientId(),
                    tier = 0,
                    count = 1,
                    classification = 4,
                    maxTier = MAX_FORGE_TIER,
                    slot = itemKind,
                    key = tostring(item:getRealUID())
                }
            end
        end
        return false
    end)
    table.sort(targets, function(a, b)
        if a.id == b.id then return tonumber(a.key) < tonumber(b.key) end
        return a.id < b.id
    end)
    return targets
end

getConvergenceInventory = function(player)
    local grouped = {
        weapon = {},
        armor = {},
        helmet = {},
        legs = {},
        boots = {}
    }
    visitInventoryItems(player, function(item)
        if isEquipableItem(item) then
            local itemType = item:getType()
            local kind = ForgeItems.getEquipmentKind(itemType)
            local tier = getForgeTier(item)
            if grouped[kind] and ForgeItems.getClassification(itemType) == 4 and tier > 0 then
                grouped[kind][#grouped[kind] + 1] = {
                    id = item:getId(),
                    clientId = itemType:getClientId(),
                    tier = tier,
                    count = 1,
                    classification = 4,
                    maxTier = MAX_FORGE_TIER,
                    slot = kind,
                    key = tostring(item:getRealUID())
                }
            end
        end
        return false
    end)
    for _, items in pairs(grouped) do
        table.sort(items, function(a, b)
            if a.tier == b.tier then
                if a.id == b.id then return tonumber(a.key) < tonumber(b.key) end
                return a.id < b.id
            end
            return a.tier > b.tier
        end)
    end
    return grouped
end

getTransferInventory = function(player)
    local grouped = {
        weapon = { donors = {}, receivers = {} },
        armor = { donors = {}, receivers = {} },
        helmet = { donors = {}, receivers = {} },
        legs = { donors = {}, receivers = {} },
        boots = { donors = {}, receivers = {} }
    }

    visitInventoryItems(player, function(item)
        if not isEquipableItem(item) then return false end

        local itemType = item:getType()
        local kind = ForgeItems.getEquipmentKind(itemType)
        local classification = ForgeItems.getClassification(itemType)
        local tier = getForgeTier(item)
        local group = grouped[kind]
        if not group or classification < 2 or classification > 4 then return false end

        local entry = {
            id = item:getId(),
            clientId = itemType:getClientId(),
            tier = tier,
            count = 1,
            classification = classification,
            maxTier = CLASSIFICATION_MAX_TIER[classification] or 1,
            slot = kind,
            key = tostring(item:getRealUID())
        }
        if tier >= 2 and tier <= (CLASSIFICATION_MAX_TIER[classification] or 1) then
            group.donors[#group.donors + 1] = entry
        elseif tier == 0 then
            group.receivers[#group.receivers + 1] = entry
        end
        return false
    end)

    for _, group in pairs(grouped) do
        table.sort(group.donors, function(a, b)
            if a.tier == b.tier then
                if a.id == b.id then return tonumber(a.key) < tonumber(b.key) end
                return a.id < b.id
            end
            return a.tier > b.tier
        end)
        table.sort(group.receivers, function(a, b)
            if a.classification == b.classification then
                if a.id == b.id then return tonumber(a.key) < tonumber(b.key) end
                return a.id < b.id
            end
            return a.classification < b.classification
        end)
    end
    return grouped
end

local function getFusionInfo(itemType, tier)
    local classification = ForgeItems.getClassification(itemType)
    local prices = FUSION_PRICES[classification] or {}
    local maxTier = CLASSIFICATION_MAX_TIER[classification] or 1
    local priceTier = math.min(maxTier, math.max(0, tonumber(tier) or 0))
    return classification, maxTier,
        tonumber(prices[priceTier]) or 0,
        FUSION_DUST_COSTS[math.min(10, math.max(1, (tonumber(tier) or 0) + 1))] or 150
end

local function sendSelectedItem(player, item, convergence)
    if not isEquipableItem(item) then
        sendForgeError(player, 'Only weapons, armors, helmets, legs and boots can be placed in the forge.')
        return
    end
    local tier = getForgeTier(item)
    local classification, maxTier, price, dustCost = getFusionInfo(item:getType(), tier)

    if convergence == true then
        if classification ~= 4 then
            sendForgeError(player, 'Convergence requires a Classification 4 donor item.')
            return
        elseif tier <= 0 then
            sendForgeError(player, 'The Convergence donor must already have a forge tier.')
            return
        end

        local convergencePrice = tonumber(CONVERGENCE_TRANSFER_PRICES[tier]) or 0
        local convergenceCoreCost = tonumber(CONVERGENCE_TRANSFER_CORE_COSTS[tier]) or 0
        player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
            action = 'item_state',
            data = {
                itemId = item:getId(),
                clientId = item:getType():getClientId(),
                tier = tier,
                targetTier = tier,
                price = convergencePrice,
                dustCost = 160,
                coreCost = convergenceCoreCost,
                classification = 4,
                maxTier = MAX_FORGE_TIER,
                requiredCopies = 1,
                availableCopies = 1,
                equipmentKind = ForgeItems.getEquipmentKind(item:getType()),
                convergence = true,
                convergenceTargets = getConvergenceTargets(player, item),
                key = tostring(item:getRealUID()),
                message = string.format(
                    'Tier %d convergence accepted. Select any Tier 0 Classification 4 receiver.', tier)
            }
        }))
        return
    end

    if tier >= maxTier then
        sendForgeError(player, string.format('This item is already at the maximum tier for Classification %d (Tier %d).', classification, maxTier))
        return
    end
    player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
        action = 'item_state',
        data = {
            itemId = item:getId(),
            clientId = item:getType():getClientId(),
            tier = tier,
            price = tier < maxTier and price or 0,
            dustCost = tier < maxTier and dustCost or 0,
            classification = classification,
            maxTier = maxTier,
            requiredCopies = tier == 0 and 1 or 2,
            availableCopies = countIdenticalTierItems(player, item:getId(), tier),
            improveCoreCost = IMPROVE_CORE_COSTS[math.min(maxTier, tier + 1)] or 0,
            lossCoreCost = LOSS_CORE_COSTS[math.min(maxTier, tier + 1)] or 0,
            key = tostring(item:getRealUID()),
            message = tier >= maxTier and string.format('This classification %d item is already at its tier limit (%d).', classification, maxTier) or
                string.format('Equipment accepted. Upgrade tier %d to tier %d.', tier, tier + 1)
        }
    }))
end

sendForgeError = function(player, message)
    player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
        action = 'error',
        data = { message = message }
    }))
end

local function performConvergenceFusion(player, data)
    local donorKey = tonumber(data.targetKey)
    local receiverKey = tonumber(data.convergenceTargetKey)
    local donor = findInventoryItemByUid(player, donorKey)
    local receiver = findInventoryItemByUid(player, receiverKey)

    if not isEquipableItem(donor) or donor:getId() ~= tonumber(data.itemId) or
        donor:getRealUID() ~= donorKey or getForgeTier(donor) ~= tonumber(data.tier) then
        sendForgeError(player, 'The Convergence donor was moved or replaced. Select it again.')
        return
    end
    if not isEquipableItem(receiver) or receiver:getId() ~= tonumber(data.targetItemId) or
        receiver:getRealUID() ~= receiverKey then
        sendForgeError(player, 'The Convergence receiver was moved or replaced. Select it again.')
        return
    end
    if donorKey == receiverKey then
        sendForgeError(player, 'The donor and receiver must be different items.')
        return
    end

    local donorType = donor:getType()
    local receiverType = receiver:getType()
    local donorTier = getForgeTier(donor)
    if ForgeItems.getClassification(donorType) ~= 4 or
        ForgeItems.getClassification(receiverType) ~= 4 then
        sendForgeError(player, 'Both Convergence items must be Classification 4.')
        return
    elseif donorTier <= 0 then
        sendForgeError(player, 'The Convergence donor must already have a forge tier.')
        return
    elseif getForgeTier(receiver) ~= 0 then
        sendForgeError(player, 'The Convergence receiver must be at Tier 0.')
        return
    end

    local price = tonumber(CONVERGENCE_TRANSFER_PRICES[donorTier]) or 0
    local coreCost = tonumber(CONVERGENCE_TRANSFER_CORE_COSTS[donorTier]) or 0
    local dustCost = 160
    local balances = getBalances(player)
    if price <= 0 or coreCost <= 0 then
        sendForgeError(player, 'There is no Convergence Transfer cost configured for that tier.')
        return
    elseif balances.gold < price then
        sendForgeError(player, 'You do not have enough gold.')
        return
    elseif balances.dust < dustCost then
        sendForgeError(player, 'You do not have enough forge dust.')
        return
    elseif balances.cores < coreCost then
        sendForgeError(player, 'You do not have enough forge cores.')
        return
    end

    if not player:removeMoney(price) then
        sendForgeError(player, 'The gold payment could not be completed.')
        return
    end
    if not player:removeItem(ITEM_FORGE_DUST, dustCost) then
        player:addMoney(price)
        sendForgeError(player, 'The forge dust payment could not be completed.')
        return
    end
    if not player:removeItem(ITEM_EXALTED_CORE, coreCost) then
        player:addMoney(price)
        player:addItem(ITEM_FORGE_DUST, dustCost)
        sendForgeError(player, 'The forge core payment could not be completed.')
        return
    end

    local donorClientId = donorType:getClientId()
    local donorName = donorType:getName()
    local receiverClientId = receiverType:getClientId()
    local receiverName = receiverType:getName()
    if not donor:remove(1) then
        player:addMoney(price)
        player:addItem(ITEM_FORGE_DUST, dustCost)
        player:addItem(ITEM_EXALTED_CORE, coreCost)
        sendForgeError(player, 'The Convergence donor could not be consumed. Nothing was changed.')
        return
    end

    receiver:setCustomAttribute(FORGE_TIER_ATTRIBUTE, donorTier)
    addHistory(player, 0, string.format(
        'Convergence transferred forge tier %d from %s to %s',
        donorTier, donorName, receiverName))
    player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
        action = 'result',
        data = {
            actionType = 0,
            title = 'Convergence Result',
            success = true,
            leftItemId = donorClientId,
            leftTier = donorTier,
            rightItemId = receiverClientId,
            rightTier = donorTier,
            bonus = 0,
            bonusLabel = '',
            coreCount = coreCost,
            label = string.format('Forge tier %d was transferred successfully.', donorTier),
            balances = getBalances(player)
        }
    }))
end

local function performRegularTransfer(player, data)
    local donorKey = tonumber(data.transferDonorKey)
    local receiverKey = tonumber(data.transferTargetKey)
    local donor = findInventoryItemByUid(player, donorKey)
    local receiver = findInventoryItemByUid(player, receiverKey)

    if not isEquipableItem(donor) or donor:getId() ~= tonumber(data.itemId) or
        donor:getRealUID() ~= donorKey or getForgeTier(donor) ~= tonumber(data.tier) then
        sendForgeError(player, 'The Transfer donor was moved or replaced. Select it again.')
        return
    end
    if not isEquipableItem(receiver) or receiver:getId() ~= tonumber(data.targetItemId) or
        receiver:getRealUID() ~= receiverKey then
        sendForgeError(player, 'The Transfer receiver was moved or replaced. Select it again.')
        return
    end
    if donorKey == receiverKey then
        sendForgeError(player, 'The donor and receiver must be different items.')
        return
    end

    local donorType = donor:getType()
    local receiverType = receiver:getType()
    local donorTier = getForgeTier(donor)
    local donorClassification = ForgeItems.getClassification(donorType)
    local receiverClassification = ForgeItems.getClassification(receiverType)
    if donorClassification < 2 or donorClassification > 4 or
        receiverClassification ~= donorClassification then
        sendForgeError(player, 'Regular Transfer requires two items of the same Classification (2, 3 or 4).')
        return
    elseif donorTier < 2 then
        sendForgeError(player, 'The Transfer donor must be at least Tier 2.')
        return
    elseif getForgeTier(receiver) ~= 0 then
        sendForgeError(player, 'The Transfer receiver must be at Tier 0.')
        return
    end

    local resultTier = donorTier - 1
    local price = tonumber((TRANSFER_PRICES[donorClassification] or {})[resultTier]) or 0
    local coreCost = tonumber(TRANSFER_CORE_COSTS[resultTier]) or 0
    local dustCost = 100
    local balances = getBalances(player)
    if price <= 0 or coreCost <= 0 then
        sendForgeError(player, 'There is no Regular Transfer cost configured for this tier.')
        return
    elseif balances.gold < price then
        sendForgeError(player, 'You do not have enough gold.')
        return
    elseif balances.dust < dustCost then
        sendForgeError(player, 'You do not have enough forge dust.')
        return
    elseif balances.cores < coreCost then
        sendForgeError(player, 'You do not have enough forge cores.')
        return
    end

    if not player:removeMoney(price) then
        sendForgeError(player, 'The gold payment could not be completed.')
        return
    end
    if not player:removeItem(ITEM_FORGE_DUST, dustCost) then
        player:addMoney(price)
        sendForgeError(player, 'The forge dust payment could not be completed.')
        return
    end
    if not player:removeItem(ITEM_EXALTED_CORE, coreCost) then
        player:addMoney(price)
        player:addItem(ITEM_FORGE_DUST, dustCost)
        sendForgeError(player, 'The forge core payment could not be completed.')
        return
    end

    local donorClientId = donorType:getClientId()
    local donorName = donorType:getName()
    local receiverClientId = receiverType:getClientId()
    local receiverName = receiverType:getName()
    if not donor:remove(1) then
        player:addMoney(price)
        player:addItem(ITEM_FORGE_DUST, dustCost)
        player:addItem(ITEM_EXALTED_CORE, coreCost)
        sendForgeError(player, 'The Transfer donor could not be consumed. Nothing was changed.')
        return
    end

    receiver:setCustomAttribute(FORGE_TIER_ATTRIBUTE, resultTier)
    addHistory(player, 1, string.format(
        'Transferred forge tier %d from %s to %s; receiver became tier %d',
        donorTier, donorName, receiverName, resultTier))
    player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
        action = 'result',
        data = {
            actionType = 1,
            title = 'Transfer Result',
            success = true,
            leftItemId = donorClientId,
            leftTier = donorTier,
            rightItemId = receiverClientId,
            rightTier = resultTier,
            bonus = 0,
            bonusLabel = '',
            label = string.format('Forge tier %d was transferred successfully as tier %d.',
                donorTier, resultTier),
            balances = getBalances(player)
        }
    }))
end

local function performForge(player, data)
    local actionType = tonumber(data.type)
    if actionType ~= 0 and actionType ~= 1 then
        sendForgeError(player, 'Unknown forge action.')
        return
    end

    if actionType == 0 and data.convergence == true then
        performConvergenceFusion(player, data)
        return
    end
    if actionType == 1 then
        performRegularTransfer(player, data)
        return
    end

    local targetItem = resolveTargetItem(player, data.target)
    if actionType == 0 then
        local hasDroppedTarget = type(data.target) == 'table'
        local targetKey = tonumber(data.targetKey)
        if not targetItem and targetKey and targetKey > 0 then
            targetItem = findInventoryItemByUid(player, targetKey)
        end
        if not targetItem and not hasDroppedTarget then
            targetItem = findFusionSourceItem(player, data.itemId, data.tier)
        end

        if not isEquipableItem(targetItem) then
            sendForgeError(player, 'The selected equipment is no longer available.')
            return
        end

        if targetItem:getId() ~= tonumber(data.itemId) or getForgeTier(targetItem) ~= tonumber(data.tier) or
            (targetKey and targetKey > 0 and targetItem:getRealUID() ~= targetKey) then
            sendForgeError(player, 'The selected equipment was moved or replaced. Select it again.')
            return
        end

        local currentTier = getForgeTier(targetItem)
        local classification, maxTier, price, dustCost = getFusionInfo(targetItem:getType(), currentTier)
        if currentTier >= maxTier then
            sendForgeError(player, string.format('This classification %d item cannot exceed tier %d.', classification, maxTier))
            return
        end

        local fusionPartner = nil
        if currentTier > 0 then
            fusionPartner = findFusionPartner(player, targetItem, currentTier)
        end
        if currentTier > 0 and not fusionPartner then
            sendForgeError(player, 'Fusion requires two identical items of the same tier.')
            return
        end
        local targetTier = currentTier + 1
        local coreCost = 0
        if data.chanceImproved == true then coreCost = coreCost + (IMPROVE_CORE_COSTS[targetTier] or 0) end
        if data.reduceTierLoss == true then coreCost = coreCost + (LOSS_CORE_COSTS[targetTier] or 0) end
        local balances = getBalances(player)
        if balances.gold < price then
            sendForgeError(player, 'You do not have enough gold.')
            return
        elseif balances.dust < dustCost then
            sendForgeError(player, 'You do not have enough forge dust.')
            return
        elseif balances.cores < coreCost then
            sendForgeError(player, 'You do not have enough forge cores.')
            return
        end

        if not player:removeMoney(price) then
            sendForgeError(player, 'The gold payment could not be completed.')
            return
        end
        if not player:removeItem(ITEM_FORGE_DUST, dustCost) then
            player:addMoney(price)
            sendForgeError(player, 'The forge dust payment could not be completed.')
            return
        end
        if coreCost > 0 and not player:removeItem(ITEM_EXALTED_CORE, coreCost) then
            player:addMoney(price)
            player:addItem(ITEM_FORGE_DUST, dustCost)
            sendForgeError(player, 'The forge core payment could not be completed.')
            return
        end

        local successChance = data.chanceImproved == true and 65 or 50
        local success = math.random(1, 100) <= successChance
        if not success then
            local lostTier = currentTier > 0
            local reduceLoss = data.reduceTierLoss == true and math.random(1, 100) <= 50
            local resultTier = (lostTier and not reduceLoss) and (currentTier - 1) or currentTier
            if fusionPartner and not fusionPartner:remove(1) then
                player:addMoney(price)
                player:addItem(ITEM_FORGE_DUST, dustCost)
                if coreCost > 0 then player:addItem(ITEM_EXALTED_CORE, coreCost) end
                sendForgeError(player, 'The second fusion item could not be consumed. Nothing was changed.')
                return
            end
            targetItem:setCustomAttribute(FORGE_TIER_ATTRIBUTE, resultTier)
            local clientId = targetItem:getType():getClientId()
            local lossMessage = reduceLoss and ' Failure protected: the tier loss was avoided.' or
                (lostTier and string.format(' The item lost one tier (%d).', resultTier) or ' The item remained at tier 0.')
            addHistory(player, 0, string.format('Fusion failed for %s at tier %d.%s',
                targetItem:getType():getName(), currentTier, lossMessage))
            player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
                action = 'result',
                data = {
                    actionType = 0,
                    success = false,
                    leftItemId = clientId,
                    leftTier = currentTier,
                    rightItemId = clientId,
                    rightTier = resultTier,
                    bonus = 0,
                    coreCount = coreCost,
                    label = lossMessage,
                    balances = getBalances(player)
                }
            }))
            return
        end

        -- Bonus at 2%
        local bonus = 0
        local bonusLabel = ''
        local bonusRoll = math.random(1, 1000)
        local newTier = currentTier + 1
        if bonusRoll <= 20 then
            local possibleBonuses = fusionPartner and { 1, 2, 3, 4, 5, 6, 7 } or { 1, 2, 3, 7 }
            bonus = possibleBonuses[math.random(1, #possibleBonuses)]
            if bonus == 1 then
                bonusLabel = 'Lucky bonus: the forge dust was not consumed.'
            elseif bonus == 2 then
                bonusLabel = 'Lucky bonus: the forge cores were not consumed.'
            elseif bonus == 3 then
                bonusLabel = 'Lucky bonus: the gold was not consumed.'
            elseif bonus == 4 then
                bonusLabel = 'Lucky bonus: the second item was retained.'
            elseif bonus == 5 then
                bonusLabel = 'Lucky bonus: the second item was retained with decreased tier.'
            elseif bonus == 6 then
                bonusLabel = 'Lucky bonus: the second item was retained with increased tier.'
            elseif bonus == 7 then
                newTier = math.min(maxTier, currentTier + 2)
                bonusLabel = 'Lucky bonus: the fused item gained two tiers.'
            end
        end

        if fusionPartner then
            if bonus == 5 then
                fusionPartner:setCustomAttribute(FORGE_TIER_ATTRIBUTE, math.max(0, currentTier - 1))
            elseif bonus == 6 then
                fusionPartner:setCustomAttribute(FORGE_TIER_ATTRIBUTE, math.min(maxTier, currentTier + 1))
            elseif bonus ~= 4 and not fusionPartner:remove(1) then
                player:addMoney(price)
                player:addItem(ITEM_FORGE_DUST, dustCost)
                if coreCost > 0 then player:addItem(ITEM_EXALTED_CORE, coreCost) end
                sendForgeError(player, 'The second fusion item could not be consumed. Nothing was changed.')
                return
            end
        end

        if bonus == 1 then
            player:addItem(ITEM_FORGE_DUST, dustCost)
        elseif bonus == 2 and coreCost > 0 then
            player:addItem(ITEM_EXALTED_CORE, coreCost)
        elseif bonus == 3 then
            player:addMoney(price)
        end

        targetItem:setCustomAttribute(FORGE_TIER_ATTRIBUTE, newTier)
        local clientId = targetItem:getType():getClientId()
        local historyDescription = string.format('Upgraded %s from forge tier %d to %d',
            targetItem:getType():getName(), currentTier, newTier)
        if bonusLabel ~= '' then historyDescription = historyDescription .. ' (' .. bonusLabel .. ')' end
        addHistory(player, 0, historyDescription)
        player:sendExtendedOpcode(FORGE_OPCODE, json.encode({
            action = 'result',
            data = {
                actionType = 0,
                success = true,
                leftItemId = clientId,
                leftTier = currentTier,
                rightItemId = clientId,
                rightTier = newTier,
                bonus = bonus,
                bonusLabel = bonusLabel,
                coreCount = coreCost,
                balances = getBalances(player)
            }
        }))
        return
    end

    sendForgeError(player, 'Drop an equipable item into the forge before upgrading it.')
end

local extendedEvent = CreatureEvent('ForgeExtendedOpcode')
function extendedEvent.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= FORGE_OPCODE then
        return true
    end

    local ok, request = pcall(json.decode, buffer)
    if not ok or type(request) ~= 'table' then
        return true
    end

    local action = request.action
    local data = request.data or {}
    if action == 'open' then
        sendState(player, data.page, data.classification)
    elseif action == 'balances' then
        sendBalances(player)
    elseif action == 'select_item' then
        local item = resolveTargetItem(player, data.target)
        if item then
            sendSelectedItem(player, item, data.convergence == true)
        else
            sendForgeError(player, 'Drop an item from your inventory or backpack.')
        end
    elseif action == 'select_convergence' then
        local item = findInventoryItemByUid(player, data.sourceKey)
        if item then
            sendSelectedItem(player, item, true)
        else
            sendForgeError(player, 'The Convergence donor is no longer in your inventory.')
        end
    elseif action == 'history' then
        sendHistory(player, data.page)
    elseif action == 'convert' then
        convert(player, tonumber(data.type))
    elseif action == 'forge' then
        performForge(player, data)
    end
    return true
end
extendedEvent:type('extendedopcode')
extendedEvent:register()

local loginEvent = CreatureEvent('ForgeLogin')
function loginEvent.onLogin(player)
    player:registerEvent('ForgeExtendedOpcode')
    return true
end
loginEvent:type('login')
loginEvent:register()

local forgeObjectAction = Action()
function forgeObjectAction.onUse(player)
    sendState(player)
    return true
end
forgeObjectAction:aid(33736)
forgeObjectAction:register()
