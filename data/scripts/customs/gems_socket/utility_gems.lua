UtilityGems = UtilityGems or {}

local BOND_MODAL_ID = 9924
local MASTERY_CHOICE_MODAL_ID = 9925
local MASTERY_CONFIRM_MODAL_ID = 9926
local PET_ID_STORAGE = 633453
local TRAINING_COOLDOWN_STORAGE = 994000
local runtimeState = {}
local pendingBonds = {}
local pendingMastery = {}

local masteryProfessions = {
    mining = "Mining",
    herbalist = "Herbalist",
    woodcutting = "Woodcutting",
}
local masteryConfig = GemsSocket.SPECIALS and GemsSocket.SPECIALS.professionMastery or {}
local masteryTierStarts = masteryConfig.tierStarts or { 0, 200, 600, 1400, 3000, 5000 }
local masteryEfficiency = masteryConfig.efficiencyByTier or { 0, 25, 50, 100, 150, 200 }
local masteryRareFindGathers = math.max(1, tonumber(masteryConfig.rareFindGathersFor100) or 5000)

local function getMasteryProgress(state)
    local gathers = math.max(0, tonumber(state and state.gathers) or 0)
    local tier = 1
    for index = #masteryTierStarts, 1, -1 do
        if gathers >= masteryTierStarts[index] then
            tier = index
            break
        end
    end

    local tierPercent = 100
    if tier < #masteryTierStarts then
        local tierStart = masteryTierStarts[tier]
        local tierEnd = masteryTierStarts[tier + 1]
        tierPercent = ((gathers - tierStart) / (tierEnd - tierStart)) * 100
    end

    return {
        profession = state and state.profession or nil,
        gathers = gathers,
        tier = tier,
        tierPercent = math.max(0, math.min(100, tierPercent)),
        efficiency = masteryEfficiency[tier] or 0,
        rareFind = math.max(0, math.min(100, (gathers / masteryRareFindGathers) * 100)),
    }
end

local utilityKeys = {
    cartographygem = true,
    bondgem = true,
    collectorgem = true,
    traininggem = true,
    professionmasterygem = true,
}

local function getConfiguredGemItemId(gemKey, fallback)
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[gemKey]
    return tonumber(gemData and gemData.itemId) or fallback
end

local BOND_GEM_ITEM_ID = getConfiguredGemItemId("bondgem", 30713)
local PROFESSION_MASTERY_GEM_ITEM_ID = getConfiguredGemItemId("professionmasterygem", 30856)

local function getPrefix(socketIndex, name)
    if socketIndex then
        return string.format("socket_%d_%s_", socketIndex, name)
    end
    return name .. "_"
end

local function readNumber(item, key)
    return math.max(0, tonumber(item:getCustomAttribute(key)) or 0)
end

function UtilityGems.supports(gemKey)
    return utilityKeys[gemKey] == true
end

function UtilityGems.readState(item, socketIndex, gemKey)
    if not item or not item:isItem() or not UtilityGems.supports(gemKey) then
        return nil
    end

    if gemKey == "cartographygem" then
        local prefix = getPrefix(socketIndex, "cartography")
        return {
            percentTenths = readNumber(item, prefix .. "percent_tenths"),
            discoveredZones = readNumber(item, prefix .. "discovered_zones"),
            totalZones = readNumber(item, prefix .. "total_zones"),
        }
    elseif gemKey == "bondgem" then
        local prefix = getPrefix(socketIndex, "bond")
        local targetGuid = readNumber(item, prefix .. "target_guid")
        local targetName = item:getCustomAttribute(prefix .. "target_name")
        if targetGuid <= 0 or type(targetName) ~= "string" or targetName == "" then
            return nil
        end
        return {
            targetGuid = targetGuid,
            targetName = targetName,
            cooldownUntil = readNumber(item, prefix .. "cooldown_until"),
        }
    elseif gemKey == "collectorgem" then
        local prefix = getPrefix(socketIndex, "collector")
        return {
            outfitTenths = readNumber(item, prefix .. "outfit_tenths"),
            mountTenths = readNumber(item, prefix .. "mount_tenths"),
        }
    elseif gemKey == "professionmasterygem" then
        local prefix = getPrefix(socketIndex, "profession_mastery")
        local profession = item:getCustomAttribute(prefix .. "profession")
        if not masteryProfessions[profession] then
            return nil
        end
        return {
            profession = profession,
            gathers = readNumber(item, prefix .. "gathers"),
        }
    end
    return nil
