local mType = Game.createMonsterType("Void Ooze")
local monster = {}

monster.description = "a void ooze"
monster.experience = 39000
monster.outfit = {
	lookType = 1470,
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
monster.raceid = 1502
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
	{text = "Bloop...", yell = false},
	{text = "The void consumes all!", yell = false},
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "wand of cosmic energy", chance = 23636},
	{id = "wand of inferno", chance = 15240},
	{id = "northwind rod", chance = 25500},
	{id = "springsprout rod", chance = 21000},
	{id = "obsidian lance", chance = 5500},
	{id = "guardian shield", chance = 11243},
	{id = "Crystal Sword", chance = 10000},
	{id = "spellweaver's robe", chance = 860},
	{id = "knight armor", chance = 1000},
	{id = "royal helmet", chance = 300},
	{id = 30233, chance = 4000},
	{id = 30234, chance = 4000},
	{id = "titan axe", chance = 8600},
	{id = "glorious axe", chance = 9870},
	{id = "wand of defiance", chance = 13000},
	{id = "green crystal shard", chance = 8000},
	{id = "blue crystal splinter", chance = 16000, maxCount = 2},
	{id = "cyan crystal fragment", chance = 13000},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_WATERDAMAGE, minDamage = -111, maxDamage = -1050},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -750, maxDamage = -1300, radius = 4, effect = 208, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_WATERDAMAGE, minDamage = -550, maxDamage = -1200, range = 7, shootEffect = 130, effect = 283, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_WATERDAMAGE, minDamage = -800, maxDamage = -1250, length = 8, effect = 343, target = false}
}

monster.defenses = {
	defense = 105,
	armor = 105
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 20},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = -5},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE , percent = 70},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
