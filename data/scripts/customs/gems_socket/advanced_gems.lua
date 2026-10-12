-- Advanced socket gem effects that are large enough to keep outside the core
-- socket UI/action file.


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

local phantomState = {}
local paradoxState = {}
local manaNovaState = {}
local hexmirrorState = {}
local chameleonState = {}
local volleyChainState = {}
local galvanicState = {}
local galvanicCharges = {}
local treasureGoblinState = {}
local rollGemState = {}
local rollGemParalyzeState = {}
local wayfinderState = {}
local warcryState = {}
local warcryShieldState = {}
local obsidianGrudgeState = {}
local martyrState = {}
local heraldState = {}
local huntersFocusState = {}
local lastBreathState = {}
local anchorState = {}
local momentumState = {}
local bloodPriceState = {}
local bloodPriceSerial = 0
local pacifistState = {}
local carrionState = {}
local damageGemDirty = {}
local damageGemPending = {}
local damageGemFlushScheduled = {}
local advancedPulseTokens = {}
local advancedPulseSerial = 0
local runeheartTimers = {}
local tideTimerStarted = false
local tideMode = "offpeak"
local tideLastCheck = 0
local WARCRY_SUBID = 992432
local MARTYR_SUBID = 992433
local WAYFINDER_SUBID = 992434
local INFECTION_BASE_LEVEL_STORAGE = 992450
local applyPercentReduction
local playerNeedsAdvancedGemPulse
local ensureAdvancedGemPulse

if type(_G.ExtraSocketGems) ~= "table" then
    dofile("data/scripts/customs/gems_socket/extra_gems.lua")
end

local function getEquippedSocketBonusTotal(player, bonusKey)
    if not player or type(bonusKey) ~= "string" or bonusKey == "" then
        return 0
    end

    if type(_G.GemsSocket_getEquippedSocketBonusTotal) == "function" then
        return tonumber(_G.GemsSocket_getEquippedSocketBonusTotal(player, bonusKey)) or 0
    end

    local total = 0
    local attributeKey = "socket_bonus_" .. bonusKey
    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            total = total + (tonumber(item:getCustomAttribute(attributeKey) or 0) or 0)
        end
    end
    return total
end

local function getSocketBonusCache(player)
    if type(_G.GemsSocketBonusCache) == "table" and type(_G.GemsSocketBonusCache.getPlayerCache) == "function" then
        return _G.GemsSocketBonusCache.getPlayerCache(player)
    end
    return nil
end

local function playerHasEquippedSocketGem(player, gemKey)
    if not player or not player:isPlayer() or type(gemKey) ~= "string" or gemKey == "" then
        return false
    end

    local cache = getSocketBonusCache(player)
    if cache and type(cache.gemsByKey) == "table" and type(cache.gemsByKey[gemKey]) == "table" and #cache.gemsByKey[gemKey] > 0 then
        return true
    end

    local hasGem = _G.GemsSocket_playerHasEquippedSocketGem
    return type(hasGem) == "function" and hasGem(player, gemKey) or false
end

local function forEachEquippedGemSocket(player, gemKey, callback, bonusCache)
    if not player or type(callback) ~= "function"
        or type(_G.GemsSocket_getSocketCount) ~= "function"
        or type(_G.GemsSocket_getSocketGemKey) ~= "function" then
        return
    end

    if bonusCache and type(_G.GemsSocketBonusCache) == "table"
        and type(_G.GemsSocketBonusCache.forEachCachedGemSocket) == "function" then
        _G.GemsSocketBonusCache.forEachCachedGemSocket(bonusCache, gemKey, callback)
        return
    elseif type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, gemKey, callback)
        return
    end

    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            for socketIndex = 1, _G.GemsSocket_getSocketCount(item) do
                if _G.GemsSocket_getSocketGemKey(item, socketIndex) == gemKey then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

local function refreshStatefulSocket(item, socketIndex, gemKey)
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[gemKey] or nil
    if gemData and type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, gemData)
    end
    if type(_G.GemsSocket_refreshSocketDisplay) == "function" then
        _G.GemsSocket_refreshSocketDisplay(item)
    elseif type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
end

local function addFlatDamage(damage, amount)
    damage = tonumber(damage) or 0
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    if damage < 0 then
        return damage - amount
    end
    return damage + amount
end

local function getRuneheartRunePool()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS.runeheartstone or nil
    local configuredRunes = gemData and gemData.runes or nil
    if type(configuredRunes) ~= "table" or #configuredRunes == 0 then
        return nil
    end

    local runePool = {}
    for _, runeEntry in ipairs(configuredRunes) do
        local runeId = type(runeEntry) == "table" and tonumber(runeEntry.id) or tonumber(runeEntry)
        if runeId and runeId > 0 then
            runePool[#runePool + 1] = {
                id = runeId,
                name = type(runeEntry) == "table" and runeEntry.name or nil,
            }
        end
    end

    return #runePool > 0 and runePool or nil
end

local function rollChance(chance)
    chance = tonumber(chance) or 0
    if chance <= 0 then
        return false
    end
    if chance >= 100 then
        return true
    end
    return math.random(10000) <= math.floor(chance * 100)
end

local function getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage = tonumber(primaryDamage) or 0
    secondaryDamage = tonumber(secondaryDamage) or 0
    return math.abs(primaryDamage) + math.abs(secondaryDamage)
end

local function reduceDamageByAmount(damage, amount)
    damage = tonumber(damage) or 0
    amount = math.max(0, tonumber(amount) or 0)
    if damage == 0 or amount <= 0 then
        return damage, 0
    end

    local consumed = math.min(math.abs(damage), amount)
    local remaining = math.abs(damage) - consumed
    if remaining <= 0 then
        return 0, consumed
    end

    if damage < 0 then
        return -remaining, consumed
    end
    return remaining, consumed
end

local function reduceSplitDamageByAmount(primaryDamage, secondaryDamage, amount)
    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then
        return primaryDamage, secondaryDamage, 0
    end

    local absorbed = 0
    primaryDamage, absorbed = reduceDamageByAmount(primaryDamage, amount)
    amount = amount - absorbed

    local secondaryAbsorbed = 0
    secondaryDamage, secondaryAbsorbed = reduceDamageByAmount(secondaryDamage, amount)
    absorbed = absorbed + secondaryAbsorbed

    return primaryDamage, secondaryDamage, absorbed
end

local function showWarcryShieldAbsorb(player, absorbed)
    if not player or absorbed <= 0 then
        return
    end

    local position = player:getPosition()
    if not position then
        return
    end

    for _, spectator in ipairs(Game.getSpectators(position, false, true, 8, 8, 6, 6) or {}) do
        if spectator and spectator:isPlayer() then
            spectator:sendTextMessage(MESSAGE_DAMAGE_DEALT, "", position, absorbed, TEXTCOLOR_SKYBLUE)
        end
    end
end

local function getWarcryShieldRuntime(player)
    if not player then
        return nil
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return nil
    end

    local state = warcryShieldState[playerId]
    if not state then
        return nil
    end

    local now = os.time()
    if (state.expiresAt or 0) < now or (tonumber(state.amount) or 0) <= 0 then
        warcryShieldState[playerId] = nil
        return nil
    end

    return state
end

local function grantWarcryShieldRuntime(player, shieldAmount, duration)
    if not player then
        return 0
    end

    shieldAmount = math.max(0, tonumber(shieldAmount) or 0)
    duration = math.max(1, tonumber(duration) or 1)
    if shieldAmount <= 0 then
        return 0
    end

    local playerId = player:getId()
    if not playerId or playerId <= 0 then
        return 0
    end

    local existingAmount = tonumber(warcryShieldState[playerId] and warcryShieldState[playerId].amount) or 0
    warcryShieldState[playerId] = {
        amount = math.max(shieldAmount, existingAmount),
        expiresAt = os.time() + duration,
    }
    return warcryShieldState[playerId].amount
end

function _G.GemsSocket_advancedGrantRuntimeShield(player, shieldAmount, duration, effect)
    local amount = grantWarcryShieldRuntime(player, shieldAmount, duration)
    if amount > 0 and player and player:isPlayer() then
        player:getPosition():sendMagicEffect(effect or CONST_ME_HOLYAREA)
    end
    return amount
end

local function scaleAmount(baseValue, percent)
    baseValue = tonumber(baseValue) or 0
    percent = tonumber(percent) or 0
    if baseValue <= 0 or percent <= 0 then
        return 0
    end
    return math.max(1, math.floor(baseValue * (percent / 100)))
end

local function addScaledDamage(damage, percent)
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

local function reduceOutgoingDamage(damage, percent)
    damage = tonumber(damage) or 0
    percent = tonumber(percent) or 0
    if damage == 0 or percent <= 0 then
        return damage
    end

    local multiplier = math.max(0, 1 - (percent / 100))
    if multiplier <= 0 then
        return 0
    end

    local scaled = math.floor(math.abs(damage) * multiplier + 0.5)
    if scaled <= 0 and math.abs(damage) > 0 then
        scaled = 1
    end

    if damage < 0 then
        return -scaled
    end

    if damage > 0 then
        return scaled
    end

    return 0
end

local function getSpecialConfig(key)
    local special = GemsSocket and GemsSocket.SPECIALS and GemsSocket.SPECIALS[key] or nil
    return type(special) == "table" and special or {}
end

local function isNormalMonster(creature)
    if not creature or not creature:isMonster() then
        return false
    end
    if type(_G.GemsSocket_isNormalMonster) == "function" then
        return _G.GemsSocket_isNormalMonster(creature)
    end
    return not (creature.getMaster and creature:getMaster())
end

local function isBossMonster(monster)
    if not monster or not monster.isMonster or not monster:isMonster() then
        return false
    end
    local monsterType = monster:getType()
    if not monsterType then
        return false
    end
    for _, methodName in ipairs({ "isRewardBoss", "isBoss" }) do
        local method = monsterType[methodName]
        if type(method) == "function" then
            local ok, result = pcall(method, monsterType)
            if ok and result then
                return true
            end
        end
    end
    if type(monster.isBoss) == "function" then
        local ok, result = pcall(monster.isBoss, monster)
        if ok and result then
            return true
        end
    end
    return false
end

