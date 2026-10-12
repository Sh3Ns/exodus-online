local mType = Game.createMonsterType("Zharvorin's Soulcage")
local monster = {}

monster.description = "a Zharvorin's Soulcage"
monster.experience = 0
monster.outfit = {
	lookTypeEx = 30138,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 10000
monster.maxHealth = 10000
monster.race = "undead"
monster.raceid = 1570
monster.corpse = 0
monster.speed = 0
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.events = {
	"playerAttackSound"
}

monster.summon = {
	maxSummons = 1,
	summons = {
		{name = "an eye", chance = 30, interval = 1000, count = 1},
	}
}

monster.strategiesTarget = {
	nearest = 60,
	health = 10,
	damage = 30,
	random = 0,
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
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1500, maxDamage = -3000},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_WATERDAMAGE, minDamage = -750, maxDamage = -1500, radius = 4, effect = 368, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ENERGYDAMAGE, minDamage = -550, maxDamage = -900, range = 7, shootEffect = 56, effect = 38, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_WATERDAMAGE, minDamage = -800, maxDamage = -1450, length = 8, effect = 323, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ENERGYDAMAGE, minDamage = 0, maxDamage = -1180, range = 7, shootEffect = 104, effect = 222, target = false}
	}

monster.defenses = {
	defense = 120,
	armor = 120,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
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
