local mType = Game.createMonsterType("Moonspawn Oozecrown")
local monster = {}

monster.description = "a Moonspawn Oozecrown"
monster.experience = 35000
monster.outfit = {
	lookType = 1557,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 36700
monster.maxHealth = 36700
monster.race = "plant"
monster.raceid = 2195
monster.corpse = 26691
monster.speed = 400
monster.manaCost = 0
monster.maxSummons = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10
}

monster.strategiesTarget = {
	nearest = 60,
	health = 10,
	damage = 30,
	random = 0,
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
	canWalkOnPoison = true,
	pet = false
}

monster.light = {
	level = 0,
	color = 0
}

monster.voices = {
	interval = 7000,
	chance = 30,
	{text = "<Blrrrpp>", yell = true},
	{text = "<Pffshhht>", yell = true},
	{text = "<Shlooom>", yell = true}
}

monster.loot = {
	{id = "crystal coin", chance = 83000, maxCount = 4},
	{id = "platinum coin", chance = 98000, maxCount = 30},
	{id = "advanced mana potion", chance = 35000, maxCount = 2},
	{id = "advanced health potion", chance = 35000, maxCount = 2},
	{id = "advanced spirit potion", chance = 35000, maxCount = 2},
	{id = "mushroom pie", chance = 10400},
	{id = "dark mushroom", chance = 3800},
	{id = "yellow gem", chance = 2900},
	{id = "wand of decay", chance = 1900},
	{id = "lunar staff", chance = 940},
	{id = "magic sulphur", chance = 470},
	{id = "mushroom backpack", chance = 470},
	{id = "moonspawn tentacle", chance = 5000},
	{id = "moonspawn headpiece", chance = 4500}
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -450, maxDamage = -1870},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_DEATHDAMAGE, minDamage = -650, maxDamage = -1750, length = 8, spread = 3, effect = 450, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_ENERGYDAMAGE, minDamage = -580, maxDamage = -1555, shootEffect = 127, target = true},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_EARTHDAMAGE, minDamage = -666, maxDamage = -1420, length = 8, spread = 3, effect = 431, target = false}
	}

monster.defenses = {
	defense = 100,
	armor = 80,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = -5},
	{type = COMBAT_ENERGYDAMAGE, percent = 5},
	{type = COMBAT_EARTHDAMAGE, percent = 28},
	{type = COMBAT_FIREDAMAGE, percent = -8},
	{type = COMBAT_LIFEDRAIN, percent = 100},
	{type = COMBAT_MANADRAIN, percent = 100},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = -6},
	{type = COMBAT_HOLYDAMAGE , percent = -6},
	{type = COMBAT_DEATHDAMAGE , percent = 10},
	{type = COMBAT_WATERDAMAGE , percent = 0},
	{type = COMBAT_ARCANEDAMAGE , percent = -5}
}

monster.immunities = {
	{type = "paralyze", condition = false},
	{type = "outfit", condition = false},
	{type = "invisible", condition = true},
	{type = "bleed", condition = false}
}

mType:register(monster)
