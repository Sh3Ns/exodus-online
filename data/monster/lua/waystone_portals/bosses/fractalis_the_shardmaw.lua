local mType = Game.createMonsterType("Fractalis the Shardmaw")
local monster = {}
monster.description = "a Fractalis the Shardmaw"
monster.experience = 300000
monster.outfit = {
	lookType = 1425
}

monster.health = 300000
monster.maxHealth = 300000
monster.corpse = 26691
monster.speed = 850
monster.maxSummons = 0
monster.race = "magical"
monster.raceid = 1114

monster.changeTarget = {
	interval = 4000,
	chance = 20
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = true,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 90,
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

monster.summons = {
}

monster.events = {
	"playerAttackSound"
}

monster.voices = {
}

monster.loot = { 
	{id = "Crystal Coin", chance = 100000, maxCount = 18},
	{id = "mythic mana potion", chance = 45000, maxCount = 6},
	{id = "mythic health potion", chance = 45000, maxCount = 6},
	{id = "mythic spirit potion", chance = 45000, maxCount = 6},
	{id = "runescribed parchment", chance = 8000, maxCount = 1},
	{id = "aethus fragment", chance = 8000, maxCount = 1},
	{id = "envenomed heart", chance = 8000, maxCount = 1},
	{id = "corrupted skull", chance = 8000, maxCount = 1},
	{id = "mystic essence", chance = 8000, maxCount = 1},
	{id = "armor shard", chance = 8000, maxCount = 1},
	{id = "runic stone shard", chance = 8000, maxCount = 1},
	{id = "myst charged stone", chance = 60000, maxCount = 2},
	{id = "seraphic charged stone", chance = 60000, maxCount = 2},
	{id = "molten charged stone", chance = 60000, maxCount = 2},
	{id = "dawnforged charged stone", chance = 60000, maxCount = 2},
	{id = "blacksmith hammer", chance = 30000, maxCount = 2},
	{id = "exalted orb", chance = 50000, maxCount = 8},
	{id = "stoic iks robe", chance = 2500},
	{id = "iks footwraps", chance = 2500},
	{id = "stoic iks casque", chance = 2500},
	{id = "stoic iks headpiece", chance = 2500},
	{id = "arcane dragon robe", chance = 2500},
	{id = "dauntless dragon scale armor", chance = 2500},
	{id = "mystical dragon robe", chance = 2500},
	{id = "stoic iks chestplate", chance = 2500},
	{id = "stoic iks cuirass", chance = 2500},
	{id = "unerring dragon scale armor", chance = 2500},
	{id = "stoic iks culet", chance = 2500},
	{id = "stoic iks faulds", chance = 2500},
	{id = "stoic iks boots", chance = 2500},
	{id = "stoic iks sandals", chance = 2500},
	{id = "chaos orb", chance = 35000, maxCount = 5},
	{id = "divine orb", chance = 20000, maxCount = 3},
	{id = "angel orb", chance = 10000, maxCount = 1},
	{id = "boss token", chance = 8000, maxCount = 2},
	{id = "exercise token", chance = 8000, maxCount = 2},
	{id = "ticket roulette", chance = 5000, maxCount = 2},
}

monster.attacks = {
	{name ="melee", interval = 2000, type = COMBAT_WATERDAMAGE, chance = 100, minDamage = -1500, maxDamage = -3000},
	{name ="combat", interval = 2000, chance = 7, type = COMBAT_PHYSICALDAMAGE, minDamage = -1650, maxDamage = -2900, length = 8, spread = 3, effect = 207, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ICEDAMAGE, minDamage = -2150, maxDamage = -3360, length = 10, spread = 3, effect = 281, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -1840, maxDamage = -2800, radius = 5, effect = 204, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_WATERDAMAGE, minDamage = -1700, maxDamage = -2954, length = 8, spread = 3, effect = 232, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_WATERDAMAGE, minDamage = -1640, maxDamage = -2755, radius = 5, effect = 283, target = true},
	{name ="fractalisParalyzer", interval = 2000, chance = 15, target = false}
}

monster.defenses = {
	defense = 220,
	armor = 220,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = -6},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -5},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 10},
	{type = COMBAT_HOLYDAMAGE , percent = -14},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 27},
	{type = COMBAT_ARCANEDAMAGE, percent = -8},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = false},
	{type = "earth", condition = false},
	{type = "ice", condition = true},
	{type = "drown", condition = true},
	{type = "holy", condition = false},
	{type = "death", condition = false},
	{type = "water", condition = true},
	{type = "arcane", condition = false},
	{type = "lifedrain", combat = true},
	{type = "paralyze", condition = true},
	{type = "invisible", condition = true}
}

mType.onThink = function(monster, interval)
end

mType.onAppear = function(monster, creature)
	if monster:getId() == creature:getId() then
	end
end

mType.onDisappear = function(monster, creature)
	if monster:getId() == creature:getId() then
	end
end

mType.onMove = function(monster, creature, fromPosition, toPosition)
	if monster:getId() == creature:getId() then
	end
end

mType.onSay = function(monster, creature, type, message)
end

mType:register(monster)
