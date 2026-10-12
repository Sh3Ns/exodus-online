print(">> [Gems Socket] Loaded")
GemsSocket = GemsSocket or {}

local function buildGemIndexes()
    GemsSocket.gemsByItemId = {}
    for gemKey, gemData in pairs(GemsSocket.GEMS) do
        GemsSocket.gemsByItemId[gemData.itemId] = gemKey
    end
end

local function ensureGemIndexes(itemId)
    if type(GemsSocket.GEMS) ~= "table" then
        return
    end

    if type(GemsSocket.gemsByItemId) ~= "table" or not next(GemsSocket.gemsByItemId) then
        buildGemIndexes()
        return
    end

    if itemId and not GemsSocket.gemsByItemId[itemId] then
        for gemKey, gemData in pairs(GemsSocket.GEMS) do
            if gemData and gemData.itemId == itemId then
                buildGemIndexes()
                return
            end
        end
    end
end

buildGemIndexes()

if type(GemsSocketConditionCleanse) ~= "table" then
    dofile("data/scripts/customs/gems_socket/condition_cleanse_gem.lua")
end
if type(_G.GemsSocket_registerAmplifierGem) ~= "function" then
    dofile("data/scripts/customs/gems_socket/gem_amplifier.lua")
end
if type(_G.GemsSocket_registerAmplifierGem) == "function" then
    _G.GemsSocket_registerAmplifierGem()
end

selectedTargets = {}
EXTENDED_OPCODE_CHUNK_SIZE = 6000

SOCKET_ABYSSAL_DEPTHS_DURATION = 6
SOCKET_ABYSSAL_DEPTHS_COOLDOWN = 20
abyssalDepthsState = {}
SOCKET_SPELLFURY_DURATION = 6
SOCKET_SPELLFURY_COOLDOWN = 20
spellfuryState = {}
SOCKET_ASCENDANCE_DURATION = 6
SOCKET_ASCENDANCE_COOLDOWN = 20
SOCKET_ASCENDANCE_RANGE = 2
ascendanceState = {}
SOCKET_VOLTSTONE_COOLDOWN = 20
voltstoneState = {}
SOCKET_EMBERSTONE_DURATION = 6
SOCKET_EMBERSTONE_COOLDOWN = 20
SOCKET_EMBERSTONE_RANGE = 2
emberstoneState = {}
SOCKET_BINDSTONE_COOLDOWN = 20
bindstoneState = {}
bindstoneTargetState = {}
SOCKET_SURGESTONE_COOLDOWN = 20
SOCKET_SURGESTONE_RANGE = 3
SOCKET_SURGESTONE_TARGETS = 3
surgestoneState = {}
SOCKET_WARSTONE_DURATION = 6
SOCKET_WARSTONE_COOLDOWN = 20
warstoneState = {}
SOCKET_BOONSTONE_DURATION = 6
SOCKET_BOONSTONE_COOLDOWN = 30
boonstoneState = {}
SOCKET_VENOMSTONE_DURATION = 6
SOCKET_VENOMSTONE_COOLDOWN = 20
venomstoneState = {}
SOCKET_DREADSTONE_DURATION = 4
SOCKET_DREADSTONE_COOLDOWN = 20
dreadstoneState = {}
SOCKET_SPIRITSTONE_DURATION = 10
SOCKET_SPIRITSTONE_COOLDOWN = 30
spiritstoneState = {}
SOCKET_VOIDSTONE_DURATION = 6
SOCKET_VOIDSTONE_COOLDOWN = 20
voidstoneState = {}
SOCKET_GRAVITYSTONE_DURATION = 6
SOCKET_GRAVITYSTONE_COOLDOWN = 25
gravitystoneState = {}
SOCKET_CHRONOSTONE_DURATION = 6
SOCKET_CHRONOSTONE_COOLDOWN = 25
chronostoneState = {}
SOCKET_CHRONOSTONE_STORAGE_UNTIL = 992201
SOCKET_CHRONOSTONE_STORAGE_PERCENT = 992202
SOCKET_MARKSMANSTONE_COOLDOWN = 20
marksmanstoneState = {}
SOCKET_BATTLESTONE_COOLDOWN = 25
battlestoneState = {}
SOCKET_ARCANESTONE_COOLDOWN = 25
arcanestoneState = {}
SOCKET_MENDSTONE_DURATION = 6
SOCKET_MENDSTONE_COOLDOWN = 25
mendstoneState = {}
SOCKET_TOTEM_DURATION = 10
SOCKET_TOTEM_COOLDOWN = 25
totemGemState = {}
SOCKET_TOTEM_RANGE = 2
SOCKET_SACRED_LINK_DURATION = 6
SOCKET_SACRED_LINK_COOLDOWN = 30
SOCKET_SACRED_LINK_RANGE = 7
sacredLinkState = {}
sacredLinkRedirectLock = {}
SOCKET_REVERSAL_DURATION = 6
SOCKET_REVERSAL_COOLDOWN = 30
reversalState = {}
SOCKET_MIRRORGEM_DEFAULT_COOLDOWN = 30
mirrorgemState = {}
mirrorgemEchoLock = {}
SOCKET_SOULMARK_COOLDOWN = 30
soulmarkGemState = {}
kingsguardGemState = {}
mimicGemState = {}
cowardsCrownState = {}
betrayalGemCooldownState = {}
betrayalGemActiveState = {}
shockwaveStoneState = {}
riftstepGemState = {}
siphonBloomState = {}
siphonBloomActive = {}
phoenixReviveState = {}
hauntedHuntRuntimeState = {}
hauntedHuntBossDamageState = {}

local function toNumber(value, fallback)
    local num = tonumber(value)
    if not num then
        return fallback
    end
    return num
end

local function setCustomAttributeIfChanged(item, key, value)
    if not item or not item.isItem or not item:isItem() then
        return false
    end
    if item:getCustomAttribute(key) == value then
        return false
    end
    item:setCustomAttribute(key, value)
    return true
end

local function getSocketCount(item)
    return math.max(0, toNumber(item:getCustomAttribute("socket_count"), 0))
end

local function getConfiguredSocketCount(itemId)
    return math.max(0, toNumber(GemsSocket.SOCKET_ADDER_ITEMS[itemId], 0))
end

local function setSocketCount(item, count)
    local clampedCount = math.max(0, math.min(GemsSocket.MAX_SOCKETS, count))
    item:setCustomAttribute("socket_count", clampedCount)
    if clampedCount > 0 then
        item:setCustomAttribute("socket_enabled", 1)
    else
        item:removeCustomAttribute("socket_enabled")
    end
end

local function hasSockets(item)
    if not item or not item:isItem() then
        return false
    end

    if GemsSocket.gemsByItemId and GemsSocket.gemsByItemId[item:getId()] then
        return false
    end

    local enabled = tonumber(item:getCustomAttribute("socket_enabled") or 0) or 0
    return enabled > 0 and getSocketCount(item) > 0
end

local function getSocketGemKey(item, index)
    return item:getCustomAttribute(string.format("socket_%d_gem", index))
end

local function getSocketGemLevel(item, index)
    return math.max(1, toNumber(item:getCustomAttribute(string.format("socket_%d_level", index)), 1))
end

local function setSocketGemKey(item, index, gemKey)
    local key = string.format("socket_%d_gem", index)
    if gemKey and gemKey ~= "" then
        item:setCustomAttribute(key, gemKey)
    else
        item:removeCustomAttribute(key)
    end
end

local function setSocketGemLevel(item, index, level)
    local key = string.format("socket_%d_level", index)
    level = math.max(1, toNumber(level, 1))
    item:setCustomAttribute(key, level)
end

GemsSocket.EQUIPPED_SOCKET_SLOTS = {
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

if type(_G.GemsSocketBonusCache) ~= "table" then
    dofile("data/scripts/customs/gems_socket/socket_bonus_cache.lua")
end
if type(_G.GemsSocketVisibilitySyncQueue) ~= "table" then
    dofile("data/scripts/customs/gems_socket/visibility_sync_queue.lua")
end

local function getGemMaxLevel(gemData)
    if type(gemData) ~= "table" then
        return 1
    end

    if type(gemData.tiers) ~= "table" then
        return 1
    end

    local maxLevel = 0
    for level in pairs(gemData.tiers) do
        maxLevel = math.max(maxLevel, tonumber(level) or 0)
    end
    return math.max(1, maxLevel)
end

local function getGemLevelData(gemKey, level)
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not gemData then
        return nil, nil, 1
    end

    local maxLevel = getGemMaxLevel(gemData)
    local clampedLevel = math.max(1, math.min(toNumber(level, 1), maxLevel))
    local levelData = gemData.tiers and (gemData.tiers[clampedLevel] or gemData.tiers[tostring(clampedLevel)]) or nil

    if not levelData then
        levelData = {
            name = gemData.name,
            bonuses = gemData.bonuses,
            tooltip = gemData.tooltip,
            upgrade = nil,
        }
    end

    return gemData, levelData, maxLevel
end

local PredatorEye = {
    gemKey = "predatoreye",
    defaultKillsRequired = 500,
    defaultDamagePercent = 12,
    defaultExecuteThreshold = 5,
}

function PredatorEye.isGem(gemKey)
    return gemKey == PredatorEye.gemKey
end

function PredatorEye.getSettings(level)
    local gemData, levelData = getGemLevelData(PredatorEye.gemKey, level or 1)
    local gemPredator = type(gemData) == "table" and type(gemData.predator) == "table" and gemData.predator or nil
    local levelPredator = type(levelData) == "table" and type(levelData.predator) == "table" and levelData.predator or nil

    return {
        killsRequired = math.max(1, toNumber(levelPredator and levelPredator.killsRequired, gemPredator and gemPredator.killsRequired or PredatorEye.defaultKillsRequired)),
        damagePercent = math.max(0, toNumber(levelPredator and levelPredator.damagePercent, gemPredator and gemPredator.damagePercent or PredatorEye.defaultDamagePercent)),
        executeThreshold = math.max(0, toNumber(levelPredator and levelPredator.executeThreshold, gemPredator and gemPredator.executeThreshold or PredatorEye.defaultExecuteThreshold)),
    }
end

function PredatorEye.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_predator_", socketIndex)
    end
    return "predator_"
end

function PredatorEye.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = PredatorEye.getAttributePrefix(socketIndex)
    local activeName = item:getCustomAttribute(prefix .. "active_name")
    local nextName = item:getCustomAttribute(prefix .. "next_name")
    local nextKills = math.max(0, tonumber(item:getCustomAttribute(prefix .. "next_kills")) or 0)

    if type(activeName) ~= "string" or activeName == "" then
        activeName = nil
    end
    if type(nextName) ~= "string" or nextName == "" then
        nextName = nil
    end
    if not activeName and not nextName and nextKills <= 0 then
        return nil
    end

    return {
        activeName = activeName,
        nextName = nextName,
        nextKills = nextKills,
    }
end

function PredatorEye.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = PredatorEye.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "active_name")
    item:removeCustomAttribute(prefix .. "next_name")
    item:removeCustomAttribute(prefix .. "next_kills")
end

function PredatorEye.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    PredatorEye.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local prefix = PredatorEye.getAttributePrefix(socketIndex)
    if type(state.activeName) == "string" and state.activeName ~= "" then
        item:setCustomAttribute(prefix .. "active_name", state.activeName)
    end
    if type(state.nextName) == "string" and state.nextName ~= "" then
        item:setCustomAttribute(prefix .. "next_name", state.nextName)
    end

    local nextKills = math.max(0, tonumber(state.nextKills) or 0)
    if nextKills > 0 then
        item:setCustomAttribute(prefix .. "next_kills", nextKills)
    end
end

function PredatorEye.getCompactProgress(state, level)
    local settings = PredatorEye.getSettings(level)
    state = type(state) == "table" and state or nil
    if state and state.activeName and state.nextName and (state.nextKills or 0) > 0 then
        return string.format("Predator: %s -> %s %d/%d", state.activeName, state.nextName, state.nextKills, settings.killsRequired)
    end
    if state and state.activeName then
        return string.format("Predator: %s %d/%d", state.activeName, settings.killsRequired, settings.killsRequired)
    end
    if state and state.nextName then
        return string.format("Predator: %s %d/%d", state.nextName, state.nextKills or 0, settings.killsRequired)
    end
    return string.format("Predator: No prey 0/%d", settings.killsRequired)
end

