local mType = Game.createMonsterType("Ironburrow Devourer")
local monster = {}

monster.description = "a ironburrow devourer"
monster.experience = 49000
monster.outfit = {
	lookType = 1490,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 42000
monster.maxHealth = 42000
monster.race = "lycanthrope"
monster.raceid = 1229
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
	{text = "Grinding... crushing...", yell = false},
	{text = "Burrow protocol engaged.", yell = false},
	{text = "Target detected underground.", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "blue crystal shard", chance = 23000, maxCount = 3},
	{id = "violet crystal shard", chance = 32000, maxCount = 3},
	{id = "green crystal shard", chance = 21600, maxCount = 3},
	{id = "green crystal splinter", chance = 30000, maxCount = 5},
	{id = "auralis bloom", chance = 4000},
	{id = "piece of cryth ore", chance = 4000},
	{id = "brown crystal splinter", chance = 30410, maxCount = 5},
	{id = "blue crystal splinter", chance = 40000, maxCount = 5},
	{id = "boots of haste", chance = 2000},
	{id = "crown helmet", chance = 7000},
	{id = "magic plate armor", chance = 2500},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, effect = 1, minDamage = -100, maxDamage = -720},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -180, maxDamage = -900, range = 5, shootEffect = 60, effect = 207, target = true},
	{name ="combat", interval = 2000, chance = 17, type = COMBAT_EARTHDAMAGE, minDamage = -220, maxDamage = -1050, radius = 3, effect = 382, target = false},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_PHYSICALDAMAGE, minDamage = -300, maxDamage = -1400, length = 5, spread = 3, effect = 368, target = false}
}

monster.defenses = {
	defense = 115,
	armor = 130
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 35},
	{type = COMBAT_ENERGYDAMAGE, percent = -5},
	{type = COMBAT_EARTHDAMAGE, percent = 60},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = -5},
	{type = COMBAT_DEATHDAMAGE , percent = 10},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 5}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
