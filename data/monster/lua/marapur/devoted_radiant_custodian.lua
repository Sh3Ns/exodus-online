local mType = Game.createMonsterType("Devoted Radiant Custodian")
local monster = {}

monster.description = "a Devoted Radiant Custodian"
monster.experience = 33000
monster.outfit = {
	lookType = 1570,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 3,
	lookMount = 0
}

monster.health = 31000
monster.maxHealth = 31000
monster.race = "human"
monster.raceid = 2201  
monster.corpse = 26691
monster.speed = 400
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 60,
	health = 10,
	damage = 30,
	random = 0,
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
	canPushCreatures = true,
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

monster.voices = {
	interval = 7000,
	chance = 30

}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "skull staff", chance = 65560},
	{id = "epee", chance = 75560},
	{id = "crystal mace", chance = 25560},
	{id = "noble axe", chance = 8560},
	{id = "spellbook of mind control", chance = 9000},
	{id = "fire axe", chance = 13500},
	{id = "royal helmet", chance = 15500},
	{id = "mastermind shield", chance = 9500},
	{id = "assassin dagger", chance = 8500},
	{id = "butcher's axe", chance = 7500},
	{id = "jade hammer", chance = 6500},
	{id = "crystalline sword", chance = 5500},
	{id = "alloy legs", chance = 4500},
	{id = "metal bat", chance = 3500},
	{id = "pyrophyte seed pod", chance = 3000},
	{id = "tatty robe", chance = 4000},
	{id = "loose prayer beads", chance = 3000},
	{id = "ice shard", chance = 2000},
	{id = "golden belt", chance = 1800},
	{id = "gilded bell", chance = 1500},
	{id = "cloud familiar", chance = 1300},
	{id = "ceremonial bowl", chance = 2000},
	{id = "catnip", chance = 4500},
	{id = "broken arrow", chance = 2800},
	{id = "book of faith", chance = 2200},
	{id = "skewered fish", chance = 2000}

}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -450, maxDamage = -1513, effect = 446},
	{name ="combat", interval = 1000, chance = 12, type = COMBAT_ENERGYDAMAGE, minDamage = -600, maxDamage = -1700, radius = 7, effect = 452, target = false},
	{name ="combat", interval = 1000, chance = 12, type = COMBAT_WATERDAMAGE, minDamage = -400, maxDamage = -1800, radius = 7, effect = 440, target = false},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_ICEDAMAGE, minDamage = -500, maxDamage = -1340, range = 7, effect = 434, target = false},
}

monster.defenses = {
	defense = 90,
	armor = 90,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 5},
	{type = COMBAT_ENERGYDAMAGE, percent = 5},
	{type = COMBAT_EARTHDAMAGE, percent = 5},
	{type = COMBAT_FIREDAMAGE, percent = 5},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = 5},
	{type = COMBAT_DEATHDAMAGE , percent = 5},
	{type = COMBAT_WATERDAMAGE , percent = 5},
	{type = COMBAT_ARCANEDAMAGE , percent = 5}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
