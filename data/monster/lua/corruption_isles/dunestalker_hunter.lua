local mType = Game.createMonsterType("Dunestalker Hunter")
local monster = {}

monster.description = "a dunestalker hunter"
monster.experience = 48000
monster.outfit = {
	lookType = 1489,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 42000
monster.maxHealth = 42000
monster.race = "lycanthrope"
monster.raceid = 1027
monster.corpse = 26691
monster.speed = 500
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 100,
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
	canWalkOnPoison = true
}

monster.light = {
	level = 0,
	color = 0
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{text = "The sands claim you!", yell = false},
	{text = "You cannot escape the hunt!", yell = false},
	{text = "The desert watches...", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "golden legs", chance = 1950},
	{id = "giant ruby", chance = 1300},
	{id = "giant sapphire", chance = 2300},
	{id = "giant emerald", chance = 2300},
	{id = "skull staff", chance = 6350},
	{id = "grimwood pistil", chance = 4000},
	{id = "duskwillow pistil", chance = 4000},
	{id = "gold token", chance = 2700},
	{id = "gold ingot", chance = 24400},
	{id = "ice robe", chance = 6500},
	{id = "silver token", chance = 34500, maxCount = 2},
	{id = "amulet of loss", chance = 1900},
	{id = "sliver", chance = 4000, maxCount = 3},
	{id = "dust", chance = 8000, maxCount = 3}
}

monster.attacks = {
	{name ="combat", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -450, maxDamage = -1380, range = 6, shootEffect = 80, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -450, maxDamage = -980, radius = 3, effect = 389, target = false},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_PHYSICALDAMAGE, minDamage = -600, maxDamage = -1200, range = 7, shootEffect = 54, effect = 268, target = false}
}

monster.defenses = {
	defense = 105,
	armor = 100
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 20},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 35},
	{type = COMBAT_FIREDAMAGE, percent = 10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -10},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 5},
	{type = COMBAT_WATERDAMAGE , percent = -5},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
