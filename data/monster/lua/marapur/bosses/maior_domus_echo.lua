local mType = Game.createMonsterType("Maior Domus Echo")
local monster = {}

monster.description = "Maior Domus Echo"
monster.experience = 750000
monster.outfit = {
	lookType = 1568,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 185000
monster.maxHealth = 400000
monster.race = "undead"
monster.raceid = 2205
monster.corpse = 26691
monster.speed = 550

monster.changeTarget = {
	interval = 2000,
	chance = 10
}


monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
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
	staticAttackChance = 95,
	targetDistance = 1,
	isRewardBoss = true,
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

monster.summon = {

}

monster.voices = {
	interval = 5000,
	chance = 10,
	{text = "Mortal flesh cannot withstand an eternal god.", yell = true},
	{text = "Ra may judge you... but I shall destroy you.", yell = true},
}

monster.loot = {
	{id = "crystal coin", chance = 100000, maxCount = 35},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "divine mana potion", chance = 35000, maxCount = 5},
	{id = "divine health potion", chance = 35000, maxCount = 5},
	{id = "divine spirit potion", chance = 35000, maxCount = 5},
	{id = "cloud in a bottle", chance = 500},
	{id = "figurine of maior domus", chance = 1300},
	{id = "auric moon sigil", chance = 800},
	{id = "moonsilver strike helm", chance = 600},
	{id = "moonsilver trail hood", chance = 600},
	{id = "moonsilver nimbus hat", chance = 600},
	{id = 30954, chance = 600}, -- flamingo precision amulet
	{id = 30955, chance = 600}, -- flamingo destruction amulet
	{id = 30957, chance = 600}, -- swan amulet
	{id = "boss token", chance = 800},
	{id = "nightmare coin", chance = 1200}
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -900, maxDamage = -2500},
	{name = "domus echo root serpent", interval = 3250, chance = 21, minDamage = -1200, maxDamage = -2100, combatValues = true, target = false},
	{name = "domus echo iron star", interval = 3750, chance = 19, minDamage = -1500, maxDamage = -2500, combatValues = true, target = false},
	{name = "domus echo storm saltire", interval = 2250, chance = 18, minDamage = -1700, maxDamage = -2800, combatValues = true, target = false},
	{name = "domus echo flame wheel", interval = 2750, chance = 17, minDamage = -1300, maxDamage = -2300, combatValues = true, target = false},
	{name = "domus echo infernal rain", interval = 3500, chance = 15, minDamage = -1800, maxDamage = -2800, combatValues = true, target = false}
}

monster.defenses = {
	defense = 200,
	armor = 200,
	{name = "speed", chance = 15, interval = 2000, speed = 850, effect = CONST_ME_MAGIC_RED},
	{name ="combat", interval = 5000, chance = 25, type = COMBAT_HEALING, minDamage = 2000, maxDamage = 5250, effect = 185, target = false},
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 7},
	{type = COMBAT_EARTHDAMAGE, percent = 3},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = -11},
	{type = COMBAT_DEATHDAMAGE , percent = -4},
	{type = COMBAT_WATERDAMAGE, percent = -4},
	{type = COMBAT_ARCANEDAMAGE, percent = 18}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType.onThink = function(monster, interval)
end

mType.onAppear = function(monster, creature)
end

mType.onDisappear = function(monster, creature)
end

mType.onMove = function(monster, creature, fromPosition, toPosition)
end

mType.onSay = function(monster, creature, type, message)
end

mType:register(monster)
