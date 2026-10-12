local mType = Game.createMonsterType("Vladrukh")
local monster = {}

monster.description = "Vladrukh"
monster.experience = 300000
monster.outfit = {
	lookType = 1443,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 450000
monster.maxHealth = 450000
monster.race = "undead"
monster.raceid = 1501
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
	"playerAttackSound"
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
	{text = "I Will crush you!", yell = true},
	{text = "Do you think you can beat me?", yell = true},
}

monster.loot = {
	{id = "crystal coin", chance = 100000, maxCount = 35},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "divine mana potion", chance = 35000, maxCount = 5},
	{id = "divine health potion", chance = 35000, maxCount = 5},
	{id = "divine spirit potion", chance = 35000, maxCount = 5},
	{id = "norcferatu skullguard", chance = 2000},
	{id = "norcferatu bonehood", chance = 2000},
	{id = "norcferatu tuskplate", chance = 2000},
	{id = "norcferatu bloodhide", chance = 2000},
	{id = "norcferatu bonecloak", chance = 2000},
	{id = "norcferatu thornwraps", chance = 2000},
	{id = "norcferatu bloodstrider", chance = 2000},
	{id = "norcferatu fleshguards", chance = 2000},
	{id = "norcferatu goretrampers", chance = 2000},
	{id = "norcferatu fangstompers", chance = 2000},
	{id = "greater garlic necklace", chance = 25000},
	-- Wheel of Destiny gems
	{id = 27151, chance = 10000}, -- Guardian Gem
	{id = 27154, chance = 10000}, -- Marksman Gem
	{id = 27157, chance = 10000}, -- Sage Gem
	{id = 27160, chance = 10000}, -- Mystic Gem
	{id = 30914, chance = 10000}, -- Spiritualist Gem
	{id = 27152, chance = 5000}, -- Greater Guardian Gem
	{id = 27155, chance = 5000}, -- Greater Marksman Gem
	{id = 27158, chance = 5000}, -- Greater Sage Gem
	{id = 27161, chance = 5000}, -- Greater Mystic Gem
	{id = 30915, chance = 5000}, -- Greater Spiritualist Gem
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1100, maxDamage = -2400},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_LIFEDRAIN, minDamage = -900, maxDamage = -1800, length = 10, spread = 3, effect = 321, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -1200, maxDamage = -1800, radius = 4, effect = 336, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -1400, maxDamage = -1900, radius = 4, shootEffect = 83, effect = 352, target = true},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -1100, maxDamage = -2900, length = 10, spread = 3, effect = 238, target = false},
}

monster.defenses = {
	defense = 225,
	armor = 225,
	{name = "speed", chance = 15, interval = 2000, speed = 850, effect = CONST_ME_MAGIC_RED},
	{name ="combat", interval = 2000, chance = 25, type = COMBAT_HEALING, minDamage = 800, maxDamage = 2250, effect = 185, target = false},
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
