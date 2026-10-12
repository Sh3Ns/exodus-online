local mType = Game.createMonsterType("Stonehide Ravager")
local monster = {}

monster.description = "a stonehide ravager"
monster.experience = 48300
monster.outfit = {
	lookType = 1469,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 39500
monster.maxHealth = 39500
monster.race = "construct"
monster.raceid = 1435
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
	{text = "You dare enter my territory?", yell = false},
	{text = "Bones will break!", yell = false},
	{text = "Your efforts are futile!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "brown piece of cloth", chance = 6000},
	{id = "yellow piece of cloth", chance = 3500},
	{id = "terra boots", chance = 8720},
	{id = "spellbook of mind control", chance = 2420},
	{id = "underworld rod", chance = 3720},
	{id = "Soul Orb", chance = 3000, maxCount = 4},
	{id = "Necrotic Rod", chance = 3000},
	{id = "Magma Monocle", chance = 9500},
	{id = "voidslag crystal shard", chance = 4000},
	{id = "aqualith crystal shard", chance = 4000},
	{id = "springsprout rod", chance = 12510},

}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -800, maxDamage = -1320},
	{name = "combat", interval = 2000, chance = 22, type = COMBAT_PHYSICALDAMAGE, minDamage = -420, maxDamage = -1850, range = 5, shootEffect = 12, effect = 337, target = true},
	{name = "combat", interval = 2000, chance = 18, type = COMBAT_PHYSICALDAMAGE, minDamage = -510, maxDamage = -1650, radius = 3, effect = 10, target = true},
	{name = "combat", interval = 2000, chance = 14, type = COMBAT_EARTHDAMAGE, minDamage = -380, maxDamage = -1380, length = 5, spread = 3, effect = 390, target = false},
	{name = "combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -650, maxDamage = -1500, radius = 4, effect = 394, target = false}
}

monster.defenses = {
	defense = 110,
	armor = 120
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 30},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 40},
	{type = COMBAT_FIREDAMAGE, percent = -15},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE, percent = -10},
	{type = COMBAT_DEATHDAMAGE, percent = 10},
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
