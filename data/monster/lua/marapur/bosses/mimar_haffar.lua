local mType = Game.createMonsterType("Mimar Haffar")
local monster = {}

monster.description = "Mimar Haffar"
monster.experience = 500000
monster.outfit = {
	lookType = 1572,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 350000
monster.maxHealth = 350000
monster.race = "undead"
monster.raceid = 2203
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
	{text = "Zah'ra khadim… Azhar qel'mar! Vashir na'zul, Kharaz im'djinn!", yell = true},
	{text = "Sha'zir… qalem nar'ash. Zul kharim, zul amar.", yell = true},
}

monster.loot = {
	{id = "crystal coin", chance = 100000, maxCount = 35},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "divine mana potion", chance = 35000, maxCount = 5},
	{id = "divine health potion", chance = 35000, maxCount = 5},
	{id = "divine spirit potion", chance = 35000, maxCount = 5},
	{id = "figurine of mimar haffar", chance = 800},
	{id = "auric moon sigil", chance = 500},
	{id = "moonsilver battle visor", chance = 600},
	{id = "moonsilver spirit mask", chance = 600},
	{id = "dirty turban", chance = 9000, maxCount = 2},
	{id = 30953, chance = 600}, -- valor amulet
	{id = 30956, chance = 600}, -- nature amulet
	{id = "boss token", chance = 800},
	{id = "nightmare coin", chance = 1200}
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -500, maxDamage = -2000},
	{name = "mimar solar return", interval = 1700, chance = 18, minDamage = -800, maxDamage = -1400, combatValues = true, target = false},
	{name = "mimar flame corona", interval = 2500, chance = 16, minDamage = -900, maxDamage = -1700, combatValues = true, target = false},
	{name = "mimar radiant cross", interval = 2000, chance = 15, minDamage = -1000, maxDamage = -1900, combatValues = true, target = false},
	{name = "mimar dancing flames", interval = 2500, chance = 14, minDamage = -800, maxDamage = -1600, combatValues = true, target = false},
	{name = "mimar consecrated ground", interval = 3500, chance = 12, minDamage = -1200, maxDamage = -2200, combatValues = true, target = false}
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
