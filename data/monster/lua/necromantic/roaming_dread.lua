local mType = Game.createMonsterType("Roaming Dread")
local monster = {}

monster.description = "a Roaming Dread"
monster.experience = 18000
monster.outfit = {
	lookType = 1448,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 25000
monster.maxHealth = 25000
monster.race = "giant"
monster.raceid = 1348
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
	{name ="melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -730},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ENERGYDAMAGE, minDamage = 0, maxDamage = -900, range = 7, radius = 6, shootEffect = 103, effect = 8, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ICEDAMAGE, minDamage = -300, maxDamage = -1100, range = 7, radius = 6, shootEffect = 102, effect = 43, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ENERGYDAMAGE, minDamage = -400, maxDamage = -950, length = 5, spread = 3, effect = 35, target = false},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_MANADRAIN, minDamage = -600, maxDamage = -1200, radius = 5, effect = 48, target = false}
	}

monster.defenses = {
	defense = 110,
	armor = 110,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 13},
	{type = COMBAT_EARTHDAMAGE, percent = 4},
	{type = COMBAT_FIREDAMAGE, percent = -28},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 9},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = -18},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
