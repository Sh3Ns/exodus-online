local mType = Game.createMonsterType("Ancient Moss Guardian")
local monster = {}

monster.description = "a ancient moss guardian"
monster.experience = 47000
monster.outfit = {
	lookType = 1475,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 31000
monster.maxHealth = 31000
monster.race = "elemental"
monster.raceid = 854
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
	chance = 10,
	{text = "Stone remembers your trespass...", yell = false},
	{text = "Roots will claim your bones.", yell = false},
	{text = "The earth rejects you!", yell = false},
	{text = "Your steps awaken my wrath.", yell = false},
	{text = "You disturb the ancient ground.", yell = false},
	{text = "Return to dust!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "golden legs", chance = 2800},
	{id = "giant ruby", chance = 3500},
	{id = "naga tanko", chance = 700},
	{id = "talon", chance = 34000, maxCount = 4},
	{id = "vampire shield", chance = 8500},
	{id = "zaoan halberd", chance = 10000},
	{id = "mino lance", chance = 9600},
	{id = "rift lance", chance = 6800},
	{id = "verdant bark", chance = 5000},
	{id = "dragon fruit", chance = 5000},
	{id = "shockwave amulet", chance = 6000},
}

monster.attacks = {
	{name ="combat", interval = 2000, chance = 100, type = COMBAT_EARTHDAMAGE, minDamage = -300, maxDamage = -1250, range = 7, shootEffect = 128, effect = 390, target = true},
	{name ="combat", interval = 2000, chance = 18, type = COMBAT_PHYSICALDAMAGE, minDamage = -350, maxDamage = -1700, range = 7, shootEffect = 69, effect = 350, target = true},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_EARTHDAMAGE, minDamage = -400, maxDamage = -800, radius = 3, effect = 387, target = true},
	{name ="combat", interval = 2000, chance = 7, type = COMBAT_PHYSICALDAMAGE, minDamage = -750, maxDamage = -1300, radius = 3, effect = 352, target = false}
}


monster.defenses = {
	defense = 110,
	armor = 115
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 25},
	{type = COMBAT_ENERGYDAMAGE, percent = -10},
	{type = COMBAT_EARTHDAMAGE, percent = 100},
	{type = COMBAT_FIREDAMAGE, percent = -15},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 20},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
