local mType = Game.createMonsterType("Inferno Juggernaut")
local monster = {}
monster.description = "a Inferno Juggernaut"
monster.experience = 65000
monster.outfit = {
	lookType = 1423
}

monster.health = 120000
monster.maxHealth = 120000
monster.corpse = 26691
monster.speed = 400
monster.maxSummons = 0
monster.race = "undead"
monster.raceid = 1226

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
	{id = "Crystal Coin", chance = 70000, maxCount = 24},
	{id = "divine mana potion", chance = 35000, maxCount = 6},
	{id = "divine health potion", chance = 35000, maxCount = 6},
	{id = "divine spirit potion", chance = 35000, maxCount = 6},
	{id = "titanium bar", chance = 29000, maxCount = 2},
	{id = "giant white pearl", chance = 38000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 34000, maxCount = 2},
	{id = "giant midnight pearl", chance = 30000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 14000, maxCount = 1},
	{id = "orb of transmutation", chance = 50000, maxCount = 5},
	{id = "orb of augmentation", chance = 46000, maxCount = 5},
	{id = "regal orb", chance = 40000, maxCount = 3},
	{id = "vaal orb", chance = 35000, maxCount = 3},
	{id = "exalted orb", chance = 28000, maxCount = 2},
	{id = "chaos orb", chance = 22000, maxCount = 2},
	{id = "divine orb", chance = 13000, maxCount = 1},
	{id = "angel orb", chance = 5000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1000, maxDamage = -2500},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -1960, maxDamage = -3250, range = 8, shootEffect = 97, target = true},
	{name ="combat", interval = 1000, chance = 15, type = COMBAT_LIFEDRAIN, minDamage = -1800, maxDamage = -4000, shootEffect = 98, range = 8, target = false},
	{name ="combat", interval = 1000, chance = 13, type = COMBAT_FIREDAMAGE, minDamage = -1200, maxDamage = -3490, range = 8, shootEffect = 84, effect = 234, target = false},
	{name ="combat", interval = 1000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -1420, maxDamage = -2777, range = 8, shootEffect = 104, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_DROWNDAMAGE, minDamage = -1150, maxDamage = -3800, radius = 8, effect = 352, target = false},
	{name ="condition", type = CONDITION_FIRE, interval = 2000, chance = 10, minDamage = -1280, maxDamage = -1950, radius = 8, effect = 348, target = false},
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
