local ForgeEffectConfig = {
    tierAttribute = "forge_tier",
    maxTier = 10,

    chances = {
        onslaught = { 0.50, 1.05, 1.70, 2.45, 3.30, 4.25, 5.30, 6.45, 7.70, 9.05 },
        ruse = { 0.50, 1.03, 1.62, 2.28, 3.00, 3.78, 4.62, 5.52, 6.48, 7.51 },
        momentum = { 2.00, 4.05, 6.20, 8.45, 10.80, 13.25, 15.80, 18.45, 21.20, 24.05 },
        transcendence = { 0.13, 0.27, 0.44, 0.64, 0.86, 1.11, 1.38, 1.68, 2.00, 2.35 },
        amplification = { 2.50, 5.40, 9.10, 13.60, 18.90, 25.00, 31.90, 39.60, 48.10, 57.40 },
    },

    effects = {
        onslaughtDamageBonusPercent = 60,
        momentumCooldownReductionMs = 2000,
        transcendenceDurationMs = 7000,
        transcendenceSpellDamageBonusPercent = 20,
    },

    -- Officially, using a weapon, offensive rune or offensive spell makes the
    -- next 2-second Transcendence check eligible. The active buff only boosts
    -- spell/rune damage at least for 7s because we don't have the avatar system
    transcendenceTriggerOrigins = {
        [ORIGIN_SPELL] = true,
        [ORIGIN_MELEE] = true,
        [ORIGIN_RANGED] = true,
        [ORIGIN_WAND] = true,
    },

    visuals = {
        onslaught = 409,
        ruse = 410,
        momentum = 411,
        transcendence = 408,
    },
}

local ForgeItems = dofile("data/scripts/customs/forge/forge_items.lua")
local runtime = {}

local function nowMs()
    return os.mtime and os.mtime() or (os.time() * 1000)
end

local function getTier(item, expectedKind)
    if not item or not item:isItem() then return 0 end
    local itemType = item:getType()
    if not itemType or ForgeItems.getEquipmentKind(itemType) ~= expectedKind then return 0 end
    local tier = math.floor(tonumber(item:getCustomAttribute(ForgeEffectConfig.tierAttribute)) or 0)
    return math.max(0, math.min(ForgeEffectConfig.maxTier, tier))
end

local function getEquippedTier(player, slot, kind)
    if not player or not player:isPlayer() then return 0 end
    return getTier(player:getSlotItem(slot), kind)
end

local function getWeaponTier(player)
    local highestTier = 0
    for _, slot in ipairs({ CONST_SLOT_RIGHT, CONST_SLOT_LEFT }) do
        highestTier = math.max(highestTier, getEquippedTier(player, slot, "weapon"))
    end
    return highestTier
end

local function getAmplificationImpact(player)
    local tier = getEquippedTier(player, CONST_SLOT_FEET, "boots")
    return ForgeEffectConfig.chances.amplification[tier] or 0
end

local function getAmplifiedChance(player, effectName, tier)
    local baseChance = ForgeEffectConfig.chances[effectName][tier] or 0
    local amplification = getAmplificationImpact(player)
    return math.min(100, baseChance * (1 + (amplification / 100)))
end

local function rolls(player, effectName, tier)
    if tier <= 0 then return false end
    local chance = getAmplifiedChance(player, effectName, tier)
    return math.random(1, 1000000) <= math.floor((chance * 10000) + 0.5)
end

local function isDamageComponent(value, combatType)
    return value ~= 0 and combatType ~= COMBAT_NONE and combatType ~= COMBAT_HEALING
end

local function hasDamage(primaryDamage, primaryType, secondaryDamage, secondaryType)
    return isDamageComponent(primaryDamage, primaryType) or
        isDamageComponent(secondaryDamage, secondaryType)
end

local function scaleValue(value, bonusPercent)
    if value == 0 then return 0 end
    local scaled = math.floor((math.abs(value) * (1 + (bonusPercent / 100))) + 0.5)
    return value < 0 and -scaled or scaled
end

local function scaleDamage(primaryDamage, primaryType, secondaryDamage, secondaryType, bonusPercent)
    if isDamageComponent(primaryDamage, primaryType) then
        primaryDamage = scaleValue(primaryDamage, bonusPercent)
    end
    if isDamageComponent(secondaryDamage, secondaryType) then
        secondaryDamage = scaleValue(secondaryDamage, bonusPercent)
    end
    return primaryDamage, secondaryDamage
end

