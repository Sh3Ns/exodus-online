local mType = Game.createMonsterType("Brood Abomination")
local monster = {}

monster.description = "a brood abomination"
monster.experience = 37000
monster.outfit = {
	lookType = 1472,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 33000
monster.maxHealth = 33000
monster.race = "mammal"
monster.raceid = 966
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
	targetDistance = 1,
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
	{text = "Flesh... more flesh...", yell = false},
	{text = "You will feed the brood.", yell = false},
	{text = "*wet chittering*", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "brown mushroom", chance = 56120, maxCount = 9},
	{id = "fire axe", chance = 21400},
	{id = "honeycomb", chance = 5000, maxCount = 2},
	{id = "ivory comb", chance = 10200},
	{id = "mercenary sword", chance = 11050},
	{id = "haunted blade", chance = 9960},
	{id = 30235, chance = 4000},
	{id = "warrior's axe", chance = 7300},
	{id = "twiceslicer", chance = 5000},
	{id = "ornate crossbow", chance = 5920},
	{id = "warrior helmet", chance = 11920},
	{id = "goblin essence", chance = 6000, maxCount = 3},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, effect = 307, minDamage = -480, maxDamage = -780},
	{name = "combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -400, maxDamage = -950, range = 6, shootEffect = 113, effect = 342, target = true},
	{name = "combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -420, maxDamage = -850, radius = 3, effect = 169, target = true},
	{name = "combat", interval = 2000, chance = 10, type = COMBAT_ENERGYDAMAGE, minDamage = -600, maxDamage = -1200, radius = 2, effect = 257, target = false}
}

monster.defenses = {
	defense = 100,
	armor = 95
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 10},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 80},
	{type = COMBAT_FIREDAMAGE, percent = -15},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE, percent = -5},
	{type = COMBAT_DEATHDAMAGE, percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 10},
	{type = COMBAT_ARCANEDAMAGE, percent = 0}
}


monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
