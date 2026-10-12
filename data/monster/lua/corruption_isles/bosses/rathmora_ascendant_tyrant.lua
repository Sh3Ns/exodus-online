local mType = Game.createMonsterType("Rathmora Ascendant Tyrant")
local monster = {}

monster.description = "Rathmora Ascendant Tyrant"
monster.experience = 700000
monster.outfit = {
	lookType = 1503,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 700000
monster.maxHealth = 700000
monster.race = "demon"
monster.raceid = 1338
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
	"playerAttackSound",
	"RathmoraSkyCaravanDeath"
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
	{text = "Your blood is mine to command.", yell = false},
	{text = "I am the pulse of your doom.", yell = false},
	{text = "Every heartbeat feeds me.", yell = false},
	{text = "You cannot resist the call.", yell = false},
	{text = "I will drain this world dry.", yell = false},
	{text = "Your veins betray you.", yell = false}
}

monster.loot = {
	{id = 2160, chance = 100000, maxCount = 80},
	{id = "mythic health potion", chance = 90000, maxCount = 10},
	{id = "mythic mana potion", chance = 90000, maxCount = 10}, 
	{id = "mythic spirit potion", chance = 90000, maxCount = 10}, 
	{id = "boss token", chance = 70000, maxCount = 2},
	{id = "exercise token", chance = 55000, maxCount = 2},
	{id = "Scarlet Raven", chance = 2000},
	{id = "the counterspell", chance = 2200},
	{id = "whisperwind", chance = 4000},
	{id = "menethil march", chance = 4000},
	{id = "shadowmeld", chance = 4000},
	{id = "the awakener", chance = 2000},
	{id = "rathmora heart", chance = 50000, maxCount = 1},
	{id = "electrical device", chance = 90000, maxCount = 1},
	{id = "essence of soul", chance = 55000},
	{id = "masterpiece armor shard", chance = 65000, maxCount = 10},
	{id = "spirit vessel", chance = 55000, maxCount = 4},
	{id = "rathmora head", chance = 55000, maxCount = 3},
	{id = "blazing leaf", chance = 60000, maxCount = 8},
	{id = "soul leaf", chance = 85000, maxCount = 10},
	{id = "life leaf", chance = 90000, maxCount = 15},
	{id = "rathmora eye", chance = 60000, maxCount = 2},
	{id = "runescribed parchment", chance = 50000, maxCount = 2},
	{id = "decayed rune", chance = 50000, maxCount = 2},
	{id = "vessel spirit essence", chance = 55000, maxCount = 2},
	{id = "rathmora chest", chance = 95000, maxCount = 2},
	{id = "key of rathmora chest", chance = 90000, maxCount = 2},
	{id = "seal of corruption", chance = 80000, maxCount = 2},
	{id = "seal of void corruption", chance = 50000, maxCount = 1},
	{id = "seal of ancient corruption", chance = 35000, maxCount = 1},
	{id = "seal of infernal corruption", chance = 20000},
	{id = "seal infernal protection", chance = 90000, maxCount = 3},
	{id = "seal fractured protection", chance = 70000, maxCount = 3},
	{id = "giant emerald", chance = 30000},
	{id = "giant ruby" , chance = 30000},
	{id = "giant topaz" , chance = 30000},
	{id = "blacksmith hammer", chance = 14000},
	{id = "sigil of arcane", chance = 15000},
	{id = "sigil of death", chance = 15000},
	{id = "sigil of drown", chance = 15000},
	{id = "sigil of earth", chance = 15000},
	{id = "sigil of energy", chance = 15000},
	{id = "sigil of fire", chance = 15000},
	{id = "sigil of holy", chance = 15000},
	{id = "sigil of ice", chance = 15000},
	{id = "sigil of physical", chance = 15000},
	{id = "sigil of water", chance = 15000},
	{id = "catalyst of arcane", chance = 15000},
	{id = "catalyst of death", chance = 15000},
	{id = "catalyst of earth", chance = 15000},
	{id = "catalyst of energy", chance = 15000},
	{id = "catalyst of fire", chance = 15000},
	{id = "catalyst of holy", chance = 15000},
	{id = "catalyst of ice", chance = 15000},
	{id = "catalyst of water", chance = 15000},
	{id = "rune of armorsmith", chance = 15000},
	{id = "rune of axe", chance = 15000},
	{id = "rune of club", chance = 15000},
	{id = "rune of crafting", chance = 15000},
	{id = "rune of critical", chance = 15000},
	{id = "rune of distance", chance = 15000},
	{id = "rune of fist", chance = 15000},
	{id = "rune of herbalist", chance = 15000},
	{id = "rune of jewelsmith", chance = 15000},
	{id = "rune of life", chance = 15000},
	{id = "rune of magic", chance = 15000},
	{id = "rune of mana", chance = 15000},
	{id = "rune of mining", chance = 15000},
	{id = "rune of sword", chance = 15000},
	{id = "rune of weaponsmith", chance = 15000},
	{id = "rune of woodcutting", chance = 15000},
	{id = 29619, chance = 85000, maxCount = 3}, --- Upgrade Rune v1
	{id = 29620, chance= 50000, maxCount = 2}, --- Upgrade Rune v2
	{id = 29621, chance = 35000, maxCount = 2}, --- Upgrade Rune v3
	{id = 29622, chance = 20000, maxCount = 2}, --- Upgrade Rune v4
	{id = 29623, chance = 55000, maxCount = 2} --- Upgrade and Rarity Remover


}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, minDamage = -2100, maxDamage = -4200},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ARCANEDAMAGE, minDamage = -2200, maxDamage = -5800, radius = 8, effect = 353, target = true},
	{name ="combat", interval = 2000, chance = 18, type = COMBAT_DEATHDAMAGE, minDamage = -1950, maxDamage = -4800, radius = 7, effect = 338, target = true},
	{name ="combat", interval = 2000, chance = 16, type = COMBAT_ARCANEDAMAGE, minDamage = -2300, maxDamage = -5180, length = 9, spread = 4, effect = 217, target = false},
	{name ="rathmora skill reducer", interval = 2000, chance = 25, target = false},
	{name ="combat", interval = 2000, chance = 14, type = COMBAT_ENERGYDAMAGE, minDamage = -2200, maxDamage = -5770, range = 7, shootEffect = 106, effect = 280, target = true},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_DEATHDAMAGE, minDamage = -2270, maxDamage = -5360, range = 7, shootEffect = 11, effect = 394, target = true},
	{name ="rathmora attack agressive", interval = 20000, chance = 30, minDamage = -3500, maxDamage = -6000},
	{name ="combat", interval = 3500, chance = 35, type = COMBAT_ICEDAMAGE, minDamage = -2360, maxDamage = -4130, range = 7, radius = 9, shootEffect = 102, effect = 398, target = true},
	{name ="drunk", interval = 1000, chance = 7, range = 7, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYAREA, target = false},
}

monster.defenses = {
	defense = 155,
	armor = 175,
	{name ="combat", interval = 3000, chance = 15, type = COMBAT_HEALING, minDamage = 2500, maxDamage = 3500, effect = 185, target = false},
	{name = "speed", chance = 15, interval = 2*1000, speed = 850, effect = CONST_ME_MAGIC_RED}
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 40},
	{type = COMBAT_ENERGYDAMAGE, percent = 10},
	{type = COMBAT_EARTHDAMAGE, percent = 15},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 100},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = -20},
	{type = COMBAT_DEATHDAMAGE , percent = 20},
	{type = COMBAT_WATERDAMAGE , percent = 15},
	{type = COMBAT_ARCANEDAMAGE , percent = 50}
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