function PredatorEye.buildTooltip(baseTooltip, state, level)
    local settings = PredatorEye.getSettings(level)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    state = type(state) == "table" and state or nil
    if state and state.activeName then
        lines[#lines + 1] = string.format("Power: %s, %d/%d", state.activeName, settings.killsRequired, settings.killsRequired)
    elseif state and state.nextName then
        lines[#lines + 1] = string.format("Power: %s, %d/%d", state.nextName, state.nextKills or 0, settings.killsRequired)
    else
        lines[#lines + 1] = string.format("Power: No prey, 0/%d", settings.killsRequired)
    end

    if state and state.activeName and state.nextName and (state.nextKills or 0) > 0 then
        lines[#lines + 1] = string.format("Next: %s, %d/%d", state.nextName, state.nextKills, settings.killsRequired)
    end

    return table.concat(lines, "\n")
end

PhoenixGem = {
    gemKey = "phoenixgem",
    defaultKillsRequired = 5000,
    defaultMaxCharges = 3,
}

function PhoenixGem.isGem(gemKey)
    return gemKey == PhoenixGem.gemKey
end

function PhoenixGem.getSettings(level)
    local gemData, levelData = getGemLevelData(PhoenixGem.gemKey, level or 1)
    local gemPhoenix = type(gemData) == "table" and type(gemData.phoenix) == "table" and gemData.phoenix or nil
    local levelPhoenix = type(levelData) == "table" and type(levelData.phoenix) == "table" and levelData.phoenix or nil
    return {
        killsRequired = math.max(1, toNumber(levelPhoenix and levelPhoenix.killsRequired, gemPhoenix and gemPhoenix.killsRequired or PhoenixGem.defaultKillsRequired)),
        maxCharges = math.max(1, toNumber(levelPhoenix and levelPhoenix.maxCharges, gemPhoenix and gemPhoenix.maxCharges or PhoenixGem.defaultMaxCharges)),
    }
end

function PhoenixGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_phoenix_", socketIndex)
    end
    return "phoenix_"
end

function PhoenixGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = PhoenixGem.getAttributePrefix(socketIndex)
    local charges = math.max(0, tonumber(item:getCustomAttribute(prefix .. "charges")) or 0)
    local kills = math.max(0, tonumber(item:getCustomAttribute(prefix .. "kills")) or 0)
    if charges <= 0 and kills <= 0 then
        return nil
    end

    return {
        charges = charges,
        kills = kills,
    }
end

function PhoenixGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = PhoenixGem.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "charges")
    item:removeCustomAttribute(prefix .. "kills")
end

function PhoenixGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    PhoenixGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local prefix = PhoenixGem.getAttributePrefix(socketIndex)
    local charges = math.max(0, tonumber(state.charges) or 0)
    local kills = math.max(0, tonumber(state.kills) or 0)
    if charges > 0 then
        item:setCustomAttribute(prefix .. "charges", charges)
    end
    if kills > 0 then
        item:setCustomAttribute(prefix .. "kills", kills)
    end
end

function PhoenixGem.getCompactProgress(state, level)
    local settings = PhoenixGem.getSettings(level)
    state = type(state) == "table" and state or {}
    local charges = math.max(0, tonumber(state.charges) or 0)
    local kills = math.max(0, tonumber(state.kills) or 0)
    return string.format("Phoenix: %d/%d revives %d/%d", charges, settings.maxCharges, kills, settings.killsRequired)
end

function PhoenixGem.buildTooltip(baseTooltip, state, level)
    local settings = PhoenixGem.getSettings(level)
    state = type(state) == "table" and state or {}
    local charges = math.max(0, tonumber(state.charges) or 0)
    local kills = math.max(0, tonumber(state.kills) or 0)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end
    lines[#lines + 1] = string.format("Revives: %d/%d", charges, settings.maxCharges)
    if charges < settings.maxCharges then
        lines[#lines + 1] = string.format("Next Charge: %d/%d kills", kills, settings.killsRequired)
    else
        lines[#lines + 1] = "Next Charge: Full"
    end
    return table.concat(lines, "\n")
end

function PhoenixGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, PhoenixGem.gemKey, callback)
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local item = player:getSlotItem(slot)
        if item and hasSockets(item) then
            for socketIndex = 1, getSocketCount(item) do
                if PhoenixGem.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function PhoenixGem.advanceProgress(item, socketIndex)
    if not item then
        return false
    end

    local settings = PhoenixGem.getSettings(getSocketGemLevel(item, socketIndex))
    local state = PhoenixGem.readState(item, socketIndex) or {}
    state.charges = math.max(0, tonumber(state.charges) or 0)
    state.kills = math.max(0, tonumber(state.kills) or 0)
    if state.charges >= settings.maxCharges then
        return false
    end

    state.kills = state.kills + 1
    local gainedCharge = false
    if state.kills >= settings.killsRequired then
        state.kills = 0
        state.charges = math.min(settings.maxCharges, state.charges + 1)
        gainedCharge = true
    end

    PhoenixGem.writeState(item, socketIndex, state)
    setSocketGemDisplayData(item, socketIndex, GemsSocket.GEMS[PhoenixGem.gemKey])
    GemsSocket_refreshSocketDisplay(item)
    return gainedCharge
end

function PhoenixGem.consumeCharge(player)
    if not player then
        return false
    end

    local consumed = false
    PhoenixGem.forEachEquippedSocket(player, function(item, socketIndex)
        if consumed then
            return
        end

        local state = PhoenixGem.readState(item, socketIndex) or {}
        local charges = math.max(0, tonumber(state.charges) or 0)
        if charges <= 0 then
            return
        end

        state.charges = charges - 1
        PhoenixGem.writeState(item, socketIndex, state)
        setSocketGemDisplayData(item, socketIndex, GemsSocket.GEMS[PhoenixGem.gemKey])
        GemsSocket_refreshSocketDisplay(item)
        consumed = true
    end)

    return consumed
end

ChronicleGem = {
    gemKey = "chroniclegem",
}

local CHRONICLE_GEM_BONUS_SUBID = 992431

function ChronicleGem.isGem(gemKey)
    return gemKey == ChronicleGem.gemKey
end

function ChronicleGem.getSettings(level)
    local gemData, levelData = getGemLevelData(ChronicleGem.gemKey, level or 1)
    local gemChronicle = type(gemData) == "table" and type(gemData.chronicle) == "table" and gemData.chronicle or nil
    local levelChronicle = type(levelData) == "table" and type(levelData.chronicle) == "table" and levelData.chronicle or nil
    return {
        monsterKillsPerStack = math.max(1, toNumber(levelChronicle and levelChronicle.monsterKillsPerStack, gemChronicle and gemChronicle.monsterKillsPerStack or 100000)),
        bossKillsPerStack = math.max(1, toNumber(levelChronicle and levelChronicle.bossKillsPerStack, gemChronicle and gemChronicle.bossKillsPerStack or 100)),
        damagePerStack = math.max(0, toNumber(levelChronicle and levelChronicle.damagePerStack, gemChronicle and gemChronicle.damagePerStack or 1)),
        healthPerStack = math.max(0, toNumber(levelChronicle and levelChronicle.healthPerStack, gemChronicle and gemChronicle.healthPerStack or 200)),
        manaPerStack = math.max(0, toNumber(levelChronicle and levelChronicle.manaPerStack, gemChronicle and gemChronicle.manaPerStack or 125)),
        maxMonsterStacks = math.max(0, toNumber(levelChronicle and levelChronicle.maxMonsterStacks, gemChronicle and gemChronicle.maxMonsterStacks or math.max(1, toNumber(level, 1)))),
        maxBossStacks = math.max(0, toNumber(levelChronicle and levelChronicle.maxBossStacks, gemChronicle and gemChronicle.maxBossStacks or math.max(1, toNumber(level, 1)))),
    }
end

function ChronicleGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_chronicle_", socketIndex)
    end
    return "chronicle_"
end

function ChronicleGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = ChronicleGem.getAttributePrefix(socketIndex)
    local monsterKills = math.max(0, tonumber(item:getCustomAttribute(prefix .. "monster_kills")) or 0)
    local bossKills = math.max(0, tonumber(item:getCustomAttribute(prefix .. "boss_kills")) or 0)
    if monsterKills <= 0 and bossKills <= 0 then
        return nil
    end

    return {
        monsterKills = monsterKills,
        bossKills = bossKills,
    }
end

function ChronicleGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = ChronicleGem.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "monster_kills")
    item:removeCustomAttribute(prefix .. "boss_kills")
end

function ChronicleGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    ChronicleGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local prefix = ChronicleGem.getAttributePrefix(socketIndex)
    local monsterKills = math.max(0, tonumber(state.monsterKills) or 0)
    local bossKills = math.max(0, tonumber(state.bossKills) or 0)
    if monsterKills > 0 then
        item:setCustomAttribute(prefix .. "monster_kills", monsterKills)
    end
    if bossKills > 0 then
        item:setCustomAttribute(prefix .. "boss_kills", bossKills)
    end
end

function ChronicleGem.getProgress(state, level)
    local settings = ChronicleGem.getSettings(level)
    state = type(state) == "table" and state or {}
    local monsterKills = math.max(0, tonumber(state.monsterKills) or 0)
    local bossKills = math.max(0, tonumber(state.bossKills) or 0)
    return {
        monsterKills = monsterKills,
        bossKills = bossKills,
        monsterStacks = math.min(settings.maxMonsterStacks, math.floor(monsterKills / settings.monsterKillsPerStack)),
        bossStacks = math.min(settings.maxBossStacks, math.floor(bossKills / settings.bossKillsPerStack)),
        settings = settings,
    }
end

function ChronicleGem.getCompactProgress(state, level)
    local progress = ChronicleGem.getProgress(state, level)
    return string.format("Chronicle: %d/%d M  %d/%d B", progress.monsterStacks, progress.settings.maxMonsterStacks, progress.bossStacks, progress.settings.maxBossStacks)
end

function ChronicleGem.buildTooltip(baseTooltip, state, level)
    local progress = ChronicleGem.getProgress(state, level)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end
    lines[#lines + 1] = string.format("Monsters Slain: %d", progress.monsterKills)
    lines[#lines + 1] = string.format("Bosses Slain: %d", progress.bossKills)
    lines[#lines + 1] = string.format("Monster Mastery: %d/%d", progress.monsterStacks, progress.settings.maxMonsterStacks)
    lines[#lines + 1] = string.format("Boss Mastery: %d/%d", progress.bossStacks, progress.settings.maxBossStacks)
    lines[#lines + 1] = string.format("Power: +%d%% damage, +%d HP, +%d Mana", progress.monsterStacks * progress.settings.damagePerStack, progress.bossStacks * progress.settings.healthPerStack, progress.bossStacks * progress.settings.manaPerStack)
    return table.concat(lines, "\n")
end

function ChronicleGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, ChronicleGem.gemKey, callback)
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local item = player:getSlotItem(slot)
        if item and hasSockets(item) then
            for socketIndex = 1, getSocketCount(item) do
                if ChronicleGem.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function ChronicleGem.recordKill(item, socketIndex, isBossKill)
    if not item then
        return false
    end

    local state = ChronicleGem.readState(item, socketIndex) or {}
    local oldProgress = ChronicleGem.getProgress(state, getSocketGemLevel(item, socketIndex))
    state.monsterKills = math.max(0, tonumber(state.monsterKills) or 0) + 1
    state.bossKills = math.max(0, tonumber(state.bossKills) or 0) + (isBossKill and 1 or 0)
    ChronicleGem.writeState(item, socketIndex, state)
    setSocketGemDisplayData(item, socketIndex, GemsSocket.GEMS[ChronicleGem.gemKey])
    local newProgress = ChronicleGem.getProgress(state, getSocketGemLevel(item, socketIndex))
    local bonusesChanged = newProgress.monsterStacks ~= oldProgress.monsterStacks or newProgress.bossStacks ~= oldProgress.bossStacks
    if bonusesChanged then
        refreshSocketItem(item)
    else
        GemsSocket_refreshSocketDisplay(item)
    end
    return bonusesChanged
end

function ChronicleGem.addBonuses(item, socketIndex, totals)
    if not item or type(totals) ~= "table" then
        return
    end

    local progress = ChronicleGem.getProgress(ChronicleGem.readState(item, socketIndex), getSocketGemLevel(item, socketIndex))
    local damageBonus = progress.monsterStacks * progress.settings.damagePerStack
    local healthBonus = progress.bossStacks * progress.settings.healthPerStack
    local manaBonus = progress.bossStacks * progress.settings.manaPerStack
    if damageBonus > 0 then
        totals.socket_chronicle_damage_percent = (totals.socket_chronicle_damage_percent or 0) + damageBonus
    end
    if healthBonus > 0 then
        totals.socket_chronicle_health = (totals.socket_chronicle_health or 0) + healthBonus
    end
    if manaBonus > 0 then
        totals.socket_chronicle_mana = (totals.socket_chronicle_mana or 0) + manaBonus
    end
end

HauntedHuntGem = {
    gemKey = "hauntedhuntgem",
    defaultProgressRequired = 100,
    defaultProgressPerKill = 4,
    defaultComebackChance = 10,
    monsterLookup = nil,
}

function HauntedHuntGem.isGem(gemKey)
    return gemKey == HauntedHuntGem.gemKey
end

function HauntedHuntGem.getSpecialConfig()
    return (GemsSocket.SPECIALS and GemsSocket.SPECIALS.hauntedHunt) or {}
end

function HauntedHuntGem.getSettings(level)
    local gemData, levelData = getGemLevelData(HauntedHuntGem.gemKey, level or 1)
    local gemSettings = type(gemData) == "table" and type(gemData.hauntedHunt) == "table" and gemData.hauntedHunt or nil
    local levelSettings = type(levelData) == "table" and type(levelData.hauntedHunt) == "table" and levelData.hauntedHunt or nil
    return {
        progressRequired = math.max(1, toNumber(levelSettings and levelSettings.progressRequired, gemSettings and gemSettings.progressRequired or HauntedHuntGem.defaultProgressRequired)),
        progressPerKill = math.max(1, toNumber(levelSettings and levelSettings.progressPerKill, gemSettings and gemSettings.progressPerKill or HauntedHuntGem.defaultProgressPerKill)),
        comebackChance = math.max(0, toNumber(levelSettings and levelSettings.comebackChance, gemSettings and gemSettings.comebackChance or HauntedHuntGem.defaultComebackChance)),
    }
end

function HauntedHuntGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_haunted_", socketIndex)
    end
    return "haunted_"
end

function HauntedHuntGem.buildMonsterLookup()
    local lookup = {}
    local special = HauntedHuntGem.getSpecialConfig()
    local families = type(special.families) == "table" and special.families or {}
    for index, family in ipairs(families) do
        if type(family) == "table" and type(family.monsters) == "table" and type(family.boss) == "string" and family.boss ~= "" then
            local familyId = family.id or string.format("family_%d", index)
            local entry = {
                id = familyId,
                boss = family.boss,
                monsters = family.monsters,
                rewardItemId = tonumber(family.rewardItemId) or tonumber(special.rewardItemId) or 0,
                rewardBaseCount = math.max(0, tonumber(family.rewardBaseCount) or tonumber(special.rewardBaseCount) or 0),
                rewardPerHauntLevel = math.max(0, tonumber(family.rewardPerHauntLevel) or tonumber(special.rewardPerHauntLevel) or 0),
            }
            for _, monsterName in ipairs(family.monsters) do
                if type(monsterName) == "string" and monsterName ~= "" then
                    lookup[monsterName:lower()] = entry
                end
            end
        end
    end
    HauntedHuntGem.monsterLookup = lookup
    return lookup
end

function HauntedHuntGem.getFamilyForMonster(monsterName)
    if type(monsterName) ~= "string" or monsterName == "" then
        return nil
    end

    local lookup = HauntedHuntGem.monsterLookup or HauntedHuntGem.buildMonsterLookup()
    return lookup[monsterName:lower()]
end

function HauntedHuntGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = HauntedHuntGem.getAttributePrefix(socketIndex)
    local progress = math.max(0, tonumber(item:getCustomAttribute(prefix .. "progress")) or 0)
    local hauntLevel = math.max(0, tonumber(item:getCustomAttribute(prefix .. "level")) or 0)
    local escapes = math.max(0, tonumber(item:getCustomAttribute(prefix .. "escapes")) or 0)
    local activeBossId = math.max(0, tonumber(item:getCustomAttribute(prefix .. "active_boss_id")) or 0)
    local anchorX = tonumber(item:getCustomAttribute(prefix .. "anchor_x")) or 0
    local anchorY = tonumber(item:getCustomAttribute(prefix .. "anchor_y")) or 0
    local anchorZ = tonumber(item:getCustomAttribute(prefix .. "anchor_z")) or 0
    local awaySince = math.max(0, tonumber(item:getCustomAttribute(prefix .. "away_since")) or 0)
    local familyId = item:getCustomAttribute(prefix .. "family_id")
    local bossName = item:getCustomAttribute(prefix .. "boss_name")
    local eventState = item:getCustomAttribute(prefix .. "event_state")

    if type(familyId) ~= "string" or familyId == "" then
        familyId = nil
    end
    if type(bossName) ~= "string" or bossName == "" then
        bossName = nil
    end
    if type(eventState) ~= "string" or eventState == "" then
        eventState = nil
    end

    if progress <= 0 and hauntLevel <= 0 and escapes <= 0 and activeBossId <= 0 and not familyId and not bossName and not eventState then
        return nil
    end

    return {
        progress = progress,
        hauntLevel = hauntLevel,
        escapes = escapes,
        activeBossId = activeBossId,
        anchorX = anchorX,
        anchorY = anchorY,
        anchorZ = anchorZ,
        awaySince = awaySince,
        familyId = familyId,
        bossName = bossName,
        eventState = eventState,
    }
end

function HauntedHuntGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = HauntedHuntGem.getAttributePrefix(socketIndex)
    for _, suffix in ipairs({
        "progress", "level", "escapes", "active_boss_id",
        "anchor_x", "anchor_y", "anchor_z", "away_since",
        "family_id", "boss_name", "event_state"
    }) do
        item:removeCustomAttribute(prefix .. suffix)
    end
end

function HauntedHuntGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    HauntedHuntGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local prefix = HauntedHuntGem.getAttributePrefix(socketIndex)
    local progress = math.max(0, tonumber(state.progress) or 0)
    local hauntLevel = math.max(0, tonumber(state.hauntLevel) or 0)
    local escapes = math.max(0, tonumber(state.escapes) or 0)
    local activeBossId = math.max(0, tonumber(state.activeBossId) or 0)
    local anchorX = tonumber(state.anchorX) or 0
    local anchorY = tonumber(state.anchorY) or 0
    local anchorZ = tonumber(state.anchorZ) or 0
    local awaySince = math.max(0, tonumber(state.awaySince) or 0)

    if progress > 0 then item:setCustomAttribute(prefix .. "progress", progress) end
    if hauntLevel > 0 then item:setCustomAttribute(prefix .. "level", hauntLevel) end
    if escapes > 0 then item:setCustomAttribute(prefix .. "escapes", escapes) end
    if activeBossId > 0 then item:setCustomAttribute(prefix .. "active_boss_id", activeBossId) end
    if anchorX ~= 0 or anchorY ~= 0 or anchorZ ~= 0 then
        item:setCustomAttribute(prefix .. "anchor_x", anchorX)
        item:setCustomAttribute(prefix .. "anchor_y", anchorY)
        item:setCustomAttribute(prefix .. "anchor_z", anchorZ)
    end
    if awaySince > 0 then item:setCustomAttribute(prefix .. "away_since", awaySince) end
    if type(state.familyId) == "string" and state.familyId ~= "" then item:setCustomAttribute(prefix .. "family_id", state.familyId) end
    if type(state.bossName) == "string" and state.bossName ~= "" then item:setCustomAttribute(prefix .. "boss_name", state.bossName) end
    if type(state.eventState) == "string" and state.eventState ~= "" then item:setCustomAttribute(prefix .. "event_state", state.eventState) end
end

function HauntedHuntGem.getProgressPercent(state, level)
    local settings = HauntedHuntGem.getSettings(level)
    local progress = math.max(0, tonumber(type(state) == "table" and state.progress or 0) or 0)
    return math.max(0, math.min(100, math.floor((progress / settings.progressRequired) * 100)))
end

function HauntedHuntGem.getProgressValues(state, level)
    local settings = HauntedHuntGem.getSettings(level)
    local progress = math.max(0, tonumber(type(state) == "table" and state.progress or 0) or 0)
    local required = math.max(1, tonumber(settings.progressRequired) or HauntedHuntGem.defaultProgressRequired)
    return math.min(progress, required), required, HauntedHuntGem.getProgressPercent(state, level)
end

function HauntedHuntGem.getCompactProgress(state, level)
    local progress, required, percent = HauntedHuntGem.getProgressValues(state, level)
    local hauntLevel = math.max(0, tonumber(type(state) == "table" and state.hauntLevel or 0) or 0)
    if hauntLevel > 0 then
        return string.format("Haunted Hunt: %d/%d (%d%%) Haunted: Yes (%d)", progress, required, percent, hauntLevel)
    end
    return string.format("Haunted Hunt: %d/%d (%d%%) Haunted: No", progress, required, percent)
end

function HauntedHuntGem.buildTooltip(baseTooltip, state, level)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    local progress, required, percent = HauntedHuntGem.getProgressValues(state, level)
    local hauntLevel = math.max(0, tonumber(type(state) == "table" and state.hauntLevel or 0) or 0)
    local bossName = type(state) == "table" and state.bossName or nil
    lines[#lines + 1] = string.format("Haunted Hunt: %d/%d (%d%%)", progress, required, percent)
    if hauntLevel > 0 then
        lines[#lines + 1] = string.format("Haunted: Yes (%d)", hauntLevel)
    else
        lines[#lines + 1] = "Haunted: No"
    end
    lines[#lines + 1] = string.format("Bound Boss: %s", bossName or "None")
    return table.concat(lines, "\n")
end

function HauntedHuntGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, HauntedHuntGem.gemKey, callback)
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local item = player:getSlotItem(slot)
        if item and hasSockets(item) then
            for socketIndex = 1, getSocketCount(item) do
                if HauntedHuntGem.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function HauntedHuntGem.findEquippedSocket(player)
    local foundItem, foundSocketIndex, foundState
    HauntedHuntGem.forEachEquippedSocket(player, function(item, socketIndex)
        if foundItem then
            return
        end
        foundItem = item
        foundSocketIndex = socketIndex
        foundState = HauntedHuntGem.readState(item, socketIndex) or {}
    end)
    return foundItem, foundSocketIndex, foundState
end

function HauntedHuntGem.refreshSocket(item, socketIndex)
    setSocketGemDisplayData(item, socketIndex, GemsSocket.GEMS[HauntedHuntGem.gemKey])
    GemsSocket_refreshSocketDisplay(item)
end

local function HauntedHuntGem_cleanupSpawned(runtime)
    if type(runtime) ~= "table" then
        return
    end

    if type(runtime.waveMonsterIds) == "table" then
        for _, monsterId in ipairs(runtime.waveMonsterIds) do
            local monster = Monster(monsterId)
            if monster then
                monster:remove()
            end
        end
        runtime.waveMonsterIds = {}
    end
end

local function HauntedHuntGem_getAnchorPosition(state)
    if type(state) ~= "table" then
        return nil
    end

    local x = tonumber(state.anchorX) or 0
    local y = tonumber(state.anchorY) or 0
    local z = tonumber(state.anchorZ) or 0
    if x == 0 and y == 0 and z == 0 then
        return nil
    end

    return Position(x, y, z)
end

local function HauntedHuntGem_findSpawnPosition(anchorPosition)
    if not anchorPosition then
        return nil
    end

    local candidates = {}
    for radius = 1, 3 do
        for x = -radius, radius do
            for y = -radius, radius do
                if not (x == 0 and y == 0) then
                    candidates[#candidates + 1] = Position(anchorPosition.x + x, anchorPosition.y + y, anchorPosition.z)
                end
            end
        end
    end

    for index = #candidates, 2, -1 do
        local swapIndex = math.random(index)
        candidates[index], candidates[swapIndex] = candidates[swapIndex], candidates[index]
    end

    for _, position in ipairs(candidates) do
        local tile = Tile(position)
        if tile and not tile:hasFlag(TILESTATE_PROTECTIONZONE) and not tile:hasFlag(TILESTATE_FLOORCHANGE)
            and not tile:hasFlag(TILESTATE_BLOCKSOLID) and not tile:hasFlag(TILESTATE_BLOCKPATH) and not tile:getHouse() then
            return position
        end
    end

    return anchorPosition
end

local function HauntedHuntGem_awardReward(player, family, hauntLevel)
    if not player or not family then
        return
    end

    local rewardItemId = tonumber(family.rewardItemId) or 0
    local rewardBaseCount = math.max(0, tonumber(family.rewardBaseCount) or 0)
    local rewardPerHauntLevel = math.max(0, tonumber(family.rewardPerHauntLevel) or 0)
    local rewardCount = rewardBaseCount + (math.max(0, hauntLevel or 0) * rewardPerHauntLevel)
    if rewardItemId <= 0 or rewardCount <= 0 then
        return
    end

    player:addItem(rewardItemId, rewardCount)
    local itemType = ItemType(rewardItemId)
    local rewardName = itemType and itemType:getName() or "reward"
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Haunted Hunt bonus reward: %dx %s.", rewardCount, rewardName))
end

function HauntedHuntGem.failActiveEvent(player, item, socketIndex, state, reason)
    if not player or not item or not socketIndex then
        return false
    end

    state = type(state) == "table" and state or {}
    local activeBossId = math.max(0, tonumber(state.activeBossId) or 0)
    if activeBossId > 0 then
        local boss = Monster(activeBossId)
        if boss then
            boss:remove()
        end
        hauntedHuntBossDamageState[activeBossId] = nil
    end

    local runtime = hauntedHuntRuntimeState[player:getId()]
    HauntedHuntGem_cleanupSpawned(runtime)
    hauntedHuntRuntimeState[player:getId()] = nil

    local internalFailure = reason == "spawn_failed" or reason == "missing_boss" or reason == "missing"
    state.activeBossId = 0
    state.anchorX = 0
    state.anchorY = 0
    state.anchorZ = 0
    state.awaySince = 0
    if internalFailure then
        state.eventState = nil
        state.progress = 0
    else
        state.eventState = "haunted"
        state.hauntLevel = math.max(0, tonumber(state.hauntLevel) or 0) + 1
        state.escapes = math.max(0, tonumber(state.escapes) or 0) + 1
    end
    HauntedHuntGem.writeState(item, socketIndex, state)
    HauntedHuntGem.refreshSocket(item, socketIndex)

    local special = HauntedHuntGem.getSpecialConfig()
    if internalFailure then
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Haunted Hunt could not summon %s.", state.bossName or "the boss"))
    else
        player:getPosition():sendMagicEffect(special.failEffect or CONST_ME_MORTAREA)
        player:sendTextMessage(MESSAGE_INFO_DESCR, special.failMessage or "The haunted boss slips away and binds itself to your soul.")
    end
    return true
end

function HauntedHuntGem.completeBoss(player, item, socketIndex, state)
    if not player or not item or not socketIndex then
        return false
    end

    state = type(state) == "table" and state or {}
    local family = HauntedHuntGem.getFamilyById(state.familyId)

    hauntedHuntBossDamageState[math.max(0, tonumber(state.activeBossId) or 0)] = nil
    HauntedHuntGem_cleanupSpawned(hauntedHuntRuntimeState[player:getId()])
    hauntedHuntRuntimeState[player:getId()] = nil

    local hauntLevel = math.max(0, tonumber(state.hauntLevel) or 0)
    state.progress = 0
    state.hauntLevel = 0
    state.escapes = 0
    state.activeBossId = 0
    state.anchorX = 0
    state.anchorY = 0
    state.anchorZ = 0
    state.awaySince = 0
    state.familyId = nil
    state.bossName = nil
    state.eventState = nil
    HauntedHuntGem.writeState(item, socketIndex, state)
    HauntedHuntGem.refreshSocket(item, socketIndex)

    if family then
        HauntedHuntGem_awardReward(player, family, hauntLevel)
    end

    local special = HauntedHuntGem.getSpecialConfig()
    player:getPosition():sendMagicEffect(special.successEffect or CONST_ME_HOLYAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.successMessage or "The haunted boss is defeated. The hunt falls silent.")
    return true
end

local function HauntedHuntGem_monitor(playerId, token)
    local player = Player(playerId)
    if not player then
        return
    end

    local runtime = hauntedHuntRuntimeState[playerId]
    if not runtime or runtime.token ~= token then
        return
    end

    local item, socketIndex, state = HauntedHuntGem.findEquippedSocket(player)
    if not item or not socketIndex or type(state) ~= "table" or (state.eventState ~= "wave" and state.eventState ~= "boss") then
        hauntedHuntRuntimeState[playerId] = nil
        return
    end

    local special = HauntedHuntGem.getSpecialConfig()
    local anchorPosition = HauntedHuntGem_getAnchorPosition(state)
    local leashRadius = math.max(1, tonumber(special.leashRadius) or 30)
    local awaySeconds = math.max(1, tonumber(special.awaySeconds) or 8)

    if anchorPosition and getDistanceBetween(player:getPosition(), anchorPosition) > leashRadius then
        local now = os.time()
        if (tonumber(state.awaySince) or 0) <= 0 then
            state.awaySince = now
            HauntedHuntGem.writeState(item, socketIndex, state)
            HauntedHuntGem.refreshSocket(item, socketIndex)
        elseif now - state.awaySince >= awaySeconds then
            HauntedHuntGem.failActiveEvent(player, item, socketIndex, state, "distance")
            return
        end
    elseif (tonumber(state.awaySince) or 0) > 0 then
        state.awaySince = 0
        HauntedHuntGem.writeState(item, socketIndex, state)
        HauntedHuntGem.refreshSocket(item, socketIndex)
    end

    if state.eventState == "boss" and math.max(0, tonumber(state.activeBossId) or 0) > 0 then
        local boss = Monster(state.activeBossId)
        if not boss then
            HauntedHuntGem.failActiveEvent(player, item, socketIndex, state, "missing")
            return
        end
    end

    addEvent(HauntedHuntGem_monitor, 1000, playerId, token)
end

local function HauntedHuntGem_startMonitor(player)
    if not player then
        return
    end

    local playerId = player:getId()
    local runtime = hauntedHuntRuntimeState[playerId] or {}
    runtime.token = math.max(1, tonumber(runtime.token) or 0) + 1
    hauntedHuntRuntimeState[playerId] = runtime
    addEvent(HauntedHuntGem_monitor, 1000, playerId, runtime.token)
end

function HauntedHuntGem.getFamilyById(familyId)
    if type(familyId) ~= "string" or familyId == "" then
        return nil
    end

    local lookup = HauntedHuntGem.monsterLookup or HauntedHuntGem.buildMonsterLookup()
    for _, entry in pairs(lookup) do
        if entry.id == familyId then
            return entry
        end
    end

    return nil
end

local function HauntedHuntGem_spawnWaveMonsters(playerId, familyId, anchorX, anchorY, anchorZ)
    if not playerId or not familyId or not anchorX or not anchorY or not anchorZ then
        return
    end

    local runtime = hauntedHuntRuntimeState[playerId]
    if not runtime then
        return
    end

    local family = HauntedHuntGem.getFamilyById(familyId)
    if not family then
        return
    end

    local anchorPosition = Position(anchorX, anchorY, anchorZ)
    local special = HauntedHuntGem.getSpecialConfig()
    runtime.waveMonsterIds = runtime.waveMonsterIds or {}
    local waveSize = math.max(1, tonumber(special.waveSize) or 3)
    for _ = 1, waveSize do
        local monsterName = family.monsters[math.random(#family.monsters)]
        local spawnPosition = HauntedHuntGem_findSpawnPosition(anchorPosition)
        local monster = spawnPosition and Game.createMonster(monsterName, spawnPosition, false, true)
        if monster then
            table.insert(runtime.waveMonsterIds, monster:getId())
            monster:getPosition():sendMagicEffect(special.waveEffect or CONST_ME_MORTAREA)
        end
    end
end

local function HauntedHuntGem_spawnBoss(playerId, socketIndex, expectedBossName)
    local player = Player(playerId)
    if not player then
        return
    end

    local item, foundSocketIndex, state = HauntedHuntGem.findEquippedSocket(player)
    if not item or foundSocketIndex ~= socketIndex or type(state) ~= "table" or state.eventState ~= "wave" then
        return
    end

    local anchorPosition = HauntedHuntGem_getAnchorPosition(state) or player:getPosition()
    local spawnPosition = HauntedHuntGem_findSpawnPosition(anchorPosition)
    local bossName = state.bossName or expectedBossName
    if type(bossName) ~= "string" or bossName == "" then
        HauntedHuntGem.failActiveEvent(player, item, foundSocketIndex, state, "missing_boss")
        return
    end

    local boss = spawnPosition and Game.createMonster(bossName, spawnPosition, false, true)
    if not boss then
        HauntedHuntGem.failActiveEvent(player, item, foundSocketIndex, state, "spawn_failed")
        return
    end

    local hauntLevel = math.max(0, tonumber(state.hauntLevel) or 0)
    if hauntLevel > 0 then
        local baseMaxHealth = boss:getMaxHealth()
        local scaledMaxHealth = math.max(1, math.floor(baseMaxHealth * (1 + (0.12 * hauntLevel))))
        if scaledMaxHealth > baseMaxHealth then
            boss:setMaxHealth(scaledMaxHealth)
            boss:addHealth("healing", scaledMaxHealth - boss:getHealth())
        end
        hauntedHuntBossDamageState[boss:getId()] = 8 * hauntLevel
    else
        hauntedHuntBossDamageState[boss:getId()] = nil
    end

    state.eventState = "boss"
    state.activeBossId = boss:getId()
    state.awaySince = 0
    HauntedHuntGem.writeState(item, foundSocketIndex, state)
    HauntedHuntGem.refreshSocket(item, foundSocketIndex)

    local special = HauntedHuntGem.getSpecialConfig()
    boss:getPosition():sendMagicEffect(special.bossEffect or CONST_ME_TELEPORT)
end

function HauntedHuntGem.beginEncounter(player, item, socketIndex, state, family)
    if not player or not item or not socketIndex or not family then
        return false
    end

    state = type(state) == "table" and state or {}
    local anchorPosition = player:getPosition()
    state.progress = 0
    state.familyId = family.id
    state.bossName = family.boss
    state.eventState = "wave"
    state.activeBossId = 0
    state.anchorX = anchorPosition.x
    state.anchorY = anchorPosition.y
    state.anchorZ = anchorPosition.z
    state.awaySince = 0
    HauntedHuntGem.writeState(item, socketIndex, state)
    HauntedHuntGem.refreshSocket(item, socketIndex)

    local runtime = hauntedHuntRuntimeState[player:getId()] or {}
    runtime.waveMonsterIds = {}
    hauntedHuntRuntimeState[player:getId()] = runtime

    local special = HauntedHuntGem.getSpecialConfig()
    player:getPosition():sendMagicEffect(special.spawnEffect or CONST_ME_MORTAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.waveStartMessage or "A haunted rift opens nearby.")

    local waveCount = math.max(1, tonumber(special.waveCount) or 2)
    local waveIntervalMs = math.max(500, tonumber(special.waveIntervalMs) or 2500)
    for waveIndex = 1, waveCount do
        addEvent(HauntedHuntGem_spawnWaveMonsters, math.max(1, (waveIndex - 1) * waveIntervalMs), player:getId(), family.id, anchorPosition.x, anchorPosition.y, anchorPosition.z)
    end

    local bossDelay = math.max(1, tonumber(special.bossSpawnDelayMs) or 6000)
    addEvent(HauntedHuntGem_spawnBoss, bossDelay, player:getId(), socketIndex, family.boss)
    HauntedHuntGem_startMonitor(player)
    return true
end

function HauntedHuntGem.tryReturn(player, item, socketIndex, state)
    if not player or not item or not socketIndex or type(state) ~= "table" then
        return false
    end

    if state.eventState ~= "haunted" or type(state.bossName) ~= "string" or state.bossName == "" then
        return false
    end

    local settings = HauntedHuntGem.getSettings(getSocketGemLevel(item, socketIndex))
    if not rollSocketChance(settings.comebackChance) then
        return false
    end

    local family = HauntedHuntGem.getFamilyById(state.familyId)
    if not family then
        local lookup = HauntedHuntGem.monsterLookup or HauntedHuntGem.buildMonsterLookup()
        for _, entry in pairs(lookup) do
            if entry.boss == state.bossName then
                family = entry
                break
            end
        end
    end
    if not family then
        return false
    end

    local special = HauntedHuntGem.getSpecialConfig()
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.comebackSpawnMessage or "The haunted boss has found you again.")
    return HauntedHuntGem.beginEncounter(player, item, socketIndex, state, family)
end

function HauntedHuntGem.advanceProgress(player, item, socketIndex, monsterName)
    if not player or not item or not socketIndex then
        return false
    end

    local state = HauntedHuntGem.readState(item, socketIndex) or {}
    if state.eventState == "wave" or state.eventState == "boss" then
        return false
    end

    if state.eventState == "haunted" and HauntedHuntGem.tryReturn(player, item, socketIndex, state) then
        return true
    end

    local settings = HauntedHuntGem.getSettings(getSocketGemLevel(item, socketIndex))
    local family = HauntedHuntGem.getFamilyForMonster(monsterName)
    if not family then
        return false
    end

    if state.familyId and state.familyId ~= family.id then
        state.progress = 0
    end

    state.familyId = family.id
    state.bossName = family.boss
    state.eventState = nil
    state.progress = math.max(0, tonumber(state.progress) or 0) + settings.progressPerKill

    if state.progress >= settings.progressRequired then
        return HauntedHuntGem.beginEncounter(player, item, socketIndex, state, family)
    end

    HauntedHuntGem.writeState(item, socketIndex, state)
    HauntedHuntGem.refreshSocket(item, socketIndex)
    return true
end

function GemsSocket_readSpecialGemState(item, socketIndex, gemKey)
    if type(_G.LivingGem) == "table" and _G.LivingGem.isGem and _G.LivingGem.isGem(gemKey) then
        return _G.LivingGem.readState(item, socketIndex)
    end
    if type(_G.TreasuryGem) == "table" and _G.TreasuryGem.isGem and _G.TreasuryGem.isGem(gemKey) then
        return _G.TreasuryGem.readState(item, socketIndex)
    end
    if type(_G.PossessionGem) == "table" and _G.PossessionGem.isGem and _G.PossessionGem.isGem(gemKey) then
        return _G.PossessionGem.readState(item, socketIndex)
    end
    if PredatorEye.isGem(gemKey) then
        return PredatorEye.readState(item, socketIndex)
    end
    if PhoenixGem.isGem(gemKey) then
        return PhoenixGem.readState(item, socketIndex)
    end
    if ChronicleGem.isGem(gemKey) then
        return ChronicleGem.readState(item, socketIndex)
    end
    if HauntedHuntGem.isGem(gemKey) then
        return HauntedHuntGem.readState(item, socketIndex)
    end
    if type(_G.AbattoirGem) == "table" and _G.AbattoirGem.isGem and _G.AbattoirGem.isGem(gemKey) then
        return _G.AbattoirGem.readState(item, socketIndex)
    end
    if type(_G.TriCraftGem) == "table" and _G.TriCraftGem.isGem and _G.TriCraftGem.isGem(gemKey) then
        return _G.TriCraftGem.readState(item, socketIndex)
    end
    if type(_G.GravediggerGem) == "table" and _G.GravediggerGem.isGem and _G.GravediggerGem.isGem(gemKey) then
        return _G.GravediggerGem.readState(item, socketIndex)
    end
    if type(_G.ObituaryGem) == "table" and _G.ObituaryGem.isGem and _G.ObituaryGem.isGem(gemKey) then
        return _G.ObituaryGem.readState(item, socketIndex)
    end
    if type(_G.OverkillGem) == "table" and _G.OverkillGem.isGem and _G.OverkillGem.isGem(gemKey) then
        return _G.OverkillGem.readState(item, socketIndex)
    end
    if type(_G.RequiemGem) == "table" and _G.RequiemGem.isGem and _G.RequiemGem.isGem(gemKey) then
        return _G.RequiemGem.readState(item, socketIndex)
    end
    if type(_G.WaystoneConquerorGem) == "table" and _G.WaystoneConquerorGem.isGem and _G.WaystoneConquerorGem.isGem(gemKey) then
        return _G.WaystoneConquerorGem.readState(item, socketIndex)
    end
    if type(_G.CarrionGem) == "table" and _G.CarrionGem.isGem and _G.CarrionGem.isGem(gemKey) then
        return _G.CarrionGem.readState(item, socketIndex)
    end
    if type(_G.NemesisBrandGem) == "table" and _G.NemesisBrandGem.isGem and _G.NemesisBrandGem.isGem(gemKey) then
        return _G.NemesisBrandGem.readState(item, socketIndex)
    end
    if type(_G.DamageGem) == "table" and _G.DamageGem.isGem and _G.DamageGem.isGem(gemKey) then
        return _G.DamageGem.readState(item, socketIndex)
    end
    if type(_G.UtilityGems) == "table" and _G.UtilityGems.supports and _G.UtilityGems.supports(gemKey) then
        return _G.UtilityGems.readState(item, socketIndex, gemKey)
    end
    return nil
end

function GemsSocket_writeSpecialGemState(item, socketIndex, gemKey, state)
    if type(_G.LivingGem) == "table" and _G.LivingGem.isGem and _G.LivingGem.isGem(gemKey) then
        _G.LivingGem.writeState(item, socketIndex, state)
    elseif type(_G.TreasuryGem) == "table" and _G.TreasuryGem.isGem and _G.TreasuryGem.isGem(gemKey) then
        _G.TreasuryGem.writeState(item, socketIndex, state)
    elseif type(_G.PossessionGem) == "table" and _G.PossessionGem.isGem and _G.PossessionGem.isGem(gemKey) then
        _G.PossessionGem.writeState(item, socketIndex, state)
    elseif PredatorEye.isGem(gemKey) then
        PredatorEye.writeState(item, socketIndex, state)
    elseif PhoenixGem.isGem(gemKey) then
        PhoenixGem.writeState(item, socketIndex, state)
    elseif ChronicleGem.isGem(gemKey) then
        ChronicleGem.writeState(item, socketIndex, state)
    elseif HauntedHuntGem.isGem(gemKey) then
        HauntedHuntGem.writeState(item, socketIndex, state)
    elseif type(_G.AbattoirGem) == "table" and _G.AbattoirGem.isGem and _G.AbattoirGem.isGem(gemKey) then
        _G.AbattoirGem.writeState(item, socketIndex, state)
    elseif type(_G.TriCraftGem) == "table" and _G.TriCraftGem.isGem and _G.TriCraftGem.isGem(gemKey) then
        _G.TriCraftGem.writeState(item, socketIndex, state)
    elseif type(_G.GravediggerGem) == "table" and _G.GravediggerGem.isGem and _G.GravediggerGem.isGem(gemKey) then
        _G.GravediggerGem.writeState(item, socketIndex, state)
    elseif type(_G.ObituaryGem) == "table" and _G.ObituaryGem.isGem and _G.ObituaryGem.isGem(gemKey) then
        _G.ObituaryGem.writeState(item, socketIndex, state)
    elseif type(_G.OverkillGem) == "table" and _G.OverkillGem.isGem and _G.OverkillGem.isGem(gemKey) then
        _G.OverkillGem.writeState(item, socketIndex, state)
    elseif type(_G.RequiemGem) == "table" and _G.RequiemGem.isGem and _G.RequiemGem.isGem(gemKey) then
        _G.RequiemGem.writeState(item, socketIndex, state)
    elseif type(_G.WaystoneConquerorGem) == "table" and _G.WaystoneConquerorGem.isGem and _G.WaystoneConquerorGem.isGem(gemKey) then
        _G.WaystoneConquerorGem.writeState(item, socketIndex, state)
    elseif type(_G.CarrionGem) == "table" and _G.CarrionGem.isGem and _G.CarrionGem.isGem(gemKey) then
        _G.CarrionGem.writeState(item, socketIndex, state)
    elseif type(_G.NemesisBrandGem) == "table" and _G.NemesisBrandGem.isGem and _G.NemesisBrandGem.isGem(gemKey) then
        _G.NemesisBrandGem.writeState(item, socketIndex, state)
    elseif type(_G.DamageGem) == "table" and _G.DamageGem.isGem and _G.DamageGem.isGem(gemKey) then
        _G.DamageGem.writeState(item, socketIndex, state)
    elseif type(_G.UtilityGems) == "table" and _G.UtilityGems.supports and _G.UtilityGems.supports(gemKey) then
        _G.UtilityGems.writeState(item, socketIndex, gemKey, state)
    end
end

function GemsSocket_clearSpecialGemState(item, socketIndex, gemKey)
    if type(_G.LivingGem) == "table" and _G.LivingGem.isGem and _G.LivingGem.isGem(gemKey) then
        _G.LivingGem.clearState(item, socketIndex)
    elseif type(_G.TreasuryGem) == "table" and _G.TreasuryGem.isGem and _G.TreasuryGem.isGem(gemKey) then
        _G.TreasuryGem.clearState(item, socketIndex)
    elseif type(_G.PossessionGem) == "table" and _G.PossessionGem.isGem and _G.PossessionGem.isGem(gemKey) then
        _G.PossessionGem.clearState(item, socketIndex)
    elseif PredatorEye.isGem(gemKey) then
        PredatorEye.clearState(item, socketIndex)
    elseif PhoenixGem.isGem(gemKey) then
        PhoenixGem.clearState(item, socketIndex)
    elseif ChronicleGem.isGem(gemKey) then
        ChronicleGem.clearState(item, socketIndex)
    elseif HauntedHuntGem.isGem(gemKey) then
        HauntedHuntGem.clearState(item, socketIndex)
    elseif type(_G.AbattoirGem) == "table" and _G.AbattoirGem.isGem and _G.AbattoirGem.isGem(gemKey) then
        _G.AbattoirGem.clearState(item, socketIndex)
    elseif type(_G.TriCraftGem) == "table" and _G.TriCraftGem.isGem and _G.TriCraftGem.isGem(gemKey) then
        _G.TriCraftGem.clearState(item, socketIndex)
    elseif type(_G.GravediggerGem) == "table" and _G.GravediggerGem.isGem and _G.GravediggerGem.isGem(gemKey) then
        _G.GravediggerGem.clearState(item, socketIndex)
    elseif type(_G.ObituaryGem) == "table" and _G.ObituaryGem.isGem and _G.ObituaryGem.isGem(gemKey) then
        _G.ObituaryGem.clearState(item, socketIndex)
    elseif type(_G.OverkillGem) == "table" and _G.OverkillGem.isGem and _G.OverkillGem.isGem(gemKey) then
        _G.OverkillGem.clearState(item, socketIndex)
    elseif type(_G.RequiemGem) == "table" and _G.RequiemGem.isGem and _G.RequiemGem.isGem(gemKey) then
        _G.RequiemGem.clearState(item, socketIndex)
    elseif type(_G.WaystoneConquerorGem) == "table" and _G.WaystoneConquerorGem.isGem and _G.WaystoneConquerorGem.isGem(gemKey) then
        _G.WaystoneConquerorGem.clearState(item, socketIndex)
    elseif type(_G.CarrionGem) == "table" and _G.CarrionGem.isGem and _G.CarrionGem.isGem(gemKey) then
        _G.CarrionGem.clearState(item, socketIndex)
    elseif type(_G.NemesisBrandGem) == "table" and _G.NemesisBrandGem.isGem and _G.NemesisBrandGem.isGem(gemKey) then
        _G.NemesisBrandGem.clearState(item, socketIndex)
    elseif type(_G.DamageGem) == "table" and _G.DamageGem.isGem and _G.DamageGem.isGem(gemKey) then
        _G.DamageGem.clearState(item, socketIndex)
    elseif type(_G.UtilityGems) == "table" and _G.UtilityGems.supports and _G.UtilityGems.supports(gemKey) then
        _G.UtilityGems.clearState(item, socketIndex, gemKey)
    end
end

function GemsSocket_buildSpecialGemTooltip(gemKey, baseTooltip, item, socketIndex, level)
    local tooltip = baseTooltip or ""
    if type(_G.LivingGem) == "table" and _G.LivingGem.isGem and _G.LivingGem.isGem(gemKey) then
        tooltip = _G.LivingGem.buildTooltip(baseTooltip, _G.LivingGem.readState(item, socketIndex), level)
    elseif type(_G.TreasuryGem) == "table" and _G.TreasuryGem.isGem and _G.TreasuryGem.isGem(gemKey) then
        tooltip = _G.TreasuryGem.buildTooltip(baseTooltip, _G.TreasuryGem.readState(item, socketIndex), level)
    elseif type(_G.PossessionGem) == "table" and _G.PossessionGem.isGem and _G.PossessionGem.isGem(gemKey) then
        tooltip = _G.PossessionGem.buildTooltip(baseTooltip, _G.PossessionGem.readState(item, socketIndex), level)
    elseif PredatorEye.isGem(gemKey) then
        tooltip = PredatorEye.buildTooltip(baseTooltip, PredatorEye.readState(item, socketIndex), level)
    elseif PhoenixGem.isGem(gemKey) then
        tooltip = PhoenixGem.buildTooltip(baseTooltip, PhoenixGem.readState(item, socketIndex), level)
    elseif ChronicleGem.isGem(gemKey) then
        tooltip = ChronicleGem.buildTooltip(baseTooltip, ChronicleGem.readState(item, socketIndex), level)
    elseif HauntedHuntGem.isGem(gemKey) then
        tooltip = HauntedHuntGem.buildTooltip(baseTooltip, HauntedHuntGem.readState(item, socketIndex), level)
    elseif type(_G.AbattoirGem) == "table" and _G.AbattoirGem.isGem and _G.AbattoirGem.isGem(gemKey) then
        tooltip = _G.AbattoirGem.buildTooltip(baseTooltip, _G.AbattoirGem.readState(item, socketIndex), level)
    elseif type(_G.TriCraftGem) == "table" and _G.TriCraftGem.isGem and _G.TriCraftGem.isGem(gemKey) then
        tooltip = _G.TriCraftGem.buildTooltip(baseTooltip, _G.TriCraftGem.readState(item, socketIndex), level)
    elseif type(_G.GravediggerGem) == "table" and _G.GravediggerGem.isGem and _G.GravediggerGem.isGem(gemKey) then
        tooltip = _G.GravediggerGem.buildTooltip(baseTooltip, _G.GravediggerGem.readState(item, socketIndex), level)
    elseif type(_G.ObituaryGem) == "table" and _G.ObituaryGem.isGem and _G.ObituaryGem.isGem(gemKey) then
        tooltip = _G.ObituaryGem.buildTooltip(baseTooltip, _G.ObituaryGem.readState(item, socketIndex), level)
    elseif type(_G.OverkillGem) == "table" and _G.OverkillGem.isGem and _G.OverkillGem.isGem(gemKey) then
        tooltip = _G.OverkillGem.buildTooltip(baseTooltip, _G.OverkillGem.readState(item, socketIndex), level)
    elseif type(_G.RequiemGem) == "table" and _G.RequiemGem.isGem and _G.RequiemGem.isGem(gemKey) then
        tooltip = _G.RequiemGem.buildTooltip(baseTooltip, _G.RequiemGem.readState(item, socketIndex), level)
    elseif type(_G.WaystoneConquerorGem) == "table" and _G.WaystoneConquerorGem.isGem and _G.WaystoneConquerorGem.isGem(gemKey) then
        tooltip = _G.WaystoneConquerorGem.buildTooltip(baseTooltip, _G.WaystoneConquerorGem.readState(item, socketIndex), level)
    elseif type(_G.TideGem) == "table" and _G.TideGem.isGem and _G.TideGem.isGem(gemKey) then
        local owner = item and type(item.getTopParent) == "function" and item:getTopParent() or nil
        tooltip = _G.TideGem.buildTooltip(baseTooltip, player or owner)
    elseif type(_G.CarrionGem) == "table" and _G.CarrionGem.isGem and _G.CarrionGem.isGem(gemKey) then
        tooltip = _G.CarrionGem.buildTooltip(baseTooltip, _G.CarrionGem.readState(item, socketIndex), level)
    elseif type(_G.NemesisBrandGem) == "table" and _G.NemesisBrandGem.isGem and _G.NemesisBrandGem.isGem(gemKey) then
        tooltip = _G.NemesisBrandGem.buildTooltip(baseTooltip, _G.NemesisBrandGem.readState(item, socketIndex), level)
    elseif type(_G.DamageGem) == "table" and _G.DamageGem.isGem and _G.DamageGem.isGem(gemKey) then
        tooltip = _G.DamageGem.buildTooltip(baseTooltip, _G.DamageGem.readState(item, socketIndex), level)
    elseif type(_G.UtilityGems) == "table" and _G.UtilityGems.supports and _G.UtilityGems.supports(gemKey) then
        tooltip = _G.UtilityGems.buildTooltip(gemKey, baseTooltip, item, socketIndex, level)
    end

    return tooltip
end

function GemsSocket_buildSpecialGemCompactTooltip(gemKey, baseTooltip, item, socketIndex, level, player)
    local compactTooltip = baseTooltip or ""
    if type(_G.LivingGem) == "table" and _G.LivingGem.isGem and _G.LivingGem.isGem(gemKey) then
        compactTooltip = _G.LivingGem.getCompactProgress(_G.LivingGem.readState(item, socketIndex), level)
    elseif type(_G.TreasuryGem) == "table" and _G.TreasuryGem.isGem and _G.TreasuryGem.isGem(gemKey) then
        compactTooltip = _G.TreasuryGem.getCompactProgress(_G.TreasuryGem.readState(item, socketIndex), level)
    elseif type(_G.PossessionGem) == "table" and _G.PossessionGem.isGem and _G.PossessionGem.isGem(gemKey) then
        compactTooltip = _G.PossessionGem.getCompactProgress(_G.PossessionGem.readState(item, socketIndex), level)
    elseif PredatorEye.isGem(gemKey) then
        compactTooltip = PredatorEye.getCompactProgress(PredatorEye.readState(item, socketIndex), level)
    elseif PhoenixGem.isGem(gemKey) then
        compactTooltip = PhoenixGem.getCompactProgress(PhoenixGem.readState(item, socketIndex), level)
    elseif ChronicleGem.isGem(gemKey) then
        compactTooltip = ChronicleGem.getCompactProgress(ChronicleGem.readState(item, socketIndex), level)
    elseif HauntedHuntGem.isGem(gemKey) then
        compactTooltip = HauntedHuntGem.getCompactProgress(HauntedHuntGem.readState(item, socketIndex), level)
    elseif type(_G.AbattoirGem) == "table" and _G.AbattoirGem.isGem and _G.AbattoirGem.isGem(gemKey) then
        compactTooltip = _G.AbattoirGem.getCompactProgress(_G.AbattoirGem.readState(item, socketIndex), level)
    elseif type(_G.TriCraftGem) == "table" and _G.TriCraftGem.isGem and _G.TriCraftGem.isGem(gemKey) then
        compactTooltip = _G.TriCraftGem.getCompactProgress(_G.TriCraftGem.readState(item, socketIndex), level)
    elseif type(_G.GravediggerGem) == "table" and _G.GravediggerGem.isGem and _G.GravediggerGem.isGem(gemKey) then
        compactTooltip = _G.GravediggerGem.getCompactProgress(_G.GravediggerGem.readState(item, socketIndex), level)
    elseif type(_G.ObituaryGem) == "table" and _G.ObituaryGem.isGem and _G.ObituaryGem.isGem(gemKey) then
        compactTooltip = _G.ObituaryGem.getCompactProgress(_G.ObituaryGem.readState(item, socketIndex), level)
    elseif type(_G.OverkillGem) == "table" and _G.OverkillGem.isGem and _G.OverkillGem.isGem(gemKey) then
        compactTooltip = _G.OverkillGem.getCompactProgress(_G.OverkillGem.readState(item, socketIndex), level)
    elseif type(_G.RequiemGem) == "table" and _G.RequiemGem.isGem and _G.RequiemGem.isGem(gemKey) then
        compactTooltip = _G.RequiemGem.getCompactProgress(_G.RequiemGem.readState(item, socketIndex), level)
    elseif type(_G.MomentumGem) == "table" and _G.MomentumGem.isGem and _G.MomentumGem.isGem(gemKey) then
        local owner = item and type(item.getTopParent) == "function" and item:getTopParent() or nil
        compactTooltip = _G.MomentumGem.getCompactProgress(player or owner)
    elseif type(_G.WaystoneConquerorGem) == "table" and _G.WaystoneConquerorGem.isGem and _G.WaystoneConquerorGem.isGem(gemKey) then
        compactTooltip = _G.WaystoneConquerorGem.getCompactProgress(_G.WaystoneConquerorGem.readState(item, socketIndex), level)
    elseif type(_G.TideGem) == "table" and _G.TideGem.isGem and _G.TideGem.isGem(gemKey) then
        local owner = item and type(item.getTopParent) == "function" and item:getTopParent() or nil
        compactTooltip = _G.TideGem.getCompactProgress(player or owner)
    elseif type(_G.CarrionGem) == "table" and _G.CarrionGem.isGem and _G.CarrionGem.isGem(gemKey) then
        compactTooltip = _G.CarrionGem.getCompactProgress(_G.CarrionGem.readState(item, socketIndex), level)
    elseif type(_G.NemesisBrandGem) == "table" and _G.NemesisBrandGem.isGem and _G.NemesisBrandGem.isGem(gemKey) then
        compactTooltip = _G.NemesisBrandGem.getCompactProgress(_G.NemesisBrandGem.readState(item, socketIndex), level)
    elseif type(_G.DamageGem) == "table" and _G.DamageGem.isGem and _G.DamageGem.isGem(gemKey) then
        compactTooltip = _G.DamageGem.getCompactProgress(_G.DamageGem.readState(item, socketIndex), level)
    elseif gemKey == "memorygem" and type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.getMemoryCompactProgress) == "function" then
        local owner = item and type(item.getTopParent) == "function" and item:getTopParent() or nil
        compactTooltip = _G.ExtraSocketGems.getMemoryCompactProgress(player or owner, level, baseTooltip)
    elseif type(_G.UtilityGems) == "table" and _G.UtilityGems.supports and _G.UtilityGems.supports(gemKey) then
        compactTooltip = _G.UtilityGems.buildCompactTooltip(gemKey, baseTooltip, item, socketIndex, level)
    end

    return compactTooltip
end

local function getTreasurySocketDisplayName(item, socketIndex, gemData, baseName)
    if type(_G.TreasuryGem) ~= "table" or not _G.TreasuryGem.isGem or not _G.TreasuryGem.isGem("treasurygem") then
        return baseName
    end

    local state = _G.TreasuryGem.readState(item, socketIndex)
    local compact = _G.TreasuryGem.getCompactProgress(state)
    if type(compact) ~= "string" or compact == "" then
        return baseName
    end

    return string.format("%s | %s", baseName or (gemData and gemData.name) or "Gem", compact)
end

local function awardGemTierStorage(player, gemKey, level)
    if not player or type(player.setStorageValue) ~= "function" then
        return
    end

    local _, levelData = getGemLevelData(gemKey, level)
    if type(levelData) ~= "table" then
        return
    end

    local storage = tonumber(levelData.storage) or 0
    if storage <= 0 then
        return
    end

    local storageValue = tonumber(levelData.storageValue)
    if storageValue == nil then
        storageValue = 1
    end

    local currentValue = -1
    if type(player.getStorageValue) == "function" then
        currentValue = tonumber(player:getStorageValue(storage)) or -1
        if currentValue >= storageValue then
            return
        end
    end

    player:setStorageValue(storage, storageValue)
    if OrnamentSystem and type(OrnamentSystem.notifyStorageUnlock) == "function" then
        OrnamentSystem.notifyStorageUnlock(player, storage, currentValue, storageValue)
    end
end

local function applyGemItemMetadata(item, gemKey, level)
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not item or not gemData then
        return false
    end

    local _, levelData, maxLevel = getGemLevelData(gemKey, level)
    local gemLevel = math.max(1, math.min(toNumber(level, 1), maxLevel))
    local changed = false
    changed = setCustomAttributeIfChanged(item, "gem_key", gemKey) or changed
    changed = setCustomAttributeIfChanged(item, "gem_level", gemLevel) or changed
    changed = setCustomAttributeIfChanged(item, "gem_maxlevel", maxLevel) or changed
    changed = setCustomAttributeIfChanged(item, "gem_name", (levelData and levelData.name) or gemData.name) or changed
    changed = setCustomAttributeIfChanged(item, "gem_clientid", ItemType(gemData.itemId):getClientId()) or changed
    changed = setCustomAttributeIfChanged(item, "gem_tooltip", GemsSocket_buildSpecialGemTooltip(gemKey, (levelData and levelData.tooltip) or gemData.tooltip or "", item, nil, gemLevel)) or changed
    return changed
end

local function ensureGemItemMetadata(item)
    if not item or not item:isItem() then
        return false
    end

    ensureGemIndexes(item:getId())
    local gemKey = GemsSocket.gemsByItemId and GemsSocket.gemsByItemId[item:getId()]
    if not gemKey then
        return false
    end

    local level = toNumber(item:getCustomAttribute("gem_level"), 1)
    return applyGemItemMetadata(item, gemKey, level)
end

local function getGemItemLevel(item)
    return math.max(1, toNumber(item and item:getCustomAttribute("gem_level"), 1))
end

setSocketGemDisplayData = function(item, index, gemData, player)
    local baseKey = string.format("socket_%d_", index)
    if gemData then
        local gemKey = getSocketGemKey(item, index)
        local gemLevel = getSocketGemLevel(item, index)
        local _, levelData, maxLevel = getGemLevelData(gemKey, gemLevel)
        local displayName = (levelData and levelData.name) or gemData.name
        if gemKey == "treasurygem" then
            displayName = getTreasurySocketDisplayName(item, index, gemData, displayName)
        end
        setCustomAttributeIfChanged(item, baseKey .. "name", displayName)
        setCustomAttributeIfChanged(item, baseKey .. "clientid", ItemType(gemData.itemId):getClientId())
        local tooltip = GemsSocket_buildSpecialGemTooltip(gemKey, (levelData and levelData.tooltip) or gemData.tooltip, item, index, gemLevel)
        if type(_G.MomentumGem) == "table" and _G.MomentumGem.isGem and _G.MomentumGem.isGem(gemKey) then
            local owner = item and type(item.getTopParent) == "function" and item:getTopParent() or nil
            tooltip = string.format("%s\n%s", tooltip or "", _G.MomentumGem.getCompactProgress(player or owner))
        end
        setCustomAttributeIfChanged(item, baseKey .. "tooltip", tooltip)
        setCustomAttributeIfChanged(item, baseKey .. "level", gemLevel)
        setCustomAttributeIfChanged(item, baseKey .. "maxlevel", maxLevel)
    else
        item:removeCustomAttribute(baseKey .. "name")
        item:removeCustomAttribute(baseKey .. "clientid")
        item:removeCustomAttribute(baseKey .. "tooltip")
        item:removeCustomAttribute(baseKey .. "level")
        item:removeCustomAttribute(baseKey .. "maxlevel")
    end
end

local function flushDamageGemPending(player)
    if type(_G.DamageGem) == "table" and type(_G.DamageGem.flushPending) == "function" then
        _G.DamageGem.flushPending(player)
    end
end

local function flushDamageGemPendingSoon(player)
    if type(_G.DamageGem) == "table" and type(_G.DamageGem.flushPendingSoon) == "function" then
        _G.DamageGem.flushPendingSoon(player, 250)
    end
end

local function clearSocketGem(item, socketIndex)
    local gemKey = getSocketGemKey(item, socketIndex)
    setSocketGemKey(item, socketIndex, nil)
    item:removeCustomAttribute(string.format("socket_%d_level", socketIndex))
    GemsSocket_clearSpecialGemState(item, socketIndex, gemKey)
    setSocketGemDisplayData(item, socketIndex, nil)
end

local function createLeveledGemItem(gemKey, level, extraState)
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not gemData then
        return nil
    end

    local gemItem = Game.createItem(gemData.itemId, 1)
    if not gemItem then
        return nil
    end

    applyGemItemMetadata(gemItem, gemKey, level)
    if type(extraState) == "table" then
        GemsSocket_writeSpecialGemState(gemItem, nil, gemKey, extraState)
        applyGemItemMetadata(gemItem, gemKey, level)
    end

    return gemItem
end

local function addLeveledGemToPlayer(player, gemKey, level, extraState)
    if not player then
        return false
    end

    local gemItem = createLeveledGemItem(gemKey, level, extraState)
    if not gemItem then
        return false
    end

    local result = player:addItemEx(gemItem, false)
    if result ~= RETURNVALUE_NOERROR then
        gemItem:remove()
        return false
    end

    return true, gemItem
end

function GemsSocket_itemHasSocketGem(item, gemKey, ignoredSocketIndex)
    if not item or not item:isItem() or not gemKey or gemKey == "" or not hasSockets(item) then
        return false
    end

    for index = 1, getSocketCount(item) do
        if index ~= ignoredSocketIndex and getSocketGemKey(item, index) == gemKey then
            return true
        end
    end

    return false
end

function GemsSocket_playerHasEquippedSocketGem(player, gemKey, ignoredItemUniqueId)
    if not player or not gemKey or gemKey == "" then
        return false
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local equippedItem = player:getSlotItem(slot)
        local equippedUniqueId = equippedItem and equippedItem:getUniqueId() or nil
        if equippedUniqueId ~= ignoredItemUniqueId and GemsSocket_itemHasSocketGem(equippedItem, gemKey) then
            return true
        end
    end

    return false
end

local function getEquippedSocketBonusTotal(player, bonusKey)
    if not player or type(bonusKey) ~= "string" or bonusKey == "" then
        return 0
    end

    local cache = GemsSocketBonusCache.getPlayerCache(player)
    if cache then
        return tonumber(cache.totals[bonusKey]) or 0
    end
    return GemsSocketBonusCache.legacyTotal(player, bonusKey)
end

function GemsSocket_getEquippedSocketBonusMax(player, bonusKey)
    if not player or type(bonusKey) ~= "string" or bonusKey == "" then
        return 0
    end

    local cache = GemsSocketBonusCache.getPlayerCache(player)
    if cache then
        return tonumber(cache.maximums[bonusKey]) or 0
    end
    return GemsSocketBonusCache.legacyMax(player, bonusKey)
end

local function bonusesContainAnyKey(bonuses, bonusKeys)
    if type(bonuses) ~= "table" then
        return false
    end

    if type(bonusKeys) == "string" then
        return bonuses[bonusKeys] ~= nil
    end

    if type(bonusKeys) ~= "table" then
        return false
    end

    for _, bonusKey in ipairs(bonusKeys) do
        if bonuses[bonusKey] ~= nil then
            return true
        end
    end

    return false
end

local function getConfiguredGemEffect(gemKey, level)
    local gemData = gemKey and GemsSocket.GEMS[gemKey] or nil
    if type(gemData) ~= "table" then
        return nil
    end

    local _, levelData = getGemLevelData(gemKey, level)
    local effect = tonumber((type(levelData) == "table" and levelData.effect) or gemData.effect) or 0
    if effect > 0 then
        return effect
    end

    return nil
end

local function getEquippedSocketTriggerEffect(player, bonusKeys, fallbackEffect, playerBonusCache)
    if not player or not player.isPlayer or not player:isPlayer() then
        return fallbackEffect
    end

    local cache = playerBonusCache or GemsSocketBonusCache.getPlayerCache(player)
    local gemsByKey = cache and cache.gemsByKey or nil
    if type(gemsByKey) ~= "table" then
        return fallbackEffect
    end

    for gemKey, entries in pairs(gemsByKey) do
        local gemData = GemsSocket.GEMS[gemKey]
        if type(gemData) == "table" then
            for _, entry in ipairs(entries or {}) do
                local _, levelData = getGemLevelData(gemKey, tonumber(entry.level) or 1)
                local bonuses = type(levelData) == "table" and type(levelData.bonuses) == "table" and levelData.bonuses or gemData.bonuses
                if bonusesContainAnyKey(bonuses, bonusKeys) then
                    local effect = getConfiguredGemEffect(gemKey, entry.level)
                    if effect then
                        return effect
                    end
                end
            end
        end
    end

    return fallbackEffect
end

rollSocketChance = function(chance)
    chance = tonumber(chance) or 0
    if chance <= 0 then
        return false
    end

    if chance >= 100 then
        return true
    end

    return math.random(10000) <= math.floor(chance * 100)
end

local function getSocketParryDamage(primaryDamage, secondaryDamage, reflectPercent)
    local totalDamage = math.abs(tonumber(primaryDamage) or 0) + math.abs(tonumber(secondaryDamage) or 0)
    if totalDamage <= 0 then
        return 0
    end

    reflectPercent = tonumber(reflectPercent) or 100
    if reflectPercent <= 0 then
        return 0
    end

    return math.max(1, math.floor(totalDamage * (reflectPercent / 100)))
end

local function applySocketReflectDamage(sourceId, targetId, damage, effect)
    local source = Player(sourceId)
    local target = Monster(targetId) or Player(targetId)
    damage = math.max(1, math.floor(tonumber(damage) or 0))
    if not source or not target or damage <= 0 then
        return
    end

    local beforeHealth = target:getHealth()
    doTargetCombatHealth(0, target, COMBAT_PHYSICALDAMAGE, -damage, -damage, effect or CONST_ME_BLOCKHIT)

    -- Some combat contexts can reject reflected damage. Monster fallback keeps Parry/Thorns from vanishing silently.
    if target:isMonster() and target:getHealth() >= beforeHealth then
        target:addHealth("physical", -damage)
        target:getPosition():sendMagicEffect(effect or CONST_ME_BLOCKHIT)
    end
end

local function applySocketDelayedHeal(playerId, amount, effect)
    local player = Player(playerId)
    amount = math.max(1, math.floor(tonumber(amount) or 0))
    if not player or amount <= 0 then
        return
    end

    local missingHealth = math.max(0, player:getMaxHealth() - player:getHealth())
    if missingHealth <= 0 then
        return
    end

    amount = math.min(amount, missingHealth)
    player:addHealth("healing", amount)
    player:getPosition():sendMagicEffect(effect or CONST_ME_MAGIC_GREEN)
end

local function trySocketParryAndThorns(creature, attacker, primaryDamage, secondaryDamage, totals)
    if not creature or not creature:isPlayer() or not attacker or attacker == creature
        or not attacker.isCreature or not attacker:isCreature() then
        return false
    end

    totals = totals or {}
    local triggered = false
    local parryChance = totals.socket_parry_chance or 0
    local parryRoll = rollSocketChance(parryChance)
    if parryRoll then
        local reflectPercent = totals.socket_parry_percent or 0
        if reflectPercent <= 0 then
            reflectPercent = 100
        end

        local reflectDamage = getSocketParryDamage(primaryDamage, secondaryDamage, reflectPercent)
        if reflectDamage > 0 then
            triggered = true
            local parryEffect = getEquippedSocketTriggerEffect(creature, { "socket_parry_chance", "socket_parry_percent" }, CONST_ME_BLOCKHIT)
            creature:say("PARRY!", TALKTYPE_MONSTER_SAY)
            addEvent(applySocketReflectDamage, 1, creature:getId(), attacker:getId(), reflectDamage, parryEffect)
            attacker:getPosition():sendMagicEffect(parryEffect)
            applySacredLinkParryShield(creature)
        end
    end

    local thornsChance = totals.socket_thorns_chance or 0
    local thornsRoll = rollSocketChance(thornsChance)
    if thornsRoll then
        local thornsDamage = totals.socket_thorns_damage or 0
        if thornsDamage > 0 then
            triggered = true
            local thornsEffect = getEquippedSocketTriggerEffect(creature, { "socket_thorns_chance", "socket_thorns_damage" }, CONST_ME_DRAWBLOOD)
            addEvent(applySocketReflectDamage, 1, creature:getId(), attacker:getId(), thornsDamage, thornsEffect)
            attacker:getPosition():sendMagicEffect(thornsEffect)
        end
    end

    return triggered
end

local function scaleSocketCombatDamage(damage, multiplier)
    damage = tonumber(damage) or 0
    multiplier = tonumber(multiplier) or 1
    if damage == 0 or multiplier == 1 then
        return damage
    end

    local scaled = math.floor(math.abs(damage) * multiplier)
    if scaled <= 0 then
        return 0
    end

    if damage < 0 then
        return -scaled
    end
    return scaled
end

local function getIncomingSocketDamage(primaryDamage, secondaryDamage)
    return math.abs(tonumber(primaryDamage) or 0) + math.abs(tonumber(secondaryDamage) or 0)
end

function GemsSocket_hasCombatRuntime(player, target)
    if not player or not player:isPlayer() then
        return false
    end
    local playerId = player:getId()
    local targetId = target and target.getId and target:getId() or nil
    local now = os.time()
    local phoenix = phoenixReviveState[playerId]
    if ascendanceState[playerId] and now <= (ascendanceState[playerId].activeUntil or 0)
        or warstoneState[playerId] and now <= (warstoneState[playerId].activeUntil or 0)
        or boonstoneState[playerId] and now <= (boonstoneState[playerId].activeUntil or 0)
        or voidstoneState[playerId] and now <= (voidstoneState[playerId].activeUntil or 0)
        or battlestoneState[playerId] and now <= (battlestoneState[playerId].activeUntil or 0)
        or mendstoneState[playerId] and now <= (mendstoneState[playerId].activeUntil or 0)
        or totemGemState[playerId] and now <= (totemGemState[playerId].activeUntil or 0)
        or sacredLinkState[playerId] and now <= (sacredLinkState[playerId].activeUntil or 0)
        or reversalState[playerId] and now <= (reversalState[playerId].activeUntil or 0)
        or phoenix and now <= (phoenix.invincibleUntil or 0) then
        return true
    end
    for _, state in pairs(sacredLinkState) do
        if state and now <= (state.activeUntil or 0) then
            return true
        end
    end
    for _, state in pairs(totemGemState) do
        if state and now <= (state.activeUntil or 0) then
            return true
        end
    end
    if player:getParty() and type(GemsSocketBonusCache.hasPlayersWithGem) == "function" then
        if GemsSocketBonusCache.hasPlayersWithGem("formationstone")
            or GemsSocketBonusCache.hasPlayersWithGem("lifelinegem")
            or GemsSocketBonusCache.hasPlayersWithGem("martyrgem")
            or type(_G.GemsSocket_advancedHasMartyrCandidate) == "function"
                and _G.GemsSocket_advancedHasMartyrCandidate(player) then
            return true
        end
    end
    if type(_G.GemsSocket_advancedHasCombatRuntime) == "function"
        and _G.GemsSocket_advancedHasCombatRuntime(playerId) then
        return true
    end
    return type(_G.ExtraSocketGems) == "table"
        and type(_G.ExtraSocketGems.hasCombatRuntime) == "function"
        and _G.ExtraSocketGems.hasCombatRuntime(playerId, targetId) or false
end

local function getSocketAttackerPlayer(attacker)
    if not attacker then
        return nil
    end

    if attacker:isPlayer() then
        return attacker
    end

    local master = attacker:getMaster()
    if master and master:isPlayer() then
        return master
    end

    return nil
end

function GemsSocket_hasOtherGuildMemberOnline(player)
    if not player or not player:isPlayer() then
        return false
    end

    local guild = player:getGuild()
    if not guild then
        return false
    end

    local guildId = guild:getId()
    local playerId = player:getId()

    local members = guild:getMembersOnline()
    if type(members) == "table" then
        for _, member in ipairs(members) do
            if member and member:isPlayer() and member:getId() ~= playerId then
                return true
            end
        end
    end

    for _, onlinePlayer in ipairs(Game.getPlayers() or {}) do
        if onlinePlayer and onlinePlayer:isPlayer() and onlinePlayer:getId() ~= playerId then
            local onlineGuild = onlinePlayer:getGuild()
            if onlineGuild and onlineGuild:getId() == guildId then
                return true
            end
        end
    end

    return false
end

function GemsSocket_getSoulmarkState(player)
    if not player or not player:isPlayer() then
        return nil
    end

    local playerId = player:getId()
    local state = soulmarkGemState[playerId]
    if not state then
        state = {
            targetId = 0,
            cooldownUntil = 0,
        }
        soulmarkGemState[playerId] = state
    end
    return state
end

function GemsSocket_clearSoulmarkTarget(player, target)
    if not player or not player:isPlayer() or not target then
        return
    end

    local state = soulmarkGemState[player:getId()]
    if state and state.targetId == target:getId() then
        state.targetId = 0
    end
end

function GemsSocket_createPacifiedCondition(durationSeconds)
    durationSeconds = math.max(0, tonumber(durationSeconds) or 0)
    if durationSeconds <= 0 then
        return nil
    end

    local condition = Condition(CONDITION_PACIFIED)
    condition:setParameter(CONDITION_PARAM_TICKS, durationSeconds * 1000)
    return condition
end

function GemsSocket_tryTriggerKingsguardGem(player, attacker, totals)
    if not player or not player:isPlayer() or not player:getGuild() then
        return
    end

    local attackerPlayer = getSocketAttackerPlayer(attacker)
    if not attackerPlayer or attackerPlayer == player then
        return
    end

    local chance = totals.socket_kingsguard_chance or 0
    if chance <= 0 then
        return
    end

    local playerId = player:getId()
    local state = kingsguardGemState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        kingsguardGemState[playerId] = state
    end

    local now = os.time()
    if now < (state.cooldownUntil or 0) then
        return
    end

    local cooldown = math.max(1, totals.socket_kingsguard_cooldown or 0)
    state.cooldownUntil = now + cooldown

    if not rollSocketChance(chance) then
        return
    end

    local duration = math.max(1, totals.socket_kingsguard_duration or 0)
    local condition = GemsSocket_createPacifiedCondition(duration)
    if condition then
        attackerPlayer:addCondition(condition)
        attackerPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
        attackerPlayer:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You are silenced for %d seconds.", duration))
    end
end

local function getSocketScaledAmount(baseValue, percent)
    baseValue = tonumber(baseValue) or 0
    percent = tonumber(percent) or 0
    if baseValue <= 0 or percent <= 0 then
        return 0
    end

    return math.max(1, math.floor(baseValue * (percent / 100)))
end

local function getAbyssalDepthsState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = abyssalDepthsState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
        }
        abyssalDepthsState[playerId] = state
    end

    return state
end

local function isSocketSpellOrigin(origin)
    if origin == ORIGIN_CONDITION or origin == ORIGIN_MELEE or origin == ORIGIN_RANGED then
        return false
    end

    if ORIGIN_WAND and origin == ORIGIN_WAND then
        return false
    end

    return origin ~= nil
end

local function getAbyssalDepthsDamageBonus(player, totals)
    local bonusPercent = totals.socket_abyssal_depths_percent or 0
    if bonusPercent <= 0 then
        return 0
    end

    local state = getAbyssalDepthsState(player)
    if not state then
        return 0
    end

    local now = os.time()
    if now > state.activeUntil then
        return 0
    end

    return bonusPercent
end

local function tryTriggerAbyssalDepths(player, totalDamage, totals)
    if totalDamage <= 0 then
        return
    end

    local chance = totals.socket_abyssal_depths_chance or 0
    local bonusPercent = totals.socket_abyssal_depths_percent or 0
    if chance <= 0 or bonusPercent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getAbyssalDepthsState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_ABYSSAL_DEPTHS_DURATION
    state.cooldownUntil = now + SOCKET_ABYSSAL_DEPTHS_COOLDOWN
    player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
end

local function getSpellfuryState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = spellfuryState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
        }
        spellfuryState[playerId] = state
    end

    return state
end

local function getAscendanceState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = ascendanceState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            blastDamage = 0,
            dodgeBonus = 0,
        }
        ascendanceState[playerId] = state
    end

    return state
end

local function getVoltstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = voltstoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        voltstoneState[playerId] = state
    end

    return state
end

local function getEmberstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = emberstoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            explosionDamage = 0,
            burnDamage = 0,
        }
        emberstoneState[playerId] = state
    end

    return state
end

local function getBindstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = bindstoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        bindstoneState[playerId] = state
    end

    return state
end

local function getSurgestoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = surgestoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        surgestoneState[playerId] = state
    end

    return state
end

local function getWarstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = warstoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            damageBonus = 0,
        }
        warstoneState[playerId] = state
    end

    return state
end

local function getBoonstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = boonstoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            damageBonus = 0,
            speedDelta = 0,
        }
        boonstoneState[playerId] = state
    end

    return state
end

local function getVenomstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = venomstoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        venomstoneState[playerId] = state
    end

    return state
end

local function getDreadstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = dreadstoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        dreadstoneState[playerId] = state
    end

    return state
end

local function getSpiritstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = spiritstoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            healthGain = 0,
            manaGain = 0,
        }
        spiritstoneState[playerId] = state
    end

    return state
end

local function getVoidstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = voidstoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            targetId = 0,
            vulnerabilityPercent = 0,
        }
        voidstoneState[playerId] = state
    end

    return state
end

local function getGravitystoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = gravitystoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        gravitystoneState[playerId] = state
    end

    return state
end

local function getChronostoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = chronostoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            reductionPercent = 0,
        }
        chronostoneState[playerId] = state
    end

    return state
end

function getMarksmanstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = marksmanstoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        marksmanstoneState[playerId] = state
    end

    return state
end

function getBattlestoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = battlestoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            pending = false,
            echoing = false,
        }
        battlestoneState[playerId] = state
    end

    return state
end

function getArcanestoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = arcanestoneState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        arcanestoneState[playerId] = state
    end

    return state
end

function getMendstoneState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = mendstoneState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
        }
        mendstoneState[playerId] = state
    end

    return state
end

function getTotemGemState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = totemGemState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            kind = nil,
            power = 0,
            bonusPercent = 0,
            position = nil,
            visualItem = nil,
        }
        totemGemState[playerId] = state
    end

    return state
