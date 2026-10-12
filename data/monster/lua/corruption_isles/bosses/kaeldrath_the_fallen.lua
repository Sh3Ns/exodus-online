local mType = Game.createMonsterType("Kaeldrath The Fallen")
local monster = {}

monster.description = "Kaeldrath The Fallen"
monster.experience = 350000
monster.outfit = {
	lookType = 1496,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 350000
monster.maxHealth = 350000
monster.race = "demon"
monster.raceid = 1230
monster.corpse = 26691
monster.speed = 750
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
	targetDistance = 3,
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
	{text = "Kneel... or be broken.", yell = false},
	{text = "Your end is carved in steel.", yell = false},
	{text = "I have slain greater than you.", yell = false},
	{text = "Stand and face oblivion.", yell = false},
	{text = "Your courage will shatter.", yell = false},
	{text = "None survive my blade.", yell = false}
}

monster.loot = {
	{id = 2160, chance = 100000, maxCount = 50},
	{id = "divine health potion", chance = 90000, maxCount = 10},
	{id = "divine mana potion", chance = 90000, maxCount = 10}, 
	{id = "divine spirit potion", chance = 90000, maxCount = 10},
	{id = "seal of void corruption", chance = 85000, maxCount = 2},
	{id = "legendary exotic essence", chance = 55000, maxCount = 5},
	{id = "legendary chaos essence", chance = 33000, maxCount = 5},
	{id = "legendary abyssal essence", chance = 26000, maxCount = 5},
	{id = "legendary ancestral essence", chance = 20000, maxCount = 5},
	{id = "rare essence", chance = 50000, maxCount = 5},
	{id = "epic essence", chance = 35000, maxCount = 5},
	{id = "mythic essence", chance = 25000, maxCount = 5},
	{id = "moist bow", chance = 5000},
	{id = "moist crossbow", chance = 5000},
	{id = "moist helmet", chance = 8000},
	{id = "moist armor", chance = 5500},
	{id = "moist legs", chance = 7000},
	{id = "moist boots", chance = 10000},
	{id = "moist hood", chance = 8000},
	{id = "moist robe", chance = 5500},
	{id = "moist pants", chance = 7000},
	{id = "moist shoes", chance = 10000},
	{id = "moist coiff", chance = 8000},
	{id = "moist vestment", chance = 5500},
	{id = "moist greaves", chance = 10000},
	{id = "moist breeches", chance = 7000},
	{id = "moist quiver", chance = 5000},
	{id = "fractured aether", chance = 5000, maxCount = 3},
	{id = "crystallized aether", chance = 5000},
	{id = "aether essence", chance = 5000},
	{id = "verdant bark", chance = 5000},
	{id = "twilight bloom flower", chance = 5000},
	{id = "moonsang cocoon silk", chance = 5000},
	{id = "fractured verdant crystal", chance = 5000, maxCount = 3},
	{id = "crystallized verdant crystal", chance = 5000},
	{id = "verdant crystal essence", chance = 5000},
	{id = 30231, chance = 5000},
	{id = 30232, chance = 5000},
	{id = 30233, chance = 5000},
	{id = 30234, chance = 5000},
	{id = 30235, chance = 5000},
	{id = 30236, chance = 5000},
	{id = 30237, chance = 5000},
	{id = 30238, chance = 5000},
	{id = "grimwood pistil", chance = 5000},
	{id = "duskwillow pistil", chance = 5000},
	{id = "gildedheart pistil", chance = 5000},
	{id = "cinderbark pistil", chance = 5000},
	{id = "frostpine pistil", chance = 5000},
	{id = "colybis butyraces", chance = 5000},
	{id = "agrocybe agerita", chance = 5000},
	{id = "psyliota arvensis", chance = 5000},
	{id = "laccaria laccata", chance = 5000},
	{id = "virelia flower", chance = 5000},
	{id = "auralis bloom", chance = 5000},
	{id = "piece of cryth ore", chance = 5000, maxCount = 3},
	{id = "cryth crystal", chance = 5000},
	{id = "cryth ingot", chance = 5000},
	{id = "piece of obryx ore", chance = 5000, maxCount = 3},
	{id = "obryx crystal", chance = 5000},
	{id = "obryx ingot", chance = 5000},
	{id = "piece of drazium ore", chance = 5000, maxCount = 3},
	{id = "drazium crystal", chance = 5000},
	{id = "drazium ingot", chance = 5000},
	{id = "piece of redsyl ore", chance = 5000, maxCount = 3},
	{id = "redsyl crystal", chance = 5000},
	{id = "redsyl ingot", chance = 5000},
	{id = "voidslag crystal shard", chance = 5000},
	{id = "aqualith crystal shard", chance = 5000},
	{id = 30264, chance = 5000},
	{id = "solvex prism", chance = 5000},
	{id = "crimsyx prism", chance = 5000},
	{id = "verdwood", chance = 5000},
	{id = "sylvan wood", chance = 5000},
	{id = "aurawood", chance = 5000},
	{id = "umbrabloom wood", chance = 5000},
	{id = "bloodwood", chance = 5000},
	{id = 29619, chance = 15000}, --- Upgrade Rune v1
	{id = 29620, chance= 13000}, --- Upgrade Rune v2
	{id = 29621, chance = 12000}, --- Upgrade Rune v3
	{id = 29622, chance = 9000}, --- Upgrade Rune v4
	{id = 29623, chance = 10000} --- Upgrade and Rarity Remover


}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, type = COMBAT_PHYSICALDAMAGE, shootEffect = 81, minDamage = -800, maxDamage = -1800, range = 7},
	{name ="combat", interval = 2000, chance = 18, type = COMBAT_PHYSICALDAMAGE, minDamage = -1000, maxDamage = -2400, range = 3, shootEffect = 54, effect = 268, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_DEATHDAMAGE, minDamage = -1200, maxDamage = -2800, length = 8, spread = 2, effect = 229, target = false},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_ICEDAMAGE, minDamage = -1600, maxDamage = -2500, range = 7, shootEffect = 35, effect = 391, target = true},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_FIREDAMAGE, minDamage = -1800, maxDamage = -2200, range = 7, shootEffect = 79, effect = 383, target = true},
	{name ="combat", interval = 2000, chance = 12, type = COMBAT_ENERGYDAMAGE, minDamage = -1200, maxDamage = -2800, range = 6, shootEffect = 70, effect = 306, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -1400, maxDamage = -3800, range = 4, shootEffect = 54, effect = 356, target = true}
}

monster.defenses = {
	defense = 140,
	armor = 165,
	{name ="combat", interval = 3000, chance = 15, type = COMBAT_HEALING, minDamage = 2500, maxDamage = 3500, effect = 185, target = false},
	{name = "speed", chance = 15, interval = 2*1000, speed = 850, effect = CONST_ME_MAGIC_RED}
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 35},
	{type = COMBAT_ENERGYDAMAGE, percent = 10},
	{type = COMBAT_EARTHDAMAGE, percent = 40},
	{type = COMBAT_FIREDAMAGE, percent = -5},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = -15},
	{type = COMBAT_DEATHDAMAGE , percent = 25},
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