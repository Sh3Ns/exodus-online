local mType = Game.createMonsterType("Devoted Radiant Inquisitor")
local monster = {}

monster.description = "a Devoted Radiant Inquisitor"
monster.experience = 32500
monster.outfit = {
	lookType = 1561,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 2,
	lookMount = 0
}

monster.health = 31500
monster.maxHealth = 31500
monster.race = "human"
monster.raceid = 2198
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
	targetDistance = 3,
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
	chance = 30,
	{text = "You are flawed!", yell = true},
	{text = "This place will be cleansed of you!", yell = true}

}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "gold ingot", chance = 65560},
	{id = "glacier robe", chance = 25560},
	{id = "violet gem", chance = 25560},
	{id = "blue gem", chance = 45560},
	{id = "rift bow", chance = 2500},
	{id = "wood cape", chance = 16500},
	{id = "northwind rod", chance = 13500},
	{id = "springsprout rod", chance = 11500},
	{id = "sacred tree amulet", chance = 8500},
	{id = "crystalline armor", chance = 4500},
	{id = "rubber cap", chance = 3500},
	{id = "fur armor", chance = 2500},
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
	{id = "skewered fish", chance = 2000},
	{id = "shatterstorm arrow", chance = 2000, maxCount = 4},
	{id = "firestorm arrow", chance = 2000, maxCount = 4},
	{id = "terrastorm arrow", chance = 2000, maxCount = 4},
	{id = "froststorm arrow", chance = 2000, maxCount = 4},
	{id = "thunderstorm arrow", chance = 2000, maxCount = 4}

}

monster.attacks = {
	{name ="melee", interval = 2000, type = COMBAT_PHYSICALDAMAGE, shootEffect = 132, chance = 100, minDamage = -500, maxDamage = -1520},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_HOLYDAMAGE, minDamage = -450, maxDamage = -1505, length = 8, spread = 3, effect = 361, target = false},
	{name ="combat", interval = 2000, chance = 16, type = COMBAT_ENERGYDAMAGE, minDamage = -650, maxDamage = -1850, radius = 4, effect = 453, target = false},
	{name ="combat", interval = 2000, chance = 22, type = COMBAT_ENERGYDAMAGE, minDamage = -800, maxDamage = -1700, range = 7, shootEffect = 136, effect = 455, target = false},
	{name ="condition", type = CONDITION_BLEEDING, interval = 2000, chance = 40, minDamage = -400, maxDamage = -1550, radius = 4, shootEffect = 106, target = true},
}

monster.defenses = {
	defense = 80,
	armor = 100,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = -10},
	{type = COMBAT_ENERGYDAMAGE, percent = 20},
	{type = COMBAT_EARTHDAMAGE, percent = 5},
	{type = COMBAT_FIREDAMAGE, percent = -5},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -10},
	{type = COMBAT_HOLYDAMAGE , percent = 25},
	{type = COMBAT_DEATHDAMAGE , percent = -5},
	{type = COMBAT_WATERDAMAGE , percent = -11},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
