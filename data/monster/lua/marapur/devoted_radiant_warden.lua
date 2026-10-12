local mType = Game.createMonsterType("Devoted Radiant Warden")
local monster = {}

monster.description = "a Devoted Radiant Warden"
monster.experience = 35000
monster.outfit = {
	lookType = 1564,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 2,
	lookMount = 0
}

monster.health = 38500
monster.maxHealth = 38500
monster.race = "human"
monster.raceid = 2200
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
	{text = "You do not belong here!", yell = true},
	{text = "Maintaining order is mandatory!", yell = true},
	{text = "Deviation is intolerable!", yell = true}

}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "gold ring", chance = 13500},
	{id = "jade hammer", chance = 11500},
	{id = "hammer of wrath", chance = 10000},
	{id = "onyx flail", chance = 19500},
	{id = "twiceslicer", chance = 17500},
	{id = "stone skin amulet", chance = 15500},
	{id = "nightmare blade", chance = 9500},
	{id = "demonrage sword", chance = 7500},
	{id = "dreaded cleaver", chance = 2500},
	{id = "butcher's axe", chance = 1500},
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
	{name ="melee", interval = 2000, type = COMBAT_PHYSICALDAMAGE, chance = 100, minDamage = -700, maxDamage = -1960},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_FIREDAMAGE, minDamage = -500, maxDamage = -1800, length = 8, spread = 3, effect = 449, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_DEATHDAMAGE, minDamage = -620, maxDamage = -1910, range = 7, shootEffect = 229, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -535, maxDamage = -1550, length = 8, spread = 3, effect = 425, target = false},
}

monster.defenses = {
	defense = 110,
	armor = 110,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 10},
	{type = COMBAT_ENERGYDAMAGE, percent = -10},
	{type = COMBAT_EARTHDAMAGE, percent = -5},
	{type = COMBAT_FIREDAMAGE, percent = 30},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = -10},
	{type = COMBAT_DEATHDAMAGE , percent = 20},
	{type = COMBAT_WATERDAMAGE , percent = -7},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
