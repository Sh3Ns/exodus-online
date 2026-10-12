local mType = Game.createMonsterType("Glacial Hellcharger")
local monster = {}
monster.description = "a Glacial Hellcharger"
monster.experience = 65000
monster.outfit = {
	lookType = 1422
}

monster.health = 120000
monster.maxHealth = 120000
monster.corpse = 26691
monster.speed = 400
monster.maxSummons = 0
monster.race = "undead"
monster.raceid = 1172

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
	{id = "Crystal Coin", chance = 60000, maxCount = 15},
	{id = "divine mana potion", chance = 19000, maxCount = 2},
	{id = "divine health potion", chance = 19000, maxCount = 2},
	{id = "divine spirit potion", chance = 19000, maxCount = 2},
	{id = "titanium bar", chance = 15000, maxCount = 2},
	{id = "giant white pearl", chance = 28000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 23000, maxCount = 2},
	{id = "giant midnight pearl", chance = 20000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 8000, maxCount = 1},
	{id = "orb of transmutation", chance = 35000, maxCount = 4},
	{id = "orb of augmentation", chance = 28000, maxCount = 4},
	{id = "regal orb", chance = 20000, maxCount = 2},
	{id = "vaal orb", chance = 17000, maxCount = 2},
	{id = "exalted orb", chance = 15000, maxCount = 1},
	{id = "chaos orb", chance = 13000, maxCount = 1},
	{id = "divine orb", chance = 7000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1500, maxDamage = -2200, condition = {type = CONDITION_SPLASHED, totalDamage = 1360, interval = 4000}},
	{name ="combat", interval = 3000, chance = 23, type = COMBAT_ICEDAMAGE, minDamage = -1400, maxDamage = -2700, range = 7, radius = 7, shootEffect = 102, effect = 359, target = true},
	{name ="combat", interval = 3500, chance = 20, type = COMBAT_MANADRAIN, minDamage = -1100, maxDamage = -2300, range = 7, radius = 6, shootEffect = 106, effect = 358, target = true},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_ICEDAMAGE, minDamage = -1000, maxDamage = -2400, range = 7, radius = 1, shootEffect = 110, effect = 300, target = true},
	{name ="combat", interval = 1200, chance = 7, type = COMBAT_WATERDAMAGE, minDamage = -900, maxDamage = -3300, length = 8, spread = 3, effect = 215, target = false},
	{name ="combat", interval = 2000, chance = 14, type = COMBAT_WATERDAMAGE, minDamage = -1300, maxDamage = -1600, length = 8, spread = 3, effect = 232, target = false}
}

monster.defenses = {
	defense = 230,
	armor = 230,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
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
