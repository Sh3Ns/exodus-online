local mType = Game.createMonsterType("Devoted Radiant Templar")
local monster = {}

monster.description = "a Devoted Radiant Templar"
monster.experience = 35000
monster.outfit = {
	lookType = 1563,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 3,
	lookMount = 0
}

monster.health = 38500
monster.maxHealth = 38500
monster.race = "human"
monster.raceid = 2207
monster.corpse = 26691
monster.speed = 400
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 60,
	health = 10,
	damage = 30,
	random = 0,
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
	canWalkOnPoison = true,
	pet = false
}

monster.light = {
	level = 0,
	color = 0
}

monster.voices = {
	interval = 7000,
	chance = 30,
	{text = "My conviction shall be my shield!", yell = true},
	{text = "You shall not pass!", yell = true},
	{text = "We will stand firm!", yell = true}

}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "small diamond", chance = 65560, maxCount = 7},
	{id = "gold ingot", chance = 25560},
	{id = "blue crystal splinter", chance = 25560},
	{id = "cyan crystal fragment", chance = 25560},
	{id = "red crystal fragment", chance = 25560},
	{id = "magma boots", chance = 35500},
	{id = "blue gem", chance = 65560},
	{id = "giant sword", chance = 13500},
	{id = "war axe", chance = 9500},
	{id = "mercenary sword", chance = 11500},
	{id = "green crystal fragment", chance = 9500},
	{id = "onyx chip", chance = 7500},
	{id = "pyrophyte seed pod", chance = 3000},
	{id = "tatty robe", chance = 4000},
	{id = "loose prayer beads", chance = 3000},
	{id = "ice shard", chance = 2000},
	{id = "golden belt", chance = 1800},
	{id = "gilded bell", chance = 1500},
	{id = "cloud familiar", chance = 1300},
	{id = "ceremonial bowl", chance = 2000},
	{id = "catnip", chance = 4500},
	{id = "broken arrow", chance = 2800},
	{id = "book of faith", chance = 2200},
	{id = "skewered fish", chance = 2000}

}

monster.attacks = {
	{name ="melee", interval = 2000, type = COMBAT_PHYSICALDAMAGE, chance = 100, minDamage = -444, maxDamage = -1600},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -380, maxDamage = -1500, range = 4, radius = 4, effect = 231, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_HOLYDAMAGE, minDamage = -650, maxDamage = -999, length = 7, spread = 5, effect = 360, target = false},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_ENERGYDAMAGE, minDamage = -550, maxDamage = -1440, radius = 5, effect = 377, target = false},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_EARTHDAMAGE, minDamage = -700, maxDamage = -1620, length = 7, spread = 8, effect = 389, target = false}
}

monster.defenses = {
	defense = 110,
	armor = 110,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 5},
	{type = COMBAT_ENERGYDAMAGE, percent = 20},
	{type = COMBAT_EARTHDAMAGE, percent = 5},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -10},
	{type = COMBAT_HOLYDAMAGE , percent = 25},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
