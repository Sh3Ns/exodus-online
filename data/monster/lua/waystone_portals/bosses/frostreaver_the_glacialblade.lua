local mType = Game.createMonsterType("Frostreaver the Glacialblade")
local monster = {}
monster.description = "a Frostreaver the Glacialblade"
monster.experience = 350000
monster.outfit = {
	lookType = 1427
}

monster.health = 350000
monster.maxHealth = 350000
monster.corpse = 26691
monster.speed = 850
monster.maxSummons = 0
monster.race = "giant"
monster.raceid = 1126

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
	{id = "Crystal Coin", chance = 100000, maxCount = 23},
	{id = "mythic mana potion", chance = 45000, maxCount = 6},
	{id = "mythic health potion", chance = 45000, maxCount = 6},
	{id = "mythic spirit potion", chance = 45000, maxCount = 6},
	{id = "runescribed parchment", chance = 12000, maxCount = 1},
	{id = "aethus fragment", chance = 12000, maxCount = 1},
	{id = "envenomed heart", chance = 12000, maxCount = 1},
	{id = "corrupted skull", chance = 12000, maxCount = 1},
	{id = "mystic essence", chance = 12000, maxCount = 1},
	{id = "armor shard", chance = 12000, maxCount = 1},
	{id = "runic stone shard", chance = 12000, maxCount = 1},
	{id = "myst charged stone", chance = 60000, maxCount = 3},
	{id = "seraphic charged stone", chance = 60000, maxCount = 3},
	{id = "molten charged stone", chance = 60000, maxCount = 2},
	{id = "dawnforged charged stone", chance = 60000, maxCount = 3},
	{id = "blacksmith hammer", chance = 30000, maxCount = 2},
	{id = "exalted orb", chance = 50000, maxCount = 10},
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
	{id = "chaos orb", chance = 35000, maxCount = 8},
	{id = "divine orb", chance = 20000, maxCount = 5},
	{id = "angel orb", chance = 10000, maxCount = 2},
	{id = "boss token", chance = 8000, maxCount = 2},
	{id = "exercise token", chance = 8000, maxCount = 2},
	{id = "ticket roulette", chance = 5000, maxCount = 2},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1000, maxDamage = -3000},
	{name ="glacialwave", interval = 2000, chance = 20, minDamage = -4000, maxDamage = -6000, target = false},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_ICEDAMAGE, minDamage = -2000, maxDamage = -3458, range = 7, shootEffect = 110, effect = 197, target = false},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_ENERGYDAMAGE, minDamage = -1366, maxDamage = -2570, range = 7, radius = 4, shootEffect = 103, effect = 360, target = true},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_ICEDAMAGE, minDamage = -1960, maxDamage = -3000, range = 7, shootEffect = 102, effect = 205, target = false},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_PHYSICALDAMAGE, minDamage = -1350, maxDamage = -2850, range = 7, effect = 208, target = false},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_MANADRAIN, minDamage = -999, maxDamage = -2999, range = 7, effect = 86, target = false},
	{name ="speed", interval = 2000, chance = 15, speed = -900, range = 7, effect = 294, target = false, duration = 20000}
}

monster.defenses = {
	defense = 200,
	armor = 200,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 29},
	{type = COMBAT_EARTHDAMAGE, percent = -4},
	{type = COMBAT_FIREDAMAGE, percent = -13},
	{type = COMBAT_LIFEDRAIN, percent = 15},
	{type = COMBAT_MANADRAIN, percent = 20},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 100},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 29},
	{type = COMBAT_ARCANEDAMAGE, percent = -6},
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
