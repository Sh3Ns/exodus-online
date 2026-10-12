local mType = Game.createMonsterType("Blacksteel Brute")
local monster = {}

monster.description = "a blacksteel brute"
monster.experience = 42570
monster.outfit = {
	lookType = 1466,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 37500
monster.maxHealth = 37500
monster.race = "humanoid"
monster.raceid = 930
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
	{text = "Your head will roll!", yell = false},
	{text = "Stand and fight!", yell = false},
	{text = "I'll cleave you in two!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "amulet of loss", chance = 420},
	{id = "gold ring", chance = 1870},
	{id = "hailstorm rod", chance = 10000},
	{id = "crown armor", chance = 2000},
	{id = "crown shield", chance = 3000},
	{id = "crown helmet", chance = 4000},
	{id = "blank rune", chance = 26250, maxCount = 2},
	{id = "golden sickle", chance = 1350},
	{id = "skull staff", chance = 5520},
	{id = "scythe", chance = 13000},
	{id = "soul orb", chance = 53720},
	{id = "terra mantle", chance = 4050},
	{id = 30232, chance = 4000},
	{id = "terra legs", chance = 3500},
	{id = "gold ingot", chance = 11270},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, effect = CONST_ME_DRAWBLOOD, minDamage = -520, maxDamage = -520},
	{name = "combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -320, maxDamage = -1250, range = 5, shootEffect = 26, effect = 265, target = true},
	{name = "combat", interval = 2000, chance = 15, type = COMBAT_HOLYDAMAGE, minDamage = -400, maxDamage = -1100, radius = 3, effect = 269, target = false},
	{name = "combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -550, maxDamage = -1200, length = 4, spread = 3, effect = 206, target = false}
}

monster.defenses = {
	defense = 110,
	armor = 115
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 25},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -5},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 10},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}


monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
