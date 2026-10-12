local mType = Game.createMonsterType("Rhazgor the Crimson Slayer")
local monster = {}
monster.description = "a Rhazgor the Crimson Slayer"
monster.experience = 400000
monster.outfit = {
	lookType = 1428
}

monster.health = 400000
monster.maxHealth = 400000
monster.corpse = 26691
monster.speed = 850
monster.maxSummons = 0
monster.race = "giant"
monster.raceid = 1343

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
	{id = "Crystal Coin", chance = 100000, maxCount = 35},
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
	{id = "myst charged stone", chance = 60000, maxCount = 4},
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
	{id = "seraphic charged stone", chance = 60000, maxCount = 4},
	{id = "molten charged stone", chance = 60000, maxCount = 4},
	{id = "dawnforged charged stone", chance = 60000, maxCount = 4},
	{id = "blacksmith hammer", chance = 30000, maxCount = 2},
	{id = "myst emblem", chance = 30000, maxCount = 1},
	{id = "seraphic emblem", chance = 30000, maxCount = 1},
	{id = "molten emblem", chance = 30000, maxCount = 1},
	{id = "dawnforged emblem", chance = 30000, maxCount = 1},
	{id = "empowered stone shard", chance = 30000, maxCount = 1},
	{id = "exalted orb", chance = 50000, maxCount = 12},
	{id = "chaos orb", chance = 35000, maxCount = 10},
	{id = "divine orb", chance = 20000, maxCount = 7},
	{id = "angel orb", chance = 10000, maxCount = 2},
	{id = "boss token", chance = 8000, maxCount = 2},
	{id = "exercise token", chance = 8000, maxCount = 2},
	{id = "ticket roulette", chance = 5000, maxCount = 2},
}

monster.attacks = {
	{name ="melee", interval = 2000, type = COMBAT_PHYSICALDAMAGE, chance = 100, minDamage = -1800, maxDamage = -3300},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_DEATHDAMAGE, minDamage = -1800, maxDamage = -3600, radius = 4, shootEffect = 114, effect = 158, target = true},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_FIREDAMAGE, minDamage = -2000, maxDamage = -3600, length = 8, spread = 3, effect = 277, target = false},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_FIREDAMAGE, minDamage = -2600, maxDamage = -3900, length = 8, spread = 3, effect = 226, target = false},
	{name ="rhazgorSummon", interval = 2000, chance = 15, minDamage = -4000, maxDamage = -6500, target = false},
	{name ="globalSkillReducer", interval = 2000, chance = 10, target = false},
}

monster.defenses = {
	defense = 200,
	armor = 200,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = -18},
	{type = COMBAT_EARTHDAMAGE, percent = -3},
	{type = COMBAT_FIREDAMAGE, percent = 85},
	{type = COMBAT_LIFEDRAIN, percent = 20},
	{type = COMBAT_MANADRAIN, percent = 20},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -14},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = -26},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = true},
	{type = "earth", condition = false},
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
