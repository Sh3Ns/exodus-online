TriCraftGem = TriCraftGem or {}

TriCraftGem.gemKey = "tricraftgem"
TriCraftGem.professions = {
    mining = "Mining",
    woodcutting = "Woodcutting",
    herbalist = "Herbalist",
}

local function triCraftToNumber(value, fallback)
    local number = tonumber(value)
    if number == nil then
        return fallback or 0
    end
    return number
end

local function getTriCraftGemData()
    return GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[TriCraftGem.gemKey] or nil
end

local function getSpecialConfig()
    return (GemsSocket and GemsSocket.SPECIALS and GemsSocket.SPECIALS.triCraft) or {}
end

local function getMessages()
    local special = getSpecialConfig()
    return type(special.messages) == "table" and special.messages or {}
end

local function setItemAttributeIfChanged(item, key, value)
    if item:getCustomAttribute(key) ~= value then
        item:setCustomAttribute(key, value)
    end
end

local function removeItemAttributeIfPresent(item, key)
    if item:getCustomAttribute(key) ~= nil then
        item:removeCustomAttribute(key)
    end
end

local function rollPercent(chance)
    chance = math.max(0, triCraftToNumber(chance, 0))
    if chance <= 0 then
        return false
    end
    return math.random(10000) <= math.min(10000, math.floor(chance * 100))
end

local function getMaxGemLevel()
    local gemData = getTriCraftGemData()
    if type(gemData) ~= "table" or type(gemData.tiers) ~= "table" then
        return 1
    end

    local maxLevel = 1
    for level in pairs(gemData.tiers) do
        maxLevel = math.max(maxLevel, tonumber(level) or 1)
    end
    return maxLevel
end

local function getTierConfig(level)
    local gemData = getTriCraftGemData()
    local tiers = type(gemData) == "table" and gemData.tiers or nil
    local tierData = type(tiers) == "table" and tiers[math.max(1, triCraftToNumber(level, 1))] or nil
    if type(tierData) == "table" and type(tierData.triCraft) == "table" then
        return tierData.triCraft
    end

    local fallbackTier = type(tiers) == "table" and tiers[1] or nil
    if type(fallbackTier) == "table" and type(fallbackTier.triCraft) == "table" then
        return fallbackTier.triCraft
    end
    return {}
end

local function getRequirement(level)
    return math.max(1, triCraftToNumber(getTierConfig(level).requiredPerProfession, 1000))
end

local function getTierValue(level, key, fallback)
    return triCraftToNumber(getTierConfig(level)[key], fallback)
end

local function normalizeState(state)
    state = type(state) == "table" and state or {}
    state.mining = math.max(0, triCraftToNumber(state.mining, 0))
    state.woodcutting = math.max(0, triCraftToNumber(state.woodcutting, 0))
    state.herbalist = math.max(0, triCraftToNumber(state.herbalist, 0))
    return state
end

local function getStateTotal(state)
    state = normalizeState(state)
    return state.mining + state.woodcutting + state.herbalist
end

local function getProgressPercent(value, requirement)
    return math.min(100, math.floor((math.max(0, triCraftToNumber(value, 0)) / math.max(1, requirement)) * 100))
end

local function getPathAndBalance(state, requirement)
    state = normalizeState(state)
    requirement = math.max(1, triCraftToNumber(requirement, 1000))

    local miningPercent = getProgressPercent(state.mining, requirement)
    local woodcuttingPercent = getProgressPercent(state.woodcutting, requirement)
    local herbalistPercent = getProgressPercent(state.herbalist, requirement)
    local minPercent = math.min(miningPercent, woodcuttingPercent, herbalistPercent)
    local maxPercent = math.max(miningPercent, woodcuttingPercent, herbalistPercent)
    local tolerance = math.max(0, triCraftToNumber(getSpecialConfig().balanceTolerancePercent, 10))

    if minPercent >= 100 then
        return "Primal", "stable"
    end
    if minPercent > 0 and maxPercent - minPercent <= tolerance then
        return "Primal", "stable"
    end
    if miningPercent >= woodcuttingPercent and miningPercent >= herbalistPercent then
        return "Stone", "unstable"
    end
    if woodcuttingPercent >= herbalistPercent then
        return "Root", "unstable"
    end
    return "Bloom", "unstable"
