local mType = Game.createMonsterType("Waterglow Conjurer")
local monster = {}
monster.description = "a Waterglow Conjurer"
monster.experience = 39000
monster.outfit = {
	lookType = 1415
}

monster.health = 38500
monster.maxHealth = 38500
monster.corpse = 26691
monster.speed = 450
monster.maxSummons = 0
monster.race = "magical"
monster.raceid = 1514

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
	{id = "divine mana potion", chance = 19000, maxCount = 4},
	{id = "divine health potion", chance = 19000, maxCount = 4},
	{id = "divine spirit potion", chance = 19000, maxCount = 4},
	{id = "titanium bar", chance = 15000, maxCount = 2},
	{id = "giant white pearl", chance = 22000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 18000, maxCount = 2},
	{id = "giant midnight pearl", chance = 14000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 11000, maxCount = 1},
	{id = "orb of transmutation", chance = 50000, maxCount = 5},
	{id = "orb of augmentation", chance = 42000, maxCount = 5},
	{id = "regal orb", chance = 35000, maxCount = 4},
	{id = "vaal orb", chance = 27000, maxCount = 3},
	{id = "exalted orb", chance = 23000, maxCount = 3},
	{id = "chaos orb", chance = 17000, maxCount = 2},
	{id = "divine orb", chance = 6000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -800, maxDamage = -1650, effect = 1, range = 7, target = false},
	{name ="combat", interval = 2000, chance = 13, type = COMBAT_WATERDAMAGE, minDamage = -1000, maxDamage = -2350, length = 8, spread = 3, effect = 343, target = false},
	{name ="combat", interval = 4000, chance = 15, type = COMBAT_WATERDAMAGE, minDamage = -1000, maxDamage = -1900, radius = 3, shootEffect = 110, effect = 198, target = true},
	{name ="combat", interval = 2000, chance = 22, type = COMBAT_WATERDAMAGE, minDamage = -1000, maxDamage = -1900, range = 4, shootEffect = 114, target = true}
}

monster.defenses = {
	defense = 140,
	armor = 140,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 100},
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
