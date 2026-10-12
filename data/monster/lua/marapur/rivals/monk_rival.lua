local mType = Game.createMonsterType("Monk Rival")
local monster = {}

monster.description = "a monk rival"
monster.experience = 0
monster.outfit = {
    lookType = 1464,
    lookHead = 19,
    lookBody = 76,
    lookLegs = 74,
    lookFeet = 114,
    lookAddons = 0,
    lookMount = 0
}

monster.health = 10000
monster.maxHealth = 10000
monster.race = "humanoid"
monster.corpse = 0
monster.speed = 400
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
    interval = 3000,
    chance = 15
}

monster.strategiesTarget = {
    nearest = 80,
    health = 10,
    damage = 10,
    random = 0
}

monster.events = {
    "playerAttackSound"
}

monster.flags = {
    summonable = false,
    attackable = true,
    hostile = true,
    convinceable = false,
    pushable = false,
    rewardBoss = false,
    illusionable = false,
    canPushItems = true,
    canPushCreatures = false,
    staticAttackChance = 90,
    targetDistance = 1,
    runHealth = 0,
    healthHidden = false,
    isBlockable = false,
    canWalkOnEnergy = true,
    canWalkOnFire = true,
    canWalkOnPoison = true,
    pet = false
}

monster.light = {
    level = 0,
    color = 0
}

monster.summon = {
}

monster.voices = {
    interval = 5000,
    chance = 0
}

monster.loot = {
}

monster.attacks = {
    { name = "melee", interval = 1600, chance = 100, minDamage = -180, maxDamage = -400 },
    { name = "combat", interval = 2100, chance = 22, type = COMBAT_PHYSICALDAMAGE, minDamage = -170, maxDamage = -380, radius = 2, effect = CONST_ME_HITAREA, target = false },
    { name = "combat", interval = 2500, chance = 18, type = COMBAT_HOLYDAMAGE, minDamage = -150, maxDamage = -350, range = 4, shootEffect = CONST_ANI_HOLY, effect = CONST_ME_HOLYDAMAGE, target = true },
    { name = "combat", interval = 3000, chance = 15, type = COMBAT_LIFEDRAIN, minDamage = -150, maxDamage = -300, radius = 3, effect = CONST_ME_MORTAREA, target = false }
}

monster.defenses = {
    defense = 50,
    armor = 45
}

monster.elements = {
    { type = COMBAT_PHYSICALDAMAGE, percent = 0 },
    { type = COMBAT_ENERGYDAMAGE, percent = 0 },
    { type = COMBAT_EARTHDAMAGE, percent = 0 },
    { type = COMBAT_FIREDAMAGE, percent = 0 },
    { type = COMBAT_LIFEDRAIN, percent = 0 },
    { type = COMBAT_MANADRAIN, percent = 0 },
    { type = COMBAT_DROWNDAMAGE, percent = 0 },
    { type = COMBAT_ICEDAMAGE, percent = 0 },
    { type = COMBAT_HOLYDAMAGE, percent = 0 },
    { type = COMBAT_DEATHDAMAGE, percent = 0 },
    { type = COMBAT_WATERDAMAGE, percent = 0 },
    { type = COMBAT_ARCANEDAMAGE, percent = 0 }
}

monster.immunities = {
    { type = "paralyze", condition = false },
    { type = "outfit", condition = true },
    { type = "invisible", condition = true },
    { type = "bleed", condition = false }
}

mType:register(monster)
