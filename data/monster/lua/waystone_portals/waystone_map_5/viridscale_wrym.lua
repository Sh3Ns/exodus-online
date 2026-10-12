local mType = Game.createMonsterType("Viridscale Wrym")
local monster = {}
monster.description = "a Viridscale Wrym"
monster.experience = 43000
monster.outfit = {
	lookType = 1417
}

monster.health = 40000
monster.maxHealth = 40000
monster.corpse = 26691
monster.speed = 450
monster.maxSummons = 0
monster.race = "dragon"
monster.raceid = 1500

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
	{id = "divine mana potion", chance = 19000, maxCount = 3},
	{id = "divine health potion", chance = 19000, maxCount = 3},
	{id = "divine spirit potion", chance = 19000, maxCount = 3},
	{id = "titanium bar", chance = 10000, maxCount = 2},
	{id = "giant white pearl", chance = 20000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 16000, maxCount = 2},
	{id = "giant midnight pearl", chance = 13000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 10000, maxCount = 1},
	{id = "orb of transmutation", chance = 40000, maxCount = 4},
	{id = "orb of augmentation", chance = 32000, maxCount = 4},
	{id = "regal orb", chance = 28000, maxCount = 3},
	{id = "vaal orb", chance = 21000, maxCount = 2},
	{id = "exalted orb", chance = 18000, maxCount = 2},
	{id = "chaos orb", chance = 12000, maxCount = 1},
	{id = "divine orb", chance = 4000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -800, maxDamage = -1600},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_EARTHDAMAGE, minDamage = -640, maxDamage = -1980, length = 4, spread = 3, effect = 362, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_HOLYDAMAGE, minDamage = -700, maxDamage = -1950, range = 7, shootEffect = 103, effect = 360, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_HOLYDAMAGE, minDamage = -950, maxDamage = -2100, range = 7, shootEffect = 106, effect = 223, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_EARTHDAMAGE, minDamage = -700, maxDamage = -1880, radius = 4, effect = 188, target = true},
}

monster.defenses = {
	defense = 140,
	armor = 140,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = -10},
	{type = COMBAT_EARTHDAMAGE, percent = 13},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = -11},
	{type = COMBAT_WATERDAMAGE, percent = -7},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = false},
	{type = "earth", condition = true},
	{type = "ice", condition = false},
	{type = "drown", condition = false},
	{type = "holy", condition = true},
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
