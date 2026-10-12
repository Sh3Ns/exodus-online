local mType = Game.createMonsterType("Phosphorus Manifestation")
local monster = {}

monster.description = "Phosphorus Manifestation"
monster.experience = 1000000
monster.outfit = {
	lookType = 1565,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 750000
monster.maxHealth = 750000
monster.race = "undead"
monster.raceid = 2202
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
	"playerAttackSound",
	"phosphoruschange"
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
	{text = "I Will crush you!", yell = true},
	{text = "Do you think you can beat me?", yell = true},
}

monster.loot = {
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1000, maxDamage = -3000},
	{name = "manifestation death tide", interval = 3000, chance = 22, minDamage = -1500, maxDamage = -2400, combatValues = true, target = false},
	{name = "manifestation arcane orbit", interval = 3500, chance = 21, minDamage = -1700, maxDamage = -2700, combatValues = true, target = false},
	{name = "manifestation abyssal sweep", interval = 2800, chance = 20, minDamage = -1800, maxDamage = -2900, combatValues = true, target = false},
	{name = "manifestation soul rain", interval = 3500, chance = 19, minDamage = -1600, maxDamage = -2600, combatValues = true, target = false},
	{name = "manifestation astral spiral", interval = 2800, chance = 18, minDamage = -2000, maxDamage = -3000, combatValues = true, target = false}
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
