local mType = Game.createMonsterType("Phosphorus Ascendant")
local monster = {}

monster.description = "Phoshorus Ascendant"
monster.experience = 1000000
monster.outfit = {
	lookType = 1571,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 350000
monster.maxHealth = 750000
monster.race = "undead"
monster.raceid = 2206
monster.corpse = 26691
monster.speed = 550

monster.changeTarget = {
	interval = 2000,
	chance = 10
}


monster.strategiesTarget = {
	nearest = 40,
	health = 20,
	damage = 20,
	random = 20,
}
monster.events = {
	"playerAttackSound"
}
monster.flags = {
	summonable = false,
	attackable = true,
	challengeable = false,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 95,
	targetDistance = 1,
	isRewardBoss = true,
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
	{text = "Smell the fear!", yell = true},
	{text = "Im curious to see your power!", yell = true},
}

monster.loot = {
	{id = "crystal coin", chance = 100000, maxCount = 35},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "divine mana potion", chance = 35000, maxCount = 5},
	{id = "divine health potion", chance = 35000, maxCount = 5},
	{id = "divine spirit potion", chance = 35000, maxCount = 5},
	{id = "lunar ascension orb", chance = 3000},
	{id = "auric moon sigil", chance = 2000, maxCount = 2},
	{id = "figurine of Phosphorus", chance = 1000},
	{id = "moonsilver epee", chance = 500},
	{id = "moonsilver claymore", chance = 500},
	{id = "moonsilver axe", chance = 500},
	{id = "moonsilver chopper", chance = 500},
	{id = "moonsilver crusher", chance = 500},
	{id = "moonsilver mace", chance = 500},
	{id = "moonsilver channeler", chance = 500},
	{id = "moonsilver sceptre", chance = 500},
	{id = "moonsilver katar", chance = 500},
	{id = "moonsilver bow", chance = 500},
	{id = "moonsilver crossbow", chance = 500},
	{id = "giant sapphire", chance = 5000},
	{id = "giant ruby", chance = 5000},
	{id = "giant emerald", chance = 5000},
	{id = "giant topaz", chance = 5000},
	{id = "giant amethyst", chance = 5000},
	{id = "boss token", chance = 3800},
	{id = "nightmare coin", chance = 5200, maxCount = 2}
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1000, maxDamage = -4000},
	{name = "ascendant death recoil", interval = 2750, chance = 23, minDamage = -2200, maxDamage = -3400, combatValues = true, target = false},
	{name = "ascendant arcane crown", interval = 3050, chance = 22, minDamage = -2600, maxDamage = -4100, combatValues = true, target = false},
	{name = "ascendant tidal judgment", interval = 2500, chance = 21, minDamage = -2800, maxDamage = -4500, combatValues = true, target = false},
	{name = "ascendant iron extinction", interval = 2250, chance = 20, minDamage = -2400, maxDamage = -3900, combatValues = true, target = false},
	{name = "ascendant energy collapse", interval = 3500, chance = 19, minDamage = -3200, maxDamage = -5000, combatValues = true, target = false}
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
