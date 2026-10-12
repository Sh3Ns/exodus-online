-- Script maded by

--            _                   _             _     _      _    _          _        _                 _______
--           / /\                _\ \          /\ \ /_/\    /\ \ /\ \    _ / /\   _  /\ \              / ___  /\
--          / /  \              /\__ \        /  \ \\ \ \   \ \_\\ \ \  /_/ / /  /\_\\ \ \            / /\__\ \ \
--         / / /\ \            / /_ \_\      / /\ \ \\ \ \__/ / / \ \ \ \___\/  / / / \ \ \          / / /   \_\/
--        / / /\ \ \          / / /\/_/     / / /\ \_\\ \__ \/_/  / / /  \ \ \ / / /   \ \ \        / / /
--       / / /  \ \ \        / / /         / /_/_ \/_/ \/_/\__/\  \ \ \   \_\ \\ \ \____\ \ \       \ \ \
--      / / /___/ /\ \      / / /         / /____/\     _/\/__\ \  \ \ \  / / / \ \________\ \       \ \ \
--     / / /_____/ /\ \    / / / ____    / /\____\/    / _/_/\ \ \  \ \ \/ / /   \/________/\ \       \ \ \
--    / /_________/\ \ \  / /_/_/ ___/\ / / /______   / / /   \ \ \  \ \ \/ /              \ \ \  ____/ / /
--   / / /_       __\ \_\/_______/\__\// / /_______\ / / /    /_/ /   \ \  /                \ \_\/_____/ /
--   \_\___\     /____/_/\_______\/    \/__________/ \/_/     \_\/     \_\/                  \/_/\_____\/

--- Do not touch if you dont know what you are doing ---

local config = {
    chances = {7, 9, 14, 20},
    bonusPercents = {3, 6, 9, 15},
    durations = {25, 45, 65, 90},
    minDetectableDamage = 50,
    onlyWeapons = false,
}

local summonStorage = DeckSystem.Legendary.CanCreateSummon
local summonEventName = "SummonFollow"
local summonEffects = {
    spawn = 214,
    remove = 218,
}

local allowedOrigins = {}
if ORIGIN_WAND then
    allowedOrigins[ORIGIN_WAND] = true
end
if ORIGIN_MELEE then
    allowedOrigins[ORIGIN_MELEE] = true
end
if ORIGIN_RANGED then
    allowedOrigins[ORIGIN_RANGED] = true
end

local function makeSet(list)
    local set = {}
    for i = 1, #list do
        set[list[i]] = true
    end
    return set
end

local weaponSets = {
    knight = makeSet({
        7382, 7403, 7405, 6528, 8932, 2408, 2390, 11306, 12613, 22398, 22399, 22400, 22401, 22402, 22403, 26759, 26760, 27204,
        27214, 27269, 27377, 27378, 27400, 27458, 27459, 27464, 27465, 27654, 27655, 27681, 2454, 2443, 6553, 7453, 2415, 8926,
        11309, 22404, 22405, 22406, 22407, 22408, 22409, 27205, 27216, 27285, 27379, 27380, 27404, 27462, 27463, 27468, 27469, 27643,
        27658, 27659, 27682, 2444, 2452, 7423, 829, 11308, 201108, 22410, 22411, 22412, 22413, 22414, 22415, 27206, 27210, 27229,
        27381, 27382, 27405, 27460, 27461, 27466, 27467, 27642, 27656, 27657, 27683, 28025, 28026, 28027, 28102, 28103, 28104, 28128,
        28129, 28130, 28134, 28135, 28373, 28374, 28375, 28712, 28714, 28716, 29481, 29482, 29483, 29484, 29485, 29486, 2401, 11306,
        11308, 29927, 29929, 29931, 29934, 29936, 29941, 29942, 29943, 29949, 29954, 29928, 29932, 29956, 29937, 29940, 29947, 29950,
        29951, 29953, 29930, 29933, 20108, 29935, 29957, 29938, 29939, 29946, 29948, 29952, 29955, 29944, 29945, 30926, 30927, 30928, 30929, 30930, 30931, 30932, 30933, 30934, 30935, 30936, 30937, 30942, 30943
    }),
    druid = makeSet({
        18411, 18412, 24839, 26757, 27197, 27386, 27396, 27479, 27480, 27209, 27649, 27671, 27672, 27689, 28042, 28110, 28133, 28376,
        28717, 29489, 29490, 30940, 30941
    }),
    sorcerer = makeSet({
        18390, 18409, 19391, 25421, 25422, 26756, 27194, 27198, 27208, 27385, 27397, 27476, 27477, 27650, 27665, 27666, 27688, 28042,
        28110, 28132, 28376, 28717, 29487, 29488, 30938, 30939
    }),
    paladin = makeSet({
        5803, 8850, 8853, 8852, 8851, 8856, 8858, 8854, 15643, 15644, 16111, 18453, 18454, 21690, 22416, 22417, 22418, 22419, 22420,
        22421, 25522, 25523, 26758, 26765, 27199, 27212, 27230, 27383, 27384, 27395, 27471, 27472, 27473, 27474, 27646, 27661, 27662,
        27685, 28051, 28052, 28116, 28131, 28137, 28378, 28713, 28715, 29477, 29478, 29479, 29480, 30944, 30945, 30946, 30947
    }),
}