local function showProc(player, effectName, effectPosition)
    if not player then return end
    local effect = ForgeEffectConfig.visuals[effectName]
    if effect and effect ~= CONST_ME_NONE then
        (effectPosition or player:getPosition()):sendMagicEffect(effect)
    end
    player:sendTextMessage(MESSAGE_STATUS_SMALL,
        string.format("Forge effect triggered: %s.", effectName:gsub("^%l", string.upper)))
end

local function getRuntime(player)
    local playerId = player:getId()
    local state = runtime[playerId]
    if not state then
        state = { transcendencePending = false, transcendenceUntil = 0 }
        runtime[playerId] = state
    end
    return state
end

local function processForgeDamage(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not hasDamage(primaryDamage, primaryType, secondaryDamage, secondaryType) then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    -- Ruse is resolved first: a dodged attack cannot trigger offensive effects.
    if target and target:isPlayer() and source and source ~= target then
        local armorTier = getEquippedTier(target, CONST_SLOT_ARMOR, "armor")
        if rolls(target, "ruse", armorTier) then
            showProc(target, "ruse")
            return 0, primaryType, 0, secondaryType
        end
    end

    if not source or not source:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local state = getRuntime(source)
    local currentTime = nowMs()

    if origin == ORIGIN_SPELL and currentTime < state.transcendenceUntil then
        primaryDamage, secondaryDamage = scaleDamage(
            primaryDamage, primaryType, secondaryDamage, secondaryType,
            ForgeEffectConfig.effects.transcendenceSpellDamageBonusPercent)
    end

    if ForgeEffectConfig.transcendenceTriggerOrigins[origin] then
        state.transcendencePending = true
    end

    if origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or origin == ORIGIN_WAND then
        local weaponTier = getWeaponTier(source)
        if rolls(source, "onslaught", weaponTier) then
            primaryDamage, secondaryDamage = scaleDamage(
                primaryDamage, primaryType, secondaryDamage, secondaryType,
                ForgeEffectConfig.effects.onslaughtDamageBonusPercent)
            showProc(source, "onslaught", target and target:getPosition() or source:getPosition())
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local healthEvent = CreatureEvent("ForgeEffectsHealthChange")
function healthEvent.onHealthChange(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    return processForgeDamage(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end
healthEvent:register()

local manaEvent = CreatureEvent("ForgeEffectsManaChange")
function manaEvent.onManaChange(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    return processForgeDamage(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end
manaEvent:register()

local targetEvent = EventCallback
function targetEvent.onTargetCombat(creature, target)
    if creature and target and creature:isPlayer() then
        target:registerEvent("ForgeEffectsHealthChange")
        target:registerEvent("ForgeEffectsManaChange")
    end
    return RETURNVALUE_NOERROR
end
targetEvent:register(8)

local loginEvent = CreatureEvent("ForgeEffectsLogin")
loginEvent:type("login")
function loginEvent.onLogin(player)
    runtime[player:getId()] = nil
    player:registerEvent("ForgeEffectsHealthChange")
    player:registerEvent("ForgeEffectsManaChange")
    player:registerEvent("ForgeEffectsLogout")
    return true
end
loginEvent:register()

local logoutEvent = CreatureEvent("ForgeEffectsLogout")
logoutEvent:type("logout")
function logoutEvent.onLogout(player)
    runtime[player:getId()] = nil
    return true
end
logoutEvent:register()

local thinkEvent = GlobalEvent("ForgeEffectsThink")
function thinkEvent.onThink()
    local currentTime = nowMs()
    for _, player in ipairs(Game.getPlayers()) do
        if player:getCondition(CONDITION_INFIGHT, CONDITIONID_DEFAULT) then
            local helmetTier = getEquippedTier(player, CONST_SLOT_HEAD, "helmet")
            if rolls(player, "momentum", helmetTier) then
                local reduced = player:reduceSpellCooldowns(ForgeEffectConfig.effects.momentumCooldownReductionMs)
                if reduced > 0 then showProc(player, "momentum") end
            end
        end

        local state = runtime[player:getId()]
        if state and state.transcendencePending then
            state.transcendencePending = false
            if currentTime >= state.transcendenceUntil then
                local legsTier = getEquippedTier(player, CONST_SLOT_LEGS, "legs")
                if rolls(player, "transcendence", legsTier) then
                    state.transcendenceUntil = currentTime + ForgeEffectConfig.effects.transcendenceDurationMs
                    showProc(player, "transcendence")
                end
            end
        end
    end
    return true
end
thinkEvent:interval(2000)
thinkEvent:register()
