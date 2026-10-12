local mType = Game.createMonsterType("Rathmora The Blood Tyrant")
local monster = {}

monster.description = "Rathmora The Blood Tyrant"
monster.experience = 600000
monster.outfit = {
	lookType = 1501,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 600000
monster.maxHealth = 600000
monster.race = "demon"
monster.raceid = 1339
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
	{text = "Your blood calls to me...", yell = false},
	{text = "I will feast on your veins.", yell = false},
	{text = "You cannot escape the hunt.", yell = false},
	{text = "Your heart will burst.", yell = false},
	{text = "Bleed... for me.", yell = false}
}

monster.loot = {
	{id = 2160, chance = 100000, maxCount = 60},
	{id = "mythic health potion", chance = 90000, maxCount = 8},
	{id = "mythic mana potion", chance = 90000, maxCount = 8}, 
	{id = "mythic spirit potion", chance = 90000, maxCount = 8}, 
	{id = "boss token", chance = 50000, maxCount = 2},
	{id = "exercise token", chance = 35000, maxCount = 2},
	{id = "rathmora heart", chance = 10000, maxCount = 1},
	{id = "electrical device", chance = 10000, maxCount = 1},
	{id = "essence of soul", chance = 15000},
	{id = "masterpiece armor shard", chance = 35000, maxCount = 5},
	{id = "spirit vessel", chance = 15000, maxCount = 2},
	{id = "rathmora head", chance = 20000, maxCount = 2},
	{id = "blazing leaf", chance = 45000, maxCount = 3},
	{id = "soul leaf", chance = 65000, maxCount = 3},
	{id = "life leaf", chance = 90000, maxCount = 3},
	{id = "rathmora eye", chance = 20000, maxCount = 2},
	{id = "titanium bar", chance = 80000, maxCount = 10},
	{id = "auric sunfang", chance = 30000, maxCount = 1},
	{id = "decayed rune", chance = 30000},
	{id = "runescribed parchment", chance = 30000, maxCount = 2},
	{id = "vessel spirit essence", chance = 15000, maxCount = 2},
	{id = "rathmora chest", chance = 15000, maxCount = 1},
	{id = "key of rathmora chest", chance = 30000, maxCount = 1},
	{id = "seal of corruption", chance = 30000, maxCount = 2},
	{id = "seal of void corruption", chance = 20000, maxCount = 1},
	{id = "seal of ancient corruption", chance = 15000, maxCount = 1},
	{id = "seal of infernal corruption", chance = 9000},
	{id = "seal infernal protection", chance = 50000, maxCount = 2},
	{id = "seal fractured protection", chance = 20000, maxCount = 2},
	{id = "sigil of arcane", chance = 10000},
	{id = "sigil of death", chance = 10000},
	{id = "sigil of drown", chance = 10000},
	{id = "sigil of earth", chance = 10000},
	{id = "sigil of energy", chance = 10000},
	{id = "sigil of fire", chance = 10000},
	{id = "sigil of holy", chance = 10000},
	{id = "sigil of ice", chance = 10000},
	{id = "sigil of physical", chance = 10000},
	{id = "sigil of water", chance = 10000},
	{id = "catalyst of arcane", chance = 10000},
	{id = "catalyst of death", chance = 10000},
	{id = "catalyst of earth", chance = 10000},
	{id = "catalyst of energy", chance = 10000},
	{id = "catalyst of fire", chance = 10000},
	{id = "catalyst of holy", chance = 10000},
	{id = "catalyst of ice", chance = 10000},
	{id = "catalyst of water", chance = 10000},
	{id = "rune of armorsmith", chance = 10000},
	{id = "rune of axe", chance = 10000},
	{id = "rune of club", chance = 10000},
	{id = "rune of crafting", chance = 10000},
	{id = "rune of critical", chance = 10000},
	{id = "rune of distance", chance = 10000},
	{id = "rune of fist", chance = 10000},
	{id = "rune of herbalist", chance = 10000},
	{id = "rune of jewelsmith", chance = 10000},
	{id = "rune of life", chance = 10000},
	{id = "rune of magic", chance = 10000},
	{id = "rune of mana", chance = 10000},
	{id = "rune of mining", chance = 10000},
	{id = "rune of sword", chance = 10000},
	{id = "rune of weaponsmith", chance = 10000},
	{id = "rune of woodcutting", chance = 10000},
	{id = "rune of shielding", chance = 10000},
	{id = "rune of fishing", chance = 10000},
	{id = 29619, chance = 65000, maxCount = 3}, --- Upgrade Rune v1
	{id = 29620, chance= 30000, maxCount = 2}, --- Upgrade Rune v2
	{id = 29621, chance = 20000, maxCount = 2}, --- Upgrade Rune v3
	{id = 29622, chance = 15000, maxCount = 1}, --- Upgrade Rune v4
	{id = 29623, chance = 55000, maxCount = 2} --- Upgrade and Rarity Remover


}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_ARCANEDAMAGE, minDamage = -900, maxDamage = -1800},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_DEATHDAMAGE, minDamage = -1800, maxDamage = -3800, radius = 6, effect = 158, target = true},
	{name ="combat", interval = 2000, chance = 26, type = COMBAT_HOLYDAMAGE, minDamage = -1900, maxDamage = -4000, radius = 6, effect = 201, target = true},
	{name ="combat", interval = 2000, chance = 24, type = COMBAT_HOLYDAMAGE, minDamage = -1800, maxDamage = -3600, radius = 6, effect = 223, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -1800, maxDamage = -3700, range = 5, shootEffect = 83, effect = 182, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ARCANEDAMAGE, minDamage = -1800, maxDamage = -3500, length = 6, spread = 2, effect = 247, target = false},
	{name ="combat", interval = 1000, chance = 34, type = COMBAT_FIREDAMAGE, minDamage = -1300, maxDamage = -4400, range = 7, radius = 7, shootEffect = 84, effect = 216, target = true},
	{name ="rathmora attack", interval = 20000, chance = 30, minDamage = -2500, maxDamage = -4000},
}

monster.defenses = {
	defense = 135,
	armor = 155,
	{name ="combat", interval = 3000, chance = 15, type = COMBAT_HEALING, minDamage = 2500, maxDamage = 3500, effect = 185, target = false},
	{name = "speed", chance = 15, interval = 2*1000, speed = 850, effect = CONST_ME_MAGIC_RED}
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 35},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 10},
	{type = COMBAT_FIREDAMAGE, percent = 10},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 100},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = 15},
	{type = COMBAT_DEATHDAMAGE , percent = 20},
	{type = COMBAT_WATERDAMAGE , percent = -15},
	{type = COMBAT_ARCANEDAMAGE , percent = 15}
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