local function getNearbyMonsters(centerPosition, range, excludedCreature)
    local monsters = {}
    if not centerPosition then
        return monsters
    end

    for _, creature in ipairs(Game.getSpectators(centerPosition, false, false, range, range, range, range) or {}) do
        if creature ~= excludedCreature and isNormalMonster(creature) then
            monsters[#monsters + 1] = creature
        end
    end
    return monsters
end

local function sendAreaEffects(centerPosition, radius, effect)
    if not centerPosition then
        return
    end

    radius = math.max(0, tonumber(radius) or 0)
    effect = effect or CONST_ME_HOLYAREA
    for x = centerPosition.x - radius, centerPosition.x + radius do
        for y = centerPosition.y - radius, centerPosition.y + radius do
            local position = Position(x, y, centerPosition.z)
            if Tile(position) then
                position:sendMagicEffect(effect)
            end
        end
    end
end

local function isPositionInSquare(centerPosition, position, radius)
    if not centerPosition or not position or centerPosition.z ~= position.z then
        return false
    end

    radius = math.max(0, tonumber(radius) or 0)
    return math.abs(position.x - centerPosition.x) <= radius
        and math.abs(position.y - centerPosition.y) <= radius
end

local function pickNearbyMonsters(centerPosition, range, maxTargets, excludedCreature)
    local candidates = getNearbyMonsters(centerPosition, range, excludedCreature)
    local picked = {}
    maxTargets = math.max(0, tonumber(maxTargets) or 0)
    while #candidates > 0 and #picked < maxTargets do
        local index = math.random(#candidates)
        picked[#picked + 1] = table.remove(candidates, index)
    end
    return picked
end

local elementalEffects = {}
if COMBAT_FIREDAMAGE then elementalEffects[COMBAT_FIREDAMAGE] = CONST_ME_FIREAREA end
if COMBAT_ICEDAMAGE then elementalEffects[COMBAT_ICEDAMAGE] = CONST_ME_ICEATTACK end
if COMBAT_ENERGYDAMAGE then elementalEffects[COMBAT_ENERGYDAMAGE] = CONST_ME_ENERGYHIT end
if COMBAT_EARTHDAMAGE then elementalEffects[COMBAT_EARTHDAMAGE] = CONST_ME_SMALLPLANTS end
if COMBAT_DEATHDAMAGE then elementalEffects[COMBAT_DEATHDAMAGE] = CONST_ME_MORTAREA end
if COMBAT_HOLYDAMAGE then elementalEffects[COMBAT_HOLYDAMAGE] = CONST_ME_HOLYDAMAGE end
if COMBAT_WATERDAMAGE then elementalEffects[COMBAT_WATERDAMAGE] = CONST_ME_LOSEENERGY end
if COMBAT_DROWNDAMAGE then elementalEffects[COMBAT_DROWNDAMAGE] = CONST_ME_LOSEENERGY end
if COMBAT_ARCANEDAMAGE then elementalEffects[COMBAT_ARCANEDAMAGE] = CONST_ME_PURPLEENERGY end

local function isElementalType(combatType)
    return elementalEffects[combatType] ~= nil
end

local function isEnergyDamageType(combatType)
    return combatType == COMBAT_ENERGYDAMAGE
end

local function isSpellOrigin(origin)
    if origin == ORIGIN_CONDITION or origin == ORIGIN_MELEE or origin == ORIGIN_RANGED then
        return false
    end
    if ORIGIN_WAND and origin == ORIGIN_WAND then
        return false
    end
    return origin ~= nil
end

local function isPaladin(player)
    local vocation = player and player:getVocation()
    local name = vocation and vocation:getName() or ""
    return tostring(name):lower():find("paladin", 1, true) ~= nil
end

local function isDistanceWeapon(item)
    if not item or not item:isItem() then
        return false
    end

    local itemType = item:getType()
    if not itemType then
        return false
    end

    local weaponType = itemType:getWeaponType()
    return weaponType == WEAPON_DISTANCE or weaponType == WEAPON_AMMO
end

local function playerHasDistanceWeaponEquipped(player)
    if not player or not player:isPlayer() then
        return false
    end

    return isDistanceWeapon(player:getSlotItem(CONST_SLOT_LEFT))
        or isDistanceWeapon(player:getSlotItem(CONST_SLOT_RIGHT))
        or isDistanceWeapon(player:getSlotItem(CONST_SLOT_AMMO))
end

local function isVolleyChainHit(player, origin)
    if ORIGIN_RANGED and origin == ORIGIN_RANGED then
        return true
    end

    if origin == ORIGIN_MELEE or origin == ORIGIN_CONDITION or isSpellOrigin(origin) then
        return false
    end

    return playerHasDistanceWeaponEquipped(player)
end

local function arePartyLinkedPlayers(firstPlayer, secondPlayer)
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

local function getPartyPlayersInRange(owner, range)
    local players = {}
    if not owner or not owner:isPlayer() then
        return players
    end

    local ownerPosition = owner:getPosition()
    if not ownerPosition then
        return players
    end

    range = math.max(0, tonumber(range) or 0)
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

local function getPartyRoster(player)
    local players = {}
    if not player or not player:isPlayer() then
        return players
    end

    local party = player:getParty()
    if not party then
        return { player }
    end

    local leader = party:getLeader()
    if leader and leader:isPlayer() then
        players[#players + 1] = leader
    end

    for _, member in ipairs(party:getMembers() or {}) do
        if member and member:isPlayer() and member ~= leader then
            players[#players + 1] = member
        end
    end

    return players
end

local function updateTideMode()
    local special = getSpecialConfig("tide")
    local startHour = math.max(0, math.min(23, tonumber(special.peakStartHour) or 18))
    local endHour = math.max(0, math.min(23, tonumber(special.peakEndHour) or 23))
    local hour = tonumber(os.date("%H")) or 0

    if startHour <= endHour then
        tideMode = (hour >= startHour and hour < endHour) and "peak" or "offpeak"
    else
        tideMode = (hour >= startHour or hour < endHour) and "peak" or "offpeak"
    end
    tideLastCheck = os.time()
end

local function runTideCheck()
    updateTideMode()
    local interval = math.max(60, tonumber(getSpecialConfig("tide").checkIntervalSeconds) or 600)
    addEvent(runTideCheck, interval * 1000)
end

local function ensureTideTimer()
    if tideTimerStarted then
        return
    end

    tideTimerStarted = true
    updateTideMode()
    addEvent(runTideCheck, math.max(60, tonumber(getSpecialConfig("tide").checkIntervalSeconds) or 600) * 1000)
end

local function getTideMode()
    ensureTideTimer()
    local interval = math.max(60, tonumber(getSpecialConfig("tide").checkIntervalSeconds) or 600)
    if os.time() - tideLastCheck >= interval then
        updateTideMode()
    end
    return tideMode
end

TideGem = TideGem or {}

function TideGem.isGem(gemKey)
    return gemKey == "tidegem"
end

function TideGem.getCompactProgress(player)
    if not player or not player:isPlayer() then
        return "Tide: Offpeak  EXP +0%"
    end

    if getTideMode() == "peak" then
        local rarity = math.max(0, getEquippedSocketBonusTotal(player, "socket_tide_loot_percent"))
        return string.format("Tide: Peak  Rarity +%s%%", tostring(rarity))
    end

    local experience = math.max(0, getEquippedSocketBonusTotal(player, "socket_tide_xp_percent"))
    return string.format("Tide: Offpeak  EXP +%s%%", tostring(experience))
end

function TideGem.buildTooltip(baseTooltip, player)
    return string.format("%s\n%s", tostring(baseTooltip or ""), TideGem.getCompactProgress(player))
end

local function getFormationReduction(player, bonusCache)
    if not player or not player:isPlayer() then
        return 0
    end

    local playerPosition = player:getPosition()
    if not playerPosition then
        return 0
    end

    local roster = getPartyRoster(player)
    local bestReduction = 0
    for _, carrier in ipairs(roster) do
        local carrierCache = carrier == player and bonusCache
            or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(carrier) or nil)
        local carrierTotals = carrierCache and carrierCache.totals or {}
        local perMember = math.max(0, carrierTotals.socket_formation_defense_per_member or 0)
        if perMember > 0 then
            local range = math.max(1, carrierTotals.socket_formation_range or 0)
            local maxMembers = math.max(1, carrierTotals.socket_formation_max_members or 0)
            local carrierPosition = carrier:getPosition()
            if carrierPosition and playerPosition:getDistance(carrierPosition) <= range then
                local nearbyMembers = 0
                for _, member in ipairs(roster) do
                    local memberPosition = member ~= carrier and member:getPosition() or nil
                    if memberPosition and carrierPosition:getDistance(memberPosition) <= range then
                        nearbyMembers = nearbyMembers + 1
                    end
                end
                if nearbyMembers > 0 then
                    bestReduction = math.max(bestReduction, math.min(nearbyMembers, maxMembers) * perMember)
                end
            end
        end
    end

    return bestReduction
end

local function damageMonstersInSquare(player, centerPosition, range, damage, effect, combatType)
    if not player or not centerPosition or damage <= 0 then
        return
    end

    centerPosition:sendMagicEffect(effect or CONST_ME_ENERGYAREA)
    range = math.max(1, tonumber(range) or 1)
    for _, monster in ipairs(getNearbyMonsters(centerPosition, range)) do
        local monsterPosition = monster:getPosition()
        if monsterPosition and math.abs(monsterPosition.x - centerPosition.x) <= range
            and math.abs(monsterPosition.y - centerPosition.y) <= range
            and monsterPosition.z == centerPosition.z then
            doTargetCombatHealth(player, monster, combatType or COMBAT_ENERGYDAMAGE, -damage, -damage, effect or CONST_ME_ENERGYHIT)
        end
    end
end

local function releaseAnchorShockwave(player, stacks, totals)
    totals = totals or {}
    local perLevel = math.max(0, totals.socket_anchor_damage_per_level_per_stack or 0)
    local range = math.max(1, totals.socket_anchor_range or 0)
    local damage = math.max(0, math.floor(player:getLevel() * perLevel * math.max(0, stacks or 0)))
    if damage <= 0 then
        return
    end

    damageMonstersInSquare(player, player:getPosition(), range, damage, CONST_ME_PURPLEENERGY, COMBAT_ARCANEDAMAGE)
end

local function lastBreathUsesProc(totals)
    return (totals.socket_last_breath_cooldown or 0) > 0
end

local function tryActivateLastBreath(player, totals)
    local perSecond = math.max(0, totals.socket_last_breath_percent_per_second or 0)
    if perSecond <= 0 then
        return false
    end

    local threshold = math.max(1, totals.socket_last_breath_threshold or 0)
    local healthPercent = player:getMaxHealth() > 0 and ((player:getHealth() / player:getMaxHealth()) * 100) or 100
    if healthPercent >= threshold then
        return false
    end

    local playerId = player:getId()
    local state = lastBreathState[playerId] or { percent = 0, cooldownUntil = 0 }
    lastBreathState[playerId] = state
    if state.active then
        return true
    end

    local now = os.time()
    if now < (state.cooldownUntil or 0) then
        return false
    end

    state.active = true
    state.percent = math.max(perSecond, tonumber(state.percent) or 0)
    state.cooldownUntil = now + math.max(0, totals.socket_last_breath_cooldown or 0)
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Last Breath awakens.")
    ensureAdvancedGemPulse(player)
    return true
end

local function runAdvancedGemPulse(playerId, token)
    local player = Player(playerId)
    if not player or advancedPulseTokens[playerId] ~= token then
        return
    end
    if type(_G.GemsSocketBonusCache) == "table" then
        _G.GemsSocketBonusCache.bumpMetric("advanced_pulses")
    end

    local bonusCache = getSocketBonusCache(player)
    local totals = bonusCache and bonusCache.totals or {}

    local lastBreathPerSecond = math.max(0, totals.socket_last_breath_percent_per_second or 0)
    if lastBreathPerSecond > 0 then
        local threshold = math.max(1, totals.socket_last_breath_threshold or 0)
        local resetThreshold = math.max(threshold, totals.socket_last_breath_reset_threshold or 0)
        local maxPercent = math.max(lastBreathPerSecond, totals.socket_last_breath_max_percent or 0)
        local healPercent = math.max(0, totals.socket_last_breath_heal_percent_per_second or 0)
        local usesProc = lastBreathUsesProc(totals)
        local healthPercent = player:getMaxHealth() > 0 and ((player:getHealth() / player:getMaxHealth()) * 100) or 100
        local state = lastBreathState[playerId] or { percent = 0, cooldownUntil = 0 }
        lastBreathState[playerId] = state
        if healthPercent < threshold and (not usesProc or state.active) then
            state.percent = math.min(maxPercent, math.max(0, tonumber(state.percent) or 0) + lastBreathPerSecond)
            if healPercent > 0 and player:getHealth() < player:getMaxHealth() then
                local healAmount = math.max(1, math.floor(player:getMaxHealth() * healPercent / 100))
                player:addHealth("healing", healAmount)
                player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
            end
        elseif healthPercent > resetThreshold then
            state.percent = 0
            state.active = false
        end
    else
        lastBreathState[playerId] = nil
    end

    local maxAnchorStacks = math.max(0, totals.socket_anchor_max_stacks or 0)
    if maxAnchorStacks > 0 then
        local position = player:getPosition()
        local state = anchorState[playerId] or { stacks = 0, stationarySeconds = 0 }
        anchorState[playerId] = state
        if state.x ~= nil then
            local dx = math.abs(position.x - state.x)
            local dy = math.abs(position.y - state.y)
            local distance = math.max(dx, dy)
            local teleported = position.z ~= state.z or distance > 1

            if teleported then
                state.stacks = 0
                state.stationarySeconds = 0
            elseif distance > 0 then
                local consumedStacks = math.max(0, tonumber(state.stacks) or 0)
                state.stacks = 0
                state.stationarySeconds = 0
                if consumedStacks > 0 then
                    releaseAnchorShockwave(player, consumedStacks, totals)
                end
            else
                local interval = math.max(1, totals.socket_anchor_stack_interval or 0)
                state.stationarySeconds = math.max(0, tonumber(state.stationarySeconds) or 0) + 1
                if state.stationarySeconds >= interval then
                    state.stationarySeconds = 0
                    state.stacks = math.min(maxAnchorStacks, math.max(0, tonumber(state.stacks) or 0) + 1)
                end
            end
        end
        state.x, state.y, state.z = position.x, position.y, position.z
    else
        anchorState[playerId] = nil
    end

    local momentumPerTile = math.max(0, totals.socket_momentum_per_tile or 0)
    if momentumPerTile > 0 then
        local position = player:getPosition()
        local state = momentumState[playerId] or { charge = 0, stationarySeconds = 0, armed = false }
        momentumState[playerId] = state
        if position and state.x ~= nil then
            local dx = math.abs(position.x - state.x)
            local dy = math.abs(position.y - state.y)
            local distance = math.max(dx, dy)
            local teleported = position.z ~= state.z or distance > 8
            if teleported then
                if not state.armed then
                    state.charge = 0
                end
                state.stationarySeconds = 0
            elseif distance > 0 then
                if not state.armed then
                    local maxCharge = math.max(1, totals.socket_momentum_max or 0)
                    state.charge = math.min(maxCharge, math.max(0, tonumber(state.charge) or 0) + (distance * momentumPerTile))
                end
                state.stationarySeconds = 0
            elseif not state.armed and (tonumber(state.charge) or 0) > 0 then
                state.stationarySeconds = math.max(0, tonumber(state.stationarySeconds) or 0) + 1
                local stopSeconds = math.max(1, totals.socket_momentum_stop_seconds or 0)
                if state.stationarySeconds >= stopSeconds then
                    state.armed = true
                    player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
                    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Momentum Gem arms %d stored Momentum for your next offensive spell.", state.charge))
                end
            end
        end
        if position then
            state.x, state.y, state.z = position.x, position.y, position.z
        end
        MomentumGem.refreshEquipped(player)
    else
        momentumState[playerId] = nil
    end

    local pacifistPerInterval = math.max(0, totals.socket_pacifist_percent_per_interval or 0)
    if pacifistPerInterval > 0 then
        local interval = math.max(1, totals.socket_pacifist_interval or 0)
        local maxPercent = math.max(pacifistPerInterval, totals.socket_pacifist_max_percent or 0)
        local state = pacifistState[playerId] or { elapsed = 0, percent = 0 }
        pacifistState[playerId] = state
        state.elapsed = math.max(0, tonumber(state.elapsed) or 0) + 1
        if state.elapsed >= interval then
            state.elapsed = 0
            state.percent = math.min(maxPercent, math.max(0, tonumber(state.percent) or 0) + pacifistPerInterval)
        end
    else
        pacifistState[playerId] = nil
    end

    local carrion = carrionState[playerId]
    if carrion then
        local now = os.time()
        local changed = false
        if (totals.socket_carrion_frenzy_duration or 0) <= 0 then
            carrionState[playerId] = nil
            CarrionGem.refreshEquipped(player, nil)
        else
            if (tonumber(carrion.chainUntil) or 0) > 0 and now > (tonumber(carrion.chainUntil) or 0) then
                carrion.chainKills = 0
                carrion.chainUntil = 0
                changed = true
            end
            if (tonumber(carrion.frenzyUntil) or 0) > 0 and now > (tonumber(carrion.frenzyUntil) or 0) then
                carrion.frenzyUntil = 0
                changed = true
            end
            if changed then
                CarrionGem.refreshEquipped(player, carrion)
            end
        end
    end

    if damageGemDirty[playerId] and type(_G.DamageGem) == "table" and type(_G.DamageGem.refreshEquipped) == "function" then
        _G.DamageGem.refreshEquipped(player)
        damageGemDirty[playerId] = nil
    end

    if advancedPulseTokens[playerId] == token and playerNeedsAdvancedGemPulse(player) then
        addEvent(runAdvancedGemPulse, 1000, playerId, token)
    else
        advancedPulseTokens[playerId] = nil
    end
end

playerNeedsAdvancedGemPulse = function(player)
    if not player or not player:isPlayer() then
        return false
    end

    local playerId = player:getId()
    if damageGemDirty[playerId] or carrionState[playerId] then
        return true
    end
    if lastBreathState[playerId] or anchorState[playerId] or momentumState[playerId] or pacifistState[playerId] then
        return true
    end

    local bonusCache = getSocketBonusCache(player)
    local totals = bonusCache and bonusCache.totals or {}
    return (totals.socket_last_breath_percent_per_second or 0) > 0
        or (totals.socket_anchor_max_stacks or 0) > 0
        or (totals.socket_momentum_per_tile or 0) > 0
        or (totals.socket_pacifist_percent_per_interval or 0) > 0
end

ensureAdvancedGemPulse = function(player)
    if not player or not player:isPlayer() or not playerNeedsAdvancedGemPulse(player) then
        return
    end

    local playerId = player:getId()
    if advancedPulseTokens[playerId] then
        return
    end

    advancedPulseSerial = advancedPulseSerial + 1
    advancedPulseTokens[playerId] = advancedPulseSerial
    addEvent(runAdvancedGemPulse, 1000, playerId, advancedPulseTokens[playerId])
end

local function getLastBreathPercent(player, totals)
    local perSecond = totals and (totals.socket_last_breath_percent_per_second or 0)
        or getEquippedSocketBonusTotal(player, "socket_last_breath_percent_per_second")
    if perSecond <= 0 then
        return 0
    end

    local playerId = player:getId()
    local state = lastBreathState[playerId]
    if not state then
        if totals and lastBreathUsesProc(totals) then
            return 0
        end
        local threshold = math.max(1, totals and (totals.socket_last_breath_threshold or 0)
            or getEquippedSocketBonusTotal(player, "socket_last_breath_threshold"))
        local healthPercent = player:getMaxHealth() > 0 and ((player:getHealth() / player:getMaxHealth()) * 100) or 100
        if healthPercent < threshold then
            lastBreathState[playerId] = { percent = math.max(0, perSecond), active = true }
            state = lastBreathState[playerId]
            ensureAdvancedGemPulse(player)
        end
    end
    return math.max(0, tonumber(state and state.percent) or 0)
end

local function applyLastBreathDamage(player, primaryDamage, secondaryDamage, totals)
    local percent = getLastBreathPercent(player, totals)
    if percent <= 0 then
        return primaryDamage, secondaryDamage
    end
    return addScaledDamage(primaryDamage, percent), addScaledDamage(secondaryDamage, percent)
end

local function clearMomentumSpell(playerId, token)
    local state = momentumState[playerId]
    if state and state.pendingToken == token then
        state.pendingPercent = nil
        state.pendingToken = nil
    end
end

local function prepareMomentumSpell(player)
    local state = momentumState[player:getId()]
    local charge = math.max(0, tonumber(state and state.charge) or 0)
    if not state or not state.armed or charge <= 0 then
        return
    end
    local tilesPerPercent = math.max(1, getEquippedSocketBonusTotal(player, "socket_momentum_tiles_per_percent"))
    local maxPercent = math.max(0, getEquippedSocketBonusTotal(player, "socket_momentum_max_damage_percent"))
    local percent = math.min(maxPercent, charge / tilesPerPercent)
    state.charge = 0
    state.stationarySeconds = 0
    state.armed = false
    if percent <= 0 then
        return
    end
    state.pendingToken = math.max(0, tonumber(state.pendingToken) or 0) + 1
    state.pendingPercent = percent
    addEvent(clearMomentumSpell, 3000, player:getId(), state.pendingToken)
    player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Momentum Gem releases +%.1f%% spell damage.", percent))
end

local function applyMomentumDamage(player, origin, primaryDamage, secondaryDamage)
    if not isSpellOrigin(origin) then
        return primaryDamage, secondaryDamage
    end
    local state = momentumState[player:getId()]
    local percent = math.max(0, tonumber(state and state.pendingPercent) or 0)
    if percent <= 0 then
        return primaryDamage, secondaryDamage
    end
    state.pendingPercent = nil
    state.pendingToken = nil
    return addScaledDamage(primaryDamage, percent), addScaledDamage(secondaryDamage, percent)
end

local function tryTriggerWayfinder(player)
    local speed = math.max(0, getEquippedSocketBonusTotal(player, "socket_wayfinder_speed"))
    if speed <= 0 then
        return
    end

    local playerId = player:getId()
    local now = os.time()
    local state = wayfinderState[playerId] or {}
    if now < (state.cooldownUntil or 0) then
        return
    end

    local duration = math.max(1, getEquippedSocketBonusTotal(player, "socket_wayfinder_duration"))
    local cooldown = math.max(duration, getEquippedSocketBonusTotal(player, "socket_wayfinder_cooldown"))
    local effect = getEquippedSocketBonusTotal(player, "socket_wayfinder_effect")

    player:removeCondition(CONDITION_HASTE, CONDITIONID_DEFAULT, WAYFINDER_SUBID, true)
    local condition = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
    condition:setParameter(CONDITION_PARAM_SUBID, WAYFINDER_SUBID)
    condition:setParameter(CONDITION_PARAM_TICKS, duration * 1000)
    condition:setParameter(CONDITION_PARAM_SPEED, speed)
    player:addCondition(condition)

    player:getPosition():sendMagicEffect(effect > 0 and effect or CONST_ME_MAGIC_BLUE)
    wayfinderState[playerId] = { cooldownUntil = now + cooldown }
end

MomentumGem = MomentumGem or { gemKey = "momentumgem" }

function MomentumGem.isGem(gemKey)
    return gemKey == MomentumGem.gemKey
end

function MomentumGem.getCompactProgress(player)
    if not player or not player:isPlayer() then
        return "Momentum: 0"
    end

    local state = momentumState[player:getId()]
    local charge = math.max(0, math.floor(tonumber(state and state.charge) or 0))
    local maxCharge = math.max(0, getEquippedSocketBonusTotal(player, "socket_momentum_max"))
    local armed = state and state.armed and " Armed" or ""
    if maxCharge > 0 then
        return string.format("Momentum: %d/%d%s", charge, maxCharge, armed)
    end
    return string.format("Momentum: %d%s", charge, armed)
end

function MomentumGem.refreshEquipped(player)
    if not player or not player:isPlayer() or type(_G.setSocketGemDisplayData) ~= "function" then
        return
    end

    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[MomentumGem.gemKey] or nil
    if not gemData then
        return
    end

    forEachEquippedGemSocket(player, MomentumGem.gemKey, function(item, socketIndex)
        _G.setSocketGemDisplayData(item, socketIndex, gemData, player)
        if type(_G.GemsSocket_refreshSocketDisplay) == "function" then
            _G.GemsSocket_refreshSocketDisplay(item)
        elseif type(_G.refreshSocketItem) == "function" then
            _G.refreshSocketItem(item)
        end
    end)
end

local function clearBloodPriceCast(playerId, token)
    local state = bloodPriceState[playerId]
    if state and state.token == token then
        bloodPriceState[playerId] = nil
    end
end

function _G.GemsSocket_getBloodPriceHealthCost(player, spellGroup, aggressive, manaCost, missingMana)
    if not player or not player:isPlayer() then
        return 0
    end

    spellGroup = tostring(spellGroup or ""):lower()
    missingMana = math.max(0, math.floor(tonumber(missingMana) or 0))
    manaCost = math.max(0, math.floor(tonumber(manaCost) or 0))
    if missingMana <= 0 or manaCost <= 0 or not aggressive or spellGroup ~= "attack" then
        return 0
    end

    local healthPerMana = math.max(0, getEquippedSocketBonusTotal(player, "socket_blood_price_health_per_mana"))
    local damagePercent = math.max(0, getEquippedSocketBonusTotal(player, "socket_blood_price_damage_percent"))
    if healthPerMana <= 0 or damagePercent <= 0 then
        return 0
    end

    local healthCost = math.max(1, math.ceil(missingMana * healthPerMana))
    if healthCost >= player:getHealth() then
        return 0
    end

    return healthCost
end

function _G.GemsSocket_prepareBloodPriceCast(player, spellGroup, aggressive, manaCost, healthCost)
    if not player or not player:isPlayer() then
        return
    end

    local playerId = player:getId()
    bloodPriceState[playerId] = nil
    spellGroup = tostring(spellGroup or ""):lower()
    manaCost = math.max(0, math.floor(tonumber(manaCost) or 0))
    healthCost = math.max(0, math.floor(tonumber(healthCost) or 0))
    if healthCost <= 0 or manaCost <= 0 or not aggressive or spellGroup ~= "attack" then
        return
    end

    local damagePercent = math.max(0, getEquippedSocketBonusTotal(player, "socket_blood_price_damage_percent"))
    if damagePercent <= 0 then
        return
    end

    bloodPriceSerial = bloodPriceSerial + 1
    local token = bloodPriceSerial
    bloodPriceState[playerId] = {
        token = token,
        damagePercent = damagePercent,
    }
    addEvent(clearBloodPriceCast, 1000, playerId, token)
end

local function applyBloodPriceDamage(player, origin, primaryDamage, secondaryDamage)
    if not isSpellOrigin(origin) then
        return primaryDamage, secondaryDamage
    end

    local state = bloodPriceState[player:getId()]
    local percent = math.max(0, tonumber(state and state.damagePercent) or 0)
    if percent <= 0 then
        return primaryDamage, secondaryDamage
    end
    return addScaledDamage(primaryDamage, percent), addScaledDamage(secondaryDamage, percent)
end

local function getPacifistPercent(player)
    if getEquippedSocketBonusTotal(player, "socket_pacifist_percent_per_interval") <= 0 then
        return 0
    end
    local state = pacifistState[player:getId()]
    return math.max(0, tonumber(state and state.percent) or 0)
end

local function resetPacifistPower(player)
    local state = pacifistState[player:getId()]
    if state then
        state.elapsed = 0
        state.percent = 0
    end
end

CarrionGem = {
    gemKey = "carriongem",
}

function CarrionGem.isGem(gemKey)
    return gemKey == CarrionGem.gemKey
end

function CarrionGem.getSettings(player)
    local required = getEquippedSocketBonusTotal(player, "socket_carrion_chain_required")
    local window = getEquippedSocketBonusTotal(player, "socket_carrion_chain_window")
    local duration = getEquippedSocketBonusTotal(player, "socket_carrion_frenzy_duration")
    local spellCooldownMs = getEquippedSocketBonusTotal(player, "socket_carrion_spell_cooldown_ms")
    if required <= 0 or window <= 0 or duration <= 0 then
        return nil
    end

    return {
        required = math.max(1, required),
        window = math.max(1, window),
        duration = math.max(1, duration),
        spellCooldownMs = math.max(0, spellCooldownMs),
    }
end

function CarrionGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_carrion_", socketIndex)
    end
    return "carrion_"
end

function CarrionGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = CarrionGem.getAttributePrefix(socketIndex)
    local chainKills = math.max(0, tonumber(item:getCustomAttribute(prefix .. "chain_kills")) or 0)
    local chainUntil = math.max(0, tonumber(item:getCustomAttribute(prefix .. "chain_until")) or 0)
    local frenzyUntil = math.max(0, tonumber(item:getCustomAttribute(prefix .. "frenzy_until")) or 0)
    if chainKills <= 0 and chainUntil <= 0 and frenzyUntil <= 0 then
        return nil
    end

    return {
        chainKills = chainKills,
        chainUntil = chainUntil,
        frenzyUntil = frenzyUntil,
    }
end

function CarrionGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = CarrionGem.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "chain_kills")
    item:removeCustomAttribute(prefix .. "chain_until")
    item:removeCustomAttribute(prefix .. "frenzy_until")
end

function CarrionGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    CarrionGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local prefix = CarrionGem.getAttributePrefix(socketIndex)
    local chainKills = math.max(0, tonumber(state.chainKills) or 0)
    local chainUntil = math.max(0, tonumber(state.chainUntil) or 0)
    local frenzyUntil = math.max(0, tonumber(state.frenzyUntil) or 0)
    if chainKills > 0 then item:setCustomAttribute(prefix .. "chain_kills", chainKills) end
    if chainUntil > 0 then item:setCustomAttribute(prefix .. "chain_until", chainUntil) end
    if frenzyUntil > 0 then item:setCustomAttribute(prefix .. "frenzy_until", frenzyUntil) end
end

function CarrionGem.getCompactProgress(state)
    local now = os.time()
    state = type(state) == "table" and state or {}
    local frenzyLeft = math.max(0, (tonumber(state.frenzyUntil) or 0) - now)
    if frenzyLeft > 0 then
        return string.format("Carrion Frenzy: %ds", frenzyLeft)
    end

    local chainLeft = math.max(0, (tonumber(state.chainUntil) or 0) - now)
    local chainKills = chainLeft > 0 and math.max(0, tonumber(state.chainKills) or 0) or 0
    return string.format("Carrion Chain: %d kills", chainKills)
end

function CarrionGem.buildTooltip(baseTooltip, state)
    return string.format("%s\n%s", tostring(baseTooltip or ""), CarrionGem.getCompactProgress(state))
end

function CarrionGem.refreshEquipped(player, state)
    if not player then
        return
    end

    forEachEquippedGemSocket(player, CarrionGem.gemKey, function(item, socketIndex)
        CarrionGem.writeState(item, socketIndex, state)
        refreshStatefulSocket(item, socketIndex, CarrionGem.gemKey)
    end)
end

function CarrionGem.recordKill(player, target)
    if not player or not player:isPlayer() or not isNormalMonster(target) then
        return
    end

    local settings = CarrionGem.getSettings(player)
    if not settings then
        carrionState[player:getId()] = nil
        return
    end

    local now = os.time()
    local playerId = player:getId()
    local state = carrionState[playerId] or { chainKills = 0, chainUntil = 0, frenzyUntil = 0 }
    carrionState[playerId] = state

    if now > (state.chainUntil or 0) then
        state.chainKills = 0
    end

    state.chainKills = math.max(0, tonumber(state.chainKills) or 0) + 1
    state.chainUntil = now + settings.window
    if state.chainKills >= settings.required then
        state.chainKills = 0
        state.chainUntil = 0
        state.frenzyUntil = now + settings.duration
        player:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Carrion Frenzy surges through your spells.")
    end

    CarrionGem.refreshEquipped(player, state)
end

function _G.GemsSocket_getCarrionSpellCooldownMs(player, spellName, spellGroup, aggressive, cooldownType, currentCooldown)
    if not player or not player:isPlayer() or not aggressive then
        return nil
    end

    spellGroup = tostring(spellGroup or ""):lower()
    if spellGroup ~= "attack" then
        return nil
    end

    local state = carrionState[player:getId()]
    if not state or os.time() > (tonumber(state.frenzyUntil) or 0) then
        if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.getSpellCooldownMs) == "function" then
            return _G.ExtraSocketGems.getSpellCooldownMs(player, currentCooldown)
        end
        return nil
    end

    if getEquippedSocketBonusTotal(player, "socket_carrion_frenzy_duration") <= 0 then
        carrionState[player:getId()] = nil
        if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.getSpellCooldownMs) == "function" then
            return _G.ExtraSocketGems.getSpellCooldownMs(player, currentCooldown)
        end
        return nil
    end

    local cooldown = math.max(0, getEquippedSocketBonusTotal(player, "socket_carrion_spell_cooldown_ms"))
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.getSpellCooldownMs) == "function" then
        return _G.ExtraSocketGems.getSpellCooldownMs(player, cooldown) or cooldown
    end
    return cooldown
