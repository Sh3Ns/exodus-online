local mType = Game.createMonsterType("Classic Caravan")
local monster = {}

monster.description = "a Classic Caravan"
monster.experience = 0
monster.outfit = {
	lookType = 1507,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0
}

monster.health = 1000000
monster.maxHealth = 1000000
monster.race = "undead"
monster.raceid = 984
monster.corpse = 26691
monster.speed = 0
monster.manaCost = 0
monster.maxSummons = 0
monster.runHealth = 0

monster.changeTarget = {
	interval = 4000,
	chance = 0
}

monster.flags = {
	summonable = false,
	attackable = false,
	hostile = false,
	convinceable = false,
	pushable = false,
	isRewardBoss = false,
	illusionable = false,
	canPushItems = false,
	canPushCreatures = false,
	staticAttackChance = 0,
	targetDistance = 1,
	healthHidden = true,
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
	interval = 5000,
	chance = 0
}

monster.loot = {}
monster.attacks = {}

monster.defenses = {
	defense = 0,
	armor = 0
}

monster.elements = {}

monster.immunities = {
	{type = "paralyze", condition = true},
	{type = "outfit", condition = true},
	{type = "invisible", condition = true},
	{type = "bleed", condition = true}
}

mType.onThink = function(monster, interval)
	monster:setTarget(nil)
	monster:setFollowCreature(nil)
	return true
end

mType:register(monster)
