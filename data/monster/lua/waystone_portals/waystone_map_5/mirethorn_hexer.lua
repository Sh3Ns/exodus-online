local mType = Game.createMonsterType("Mirethorn Hexer")
local monster = {}
monster.description = "a Mirethorn Hexer"
monster.experience = 39000
monster.outfit = {
	lookType = 1413
}

monster.health = 38500
monster.maxHealth = 38500
monster.corpse = 26691
monster.speed = 450
monster.maxSummons = 0
monster.race = "magical"
monster.raceid = 1270

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
	{id = "verdant scale", chance = 9000, maxCount = 1},
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
	{name ="melee", interval = 2000, chance = 100, minDamage = -850, maxDamage = -1950, effect = 1, range = 7, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -750, maxDamage = -2200, radius = 4, effect = 181, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -950, maxDamage = -2300, range = 7, shootEffect = 105, effect = 196, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -1000, maxDamage = -2480, range = 7, shootEffect = 101, effect = 199, target = false}
}

monster.defenses = {
	defense = 140,
	armor = 140,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 100},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 0},
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
