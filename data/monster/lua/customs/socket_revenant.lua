local mType = Game.createMonsterType("Socket Revenant")
local monster = {}

monster.description = "a socket revenant"
monster.experience = 0
monster.outfit = {
	lookType = 1524,
	lookHead = 77,
	lookBody = 80,
	lookLegs = 84,
	lookFeet = 94,
	lookAddons = 3,
	lookMount = 0
}

monster.health = 2500
monster.maxHealth = 2500
monster.race = "undead"
monster.raceid = 1417
monster.corpse = 0
monster.speed = 260
monster.manaCost = 0
monster.maxSummons = 0
monster.runHealth = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = false,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = false,
	pet = false
}

monster.events = {
	"playerAttackSound"
}

monster.voices = {}
monster.loot = {}

monster.attacks = {
	{name = "melee", interval = 1500, chance = 100, minDamage = -90, maxDamage = -230},
	{name = "combat", interval = 2000, chance = 20, type = COMBAT_DEATHDAMAGE, minDamage = -120, maxDamage = -360, range = 5, shootEffect = CONST_ANI_SUDDENDEATH, effect = CONST_ME_MORTAREA, target = true},
	{name = "combat", interval = 2500, chance = 15, type = COMBAT_LIFEDRAIN, minDamage = -110, maxDamage = -320, radius = 2, effect = CONST_ME_SMALLCLOUDS, target = true}
}

monster.defenses = {
	defense = 60,
	armor = 60
}

monster.elements = {
	{type = COMBAT_DEATHDAMAGE, percent = 70},
	{type = COMBAT_HOLYDAMAGE, percent = -20}
}

monster.immunities = {
	{type = "invisible", condition = true}
}

mType:register(monster)
