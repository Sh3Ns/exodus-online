local mType = Game.createMonsterType("Paradox")
local monster = {}

monster.description = "a Paradox"
monster.experience = 0
monster.outfit = {
	lookType = 128,
	lookHead = 76,
	lookBody = 57,
	lookLegs = 76,
	lookFeet = 95,
	lookAddons = 2,
	lookMount = 0
}


monster.health = 8000
monster.maxHealth = 8000
monster.race = "undead"
monster.raceid = 1317
monster.corpse = 0
monster.speed = 500

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 100,
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
	targetDistance = 4,
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

}

monster.loot = {
	
}

monster.attacks = {
	{name ="combat", interval = 2000, chance = 100, type = COMBAT_ARCANEDAMAGE, minDamage = -110, maxDamage = -530, range = 7, shootEffect = 127, target = true},
	{name ="combat", interval = 6000, chance = 12, type = COMBAT_WATERDAMAGE, minDamage = -160, maxDamage = -585, range = 7, shootEffect = 122, target = true},
	{name ="combat", interval = 4000, chance = 10, type = COMBAT_EARTHDAMAGE, minDamage = -160, maxDamage = -545, range = 7, effect = 390, shootEffect = 118, target = true},
	{name = "speed", chance = 15, interval = 2*1000, speed = -400, radius = 1, target = true, duration = 30*1000, effect = CONST_ME_MAGIC_RED},
}

monster.defenses = {
	defense = 50,
	armor = 82
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 33},
	{type = COMBAT_ENERGYDAMAGE, percent = 33},
	{type = COMBAT_EARTHDAMAGE, percent = 33},
	{type = COMBAT_FIREDAMAGE, percent = 33},
	{type = COMBAT_LIFEDRAIN, percent = 33},
	{type = COMBAT_MANADRAIN, percent = 33},
	{type = COMBAT_DROWNDAMAGE, percent = 33},
	{type = COMBAT_ICEDAMAGE, percent = 33},
	{type = COMBAT_HOLYDAMAGE , percent = 33},
	{type = COMBAT_DEATHDAMAGE , percent = 33}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
