local mType = Game.createMonsterType("Venom Ooze")
local monster = {}

monster.description = "a venom ooze"
monster.experience = 39000
monster.outfit = {
	lookType = 1471,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 37000
monster.maxHealth = 37000
monster.race = "plant"
monster.raceid = 1495
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
	{text = "*toxic bubbling*", yell = false},
	{text = "The poison consumes all!", yell = false},
	{text = "Your flesh will rot away!", yell = false},
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "dragon slayer", chance = 13500},
	{id = "runed sword", chance = 8800},
	{id = "demonic essence", chance = 35000, maxCount = 2},
	{id = "crown helmet", chance = 5250},
	{id = "crown armor", chance = 3250},
	{id = "crown legs", chance = 6250},
	{id = "sylvan wood", chance = 3000},
	{id = "aurawood", chance = 2000},
	{id = "divine plate", chance = 950},
	{id = "diamond sceptre", chance = 14590},
	{id = "dragon ham", chance = 80000, maxCount = 5},
	{id = "knight axe", chance = 20000},
	{id = "crystal mace", chance = 11700},
	{id = "chaos mace", chance = 8930},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -280, maxDamage = -790},
	{name = "combat", interval = 2000, chance = 24, type = COMBAT_EARTHDAMAGE, minDamage = -300, maxDamage = -1150, range = 7, shootEffect = 30, effect = 47, target = true},
	{name = "combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -380, maxDamage = -1280, radius = 3, effect = 182, target = true},
	{name = "combat", interval = 2000, chance = 8, type = COMBAT_EARTHDAMAGE, minDamage = -650, maxDamage = -1200, radius = 4, effect = 186, target = false}
}

monster.defenses = {
	defense = 90,
	armor = 85
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = -10},
	{type = COMBAT_EARTHDAMAGE, percent = 100},
	{type = COMBAT_FIREDAMAGE, percent = -30},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 100},
	{type = COMBAT_ICEDAMAGE, percent = 40},
	{type = COMBAT_HOLYDAMAGE, percent = 0},
	{type = COMBAT_DEATHDAMAGE, percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = -10},
	{type = COMBAT_ARCANEDAMAGE, percent = 10}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
