local mType = Game.createMonsterType("Devoted Radiant Zealot")
local monster = {}

monster.description = "a Devoted Radiant Zealot"
monster.experience = 32500
monster.outfit = {
	lookType = 1560,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 2,
	lookMount = 0
}

monster.health = 34400
monster.maxHealth = 34400
monster.race = "human"
monster.raceid = 2197
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
	{text = "All for the Light!", yell = true},
	{text = "Repent!", yell = true},
	{text = "No doubt can sway me!", yell = true},

}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "spellbook of warding", chance = 41920},
	{id = "underworld rod", chance = 31920},
	{id = "springsprout rod", chance = 28920},
	{id = "gold ingot", chance = 54560},
	{id = "glacial rod", chance = 44560},
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
	{name ="melee", interval = 2000, chance = 100, minDamage = -500, maxDamage = -1520},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_HOLYDAMAGE, minDamage = -520, maxDamage = -1790, range = 7, shootEffect = 57, effect = 417, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_FIREDAMAGE, minDamage = -550, maxDamage = -1605, range = 7, radius = 1, shootEffect = 131, effect = 416, target = true},
	{name ="poisonfield", interval = 2000, chance = 20, range = 7, radius = 2, shootEffect = 55, target = true}
}

monster.defenses = {
	defense = 80,
	armor = 100,
	{name ="combat", interval = 4000, chance = 25, type = COMBAT_HEALING, minDamage = 800, maxDamage = 2250, effect = 185, target = false},
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = -15},
	{type = COMBAT_ENERGYDAMAGE, percent = 40},
	{type = COMBAT_EARTHDAMAGE, percent = 10},
	{type = COMBAT_FIREDAMAGE, percent = -5},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -5},
	{type = COMBAT_HOLYDAMAGE , percent = 20},
	{type = COMBAT_DEATHDAMAGE , percent = -10},
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
