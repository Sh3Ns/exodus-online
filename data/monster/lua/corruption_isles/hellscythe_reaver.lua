local mType = Game.createMonsterType("Hellscythe Reaver")
local monster = {}

monster.description = "a hellscythe reaver"
monster.experience = 46500
monster.outfit = {
	lookType = 1492,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 36000
monster.maxHealth = 36000
monster.race = "demon"
monster.raceid = 1209
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
	{text = "Your soul belongs to hell!", yell = false},
	{text = "Reap their lives!", yell = false},
	{text = "Blood for the abyss!", yell = false}
}


monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "violet gem", chance = 5600},
	{id = "opal", chance = 3200, maxCount = 2},
	{id = "wand of voodoo", chance = 3200},
	{id = "gold ingot", chance = 15750, maxCount = 2},
	{id = "epee", chance = 8120},
	{id = "fire axe", chance = 11120},
	{id = "titan axe", chance = 9120},
	{id = "taurus mace", chance = 9000},
	{id = "blue robe", chance = 6500},
	{id = "spiked squelcher", chance = 3000},
	{id = "dragon slayer", chance = 8000},
	{id = "magic plate armor", chance = 2500},
	{id = "agrocybe agerita", chance = 4000},
	{id = "psyliota arvensis", chance = 4000},
	{id = "crown helmet", chance = 7000},
	{id = "crown armor", chance = 3250},
	{id = "jagged sword", chance = 22000},
	{id = "mino shield", chance = 22000},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_FIREDAMAGE, minDamage = -150, maxDamage = -780},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_DEATHDAMAGE, minDamage = -250, maxDamage = -1250, range = 6, shootEffect = 32, effect = 369, target = true},
	{name ="combat", interval = 2000, chance = 22, type = COMBAT_FIREDAMAGE, minDamage = -320, maxDamage = -1350, radius = 3, effect = 361, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -420, maxDamage = -1250, length = 5, spread = 3, effect = 290, target = false}
}

monster.defenses = {
	defense = 110,
	armor = 115
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 10},
	{type = COMBAT_FIREDAMAGE, percent = 60},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -10},
	{type = COMBAT_HOLYDAMAGE , percent = -20},
	{type = COMBAT_DEATHDAMAGE , percent = 70},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 10}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
