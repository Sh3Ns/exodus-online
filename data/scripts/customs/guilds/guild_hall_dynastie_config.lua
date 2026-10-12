GuildHallDynastieConfig = {
	-- Default Dynastie Core Radius
	DEFAULT_RADIUS = 80,
	-- Default Collect, it's scripted to 7 days before collect it
	DEFAULT_COLLECT_SECONDS = 7 * 24 * 60 * 60,
	-- Default Base item id, is the base item id showed on the map when there is no a dynastie core placed
	DEFAULT_BASE_ITEM_ID = 30651,
	--- Default Placed item ID of dynastie core ( sprite of dynastie core ) i have patched it into many levels, because i was wondering to create a sprite with evolutions, but missing time i used the same id on each level, you can change it if you wish.
	DEFAULT_PLACED_ITEM_ID = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL1 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL2 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL3 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL4 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL5 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL6 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL7 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL8 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL9 = 30655,
	DEFAULT_PLACED_ITEM_ID_LVL10 = 30655,
	DEFAULT_REQUIRED_ITEM_ID = 30654,
	-- The same, item required for place a Dynasty Core, can be different on each level, like increasing level item required.
	DEFAULT_REQUIRED_ITEM_ID_LVL1 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL2 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL3 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL4 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL5 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL6 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL7 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL8 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL9 = 30654,
	DEFAULT_REQUIRED_ITEM_ID_LVL10 = 30654,
	-- Quantity of item required for place a Dynasty core
	DEFAULT_REQUIRED_ITEM_COUNT = 1,
	-- Cooldown for place a core
	DEFAULT_PLACE_COOLDOWN_SECONDS = 24 * 60 * 60,
	-- Default Dynasty Tokens, 1 token per hour
	DEFAULT_TOKENS_PER_HOUR = 1,
	-- Base minimum Tax , 0%, the tax, is on the radius of the core, ALL NPC buy/sell will be taxed by the core, so example item costs 220 gold to buy, if core has 10% tax then will be 220 + 22 so 242 gold, on npc shop module windows will show the correct value 242, so 220 is the money for the NPC and the 22 goes to the Dynasty Core.
	DEFAULT_MIN_TAX = 0,
	-- Max Tax 10%
	DEFAULT_MAX_TAX = 10,
	-- Default Tax Rate
	DEFAULT_TAX_RATE = 0,
	-- Default Level of Dynasty core
	DEFAULT_LEVEL = 1,
	-- Default Maximum Level
	DEFAULT_LEVEL_CAP = 50,
	-- Default EXP per level
	DEFAULT_LEVEL_BASE_EXP = 225000,
	-- Event World Board Quest, increases 10%
	EVENT_TAX_BOOM_BONUS_PERCENT = 10,
	-- Guild EXP boost On Event, is 100 , that means x2 exp boost during the event
	EVENT_GUILD_EXP_BOOST_PERCENT = 100,
	-- Event Pet , Double Exp
	EVENT_PET_DOUBLE_EXP_MULTIPLIER = 2,
	-- World Quest Board Item ID placed on the world
	EVENT_BOARD_ITEM_ID = 30656,
	-- Event Board max quests at same time and 3 times repetition maximum per player
	EVENT_BOARD_MAX_ACCEPTED = 3,
	--- Event Board Owners Rewards, is the reward by completing 1 World Board Quest by a player that has a guild. Example you own Thais Dynasty Core, 50 players will make a small world board quest then, example 500 exp Dynasty x 50 and guildGold x 50 + dynastieTokens * 50 added to the Dyanstie core of the city.
	EVENT_BOARD_OWNER_REWARDS = {
		small = { dynastieExp = 250, guildGold = 350, dynastieTokens = 1 },
		medium = { dynastieExp = 500, guildGold = 650, dynastieTokens = 2 },
		large = { dynastieExp = 750, guildGold = 850, dynastieTokens = 3 }
	},
	-- World Quest Boards Positions
	EVENT_BOARD_POSITIONS = {
		dynastie_venore = { x = 32960, y = 32073, z = 6 },
		dynastie_thais = { x = 32373, y = 32212, z = 7 },
		dynastie_kazordoon = { x = 32612, y = 31919, z = 9 },
		dynastie_carlin = { x = 32345, y = 31773, z = 7 },
		dynastie_abdendriel = { x = 32671, y = 31662, z = 6 },
		dynastie_libertybay = { x = 32300, y = 32816, z = 7 },
		dynastie_porthope = { x = 32626, y = 32750, z = 7 },
		dynastie_ankrahmun = { x = 33157, y = 32810, z = 6 },
		dynastie_darashia = { x = 33222, y = 32423, z = 7 },
		dynastie_edron = { x = 33199, y = 31816, z = 7 },
		dynastie_svargrond = { x = 32236, y = 31138, z = 7 },
		dynastie_yalahar = { x = 32799, y = 31236, z = 7 },
		dynastie_roshamuul = { x = 33556, y = 32366, z = 7 },
		dynastie_rathleton = { x = 33630, y = 31897, z = 6 },
		dynastie_rookgaard = { x = 32095, y = 32200, z = 7 },
		dynastie_farmine = { x = 33027, y = 31536, z = 10 },
		dynastie_krailos = { x = 33634, y = 31635, z = 7 },
		dynastie_vyrsk = { x = 31165, y = 31301, z = 6 },
	},
	-- Locations of Dynastie Core, 1 per city 
	LOCATIONS = {
		{ id = "dynastie_thais", name = "Thais Dynasty", position = { x = 32373, y = 32211, z = 7 }, city = "Thais", radius = 80 },
		{ id = "dynastie_venore", name = "Venore Dynasty", position = { x = 32959, y = 32076, z = 6 }, city = "Venore", radius = 80 },
		{ id = "dynastie_kazordoon", name = "Kazordoon Dynasty", position = { x = 32609, y = 31921, z = 9 }, city = "Kazordoon", radius = 80 },
		{ id = "dynastie_carlin", name = "Carlin Dynasty", position = { x = 32345, y = 31770, z = 7 }, city = "Carlin", radius = 80 },
		{ id = "dynastie_abdendriel", name = "Ab'Dendriel Dynasty", position = { x = 32671, y = 31666, z = 8 }, city = "Ab'Dendriel", radius = 80 },
		{ id = "dynastie_edron", name = "Edron Dynasty", position = { x = 33204, y = 31822, z = 7 }, city = "Edron", radius = 80 },
		{ id = "dynastie_darashia", name = "Darashia Dynasty", position = { x = 33224, y = 32423, z = 7 }, city = "Darashia", radius = 80 },
		{ id = "dynastie_ankrahmun", name = "Ankrahmun Dynasty", position = { x = 33158, y = 32816, z = 6 }, city = "Ankrahmun", radius = 80 },
		{ id = "dynastie_libertybay", name = "Liberty Bay Dynasty", position = { x = 32300, y = 32819, z = 7 }, city = "Liberty Bay", radius = 80 },
		{ id = "dynastie_porthope", name = "Port Hope Dynasty", position = { x = 32623, y = 32755, z = 7 }, city = "Port Hope", radius = 80 },
		{ id = "dynastie_svargrond", name = "Svargrond Dynasty", position = { x = 32237, y = 31143, z = 7 }, city = "Svargrond", radius = 80 },
		{ id = "dynastie_yalahar", name = "Yalahar Dynasty", position = { x = 32796, y = 31237, z = 7 }, city = "Yalahar", radius = 80 },
		{ id = "dynastie_roshamuul", name = "Roshamuul Dynasty", position = { x = 33554, y = 32366, z = 7 }, city = "Roshamuul", radius = 80 },
		{ id = "dynastie_rathleton", name = "Rathleton Dynasty", position = { x = 33628, y = 31902, z = 6 }, city = "Rathleton", radius = 80 },
		{ id = "dynastie_rookgaard", name = "Rookgaard Dynasty", position = { x = 32094, y = 32202, z = 7 }, city = "Rookgaard", radius = 80 },
		{ id = "dynastie_farmine", name = "Farmine Dynasty", position = { x = 33020, y = 31532, z = 10 }, city = "Farmine", radius = 80 },
		{ id = "dynastie_krailos", name = "Krailos Dynasty", position = { x = 33633, y = 31637, z = 7 }, city = "Krailos", radius = 80 },
		{ id = "dynastie_vyrsk", name = "Vyrsk Dynasty", position = { x = 31162, y = 31300, z = 6 }, city = "Vyrsk", radius = 80 }
	}
}