local legendaryGroups = {
    {
        weaponSet = weaponSets.knight,
        summons = {"Nineveth", "Kaldor", "Blackfang", "Thirain"},
        bonusParams = {
            CONDITION_PARAM_SKILL_MELEE,
            CONDITION_PARAM_SKILL_FIST,
        },
        storages = {
            DeckSystem.Legendary.LegendaryExoticKaiserLv6,
            DeckSystem.Legendary.LegendaryChaosKaiserLv6,
            DeckSystem.Legendary.LegendaryAbyssalKaiserLv6,
            DeckSystem.Legendary.LegendaryAncestralKaiserLv6,
        },
    },
    {
        weaponSet = weaponSets.druid,
        summons = {"Signatus", "Erasmo", "Azena", "Navinos"},
        bonusParams = {
            CONDITION_PARAM_STAT_MAGICPOINTS,
        },
        storages = {
            DeckSystem.Legendary.LegendaryExoticSaydonLv6,
            DeckSystem.Legendary.LegendaryChaosSaydonLv6,
            DeckSystem.Legendary.LegendaryAbyssalSaydonLv6,
            DeckSystem.Legendary.LegendaryAncestralSaydonLv6,
        },
    },
    {
        weaponSet = weaponSets.paladin,
        summons = {"Vykas", "Wonpho", "Kyzra", "Shandi"},
        bonusParams = {
            CONDITION_PARAM_SKILL_DISTANCE,
        },
        storages = {
            DeckSystem.Legendary.LegendaryExoticVercruzeLv6,
            DeckSystem.Legendary.LegendaryChaosVercruzeLv6,
            DeckSystem.Legendary.LegendaryAbyssalVercruzeLv6,
            DeckSystem.Legendary.LegendaryAncestralVercruzeLv6,
        },
    },
    {
        weaponSet = weaponSets.sorcerer,
        summons = {"Kagros", "Lutia", "Thaemine", "Halrock"},
        bonusParams = {
            CONDITION_PARAM_STAT_MAGICPOINTS,
        },
        storages = {
            DeckSystem.Legendary.LegendaryExoticAscalonLv6,
            DeckSystem.Legendary.LegendaryChaosAscalonLv6,
            DeckSystem.Legendary.LegendaryAbyssalAscalonLv6,
            DeckSystem.Legendary.LegendaryAncestralAscalonLv6,
        },
    },
}

local function getLegendaryRank(player)
    for groupIndex = 1, #legendaryGroups do
        local group = legendaryGroups[groupIndex]
        for rank = #group.storages, 1, -1 do
            if player:getStorageValue(group.storages[rank]) == 1 then
                return group, rank
            end
        end
    end
    return nil, nil
end

local function removeSummon(playerId, monsterId)
    local summonOwner = Player(playerId)
    local monster = Monster(monsterId)
    if monster then
        monster:getPosition():sendMagicEffect(summonEffects.remove)
        monster:remove()
    end
    if summonOwner then
        summonOwner:setStorageValue(summonStorage, 0)
    end
end

local function applyLegendaryBonus(player, bonusParams, rank)
    local bonus = Condition(CONDITION_ATTRIBUTES)
    bonus:setParameter(CONDITION_PARAM_TICKS, config.durations[rank] * 1000)
    for i = 1, #bonusParams do
        bonus:setParameter(bonusParams[i], config.bonusPercents[rank])
    end
    player:addCondition(bonus)
end

local function tryTriggerLegendary(player, damage)
    if damage < config.minDetectableDamage or player:getStorageValue(summonStorage) >= 1 then
        return
    end

    local leftHand = player:getSlotItem(CONST_SLOT_LEFT)
    if not leftHand then
        return
    end

    local group, rank = getLegendaryRank(player)
    if not group or not group.weaponSet[leftHand:getId()] then
        return
    end

    if math.random(100) > config.chances[rank] then
        return
    end

    local monster = Game.createMonster(group.summons[rank], player:getPosition())
    if not monster then
        return
    end

    monster:setMaster(player)
    monster:registerEvent(summonEventName)
    monster:getPosition():sendMagicEffect(summonEffects.spawn)

    player:setStorageValue(summonStorage, 1)
    playSound(player, "monster_summoned.ogg")

    addEvent(removeSummon, config.durations[rank] * 1000, player:getId(), monster:getId())
    applyLegendaryBonus(player, group.bonusParams, rank)
end

local function shouldProcessOrigin(origin)
    return not config.onlyWeapons or allowedOrigins[origin] == true
end

local function whenPlayerAttack(player, damage)
    tryTriggerLegendary(player, math.abs(damage))
end

local healthEvent = CreatureEvent("WhenPlayerAttackHealth")

function healthEvent.onHealthChange(creature, player, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not player or not player:isPlayer() or primaryType == COMBAT_HEALING then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if shouldProcessOrigin(origin) then
        whenPlayerAttack(player, primaryDamage + secondaryDamage)
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

healthEvent:register()

local manaEvent = CreatureEvent("WhenPlayerAttackMana")

function manaEvent.onManaChange(creature, player, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not player or not player:isPlayer() or primaryType == COMBAT_MANADRAIN then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if shouldProcessOrigin(origin) then
        whenPlayerAttack(player, primaryDamage + secondaryDamage)
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

manaEvent:register()
