local storageDouble = 405905

local area = {
	{0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
	{1, 1, 0, 1, 1},
}

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

local function getWeaponDamageType(player)
    local weapon = player:getSlotItem(CONST_SLOT_LEFT)
    if player:getStorageValue(37071) == 1 then
        return COMBAT_WATERDAMAGE
    elseif player:getStorageValue(37070) == 1 then
        return COMBAT_DEATHDAMAGE
    elseif player:getStorageValue(37069) == 1 then
        return COMBAT_FIREDAMAGE
    elseif player:getStorageValue(37068) == 1 then
        return COMBAT_PHYSICALDAMAGE
    end
    if not weapon then
        return COMBAT_PHYSICALDAMAGE
    end
    local weaponId = weapon:getId()
    return weaponDamageType[weaponId] or COMBAT_PHYSICALDAMAGE
end

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_NONE)
combat:setParameter(COMBAT_PARAM_EFFECT, 371)
combat:setArea(createCombatArea(area))

function onGetFormulaValues(player, skill, attack, factor)
    local fistSkill = player:getEffectiveSkillLevel(SKILL_FIST)
    local min = (player:getLevel() / 5) + (fistSkill * 2.6) + 8
    local max = (player:getLevel() / 5) + (fistSkill * 3.8) + 14

    if player:getStorageValue(storageDouble) == 1 then
        min = math.floor(min * 1.08)
        max = math.floor(max * 1.08)
    end
    if MonkHarmony then
        min, max = MonkHarmony.scaleDamage(player, min, max)
    end
    return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then return false end
    local dmgType = getWeaponDamageType(player)
    combat:setParameter(COMBAT_PARAM_TYPE, dmgType)
    playSound(creature, "arcane_5.ogg")
    if MonkHarmony then
        return MonkHarmony.castSpender(player, combat, variant)
    end
    return combat:execute(player, variant)
end
