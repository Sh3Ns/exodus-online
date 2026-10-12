local mType = Game.createMonsterType("Duskhorn Drake")
local monster = {}
monster.description = "a Duskhorn Drake"
monster.experience = 40000
monster.outfit = {
	lookType = 1406
}

monster.health = 37000
monster.maxHealth = 37000
monster.corpse = 26691
monster.speed = 500
monster.maxSummons = 0
monster.race = "dragon"
monster.raceid = 1029

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
	{id = "vorsk scale", chance = 7000, maxCount = 1},
	{id = "titanium bar", chance = 8000, maxCount = 2},
	{id = "giant white pearl", chance = 18000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 13000, maxCount = 2},
	{id = "giant midnight pearl", chance = 10000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 8000, maxCount = 1},
	{id = "orb of transmutation", chance = 30000, maxCount = 4},
	{id = "orb of augmentation", chance = 22000, maxCount = 4},
	{id = "regal orb", chance = 18000, maxCount = 3},
	{id = "vaal orb", chance = 15000, maxCount = 2},
	{id = "exalted orb", chance = 12000, maxCount = 2},
	{id = "chaos orb", chance = 10000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -750, maxDamage = -1500},
	{name ="condition", type = CONDITION_FIRE, interval = 1000, chance = 11, minDamage = -900, maxDamage = -1900, length = 5, spread = 3, effect = 213, target = false},
	{name ="combat", interval = 3000, chance = 15, type = COMBAT_MANADRAIN, minDamage = -850, maxDamage = -1800, length = 8, spread = 3, effect = 225, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -600, maxDamage = -1900, range = 4, radius = 1, shootEffect = 81, effect = 267, target = false},
	{name ="combat", interval = 1000, chance = 8, type = COMBAT_ENERGYDAMAGE, minDamage = -700, maxDamage = -1700, radius = 6, effect = 357, target = false}
}

monster.defenses = {
	defense = 150,
	armor = 150,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 19},
	{type = COMBAT_ENERGYDAMAGE, percent = -10},
	{type = COMBAT_EARTHDAMAGE, percent = -7},
	{type = COMBAT_FIREDAMAGE, percent = 11},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -6},
	{type = COMBAT_HOLYDAMAGE , percent = -10},
	{type = COMBAT_DEATHDAMAGE , percent = -14},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = false},
	{type = "earth", condition = false},
	{type = "ice", condition = false},
	{type = "drown", condition = false},
	{type = "holy", condition = false},
	{type = "death", condition = false},
	{type = "water", condition = false},
	{type = "arcane", condition = false},
	{type = "lifedrain", combat = false},
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
