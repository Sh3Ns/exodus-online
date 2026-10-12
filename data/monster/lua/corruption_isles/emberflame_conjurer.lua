local mType = Game.createMonsterType("Emberflame Conjurer")
local monster = {}

monster.description = "a emberflame conjurer"
monster.experience = 36200
monster.outfit = {
	lookType = 1482,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 35500
monster.maxHealth = 35500
monster.race = "demon"
monster.raceid = 1040
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
	{text = "Feel the flames!", yell = false},
	{text = "Burn to ashes!", yell = false},
	{text = "The fire consumes all!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "crystal sword", chance = 4710},
	{id = "glorious axe", chance = 2800},
	{id = "blue crystal splinter", chance = 14120},
	{id = "cyan crystal fragment", chance = 6050},
	{id = "guardian halberd", chance = 6560},
	{id = "tower shield", chance = 3820},
	{id = "iron ore", chance = 60000, maxCount = 3},
	{id = "small diamond", chance = 3578, maxCount = 3},
	{id = "frostpine pistil", chance = 4000},
	{id = "colybis butyraces", chance = 4000},
	{id = "small sapphire", chance = 3578, maxCount = 3},
	{id = "prismatic bolt", chance = 36500, maxCount = 5},
	{id = "crystalline arrow", chance = 34950, maxCount = 10},
	{id = "ice robe", chance = 6500},
}

monster.attacks = {
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -350, maxDamage = -1120, range = 6, shootEffect = 121, effect = 384, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_FIREDAMAGE, minDamage = -450, maxDamage = -1150, range = 7, radius = 3, effect = 216, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_ENERGYDAMAGE, minDamage = -500, maxDamage = -1200, length = 5, spread = 3, effect = 396, target = false}
}

monster.defenses = {
	defense = 80,
	armor = 75
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 10},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 70},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -20},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 10},
	{type = COMBAT_WATERDAMAGE , percent = -10},
	{type = COMBAT_ARCANEDAMAGE , percent = 5}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
