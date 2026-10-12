local mType = Game.createMonsterType("Dynasty Paladin")
local monster = {}

monster.description = "a dynastie paladin"
monster.experience = 0
monster.outfit = {
	lookType = 1515,
	lookHead = 114,
	lookBody = 94,
	lookLegs = 114,
	lookFeet = 114,
	lookAddons = 0,
	lookMount = 0,
	lookWings = 0,
	lookAura = 0,
	lookShader = 0
}

monster.health = 3500
monster.maxHealth = 3500
monster.race = "human"
monster.raceid = 1033
monster.corpse = 0
monster.speed = 450
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 0
}

monster.strategiesTarget = {
	nearest = 100
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
	staticAttackChance = 85,
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
	chance = 8
}

monster.loot = {}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -120},
	{name ="combat", interval = 2200, chance = 45, type = COMBAT_PHYSICALDAMAGE, minDamage = -140, maxDamage = -240, range = 5, shootEffect = CONST_ANI_ARROW, target = true},
	{name ="combat", interval = 2400, chance = 28, type = COMBAT_HOLYDAMAGE, minDamage = -180, maxDamage = -320, range = 4, shootEffect = CONST_ANI_FLASHARROW, effect = CONST_ME_HOLYDAMAGE, target = true}
}

monster.defenses = {
	defense = 28,
	armor = 26
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 10},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE, percent = 25},
	{type = COMBAT_DEATHDAMAGE, percent = -5}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = false},
	{type = "bleed", condition = false}
}

mType:register(monster)
