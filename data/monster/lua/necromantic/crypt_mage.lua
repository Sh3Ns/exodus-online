local mType = Game.createMonsterType("Crypt Mage")
local monster = {}

monster.description = "a Crypt Mage"
monster.experience = 11000
monster.outfit = {
	lookType = 1449,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 14000
monster.maxHealth = 14000
monster.race = "giant"
monster.raceid = 998
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
	targetDistance = 3,
	runHealth = 2000,
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
	interval = 5000,
	chance = 10,
}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "runic claw", chance = 7100},
	{id = "frostbone shard", chance = 4000},
	{id = "vorsk scale", chance = 2800},
	{id = "azure crystal fragment", chance = 1900},
	{id = "venerable cloth", chance = 900},
	{id = "eviscerated eye", chance = 1000},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -150, maxDamage = -450, condition = {type = CONDITION_POISON, totalDamage = 1240, interval = 4000}},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_LIFEDRAIN, minDamage = -480, maxDamage = -1150, range = 7, shootEffect = 99, effect = 244, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ICEDAMAGE, minDamage = -550, maxDamage = -900, range = 7, effect = 282, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_MANADRAIN, minDamage = -400, maxDamage = -1500, radius = 4, range = 6, shootEffect = 111, effect = 350, target = true}
	}

monster.defenses = {
	defense = 90,
	armor = 90,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = -14},
	{type = COMBAT_ENERGYDAMAGE, percent = -6},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 15},
	{type = COMBAT_HOLYDAMAGE , percent = 12},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = -10},
	{type = COMBAT_ARCANEDAMAGE , percent = -30}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
