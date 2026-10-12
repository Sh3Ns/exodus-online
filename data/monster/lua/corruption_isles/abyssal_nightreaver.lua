local mType = Game.createMonsterType("Abyssal Nightreaver")
local monster = {}

monster.description = "a abyssal nightreaver"
monster.experience = 42500
monster.outfit = {
	lookType = 1493,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 38000
monster.maxHealth = 38000
monster.race = "demon"
monster.raceid = 848
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
	targetDistance = 3,
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
	{text = "Screeeech!", yell = false},
	{text = "Darkness descends!", yell = false},
	{text = "Your fear feeds me!", yell = false}
}

monster.loot = {
	{id = "platinum coin", chance = 40000, maxCount = 99},
	{id = "crystal coin", chance = 60000},
	{id = "divine mana potion", chance = 31500, maxCount = 2},
	{id = "divine health potion", chance = 31500, maxCount = 2},
	{id = "divine spirit potion", chance = 31500, maxCount = 2},
	{id = "boots of haste", chance = 2800},
	{id = "demon shield", chance = 2100},
	{id = "fractured aether", chance = 7000},
	{id = "crystallized aether", chance = 4000},
	{id = "aether essence", chance = 2000},
	{id = "devil helmet", chance = 11000},
	{id = "dragon hammer", chance = 22500},
	{id = "fire axe", chance = 9000},
	{id = "gold ring", chance = 2800},
	{id = "falcon shield", chance = 700},
	{id = "naga tanko", chance = 700},
	{id = "glooth club", chance = 10500},
	{id = "venerable cloth", chance = 3000},
	{id = "old stick", chance = 4000, maxCount = 2},
}

monster.attacks = {
	{name ="combat", interval = 2000, chance = 100, type = COMBAT_DEATHDAMAGE, minDamage = -320, maxDamage = -1180, range = 7, shootEffect = 127, effect = 386, target = true},
	{name ="combat", interval = 2000, chance = 18, type = COMBAT_PHYSICALDAMAGE, minDamage = -580, maxDamage = -1220, range = 3, radius = 4, effect = 123, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_DEATHDAMAGE, minDamage = -320, maxDamage = -1650,
	length = 6, spread = 2, effect = 369, target = false},
	{name ="combat", interval = 2000, chance = 15, type = COMBAT_LIFEDRAIN,	minDamage = -200, maxDamage = -950, range = 5,
	effect = 244, target = true}
}

monster.defenses = {
	defense = 95,
	armor = 90
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 10},
	{type = COMBAT_ENERGYDAMAGE, percent = 10},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = -10},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 20},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 5},
	{type = COMBAT_HOLYDAMAGE , percent = -20},
	{type = COMBAT_DEATHDAMAGE , percent = 65},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = 15}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
