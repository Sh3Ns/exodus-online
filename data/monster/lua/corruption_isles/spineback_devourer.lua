local mType = Game.createMonsterType("Spineback Devourer")
local monster = {}

monster.description = "a spineback devourer"
monster.experience = 42570
monster.outfit = {
	lookType = 1467,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 37500
monster.maxHealth = 37500
monster.race = "construct"
monster.raceid = 1426
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
	{text = "Grrrrr!", yell = false},
	{text = "Crush intruder!", yell = false},
	{text = "*angry roar*", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "small ruby", chance = 9600, maxCount = 3},
	{id = "small amethyst", chance = 17000, maxCount = 3},
	{id = "giant sword", chance = 11560},
	{id = "warrior helmet", chance = 12820},
	{id = "knight armor", chance = 9000},
	{id = "white piece of cloth", chance = 4520},
	{id = "red piece of cloth", chance = 1130},
	{id = "small topaz", chance = 17000, maxCount = 2},
	{id = "piece of redsyl ore", chance = 4000},
	{id = "redsyl crystal", chance = 4000},
	{id = "Mino Shield", chance = 18000},
	{id = "Terra Boots", chance = 8500},
	{id = "Terra Hood", chance = 4400},
	{id = "Beastslayer Axe", chance = 11500},
	{id = "Black Shield", chance = 3500},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -99, maxDamage = -999},
	{name = "combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -300, maxDamage = -1100, effect = 158, target = true},
	{name = "combat", interval = 2000, chance = 16, type = COMBAT_PHYSICALDAMAGE, minDamage = -420, maxDamage = -1350, radius = 3, effect = 184, target = true},
	{name = "combat", interval = 2000, chance = 8, type = COMBAT_PHYSICALDAMAGE, minDamage = -650, maxDamage = -1200, radius = 4, effect = 355, target = false}
}

monster.defenses = {
	defense = 105,
	armor = 110
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 20},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 30},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE, percent = -5},
	{type = COMBAT_DEATHDAMAGE, percent = 5},
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