end

function getSacredLinkState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = sacredLinkState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            redirectPercent = 0,
            resistancePercent = 0,
            shieldPercent = 0,
            shieldUntil = 0,
        }
        sacredLinkState[playerId] = state
    end

    return state
end

function getReversalState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = reversalState[playerId]
    if not state then
        state = {
            activeUntil = 0,
            cooldownUntil = 0,
            storedHealing = 0,
            storePercent = 0,
            holyPercent = 0,
        }
        reversalState[playerId] = state
    end

    return state
end

local function getSpellfuryDamageBonus(player, origin, totals)
    if not isSocketSpellOrigin(origin) then
        return 0
    end

    local bonusPercent = totals.socket_spellfury_percent or 0
    if bonusPercent <= 0 then
        return 0
    end

    local state = getSpellfuryState(player)
    if not state then
        return 0
    end

    local now = os.time()
    if now > state.activeUntil then
        return 0
    end

    return bonusPercent
end

local function getWarstoneDamageBonus(player)
    local state = getWarstoneState(player)
    if not state then
        return 0
    end

    local now = os.time()
    if now > state.activeUntil then
        return 0
    end

    return math.max(0, tonumber(state.damageBonus) or 0)
end

local function getBoonstoneDamageBonus(player)
    local state = getBoonstoneState(player)
    if not state then
        return 0
    end

    local now = os.time()
    if now > state.activeUntil then
        return 0
    end

    return math.max(0, tonumber(state.damageBonus) or 0)
end

local function getVoidstoneDamageBonus(player, target)
    if not target then
        return 0
    end

    local state = getVoidstoneState(player)
    if not state then
        return 0
    end

    local now = os.time()
    if now > state.activeUntil or state.targetId ~= target:getId() then
        return 0
    end

    return math.max(0, tonumber(state.vulnerabilityPercent) or 0)
end

local function getAscendanceDodgeBonus(player)
    local state = getAscendanceState(player)
    if not state then
        return 0
    end

    local now = os.time()
    if now > state.activeUntil then
        return 0
    end

    return math.max(0, tonumber(state.dodgeBonus) or 0)
end

function hasActiveBattlestone(player)
    local state = getBattlestoneState(player)
    if not state then
        return false
    end

    return state.pending == true and os.time() <= state.activeUntil
end

function consumeBattlestone(player)
    local state = getBattlestoneState(player)
    if not state then
        return
    end

    state.pending = false
    state.activeUntil = 0
    state.echoing = false
end

function getMirrorgemState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = mirrorgemState[playerId]
    if not state then
        state = {
            cooldownUntil = 0,
        }
        mirrorgemState[playerId] = state
    end

    return state
end

local function tryTriggerMirrorgem(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, totals)
    if not isSocketSpellOrigin(origin) or not target or not target:isMonster() then
        return
    end

    local damagePercent = totals.socket_mirrorgem_damage or 0
    if damagePercent <= 0 then
        return
    end

    local state = getMirrorgemState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    local cooldown = totals.socket_mirrorgem_cooldown or 0
    if cooldown <= 0 then
        cooldown = SOCKET_MIRRORGEM_DEFAULT_COOLDOWN
    end

    local totalDamage = getIncomingSocketDamage(primaryDamage, secondaryDamage)
    local echoDamage = getSocketScaledAmount(totalDamage, damagePercent)
    if echoDamage <= 0 then
        return
    end

    local echoType = primaryType
    if (not echoType or echoType == COMBAT_NONE or primaryDamage <= 0) and secondaryType and secondaryType ~= COMBAT_NONE then
        echoType = secondaryType
    end

    if not echoType or echoType == COMBAT_NONE then
        return
    end

    state.cooldownUntil = now + cooldown
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    mirrorgemEchoLock[player:getId()] = true
    doTargetCombatHealth(player, target, echoType, -echoDamage, -echoDamage, CONST_ME_PURPLEENERGY)
    mirrorgemEchoLock[player:getId()] = nil
end

function hasActiveMendstone(player)
    local state = getMendstoneState(player)
    if not state then
        return false
    end

    return os.time() <= state.activeUntil
