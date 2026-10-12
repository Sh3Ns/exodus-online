local mType = Game.createMonsterType("Nexlurith")
local monster = {}
monster.description = "a Nexlurith"
monster.experience = 38000
monster.outfit = {
	lookType = 1398
}

monster.health = 38000
monster.maxHealth = 38000
monster.corpse = 26691
monster.speed = 500
monster.maxSummons = 0
monster.race = "extra dimensional"
monster.raceid = 1295

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
	{id = "titanium bar", chance = 6000, maxCount = 2},
	{id = "giant white pearl", chance = 16000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 10000, maxCount = 2},
	{id = "giant midnight pearl", chance = 8000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 5000, maxCount = 1},
	{id = "orb of transmutation", chance = 15000, maxCount = 2},
	{id = "orb of augmentation", chance = 10000, maxCount = 2},
	{id = "regal orb", chance = 8000, maxCount = 1},
	{id = "vaal orb", chance = 7000, maxCount = 1},
	{id = "exalted orb", chance = 5000, maxCount = 1},
	{id = "chaos orb", chance = 3000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1150, maxDamage = -1600},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_DROWNDAMAGE, minDamage = -900, maxDamage = -1700, radius = 6, effect = 274, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ARCANEDAMAGE, minDamage = -800, maxDamage = -1900, effect = 291, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_PHYSICALDAMAGE, minDamage = -750, maxDamage = -2000, length = 4, spread = 3, effect = 336, target = false}
}

monster.defenses = {
	defense = 145,
	armor = 145,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 9},
	{type = COMBAT_ENERGYDAMAGE, percent = -6},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -11},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -13},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = 8},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = false},
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
