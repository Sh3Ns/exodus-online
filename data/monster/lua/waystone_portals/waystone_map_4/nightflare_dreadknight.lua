local mType = Game.createMonsterType("Nightflare Dreadknight")
local monster = {}
monster.description = "a Nightflare Dreadknight"
monster.experience = 65000
monster.outfit = {
	lookType = 1420
}

monster.health = 120000
monster.maxHealth = 120000
monster.corpse = 26691
monster.speed = 400
monster.maxSummons = 0
monster.race = "undead"
monster.raceid = 1299

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
	{id = "Crystal Coin", chance = 60000, maxCount = 18},
	{id = "divine mana potion", chance = 19000, maxCount = 4},
	{id = "divine health potion", chance = 19000, maxCount = 4},
	{id = "divine spirit potion", chance = 19000, maxCount = 4},
	{id = "titanium bar", chance = 15000, maxCount = 3},
	{id = "giant white pearl", chance = 28000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 23000, maxCount = 2},
	{id = "giant midnight pearl", chance = 20000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 8000, maxCount = 1},
	{id = "orb of transmutation", chance = 35000, maxCount = 4},
	{id = "orb of augmentation", chance = 28000, maxCount = 4},
	{id = "regal orb", chance = 20000, maxCount = 3},
	{id = "vaal orb", chance = 17000, maxCount = 3},
	{id = "exalted orb", chance = 15000, maxCount = 2},
	{id = "chaos orb", chance = 13000, maxCount = 1},
	{id = "divine orb", chance = 7000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1100, maxDamage = -1950},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ARCANEDAMAGE, minDamage = -1500, maxDamage = -2850, range = 3, length = 9, spread = 3, effect = 314, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -1000, maxDamage = -3400, range = 3, length = 9, spread = 4, effect = 207, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ARCANEDAMAGE, minDamage = -800, maxDamage = -3200, radius = 8, effect = 312, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_LIFEDRAIN, minDamage = -1750, maxDamage = -2800, radius = 8, effect = 303, target = false},
	{name ="combat", interval = 3000, chance = 7, type = COMBAT_ARCANEDAMAGE, minDamage = -1000, maxDamage = -2400, length = 8, spread = 3, effect = 217, target = false},
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
