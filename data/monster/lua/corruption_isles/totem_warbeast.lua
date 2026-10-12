local mType = Game.createMonsterType("Totem Warbeast")
local monster = {}

monster.description = "a totem warbeast"
monster.experience = 44500
monster.outfit = {
	lookType = 1468,
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
monster.raceid = 1471
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
	{text = "The spirits will devour you!", yell = false},
	{text = "Feel the fury of the totems!", yell = false},
	{text = "Your soul will be consumed!", yell = false},
	{text = "The elements will tear you apart!", yell = false},
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "yellow gem", chance = 7900},
	{id = "devil helmet", chance = 33360},
	{id = "magma legs", chance = 4350},
	{id = "demon shield", chance = 2210},
	{id = "nightmare blade", chance = 2230},
	{id = "blue gem", chance = 1780},
	{id = "rift crossbow", chance = 920},
	{id = "steel boots", chance = 2040},
	{id = "rift shield", chance = 2620},
	{id = "rift lance", chance = 2680},
	{id = "crimsyx prism", chance = 4000},
	{id = "verdwood", chance = 4000},
	{id = "rift bow", chance = 1670},
	{id = "abyss hammer", chance = 1510},
	{id = "crystallized ribs", chance = 2300},
	{id = "composite hornbow", chance = 2910},
	{id = "springsprout rod", chance = 8720},
}

monster.attacks = {
	{name = "combat", interval = 2000, chance = 100, type = COMBAT_ICEDAMAGE, minDamage = -320, maxDamage = -1200, range = 7, shootEffect = 102, effect = 395, target = true},
	{name = "combat", interval = 2000, chance = 22, type = COMBAT_ARCANEDAMAGE, minDamage = -420, maxDamage = -850, radius = 3, effect = 314, target = true},
	{name = "combat", interval = 2000, chance = 16, type = COMBAT_ENERGYDAMAGE, minDamage = -380, maxDamage = -1380, length = 5, spread = 3, effect = 357, target = false},
	{name = "combat", interval = 2000, chance = 14, type = COMBAT_ARCANEDAMAGE, minDamage = -650, maxDamage = -1200, radius = 4, effect = 288, target = false}
}

monster.defenses = {
	defense = 105,
	armor = 110
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 20},
	{type = COMBAT_ENERGYDAMAGE, percent = 35},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 10},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -10},
	{type = COMBAT_HOLYDAMAGE, percent = -15},
	{type = COMBAT_DEATHDAMAGE, percent = 10},
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
