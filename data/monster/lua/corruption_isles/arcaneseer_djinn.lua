local mType = Game.createMonsterType("Arcaneseer Djinn")
local monster = {}

monster.description = "a arcaneseer djinn"
monster.experience = 45000
monster.outfit = {
	lookType = 1483,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 31500
monster.maxHealth = 31500
monster.race = "demon"
monster.raceid = 898
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
	{text = "The currents obey me.", yell = false},
	{text = "Your fate is already written.", yell = false},
	{text = "Arcane power flows!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "falcon circlet", chance = 900},
	{id = "gnome legs", chance = 2000},
	{id = "toga mortis", chance = 700},
	{id = "bear skin", chance = 1100},
	{id = "small sapphire", chance = 8000, maxCount = 4},
	{id = "giant sapphire", chance = 2000},
	{id = "dwarven legs", chance = 900},
	{id = "fractured verdant crystal", chance = 7000},
	{id = "crystallized verdant crystal", chance = 4000},
	{id = "verdant crystal essence", chance = 2000},
	{id = "golden boots", chance = 1100},
	{id = "naga rod", chance = 1500},
	{id = "naga wand", chance = 1500},
}

monster.attacks = {
	{name ="combat", interval = 2000, chance = 100, type = COMBAT_ARCANEDAMAGE, minDamage = -350, maxDamage = -1280, range = 7, shootEffect = 127, effect = 386, target = true},
	{name ="combat", interval = 2000, chance = 24, type = COMBAT_ICEDAMAGE, minDamage = -420, maxDamage = -920, range = 6, shootEffect = 126, effect = 398, target = true},
	{name ="combat", interval = 2000, chance = 18, type = COMBAT_ARCANEDAMAGE, minDamage = -520, maxDamage = -1200, radius = 3, effect = 312, target = false}
}

monster.defenses = {
	defense = 95,
	armor = 90
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 20},
	{type = COMBAT_EARTHDAMAGE, percent = 10},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 20},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 40},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 10},
	{type = COMBAT_WATERDAMAGE , percent = 50},
	{type = COMBAT_ARCANEDAMAGE , percent = 35}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