end

local function getPlayerAttacker(attacker)
    if not attacker or not attacker.isCreature or not attacker:isCreature() then
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

NemesisBrandGem = {
    gemKey = "nemesisbrandgem",
}

function NemesisBrandGem.isGem(gemKey)
    return gemKey == NemesisBrandGem.gemKey
end

function NemesisBrandGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_nemesis_", socketIndex)
    end
    return "nemesis_"
end

function NemesisBrandGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = NemesisBrandGem.getAttributePrefix(socketIndex)
    local targetGuid = math.max(0, tonumber(item:getCustomAttribute(prefix .. "target_guid")) or 0)
    local targetName = item:getCustomAttribute(prefix .. "target_name")
    local expiresAt = math.max(0, tonumber(item:getCustomAttribute(prefix .. "expires_at")) or 0)
    if type(targetName) ~= "string" or targetName == "" then
        targetName = nil
    end
    if targetGuid <= 0 and not targetName and expiresAt <= 0 then
        return nil
    end

    return {
        targetGuid = targetGuid,
        targetName = targetName,
        expiresAt = expiresAt,
    }
end

function NemesisBrandGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = NemesisBrandGem.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "target_guid")
    item:removeCustomAttribute(prefix .. "target_name")
    item:removeCustomAttribute(prefix .. "expires_at")
end

function NemesisBrandGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    NemesisBrandGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local prefix = NemesisBrandGem.getAttributePrefix(socketIndex)
    local targetGuid = math.max(0, tonumber(state.targetGuid) or 0)
    local targetName = type(state.targetName) == "string" and state.targetName or nil
    local expiresAt = math.max(0, tonumber(state.expiresAt) or 0)
    if targetGuid > 0 then item:setCustomAttribute(prefix .. "target_guid", targetGuid) end
    if targetName and targetName ~= "" then item:setCustomAttribute(prefix .. "target_name", targetName) end
    if expiresAt > 0 then item:setCustomAttribute(prefix .. "expires_at", expiresAt) end
end

function NemesisBrandGem.getTierBonuses(level)
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[NemesisBrandGem.gemKey] or nil
    local tier = gemData and gemData.tiers and gemData.tiers[math.max(1, tonumber(level) or 1)] or nil
    local bonuses = tier and tier.bonuses or gemData and gemData.bonuses or {}
    return {
        damagePercent = math.max(0, tonumber(bonuses.socket_nemesis_damage_percent) or 0),
        resistancePercent = math.max(0, tonumber(bonuses.socket_nemesis_resistance_percent) or 0),
    }
end

function NemesisBrandGem.getCompactProgress(state, level)
    local now = os.time()
    state = type(state) == "table" and state or nil
    local bonuses = NemesisBrandGem.getTierBonuses(level)
    local bonusText = string.format("+%d%% damage, -%d%% damage taken", bonuses.damagePercent, bonuses.resistancePercent)
    if not state or (tonumber(state.expiresAt) or 0) <= now then
        return string.format("Nemesis: None (%s)", bonusText)
    end

    local remaining = math.max(0, (tonumber(state.expiresAt) or 0) - now)
    local minutes = math.max(1, math.ceil(remaining / 60))
    return string.format("Nemesis: %s %dm (%s)", state.targetName or "Unknown", minutes, bonusText)
end

function NemesisBrandGem.buildTooltip(baseTooltip, state, level)
    return string.format("%s\n%s", tostring(baseTooltip or ""), NemesisBrandGem.getCompactProgress(state, level))
end

function NemesisBrandGem.isStateActive(state, targetPlayer)
    if type(state) ~= "table" or not targetPlayer or not targetPlayer:isPlayer() then
        return false
    end
    if (tonumber(state.expiresAt) or 0) <= os.time() then
        return false
    end
    local targetGuid = math.max(0, tonumber(state.targetGuid) or 0)
    return targetGuid > 0 and targetGuid == targetPlayer:getGuid()
end

function NemesisBrandGem.refreshEquipped(player)
    if not player then
        return
    end
    forEachEquippedGemSocket(player, NemesisBrandGem.gemKey, function(item, socketIndex)
        refreshStatefulSocket(item, socketIndex, NemesisBrandGem.gemKey)
    end)
end

function NemesisBrandGem.brandKiller(victim, killer)
    if not victim or not victim:isPlayer() or not killer or not killer:isPlayer() or victim == killer then
        return
    end

    local duration = math.max(0, getEquippedSocketBonusTotal(victim, "socket_nemesis_duration"))
    if duration <= 0 then
        return
    end

    local expiresAt = os.time() + duration
    local wrote = false
    forEachEquippedGemSocket(victim, NemesisBrandGem.gemKey, function(item, socketIndex)
        NemesisBrandGem.writeState(item, socketIndex, {
            targetGuid = killer:getGuid(),
            targetName = killer:getName(),
            expiresAt = expiresAt,
        })
        refreshStatefulSocket(item, socketIndex, NemesisBrandGem.gemKey)
        wrote = true
    end)

    if wrote then
        victim:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Nemesis Brand marks %s for revenge.", killer:getName()))
    end
end

function NemesisBrandGem.clearBrandAgainst(player, targetPlayer)
    if not player or not player:isPlayer() or not targetPlayer or not targetPlayer:isPlayer() then
        return
    end

    local cleared = false
    forEachEquippedGemSocket(player, NemesisBrandGem.gemKey, function(item, socketIndex)
        local state = NemesisBrandGem.readState(item, socketIndex)
        if NemesisBrandGem.isStateActive(state, targetPlayer) then
            NemesisBrandGem.clearState(item, socketIndex)
            refreshStatefulSocket(item, socketIndex, NemesisBrandGem.gemKey)
            cleared = true
        end
    end)

    if cleared then
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Your Nemesis Brand against %s fades.", targetPlayer:getName()))
    end
end

function NemesisBrandGem.hasActiveBrandAgainst(player, targetPlayer, bonusCache)
    local found = false
    forEachEquippedGemSocket(player, NemesisBrandGem.gemKey, function(item, socketIndex)
        if found then
            return
        end
        local state = NemesisBrandGem.readState(item, socketIndex)
        if NemesisBrandGem.isStateActive(state, targetPlayer) then
            found = true
        elseif state and (tonumber(state.expiresAt) or 0) > 0 and (tonumber(state.expiresAt) or 0) <= os.time() then
            NemesisBrandGem.clearState(item, socketIndex)
            refreshStatefulSocket(item, socketIndex, NemesisBrandGem.gemKey)
        end
    end, bonusCache)
    return found
end

local function applyNemesisIncoming(player, attackerPlayer, primaryDamage, secondaryDamage, bonusCache, totals)
    if not attackerPlayer or not NemesisBrandGem.hasActiveBrandAgainst(player, attackerPlayer, bonusCache) then
        return primaryDamage, secondaryDamage
    end

    local resistance = math.max(0, totals.socket_nemesis_resistance_percent or 0)
    if resistance <= 0 then
        return primaryDamage, secondaryDamage
    end
    return applyPercentReduction(primaryDamage, secondaryDamage, resistance)
end

local function applyNemesisOutgoingPvP(attackerPlayer, targetPlayer, primaryDamage, secondaryDamage, bonusCache, totals)
    if not attackerPlayer or not targetPlayer or not NemesisBrandGem.hasActiveBrandAgainst(attackerPlayer, targetPlayer, bonusCache) then
        return primaryDamage, secondaryDamage
    end

    local damagePercent = math.max(0, totals.socket_nemesis_damage_percent or 0)
    if damagePercent <= 0 then
        return primaryDamage, secondaryDamage
    end
    return addScaledDamage(primaryDamage, damagePercent), addScaledDamage(secondaryDamage, damagePercent)
end

local function applyAnchorReduction(player, primaryDamage, secondaryDamage, totals)
    local state = anchorState[player:getId()]
    local stacks = math.max(0, tonumber(state and state.stacks) or 0)
    local perStack = math.max(0, totals.socket_anchor_defense_per_stack or 0)
    local reduction = stacks * perStack
    if reduction <= 0 then
        return primaryDamage, secondaryDamage
    end
    return applyPercentReduction(primaryDamage, secondaryDamage, reduction)
end

local function heraldExplosionCheck(playerId, targetId, positionData, explosionDamage)
    local player = Player(playerId)
    if not player or not positionData then
        return
    end

    local target = Monster(targetId)
    if target and target:getHealth() > 0 then
        return
    end

    damageMonstersInSquare(player, Position(positionData.x, positionData.y, positionData.z), 1, explosionDamage, CONST_ME_ENERGYAREA)
end

local function tryTriggerHerald(player, target, totalDamage, totals)
    local chance = totals.socket_herald_chance or 0
    if chance <= 0 or totalDamage <= 0 or not rollChance(chance) then
        return
    end

    local playerId = player:getId()
    local now = os.time()
    local state = heraldState[playerId] or { cooldownUntil = 0 }
    heraldState[playerId] = state
    if now < (state.cooldownUntil or 0) then
        return
    end

    local cooldown = math.max(1, totals.socket_herald_cooldown or 0)
    local maxShots = math.max(1, math.min(12, totals.socket_herald_max_shots or 0))
    local range = math.max(1, totals.socket_herald_range or 0)
    local damagePercent = math.max(0, totals.socket_herald_damage_percent or 0)
    local explosionPercent = math.max(0, totals.socket_herald_explosion_percent or 0)
    local shotDamage = scaleAmount(totalDamage, damagePercent)
    if shotDamage <= 0 then
        return
    end

    local targets = pickNearbyMonsters(target:getPosition(), range, maxShots)
    if #targets == 0 then
        targets = { target }
    end

    state.cooldownUntil = now + cooldown
    player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
    for _, shotTarget in ipairs(targets) do
        local shotPosition = shotTarget:getPosition()
        if shotPosition then
            local targetId = shotTarget:getId()
            player:getPosition():sendDistanceEffect(shotPosition, CONST_ANI_ENERGY)
            doTargetCombatHealth(player, shotTarget, COMBAT_ENERGYDAMAGE, -shotDamage, -shotDamage, CONST_ME_ENERGYHIT)
            local explosionDamage = scaleAmount(shotDamage, explosionPercent)
            if explosionDamage > 0 then
                addEvent(heraldExplosionCheck, 1, playerId, targetId, { x = shotPosition.x, y = shotPosition.y, z = shotPosition.z }, explosionDamage)
            end
        end
    end
end

local function applyHuntersFocus(player, target, primaryDamage, secondaryDamage, totals)
    local percentPerInterval = math.max(0, totals.socket_hunters_focus_percent or 0)
    if percentPerInterval <= 0 or not target then
        return primaryDamage, secondaryDamage
    end

    local interval = math.max(1, totals.socket_hunters_focus_interval or 0)
    local maxPercent = math.max(percentPerInterval, totals.socket_hunters_focus_max or 0)
    local now = os.time()
    local playerId = player:getId()
    local targetId = target:getId()
    local state = huntersFocusState[playerId]
    if not state or state.targetId ~= targetId then
        state = { targetId = targetId, startedAt = now }
        huntersFocusState[playerId] = state
        return primaryDamage, secondaryDamage
    end

    local elapsed = math.max(0, now - (state.startedAt or now))
    local bonusPercent = math.min(maxPercent, math.floor(elapsed / interval) * percentPerInterval)
    if bonusPercent <= 0 then
        return primaryDamage, secondaryDamage
    end

    return addScaledDamage(primaryDamage, bonusPercent), addScaledDamage(secondaryDamage, bonusPercent)
end

local function getPendulumPhase(player, totals)
    local period = math.max(1, totals.socket_pendulum_period or 0)
    if period <= 0 then
        return nil
    end

    local hasAggressive = (totals.socket_pendulum_aggressive_damage or 0) > 0
    local hasDefensive = (totals.socket_pendulum_defensive_defense or 0) > 0
    if not hasAggressive and not hasDefensive then
        return nil
    end

    local phaseIndex = math.floor(os.time() / period) % 2
    return phaseIndex == 0 and "aggressive" or "defensive"
end

local function reduceDamageValue(value, multiplier)
    value = tonumber(value) or 0
    multiplier = tonumber(multiplier)

    if multiplier == nil then
        multiplier = 1
    end

    multiplier = math.max(0, multiplier)

    if value < 0 then
        return -math.floor(math.abs(value) * multiplier + 0.5)
    end

    if value > 0 then
        return math.floor(value * multiplier + 0.5)
    end

    return 0
end

local function applyPendulumIncoming(carrier, primaryDamage, secondaryDamage, totals)
    if not carrier or not carrier:isPlayer() then
        return primaryDamage, secondaryDamage
    end

    local phase = getPendulumPhase(carrier, totals)

    if phase == "aggressive" then
        local penalty = math.max(0, totals.socket_pendulum_aggressive_defense_penalty or 0)
        if penalty > 0 then
            return addScaledDamage(primaryDamage, penalty),
                   addScaledDamage(secondaryDamage, penalty)
        end

    elseif phase == "defensive" then
        local defense = math.max(0, totals.socket_pendulum_defensive_defense or 0)
        if defense > 0 then
            return applyPercentReduction(primaryDamage, secondaryDamage, defense)
        end
    end

    return primaryDamage, secondaryDamage
end

local function getPendulumDefensiveDamagePenalty(totals)
    local penalty = math.max(0, tonumber(totals.socket_pendulum_defensive_damage_penalty) or 0)
    local defense = math.max(0, tonumber(totals.socket_pendulum_defensive_defense) or 0)

    if penalty >= 100 and defense >= 100 then
        local configured = GemsSocket
            and GemsSocket.GEMS
            and GemsSocket.GEMS.pendulumstone
            and GemsSocket.GEMS.pendulumstone.bonuses
            and tonumber(GemsSocket.GEMS.pendulumstone.bonuses.socket_pendulum_defensive_damage_penalty)
            or nil

        if configured and configured >= 0 and configured < penalty then
            return configured
        end
    end

    return penalty
end

local function applyPendulumOutgoing(carrier, primaryDamage, secondaryDamage, totals)
    if not carrier or not carrier:isPlayer() then
        return primaryDamage, secondaryDamage
    end

    local phase = getPendulumPhase(carrier, totals)

    if phase == "aggressive" then
        local damageBonus = math.max(0, totals.socket_pendulum_aggressive_damage or 0)
        if damageBonus > 0 then
            return addScaledDamage(primaryDamage, damageBonus),
                   addScaledDamage(secondaryDamage, damageBonus)
        end

    elseif phase == "defensive" then
        local penalty = getPendulumDefensiveDamagePenalty(totals)
        if penalty > 0 then
            return reduceOutgoingDamage(primaryDamage, penalty),
                   reduceOutgoingDamage(secondaryDamage, penalty)
        end
    end

    return primaryDamage, secondaryDamage
end

local function applyWarcryShield(player, shieldPercent, duration, range)
    shieldPercent = math.max(0, tonumber(shieldPercent) or 0)
    duration = math.max(1, tonumber(duration) or 1)
    if shieldPercent <= 0 then
        return false
    end

    local affected = false
    for _, member in ipairs(getPartyPlayersInRange(player, range)) do
        local shieldAmount = scaleAmount(member:getMaxHealth(), shieldPercent)
        if shieldAmount > 0 then
            grantWarcryShieldRuntime(member, shieldAmount, duration)
            member:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
            affected = true
        end
    end

    return affected
end

function _G.GemsSocket_advancedApplyWarcryShieldDamage(player, primaryDamage, secondaryDamage)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return primaryDamage, secondaryDamage
    end

    if not player or not player:isPlayer() then
        return primaryDamage, secondaryDamage
    end

    local state = getWarcryShieldRuntime(player)
    if not state then
        return primaryDamage, secondaryDamage
    end

    local incomingDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if incomingDamage <= 0 then
        return primaryDamage, secondaryDamage
    end

    local shieldAmount = math.max(0, tonumber(state.amount) or 0)
    if shieldAmount <= 0 then
        warcryShieldState[player:getId()] = nil
        return primaryDamage, secondaryDamage
    end

    local absorbAmount = math.min(incomingDamage, shieldAmount)
    if absorbAmount <= 0 then
        return primaryDamage, secondaryDamage
    end

    primaryDamage, secondaryDamage, absorbAmount = reduceSplitDamageByAmount(primaryDamage, secondaryDamage, absorbAmount)
    state.amount = math.max(0, shieldAmount - absorbAmount)
    if state.amount <= 0 then
        warcryShieldState[player:getId()] = nil
    end

    showWarcryShieldAbsorb(player, absorbAmount)
    player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    return primaryDamage, secondaryDamage
end

