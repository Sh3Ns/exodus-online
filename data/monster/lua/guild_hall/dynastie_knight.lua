local mType = Game.createMonsterType("Dynasty Knight")
local monster = {}

monster.description = "a dynastie knight"
monster.experience = 0
monster.outfit = {
	lookType = 1514,
	lookHead = 114,
	lookBody = 95,
	lookLegs = 114,
	lookFeet = 95,
	lookAddons = 0,
	lookMount = 0,
	lookWings = 0,
	lookAura = 0,
	lookShader = 0
}

monster.health = 4800
monster.maxHealth = 4800
monster.race = "human"
monster.raceid = 1031
monster.corpse = 0
monster.speed = 450
monster.manaCost = 0

monster.changeTarget = {
	interval = 5000,
	chance = 0
}

monster.events = {
	"playerAttackSound"
}

monster.strategiesTarget = {
	nearest = 100
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
	chance = 8
}

monster.loot = {}

monster.attacks = {
	{name ="melee", interval = 1800, chance = 100, minDamage = 0, maxDamage = -260},
	{name ="combat", interval = 2600, chance = 22, type = COMBAT_PHYSICALDAMAGE, minDamage = -180, maxDamage = -280, radius = 1, effect = CONST_ME_HITAREA, target = false},
	{name ="combat", interval = 3200, chance = 16, type = COMBAT_PHYSICALDAMAGE, minDamage = -140, maxDamage = -230, length = 3, spread = 0, effect = CONST_ME_DRAWBLOOD, target = false}
}

monster.defenses = {
	defense = 38,
	armor = 34
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 8},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 10},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE, percent = 0},
	{type = COMBAT_DEATHDAMAGE, percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = false},
	{type = "bleed", condition = false}
}

mType:register(monster)