end

function UtilityGems.clearState(item, socketIndex, gemKey)
    if not item or not item:isItem() then
        return
    end

    local keys = {}
    if gemKey == "cartographygem" then
        local prefix = getPrefix(socketIndex, "cartography")
        keys = { prefix .. "percent_tenths", prefix .. "discovered_zones", prefix .. "total_zones" }
    elseif gemKey == "bondgem" then
        local prefix = getPrefix(socketIndex, "bond")
        keys = { prefix .. "target_guid", prefix .. "target_name", prefix .. "cooldown_until" }
    elseif gemKey == "collectorgem" then
        local prefix = getPrefix(socketIndex, "collector")
        keys = { prefix .. "outfit_tenths", prefix .. "mount_tenths" }
    elseif gemKey == "professionmasterygem" then
        local prefix = getPrefix(socketIndex, "profession_mastery")
        keys = { prefix .. "profession", prefix .. "gathers" }
    end

    for _, key in ipairs(keys) do
        item:removeCustomAttribute(key)
    end
end

function UtilityGems.writeState(item, socketIndex, gemKey, state)
    if not item or not item:isItem() or not UtilityGems.supports(gemKey) then
        return
    end

    UtilityGems.clearState(item, socketIndex, gemKey)
    state = type(state) == "table" and state or {}
    if gemKey == "cartographygem" then
        local prefix = getPrefix(socketIndex, "cartography")
        item:setCustomAttribute(prefix .. "percent_tenths", math.max(0, tonumber(state.percentTenths) or 0))
        item:setCustomAttribute(prefix .. "discovered_zones", math.max(0, tonumber(state.discoveredZones) or 0))
        item:setCustomAttribute(prefix .. "total_zones", math.max(0, tonumber(state.totalZones) or 0))
    elseif gemKey == "bondgem" then
        local targetGuid = math.max(0, tonumber(state.targetGuid) or 0)
        local targetName = tostring(state.targetName or "")
        if targetGuid > 0 and targetName ~= "" then
            local prefix = getPrefix(socketIndex, "bond")
            item:setCustomAttribute(prefix .. "target_guid", targetGuid)
            item:setCustomAttribute(prefix .. "target_name", targetName)
            item:setCustomAttribute(prefix .. "cooldown_until", math.max(0, tonumber(state.cooldownUntil) or 0))
        end
    elseif gemKey == "collectorgem" then
        local prefix = getPrefix(socketIndex, "collector")
        item:setCustomAttribute(prefix .. "outfit_tenths", math.max(0, tonumber(state.outfitTenths) or 0))
        item:setCustomAttribute(prefix .. "mount_tenths", math.max(0, tonumber(state.mountTenths) or 0))
    elseif gemKey == "professionmasterygem" and masteryProfessions[state.profession] then
        local prefix = getPrefix(socketIndex, "profession_mastery")
        item:setCustomAttribute(prefix .. "profession", state.profession)
        item:setCustomAttribute(prefix .. "gathers", math.max(0, tonumber(state.gathers) or 0))
    end
end

local function appendLine(baseTooltip, line)
    local base = tostring(baseTooltip or "")
    return base ~= "" and (base .. "\n" .. line) or line
end

function UtilityGems.buildTooltip(gemKey, baseTooltip, item, socketIndex)
    local state = UtilityGems.readState(item, socketIndex, gemKey) or {}
    if gemKey == "cartographygem" then
        local tooltip = appendLine(baseTooltip, string.format("World Exploration: %.1f%%", (state.percentTenths or 0) / 10))
        return tooltip .. string.format("\nZones: %d/%d", math.max(0, tonumber(state.discoveredZones) or 0), math.max(0, tonumber(state.totalZones) or 0))
    elseif gemKey == "bondgem" then
        if state.targetName then
            return appendLine(baseTooltip, "Bounded to player: " .. state.targetName)
        end
        return baseTooltip or ""
    elseif gemKey == "collectorgem" then
        local tooltip = appendLine(baseTooltip, string.format("Outfits: %.1f%%", (state.outfitTenths or 0) / 10))
        return tooltip .. string.format("\nMounts: %.1f%%", (state.mountTenths or 0) / 10)
    elseif gemKey == "professionmasterygem" then
        if not state.profession then
            return appendLine(baseTooltip, "Profession: Not selected")
        end
        local progress = getMasteryProgress(state)
        local tooltip = appendLine(baseTooltip, string.format("%s Tier %d: %.1f%%", masteryProfessions[state.profession], progress.tier, progress.tierPercent))
        tooltip = tooltip .. string.format("\nEfficiency: %d%%", progress.efficiency)
        return tooltip .. string.format("\nRare Find: %.1f%%", progress.rareFind)
    end
    return baseTooltip or ""
