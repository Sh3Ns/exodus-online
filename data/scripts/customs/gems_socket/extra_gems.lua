ExtraSocketGems = ExtraSocketGems or {}
if ExtraSocketGems.loaded then
    return
end

ExtraSocketGems.loaded = true

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

local CONDITION_SUBIDS = {
    guardian = 992461,
    panic = 992462,
    madness = 992463,
    hunterCompass = 992464,
}

local executionerState = {}
local echoStrikeLock = {}
local ruptureState = {}
local guardianPulseState = {}
local secondSkinState = {}
local panicWardState = {}
local memoryState = {}
local madnessState = {}
local madnessTokens = {}
local madnessSerial = 0
local ambushState = {}
local ambushRewardByMonsterId = {}
local treasureEchoState = {}
local luckyHourglassState = {}
local luckyHourglassTokens = {}
local luckyHourglassSerial = 0
local sunderState = {}
local sharedGraceState = {}
local beaconState = {}
local recentBeaconHealers = {}
local bulwarkState = {}
local titanState = {}
local manaLeechState = {}
local evasionState = {}
local lifelineState = {}
local guardBreakState = {}
local weakPointState = {}
local lightweightState = {}

local elementalTypes = {}
if COMBAT_FIREDAMAGE then elementalTypes[COMBAT_FIREDAMAGE] = true end
if COMBAT_ICEDAMAGE then elementalTypes[COMBAT_ICEDAMAGE] = true end
if COMBAT_ENERGYDAMAGE then elementalTypes[COMBAT_ENERGYDAMAGE] = true end
if COMBAT_EARTHDAMAGE then elementalTypes[COMBAT_EARTHDAMAGE] = true end
if COMBAT_DEATHDAMAGE then elementalTypes[COMBAT_DEATHDAMAGE] = true end
if COMBAT_HOLYDAMAGE then elementalTypes[COMBAT_HOLYDAMAGE] = true end
if COMBAT_WATERDAMAGE then elementalTypes[COMBAT_WATERDAMAGE] = true end
if COMBAT_DROWNDAMAGE then elementalTypes[COMBAT_DROWNDAMAGE] = true end
if COMBAT_ARCANEDAMAGE then elementalTypes[COMBAT_ARCANEDAMAGE] = true end

local function getBonus(player, key)
    if not player or type(key) ~= "string" then
        return 0
    end
    if type(_G.GemsSocket_getEquippedSocketBonusTotal) == "function" then
        return tonumber(_G.GemsSocket_getEquippedSocketBonusTotal(player, key)) or 0
    end

    local total = 0
    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            total = total + (tonumber(item:getCustomAttribute("socket_bonus_" .. key) or 0) or 0)
        end
    end
    return total
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
    return math.abs(tonumber(primaryDamage) or 0) + math.abs(tonumber(secondaryDamage) or 0)
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

local function reduceDamage(damage, percent)
    damage = tonumber(damage) or 0
    percent = tonumber(percent) or 0
    if damage == 0 or percent <= 0 then
        return damage
    end
    local reduced = math.floor(math.abs(damage) * math.max(0, 1 - (percent / 100)))
    if reduced <= 0 then
        return 0
    end
    if damage < 0 then
        return -reduced
    end
    return reduced
end

local function increaseDamage(damage, percent)
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
    local reduced = math.floor(math.abs(damage) * math.max(0, 1 - (percent / 100)))
    if damage < 0 then
        return -reduced
    end
    return reduced
end

local function reduceHealingAmount(damage, percent)
    damage = tonumber(damage) or 0
    percent = tonumber(percent) or 0
    if damage >= 0 or percent <= 0 then
        return damage
    end
    local reduced = math.floor(math.abs(damage) * math.max(0, 1 - (percent / 100)))
    return -reduced
end

local function getDominantDamageType(primaryDamage, primaryType, secondaryDamage, secondaryType)
    local primary = math.abs(tonumber(primaryDamage) or 0)
    local secondary = math.abs(tonumber(secondaryDamage) or 0)
    if secondary > primary then
        return secondaryType
    end
    return primaryType
end

local function isElementalType(combatType)
    return elementalTypes[combatType] == true
end

local function isBasicAttackOrigin(origin, primaryType, secondaryType)
    if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or (ORIGIN_WAND and origin == ORIGIN_WAND) then
        return true
    end
    -- Some weapon hits can arrive as ORIGIN_NONE on this codebase. Keep the
    -- fallback physical-only so offensive spells still do not trigger basic gems.
    if origin == ORIGIN_NONE then
        return primaryType == COMBAT_PHYSICALDAMAGE or secondaryType == COMBAT_PHYSICALDAMAGE
    end
    return false
end

local function isSpellOrigin(origin)
    if origin == nil or origin == ORIGIN_CONDITION or origin == ORIGIN_MELEE or origin == ORIGIN_RANGED then
        return false
    end
    if ORIGIN_WAND and origin == ORIGIN_WAND then
        return false
    end
    return true
end

local function reduceDamageByFlat(primaryDamage, secondaryDamage, flatAmount)
    flatAmount = math.max(0, math.floor(tonumber(flatAmount) or 0))
    if flatAmount <= 0 then
        return primaryDamage, secondaryDamage
    end

    local primary = math.abs(tonumber(primaryDamage) or 0)
    local secondary = math.abs(tonumber(secondaryDamage) or 0)
    local total = primary + secondary
    if total <= 0 then
        return primaryDamage, secondaryDamage
    end

    flatAmount = math.min(flatAmount, total)
    local primaryReduction = math.floor(flatAmount * (primary / total))
    local secondaryReduction = flatAmount - primaryReduction
    local newPrimary = math.max(0, primary - primaryReduction)
    local newSecondary = math.max(0, secondary - secondaryReduction)
    if (tonumber(primaryDamage) or 0) < 0 then
        newPrimary = -newPrimary
    end
    if (tonumber(secondaryDamage) or 0) < 0 then
        newSecondary = -newSecondary
    end
    return newPrimary, newSecondary
end

local function reduceMagicDamage(primaryDamage, primaryType, secondaryDamage, secondaryType, percent)
    local changed = false
    if isElementalType(primaryType) and (tonumber(primaryDamage) or 0) ~= 0 then
        primaryDamage = reduceDamage(primaryDamage, percent)
        changed = true
    end
    if isElementalType(secondaryType) and (tonumber(secondaryDamage) or 0) ~= 0 then
        secondaryDamage = reduceDamage(secondaryDamage, percent)
        changed = true
    end
    return primaryDamage, secondaryDamage, changed
end

local function getPositionDistance(firstPosition, secondPosition)
    if not firstPosition or not secondPosition or firstPosition.z ~= secondPosition.z then
        return 0
    end
    return math.max(math.abs(firstPosition.x - secondPosition.x), math.abs(firstPosition.y - secondPosition.y))
end

local function updateEvasionMovement(player, totals, now)
    local requiredTiles = math.max(0, math.floor(tonumber(totals.socket_evasion_tiles_required) or 0))
    if requiredTiles <= 0 then
        evasionState[player:getId()] = nil
        return nil
    end

    local playerId = player:getId()
    local position = player:getPosition()
    if not position then
        return evasionState[playerId]
    end

    local state = evasionState[playerId] or {
        tiles = 0,
        activeUntil = 0,
        cooldownUntil = 0,
    }
    evasionState[playerId] = state

    if state.lastPosition then
        local distance = getPositionDistance(position, state.lastPosition)
        if distance > 0 then
            state.tiles = math.min(requiredTiles, math.max(0, tonumber(state.tiles) or 0) + math.min(distance, requiredTiles))
        end
    end
    state.lastPosition = { x = position.x, y = position.y, z = position.z }

    if state.tiles >= requiredTiles and now >= (state.cooldownUntil or 0) then
        local duration = math.max(1, math.floor(tonumber(totals.socket_evasion_duration) or 0))
        local cooldown = math.max(duration, math.floor(tonumber(totals.socket_evasion_cooldown) or 0))
        state.tiles = 0
        state.activeUntil = now + duration
        state.cooldownUntil = now + cooldown
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end
    return state
end

local function getLightweightState(player)
    local playerId = player:getId()
    local state = lightweightState[playerId]
    if not state then
        state = {
            cooldowns = {},
            counters = {},
            flags = {},
            lastAttackAt = 0,
            lastReceivedAt = 0,
            lastSpellAt = 0,
            lastMoveAt = os.time(),
            movedTiles = 0,
            freshStartReady = true,
        }
        lightweightState[playerId] = state
    end
    return state
end

local function cooldownReady(state, key, now)
    return now >= (state.cooldowns[key] or 0)
end

local function setCooldown(state, key, seconds, now)
    state.cooldowns[key] = now + math.max(0, tonumber(seconds) or 0)
end

local function useCooldown(state, key, seconds, now)
    if not cooldownReady(state, key, now) then
        return false
    end
    setCooldown(state, key, seconds, now)
    return true
end

local function isTrackedKillGemHit(player, attacker, origin)
    if not player or not player:isPlayer() then
        return false
    end

    if origin == ORIGIN_CONDITION then
        return false
    end

    if not attacker or attacker == player then
        return false
    end

    return true
end

local function applyOutgoingPercent(primaryDamage, secondaryDamage, percent)
    percent = math.max(0, tonumber(percent) or 0)
    if percent <= 0 then
        return primaryDamage, secondaryDamage, false
    end
    return addScaledDamage(primaryDamage, percent), addScaledDamage(secondaryDamage, percent), true
end

local function applyIncomingReduction(primaryDamage, secondaryDamage, percent)
    percent = math.max(0, tonumber(percent) or 0)
    if percent <= 0 then
        return primaryDamage, secondaryDamage, false
    end
    return reduceDamage(primaryDamage, percent), reduceDamage(secondaryDamage, percent), true
end

local function scaleByPercent(amount, percent)
    amount = math.max(0, tonumber(amount) or 0)
    percent = math.max(0, tonumber(percent) or 0)
    if amount <= 0 or percent <= 0 then
        return 0
    end
    return math.max(1, math.floor(amount * (percent / 100)))
end

local function playerHealthPercent(player)
    return player:getMaxHealth() > 0 and ((player:getHealth() / player:getMaxHealth()) * 100) or 100
end

local function playerManaPercent(player)
    return player:getMaxMana() > 0 and ((player:getMana() / player:getMaxMana()) * 100) or 100
end

local function updateLightweightMovement(player, state, now)
    local position = player:getPosition()
    if not position then
        return
    end
    state.lastMovementDistance = 0
    if state.lastPosition then
        local distance = getPositionDistance(position, state.lastPosition)
        state.lastMovementDistance = distance
        if distance > 0 then
            state.movedTiles = math.min(1000, math.max(0, tonumber(state.movedTiles) or 0) + math.min(distance, 25))
            state.lastMoveAt = now
        end
    end
    state.lastPosition = { x = position.x, y = position.y, z = position.z }
end

function ExtraSocketGems.onPlayerMove(player)
    if not player or not player:isPlayer() then
        return
    end

    local cache = type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil
    local totals = cache and cache.totals or {}
    if (tonumber(totals.socket_nullstep_reduction_percent) or 0) <= 0 then
        return
    end

    local now = os.time()
    local state = getLightweightState(player)
    updateLightweightMovement(player, state, now)
    local requiredTiles = math.max(2, tonumber(totals.socket_nullstep_min_distance) or 2)
    if ((state.lastMovementDistance or 0) >= requiredTiles or (state.movedTiles or 0) >= requiredTiles)
        and useCooldown(state, "nullstep", totals.socket_nullstep_cooldown, now) then
        state.movedTiles = 0
        state.nullstepActiveUntil = now + math.max(1, tonumber(totals.socket_nullstep_window) or 3)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end
end

local function removeOneNegativeCondition(player)
    if not player or not player:isPlayer() then
        return false
    end
    if type(_G.GemsSocket_removeRandomSocketDebuff) == "function" then
        return _G.GemsSocket_removeRandomSocketDebuff(player) == true
    end

    local conditions = {
        CONDITION_POISON,
        CONDITION_FIRE,
        CONDITION_ENERGY,
        CONDITION_BLEEDING,
        CONDITION_PARALYZE,
        CONDITION_DRUNK,
        CONDITION_DROWN,
        CONDITION_FREEZING,
        CONDITION_DAZZLED,
        CONDITION_CURSED,
    }

    for _, conditionType in ipairs(conditions) do
        if conditionType then
            if player:getCondition(conditionType, CONDITIONID_DEFAULT) then
                player:removeCondition(conditionType, CONDITIONID_DEFAULT)
                return true
            end
            if CONDITIONID_COMBAT and player:getCondition(conditionType, CONDITIONID_COMBAT) then
                player:removeCondition(conditionType, CONDITIONID_COMBAT)
                return true
            end
        end
    end
    return false
end

local function incrementCounter(state, key, required)
    required = math.max(1, math.floor(tonumber(required) or 1))
    local value = (state.counters[key] or 0) + 1
    if value >= required then
        state.counters[key] = 0
        return true
    end
    state.counters[key] = value
    return false
end

