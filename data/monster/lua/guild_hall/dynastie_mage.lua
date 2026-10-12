local mType = Game.createMonsterType("Dynasty Mage")
local monster = {}

monster.description = "a dynastie mage"
monster.experience = 0
monster.outfit = {
	lookType = 1516,
	lookHead = 114,
	lookBody = 114,
	lookLegs = 94,
	lookFeet = 95,
	lookAddons = 0,
	lookMount = 0,
	lookWings = 0,
	lookAura = 0,
	lookShader = 0
}

monster.health = 3000
monster.maxHealth = 3000
monster.race = "human"
monster.raceid = 1032
monster.corpse = 0
monster.speed = 450
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 0
}

monster.events = {
	"playerAttackSound"
}

monster.strategiesTarget = {
	nearest = 70,
	health = 30
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
	staticAttackChance = 85,
	targetDistance = 2,
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
	{name ="melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -70},
	{name ="combat", interval = 2200, chance = 42, type = COMBAT_ENERGYDAMAGE, minDamage = -170, maxDamage = -300, range = 4, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYHIT, target = true},
	{name ="combat", interval = 2600, chance = 24, type = COMBAT_FIREDAMAGE, minDamage = -140, maxDamage = -260, radius = 2, effect = CONST_ME_FIREAREA, target = true},
	{name ="combat", interval = 3200, chance = 14, type = COMBAT_ICEDAMAGE, minDamage = -150, maxDamage = -240, length = 4, spread = 3, effect = CONST_ME_ICEAREA, target = false}
}

monster.defenses = {
	defense = 20,
	armor = 18
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 15},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
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