end

function UtilityGems.buildCompactTooltip(gemKey, baseTooltip, item, socketIndex)
    local state = UtilityGems.readState(item, socketIndex, gemKey) or {}
    if gemKey == "cartographygem" then
        return string.format("Zones: %d/%d (%.1f%%)", math.max(0, tonumber(state.discoveredZones) or 0), math.max(0, tonumber(state.totalZones) or 0), (state.percentTenths or 0) / 10)
    elseif gemKey == "bondgem" then
        return state.targetName and ("Bounded: " .. state.targetName) or (baseTooltip or "")
    elseif gemKey == "collectorgem" then
        return string.format("Outfits: %.1f%%\nMounts: %.1f%%", (state.outfitTenths or 0) / 10, (state.mountTenths or 0) / 10)
    elseif gemKey == "traininggem" then
        return "Pet Gathering: 5 tiles / 30s"
    elseif gemKey == "professionmasterygem" then
        if not state.profession then
            return "Profession: Not selected"
        end
        local progress = getMasteryProgress(state)
        return string.format("%s Tier %d: %.1f%%\nEfficiency: %d%%  Rare Find: %.1f%%", masteryProfessions[state.profession], progress.tier, progress.tierPercent, progress.efficiency, progress.rareFind)
    end
    return baseTooltip or ""
end

local function forEachEquippedUtilityGem(player, wantedKey, callback)
    if wantedKey and type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, wantedKey, callback)
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS or {}) do
        local item = player:getSlotItem(slot)
        if item and _G.GemsSocket_hasSockets and _G.GemsSocket_hasSockets(item) then
            for socketIndex = 1, _G.GemsSocket_getSocketCount(item) do
                local gemKey = _G.GemsSocket_getSocketGemKey(item, socketIndex)
                if utilityKeys[gemKey] and (not wantedKey or gemKey == wantedKey) then
                    callback(item, socketIndex, gemKey)
                end
            end
        end
    end
end


UtilityGems.activePlayers = UtilityGems.activePlayers or {}

function UtilityGems.refreshActivePlayer(player)
    if not player or not player:isPlayer() then
        return false
    end

    local active = false
    if type(_G.GemsSocket_hasEquippedGem) == "function" then
        active = _G.GemsSocket_hasEquippedGem(player, "cartographygem")
            or _G.GemsSocket_hasEquippedGem(player, "collectorgem")
            or _G.GemsSocket_hasEquippedGem(player, "traininggem")
    else
        forEachEquippedUtilityGem(player, nil, function(_, _, gemKey)
            if gemKey == "cartographygem" or gemKey == "collectorgem" or gemKey == "traininggem" then
                active = true
            end
        end)
    end

    active = active or player:getItemById(30733, true) ~= nil or player:getItemById(30735, true) ~= nil
    UtilityGems.activePlayers[player:getId()] = active and true or nil
    return active
end

local function updateSocketState(item, socketIndex, gemKey, state)
    local current = UtilityGems.readState(item, socketIndex, gemKey) or {}
    local changed = false
    for key, value in pairs(state) do
        if current[key] ~= value then
            changed = true
            break
        end
    end
    if not changed then
        return
    end

    UtilityGems.writeState(item, socketIndex, gemKey, state)
    if _G.setSocketGemDisplayData then
        _G.setSocketGemDisplayData(item, socketIndex, GemsSocket.GEMS[gemKey])
    end
    if _G.refreshSocketItem then
        _G.refreshSocketItem(item)
    end
end

local function findProfessionMasterySocket(player, profession)
    local foundItem, foundSocket, foundState
    forEachEquippedUtilityGem(player, "professionmasterygem", function(item, socketIndex)
        if not foundItem then
            local state = UtilityGems.readState(item, socketIndex, "professionmasterygem")
            if state and state.profession == profession then
                foundItem, foundSocket, foundState = item, socketIndex, state
            end
        end
    end)
    return foundItem, foundSocket, foundState
end