end

function arePartyLinkedPlayers(firstPlayer, secondPlayer)
    if not firstPlayer or not secondPlayer or not firstPlayer:isPlayer() or not secondPlayer:isPlayer() then
        return false
    end

    if firstPlayer == secondPlayer then
        return true
    end

    local firstParty = firstPlayer:getParty()
    local secondParty = secondPlayer:getParty()
    return firstParty and secondParty and firstParty == secondParty
end

function getPartyPlayersInRange(owner, range)
    local players = {}
    if not owner or not owner:isPlayer() then
        return players
    end

    local ownerPosition = owner:getPosition()
    if not ownerPosition then
        return players
    end

    local party = owner:getParty()
    local candidates = party and party:getMembers() or {}
    if party and party:getLeader() then
        candidates[#candidates + 1] = party:getLeader()
    elseif not party then
        candidates[1] = owner
    end
    for _, member in ipairs(candidates) do
        local memberPosition = member and member:isPlayer() and member:getPosition() or nil
        if memberPosition and ownerPosition:getDistance(memberPosition) <= range then
            players[#players + 1] = member
        end
    end

    return players
end

function clearTotemVisual(state)
    if not state then
        return
    end

    local visualItem = state.visualItem
    if visualItem and visualItem:isItem() then
        visualItem:remove()
    end
    state.visualItem = nil
end

local function getNearbyMonsters(centerPosition, range)
    local monsters = {}
    if not centerPosition then
        return monsters
    end

    for _, creature in ipairs(Game.getSpectators(centerPosition, false, false, range, range, range, range) or {}) do
        if creature:isMonster() and not creature:getMaster() then
            monsters[#monsters + 1] = creature
        end
    end

    return monsters
end

function ShockwaveStone_getState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = shockwaveStoneState[playerId]
    if not state then
        state = {
            cooldownUntil = 0,
        }
        shockwaveStoneState[playerId] = state
    end

    return state
end

function ShockwaveStone_isBossMonster(monster)
    if not monster or not monster:isMonster() then
        return true
    end

    local monsterType = MonsterType(monster:getName())
    if not monsterType then
        return false
    end

    if type(monsterType.isRewardBoss) == "function" then
        local ok, isRewardBoss = pcall(function()
            return monsterType:isRewardBoss()
        end)
        if ok and isRewardBoss then
            return true
        end
    end

    if type(monsterType.isBoss) == "function" then
        local ok, isBoss = pcall(function()
            return monsterType:isBoss()
        end)
        if ok and isBoss then
            return true
        end
    end

    return false
end

function ShockwaveStone_isBlockedPosition(creature, position)
    local tile = Tile(position)
    if not tile then
        return true
    end

    if tile:hasFlag(TILESTATE_PROTECTIONZONE)
        or tile:hasFlag(TILESTATE_TELEPORT)
        or tile:hasFlag(TILESTATE_FLOORCHANGE)
        or tile:hasFlag(TILESTATE_BLOCKSOLID)
        or tile:hasFlag(TILESTATE_BLOCKPATH)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKSOLID)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKPATH) then
        return true
    end

    if tile:getTopCreature() then
        return true
    end

    if creature and queryTileAddThing(creature:getId(), position) ~= RETURNVALUE_NOERROR then
        return true
    end

    return false
end

function GemsSocket_isNormalMonster(monster)
    return monster and monster:isMonster() and not monster:getMaster() and not ShockwaveStone_isBossMonster(monster)
end

function GemsSocket_isSafePlayerTeleportPosition(player, position)
    local tile = position and Tile(position)
    if not player or not tile then
        return false
    end

    if tile:getHouse()
        or tile:hasFlag(TILESTATE_PROTECTIONZONE)
        or tile:hasFlag(TILESTATE_TELEPORT)
        or tile:hasFlag(TILESTATE_FLOORCHANGE)
        or tile:hasFlag(TILESTATE_BLOCKSOLID)
        or tile:hasFlag(TILESTATE_BLOCKPATH)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKSOLID)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKPATH)
        or tile:getTopCreature() then
        return false
    end

    return queryTileAddThing(player:getId(), position) == RETURNVALUE_NOERROR
end

function GemsSocket_isSafeMonsterSpawnPosition(position)
    local tile = position and Tile(position)
    if not tile then
        return false
    end

    if tile:getHouse()
        or tile:hasFlag(TILESTATE_PROTECTIONZONE)
        or tile:hasFlag(TILESTATE_TELEPORT)
        or tile:hasFlag(TILESTATE_FLOORCHANGE)
        or tile:hasFlag(TILESTATE_BLOCKSOLID)
        or tile:hasFlag(TILESTATE_BLOCKPATH)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKSOLID)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKPATH)
        or tile:getTopCreature() then
        return false
    end

    return true
end

function GemsSocket_findNearbySpawnPosition(anchorPosition, minRange, maxRange)
    if not anchorPosition then
        return nil
    end

    minRange = math.max(0, tonumber(minRange) or 0)
    maxRange = math.max(minRange, tonumber(maxRange) or minRange)
    local candidates = {}
    for radius = minRange, maxRange do
        for dx = -radius, radius do
            for dy = -radius, radius do
                if math.max(math.abs(dx), math.abs(dy)) == radius then
                    candidates[#candidates + 1] = Position(anchorPosition.x + dx, anchorPosition.y + dy, anchorPosition.z)
                end
            end
        end
    end

    for index = #candidates, 2, -1 do
        local swapIndex = math.random(index)
        candidates[index], candidates[swapIndex] = candidates[swapIndex], candidates[index]
    end

    for _, position in ipairs(candidates) do
        if GemsSocket_isSafeMonsterSpawnPosition(position) then
            return position
        end
    end

    return nil
end

function GemsSocket_getSign(value)
    value = tonumber(value) or 0
    if value > 0 then
        return 1
    elseif value < 0 then
        return -1
    end
    return 0
end

function GemsSocket_findCowardsCrownPosition(player, monster)
    if not player or not monster then
        return nil
    end

    local playerPosition = player:getPosition()
    local monsterPosition = monster:getPosition()
    if not playerPosition or not monsterPosition then
        return nil
    end

    local dx = GemsSocket_getSign(monsterPosition.x - playerPosition.x)
    local dy = GemsSocket_getSign(monsterPosition.y - playerPosition.y)
    if dx == 0 and dy == 0 then
        return nil
    end

    local offsets = {
        { x = dx, y = dy },
        { x = dx, y = 0 },
        { x = 0, y = dy },
        { x = dx, y = -dy },
        { x = -dx, y = dy },
    }

    for _, offset in ipairs(offsets) do
        local position = Position(monsterPosition.x + offset.x, monsterPosition.y + offset.y, monsterPosition.z)
        if GemsSocket_isSafePlayerTeleportPosition(player, position) then
            return position
        end
    end

    return nil
end

function GemsSocket_tryTriggerMimicGem(player, target)
    if not player or not player:isPlayer() or not GemsSocket_isNormalMonster(target) or mimicGemState[target:getId()] then
        return
    end

    local chance = getEquippedSocketBonusTotal(player, "socket_mimic_chance")
    if chance <= 0 or not rollSocketChance(chance) then
        return
    end

    local spawnPosition = GemsSocket_findNearbySpawnPosition(target:getPosition(), 1, 2)
    if not spawnPosition then
        return
    end

    local targetName = target:getName()
    local mimic = Game.createMonster(targetName, spawnPosition, true, true)
    if not mimic then
        return
    end

    mimicGemState[mimic:getId()] = {
        sourceName = targetName,
        extraRolls = math.max(1, getEquippedSocketBonusTotal(player, "socket_mimic_extra_rolls")),
    }
    if mimic.selectTarget then
        mimic:selectTarget(player)
    end
    if mimic.setTarget then
        mimic:setTarget(player)
    end

    spawnPosition:sendMagicEffect(CONST_ME_TELEPORT)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("The fallen %s twists into a hostile mimic.", targetName))
end

function GemsSocket_mimicOnDropLoot(player, monster, corpse)
    if not monster or not corpse then
        return true
    end

    local state = mimicGemState[monster:getId()]
    if not state then
        return true
    end
    mimicGemState[monster:getId()] = nil

    local monsterType = MonsterType(state.sourceName or monster:getName())
    local monsterLoot = monsterType and monsterType:getLoot() or nil
    if not monsterLoot then
        return true
    end

    local extraRolls = math.max(1, tonumber(state.extraRolls) or 1)
    for _ = 1, extraRolls do
        for _, lootData in ipairs(monsterLoot) do
            if lootData.itemId and lootData.chance and getLootRandom() <= lootData.chance then
                local minCount = lootData.minCount or 1
                local maxCount = lootData.maxCount or (lootData.count or 1)
                local count = math.max(1, math.random(minCount, maxCount))
                corpse:addItem(lootData.itemId, count)
            end
        end
    end

    return true
end

