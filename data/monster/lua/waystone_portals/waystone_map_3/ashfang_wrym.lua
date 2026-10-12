local mType = Game.createMonsterType("Ashfang Wrym")
local monster = {}
monster.description = "a Ashfang Wrym"
monster.experience = 43000
monster.outfit = {
	lookType = 1418
}

monster.health = 43000
monster.maxHealth = 43000
monster.corpse = 26691
monster.speed = 450
monster.maxSummons = 0
monster.race = "dragon"
monster.raceid = 904

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
	illusionable = true,
	canPushItems = true,
	canPushCreatures = false,
	staticAttackChance = 90,
	targetDistance = 1,
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
	{id = "Crystal Coin", chance = 60000, maxCount = 7},
	{id = "advanced mana potion", chance = 19000, maxCount = 2},
	{id = "advanced health potion", chance = 19000, maxCount = 2},
	{id = "advanced spirit potion", chance = 19000, maxCount = 2},
	{id = "fortune sack", chance = 15000, maxCount = 4},
	{id = "blood essence", chance = 8000, maxCount = 3},
	{id = "titanium bar", chance = 8000, maxCount = 2},
	{id = "giant white pearl", chance = 18000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 13000, maxCount = 2},
	{id = "giant midnight pearl", chance = 10000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 8000, maxCount = 1},
	{id = "orb of transmutation", chance = 20000, maxCount = 4},
	{id = "orb of augmentation", chance = 15000, maxCount = 4},
	{id = "regal orb", chance = 12000, maxCount = 2},
	{id = "vaal orb", chance = 10000, maxCount = 2},
	{id = "exalted orb", chance = 8000, maxCount = 1},
	{id = "chaos orb", chance = 7000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1000, maxDamage = -1800},
	{name ="combat", interval = 2000, chance = 30, type = COMBAT_FIREDAMAGE, minDamage = -1000, maxDamage = -1620, range = 7, radius = 4, shootEffect = 104, effect = 206, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_DEATHDAMAGE, minDamage = -1000, maxDamage = -1800, range = 7, shootEffect = 99, effect = 322, target = true},
	{name ="firefield", interval = 2000, chance = 10, range = 7, radius = 4, shootEffect = CONST_ANI_FIRE, target = true},
	{name ="combat", interval = 2000, chance = 22, type = COMBAT_FIREDAMAGE, minDamage = -850, maxDamage = -1870, length = 8, spread = 3, effect = 311, target = false}
}

monster.defenses = {
	defense = 140,
	armor = 140,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 14},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 17},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -12},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 7},
	{type = COMBAT_WATERDAMAGE, percent = -15},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = true},
	{type = "earth", condition = false},
	{type = "ice", condition = false},
	{type = "drown", condition = false},
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