function _G.ProfessionMastery_rollRareFind(player, profession)
    local _, _, state = findProfessionMasterySocket(player, profession)
    if not state then
        return false
    end
    local chance = getMasteryProgress(state).rareFind
    return chance >= 100 or math.random(10000) <= math.floor(chance * 100)
end

function _G.ProfessionMastery_adjustRewardCount(player, profession, baseCount)
    baseCount = math.max(1, tonumber(baseCount) or 1)
    local _, _, state = findProfessionMasterySocket(player, profession)
    if not state then
        return baseCount
    end

    local efficiency = getMasteryProgress(state).efficiency
    if efficiency <= 0 then
        return baseCount
    end
    if efficiency <= 100 then
        return baseCount + ((math.random(10000) <= efficiency * 100) and baseCount or 0)
    end

    local count = baseCount * 2
    local thirdRewardChance = math.min(50, (efficiency - 100) / 2)
    if math.random(10000) <= math.floor(thirdRewardChance * 100) then
        count = count + baseCount
    end
    return count
end

function _G.ProfessionMastery_onGather(player, profession)
    local item, socketIndex, state = findProfessionMasterySocket(player, profession)
    if not item or not state then
        return
    end
    state.gathers = math.max(0, tonumber(state.gathers) or 0) + 1
    updateSocketState(item, socketIndex, "professionmasterygem", state)
end

local function updateLooseGemState(item, gemKey, state)
    if not item then
        return
    end
    local current = UtilityGems.readState(item, nil, gemKey) or {}
    for key, value in pairs(state) do
        if current[key] ~= value then
            UtilityGems.writeState(item, nil, gemKey, state)
            if _G.GemsSocket_ensureGemItemMetadata then
                _G.GemsSocket_ensureGemItemMetadata(item)
            end
            if type(item.refresh) == "function" then
                item:refresh()
            end
            return
        end
    end
end

local function initializeExplorationState(player)
    local state = runtimeState[player:getId()] or {}
    runtimeState[player:getId()] = state
    if state.explorationInitialized then
        return state
    end

    state.explorationInitialized = true
    state.explorationPoints = 0
    state.discoveredZones = {}
    local config = GemsSocketCartography or {}
    for zoneId, zone in pairs(config.zones or {}) do
        if player:getStorageValue((config.storageBase or 993000) + zoneId) == 1 then
            state.discoveredZones[zoneId] = true
            state.explorationPoints = state.explorationPoints + (zone.points or 0)
        end
    end
    return state
end

local function getExplorationTenths(state)
    local total = math.max(0, tonumber(GemsSocketCartography and GemsSocketCartography.totalPoints) or 0)
    if total <= 0 then
        return 0
    end
    return math.max(0, math.min(1000, math.floor(((state.explorationPoints or 0) / total) * 1000 + 0.5)))
end

local function getCartographyZoneCounts(state)
    local totalZones = 0
    for _ in pairs((GemsSocketCartography and GemsSocketCartography.zones) or {}) do
        totalZones = totalZones + 1
    end

    local discoveredZones = 0
    for _ in pairs((state and state.discoveredZones) or {}) do
        discoveredZones = discoveredZones + 1
    end

    return discoveredZones, totalZones
end

