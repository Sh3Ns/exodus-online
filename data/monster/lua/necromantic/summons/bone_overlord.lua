local mType = Game.createMonsterType("Bone Overlord")
local monster = {}

monster.description = "a Bone Overlord"
monster.experience = 0
monster.outfit = {
	lookTypeEx = 30109,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 10000000
monster.maxHealth = 10000000
monster.race = "undead"
monster.raceid = 948
monster.corpse = 0
monster.speed = 0
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

monster.flags = {
	summonable = false,
	attackable = false,
	hostile = false,
	convinceable = false,
	pushable = false,
	rewardBoss = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = true,
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
	chance = 100,
	{text = "MY RULE OVER LIFE AND DEATH WILL BE UNCHALLENGED!", yell = true},
	{text = "MY VICTORY WILL BE GLORIOUS!", yell = true},
	{text = "YOU SHORT LIVED VESSELS OF DEATH WILL ONLY FUEL MY POWER!", yell = true},
	{text = "BEHOLD THE LAST OF THE TRUE BONELORDS!", yell = true},
	{text = "YOU PUNY CREATURES CAN'T STOP ME!", yell = true},
	{text = "I WILL BECOME A 001!", yell = true},
	{text = "I DEATH YOU WILL BECOME MY PUPPETS!", yell = true},
	{text = "BY THE ELDRITCH POWERS THAT I COMMAND - I WILL CRUSH YOU!", yell = true},
	{text = "THE SOULS ARE MINE!", yell = true},
	{text = "I DON'T NEED THE SHIRON'FAL!", yell = true},
	{text = "DEATH AWAITS THOSE WHO DEFY ME!", yell = true},
	{text = "YOU ONLY DELAY THE INNEVITABLE!", yell = true},
	{text = "ALL DRAGON SOULS BELONG TO ME!", yell = true},
	{text = "ALL OF THIS IS ONLY A MINOR SETBACK!", yell = true},
	{text = "IN THE END VICTORY WILL BE MINE NONTHELESS!", yell = true},
}

monster.loot = {
}

monster.attacks = {

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
