local mType = Game.createMonsterType("Maior Domus")
local monster = {}

monster.description = "Maior Domus"
monster.experience = 750000
monster.outfit = {
	lookType = 1569,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 400000
monster.maxHealth = 400000
monster.race = "undead"
monster.raceid = 2204
monster.corpse = 26691
monster.speed = 550

monster.changeTarget = {
	interval = 2000,
	chance = 10
}


monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
}
monster.events = {
	"playerAttackSound",
	"maiordomuschange"
}
monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 95,
	targetDistance = 1,
	isRewardBoss = false,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
	pet = false
}

monster.light = {
	level = 0,
	color = 0
}

monster.summon = {

}

monster.voices = {
	interval = 5000,
	chance = 10,
	{text = "Your bones shall join the foundations of my temple.", yell = true},
	{text = "The desert is my kingdom. Your grave is already dug.", yell = true},
}

monster.loot = {
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -800, maxDamage = -2200},
	{name = "domus earthen advance", interval = 3500, chance = 20, minDamage = -1000, maxDamage = -1800, combatValues = true, target = false},
	{name = "domus crushing halo", interval = 2000, chance = 18, minDamage = -1300, maxDamage = -2200, combatValues = true, target = false},
	{name = "domus voltaic lanes", interval = 2500, chance = 17, minDamage = -1500, maxDamage = -2500, combatValues = true, target = false},
	{name = "domus tectonic sweep", interval = 3000, chance = 16, minDamage = -1100, maxDamage = -2000, combatValues = true, target = false},
	{name = "domus shrapnel floor", interval = 2800, chance = 14, minDamage = -1600, maxDamage = -2500, combatValues = true, target = false}
}

monster.defenses = {
	defense = 200,
	armor = 200,
	{name = "speed", chance = 15, interval = 2000, speed = 850, effect = CONST_ME_MAGIC_RED},
	{name ="combat", interval = 5000, chance = 25, type = COMBAT_HEALING, minDamage = 2000, maxDamage = 5250, effect = 185, target = false},
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 7},
	{type = COMBAT_EARTHDAMAGE, percent = 3},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = -11},
	{type = COMBAT_DEATHDAMAGE , percent = -4},
	{type = COMBAT_WATERDAMAGE, percent = -4},
	{type = COMBAT_ARCANEDAMAGE, percent = 18}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType.onThink = function(monster, interval)
end

mType.onAppear = function(monster, creature)
end

mType.onDisappear = function(monster, creature)
end

mType.onMove = function(monster, creature, fromPosition, toPosition)
end

mType.onSay = function(monster, creature, type, message)
end

mType:register(monster)
