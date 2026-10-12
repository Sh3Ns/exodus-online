local mType = Game.createMonsterType("Dreadhorn Ravager")
local monster = {}

monster.description = "a dreadhorn ravager"
monster.experience = 48000
monster.outfit = {
	lookType = 1486,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 37500
monster.maxHealth = 37500
monster.race = "lycanthrope"
monster.raceid = 1021
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
	{text = "Your bones will break!", yell = false},
	{text = "Crush... destroy!", yell = false},
	{text = "The hunt begins!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "violet gem", chance = 74560},
	{id = "spellbook of warding", chance = 18920},
	{id = "underworld rod", chance = 31920},
	{id = 30238, chance = 4000},
	{id = "springsprout rod", chance = 28920},
	{id = "gold ingot", chance = 54560},
	{id = "glacial rod", chance = 9560},
	{id = "green gem", chance = 64560},
	{id = "stone skin amulet", chance = 31920},
	{id = "platinum amulet", chance = 13920},
	{id = "sacred tree amulet", chance = 9920},
	{id = "exalted core", chance = 3000},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_DEATHDAMAGE, minDamage = -700, maxDamage = -1000},
	{name ="combat", interval = 2000, chance = 18, type = COMBAT_PHYSICALDAMAGE, minDamage = -380, maxDamage = -1320, range = 5, shootEffect = 107, effect = 370, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_PHYSICALDAMAGE, minDamage = -520, maxDamage = -1100, radius = 3, effect = 338, target = false},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_DEATHDAMAGE, minDamage = -650, maxDamage = -1250, length = 4, spread = 3, effect = 358, target = false}
}

monster.defenses = {
	defense = 115,
	armor = 125
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 30},
	{type = COMBAT_ENERGYDAMAGE, percent = 10},
	{type = COMBAT_EARTHDAMAGE, percent = 10},
	{type = COMBAT_FIREDAMAGE, percent = 5},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -5},
	{type = COMBAT_HOLYDAMAGE , percent = -10},
	{type = COMBAT_DEATHDAMAGE , percent = 25},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 5}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
