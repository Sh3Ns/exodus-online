local mType = Game.createMonsterType("Hive Widow")
local monster = {}

monster.description = "a hive widow"
monster.experience = 39500
monster.outfit = {
	lookType = 1479,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 38500
monster.maxHealth = 38500
monster.race = "vermin"
monster.raceid = 1213
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
	{text = "The brood must feed...", yell = false},
	{text = "You walk into my nest.", yell = false},
	{text = "*chittering noises*", yell = false},
	{text = "Your flesh belongs to the swarm.", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "brown mushroom", chance = 14000, maxCount = 2},
	{id = "beastslayer axe", chance = 7260},
	{id = "mercenary sword", chance = 3500},
	{id = "spiked squelcher", chance = 1410},
	{id = "crown legs", chance = 6500},
	{id = "crusader helmet", chance = 1400},
	{id = "tower shield", chance = 7280},
	{id = "steel boots", chance = 2420},
	{id = "onyx flail", chance = 2100},
	{id = "leaf robe", chance = 2000},
	{id = "laccaria laccata", chance = 4000},
	{id = "virelia flower", chance = 4000},
	{id = "jade hammer", chance = 900},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_EARTHDAMAGE, minDamage = -199, maxDamage = -1199},
	{name = "combat", interval = 2000, chance = 26, type = COMBAT_EARTHDAMAGE, minDamage = -300, maxDamage = -850, range = 7, shootEffect = 12, effect = 336, target = true},
	{name = "combat", interval = 2000, chance = 22, type = COMBAT_EARTHDAMAGE, minDamage = -420, maxDamage = -850, radius = 3, effect = 390, target = true},
	{name = "combat", interval = 2000, chance = 18, type = COMBAT_EARTHDAMAGE, minDamage = -380, maxDamage = -1380, length = 5, spread = 3, effect = 349, target = false},
	{name = "combat", interval = 2000, chance = 12, type = COMBAT_EARTHDAMAGE, minDamage = -650, maxDamage = -1200, radius = 4, effect = 363, target = false}
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
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE, percent = -10},
	{type = COMBAT_DEATHDAMAGE, percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 10},
	{type = COMBAT_ARCANEDAMAGE, percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
