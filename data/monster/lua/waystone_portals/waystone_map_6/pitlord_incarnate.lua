local mType = Game.createMonsterType("Pitlord Incarnate")
local monster = {}
monster.description = "a Pitlord Incarnate"
monster.experience = 42500
monster.outfit = {
	lookType = 1410
}

monster.health = 44000
monster.maxHealth = 44000
monster.corpse = 26691
monster.speed = 450
monster.maxSummons = 0
monster.race = "demon"
monster.raceid = 1327

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
	{id = "brainforged", chance = 7000, maxCount = 1},
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
	{name ="melee", interval = 2000, chance = 100, minDamage = -1000, maxDamage = -2200},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_LIFEDRAIN, minDamage = -870, maxDamage = -1990, radius = 4, effect = 209, target = false},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_FIREDAMAGE, minDamage = -880, maxDamage = -2610, radius = 4, effect = 200, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_FIREDAMAGE, minDamage = -780, maxDamage = -2770, effect = 234, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -700, maxDamage = -1490, length = 5, spread = 3, effect = 306, target = false}
}

monster.defenses = {
	defense = 200,
	armor = 200,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 33},
	{type = COMBAT_ENERGYDAMAGE, percent = -11},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 45},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = -30},
	{type = COMBAT_ICEDAMAGE, percent = -23},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = -44},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = true},
	{type = "earth", condition = false},
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