local function applyLightweightOutgoing(player, target, primaryDamage, secondaryDamage, origin, totals, now, totalDamage)
    local state = getLightweightState(player)
    updateLightweightMovement(player, state, now)
    local changed = false

    local function bonus(key, percent, cooldown)
        if percent > 0 and useCooldown(state, key, cooldown, now) then
            primaryDamage, secondaryDamage = applyOutgoingPercent(primaryDamage, secondaryDamage, percent)
            changed = true
            return true
        end
        return false
    end

    if (totals.socket_steady_hand_percent or 0) > 0
        and now - (state.lastMoveAt or now) >= math.max(0, totals.socket_steady_hand_still_seconds or 0) then
        bonus("steady_hand", totals.socket_steady_hand_percent, totals.socket_steady_hand_cooldown)
    end

    if (totals.socket_quick_step_percent or 0) > 0
        and (state.movedTiles or 0) >= math.max(1, totals.socket_quick_step_tiles or 0)
        and bonus("quick_step", totals.socket_quick_step_percent, totals.socket_quick_step_cooldown) then
        state.movedTiles = 0
    end

    if (totals.socket_revenge_spark_percent or 0) > 0
        and now - (state.lastReceivedAt or 0) <= math.max(1, totals.socket_revenge_spark_window or 0) then
        bonus("revenge_spark", totals.socket_revenge_spark_percent, totals.socket_revenge_spark_cooldown)
    end

    if (totals.socket_desperate_focus_percent or 0) > 0
        and playerHealthPercent(player) <= math.max(1, totals.socket_desperate_focus_threshold or 0) then
        bonus("desperate_focus", totals.socket_desperate_focus_percent, totals.socket_desperate_focus_cooldown)
    end

    if (totals.socket_full_mind_spell_percent or 0) > 0 and isSpellOrigin(origin)
        and playerManaPercent(player) >= math.max(1, totals.socket_full_mind_threshold or 0) then
        bonus("full_mind", totals.socket_full_mind_spell_percent, totals.socket_full_mind_cooldown)
    end

    if (totals.socket_battle_rhythm_percent or 0) > 0
        and incrementCounter(state, "battle_rhythm", totals.socket_battle_rhythm_hit_count) then
        primaryDamage, secondaryDamage = applyOutgoingPercent(primaryDamage, secondaryDamage, totals.socket_battle_rhythm_percent)
        changed = true
    end

    if (totals.socket_blood_tithe_damage_percent or 0) > 0
        and cooldownReady(state, "blood_tithe", now) then
        local cost = scaleByPercent(player:getHealth(), totals.socket_blood_tithe_hp_cost_percent or 0)
        if cost > 0 and cost < player:getHealth() then
            player:addHealth("physical", -cost)
            setCooldown(state, "blood_tithe", totals.socket_blood_tithe_cooldown, now)
            primaryDamage, secondaryDamage = applyOutgoingPercent(primaryDamage, secondaryDamage, totals.socket_blood_tithe_damage_percent)
            changed = true
        end
    end

    if (totals.socket_mana_price_damage_percent or 0) > 0
        and cooldownReady(state, "mana_price", now) then
        local cost = scaleByPercent(player:getMana(), totals.socket_mana_price_mana_cost_percent or 0)
        if cost > 0 and cost < player:getMana() then
            player:addMana(-cost)
            setCooldown(state, "mana_price", totals.socket_mana_price_cooldown, now)
            primaryDamage, secondaryDamage = applyOutgoingPercent(primaryDamage, secondaryDamage, totals.socket_mana_price_damage_percent)
            changed = true
        end
    end

    if (totals.socket_warmup_percent or 0) > 0
        and now - (state.lastAttackAt or 0) >= math.max(1, totals.socket_warmup_idle_seconds or 0) then
        bonus("warmup", totals.socket_warmup_percent, totals.socket_warmup_cooldown)
    end

    if (totals.socket_lucky_scratch_chance or 0) > 0 and rollChance(totals.socket_lucky_scratch_chance)
        and bonus("lucky_scratch", totals.socket_lucky_scratch_damage_percent or 0, totals.socket_lucky_scratch_cooldown) then
    end

    if state.flags.sharpHands and (totals.socket_sharp_hands_percent or 0) > 0 then
        state.flags.sharpHands = nil
        primaryDamage, secondaryDamage = applyOutgoingPercent(primaryDamage, secondaryDamage, totals.socket_sharp_hands_percent)
        changed = true
    end

    if state.flags.hardLanding and (totals.socket_hard_landing_percent or 0) > 0
        and bonus("hard_landing", totals.socket_hard_landing_percent, totals.socket_hard_landing_cooldown) then
        state.flags.hardLanding = nil
    end

    if (totals.socket_low_flame_chance or 0) > 0 and playerHealthPercent(player) <= math.max(1, totals.socket_low_flame_threshold or 0)
        and rollChance(totals.socket_low_flame_chance) then
        bonus("low_flame", totals.socket_low_flame_damage_percent or 0, totals.socket_low_flame_cooldown)
    end

    if (totals.socket_high_flame_chance or 0) > 0 and playerHealthPercent(player) >= math.max(1, totals.socket_high_flame_threshold or 0)
        and rollChance(totals.socket_high_flame_chance) then
        bonus("high_flame", totals.socket_high_flame_damage_percent or 0, totals.socket_high_flame_cooldown)
    end

    if (totals.socket_short_fuse_percent or 0) > 0
        and now - (state.lastReceivedAt or 0) <= math.max(1, totals.socket_short_fuse_window or 0) then
        bonus("short_fuse", totals.socket_short_fuse_percent, totals.socket_short_fuse_cooldown)
    end

    if (totals.socket_long_fuse_percent or 0) > 0
        and (state.lastReceivedAt or 0) > 0
        and now - state.lastReceivedAt >= math.max(1, totals.socket_long_fuse_wait_seconds or 0) then
        bonus("long_fuse", totals.socket_long_fuse_percent, totals.socket_long_fuse_cooldown)
    end

    if (totals.socket_fighters_mark_percent or 0) > 0 and target then
        local targetId = target:getId()
        if state.fightersMarkTargetId == targetId then
            state.fightersMarkHits = (state.fightersMarkHits or 0) + 1
        else
            state.fightersMarkTargetId = targetId
            state.fightersMarkHits = 1
        end
        if state.fightersMarkHits >= math.max(1, totals.socket_fighters_mark_hits or 0)
            and bonus("fighters_mark", totals.socket_fighters_mark_percent, totals.socket_fighters_mark_cooldown) then
            state.fightersMarkHits = 0
        end
    end

    if (totals.socket_empty_mind_mana_percent or 0) > 0 and player:getMaxMana() > 0
        and playerManaPercent(player) <= math.max(1, totals.socket_empty_mind_threshold or 0)
        and useCooldown(state, "empty_mind", totals.socket_empty_mind_cooldown, now) then
        player:addMana(scaleByPercent(player:getMaxMana(), totals.socket_empty_mind_mana_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    if (totals.socket_weapon_chain_heal_percent or 0) > 0 and isBasicAttackOrigin(origin)
        and incrementCounter(state, "weapon_chain", totals.socket_weapon_chain_count) then
        player:addHealth("healing", scaleByPercent(player:getMaxHealth(), totals.socket_weapon_chain_heal_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end

    state.lastAttackAt = now
    state.lastDamageDealtAt = now
    if target and isSpellOrigin(origin) then
        state.lastSpellHitTargetId = target:getId()
        state.lastSpellHitAt = now
    end
    state.lastHitTargetId = target and target:getId() or nil
    state.lastHitTargetHealth = target and target:getHealth() or 0
    state.lastHitDamage = getDamageAmount(primaryDamage, secondaryDamage)
    return primaryDamage, secondaryDamage, changed
end

local function applyLightweightIncoming(player, attacker, primaryDamage, secondaryDamage, origin, totals, now)
    local state = getLightweightState(player)
    updateLightweightMovement(player, state, now)
    local totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if totalDamage <= 0 then
        return primaryDamage, secondaryDamage
    end

    local function reduce(key, percent, cooldown)
        if percent > 0 and useCooldown(state, key, cooldown, now) then
            primaryDamage, secondaryDamage = applyIncomingReduction(primaryDamage, secondaryDamage, percent)
            totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
            return true
        end
        return false
    end

    if (totals.socket_guarded_breath_reduce_percent or 0) > 0
        and now - (state.lastAttackAt or 0) >= math.max(1, totals.socket_guarded_breath_idle_seconds or 0) then
        reduce("guarded_breath", totals.socket_guarded_breath_reduce_percent, totals.socket_guarded_breath_cooldown)
    end
    if (totals.socket_brace_reduce_percent or 0) > 0 and player:getMaxHealth() > 0
        and totalDamage >= math.floor(player:getMaxHealth() * ((totals.socket_brace_threshold or 0) / 100)) then
        reduce("brace", totals.socket_brace_reduce_percent, totals.socket_brace_cooldown)
    end
    if (totals.socket_last_stand_reduce_percent or 0) > 0 and playerHealthPercent(player) <= math.max(1, totals.socket_last_stand_threshold or 0) then
        reduce("last_stand", totals.socket_last_stand_reduce_percent, totals.socket_last_stand_cooldown)
    end
    if (totals.socket_thick_skin_reduce_percent or 0) > 0
        and now - (state.lastReceivedAt or 0) >= math.max(1, totals.socket_thick_skin_idle_seconds or 0) then
        reduce("thick_skin", totals.socket_thick_skin_reduce_percent, totals.socket_thick_skin_cooldown)
    end
    if (totals.socket_safety_rhythm_reduce_percent or 0) > 0
        and incrementCounter(state, "safety_rhythm", totals.socket_safety_rhythm_hit_count) then
        primaryDamage, secondaryDamage = applyIncomingReduction(primaryDamage, secondaryDamage, totals.socket_safety_rhythm_reduce_percent)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end
    if (totals.socket_cooldown_reduce_percent or 0) > 0
        and now - (state.lastReceivedAt or 0) >= math.max(1, totals.socket_cooldown_idle_seconds or 0) then
        reduce("cooldown", totals.socket_cooldown_reduce_percent, totals.socket_cooldown_cooldown)
    end
    if (totals.socket_lucky_guard_chance or 0) > 0 and rollChance(totals.socket_lucky_guard_chance) then
        reduce("lucky_guard", totals.socket_lucky_guard_reduce_percent or 0, totals.socket_lucky_guard_cooldown)
    end
    if state.flags.safeHands and (totals.socket_safe_hands_reduce_percent or 0) > 0 then
        state.flags.safeHands = nil
        primaryDamage, secondaryDamage = applyIncomingReduction(primaryDamage, secondaryDamage, totals.socket_safe_hands_reduce_percent)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end
    if (totals.socket_soft_landing_reduce_percent or 0) > 0
        and now - (state.lastReceivedAt or 0) <= math.max(1, totals.socket_soft_landing_window or 0)
        and reduce("soft_landing", totals.socket_soft_landing_reduce_percent, totals.socket_soft_landing_cooldown) then
        state.flags.hardLanding = true
    end
    if (totals.socket_hard_landing_percent or 0) > 0
        and cooldownReady(state, "hard_landing", now)
        and now - (state.lastReceivedAt or 0) <= math.max(1, totals.socket_hard_landing_window or 0) then
        state.flags.hardLanding = true
    end
    if (totals.socket_low_tide_reduce_percent or 0) > 0 and playerManaPercent(player) <= math.max(1, totals.socket_low_tide_threshold or 0) then
        reduce("low_tide", totals.socket_low_tide_reduce_percent, totals.socket_low_tide_cooldown)
    end
    if (totals.socket_high_tide_heal_percent or 0) > 0 and playerManaPercent(player) >= math.max(1, totals.socket_high_tide_threshold or 0)
        and useCooldown(state, "high_tide", totals.socket_high_tide_cooldown, now) then
        player:addHealth("healing", scaleByPercent(player:getMaxHealth(), totals.socket_high_tide_heal_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end
    if (totals.socket_narrow_escape_mana_percent or 0) > 0 and player:getMaxHealth() > 0
        and ((math.max(0, player:getHealth() - totalDamage) / player:getMaxHealth()) * 100) <= math.max(1, totals.socket_narrow_escape_threshold or 0)
        and useCooldown(state, "narrow_escape", totals.socket_narrow_escape_cooldown, now) then
        player:addMana(scaleByPercent(player:getMaxMana(), totals.socket_narrow_escape_mana_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end
    if player:getHealth() - totalDamage <= 0 then
        state.freshStartReady = true
    end
    if (totals.socket_quiet_armor_reduce_percent or 0) > 0
        and now - (state.lastSpellAt or 0) >= math.max(1, totals.socket_quiet_armor_idle_seconds or 0) then
        reduce("quiet_armor", totals.socket_quiet_armor_reduce_percent, totals.socket_quiet_armor_cooldown)
    end
    if (totals.socket_loud_armor_reduce_percent or 0) > 0
        and now - (state.lastSpellAt or 0) <= math.max(1, totals.socket_loud_armor_window or 0) then
        reduce("loud_armor", totals.socket_loud_armor_reduce_percent, totals.socket_loud_armor_cooldown)
    end
    if (totals.socket_lucky_boots_chance or 0) > 0 and (state.movedTiles or 0) >= math.max(1, totals.socket_lucky_boots_tiles or 0)
        and rollChance(totals.socket_lucky_boots_chance)
        and reduce("lucky_boots", totals.socket_lucky_boots_reduce_percent or 0, totals.socket_lucky_boots_cooldown) then
        state.movedTiles = 0
    end

    if totalDamage > 0 then
        state.lastDamageReceivedAt = now
        if isTrackedKillGemHit(player, attacker, origin) then
            state.lastReceivedAt = now
        end
    end
    return primaryDamage, secondaryDamage
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

local function getMonsterName(monster)
    if not monster or not monster:isMonster() then
        return nil
    end
    return tostring(monster:getName() or ""):lower()
end

local function getNearbyMonsters(centerPosition, range, excludedCreature)
    local monsters = {}
    if not centerPosition then
        return monsters
    end
    range = math.max(0, tonumber(range) or 0)
    for _, creature in ipairs(Game.getSpectators(centerPosition, false, false, range, range, range, range) or {}) do
        if creature ~= excludedCreature and isNormalMonster(creature) then
            monsters[#monsters + 1] = creature
        end
    end
    return monsters
end

local function sameParty(firstPlayer, secondPlayer)
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

local function getPartyPlayersInRange(owner, range, includeOwner)
    local players = {}
    if not owner or not owner:isPlayer() then
        return players
    end
    local position = owner:getPosition()
    if not position then
        return players
    end
    range = math.max(0, tonumber(range) or 0)
    local party = owner:getParty()
    local candidates = party and party:getMembers() or {}
    if party and party:getLeader() then
        candidates[#candidates + 1] = party:getLeader()
    elseif includeOwner then
        candidates[1] = owner
    end
    for _, member in ipairs(candidates) do
        local memberPosition = member and member:isPlayer() and member:getPosition() or nil
        if memberPosition and (includeOwner or member ~= owner)
            and position:getDistance(memberPosition) <= range then
            players[#players + 1] = member
        end
    end
    return players
end

local function getRecentBeaconHealer(healedPlayer)
    if not healedPlayer or not healedPlayer:isPlayer() then
        return nil
    end

    local now = os.time()
    for healerId, state in pairs(recentBeaconHealers) do
        if not state or now > (state.expiresAt or 0) then
            recentBeaconHealers[healerId] = nil
        else
            local healer = Player(healerId)
            if healer and healer:isPlayer() and healer ~= healedPlayer and sameParty(healer, healedPlayer) then
                return healer
            end
        end
    end
    return nil
end

local function getPartyBeaconCarrier(healedPlayer)
    if not healedPlayer or not healedPlayer:isPlayer() then
        return nil
    end

    local party = healedPlayer:getParty()
    if not party then
        return nil
    end

    local candidates = party:getMembers() or {}
    if party:getLeader() then
        candidates[#candidates + 1] = party:getLeader()
    end

    for _, member in ipairs(candidates) do
        if member and member:isPlayer() and member ~= healedPlayer and getBonus(member, "socket_beacon_reduction_percent") > 0 then
            return member
        end
    end
    return nil
end

local function getSpecialConfig(key)
    if type(GemsSocket) ~= "table" or type(GemsSocket.SPECIALS) ~= "table" then
        return {}
    end
    return GemsSocket.SPECIALS[key] or {}
end

local function addPositionOffset(position, dx, dy)
    if not position then
        return nil
    end
    return Position(position.x + dx, position.y + dy, position.z)
end

local function isSpawnableTile(position)
    local tile = position and Tile(position) or nil
    if not tile then
        return false
    end
    if tile:getHouse() or tile:getTopCreature() then
        return false
    end
    if TILESTATE_PROTECTIONZONE and tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        return false
    end
    if TILESTATE_BLOCKSOLID and tile:hasFlag(TILESTATE_BLOCKSOLID) then
        return false
    end
    return true
end

local function findNearbyFreePosition(centerPosition, minRange, maxRange)
    if not centerPosition then
        return nil
    end
    minRange = math.max(0, tonumber(minRange) or 0)
    maxRange = math.max(minRange, tonumber(maxRange) or minRange)
    for _ = 1, 24 do
        local dx = math.random(-maxRange, maxRange)
        local dy = math.random(-maxRange, maxRange)
        if math.max(math.abs(dx), math.abs(dy)) >= minRange then
            local position = addPositionOffset(centerPosition, dx, dy)
            if isSpawnableTile(position) then
                return position
            end
        end
    end
    for range = minRange, maxRange do
        for dx = -range, range do
            for dy = -range, range do
                if math.max(math.abs(dx), math.abs(dy)) == range then
                    local position = addPositionOffset(centerPosition, dx, dy)
                    if isSpawnableTile(position) then
                        return position
                    end
                end
            end
        end
    end
    return nil
end

local function increaseMonsterLevel(monster, levels, maxLevel, effect)
    if not monster or not monster:isMonster() or type(monster.getMonsterLevel) ~= "function" or type(monster.setMonsterLevel) ~= "function" then
        return false
    end
    levels = math.max(0, math.floor(tonumber(levels) or 0))
    if levels <= 0 then
        return false
    end
    local oldLevel = math.max(0, tonumber(monster:getMonsterLevel()) or 0)
    local newLevel = oldLevel + levels
    if maxLevel and maxLevel > 0 then
        newLevel = math.min(newLevel, maxLevel)
    end
    if newLevel <= oldLevel then
        return false
    end

    local special = getSpecialConfig("luckyHourglassGem")
    local healthPerLevel = math.max(0, tonumber(special.monsterLevelHealthBonusPerLevel) or 0.0074)
    local oldMaxHealth = math.max(1, tonumber(monster:getMaxHealth()) or 1)
    local oldHealth = math.max(1, tonumber(monster:getHealth()) or 1)
    local healthRatio = (1 + (healthPerLevel * newLevel)) / math.max(0.0001, 1 + (healthPerLevel * oldLevel))
    local newMaxHealth = math.max(oldMaxHealth, math.floor(oldMaxHealth * healthRatio + 0.5))
    local newHealth = math.max(1, math.min(newMaxHealth, math.floor((oldHealth / oldMaxHealth) * newMaxHealth + 0.5)))

    monster:setMonsterLevel(newLevel)
    monster:setMaxHealth(newMaxHealth)
    monster:addHealth("healing", newHealth - monster:getHealth())
    monster:getPosition():sendMagicEffect(effect or CONST_ME_MAGIC_RED)
    return true
end

local function pickWeightedEntry(entries)
    if type(entries) ~= "table" or #entries == 0 then
        return nil
    end
    local totalWeight = 0
    for _, entry in ipairs(entries) do
        totalWeight = totalWeight + math.max(0, tonumber(entry.weight) or 1)
    end
    if totalWeight <= 0 then
        return entries[math.random(#entries)]
    end
    local roll = math.random(totalWeight)
    local cursor = 0
    for _, entry in ipairs(entries) do
        cursor = cursor + math.max(0, tonumber(entry.weight) or 1)
        if roll <= cursor then
            return entry
        end
    end
    return entries[#entries]
end

local function addContainerReward(container, itemId, count)
    itemId = math.floor(tonumber(itemId) or 0)
    count = math.max(1, math.floor(tonumber(count) or 1))
    if itemId <= 0 or not container or type(container.addItem) ~= "function" then
        return false
    end
    local added = false
    local remaining = count
    while remaining > 0 do
        local stack = math.min(100, remaining)
        if container:addItem(itemId, stack) then
            added = true
        end
        remaining = remaining - stack
    end
    return added
end

local function addPlayerReward(player, itemId, count)
    itemId = math.floor(tonumber(itemId) or 0)
    count = math.max(1, math.floor(tonumber(count) or 1))
    if itemId <= 0 or not player or not player:isPlayer() then
        return false
    end
    local remaining = count
    while remaining > 0 do
        local stack = math.min(100, remaining)
        player:addItem(itemId, stack)
        remaining = remaining - stack
    end
    return true
end

local function applyDelayedLifelineHeal(playerId, healAmount)
    local player = Player(playerId)
    if not player or not player:isPlayer() then
        return
    end

    healAmount = math.max(1, math.floor(tonumber(healAmount) or 0))
    player:addHealth("healing", healAmount)
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
end

local function removeTemporaryChest(positionData, itemId, expiresAt)
    local position = Position(positionData.x, positionData.y, positionData.z)
    local tile = Tile(position)
    if not tile then
        return
    end
    for _, item in ipairs(tile:getItems() or {}) do
        if item:getId() == itemId and math.floor(tonumber(item:getCustomAttribute("socket_treasure_echo_expires")) or 0) == expiresAt then
            item:remove()
            position:sendMagicEffect(CONST_ME_POFF)
            return
        end
    end
end

local function removeTemporaryMonster(monsterId, effect)
    local monster = Monster(monsterId)
    if not monster then
        return
    end
    local position = monster:getPosition()
    ambushRewardByMonsterId[monsterId] = nil
    monster:remove()
    if position then
        position:sendMagicEffect(effect or CONST_ME_POFF)
    end
end

local function applyTemporaryShield(player, subId, amount, duration, effect)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    duration = math.max(1, tonumber(duration) or 1)
    if not player or not player:isPlayer() or amount <= 0 then
        return false
    end
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, subId, true)
    local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    condition:setParameter(CONDITION_PARAM_SUBID, subId)
    condition:setParameter(CONDITION_PARAM_TICKS, duration * 1000)
    condition:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTS, amount)
    condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
    player:addCondition(condition)
    player:addHealth("healing", amount)
    player:getPosition():sendMagicEffect(effect or CONST_ME_HOLYAREA)
    return true
end

local function applySpeedCondition(player, subId, speed, duration)
    speed = math.floor(tonumber(speed) or 0)
    duration = math.max(1, tonumber(duration) or 1)
    if not player or not player:isPlayer() or speed <= 0 then
        return false
    end
    player:removeCondition(CONDITION_HASTE, CONDITIONID_DEFAULT, subId, true)
    local condition = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
    condition:setParameter(CONDITION_PARAM_SUBID, subId)
    condition:setParameter(CONDITION_PARAM_TICKS, duration * 1000)
    condition:setParameter(CONDITION_PARAM_SPEED, speed)
    player:addCondition(condition)
    return true
end

local function applyMadnessCondition(player, effect, value, duration)
    if not player or not player:isPlayer() then
        return
    end
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness, true)
    if not effect or not effect.params then
        return
    end
    local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    condition:setParameter(CONDITION_PARAM_SUBID, CONDITION_SUBIDS.madness)
    condition:setParameter(CONDITION_PARAM_TICKS, math.max(1, duration) * 1000)
    condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
    for _, param in ipairs(effect.params) do
        if param then
            condition:setParameter(param, value)
        end
    end
    player:addCondition(condition)
end

local madnessRolls = {
    {
        key = "damage_up_element_down",
        message = "Madness Gem surges with damage and weakens elemental defenses.",
        state = function(player)
            return {
                outgoingDamagePercent = getBonus(player, "socket_madness_damage_percent"),
                incomingElementPenalty = getBonus(player, "socket_madness_element_percent"),
            }
        end,
    },
    {
        key = "element_up_damage_down",
        message = "Madness Gem hardens elemental defenses and weakens damage.",
        state = function(player)
            return {
                incomingElementReduction = getBonus(player, "socket_madness_element_percent"),
                outgoingDamagePenalty = getBonus(player, "socket_madness_damage_percent"),
            }
        end,
    },
    {
        key = "weapon_up_defense_down",
        message = "Madness Gem sharpens weapon attacks and weakens defense.",
        state = function(player)
            return {
                basicAttackPercent = getBonus(player, "socket_madness_weapon_percent"),
                incomingDamagePenalty = getBonus(player, "socket_madness_defense_percent"),
            }
        end,
    },
    {
        key = "defense_up_weapon_down",
        message = "Madness Gem hardens defense and weakens weapon attacks.",
        state = function(player)
            return {
                incomingDamageReduction = getBonus(player, "socket_madness_defense_percent"),
                basicAttackPenalty = getBonus(player, "socket_madness_weapon_percent"),
            }
        end,
    },
    {
        key = "magic_up_melee_down",
        message = "Madness Gem empowers magic and weakens melee skills.",
        condition = {
            positiveParams = { CONDITION_PARAM_STAT_MAGICPOINTS },
            negativeParams = { CONDITION_PARAM_SKILL_AXE, CONDITION_PARAM_SKILL_SWORD, CONDITION_PARAM_SKILL_CLUB },
        },
    },
    {
        key = "melee_up_magic_down",
        message = "Madness Gem empowers melee skills and weakens magic.",
        condition = {
            positiveParams = { CONDITION_PARAM_SKILL_AXE, CONDITION_PARAM_SKILL_SWORD, CONDITION_PARAM_SKILL_CLUB },
            negativeParams = { CONDITION_PARAM_STAT_MAGICPOINTS },
        },
    },
}

local function rollMadness(player)
    local interval = math.max(10, getBonus(player, "socket_madness_interval"))
    if interval <= 0 then
        return nil
    end
    local roll = madnessRolls[math.random(#madnessRolls)]
    local skillValue = math.max(1, getBonus(player, "socket_madness_skill_value"))
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness, true)
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness + 1, true)
    local state = {
        key = roll.key,
        expiresAt = os.time() + interval,
    }
    if roll.state then
        local values = roll.state(player)
        for key, value in pairs(values) do
            state[key] = value
        end
    end
    if roll.condition then
        applyMadnessCondition(player, { params = roll.condition.positiveParams }, skillValue, interval)
        if roll.condition.negativeParams then
            local negative = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
            negative:setParameter(CONDITION_PARAM_SUBID, CONDITION_SUBIDS.madness + 1)
            negative:setParameter(CONDITION_PARAM_TICKS, interval * 1000)
            negative:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
            for _, param in ipairs(roll.condition.negativeParams) do
                negative:setParameter(param, -skillValue)
            end
            player:addCondition(negative)
        end
    end
    player:sendTextMessage(MESSAGE_INFO_DESCR, roll.message)
    player:getPosition():sendMagicEffect(CONST_ME_PURPLEENERGY)
    madnessState[player:getId()] = state
    return interval
end

local function runMadnessPulse(playerId, token)
    local player = Player(playerId)
    if not player or madnessTokens[playerId] ~= token then
        return
    end
    if getBonus(player, "socket_madness_interval") <= 0 then
        madnessState[playerId] = nil
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness, true)
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness + 1, true)
        return
    end
    local interval = rollMadness(player) or 60
    addEvent(runMadnessPulse, math.max(10, interval) * 1000, playerId, token)
end

local function ensureMadnessPulse(player)
    if not player or not player:isPlayer() or getBonus(player, "socket_madness_interval") <= 0 then
        return
    end
    local playerId = player:getId()
    madnessSerial = madnessSerial + 1
    madnessTokens[playerId] = madnessSerial
    addEvent(runMadnessPulse, 1000, playerId, madnessTokens[playerId])
end

local luckyHourglassRolls = {
    {
        key = "gold",
        message = "Lucky Hourglass turns your monster gold brighter.",
        canRoll = function(player)
            return getBonus(player, "socket_lucky_hourglass_gold_multiplier") > 0
        end,
        state = function(player)
            return { goldMultiplier = getBonus(player, "socket_lucky_hourglass_gold_multiplier") }
        end,
    },
    {
        key = "cooldowns",
        message = "Lucky Hourglass makes your attack spells recover faster.",
        canRoll = function(player)
            return getBonus(player, "socket_lucky_hourglass_cooldown_reduction_percent") > 0
        end,
        state = function(player)
            return { cooldownReductionPercent = getBonus(player, "socket_lucky_hourglass_cooldown_reduction_percent") }
        end,
    },
    {
        key = "monster_levels",
        message = "Lucky Hourglass strengthens nearby prey for better risk.",
        canRoll = function(player)
            return getBonus(player, "socket_lucky_hourglass_monster_level_bonus") > 0
        end,
        state = function(player)
            return { monsterLevelBonus = getBonus(player, "socket_lucky_hourglass_monster_level_bonus") }
        end,
    },
    {
        key = "reduced_healing",
        message = "Lucky Hourglass drains part of your healing.",
        canRoll = function(player)
            return getBonus(player, "socket_lucky_hourglass_healing_penalty_percent") > 0
        end,
        state = function(player)
            return { healingPenaltyPercent = getBonus(player, "socket_lucky_hourglass_healing_penalty_percent") }
        end,
    },
}

local function rollLuckyHourglass(player)
    local interval = math.max(30, getBonus(player, "socket_lucky_hourglass_interval"))
    if interval <= 0 then
        return nil
    end
    local candidates = {}
    for _, roll in ipairs(luckyHourglassRolls) do
        if roll.canRoll(player) then
            candidates[#candidates + 1] = roll
        end
    end
    if #candidates == 0 then
        luckyHourglassState[player:getId()] = nil
        return interval
    end

    local duration = math.max(10, getBonus(player, "socket_lucky_hourglass_duration"))
    local roll = candidates[math.random(#candidates)]
    local state = roll.state(player)
    state.key = roll.key
    state.expiresAt = os.time() + duration
    luckyHourglassState[player:getId()] = state
    player:sendTextMessage(MESSAGE_INFO_DESCR, roll.message)
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    return interval
end

local function runLuckyHourglassPulse(playerId, token)
    local player = Player(playerId)
    if not player or luckyHourglassTokens[playerId] ~= token then
        return
    end
    if getBonus(player, "socket_lucky_hourglass_interval") <= 0 then
        luckyHourglassState[playerId] = nil
        luckyHourglassTokens[playerId] = nil
        return
    end
    local interval = rollLuckyHourglass(player) or 180
    addEvent(runLuckyHourglassPulse, math.max(30, interval) * 1000, playerId, token)
end

local function ensureLuckyHourglassPulse(player)
    if not player or not player:isPlayer() or getBonus(player, "socket_lucky_hourglass_interval") <= 0 then
        return
    end
    local playerId = player:getId()
    luckyHourglassSerial = luckyHourglassSerial + 1
    luckyHourglassTokens[playerId] = luckyHourglassSerial
    addEvent(runLuckyHourglassPulse, 1000, playerId, luckyHourglassTokens[playerId])
end

local function getActiveLuckyHourglassState(player)
    if not player or not player:isPlayer() then
        return nil
    end
    local state = luckyHourglassState[player:getId()]
    if not state or os.time() > (state.expiresAt or 0) then
        luckyHourglassState[player:getId()] = nil
        return nil
    end
    return state
end

function ExtraSocketGems.onLogin(player)
    if player and player:isPlayer() then
        local state = getLightweightState(player)
        local position = player:getPosition()
        state.freshStartReady = true
        state.lastPosition = position and { x = position.x, y = position.y, z = position.z } or state.lastPosition
    end
    ensureMadnessPulse(player)
    ensureLuckyHourglassPulse(player)
    return true
end

function ExtraSocketGems.onLogout(player)
    if not player or not player:isPlayer() then
        return true
    end
    local playerId = player:getId()
    executionerState[playerId] = nil
    echoStrikeLock[playerId] = nil
    ruptureState[playerId] = nil
    guardianPulseState[playerId] = nil
    secondSkinState[playerId] = nil
    panicWardState[playerId] = nil
    memoryState[playerId] = nil
    madnessState[playerId] = nil
    madnessTokens[playerId] = nil
    ambushState[playerId] = nil
    treasureEchoState[playerId] = nil
    luckyHourglassState[playerId] = nil
    luckyHourglassTokens[playerId] = nil
    sharedGraceState[playerId] = nil
    beaconState[playerId] = nil
    recentBeaconHealers[playerId] = nil
    bulwarkState[playerId] = nil
    titanState[playerId] = nil
    manaLeechState[playerId] = nil
    evasionState[playerId] = nil
    lifelineState[playerId] = nil
    weakPointState[playerId] = nil
    lightweightState[playerId] = nil
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.guardian, true)
    player:removeCondition(CONDITION_HASTE, CONDITIONID_DEFAULT, CONDITION_SUBIDS.panic, true)
    player:removeCondition(CONDITION_HASTE, CONDITIONID_DEFAULT, CONDITION_SUBIDS.hunterCompass, true)
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness, true)
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness + 1, true)
    return true
end

function ExtraSocketGems.hasCombatRuntime(playerId, targetId)
    local now = os.time()
    local panic = panicWardState[playerId]
    local madness = madnessState[playerId]
    local beacon = beaconState[playerId]
    local bulwark = bulwarkState[playerId]
    local evasion = evasionState[playerId]
    return panic and now <= (panic.activeUntil or 0)
        or madness and now <= (madness.expiresAt or 0)
        or beacon and now <= (beacon.expiresAt or 0)
        or bulwark and now <= (bulwark.activeUntil or 0)
        or evasion and now <= (evasion.activeUntil or 0)
        or (targetId and sunderState[targetId] ~= nil or false)
end

function ExtraSocketGems.getMemoryCompactProgress(player, level, baseTooltip)
    local requiredKills = 30
    local damagePercent = nil
    baseTooltip = tostring(baseTooltip or "")

    local parsedRequired, parsedDamage = baseTooltip:match("After killing the same monster type%s*(%d+)%s*times in a row, deal%s*%+([%d%.%,]+)%% damage")
    if parsedRequired then
        requiredKills = math.max(1, tonumber(parsedRequired) or requiredKills)
    end
    if parsedDamage then
        damagePercent = parsedDamage
    end

    if player and player:isPlayer() then
        requiredKills = math.max(1, getBonus(player, "socket_memory_required_kills"))
        local liveDamage = getBonus(player, "socket_memory_damage_percent")
        if liveDamage > 0 then
            damagePercent = tostring(liveDamage)
        end
    end

    damagePercent = damagePercent or tostring(math.max(1, tonumber(level) or 1))

    local state = player and player:isPlayer() and memoryState[player:getId()] or nil
    if not state or not state.currentName then
        return string.format("Memory: No monster 0/%d  Damage +%s%%", requiredKills, damagePercent)
    end

    local kills = math.min(requiredKills, math.max(0, tonumber(state.currentKills) or 0))
    if state.activeName then
        return string.format("Remembered: %s  Damage +%s%%", state.activeName, damagePercent)
    end

    return string.format("Learning: %s %d/%d  Damage +%s%%", state.currentName, kills, requiredKills, damagePercent)
end

function ExtraSocketGems.refreshPlayerBonuses(player)
    if not player or not player:isPlayer() then
        return
    end
    if getBonus(player, "socket_madness_interval") > 0 and not madnessTokens[player:getId()] then
        ensureMadnessPulse(player)
    elseif getBonus(player, "socket_madness_interval") <= 0 then
        local playerId = player:getId()
        madnessState[playerId] = nil
        madnessTokens[playerId] = nil
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness, true)
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBIDS.madness + 1, true)
    end
    if getBonus(player, "socket_lucky_hourglass_interval") > 0 and not luckyHourglassTokens[player:getId()] then
        ensureLuckyHourglassPulse(player)
    elseif getBonus(player, "socket_lucky_hourglass_interval") <= 0 then
        local playerId = player:getId()
        luckyHourglassState[playerId] = nil
        luckyHourglassTokens[playerId] = nil
    end
end

local function rewardAmbushKill(player, targetId)
    local reward = ambushRewardByMonsterId[targetId]
    if not reward then
        return false
    end
    ambushRewardByMonsterId[targetId] = nil
    if not player or not player:isPlayer() then
        return true
    end
    if (reward.goldMax or 0) > 0 then
        local minGold = math.max(0, tonumber(reward.goldMin) or 0)
        local maxGold = math.max(minGold, tonumber(reward.goldMax) or minGold)
        local count = math.random(minGold, maxGold)
        if count > 0 then
            addPlayerReward(player, reward.goldItemId or 2148, count)
        end
    end
    if (reward.gemPowerChance or 0) > 0 and rollChance(reward.gemPowerChance) then
        local count = math.max(1, math.floor(tonumber(reward.gemPowerCount) or 1))
        addPlayerReward(player, reward.gemPowerItemId or 30658, count)
    end
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    return true
end

local function trySpawnAmbush(player, target, now)
    local chance = getBonus(player, "socket_ambush_chance")
    if chance <= 0 or not rollChance(chance) then
        return
    end
    local playerId = player:getId()
    local cooldown = math.max(1, getBonus(player, "socket_ambush_cooldown"))
    local state = ambushState[playerId] or { cooldownUntil = 0 }
    ambushState[playerId] = state
    if now < (state.cooldownUntil or 0) then
        return
    end

    local special = getSpecialConfig("ambushGem")
    local monsters = type(special.monsters) == "table" and special.monsters or { "Demon Skeleton" }
    local count = math.max(1, getBonus(player, "socket_ambush_count"))
    local lifetime = math.max(10, getBonus(player, "socket_ambush_lifetime"))
    local levelBonus = math.max(0, getBonus(player, "socket_ambush_level_bonus"))
    local spawned = 0
    local center = target:getPosition()
    for _ = 1, count do
        local position = findNearbyFreePosition(center, 1, 3)
        if position then
            local monsterName = monsters[math.random(#monsters)]
            local monster = Game.createMonster(monsterName, position, true, true)
            if monster then
                spawned = spawned + 1
                increaseMonsterLevel(monster, levelBonus, nil, special.spawnEffect or CONST_ME_MORTAREA)
                ambushRewardByMonsterId[monster:getId()] = {
                    goldItemId = special.goldItemId or 2148,
                    goldMin = getBonus(player, "socket_ambush_reward_gold_min"),
                    goldMax = getBonus(player, "socket_ambush_reward_gold_max"),
                    gemPowerItemId = special.gemPowerItemId or 30658,
                    gemPowerChance = getBonus(player, "socket_ambush_reward_gempower_chance"),
                    gemPowerCount = getBonus(player, "socket_ambush_reward_gempower_count"),
                }
                addEvent(removeTemporaryMonster, lifetime * 1000, monster:getId(), special.expireEffect or CONST_ME_POFF)
                position:sendMagicEffect(special.spawnEffect or CONST_ME_MORTAREA)
            end
        end
    end

    if spawned > 0 then
        state.cooldownUntil = now + cooldown
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Ambush Gem draws a hostile pack nearby.")
    end
end

local function trySpawnTreasureEcho(player, target, now)
    local chance = getBonus(player, "socket_treasure_echo_chance")
    if chance <= 0 or not rollChance(chance) then
        return
    end
    local playerId = player:getId()
    local cooldown = math.max(1, getBonus(player, "socket_treasure_echo_cooldown"))
    local state = treasureEchoState[playerId] or { cooldownUntil = 0 }
    treasureEchoState[playerId] = state
    if now < (state.cooldownUntil or 0) then
        return
    end

    local special = getSpecialConfig("treasureEchoGem")
    local chestItemId = math.max(1, tonumber(special.chestItemId) or 1746)
    local position = findNearbyFreePosition(target:getPosition(), 1, 2)
    if not position then
        return
    end
    local chest = Game.createItem(chestItemId, 1, position)
    if not chest then
        return
    end

    local lifetime = math.max(5, getBonus(player, "socket_treasure_echo_lifetime"))
    local expiresAt = now + lifetime
    chest:setCustomAttribute("socket_treasure_echo_expires", expiresAt)

    local minGold = math.max(0, getBonus(player, "socket_treasure_echo_gold_min"))
    local maxGold = math.max(minGold, getBonus(player, "socket_treasure_echo_gold_max"))
    if maxGold > 0 then
        addContainerReward(chest, special.goldItemId or 2148, math.random(minGold, maxGold))
    end

    if rollChance(getBonus(player, "socket_treasure_echo_material_chance")) then
        local material = pickWeightedEntry(special.materialItems)
        if material then
            local count = math.max(1, getBonus(player, "socket_treasure_echo_material_count"))
            addContainerReward(chest, material.itemId, count)
        end
    end

    if rollChance(getBonus(player, "socket_treasure_echo_gempower_chance")) then
        local count = math.max(1, getBonus(player, "socket_treasure_echo_gempower_count"))
        addContainerReward(chest, special.gemPowerItemId or 30658, count)
    end

    state.cooldownUntil = now + cooldown
    position:sendMagicEffect(special.spawnEffect or CONST_ME_MAGIC_GREEN)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Treasure Echo Gem leaves a temporary chest behind.")
    addEvent(removeTemporaryChest, lifetime * 1000, { x = position.x, y = position.y, z = position.z }, chestItemId, expiresAt)
end

local function tryLuckyHourglassMonsterLevel(player, target)
    local state = getActiveLuckyHourglassState(player)
    if not state or (state.monsterLevelBonus or 0) <= 0 then
        return
    end
    local special = getSpecialConfig("luckyHourglassGem")
    local range = math.max(1, tonumber(special.monsterLevelRange) or 5)
    local candidates = {}
    for _, monster in ipairs(getNearbyMonsters(target:getPosition(), range, target)) do
        if monster:getHealth() > 0 then
            candidates[#candidates + 1] = monster
        end
    end
    if #candidates == 0 then
        return
    end
    local monster = candidates[math.random(#candidates)]
    if increaseMonsterLevel(monster, state.monsterLevelBonus, tonumber(special.monsterLevelMax) or nil, special.monsterLevelEffect or CONST_ME_MAGIC_RED) then
        monster:say("EMPOWERED", TALKTYPE_MONSTER_SAY)
    end
end

function ExtraSocketGems.onKill(player, target)
    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return true
    end

    local playerId = player:getId()
    local now = os.time()
    local bonusCache = type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil
    local totals = bonusCache and bonusCache.totals or {}
    local lightState = getLightweightState(player)
    local monsterName = getMonsterName(target)
    local elapsedSinceHit = now - (lightState.lastReceivedAt or 0)
    local elapsedSinceDamage = now - (lightState.lastDamageReceivedAt or 0)
    local currentMana = player:getMana()
    local currentHealth = player:getHealth()

    if (totals.socket_clean_kill_mana_percent or 0) > 0
        and elapsedSinceHit >= math.max(1, totals.socket_clean_kill_safe_seconds or 0)
        and useCooldown(lightState, "clean_kill", totals.socket_clean_kill_cooldown, now) then
        local manaAmount = scaleByPercent(player:getMaxMana(), totals.socket_clean_kill_mana_percent)
        player:addMana(manaAmount)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    if (totals.socket_dirty_kill_heal_percent or 0) > 0
        and elapsedSinceDamage <= math.max(1, totals.socket_dirty_kill_window or 0)
        and useCooldown(lightState, "dirty_kill", totals.socket_dirty_kill_cooldown, now) then
        local healAmount = scaleByPercent(player:getMaxHealth(), totals.socket_dirty_kill_heal_percent)
        player:addHealth("healing", healAmount)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end

    if (totals.socket_mercy_mana_percent or 0) > 0
        and lightState.lastHitTargetId == target:getId()
        and (tonumber(lightState.lastHitDamage) or 0) > (tonumber(lightState.lastHitTargetHealth) or 0)
        and useCooldown(lightState, "mercy", totals.socket_mercy_cooldown, now) then
        player:addMana(scaleByPercent(player:getMaxMana(), totals.socket_mercy_mana_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    if (totals.socket_minor_feast_heal_percent or 0) > 0
        and incrementCounter(lightState, "minor_feast", totals.socket_minor_feast_kill_count) then
        player:addHealth("healing", scaleByPercent(player:getMaxHealth(), totals.socket_minor_feast_heal_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end

    if (totals.socket_minor_focus_mana_percent or 0) > 0
        and incrementCounter(lightState, "minor_focus", totals.socket_minor_focus_kill_count) then
        player:addMana(scaleByPercent(player:getMaxMana(), totals.socket_minor_focus_mana_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    local spellHungerPercent = math.max(0, tonumber(totals.socket_spell_hunger_mana_percent) or 0)
    if spellHungerPercent > 0 and lightState.lastSpellHitTargetId == target:getId()
        and now - (lightState.lastSpellHitAt or 0) <= math.max(1, tonumber(totals.socket_spell_hunger_window) or 0)
        and useCooldown(lightState, "spell_hunger", totals.socket_spell_hunger_cooldown, now) then
        player:addMana(scaleByPercent(player:getMaxMana(), spellHungerPercent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    local compassSpeed = math.max(0, tonumber(totals.socket_hunter_compass_speed) or 0)
    if compassSpeed > 0 and monsterName then
        if lightState.hunterCompassName == monsterName then
            lightState.hunterCompassKills = math.max(0, tonumber(lightState.hunterCompassKills) or 0) + 1
        else
            lightState.hunterCompassName = monsterName
            lightState.hunterCompassKills = 1
        end
        if lightState.hunterCompassKills >= math.max(1, tonumber(totals.socket_hunter_compass_kills) or 0)
            and useCooldown(lightState, "hunter_compass", totals.socket_hunter_compass_cooldown, now) then
            lightState.hunterCompassKills = 0
            applySpeedCondition(player, CONDITION_SUBIDS.hunterCompass, compassSpeed, math.max(1, tonumber(totals.socket_hunter_compass_duration) or 0))
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        end
    end

    local killedAmbush = rewardAmbushKill(player, target:getId())
    local executionerDamage = getBonus(player, "socket_executioner_damage_percent")
    if executionerDamage > 0 then
        local state = executionerState[playerId] or { cooldownUntil = 0 }
        executionerState[playerId] = state
        if now >= (state.cooldownUntil or 0) then
            state.activeUntil = now + math.max(1, getBonus(player, "socket_executioner_window"))
            state.cooldownUntil = now + math.max(1, getBonus(player, "socket_executioner_cooldown"))
            player:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
        end
    end

    local requiredKills = math.max(1, getBonus(player, "socket_memory_required_kills"))
    local memoryBonus = getBonus(player, "socket_memory_damage_percent")
    if requiredKills > 0 and memoryBonus > 0 and monsterName then
        local state = memoryState[playerId] or {}
        memoryState[playerId] = state
        if state.currentName == monsterName then
            state.currentKills = math.min(requiredKills, math.max(0, tonumber(state.currentKills) or 0) + 1)
        else
            state.currentName = monsterName
            state.currentKills = 1
            state.activeName = nil
        end
        if state.currentKills >= requiredKills and state.activeName ~= monsterName then
            state.activeName = monsterName
            player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Memory Gem remembers %s.", target:getName()))
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        end
    end
    if not killedAmbush then
        trySpawnAmbush(player, target, now)
        trySpawnTreasureEcho(player, target, now)
        tryLuckyHourglassMonsterLevel(player, target)
    end
    return true
end

local function echoStrikeHit(playerId, targetId, combatType, damage, effect)
    local player = Player(playerId)
    local target = Monster(targetId)
    if not player or not target or target:getHealth() <= 0 then
        return
    end
    echoStrikeLock[playerId] = true
    doTargetCombatHealth(player, target, combatType or COMBAT_PHYSICALDAMAGE, -damage, -damage, effect or CONST_ME_HITAREA)
    echoStrikeLock[playerId] = nil
end

local function serratedEdgeTick(playerId, targetId, damage)
    local player = Player(playerId)
    local target = Monster(targetId)
    if not player or not target or target:getHealth() <= 0 then
        return
    end
    damage = math.max(1, math.floor(tonumber(damage) or 0))
    doTargetCombatHealth(player, target, COMBAT_PHYSICALDAMAGE, -damage, -damage, CONST_ME_DRAWBLOOD)
end

local function ruptureTick(playerId, targetId, token, remainingTicks, damage)
    local state = ruptureState[playerId]
    if not state or state.token ~= token then
        return
    end
    local player = Player(playerId)
    local target = Monster(targetId)
    if not player or not target or target:getHealth() <= 0 then
        return
    end
    damage = math.max(1, math.floor(tonumber(damage) or 0))
    doTargetCombatHealth(player, target, COMBAT_PHYSICALDAMAGE, -damage, -damage, CONST_ME_DRAWBLOOD)
    remainingTicks = math.max(0, tonumber(remainingTicks) or 0) - 1
    if remainingTicks > 0 then
        addEvent(ruptureTick, math.max(1, state.interval or 2) * 1000, playerId, targetId, token, remainingTicks, damage)
    end
end

function ExtraSocketGems.onOffensiveHit(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}
    local playerId = player:getId()
    local totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if totalDamage <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    local now = os.time()
    local targetId = target:getId()
    local lightState = getLightweightState(player)
    updateEvasionMovement(player, totals, now)
    primaryDamage, secondaryDamage = applyLightweightOutgoing(player, target, primaryDamage, secondaryDamage, origin, totals, now, totalDamage)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)

    local stabilityDamage = math.max(0, tonumber(totals.socket_stability_damage_percent) or 0)
    if stabilityDamage > 0 then
        primaryDamage = addScaledDamage(primaryDamage, stabilityDamage)
        secondaryDamage = addScaledDamage(secondaryDamage, stabilityDamage)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local firstBloodPercent = math.max(0, tonumber(totals.socket_first_blood_damage_percent) or 0)
    if firstBloodPercent > 0 and target:getMaxHealth() > 0 and target:getHealth() >= target:getMaxHealth()
        and useCooldown(lightState, "first_blood", totals.socket_first_blood_cooldown, now) then
        primaryDamage = addScaledDamage(primaryDamage, firstBloodPercent)
        secondaryDamage = addScaledDamage(secondaryDamage, firstBloodPercent)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
        target:getPosition():sendMagicEffect(CONST_ME_HITAREA)
    end

    local weakPoint = weakPointState[playerId]
    if weakPoint and weakPoint.targetId == targetId and now <= (weakPoint.expiresAt or 0) and (weakPoint.percent or 0) > 0 then
        primaryDamage = addScaledDamage(primaryDamage, weakPoint.percent)
        secondaryDamage = addScaledDamage(secondaryDamage, weakPoint.percent)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
        weakPointState[playerId] = nil
        target:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
    elseif weakPoint and now > (weakPoint.expiresAt or 0) then
        weakPointState[playerId] = nil
    end

    local lastEmberPercent = math.max(0, tonumber(totals.socket_last_ember_damage_percent) or 0)
    if lastEmberPercent > 0 and playerHealthPercent(player) <= math.max(1, tonumber(totals.socket_last_ember_threshold) or 0)
        and (isElementalType(primaryType) or isElementalType(secondaryType))
        and useCooldown(lightState, "last_ember", totals.socket_last_ember_cooldown, now) then
        primaryDamage = addScaledDamage(primaryDamage, lastEmberPercent)
        secondaryDamage = addScaledDamage(secondaryDamage, lastEmberPercent)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
        player:getPosition():sendMagicEffect(CONST_ME_FIREATTACK or CONST_ME_HITAREA)
    end

    local bossFocusPercent = math.max(0, tonumber(totals.socket_boss_focus_damage_percent) or 0)
    if bossFocusPercent > 0 and target:getMaxHealth() >= math.max(1, tonumber(totals.socket_boss_focus_min_health) or 0) then
        primaryDamage = addScaledDamage(primaryDamage, bossFocusPercent)
        secondaryDamage = addScaledDamage(secondaryDamage, bossFocusPercent)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local glassheartDamage = math.max(0, tonumber(totals.socket_glassheart_damage_dealt_percent) or 0)
    if glassheartDamage > 0 then
        primaryDamage = addScaledDamage(primaryDamage, glassheartDamage)
        secondaryDamage = addScaledDamage(secondaryDamage, glassheartDamage)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local bloodPactDamage = math.max(0, tonumber(totals.socket_blood_pact_spell_damage_percent) or 0)
    if bloodPactDamage > 0 and isSpellOrigin(origin) then
        primaryDamage = addScaledDamage(primaryDamage, bloodPactDamage)
        secondaryDamage = addScaledDamage(secondaryDamage, bloodPactDamage)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local sunder = sunderState[targetId]
    if sunder and now <= (sunder.expiresAt or 0) and (sunder.stacks or 0) > 0 and (sunder.reductionPerStack or 0) > 0 then
        local bonusPercent = math.max(0, sunder.stacks * sunder.reductionPerStack)
        primaryDamage = addScaledDamage(primaryDamage, bonusPercent)
        secondaryDamage = addScaledDamage(secondaryDamage, bonusPercent)
    elseif sunder then
        sunderState[targetId] = nil
    end

    local guardBreak = guardBreakState[targetId]
    if guardBreak and now <= (guardBreak.expiresAt or 0) and (guardBreak.percent or 0) > 0 then
        primaryDamage = addScaledDamage(primaryDamage, guardBreak.percent)
        secondaryDamage = addScaledDamage(secondaryDamage, guardBreak.percent)
    elseif guardBreak then
        guardBreakState[targetId] = nil
    end

    local executioner = executionerState[playerId]
    if executioner and os.time() <= (executioner.activeUntil or 0) then
        local threshold = math.max(1, totals.socket_executioner_threshold or 0)
        local healthPercent = target:getMaxHealth() > 0 and ((target:getHealth() / target:getMaxHealth()) * 100) or 100
        if healthPercent <= threshold then
            local percent = math.max(0, totals.socket_executioner_damage_percent or 0)
            primaryDamage = addScaledDamage(primaryDamage, percent)
            secondaryDamage = addScaledDamage(secondaryDamage, percent)
            executioner.activeUntil = 0
            target:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
        end
    end

    local memory = memoryState[playerId]
    if memory and memory.activeName and memory.activeName == getMonsterName(target) then
        local percent = math.max(0, totals.socket_memory_damage_percent or 0)
        primaryDamage = addScaledDamage(primaryDamage, percent)
        secondaryDamage = addScaledDamage(secondaryDamage, percent)
    end

    local madness = madnessState[playerId]
    if madness and os.time() <= (madness.expiresAt or 0) then
        if (madness.outgoingDamagePercent or 0) > 0 then
            primaryDamage = addScaledDamage(primaryDamage, madness.outgoingDamagePercent)
            secondaryDamage = addScaledDamage(secondaryDamage, madness.outgoingDamagePercent)
        end
        if (madness.outgoingDamagePenalty or 0) > 0 then
            primaryDamage = reduceOutgoingDamage(primaryDamage, madness.outgoingDamagePenalty)
            secondaryDamage = reduceOutgoingDamage(secondaryDamage, madness.outgoingDamagePenalty)
        end
        if isBasicAttackOrigin(origin) and (madness.basicAttackPercent or 0) > 0 then
            primaryDamage = addScaledDamage(primaryDamage, madness.basicAttackPercent)
            secondaryDamage = addScaledDamage(secondaryDamage, madness.basicAttackPercent)
        end
        if isBasicAttackOrigin(origin) and (madness.basicAttackPenalty or 0) > 0 then
            primaryDamage = reduceOutgoingDamage(primaryDamage, madness.basicAttackPenalty)
            secondaryDamage = reduceOutgoingDamage(secondaryDamage, madness.basicAttackPenalty)
        end
    end

    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    local echoChance = totals.socket_echo_strike_chance or 0
    if totalDamage > 0 and echoChance > 0 and not echoStrikeLock[playerId] and isBasicAttackOrigin(origin, primaryType, secondaryType) and rollChance(echoChance) then
        local percent = math.max(1, totals.socket_echo_strike_damage_percent or 0)
        local delay = math.max(100, totals.socket_echo_strike_delay_ms or 0)
        local echoDamage = math.max(1, math.floor(totalDamage * (percent / 100)))
        local combatType = primaryType
        if combatType == nil or (COMBAT_NONE and combatType == COMBAT_NONE) then
            combatType = secondaryType
        end
        if combatType == nil or (COMBAT_NONE and combatType == COMBAT_NONE) then
            combatType = COMBAT_PHYSICALDAMAGE
        end
        addEvent(echoStrikeHit, delay, playerId, target:getId(), combatType, echoDamage, CONST_ME_HITAREA)
    end

    local rupturePercent = totals.socket_rupture_damage_percent_per_stack or 0
    if rupturePercent > 0 then
        local state = ruptureState[playerId] or { token = 0 }
        ruptureState[playerId] = state
        if state.targetId == target:getId() then
            state.stacks = math.min(math.max(1, totals.socket_rupture_max_stacks or 0), math.max(0, tonumber(state.stacks) or 0) + 1)
        else
            state.targetId = target:getId()
            state.stacks = 1
        end
        state.token = math.max(0, tonumber(state.token) or 0) + 1
        state.interval = math.max(1, totals.socket_rupture_tick_interval or 0)
        local ticks = math.max(1, totals.socket_rupture_ticks or 0)
        local damage = math.max(1, math.floor(totalDamage * ((rupturePercent * state.stacks) / 100)))
        addEvent(ruptureTick, state.interval * 1000, playerId, target:getId(), state.token, ticks, damage)
    end

    local sunderChance = totals.socket_sunder_chance or 0
    if sunderChance > 0 and rollChance(sunderChance) then
        local maxStacks = math.max(1, totals.socket_sunder_max_stacks or 0)
        local duration = math.max(1, totals.socket_sunder_duration or 0)
        local state = sunderState[targetId] or { stacks = 0 }
        state.stacks = math.min(maxStacks, math.max(0, tonumber(state.stacks) or 0) + 1)
        state.reductionPerStack = math.max(state.reductionPerStack or 0, totals.socket_sunder_armor_reduction_percent or 0)
        state.expiresAt = now + duration
        sunderState[targetId] = state
        target:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end

    local guardBreakChance = math.max(0, tonumber(totals.socket_guard_break_chance) or 0)
    local guardBreakPercent = math.max(0, tonumber(totals.socket_guard_break_damage_percent) or 0)
    if guardBreakChance > 0 and guardBreakPercent > 0 and rollChance(guardBreakChance) then
        guardBreakState[targetId] = {
            percent = guardBreakPercent,
            expiresAt = now + math.max(1, tonumber(totals.socket_guard_break_duration) or 0),
        }
        target:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end

    local weakChance = math.max(0, tonumber(totals.socket_weak_point_chance) or 0)
    local weakPercent = math.max(0, tonumber(totals.socket_weak_point_damage_percent) or 0)
    if weakChance > 0 and weakPercent > 0 and rollChance(weakChance) then
        weakPointState[playerId] = {
            targetId = targetId,
            percent = weakPercent,
            expiresAt = now + math.max(1, tonumber(totals.socket_weak_point_window) or 0),
        }
    end

    local serratedChance = math.max(0, tonumber(totals.socket_serrated_edge_chance) or 0)
    local serratedPercent = math.max(0, tonumber(totals.socket_serrated_edge_damage_percent) or 0)
    if totalDamage > 0 and serratedChance > 0 and serratedPercent > 0 and isBasicAttackOrigin(origin, primaryType, secondaryType) and rollChance(serratedChance) then
        local bleedDamage = math.max(1, math.floor(totalDamage * (serratedPercent / 100)))
        addEvent(serratedEdgeTick, math.max(100, tonumber(totals.socket_serrated_edge_delay_ms) or 500), playerId, targetId, bleedDamage)
    end

    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    local vampiricChance = math.max(0, tonumber(totals.socket_vampiric_chance) or 0)
    local vampiricPercent = math.max(0, tonumber(totals.socket_vampiric_heal_percent) or 0)
    if vampiricChance > 0 and vampiricPercent > 0 and rollChance(vampiricChance) then
        local healAmount = math.max(1, math.floor(totalDamage * (vampiricPercent / 100)))
        player:addHealth("healing", healAmount)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end

    local manaChance = math.max(0, tonumber(totals.socket_mana_leech_chance) or 0)
    local manaPercent = math.max(0, tonumber(totals.socket_mana_leech_restore_percent) or 0)
    if manaChance > 0 and manaPercent > 0 and player:getMaxMana() > 0 then
        local state = manaLeechState[playerId] or { cooldownUntil = 0 }
        manaLeechState[playerId] = state
        if now >= (state.cooldownUntil or 0) and rollChance(manaChance) then
            local cooldown = math.max(0, tonumber(totals.socket_mana_leech_cooldown) or 0)
            local manaAmount = math.max(1, math.floor(player:getMaxMana() * (manaPercent / 100)))
            state.cooldownUntil = now + cooldown
            player:addMana(manaAmount)
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local function applySecondSkin(player, primaryDamage, primaryType, secondaryDamage, secondaryType, totals)
    local playerId = player:getId()
    local state = secondSkinState[playerId]
    if not state or not state.damageType or os.time() > (state.expiresAt or 0) then
        return primaryDamage, secondaryDamage, false
    end
    local reduction = math.max(0, totals.socket_second_skin_reduction_percent or 0)
    if reduction <= 0 then
        return primaryDamage, secondaryDamage, false
    end
    local used = false
    if primaryType == state.damageType and primaryDamage > 0 then
        primaryDamage = reduceDamage(primaryDamage, reduction)
        used = true
    end
    if secondaryType == state.damageType and secondaryDamage > 0 then
        secondaryDamage = reduceDamage(secondaryDamage, reduction)
        used = true
    end
    if used then
        state.damageType = nil
        state.expiresAt = 0
        player:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end
    return primaryDamage, secondaryDamage, used
end

function ExtraSocketGems.onIncomingHit(player, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin, bonusCache)
    if not player or not player:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}

    local playerId = player:getId()
    local now = os.time()
    local totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if totalDamage <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    primaryDamage, secondaryDamage = applyLightweightIncoming(player, attacker, primaryDamage, secondaryDamage, origin, totals, now)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    if totalDamage <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local lightState = getLightweightState(player)
    if (totals.socket_nullstep_reduction_percent or 0) > 0 then
        updateLightweightMovement(player, lightState, now)
        local requiredTiles = math.max(2, tonumber(totals.socket_nullstep_min_distance) or 2)
        if ((lightState.lastMovementDistance or 0) >= requiredTiles or (lightState.movedTiles or 0) >= requiredTiles)
            and useCooldown(lightState, "nullstep", totals.socket_nullstep_cooldown, now) then
            lightState.movedTiles = 0
            lightState.nullstepActiveUntil = now + math.max(1, tonumber(totals.socket_nullstep_window) or 3)
        end
    end

    local stabilityReduction = math.max(0, tonumber(totals.socket_stability_reduction_percent) or 0)
    if stabilityReduction > 0 then
        primaryDamage = reduceDamage(primaryDamage, stabilityReduction)
        secondaryDamage = reduceDamage(secondaryDamage, stabilityReduction)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    if (lightState.barrierSipActiveUntil or 0) >= now and (totals.socket_barrier_sip_reduction_percent or 0) > 0 then
        primaryDamage = reduceDamage(primaryDamage, totals.socket_barrier_sip_reduction_percent)
        secondaryDamage = reduceDamage(secondaryDamage, totals.socket_barrier_sip_reduction_percent)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    if (lightState.nullstepActiveUntil or 0) >= now and (totals.socket_nullstep_reduction_percent or 0) > 0 then
        primaryDamage = reduceDamage(primaryDamage, totals.socket_nullstep_reduction_percent)
        secondaryDamage = reduceDamage(secondaryDamage, totals.socket_nullstep_reduction_percent)
        lightState.nullstepActiveUntil = 0
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
    end

    local duelistReduction = math.max(0, tonumber(totals.socket_duelist_reduction_percent) or 0)
    if duelistReduction > 0 and now >= (lightState.duelistNextScanAt or 0) then
        local range = math.max(1, tonumber(totals.socket_duelist_range) or 0)
        local maxMonsters = math.max(1, tonumber(totals.socket_duelist_max_monsters) or 1)
        local scanInterval = math.max(1, tonumber(totals.socket_duelist_scan_interval) or 2)
        lightState.duelistNextScanAt = now + scanInterval
        lightState.duelistActiveUntil = (#getNearbyMonsters(player:getPosition(), range) <= maxMonsters) and (now + scanInterval) or 0
    end
    if duelistReduction > 0 and now <= (lightState.duelistActiveUntil or 0) then
        primaryDamage = reduceDamage(primaryDamage, duelistReduction)
        secondaryDamage = reduceDamage(secondaryDamage, duelistReduction)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local recoveryWindowPercent = math.max(0, tonumber(totals.socket_recovery_window_heal_percent) or 0)
    if recoveryWindowPercent > 0 and player:getMaxHealth() > 0
        and totalDamage >= math.floor(player:getMaxHealth() * ((tonumber(totals.socket_recovery_window_big_hit_percent) or 0) / 100))
        and useCooldown(lightState, "recovery_window", totals.socket_recovery_window_cooldown, now) then
        lightState.recoveryWindowPercent = recoveryWindowPercent
        lightState.recoveryWindowUntil = now + math.max(1, tonumber(totals.socket_recovery_window_duration) or 0)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end

    local armorEchoChance = math.max(0, tonumber(totals.socket_armor_echo_chance) or 0)
    local armorEchoPercent = math.max(0, tonumber(totals.socket_armor_echo_damage_percent) or 0)
    if attacker and attacker:isMonster() and totalDamage > 0 and armorEchoChance > 0 and armorEchoPercent > 0
        and cooldownReady(lightState, "armor_echo", now) and rollChance(armorEchoChance) then
        setCooldown(lightState, "armor_echo", totals.socket_armor_echo_cooldown, now)
        local echoDamage = math.max(1, math.floor(totalDamage * (armorEchoPercent / 100)))
        doTargetCombatHealth(player, attacker, COMBAT_PHYSICALDAMAGE, -echoDamage, -echoDamage, CONST_ME_HITAREA)
    end

    local evasion = updateEvasionMovement(player, totals, now)
    if evasion and now <= (evasion.activeUntil or 0) then
        local evasionChance = math.max(0, tonumber(totals.socket_evasion_dodge_percent) or 0)
        if evasionChance > 0 and rollChance(evasionChance) then
            player:say("EVADE!", TALKTYPE_MONSTER_SAY)
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return 0, primaryType, 0, secondaryType
        end
    end

    local stonefootChance = math.max(0, tonumber(totals.socket_stonefoot_slow_ignore_chance) or 0)
    if stonefootChance > 0 and CONDITION_PARALYZE and rollChance(stonefootChance) then
        player:removeCondition(CONDITION_PARALYZE)
    end

    local glassheartPenalty = math.max(0, tonumber(totals.socket_glassheart_damage_taken_percent) or 0)
    if glassheartPenalty > 0 then
        primaryDamage = increaseDamage(primaryDamage, glassheartPenalty)
        secondaryDamage = increaseDamage(secondaryDamage, glassheartPenalty)
        totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    end

    local titanThreshold = math.max(0, tonumber(totals.socket_titan_threshold_percent) or 0)
    local titanReduction = math.max(0, tonumber(totals.socket_titan_excess_reduction_percent) or 0)
    if titanThreshold > 0 and titanReduction > 0 and player:getMaxHealth() > 0 then
        local state = titanState[playerId] or { cooldownUntil = 0 }
        titanState[playerId] = state
        if now >= (state.cooldownUntil or 0) then
            local thresholdDamage = math.floor(player:getMaxHealth() * (titanThreshold / 100))
            if totalDamage > thresholdDamage then
                local excess = totalDamage - thresholdDamage
                local prevented = math.floor(excess * (titanReduction / 100))
                if prevented > 0 then
                    primaryDamage, secondaryDamage = reduceDamageByFlat(primaryDamage, secondaryDamage, prevented)
                    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
                    state.cooldownUntil = now + math.max(1, tonumber(totals.socket_titan_cooldown) or 0)
                    player:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
                end
            end
        end
    end

    local counterChance = math.max(0, tonumber(totals.socket_counterspell_chance) or 0)
    local counterReduction = math.max(0, tonumber(totals.socket_counterspell_reduction_percent) or 0)
    if counterChance > 0 and counterReduction > 0 and rollChance(counterChance) then
        local changed
        primaryDamage, secondaryDamage, changed = reduceMagicDamage(primaryDamage, primaryType, secondaryDamage, secondaryType, counterReduction)
        if changed then
            totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        end
    end

    local bulwarkThreshold = math.max(0, tonumber(totals.socket_bulwark_threshold) or 0)
    local bulwarkReduction = math.max(0, tonumber(totals.socket_bulwark_reduction_percent) or 0)
    if bulwarkThreshold > 0 and bulwarkReduction > 0 and player:getMaxHealth() > 0 then
        local state = bulwarkState[playerId] or { cooldownUntil = 0, activeUntil = 0 }
        bulwarkState[playerId] = state
        local healthAfter = math.max(0, player:getHealth() - totalDamage)
        local healthAfterPercent = (healthAfter / player:getMaxHealth()) * 100
        if now >= (state.cooldownUntil or 0) and healthAfterPercent <= bulwarkThreshold then
            local duration = math.max(1, tonumber(totals.socket_bulwark_duration) or 0)
            state.activeUntil = now + duration
            state.cooldownUntil = now + math.max(duration, tonumber(totals.socket_bulwark_cooldown) or 0)
            player:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
        end
        if now <= (state.activeUntil or 0) then
            primaryDamage = reduceDamage(primaryDamage, bulwarkReduction)
            secondaryDamage = reduceDamage(secondaryDamage, bulwarkReduction)
            totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
        end
    end

    local beacon = beaconState[playerId]
    if beacon and now <= (beacon.expiresAt or 0) and (beacon.reduction or 0) > 0 then
        primaryDamage = reduceDamage(primaryDamage, beacon.reduction)
        secondaryDamage = reduceDamage(secondaryDamage, beacon.reduction)
    elseif beacon then
        beaconState[playerId] = nil
    end

    primaryDamage, secondaryDamage = applySecondSkin(player, primaryDamage, primaryType, secondaryDamage, secondaryType, totals)
    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)

    local stonebloodMax = math.max(0, totals.socket_stoneblood_max_resistance or 0)
    if stonebloodMax > 0 and player:getMaxHealth() > 0 then
        local missingPercent = math.max(0, 100 - ((player:getHealth() / player:getMaxHealth()) * 100))
        local reduction = math.min(stonebloodMax, stonebloodMax * (missingPercent / 100))
        if reduction > 0 then
            primaryDamage = reduceDamage(primaryDamage, reduction)
            secondaryDamage = reduceDamage(secondaryDamage, reduction)
        end
    end

    local cursedPenalty = math.max(0, totals.socket_cursed_fortune_damage_taken_percent or 0)
    if cursedPenalty > 0 and attacker and attacker:isMonster() then
        primaryDamage = increaseDamage(primaryDamage, cursedPenalty)
        secondaryDamage = increaseDamage(secondaryDamage, cursedPenalty)
    end

    local madness = madnessState[playerId]
    if madness and now <= (madness.expiresAt or 0) then
        if (madness.incomingDamageReduction or 0) > 0 then
            primaryDamage = reduceDamage(primaryDamage, madness.incomingDamageReduction)
            secondaryDamage = reduceDamage(secondaryDamage, madness.incomingDamageReduction)
        end
        if (madness.incomingDamagePenalty or 0) > 0 then
            primaryDamage = increaseDamage(primaryDamage, madness.incomingDamagePenalty)
            secondaryDamage = increaseDamage(secondaryDamage, madness.incomingDamagePenalty)
        end
        if (madness.incomingElementReduction or 0) > 0 then
            if isElementalType(primaryType) then
                primaryDamage = reduceDamage(primaryDamage, madness.incomingElementReduction)
            end
            if isElementalType(secondaryType) then
                secondaryDamage = reduceDamage(secondaryDamage, madness.incomingElementReduction)
            end
        end
        if (madness.incomingElementPenalty or 0) > 0 then
            if isElementalType(primaryType) then
                primaryDamage = increaseDamage(primaryDamage, madness.incomingElementPenalty)
            end
            if isElementalType(secondaryType) then
                secondaryDamage = increaseDamage(secondaryDamage, madness.incomingElementPenalty)
            end
        end
    end

    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    local guardianCooldown = totals.socket_guardian_pulse_cooldown or 0
    if guardianCooldown > 0 and now >= ((guardianPulseState[playerId] and guardianPulseState[playerId].cooldownUntil) or 0) then
        local shieldPercent = math.max(0, totals.socket_guardian_pulse_shield_percent or 0)
        local range = math.max(1, totals.socket_guardian_pulse_range or 0)
        local duration = math.max(1, totals.socket_guardian_pulse_duration or 0)
        local shieldAmount = math.floor(player:getMaxHealth() * (shieldPercent / 100))
        local affected = false
        for _, member in ipairs(getPartyPlayersInRange(player, range, false)) do
            local granted = 0
            if type(_G.GemsSocket_advancedGrantRuntimeShield) == "function" then
                granted = _G.GemsSocket_advancedGrantRuntimeShield(member, shieldAmount, duration, CONST_ME_HOLYAREA)
            else
                granted = applyTemporaryShield(member, CONDITION_SUBIDS.guardian, shieldAmount, duration, CONST_ME_HOLYAREA) and shieldAmount or 0
            end
            if granted > 0 then
                affected = true
            end
        end
        if affected then
            guardianPulseState[playerId] = { cooldownUntil = now + math.max(1, guardianCooldown) }
            player:say("GUARDIAN PULSE!", TALKTYPE_MONSTER_SAY)
        end
    end

    local panicCooldown = totals.socket_panic_ward_cooldown or 0
    if panicCooldown > 0 and now >= ((panicWardState[playerId] and panicWardState[playerId].cooldownUntil) or 0) then
        local range = math.max(1, totals.socket_panic_ward_range or 0)
        local required = math.max(1, totals.socket_panic_ward_monsters or 0)
        if #getNearbyMonsters(player:getPosition(), range) >= required then
            local duration = math.max(1, totals.socket_panic_ward_duration or 0)
            local speed = math.max(0, totals.socket_panic_ward_speed or 0)
            local reduction = math.max(0, totals.socket_panic_ward_reduction_percent or 0)
            panicWardState[playerId] = {
                cooldownUntil = now + math.max(1, panicCooldown),
                activeUntil = now + duration,
                reduction = reduction,
            }
            applySpeedCondition(player, CONDITION_SUBIDS.panic, speed, duration)
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        end
    end

    local panicState = panicWardState[playerId]
    if panicState and now <= (panicState.activeUntil or 0) and (panicState.reduction or 0) > 0 then
        primaryDamage = reduceDamage(primaryDamage, panicState.reduction)
        secondaryDamage = reduceDamage(secondaryDamage, panicState.reduction)
    end

    local secondSkinCooldown = totals.socket_second_skin_cooldown or 0
    local secondSkinThreshold = totals.socket_second_skin_big_hit_percent or 0
    if secondSkinCooldown > 0 and secondSkinThreshold > 0 and player:getMaxHealth() > 0 then
        local state = secondSkinState[playerId]
        if now >= (state and state.cooldownUntil or 0) and totalDamage >= math.floor(player:getMaxHealth() * (secondSkinThreshold / 100)) then
            secondSkinState[playerId] = {
                damageType = getDominantDamageType(primaryDamage, primaryType, secondaryDamage, secondaryType),
                expiresAt = now + math.max(1, totals.socket_second_skin_duration or 0),
                cooldownUntil = now + math.max(1, secondSkinCooldown),
            }
            player:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
        end
    end

    totalDamage = getDamageAmount(primaryDamage, secondaryDamage)
    local party = player:getParty()
    if party and totalDamage > 0 and player:getMaxHealth() > 0 then
        local healthAfter = math.max(0, player:getHealth() - totalDamage)
        local afterPercent = (healthAfter / player:getMaxHealth()) * 100
        local candidates = party:getMembers() or {}
        local leader = party:getLeader()
        if leader then
            candidates[#candidates + 1] = leader
        end
        local seen = {}
        for _, member in ipairs(candidates) do
            if member and member:isPlayer() and member ~= player and not seen[member:getId()] then
                seen[member:getId()] = true
                local memberCache = type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(member) or nil
                local memberTotals = memberCache and memberCache.totals or {}
                local threshold = math.max(0, tonumber(memberTotals.socket_lifeline_threshold_percent) or 0)
                local healPercent = math.max(0, tonumber(memberTotals.socket_lifeline_heal_percent) or 0)
                if threshold <= 0 then
                    threshold = math.max(0, getBonus(member, "socket_lifeline_threshold_percent"))
                end
                if healPercent <= 0 then
                    healPercent = math.max(0, getBonus(member, "socket_lifeline_heal_percent"))
                end
                if threshold > 0 and healPercent > 0 and afterPercent <= threshold then
                    local range = math.max(1, tonumber(memberTotals.socket_lifeline_range) or getBonus(member, "socket_lifeline_range") or 0)
                    local victimPosition = player:getPosition()
                    local memberPosition = member:getPosition()
                    if victimPosition and memberPosition and victimPosition:getDistance(memberPosition) <= range then
                        local memberId = member:getId()
                        local state = lifelineState[memberId] or { cooldownUntil = 0 }
                        lifelineState[memberId] = state
                        if now >= (state.cooldownUntil or 0) then
                            local cooldown = math.max(1, tonumber(memberTotals.socket_lifeline_cooldown) or getBonus(member, "socket_lifeline_cooldown") or 0)
                            local healAmount = math.max(1, math.floor(player:getMaxHealth() * (healPercent / 100)))
                            state.cooldownUntil = now + cooldown
                            addEvent(applyDelayedLifelineHeal, 1, player:getId(), healAmount)
                            member:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
                            break
                        end
                    end
                end
            end
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function ExtraSocketGems.onHealing(target, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
    local healedPlayer = target and target:isPlayer() and target or nil
    if not healedPlayer then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local totalHealing = 0
    if primaryType == COMBAT_HEALING and primaryDamage ~= 0 then
        totalHealing = totalHealing + math.abs(primaryDamage)
    end
    if secondaryType == COMBAT_HEALING and secondaryDamage ~= 0 then
        totalHealing = totalHealing + math.abs(secondaryDamage)
    end
    if totalHealing <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local lucky = getActiveLuckyHourglassState(healedPlayer)
    if lucky and (lucky.healingPenaltyPercent or 0) > 0 then
        primaryDamage = reduceHealingAmount(primaryDamage, lucky.healingPenaltyPercent)
        secondaryDamage = reduceHealingAmount(secondaryDamage, lucky.healingPenaltyPercent)
        totalHealing = 0
        if primaryType == COMBAT_HEALING and primaryDamage ~= 0 then
            totalHealing = totalHealing + math.abs(primaryDamage)
        end
        if secondaryType == COMBAT_HEALING and secondaryDamage ~= 0 then
            totalHealing = totalHealing + math.abs(secondaryDamage)
        end
    end

    local healedCache = type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(healedPlayer) or nil
    local healedTotals = healedCache and healedCache.totals or {}
    local healedState = getLightweightState(healedPlayer)
    local now = os.time()

    local stubbornPercent = math.max(0, tonumber(healedTotals.socket_stubborn_heal_percent) or 0)
    if stubbornPercent > 0 and playerHealthPercent(healedPlayer) <= math.max(1, tonumber(healedTotals.socket_stubborn_threshold) or 0) then
        primaryDamage = addScaledDamage(primaryDamage, stubbornPercent)
        secondaryDamage = addScaledDamage(secondaryDamage, stubbornPercent)
    end

    if (healedState.recoveryWindowUntil or 0) >= now and (healedState.recoveryWindowPercent or 0) > 0 then
        primaryDamage = addScaledDamage(primaryDamage, healedState.recoveryWindowPercent)
        secondaryDamage = addScaledDamage(secondaryDamage, healedState.recoveryWindowPercent)
    end

    local isSelfHeal = (attacker == healedPlayer) or (attacker == nil)
    if isSelfHeal then
        local overhealManaPercent = math.max(0, tonumber(healedTotals.socket_overheal_mana_percent) or 0)
        if overhealManaPercent > 0 and healedPlayer:getMaxMana() > 0
            and cooldownReady(healedState, "overheal", now) then
            local missingHealth = math.max(0, healedPlayer:getMaxHealth() - healedPlayer:getHealth())
            local overheal = math.max(0, totalHealing - missingHealth)
            if overheal > 0 then
                setCooldown(healedState, "overheal", healedTotals.socket_overheal_cooldown, now)
                local manaAmount = math.max(1, math.floor(overheal * (overhealManaPercent / 100)))
                healedPlayer:addMana(manaAmount)
                healedPlayer:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
            end
        end

        local idleSeconds = math.max(1, tonumber(healedTotals.socket_calm_recovery_idle_seconds) or 0)
        local calmElapsed = now - math.max(healedState.lastDamageDealtAt or 0, healedState.lastDamageReceivedAt or 0)
        local attackerName = (attacker and attacker.getName and attacker:getName()) or "nil"
        local targetName = (target and target.getName and target:getName()) or "nil"
        if (healedTotals.socket_calm_recovery_percent or 0) > 0
            and calmElapsed >= idleSeconds
            and useCooldown(healedState, "calm_recovery", healedTotals.socket_calm_recovery_cooldown, now) then
            print(string.format(
                "[HealGemDebug][%s] [Calm Recovery] triggered attacker=%s target=%s elapsed=%ds needed=%ds percent=%s primary=%d secondary=%d",
                healedPlayer:getName(),
                attackerName,
                targetName,
                calmElapsed,
                idleSeconds,
                tostring(healedTotals.socket_calm_recovery_percent),
                tonumber(primaryDamage) or 0,
                tonumber(secondaryDamage) or 0
            ))
            primaryDamage = addScaledDamage(primaryDamage, healedTotals.socket_calm_recovery_percent)
            secondaryDamage = addScaledDamage(secondaryDamage, healedTotals.socket_calm_recovery_percent)
        elseif (healedTotals.socket_calm_recovery_percent or 0) > 0 then
            print(string.format(
                "[HealGemDebug][%s] [Calm Recovery] skipped self=%s attacker=%s target=%s elapsed=%ds needed=%ds cooldownReady=%s lastDealt=%s lastReceived=%s primary=%d secondary=%d",
                healedPlayer:getName(),
                tostring(isSelfHeal),
                attackerName,
                targetName,
                calmElapsed,
                idleSeconds,
                tostring(cooldownReady(healedState, "calm_recovery", now)),
                tostring(healedState.lastDamageDealtAt or 0),
                tostring(healedState.lastDamageReceivedAt or 0),
                tonumber(primaryDamage) or 0,
                tonumber(secondaryDamage) or 0
            ))
        end

        if (healedTotals.socket_panic_recovery_percent or 0) > 0
            and playerHealthPercent(healedPlayer) <= math.max(1, tonumber(healedTotals.socket_panic_recovery_threshold) or 0)
            and useCooldown(healedState, "panic_recovery", healedTotals.socket_panic_recovery_cooldown, now) then
            primaryDamage = addScaledDamage(primaryDamage, healedTotals.socket_panic_recovery_percent)
            secondaryDamage = addScaledDamage(secondaryDamage, healedTotals.socket_panic_recovery_percent)
        end
    end

    local healer = attacker and attacker:isPlayer() and attacker or getRecentBeaconHealer(healedPlayer) or getPartyBeaconCarrier(healedPlayer)
    if healer and healer ~= healedPlayer and sameParty(healer, healedPlayer) then
        local beaconReduction = getBonus(healer, "socket_beacon_reduction_percent")
        if beaconReduction > 0 then
            beaconState[healedPlayer:getId()] = {
                expiresAt = os.time() + math.max(1, getBonus(healer, "socket_beacon_duration")),
                reduction = beaconReduction,
            }
            healedPlayer:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
        end
    end

    if healer ~= healedPlayer then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local player = healedPlayer
    local sharedPercent = getBonus(player, "socket_shared_grace_percent")
    if sharedPercent > 0 then
        local playerId = player:getId()
        local now = os.time()
        local cooldown = math.max(0, getBonus(player, "socket_shared_grace_cooldown"))
        if now >= ((sharedGraceState[playerId] and sharedGraceState[playerId].cooldownUntil) or 0) then
            local range = math.max(1, getBonus(player, "socket_shared_grace_range"))
            local lowestMember = nil
            local lowestPercent = 101
            for _, member in ipairs(getPartyPlayersInRange(player, range, false)) do
                if member:getMaxHealth() > 0 and member:getHealth() < member:getMaxHealth() then
                    local healthPercent = (member:getHealth() / member:getMaxHealth()) * 100
                    if healthPercent < lowestPercent then
                        lowestPercent = healthPercent
                        lowestMember = member
                    end
                end
            end
            if lowestMember then
                local amount = math.max(1, math.floor(totalHealing * (sharedPercent / 100)))
                lowestMember:addHealth("healing", amount)
                lowestMember:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
                sharedGraceState[playerId] = { cooldownUntil = now + cooldown }
            end
        end
    end

    local chance = getBonus(player, "socket_blood_echo_chance")
    if chance <= 0 or not rollChance(chance) then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    if totalHealing <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    local percent = math.max(0, getBonus(player, "socket_blood_echo_damage_percent"))
    local damage = math.max(1, math.floor(totalHealing * (percent / 100)))
    local range = math.max(1, getBonus(player, "socket_blood_echo_range"))
    for _, monster in ipairs(getNearbyMonsters(player:getPosition(), range)) do
        doTargetCombatHealth(player, monster, COMBAT_DEATHDAMAGE, -damage, -damage, CONST_ME_MORTAREA)
    end
    player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function ExtraSocketGems.getLootRarityBonus(player)
    if not player or not player:isPlayer() then
        return 0
    end
    return getBonus(player, "socket_cursed_fortune_rarity_chance") - getBonus(player, "socket_cartel_rarity_penalty")
end

function ExtraSocketGems.getGoldLootMultiplierBonus(player)
    if not player or not player:isPlayer() then
        return 0
    end
    local total = math.max(0, getBonus(player, "socket_cartel_gold_multiplier"))
    local lucky = getActiveLuckyHourglassState(player)
    if lucky and (lucky.goldMultiplier or 0) > 0 then
        total = total + lucky.goldMultiplier
    end
    return total
end

_G.GemsSocket_getGoldLootMultiplierBonus = function(player)
    return ExtraSocketGems.getGoldLootMultiplierBonus(player)
end

function ExtraSocketGems.getSpellCooldownMs(player, currentCooldown)
    if not player or not player:isPlayer() then
        return nil
    end
    currentCooldown = math.max(0, tonumber(currentCooldown) or 0)
    local lucky = getActiveLuckyHourglassState(player)
    if not lucky or (lucky.cooldownReductionPercent or 0) <= 0 then
        return nil
    end
    return math.max(0, math.floor(currentCooldown * math.max(0, 1 - (lucky.cooldownReductionPercent / 100))))
end

function ExtraSocketGems.onSpellCast(player, spellName, spellGroup, aggressive, manaCost, bonusCache)
    if not player or not player:isPlayer() then
        return
    end

    local now = os.time()
    local state = getLightweightState(player)
    updateLightweightMovement(player, state, now)
    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}
    manaCost = math.max(0, tonumber(manaCost) or 0)

    if not aggressive and (totals.socket_beacon_reduction_percent or 0) > 0 then
        recentBeaconHealers[player:getId()] = { expiresAt = now + 2 }
    end

    if (totals.socket_mana_battery_restore_percent or 0) > 0 and player:getMaxMana() > 0 then
        local requiredPercent = math.max(1, tonumber(totals.socket_mana_battery_spend_percent) or 0)
        local requiredMana = math.max(1, math.floor(player:getMaxMana() * (requiredPercent / 100)))
        state.manaBatterySpent = math.min(requiredMana, math.max(0, tonumber(state.manaBatterySpent) or 0) + manaCost)
        if state.manaBatterySpent >= requiredMana
            and cooldownReady(state, "mana_battery", now)
            and rollChance(totals.socket_mana_battery_chance or 100) then
            state.manaBatterySpent = 0
            setCooldown(state, "mana_battery", totals.socket_mana_battery_cooldown, now)
            player:addMana(scaleByPercent(player:getMaxMana(), totals.socket_mana_battery_restore_percent))
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        end
    end

    if (totals.socket_rune_saver_chance or 0) > 0
        and aggressive
        and tostring(spellGroup or ""):lower() == "attack"
        and manaCost <= 0
        and cooldownReady(state, "rune_saver", now)
        and rollChance(totals.socket_rune_saver_chance) then
        setCooldown(state, "rune_saver", totals.socket_rune_saver_cooldown, now)
        player:addMana(scaleByPercent(player:getMaxMana(), totals.socket_rune_saver_mana_percent or 1))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    if (totals.socket_spell_pause_mana_reduce_percent or 0) > 0
        and now - (state.lastSpellAt or 0) >= math.max(1, totals.socket_spell_pause_idle_seconds or 0)
        and useCooldown(state, "spell_pause", totals.socket_spell_pause_cooldown, now) then
        player:addMana(scaleByPercent(manaCost, totals.socket_spell_pause_mana_reduce_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    if (totals.socket_spell_chain_mana_percent or 0) > 0
        and incrementCounter(state, "spell_chain", totals.socket_spell_chain_count) then
        player:addMana(scaleByPercent(player:getMaxMana(), totals.socket_spell_chain_mana_percent))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    state.lastSpellAt = now
    state.lastSpellManaCost = manaCost

    if not aggressive then
        return
    end

    spellGroup = tostring(spellGroup or ""):lower()
    if spellGroup ~= "attack" then
        return
    end

    local hpCostPercent = math.max(0, tonumber(totals.socket_blood_pact_hp_cost_percent) or 0)
    local damagePercent = math.max(0, tonumber(totals.socket_blood_pact_spell_damage_percent) or 0)
    if hpCostPercent <= 0 or damagePercent <= 0 then
        return
    end

    local healthCost = math.max(1, math.floor(player:getHealth() * (hpCostPercent / 100)))
    if healthCost <= 0 or healthCost >= player:getHealth() then
        return
    end

    player:addHealth("physical", -healthCost)
    player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
end

function ExtraSocketGems.tryCraftMaterialRefund(player, consumedMaterials, bonusCache)
    if not player or not player:isPlayer() or type(consumedMaterials) ~= "table" then
        return false
    end

    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}
    local chance = math.max(0, tonumber(totals.socket_artisan_luck_chance) or 0)
    if chance <= 0 then
        chance = math.max(0, getBonus(player, "socket_artisan_luck_chance"))
    end
    if chance <= 0 or not rollChance(chance) then
        return false
    end

    local totalCount = 0
    for _, material in ipairs(consumedMaterials) do
        totalCount = totalCount + math.max(0, math.floor(tonumber(material.count) or 0))
    end
    if totalCount <= 0 then
        return false
    end

    local pick = math.random(totalCount)
    local selected = nil
    for _, material in ipairs(consumedMaterials) do
        local count = math.max(0, math.floor(tonumber(material.count) or 0))
        if count > 0 then
            if pick <= count then
                selected = material
                break
            end
            pick = pick - count
        end
    end
    if not selected then
        return false
    end

    local special = getSpecialConfig("artisanLuckGem")
    local refundCount = math.max(1, math.floor(tonumber(special.refundCount) or 1))
    if not addPlayerReward(player, selected.id, refundCount) then
        return false
    end

    player:getPosition():sendMagicEffect(special.effect or CONST_ME_MAGIC_GREEN)
    local itemName = tostring(ItemType(selected.id):getName() or "material")
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format(special.message or "Artisan's Luck refunds %d %s.", refundCount, itemName))
    return true
end

function ExtraSocketGems.shouldSavePotion(player, bonusCache)
    if not player or not player:isPlayer() then
        return false
    end
    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}
    local chance = math.max(0, tonumber(totals.socket_potion_saver_chance) or 0)
    if chance <= 0 then
        return false
    end
    local state = getLightweightState(player)
    local now = os.time()
    if not cooldownReady(state, "potion_saver", now) or not rollChance(chance) then
        return false
    end
    setCooldown(state, "potion_saver", totals.socket_potion_saver_cooldown, now)
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Potion Saver Gem preserves your potion.")
    return true
end

function ExtraSocketGems.onUsePotion(player, target, potion, bonusCache)
    if not player or not player:isPlayer() or type(potion) ~= "table" then
        return nil
    end
    bonusCache = bonusCache or (type(_G.GemsSocketBonusCache) == "table" and _G.GemsSocketBonusCache.getPlayerCache(player) or nil)
    local totals = bonusCache and bonusCache.totals or {}
    local state = getLightweightState(player)
    local now = os.time()
    updateLightweightMovement(player, state, now)

    local result = {
        healthPercent = 0,
        manaPercent = 0,
        mirrorSipPercent = 0,
    }
    local hasHealth = potion.health ~= nil
    local hasMana = potion.mana ~= nil

    if (totals.socket_potion_echo_percent or 0) > 0
        and useCooldown(state, "potion_echo", totals.socket_potion_echo_cooldown, now) then
        result.healthPercent = result.healthPercent + (hasHealth and totals.socket_potion_echo_percent or 0)
        result.manaPercent = result.manaPercent + (hasMana and totals.socket_potion_echo_percent or 0)
    end

    if hasHealth and (totals.socket_dry_flask_percent or 0) > 0
        and playerHealthPercent(player) <= math.max(1, totals.socket_dry_flask_threshold or 0)
        and useCooldown(state, "dry_flask", totals.socket_dry_flask_cooldown, now) then
        result.healthPercent = result.healthPercent + totals.socket_dry_flask_percent
    end

    if hasHealth and not hasMana and (totals.socket_second_sip_percent or 0) > 0 then
        state.secondSipUntil = now + math.max(1, totals.socket_second_sip_window or 0)
    elseif hasMana and not hasHealth and (totals.socket_second_sip_percent or 0) > 0
        and now <= (state.secondSipUntil or 0)
        and useCooldown(state, "second_sip", totals.socket_second_sip_cooldown, now) then
        state.secondSipUntil = 0
        result.manaPercent = result.manaPercent + totals.socket_second_sip_percent
    end

    if hasHealth and (totals.socket_mirror_sip_percent or 0) > 0
        and useCooldown(state, "mirror_sip", totals.socket_mirror_sip_cooldown, now) then
        result.mirrorSipPercent = totals.socket_mirror_sip_percent
    end

    if (totals.socket_safe_hands_reduce_percent or 0) > 0
        and useCooldown(state, "safe_hands_potion", totals.socket_safe_hands_cooldown, now) then
        state.flags.safeHands = true
    end
    if (totals.socket_sharp_hands_percent or 0) > 0
        and useCooldown(state, "sharp_hands_potion", totals.socket_sharp_hands_cooldown, now) then
        state.flags.sharpHands = true
    end

    if state.freshStartReady and (totals.socket_fresh_start_potion_percent or 0) > 0 then
        state.freshStartReady = false
        result.healthPercent = result.healthPercent + (hasHealth and totals.socket_fresh_start_potion_percent or 0)
        result.manaPercent = result.manaPercent + (hasMana and totals.socket_fresh_start_potion_percent or 0)
    end

    if hasHealth and (totals.socket_barrier_sip_reduction_percent or 0) > 0
        and useCooldown(state, "barrier_sip", totals.socket_barrier_sip_cooldown, now) then
        state.barrierSipActiveUntil = now + math.max(1, tonumber(totals.socket_barrier_sip_duration) or 0)
        player:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
    end

    if (totals.socket_cleanse_sip_chance or 0) > 0
        and cooldownReady(state, "cleanse_sip", now)
        and rollChance(totals.socket_cleanse_sip_chance)
        and removeOneNegativeCondition(player) then
        setCooldown(state, "cleanse_sip", totals.socket_cleanse_sip_cooldown, now)
        player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    end

    local bloomChance = math.max(0, tonumber(totals.socket_potion_bloom_chance) or 0)
    local bloomPercent = math.max(0, tonumber(totals.socket_potion_bloom_heal_percent) or 0)
    if hasHealth and bloomChance > 0 and bloomPercent > 0
        and cooldownReady(state, "potion_bloom", now)
        and rollChance(bloomChance) then
        local range = math.max(1, tonumber(totals.socket_potion_bloom_range) or 0)
        local healed = false
        for _, member in ipairs(getPartyPlayersInRange(player, range, false)) do
            local amount = scaleByPercent(member:getMaxHealth(), bloomPercent)
            if amount > 0 then
                member:addHealth("healing", amount)
                member:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
                healed = true
            end
        end
        if healed then
            setCooldown(state, "potion_bloom", totals.socket_potion_bloom_cooldown, now)
        end
    end

    return result
end

_G.GemsSocket_tryCraftMaterialRefund = function(player, consumedMaterials, bonusCache)
    if type(_G.ExtraSocketGems) ~= "table" or type(_G.ExtraSocketGems.tryCraftMaterialRefund) ~= "function" then
        return false
    end
    return _G.ExtraSocketGems.tryCraftMaterialRefund(player, consumedMaterials, bonusCache)
end
