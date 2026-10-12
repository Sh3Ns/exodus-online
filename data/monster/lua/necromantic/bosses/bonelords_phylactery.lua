local mType = Game.createMonsterType("Bonelord's Phylactery")
local monster = {}

monster.description = "a Bonelord's Phylactery"
monster.experience = 190000
monster.outfit = {
	lookTypeEx = 30139,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 250000
monster.maxHealth = 250000
monster.race = "undead"
monster.raceid = 956
monster.corpse = 26691
monster.speed = 400
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}
monster.events = {
	"playerAttackSound"
}

monster.strategiesTarget = {
	nearest = 60,
	health = 10,
	damage = 30,
	random = 0,
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
	isRewardBoss = true,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
	pet = false
}

monster.light = {
	level = 0,
	color = 0
}

monster.voices = {
	interval = 5000,
	chance = 10,
}

monster.loot = {
	{id = "crystal coin", chance = 100000, maxCount = 55},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "divine mana potion", chance = 35000, maxCount = 12},
	{id = "divine health potion", chance = 35000, maxCount = 12},
	{id = "divine spirit potion", chance = 35000, maxCount = 12},
	{id = "stag helmet", chance = 3000},
	{id = "stag robe", chance = 3000},
	{id = "stag plate", chance = 3000},
	{id = "stag legs", chance = 3000},
	{id = "stag shinguards", chance = 3000},
	{id = "stag boots", chance = 3000},
	{id = "stag footwraps", chance = 3000},
	{id = "stag spellbook", chance = 3000},
	{id = "stag scrolls", chance = 3000},
	{id = "stag shield", chance = 3000},
	{id = "crypt spine", chance = 3000},
	{id = "crypt splitter", chance = 3000},
	{id = "crypt breaker", chance = 3000},
	{id = "crypt strike", chance = 3000},
	{id = "crypt bile", chance = 3000},
	{id = "crypt jaw", chance = 3000},
	{id = "crypt slicer", chance = 3000},
	-- Wheel of Destiny gems
	{id = 27151, chance = 10000}, -- Guardian Gem
	{id = 27154, chance = 10000}, -- Marksman Gem
	{id = 27157, chance = 10000}, -- Sage Gem
	{id = 27160, chance = 10000}, -- Mystic Gem
	{id = 30914, chance = 10000}, -- Spiritualist Gem
	{id = 27152, chance = 5000}, -- Greater Guardian Gem
	{id = 27155, chance = 5000}, -- Greater Marksman Gem
	{id = 27158, chance = 5000}, -- Greater Sage Gem
	{id = 27161, chance = 5000}, -- Greater Mystic Gem
	{id = 30915, chance = 5000}, -- Greater Spiritualist Gem
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -800, maxDamage = -2000},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ARCANEDAMAGE, minDamage = -800, maxDamage = -1600, range = 7, radius = 4, shootEffect = 85, effect = 247, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -750, maxDamage = -1700, range = 7, shootEffect = 55, effect = 196, target = true},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_ARCANEDAMAGE, minDamage = -750, maxDamage = -2000, radius = 6, effect = 247, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -800, maxDamage = -1950, range = 7, radius = 6, shootEffect = 98, effect = 305, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_PHYSICALDAMAGE, minDamage = -1000, maxDamage = -1980, range = 7, shootEffect = 60, effect = 274, target = false}
	}

monster.defenses = {
	defense = 150,
	armor = 150,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 18},
	{type = COMBAT_ENERGYDAMAGE, percent = 18},
	{type = COMBAT_EARTHDAMAGE, percent = 18},
	{type = COMBAT_FIREDAMAGE, percent = 18},
	{type = COMBAT_LIFEDRAIN, percent = 18},
	{type = COMBAT_MANADRAIN, percent = 18},
	{type = COMBAT_DROWNDAMAGE, percent = 18},
	{type = COMBAT_ICEDAMAGE, percent = 18},
	{type = COMBAT_HOLYDAMAGE , percent = 18},
	{type = COMBAT_DEATHDAMAGE , percent = 18},
	{type = COMBAT_WATERDAMAGE , percent = 18},
	{type = COMBAT_ARCANEDAMAGE , percent = 18}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
