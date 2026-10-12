local mType = Game.createMonsterType("Moonstone Miner")
local monster = {}

monster.description = "a moonstone miner"
monster.experience = 0
monster.outfit = {
    lookType = 1573,
    lookHead = 0,
    lookBody = 0,
    lookLegs = 0,
    lookFeet = 0,
    lookAddons = 0,
    lookMount = 0
}

monster.health = 8000
monster.maxHealth = 8000
monster.race = "humanoid"
monster.corpse = 26691
monster.speed = 320
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
    interval = 4000,
    chance = 10
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
    {
        id = 31906,
        chance = 100000,
        maxCount = 2
    }
}

monster.attacks = {
    { name = "melee", interval = 2000, chance = 100, minDamage = -100, maxDamage = -250 }
}

monster.defenses = {
    defense = 20,
    armor = 20
}

monster.elements = {
    { type = COMBAT_PHYSICALDAMAGE, percent = 0 },
    { type = COMBAT_ENERGYDAMAGE, percent = -10 },
    { type = COMBAT_EARTHDAMAGE, percent = 80 },
    { type = COMBAT_FIREDAMAGE, percent = -10 },
    { type = COMBAT_LIFEDRAIN, percent = 0 },
    { type = COMBAT_MANADRAIN, percent = 0 },
    { type = COMBAT_DROWNDAMAGE, percent = 0 },
    { type = COMBAT_ICEDAMAGE, percent = 0 },
    { type = COMBAT_HOLYDAMAGE, percent = 0 },
    { type = COMBAT_DEATHDAMAGE, percent = 80 },
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