end

local function addExtraMaterial(player, profession, level)
    local special = getSpecialConfig()
    local materialPool = type(special.materials) == "table" and special.materials[profession] or nil
    if type(materialPool) ~= "table" or #materialPool <= 0 then
        return false
    end

    local chance = getTierValue(level, "bonusChance", 0)
    if not rollPercent(chance) then
        return false
    end

    local itemId = tonumber(materialPool[math.random(#materialPool)]) or 0
    if itemId <= 0 then
        return false
    end

    local count = math.max(1, getTierValue(level, "bonusCount", 1))
    player:addItem(itemId, count)
    player:getPosition():sendMagicEffect(special.bonusEffect or CONST_ME_MAGIC_GREEN)

    local itemName = ItemType(itemId):getName()
    local message = getMessages().bonus or "Tri-Craft Gem yields %dx extra %s."
    player:sendTextMessage(MESSAGE_STATUS_SMALL, string.format(message, count, itemName ~= "" and itemName or "materials"))
    return true
end

function TriCraftGem.isGem(gemKey)
    return gemKey == TriCraftGem.gemKey
end

function TriCraftGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_tricraft_", socketIndex)
    end
    return "tricraft_"
end

function TriCraftGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = TriCraftGem.getAttributePrefix(socketIndex)
    local state = normalizeState({
        mining = item:getCustomAttribute(prefix .. "mining"),
        woodcutting = item:getCustomAttribute(prefix .. "woodcutting"),
        herbalist = item:getCustomAttribute(prefix .. "herbalist"),
    })
    if getStateTotal(state) <= 0 then
        return nil
    end
    return state
end

function TriCraftGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = TriCraftGem.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "mining")
    item:removeCustomAttribute(prefix .. "woodcutting")
    item:removeCustomAttribute(prefix .. "herbalist")
end

function TriCraftGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    state = normalizeState(state)
    local prefix = TriCraftGem.getAttributePrefix(socketIndex)
    if getStateTotal(state) <= 0 then
        TriCraftGem.clearState(item, socketIndex)
        return
    end

    if state.mining > 0 then setItemAttributeIfChanged(item, prefix .. "mining", state.mining) else removeItemAttributeIfPresent(item, prefix .. "mining") end
    if state.woodcutting > 0 then setItemAttributeIfChanged(item, prefix .. "woodcutting", state.woodcutting) else removeItemAttributeIfPresent(item, prefix .. "woodcutting") end
    if state.herbalist > 0 then setItemAttributeIfChanged(item, prefix .. "herbalist", state.herbalist) else removeItemAttributeIfPresent(item, prefix .. "herbalist") end
end

function TriCraftGem.getCompactProgress(state, level)
    local requirement = getRequirement(level or 1)
    state = normalizeState(state)
    local path, balance = getPathAndBalance(state, requirement)
    return string.format(
        "Woodcutting: %d%%\nMining: %d%%\nHerbalist: %d%%\nPath: %s\nBalance: %s",
        getProgressPercent(state.woodcutting, requirement),
        getProgressPercent(state.mining, requirement),
        getProgressPercent(state.herbalist, requirement),
        path,
        balance
    )
end

function TriCraftGem.buildTooltip(baseTooltip, state, level)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    local requirement = getRequirement(level or 1)
    state = normalizeState(state)
    local path, balance = getPathAndBalance(state, requirement)
    lines[#lines + 1] = string.format("Woodcutting: %d / %d (%d%%)", math.min(state.woodcutting, requirement), requirement, getProgressPercent(state.woodcutting, requirement))
    lines[#lines + 1] = string.format("Mining: %d / %d (%d%%)", math.min(state.mining, requirement), requirement, getProgressPercent(state.mining, requirement))
    lines[#lines + 1] = string.format("Herbalist: %d / %d (%d%%)", math.min(state.herbalist, requirement), requirement, getProgressPercent(state.herbalist, requirement))
    lines[#lines + 1] = string.format("Path: %s", path)
    lines[#lines + 1] = string.format("Balance: %s", balance)
    lines[#lines + 1] = string.format("Extra Material Chance: %d%%", math.floor(getTierValue(level or 1, "bonusChance", 0)))
    lines[#lines + 1] = string.format("Extra Material Quantity: %d", math.floor(getTierValue(level or 1, "bonusCount", 1)))
    return table.concat(lines, "\n")
end

function TriCraftGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" or type(GemsSocket.EQUIPPED_SOCKET_SLOTS) ~= "table" then
        return
    end

    local hasSockets = _G.GemsSocket_hasSockets
    local getSocketCount = _G.GemsSocket_getSocketCount
    local getSocketGemKey = _G.GemsSocket_getSocketGemKey
    if type(hasSockets) ~= "function" or type(getSocketCount) ~= "function" or type(getSocketGemKey) ~= "function" then
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local item = player:getSlotItem(slot)
        if item and hasSockets(item) then
            for socketIndex = 1, getSocketCount(item) do
                if TriCraftGem.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function TriCraftGem.refreshSocket(item, socketIndex)
    if type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, getTriCraftGemData())
    end
    if type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
end

function TriCraftGem.refreshSocketDisplay(item, socketIndex)
    if type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, getTriCraftGemData())
    end
    if type(_G.GemsSocket_refreshSocketDisplay) == "function" then
        _G.GemsSocket_refreshSocketDisplay(item)
    end
end

function TriCraftGem.levelUp(player, item, socketIndex, currentLevel)
    local maxLevel = getMaxGemLevel()
    local special = getSpecialConfig()
    if currentLevel >= maxLevel then
        TriCraftGem.refreshSocketDisplay(item, socketIndex)
        return
    end

    item:setCustomAttribute(string.format("socket_%d_level", socketIndex), currentLevel + 1)
    TriCraftGem.clearState(item, socketIndex)
    TriCraftGem.refreshSocket(item, socketIndex)
    player:getPosition():sendMagicEffect(special.levelUpEffect or CONST_ME_HOLYAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format(getMessages().levelUp or "Tri-Craft Gem harmonizes into level %d.", currentLevel + 1))
end

function TriCraftGem.onProfessionActivity(player, profession, amount)
    if not player or not player:isPlayer() or not TriCraftGem.professions[profession] then
        return false
    end

    amount = math.max(1, triCraftToNumber(amount, 1))
    local handled = false
    TriCraftGem.forEachEquippedSocket(player, function(item, socketIndex)
        if handled then
            return
        end

        local level = type(_G.GemsSocket_getSocketGemLevel) == "function" and math.max(1, _G.GemsSocket_getSocketGemLevel(item, socketIndex)) or 1
        local requirement = getRequirement(level)
        local state = normalizeState(TriCraftGem.readState(item, socketIndex))
        state[profession] = math.min(requirement, math.max(0, triCraftToNumber(state[profession], 0)) + amount)

        if state.mining >= requirement and state.woodcutting >= requirement and state.herbalist >= requirement and level < getMaxGemLevel() then
            TriCraftGem.writeState(item, socketIndex, state)
            TriCraftGem.levelUp(player, item, socketIndex, level)
        else
            TriCraftGem.writeState(item, socketIndex, state)
            TriCraftGem.refreshSocketDisplay(item, socketIndex)
        end

        addExtraMaterial(player, profession, level)
        handled = true
    end)
    return handled
end

_G.TriCraftGem_onProfessionActivity = function(player, profession, amount)
    return TriCraftGem.onProfessionActivity(player, profession, amount)
end
