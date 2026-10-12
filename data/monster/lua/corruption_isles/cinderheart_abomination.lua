local mType = Game.createMonsterType("Cinderheart Abomination")
local monster = {}

monster.description = "a cinderheart abomination"
monster.experience = 46500
monster.outfit = {
	lookType = 1494,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 37000
monster.maxHealth = 37000
monster.race = "demon"
monster.raceid = 983
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
	{text = "The core burns...", yell = false},
	{text = "Molten fury!", yell = false},
	{text = "Ash and fire!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "small diamond", chance = 11800, maxCount = 4},
	{id = "orichalcum pearl", chance = 18000, maxCount = 2},
	{id = "skull helmet", chance = 1190},
	{id = "soul orb", chance = 19000},
	{id = "demonic essence", chance = 59430},
	{id = 30236, chance = 4000},
	{id = "rift bow", chance = 2500},
	{id = "concentrated demonic blood", chance = 65250},
	{id = "assassin star", chance = 19780, maxCount = 5},
	{id = "mercenary sword", chance = 5890},
	{id = "bloody edge", chance = 1480},
	{id = "unholy bone", chance = 18410},
	{id = "jade hat", chance = 2300}
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_DEATHDAMAGE, effect = 39, minDamage = -120, maxDamage = -600},
	{name ="combat", interval = 2000, chance = 80, type = COMBAT_FIREDAMAGE, minDamage = -200, maxDamage = -1100, range = 7,
	shootEffect = 131, effect = 384, target = true},
	{name ="combat", interval = 2000, chance = 16, type = COMBAT_EARTHDAMAGE, minDamage = -180, maxDamage = -1350, radius = 4,
	effect = 392, target = false},
	{name ="combat", interval = 2000, chance = 13, type = COMBAT_FIREDAMAGE, minDamage = -350, maxDamage = -1250,
	length = 5, spread = 3, effect = 216, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_DEATHDAMAGE, minDamage = -250, maxDamage = -1000, range = 5,
	effect = 326, target = true}
}

monster.defenses = {
	defense = 100,
	armor = 95
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 10},
	{type = COMBAT_ENERGYDAMAGE, percent = 5},
	{type = COMBAT_EARTHDAMAGE, percent = 30},
	{type = COMBAT_FIREDAMAGE, percent = 85},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -25},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 20},
	{type = COMBAT_WATERDAMAGE , percent = -20},
	{type = COMBAT_ARCANEDAMAGE , percent = 5}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
