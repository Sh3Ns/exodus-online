local mType = Game.createMonsterType("Plague Warbringer")
local monster = {}
monster.description = "a Plague Warbringer"
monster.experience = 65000
monster.outfit = {
	lookType = 1421
}

monster.health = 120000
monster.maxHealth = 120000
monster.corpse = 26691
monster.speed = 400
monster.maxSummons = 0
monster.race = "undead"
monster.raceid = 1328

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
	{id = "Crystal Coin", chance = 70000, maxCount = 20},
	{id = "divine mana potion", chance = 35000, maxCount = 5},
	{id = "divine health potion", chance = 35000, maxCount = 5},
	{id = "divine spirit potion", chance = 35000, maxCount = 5},
	{id = "titanium bar", chance = 25000, maxCount = 2},
	{id = "giant white pearl", chance = 28000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 23000, maxCount = 2},
	{id = "giant midnight pearl", chance = 20000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 8000, maxCount = 1},
	{id = "orb of transmutation", chance = 40000, maxCount = 5},
	{id = "orb of augmentation", chance = 36000, maxCount = 5},
	{id = "regal orb", chance = 30000, maxCount = 3},
	{id = "vaal orb", chance = 25000, maxCount = 3},
	{id = "exalted orb", chance = 20000, maxCount = 2},
	{id = "chaos orb", chance = 17000, maxCount = 2},
	{id = "divine orb", chance = 9000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1000, maxDamage = -2700},
	{name ="combat", interval = 1000, chance = 7, type = COMBAT_MANADRAIN, minDamage = -1300, maxDamage = -2400, range = 7, shootEffect = 85, target = false},
	{name ="combat", interval = 1000, chance = 13, type = COMBAT_EARTHDAMAGE, minDamage = -1850, maxDamage = -2900, radius = 8, effect = 235, target = false},
	{name ="combat", interval = 1000, chance = 10, type = COMBAT_HOLYDAMAGE, minDamage = -1250, maxDamage = -3800, radius = 8, effect = 271, target = false},
	{name ="speed", interval = 1000, chance = 12, speed = -900, radius = 6, effect = 224, target = false, duration = 60000},
	{name ="combat", interval = 1000, chance = 34, type = COMBAT_EARTHDAMAGE, minDamage = -1000, maxDamage = -3600, range = 7, radius = 7, shootEffect = 109, effect = 304, target = true}
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
