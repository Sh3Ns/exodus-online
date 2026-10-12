local mType = Game.createMonsterType("Moonspawn Blightspitter")
local monster = {}

monster.description = "a Moonspawn Blightspitter"
monster.experience = 33700
monster.outfit = {
	lookType = 1558,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 35000
monster.maxHealth = 35000
monster.race = "plant"
monster.raceid = 2194
monster.corpse = 26691
monster.speed = 400
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 60,
	health = 10,
	damage = 30,
	random = 0,
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
	canWalkOnPoison = true,
	pet = false
}

monster.light = {
	level = 0,
	color = 0
}

monster.voices = {
	interval = 7000,
	chance = 30,
	{text = "<Splorch>", yell = true},
	{text = "<Slushhhh>", yell = true},
	{text = "<Glrrrkk>", yell = true}
}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "mushroom pie", chance = 7100},
	{id = "terra amulet", chance = 5200},
	{id = "green gem", chance = 2900},
	{id = "terra legs", chance = 2900},
	{id = "green mushroom", chance = 2300},
	{id = "terra boots", chance = 2300},
	{id = "terra mantle", chance = 1700},
	{id = "muck rod", chance = 1700},
	{id = "moonstone", chance = 1100},
	{id = "mushroom backpack", chance = 570},
	{id = "moonspawn tentacle", chance = 5000},
	{id = "moonspawn headpiece", chance = 4500}
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -540, maxDamage = -1910},
	{name ="combat", interval = 2000, chance = 50, type = COMBAT_EARTHDAMAGE, minDamage = -660, maxDamage = -1950, length = 6, spread = 0, effect = 423, target = false},
	{name ="combat", interval = 2750, chance = 40, type = COMBAT_DEATHDAMAGE, minDamage = -290, maxDamage = -1720, range = 5, shootEffect = 137, target = true},
	{name ="combat", interval = 2750, chance = 30, type = COMBAT_DEATHDAMAGE, minDamage = -720, maxDamage = -1810, range = 5, shootEffect = 144, effect = 441, target = true},
	}

monster.defenses = {
	defense = 100,
	armor = 80,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = -5},
	{type = COMBAT_ENERGYDAMAGE, percent = 15},
	{type = COMBAT_EARTHDAMAGE, percent = 25},
	{type = COMBAT_FIREDAMAGE, percent = -12},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = -2},
	{type = COMBAT_DEATHDAMAGE , percent = 15},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = -6}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