local function tryTriggerWarcry(player, totals)
    local chance = totals.socket_warcry_chance or 0
    if chance <= 0 or not rollChance(chance) then
        return
    end

    local playerId = player:getId()
    local now = os.time()
    local state = warcryState[playerId] or { cooldownUntil = 0 }
    warcryState[playerId] = state
    if now < (state.cooldownUntil or 0) then
        return
    end

    local cooldown = math.max(1, totals.socket_warcry_cooldown or 0)
    local shieldPercent = math.max(0, totals.socket_warcry_shield_percent or 0)
    local duration = math.max(1, totals.socket_warcry_duration or 0)
    local range = math.max(0, totals.socket_warcry_range or 0)
    if applyWarcryShield(player, shieldPercent, duration, range) then
        state.cooldownUntil = now + cooldown
        player:say("WARCRY!", TALKTYPE_MONSTER_SAY)
    end
end

local function addObsidianGrudgeStack(playerId, token)
    local player = Player(playerId)
    local state = obsidianGrudgeState[playerId]
    if not player or not state or state.pendingToken ~= token then
        return
    end

    local now = os.time()
    if now < (state.pendingUntil or 0) then
        addEvent(addObsidianGrudgeStack, math.max(1, ((state.pendingUntil or now) - now) * 1000), playerId, token)
        return
    end

    local maxStacks = math.max(1, getEquippedSocketBonusTotal(player, "socket_obsidian_max_stacks"))
    state.stacks = math.min(maxStacks, math.max(0, tonumber(state.stacks) or 0) + 1)
    state.pendingToken = nil
    state.pendingUntil = 0
    state.nextStackAt = now + math.max(0, getEquippedSocketBonusTotal(player, "socket_obsidian_stack_cooldown"))
    player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
end

local function armObsidianGrudge(player, incomingDamage, totals)
    if not player or not player:isPlayer() or incomingDamage <= 0 then
        return
    end

    local chance = totals.socket_obsidian_chance or 0
    if chance <= 0 or not rollChance(chance) then
        return
    end

    local now = os.time()
    local playerId = player:getId()
    local state = obsidianGrudgeState[playerId] or {
        stacks = 0,
        pendingToken = 0,
        pendingUntil = 0,
        tokenCounter = 0,
        nextStackAt = 0,
    }
    obsidianGrudgeState[playerId] = state
    if now < (state.nextStackAt or 0) or (state.pendingToken or 0) > 0 then
        return
    end

    local responseWindow = math.max(1, totals.socket_obsidian_window or 0)
    state.tokenCounter = math.max(0, tonumber(state.tokenCounter) or 0) + 1
    state.pendingToken = state.tokenCounter
    state.pendingUntil = now + responseWindow
    addEvent(addObsidianGrudgeStack, responseWindow * 1000, playerId, state.pendingToken)
end

local function applyObsidianGrudge(player, primaryDamage, secondaryDamage, totals)
    local state = player and obsidianGrudgeState[player:getId()]
    if not state then
        return primaryDamage, secondaryDamage
    end

    local now = os.time()
    if (state.pendingToken or 0) > 0 and now <= (state.pendingUntil or 0) then
        state.pendingToken = nil
        state.pendingUntil = 0
    end

    local stacks = math.max(0, tonumber(state.stacks) or 0)
    if stacks <= 0 then
        return primaryDamage, secondaryDamage
    end

    local percent = math.max(0, totals.socket_obsidian_damage_percent or 0) * stacks
    if percent <= 0 then
        return primaryDamage, secondaryDamage
    end

    state.stacks = 0
    player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
    return addScaledDamage(primaryDamage, percent), addScaledDamage(secondaryDamage, percent)
end

applyPercentReduction = function(primaryDamage, secondaryDamage, percent)
    percent = math.max(0, tonumber(percent) or 0)

    local multiplier = math.max(0, 1 - (percent / 100))

    return reduceDamageValue(primaryDamage, multiplier),
           reduceDamageValue(secondaryDamage, multiplier)
end

