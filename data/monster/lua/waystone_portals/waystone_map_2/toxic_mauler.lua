local mType = Game.createMonsterType("Toxic Mauler")
local monster = {}
monster.description = "a Toxic Mauler"
monster.experience = 39000
monster.outfit = {
	lookType = 1402
}

monster.health = 40000
monster.maxHealth = 40000
monster.corpse = 26691
monster.speed = 450
monster.maxSummons = 0
monster.race = "magical"
monster.raceid = 1472

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
	{name ="melee", interval = 200, chance = 20, minDamage = -800, maxDamage = -1400},
	{name ="combat", interval = 200, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -1150, maxDamage = -1700, effect = 363, target = false},
	{name ="combat", interval = 500, chance = 10, type = COMBAT_EARTHDAMAGE, minDamage = -1120, maxDamage = -1500, length = 8, spread = 3, effect = 366, target = true},
	{name ="combat", interval = 500, chance = 10, type = COMBAT_EARTHDAMAGE, minDamage = -1000, maxDamage = -3000, radius = 8, effect = 367, target = false}
}

monster.defenses = {
	defense = 150,
	armor = 150,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 9},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 37},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = -20},
	{type = COMBAT_WATERDAMAGE, percent = -11},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = false},
	{type = "earth", condition = true},
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
