GuildHallPrismConfig = {
	-- Radius of prism Do not increase to much.
	DEFAULT_RADIUS = 60,
	-- Duration 3 days max before remove, so collect it before
	DEFAULT_DURATION_HOURS = 72,
	-- Loot chance by default 2%
	DEFAULT_LOOT_CHANCE = 2,
	-- Default gold obtainer per kill near the radius of prism
	DEFAULT_GOLD_PER_KILL = 4,
	-- Default exp for the guild obtained near the radius of prism killing a monster
	DEFAULT_EXP_PER_KILL = 6,
	-- Default loot slots, 30, if you want change you need change the backpack size also and the item id
	DEFAULT_LOOT_SLOTS = 30,
	-- Base of the prism, same as dynasty
	DEFAULT_BASE_ITEM_ID = 30651,
	-- Base of item once prism is placed
	DEFAULT_PLACED_ITEM_ID = 30652,
	-- Required item id to place a prism, prism core
	DEFAULT_REQUIRED_ITEM_ID = 30657,
	--- How many prism core required to place a prism , 1
	DEFAULT_REQUIRED_ITEM_COUNT = 1,
	LOCATIONS = {
		--- Locations, we added 22 locations, you can add some extras
		{ id = "prism_01", name = "Dorn Prism", position = { x = 31001, y = 31048, z = 7 }, radius = 60 },
		{ id = "prism_02", name = "Hallowfall Prism", position = { x = 31358, y = 31044, z = 7}, radius = 60 },
		{ id = "prism_03", name = "Frosthold Prism", position = {x = 30809, y = 31258, z = 7}, radius = 60 },
		{ id = "prism_04", name = "Vardenfell Prism", position = {x = 31640, y = 31266, z = 6}, radius = 60 },
		{ id = "prism_05", name = "Yalahar Plague Prism", position = {x = 32855, y = 31069, z = 8}, radius = 60 },
		{ id = "prism_06", name = "South Kilmaresh Prism", position = {x = 33759, y = 31472, z = 7}, radius = 60 },
		{ id = "prism_07", name = "Soulwar Thais Prism", position = {x = 33986, y = 31451, z = 7}, radius = 60 },
		{ id = "prism_08", name = "Bakragore Cave Prism", position = {x = 34330, y = 31232, z = 10}, radius = 60 },
		{ id = "prism_09", name = "Soulwar Turbulent Cave ", position = {x = 33749, y = 31320, z = 11}, radius = 60 },
		{ id = "prism_10", name = "Soulwar Demon Prism", position = {x = 33844, y = 31322, z = 11}, radius = 60 },
		{ id = "prism_11", name = "Rahtmora Cave Prism", position = {x = 33331, y = 31488, z = 12}, radius = 60 },
		{ id = "prism_12", name = "Roshamuul Prision Prism", position = {x = 33563, y = 32379, z = 10}, radius = 60 },
		{ id = "prism_13", name = "Roshamuul North Prism", position = {x = 33607, y = 32404, z = 7}, radius = 60 },
		{ id = "prism_14", name = "Rathleton Catacombs Prism", position = {x = 33427, y = 31789, z = 8}, radius = 60 },
		{ id = "prism_15", name = "Roshamuul Frazzlemaw Prism", position = {x = 33524, y = 32524, z = 6}, radius = 60 },
		{ id = "prism_16", name = "Corrupted Isle Prism", position = {x = 32494, y = 32603, z = 6}, radius = 60 },
		{ id = "prism_17", name = "Aquatic Overlord Prism", position = {x = 33237, y = 32117, z = 9}, radius = 60 },
		{ id = "prism_18", name = "Ferumbras Way Prism", position = {x = 33326, y = 32368, z = 13}, radius = 60 },
		{ id = "prism_19", name = "Azazel Isle Prism", position = {x = 33398, y = 31852, z = 4}, radius = 60 },
		{ id = "prism_20", name = "Cobra Bastion Prism", position = {x = 33527, y = 32671, z = 9}, radius = 60 },
		{ id = "prism_21", name = "Vorondor Isle Prism", position = {x = 33006, y = 31933, z = 7}, radius = 60 },
		{ id = "prism_22", name = "Asura Palace Prism", position = {x = 32945, y = 32678, z = 6}, radius = 60 }
	}
}
