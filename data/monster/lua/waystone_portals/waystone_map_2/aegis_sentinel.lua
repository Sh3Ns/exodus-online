local mType = Game.createMonsterType("Aegis Sentinel")
local monster = {}
monster.description = "a Aegis Sentinel"
monster.experience = 58000
monster.outfit = {
	lookType = 1401
}

monster.health = 40000
monster.maxHealth = 40000
monster.corpse = 26691
monster.speed = 350
monster.maxSummons = 0
monster.race = "giant"
monster.raceid = 850

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
	{id = "Crystal Coin", chance = 60000, maxCount = 7},
	{id = "advanced mana potion", chance = 19000, maxCount = 2},
	{id = "advanced health potion", chance = 19000, maxCount = 2},
	{id = "advanced spirit potion", chance = 19000, maxCount = 2},
	{id = "frostbone shard", chance = 7000, maxCount = 1},
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
	{name ="melee", interval = 2000, chance = 100, minDamage = -1500, maxDamage = -3000},
	{name ="combat", interval = 3000, chance = 9, type = COMBAT_FIREDAMAGE, minDamage = -1200, maxDamage = -2500, range = 1, effect = 361, target = false},
	{name ="condition", type = CONDITION_BEWITCHED, interval = 3000, chance = 15, minDamage = -1340, maxDamage = -2500, range = 1, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ARCANEDAMAGE, minDamage = -1000, maxDamage = -2700, radius = 4, shootEffect = 112, effect = 353, target = true},
	{name ="speed", interval = 1000, chance = 12, speed = -900, radius = 6, effect = 224, target = false, duration = 60000},
}

monster.defenses = {
	defense = 180,
	armor = 180,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = -50},
	{type = COMBAT_ENERGYDAMAGE, percent = -50},
	{type = COMBAT_EARTHDAMAGE, percent = -50},
	{type = COMBAT_FIREDAMAGE, percent = -50},
	{type = COMBAT_LIFEDRAIN, percent = -50},
	{type = COMBAT_MANADRAIN, percent = -50},
	{type = COMBAT_DROWNDAMAGE, percent = -50},
	{type = COMBAT_ICEDAMAGE, percent = -50},
	{type = COMBAT_HOLYDAMAGE , percent = -50},
	{type = COMBAT_DEATHDAMAGE , percent = -50},
	{type = COMBAT_WATERDAMAGE, percent = -50},
	{type = COMBAT_ARCANEDAMAGE, percent = -50},
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
