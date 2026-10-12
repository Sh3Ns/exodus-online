local mType = Game.createMonsterType("Storm")
local monster = {}

monster.description = "a storm"
monster.experience = 0
monster.outfit = {
    lookType = 983,
    lookHead = 0,
    lookBody = 0,
    lookLegs = 0,
    lookFeet = 0,
    lookAddons = 0,
    lookMount = 0
}

monster.health = 1
monster.maxHealth = 1
monster.race = "elemental"
monster.corpse = 0
monster.speed = 420
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
    attackable = false,
    hostile = true,
    convinceable = false,
    pushable = false,
    rewardBoss = false,
    illusionable = false,
    canPushItems = false,
    canPushCreatures = false,
    staticAttackChance = 90,
    targetDistance = 4,
    runHealth = 0,
    healthHidden = true,
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
    { name = "condition", type = CONDITION_BEWITCHED, interval = 4000, chance = 25, minDamage = -1000, maxDamage = -2000, radius = 3, effect = 452, target = false },
    { name = "combat", interval = 3000, chance = 30, type = COMBAT_FIREDAMAGE, minDamage = -2000, maxDamage = -3000, radius = 5, effect = 416, target = false }
}

monster.defenses = {
    defense = 30,
    armor = 30
}

monster.elements = {
    { type = COMBAT_PHYSICALDAMAGE, percent = 0 },
    { type = COMBAT_ENERGYDAMAGE, percent = 50 },
    { type = COMBAT_EARTHDAMAGE, percent = -20 },
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
    { type = "paralyze", condition = true },
    { type = "outfit", condition = true },
    { type = "invisible", condition = true },
    { type = "bleed", condition = true }
}

mType:register(monster)
