local mType = Game.createMonsterType("Goldsnatch Goblin")
local monster = {}

monster.description = "a Goldsnatch Goblin"
monster.experience = 3200
monster.outfit = {
	lookType = 1534,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 4200
monster.maxHealth = 4200
monster.race = "humanoid"
monster.raceid = 1176
monster.corpse = 6002
monster.speed = 580
monster.manaCost = 0
monster.maxSummons = 0
monster.runHealth = 100

monster.changeTarget = {
	interval = 4000,
	chance = 0
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = false,
	convinceable = false,
	pushable = true,
	illusionable = false,
	canPushItems = false,
	canPushCreatures = false,
	staticAttackChance = 0,
	targetDistance = 10,
	runHealth = 100,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = false,
	pet = false
}

monster.events = {
	"playerAttackSound"
}

monster.voices = {
	interval = 3000,
	chance = 20,
	{text = "Too slow, tall one!", yell = false},
	{text = "Gold goes with me!", yell = false},
	{text = "You saw nothing!", yell = false}
}

monster.loot = {
	{id = "gold coin", chance = 100000, maxCount = 100},
	{id = "platinum coin", chance = 90000, maxCount = 25},
	{id = "crystal coin", chance = 18000, maxCount = 3},
	{id = 30658, chance = 25000, maxCount = 2}
}

monster.attacks = {}

monster.defenses = {
	defense = 22,
	armor = 22,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = -10},
	{type = COMBAT_FIREDAMAGE, percent = 10},
	{type = COMBAT_ICEDAMAGE, percent = -5},
	{type = COMBAT_HOLYDAMAGE, percent = 0},
	{type = COMBAT_DEATHDAMAGE, percent = 0}
}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "invisible", condition = true}
}

mType.onThink = function(monster, interval)
	monster:setTarget(nil)
	monster:setFollowCreature(nil)
	return true
end

mType:register(monster)
