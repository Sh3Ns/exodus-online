local mType = Game.createMonsterType("Venomcoil Automaton")
local monster = {}

monster.description = "a venomcoil automaton"
monster.experience = 42000
monster.outfit = {
	lookType = 1480,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 35500
monster.maxHealth = 35500
monster.race = "construct"
monster.raceid = 1497
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
	{text = "System purge: organic detected.", yell = false},
	{text = "Injecting venom protocol.", yell = false},
	{text = "Target immobilization engaged.", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "dragon scale mail", chance = 1570},
	{id = "royal helmet", chance = 3500},
	{id = "tower shield", chance = 8350},
	{id = "auralis bloom", chance = 4000},
	{id = "psyliota arvensis", chance = 4000},
	{id = "power bolt", chance = 9700, maxCount = 7},
	{id = "violet gem", chance = 24002},
	{id = "umbrabloom wood", chance = 3000},
	{id = "bloodwood", chance = 2000},
	{id = "gold ingot", chance = 15799},
	{id = "ornate crossbow", chance = 2200},
	{id = "heavy trident", chance = 2430},
	{id = "guardian axe", chance = 8240},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -300, maxDamage = -780},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_EARTHDAMAGE, effect = 387, minDamage = -450, maxDamage = -1220, length = 8, spread = 3, target = false},
	{name ="combat", interval = 2000, chance = 13, type = COMBAT_EARTHDAMAGE, effect = 342, minDamage = -325, maxDamage = -975, radius = 4, target = false},
	{name ="combat", interval = 2000, chance = 9, type = COMBAT_PHYSICALDAMAGE, minDamage = -400, maxDamage = -800, length = 8, spread = 3, effect = 304, target = false}
}

monster.defenses = {
	defense = 95,
	armor = 100,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 25},
	{type = COMBAT_EARTHDAMAGE, percent = 50},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 10},
	{type = COMBAT_ARCANEDAMAGE , percent = 20}
}


monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
