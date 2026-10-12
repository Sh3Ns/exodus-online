local mType = Game.createMonsterType("Voltstrike Hound")
local monster = {}

monster.description = "a voltstrike hound"
monster.experience = 46000
monster.outfit = {
	lookType = 1487,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 38800
monster.maxHealth = 38800
monster.race = "lycanthrope"
monster.raceid = 1506
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
	{text = "Bzzzt...!", yell = false},
	{text = "Lightning consumes!", yell = false},
	{text = "Feel the storm!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "energy ring", chance = 12050},
	{id = "silver amulet", chance = 15000},
	{id = "draken boots", chance = 600},
	{id = "small sapphire", chance = 5300, maxCount = 3},
	{id = "assassin dagger", chance = 980},
	{id = "assassin star", chance = 26650, maxCount = 5},
	{id = "dragon slayer", chance = 6860},
	{id = "dragonbone staff", chance = 4000},
	{id = 30235, chance = 4000},
	{id = 30236, chance = 4000},
	{id = "war axe", chance = 8270},
	{id = "green gem", chance = 11000},
	{id = "blue gem", chance = 13920},
	{id = "yellow gem", chance = 11600},
	{id = "Skull Staff", chance = 4090},
	{id = "Grasshopper Legs", chance = 3790},
	{id = "djinn blade", chance = 5300},
	{id = "silver token", chance = 9500},
	{id = "elven mail", chance = 2000},
	{id = "demon shield", chance = 5270},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -450, maxDamage = -1050},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_ENERGYDAMAGE, minDamage = -500, maxDamage = -1100, length = 8, spread = 3, effect = 253, target = false},
	{name ="combat", interval = 2000, chance = 16, type = COMBAT_ENERGYDAMAGE, minDamage = -520, maxDamage = -1100, length = 5, spread = 3, effect = 256, target = false},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_ENERGYDAMAGE, minDamage = -650, maxDamage = -1250, radius = 3, effect = 254, target = false}
}

monster.defenses = {
	defense = 100,
	armor = 95
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 10},
	{type = COMBAT_ENERGYDAMAGE, percent = 80},
	{type = COMBAT_EARTHDAMAGE, percent = -10},
	{type = COMBAT_FIREDAMAGE, percent = 10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 20},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -5},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 10},
	{type = COMBAT_WATERDAMAGE , percent = -5},
	{type = COMBAT_ARCANEDAMAGE , percent = 25}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
