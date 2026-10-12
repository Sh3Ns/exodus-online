local mType = Game.createMonsterType("Cyclursus")
local monster = {}

monster.description = "a Cyclursus"
monster.experience = 10000
monster.outfit = {
	lookType = 1444,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 13500
monster.maxHealth = 13500
monster.race = "elemental"
monster.raceid = 1004
monster.corpse = 26691
monster.speed = 280
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
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
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = false,
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
	{id = "crystal coin", chance = 83000, maxCount = 2},
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
	{name ="melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -1110},
	{name ="combat", interval = 2000, chance = 50, type = COMBAT_ICEDAMAGE, minDamage = -360, maxDamage = -1250, length = 6, spread = 0, effect = 359, target = false},
	{name ="combat", interval = 2750, chance = 40, type = COMBAT_ICEDAMAGE, minDamage = -290, maxDamage = -1120, range = 5, shootEffect = 56, target = true},
	{name ="combat", interval = 2750, chance = 30, type = COMBAT_DEATHDAMAGE, minDamage = -720, maxDamage = -1810, range = 5, shootEffect = 69, effect = 358, target = true},
}

monster.defenses = {
	defense = 90,
	armor = 90,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 3},
	{type = COMBAT_ENERGYDAMAGE, percent = 7},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -11},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 25},
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
