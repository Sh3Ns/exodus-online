local mType = Game.createMonsterType("Devoted Radiant Acolyte")
local monster = {}

monster.description = "a Devoted Radiant Acolyte"
monster.experience = 32500
monster.outfit = {
	lookType = 1559,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 3,
	lookMount = 0
}

monster.health = 34400
monster.maxHealth = 34400
monster.race = "human"
monster.raceid = 2196
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
	targetDistance = 2,
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
	{text = "I will not falter!", yell = true}
}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "violet gem", chance = 74560},
	{id = "green gem", chance = 64560},
	{id = "blue gem", chance = 54560},
	{id = "northwind rod", chance = 11920},
	{id = "sacred tree amulet", chance = 21920},
	{id = "glacier shoes", chance = 12920},
	{id = "glacier robe", chance = 22920},
	{id = "stone skin amulet", chance = 8920},
	{id = "glacial rod", chance = 3920},
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
	{name ="melee", interval = 2000, chance = 100, minDamage = -450, maxDamage = -1350, condition = {type = CONDITION_BEWITCHED, totalDamage = 1500, interval = 4000}},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -480, maxDamage = -1750, range = 7, shootEffect = 97, effect = 454, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_DEATHDAMAGE, minDamage = -550, maxDamage = -1900, range = 7, effect = 437, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_MANADRAIN, minDamage = -600, maxDamage = -1800, radius = 4, range = 6, shootEffect = 127, effect = 442, target = true}
	}

monster.defenses = {
	defense = 100,
	armor = 80,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 5},
	{type = COMBAT_ENERGYDAMAGE, percent = -5},
	{type = COMBAT_EARTHDAMAGE, percent = -5},
	{type = COMBAT_FIREDAMAGE, percent = 40},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = 5},
	{type = COMBAT_DEATHDAMAGE , percent = 30},
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
