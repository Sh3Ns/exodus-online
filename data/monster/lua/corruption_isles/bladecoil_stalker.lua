local mType = Game.createMonsterType("Bladecoil Stalker")
local monster = {}

monster.description = "a bladecoil stalker"
monster.experience = 39000
monster.outfit = {
	lookType = 1481,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 34500
monster.maxHealth = 34500
monster.race = "construct"
monster.raceid = 931
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
	{text = "Target locked.", yell = false},
	{text = "Cutting protocol engaged.", yell = false},
	{text = "Intruder detected.", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "Spiked Squelcher", chance = 6200},
	{id = "Knight Armor", chance = 21980},
	{id = "Knight Legs", chance = 18000},
	{id = "War Axe", chance = 14230},
	{id = "Violet Gem", chance = 5060},
	{id = "Small Amethyst", chance = 9060, maxCount = 8},
	{id = "Small Topaz", chance = 7000, maxCount = 8},
	{id = "Small Emerald", chance = 5000, maxCount = 8},
	{id = "Green Gem", chance = 64880, maxCount = 2},
	{id = "Golden Armor", chance = 2240},
	{id = 30233, chance = 4000},
	{id = "Mastermind Shield", chance = 920},
	{id = "emerald bangle", chance = 3950},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, effect = 393, minDamage = -320, maxDamage = -1000},
	{name ="combat", interval = 2000, chance = 18, type = COMBAT_PHYSICALDAMAGE, minDamage = -320, maxDamage = -1680, range = 5, shootEffect = 98, effect = 355, target = true},
	{name ="combat", interval = 2000, chance = 14, type = COMBAT_ENERGYDAMAGE, minDamage = -400, maxDamage = -1100, length = 5, spread = 3, effect = 204, target = false},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_PHYSICALDAMAGE, minDamage = -550, maxDamage = -1150, radius = 3, effect = 244, target = false}
}

monster.defenses = {
	defense = 100,
	armor = 105
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 20},
	{type = COMBAT_ENERGYDAMAGE, percent = 15},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 5},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 10}
}


monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
