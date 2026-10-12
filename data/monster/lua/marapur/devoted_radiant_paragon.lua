local mType = Game.createMonsterType("Devoted Radiant Paragon")
local monster = {}

monster.description = "a Devoted Radiant Paragon"
monster.experience = 32500
monster.outfit = {
	lookType = 1562,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 2,
	lookMount = 0
}

monster.health = 31500
monster.maxHealth = 31500
monster.race = "human"
monster.raceid = 2199
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
	targetDistance = 3,
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
	{text = "Stand and be measured!", yell = true},
	{text = "This will not go unpunished!", yell = true},
	{text = "Your heresy will not spread!", yell = true}

}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "violet gem", chance = 74560},
	{id = "green gem", chance = 64560},
	{id = "blue gem", chance = 54560},
	{id = "wand of starstorm", chance = 31920},
	{id = "wand of voodoo", chance = 21920},
	{id = "ornate crossbow", chance = 41920},
	{id = "wand of defiance", chance = 21920, maxCount = 3},
	{id = "crystal crossbow", chance = 1920},
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
	{id = "skewered fish", chance = 2000},
	{id = "shatterstorm arrow", chance = 2000, maxCount = 4},
	{id = "firestorm arrow", chance = 2000, maxCount = 4},
	{id = "terrastorm arrow", chance = 2000, maxCount = 4},
	{id = "froststorm arrow", chance = 2000, maxCount = 4},
	{id = "thunderstorm arrow", chance = 2000, maxCount = 4}

}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, shootEffect = 142, minDamage = -500, maxDamage = -1100, condition = {type = CONDITION_FREEZING, totalDamage = 1500, interval = 4000}},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_FIREDAMAGE, minDamage = -300, maxDamage = -1695, range = 7, shootEffect = 146, effect = 459, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_LIFEDRAIN, minDamage = -530, maxDamage = -1760, length = 5, spread = 3, effect = 421, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_DEATHDAMAGE, minDamage = -600, maxDamage = -1730, radius = 3, effect = 413, target = false}
}

monster.defenses = {
	defense = 80,
	armor = 100,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 10},
	{type = COMBAT_ENERGYDAMAGE, percent = -10},
	{type = COMBAT_EARTHDAMAGE, percent = -15},
	{type = COMBAT_FIREDAMAGE, percent = 30},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 20},
	{type = COMBAT_WATERDAMAGE , percent = -5},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
