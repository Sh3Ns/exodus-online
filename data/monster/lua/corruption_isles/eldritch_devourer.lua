local mType = Game.createMonsterType("Eldritch Devourer")
local monster = {}

monster.description = "a eldritch devourer"
monster.experience = 50000
monster.outfit = {
	lookType = 1474,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 50000
monster.maxHealth = 50000
monster.race = "demon"
monster.raceid = 1037
monster.corpse = 26691
monster.speed = 500
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 100,
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
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true
}

monster.light = {
	level = 0,
	color = 0
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{text = "The void hungers...", yell = false},
	{text = "Your flesh will twist like mine...", yell = false},
	{text = "*guttural bubbling*", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "warrior helmet", chance = 7560},
	{id = "orcish maul", chance = 9670},
	{id = "headchopper", chance = 13510},
	{id = "blacksteel sword", chance = 6140},
	{id = "tower shield", chance = 4920},
	{id = "green mushroom", chance = 58200, maxCount = 10},
	{id = "mercenary sword", chance = 2070},
	{id = "noble axe", chance = 2050},
	{id = "gildedheart pistil", chance = 4000},
	{id = "cinderbark pistil", chance = 4000},
	{id = "ice robe", chance = 6500},
	{id = "cranial basher", chance = 2000},
	{id = "heroic axe", chance = 2500},
	{id = "mystic blade", chance = 3000},
	{id = "blessed sceptre", chance = 2600},
	{id = "royal axe", chance = 1900},
	{id = "the justice seeker", chance = 1600},
}

monster.attacks = {
	{name = "melee", interval = 2000, chance = 100, type = COMBAT_DEATHDAMAGE, minDamage = -520, maxDamage = -1200},
	{name = "combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -320, maxDamage = -1400, radius = 3, effect = 292, target = true},
	{name = "combat", interval = 2000, chance = 15, type = COMBAT_DEATHDAMAGE, minDamage = -420, maxDamage = -1100, radius = 3, effect = 350, target = true},
	{name = "combat", interval = 2000, chance = 10, type = COMBAT_PHYSICALDAMAGE, minDamage = -650, maxDamage = -1200, radius = 2, effect = 63, target = false}
}

monster.defenses = {
	defense = 105,
	armor = 100
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 15},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 20},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 25},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -5},
	{type = COMBAT_HOLYDAMAGE , percent = -25},
	{type = COMBAT_DEATHDAMAGE , percent = 40},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
