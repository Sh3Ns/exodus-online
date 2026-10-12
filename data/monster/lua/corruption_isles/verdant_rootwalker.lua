local mType = Game.createMonsterType("Verdant Rootwalker")
local monster = {}

monster.description = "a verdant rootwalker"
monster.experience = 45000
monster.outfit = {
	lookType = 1484,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 39500
monster.maxHealth = 39500
monster.race = "plant"
monster.raceid = 1498
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
	{text = "The forest awakens...", yell = false},
	{text = "Roots will claim you.", yell = false},
	{text = "Return to the soil.", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "energy ring", chance = 19050},
	{id = "silver amulet", chance = 65000},
	{id = "axe ring", chance = 47220},
	{id = "power ring", chance = 46080},
	{id = "life ring", chance = 49560},
	{id = 30238, chance = 4000},
	{id = "grimwood pistil", chance = 4000},
	{id = "energy ring", chance = 12050},
	{id = "stone skin amulet", chance = 8600},
	{id = "necklace of the deep", chance = 3800},
	{id = "Rainbow Quartz", chance = 2000},
	{id = "Noble Axe", chance = 4700},
	{id = "Zaoan armor", chance = 2050},
	{id = "Zaoan shoes", chance = 8150},
	{id = "Zaoan legs", chance = 3325},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -500, maxDamage = -2000},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -350, maxDamage = -1450, range = 6, shootEffect = 55, effect = 315, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -450, maxDamage = -1280, radius = 3, effect = 235, target = false},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_LIFEDRAIN, minDamage = -550, maxDamage = -1200, length = 5, spread = 3, effect = 274, target = false}
}

monster.defenses = {
	defense = 115,
	armor = 120
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 20},
	{type = COMBAT_ENERGYDAMAGE, percent = -5},
	{type = COMBAT_EARTHDAMAGE, percent = 80},
	{type = COMBAT_FIREDAMAGE, percent = -20},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 20},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
