local mType = Game.createMonsterType("Portal Scavenger Goblin")
local monster = {}

monster.description = "a Portal Scavenger Goblin"
monster.experience = 4000
monster.outfit = {
	lookType = 1534,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 6000
monster.maxHealth = 6000
monster.race = "humanoid"
monster.raceid = 1329
monster.corpse = 6002
monster.speed = 640
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
	{text = "Portal closing! Bye bye!", yell = false},
	{text = "No loot for you!", yell = false},
	{text = "Me vanish soon!", yell = false}
}

monster.loot = {
	{id = "gold coin", chance = 100000, maxCount = 100},
	{id = "platinum coin", chance = 100000, maxCount = 30},
	{id = "crystal coin", chance = 25000, maxCount = 4},
	{id = 30658, chance = 45000, maxCount = 4}
}

monster.attacks = {}

monster.defenses = {
	defense = 28,
	armor = 28,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 20},
	{type = COMBAT_EARTHDAMAGE, percent = -10},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE, percent = 0},
	{type = COMBAT_DEATHDAMAGE, percent = 10}
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
