local mType = Game.createMonsterType("Shardback Behemoth")
local monster = {}

monster.description = "a shardback behemoth"
monster.experience = 45000
monster.outfit = {
	lookType = 1473,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 36500
monster.maxHealth = 36500
monster.race = "demon"
monster.raceid = 1405
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
	{text = "Crystals will pierce your bones!", yell = false},
	{text = "The mountain devours intruders.", yell = false},
	{text = "*deep rumbling growl*", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "Fire Axe", chance = 1750},
	{id = "Soul Orb", chance = 9260, maxCount = 5},
	{id = "Spellbook of Warding", chance = 850},
	{id = "Wand of Inferno", chance = 11250},
	{id = "violet crystal shard", chance = 3000},
	{id = "brown crystal splinter", chance = 12000, maxCount = 2},
	{id = "Fire Sword", chance = 11250},
	{id = "piece of drazium ore" , chance = 4000},
	{id = "drazium crystal" , chance = 4000},
	{id = "Magma Coat", chance = 7950},
	{id = "Magma Legs", chance = 5450},
	{id = "assassin dagger", chance = 4000},
	{id = "haunted blade", chance = 3500},
	{id = "nightmare blade", chance = 2280},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -400, maxDamage = -900},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -250, maxDamage = -1450, length = 6, spread = 3, effect = 217, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_ICEDAMAGE, minDamage = -350, maxDamage = -1150, length = 8, spread = 3, effect = 282, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -500, maxDamage = -1250, radius = 3, effect = 287, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_ICEDAMAGE, minDamage = -700, maxDamage = -1150, radius = 4, effect = 44, target = false}
}

monster.defenses = {
	defense = 110,
	armor = 120
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 25},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 20},
	{type = COMBAT_FIREDAMAGE, percent = -25},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 100},
	{type = COMBAT_HOLYDAMAGE, percent = 0},
	{type = COMBAT_DEATHDAMAGE, percent = 10},
	{type = COMBAT_WATERDAMAGE, percent = 30},
	{type = COMBAT_ARCANEDAMAGE, percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
