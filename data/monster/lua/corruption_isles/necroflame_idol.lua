local mType = Game.createMonsterType("Necroflame Idol")
local monster = {}

monster.description = "a necroflame idol"
monster.experience = 42000
monster.outfit = {
	lookType = 1476,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 34000
monster.maxHealth = 34000
monster.race = "plant"
monster.raceid = 1293
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
	{text = "The curse binds this place...", yell = false},
	{text = "Your soul will feed the flame.", yell = false},
	{text = "None shall pass the idol.", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "skull staff", chance = 6500},
	{id = "magic sulphur", chance = 4000},
	{id = "spellbook of mind control", chance = 1370},
	{id = "gold ingot", chance = 11750, maxCount = 1},
	{id = "mortal mace", chance = 950},
	{id = "galea mortis", chance = 900},
	{id = "shadow cowl", chance = 1030},
	{id = "piece of obryx ore", chance = 4000},
	{id = "obryx crystal", chance = 4000},
	{id = "toga mortis", chance = 1100},
	{id = "giant sapphire", chance = 3800},
	{id = "giant emerald", chance = 3800},
	{id = "Gold Token", chance = 68970, maxCount = 2},
	{id = "Chaos Mace", chance = 6900},
	{id = "Skull Staff", chance = 13790},
	{id = "Huge Chunk of Crude Iron", chance = 17240},
	{id = "crown shield", chance = 3111},
	{id = "demon shield", chance = 2166},
	{id = "tower shield", chance = 6090},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_EARTHDAMAGE, minDamage = -220, maxDamage = -980},
	{name = "combat", interval = 2000, chance = 22, type = COMBAT_EARTHDAMAGE, minDamage = -320, maxDamage = -1200, range = 7, shootEffect = 55, effect = 389, target = true},
	{name = "combat", interval = 2000, chance = 18, type = COMBAT_EARTHDAMAGE, minDamage = -420, maxDamage = -850, radius = 3, effect = 367, target = true},
	{name = "combat", interval = 2000, chance = 14, type = COMBAT_EARTHDAMAGE, minDamage = -380, maxDamage = -1180, effect = 365, target = false},
}

monster.defenses = {
	defense = 100,
	armor = 105
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 50},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 30},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -5},
	{type = COMBAT_HOLYDAMAGE, percent = -25},
	{type = COMBAT_DEATHDAMAGE, percent = -5},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