local function updateCartography(player)
    local sockets = {}
    forEachEquippedUtilityGem(player, "cartographygem", function(item, socketIndex)
        sockets[#sockets + 1] = { item = item, socketIndex = socketIndex }
    end)
    local looseGem = player:getItemById(30733, true)
    if #sockets == 0 and not looseGem then
        return
    end
    if not GemsSocketCartography then
        return
    end

    local state = initializeExplorationState(player)
    if #sockets > 0 then
        local position = player:getPosition()
        for _, zone in ipairs(GemsSocketCartography.zonesByFloor[position.z] or {}) do
            if not state.discoveredZones[zone.id]
                and position.x >= zone.from.x and position.x <= zone.to.x
                and position.y >= zone.from.y and position.y <= zone.to.y then
                state.discoveredZones[zone.id] = true
                state.explorationPoints = (state.explorationPoints or 0) + zone.points
                player:setStorageValue(GemsSocketCartography.storageBase + zone.id, 1)
                player:sendTextMessage(MESSAGE_INFO_DESCR, "Cartography discovered: " .. zone.name .. ".")
                position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
            end
        end
    end

    local percentTenths = getExplorationTenths(state)
    local discoveredZones, totalZones = getCartographyZoneCounts(state)
    for _, socket in ipairs(sockets) do
        updateSocketState(socket.item, socket.socketIndex, "cartographygem", {
            percentTenths = percentTenths,
            discoveredZones = discoveredZones,
            totalZones = totalZones,
        })
    end
    updateLooseGemState(looseGem, "cartographygem", {
        percentTenths = percentTenths,
        discoveredZones = discoveredZones,
        totalZones = totalZones,
    })
end

local function calculateCollectorState(player)
    local catalog = GemsSocketCollectorCatalog or {}
    local outfits = catalog.outfits and catalog.outfits[player:getSex()] or {}

    if player:getGroup():getAccess() then
        return {
            outfitTenths = 1000,
            mountTenths = 1000,
        }
    end

    local ownedOutfits = 0
    for _, lookType in ipairs(outfits or {}) do
        if player:hasOutfit(lookType, 0) then
            ownedOutfits = ownedOutfits + 1
        end
    end

    local ownedMounts = 0
    for _, mountId in ipairs(catalog.mounts or {}) do
        if player:hasMount(mountId) then
            ownedMounts = ownedMounts + 1
        end
    end

    return {
        outfitTenths = #outfits > 0 and math.floor((ownedOutfits / #outfits) * 1000 + 0.5) or 0,
        mountTenths = #(catalog.mounts or {}) > 0 and math.floor((ownedMounts / #catalog.mounts) * 1000 + 0.5) or 0,
    }
end

local function updateCollector(player, now)
    local state = runtimeState[player:getId()] or {}
    runtimeState[player:getId()] = state
    if now < (state.nextCollectorUpdate or 0) then
        return
    end
    state.nextCollectorUpdate = now + 10

    local collection = nil
    forEachEquippedUtilityGem(player, "collectorgem", function(item, socketIndex)
        collection = collection or calculateCollectorState(player)
        updateSocketState(item, socketIndex, "collectorgem", collection)
    end)
end

local skillStages = {
    { min = 121, tries = 5 },
    { min = 91, tries = 8 },
    { min = 61, tries = 10 },
    { min = 41, tries = 15 },
    { min = 21, tries = 20 },
    { min = 10, tries = 30 },
}

local function getSkillTries(skillLevel)
    for _, stage in ipairs(skillStages) do
        if skillLevel >= stage.min then
            return stage.tries
        end
    end
    return 1
end

local function getLivingPet(player)
    local petId = player:getStorageValue(PET_ID_STORAGE)
    local pet = petId > 0 and Creature(petId) or nil
    if pet and pet:isMonster() and pet:getMaster() == player and pet:getHealth() > 0 then
        return pet
    end
    return nil
end

local function findTrainingResource(player, range)
    local resources = _G.ProfessionGatheringResources or {}
    local center = player:getPosition()
    local best = nil
    for dx = -range, range do
        for dy = -range, range do
            local distance = math.max(math.abs(dx), math.abs(dy))
            if distance >= 1 and (not best or distance <= best.distance) then
                local position = Position(center.x + dx, center.y + dy, center.z)
                local tile = Tile(position)
                for _, item in ipairs(tile and tile:getItems() or {}) do
                    local resource = resources[item:getId()]
                    if resource and player:getSkillLevel(resource.skill) >= (resource.data.requiredSkill or 0) then
                        if not best or distance < best.distance then
                            best = { item = item, position = position, resource = resource, distance = distance }
                        end
                    end
                end
            end
        end
    end
    return best
end

local function rollTrainingRewards(player, profession, data)
    local rewards = {}
    if math.random(200) == 200 or math.random(100) > ((data.loot_chance or 0) + 10) then
        return rewards
    end

    local rolls = math.random(15) == 15 and math.random(2, 3) or 1
    for _ = 1, rolls do
        local lootTable = data.normal_loot_table
        local rarityRoll = math.random(100)
        if _G.ProfessionMastery_rollRareFind(player, profession) or rarityRoll < 6 then
            lootTable = data.rare_loot_table
        elseif rarityRoll < 21 then
            lootTable = data.semi_rare_loot_table
        end
        if lootTable and #lootTable > 0 then
            local loot = lootTable[math.random(#lootTable)]
            local count = loot.count == 1 and 1 or math.random(math.max(1, loot.count or 1))
            count = _G.ProfessionMastery_adjustRewardCount(player, profession, count)
            rewards[loot.item_id] = (rewards[loot.item_id] or 0) + count
        end
    end
    return rewards
end

local function performTrainingHarvest(player, pet, target)
    local data = target.resource.data
    local rewards = rollTrainingRewards(player, target.resource.profession, data)
    local totalWeight = 0
    for itemId, count in pairs(rewards) do
        totalWeight = totalWeight + ItemType(itemId):getWeight(count)
    end
    if player:getFreeCapacity() < totalWeight then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Your pet found a resource, but you cannot carry the materials.")
        return false
    end

    target.item:transform(data.lower_tier)
    target.item:decay()
    pet:getPosition():sendDistanceEffect(target.position, CONST_ANI_SMALLSTONE)
    target.position:sendMagicEffect(target.resource.profession == "mining" and 178 or 181)

    for itemId, count in pairs(rewards) do
        player:addItem(itemId, count, false)
    end
    if next(rewards) then
        local skillLevel = player:getSkillLevel(target.resource.skill)
        player:addSkillTries(target.resource.skill, getSkillTries(skillLevel))
        if _G.GuildProfession_onActivity then
            _G.GuildProfession_onActivity(player, target.resource.profession, 1)
        end
        if _G.TriCraftGem_onProfessionActivity then
            _G.TriCraftGem_onProfessionActivity(player, target.resource.profession, 1)
        end
        _G.ProfessionMastery_onGather(player, target.resource.profession)
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Your pet gathers a nearby " .. target.resource.profession .. " resource.")
    return true
end

local function updateTraining(player, now)
    local equipped = false
    forEachEquippedUtilityGem(player, "traininggem", function()
        equipped = true
    end)
    if not equipped then
        return
    end

    local state = runtimeState[player:getId()] or {}
    runtimeState[player:getId()] = state
    local cooldownUntil = math.max(state.trainingCooldownUntil or 0, player:getStorageValue(TRAINING_COOLDOWN_STORAGE))
    if now < cooldownUntil then
        return
    end

    local pet = getLivingPet(player)
    if not pet then
        return
    end
    local range = math.max(1, math.min(5, _G.GemsSocket_getEquippedSocketBonusTotal(player, "socket_training_range")))
    local target = findTrainingResource(player, range)
    if not target then
        return
    end

    state.trainingCooldownUntil = now + math.max(1, _G.GemsSocket_getEquippedSocketBonusTotal(player, "socket_training_cooldown"))
    player:setStorageValue(TRAINING_COOLDOWN_STORAGE, state.trainingCooldownUntil)
    performTrainingHarvest(player, pet, target)
end

local function getBondSocket(player)
    local foundItem, foundSocket, foundState
    forEachEquippedUtilityGem(player, "bondgem", function(item, socketIndex)
        if not foundItem then
            local state = UtilityGems.readState(item, socketIndex, "bondgem")
            if state and state.targetGuid then
                foundItem, foundSocket, foundState = item, socketIndex, state
            end
        end
    end)
    return foundItem, foundSocket, foundState
end

local function isInCombat(player)
    if player:isPzLocked() then
        return true
    end
    return type(player.getCondition) == "function" and player:getCondition(CONDITION_INFIGHT, CONDITIONID_DEFAULT) ~= nil
end

local function isBondBlockedArea(player)
    if type(player.getDungeon) == "function" and player:getDungeon() then
        return true, "Bond teleportation is disabled inside dungeons."
    end
    local tile = Tile(player:getPosition())
    if tile and TILESTATE_PVPZONE and tile:hasFlag(TILESTATE_PVPZONE) then
        return true, "Bond teleportation is disabled inside PvP arenas."
    end
    return false
end

local function findOnlinePlayerByGuid(guid)
    guid = tonumber(guid) or 0
    for _, onlinePlayer in ipairs(Game.getPlayers()) do
        if onlinePlayer:getGuid() == guid then
            return onlinePlayer
        end
    end
    return nil
end

local bondTeleport = TalkAction("!teleport")

function bondTeleport.onSay(player)
    local item, socketIndex, state = getBondSocket(player)
    if not item then
        player:sendCancelMessage("You do not have an equipped bound Gem of Bond.")
        return false
    end

    local now = os.time()
    if now < (state.cooldownUntil or 0) then
        player:sendCancelMessage(string.format("Your bond needs %d more seconds to recover.", state.cooldownUntil - now))
        return false
    end
    local target = findOnlinePlayerByGuid(state.targetGuid)
    if not target then
        player:sendCancelMessage("The player bound to this gem is offline.")
        return false
    end
    if state.targetName ~= target:getName() then
        state.targetName = target:getName()
        updateSocketState(item, socketIndex, "bondgem", state)
    end
    if target == player then
        player:sendCancelMessage("You cannot travel through a bond to yourself.")
        return false
    end
    if isInCombat(player) or isInCombat(target) then
        player:sendCancelMessage("The bond cannot open while either player is in combat.")
        return false
    end
    local blocked, message = isBondBlockedArea(player)
    if not blocked then
        blocked, message = isBondBlockedArea(target)
    end
    if blocked then
        player:sendCancelMessage(message)
        return false
    end

    local destination = target:getPosition()
    local tile = Tile(destination)
    if not tile or tile:getHouse() or tile:hasFlag(TILESTATE_TELEPORT) or tile:hasFlag(TILESTATE_FLOORCHANGE) then
        player:sendCancelMessage("The bond cannot reach that location.")
        return false
    end

    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    player:teleportTo(destination, true)
    player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    state.cooldownUntil = now + math.max(1, _G.GemsSocket_getEquippedSocketBonusTotal(player, "socket_bond_cooldown"))
    updateSocketState(item, socketIndex, "bondgem", state)
    return false
end

bondTeleport:register()

local bondAction = Action()
bondAction:allowFarUse(true)

function bondAction.onUse(player, item, fromPosition, target)
    if UtilityGems.readState(item, nil, "bondgem") then
        player:sendCancelMessage("This Gem of Bond is already bound forever.")
        return true
    end
    if not target or not target:isPlayer() or target == player then
        player:sendCancelMessage("Use the Gem of Bond on another player.")
        return true
    end

    pendingBonds[player:getId()] = {
        itemUid = item:getRealUID(),
        targetGuid = target:getGuid(),
        targetName = target:getName(),
    }
    player:registerEvent("UtilityGemBondModal")
    local modal = ModalWindow(BOND_MODAL_ID, "Bind Gem Forever", string.format("Bind this gem forever to %s? This cannot be changed.", target:getName()))
    modal:addButton(1, "Bind")
    modal:addButton(2, "Cancel")
    modal:setDefaultEnterButton(2)
    modal:setDefaultEscapeButton(2)
    modal:sendToPlayer(player)
    return true
end

bondAction:id(BOND_GEM_ITEM_ID)
bondAction:register()

local masteryAction = Action()

function masteryAction.onUse(player, item)
    if UtilityGems.readState(item, nil, "professionmasterygem") then
        player:sendCancelMessage("This gem is already permanently bound to a profession.")
        return true
    end

    pendingMastery[player:getId()] = { itemUid = item:getRealUID() }
    player:registerEvent("UtilityGemMasteryModal")
    local modal = ModalWindow(MASTERY_CHOICE_MODAL_ID, "Choose Profession", "Choose the profession this gem will master forever.")
    modal:addChoice(1, "Mining")
    modal:addChoice(2, "Herbalist")
    modal:addChoice(3, "Woodcutting")
    modal:addButton(1, "Select")
    modal:addButton(2, "Cancel")
    modal:setDefaultEnterButton(1)
    modal:setDefaultEscapeButton(2)
    modal:sendToPlayer(player)
    return true
end

masteryAction:id(PROFESSION_MASTERY_GEM_ITEM_ID)
masteryAction:register()

local masteryModal = CreatureEvent("UtilityGemMasteryModal")
masteryModal:type("modalwindow")

function masteryModal.onModalWindow(player, modalWindowId, buttonId, choiceId)
    local pending = pendingMastery[player:getId()]
    if not pending then
        player:unregisterEvent("UtilityGemMasteryModal")
        return true
    end

    if modalWindowId == MASTERY_CHOICE_MODAL_ID then
        if buttonId ~= 1 then
            pendingMastery[player:getId()] = nil
            player:unregisterEvent("UtilityGemMasteryModal")
            return true
        end

        local choices = { [1] = "mining", [2] = "herbalist", [3] = "woodcutting" }
        pending.profession = choices[choiceId]
        if not pending.profession then
            pendingMastery[player:getId()] = nil
            player:unregisterEvent("UtilityGemMasteryModal")
            return true
        end

        local professionName = masteryProfessions[pending.profession]
        local modal = ModalWindow(MASTERY_CONFIRM_MODAL_ID, "Confirm Permanent Binding", string.format("Are you sure you want to bind %s to this gem forever?", professionName))
        modal:addButton(1, "Bind")
        modal:addButton(2, "Cancel")
        modal:setDefaultEnterButton(2)
        modal:setDefaultEscapeButton(2)
        modal:sendToPlayer(player)
        return true
    end

    if modalWindowId ~= MASTERY_CONFIRM_MODAL_ID then
        return true
    end
    pendingMastery[player:getId()] = nil
    player:unregisterEvent("UtilityGemMasteryModal")
    if buttonId ~= 1 or not pending.profession then
        return true
    end

    local item = player:getItem(pending.itemUid)
    if not item or item:getId() ~= PROFESSION_MASTERY_GEM_ITEM_ID or UtilityGems.readState(item, nil, "professionmasterygem") then
        player:sendCancelMessage("The profession gem is no longer available.")
        return true
    end

    UtilityGems.writeState(item, nil, "professionmasterygem", {
        profession = pending.profession,
        gathers = 0,
    })
    if _G.GemsSocket_ensureGemItemMetadata then
        _G.GemsSocket_ensureGemItemMetadata(item)
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("The gem is now bound forever to %s.", masteryProfessions[pending.profession]))
    player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    return true
end

masteryModal:register()

local bondModal = CreatureEvent("UtilityGemBondModal")
bondModal:type("modalwindow")

function bondModal.onModalWindow(player, modalWindowId, buttonId)
    if modalWindowId ~= BOND_MODAL_ID then
        return true
    end
    player:unregisterEvent("UtilityGemBondModal")
    local pending = pendingBonds[player:getId()]
    pendingBonds[player:getId()] = nil
    if buttonId ~= 1 or not pending then
        return true
    end

    local item = player:getItem(pending.itemUid)
    if not item or item:getId() ~= BOND_GEM_ITEM_ID or UtilityGems.readState(item, nil, "bondgem") then
        player:sendCancelMessage("The Gem of Bond is no longer available.")
        return true
    end

    UtilityGems.writeState(item, nil, "bondgem", {
        targetGuid = pending.targetGuid,
        targetName = pending.targetName,
        cooldownUntil = 0,
    })
    if _G.GemsSocket_ensureGemItemMetadata then
        _G.GemsSocket_ensureGemItemMetadata(item)
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, "The gem binds forever to " .. pending.targetName .. ".")
    player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    return true
end

bondModal:register()

local utilityDeath = CreatureEvent("UtilityGemBondDeath")
utilityDeath:type("death")

function utilityDeath.onDeath(player)
    local deadGuid = player:getGuid()
    local function notifyHolder(holder)
        local _, _, state = getBondSocket(holder)
        if state and state.targetGuid == deadGuid then
            holder:sendTextMessage(MESSAGE_INFO_DESCR, "Your bond trembles...")
        end
    end
    if type(_G.GemsSocket_forEachPlayerWithGem) == "function" then
        _G.GemsSocket_forEachPlayerWithGem("bondgem", notifyHolder)
        return true
    end
    for _, holder in ipairs(Game.getPlayers()) do
        notifyHolder(holder)
    end
    return true
end

utilityDeath:register()

local utilityLogin = CreatureEvent("UtilityGemsLogin")
utilityLogin:type("login")

function utilityLogin.onLogin(player)
    runtimeState[player:getId()] = nil
    UtilityGems.refreshActivePlayer(player)
    player:registerEvent("UtilityGemBondDeath")
    player:registerEvent("UtilityGemsLogout")
    return true
end

utilityLogin:register()

local utilityLogout = CreatureEvent("UtilityGemsLogout")
utilityLogout:type("logout")

function utilityLogout.onLogout(player)
    runtimeState[player:getId()] = nil
    UtilityGems.activePlayers[player:getId()] = nil
    pendingBonds[player:getId()] = nil
    pendingMastery[player:getId()] = nil
    return true
end

utilityLogout:register()

local utilityThink = GlobalEvent("UtilityGemsThink")

function utilityThink.onThink()
    local now = os.time()
    for playerId in pairs(UtilityGems.activePlayers) do
        local player = Player(playerId)
        if player then
            if type(_G.GemsSocketBonusCache) == "table" then
                _G.GemsSocketBonusCache.bumpMetric("utility_player_ticks")
            end
            updateCartography(player)
            updateCollector(player, now)
            updateTraining(player, now)
        else
            UtilityGems.activePlayers[playerId] = nil
        end
    end
    return true
end

utilityThink:interval(1000)
utilityThink:register()
