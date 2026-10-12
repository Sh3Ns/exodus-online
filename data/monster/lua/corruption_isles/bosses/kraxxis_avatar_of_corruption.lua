local mType = Game.createMonsterType("Kraxxis Avatar of Corruption")
local monster = {}

monster.description = "Kraxxis Avatar of Corruption"
monster.experience = 550000
monster.outfit = {
	lookType = 1502,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 550000
monster.maxHealth = 550000
monster.race = "demon"
monster.raceid = 1242
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
	chance = 14,
	{text = "We ascend... beyond flesh.", yell = false},
	{text = "The corruption... consumes all.", yell = false},
	{text = "You cannot withstand both of us.", yell = false},
	{text = "We are unleashed.", yell = false},
	{text = "Your end feeds our power.", yell = false}
}

monster.loot = {
	{id = 2160, chance = 100000, maxCount = 50},
	{id = "mythic health potion", chance = 90000, maxCount = 10},
	{id = "mythic mana potion", chance = 90000, maxCount = 10}, 
	{id = "mythic spirit potion", chance = 90000, maxCount = 10}, 
	{id = "boss token", chance = 38000, maxCount = 2},
	{id = "exercise token", chance = 34000, maxCount = 2},
	{id = "Scarlet Raven", chance = 2000},
	{id = "the counterspell", chance = 2200},
	{id = "whisperwind", chance = 3000},
	{id = "menethil march", chance = 3000},
	{id = "magma robe", chance = 9000},
	{id = "make-do boots", chance = 9000},
	{id = "makeshift boots", chance = 9000},
	{id = "forbidden ring", chance = 9000},
	{id = "charged ethereal ring", chance = 9000},
	{id = "shadewalker legs", chance = 9000},
	{id = "embersage legs", chance = 9000},
	{id = "embersage helmet", chance = 9000},
	{id = "shadewalker helmet", chance = 9000},
	{id = "aeris quiver", chance = 9000},
	{id = "shadewalker bow", chance = 9000},
	{id = "vigils wand", chance = 9000},
	{id = "vigils armor", chance = 9000},
	{id = "vigils helmet", chance = 9000},
	{id = "vigils legs", chance = 9000},
	{id = "vigils spellbook", chance = 9000},
	{id = "embersage axe", chance = 9000},
	{id = "embersage sword", chance = 9000},
	{id = "embersage club", chance = 9000},
	{id = "shadowmeld", chance = 4000},
	{id = "the awakener", chance = 1500},
	{id = "seal of corruption", chance = 40000, maxCount = 2},
	{id = "seal of void corruption", chance = 30000, maxCount = 1},
	{id = "seal of ancient corruption", chance = 2000, maxCount = 1},
	{id = "seal of infernal corruption", chance = 13000},
	{id = "seal infernal protection", chance = 30000},
	{id = "seal fractured protection", chance = 20000},
	{id = "giant sapphire", chance = 28000},
	{id = "blacksmith hammer", chance = 11000},
	{id = "giant topaz", chance = 28000},
	{id = 29619, chance = 65000, maxCount = 3}, --- Upgrade Rune v1
	{id = 29620, chance= 30000, maxCount = 2}, --- Upgrade Rune v2
	{id = 29621, chance = 20000, maxCount = 2}, --- Upgrade Rune v3
	{id = 29622, chance = 15000, maxCount = 1}, --- Upgrade Rune v4
	{id = 29623, chance = 55000, maxCount = 2} --- Upgrade and Rarity Remover


}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -1100, maxDamage = -2200},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_ARCANEDAMAGE, minDamage = -1000, maxDamage = -3500, length = 8, spread = 3, effect = 288, target = false},
	{name ="combat", interval = 2000, chance = 24, type = COMBAT_PHYSICALDAMAGE, minDamage = -900, maxDamage = -4000, length = 8, spread = 3, effect = 244, target = false},
	{name ="combat", interval = 2000, chance = 22, type = COMBAT_DEATHDAMAGE, minDamage = -1250, maxDamage = -4900, radius = 8, effect = 267, target = true},
	{name ="combat", interval = 2000, chance = 24, type = COMBAT_ARCANEDAMAGE, minDamage = -1200, maxDamage = -4200, radius = 7, effect = 377, target = true},
	{name ="combat", interval = 2000, chance = 28, type = COMBAT_EARTHDAMAGE, minDamage = -1700, maxDamage = -3670, effect = 188, target = true},
	{name ="kraxxis spell", interval = 10000, chance = 30, target = false},
	{name ="kraxxis corruption", inteval = 20000, chance = 40, minDamage = -2300, maxDamage = -4000, target= true},
}
 
monster.defenses = {
	defense = 165,
	armor = 180,
	{name ="combat", interval = 3000, chance = 15, type = COMBAT_HEALING, minDamage = 2500, maxDamage = 3500, effect = 185, target = false},
	{name = "speed", chance = 15, interval = 2*1000, speed = 850, effect = CONST_ME_MAGIC_RED}
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 35},
	{type = COMBAT_ENERGYDAMAGE, percent = 25},
	{type = COMBAT_EARTHDAMAGE, percent = 25},
	{type = COMBAT_FIREDAMAGE, percent = 50},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 100},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = -20},
	{type = COMBAT_DEATHDAMAGE , percent = 20},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 10}
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