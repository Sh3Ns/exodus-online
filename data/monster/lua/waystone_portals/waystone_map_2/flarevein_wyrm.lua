local mType = Game.createMonsterType("Flarevein Wyrm")
local monster = {}
monster.description = "a Flarevein Wyrm"
monster.experience = 65000
monster.outfit = {
	lookType = 1403
}

monster.health = 110000
monster.maxHealth = 110000
monster.corpse = 26691
monster.speed = 500
monster.maxSummons = 0
monster.race = "dragon"
monster.raceid = 1105

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
	{id = "titanium bar", chance = 6000, maxCount = 2},
	{id = "giant white pearl", chance = 16000, maxCount = 2},
	{id = "giant sky blue pearl", chance = 10000, maxCount = 2},
	{id = "giant midnight pearl", chance = 8000, maxCount = 1},
	{id = "diamond ring in a shell", chance = 5000, maxCount = 1},
	{id = "orb of transmutation", chance = 35000, maxCount = 3},
	{id = "orb of augmentation", chance = 25000, maxCount = 3},
	{id = "regal orb", chance = 20000, maxCount = 2},
	{id = "vaal orb", chance = 16000, maxCount = 2},
	{id = "exalted orb", chance = 12000, maxCount = 1},
	{id = "chaos orb", chance = 8000, maxCount = 1},
	{id = "divine orb", chance = 4000, maxCount = 1},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -800, maxDamage = -2000},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_LIFEDRAIN, minDamage = -700, maxDamage = -2400, length = 10, spread = 3, effect = 208, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_DEATHDAMAGE, minDamage = -650, maxDamage = -2300, radius = 4, effect = 353, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -1000, maxDamage = -2400, radius = 4, shootEffect = 36, effect = 257, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -1000, maxDamage = -2900, length = 10, spread = 3, effect = 360, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_FIREDAMAGE, minDamage = -450, maxDamage = -1900, radius = 6, shootEffect = 340, effect = 60, target = true}
}

monster.defenses = {
	defense = 200,
	armor = 200,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 100},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 100},
	{type = COMBAT_ICEDAMAGE, percent = -10},
	{type = COMBAT_HOLYDAMAGE , percent = 3},
	{type = COMBAT_DEATHDAMAGE , percent = 18},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = -60},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = true},
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
