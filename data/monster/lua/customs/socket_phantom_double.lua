local mType = Game.createMonsterType("Socket Phantom Double")
local monster = {}

monster.description = "a phantom double"
monster.experience = 0
monster.outfit = {
	lookType = 1531,
	lookHead = 51,
	lookBody = 44,
	lookLegs = 107,
	lookFeet = 73,
	lookAddons = 3,
	lookMount = 0
}

monster.health = 2000
monster.maxHealth = 2000
monster.race = "magical"
monster.raceid = 1416
monster.corpse = 0
monster.speed = 320
monster.manaCost = 0
monster.maxSummons = 0
monster.runHealth = 0

monster.changeTarget = {
	interval = 3000,
	chance = 15
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = false,
	staticAttackChance = 90,
	targetDistance = 3,
	runHealth = 0,
	healthHidden = false,
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = false,
	pet = false
}

monster.events = {
	"playerAttackSound"
}

monster.voices = {}
monster.loot = {}

monster.attacks = {
	{name = "melee", interval = 1800, chance = 100, minDamage = -80, maxDamage = -280},
	{name = "combat", interval = 1600, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -110, maxDamage = -450, range = 5, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYAREA, target = true},
	{name = "combat", interval = 2200, chance = 18, type = COMBAT_DEATHDAMAGE, minDamage = -140, maxDamage = -430, radius = 2, effect = CONST_ME_MORTAREA, target = true},
	{name = "combat", interval = 2500, chance = 12, type = COMBAT_MANADRAIN, minDamage = -120, maxDamage = -440, radius = 2, effect = CONST_ME_PURPLEENERGY, target = true}
}

monster.defenses = {
	defense = 50,
	armor = 50,
	{name = "invisible", interval = 2000, chance = 15, effect = CONST_ME_MAGIC_BLUE}
}

monster.elements = {
	{type = COMBAT_DEATHDAMAGE, percent = 40},
	{type = COMBAT_ENERGYDAMAGE, percent = 30},
	{type = COMBAT_HOLYDAMAGE, percent = -20}
}

monster.immunities = {
	{type = "invisible", condition = true}
}

mType:register(monster)
