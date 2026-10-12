local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_NONE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)

local storageDouble = 405905

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
    if not weapon then
        return COMBAT_PHYSICALDAMAGE
    end
    local weaponId = weapon:getId()
    return weaponDamageType[weaponId] or COMBAT_PHYSICALDAMAGE
end

function onGetFormulaValues(player, skill, attack, factor)
	local fistSkill = player:getEffectiveSkillLevel(SKILL_FIST)
	local min = (player:getLevel() / 5) + (fistSkill * 0.8) + 1.5
	local max = (player:getLevel() / 5) + (fistSkill * 1.6) + 3.2
	if player:getStorageValue(storageDouble) == 1 then
        min = math.floor(min * 1.08)
        max = math.floor(max * 1.08)
    end

    local weapon = player:getSlotItem(CONST_SLOT_LEFT)
    if weapon and weapon:getId() == 29929 then
        min = math.floor(min * 1.08)
        max = math.floor(max * 1.08)
    end
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	local player = Player(creature)
    if not player then return false end

	playSound(creature, "block.ogg")
	local dmgType = getWeaponDamageType(player)
    combat:setParameter(COMBAT_PARAM_TYPE, dmgType)
    if MonkHarmony then
        return MonkHarmony.castBuilder(player, combat, variant, 1)
    end
    return combat:execute(player, variant)
end
