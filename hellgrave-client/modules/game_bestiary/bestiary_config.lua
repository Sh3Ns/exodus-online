Bestiary = {}
BESTIARY_OPCODE = 61

Bestiary.categories = {}
Bestiary.categoryCreaturesCache = {}
Bestiary.creatureInfoCache = {}
Bestiary.killsCache = {}
Bestiary.trackedCreatures = {}

--- Config
BESTIARY_MAX_TRACKED_CREATURES = 10
BESTIARY_DISPLAY_STATS_AT_PERCENT = 100
BESTIARY_DISPLAY_DEFENSES_AT_PERCENT = 100
BESTIARY_FETCH_LIMIT = 20
BESTIARY_LOOT_FETCH_LIMIT = 12
Bestiary.currentCategoryPage = 1

BESTIARY_NO_BONUS_TEXT = "No Bonus"

Bestiary.categoriesDisplay = {
	{id = 1, name = "Amphibic", display = {card = "images/cards/Amphibic"}},
	{id = 2, name = "Aquatic", display = {card = "images/cards/Aquatic"}},
	{id = 3, name = "Birds", display = {card = "images/cards/Bird"}},
	{id = 4, name = "Construct", display = {card = "images/cards/Construct"}},
	{id = 5, name = "Demons", display = {card = "images/cards/Demon"}},
	{id = 6, name = "Dragons", display = {card = "images/cards/Dragon"}},
	{id = 7, name = "Elementals", display = {card = "images/cards/Elemental"}},
	{id = 8, name = "Extra Dimensionals", display = {card = "images/cards/Extra_Dimensional"}},
	{id = 9, name = "Fey", display = {card = "images/cards/Fey"}},
	{id = 10, name = "Giants", display = {card = "images/cards/Giant"}},
	{id = 11, name = "Humans", display = {card = "images/cards/Human"}},
	{id = 12, name = "Humanoids", display = {card = "images/cards/Humanoid"}},
	{id = 13, name = "Inkborn", display = {card = "images/cards/Humanoid"}},
	{id = 14, name = "Lycanthropes", display = {card = "images/cards/Lycanthrope"}},
	{id = 15, name = "Magical", display = {card = "images/cards/Magical"}},
	{id = 16, name = "Mammals", display = {card = "images/cards/Mammal"}},
	{id = 17, name = "Plants", display = {card = "images/cards/Plant"}},
	{id = 18, name = "Reptiles", display = {card = "images/cards/Reptile"}},
	{id = 19, name = "Slimes", display = {card = "images/cards/Slime"}},
	{id = 20, name = "Undead", display = {card = "images/cards/Undead"}},
	{id = 21, name = "Vermin", display = {card = "images/cards/Vermin"}},
	{id = 22, name = "Bosses Bane", display = {card = "images/cards/BossesBane"}},
	{id = 23, name = "Bosses Archfoe", display = {card = "images/cards/BossesArchfoe"}},
	{id = 24, name = "Bosses Nemesis", display = {card = "images/cards/BossesNemesis"}},
	{id = 25, name = "Bosses Apex", display = {card = "images/cards/BossesApex"}},
}

Bestiary.lootDisplayConfig = {
	{ progressPercent = 100, minItemChance = 0 },
	{ progressPercent = 75, minItemChance = 10 },
	{ progressPercent = 50, minItemChance = 25 },
	{ progressPercent = 25, minItemChance = 50 },
	{ progressPercent = 0, minItemChance = nil },
}

Bestiary.charmsInfo = {
	["1"] = {
		["name"] = "Adrenaline Burst",
		["image"] = "Adrenaline_Burst",
		["pointsPrice"] = 650,
		["description"] = "Bursts of adrenaline enhance your reflexes with a 6% chance after getting hit and lets you move faster for 10 seconds."
	},
	["2"] = {
		["name"] = "Zap",
		["image"] = "Zap",
		["pointsPrice"] = 950,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Energy Damage once."
	},
	["3"] = {
		["name"] = "Wound",
		["image"] = "Wound",
		["pointsPrice"] = 750,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Physical Damage once."
	},
	["4"] = {
		["name"] = "Void Inversion",
		["image"] = "Void_Inversion",
		["pointsPrice"] = 650,
		["description"] = "20% chance to gain mana instead of losing it when taking Mana Drain damage."
	},
	["5"] = {
		["name"] = "Poison",
		["image"] = "Poison",
		["pointsPrice"] = 750,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Earth Damage once."
	},
	["6"] = {
		["name"] = "Parry",
		["image"] = "Parry",
		["pointsPrice"] = 1150,
		["description"] = "Any damage taken has a 5% chance to be reflected to the aggressor as Physical Damage."
	},
	["7"] = {
		["name"] = "Overpower",
		["image"] = "Overpower",
		["pointsPrice"] = 1650,
		["description"] = "Each attack has a 5% chance to deal Physical Damage equal to 5% of your maximum health."
	},
	["8"] = {
		["name"] = "Overflux",
		["image"] = "Overflux",
		["pointsPrice"] = 1650,
		["description"] = "Each attack has a 5% chance to deal Physical Damage equal to 2.5% of your maximum mana."
	},
	["9"] = {
		["name"] = "Numb",
		["image"] = "Numb",
		["pointsPrice"] = 650,
		["description"] = "Numbs the creature with a 6% chance after its attack and paralyses the creature for 10 seconds."
	},
	["10"] = {
		["name"] = "Freeze",
		["image"] = "Freeze",
		["pointsPrice"] = 950,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Ice Damage once."
	},
	["11"] = {
		["name"] = "Enflame",
		["image"] = "Enflame",
		["pointsPrice"] = 1150,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Fire Damage once."
	},
	["12"] = {
		["name"] = "Dodge",
		["image"] = "Dodge",
		["pointsPrice"] = 750,
		["description"] = "Dodges an attack with a 5% chance, taking no damage at all."
	},
	["13"] = {
		["name"] = "Divine Wrath",
		["image"] = "Divine_Wrath",
		["pointsPrice"] = 1650,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Holy Damage once."
	},
	["14"] = {
		["name"] = "Curse",
		["image"] = "Curse",
		["pointsPrice"] = 1050,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Death Damage once."
	},
	["15"] = {
		["name"] = "Cripple",
		["image"] = "Cripple",
		["pointsPrice"] = 650,
		["description"] = "Cripples the creature with a 6% chance and paralyses it for 10 seconds."
	},
	["16"] = {
		["name"] = "Carnage",
		["image"] = "Carnage",
		["pointsPrice"] = 1650,
		["description"] = "Killing a monster has 10% chance to deal Physical Damage equal to 15% of its maximum health to all monsters in a small radius."
	},
	["17"] = {
		["name"] = "Splash",
		["image"] = "Splash",
		["pointsPrice"] = 1050,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 5% of its maximum Hit Points as Water Damage once."
	},
	["18"] = {
		["name"] = "Abyss",
		["image"] = "Abyss",
		["pointsPrice"] = 1050,
		["description"] = "Each attack on a creature has a 5% chance to trigger and deal 6% of its maximum Hit Points as Arcane Damage once."
	},
}