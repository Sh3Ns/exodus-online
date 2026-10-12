local mType = Game.createMonsterType("Gloomstinger")
local monster = {}
monster.description = "a Gloomstinger"
monster.experience = 50000
monster.outfit = {
	lookType = 1400
}

monster.health = 44000
monster.maxHealth = 44000
monster.corpse = 26691
monster.speed = 500
monster.maxSummons = 0
monster.race = "undead"
monster.raceid = 1174

monster.changeTarget = {
	interval = 4000,
	chance = 30
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
	targetDistance = 3,
	runHealth = 5000,
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
	{name ="melee", interval = 3000, chance = 100, minDamage = -1400, maxDamage = -2500},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_EARTHDAMAGE, minDamage = -950, maxDamage = -1700, range = 6, radius = 3, shootEffect = 83, effect = 362, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_MANADRAIN, minDamage = -700, maxDamage = -1650, range = 1, effect = 353, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_DEATHDAMAGE, minDamage = -1375, maxDamage = -1700, range = 1, shootEffect = 76, target = false},
	{name ="drunk", interval = 2000, chance = 10, radius = 5, effect = 335, target = false, duration = 6000},
	{name ="condition", type = CONDITION_BLEEDING, interval = 2000, chance = 10, minDamage = -699, maxDamage = -999, radius = 8, effect = 187, target = false},
}

monster.defenses = {
	defense = 250,
	armor = 250,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 30},
	{type = COMBAT_ENERGYDAMAGE, percent = -40},
	{type = COMBAT_EARTHDAMAGE, percent = 70},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = -14},
	{type = COMBAT_DEATHDAMAGE , percent = 35},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = -22},
}

monster.immunities = {
	{type = "physical", condition = true},
	{type = "energy", condition = false},
	{type = "fire", condition = true},
	{type = "earth", condition = true},
	{type = "ice", condition = false},
	{type = "drown", condition = false},
	{type = "holy", condition = false},
	{type = "death", condition = true},
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
