local mType = Game.createMonsterType("Night Harpy")
local monster = {}

monster.description = "a Night Harpy"
monster.experience = 16000
monster.outfit = {
	lookType = 1450,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 14000
monster.maxHealth = 14000
monster.race = "elemental"
monster.raceid = 1297
monster.corpse = 26691
monster.speed = 400
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.events = {
	"playerAttackSound"
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
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
	interval = 5000,
	chance = 10,
}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "runic claw", chance = 7100},
	{id = "frostbone shard", chance = 4000},
	{id = "vorsk scale", chance = 2800},
	{id = "azure crystal fragment", chance = 1900},
	{id = "venerable cloth", chance = 900},
	{id = "eviscerated eye", chance = 1000},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -400, maxDamage = -1200},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_PHYSICALDAMAGE, minDamage = -650, maxDamage = -900, range = 6, radius = 3, shootEffect = 81, effect = 371, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_FIREDAMAGE, minDamage = -400, maxDamage = -650, range = 1, effect = 361, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_PHYSICALDAMAGE, minDamage = -375, maxDamage = -700, range = 5, shootEffect = 77, target = false},
	{name ="condition", type = CONDITION_BLEEDING, interval = 2000, chance = 10, minDamage = -320, maxDamage = -960, radius = 6, effect = 208, target = false}
}

monster.defenses = {
	defense = 110,
	armor = 110,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 20},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 4},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -11},
	{type = COMBAT_HOLYDAMAGE , percent = -6},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
