local mType = Game.createMonsterType("Ancient Root Tyrant")
local monster = {}

monster.description = "a ancient root tyrant"
monster.experience = 45000
monster.outfit = {
	lookType = 1485,
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
monster.raceid = 855
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
	{text = "The forest will reclaim you.", yell = false},
	{text = "You trespass sacred soil.", yell = false},
	{text = "Roots... will devour you.", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "giant sword", chance = 60000},
	{id = "falcon longsword", chance = 800},
	{id = "mercenary sword", chance = 10000},
	{id = "relic sword", chance = 7000},
	{id = "demonrage sword", chance = 2800},
	{id = "zaoan sword", chance = 3000},
	{id = "zaoan helmet", chance = 3000},
	{id = "zaoan armor", chance = 2700},
	{id = "zaoan legs", chance = 2400},
	{id = "twilight bloom flower", chance = 4000},
	{id = "moonsang cocoon silk", chance = 4000},
	{id = "zaoan shoes", chance = 9100},
	{id = "old stick", chance = 4000, maxCount = 2},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_EARTHDAMAGE, effect = 365, minDamage = -200, maxDamage = -1600},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -400, maxDamage = -850, range = 6, shootEffect = 124, effect = 362, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -520, maxDamage = -1100, radius = 3, effect = 315, target = false},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_LIFEDRAIN, minDamage = -650, maxDamage = -1250, length = 5, spread = 3, effect = 331, target = false}
}

monster.defenses = {
	defense = 120,
	armor = 135
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 25},
	{type = COMBAT_ENERGYDAMAGE, percent = -5},
	{type = COMBAT_EARTHDAMAGE, percent = 90},
	{type = COMBAT_FIREDAMAGE, percent = -25},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 15},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 25},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
