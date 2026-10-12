local mType = Game.createMonsterType("Bloodshade Reaper")
local monster = {}
monster.description = "a Bloodshade Reaper"
monster.experience = 43500
monster.outfit = {
	lookType = 1407
}

monster.health = 44000
monster.maxHealth = 44000
monster.corpse = 26691
monster.speed = 500
monster.maxSummons = 0
monster.race = "magical"
monster.raceid = 937

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
	targetDistance = 3,
	runHealth = 3500,
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
	{id = "gargantuan eye", chance = 7000, maxCount = 1},
	{id = "titanium bar", chance = 8000, maxCount = 2},
	{id = "giant white pearl", chance = 18000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 13000, maxCount = 2},
	{id = "giant midnight pearl", chance = 10000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 8000, maxCount = 1},
	{id = "orb of transmutation", chance = 30000, maxCount = 4},
	{id = "orb of augmentation", chance = 22000, maxCount = 4},
	{id = "regal orb", chance = 18000, maxCount = 3},
	{id = "vaal orb", chance = 15000, maxCount = 2},
	{id = "exalted orb", chance = 12000, maxCount = 2},
	{id = "chaos orb", chance = 10000, maxCount = 1},
}

monster.attacks = {
	{name ="combat", interval = 2000, chance = 100, type = COMBAT_ICEDAMAGE, minDamage = -700, maxDamage = -2230, shootEffect = 102, effect = CONST_ME_WATERSPLASH, range = 7},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_WATERDAMAGE, minDamage = -800, maxDamage = -2100, range = 7, radius = 6, shootEffect = 110, effect = 232, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_LIFEDRAIN, minDamage = -600, maxDamage = -1900, range = 7, radius = 6, shootEffect = 107, effect = 220, target = true},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_ICEDAMAGE, minDamage = -800, maxDamage = -1800, length = 5, spread = 3, effect = 282, target = false},
}

monster.defenses = {
	defense = 180,
	armor = 180,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 5},
	{type = COMBAT_ENERGYDAMAGE, percent = 5},
	{type = COMBAT_EARTHDAMAGE, percent = 5},
	{type = COMBAT_FIREDAMAGE, percent = 5},
	{type = COMBAT_LIFEDRAIN, percent = 5},
	{type = COMBAT_MANADRAIN, percent = 5},
	{type = COMBAT_DROWNDAMAGE, percent = 5},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = 5},
	{type = COMBAT_DEATHDAMAGE , percent = 5},
	{type = COMBAT_WATERDAMAGE, percent = 5},
	{type = COMBAT_ARCANEDAMAGE, percent = 5},
}

monster.immunities = {
	{type = "physical", condition = true},
	{type = "energy", condition = true},
	{type = "fire", condition = true},
	{type = "earth", condition = true},
	{type = "ice", condition = true},
	{type = "drown", condition = true},
	{type = "holy", condition = true},
	{type = "death", condition = true},
	{type = "water", condition = true},
	{type = "arcane", condition = true},
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
