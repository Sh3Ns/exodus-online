local mType = Game.createMonsterType("Cursed Voidcaller")
local monster = {}

monster.description = "a cursed voidcaller"
monster.experience = 39000
monster.outfit = {
	lookType = 1478,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 36000
monster.maxHealth = 36000
monster.race = "elemental"
monster.raceid = 1002
monster.corpse = 26691
monster.speed = 500
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 100,
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
	canWalkOnPoison = true
}

monster.light = {
	level = 0,
	color = 0
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{text = "Hehehe... another test subject!", yell = false},
	{text = "Magic will tear you apart!", yell = false},
	{text = "You cannot comprehend my power!", yell = false},
	{text = "The arcane answers only to me!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "brown mushroom", chance = 56120, maxCount = 6},
	{id = "violet gem", chance = 44560},
	{id = "giant sword", chance = 20000},
	{id = "crystal mace", chance = 15000},
	{id = "crown shield", chance = 11920},
	{id = "jade hammer", chance = 9920},
	{id = "tower shield", chance = 20740},
	{id = "skull helmet", chance = 3000},
	{id = 30237, chance = 4000},
	{id = "titanium bar", chance = 3000},
	{id = "venerable cloth", chance = 3000},
	{id = "piece of cryth ore", chance = 3000},
	{id = "piece of drazium ore" , chance = 3000},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_ARCANEDAMAGE, effect = 288, minDamage = -320, maxDamage = -1000},
	{name = "combat", interval = 2000, chance = 25, type = COMBAT_ARCANEDAMAGE, minDamage = -320, maxDamage = -700, range = 7, shootEffect = 125, effect = 393, target = true},
	{name = "combat", interval = 2000, chance = 18, type = COMBAT_DEATHDAMAGE, minDamage = -400, maxDamage = -1350, range = 7, shootEffect = 32, effect = 158, target = true},
	{name = "combat", interval = 2000, chance = 10, type = COMBAT_ARCANEDAMAGE, minDamage = -600, maxDamage = -1200, radius = 3, effect = 291, target = false}
}

monster.defenses = {
	defense = 90,
	armor = 80
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 10},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 20},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -10},
	{type = COMBAT_HOLYDAMAGE, percent = -20},
	{type = COMBAT_DEATHDAMAGE, percent = 35},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = 40}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
