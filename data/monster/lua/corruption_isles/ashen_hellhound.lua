local mType = Game.createMonsterType("Ashen Hellhound")
local monster = {}

monster.description = "a ashen hellhound"
monster.experience = 47800
monster.outfit = {
	lookType = 1477,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 40000
monster.maxHealth = 40000
monster.race = "demon"
monster.raceid = 903
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
	{text = "Grrrrr...", yell = false},
	{text = "Your scent betrays you!", yell = false},
	{text = "Flesh for the flames!", yell = false},
	{text = "Run... I enjoy the chase.", yell = false},
	{text = "Your bones will burn!", yell = false},
	{text = "The hunt begins!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "diamond", chance = 11170},
	{id = "amber with a bug", chance = 780},
	{id = "small amethyst", chance = 14000, maxCount = 2},
	{id = "small emerald", chance = 14000, maxCount = 2},
	{id = "small diamond", chance = 14000, maxCount = 2},
	{id = "giant topaz", chance = 2580},
	{id = 30231, chance = 4000},
	{id = "skull staff", chance = 11300},
	{id = "warrior's axe", chance = 6300},
	{id = "red gem", chance = 18150, maxCount = 2},
	{id = "ornate crossbow", chance = 4000},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_FIREDAMAGE, effect = 226, minDamage = -400, maxDamage = -950},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -300, maxDamage = -850, range = 5, shootEffect = CONST_ANI_FIRE, effect = 340, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_FIREDAMAGE, minDamage = -400, maxDamage = -1450, radius = 3, effect = 384, target = true},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_PHYSICALDAMAGE, minDamage = -350, maxDamage = -750, radius = 4, effect = 229, target = false},
	{name ="combat", interval = 2000, chance = 7, type = COMBAT_FIREDAMAGE, minDamage = -650, maxDamage = -1200, radius = 3, effect = 276, target = false}
}

monster.defenses = {
	defense = 100,
	armor = 95
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 60},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -20},
	{type = COMBAT_HOLYDAMAGE , percent = -15},
	{type = COMBAT_DEATHDAMAGE , percent = 20},
	{type = COMBAT_WATERDAMAGE , percent = -10},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
