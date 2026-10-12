local mType = Game.createMonsterType("Vorgrun of the Jade Fangs")
local monster = {}
monster.description = "a Vorgrun of the Jade Fangs"
monster.experience = 250000
monster.outfit = {
	lookType = 1429
}

monster.health = 250000
monster.maxHealth = 250000
monster.corpse = 26691
monster.speed = 850
monster.maxSummons = 0
monster.race = "giant"
monster.raceid = 1507

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
	{id = "runic stone shard", chance = 8000, maxCount = 1},
	{id = "myst charged stone", chance = 60000, maxCount = 2},
	{id = "seraphic charged stone", chance = 60000, maxCount = 2},
	{id = "molten charged stone", chance = 60000, maxCount = 2},
	{id = "dawnforged charged stone", chance = 60000, maxCount = 2},
	{id = "blacksmith hammer", chance = 30000, maxCount = 1},
	{id = "exalted orb", chance = 50000, maxCount = 8},
	{id = "chaos orb", chance = 35000, maxCount = 5},
	{id = "divine orb", chance = 20000, maxCount = 3},
	{id = "angel orb", chance = 10000, maxCount = 1},
	{id = "boss token", chance = 8000, maxCount = 2},
	{id = "exercise token", chance = 8000, maxCount = 2},
	{id = "ticket roulette", chance = 5000, maxCount = 2},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1800, maxDamage = -2800},
	{name ="vorgrunwave", interval = 2000, chance = 20, minDamage = -3550, maxDamage = -5500, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -1740, maxDamage = -2800, radius = 5, effect = 182, target = false},
	{name ="condition", type = CONDITION_POISON, interval = 2000, chance = 15, minDamage = -1100, maxDamage = -2400, range = 7, radius = 7, effect = 196, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_LIFEDRAIN, minDamage = -1050, maxDamage = -2850, radius = 5, effect = 208, target = true},
	{name ="combat", interval = 2000, chance = 19, type = COMBAT_MANADRAIN, minDamage = -1300, maxDamage = -2300, range = 7, radius = 6, shootEffect = 112, effect = 209, target = true},
}

monster.defenses = {
	defense = 200,
	armor = 200,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = -7},
	{type = COMBAT_EARTHDAMAGE, percent = 100},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 30},
	{type = COMBAT_MANADRAIN, percent = 27},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 9},
	{type = COMBAT_DEATHDAMAGE , percent = -10},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = false},
	{type = "earth", condition = true},
	{type = "ice", condition = false},
	{type = "drown", condition = true},
	{type = "holy", condition = false},
	{type = "death", condition = false},
	{type = "water", condition = false},
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
