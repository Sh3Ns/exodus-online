local mType = Game.createMonsterType("Stormfang Ravager")
local monster = {}

monster.description = "a stormfang ravager"
monster.experience = 46500
monster.outfit = {
	lookType = 1488,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 37800
monster.maxHealth = 37800
monster.race = "lycanthrope"
monster.raceid = 1436
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
	{text = "The storm hunts you!", yell = false},
	{text = "Lightning strikes!", yell = false},
	{text = "You cannot escape the storm!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "Small Diamond", chance = 20000, maxCount = 7},
	{id = "Small Topaz", chance = 20000, maxCount = 7},
	{id = "Ornate Chestplate", chance = 1200},
	{id = "Wyvern Fang", chance = 8600},
	{id = "Diamond Sceptre", chance = 5600},
	{id = "Sai", chance = 3050},
	{id = "Stone Skin Amulet", chance = 19050},
	{id = "Sacred Tree Amulet", chance = 6350},
	{id = 30264, chance = 4000},
	{id = "solvex prism", chance = 4000},
	{id = "Swamplair Armor", chance = 1950},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -420, maxDamage = -1120, range = 5, shootEffect = 120, effect = 377, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -420, maxDamage = -900, range = 6, shootEffect = 126, effect = 256, target = true},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_ENERGYDAMAGE, minDamage = -650, maxDamage = -1250, radius = 3, effect = 397, target = false}
}

monster.defenses = {
	defense = 110,
	armor = 105
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 85},
	{type = COMBAT_EARTHDAMAGE, percent = -15},
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