local function getMartyrCandidates(player)
    local party = player and player:getParty()
    if not party then
        return {}
    end

    local candidates = {}
    local leader = party:getLeader()
    if leader and leader:isPlayer() and leader ~= player then
        candidates[#candidates + 1] = leader
    end
    for _, member in ipairs(party:getMembers() or {}) do
        if member and member:isPlayer() and member ~= player and member ~= leader then
            candidates[#candidates + 1] = member
        end
    end
    return candidates
end

function _G.GemsSocket_advancedHasMartyrCandidate(player)
    if not player or not player:isPlayer() then
        return false
    end

    local playerPosition = player:getPosition()
    if not playerPosition then
        return false
    end

    local now = os.time()
    for _, protector in ipairs(getMartyrCandidates(player)) do
        local protectorCache = type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(protector) or nil
        local protectorTotals = protectorCache and protectorCache.totals or {}
        local redirectPercent = math.max(0, protectorTotals.socket_martyr_redirect_percent or 0)
        local cooldown = math.max(0, protectorTotals.socket_martyr_cooldown or 0)
        local range = math.max(0, protectorTotals.socket_martyr_range or 0)
        local state = martyrState[protector:getId()]
        local protectorPosition = protector:getPosition()
        if redirectPercent > 0 and cooldown > 0 and protector:getHealth() > 0
            and now >= (state and state.cooldownUntil or 0)
            and protectorPosition and playerPosition:getDistance(protectorPosition) <= range then
            return true
        end
    end

    return false
end

local function applyMartyrShield(player, shieldPercent, duration)
    local shieldAmount = scaleAmount(player:getMaxHealth(), shieldPercent)
    if shieldAmount <= 0 then
        return 0
    end

    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, MARTYR_SUBID, true)
    grantWarcryShieldRuntime(player, shieldAmount, duration)
    return shieldAmount
end

function _G.GemsSocket_advancedTryTriggerMartyr(player, primaryDamage, secondaryDamage)
    local incomingDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if not player or not player:isPlayer() or incomingDamage < player:getHealth() then
        return primaryDamage, secondaryDamage
    end

    local now = os.time()
    local playerPosition = player:getPosition()
    local selected = nil
    for _, protector in ipairs(getMartyrCandidates(player)) do
        local protectorCache = type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(protector) or nil
        local protectorTotals = protectorCache and protectorCache.totals or {}
        local redirectPercent = math.max(0, protectorTotals.socket_martyr_redirect_percent or 0)
        local cooldown = math.max(0, protectorTotals.socket_martyr_cooldown or 0)
        local range = math.max(0, protectorTotals.socket_martyr_range or 0)
        local state = martyrState[protector:getId()]
        local protectorPosition = protector:getPosition()
        if redirectPercent > 0 and cooldown > 0 and protector:getHealth() > 0
            and now >= (state and state.cooldownUntil or 0)
            and playerPosition and protectorPosition and playerPosition:getDistance(protectorPosition) <= range
            and (not selected or redirectPercent > selected.redirectPercent) then
            selected = {
                protector = protector,
                redirectPercent = redirectPercent,
                cooldown = cooldown,
                totals = protectorTotals,
            }
        end
    end

    if not selected then
        return primaryDamage, secondaryDamage
    end

    local protector = selected.protector
    local protectorId = protector:getId()
    martyrState[protectorId] = { cooldownUntil = now + selected.cooldown }

    local reducedPrimary, reducedSecondary = applyPercentReduction(primaryDamage, secondaryDamage, selected.redirectPercent)
    local redirectedDamage = math.max(0, incomingDamage - getDamageAmount(reducedPrimary, reducedSecondary))
    local shieldPercent = math.max(0, selected.totals.socket_martyr_shield_percent or 0)
    local shieldDuration = math.max(1, selected.totals.socket_martyr_shield_duration or 0)
    applyMartyrShield(player, shieldPercent, shieldDuration)

    if redirectedDamage > 0 then
        protector:addHealth("physical", -redirectedDamage)
    end
    protector:say("MARTYR!", TALKTYPE_MONSTER_SAY)
    protector:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
    player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    return reducedPrimary, reducedSecondary
end

local function buildReflectedCondition(durationSeconds, tickDamage)
    durationSeconds = math.max(1, tonumber(durationSeconds) or 6)
    tickDamage = math.max(1, tonumber(tickDamage) or 80)
    local durationMs = durationSeconds * 1000
    local pool = {
        function()
            local condition = Condition(CONDITION_FIRE)
            condition:addDamage(3, 2000, -tickDamage)
            return condition, CONST_ME_FIREAREA
        end,
        function()
            local condition = Condition(CONDITION_POISON)
            condition:addDamage(3, 2000, -tickDamage)
            return condition, CONST_ME_MAGIC_GREEN
        end,
        function()
            local condition = Condition(CONDITION_ENERGY)
            condition:addDamage(3, 2000, -tickDamage)
            return condition, CONST_ME_ENERGYHIT
        end,
        function()
            local condition = Condition(CONDITION_CURSED)
            condition:addDamage(3, 2000, -tickDamage)
            return condition, CONST_ME_MORTAREA
        end,
        function()
            local condition = Condition(CONDITION_DAZZLED)
            condition:addDamage(3, 2000, -tickDamage)
            return condition, CONST_ME_HOLYDAMAGE
        end,
        function()
            local condition = Condition(CONDITION_BLEEDING)
            condition:addDamage(3, 2000, -tickDamage)
            return condition, CONST_ME_DRAWBLOOD
        end,
        function()
            local condition = Condition(CONDITION_PARALYZE)
            condition:setParameter(CONDITION_PARAM_TICKS, durationMs)
            condition:setFormula(-0.35, -0.35, -0.35, -0.35)
            return condition, CONST_ME_STONES
        end,
        function()
            local condition = Condition(CONDITION_DRUNK)
            condition:setParameter(CONDITION_PARAM_TICKS, durationMs)
            return condition, CONST_ME_STUN
        end,
    }

    local builder = pool[math.random(#pool)]
    return builder()
end

local function restoreManaNovaTick(playerId, remainingTicks, restorePercent)
    local player = Player(playerId)
    if not player or remainingTicks <= 0 then
        return
    end

    local restoreAmount = scaleAmount(player:getMaxMana(), restorePercent)
    if restoreAmount > 0 then
        player:addMana(restoreAmount)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    if remainingTicks > 1 then
        addEvent(restoreManaNovaTick, 1000, playerId, remainingTicks - 1, restorePercent)
    end
end

local function triggerManaNova(player)
    if not player or not player:isPlayer() then
        return false
    end

    local cooldown = getEquippedSocketBonusTotal(player, "socket_mana_nova_cooldown")
    if cooldown <= 0 then
        return false
    end

    local playerId = player:getId()
    local now = os.time()
    local state = manaNovaState[playerId] or { cooldownUntil = 0 }
    manaNovaState[playerId] = state
    if now < (state.cooldownUntil or 0) then
        return false
    end

    local special = getSpecialConfig("manaNova")
    local radius = math.max(1, tonumber(special.radius) or 4)
    local damagePercent = math.max(0, getEquippedSocketBonusTotal(player, "socket_mana_nova_damage_percent"))
    local damage = scaleAmount(player:getMaxMana(), damagePercent)
    local blindSeconds = math.max(0, getEquippedSocketBonusTotal(player, "socket_mana_nova_blind_seconds"))
    local position = player:getPosition()

    state.cooldownUntil = now + math.max(1, cooldown)
    local areaEffect = special.areaEffect or special.triggerEffect or 389
    position:sendMagicEffect(special.triggerEffect or areaEffect)
    sendAreaEffects(position, radius, areaEffect)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.message or "Mana Nova erupts from your empty spirit.")

    for _, monster in ipairs(getNearbyMonsters(position, radius)) do
        if isPositionInSquare(position, monster:getPosition(), radius) then
            if damage > 0 then
                local hitEffect = special.hitEffect or 389
                local result = doTargetCombatHealth(player, monster, COMBAT_EARTHDAMAGE, -damage, -damage, hitEffect)
                if result == false then
                    monster:addHealth(-damage)
                    monster:getPosition():sendMagicEffect(hitEffect)
                end
            end
            if blindSeconds > 0 then
                local condition = Condition(CONDITION_DAZZLED)
                condition:setParameter(CONDITION_PARAM_TICKS, blindSeconds * 1000)
                monster:addCondition(condition)
            end
        end
    end

    local restorePercent = math.max(0, getEquippedSocketBonusTotal(player, "socket_mana_nova_restore_percent"))
    local restoreSeconds = math.max(0, getEquippedSocketBonusTotal(player, "socket_mana_nova_restore_seconds"))
    if restorePercent > 0 and restoreSeconds > 0 then
        addEvent(restoreManaNovaTick, 1000, playerId, restoreSeconds, restorePercent)
    end
    return true
end

local function checkManaNovaAfterChange(playerId, previousMana)
    local player = Player(playerId)
    if not player or (tonumber(previousMana) or 0) <= 0 then
        return
    end
    if player:getMana() <= 0 then
        triggerManaNova(player)
    end
end

GravediggerGem = GravediggerGem or {
    gemKey = "gravediggersmalachite",
}

function GravediggerGem.isGem(gemKey)
    return gemKey == GravediggerGem.gemKey
end

function GravediggerGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_gravedigger_", socketIndex)
    end
    return "gravedigger_"
end

function GravediggerGem.getSettings()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[GravediggerGem.gemKey] or nil
    local config = type(gemData) == "table" and type(gemData.gravedigger) == "table" and gemData.gravedigger or {}
    return {
        deathsPerStack = math.max(1, tonumber(config.deathsPerStack) or 50),
        healthPerStack = math.max(0, tonumber(config.healthPerStack) or 10),
        manaPerStack = math.max(0, tonumber(config.manaPerStack) or 10),
    }
end

function GravediggerGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local deaths = math.max(0, tonumber(item:getCustomAttribute(GravediggerGem.getAttributePrefix(socketIndex) .. "deaths")) or 0)
    if deaths <= 0 then
        return nil
    end
    return { deaths = deaths }
end

function GravediggerGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end
    item:removeCustomAttribute(GravediggerGem.getAttributePrefix(socketIndex) .. "deaths")
end

function GravediggerGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    GravediggerGem.clearState(item, socketIndex)
    local deaths = type(state) == "table" and math.max(0, tonumber(state.deaths) or 0) or 0
    if deaths > 0 then
        item:setCustomAttribute(GravediggerGem.getAttributePrefix(socketIndex) .. "deaths", deaths)
    end
end

function GravediggerGem.getProgress(state)
    local settings = GravediggerGem.getSettings()
    local deaths = type(state) == "table" and math.max(0, tonumber(state.deaths) or 0) or 0
    local stacks = math.floor(deaths / settings.deathsPerStack)
    return {
        deaths = deaths,
        stacks = stacks,
        nextDeaths = (stacks + 1) * settings.deathsPerStack,
        health = stacks * settings.healthPerStack,
        mana = stacks * settings.manaPerStack,
        settings = settings,
    }
end

function GravediggerGem.getCompactProgress(state)
    local progress = GravediggerGem.getProgress(state)
    return string.format("Deaths: %d | HP: +%d | Mana: +%d", progress.deaths, progress.health, progress.mana)
end

function GravediggerGem.buildTooltip(baseTooltip, state)
    local progress = GravediggerGem.getProgress(state)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end
    lines[#lines + 1] = string.format("Global Player Deaths Recorded: %d", progress.deaths)
    lines[#lines + 1] = string.format("Funeral Power: %d stacks", progress.stacks)
    lines[#lines + 1] = string.format("Bonus: +%d max HP, +%d max Mana", progress.health, progress.mana)
    lines[#lines + 1] = string.format("Next stack at: %d deaths", progress.nextDeaths)
    return table.concat(lines, "\n")
end

function GravediggerGem.addBonuses(item, socketIndex, totals)
    if type(totals) ~= "table" then
        return
    end

    local progress = GravediggerGem.getProgress(GravediggerGem.readState(item, socketIndex))
    if progress.health > 0 then
        totals.socket_gravedigger_health = (totals.socket_gravedigger_health or 0) + progress.health
    end
    if progress.mana > 0 then
        totals.socket_gravedigger_mana = (totals.socket_gravedigger_mana or 0) + progress.mana
    end
end

function GravediggerGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, GravediggerGem.gemKey, callback)
        return
    end

    if type(_G.GemsSocket_getSocketCount) ~= "function" or type(_G.GemsSocket_getSocketGemKey) ~= "function" then
        return
    end

    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            for socketIndex = 1, _G.GemsSocket_getSocketCount(item) do
                if GravediggerGem.isGem(_G.GemsSocket_getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function GravediggerGem.recordGlobalDeath(player, item, socketIndex)
    local oldProgress = GravediggerGem.getProgress(GravediggerGem.readState(item, socketIndex))
    local state = GravediggerGem.readState(item, socketIndex) or {}
    state.deaths = math.max(0, tonumber(state.deaths) or 0) + 1
    GravediggerGem.writeState(item, socketIndex, state)

    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[GravediggerGem.gemKey] or nil
    if gemData and type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, gemData)
    end

    local newProgress = GravediggerGem.getProgress(state)
    if newProgress.stacks > oldProgress.stacks then
        if type(_G.refreshSocketItem) == "function" then
            _G.refreshSocketItem(item)
        end
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("The Gravedigger's Malachite records its %dth funeral and grants +%d HP / +%d Mana.", newProgress.deaths, newProgress.health, newProgress.mana))
        return true
    end
    if type(_G.GemsSocket_refreshSocketDisplay) == "function" then
        _G.GemsSocket_refreshSocketDisplay(item)
    elseif type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
    return false
end

function GravediggerGem.onPlayerDeath(deadPlayer)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return true
    end

    local function recordForPlayer(player)
        local gainedStack = false
        GravediggerGem.forEachEquippedSocket(player, function(item, socketIndex)
            if GravediggerGem.recordGlobalDeath(player, item, socketIndex) then
                gainedStack = true
            end
        end)

        if gainedStack and type(_G.GemsSocket_refreshPlayerBonuses) == "function" then
            _G.GemsSocket_refreshPlayerBonuses(player)
        end
    end

    if type(_G.GemsSocket_forEachPlayerWithGem) == "function" then
        _G.GemsSocket_forEachPlayerWithGem(GravediggerGem.gemKey, recordForPlayer)
        return true
    end

    local onlinePlayers = Game.getPlayers()
    for _, player in ipairs(onlinePlayers or {}) do
        recordForPlayer(player)
    end
    return true
end

ObituaryGem = ObituaryGem or {
    gemKey = "obituarygem",
}

function ObituaryGem.isGem(gemKey)
    return gemKey == ObituaryGem.gemKey
end

function ObituaryGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_obituary_", socketIndex)
    end
    return "obituary_"
end

function ObituaryGem.getSettings()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[ObituaryGem.gemKey] or nil
    local bonuses = type(gemData) == "table" and type(gemData.bonuses) == "table" and gemData.bonuses or {}
    return {
        damagePerDeath = math.max(0, tonumber(bonuses.socket_obituary_damage_per_death) or 2),
        duration = math.max(1, tonumber(bonuses.socket_obituary_duration) or 86400),
        maxEntries = math.max(1, tonumber(bonuses.socket_obituary_max_entries) or 100),
    }
end

function ObituaryGem.normalizeMonsterName(monsterName)
    monsterName = tostring(monsterName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if monsterName == "" then
        return nil
    end
    return monsterName:lower()
end

function ObituaryGem.decodeEntries(rawEntries)
    if type(rawEntries) ~= "string" or rawEntries == "" then
        return {}
    end

    if type(json) == "table" and type(json.decode) == "function" then
        local ok, decoded = pcall(json.decode, rawEntries)
        if ok and type(decoded) == "table" then
            return decoded
        end
    end

    return {}
end

function ObituaryGem.encodeEntries(entries)
    if type(entries) ~= "table" or #entries == 0 then
        return nil
    end

    if type(json) == "table" and type(json.encode) == "function" then
        local ok, encoded = pcall(json.encode, entries)
        if ok and type(encoded) == "string" and encoded ~= "" then
            return encoded
        end
    end

    return nil
end

function ObituaryGem.getActiveEntries(entries, now)
    entries = type(entries) == "table" and entries or {}
    now = tonumber(now) or os.time()
    local active = {}
    for _, entry in ipairs(entries) do
        local name = type(entry) == "table" and tostring(entry.name or "") or ""
        local key = ObituaryGem.normalizeMonsterName(type(entry) == "table" and (entry.key or entry.name) or nil)
        local expiresAt = math.max(0, tonumber(type(entry) == "table" and entry.expiresAt or 0) or 0)
        if name ~= "" and key and expiresAt > now then
            active[#active + 1] = {
                name = name,
                key = key,
                expiresAt = expiresAt,
            }
        end
    end
    return active
end

function ObituaryGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local rawEntries = item:getCustomAttribute(ObituaryGem.getAttributePrefix(socketIndex) .. "entries")
    local entries = ObituaryGem.getActiveEntries(ObituaryGem.decodeEntries(rawEntries), os.time())
    if #entries == 0 then
        return nil
    end
    return { entries = entries }
end

function ObituaryGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end
    item:removeCustomAttribute(ObituaryGem.getAttributePrefix(socketIndex) .. "entries")
end

function ObituaryGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    ObituaryGem.clearState(item, socketIndex)
    local entries = ObituaryGem.getActiveEntries(type(state) == "table" and state.entries or nil, os.time())
    if #entries == 0 then
        return
    end

    local maxEntries = ObituaryGem.getSettings().maxEntries
    table.sort(entries, function(left, right)
        return (tonumber(left.expiresAt) or 0) > (tonumber(right.expiresAt) or 0)
    end)
    while #entries > maxEntries do
        table.remove(entries)
    end

    local encoded = ObituaryGem.encodeEntries(entries)
    if encoded then
        item:setCustomAttribute(ObituaryGem.getAttributePrefix(socketIndex) .. "entries", encoded)
    end
end

function ObituaryGem.getAggregatedEntries(state)
    local settings = ObituaryGem.getSettings()
    local grouped = {}
    for _, entry in ipairs(type(state) == "table" and state.entries or {}) do
        local key = ObituaryGem.normalizeMonsterName(entry.key or entry.name)
        if key then
            local existing = grouped[key]
            if not existing then
                existing = {
                    name = entry.name,
                    count = 0,
                    expiresAt = 0,
                }
                grouped[key] = existing
            end
            existing.count = existing.count + 1
            existing.expiresAt = math.max(existing.expiresAt, tonumber(entry.expiresAt) or 0)
            existing.damage = existing.count * settings.damagePerDeath
        end
    end

    local entries = {}
    for _, entry in pairs(grouped) do
        entries[#entries + 1] = entry
    end
    table.sort(entries, function(left, right)
        if left.damage ~= right.damage then
            return left.damage > right.damage
        end
        return left.name < right.name
    end)
    return entries
end

function ObituaryGem.formatRemainingTime(expiresAt)
    local remaining = math.max(0, (tonumber(expiresAt) or 0) - os.time())
    local hours = math.floor(remaining / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    end
    return string.format("%dm", minutes)
end

function ObituaryGem.getCompactProgress(state)
    local entries = ObituaryGem.getAggregatedEntries(state)
    if #entries == 0 then
        return "Obituary: No deaths recorded"
    end

    local entry = entries[1]
    return string.format("Obituary: %s +%d%% (%s)", entry.name, entry.damage, ObituaryGem.formatRemainingTime(entry.expiresAt))
end

function ObituaryGem.buildTooltip(baseTooltip, state)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    local entries = ObituaryGem.getAggregatedEntries(state)
    if #entries == 0 then
        lines[#lines + 1] = "Diary: No active deaths recorded."
    else
        lines[#lines + 1] = "Active Obituaries:"
        for index = 1, math.min(4, #entries) do
            local entry = entries[index]
            lines[#lines + 1] = string.format("%s: +%d%% damage, %s left", entry.name, entry.damage, ObituaryGem.formatRemainingTime(entry.expiresAt))
        end
        if #entries > 4 then
            lines[#lines + 1] = string.format("...and %d more.", #entries - 4)
        end
    end
    return table.concat(lines, "\n")
end

function ObituaryGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, ObituaryGem.gemKey, callback)
        return
    end

    if type(_G.GemsSocket_getSocketCount) ~= "function" or type(_G.GemsSocket_getSocketGemKey) ~= "function" then
        return
    end

    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            for socketIndex = 1, _G.GemsSocket_getSocketCount(item) do
                if ObituaryGem.isGem(_G.GemsSocket_getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function ObituaryGem.refreshSocket(item, socketIndex)
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[ObituaryGem.gemKey] or nil
    if gemData and type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, gemData)
    end
    if type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
end

function ObituaryGem.recordDeath(player, item, socketIndex, monsterName)
    local key = ObituaryGem.normalizeMonsterName(monsterName)
    if not key then
        return false
    end

    local settings = ObituaryGem.getSettings()
    local state = ObituaryGem.readState(item, socketIndex) or { entries = {} }
    state.entries[#state.entries + 1] = {
        name = tostring(monsterName),
        key = key,
        expiresAt = os.time() + settings.duration,
    }
    ObituaryGem.writeState(item, socketIndex, state)
    ObituaryGem.refreshSocket(item, socketIndex)
    return true
end

function ObituaryGem.getKillerMonsterName(killer, mostDamageKiller)
    for _, creature in ipairs({ killer }) do
        if creature and creature:isMonster() then
            local master = creature:getMaster()
            if not (master and master:isPlayer()) then
                return creature:getName()
            end
        end
    end
    for _, creature in ipairs({ mostDamageKiller }) do
        if creature and creature:isMonster() then
            local master = creature:getMaster()
            if not (master and master:isPlayer()) then
                return creature:getName()
            end
        end
    end
    return nil
end

function ObituaryGem.onPlayerDeath(player, killer, mostDamageKiller)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return true
    end

    local monsterName = ObituaryGem.getKillerMonsterName(killer, mostDamageKiller)
    if not monsterName then
        return true
    end

    local recorded = false
    ObituaryGem.forEachEquippedSocket(player, function(item, socketIndex)
        if ObituaryGem.recordDeath(player, item, socketIndex, monsterName) then
            recorded = true
        end
    end)

    if recorded then
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("The Obituary Gem records your death to %s.", monsterName))
    end
    return true
end

function ObituaryGem.getDamageBonus(player, target, bonusCache)
    if not player or not target or not target:isMonster() then
        return 0
    end

    local targetKey = ObituaryGem.normalizeMonsterName(target:getName())
    if not targetKey then
        return 0
    end

    local settings = ObituaryGem.getSettings()
    local bonus = 0
    forEachEquippedGemSocket(player, ObituaryGem.gemKey, function(item, socketIndex)
        local state = ObituaryGem.readState(item, socketIndex)
        for _, entry in ipairs(type(state) == "table" and state.entries or {}) do
            if ObituaryGem.normalizeMonsterName(entry.key or entry.name) == targetKey then
                bonus = bonus + settings.damagePerDeath
            end
        end
    end, bonusCache)
    return bonus
end

local function applyObituaryDamage(player, target, primaryDamage, secondaryDamage, bonusCache)
    local bonus = ObituaryGem.getDamageBonus(player, target, bonusCache)
    if bonus <= 0 then
        return primaryDamage, secondaryDamage
    end
    return addScaledDamage(primaryDamage, bonus), addScaledDamage(secondaryDamage, bonus)
end

OverkillGem = OverkillGem or { gemKey = "overkillgem" }

function OverkillGem.isGem(gemKey)
    return gemKey == OverkillGem.gemKey
end

function OverkillGem.getPrefix(socketIndex)
    return socketIndex and string.format("socket_%d_overkill_", socketIndex) or "overkill_"
end

function OverkillGem.getSettings()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[OverkillGem.gemKey] or {}
    local bonuses = type(gemData.bonuses) == "table" and gemData.bonuses or {}
    return {
        storePercent = math.max(0, tonumber(bonuses.socket_overkill_store_percent) or 50),
        releasePercent = math.max(0, tonumber(bonuses.socket_overkill_release_percent) or 100),
        maxDamage = math.max(1, tonumber(bonuses.socket_overkill_max_damage) or 50000),
    }
end

function OverkillGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end
    local stored = math.max(0, tonumber(item:getCustomAttribute(OverkillGem.getPrefix(socketIndex) .. "stored")) or 0)
    return stored > 0 and { stored = stored } or nil
end

function OverkillGem.clearState(item, socketIndex)
    if item and item.isItem and item:isItem() then
        item:removeCustomAttribute(OverkillGem.getPrefix(socketIndex) .. "stored")
    end
end

function OverkillGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end
    OverkillGem.clearState(item, socketIndex)
    local stored = math.min(OverkillGem.getSettings().maxDamage, math.max(0, math.floor(tonumber(type(state) == "table" and state.stored) or 0)))
    if stored > 0 then
        item:setCustomAttribute(OverkillGem.getPrefix(socketIndex) .. "stored", stored)
    end
end

function OverkillGem.getCompactProgress(state)
    return string.format("Stored Damage: %d / %d", math.max(0, tonumber(type(state) == "table" and state.stored) or 0), OverkillGem.getSettings().maxDamage)
end

function OverkillGem.buildTooltip(baseTooltip, state)
    return string.format("%s\nStored Damage: %d/%d", tostring(baseTooltip or ""), math.max(0, tonumber(type(state) == "table" and state.stored) or 0), OverkillGem.getSettings().maxDamage)
end

function OverkillGem.apply(player, target, primaryDamage, secondaryDamage, bonusCache)
    local socketItem, socketIndex
    forEachEquippedGemSocket(player, OverkillGem.gemKey, function(item, index)
        if not socketItem then
            socketItem, socketIndex = item, index
        end
    end, bonusCache)
    if not socketItem then
        return primaryDamage, secondaryDamage
    end

    local settings = OverkillGem.getSettings()
    local state = OverkillGem.readState(socketItem, socketIndex) or { stored = 0 }
    local stored = math.max(0, tonumber(state.stored) or 0)
    local baseDamage = getDamageAmount(primaryDamage, secondaryDamage)
    local released = math.floor(stored * (settings.releasePercent / 100))
    if released > 0 then
        if tonumber(primaryDamage) ~= 0 then
            primaryDamage = addFlatDamage(primaryDamage, released)
        else
            secondaryDamage = addFlatDamage(secondaryDamage, released)
        end
        state.stored = 0
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Overkill Gem releases %d stored damage.", released))
    end

    local targetHealth = math.max(0, tonumber(target and target:getHealth()) or 0)
    if targetHealth > 0 and baseDamage > targetHealth then
        local excess = baseDamage - targetHealth
        state.stored = math.min(settings.maxDamage, math.floor(excess * (settings.storePercent / 100)))
        if state.stored > 0 then
            player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Overkill Gem stores %d excess damage.", state.stored))
        end
    end

    OverkillGem.writeState(socketItem, socketIndex, state)
    if released > 0 or (state.stored or 0) > 0 then
        refreshStatefulSocket(socketItem, socketIndex, OverkillGem.gemKey)
    end
    return primaryDamage, secondaryDamage
end

RequiemGem = RequiemGem or { gemKey = "requiemgem" }

function RequiemGem.isGem(gemKey)
    return gemKey == RequiemGem.gemKey
end

function RequiemGem.getPrefix(socketIndex)
    return socketIndex and string.format("socket_%d_requiem_", socketIndex) or "requiem_"
end

function RequiemGem.getSettings()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[RequiemGem.gemKey] or {}
    local bonuses = type(gemData.bonuses) == "table" and gemData.bonuses or {}
    return {
        required = math.max(1, tonumber(bonuses.socket_requiem_souls_required) or 100),
        perKill = math.max(1, tonumber(bonuses.socket_requiem_souls_per_kill) or 1),
    }
end

function RequiemGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end
    local souls = math.max(0, tonumber(item:getCustomAttribute(RequiemGem.getPrefix(socketIndex) .. "souls")) or 0)
    return souls > 0 and { souls = souls } or nil
end

function RequiemGem.clearState(item, socketIndex)
    if item and item.isItem and item:isItem() then
        item:removeCustomAttribute(RequiemGem.getPrefix(socketIndex) .. "souls")
    end
end

function RequiemGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end
    RequiemGem.clearState(item, socketIndex)
    local souls = math.min(RequiemGem.getSettings().required, math.max(0, math.floor(tonumber(type(state) == "table" and state.souls) or 0)))
    if souls > 0 then
        item:setCustomAttribute(RequiemGem.getPrefix(socketIndex) .. "souls", souls)
    end
end

function RequiemGem.getCompactProgress(state)
    return string.format("Souls: %d / %d", math.max(0, tonumber(type(state) == "table" and state.souls) or 0), RequiemGem.getSettings().required)
end

function RequiemGem.buildTooltip(baseTooltip, state)
    return string.format("%s\nSouls: %d/%d", tostring(baseTooltip or ""), math.max(0, tonumber(type(state) == "table" and state.souls) or 0), RequiemGem.getSettings().required)
end

function RequiemGem.recordKill(player, target)
    if not isNormalMonster(target) then
        return false
    end
    local settings = RequiemGem.getSettings()
    forEachEquippedGemSocket(player, RequiemGem.gemKey, function(item, socketIndex)
        local state = RequiemGem.readState(item, socketIndex) or { souls = 0 }
        local previous = math.max(0, tonumber(state.souls) or 0)
        state.souls = math.min(settings.required, previous + settings.perKill)
        RequiemGem.writeState(item, socketIndex, state)
        refreshStatefulSocket(item, socketIndex, RequiemGem.gemKey)
        if previous < settings.required and state.souls >= settings.required then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Requiem Gem is filled with souls and can prevent one lethal hit.")
        end
    end)
    return true
end

function RequiemGem.tryPreventDeath(player, incomingDamage, bonusCache)
    if not player or incomingDamage < player:getHealth() then
        return false
    end
    local required = RequiemGem.getSettings().required
    local used = false
    forEachEquippedGemSocket(player, RequiemGem.gemKey, function(item, socketIndex)
        if used then
            return
        end
        local state = RequiemGem.readState(item, socketIndex) or { souls = 0 }
        if math.max(0, tonumber(state.souls) or 0) >= required then
            state.souls = 0
            RequiemGem.writeState(item, socketIndex, state)
            refreshStatefulSocket(item, socketIndex, RequiemGem.gemKey)
            used = true
        end
    end, bonusCache)
    if not used then
        return false
    end
    player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Requiem consumes its souls and refuses your death.")
    return math.max(0, player:getHealth() - 1)
end

WaystoneConquerorGem = WaystoneConquerorGem or {
    gemKey = "waystoneconquerorgem",
    mapLabels = {
        tier1_map1 = "Tier I - Map I", tier1_map2 = "Tier I - Map II",
        tier2_map1 = "Tier II - Map I", tier2_map2 = "Tier II - Map II",
        tier3_map1 = "Tier III - Map I", tier3_map2 = "Tier III - Map II",
        tier4_map1 = "Tier IV - Map I", tier4_map2 = "Tier IV - Map II",
        tier5_map1 = "Tier V - Map I", tier5_map2 = "Tier V - Map II",
        tier6_map1 = "Tier VI - Map I", tier6_map2 = "Tier VI - Map II",
    },
    mapStorages = {
        tier1_map1 = 720172, tier1_map2 = 720173,
        tier2_map1 = 720174, tier2_map2 = 720175,
        tier3_map1 = 720176, tier3_map2 = 720177,
        tier4_map1 = 720178, tier4_map2 = 720179,
        tier5_map1 = 720180, tier5_map2 = 720181,
        tier6_map1 = 720182, tier6_map2 = 720183,
    },
    baseBossCooldown = 500,
}

function WaystoneConquerorGem.isGem(gemKey)
    return gemKey == WaystoneConquerorGem.gemKey
end

function WaystoneConquerorGem.getPrefix(socketIndex)
    return socketIndex and string.format("socket_%d_waystone_conqueror_", socketIndex) or "waystone_conqueror_"
end


function WaystoneConquerorGem.getSettings()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[WaystoneConquerorGem.gemKey] or {}
    local bonuses = type(gemData.bonuses) == "table" and gemData.bonuses or {}
    return {
        perMap = math.max(0, tonumber(bonuses.socket_waystone_cooldown_reduction_per_map) or 2),
        maxMaps = math.max(1, tonumber(bonuses.socket_waystone_max_maps) or 12),
        maxReduction = math.max(0, tonumber(bonuses.socket_waystone_max_cooldown_reduction) or 24),
    }
end

function WaystoneConquerorGem.decodeMaps(raw)
    local maps = {}
    for mapId in tostring(raw or ""):gmatch("[^,]+") do
        if WaystoneConquerorGem.mapLabels[mapId] then
            maps[mapId] = true
        end
    end
    return maps
end

function WaystoneConquerorGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end
    local maps = WaystoneConquerorGem.decodeMaps(item:getCustomAttribute(WaystoneConquerorGem.getPrefix(socketIndex) .. "maps"))
    return next(maps) and { maps = maps } or nil
end

function WaystoneConquerorGem.clearState(item, socketIndex)
    if item and item.isItem and item:isItem() then
        item:removeCustomAttribute(WaystoneConquerorGem.getPrefix(socketIndex) .. "maps")
    end
end


function WaystoneConquerorGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end
    WaystoneConquerorGem.clearState(item, socketIndex)
    local entries = {}
    for mapId, completed in pairs(type(state) == "table" and state.maps or {}) do
        if completed and WaystoneConquerorGem.mapLabels[mapId] then
            entries[#entries + 1] = mapId
        end
    end
    table.sort(entries)
    if #entries > 0 then
        item:setCustomAttribute(WaystoneConquerorGem.getPrefix(socketIndex) .. "maps", table.concat(entries, ","))
    end
end

function WaystoneConquerorGem.getProgress(state)
    local count = 0
    for mapId, completed in pairs(type(state) == "table" and state.maps or {}) do
        if completed and WaystoneConquerorGem.mapLabels[mapId] then
            count = count + 1
        end
    end
    local settings = WaystoneConquerorGem.getSettings()
    count = math.min(settings.maxMaps, count)
    return count, math.min(settings.maxReduction, count * settings.perMap), settings
end

function WaystoneConquerorGem.getCompactProgress(state)
    local count, reduction, settings = WaystoneConquerorGem.getProgress(state)
    return string.format("Waystone Conquest: %d/%d  Cooldown: -%d%%", count, settings.maxMaps, reduction)
end

function WaystoneConquerorGem.buildTooltip(baseTooltip, state)
    local count, reduction, settings = WaystoneConquerorGem.getProgress(state)
    return string.format("%s\nWaystone Conquest: %d/%d\nBoss Cooldown Reduction: %d%%", tostring(baseTooltip or ""), count, settings.maxMaps, reduction)
end

function WaystoneConquerorGem.recordMap(player, mapId)
    if not player or not WaystoneConquerorGem.mapLabels[mapId] then
        return false
    end
    local newlyCompleted = false
    forEachEquippedGemSocket(player, WaystoneConquerorGem.gemKey, function(item, socketIndex)
        local state = WaystoneConquerorGem.readState(item, socketIndex) or { maps = {} }
        if not state.maps[mapId] then
            state.maps[mapId] = true
            WaystoneConquerorGem.writeState(item, socketIndex, state)
            refreshStatefulSocket(item, socketIndex, WaystoneConquerorGem.gemKey)
            newlyCompleted = true
        end
    end)
    if newlyCompleted then
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Waystone Conqueror records %s.", WaystoneConquerorGem.mapLabels[mapId]))
    end
    return newlyCompleted
end

function WaystoneConquerorGem.reduceCurrentBossCooldown(player, mapId)
    local storage = WaystoneConquerorGem.mapStorages[mapId]
    if not player or not storage then
        return
    end
    local currentEnd = tonumber(player:getStorageValue(storage)) or 0
    local now = os.time()
    if currentEnd <= now then
        return
    end
    local baseCooldown = WaystoneConquerorGem.baseBossCooldown
    local reducedCooldown = _G.GemsSocket_getWaystoneBossCooldown(player, baseCooldown)
    local enteredAt = currentEnd - baseCooldown
    local reducedEnd = enteredAt + reducedCooldown
    player:setStorageValue(storage, reducedEnd > now and reducedEnd or -1)
end

function WaystoneConquerorGem.recordBossCompletion(monster, mapId)
    if not monster or not monster:isMonster() or not WaystoneConquerorGem.mapLabels[mapId] then
        return false
    end
    local awarded = {}
    for attackerId, entry in pairs(monster:getDamageMap() or {}) do
        local damage = type(entry) == "table" and tonumber(entry.total or entry.damage or entry[1] or 0) or tonumber(entry)
        local player = Player(attackerId)
        if not player then
            local creature = Creature(attackerId)
            local master = creature and creature:getMaster() or nil
            player = master and master:isPlayer() and master or nil
        end
        if player and (tonumber(damage) or 0) > 0 and not awarded[player:getId()] then
            awarded[player:getId()] = true
            WaystoneConquerorGem.recordMap(player, mapId)
            WaystoneConquerorGem.reduceCurrentBossCooldown(player, mapId)
        end
    end
    return true
end

function WaystoneConquerorGem.getCooldownReduction(player)
    local highest = 0
    forEachEquippedGemSocket(player, WaystoneConquerorGem.gemKey, function(item, socketIndex)
        local _, reduction = WaystoneConquerorGem.getProgress(WaystoneConquerorGem.readState(item, socketIndex))
        highest = math.max(highest, reduction)
    end)
    return highest
end

function _G.GemsSocket_getWaystoneBossCooldown(player, baseSeconds)
    baseSeconds = math.max(1, tonumber(baseSeconds) or 1)
    local reduction = WaystoneConquerorGem.getCooldownReduction(player)
    return math.max(1, math.ceil(baseSeconds * math.max(0, 1 - (reduction / 100))))
end

DamageGem = DamageGem or { gemKey = "damagegem" }

function DamageGem.isGem(gemKey)
    return gemKey == DamageGem.gemKey
end

function DamageGem.getPrefix(socketIndex)
    return socketIndex and string.format("socket_%d_damage_gem_", socketIndex) or "damage_gem_"
end

function DamageGem.normalize(value)
    local digits = tostring(value or "0"):match("^%s*(%d+)%s*$") or "0"
    digits = digits:gsub("^0+", "")
    return digits ~= "" and digits or "0"
end

function DamageGem.addDecimal(left, right)
    left = DamageGem.normalize(left)
    right = DamageGem.normalize(right)
    local i, j, carry = #left, #right, 0
    local reversed = {}
    while i > 0 or j > 0 or carry > 0 do
        local a = i > 0 and tonumber(left:sub(i, i)) or 0
        local b = j > 0 and tonumber(right:sub(j, j)) or 0
        local sum = a + b + carry
        reversed[#reversed + 1] = tostring(sum % 10)
        carry = math.floor(sum / 10)
        i, j = i - 1, j - 1
    end
    local result = {}
    for index = #reversed, 1, -1 do
        result[#result + 1] = reversed[index]
    end
    return table.concat(result)
end

function DamageGem.format(value)
    local digits = DamageGem.normalize(value)
    local parts = {}
    while #digits > 3 do
        table.insert(parts, 1, digits:sub(-3))
        digits = digits:sub(1, -4)
    end
    table.insert(parts, 1, digits)
    return table.concat(parts, ",")
end

function DamageGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end
    local total = DamageGem.normalize(item:getCustomAttribute(DamageGem.getPrefix(socketIndex) .. "total"))
    return total ~= "0" and { total = total } or nil
end

function DamageGem.clearState(item, socketIndex)
    if item and item.isItem and item:isItem() then
        item:removeCustomAttribute(DamageGem.getPrefix(socketIndex) .. "total")
    end
end

function DamageGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end
    DamageGem.clearState(item, socketIndex)
    local total = DamageGem.normalize(type(state) == "table" and state.total or "0")
    if total ~= "0" then
        item:setCustomAttribute(DamageGem.getPrefix(socketIndex) .. "total", total)
    end
end

local function getDamageGemFlushDamage(critical)
    local performance = GemsSocket and GemsSocket.PERFORMANCE or {}
    local configured = critical and performance.damageGemCriticalFlushDamage or performance.damageGemFlushDamage
    return math.max(1, tonumber(configured) or (critical and 50000 or 10000))
end

local function getDamageGemPendingKey(item, socketIndex)
    local uniqueId = item and item.getUniqueId and tonumber(item:getUniqueId()) or 0
    if uniqueId and uniqueId > 0 then
        return string.format("%d:%d", uniqueId, tonumber(socketIndex) or 0)
    end
    return string.format("%s:%d", tostring(item), tonumber(socketIndex) or 0)
end

local function flushDamageGemEntry(playerId, key, entry)
    local pending = damageGemPending[playerId]
    if type(entry) ~= "table" then
        return false
    end
    local amount = math.floor(tonumber(entry.amount) or 0)
    if amount <= 0 then
        if pending then
            pending[key] = nil
        end
        return false
    end

    local item = entry.item
    local socketIndex = entry.socketIndex
    if not item or not item.isItem or not item:isItem() then
        if pending then
            pending[key] = nil
        end
        return false
    end

    local state = DamageGem.readState(item, socketIndex) or { total = "0" }
    state.total = DamageGem.addDecimal(state.total, tostring(amount))
    DamageGem.writeState(item, socketIndex, state)
    entry.amount = 0
    if pending then
        pending[key] = nil
    end
    damageGemDirty[playerId] = true
    return true
end

function DamageGem.getCompactProgress(state)
    return string.format("Lifetime Damage: %s", DamageGem.format(type(state) == "table" and state.total or "0"))
end

function DamageGem.buildTooltip(baseTooltip, state)
    return string.format("%s\nLifetime Damage: %s", tostring(baseTooltip or ""), DamageGem.format(type(state) == "table" and state.total or "0"))
end

function DamageGem.record(player, target, damage, bonusCache)
    local totals = bonusCache and bonusCache.totals
    if not player or not target or not target:isMonster()
        or (totals and (totals.socket_damage_tracker_enabled or 0)
            or getEquippedSocketBonusTotal(player, "socket_damage_tracker_enabled")) <= 0 then
        return
    end
    local effectiveDamage = math.min(math.max(0, math.floor(tonumber(damage) or 0)), math.max(0, tonumber(target:getHealth()) or 0))
    if effectiveDamage <= 0 then
        return
    end
    local playerId = player:getId()
    local pending = damageGemPending[playerId]
    if not pending then
        pending = {}
        damageGemPending[playerId] = pending
    end
    local flushed = false
    local flushDamage = getDamageGemFlushDamage(false)
    local criticalFlushDamage = getDamageGemFlushDamage(true)
    forEachEquippedGemSocket(player, DamageGem.gemKey, function(item, socketIndex)
        local key = getDamageGemPendingKey(item, socketIndex)
        local entry = pending[key]
        if not entry then
            entry = { item = item, socketIndex = socketIndex, amount = 0 }
            pending[key] = entry
        end
        entry.amount = math.max(0, tonumber(entry.amount) or 0) + effectiveDamage
        if entry.amount >= flushDamage or entry.amount >= criticalFlushDamage then
            flushed = flushDamageGemEntry(playerId, key, entry) or flushed
        end
    end, bonusCache)
    if flushed then
        DamageGem.refreshEquipped(player)
    end
end

function DamageGem.refreshEquipped(player)
    forEachEquippedGemSocket(player, DamageGem.gemKey, function(item, socketIndex)
        refreshStatefulSocket(item, socketIndex, DamageGem.gemKey)
    end)
    if player and player:isPlayer() then
        damageGemDirty[player:getId()] = nil
    end
end

function DamageGem.flushPending(player)
    if not player or not player:isPlayer() then
        return false
    end

    local playerId = player:getId()
    damageGemFlushScheduled[playerId] = nil
    local pending = damageGemPending[playerId]
    if type(pending) ~= "table" then
        return false
    end

    local flushed = false
    for key, entry in pairs(pending) do
        flushed = flushDamageGemEntry(playerId, key, entry) or flushed
    end
    if next(pending) == nil then
        damageGemPending[playerId] = nil
    end
    if flushed then
        DamageGem.refreshEquipped(player)
    end
    return flushed
end

function DamageGem.flushPendingSoon(player, delayMs)
    if not player or not player:isPlayer() then
        return false
    end

    local playerId = player:getId()
    if damageGemFlushScheduled[playerId] then
        return false
    end

    damageGemFlushScheduled[playerId] = true
    addEvent(function(pid)
        local delayedPlayer = Player(pid)
        if delayedPlayer and type(DamageGem.flushPending) == "function" then
            DamageGem.flushPending(delayedPlayer)
        else
            damageGemFlushScheduled[pid] = nil
        end
    end, math.max(50, tonumber(delayMs) or 250), playerId)
    return true
end

local function getGamblerConfig(item, socketIndex)
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS.gamblersoulgem or nil
    if type(gemData) ~= "table" then
        return {}
    end

    if item and socketIndex and type(_G.GemsSocket_getSocketGemLevel) == "function" then
        local level = math.max(1, tonumber(_G.GemsSocket_getSocketGemLevel(item, socketIndex)) or 1)
        local tierData = type(gemData.tiers) == "table" and gemData.tiers[level] or nil
        if type(tierData) == "table" and type(tierData.gambler) == "table" then
            return tierData.gambler
        end
    end

    return type(gemData.gambler) == "table" and gemData.gambler or {}
end

function _G.GemsSocket_getBossLootGamble(player, monster, corpse)
    local bonusTotal = getEquippedSocketBonusTotal(player, "socket_gambler_soul_enabled")
    local hasGem = playerHasEquippedSocketGem(player, "gamblersoulgem")
    local hasMaster = monster and monster:isMonster() and monster:getMaster() ~= nil or false
    local isBoss = isBossMonster(monster)

    if not player or not player:isPlayer() or not monster or not monster:isMonster() or not corpse
        or (bonusTotal <= 0 and not hasGem)
        or hasMaster or not isBoss then
        return nil
    end
    if tonumber(corpse:getCustomAttribute("gambler_soul_rolled") or 0) == 1 then
        return nil
    end
    corpse:setCustomAttribute("gambler_soul_rolled", 1)

    local gamblerItem, gamblerSocketIndex
    forEachEquippedGemSocket(player, "gamblersoulgem", function(item, socketIndex)
        if not gamblerItem then
            gamblerItem = item
            gamblerSocketIndex = socketIndex
        end
    end)

    local config = getGamblerConfig(gamblerItem, gamblerSocketIndex)
    local fortune = math.max(0, tonumber(config.fortuneWeight) or 25)
    local nothing = math.max(0, tonumber(config.nothingWeight) or 50)
    local misfortune = math.max(0, tonumber(config.misfortuneWeight) or 25)
    local total = fortune + nothing + misfortune
    if total <= 0 then
        return nil
    end
    local roll = (math.random(1000000) / 1000000) * total
    local outcome
    if roll < fortune then
        outcome = "fortune"
    elseif roll < fortune + nothing then
        outcome = "nothing"
    else
        outcome = "misfortune"
    end

    local messages = {
        fortune = "Gambler's Soul rolls Fortune: the boss receives bonus loot rolls.",
        nothing = "Gambler's Soul rolls Nothing: the boss keeps its normal loot.",
        misfortune = "Gambler's Soul rolls Misfortune: standard boss loot chances are halved.",
    }
    player:sendTextMessage(MESSAGE_INFO_DESCR, messages[outcome])
    return {
        outcome = outcome,
        fortuneExtraRollPercent = math.max(0, math.min(100, tonumber(config.fortuneExtraRollPercent) or 50)),
        misfortuneLootPercent = math.max(0, math.min(100, tonumber(config.misfortuneLootPercent) or 50)),
    }
end

local function canInfectMonster(monster)
    if not isNormalMonster(monster) or monster:getHealth() <= 0 or monster:getMaster() or isBossMonster(monster) then
        return false
    end
    if type(monster.isRemoved) == "function" and monster:isRemoved() then
        return false
    end
    if type(monster.getName) ~= "function" or monster:getName() == "" then
        return false
    end
    if type(_G.GuildDynastie_isDefenderMonster) == "function" and _G.GuildDynastie_isDefenderMonster(monster) then
        return false
    end
    local position = monster:getPosition()
    local tile = position and Tile(position) or nil
    if not tile or tile:getHouse() or tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        return false
    end
    local monsterType = monster:getType()
    local loot = monsterType and monsterType.getLoot and monsterType:getLoot() or nil
    return type(loot) == "table" and next(loot) ~= nil
end

local function infectMonster(monster, levels, maxLevel)
    if not canInfectMonster(monster) or type(monster.getMonsterLevel) ~= "function" or type(monster.setMonsterLevel) ~= "function" then
        return false
    end
    local oldLevel = math.max(0, tonumber(monster:getMonsterLevel()) or 0)
    local newLevel = math.min(maxLevel, oldLevel + levels)
    if newLevel <= oldLevel then
        return false
    end

    if monster:getStorageValue(INFECTION_BASE_LEVEL_STORAGE) < 0 then
        monster:setStorageValue(INFECTION_BASE_LEVEL_STORAGE, oldLevel)
    end
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS.infectiongem or nil
    local infection = type(gemData) == "table" and type(gemData.infection) == "table" and gemData.infection or {}
    local healthPerLevel = math.max(0, tonumber(infection.healthBonusPerLevel) or 0.0074)
    local oldMaxHealth = math.max(1, tonumber(monster:getMaxHealth()) or 1)
    local oldHealth = math.max(1, tonumber(monster:getHealth()) or 1)
    local healthRatio = (1 + (healthPerLevel * newLevel)) / math.max(0.0001, 1 + (healthPerLevel * oldLevel))
    local newMaxHealth = math.max(oldMaxHealth, math.floor(oldMaxHealth * healthRatio + 0.5))
    local newHealth = math.max(1, math.min(newMaxHealth, math.floor((oldHealth / oldMaxHealth) * newMaxHealth + 0.5)))

    monster:setMonsterLevel(newLevel)
    monster:setMaxHealth(newMaxHealth)
    monster:addHealth("healing", newHealth - monster:getHealth())
    monster:getPosition():sendMagicEffect(infection.effect or CONST_ME_POISONAREA)
    monster:say(string.format("INFECTED - LEVEL %d", newLevel), TALKTYPE_MONSTER_SAY)
    return true
end

local function trySpreadInfection(player, killedMonster)
    local chance = math.max(0, getEquippedSocketBonusTotal(player, "socket_infection_chance"))
    if chance <= 0 or not killedMonster or not rollChance(chance) then
        return
    end
    local range = math.max(1, getEquippedSocketBonusTotal(player, "socket_infection_range"))
    local maxTargets = math.max(1, getEquippedSocketBonusTotal(player, "socket_infection_targets"))
    local levels = math.max(1, getEquippedSocketBonusTotal(player, "socket_infection_levels"))
    local maxLevel = math.max(levels, getEquippedSocketBonusTotal(player, "socket_infection_max_level"))
    local candidates = {}
    for _, monster in ipairs(getNearbyMonsters(killedMonster:getPosition(), range, killedMonster)) do
        if canInfectMonster(monster) then
            candidates[#candidates + 1] = monster
        end
    end
    local infected = 0
    while #candidates > 0 and infected < maxTargets do
        local index = math.random(#candidates)
        local monster = table.remove(candidates, index)
        if infectMonster(monster, levels, maxLevel) then
            infected = infected + 1
        end
    end
end

function _G.GemsSocket_getExperienceMonsterLevel(monster)
    if not monster or not monster:isMonster() then
        return 0
    end
    local baseLevel = tonumber(monster:getStorageValue(INFECTION_BASE_LEVEL_STORAGE)) or -1
    if baseLevel >= 0 then
        return baseLevel
    end
    return math.max(0, tonumber(monster:getMonsterLevel()) or 0)
end

local function findNearbyFreePosition(center, minRange, maxRange)
    if not center then
        return nil
    end

    local positions = {}
    for radius = minRange, maxRange do
        for x = -radius, radius do
            for y = -radius, radius do
                if math.max(math.abs(x), math.abs(y)) == radius then
                    positions[#positions + 1] = Position(center.x + x, center.y + y, center.z)
                end
            end
        end
    end

    for i = #positions, 2, -1 do
        local j = math.random(i)
        positions[i], positions[j] = positions[j], positions[i]
    end

    for _, pos in ipairs(positions) do
        local tile = Tile(pos)
        if tile
            and not tile:getHouse()
            and not tile:hasFlag(TILESTATE_PROTECTIONZONE)
            and not tile:hasFlag(TILESTATE_BLOCKSOLID)
            and not tile:getTopCreature() then
            return pos
        end
    end

    local centerTile = Tile(center)
    if centerTile
        and not centerTile:getHouse()
        and not centerTile:hasFlag(TILESTATE_PROTECTIONZONE)
        and not centerTile:hasFlag(TILESTATE_BLOCKSOLID)
        and not centerTile:getTopCreature() then
        return center
    end

    return nil
end

local function removeCreatureById(creatureId)
    local creature = Creature(creatureId)
    if creature then
        creature:remove()
    end
end

local function getParadoxSpecialConfig()
    local special = GemsSocket and GemsSocket.SPECIALS and GemsSocket.SPECIALS.paradox or nil
    return type(special) == "table" and special or {}
end

local function targetCreature(attacker, target)
    if not attacker or not target then
        return
    end

    if attacker.selectTarget then
        attacker:selectTarget(target)
    end
    if attacker.setTarget then
        attacker:setTarget(target)
    end
end

local function isParadoxMonsterTarget(creature, echo)
    if not creature or creature == echo or not creature:isMonster() then
        return false
    end

    if type(_G.GemsSocket_isNormalMonster) == "function" then
        return _G.GemsSocket_isNormalMonster(creature)
    end

    return not (creature.getMaster and creature:getMaster())
end

local function retargetParadoxMonsters(playerId, echoId, activeUntil, radius)
    local player = Player(playerId)
    local echo = Creature(echoId)
    local state = paradoxState[playerId]
    if not player or not echo or not state or state.activeUntil ~= activeUntil then
        return
    end

    if os.time() > activeUntil then
        return
    end

    local anchorPosition = echo:getPosition() or player:getPosition()
    local targets = {}
    -- This query belongs to an active Paradox timeline and stops with its token/state.
    for _, spectator in ipairs(Game.getSpectators(anchorPosition, false, false, radius, radius, radius, radius) or {}) do
        if isParadoxMonsterTarget(spectator, echo) then
            targets[#targets + 1] = spectator
            targetCreature(spectator, echo)
        end
    end

    if #targets > 0 then
        targetCreature(echo, targets[math.random(#targets)])
    end

    addEvent(retargetParadoxMonsters, 1000, playerId, echoId, activeUntil, radius)
end

local function endParadoxTimeline(playerId, activeUntil)
    local state = paradoxState[playerId]
    if not state or state.activeUntil ~= activeUntil then
        return
    end

    local player = Player(playerId)
    local special = getParadoxSpecialConfig()
    local echo = state.echoId and Creature(state.echoId) or nil
    if echo then
        echo:getPosition():sendMagicEffect(special.collapseEffect or CONST_ME_POFF)
        echo:remove()
    end

    if player and state.restoreGhostMode then
        player:setGhostMode(false)
        player:getPosition():sendMagicEffect(special.collapseEffect or CONST_ME_POFF)
    end

    state.activeUntil = nil
    state.echoId = nil
    state.restoreGhostMode = nil
end

local function summonTemporaryMonster(player, monsterName, position, durationSeconds, copyPlayerLook)
    local monster = Game.createMonster(monsterName, position, true, true)
    if not monster then
        return nil
    end

    monster:setMaster(player)
    if copyPlayerLook then
        monster:setOutfit(player:getOutfit())
        monster:rename(player:getName() .. "'s Shadow", "a phantom double")
    end

    if player.copyVisibilityRules then
        monster:copyVisibilityRules(player)
    end

    addEvent(removeCreatureById, math.max(1, durationSeconds) * 1000, monster:getId())
    return monster
end

local function getTreasureGoblinConfig()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS.treasuregoblingem or nil
    local config = type(gemData) == "table" and type(gemData.treasureGoblin) == "table" and gemData.treasureGoblin or {}
    return {
        monsters = type(config.monsters) == "table" and config.monsters or { "Gem Hoarder Goblin", "Goldsnatch Goblin", "Portal Scavenger Goblin" },
        spawnMinRange = math.max(1, tonumber(config.spawnMinRange) or 1),
        spawnMaxRange = math.max(1, tonumber(config.spawnMaxRange) or 3),
        fleeSeconds = math.max(1, tonumber(config.fleeSeconds) or 12),
        lifetimeSeconds = math.max(1, tonumber(config.lifetimeSeconds) or 60),
        fleeIntervalMs = math.max(200, tonumber(config.fleeIntervalMs) or 700),
        spawnEffect = config.spawnEffect or CONST_ME_TELEPORT,
        fleeEffect = config.fleeEffect or CONST_ME_POFF,
        message = config.message or "A treasure goblin slips out of the corpse and starts running!",
    }
end

local function getDirectionAway(fromPosition, threatPosition)
    if not fromPosition or not threatPosition then
        return nil
    end

    local dx = fromPosition.x - threatPosition.x
    local dy = fromPosition.y - threatPosition.y
    if math.abs(dx) > math.abs(dy) then
        return dx >= 0 and DIRECTION_EAST or DIRECTION_WEST
    elseif math.abs(dy) > 0 then
        return dy >= 0 and DIRECTION_SOUTH or DIRECTION_NORTH
    elseif dx ~= 0 then
        return dx >= 0 and DIRECTION_EAST or DIRECTION_WEST
    end
    return nil
end

local treasureGoblinDirectionOffsets = {
    [DIRECTION_NORTH] = { x = 0, y = -1 },
    [DIRECTION_EAST] = { x = 1, y = 0 },
    [DIRECTION_SOUTH] = { x = 0, y = 1 },
    [DIRECTION_WEST] = { x = -1, y = 0 },
}

local function isTreasureGoblinWalkableTile(position, goblin)
    local tile = position and Tile(position) or nil
    if not tile
        or tile:getHouse()
        or tile:hasFlag(TILESTATE_PROTECTIONZONE)
        or tile:hasFlag(TILESTATE_BLOCKSOLID)
        or tile:hasFlag(TILESTATE_BLOCKPATH)
        or tile:getTopCreature() then
        return false
    end

    if type(tile.isWalkable) == "function" then
        local ok, walkable = pcall(function()
            return tile:isWalkable()
        end)
        if ok and not walkable then
            return false
        end
    end

    if goblin and type(tile.queryAdd) == "function" then
        local ok, result = pcall(function()
            return tile:queryAdd(goblin, FLAG_PATHFINDING or 0)
        end)
        if ok and result ~= (RETURNVALUE_NOERROR or 0) then
            return false
        end
    end

    return true
end

local function moveTreasureGoblinAway(goblin, player)
    if not goblin or not player then
        return false
    end

    local fromPosition = goblin:getPosition()
    local playerPosition = player:getPosition()
    if not fromPosition or not playerPosition then
        return false
    end

    local directions = { DIRECTION_NORTH, DIRECTION_EAST, DIRECTION_SOUTH, DIRECTION_WEST }
    local validDirections = {}

    for _, direction in ipairs(directions) do
        local offset = treasureGoblinDirectionOffsets[direction]
        local nextPosition = Position(fromPosition.x + offset.x, fromPosition.y + offset.y, fromPosition.z)
        if isTreasureGoblinWalkableTile(nextPosition, goblin) then
            validDirections[#validDirections + 1] = {
                direction = direction,
                distance = getDistanceBetween(nextPosition, playerPosition),
            }
        end
    end

    if #validDirections == 0 then
        return false
    end

    local currentDistance = getDistanceBetween(fromPosition, playerPosition)
    local preferredDirections = {}
    for _, option in ipairs(validDirections) do
        if option.distance >= currentDistance then
            preferredDirections[#preferredDirections + 1] = option.direction
        end
    end

    for _, option in ipairs(validDirections) do
        if #preferredDirections == 0 then
            preferredDirections[#preferredDirections + 1] = option.direction
        end
    end

    local chosenDirection = preferredDirections[math.random(#preferredDirections)]
    return doMoveCreature(goblin:getId(), chosenDirection)
end

local function removeTreasureGoblinById(goblinId)
    local goblin = Creature(goblinId)
    if not goblin then
        return
    end

    local config = getTreasureGoblinConfig()
    goblin:getPosition():sendMagicEffect(config.fleeEffect)
    goblin:remove()
end

local function fleeTreasureGoblin(playerId, goblinId, remainingMs, intervalMs)
    if remainingMs <= 0 then
        removeTreasureGoblinById(goblinId)
        return
    end

    local player = Player(playerId)
    local goblin = Creature(goblinId)
    if not player or not goblin then
        return
    end

    moveTreasureGoblinAway(goblin, player)

    addEvent(fleeTreasureGoblin, intervalMs, playerId, goblinId, remainingMs - intervalMs, intervalMs)
end

local function tryTriggerTreasureGoblin(player, target)
    if not player or not player:isPlayer() or not target or not isNormalMonster(target) then
        return
    end

    local chance = getEquippedSocketBonusTotal(player, "socket_treasure_goblin_chance")
    if chance <= 0 or not rollChance(chance) then
        return
    end

    local cooldown = math.max(1, getEquippedSocketBonusTotal(player, "socket_treasure_goblin_cooldown"))
    local playerId = player:getId()
    local now = os.time()
    local state = treasureGoblinState[playerId] or { cooldownUntil = 0 }
    treasureGoblinState[playerId] = state
    if now < (state.cooldownUntil or 0) then
        return
    end

    local config = getTreasureGoblinConfig()
    local pool = {}
    for _, monsterName in ipairs(config.monsters) do
        if type(monsterName) == "string" and monsterName ~= "" then
            pool[#pool + 1] = monsterName
        end
    end
    if #pool == 0 then
        return
    end

    local spawnPosition
    if type(_G.GemsSocket_findNearbySpawnPosition) == "function" then
        spawnPosition = _G.GemsSocket_findNearbySpawnPosition(target:getPosition(), config.spawnMinRange, config.spawnMaxRange)
    else
        spawnPosition = findNearbyFreePosition(target:getPosition(), config.spawnMinRange, config.spawnMaxRange)
    end
    if not spawnPosition then
        return
    end

    local monsterName = pool[math.random(#pool)]
    local goblin = Game.createMonster(monsterName, spawnPosition, true, true)
    if not goblin then
        return
    end

    state.cooldownUntil = now + cooldown
    spawnPosition:sendMagicEffect(config.spawnEffect)
    player:sendTextMessage(MESSAGE_INFO_DESCR, config.message)
    if goblin.say then
        goblin:say("Shiny shiny! Catch me!", TALKTYPE_MONSTER_SAY)
    end
    if goblin.setTarget then
        goblin:setTarget(nil)
    end

    addEvent(fleeTreasureGoblin, config.fleeIntervalMs, playerId, goblin:getId(), config.fleeSeconds * 1000, config.fleeIntervalMs)
    addEvent(removeTreasureGoblinById, config.lifetimeSeconds * 1000, goblin:getId())
end

local function getRollGemConfig()
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS.rollgem or nil
    local config = type(gemData) == "table" and type(gemData.rollGem) == "table" and gemData.rollGem or {}
    return {
        range = math.max(1, tonumber(config.range) or 3),
        blastRange = math.max(1, tonumber(config.blastRange) or 1),
        pushDistance = math.max(1, tonumber(config.pushDistance) or 2),
        damage = math.max(1, tonumber(config.damage) or 250),
        healPercent = math.max(1, tonumber(config.healPercent) or 5),
        manaPercent = math.max(1, tonumber(config.manaPercent) or 5),
        hasteSeconds = math.max(1, tonumber(config.hasteSeconds) or 5),
        hasteSpeed = math.max(1, tonumber(config.hasteSpeed) or 250),
        paralyzeSeconds = math.max(1, tonumber(config.paralyzeSeconds) or 2),
        pushImpactDamagePercent = math.max(0, tonumber(config.pushImpactDamagePercent) or 1),
        gemPowerMin = math.max(1, tonumber(config.gemPowerMin) or 1),
        gemPowerMax = math.max(1, tonumber(config.gemPowerMax) or 3),
        effect = config.effect or CONST_ME_PURPLEENERGY,
        blastEffect = config.blastEffect or CONST_ME_EXPLOSIONAREA,
        pushEffect = config.pushEffect or CONST_ME_POFF,
        pushImpactEffect = config.pushImpactEffect or CONST_ME_BLOCKHIT,
        healEffect = config.healEffect or CONST_ME_MAGIC_GREEN,
        manaEffect = config.manaEffect or CONST_ME_MAGIC_BLUE,
        hasteEffect = config.hasteEffect or CONST_ME_MAGIC_BLUE,
        paralyzeEffect = config.paralyzeEffect or CONST_ME_STUN,
    }
end

local function getRollGemTargets(player, range)
    if not player then
        return {}
    end
    return getNearbyMonsters(player:getPosition(), range)
end

local function isRollGemPushTile(position, monster)
    local tile = position and Tile(position) or nil
    if not tile
        or tile:getHouse()
        or tile:hasFlag(TILESTATE_PROTECTIONZONE)
        or tile:hasFlag(TILESTATE_BLOCKSOLID)
        or tile:hasFlag(TILESTATE_BLOCKPATH)
        or tile:getTopCreature() then
        return false
    end

    if type(tile.isWalkable) == "function" then
        local ok, walkable = pcall(function()
            return tile:isWalkable()
        end)
        if ok and not walkable then
            return false
        end
    end

    if monster and type(tile.queryAdd) == "function" then
        local ok, result = pcall(function()
            return tile:queryAdd(monster, FLAG_PATHFINDING or 0)
        end)
        if ok and result ~= (RETURNVALUE_NOERROR or 0) then
            return false
        end
    end

    return true
end

local function getRollGemNextPosition(position, direction)
    if not position then
        return nil
    end

    if direction == DIRECTION_NORTH then
        return Position(position.x, position.y - 1, position.z)
    elseif direction == DIRECTION_EAST then
        return Position(position.x + 1, position.y, position.z)
    elseif direction == DIRECTION_SOUTH then
        return Position(position.x, position.y + 1, position.z)
    elseif direction == DIRECTION_WEST then
        return Position(position.x - 1, position.y, position.z)
    end
    return nil
end

local function releaseRollGemParalyze(monsterId, expectedUntil)
    local monster = Monster(monsterId)
    if not monster then
        rollGemParalyzeState[monsterId] = nil
        return
    end

    local state = rollGemParalyzeState[monsterId]
    if not state or state.activeUntil ~= expectedUntil or os.time() < expectedUntil then
        return
    end

    if monster.setMovementBlocked then
        monster:setMovementBlocked(false)
    end
    if monster.setNoMove then
        monster:setNoMove(false)
    end
    rollGemParalyzeState[monsterId] = nil
end

local function pushRollGemTargets(player, config)
    local targets = getRollGemTargets(player, config.range)
    if #targets == 0 then
        return false
    end

    for _, monster in ipairs(targets) do
        local direction = getDirectionAway(monster:getPosition(), player:getPosition())
        if direction then
            local movedSteps = 0
            for _ = 1, config.pushDistance do
                local currentPosition = monster:getPosition()
                local nextPosition = getRollGemNextPosition(currentPosition, direction)
                if not isRollGemPushTile(nextPosition, monster) or not doMoveCreature(monster:getId(), direction) then
                    if movedSteps > 0 and config.pushImpactDamagePercent > 0 then
                        local impactDamage = math.max(1, math.floor(math.max(1, monster:getMaxHealth()) * (config.pushImpactDamagePercent / 100)))
                        doTargetCombatHealth(player, monster, COMBAT_PHYSICALDAMAGE, -impactDamage, -impactDamage, config.pushImpactEffect)
                    end
                    break
                end
                movedSteps = movedSteps + 1
            end
            if movedSteps > 0 then
                monster:getPosition():sendMagicEffect(config.pushEffect)
            end
        end
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Roll Gem throws nearby monsters away.")
    return true
end

local function blastRollGemTargets(player, config)
    local targets = getRollGemTargets(player, config.blastRange)
    if #targets == 0 then
        return false
    end

    player:getPosition():sendMagicEffect(config.blastEffect)
    for _, monster in ipairs(targets) do
        doTargetCombatHealth(player, monster, COMBAT_ARCANEDAMAGE, -config.damage, -config.damage, config.blastEffect)
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Roll Gem detonates around you.")
    return true
end

local function healRollGemPlayer(player, config)
    local amount = scaleAmount(player:getMaxHealth(), config.healPercent)
    if amount <= 0 then
        return false
    end

    player:addHealth("healing", amount)
    player:getPosition():sendMagicEffect(config.healEffect)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Roll Gem restores %d health.", amount))
    return true
end

local function manaRollGemPlayer(player, config)
    local amount = scaleAmount(player:getMaxMana(), config.manaPercent)
    if amount <= 0 then
        return false
    end

    player:addMana(amount)
    player:getPosition():sendMagicEffect(config.manaEffect)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Roll Gem restores %d mana.", amount))
    return true
end

local function hasteRollGemPlayer(player, config)
    local condition = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
    condition:setParameter(CONDITION_PARAM_TICKS, config.hasteSeconds * 1000)
    condition:setParameter(CONDITION_PARAM_SPEED, config.hasteSpeed)
    player:addCondition(condition)
    player:getPosition():sendMagicEffect(config.hasteEffect)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Roll Gem hastes you.")
    return true
end

local function paralyzeRollGemTargets(player, config)
    local targets = getRollGemTargets(player, config.range)
    if #targets == 0 then
        return false
    end

    local expectedUntil = os.time() + math.max(1, config.paralyzeSeconds)
    for _, monster in ipairs(targets) do
        local condition = Condition(CONDITION_PARALYZE)
        condition:setParameter(CONDITION_PARAM_TICKS, config.paralyzeSeconds * 1000)
        condition:setFormula(-0.45, -0.45, -0.45, -0.45)
        monster:addCondition(condition)
        if monster.setTarget then
            monster:setTarget(nil)
        end
        if monster.setFollowCreature then
            monster:setFollowCreature(nil)
        end
        if monster.setMovementBlocked then
            monster:setMovementBlocked(true)
        end
        if monster.setNoMove then
            monster:setNoMove(true)
        end
        rollGemParalyzeState[monster:getId()] = { activeUntil = expectedUntil }
        addEvent(releaseRollGemParalyze, config.paralyzeSeconds * 1000, monster:getId(), expectedUntil)
        monster:getPosition():sendMagicEffect(config.paralyzeEffect)
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Roll Gem locks nearby monsters in place.")
    return true
end

local function gemPowerRollGemPlayer(player, config)
    local maxCount = math.max(config.gemPowerMin, config.gemPowerMax)
    local count = math.random(config.gemPowerMin, maxCount)
    player:addItem(30658, count)
    player:getPosition():sendMagicEffect(config.effect)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Roll Gem creates %d Gem Power.", count))
    return true
end

local function tryTriggerRollGem(player, target)
    if not player or not player:isPlayer() or not target or not isNormalMonster(target) then
        return
    end

    local chance = getEquippedSocketBonusTotal(player, "socket_roll_chance")
    if chance <= 0 then
        return
    end

    local playerId = player:getId()
    local now = os.time()
    local state = rollGemState[playerId] or { cooldownUntil = 0 }
    rollGemState[playerId] = state
    if now < (state.cooldownUntil or 0) or not rollChance(chance) then
        return
    end

    local config = getRollGemConfig()
    local effects = {
        pushRollGemTargets,
        blastRollGemTargets,
        healRollGemPlayer,
        manaRollGemPlayer,
        hasteRollGemPlayer,
        paralyzeRollGemTargets,
        gemPowerRollGemPlayer,
    }

    local indexes = {}
    for index = 1, #effects do
        indexes[#indexes + 1] = index
    end

    local triggered = false
    while #indexes > 0 and not triggered do
        local pick = math.random(#indexes)
        local effect = effects[table.remove(indexes, pick)]
        triggered = effect(player, config) == true
    end

    if triggered then
        state.cooldownUntil = now + math.max(1, getEquippedSocketBonusTotal(player, "socket_roll_cooldown"))
    end
end

function _G.GemsSocket_advancedOnSpellCast(player, spellName, spellGroup, aggressive, manaCost)
    if not player or not player:isPlayer() then
        return
    end

    local bonusCache = getSocketBonusCache(player)
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onSpellCast) == "function" then
        _G.ExtraSocketGems.onSpellCast(player, spellName, spellGroup, aggressive, manaCost, bonusCache)
    end

    if not aggressive then
        return
    end

    spellGroup = tostring(spellGroup or ""):lower()
    if spellGroup ~= "attack" then
        return
    end

    prepareMomentumSpell(player)

    local chance = getEquippedSocketBonusTotal(player, "socket_phantom_chance")
    if chance <= 0 or not rollChance(chance) then
        return
    end

    local playerId = player:getId()
    local now = os.time()
    local state = phantomState[playerId] or { cooldownUntil = 0 }
    phantomState[playerId] = state
    if now < state.cooldownUntil then
        return
    end

    local duration = math.max(1, getEquippedSocketBonusTotal(player, "socket_phantom_duration"))
    local cooldown = math.max(duration, getEquippedSocketBonusTotal(player, "socket_phantom_cooldown"))
    local pos = findNearbyFreePosition(player:getPosition(), 1, 2)
    local phantom = summonTemporaryMonster(player, "Socket Phantom Double", pos, duration, true)
    if not phantom then
        return
    end

    state.cooldownUntil = now + cooldown
    player:getPosition():sendMagicEffect(CONST_ME_PURPLEENERGY)
end

function _G.GemsSocket_advancedTryTriggerParadox(player, incomingDamage, attacker, bonusCache)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return false
    end

    if not player or not player:isPlayer() or not attacker or not attacker:isMonster() then
        return false
    end

    local playerTile = Tile(player:getPosition())
    if playerTile and playerTile:hasFlag(TILESTATE_PROTECTIONZONE) then
        return false
    end

    incomingDamage = tonumber(incomingDamage) or 0
    if incomingDamage <= 0 then
        return false
    end

    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}

    local threshold = math.max(0, totals.socket_paradox_threshold or 0)
    if threshold <= 0 then
        return false
    end

    local currentHealth = math.max(0, player:getHealth())
    local maxHealth = math.max(1, player:getMaxHealth())
    local healthPercentBefore = (currentHealth / maxHealth) * 100
    local healthPercentAfter = (math.max(0, currentHealth - incomingDamage) / maxHealth) * 100
    if healthPercentBefore <= threshold or healthPercentAfter > threshold then
        return false
    end

    local playerId = player:getId()
    local now = os.time()
    local state = paradoxState[playerId] or { cooldownUntil = 0 }
    paradoxState[playerId] = state
    if state.activeUntil or now < (state.cooldownUntil or 0) then
        return false
    end

    local special = getParadoxSpecialConfig()
    local duration = math.max(1, totals.socket_paradox_duration or 0)
    if duration <= 1 then
        duration = math.max(1, tonumber(special.durationSeconds) or 5)
    end

    local cooldown = math.max(duration, totals.socket_paradox_cooldown or 0)
    local radius = math.max(1, totals.socket_paradox_radius or 0)
    local spawnPosition = findNearbyFreePosition(player:getPosition(), 1, 2)
    if not spawnPosition then
        return false
    end

    local echo = summonTemporaryMonster(player, special.monsterName or "Clone", spawnPosition, duration, true)
    if not echo then
        return false
    end

    if echo.rename then
        echo:rename(player:getName(), "a paradox echo")
    end

    state.cooldownUntil = now + cooldown
    state.activeUntil = now + duration
    state.echoId = echo:getId()
    state.restoreGhostMode = not player:isInGhostMode()

    if state.restoreGhostMode then
        player:setGhostMode(true)
    end

    player:getPosition():sendMagicEffect(special.triggerEffect or CONST_ME_PURPLEENERGY)
    spawnPosition:sendMagicEffect(special.triggerEffect or CONST_ME_PURPLEENERGY)
    player:sendTextMessage(MESSAGE_INFO_DESCR, special.message or "Paradox Gem splits your timeline and leaves a false self behind.")

    targetCreature(attacker, echo)
    retargetParadoxMonsters(playerId, echo:getId(), state.activeUntil, radius)
    addEvent(endParadoxTimeline, duration * 1000, playerId, state.activeUntil)
    return true
end

function _G.GemsSocket_advancedOnManaChange(player, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if not player or not player:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if getEquippedSocketBonusTotal(player, "socket_mana_nova_cooldown") <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    addEvent(checkManaNovaAfterChange, 1, player:getId(), player:getMana())
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function _G.GemsSocket_advancedOnHealing(target, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
    local player = attacker and attacker:isPlayer() and attacker or target
    if not player or not player:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local percent = getLastBreathPercent(player) + getPacifistPercent(player)
    if percent > 0 then
        if primaryType == COMBAT_HEALING and primaryDamage ~= 0 then
            primaryDamage = addScaledDamage(primaryDamage, percent)
        end
        if secondaryType == COMBAT_HEALING and secondaryDamage ~= 0 then
            secondaryDamage = addScaledDamage(secondaryDamage, percent)
        end
    end
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onHealing) == "function" then
        primaryDamage, primaryType, secondaryDamage, secondaryType = _G.ExtraSocketGems.onHealing(target, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function _G.GemsSocket_advancedOnIncomingHit(player, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache, attackerBonusCache)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if not player or not player:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}

    local totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if totalDamage <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if lastBreathUsesProc(totals) then
        tryActivateLastBreath(player, totals)
    else
        getLastBreathPercent(player, totals)
    end

    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onIncomingHit) == "function" then
        primaryDamage, primaryType, secondaryDamage, secondaryType = _G.ExtraSocketGems.onIncomingHit(player, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local attackerPlayer = getPlayerAttacker(attacker)
    if attackerPlayer and attackerPlayer ~= player then
        attackerBonusCache = attackerBonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(attackerPlayer) or nil)
        local attackerTotals = attackerBonusCache and attackerBonusCache.totals or {}
        primaryDamage, secondaryDamage = applyPendulumOutgoing(attackerPlayer, primaryDamage, secondaryDamage, attackerTotals)

        primaryDamage, secondaryDamage = applyNemesisOutgoingPvP(attackerPlayer, player, primaryDamage, secondaryDamage, attackerBonusCache, attackerTotals)
        primaryDamage, secondaryDamage = applyNemesisIncoming(player, attackerPlayer, primaryDamage, secondaryDamage, bonusCache, totals)

        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local formationReduction = getFormationReduction(player, bonusCache)
    if formationReduction > 0 then
        primaryDamage, secondaryDamage = applyPercentReduction(primaryDamage, secondaryDamage, formationReduction)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
        player:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end


    primaryDamage, secondaryDamage = applyAnchorReduction(player, primaryDamage, secondaryDamage, totals)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)

    primaryDamage, secondaryDamage = applyPendulumIncoming(player, primaryDamage, secondaryDamage, totals)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)

    armObsidianGrudge(player, totalDamage, totals)

    if origin == ORIGIN_CONDITION then
        local cooldown = totals.socket_hexmirror_cooldown or 0
        if cooldown > 0 then
            local playerId = player:getId()
            local now = os.time()
            local state = hexmirrorState[playerId] or { cooldownUntil = 0 }
            hexmirrorState[playerId] = state
            if now >= (state.cooldownUntil or 0) then
                local maxTargets = math.max(1, totals.socket_hexmirror_targets or 0)
                local range = math.max(1, totals.socket_hexmirror_range or 0)
                local duration = math.max(1, totals.socket_hexmirror_duration or 0)
                local damage = math.max(1, totals.socket_hexmirror_damage or 0)
                local targets = pickNearbyMonsters(player:getPosition(), range, maxTargets)
                if #targets > 0 then
                    state.cooldownUntil = now + math.max(1, cooldown)
                    local special = getSpecialConfig("conditionMirror")
                    player:getPosition():sendMagicEffect(special.triggerEffect or CONST_ME_MAGIC_RED)
                    player:sendTextMessage(MESSAGE_INFO_DESCR, special.message or "Hexmirror Gem reflects a random curse nearby.")
                    for _, monster in ipairs(targets) do
                        local condition, effect = buildReflectedCondition(duration, damage)
                        monster:addCondition(condition)
                        monster:getPosition():sendMagicEffect(effect or CONST_ME_MAGIC_RED)
                    end
                end
            end
        end
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local cooldown = totals.socket_chameleon_cooldown or 0
    local resistance = totals.socket_chameleon_resistance or 0
    if cooldown <= 0 or resistance <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if not isElementalType(primaryType) and not isElementalType(secondaryType) then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local playerId = player:getId()
    local now = os.time()
    local state = chameleonState[playerId] or { cooldownUntil = 0 }
    chameleonState[playerId] = state
    if now < (state.cooldownUntil or 0) then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    state.cooldownUntil = now + math.max(1, cooldown)
    primaryDamage, secondaryDamage = applyPercentReduction(primaryDamage, secondaryDamage, resistance)
    local effectType = isElementalType(primaryType) and primaryType or secondaryType
    player:getPosition():sendMagicEffect(elementalEffects[effectType] or getSpecialConfig("chameleon").triggerEffect or CONST_ME_BLOCKHIT)
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function _G.GemsSocket_advancedOnPlayerLethalHit(player, attacker, incomingDamage)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return
    end

    if not player or not player:isPlayer() or (tonumber(incomingDamage) or 0) <= 0 then
        return
    end

    local attackerPlayer = getPlayerAttacker(attacker)
    if not attackerPlayer or attackerPlayer == player then
        return
    end

    NemesisBrandGem.brandKiller(player, attackerPlayer)
    NemesisBrandGem.clearBrandAgainst(attackerPlayer, player)
end

function _G.GemsSocket_advancedOnOffensiveHit(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}

    local totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if totalDamage <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    resetPacifistPower(player)

    primaryDamage, secondaryDamage = applyObsidianGrudge(player, primaryDamage, secondaryDamage, totals)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage, secondaryDamage = applyHuntersFocus(player, target, primaryDamage, secondaryDamage, totals)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage, secondaryDamage = applyObituaryDamage(player, target, primaryDamage, secondaryDamage, bonusCache)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage, secondaryDamage = applyLastBreathDamage(player, primaryDamage, secondaryDamage, totals)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage, secondaryDamage = applyMomentumDamage(player, origin, primaryDamage, secondaryDamage)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage, secondaryDamage = applyBloodPriceDamage(player, origin, primaryDamage, secondaryDamage)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage, secondaryDamage = applyPendulumOutgoing(player, primaryDamage, secondaryDamage, totals)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    primaryDamage, secondaryDamage = OverkillGem.apply(player, target, primaryDamage, secondaryDamage, bonusCache)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onOffensiveHit) == "function" then
        primaryDamage, primaryType, secondaryDamage, secondaryType = _G.ExtraSocketGems.onOffensiveHit(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end
    tryTriggerWarcry(player, totals)
    tryTriggerHerald(player, target, totalDamage, totals)

    if ORIGIN_WAND and origin == ORIGIN_WAND and (totals.socket_galvanic_cooldown or 0) > 0 then
        local chargeSeconds = math.max(1, totals.socket_galvanic_charge_seconds or 0)
        local playerId = player:getId()
        galvanicCharges[playerId] = galvanicCharges[playerId] or {}
        galvanicCharges[playerId][target:getId()] = os.time() + chargeSeconds
        target:getPosition():sendMagicEffect((getSpecialConfig("galvanic").chargeEffect) or CONST_ME_ENERGYHIT)
    end

    if isVolleyChainHit(player, origin) and (totals.socket_volley_chain_cooldown or 0) > 0 then
        local playerId = player:getId()
        local now = os.time()
        local state = volleyChainState[playerId] or { cooldownUntil = 0 }
        volleyChainState[playerId] = state
        if now >= (state.cooldownUntil or 0) then
            local maxTargets = math.max(1, totals.socket_volley_chain_targets or 0)
            local range = math.max(1, totals.socket_volley_chain_range or 0)
            local damagePercent = math.max(0, totals.socket_volley_chain_damage_percent or 0)
            local chainDamage = scaleAmount(totalDamage, damagePercent)
            local targets = pickNearbyMonsters(target:getPosition(), range, maxTargets, target)
            if chainDamage > 0 and #targets > 0 then
                state.cooldownUntil = now + math.max(1, totals.socket_volley_chain_cooldown or 0)
                target:getPosition():sendMagicEffect(CONST_ME_HITAREA)
                for _, chainedTarget in ipairs(targets) do
                    local result = doTargetCombatHealth(player, chainedTarget, primaryType, -chainDamage, -chainDamage, CONST_ME_HITAREA)
                    if result == false then
                        chainedTarget:addHealth(-chainDamage)
                        chainedTarget:getPosition():sendMagicEffect(CONST_ME_HITAREA)
                    end
                end
            end
        end
    end

    if isSpellOrigin(origin) and (isEnergyDamageType(primaryType) or isEnergyDamageType(secondaryType))
        and (totals.socket_galvanic_cooldown or 0) > 0 then
        local playerId = player:getId()
        local chargedTargets = galvanicCharges[playerId]
        local targetId = target:getId()
        local now = os.time()
        if chargedTargets and (chargedTargets[targetId] or 0) >= now then
            local state = galvanicState[playerId] or { cooldownUntil = 0 }
            galvanicState[playerId] = state
            if now >= (state.cooldownUntil or 0) then
                local maxTargets = math.max(1, totals.socket_galvanic_targets or 0)
                local range = math.max(1, totals.socket_galvanic_range or 0)
                local damagePercent = math.max(0, totals.socket_galvanic_damage_percent or 0)
                local chainDamage = scaleAmount(totalDamage, damagePercent)
                local targets = pickNearbyMonsters(target:getPosition(), range, maxTargets, target)
                if chainDamage > 0 and #targets > 0 then
                    state.cooldownUntil = now + math.max(1, totals.socket_galvanic_cooldown or 0)
                    chargedTargets[targetId] = nil
                    local special = getSpecialConfig("galvanic")
                    target:getPosition():sendMagicEffect(special.chainEffect or CONST_ME_ENERGYAREA)
                    player:sendTextMessage(MESSAGE_INFO_DESCR, special.message or "Galvanic Gem discharges stored energy.")
                    for _, chainedTarget in ipairs(targets) do
                        doTargetCombatHealth(player, chainedTarget, COMBAT_ENERGYDAMAGE, -chainDamage, -chainDamage, CONST_ME_ENERGYHIT)
                    end
                end
            end
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function _G.GemsSocket_advancedShouldSavePotion(player)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return false
    end

    if not player or not player:isPlayer() then
        return false
    end

    local chance = getEquippedSocketBonusTotal(player, "socket_alchemist_save_chance")
    if chance <= 0 or not rollChance(chance) then
        if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.shouldSavePotion) == "function" then
            return _G.ExtraSocketGems.shouldSavePotion(player)
        end
        return false
    end

    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Alchemist Gem preserves your potion.")
    return true
end

function _G.GemsSocket_advancedOnUsePotion(player, target, potion)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return nil
    end
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onUsePotion) == "function" then
        return _G.ExtraSocketGems.onUsePotion(player, target, potion)
    end
    return nil
end

function _G.GemsSocket_advancedOnKill(player, target, lastHit)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return true
    end

    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return true
    end

    local dreamChance = getEquippedSocketBonusTotal(player, "socket_dreamcatcher_chance")
    if rollChance(dreamChance) then
        local minCount = math.max(1, getEquippedSocketBonusTotal(player, "socket_dreamcatcher_min"))
        local maxCount = math.max(minCount, getEquippedSocketBonusTotal(player, "socket_dreamcatcher_max"))
        local count = math.random(minCount, maxCount)
        player:addItem(30658, count)
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Dreamcatcher Stone caught %d Gem Power.", count))
    end

    local revenantChance = getEquippedSocketBonusTotal(player, "socket_revenant_chance")
    if rollChance(revenantChance) then
        local duration = math.max(1, getEquippedSocketBonusTotal(player, "socket_revenant_duration"))
        local pos = findNearbyFreePosition(target:getPosition(), 1, 2)
        local revenant = summonTemporaryMonster(player, "Socket Revenant", pos, duration, false)
        if revenant then
            pos:sendMagicEffect(CONST_ME_MORTAREA)
        end
    end

    tryTriggerTreasureGoblin(player, target)
    tryTriggerRollGem(player, target)
    tryTriggerWayfinder(player)
    CarrionGem.recordKill(player, target)
    RequiemGem.recordKill(player, target)
    trySpreadInfection(player, target)
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onKill) == "function" then
        _G.ExtraSocketGems.onKill(player, target, lastHit)
    end

    return true
end

function _G.GemsSocket_advancedTryTriggerRequiem(player, incomingDamage, bonusCache)
    return RequiemGem.tryPreventDeath(player, incomingDamage, bonusCache)
end

function _G.GemsSocket_advancedOnDropLoot(player, monster, corpse)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return true
    end

    if not player or not player:isPlayer() or not corpse then
        return true
    end

    if type(_G.TreasuryGem) == "table" and _G.TreasuryGem.recordCorpseLoot then
        _G.TreasuryGem.recordCorpseLoot(player, corpse)
    end

    if type(_G.CorruptionGem) == "table" and _G.CorruptionGem.applyBonusLoot then
        _G.CorruptionGem.applyBonusLoot(player, monster, corpse)
    end

    return true
end

function _G.GemsSocket_advancedGetLootRarityBonus(player)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return 0
    end

    if not player or not player:isPlayer() then
        return 0
    end

    local total = getTideMode() == "peak" and math.max(0, getEquippedSocketBonusTotal(player, "socket_tide_loot_percent")) or 0
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.getLootRarityBonus) == "function" then
        total = total + (tonumber(_G.ExtraSocketGems.getLootRarityBonus(player)) or 0)
    end
    return total
end

function _G.GemsSocket_advancedOnGainExperience(player, exp, source)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return exp
    end

    if not player or not player:isPlayer() or getTideMode() ~= "offpeak" then
        return exp
    end

    local percent = math.max(0, getEquippedSocketBonusTotal(player, "socket_tide_xp_percent"))
    if percent <= 0 then
        return exp
    end

    return exp * (1 + (percent / 100))
end

local function runRuneheart(playerId)
    local player = Player(playerId)
    if not player then
        runeheartTimers[playerId] = nil
        return
    end

    local interval = getEquippedSocketBonusTotal(player, "socket_runeheart_interval")
    if interval <= 0 then
        runeheartTimers[playerId] = nil
        return
    end

    local runePool = getRuneheartRunePool()
    local runeEntry = runePool and runePool[math.random(#runePool)] or nil
    local runeId = runeEntry and runeEntry.id or nil
    if runeId and player:addItem(runeId, 1) then
        local runeName = runeEntry.name or ItemType(runeId):getName() or "a rune"
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Runeheart Stone engraved %s into your backpack.", runeName))
    end

    addEvent(runRuneheart, math.max(60, interval) * 1000, playerId)
end

function _G.GemsSocket_ensureRuneheartTimer(player)
    if not player or not player:isPlayer()
        or getEquippedSocketBonusTotal(player, "socket_runeheart_interval") <= 0 then
        return
    end
    local playerId = player:getId()
    if not runeheartTimers[playerId] then
        runeheartTimers[playerId] = true
        addEvent(runRuneheart, math.max(60, getEquippedSocketBonusTotal(player, "socket_runeheart_interval")) * 1000, playerId)
    end
end

function _G.GemsSocket_advancedOnLogin(player)
    if type(_G.GemsSocket_isEnabled) == "function" and not _G.GemsSocket_isEnabled() then
        return true
    end

    if not player or not player:isPlayer() then
        return true
    end

    local playerId = player:getId()
    ensureTideTimer()
    if getEquippedSocketBonusTotal(player, "socket_damage_tracker_enabled") > 0 then
        damageGemDirty[playerId] = true
    end
    ensureAdvancedGemPulse(player)
    _G.GemsSocket_ensureRuneheartTimer(player)

    _G.GemsSocket_advancedRefreshPlayerBonuses(player)
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onLogin) == "function" then
        _G.ExtraSocketGems.onLogin(player)
    end
    return true
end

function _G.GemsSocket_advancedOnLogout(player)
    if not player or not player:isPlayer() then
        return true
    end

    if type(_G.DamageGem) == "table" and type(_G.DamageGem.flushPending) == "function" then
        _G.DamageGem.flushPending(player)
    end
    if damageGemDirty[player:getId()] and type(_G.DamageGem) == "table" and type(_G.DamageGem.refreshEquipped) == "function" then
        _G.DamageGem.refreshEquipped(player)
    end

    local playerId = player:getId()
    local state = paradoxState[playerId]
    if state then
        if state.restoreGhostMode then
            player:setGhostMode(false)
        end

        if state.echoId then
            removeCreatureById(state.echoId)
        end

        paradoxState[playerId] = nil
    end

    manaNovaState[playerId] = nil
    hexmirrorState[playerId] = nil
    chameleonState[playerId] = nil
    volleyChainState[playerId] = nil
    galvanicState[playerId] = nil
    galvanicCharges[playerId] = nil
    treasureGoblinState[playerId] = nil
    rollGemState[playerId] = nil
    wayfinderState[playerId] = nil
    warcryState[playerId] = nil
    warcryShieldState[playerId] = nil
    obsidianGrudgeState[playerId] = nil
    martyrState[playerId] = nil
    heraldState[playerId] = nil
    huntersFocusState[playerId] = nil
    lastBreathState[playerId] = nil
    anchorState[playerId] = nil
    momentumState[playerId] = nil
    bloodPriceState[playerId] = nil
    pacifistState[playerId] = nil
    carrionState[playerId] = nil
    damageGemDirty[playerId] = nil
    damageGemPending[playerId] = nil
    advancedPulseTokens[playerId] = nil
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onLogout) == "function" then
        _G.ExtraSocketGems.onLogout(player)
    end

    return true
end

function _G.GemsSocket_advancedHasCombatRuntime(playerId)
    local lastBreath = lastBreathState[playerId]
    local momentum = momentumState[playerId]
    local bloodPrice = bloodPriceState[playerId]
    return lastBreath and (tonumber(lastBreath.percent) or 0) > 0
        or momentum and (tonumber(momentum.pendingPercent) or 0) > 0
        or bloodPrice and (tonumber(bloodPrice.damagePercent) or 0) > 0
        or damageGemDirty[playerId] ~= nil
        or damageGemPending[playerId] ~= nil
end

function _G.GemsSocket_advancedRefreshPlayerBonuses(player)
    if not player or not player:isPlayer() then
        return
    end

    ensureAdvancedGemPulse(player)
    _G.GemsSocket_ensureRuneheartTimer(player)
    if type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.refreshPlayerBonuses) == "function" then
        _G.ExtraSocketGems.refreshPlayerBonuses(player)
    end
end

function _G.GemsSocket_rollCraftRarityBonus(player, currentRarityId, allowRarity, rarityRoller)
    if not player or not allowRarity then
        return currentRarityId or 0
    end

    local chance = getEquippedSocketBonusTotal(player, "socket_forge_rarity_chance")
    if chance <= 0 or not rollChance(chance) then
        return currentRarityId or 0
    end

    if (tonumber(currentRarityId) or 0) > 0 then
        return currentRarityId
    end

    if type(rarityRoller) == "function" then
        local forgedRarity = tonumber(rarityRoller()) or 0
        if forgedRarity > 0 then
            return forgedRarity
        end
    end
    return 1
end