function GemsSocket_tryTriggerCowardsCrown(player, totals)
    if not player or not player:isPlayer() then
        return
    end

    local threshold = totals.socket_coward_crown_threshold or 0
    if threshold <= 0 then
        return
    end

    local playerId = player:getId()
    local state = cowardsCrownState[playerId]
    if not state then
        state = { cooldownUntil = 0, nextScanAt = 0 }
        cowardsCrownState[playerId] = state
    end

    local now = os.time()
    if now < (state.cooldownUntil or 0) then
        return
    end

    local nowMs = (os.mtime and os.mtime() or (now * 1000))
    if nowMs < (tonumber(state.nextScanAt) or 0) then
        return
    end
    local performanceConfig = GemsSocket and GemsSocket.PERFORMANCE or {}
    state.nextScanAt = nowMs + math.max(100, tonumber(performanceConfig.cowardsCrownScanThrottleMs) or 500)

    local range = math.max(1, totals.socket_coward_crown_range or 0)
    local monsters = {}
    -- Surrounding monsters are the trigger condition itself, so this query cannot follow a random proc.
    for _, spectator in ipairs(Game.getSpectators(player:getPosition(), false, false, range, range, range, range) or {}) do
        if GemsSocket_isNormalMonster(spectator) then
            monsters[#monsters + 1] = spectator
        end
    end

    if #monsters < threshold then
        return
    end

    table.sort(monsters, function(left, right)
        return left:getHealth() < right:getHealth()
    end)

    for _, monster in ipairs(monsters) do
        local blinkPosition = GemsSocket_findCowardsCrownPosition(player, monster)
        if blinkPosition then
            local cooldown = math.max(1, totals.socket_coward_crown_cooldown or 0)
            state.cooldownUntil = now + cooldown
            player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            player:teleportTo(blinkPosition, true)
            player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
            return
        end
    end
end

function GemsSocket_restoreBetrayalTarget(attackerId, playerId, expectedUntil)
    local attacker = Monster(attackerId)
    local player = Player(playerId)
    if not attacker then
        return
    end

    local state = betrayalGemActiveState[attackerId]
    if not state or state.activeUntil ~= expectedUntil then
        return
    end
    local victimId = state.victimId
    betrayalGemActiveState[attackerId] = nil

    if victimId then
        local victim = Creature(victimId)
        if victim and attacker.removeTarget then
            attacker:removeTarget(victim)
        end
        if victim and victim.removeTarget then
            victim:removeTarget(attacker)
        end
    end

    if player and player:isPlayer() and attacker.selectTarget then
        attacker:selectTarget(player)
    end
    if player and player:isPlayer() and attacker.setTarget then
        attacker:setTarget(player)
    end
end

function GemsSocket_tryTriggerBetrayalGem(player, attacker, totals)
    if not player or not player:isPlayer() or not GemsSocket_isNormalMonster(attacker) or mimicGemState[attacker:getId()] then
        return nil
    end

    local chance = totals.socket_betrayal_chance or 0
    if chance <= 0 then
        return nil
    end

    local playerId = player:getId()
    local state = betrayalGemCooldownState[playerId]
    if not state then
        state = { cooldownUntil = 0 }
        betrayalGemCooldownState[playerId] = state
    end

    local now = os.time()
    if now < (state.cooldownUntil or 0) then
        return nil
    end

    local cooldown = math.max(1, totals.socket_betrayal_cooldown or 0)
    state.cooldownUntil = now + cooldown

    if not rollSocketChance(chance) then
        return nil
    end

    local range = math.max(1, totals.socket_betrayal_range or 0)
    local candidates = {}
    -- The cooldown and betrayal roll have already succeeded before this area query.
    for _, spectator in ipairs(Game.getSpectators(attacker:getPosition(), false, false, range, range, range, range) or {}) do
        if spectator ~= attacker and GemsSocket_isNormalMonster(spectator) and not mimicGemState[spectator:getId()] then
            candidates[#candidates + 1] = spectator
        end
    end

    if #candidates == 0 then
        return nil
    end

    local victim = candidates[math.random(#candidates)]
    local duration = math.max(1, totals.socket_betrayal_duration or 0)
    local activeUntil = now + duration
    local activeState = {
        activeUntil = activeUntil,
        victimId = victim:getId()
    }
    betrayalGemActiveState[attacker:getId()] = activeState
    if attacker.addTarget then
        attacker:addTarget(victim, true)
    end
    if victim.addTarget then
        victim:addTarget(attacker, true)
    end
    if attacker.selectTarget then
        attacker:selectTarget(victim)
    end
    if attacker.setTarget then
        attacker:setTarget(victim)
    end
    if victim.selectTarget then
        victim:selectTarget(attacker)
    end
    if victim.setTarget then
        victim:setTarget(attacker)
    end
    attacker:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
    victim:getPosition():sendMagicEffect(CONST_ME_POFF)
    addEvent(GemsSocket_restoreBetrayalTarget, duration * 1000, attacker:getId(), playerId, activeUntil)
    return activeState
end

local function GemsSocket_redirectBetrayalDamage(player, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, totals)
    if not player or not player:isPlayer() or not GemsSocket_isNormalMonster(attacker) then
        return primaryDamage, primaryType, secondaryDamage, secondaryType, false
    end

    local attackerId = attacker:getId()
    local state = betrayalGemActiveState[attackerId]
    local now = os.time()
    if not state or now > (state.activeUntil or 0) then
        state = GemsSocket_tryTriggerBetrayalGem(player, attacker, totals)
    end

    if not state or now > (state.activeUntil or 0) or not state.victimId then
        return primaryDamage, primaryType, secondaryDamage, secondaryType, false
    end

    local victim = Monster(state.victimId)
    if not victim or victim == attacker or not GemsSocket_isNormalMonster(victim) then
        betrayalGemActiveState[attackerId] = nil
        return primaryDamage, primaryType, secondaryDamage, secondaryType, false
    end

    local attackerPosition = attacker:getPosition()
    local victimPosition = victim:getPosition()
    if not attackerPosition or not victimPosition or attackerPosition.z ~= victimPosition.z then
        return primaryDamage, primaryType, secondaryDamage, secondaryType, false
    end

    local redirected = false
    if primaryDamage < 0 and primaryType and primaryType ~= COMBAT_NONE then
        local damage = math.abs(primaryDamage)
        doTargetCombatHealth(attacker, victim, primaryType, -damage, -damage, CONST_ME_DRAWBLOOD)
        redirected = true
    end
    if secondaryDamage < 0 and secondaryType and secondaryType ~= COMBAT_NONE then
        local damage = math.abs(secondaryDamage)
        doTargetCombatHealth(attacker, victim, secondaryType, -damage, -damage, CONST_ME_DRAWBLOOD)
        redirected = true
    end

    if redirected then
        attacker:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
        victim:getPosition():sendMagicEffect(CONST_ME_HITAREA)
        return 0, primaryType, 0, secondaryType, true
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType, false
end

function ShockwaveStone_getPushStep(playerPosition, monsterPosition)
    local dx = monsterPosition.x - playerPosition.x
    local dy = monsterPosition.y - playerPosition.y

    if dx ~= 0 then
        dx = dx > 0 and 1 or -1
    end
    if dy ~= 0 then
        dy = dy > 0 and 1 or -1
    end

    return dx, dy
end

local SHOCKWAVE_PUSH_STEP_DELAY_MS = 90

local function ShockwaveStone_getCardinalDirection(dx, dy)
    if dx > 0 then
        return EAST
    elseif dx < 0 then
        return WEST
    elseif dy > 0 then
        return SOUTH
    elseif dy < 0 then
        return NORTH
    end
    return nil
end

local function ShockwaveStone_getFaceDirection(fromPosition, toPosition)
    if not fromPosition or not toPosition then
        return nil
    end

    local dx = toPosition.x - fromPosition.x
    local dy = toPosition.y - fromPosition.y
    if math.abs(dx) >= math.abs(dy) and dx ~= 0 then
        return dx > 0 and EAST or WEST
    elseif dy ~= 0 then
        return dy > 0 and SOUTH or NORTH
    end
    return nil
end

local function ShockwaveStone_applyPushStep(monsterId, direction, faceDirection)
    local monster = Monster(monsterId)
    if not monster then
        return
    end

    doMoveCreature(monsterId, direction)
    if faceDirection then
        addEvent(function(cid, dir)
            local creature = Creature(cid)
            if creature then
                creature:setDirection(dir)
            end
        end, 1, monsterId, faceDirection)
    end
end

function ShockwaveStone_pushMonster(player, monster, pushDistance)
    local playerPosition = player:getPosition()
    local currentPosition = monster:getPosition()
    if not playerPosition or not currentPosition or playerPosition.z ~= currentPosition.z then
        return false
    end

    local dx, dy = ShockwaveStone_getPushStep(playerPosition, currentPosition)
    if dx == 0 and dy == 0 then
        return false
    end

    local collided = false
    local steps = {}
    local simulatedPosition = Position(currentPosition.x, currentPosition.y, currentPosition.z)
    local faceDirection = ShockwaveStone_getFaceDirection(currentPosition, playerPosition)

    for _ = 1, pushDistance do
        local stepParts = {}
        if dx ~= 0 then
            table.insert(stepParts, { x = dx, y = 0 })
        end
        if dy ~= 0 then
            table.insert(stepParts, { x = 0, y = dy })
        end

        for _, step in ipairs(stepParts) do
            local nextPosition = Position(simulatedPosition.x + step.x, simulatedPosition.y + step.y, simulatedPosition.z)
            if ShockwaveStone_isBlockedPosition(monster, nextPosition) then
                collided = true
                break
            end

            local direction = ShockwaveStone_getCardinalDirection(step.x, step.y)
            if direction then
                table.insert(steps, { direction = direction, position = nextPosition })
            end
            simulatedPosition = nextPosition
        end

        if collided then
            break
        end
    end

    for index, step in ipairs(steps) do
        addEvent(ShockwaveStone_applyPushStep, (index - 1) * SHOCKWAVE_PUSH_STEP_DELAY_MS, monster:getId(), step.direction, faceDirection)
        step.position:sendMagicEffect(CONST_ME_POFF)
    end

    return collided
end

function ShockwaveStone_trigger(player, bonusCache)
    local totals = bonusCache and bonusCache.totals or {}
    local maximums = bonusCache and bonusCache.maximums or {}
    local chance = totals.socket_repulse_chance or 0
    if chance <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = ShockwaveStone_getState(player)
    if not state then
        return
    end

    local now = os.time()
    local cooldown = math.max(1, maximums.socket_repulse_cooldown or 0)
    if now < state.cooldownUntil then
        return
    end

    local range = math.max(1, maximums.socket_repulse_range or 0)
    local pushDistance = math.max(1, maximums.socket_repulse_push or 0)
    local damage = math.max(0, totals.socket_repulse_damage or 0)
    local collisionDamage = math.max(0, totals.socket_repulse_collision_damage or 0)
    local monsters = getNearbyMonsters(player:getPosition(), range)
    if #monsters == 0 then
        return
    end

    state.cooldownUntil = now + cooldown
    player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)

    for _, monster in ipairs(monsters) do
        if monster:isMonster() and not monster:getMaster() and not ShockwaveStone_isBossMonster(monster) then
            local collided = ShockwaveStone_pushMonster(player, monster, pushDistance)
            local totalDamage = damage + (collided and collisionDamage or 0)
            if totalDamage > 0 then
                doTargetCombatHealth(player, monster, COMBAT_ENERGYDAMAGE, -totalDamage, -totalDamage, collided and CONST_ME_BLOCKHIT or CONST_ME_ENERGYHIT)
            end
        end
    end
end

function GemsSocket_findTileItemById(position, itemId, ownerId)
    local tile = position and Tile(position)
    if not tile then
        return nil
    end

    for _, tileItem in ipairs(tile:getItems() or {}) do
        if tileItem:getId() == itemId then
            if ownerId == nil or tonumber(tileItem:getCustomAttribute("socket_owner_id")) == ownerId then
                return tileItem
            end
        end
    end

    return nil
end

function GemsSocket_getSpecialConfig(key)
    local specials = GemsSocket.SPECIALS
    if type(specials) ~= "table" then
        return nil
    end
    local entry = specials[key]
    return type(entry) == "table" and entry or nil
end

function RiftstepGem_getState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = riftstepGemState[playerId]
    if not state then
        state = {
            cooldownUntil = 0,
        }
        riftstepGemState[playerId] = state
    end

    return state
end

function RiftstepGem_isSafePosition(creature, position)
    local tile = Tile(position)
    if not tile then
        return false
    end

    if tile:getHouse()
        or tile:hasFlag(TILESTATE_PROTECTIONZONE)
        or tile:hasFlag(TILESTATE_TELEPORT)
        or tile:hasFlag(TILESTATE_FLOORCHANGE)
        or tile:hasFlag(TILESTATE_BLOCKSOLID)
        or tile:hasFlag(TILESTATE_BLOCKPATH)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKSOLID)
        or tile:hasFlag(TILESTATE_IMMOVABLEBLOCKPATH)
        or tile:getTopCreature() then
        return false
    end

    return queryTileAddThing(creature:getId(), position) == RETURNVALUE_NOERROR
end

function RiftstepGem_findSafePosition(player, minDistance, maxDistance)
    local center = player and player:getPosition()
    if not center then
        return nil
    end

    local candidates = {}
    for dx = -maxDistance, maxDistance do
        for dy = -maxDistance, maxDistance do
            local distance = math.max(math.abs(dx), math.abs(dy))
            if distance >= minDistance and distance <= maxDistance and not (dx == 0 and dy == 0) then
                local candidate = Position(center.x + dx, center.y + dy, center.z)
                if RiftstepGem_isSafePosition(player, candidate) then
                    candidates[#candidates + 1] = candidate
                end
            end
        end
    end

    if #candidates == 0 then
        return nil
    end

    return candidates[math.random(#candidates)]
end

function RiftstepGem_runRiftPulse(positionData, damage, remainingTicks)
    local special = GemsSocket_getSpecialConfig("riftstep") or {}
    local scarItemId = tonumber(special.scarItemId) or 0
    local pulseEffect = special.riftPulseEffect or CONST_ME_PURPLEENERGY
    local radius = math.max(0, tonumber(special.riftRadius) or 1)
    local position = Position(positionData.x, positionData.y, positionData.z)

    if remainingTicks <= 0 then
        if scarItemId > 0 then
            local tileItem = GemsSocket_findTileItemById(position, scarItemId)
            if tileItem then
                tileItem:remove()
            end
        end
        return
    end

    local tileItem = nil
    if scarItemId > 0 then
        tileItem = GemsSocket_findTileItemById(position, scarItemId)
        if not tileItem then
            return
        end
    end

    position:sendMagicEffect(pulseEffect)
    for _, creature in ipairs(Game.getSpectators(position, false, false, radius, radius, radius, radius) or {}) do
        if creature:isMonster() and not creature:getMaster() then
            doTargetCombatHealth(0, creature, COMBAT_ENERGYDAMAGE, -damage, -damage, pulseEffect)
        end
    end

    addEvent(RiftstepGem_runRiftPulse, 1000, positionData, damage, remainingTicks - 1)
end

function RiftstepGem_spawnRift(player, position)
    if not player or not position then
        return
    end

    local special = GemsSocket_getSpecialConfig("riftstep") or {}
    local scarItemId = tonumber(special.scarItemId) or 0
    local damage = math.max(0, getEquippedSocketBonusTotal(player, "socket_riftstep_rift_damage"))
    local duration = math.max(1, GemsSocket_getEquippedSocketBonusMax(player, "socket_riftstep_rift_duration"))
    if damage <= 0 then
        return
    end

    if scarItemId > 0 then
        local existing = GemsSocket_findTileItemById(position, scarItemId)
        if existing then
            existing:remove()
        end

        local rift = Game.createItem(scarItemId, 1, position)
        if rift then
            rift:setCustomAttribute("socket_owner_id", player:getId())
        end
    end

    position:sendMagicEffect(special.riftSpawnEffect or special.riftPulseEffect or CONST_ME_PURPLEENERGY)
    addEvent(RiftstepGem_runRiftPulse, 0, { x = position.x, y = position.y, z = position.z }, damage, duration)
end

function RiftstepGem_trigger(player, incomingDamage, bonusCache)
    if not player or incomingDamage <= 0 then
        return false
    end

    local maximums = bonusCache and bonusCache.maximums or {}
    local thresholdBonus = tonumber(maximums.socket_riftstep_threshold) or 0
    local cooldownBonus = tonumber(maximums.socket_riftstep_cooldown) or 0
    local minDistanceBonus = tonumber(maximums.socket_riftstep_min_distance) or 0
    local maxDistanceBonus = tonumber(maximums.socket_riftstep_max_distance) or 0

    if thresholdBonus <= 0 or cooldownBonus <= 0 or minDistanceBonus <= 0 or maxDistanceBonus <= 0 then
        return false
    end

    local state = RiftstepGem_getState(player)
    if not state then
        return false
    end

    local now = os.time()
    local cooldown = math.max(1, cooldownBonus)
    if now < state.cooldownUntil then
        return false
    end

    local threshold = math.max(1, thresholdBonus)
    local currentHealth = math.max(0, player:getHealth())
    local maxHealth = math.max(1, player:getMaxHealth())
    local healthAfter = math.max(0, currentHealth - incomingDamage)
    local healthPercentAfter = (healthAfter / maxHealth) * 100
    if healthPercentAfter > threshold then
        return false
    end

    local minDistance = math.max(1, minDistanceBonus)
    local maxDistance = math.max(minDistance, maxDistanceBonus)
    local originPosition = player:getPosition()
    local safePosition = RiftstepGem_findSafePosition(player, minDistance, maxDistance)
    if not safePosition then
        return false
    end

    state.cooldownUntil = now + cooldown
    local special = GemsSocket_getSpecialConfig("riftstep") or {}
    player:teleportTo(safePosition, true)
    safePosition:sendMagicEffect(special.teleportEffect or CONST_ME_TELEPORT)
    RiftstepGem_spawnRift(player, originPosition)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.message or "Riftstep Gem tears space open and pulls you to safety.")
    return true
end

function SiphonBloom_getState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = siphonBloomState[playerId]
    if not state then
        state = {
            cooldownUntil = 0,
        }
        siphonBloomState[playerId] = state
    end

    return state
end

function SiphonBloom_getKey(ownerId, positionData)
    return string.format("%d:%d:%d:%d", ownerId, positionData.x, positionData.y, positionData.z)
end

function SiphonBloom_isSamePosition(first, second)
    return first and second and first.x == second.x and first.y == second.y and first.z == second.z
end

function SiphonBloom_consume(player, bloom)
    if not player or not player:isPlayer() or type(bloom) ~= "table" then
        return false
    end

    local healthAmount = getSocketScaledAmount(player:getMaxHealth(), bloom.healthPercent or 0)
    local manaAmount = getSocketScaledAmount(player:getMaxMana(), bloom.manaPercent or 0)
    if healthAmount > 0 then
        player:addHealth("healing", healthAmount)
    end
    if manaAmount > 0 then
        player:addMana(manaAmount)
    end

    local special = GemsSocket_getSpecialConfig("siphonBloom") or {}
    player:getPosition():sendMagicEffect(special.consumeEffect or CONST_ME_MAGIC_GREEN)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.message or "Siphon Bloom restores your vitality.")
    return true
end

function SiphonBloom_pulse(key)
    local bloom = siphonBloomActive[key]
    if type(bloom) ~= "table" then
        return
    end

    local now = os.time()
    local position = Position(bloom.position.x, bloom.position.y, bloom.position.z)
    local special = GemsSocket_getSpecialConfig("siphonBloom") or {}
    if now >= bloom.expiresAt then
        siphonBloomActive[key] = nil
        position:sendMagicEffect(special.expireEffect or CONST_ME_POFF)
        return
    end

    position:sendMagicEffect(special.pulseEffect or special.spawnEffect or CONST_ME_MAGIC_GREEN)

    local player = Player(bloom.ownerId)
    if player and player:isPlayer() and SiphonBloom_isSamePosition(player:getPosition(), position) then
        siphonBloomActive[key] = nil
        SiphonBloom_consume(player, bloom)
        return
    end

    addEvent(SiphonBloom_pulse, math.max(250, tonumber(special.pulseIntervalMs) or 1000), key)
end

function SiphonBloom_tryCreate(player, targetPosition)
    if not player or not targetPosition then
        return false
    end

    local state = SiphonBloom_getState(player)
    if not state then
        return false
    end

    local now = os.time()
    local cooldown = math.max(1, GemsSocket_getEquippedSocketBonusMax(player, "socket_bloom_cooldown"))
    if now < state.cooldownUntil then
        return false
    end

    local healPercent = math.max(0, getEquippedSocketBonusTotal(player, "socket_bloom_health_percent"))
    local manaPercent = math.max(0, getEquippedSocketBonusTotal(player, "socket_bloom_mana_percent"))
    if healPercent <= 0 and manaPercent <= 0 then
        return false
    end

    local special = GemsSocket_getSpecialConfig("siphonBloom") or {}
    local durationMs = math.max(1000, tonumber(special.durationMs) or 5000)

    state.cooldownUntil = now + cooldown
    local positionData = { x = targetPosition.x, y = targetPosition.y, z = targetPosition.z }
    local key = SiphonBloom_getKey(player:getId(), positionData)
    siphonBloomActive[key] = {
        ownerId = player:getId(),
        position = positionData,
        healthPercent = healPercent,
        manaPercent = manaPercent,
        expiresAt = now + math.ceil(durationMs / 1000),
    }

    targetPosition:sendMagicEffect(special.spawnEffect or CONST_ME_MAGIC_GREEN)
    addEvent(SiphonBloom_pulse, math.max(250, tonumber(special.pulseIntervalMs) or 1000), key)
    return true
end

function GemsSocket_onSiphonBloomStepIn(player, item, position, fromPosition)
    local special = GemsSocket_getSpecialConfig("siphonBloom") or {}
    local bloomItemId = tonumber(special.bloomItemId) or 0
    if bloomItemId <= 0 or not player or not player:isPlayer() or not item or item:getId() ~= bloomItemId then
        return true
    end

    local ownerId = tonumber(item:getCustomAttribute("socket_owner_id")) or 0
    local expiresAt = tonumber(item:getCustomAttribute("socket_expires_at")) or 0
    if ownerId ~= player:getId() or (expiresAt > 0 and os.time() > expiresAt) then
        return true
    end

    local healthPercent = math.max(0, tonumber(item:getCustomAttribute("socket_health_percent")) or 0)
    local manaPercent = math.max(0, tonumber(item:getCustomAttribute("socket_mana_percent")) or 0)
    local healthAmount = getSocketScaledAmount(player:getMaxHealth(), healthPercent)
    local manaAmount = getSocketScaledAmount(player:getMaxMana(), manaPercent)
    if healthAmount > 0 then
        player:addHealth("healing", healthAmount)
    end
    if manaAmount > 0 then
        player:addMana(manaAmount)
    end
    player:getPosition():sendMagicEffect(special.consumeEffect or CONST_ME_MAGIC_GREEN)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.message or "Siphon Bloom restores your vitality.")
    item:remove()
    return true
end

function PhoenixGem_getPlayerState(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = phoenixReviveState[playerId]
    if not state then
        state = {
            invincibleUntil = 0,
        }
        phoenixReviveState[playerId] = state
    end

    return state
end

function PhoenixGem_finishRevive(playerId, expectedUntil)
    local player = Player(playerId)
    if not player then
        return
    end

    local special = GemsSocket_getSpecialConfig("phoenix") or {}
    local state = PhoenixGem_getPlayerState(player)
    if not state or state.invincibleUntil ~= expectedUntil then
        return
    end

    local missingHealth = math.max(0, player:getMaxHealth() - player:getHealth())
    local missingMana = math.max(0, player:getMaxMana() - player:getMana())
    if missingHealth > 0 then
        player:addHealth("healing", missingHealth)
    end
    if missingMana > 0 then
        player:addMana(missingMana)
    end
    player:getPosition():sendMagicEffect(special.restoreEffect or CONST_ME_HOLYAREA)
end

function PhoenixGem_trigger(player, incomingDamage)
    if not player or incomingDamage <= 0 then
        return false
    end

    local currentHealth = math.max(0, player:getHealth())
    if incomingDamage < currentHealth then
        return false
    end

    if not PhoenixGem.consumeCharge(player) then
        return false
    end

    local state = PhoenixGem_getPlayerState(player)
    local special = GemsSocket_getSpecialConfig("phoenix") or {}
    if state then
        state.invincibleUntil = os.time() + math.max(1, tonumber(special.invulnerabilitySeconds) or 1)
    end

    local allowedDamage = math.max(0, currentHealth - 1)
    addEvent(PhoenixGem_finishRevive, math.max(1, tonumber(special.reviveDelayMs) or 100), player:getId(), state and state.invincibleUntil or 0)
    player:getPosition():sendMagicEffect(special.triggerEffect or CONST_ME_HOLYDAMAGE)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.reviveMessage or "Phoenix Gem saves you from death and restores your strength.")
    return allowedDamage
end

local function createFireDamageCondition(totalDamage)
    totalDamage = math.max(1, tonumber(totalDamage) or 0)
    local tickDamage = math.max(1, math.floor(totalDamage / 3))
    local condition = Condition(CONDITION_FIRE)
    condition:setParameter(CONDITION_PARAM_DELAYED, true)
    condition:addDamage(3, 2000, -tickDamage)
    return condition
end

local function createPoisonDamageCondition(totalDamage)
    totalDamage = math.max(1, tonumber(totalDamage) or 0)
    local condition = Condition(CONDITION_POISON)
    condition:setParameter(CONDITION_PARAM_DELAYED, true)
    condition:addDamage(6, 1000, -totalDamage)
    return condition
end

local function runFearStep(targetId)
    if not isCreature(targetId) then
        return
    end

    local cpos = getCreaturePosition(targetId)
    local dir = {}
    if cpos and queryTileAddThing(targetId, {x = cpos.x, y = cpos.y - 1, z = cpos.z}) == RETURNVALUE_NOERROR and not Tile({x = cpos.x, y = cpos.y - 1, z = cpos.z}):hasFlag(TILESTATE_PROTECTIONZONE) then
        table.insert(dir, NORTH)
    end
    if cpos and queryTileAddThing(targetId, {x = cpos.x - 1, y = cpos.y, z = cpos.z}) == RETURNVALUE_NOERROR and not Tile({x = cpos.x - 1, y = cpos.y, z = cpos.z}):hasFlag(TILESTATE_PROTECTIONZONE) then
        table.insert(dir, WEST)
    end
    if cpos and queryTileAddThing(targetId, {x = cpos.x, y = cpos.y + 1, z = cpos.z}) == RETURNVALUE_NOERROR and not Tile({x = cpos.x, y = cpos.y + 1, z = cpos.z}):hasFlag(TILESTATE_PROTECTIONZONE) then
        table.insert(dir, SOUTH)
    end
    if cpos and queryTileAddThing(targetId, {x = cpos.x + 1, y = cpos.y, z = cpos.z}) == RETURNVALUE_NOERROR and not Tile({x = cpos.x + 1, y = cpos.y, z = cpos.z}):hasFlag(TILESTATE_PROTECTIONZONE) then
        table.insert(dir, EAST)
    end

    if #dir > 0 then
        doMoveCreature(targetId, dir[math.random(1, #dir)])
    end

    local targetPos = getCreaturePosition(targetId)
    if targetPos then
        SendMagicEffect(targetPos, 217)
    end
end

local function runSpiritstonePulse(playerId, expectedActiveUntil)
    local player = Player(playerId)
    if not player then
        return
    end

    local state = spiritstoneState[playerId]
    if not state or state.activeUntil ~= expectedActiveUntil or os.time() > state.activeUntil then
        return
    end

    local healthGain = math.max(0, tonumber(state.healthGain) or 0)
    local manaGain = math.max(0, tonumber(state.manaGain) or 0)
    if healthGain > 0 then
        player:addHealth("healing", healthGain)
    end
    if manaGain > 0 then
        player:addMana(manaGain)
    end
    if healthGain > 0 or manaGain > 0 then
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end
end

local function releaseBindstoneTarget(targetId, expectedUntil)
    local target = Monster(targetId)
    if not target then
        bindstoneTargetState[targetId] = nil
        return
    end

    local state = bindstoneTargetState[targetId]
    if not state or state.activeUntil ~= expectedUntil or os.time() < expectedUntil then
        return
    end

    target:setNoMove(false)
    bindstoneTargetState[targetId] = nil
end

local function removeBoonstoneSpeed(playerId, expectedUntil, speedDelta)
    local player = Player(playerId)
    if not player then
        return
    end

    local state = boonstoneState[playerId]
    if not state or state.activeUntil ~= expectedUntil or state.speedDelta ~= speedDelta or speedDelta <= 0 then
        return
    end

    player:changeSpeed(-speedDelta)
    state.speedDelta = 0
end

local function pullCreatureTowardPosition(targetId, centerPosition)
    if not isCreature(targetId) or not centerPosition then
        return
    end

    local currentPosition = getCreaturePosition(targetId)
    if not currentPosition then
        return
    end

    local dir = nil
    if currentPosition.x < centerPosition.x then
        dir = EAST
    elseif currentPosition.x > centerPosition.x then
        dir = WEST
    elseif currentPosition.y < centerPosition.y then
        dir = SOUTH
    elseif currentPosition.y > centerPosition.y then
        dir = NORTH
    end

    if dir then
        doMoveCreature(targetId, dir)
    end
end

local function runVoidstonePulse(playerId, targetId, expectedActiveUntil)
    local player = Player(playerId)
    local target = Monster(targetId)
    if not player or not target then
        return
    end

    local state = voidstoneState[playerId]
    if not state or state.activeUntil ~= expectedActiveUntil or state.targetId ~= targetId or os.time() > state.activeUntil then
        return
    end

    target:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
end

local buildSocketParalyzeCondition

local function runGravitystonePulse(playerId, centerPositionData, damagePerPulse, expectedActiveUntil)
    local player = Player(playerId)
    if not player or not centerPositionData then
        return
    end

    if os.time() > expectedActiveUntil then
        return
    end

    local centerPosition = Position(centerPositionData.x, centerPositionData.y, centerPositionData.z)
    centerPosition:sendMagicEffect(CONST_ME_MORTAREA)
    for _, monster in ipairs(getNearbyMonsters(centerPosition, 1)) do
        local targetId = monster:getId()
        doTargetCombatHealth(player, monster, COMBAT_EARTHDAMAGE, -damagePerPulse, -damagePerPulse, CONST_ME_SMALLPLANTS)
        local slowCondition = buildSocketParalyzeCondition(60, 1)
        if slowCondition then
            monster:addCondition(slowCondition)
        end
        if targetId and targetId > 0 then
            pullCreatureTowardPosition(targetId, centerPosition)
        end
    end
end

local function runAscendancePulse(playerId, expectedActiveUntil)
    local player = Player(playerId)
    if not player then
        return
    end

    local state = ascendanceState[playerId]
    if not state or state.activeUntil ~= expectedActiveUntil or os.time() > state.activeUntil then
        return
    end

    local blastDamage = math.max(1, tonumber(state.blastDamage) or 0)
    local nearbyMonsters = getNearbyMonsters(player:getPosition(), SOCKET_ASCENDANCE_RANGE)
    if #nearbyMonsters == 0 or blastDamage <= 0 then
        return
    end

    for _ = 1, 3 do
        local target = nearbyMonsters[math.random(#nearbyMonsters)]
        if target then
            doTargetCombatHealth(player, target, COMBAT_ARCANEDAMAGE, -blastDamage, -blastDamage, CONST_ME_PURPLEENERGY)
        end
    end
end

local function triggerAscendance(player, totalDamage, totals)
    local chance = totals.socket_ascendance_chance or 0
    local dodgeBonus = totals.socket_ascendance_dodge or 0
    local blastPercent = totals.socket_ascendance_blast_percent or 0
    if chance <= 0 or dodgeBonus <= 0 or blastPercent <= 0 or totalDamage <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getAscendanceState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_ASCENDANCE_DURATION
    state.cooldownUntil = now + SOCKET_ASCENDANCE_COOLDOWN
    state.dodgeBonus = dodgeBonus
    state.blastDamage = getSocketScaledAmount(totalDamage, blastPercent)
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_ascendance_chance", "socket_ascendance_dodge", "socket_ascendance_blast_percent" }, CONST_ME_MAGIC_BLUE))

    local playerId = player:getId()
    local expectedActiveUntil = state.activeUntil
    addEvent(runAscendancePulse, 0, playerId, expectedActiveUntil)
    addEvent(runAscendancePulse, 2000, playerId, expectedActiveUntil)
    addEvent(runAscendancePulse, 4000, playerId, expectedActiveUntil)
end

local function tryTriggerBindstone(player, target, totals)
    if not target or not target:isMonster() then
        return
    end

    local chance = totals.socket_bindstone_chance or 0
    local duration = math.max(0, totals.socket_bindstone_duration or 0)
    if chance <= 0 or duration <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getBindstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    local targetId = target:getId()
    if not targetId or targetId <= 0 then
        return
    end

    state.cooldownUntil = now + SOCKET_BINDSTONE_COOLDOWN
    local expectedUntil = now + duration
    bindstoneTargetState[targetId] = { activeUntil = expectedUntil }
    target:setNoMove(true)
    target:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_bindstone_chance", "socket_bindstone_duration" }, CONST_ME_STONES))
    addEvent(releaseBindstoneTarget, duration * 1000, targetId, expectedUntil)
end

local function tryTriggerSurgestone(player, target, totalDamage, totals)
    if totalDamage <= 0 or not target or not target:isMonster() then
        return
    end

    local chance = totals.socket_surgestone_chance or 0
    local damagePercent = totals.socket_surgestone_percent or 0
    if chance <= 0 or damagePercent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getSurgestoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    local chainDamage = getSocketScaledAmount(totalDamage, damagePercent)
    if chainDamage <= 0 then
        return
    end

    local nearbyMonsters = getNearbyMonsters(target:getPosition(), SOCKET_SURGESTONE_RANGE)
    local chainedTargets = {}
    for _, monster in ipairs(nearbyMonsters) do
        if monster ~= target then
            chainedTargets[#chainedTargets + 1] = monster
        end
    end

    if #chainedTargets == 0 then
        return
    end

    state.cooldownUntil = now + SOCKET_SURGESTONE_COOLDOWN
    target:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_surgestone_chance", "socket_surgestone_percent" }, CONST_ME_ENERGYAREA))

    local chainCount = math.min(SOCKET_SURGESTONE_TARGETS, #chainedTargets)
    for i = 1, chainCount do
        local index = math.random(#chainedTargets)
        local chainedTarget = table.remove(chainedTargets, index)
        if chainedTarget then
            doTargetCombatHealth(player, chainedTarget, COMBAT_ENERGYDAMAGE, -chainDamage, -chainDamage, CONST_ME_ENERGYHIT)
        end
    end
end

local function tryTriggerVoltstone(player, target, totalDamage, totals)
    if totalDamage <= 0 or not target or not target:isMonster() then
        return
    end

    local chance = tonumber(totals.socket_voltstone_chance) or 0
    local damagePercent = tonumber(totals.socket_voltstone_percent) or 0
    if chance <= 0 or damagePercent <= 0 then
        return
    end

    local state = getVoltstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < (state.cooldownUntil or 0) then
        return
    end

    if not rollSocketChance(chance) then
        return
    end

    local burstDamage = getSocketScaledAmount(totalDamage, damagePercent)
    if burstDamage <= 0 then
        return
    end

    state.cooldownUntil = now + SOCKET_VOLTSTONE_COOLDOWN

    local center = target:getPosition()
    if not center then
        return
    end

    local triggerEffect = getEquippedSocketTriggerEffect(player, { "socket_voltstone_chance", "socket_voltstone_percent" }, CONST_ME_ENERGYAREA)

    for dx = -1, 1 do
        for dy = -1, 1 do
            local pos = Position(center.x + dx, center.y + dy, center.z)
            pos:sendMagicEffect(triggerEffect)
        end
    end

    for _, monster in ipairs(getNearbyMonsters(center, 1)) do
        if monster and monster:isMonster() and not monster:getMaster() then
            doTargetCombatHealth(player, monster, COMBAT_ENERGYDAMAGE, -burstDamage, -burstDamage, CONST_ME_ENERGYHIT)
        end
    end
end

local function runEmberstonePulse(playerId, expectedActiveUntil)
    local player = Player(playerId)
    if not player then
        return
    end

    local state = emberstoneState[playerId]
    if not state or state.activeUntil ~= expectedActiveUntil or os.time() > state.activeUntil then
        return
    end

    local nearbyMonsters = getNearbyMonsters(player:getPosition(), SOCKET_EMBERSTONE_RANGE)
    if #nearbyMonsters == 0 then
        return
    end

    local target = nearbyMonsters[math.random(#nearbyMonsters)]
    if not target then
        return
    end

    local explosionDamage = math.max(1, tonumber(state.explosionDamage) or 0)
    local burnDamage = math.max(1, tonumber(state.burnDamage) or 0)
    doTargetCombatHealth(player, target, COMBAT_FIREDAMAGE, -explosionDamage, -explosionDamage, CONST_ME_EXPLOSIONHIT)
    local condition = createFireDamageCondition(burnDamage)
    if condition then
        target:addCondition(condition)
    end
end

local function tryTriggerEmberstone(player, totalDamage, totals)
    if totalDamage <= 0 then
        return
    end

    local chance = totals.socket_emberstone_chance or 0
    local damagePercent = totals.socket_emberstone_percent or 0
    local burnPercent = totals.socket_emberstone_burn_percent or 0
    if chance <= 0 or damagePercent <= 0 or burnPercent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getEmberstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_EMBERSTONE_DURATION
    state.cooldownUntil = now + SOCKET_EMBERSTONE_COOLDOWN
    state.explosionDamage = getSocketScaledAmount(totalDamage, damagePercent)
    state.burnDamage = getSocketScaledAmount(totalDamage, burnPercent)
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_emberstone_chance", "socket_emberstone_percent", "socket_emberstone_burn_percent" }, CONST_ME_FIREAREA))

    local playerId = player:getId()
    local expectedActiveUntil = state.activeUntil
    addEvent(runEmberstonePulse, 0, playerId, expectedActiveUntil)
    addEvent(runEmberstonePulse, 2000, playerId, expectedActiveUntil)
    addEvent(runEmberstonePulse, 4000, playerId, expectedActiveUntil)
end

local function tryTriggerSpellfury(player, totalDamage, origin, totals)
    if totalDamage <= 0 or not isSocketSpellOrigin(origin) then
        return
    end

    local chance = totals.socket_spellfury_chance or 0
    local bonusPercent = totals.socket_spellfury_percent or 0
    if chance <= 0 or bonusPercent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getSpellfuryState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_SPELLFURY_DURATION
    state.cooldownUntil = now + SOCKET_SPELLFURY_COOLDOWN
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_spellfury_chance", "socket_spellfury_percent" }, CONST_ME_PURPLEENERGY))
end

local function tryTriggerWarstone(player, totals)
    local chance = totals.socket_warstone_chance or 0
    local damageBonus = totals.socket_warstone_percent or 0
    if chance <= 0 or damageBonus <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getWarstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_WARSTONE_DURATION
    state.cooldownUntil = now + SOCKET_WARSTONE_COOLDOWN
    state.damageBonus = damageBonus
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_warstone_chance", "socket_warstone_percent" }, CONST_ME_DRAWBLOOD))
end

local function tryTriggerBoonstone(player)
    local chance = getEquippedSocketBonusTotal(player, "socket_boonstone_chance")
    local speedPercent = getEquippedSocketBonusTotal(player, "socket_boonstone_speed_percent")
    local damageBonus = getEquippedSocketBonusTotal(player, "socket_boonstone_damage_percent")
    if chance <= 0 or speedPercent <= 0 or damageBonus <= 0 or not rollSocketChance(chance) then
        return false
    end

    local state = getBoonstoneState(player)
    if not state then
        return false
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return false
    end

    local currentSpeed = math.max(0, tonumber(player:getSpeed()) or 0)
    local speedDelta = math.max(1, math.floor(currentSpeed * (speedPercent / 100)))
    state.activeUntil = now + SOCKET_BOONSTONE_DURATION
    state.cooldownUntil = now + SOCKET_BOONSTONE_COOLDOWN
    state.damageBonus = damageBonus
    state.speedDelta = speedDelta

    if speedDelta > 0 then
        player:changeSpeed(speedDelta)
        addEvent(removeBoonstoneSpeed, SOCKET_BOONSTONE_DURATION * 1000, player:getId(), state.activeUntil, speedDelta)
    end

    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_boonstone_chance", "socket_boonstone_speed_percent", "socket_boonstone_damage_percent" }, CONST_ME_HOLYAREA))
    return true
end

local function tryTriggerVenomstone(player, attacker, totals)
    if not attacker or not attacker:isCreature() then
        return
    end

    local chance = totals.socket_venomstone_chance or 0
    local percent = totals.socket_venomstone_percent or 0
    if chance <= 0 or percent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getVenomstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    local poisonDamage = getSocketScaledAmount(attacker:getMaxHealth(), percent)
    if poisonDamage <= 0 then
        return
    end

    state.cooldownUntil = now + SOCKET_VENOMSTONE_COOLDOWN
    local condition = createPoisonDamageCondition(poisonDamage)
    if condition then
        attacker:addCondition(condition)
        attacker:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_venomstone_chance", "socket_venomstone_percent" }, CONST_ME_POISONAREA))
    end
end

local function tryTriggerDreadstone(player, totals)
    local chance = totals.socket_dreadstone_chance or 0
    local duration = math.max(0, totals.socket_dreadstone_duration or 0)
    if chance <= 0 or duration <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getDreadstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    local nearbyMonsters = getNearbyMonsters(player:getPosition(), 2)
    if #nearbyMonsters == 0 then
        return
    end

    state.cooldownUntil = now + SOCKET_DREADSTONE_COOLDOWN
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_dreadstone_chance", "socket_dreadstone_duration" }, 217))
    for _, monster in ipairs(nearbyMonsters) do
        local monsterId = monster:getId()
        if monsterId and monsterId > 0 then
            for step = 0, (duration * 2) - 1 do
                addEvent(runFearStep, step * 500, monsterId)
            end
        end
    end
end

local function tryTriggerSpiritstone(player, totals)
    local chance = totals.socket_spiritstone_chance or 0
    local healthGain = math.max(0, totals.socket_spiritstone_health or 0)
    local manaGain = math.max(0, totals.socket_spiritstone_mana or 0)
    if chance <= 0 or (healthGain <= 0 and manaGain <= 0) or not rollSocketChance(chance) then
        return
    end

    local state = getSpiritstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_SPIRITSTONE_DURATION
    state.cooldownUntil = now + SOCKET_SPIRITSTONE_COOLDOWN
    state.healthGain = healthGain
    state.manaGain = manaGain
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_spiritstone_chance", "socket_spiritstone_health", "socket_spiritstone_mana" }, CONST_ME_MAGIC_GREEN))

    local expectedActiveUntil = state.activeUntil
    local playerId = player:getId()
    for tick = 0, SOCKET_SPIRITSTONE_DURATION - 1 do
        addEvent(runSpiritstonePulse, tick * 1000, playerId, expectedActiveUntil)
    end
end

local function tryTriggerVoidstone(player, target, totals)
    if not target or not target:isMonster() then
        return
    end

    local chance = totals.socket_voidstone_chance or 0
    local percent = totals.socket_voidstone_percent or 0
    if chance <= 0 or percent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getVoidstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_VOIDSTONE_DURATION
    state.cooldownUntil = now + SOCKET_VOIDSTONE_COOLDOWN
    state.targetId = target:getId()
    state.vulnerabilityPercent = percent
    target:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_voidstone_chance", "socket_voidstone_percent" }, CONST_ME_PURPLEENERGY))

    local expectedActiveUntil = state.activeUntil
    local playerId = player:getId()
    local targetId = state.targetId
    for tick = 0, SOCKET_VOIDSTONE_DURATION - 1 do
        addEvent(runVoidstonePulse, tick * 1000, playerId, targetId, expectedActiveUntil)
    end
end

local function tryTriggerGravitystone(player, target, totalDamage, totals)
    if totalDamage <= 0 or not target or not target:isMonster() then
        return
    end

    local chance = totals.socket_gravitystone_chance or 0
    local percent = totals.socket_gravitystone_percent or 0
    if chance <= 0 or percent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getGravitystoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    local damagePerPulse = getSocketScaledAmount(totalDamage, percent)
    if damagePerPulse <= 0 then
        return
    end

    state.cooldownUntil = now + SOCKET_GRAVITYSTONE_COOLDOWN
    local centerPosition = target:getPosition()
    centerPosition:sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_gravitystone_chance", "socket_gravitystone_percent" }, CONST_ME_MORTAREA))
    local expectedActiveUntil = now + SOCKET_GRAVITYSTONE_DURATION
    local playerId = player:getId()
    local centerPositionData = { x = centerPosition.x, y = centerPosition.y, z = centerPosition.z }
    for tick = 0, SOCKET_GRAVITYSTONE_DURATION - 1 do
        addEvent(runGravitystonePulse, tick * 1000, playerId, centerPositionData, damagePerPulse, expectedActiveUntil)
    end
end

local function tryTriggerChronostone(player, totals)
    local chance = totals.socket_chronostone_chance or 0
    local percent = totals.socket_chronostone_percent or 0
    if chance <= 0 or percent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getChronostoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_CHRONOSTONE_DURATION
    state.cooldownUntil = now + SOCKET_CHRONOSTONE_COOLDOWN
    state.reductionPercent = percent
    player:setStorageValue(SOCKET_CHRONOSTONE_STORAGE_UNTIL, state.activeUntil)
    player:setStorageValue(SOCKET_CHRONOSTONE_STORAGE_PERCENT, percent)
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_chronostone_chance", "socket_chronostone_percent" }, CONST_ME_HOLYDAMAGE))
end

function tryTriggerMarksmanstone(player, target, totalDamage, totals)
    if not target or not target:isMonster() or totalDamage <= 0 then
        return
    end

    local chance = totals.socket_marksmanstone_chance or 0
    if chance <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getMarksmanstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.cooldownUntil = now + SOCKET_MARKSMANSTONE_COOLDOWN
    doTargetCombatHealth(player, target, COMBAT_PHYSICALDAMAGE, -totalDamage, -totalDamage, CONST_ME_HITAREA)
    player:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_SIMPLEARROW)
end

function tryTriggerBattlestone(player)
    local chance = getEquippedSocketBonusTotal(player, "socket_battlestone_chance")
    if chance <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getBattlestoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.cooldownUntil = now + SOCKET_BATTLESTONE_COOLDOWN
    state.activeUntil = now + 3
    state.pending = true
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, "socket_battlestone_chance", CONST_ME_CRITICAL_DAMAGE))
end

function tryTriggerArcanestone(player, manaCost)
    if manaCost <= 0 then
        return
    end

    local chance = getEquippedSocketBonusTotal(player, "socket_arcanestone_chance")
    if chance <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getArcanestoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.cooldownUntil = now + SOCKET_ARCANESTONE_COOLDOWN
    local triggerEffect = getEquippedSocketTriggerEffect(player, "socket_arcanestone_chance", CONST_ME_MAGIC_BLUE)
    addEvent(function(playerId, amount)
        local target = Player(playerId)
        if not target then
            return
        end
        target:addMana(amount)
        target:getPosition():sendMagicEffect(triggerEffect)
    end, 100, player:getId(), manaCost)
    player:getPosition():sendMagicEffect(triggerEffect)
end

function tryTriggerMendstone(player)
    local chance = getEquippedSocketBonusTotal(player, "socket_mendstone_chance")
    if chance <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getMendstoneState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_MENDSTONE_DURATION
    state.cooldownUntil = now + SOCKET_MENDSTONE_COOLDOWN
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, "socket_mendstone_chance", CONST_ME_MAGIC_GREEN))
end

function runTotemGemPulse(playerId, expectedActiveUntil)
    local owner = Player(playerId)
    local state = totemGemState[playerId]
    if not state then
        return
    end

    if not owner or not state.position then
        clearTotemVisual(state)
        return
    end

    if state.activeUntil ~= expectedActiveUntil or os.time() > state.activeUntil then
        clearTotemVisual(state)
        return
    end

    local center = Position(state.position.x, state.position.y, state.position.z)
    local power = math.max(1, tonumber(state.power) or 0)
    local kind = tostring(state.kind or "")

    if kind == "fire" then
        center:sendMagicEffect(CONST_ME_FIREAREA)
        for _, monster in ipairs(getNearbyMonsters(center, SOCKET_TOTEM_RANGE)) do
            doTargetCombatHealth(owner, monster, COMBAT_FIREDAMAGE, -power, -power, CONST_ME_HITBYFIRE)
        end
    elseif kind == "healing" then
        center:sendMagicEffect(CONST_ME_MAGIC_GREEN)
        for _, member in ipairs(getPartyPlayersInRange(owner, SOCKET_TOTEM_RANGE)) do
            if member:getPosition():getDistance(center) <= SOCKET_TOTEM_RANGE then
                member:addHealth("healing", power)
            end
        end
    elseif kind == "storm" then
        center:sendMagicEffect(CONST_ME_ENERGYAREA)
        local chained = 0
        for _, monster in ipairs(getNearbyMonsters(center, SOCKET_TOTEM_RANGE + 1)) do
            doTargetCombatHealth(owner, monster, COMBAT_ENERGYDAMAGE, -power, -power, CONST_ME_ENERGYHIT)
            chained = chained + 1
            if chained >= 3 then
                break
            end
        end
    elseif kind == "protection" then
        center:sendMagicEffect(CONST_ME_HOLYAREA)
    end

    if os.time() >= state.activeUntil then
        clearTotemVisual(state)
    end
end

function tryTriggerTotemGem(player, totalDamage, totals)
    if totalDamage <= 0 then
        return
    end

    local chance = totals.socket_totem_chance or 0
    local powerPercent = totals.socket_totem_power or 0
    if chance <= 0 or powerPercent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getTotemGemState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    local gemData = GemsSocket.GEMS.totemgem
    local kinds = { "fire", "healing", "storm", "protection" }
    local kind = kinds[math.random(#kinds)]
    local itemId = gemData and gemData.totems and gemData.totems[kind] and tonumber(gemData.totems[kind].itemId) or 0
    local position = player:getPosition()
    if not position then
        return
    end

    clearTotemVisual(state)
    state.activeUntil = now + SOCKET_TOTEM_DURATION
    state.cooldownUntil = now + SOCKET_TOTEM_COOLDOWN
    state.kind = kind
    state.power = math.max(1, getSocketScaledAmount(totalDamage, powerPercent))
    state.bonusPercent = powerPercent
    state.position = { x = position.x, y = position.y, z = position.z }
    state.visualItem = nil
    if itemId and itemId > 0 then
        state.visualItem = Game.createItem(itemId, 1, position)
    end

    position:sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_totem_chance", "socket_totem_power" }, CONST_ME_MAGIC_BLUE))
    local expectedActiveUntil = state.activeUntil
    for tick = 0, SOCKET_TOTEM_DURATION / 2 do
        addEvent(runTotemGemPulse, tick * 2000, player:getId(), expectedActiveUntil)
    end
    addEvent(function(playerId, expectedUntil)
        local state = totemGemState[playerId]
        if not state or state.activeUntil ~= expectedUntil then
            return
        end
        clearTotemVisual(state)
    end, SOCKET_TOTEM_DURATION * 1000 + 100, player:getId(), expectedActiveUntil)
end

function applySacredLinkParryShield(player)
    local state = getSacredLinkState(player)
    if not state or os.time() > state.activeUntil then
        return
    end

    state.shieldUntil = os.time() + 2
    local triggerEffect = getEquippedSocketTriggerEffect(player, { "socket_sacred_link_chance", "socket_sacred_link_redirect", "socket_sacred_link_resistance", "socket_sacred_link_shield" }, CONST_ME_HOLYAREA)
    player:getPosition():sendMagicEffect(triggerEffect)
    for _, member in ipairs(getPartyPlayersInRange(player, SOCKET_SACRED_LINK_RANGE)) do
        if member ~= player then
            member:getPosition():sendMagicEffect(triggerEffect)
        end
    end
end

function tryTriggerSacredLink(player, totals)
    local chance = totals.socket_sacred_link_chance or 0
    local redirectPercent = totals.socket_sacred_link_redirect or 0
    local resistancePercent = totals.socket_sacred_link_resistance or 0
    local shieldPercent = totals.socket_sacred_link_shield or 0
    if chance <= 0 or redirectPercent <= 0 or resistancePercent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getSacredLinkState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    if not player:getParty() then
        return
    end

    state.activeUntil = now + SOCKET_SACRED_LINK_DURATION
    state.cooldownUntil = now + SOCKET_SACRED_LINK_COOLDOWN
    state.redirectPercent = redirectPercent
    state.resistancePercent = resistancePercent
    state.shieldPercent = math.max(0, tonumber(shieldPercent) or 0)
    state.shieldUntil = 0
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_sacred_link_chance", "socket_sacred_link_redirect", "socket_sacred_link_resistance", "socket_sacred_link_shield" }, CONST_ME_HOLYAREA))
end

function findSacredLinkHolderForPlayer(player)
    if not player or not player:isPlayer() then
        return nil, nil
    end

    for playerId, state in pairs(sacredLinkState) do
        if state and os.time() <= state.activeUntil then
            local holder = Player(playerId)
            if holder and holder ~= player and arePartyLinkedPlayers(holder, player) then
                local holderPosition = holder:getPosition()
                local playerPosition = player:getPosition()
                if holderPosition and playerPosition and holderPosition:getDistance(playerPosition) <= SOCKET_SACRED_LINK_RANGE then
                    return holder, state
                end
            end
        end
    end

    return nil, nil
end

function getProtectionTotemReduction(player)
    if not player or not player:isPlayer() then
        return 0
    end

    local highestReduction = 0
    local playerPosition = player:getPosition()
    if not playerPosition then
        return 0
    end

    for ownerId, state in pairs(totemGemState) do
        if state and state.kind == "protection" and state.position and os.time() <= state.activeUntil then
            local owner = Player(ownerId)
            if owner and arePartyLinkedPlayers(owner, player) then
                local center = Position(state.position.x, state.position.y, state.position.z)
                if playerPosition:getDistance(center) <= SOCKET_TOTEM_RANGE then
                    highestReduction = math.max(highestReduction, math.max(0, tonumber(state.bonusPercent) or 0))
                end
            end
        end
    end

    return highestReduction
end

function runReversalRelease(playerId, expectedActiveUntil)
    local player = Player(playerId)
    local state = reversalState[playerId]
    if not player or not state or state.activeUntil ~= expectedActiveUntil then
        return
    end

    if state.storedHealing > 0 then
        player:addHealth("healing", state.storedHealing)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end

    state.storedHealing = 0
    state.storePercent = 0
    state.holyPercent = 0
end

function tryTriggerReversal(player, totals)
    local chance = totals.socket_reversal_chance or 0
    local storePercent = totals.socket_reversal_store or 0
    local holyPercent = totals.socket_reversal_holy or 0
    if chance <= 0 or storePercent <= 0 or holyPercent <= 0 or not rollSocketChance(chance) then
        return
    end

    local state = getReversalState(player)
    if not state then
        return
    end

    local now = os.time()
    if now < state.cooldownUntil then
        return
    end

    state.activeUntil = now + SOCKET_REVERSAL_DURATION
    state.cooldownUntil = now + SOCKET_REVERSAL_COOLDOWN
    state.storedHealing = 0
    state.storePercent = storePercent
    state.holyPercent = holyPercent
    player:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(player, { "socket_reversal_chance", "socket_reversal_store", "socket_reversal_holy" }, CONST_ME_HOLYDAMAGE))
    addEvent(runReversalRelease, SOCKET_REVERSAL_DURATION * 1000, player:getId(), state.activeUntil)
end

function GemsSocket_onPlayerSpellCast(player, spellName, spellGroup, aggressive, manaCost)
    if not player or not player:isPlayer() then
        return
    end

    spellGroup = tostring(spellGroup or ""):lower()
    local isAttackSpell = aggressive and spellGroup == "attack"
    local isHealingSpell = spellGroup == "healing"

    if isAttackSpell then
        tryTriggerBattlestone(player)
        tryTriggerArcanestone(player, math.max(0, tonumber(manaCost) or 0))
    end

    if isHealingSpell then
        tryTriggerMendstone(player)
    end

    if type(_G.GemsSocket_advancedOnSpellCast) == "function" then
        _G.GemsSocket_advancedOnSpellCast(player, spellName, spellGroup, aggressive, manaCost)
    end
end

buildSocketParalyzeCondition = function(speedPercent, durationSeconds)
    local slowPercent = math.abs(tonumber(speedPercent) or 0)
    local duration = math.max(1, tonumber(durationSeconds) or 0)
    if slowPercent <= 0 then
        return nil
    end

    local condition = Condition(CONDITION_PARALYZE)
    condition:setParameter(CONDITION_PARAM_TICKS, duration * 1000)
    local minSpeed = -slowPercent / 100
    local maxSpeed = -slowPercent / 100
    condition:setFormula(minSpeed, 0, maxSpeed, 0)
    return condition
end

local function clearSocketBonusAttributes(item)
    GemsSocketBonusCache.clearItemBonusAttributes(item)
end

local function recomputeSocketBonuses(item)
    GemsSocketBonusCache.bumpMetric("item_recomputes")

    local totals = {}
    for index = 1, getSocketCount(item) do
        local gemKey = getSocketGemKey(item, index)
        local _, levelData = getGemLevelData(gemKey, getSocketGemLevel(item, index))
        if levelData and type(levelData.bonuses) == "table" then
            for bonusKey, amount in pairs(levelData.bonuses) do
                totals[bonusKey] = (totals[bonusKey] or 0) + amount
            end
        end

        if type(_G.LivingGem) == "table" and _G.LivingGem.isGem and _G.LivingGem.isGem(gemKey) and _G.LivingGem.addBonuses then
            _G.LivingGem.addBonuses(item, index, totals)
        end

        if ChronicleGem.isGem(gemKey) then
            ChronicleGem.addBonuses(item, index, totals)
        end

        if type(_G.GravediggerGem) == "table" and _G.GravediggerGem.isGem and _G.GravediggerGem.isGem(gemKey) and _G.GravediggerGem.addBonuses then
            _G.GravediggerGem.addBonuses(item, index, totals)
        end
    end

    for bonusKey, amount in pairs(totals) do
        if tonumber(amount) == 0 then
            totals[bonusKey] = nil
        end
    end

    GemsSocketBonusCache.replaceItemBonusAttributes(item, totals)
    GemsSocketBonusCache.invalidateItemOwner(item)
end

local function getEquipmentMask()
    return bit.bor(
        SLOTP_HEAD,
        SLOTP_NECKLACE,
        SLOTP_ARMOR,
        SLOTP_RIGHT,
        SLOTP_LEFT,
        SLOTP_LEGS,
        SLOTP_FEET,
        SLOTP_RING,
        SLOTP_AMMO,
        SLOTP_BADGE,
        SLOTP_GLOVES,
        SLOTP_BELT
    )
end

local EQUIPMENT_MASK = getEquipmentMask()
local GEM_SLOT_ALIASES = {
    head = "helmet",
    helmet = "helmet",
    helmets = "helmet",
    armor = "armor",
    armors = "armor",
    legs = "legs",
    boots = "boots",
    feet = "boots",
    gloves = "gloves",
    belt = "belt",
    ring = "ring",
    rings = "ring",
    necklace = "necklace",
    necklaces = "necklace",
    shield = "shield",
    shields = "shield",
    ammo = "ammo",
    badge = "badge",
    badges = "badge",
    wand = "wand",
    wands = "wand",
    weapon = "weapon",
    weapons = "weapon",
}
local function normalizeGemSlotName(slotName)
    if type(slotName) ~= "string" then
        return nil
    end

    local lowered = slotName:lower()
    return GEM_SLOT_ALIASES[lowered] or lowered
end

local function getItemSlotInfo(item)
    if not item or not item:isItem() then
        return nil
    end

    local itemType = item:getType()
    if not itemType then
        return nil
    end

    local slotPosition = itemType:getSlotPosition() or 0
    local weaponType = itemType:getWeaponType() or WEAPON_NONE
    local isHandSlot = bit.band(slotPosition, SLOTP_LEFT) ~= 0 or bit.band(slotPosition, SLOTP_RIGHT) ~= 0
    local attack = itemType:getAttack() or 0
    local defense = itemType:getDefense() or 0

    return {
        slotPosition = slotPosition,
        weaponType = weaponType,
        isHandSlot = isHandSlot,
        attack = attack,
        defense = defense,
    }
end

local function itemMatchesSlotCategory(item, slotName)
    local info = getItemSlotInfo(item)
    if not info then
        return false
    end

    if slotName == "helmet" then
        return bit.band(info.slotPosition, SLOTP_HEAD) ~= 0
    elseif slotName == "necklace" then
        return bit.band(info.slotPosition, SLOTP_NECKLACE) ~= 0
    elseif slotName == "armor" then
        return bit.band(info.slotPosition, SLOTP_ARMOR) ~= 0
    elseif slotName == "legs" then
        return bit.band(info.slotPosition, SLOTP_LEGS) ~= 0
    elseif slotName == "boots" then
        return bit.band(info.slotPosition, SLOTP_FEET) ~= 0
    elseif slotName == "ring" then
        return bit.band(info.slotPosition, SLOTP_RING) ~= 0
    elseif slotName == "ammo" then
        return bit.band(info.slotPosition, SLOTP_AMMO) ~= 0
    elseif slotName == "badge" then
        return bit.band(info.slotPosition, SLOTP_BADGE) ~= 0
    elseif slotName == "gloves" then
        return bit.band(info.slotPosition, SLOTP_GLOVES) ~= 0
    elseif slotName == "belt" then
        return bit.band(info.slotPosition, SLOTP_BELT) ~= 0
    elseif slotName == "shield" then
        return info.weaponType == WEAPON_SHIELD or (info.weaponType == WEAPON_NONE and info.isHandSlot and info.attack <= 0 and info.defense > 0)
    elseif slotName == "wand" then
        return info.weaponType == WEAPON_WAND
    elseif slotName == "weapon" then
        return info.weaponType ~= WEAPON_NONE and info.weaponType ~= WEAPON_SHIELD and info.weaponType ~= WEAPON_AMMO
    end

    return false
end

local function getGemAllowedSlots(gemData)
    local normalized = {}
    if type(gemData) ~= "table" or type(gemData.slots) ~= "table" then
        return normalized
    end

    for _, slotName in ipairs(gemData.slots) do
        local normalizedName = normalizeGemSlotName(slotName)
        if normalizedName then
            normalized[#normalized + 1] = normalizedName
        end
    end

    return normalized
end

local function isGemAllowedForItem(gemData, item)
    if type(gemData) == "table" and gemData.nonSocketable then
        return false
    end

    local allowedSlots = getGemAllowedSlots(gemData)
    if #allowedSlots == 0 then
        return true
    end

    for _, slotName in ipairs(allowedSlots) do
        if itemMatchesSlotCategory(item, slotName) then
            return true
        end
    end

    return false
end

local function formatGemAllowedSlots(gemData)
    local labels = {}
    local seen = {}
    local slotLabels = {
        helmet = "Helmet",
        armor = "Armor",
        legs = "Legs",
        boots = "Boots",
        ring = "Ring",
        necklace = "Necklace",
        shield = "Shield",
        weapon = "Weapon",
        wand = "Wand",
        belt = "Belt",
        gloves = "Gloves",
        badge = "Badge",
        ammo = "Ammo",
    }
    for _, slotName in ipairs(getGemAllowedSlots(gemData)) do
        if not seen[slotName] then
            seen[slotName] = true
            labels[#labels + 1] = slotLabels[slotName] or slotName
        end
    end

    return table.concat(labels, ", ")
end

local function getGemInvalidSlotText(gemData)
    local allowedSlotsText = formatGemAllowedSlots(gemData)
    if allowedSlotsText ~= "" then
        return string.format("Only for: %s", allowedSlotsText)
    end
    return "Not valid for this item"
end

local function isSocketableItemId(itemId)
    local itemType = ItemType(itemId)
    if not itemType then
        return false
    end

    local slotPosition = itemType:getSlotPosition() or 0
    if slotPosition == 0 then
        return false
    end

    return bit.band(slotPosition, EQUIPMENT_MASK) ~= 0
end

local function isSocketableItem(item)
    if not item or not item:isItem() then
        return false
    end

    local itemType = item:getType()
    if not itemType then
        return false
    end

    local slotPosition = itemType:getSlotPosition() or 0
    if slotPosition == 0 then
        return false
    end

    return bit.band(slotPosition, EQUIPMENT_MASK) ~= 0
end

local function ensureSocketableMetadata(item)
    if not isSocketableItem(item) then
        return false
    end

    local configuredSocketCount = getConfiguredSocketCount(item:getId())
    if configuredSocketCount <= 0 then
        return false
    end

    local currentSocketCount = getSocketCount(item)
    if currentSocketCount < configuredSocketCount then
        setSocketCount(item, configuredSocketCount)
        refreshSocketItem(item)
        return true
    end

    if tonumber(item:getCustomAttribute("socket_enabled") or 0) ~= 1 then
        item:setCustomAttribute("socket_enabled", 1)
        refreshSocketItem(item)
    end

    if hasSockets(item) and item:getCustomAttribute("socket_bonus_keys") == nil then
        refreshSocketItem(item)
    end

    return hasSockets(item)
end

local function ensureSocketableTree(item)
    if not item or not item:isItem() then
        return false
    end

    ensureGemItemMetadata(item)
    local changed = ensureSocketableMetadata(item)
    local container = Container(item:getUniqueId())
    if not container then
        return changed
    end

    for _, child in ipairs(container:getItems(true) or {}) do
        ensureGemItemMetadata(child)
        if ensureSocketableMetadata(child) then
            changed = true
        end
    end

    return changed
end

local function initializePlayerSocketableItems(player)
    if not player then
        return
    end

    for slot = CONST_SLOT_HEAD, CONST_SLOT_STORE_INBOX do
        local item = player:getSlotItem(slot)
        if item then
            ensureSocketableTree(item)
            if hasSockets(item) and item:getCustomAttribute("socket_bonus_keys") == nil then
                refreshSocketItem(item)
            end
        end
    end

    local index = 0
    while true do
        local container = player:getContainerById(index)
        if not container then
            break
        end

        for _, item in ipairs(container:getItems(true) or {}) do
            ensureGemItemMetadata(item)
            ensureSocketableMetadata(item)
        end
        index = index + 1
    end
end

local function isBackpackTarget(target)
    if type(target) ~= "table" or type(target.position) ~= "table" then
        return false
    end

    local position = target.position
    return position.x == CONTAINER_POSITION and bit.band(tonumber(position.y) or 0, 0x40) ~= 0
end

local function getTargetItem(player, target)
    if type(target) ~= "table" then
        return nil
    end

    local uid = tonumber(target.uid) or 0
    if uid > 0 then
        local item = player:getItem(uid)
        if item and item:isItem() then
            return item
        end
    end

    local position = target.position
    if type(position) ~= "table" then
        return nil
    end

    local item = player:getItem({
        x = tonumber(position.x) or 0,
        y = tonumber(position.y) or 0,
        z = tonumber(position.z) or 0,
        stackpos = tonumber(position.stackpos) or 0,
    })
    if not item or not item:isItem() then
        return nil
    end

    return item
end

local function setSelectedTarget(player, item)
    if not player then
        return
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return
    end

    if item and item:isItem() then
        selectedTargets[playerId] = {
            uid = item:getRealUID(),
        }
    else
        selectedTargets[playerId] = nil
    end
end

local function getSelectedTargetItem(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local targetData = selectedTargets[playerId]
    if not targetData then
        return nil
    end

    local uid = tonumber(targetData.uid) or 0
    if uid <= 0 then
        selectedTargets[playerId] = nil
        return nil
    end

    local item = player:getItem(uid)
    if not item or not item:isItem() then
        selectedTargets[playerId] = nil
        return nil
    end

    return item
end

local function resolveActionTarget(player, target)
    local item = getSelectedTargetItem(player)
    local requestedUid = type(target) == "table" and tonumber(target.uid) or 0

    if requestedUid > 0 then
        if item and item:getRealUID() == requestedUid then
            return item
        end

        local requestedItem = getTargetItem(player, target)
        if requestedItem and requestedItem:isItem() then
            setSelectedTarget(player, requestedItem)
            return requestedItem
        end

        return item
    end

    local requestedItem = getTargetItem(player, target)
    if requestedItem and requestedItem:isItem() then
        setSelectedTarget(player, requestedItem)
        return requestedItem
    end

    return item
end

local function buildTargetReference(item)
    if not item then
        return nil
    end

    local position = item:getPosition()
    if not position then
        return nil
    end

    return {
        position = {
            x = position.x,
            y = position.y,
            z = position.z,
            stackpos = type(item.getStackPos) == "function" and item:getStackPos() or 0,
        }
    }
end

local function buildPanelTargetReference(item, target)
    local source = type(target) == "table" and target or buildTargetReference(item)
    local position = source and source.position
    if type(position) ~= "table" then
        return nil
    end

    return {
        position = {
            x = position.x,
            y = position.y,
            z = position.z,
            stackpos = tonumber(position.stackpos) or 0,
        }
    }
end

refreshSocketItem = function(item)
    if item and item.isItem and item:isItem() and hasSockets(item) then
        recomputeSocketBonuses(item)
    end

    if item and type(item.refresh) == "function" then
        item:refresh()
    end
end

function GemsSocket_refreshSocketDisplay(item)
    GemsSocketBonusCache.queueDisplayRefresh(item, 250)
end

local function serializeGem(gemKey)
    local gemData = GemsSocket.GEMS[gemKey]
    if not gemData then
        return nil
    end

    return {
        key = gemKey,
        itemId = gemData.itemId,
        clientId = ItemType(gemData.itemId):getClientId(),
        name = gemData.name,
        tooltip = gemData.tooltip,
        bestFor = compact and nil or gemData.bestFor,
        style = compact and nil or gemData.style,
    }
end

local function compactGemText(text, maxLength, maxLines)
    text = tostring(text or "")
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    maxLength = maxLength or 120
    maxLines = maxLines or 1

    local lines = {}
    for line in text:gmatch("([^\n]+)") do
        if line ~= "" then
            lines[#lines + 1] = line
            if #lines >= maxLines then
                break
            end
        end
    end

    local compact = table.concat(lines, "\n")
    if #compact > maxLength then
        compact = compact:sub(1, maxLength - 3) .. "..."
    end
    return compact
end

function GemsSocket_serializeGemCatalogEntry(gemKey, compact)
    local gemData = GemsSocket.GEMS[gemKey]
    if not gemData then
        return nil
    end

    local itemType = ItemType(gemData.itemId)
    local tiers = {}
    local maxLevel = getGemMaxLevel(gemData)
    for level = 1, maxLevel do
        local _, levelData = getGemLevelData(gemKey, level)
        if levelData then
            tiers[#tiers + 1] = {
                level = level,
                name = levelData.name or gemData.name,
                tooltip = compact and compactGemText(levelData.tooltip or gemData.tooltip, 120, 1) or (levelData.tooltip or gemData.tooltip or ""),
            }
        end
    end

    return {
        key = gemKey,
        itemId = gemData.itemId,
        clientId = itemType and itemType:getClientId() or 0,
        itemName = itemType and itemType:getName() or gemData.name,
        name = gemData.name,
        tooltip = compact and compactGemText(gemData.tooltip, 120, 1) or (gemData.tooltip or ""),
        bestFor = gemData.bestFor,
        style = gemData.style,
        nonSocketable = gemData.nonSocketable == true,
        uniquePerItem = gemData.uniquePerItem == true,
        uniqueEquipped = gemData.uniqueEquipped == true,
        tiers = tiers,
    }
end

function GemsSocket_getGemCatalog(compact)
    local catalog = {}
    for gemKey in pairs(GemsSocket.GEMS) do
        local entry = GemsSocket_serializeGemCatalogEntry(gemKey, compact)
        if entry then
            catalog[#catalog + 1] = entry
        end
    end

    table.sort(catalog, function(left, right)
        return tostring(left.name or left.key):lower() < tostring(right.name or right.key):lower()
    end)
    return catalog
end

function GemsSocket_getCompactGemCatalog()
    return GemsSocket_getGemCatalog(true)
end

function GemsSocket_getCompactGemCatalogPage(page, pageSize, searchText)
    page = math.max(1, toNumber(page, 1))
    pageSize = math.max(1, math.min(24, toNumber(pageSize, 6)))
    searchText = tostring(searchText or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

    local catalog = GemsSocket_getCompactGemCatalog()
    if searchText ~= "" then
        local filtered = {}
        for _, entry in ipairs(catalog) do
            local haystack = string.format("%s %s", tostring(entry.name or ""), tostring(entry.itemName or "")):lower()
            if haystack:find(searchText, 1, true) then
                filtered[#filtered + 1] = entry
            end
        end
        catalog = filtered
    end

    local total = #catalog
    local pageCount = math.max(1, math.ceil(total / pageSize))
    page = math.max(1, math.min(page, pageCount))

    local entries = {}
    local firstIndex = ((page - 1) * pageSize) + 1
    local lastIndex = math.min(total, firstIndex + pageSize - 1)
    for index = firstIndex, lastIndex do
        entries[#entries + 1] = catalog[index]
    end

    return {
        catalog = entries,
        page = page,
        pageCount = pageCount,
        total = total,
        search = searchText,
    }
end

function GemsSocket_paginateGemEntries(entries, page, pageSize)
    entries = entries or {}
    page = math.max(1, toNumber(page, 1))
    pageSize = math.max(1, math.min(24, toNumber(pageSize, 7)))

    local total = #entries
    local pageCount = math.max(1, math.ceil(total / pageSize))
    page = math.max(1, math.min(page, pageCount))

    local pagedEntries = {}
    local firstIndex = ((page - 1) * pageSize) + 1
    local lastIndex = math.min(total, firstIndex + pageSize - 1)
    for index = firstIndex, lastIndex do
        pagedEntries[#pagedEntries + 1] = entries[index]
    end

    return pagedEntries, page, pageCount, total
end

local function serializeSocketedGem(gemKey, level)
    local gemData, levelData, maxLevel = getGemLevelData(gemKey, level)
    if not gemData or not levelData then
        return nil
    end

    return {
        key = gemKey,
        itemId = gemData.itemId,
        clientId = ItemType(gemData.itemId):getClientId(),
        name = levelData.name or gemData.name,
        tooltip = levelData.tooltip or gemData.tooltip,
        bestFor = levelData.bestFor or gemData.bestFor,
        style = levelData.style or gemData.style,
        level = math.max(1, toNumber(level, 1)),
        maxLevel = maxLevel,
        canUpgrade = math.max(1, toNumber(level, 1)) < maxLevel,
    }
end

local function serializeSocketedGemForItem(item, socketIndex, player)
    local gemKey = getSocketGemKey(item, socketIndex)
    local gemLevel = getSocketGemLevel(item, socketIndex)
    local entry = gemKey and serializeSocketedGem(gemKey, gemLevel) or nil
    if not entry then
        return nil
    end

    entry.tooltip = GemsSocket_buildSpecialGemTooltip(gemKey, entry.tooltip, item, socketIndex, gemLevel)
    entry.compactTooltip = GemsSocket_buildSpecialGemCompactTooltip(gemKey, entry.tooltip, item, socketIndex, gemLevel, player)

    return entry
end

local function serializeSockets(item, player)
    local sockets = {}
    local socketCount = getSocketCount(item)
    for index = 1, socketCount do
        local gemKey = getSocketGemKey(item, index)
        local gemLevel = getSocketGemLevel(item, index)
        local gemData = gemKey and GemsSocket.GEMS[gemKey] or nil
        if gemData then
            setSocketGemDisplayData(item, index, gemData, player)
        end
        sockets[#sockets + 1] = {
            index = index,
            empty = gemKey == nil,
            gem = gemKey and serializeSocketedGemForItem(item, index, player) or nil,
        }
    end
    return sockets
end

local function serializeForgeRequirements(player, requirements)
    local entries = {}
    for _, requirement in ipairs(requirements or {}) do
        local itemId = tonumber(requirement.id) or 0
        local requiredCount = math.max(1, tonumber(requirement.count) or 1)
        local itemType = ItemType(itemId)
        entries[#entries + 1] = {
            itemId = itemId,
            clientId = itemType and itemType:getClientId() or 0,
            name = itemType and itemType:getName() or ("Item " .. itemId),
            required = requiredCount,
            owned = player and player:getItemCount(itemId) or 0,
        }
    end
    return entries
end

local function getNextTierRequirements(levelData)
    if type(levelData) ~= "table" then
        return nil
    end

    if type(levelData.upgrade) == "table" and type(levelData.upgrade.items) == "table" then
        return levelData.upgrade.items
    end

    if type(levelData.upgrade) == "table" and #levelData.upgrade > 0 then
        return levelData.upgrade
    end

    if type(levelData.items) == "table" then
        return levelData.items
    end

    return levelData.requirements
end

local function buildForgeData(player, item)
    local forgeSockets = {}

    for _, socketData in ipairs(serializeSockets(item, player)) do
        local forgeSocket = {
            index = socketData.index,
            empty = socketData.empty,
            gem = socketData.gem,
            nextLevel = nil,
            forgeable = false,
        }

        if socketData.gem then
            local gemKey = socketData.gem.key
            local currentLevel = socketData.gem.level or getSocketGemLevel(item, socketData.index)
            local gemData, levelData, maxLevel = getGemLevelData(gemKey, currentLevel)
            local isForgeable = gemData and type(gemData.tiers) == "table" and maxLevel > 1
            local canUpgrade = isForgeable and currentLevel < maxLevel

            forgeSocket.forgeable = isForgeable == true

            if canUpgrade then
                local nextLevel = currentLevel + 1
                local _, nextLevelData = getGemLevelData(gemKey, nextLevel)
                local requirements = serializeForgeRequirements(player, getNextTierRequirements(levelData))
                local hasMaterials = true

                for _, requirement in ipairs(requirements) do
                    if requirement.owned < requirement.required then
                        hasMaterials = false
                        break
                    end
                end

                forgeSocket.nextLevel = {
                    level = nextLevel,
                    name = nextLevelData and nextLevelData.name or gemData.name,
                    tooltip = nextLevelData and nextLevelData.tooltip or gemData.tooltip,
                    bestFor = nextLevelData and (nextLevelData.bestFor or gemData.bestFor) or gemData.bestFor,
                    style = nextLevelData and (nextLevelData.style or gemData.style) or gemData.style,
                    requirements = requirements,
                    canUpgrade = hasMaterials,
                }
            end
        end

        forgeSockets[#forgeSockets + 1] = forgeSocket
    end

    return {
        sockets = forgeSockets,
    }
end

local function getEssenceOutputItemId()
    return GemsSocket.ESSENCE and tonumber(GemsSocket.ESSENCE.outputItemId) or 30658
end

getGemEssencePower = function(gemData, level)
    level = math.max(1, toNumber(level, 1))
    if gemData and type(gemData.essencePower) == "table" then
        return math.max(1, toNumber(gemData.essencePower[level], gemData.essencePower[1] or 1))
    end

    local levelPower = GemsSocket.ESSENCE and GemsSocket.ESSENCE.levelPower or nil
    if type(levelPower) == "table" then
        return math.max(1, toNumber(levelPower[level], levelPower[1] or 1))
    end

    return level
end

local function buildEssenceData(item, player)
    local outputItemId = getEssenceOutputItemId()
    local outputItemType = ItemType(outputItemId)
    local essenceSockets = {}

    for _, socketData in ipairs(serializeSockets(item, player)) do
        local entry = {
            index = socketData.index,
            empty = socketData.empty,
            gem = socketData.gem,
            power = 0,
        }

        if socketData.gem then
            local gemData = GemsSocket.GEMS[socketData.gem.key]
            entry.power = getGemEssencePower(gemData, socketData.gem.level)
        end

        essenceSockets[#essenceSockets + 1] = entry
    end

    return {
        outputItemId = outputItemId,
        outputClientId = outputItemType and outputItemType:getClientId() or 0,
        outputName = outputItemType and outputItemType:getName() or "Gem Power",
        sockets = essenceSockets,
    }
end

local function forEachOwnedItem(player, callback)
    if not player or type(callback) ~= "function" then
        return
    end

    local visited = {}

    local function visitItem(item)
        if not item or not item:isItem() then
            return
        end

        local uid = tonumber(item:getUniqueId()) or 0
        if uid > 0 then
            if visited[uid] then
                return
            end
            visited[uid] = true
        end

        callback(item)

        -- Inventory gems can live in nested backpacks or in other currently open containers.
        -- Walk both the equipped item tree and the player's open container list, deduping by uid.
        local container = item:isContainer() and item or Container(item:getUniqueId())
        if not container then
            return
        end

        local childItems = container:getItems(true) or {}
        for _, child in ipairs(childItems) do
            visitItem(child)
        end
    end

    for slot = CONST_SLOT_HEAD, CONST_SLOT_STORE_INBOX do
        local item = player:getSlotItem(slot)
        if item then
            visitItem(item)
        end
    end

    for index = 0, 15 do
        local container = player:getContainerById(index)
        if container then
            local openItems = container:getItems(true) or {}
            for _, item in ipairs(openItems) do
                visitItem(item)
            end
        end
    end
end

local function collectInventoryGemEntries(player, item)
    buildGemIndexes()
    local grouped = {}

    forEachOwnedItem(player, function(ownedItem)
        local itemId = ownedItem and ownedItem:getId() or 0
        if not (GemsSocket.gemsByItemId and GemsSocket.gemsByItemId[itemId]) then
            return
        end
        ensureGemItemMetadata(ownedItem)

        local gemKey = ownedItem:getCustomAttribute("gem_key")
        local gemData = gemKey and GemsSocket.GEMS[gemKey]
        if not gemData or gemData.excludeFromInventoryPanels then
            return
        end

        local gemLevel = getGemItemLevel(ownedItem)
        local _, levelData, maxLevel = getGemLevelData(gemKey, gemLevel)
        local allowed = item and isGemAllowedForItem(gemData, item) or true
        local count = math.max(1, tonumber(ownedItem:getCount()) or 1)
        local specialState = GemsSocket_readSpecialGemState(ownedItem, nil, gemKey)
        local gemTooltip = GemsSocket_buildSpecialGemTooltip(gemKey, (levelData and levelData.tooltip) or gemData.tooltip, ownedItem, nil, gemLevel)
        local groupKey = string.format("%s|%d", gemKey, gemLevel)
        if specialState then
            groupKey = string.format("%s|%d|%s", gemKey, gemLevel, gemTooltip)
        end
        local entry = grouped[groupKey]

        if not entry then
            entry = {
                key = gemKey,
                itemId = gemData.itemId,
                clientId = ItemType(gemData.itemId):getClientId(),
                name = (levelData and levelData.name) or gemData.name,
                tooltip = gemTooltip,
                level = gemLevel,
                maxLevel = maxLevel,
                count = 0,
                essencePower = getGemEssencePower(gemData, gemLevel),
                allowed = allowed,
                invalidText = allowed and nil or getGemInvalidSlotText(gemData),
            }
            grouped[groupKey] = entry
        else
            entry.allowed = entry.allowed or allowed
            if entry.allowed then
                entry.invalidText = nil
            end
        end

        entry.count = entry.count + count
    end)

    local gems = {}
    for _, entry in pairs(grouped) do
        gems[#gems + 1] = entry
    end

    if #gems == 0 then
        for gemKey, gemData in pairs(GemsSocket.GEMS) do
            if gemData and not gemData.excludeFromInventoryPanels then
                local count = math.max(0, tonumber(player:getItemCount(gemData.itemId)) or 0)
                if count > 0 then
                    local _, levelData, maxLevel = getGemLevelData(gemKey, 1)
                    local allowed = item and isGemAllowedForItem(gemData, item) or true
                    gems[#gems + 1] = {
                        key = gemKey,
                        itemId = gemData.itemId,
                        clientId = ItemType(gemData.itemId):getClientId(),
                        name = (levelData and levelData.name) or gemData.name,
                        tooltip = GemsSocket_buildSpecialGemTooltip(gemKey, (levelData and levelData.tooltip) or gemData.tooltip, nil, nil, 1),
                        level = 1,
                        maxLevel = maxLevel,
                        count = count,
                        essencePower = getGemEssencePower(gemData, 1),
                        allowed = allowed,
                        invalidText = allowed and nil or getGemInvalidSlotText(gemData),
                    }
                end
            end
        end
    end
    table.sort(gems, function(a, b)
        if a.allowed ~= b.allowed then
            return a.allowed and not b.allowed
        end
        if a.level ~= b.level then
            return a.level > b.level
        end
        if a.name ~= b.name then
            return a.name < b.name
        end
        return a.count > b.count
    end)

    return gems
end

local function getAvailableGems(player, item)
    local gems = {}
    for gemKey, gemData in pairs(GemsSocket.GEMS) do
        local allowed = true
        if item then
            allowed = isGemAllowedForItem(gemData, item)
        end
        gems[#gems + 1] = {
            key = gemKey,
            itemId = gemData.itemId,
            clientId = ItemType(gemData.itemId):getClientId(),
            name = gemData.name,
            tooltip = compactGemText(gemData.tooltip, 120, 2),
            count = player:getItemCount(gemData.itemId),
            essencePower = getGemEssencePower(gemData, 1),
            allowed = allowed,
            invalidText = allowed and nil or getGemInvalidSlotText(gemData),
        }
    end

    table.sort(gems, function(a, b)
        if a.allowed ~= b.allowed then
            return a.allowed and not b.allowed
        end
        if a.count == b.count then
            return a.name < b.name
        end
        return a.count > b.count
    end)

    return gems
end

local function getInventoryGemCountByLevel(player, gemKey, level)
    level = math.max(1, tonumber(level) or 1)
    local total = 0
    forEachOwnedItem(player, function(ownedItem)
        local itemId = ownedItem and ownedItem:getId() or 0
        if not (GemsSocket.gemsByItemId and GemsSocket.gemsByItemId[itemId]) then
            return
        end
        ensureGemItemMetadata(ownedItem)

        if ownedItem:getCustomAttribute("gem_key") ~= gemKey then
            return
        end

        if getGemItemLevel(ownedItem) ~= level then
            return
        end

        total = total + math.max(1, tonumber(ownedItem:getCount()) or 1)
    end)

    if total == 0 and level == 1 then
        local gemData = GemsSocket.GEMS[gemKey]
        if gemData then
            total = math.max(0, tonumber(player:getItemCount(gemData.itemId)) or 0)
        end
    end

    return total
end

local function removeInventoryGemsByLevel(player, gemKey, level, amount)
    amount = math.max(1, tonumber(amount) or 1)
    level = math.max(1, tonumber(level) or 1)

    if getInventoryGemCountByLevel(player, gemKey, level) < amount then
        return false
    end

    local remaining = amount
    forEachOwnedItem(player, function(ownedItem)
        if remaining <= 0 then
            return
        end
        local itemId = ownedItem and ownedItem:getId() or 0
        if not (GemsSocket.gemsByItemId and GemsSocket.gemsByItemId[itemId]) then
            return
        end
        ensureGemItemMetadata(ownedItem)

        if ownedItem:getCustomAttribute("gem_key") ~= gemKey or getGemItemLevel(ownedItem) ~= level then
            return
        end

        local removeCount = math.min(remaining, math.max(1, tonumber(ownedItem:getCount()) or 1))
        if removeCount > 0 then
            ownedItem:remove(removeCount)
            remaining = remaining - removeCount
        end
    end)

    if remaining > 0 and level == 1 then
        local gemData = GemsSocket.GEMS[gemKey]
        if gemData and player:removeItem(gemData.itemId, remaining, -1, true) then
            remaining = 0
        end
    end

    return remaining <= 0
end

local function getFusionCandidates(level)
    local candidates = {}
    level = math.max(1, tonumber(level) or 1)
    for gemKey, gemData in pairs(GemsSocket.GEMS) do
        if getGemMaxLevel(gemData) >= level then
            candidates[#candidates + 1] = gemKey
        end
    end
    return candidates
end

local function buildPanelData(player, item, target)
    local itemType = item:getType()
    return {
        target = buildPanelTargetReference(item, target),
        itemId = item:getId(),
        clientId = itemType:getClientId(),
        name = itemType:getName(),
        socketCount = getSocketCount(item),
        sockets = serializeSockets(item, player),
        availableGems = nil,
    }
end

local function sendChunkedPayload(player, payload)
    local buffer = json.encode(payload)
    local parts = {}

    for i = 1, #buffer, EXTENDED_OPCODE_CHUNK_SIZE do
        parts[#parts + 1] = buffer:sub(i, i + EXTENDED_OPCODE_CHUNK_SIZE - 1)
    end

    if #parts <= 1 then
        player:sendExtendedOpcode(GemsSocket.OPCODE, buffer)
        return
    end

    player:sendExtendedOpcode(GemsSocket.OPCODE, "S" .. parts[1])
    for i = 2, #parts - 1 do
        player:sendExtendedOpcode(GemsSocket.OPCODE, "P" .. parts[i])
    end
    player:sendExtendedOpcode(GemsSocket.OPCODE, "E" .. parts[#parts])
end

local function sendPanelData(player, item, target, mode, gemsPage, gemsPageSize, showAllGems)
    mode = tostring(mode or "socket")
    local panelData = buildPanelData(player, item, target)
    panelData.forge = buildForgeData(player, item)

    if mode == "fusion" or mode == "extract" then
        panelData.availableGems = {}
        panelData.inventoryGems = collectInventoryGemEntries(player, nil)
    else
        local availableGems
        if showAllGems then
            availableGems = getAvailableGems(player, item)
        else
            availableGems = getAvailableGems(player, item)
            local allowedGems = {}
            for _, entry in ipairs(availableGems) do
                if entry.allowed ~= false then
                    allowedGems[#allowedGems + 1] = entry
                end
            end
            availableGems = allowedGems
        end

        local pagedGems, page, pageCount, total = GemsSocket_paginateGemEntries(availableGems, gemsPage, gemsPageSize)
        panelData.availableGems = pagedGems
        panelData.availableGemsPage = page
        panelData.availableGemsPageCount = pageCount
        panelData.availableGemsTotal = total
    end

    sendChunkedPayload(player, {
        action = "panel",
        data = panelData,
    })
end

local function sendInventoryEssencePanelData(player)
    local outputItemId = getEssenceOutputItemId()
    local outputItemType = ItemType(outputItemId)
    local inventoryGems = collectInventoryGemEntries(player, nil)

    sendChunkedPayload(player, {
        action = "inventory_essence_panel",
        data = {
            inventoryGems = inventoryGems,
            essence = {
                outputItemId = outputItemId,
                outputClientId = outputItemType and outputItemType:getClientId() or 0,
                outputName = outputItemType and outputItemType:getName() or "Gem Power",
            }
        }
    })
end

function GemsSocket_sendGemCatalogPage(player, page, pageSize, searchText)
    sendChunkedPayload(player, {
        action = "gem_catalog_page",
        data = GemsSocket_getCompactGemCatalogPage(page, pageSize, searchText),
    })
end

local function sendMessage(player, messageType, message)
    sendChunkedPayload(player, {
        action = "message",
        data = {
            type = messageType,
            message = message,
        }
    })
end

local function sendFusionResult(player, gemKey, level)
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not player or not gemData then
        return
    end

    local _, levelData, maxLevel = getGemLevelData(gemKey, level)
    sendChunkedPayload(player, {
        action = "fusion_result",
        data = {
            result = {
                key = gemKey,
                itemId = gemData.itemId,
                clientId = ItemType(gemData.itemId):getClientId(),
                name = (levelData and levelData.name) or gemData.name,
                tooltip = (levelData and levelData.tooltip) or gemData.tooltip,
                level = math.max(1, tonumber(level) or 1),
                maxLevel = maxLevel,
            }
        }
    })
end

local function refreshPlayerBonuses(player)
    if not player or not player:isPlayer() then
        return
    end

    GemsSocketBonusCache.bumpMetric("player_bonus_refreshes")
    GemsSocketBonusCache.rebuildPlayer(player)
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CHRONICLE_GEM_BONUS_SUBID, true)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        if type(player.setVisibilityGem) == "function" then
            player:setVisibilityGem(false)
        end
        if type(player.setVisibilityProgressionTier) == "function" then
            player:setVisibilityProgressionTier(0)
        end
        return
    end

    local socketHealthBonus = getEquippedSocketBonusTotal(player, "socket_chronicle_health") + getEquippedSocketBonusTotal(player, "socket_gravedigger_health")
    local socketManaBonus = getEquippedSocketBonusTotal(player, "socket_chronicle_mana") + getEquippedSocketBonusTotal(player, "socket_gravedigger_mana")
    if socketHealthBonus > 0 or socketManaBonus > 0 then
        local socketStatCondition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
        socketStatCondition:setParameter(CONDITION_PARAM_SUBID, CHRONICLE_GEM_BONUS_SUBID)
        socketStatCondition:setParameter(CONDITION_PARAM_TICKS, -1)
        if socketHealthBonus > 0 then
            socketStatCondition:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTS, socketHealthBonus)
        end
        if socketManaBonus > 0 then
            socketStatCondition:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTS, socketManaBonus)
        end
        player:addCondition(socketStatCondition)
    end

    if type(_G.GuildHall_refreshRarityEquipmentBonuses) == "function" then
        _G.GuildHall_refreshRarityEquipmentBonuses(player)
    end
    if type(_G.GemsSocket_refreshHiddenNpcUnlocks) == "function" then
        _G.GemsSocket_refreshHiddenNpcUnlocks(player)
    end
    if type(_G.HiddenAltarBosses_refreshPlayerVisibilityState) == "function" then
        _G.HiddenAltarBosses_refreshPlayerVisibilityState(player)
    end
    if type(_G.HiddenHiveStone_refreshPlayerVisibilityState) == "function" then
        _G.HiddenHiveStone_refreshPlayerVisibilityState(player)
    end
    if type(player.getVisibilityGemLevel) == "function" then
        local veilstoneLevel = player:getVisibilityGemLevel("veilstone")
        local nemesisLevel = player:getVisibilityGemLevel("nemesis")
        local hiveLevel = player:getVisibilityGemLevel("hivestone")
        local maxVisibilityLevel = math.max(veilstoneLevel, nemesisLevel, hiveLevel)
        player:setVisibilityGem(maxVisibilityLevel > 0)
        player:setVisibilityProgressionTier(maxVisibilityLevel)
    end
    if type(_G.GemsSocket_advancedRefreshPlayerBonuses) == "function" then
        _G.GemsSocket_advancedRefreshPlayerBonuses(player)
    end
    if type(_G.UtilityGems) == "table" and type(_G.UtilityGems.refreshActivePlayer) == "function" then
        _G.UtilityGems.refreshActivePlayer(player)
    end
end

function GemsSocket_refreshPlayerBonusesIfEquipped(player, item)
    if item and GemsSocket_isEquipmentPosition(item:getPosition()) then
        refreshPlayerBonuses(player)
        return true
    end
    return false
end

PredatorEye.equippedSlots = {
    CONST_SLOT_HEAD,
    CONST_SLOT_NECKLACE,
    CONST_SLOT_ARMOR,
    CONST_SLOT_RIGHT,
    CONST_SLOT_LEFT,
    CONST_SLOT_LEGS,
    CONST_SLOT_FEET,
    CONST_SLOT_RING,
    CONST_SLOT_AMMO,
    CONST_SLOT_BADGE,
    CONST_SLOT_GLOVES,
    CONST_SLOT_BELT,
}

PredatorEye.equippedSlotSet = {
    [CONST_SLOT_HEAD] = true,
    [CONST_SLOT_NECKLACE] = true,
    [CONST_SLOT_ARMOR] = true,
    [CONST_SLOT_RIGHT] = true,
    [CONST_SLOT_LEFT] = true,
    [CONST_SLOT_LEGS] = true,
    [CONST_SLOT_FEET] = true,
    [CONST_SLOT_RING] = true,
    [CONST_SLOT_AMMO] = true,
    [CONST_SLOT_BADGE] = true,
    [CONST_SLOT_GLOVES] = true,
    [CONST_SLOT_BELT] = true,
}

function PredatorEye.forEachEquippedSocket(player, callback, bonusCache)
    if not player or type(callback) ~= "function" then
        return
    end


    if bonusCache and type(GemsSocketBonusCache.forEachCachedGemSocket) == "function" then
        GemsSocketBonusCache.forEachCachedGemSocket(bonusCache, PredatorEye.gemKey, callback, PredatorEye.equippedSlotSet)
        return
    elseif type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, PredatorEye.gemKey, callback, PredatorEye.equippedSlotSet)
        return
    end

    for _, slot in ipairs(PredatorEye.equippedSlots) do
        local item = player:getSlotItem(slot)
        if item and hasSockets(item) then
            for socketIndex = 1, getSocketCount(item) do
                if PredatorEye.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function PredatorEye.getTargetProgress(item, socketIndex, targetName)
    local state = PredatorEye.readState(item, socketIndex)
    local settings = PredatorEye.getSettings(getSocketGemLevel(item, socketIndex))
    local normalizedTarget = type(targetName) == "string" and targetName:lower() or ""
    if normalizedTarget == "" then
        return false, 0
    end

    if state and type(state.activeName) == "string" and state.activeName:lower() == normalizedTarget then
        return true, settings.killsRequired
    end
    if state and type(state.nextName) == "string" and state.nextName:lower() == normalizedTarget then
        return false, math.max(0, tonumber(state.nextKills) or 0)
    end
    return false, 0
end

function PredatorEye.advanceProgress(item, socketIndex, targetName)
    if not item or not targetName or targetName == "" then
        return nil
    end

    local settings = PredatorEye.getSettings(getSocketGemLevel(item, socketIndex))
    local state = PredatorEye.readState(item, socketIndex) or {}
    local lowerTarget = targetName:lower()
    local activeName = type(state.activeName) == "string" and state.activeName or nil
    if activeName and activeName:lower() == lowerTarget then
        return nil
    end

    local nextName = type(state.nextName) == "string" and state.nextName or nil
    if not nextName or nextName:lower() ~= lowerTarget then
        state.nextName = targetName
        state.nextKills = 0
    end

    state.nextKills = math.max(0, tonumber(state.nextKills) or 0) + 1
    local learnedName = nil
    if state.nextKills >= settings.killsRequired then
        state.activeName = targetName
        state.nextName = nil
        state.nextKills = 0
        learnedName = targetName
    end

    PredatorEye.writeState(item, socketIndex, state)
    setSocketGemDisplayData(item, socketIndex, GemsSocket.GEMS[PredatorEye.gemKey])
    GemsSocket_refreshSocketDisplay(item)
    return learnedName
end

function PredatorEye.getDamageBonus(player, target, bonusCache)
    if not player or not target or not target:isMonster() then
        return 0
    end

    local total = 0
    local targetName = target:getName()
    PredatorEye.forEachEquippedSocket(player, function(item, socketIndex)
        local isActive = PredatorEye.getTargetProgress(item, socketIndex, targetName)
        if isActive then
            total = total + PredatorEye.getSettings(getSocketGemLevel(item, socketIndex)).damagePercent
        end
    end, bonusCache)
    return total
end

function PredatorEye.getExecuteThreshold(player, target, bonusCache)
    if not player or not target or not target:isMonster() then
        return 0
    end

    local threshold = 0
    local targetName = target:getName()
    PredatorEye.forEachEquippedSocket(player, function(item, socketIndex)
        local isActive = PredatorEye.getTargetProgress(item, socketIndex, targetName)
        if isActive then
            threshold = math.max(threshold, PredatorEye.getSettings(getSocketGemLevel(item, socketIndex)).executeThreshold)
        end
    end, bonusCache)
    return threshold
end

function PredatorEye.getRawHitDamage(primaryDamage, secondaryDamage)
    return math.abs(tonumber(primaryDamage) or 0) + math.abs(tonumber(secondaryDamage) or 0)
end

function PredatorEye.addScaledDamage(damage, percent)
    damage = tonumber(damage) or 0
    percent = tonumber(percent) or 0
    if damage == 0 or percent <= 0 then
        return damage
    end

    local bonus = math.max(1, math.floor(math.abs(damage) * (percent / 100)))
    if damage < 0 then
        return damage - bonus
    end
    return damage + bonus
end

function GemsSocket_applySoulmarkGem(player, target, primaryDamage, secondaryDamage, totals)
    local bonusPercent = totals and (totals.socket_soulmark_damage or 0)
        or getEquippedSocketBonusTotal(player, "socket_soulmark_damage")
    if bonusPercent <= 0 or not target or not target:isMonster() or target:getMaster() then
        return primaryDamage, secondaryDamage
    end

    local state = GemsSocket_getSoulmarkState(player)
    if not state then
        return primaryDamage, secondaryDamage
    end

    if (state.targetId or 0) > 0 and not Monster(state.targetId) then
        state.targetId = 0
    end

    local targetId = target:getId()
    if state.targetId == targetId then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, bonusPercent)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, bonusPercent)
        return primaryDamage, secondaryDamage
    end

    if os.time() >= (state.cooldownUntil or 0) then
        state.targetId = targetId
        state.cooldownUntil = os.time() + SOCKET_SOULMARK_COOLDOWN
    end

    return primaryDamage, secondaryDamage
end

local function handleSocketOffensiveHit(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if mirrorgemEchoLock[player:getId()] then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING
        or primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN
        or origin == ORIGIN_CONDITION then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    bonusCache = bonusCache or GemsSocketBonusCache.getPlayerCache(player)
    local totals = bonusCache and bonusCache.totals or {}
    if (not bonusCache or (bonusCache.socketCount or 0) <= 0)
        and not GemsSocket_hasCombatRuntime(player, target) then
        GemsSocketBonusCache.bumpMetric("combat_fast_exits")
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local abyssalDepthsBonus = getAbyssalDepthsDamageBonus(player, totals)
    if abyssalDepthsBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, abyssalDepthsBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, abyssalDepthsBonus)
    end

    local warstoneBonus = getWarstoneDamageBonus(player)
    if warstoneBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, warstoneBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, warstoneBonus)
    end

    local boonstoneBonus = getBoonstoneDamageBonus(player)
    if boonstoneBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, boonstoneBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, boonstoneBonus)
    end

    local voidstoneBonus = getVoidstoneDamageBonus(player, target)
    if voidstoneBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, voidstoneBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, voidstoneBonus)
    end

    local spellfuryBonus = getSpellfuryDamageBonus(player, origin, totals)
    if spellfuryBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, spellfuryBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, spellfuryBonus)
    end

    local predatorBonus = PredatorEye.getDamageBonus(player, target, bonusCache)
    if predatorBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, predatorBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, predatorBonus)
    end

    local chronicleDamageBonus = totals.socket_chronicle_damage_percent or 0
    if chronicleDamageBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, chronicleDamageBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, chronicleDamageBonus)
    end

    local livingDamageBonus = totals.socket_living_damage_percent or 0
    if livingDamageBonus > 0 then
        primaryDamage = PredatorEye.addScaledDamage(primaryDamage, livingDamageBonus)
        secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, livingDamageBonus)
    end

    primaryDamage, secondaryDamage = GemsSocket_applySoulmarkGem(player, target, primaryDamage, secondaryDamage, totals)

    local crippleChance = totals.socket_cripple_chance or 0
    if rollSocketChance(crippleChance) then
        local crippleDuration = totals.socket_cripple_duration or 0
        local crippleSlow = totals.socket_cripple_speed or 0
        local condition = buildSocketParalyzeCondition(crippleSlow, crippleDuration)
        if condition then
            target:addCondition(condition)
            target:getPosition():sendMagicEffect(CONST_ME_STONES)
        end
    end

    local executeChance = totals.socket_execute_chance or 0
    local executeThreshold = totals.socket_execute_threshold or 0
    local executePercent = totals.socket_execute_percent or 0
    local healthPercent = target:getMaxHealth() > 0 and ((target:getHealth() / target:getMaxHealth()) * 100) or 0

    if healthPercent <= executeThreshold and rollSocketChance(executeChance) then
        if getIncomingSocketDamage(primaryDamage, secondaryDamage) > 0 and executePercent > 0 then
            target:getPosition():sendMagicEffect(CONST_ME_CRITICAL_DAMAGE)
            primaryDamage = PredatorEye.addScaledDamage(primaryDamage, executePercent)
            secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, executePercent)
        end
    end

    local predatorExecuteThreshold = PredatorEye.getExecuteThreshold(player, target, bonusCache)
    if predatorExecuteThreshold > 0 and healthPercent <= predatorExecuteThreshold then
        local executeDamage = PredatorEye.getRawHitDamage(primaryDamage, secondaryDamage)
        if executeDamage > 0 then
            target:getPosition():sendMagicEffect(CONST_ME_CRITICAL_DAMAGE)
            if primaryDamage < 0 then
                primaryDamage = primaryDamage - executeDamage
            else
                primaryDamage = primaryDamage + executeDamage
            end
        end
    end

    local totalOutgoingDamage = getIncomingSocketDamage(primaryDamage, secondaryDamage)
    if type(_G.GemsSocket_advancedOnOffensiveHit) == "function" then
        primaryDamage, primaryType, secondaryDamage, secondaryType = _G.GemsSocket_advancedOnOffensiveHit(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
        totalOutgoingDamage = getIncomingSocketDamage(primaryDamage, secondaryDamage)
    end

    if isSocketSpellOrigin(origin) and hasActiveBattlestone(player) and totalOutgoingDamage > 0 then
        local battlestone = getBattlestoneState(player)
        if battlestone then
            battlestone.pending = false
            battlestone.activeUntil = 0
            battlestone.echoing = true
        end
        doTargetCombatHealth(player, target, primaryType, -totalOutgoingDamage, -totalOutgoingDamage, CONST_ME_CRITICAL_DAMAGE)
        consumeBattlestone(player)
    end
    if type(_G.PossessionGem) == "table" and _G.PossessionGem.forEachEquippedSocket then
        _G.PossessionGem.forEachEquippedSocket(player, function(item, socketIndex)
            _G.PossessionGem.tryCast(player, target, item, socketIndex)
        end, bonusCache)
    end
    tryTriggerMirrorgem(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, totals)

    tryTriggerAbyssalDepths(player, totalOutgoingDamage, totals)
    tryTriggerSpellfury(player, totalOutgoingDamage, origin, totals)
    triggerAscendance(player, totalOutgoingDamage, totals)
    tryTriggerVoltstone(player, target, totalOutgoingDamage, totals)
    tryTriggerEmberstone(player, totalOutgoingDamage, totals)
    tryTriggerBindstone(player, target, totals)
    tryTriggerSurgestone(player, target, totalOutgoingDamage, totals)
    tryTriggerVoidstone(player, target, totals)
    tryTriggerGravitystone(player, target, totalOutgoingDamage, totals)
    tryTriggerTotemGem(player, totalOutgoingDamage, totals)
    if origin == ORIGIN_RANGED then
        tryTriggerMarksmanstone(player, target, totalOutgoingDamage, totals)
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local function handleSocketOnKill(player, target)
    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return true
    end

    local isBossKill = ShockwaveStone_isBossMonster(target)

    local hauntedItem, hauntedSocketIndex, hauntedState = HauntedHuntGem.findEquippedSocket(player)
    if hauntedItem and hauntedSocketIndex and hauntedState and hauntedState.eventState == "boss"
        and math.max(0, tonumber(hauntedState.activeBossId) or 0) == target:getId() then
        HauntedHuntGem.completeBoss(player, hauntedItem, hauntedSocketIndex, hauntedState)
        return true
    end

    local learnedTargets = {}
    local targetName = target:getName()
    PredatorEye.forEachEquippedSocket(player, function(item, socketIndex)
        local learnedName = PredatorEye.advanceProgress(item, socketIndex, targetName)
        if learnedName then
            learnedTargets[learnedName:lower()] = learnedName
        end
    end)
    for _, learnedName in pairs(learnedTargets) do
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Predator Eye has learned %s.", learnedName))
    end

    local gainedPhoenixCharge = false
    PhoenixGem.forEachEquippedSocket(player, function(item, socketIndex)
        if PhoenixGem.advanceProgress(item, socketIndex) then
            gainedPhoenixCharge = true
        end
    end)
    if gainedPhoenixCharge then
        local special = GemsSocket_getSpecialConfig("phoenix") or {}
        player:sendTextMessage(MESSAGE_INFO_DESCR, special.chargeMessage or "Phoenix Gem gains a revive charge.")
    end

    local refreshLiveSocketBonuses = false
    ChronicleGem.forEachEquippedSocket(player, function(item, socketIndex)
        if ChronicleGem.recordKill(item, socketIndex, isBossKill) then
            refreshLiveSocketBonuses = true
        end
    end)

    if type(_G.LivingGem) == "table" and _G.LivingGem.forEachEquippedSocket then
        _G.LivingGem.forEachEquippedSocket(player, function(item, socketIndex)
            _G.LivingGem.recordKill(item, socketIndex)
        end)
    end
    if type(_G.PossessionGem) == "table" and _G.PossessionGem.forEachEquippedSocket then
        _G.PossessionGem.forEachEquippedSocket(player, function(item, socketIndex)
            _G.PossessionGem.recordKill(player, item, socketIndex, target)
        end)
    end

    if hauntedItem and hauntedSocketIndex then
        HauntedHuntGem.advanceProgress(player, hauntedItem, hauntedSocketIndex, targetName)
    end

    SiphonBloom_tryCreate(player, target:getPosition())
    GemsSocket_tryTriggerMimicGem(player, target)

    if refreshLiveSocketBonuses then
        refreshPlayerBonuses(player)
    end

    local blastChance = getEquippedSocketBonusTotal(player, "socket_onkill_blast_chance")
    local blastPercent = getEquippedSocketBonusTotal(player, "socket_onkill_blast_percent")
    if not rollSocketChance(blastChance) or blastPercent <= 0 then
        return true
    end

    local blastDamage = getSocketScaledAmount(target:getMaxHealth(), blastPercent)
    if blastDamage <= 0 then
        return true
    end

    local center = target:getPosition()
    local blastEffect = getEquippedSocketTriggerEffect(player, { "socket_onkill_blast_chance", "socket_onkill_blast_percent" }, CONST_ME_EXPLOSIONAREA)
    center:sendMagicEffect(blastEffect)
    for _, monster in ipairs(Game.getSpectators(center, false, false, 1, 1, 1, 1)) do
        if monster:isMonster() and monster ~= target and not monster:getMaster() then
            doTargetCombat(player, monster, COMBAT_PHYSICALDAMAGE, -blastDamage, -blastDamage, blastEffect)
        end
    end

    return true
end

local function isBoundBondState(state)
    return type(state) == "table"
        and (tonumber(state.targetGuid) or 0) > 0
        and type(state.targetName) == "string"
        and state.targetName ~= ""
end

local function normalizeSocketIndex(socketIndex)
    return math.floor(tonumber(socketIndex) or 0)
end

local function insertGem(player, target, socketIndex, gemItemId, gemSource, requestedGemKey)
    socketIndex = normalizeSocketIndex(socketIndex)
    gemItemId = tonumber(gemItemId) or 0

    local item = resolveActionTarget(player, target)
    if not item or not ensureSocketableMetadata(item) then
        setSelectedTarget(player, nil)
        sendMessage(player, "error", "Select a backpack item with sockets.")
        return true
    end

    local socketCount = getSocketCount(item)
    if socketIndex < 1 or socketIndex > socketCount then
        sendMessage(player, "error", "Invalid socket selected.")
        return true
    end

    if getSocketGemKey(item, socketIndex) then
        sendMessage(player, "error", "That socket is already occupied.")
        return true
    end

    local sourceGemItem = getTargetItem(player, gemSource)
    if (not gemItemId or gemItemId <= 0) and sourceGemItem and sourceGemItem:isItem() then
        gemItemId = sourceGemItem:getId()
    end
    local sourceGemKey = sourceGemItem and sourceGemItem:isItem() and sourceGemItem:getCustomAttribute("gem_key") or nil
    local gemKey = sourceGemKey or requestedGemKey or GemsSocket.gemsByItemId[gemItemId]
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not gemData or tonumber(gemData.itemId) ~= tonumber(gemItemId) then
        sendMessage(player, "error", "That item is not a valid gem.")
        return true
    end

    if not isGemAllowedForItem(gemData, item) then
        local allowedSlotsText = formatGemAllowedSlots(gemData)
        if allowedSlotsText ~= "" then
            sendMessage(player, "error", string.format("This gem is only for slot: %s.", allowedSlotsText))
        else
            sendMessage(player, "error", "That gem cannot be socketed into this item.")
        end
        return true
    end

    if not sourceGemItem and gemData.requiresBondBinding then
        forEachOwnedItem(player, function(ownedItem)
            if sourceGemItem or ownedItem:getId() ~= gemData.itemId then
                return
            end

            ensureGemItemMetadata(ownedItem)

            local state = GemsSocket_readSpecialGemState(ownedItem, nil, gemKey)
            if isBoundBondState(state) then
                sourceGemItem = ownedItem
            end
        end)
    end

    if not sourceGemItem and gemData.requiresProfessionBinding then
        forEachOwnedItem(player, function(ownedItem)
            if sourceGemItem or ownedItem:getId() ~= gemData.itemId then
                return
            end
            ensureGemItemMetadata(ownedItem)
            local state = GemsSocket_readSpecialGemState(ownedItem, nil, gemKey)
            if type(state) == "table" and type(state.profession) == "string" then
                sourceGemItem = ownedItem
            end
        end)
    end
    local gemLevel = 1
    local extraState = nil
    local consumeSourceGemItem = false
    local consumeInventoryGem = false
    if sourceGemItem and sourceGemItem:isItem() and sourceGemItem:getId() == gemData.itemId then
        ensureGemItemMetadata(sourceGemItem)
        gemLevel = getGemItemLevel(sourceGemItem)
        extraState = GemsSocket_readSpecialGemState(sourceGemItem, nil, gemKey)
        consumeSourceGemItem = true
    else
        if player:getItemCount(gemData.itemId) < 1 then
            sendMessage(player, "error", "You do not have that gem available.")
            return true
        end
        consumeInventoryGem = true
    end

    if gemData.requiresBondBinding and not isBoundBondState(extraState) then
        sendMessage(player, "error", string.format("Use %s on another player first before socketing it.", gemData.name))
        return true
    end

    if gemData.requiresProfessionBinding and (type(extraState) ~= "table" or type(extraState.profession) ~= "string") then
        sendMessage(player, "error", string.format("Use %s first and permanently select a profession before socketing it.", gemData.name))
        return true
    end

    if gemData.uniquePerItem and GemsSocket_itemHasSocketGem(item, gemKey, socketIndex) then
        sendMessage(player, "error", string.format("This item already has %s socketed.", gemData.name))
        return true
    end

    if consumeSourceGemItem then
        sourceGemItem:remove(1)
    elseif consumeInventoryGem then
        if not player:removeItem(gemData.itemId, 1, -1, true) then
            sendMessage(player, "error", "You do not have that gem available.")
            return true
        end
    end

    flushDamageGemPending(player)
    setSocketGemKey(item, socketIndex, gemKey)
    setSocketGemLevel(item, socketIndex, gemLevel)
    GemsSocket_writeSpecialGemState(item, socketIndex, gemKey, extraState)
    setSocketGemDisplayData(item, socketIndex, gemData)
    awardGemTierStorage(player, gemKey, gemLevel)
    setSelectedTarget(player, item)
    refreshSocketItem(item)
    GemsSocket_refreshPlayerBonusesIfEquipped(player, item)
    sendPanelData(player, item, target)
    sendMessage(player, "info", string.format("%s socketed into slot %d.", gemData.name, socketIndex))
    return true
end

local function getUniqueEquippedConflict(player, item)
    if not player or not item or not item:isItem() or not hasSockets(item) then
        return nil
    end

    local ignoredItemUniqueId = item:getUniqueId()
    for socketIndex = 1, getSocketCount(item) do
        local gemKey = getSocketGemKey(item, socketIndex)
        local gemData = gemKey and GemsSocket.GEMS[gemKey]
        if gemData and gemData.uniqueEquipped and GemsSocket_playerHasEquippedSocketGem(player, gemKey, ignoredItemUniqueId) then
            return gemData
        end

    end

    return nil
end

local function extractGem(player, target, socketIndex)
    socketIndex = normalizeSocketIndex(socketIndex)

    local item = resolveActionTarget(player, target)
    if not item then
        setSelectedTarget(player, nil)
        sendMessage(player, "error", "Select a backpack item with sockets.")
        return true
    end

    if socketIndex < 1 or socketIndex > getSocketCount(item) then
        sendMessage(player, "error", "Invalid socket selected.")
        return true
    end

    local gemKey = getSocketGemKey(item, socketIndex)
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not gemData then
        sendMessage(player, "error", "That socket is already empty.")
        return true
    end

    local level = getSocketGemLevel(item, socketIndex)
    if GemsSocket.REQUIRE_EXTRACTOR and GemsSocket.EXTRACTOR_ITEM_ID > 0 then
        if player:getItemCount(GemsSocket.EXTRACTOR_ITEM_ID) < 1 then
            sendMessage(player, "error", "You need a star extractor for this action.")
            return true
        end
    elseif GemsSocket.REQUIRE_EXTRACTOR then
        sendMessage(player, "error", "Star extractor item is not configured.")
        return true
    end

    flushDamageGemPending(player)
    local extraState = GemsSocket_readSpecialGemState(item, socketIndex, gemKey)

    if gemKey == "collectorgem" then
        extraState = nil
    end

    if not addLeveledGemToPlayer(player, gemKey, level, extraState) then
        sendMessage(player, "error", "You do not have enough room in your backpack to extract that gem.")
        return true
    end

    if GemsSocket.REQUIRE_EXTRACTOR and GemsSocket.EXTRACTOR_ITEM_ID > 0 then
        player:removeItem(GemsSocket.EXTRACTOR_ITEM_ID, 1, -1, true)
    end

    clearSocketGem(item, socketIndex)
    setSelectedTarget(player, item)
    refreshSocketItem(item)
    GemsSocket_refreshPlayerBonusesIfEquipped(player, item)
    sendPanelData(player, item, target)
    sendMessage(player, "info", string.format("%s extracted at level %d.", gemData.name, level))
    return true
end

local function removeGem(player, target, socketIndex)
    socketIndex = normalizeSocketIndex(socketIndex)

    local item = resolveActionTarget(player, target)
    if not item then
        setSelectedTarget(player, nil)
        sendMessage(player, "error", "Select a backpack item with sockets.")
        return true
    end

    if socketIndex < 1 or socketIndex > getSocketCount(item) then
        sendMessage(player, "error", "Invalid socket selected.")
        return true
    end

    local gemKey = getSocketGemKey(item, socketIndex)
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not gemData then
        sendMessage(player, "error", "That socket is already empty.")
        return true
    end

    flushDamageGemPending(player)
    clearSocketGem(item, socketIndex)
    setSelectedTarget(player, item)
    refreshSocketItem(item)
    GemsSocket_refreshPlayerBonusesIfEquipped(player, item)
    sendPanelData(player, item, target)
    sendMessage(player, "info", string.format("%s destroyed from socket %d.", gemData.name, socketIndex))
    return true
end

local function convertSocketGemToEssence(player, target, socketIndex)
    socketIndex = normalizeSocketIndex(socketIndex)

    local item = resolveActionTarget(player, target)
    if not item then
        setSelectedTarget(player, nil)
        sendMessage(player, "error", "Select a backpack item with sockets.")
        return true
    end

    if socketIndex < 1 or socketIndex > getSocketCount(item) then
        sendMessage(player, "error", "Invalid socket selected.")
        return true
    end

    local gemKey = getSocketGemKey(item, socketIndex)
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not gemData then
        sendMessage(player, "error", "That socket is empty.")
        return true
    end

    local level = getSocketGemLevel(item, socketIndex)
    local power = getGemEssencePower(gemData, level)
    local outputItemId = getEssenceOutputItemId()

    local essenceItem = player:addItem(outputItemId, power)
    if not essenceItem then
        sendMessage(player, "error", "Not enough room to receive gem power.")
        return true
    end

    flushDamageGemPending(player)
    clearSocketGem(item, socketIndex)
    setSelectedTarget(player, item)
    refreshSocketItem(item)
    GemsSocket_refreshPlayerBonusesIfEquipped(player, item)
    sendPanelData(player, item, target)
    sendMessage(player, "info", string.format("%s converted into %d gem power.", gemData.name, power))
    return true
end

local function convertInventoryGemToEssence(player, target, gemKey, gemLevel, amount)
    amount = math.max(1, toNumber(amount, 1))
    local gemData = gemKey and GemsSocket.GEMS[gemKey]
    if not gemData then
        sendMessage(player, "error", "That item is not a valid gem.")
        return true
    end

    gemLevel = math.max(1, toNumber(gemLevel, 1))

    if getInventoryGemCountByLevel(player, gemKey, gemLevel) < amount then
        sendMessage(player, "error", "You do not have enough of that exact gem level.")
        return true
    end

    local power = getGemEssencePower(gemData, gemLevel) * amount
    local essenceItem = player:addItem(getEssenceOutputItemId(), power)
    if not essenceItem then
        sendMessage(player, "error", "Not enough room to receive gem power.")
        return true
    end

    if not removeInventoryGemsByLevel(player, gemKey, gemLevel, amount) then
        essenceItem:remove(power)
        sendMessage(player, "error", "Essence conversion failed while consuming source gems.")
        return true
    end

    local item = resolveActionTarget(player, target)
    if item and ensureSocketableMetadata(item) then
        sendPanelData(player, item, nil, "extract")
    else
        sendInventoryEssencePanelData(player)
    end
    sendMessage(player, "info", string.format("%d %s level %d converted into %d gem power.", amount, gemData.name, gemLevel, power))
    return true
end

local function fuseInventoryGems(player, target, selections)
    if type(selections) ~= "table" then
        sendMessage(player, "error", "Invalid fusion selection.")
        return true
    end

    local totalAmount = 0
    local selectedLevel = nil
    local checkedSelections = {}
    local selectionTotals = {}

    for _, entry in ipairs(selections) do
        local gemKey = entry and entry.key
        local amount = math.max(0, tonumber(entry and entry.amount) or 0)
        local level = math.max(1, tonumber(entry and entry.level) or 1)
        local gemData = gemKey and GemsSocket.GEMS[gemKey]

        if gemData and amount > 0 then
            if selectedLevel and selectedLevel ~= level then
                sendMessage(player, "error", "All fusion gems must have the same level.")
                return true
            end

            selectedLevel = selectedLevel or level
            totalAmount = totalAmount + amount

            local selectionKey = string.format("%s:%d", gemKey, level)
            local checkedEntry = selectionTotals[selectionKey]
            if not checkedEntry then
                checkedEntry = {
                    key = gemKey,
                    level = level,
                    amount = 0,
                }
                selectionTotals[selectionKey] = checkedEntry
                checkedSelections[#checkedSelections + 1] = checkedEntry
            end
            checkedEntry.amount = checkedEntry.amount + amount
        end
    end

    if totalAmount ~= 3 or not selectedLevel then
        sendMessage(player, "error", "Select exactly 3 gems to fuse.")
        return true
    end

    for _, entry in ipairs(checkedSelections) do
        if getInventoryGemCountByLevel(player, entry.key, entry.level) < entry.amount then
            sendMessage(player, "error", "You do not own enough of one selected gem.")
            return true
        end
    end

    local candidates = getFusionCandidates(selectedLevel)
    if #candidates == 0 then
        sendMessage(player, "error", "No fusion result is configured for that level.")
        return true
    end

    local resultGemKey = candidates[math.random(#candidates)]
    local resultGemItem = createLeveledGemItem(resultGemKey, selectedLevel)
    if not resultGemItem then
        sendMessage(player, "error", "Fusion result could not be created.")
        return true
    end

    local addResult = player:addItemEx(resultGemItem, true)
    if addResult ~= RETURNVALUE_NOERROR then
        resultGemItem:remove()
        sendMessage(player, "error", "Not enough room to receive the fused gem.")
        return true
    end

    for _, entry in ipairs(checkedSelections) do
        if not removeInventoryGemsByLevel(player, entry.key, entry.level, entry.amount) then
            resultGemItem:remove()
            sendMessage(player, "error", "Fusion failed while consuming source gems.")
            return true
        end
    end

    local item = resolveActionTarget(player, target)
    if item and ensureSocketableMetadata(item) then
        sendPanelData(player, item, nil, "fusion")
    else
        sendInventoryEssencePanelData(player)
    end

    local resultGemData = GemsSocket.GEMS[resultGemKey]
    sendFusionResult(player, resultGemKey, selectedLevel)
    sendMessage(player, "info", string.format("Fusion complete: received %s level %d.", resultGemData and resultGemData.name or "a gem", selectedLevel))
    return true
end

local function upgradeSocketGem(player, target, socketIndex)
    socketIndex = normalizeSocketIndex(socketIndex)

    local item = resolveActionTarget(player, target)
    if not item then
        setSelectedTarget(player, nil)
        sendMessage(player, "error", "Select a backpack item with sockets.")
        return true
    end

    if socketIndex < 1 or socketIndex > getSocketCount(item) then
        sendMessage(player, "error", "Invalid socket selected.")
        return true
    end

    local gemKey = getSocketGemKey(item, socketIndex)
    if not gemKey then
        sendMessage(player, "error", "That socket is empty.")
        return true
    end

    local currentLevel = getSocketGemLevel(item, socketIndex)
    local gemData, levelData, maxLevel = getGemLevelData(gemKey, currentLevel)
    if not gemData or type(gemData.tiers) ~= "table" or maxLevel <= 1 then
        sendMessage(player, "error", "This gem has no forge path configured.")
        return true
    end
    if currentLevel >= maxLevel then
        sendMessage(player, "error", "This gem is already at its maximum forge level.")
        return true
    end

    local requirements = getNextTierRequirements(levelData)
    for _, requirement in ipairs(requirements or {}) do
        local itemId = tonumber(requirement.id) or 0
        local count = math.max(1, tonumber(requirement.count) or 1)
        if player:getItemCount(itemId) < count then
            sendMessage(player, "error", "You do not have the required forge materials.")
            return true
        end
    end

    for _, requirement in ipairs(requirements or {}) do
        player:removeItem(tonumber(requirement.id) or 0, math.max(1, tonumber(requirement.count) or 1), -1, true)
    end

    flushDamageGemPending(player)
    local newLevel = currentLevel + 1
    setSocketGemLevel(item, socketIndex, newLevel)
    setSocketGemDisplayData(item, socketIndex, gemData)
    awardGemTierStorage(player, gemKey, newLevel)
    setSelectedTarget(player, item)
    refreshSocketItem(item)
    GemsSocket_refreshPlayerBonusesIfEquipped(player, item)
    sendPanelData(player, item, target)
    sendMessage(player, "info", string.format("Socket %d upgraded to level %d.", socketIndex, newLevel))
    return true
end

local function addSocketsToItem(player, target, socketsToAdd)
    if not target or not target:isItem() or not isSocketableItem(target) then
        player:sendCancelMessage("You can only add sockets to equipable items.")
        return false
    end

    local currentCount = getSocketCount(target)
    if currentCount >= GemsSocket.MAX_SOCKETS then
        player:sendCancelMessage("This item already reached the maximum number of sockets.")
        return false
    end

    flushDamageGemPending(player)
    setSocketCount(target, math.min(GemsSocket.MAX_SOCKETS, currentCount + socketsToAdd))
    refreshSocketItem(target)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("The item now has %d socket(s).", getSocketCount(target)))
    target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    return true
end

function GemsSocket_onExtendedOpcode(player, opcode, buffer)
    if opcode ~= GemsSocket.OPCODE then
        return true
    end

    local ok, data = pcall(function()
        return json.decode(buffer)
    end)
    if not ok or type(data) ~= "table" then
        return true
    end

    local action = data.action
    local payload = data.data or {}

    if action == "select_target" then
        if not isBackpackTarget(payload.target) then
            sendMessage(player, "error", "Drag a backpack item with sockets into the socket window.")
            return true
        end

        local item = getTargetItem(player, payload.target)
        if not item or not ensureSocketableMetadata(item) then
            setSelectedTarget(player, nil)
            sendMessage(player, "error", "Only items that already have sockets can be used here.")
            return true
        end
        setSelectedTarget(player, item)
        sendPanelData(player, item, nil, payload.mode, tonumber(payload.gemsPage), tonumber(payload.gemsPageSize), payload.showAllGems == true)
        return true
    end

    if action == "refresh_panel" then
        local item = resolveActionTarget(player, payload.target)
        if not item or not ensureSocketableMetadata(item) then
            sendInventoryEssencePanelData(player)
            return true
        end

        sendPanelData(player, item, nil, payload.mode, tonumber(payload.gemsPage), tonumber(payload.gemsPageSize), payload.showAllGems == true)
        return true
    end

    if action == "inventory_essence_panel" then
        sendInventoryEssencePanelData(player)
        return true
    end

    if action == "gem_catalog_page" then
        GemsSocket_sendGemCatalogPage(player, tonumber(payload.page), tonumber(payload.pageSize), payload.search)
        return true
    end

    if action == "insert_gem" then
        return insertGem(player, payload.target, tonumber(payload.socketIndex), tonumber(payload.gemItemId), payload.gem, payload.gemKey)
    end

    if action == "extract_gem" then
        return extractGem(player, payload.target, tonumber(payload.socketIndex))
    end

    if action == "remove_gem" then
        return removeGem(player, payload.target, tonumber(payload.socketIndex))
    end

    if action == "upgrade_gem" then
        return upgradeSocketGem(player, payload.target, tonumber(payload.socketIndex))
    end

    if action == "essence_socket_gem" then
        return convertSocketGemToEssence(player, payload.target, tonumber(payload.socketIndex))
    end

    if action == "essence_inventory_gem" then
        return convertInventoryGemToEssence(player, payload.target, payload.gemKey, tonumber(payload.gemLevel), tonumber(payload.amount))
    end

    if action == "fuse_inventory_gems" then
        return fuseInventoryGems(player, payload.target, payload.selections)
    end

    return true
end

function GemsSocket_onLogin(player)
    setSelectedTarget(player, nil)
    clearTotemVisual(totemGemState[player:getId()])
    abyssalDepthsState[player:getId()] = nil
    spellfuryState[player:getId()] = nil
    ascendanceState[player:getId()] = nil
    voltstoneState[player:getId()] = nil
    emberstoneState[player:getId()] = nil
    bindstoneState[player:getId()] = nil
    surgestoneState[player:getId()] = nil
    warstoneState[player:getId()] = nil
    boonstoneState[player:getId()] = nil
    venomstoneState[player:getId()] = nil
    dreadstoneState[player:getId()] = nil
    spiritstoneState[player:getId()] = nil
    voidstoneState[player:getId()] = nil
    gravitystoneState[player:getId()] = nil
    chronostoneState[player:getId()] = nil
    marksmanstoneState[player:getId()] = nil
    battlestoneState[player:getId()] = nil
    arcanestoneState[player:getId()] = nil
    mendstoneState[player:getId()] = nil
    totemGemState[player:getId()] = nil
    sacredLinkState[player:getId()] = nil
    sacredLinkRedirectLock[player:getId()] = nil
    reversalState[player:getId()] = nil
    shockwaveStoneState[player:getId()] = nil
    riftstepGemState[player:getId()] = nil
    siphonBloomState[player:getId()] = nil
    phoenixReviveState[player:getId()] = nil
    hauntedHuntRuntimeState[player:getId()] = nil
    player:setStorageValue(SOCKET_CHRONOSTONE_STORAGE_UNTIL, -1)
    player:setStorageValue(SOCKET_CHRONOSTONE_STORAGE_PERCENT, -1)
    initializePlayerSocketableItems(player)
    refreshPlayerBonuses(player)
    player:registerEvent("GemsSocketExtended")
    player:registerEvent("GemsSocketOnHealthChange")
    player:registerEvent("GemsSocketOnManaChange")
    player:registerEvent("GemsSocketOnKill")
    if type(_G.GemsSocket_advancedOnLogin) == "function" then
        _G.GemsSocket_advancedOnLogin(player)
    end
    if type(_G.AbattoirGem) == "table" and type(_G.AbattoirGem.onLogin) == "function" then
        _G.AbattoirGem.onLogin(player)
    end
    return true
end

function GemsSocket_onLogout(player)
    if not player then
        return true
    end

    local item, socketIndex, state = HauntedHuntGem.findEquippedSocket(player)
    if item and socketIndex and state and (state.eventState == "wave" or state.eventState == "boss") then
        HauntedHuntGem.failActiveEvent(player, item, socketIndex, state, "logout")
    end

    hauntedHuntRuntimeState[player:getId()] = nil
    GemsSocketBonusCache.invalidatePlayer(player)
    soulmarkGemState[player:getId()] = nil
    kingsguardGemState[player:getId()] = nil
    cowardsCrownState[player:getId()] = nil
    betrayalGemCooldownState[player:getId()] = nil
    if type(_G.GemsSocket_advancedOnLogout) == "function" then
        _G.GemsSocket_advancedOnLogout(player)
    end
    if type(_G.AbattoirGem) == "table" and type(_G.AbattoirGem.onLogout) == "function" then
        _G.AbattoirGem.onLogout(player)
    end
    return true
end

function GemsSocket_onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if not creature or not creature:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if type(_G.GemsSocket_advancedOnManaChange) == "function" then
        return _G.GemsSocket_advancedOnManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function GemsSocket_onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    GemsSocketBonusCache.bumpMetric("player_health_events")

    if not creature or not creature:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if sacredLinkRedirectLock[creature:getId()] then
        sacredLinkRedirectLock[creature:getId()] = nil
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local bonusCache = GemsSocketBonusCache.getPlayerCache(creature)
    local totals = bonusCache and bonusCache.totals or {}
    local hauntedAttacker = attacker and attacker:isMonster()
        and (tonumber(hauntedHuntBossDamageState[attacker:getId()]) or 0) > 0
    local healingSourceHasSockets = false
    if (primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING)
        and attacker and attacker:isPlayer() and attacker ~= creature then
        local healerCache = GemsSocketBonusCache.getPlayerCache(attacker)
        healingSourceHasSockets = healerCache and (healerCache.socketCount or 0) > 0 or false
    end
    local attackerHasSockets = false
    local incomingAttackerCache = nil
    if attacker and not (primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING) then
        local attackerPlayer = getSocketAttackerPlayer(attacker)
        if attackerPlayer and attackerPlayer ~= creature then
            incomingAttackerCache = GemsSocketBonusCache.getPlayerCache(attackerPlayer)
            attackerHasSockets = incomingAttackerCache and (incomingAttackerCache.socketCount or 0) > 0 or false
        end
    end
    if (not bonusCache or (bonusCache.socketCount or 0) <= 0)
        and not hauntedAttacker and not healingSourceHasSockets and not attackerHasSockets
        and not GemsSocket_hasCombatRuntime(creature, attacker) then
        GemsSocketBonusCache.bumpMetric("combat_fast_exits")
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING then
        if attacker and attacker:isPlayer() and attacker == creature and hasActiveMendstone(creature) then
            if primaryType == COMBAT_HEALING and primaryDamage ~= 0 then
                primaryDamage = scaleSocketCombatDamage(primaryDamage, 2)
            end
            if secondaryType == COMBAT_HEALING and secondaryDamage ~= 0 then
                secondaryDamage = scaleSocketCombatDamage(secondaryDamage, 2)
            end
            creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
        end

        local reversal = getReversalState(creature)
        if reversal and os.time() <= reversal.activeUntil then
            local totalHealing = 0
            if primaryType == COMBAT_HEALING and primaryDamage ~= 0 then
                totalHealing = totalHealing + math.abs(primaryDamage)
            end
            if secondaryType == COMBAT_HEALING and secondaryDamage ~= 0 then
                totalHealing = totalHealing + math.abs(secondaryDamage)
            end

            if totalHealing > 0 then
                local missingHealth = math.max(0, creature:getMaxHealth() - creature:getHealth())
                local overheal = math.max(0, totalHealing - missingHealth)
                local burstDamage = getSocketScaledAmount(overheal, reversal.holyPercent)
                if burstDamage > 0 then
                    for _, monster in ipairs(getNearbyMonsters(creature:getPosition(), 2)) do
                        doTargetCombatHealth(creature, monster, COMBAT_HOLYDAMAGE, -burstDamage, -burstDamage, CONST_ME_HOLYDAMAGE)
                    end
                    creature:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
                end
            end
        end
        if type(_G.GemsSocket_advancedOnHealing) == "function" then
            primaryDamage, primaryType, secondaryDamage, secondaryType = _G.GemsSocket_advancedOnHealing(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
        end
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local phoenixState = PhoenixGem_getPlayerState(creature)
    if phoenixState and phoenixState.invincibleUntil >= os.time() then
        return 0, primaryType, 0, secondaryType
    end

    if primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING
        or primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if getIncomingSocketDamage(primaryDamage, secondaryDamage) <= 0 then
        GemsSocketBonusCache.bumpMetric("combat_fast_exits")
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if type(_G.GemsSocket_advancedOnIncomingHit) == "function" then
        primaryDamage, primaryType, secondaryDamage, secondaryType = _G.GemsSocket_advancedOnIncomingHit(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache, incomingAttackerCache)
    end

    if type(_G.GemsSocket_tryTriggerPurityGemCleanse) == "function" then
        _G.GemsSocket_tryTriggerPurityGemCleanse(creature, totals)
    end

    if origin == ORIGIN_CONDITION then
        trySocketParryAndThorns(creature, attacker, primaryDamage, secondaryDamage, totals)
    end

    if origin == ORIGIN_CONDITION or not attacker or attacker == creature then
        local incomingDamage = getIncomingSocketDamage(primaryDamage, secondaryDamage)
        if incomingDamage > 0 and type(_G.GemsSocket_advancedTryTriggerRequiem) == "function" then
            local allowedDamage = _G.GemsSocket_advancedTryTriggerRequiem(creature, incomingDamage, bonusCache)
            if allowedDamage ~= false then
                return allowedDamage, primaryType, 0, secondaryType
            end
        end
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if attacker:isMonster() then
        local hauntedDamageBonus = math.max(0, tonumber(hauntedHuntBossDamageState[attacker:getId()]) or 0)
        if hauntedDamageBonus > 0 then
            primaryDamage = PredatorEye.addScaledDamage(primaryDamage, hauntedDamageBonus)
            secondaryDamage = PredatorEye.addScaledDamage(secondaryDamage, hauntedDamageBonus)
        end
        GemsSocket_tryTriggerCowardsCrown(creature, totals)
        local betrayalRedirected = false
        primaryDamage, primaryType, secondaryDamage, secondaryType, betrayalRedirected = GemsSocket_redirectBetrayalDamage(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, totals)
        if betrayalRedirected then
            return primaryDamage, primaryType, secondaryDamage, secondaryType
        end
    end

    local dodgeChance = (totals.socket_dodge_chance or 0) + getAscendanceDodgeBonus(creature)
    if rollSocketChance(dodgeChance) then
        creature:say("DODGE!", TALKTYPE_MONSTER_SAY)
        creature:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(creature, "socket_dodge_chance", CONST_ME_POFF, bonusCache))
        return 0, primaryType, 0, secondaryType
    end

    trySocketParryAndThorns(creature, attacker, primaryDamage, secondaryDamage, totals)

    ShockwaveStone_trigger(creature, bonusCache)

    local guardChance = totals.socket_guard_chance or 0
    if rollSocketChance(guardChance) then
        local guardPercent = totals.socket_guard_percent or 0
        if guardPercent > 0 then
            local reductionMultiplier = math.max(0, 1 - (guardPercent / 100))
            primaryDamage = scaleSocketCombatDamage(primaryDamage, reductionMultiplier)
            secondaryDamage = scaleSocketCombatDamage(secondaryDamage, reductionMultiplier)
            creature:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(creature, { "socket_guard_chance", "socket_guard_percent" }, CONST_ME_BLOCKHIT, bonusCache))
        end
    end

    local oathboundReduction = totals.socket_oathbound_pvp_reduction or 0
    if oathboundReduction > 0 and creature:getGuild() and getSocketAttackerPlayer(attacker) then
        local reductionMultiplier = math.max(0, 1 - (oathboundReduction / 100))
        primaryDamage = scaleSocketCombatDamage(primaryDamage, reductionMultiplier)
        secondaryDamage = scaleSocketCombatDamage(secondaryDamage, reductionMultiplier)
        creature:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(creature, "socket_oathbound_pvp_reduction", CONST_ME_BLOCKHIT, bonusCache))
    end

    local vowkeeperReduction = totals.socket_vowkeeper_reduction or 0
    if vowkeeperReduction > 0 and creature:getGuild() then
        if GemsSocket_hasOtherGuildMemberOnline(creature) then
            vowkeeperReduction = vowkeeperReduction + (totals.socket_vowkeeper_online_bonus or 0)
        end

        local reductionMultiplier = math.max(0, 1 - (vowkeeperReduction / 100))
        primaryDamage = scaleSocketCombatDamage(primaryDamage, reductionMultiplier)
        secondaryDamage = scaleSocketCombatDamage(secondaryDamage, reductionMultiplier)
        creature:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(creature, { "socket_vowkeeper_reduction", "socket_vowkeeper_online_bonus" }, CONST_ME_BLOCKHIT, bonusCache))
    end

    GemsSocket_tryTriggerKingsguardGem(creature, attacker, totals)

    local protectionTotemReduction = getProtectionTotemReduction(creature)
    if protectionTotemReduction > 0 then
        local reductionMultiplier = math.max(0, 1 - (protectionTotemReduction / 100))
        primaryDamage = scaleSocketCombatDamage(primaryDamage, reductionMultiplier)
        secondaryDamage = scaleSocketCombatDamage(secondaryDamage, reductionMultiplier)
        creature:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    end

    local ownLinkState = getSacredLinkState(creature)
    if ownLinkState and os.time() <= ownLinkState.activeUntil and (ownLinkState.resistancePercent or 0) > 0 then
        local reductionMultiplier = math.max(0, 1 - ((ownLinkState.resistancePercent or 0) / 100))
        primaryDamage = scaleSocketCombatDamage(primaryDamage, reductionMultiplier)
        secondaryDamage = scaleSocketCombatDamage(secondaryDamage, reductionMultiplier)
        creature:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    end

    local linkHolder, linkState = findSacredLinkHolderForPlayer(creature)
    if linkHolder and linkState then
        if os.time() <= (linkState.shieldUntil or 0) and (linkState.shieldPercent or 0) > 0 then
            local shieldMultiplier = math.max(0, 1 - ((linkState.shieldPercent or 0) / 100))
            primaryDamage = scaleSocketCombatDamage(primaryDamage, shieldMultiplier)
            secondaryDamage = scaleSocketCombatDamage(secondaryDamage, shieldMultiplier)
            creature:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
        end

        local redirectedDamage = getSocketScaledAmount(getIncomingSocketDamage(primaryDamage, secondaryDamage), linkState.redirectPercent)
        if redirectedDamage > 0 then
            local reductionMultiplier = math.max(0, 1 - ((linkState.redirectPercent or 0) / 100))
            primaryDamage = scaleSocketCombatDamage(primaryDamage, reductionMultiplier)
            secondaryDamage = scaleSocketCombatDamage(secondaryDamage, reductionMultiplier)

            local holderDamage = getSocketScaledAmount(redirectedDamage, math.max(0, 100 - (tonumber(linkState.resistancePercent) or 0)))
            if holderDamage > 0 then
                sacredLinkRedirectLock[linkHolder:getId()] = true
                linkHolder:addHealth("physical", -holderDamage)
                linkHolder:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
            end
        end
    end

    local currentHealth = math.max(0, creature:getHealth())
    local incomingDamage = getIncomingSocketDamage(primaryDamage, secondaryDamage)
    local reversal = getReversalState(creature)
    if reversal and os.time() <= reversal.activeUntil and incomingDamage > 0 and reversal.storePercent > 0 then
        reversal.storedHealing = reversal.storedHealing + getSocketScaledAmount(incomingDamage, reversal.storePercent)
    end
    local healthPercentAfter = creature:getMaxHealth() > 0 and ((math.max(0, currentHealth - incomingDamage) / creature:getMaxHealth()) * 100) or 0
    if healthPercentAfter <= 50 then
        tryTriggerWarstone(creature, totals)
    end

    local secondWindChance = totals.socket_second_wind_chance or 0
    local secondWindRoll = rollSocketChance(secondWindChance)
    if secondWindRoll then
        local secondWindPercent = totals.socket_second_wind_percent or 0
        local healAmount = getSocketScaledAmount(creature:getMaxHealth(), secondWindPercent)
        if healAmount > 0 then
            addEvent(applySocketDelayedHeal, 100, creature:getId(), healAmount, getEquippedSocketTriggerEffect(creature, { "socket_second_wind_chance", "socket_second_wind_percent" }, CONST_ME_MAGIC_GREEN, bonusCache))
        end
    end

    local manaSurgeChance = totals.socket_mana_surge_chance or 0
    if rollSocketChance(manaSurgeChance) then
        local manaSurgePercent = totals.socket_mana_surge_percent or 0
        local manaAmount = getSocketScaledAmount(creature:getMaxMana(), manaSurgePercent)
        if manaAmount > 0 then
            creature:addMana(manaAmount)
            creature:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(creature, { "socket_mana_surge_chance", "socket_mana_surge_percent" }, CONST_ME_MAGIC_BLUE, bonusCache))
        end
    end

    local cleanseChance = totals.socket_cleanse_chance or 0
    if rollSocketChance(cleanseChance) and type(_G.GemsSocket_removeRandomSocketDebuff) == "function" and _G.GemsSocket_removeRandomSocketDebuff(creature) then
        creature:getPosition():sendMagicEffect(getEquippedSocketTriggerEffect(creature, "socket_cleanse_chance", CONST_ME_HOLYAREA, bonusCache))
    end

    if type(_G.GemsSocket_advancedTryTriggerMartyr) == "function" then
        primaryDamage, secondaryDamage = _G.GemsSocket_advancedTryTriggerMartyr(creature, primaryDamage, secondaryDamage)
        currentHealth = math.max(0, creature:getHealth())
    end

    if type(_G.GemsSocket_advancedApplyWarcryShieldDamage) == "function" then
        primaryDamage, secondaryDamage = _G.GemsSocket_advancedApplyWarcryShieldDamage(creature, primaryDamage, secondaryDamage)
    end

    local finalIncomingDamage = getIncomingSocketDamage(primaryDamage, secondaryDamage)
    if finalIncomingDamage > 0 then
        if type(_G.GemsSocket_advancedTryTriggerParadox) == "function" then
            _G.GemsSocket_advancedTryTriggerParadox(creature, finalIncomingDamage, attacker, bonusCache)
        end
        RiftstepGem_trigger(creature, finalIncomingDamage, bonusCache)
        local allowedDamage = false
        if type(_G.GemsSocket_advancedTryTriggerRequiem) == "function" then
            allowedDamage = _G.GemsSocket_advancedTryTriggerRequiem(creature, finalIncomingDamage, bonusCache)
        end
        if allowedDamage == false then
            allowedDamage = PhoenixGem_trigger(creature, finalIncomingDamage)
        end
        if allowedDamage ~= false then
            primaryDamage = allowedDamage
            secondaryDamage = 0
        elseif finalIncomingDamage >= currentHealth then
            GemsSocketBonusCache.invalidatePlayer(creature)
            flushDamageGemPending(creature)
            if type(_G.GemsSocket_advancedOnPlayerLethalHit) == "function" then
                _G.GemsSocket_advancedOnPlayerLethalHit(creature, attacker, finalIncomingDamage)
            end
            local item, socketIndex, state = HauntedHuntGem.findEquippedSocket(creature)
            if item and socketIndex and state and (state.eventState == "wave" or state.eventState == "boss") then
                HauntedHuntGem.failActiveEvent(creature, item, socketIndex, state, "death")
            end
            if type(_G.AbattoirGem) == "table" and type(_G.AbattoirGem.onDeath) == "function" then
                _G.AbattoirGem.onDeath(creature)
            end
        end
    end

    if attacker:isCreature() then
        tryTriggerVenomstone(creature, attacker, totals)
    end
    tryTriggerDreadstone(creature, totals)
    tryTriggerSpiritstone(creature, totals)
    tryTriggerChronostone(creature, totals)
    tryTriggerSacredLink(creature, totals)
    tryTriggerReversal(creature, totals)

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function GemsSocket_onMonsterHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    GemsSocketBonusCache.bumpMetric("monster_health_events")

    if getIncomingSocketDamage(primaryDamage, secondaryDamage) <= 0 then
        GemsSocketBonusCache.bumpMetric("combat_fast_exits")
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local owner = attacker and attacker:isPlayer() and attacker or nil
    if not owner and attacker and attacker:isMonster() then
        local master = attacker:getMaster()
        owner = master and master:isPlayer() and master or nil
    end
    if not owner then
        GemsSocketBonusCache.bumpMetric("combat_fast_exits")
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local bonusCache = GemsSocketBonusCache.getPlayerCache(owner)
    local totals = bonusCache and bonusCache.totals or {}
    primaryDamage, primaryType, secondaryDamage, secondaryType = handleSocketOffensiveHit(owner, creature, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
    if (totals.socket_damage_tracker_enabled or 0) > 0
        and type(_G.DamageGem) == "table" and type(_G.DamageGem.record) == "function" then
        _G.DamageGem.record(owner, creature, getIncomingSocketDamage(primaryDamage, secondaryDamage), bonusCache)
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function GemsSocket_onKill(player, target, lastHit)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return true
    end
    GemsSocketBonusCache.bumpMetric("kill_events")

    flushDamageGemPendingSoon(player)
    if type(_G.GemsSocket_advancedOnKill) == "function" then
        _G.GemsSocket_advancedOnKill(player, target, lastHit)
    end
    if type(_G.AbattoirGem) == "table" and type(_G.AbattoirGem.onKill) == "function" then
        _G.AbattoirGem.onKill(player, target, lastHit)
    end
    GemsSocket_clearSoulmarkTarget(player, target)
    return handleSocketOnKill(player, target)
end

function GemsSocket_onMoveItem(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    if toPosition.x == CONTAINER_POSITION and bit.band(tonumber(toPosition.y) or 0, 0x40) == 0 then
        local conflictGem = getUniqueEquippedConflict(player, item)
        if conflictGem then
            local message = string.format("You already have %s equipped. Remove the duplicate gem from this item before equipping it.", conflictGem.name)
            player:sendTextMessage(MESSAGE_INFO_DESCR, message)
            player:sendCancelMessage(message)
            return RETURNVALUE_NOTPOSSIBLE
        end
    end

    return RETURNVALUE_NOERROR
end

function GemsSocket_isEquipmentPosition(position)
    if not position or position.x ~= CONTAINER_POSITION
        or bit.band(tonumber(position.y) or 0, 0x40) ~= 0 then
        return false
    end

    local wantedSlot = tonumber(position.y) or 0
    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS or {}) do
        if slot == wantedSlot then
            return true
        end
    end
    return false
end

function GemsSocket_onItemMoved(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    ensureGemItemMetadata(item)
    local metadataChanged = ensureSocketableMetadata(item)
    local equipmentChanged = GemsSocket_isEquipmentPosition(fromPosition) or GemsSocket_isEquipmentPosition(toPosition)

    if equipmentChanged or metadataChanged and GemsSocket_isEquipmentPosition(item:getPosition()) then
        flushDamageGemPending(player)
        GemsSocketBonusCache.bumpMetric("equipment_move_refreshes")
        refreshPlayerBonuses(player)
    elseif type(_G.UtilityGems) == "table" and type(_G.UtilityGems.refreshActivePlayer) == "function" then
        GemsSocketBonusCache.bumpMetric("item_moves_skipped")
        local itemId = item and item:getId() or 0
        if itemId == 30733 or itemId == 30735 then
            _G.UtilityGems.refreshActivePlayer(player)
        end
    end
end

function GemsSocket_onTargetCombat(creature, target)
    if creature and creature:isPlayer() and target and target:isMonster() then
        target:registerEvent("GemsSocketOnMonsterHealthChange")
    end
    return RETURNVALUE_NOERROR
end

function GemsSocket_registerSocketAdderItem(itemId, socketsToAdd)
    if isSocketableItemId(itemId) then
        return
    end

    local action = Action()

    function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
        if addSocketsToItem(player, target, socketsToAdd) then
            item:remove(1)
        end
        return true
    end

    action:id(itemId)
    action:register()
end

_G.GemsSocket_ensureSocketableMetadata = ensureSocketableMetadata
_G.GemsSocket_ensureGemItemMetadata = ensureGemItemMetadata
_G.GemsSocket_getSocketCount = getSocketCount
_G.GemsSocket_getSocketGemKey = getSocketGemKey
_G.GemsSocket_getSocketGemLevel = getSocketGemLevel
_G.GemsSocket_serializeGem = serializeGem
_G.GemsSocket_hasSockets = hasSockets
_G.GemsSocket_addSocketsToItem = addSocketsToItem
_G.setSocketGemDisplayData = setSocketGemDisplayData
_G.refreshSocketItem = refreshSocketItem
_G.GemsSocket_recomputeSocketBonuses = recomputeSocketBonuses
_G.GemsSocket_refreshPlayerBonuses = refreshPlayerBonuses
_G.GemsSocket_invalidatePlayerBonusCache = GemsSocketBonusCache.invalidatePlayer
_G.GemsSocket_rebuildPlayerBonusCache = GemsSocketBonusCache.rebuildPlayer
_G.GemsSocket_debugLegacyBonusTotal = GemsSocketBonusCache.legacyTotal
_G.GemsSocket_debugCompareBonusCache = GemsSocketBonusCache.debugCompare
_G.GemsSocket_getEquippedSocketBonusTotal = getEquippedSocketBonusTotal
_G.GemsSocket_hasEquippedGem = GemsSocketBonusCache.hasGem
_G.GemsSocket_hasAnyEquippedGem = GemsSocketBonusCache.hasAnyGem
_G.GemsSocket_forEachEquippedGemSocket = GemsSocketBonusCache.forEachGemSocket
_G.GemsSocket_getEquippedGemMaxLevel = GemsSocketBonusCache.maxGemLevel
_G.GemsSocket_forEachPlayerWithGem = GemsSocketBonusCache.forEachPlayerWithGem
_G.GemsSocket_getPerformanceMetrics = GemsSocketBonusCache.getMetrics
_G.GemsSocket_tryTriggerBoonstone = tryTriggerBoonstone
