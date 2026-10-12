local storageDouble = 405905

local maxJumps = 4
local maxRange = 3
local jumpDistance = 2
local damageReduction = 0.05
local effect = 370

local weaponDamageType = {
    -- Energy
    [29927] = COMBAT_ENERGYDAMAGE,
    [29929] = COMBAT_ENERGYDAMAGE,
    [29931] = COMBAT_ENERGYDAMAGE,
    [29934] = COMBAT_ENERGYDAMAGE,
    [11308] = COMBAT_ENERGYDAMAGE,
    [29936] = COMBAT_ENERGYDAMAGE,
    [29941] = COMBAT_ENERGYDAMAGE,
    [29942] = COMBAT_ENERGYDAMAGE,
    [29943] = COMBAT_ENERGYDAMAGE,
    [29949] = COMBAT_ENERGYDAMAGE,
    [29954] = COMBAT_ENERGYDAMAGE,

    -- Earth
    [29928] = COMBAT_EARTHDAMAGE,
    [2401] = COMBAT_EARTHDAMAGE,
    [29932] = COMBAT_EARTHDAMAGE,
    [29956] = COMBAT_EARTHDAMAGE,
    [29937] = COMBAT_EARTHDAMAGE,
    [29940] = COMBAT_EARTHDAMAGE,
    [29947] = COMBAT_EARTHDAMAGE,
    [29950] = COMBAT_EARTHDAMAGE,
    [29951] = COMBAT_EARTHDAMAGE,
    [29953] = COMBAT_EARTHDAMAGE,

    -- Physical
    [29930] = COMBAT_PHYSICALDAMAGE,
    [11306] = COMBAT_PHYSICALDAMAGE,
    [29933] = COMBAT_PHYSICALDAMAGE,
    [20108] = COMBAT_PHYSICALDAMAGE,
    [29935] = COMBAT_PHYSICALDAMAGE,
    [29957] = COMBAT_PHYSICALDAMAGE,
    [29938] = COMBAT_PHYSICALDAMAGE,
    [29939] = COMBAT_PHYSICALDAMAGE,
    [29946] = COMBAT_PHYSICALDAMAGE,
    [29948] = COMBAT_PHYSICALDAMAGE,
    [29952] = COMBAT_PHYSICALDAMAGE,
    [29955] = COMBAT_PHYSICALDAMAGE,

    -- Arcane
    [29944] = COMBAT_ARCANEDAMAGE,

    -- Water
    [29945] = COMBAT_WATERDAMAGE
}

local area = {
    {0, 0, 1, 0, 0},
    {0, 0, 0, 1, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 3, 0, 0},
    {0, 0, 0, 0, 0},
}

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_NONE)
combat:setParameter(COMBAT_PARAM_EFFECT, effect)
combat:setArea(createCombatArea(area))

function onGetFormulaValues(player, skill, attack, factor)
    local fistSkill = player:getEffectiveSkillLevel(SKILL_FIST)
    local min = (player:getLevel() / 5) + (fistSkill * 2.1) + 9
    local max = (player:getLevel() / 5) + (fistSkill * 3.4) + 14
    return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local function getWeaponDamageType(player)
    local weapon = player:getSlotItem(CONST_SLOT_LEFT)
    if player:getStorageValue(37067) == 1 then
        return COMBAT_ARCANEDAMAGE
    elseif player:getStorageValue(37066) == 1 then
        return COMBAT_HOLYDAMAGE
    elseif player:getStorageValue(37065) == 1 then
        return COMBAT_EARTHDAMAGE
    elseif player:getStorageValue(37064) == 1 then
        return COMBAT_WATERDAMAGE
    end
    if not weapon then
        return COMBAT_PHYSICALDAMAGE
    end
    local weaponId = weapon:getId()
    return weaponDamageType[weaponId] or COMBAT_PHYSICALDAMAGE
end

local function isValidTarget(creature)
    if not creature or not creature:isMonster() then
        return false
    end
    if creature:isNpc() then
        return false
    end
    return true
end

local function calculateDamage(player, damageMult)
    local fistSkill = player:getEffectiveSkillLevel(SKILL_FIST)
    local min = (player:getLevel() / 5) + (fistSkill * 2.9) + 12
    local max = (player:getLevel() / 5) + (fistSkill * 4.2) + 20
    if player:getStorageValue(storageDouble) == 1 then
        min = math.floor(min * 1.08)
        max = math.floor(max * 1.08)
    end

    local helmet = player:getSlotItem(CONST_SLOT_HEAD)
    if helmet and helmet:getId() == 29970 then
        min = math.floor(min * 1.06)
        max = math.floor(max * 1.06)
    end
    local legs = player:getSlotItem(CONST_SLOT_LEGS)
    if legs and legs:getId() == 29999 then
        min = math.floor(min * 1.08)
        max = math.floor(max * 1.08)
    end
    return -min * damageMult, -max * damageMult
end

local function getClosestTargetInRange(fromPos, distance)
    local spectators = Game.getSpectators(fromPos, false, false, true, distance, distance, distance, distance)
    local bestTarget, bestDist = nil, math.huge
    for _, target in ipairs(spectators) do
        if isValidTarget(target) then
            local dist = fromPos:getDistance(target:getPosition())
            if dist < bestDist then
                bestDist = dist
                bestTarget = target
            end
        end
    end
    return bestTarget
end

local function getBestTargetInRange(fromPos, excludeList, distance)
    local spectators = Game.getSpectators(fromPos, false, false, true, distance, distance, distance, distance)
    local bestTarget, bestPercent = nil, -1
    for _, target in ipairs(spectators) do
        if isValidTarget(target) and not table.contains(excludeList, target) then
            local hpPercent = (target:getHealth() / target:getMaxHealth()) * 100
            if hpPercent > bestPercent then
                bestPercent = hpPercent
                bestTarget = target
            end
        end
    end
    return bestTarget
end

local function chainHit(playerId, targetId, jumpsLeft, damageMult, hitIds)
    local player = Player(playerId)
    local target = Creature(targetId)
    if not player or not target or not target:isCreature() then return end

    local hitList = {}
    for _, id in ipairs(hitIds or {}) do
        local c = Creature(id)
        if c then
            table.insert(hitList, c)
        end
    end

    local min, max = calculateDamage(player, damageMult)
    local dmgType = getWeaponDamageType(player)
    doTargetCombatHealth(player:getId(), target, dmgType, min, max, effect)
    table.insert(hitList, target)

    if jumpsLeft > 0 then
        local nextTarget = getBestTargetInRange(target:getPosition(), hitList, jumpDistance)
        if nextTarget then
            local newHitIds = {}
            for _, c in ipairs(hitList) do
                table.insert(newHitIds, c:getId())
            end
            addEvent(chainHit, 200, player:getId(), nextTarget:getId(), jumpsLeft - 1, damageMult * (1 - damageReduction), newHitIds)
        end
    end
end

function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then return false end

    local success = combat:execute(player, variant)
    if not success then
        return false
    end
    local firstTarget = getClosestTargetInRange(player:getPosition(), maxRange)
    if firstTarget then
        chainHit(player:getId(), firstTarget:getId(), maxJumps, 1.0, { firstTarget:getId() })
    end

    playSound(player, "chamaleon.ogg")
    if MonkHarmony then
        MonkHarmony.add(player, 1)
    end
    return true
end
