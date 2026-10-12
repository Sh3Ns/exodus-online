local mType = Game.createMonsterType("Kraxxis The Corruptor")
local monster = {}

monster.description = "Kraxxis The Corruptor"
monster.experience = 450000
monster.outfit = {
	lookType = 1500,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 450000
monster.maxHealth = 450000
monster.race = "demon"
monster.raceid = 1243
monster.corpse = 26691
monster.speed = 800
monster.manaCost = 0

monster.changeTarget = {
	interval = 10000,
	chance = 20
}


monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
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
	staticAttackChance = 98,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	isRewardBoss = true,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true
}

monster.events = {
	"playerAttackSound"
}

monster.light = {
	level = 0,
	color = 0
}

monster.summon = {
}

monster.voices = {
	interval = 5000,
	chance = 12,
	{text = "We hunger...", yell = false},
	{text = "Two jaws... one end.", yell = false},
	{text = "You will be torn apart.", yell = false},
	{text = "Flesh... must break.", yell = false},
	{text = "We feast as one.", yell = false}
}

monster.loot = {
	{id = 2160, chance = 100000, maxCount = 40},
	{id = "mythic health potion", chance = 80000, maxCount = 5},
	{id = "mythic mana potion", chance = 80000, maxCount = 5}, 
	{id = "mythic spirit potion", chance = 80000, maxCount = 5}, 
	{id = "boss token", chance = 15000, maxCount = 2},
	{id = "exercise token", chance = 15000, maxCount = 2},
	{id = "eldritch cuirass", chance = 3000},
	{id = "shadewalker armor", chance = 2900},
	{id = "embersage armor", chance = 2800},
	{id = "death oyoroi", chance = 2700},
	{id = "essence of soul", chance = 15000, maxCount = 2},
	{id = "masterpiece armor shard", chance = 20000, maxCount = 3},
	{id = "kraxxis device", chance = 10000, maxCount = 2},
	{id = "spirit vessel", chance = 8000},
	{id = "soul leaf", chance = 20000, maxCount = 3},
	{id = "life leaf", chance = 20000, maxCount = 3},
	{id = "decayed rune", chance = 15000, maxCount = 2},
	{id = "kraxxis skull", chance = 11000, maxCount = 1},
	{id = 2390, chance = 50}, -- Magic Longsword Ultra Rare
	{id = 29619, chance = 35000, maxCount = 3}, --- Upgrade Rune v1
	{id = 29620, chance= 20000, maxCount = 2}, --- Upgrade Rune v2
	{id = 29621, chance = 15000, maxCount = 2}, --- Upgrade Rune v3
	{id = 29622, chance = 8000, maxCount = 1}, --- Upgrade Rune v4
	{id = 29623, chance = 55000, maxCount = 2} --- Upgrade and Rarity Remover


}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -900, maxDamage = -1800},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_FIREDAMAGE, minDamage = -1800, maxDamage = -3800, effect = 278, target = true},
	{name ="combat", interval = 2000, chance = 24, type = COMBAT_EARTHDAMAGE, minDamage = -1900, maxDamage = -4000, radius = 4, effect = 390, target = true},
	{name ="combat", interval = 2000, chance = 28, type = COMBAT_DEATHDAMAGE, minDamage = -1800, maxDamage = -3600, radius = 2, effect = 394, target = true},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_EARTHDAMAGE, minDamage = -1800, maxDamage = -3700, range = 4, shootEffect = 55, effect = 272, target = true},
	{name ="combat", interval = 1000, chance = 25, type = COMBAT_DEATHDAMAGE, minDamage = -500, maxDamage = -850, length = 8, spread = 3, effect = 229, target = false},
	{name ="combat", interval = 2000, chance = 19, type = COMBAT_FIREDAMAGE, minDamage = -1800, maxDamage = -3400, length = 6, spread = 2, effect = 290, target = false},
	{name ="kraxxis spell", interval = 15000, chance = 30, target = false}
}

monster.defenses = {
	defense = 145,
	armor = 160,
	{name ="combat", interval = 3000, chance = 15, type = COMBAT_HEALING, minDamage = 2500, maxDamage = 3500, effect = 185, target = false},
	{name = "speed", chance = 15, interval = 2*1000, speed = 850, effect = CONST_ME_MAGIC_RED}
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 30},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 40},
	{type = COMBAT_FIREDAMAGE, percent = 50},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = -10},
	{type = COMBAT_DEATHDAMAGE , percent = 15},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
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