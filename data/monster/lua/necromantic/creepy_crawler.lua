local mType = Game.createMonsterType("Creepy Crawler")
local monster = {}

monster.description = "a Creepy Crawler"
monster.experience = 23000
monster.outfit = {
	lookType = 1451,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 27000
monster.maxHealth = 27000
monster.race = "elemental"
monster.raceid = 995
monster.corpse = 26691
monster.speed = 280
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
	{name ="melee", interval = 2000, chance = 100, minDamage = -111, maxDamage = -1111},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ICEDAMAGE, minDamage = -400, maxDamage = -1320, range = 7, shootEffect = 110, target = false},
	{name ="condition", type = CONDITION_FREEZING, interval = 2000, chance = 10, minDamage = -330, maxDamage = -1600, radius = 3, effect = 237, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_ICEDAMAGE, minDamage = -290, maxDamage = -1300, length = 5, spread = 2, effect = 323, target = false}
}

monster.defenses = {
	defense = 95,
	armor = 95,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 24},
	{type = COMBAT_ENERGYDAMAGE, percent = -10},
	{type = COMBAT_EARTHDAMAGE, percent = -6},
	{type = COMBAT_FIREDAMAGE, percent = -30},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 45},
	{type = COMBAT_HOLYDAMAGE , percent = -11},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 100},
	{type = COMBAT_ARCANEDAMAGE , percent = -10}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
