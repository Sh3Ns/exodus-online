local function create(api)
	local eventsApi = {}

	local weekdayNames = {
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday",
		"Sunday"
	}

	local cityDefinitions = {
		[1] = "Thais",
		[2] = "Venore",
		[3] = "Kazordoon",
		[4] = "Carlin",
		[5] = "Ab'Dendriel",
		[6] = "Liberty Bay",
		[7] = "Port Hope",
		[8] = "Ankrahmun",
		[9] = "Darashia",
		[10] = "Edron",
		[11] = "Svargrond",
		[12] = "Yalahar",
		[13] = "Roshamuul",
		[14] = "Rathleton",
		[15] = "Rookgaard",
		[16] = "Farmine",
		[17] = "Krailos",
		[18] = "Vyrsk"
	}

	local boostedCreaturePool = {
	"Brachiodemon", "Infernal Demon", "Infernal Phantom", "Branchy Crawler", "Mould Phantom", "Rotten Golem", "Bony Sea Devil", "Capricious Phantom", "Hazardous Phantom", "Turbulent Elemental", "Cloak Of Terror", "Courage Leech", "Vibrant Phantom", "Distorted Phantom", "Creepy Crawler", "Crypt Construct", "Crypt Fiend", "Crypt Mage", "Cyclursus", "Gloom Maw", "Night Harpy", "Orclops Bloodbreaker", "Roaming Dread", "Varg", "Walking Dread", "Alpha Demon", "Azure Guard", "Black Dragon", "Brontosaurus", "Butcher Ogre", "Colossal Ice Monkey", "Demon of the Depths", "Giant Hornet", "Netheria Dragon", "Reflect Spider", "Rhino of the depths", "Ruthless Spider", "Skullcrusher Demon", "Venom Spider", "Converter", "Darklight Construct", "Darklight Emitter", "Darklight Matter", "Darklight Source", "Darklight Striker", "Elder Bloodjaw", "Feral Werecrocodile", "Meandering Mushroom", "Mycobiontic Beetle", "Oozing Carcass", "Oozing Corpus", "Sopping Carcass", "Sopping Corpus", "Walking Pillar", "Wandering Pillar", "Usurper Archer", "Usurper Knight", "Usurper Warlock", "Abyssal Nightreaver", "Ancient Moss Guardian", "Ancient Root Tyrant", "Arcaneseer Djinn", "Ashen Hellhound", "Blacksteel Brute", "Bladecoil Stalker", "Brood Abomination", "Cinderheaart Abomination", "Cursed Voidcaller", "Dreadhorn Ravager", "Dunestalker Hunter", "Eldritch Devourer", "Emberflame Conjurer", "Hellscythe Reaver", "Hive Widow", "Ironburrow Devourer", "Magmafang Incinerator", "Necroflame Idol", "Shardback Behemoth", "Spineback Devourer", "Stonehide Ravager", "Stormfang Ravager", "Totem Warbeast", "Venom Ooze", "Venomcoil Automaton", "Verdant Rootwalker", "Void Ooze", "Voltstrike Hound", "Armored Giant", "Axebringer Fiend", "Enforced Mountain Goblin", "Hooded Colossus", "Mountain Goblin", "Spiked Enforcer", "Swamp Monster", "Tomb Zombie", "Wild Boar", "Frost Hydra", "Frost Larva", "Frost Spider", "Frosted Dragon", "Giant Lursk Spider", "Bloodthirst Bulgeye", "Bogspike Lancer", "Mossblade Hopper", "Mystic Baguemage", "Sunfang Croaker", "Arbaziloth master", "Arbaziloth", "Belomimus", "Bloodfang Reaver", "Bonecrusher", "Brinebrute Inferniarch", "Broodrider Inferniarch", "Demibeast", "Gralvalon", "Grave Sentinel", "Hedgehog", "Hellhunet Inferniarch", "Helm Hunter", "Malvaroth", "Pale Lancer", "Sineater Inferniarch", "Spellreaper Inferniarch", "Stonebark Titan", "Tomb guardian", "Twisterror", "Wraith Archer", "Bat Gobline", "Charged mechanic Goblin", "Mechanic Goblin", "Mounted Archer Goblin", "Mounted Mage Goblin", "Mounted Warrior Goblin", "Thief Goblin", "Aeliana", "Archon", "Baalzebul", "Lyrael", "Nyxion", "Oroniel", "Sagittarius", "Seraphiel", "Fangclaw", "Lurkskin", "Scalebreaker", "Slinkhide", "Sludgejaw", "Cinderclaw", "Scaledrake", "Emerald Mage", "Ruby Archer", "Sapphire Warrior", "Bonecleaver", "Fleshcarver", "Fleshrend", "Giant Tortoise", "Mauler", "Grothar", "Grugnor", "Krulmash", "Thokkar", "Blackblade", "Blightbearer", "Gorthak", "Malevolent", "Shadowreaper", "Urzog", "Bonelich", "Doombone", "Grimbone", "Shadow Reaper", "Skullshade", "Tombwraith", "Frost Behemoth", "Frostbite Behemoth", "Frostfang Aberration", "Glacial Behemoth", "Icebound Abomination", "Armorcoil", "Blazefang", "Gorgulith", "Nexlurith", "Voidwagner", "Aegis Sentinel", "Flarevein Wyrm", "Gloomstinger", "Pyroquill", "Toxic Mauler", "Ashfang Wyrm", "Bloodspark Adept", "Glacial Hellcharger", "Nightfang Widow", "Shadowcrystal Widow", "Bloodhsade Reaper", "Duskhorn Drake", "Nightflare Dreadknight", "Shadowvein Wrym", "Umbral Arcanist", "Hellmaw Brute", "Mirethorn hexer", "Mossfang Drake", "Plague Warbringer", "Viridscale Wrym", "Embermaw Archon", "Inferno Juggernaut", "Pitlord Incarnate", "Stormvein Wrym", "Waterglow Conjurer"
	}

	local eventPool = {
		{
			id = 1,
			name = "Tax Boom",
			description = "Dynasty tax income from this city\nis increased for a short event window.",
			scope = "city",
			startHour = 18,
			durationHours = 2
		},
		{
			id = 2,
			name = "Guild EXP Boost",
			description = "Guild members who own a dynasty core\nreceive a temporary EXP bonus everywhere.",
			scope = "guild",
			startHour = 22,
			durationHours = 2
		},
		{
			id = 3,
			name = "Pet Double EXP",
			description = "Pets receive double EXP while your guild\ncontrols a dynasty core.",
			scope = "guild",
			startHour = 16,
			durationHours = 2
		},
		{
			id = 4,
			name = "World Quest Board",
			description = "A public guild board appears near the dynasty city\nand offers shared timed quests to any player with a guild.\nQuests completed by other guilds reward a small amount of\nGold and Dynasty Tokens to that city's Dynasty Core.",
			scope = "world",
			startHour = 19,
			startMinute = 30,
			durationMinutes = 120
		},
		{
			id = 5,
			name = "Dynasty Token Surge",
			description = "Guilds that own a dynasty core receive\ndoubled passive dynasty token generation for 24 hours.",
			scope = "guild",
			startHour = 0,
			startMinute = 0,
			durationHours = 24
		},
		{
			id = 6,
			name = "Boosted Creature Hunt",
			description = "A random creature from the dynasty hunting list\ngrants bonus experience for a limited event window.",
			scope = "guild",
			startHour = 20,
			durationHours = 6
		}
	}
	
	local EVENT_ID_TAX_BOOM = 1
	local EVENT_ID_GUILD_EXP = 2
	local EVENT_ID_PET_DOUBLE_EXP = 3
	local EVENT_ID_WORLD_BOARD = 4
	local EVENT_ID_DYNASTIE_TOKEN_SURGE = 5
	local EVENT_ID_BOOSTED_CREATURE_HUNT = 6
	-- This line is for test the event, instead of nil add the value of the event to test it in live and choose the correct hour
	local TEST_FORCE_EVENT_ID = nil
	-- Repeat world board quests, 3 times per player
	local BOARD_QUEST_REPEAT_LIMIT = 3
	-- Storages not touch it
	local STORAGE_GUILD_EXP_BOOST_UNTIL = 450120
	local STORAGE_PET_DOUBLE_EXP_UNTIL = 450121
	local getEventDefinitionById
	local resolveEventForDateParts
	local boardQuestPool = {
		{ id = "board_monster_150", name = "Field Culling", icon = "kill_monsters", type = "kill_any_monster", target = 150, tier = "small", playerRewards = { exp = 800000, items = { { itemId = 2160, count = 1 } } }, guildRewards = { guildExp = 12500 } },
		{ id = "board_monster_400", name = "Battle Attrition", icon = "kill_monsters", type = "kill_any_monster", target = 400, tier = "medium", playerRewards = { exp = 1500000, items = { { itemId = 2160, count = 3 } } }, guildRewards = { guildExp = 38000 } },
		{ id = "board_monster_900", name = "Monster Collapse", icon = "kill_monsters", type = "kill_any_monster", target = 900, tier = "large", playerRewards = { exp = 2450000, items = { { itemId = 2160, count = 6 } } }, guildRewards = { guildExp = 78000 } },
		{ id = "board_players_3", name = "Street Clash", icon = "kill_players", type = "kill_any_player", target = 3, tier = "small", playerRewards = { exp = 500000, items = { { itemId = 2160, count = 2 }, { itemId = 2173, count = 1 } } }, guildRewards = { guildExp = 20000 } },
		{ id = "board_players_8", name = "Warline Breach", icon = "kill_players", type = "kill_any_player", target = 8, tier = "medium", playerRewards = { exp = 1100000, items = { { itemId = 2160, count = 2 }, { itemId = 2173, count = 1 } } }, guildRewards = { guildExp = 40000 } },
		{ id = "board_exp_1000k", name = "Campaign Drills", icon = "earn_exp", type = "gain_experience", target = 1000000, tier = "small", playerRewards = { exp = 350000, items = { } }, guildRewards = { guildExp = 12000 } },
		{ id = "board_exp_5000k", name = "Martial Momentum", icon = "earn_exp", type = "gain_experience", target = 5000000, tier = "medium", playerRewards = { exp = 1750000, items = {  } }, guildRewards = { guildExp = 25000 } },
		{ id = "board_exp_12500k", name = "Veteran Muster", icon = "earn_exp", type = "gain_experience", target = 12500000, tier = "large", playerRewards = { exp = 4500000, items = {  } }, guildRewards = { guildExp = 75000 } },
		{ id = "board_boss_1", name = "Boss Alert", icon = "dynastie_boss", type = "kill_reward_boss", target = 1, tier = "small", playerRewards = { exp = 300000, items = { { itemId = 28345, count = 5 } } }, guildRewards = { guildExp = 19500 } },
		{ id = "board_boss_3", name = "Boss Campaign", icon = "dynastie_boss", type = "kill_reward_boss", target = 3, tier = "medium", playerRewards = { exp = 900000, items = { { itemId = 28345, count = 15 } } }, guildRewards = { guildExp = 39000 } },
		{ id = "board_boss_6", name = "Boss Campaign", icon = "dynastie_boss", type = "kill_reward_boss", target = 6, tier = "large", playerRewards = { exp = 30000, items = { { itemId = 28345, count = 30 } } }, guildRewards = { guildExp = 78000 } },
		{ id = "board_mining_1", name = "Mining I", icon = "mining", type = "profession_activity", profession = "mining", target = 30, tier = "small", playerRewards = { exp = 700000, items = { { itemId = 2152, count = 50 } } }, guildRewards = { guildExp = 14500 } },
		{ id = "board_mining_2", name = "Mining II", icon = "mining", type = "profession_activity", profession = "mining", target = 60, tier = "medium", playerRewards = { exp = 1500000, items = { { itemId = 2152, count = 110 } } }, guildRewards = { guildExp = 29000 } },
		{ id = "board_mining_3", name = "Mining III", icon = "mining", type = "profession_activity", profession = "mining", target = 140, tier = "large", playerRewards = { exp = 3800000, items = { { itemId = 2160, count = 2 } } }, guildRewards = { guildExp = 74500 } },
		{ id = "board_herbalist_1", name = "Herbalist I", icon = "herbalist", type = "profession_activity", profession = "herbalist", target = 30, tier = "small", playerRewards = { exp = 700000, items = { { itemId = 2152, count = 50 } } }, guildRewards = { guildExp = 14500 } },
		{ id = "board_herbalist_2", name = "Herbalist II", icon = "herbalist", type = "profession_activity", profession = "herbalist", target = 60, tier = "medium", playerRewards = { exp = 1500000, items = { { itemId = 2152, count = 110 } } }, guildRewards = { guildExp = 29000 } },
		{ id = "board_herbalist_3", name = "Herbalist III", icon = "herbalist", type = "profession_activity", profession = "herbalist", target = 140, tier = "large", playerRewards = { exp = 3800000, items = { { itemId = 2160, count = 2 } } }, guildRewards = { guildExp = 74500 } },
		{ id = "board_woodcutting_1", name = "Woodcutting I", icon = "woodcutting", type = "profession_activity", profession = "woodcutting", target = 30, tier = "small", playerRewards = { exp = 700000, items = { { itemId = 2152, count = 50 } } }, guildRewards = { guildExp = 14500 } },
		{ id = "board_woodcutting_2", name = "Woodcutting II", icon = "woodcutting", type = "profession_activity", profession = "woodcutting", target = 60, tier = "medium", playerRewards = { exp = 1500000, items = { { itemId = 2152, count = 110 } } }, guildRewards = { guildExp = 29000 } },
		{ id = "board_woodcutting_3", name = "Woodcutting III", icon = "woodcutting", type = "profession_activity", profession = "woodcutting", target = 140, tier = "large", playerRewards = { exp = 3800000, items = { { itemId = 2160, count = 2 } } }, guildRewards = { guildExp = 74500 } },
		{ id = "board_fishing_1", name = "Fishing I", icon = "fishing", type = "profession_activity", profession = "fishing", target = 50, tier = "small", playerRewards = { exp = 850000, items = { { itemId = 2152, count = 110 } } }, guildRewards = { guildExp = 19500 } },
		{ id = "board_fishing_2", name = "Fishing II", icon = "fishing", type = "profession_activity", profession = "fishing", target = 100, tier = "medium", playerRewards = { exp = 1800000, items = { { itemId = 2152, count = 150 }, { itemId = 2160, count = 1 } } }, guildRewards = { guildExp = 39000 } },
		{ id = "board_fishing_3", name = "Fishing III", icon = "fishing", type = "profession_activity", profession = "fishing", target = 200, tier = "large", playerRewards = { exp = 4250000, items = { { itemId = 2152, count = 450 }, { itemId = 2160, count = 3 } } }, guildRewards = { guildExp = 78000 } },
		{ id = "board_crafting_1", name = "Crafting I", icon = "crafting", type = "profession_activity", profession = "crafting", target = 25, tier = "small", playerRewards = { exp = 800000, items = { { itemId = 2152, count = 200 } } }, guildRewards = { guildExp = 25000 } },
		{ id = "board_crafting_2", name = "Crafting II", icon = "crafting", type = "profession_activity", profession = "crafting", target = 50, tier = "medium", playerRewards = { exp = 2000000, items = { { itemId = 2152, count = 300 }, { itemId = 2160, count = 2 } } }, guildRewards = { guildExp = 50000 } },
		{ id = "board_crafting_3", name = "Crafting III", icon = "crafting", type = "profession_activity", profession = "crafting", target = 100, tier = "large", playerRewards = { exp = 4250000, items = { { itemId = 2152, count = 600 }, { itemId = 2160, count = 5 } } }, guildRewards = { guildExp = 105000 } },
		{ id = "board_armorsmith_1", name = "Armorsmith I", icon = "armorsmith", type = "profession_activity", profession = "armorsmith", target = 25, tier = "small", playerRewards = { exp = 800000, items = { { itemId = 2152, count = 200 } } }, guildRewards = { guildExp = 25000 } },
		{ id = "board_armorsmith_2", name = "Armorsmith II", icon = "armorsmith", type = "profession_activity", profession = "armorsmith", target = 50, tier = "medium", playerRewards = { exp = 2000000, items = { { itemId = 2152, count = 300 }, { itemId = 2160, count = 2 } } }, guildRewards = { guildExp = 50000 } },
		{ id = "board_armorsmith_3", name = "Armorsmith III", icon = "armorsmith", type = "profession_activity", profession = "armorsmith", target = 100, tier = "large", playerRewards = { exp = 4250000, items = { { itemId = 2152, count = 600 }, { itemId = 2160, count = 5 } } }, guildRewards = { guildExp = 105000 } },
		{ id = "board_weaponsmith_1", name = "Weaponsmith I", icon = "weaponsmith", type = "profession_activity", profession = "weaponsmith", target = 25, tier = "small", playerRewards = { exp = 800000, items = { { itemId = 2152, count = 200 } } }, guildRewards = { guildExp = 25000 } },
		{ id = "board_weaponsmith_2", name = "Weaponsmith II", icon = "weaponsmith", type = "profession_activity", profession = "weaponsmith", target = 50, tier = "medium", playerRewards = { exp = 2000000, items = { { itemId = 2152, count = 300 }, { itemId = 2160, count = 2 } } }, guildRewards = { guildExp = 50000 } },
		{ id = "board_weaponsmith_3", name = "Weaponsmith III", icon = "weaponsmith", type = "profession_activity", profession = "weaponsmith", target = 100, tier = "large", playerRewards = { exp = 4250000, items = { { itemId = 2152, count = 600 }, { itemId = 2160, count = 5 } } }, guildRewards = { guildExp = 105000 } },
		{ id = "board_jewelsmith_1", name = "Jewelsmith I", icon = "jewelsmith", type = "profession_activity", profession = "jewelsmith", target = 25, tier = "small", playerRewards = { exp = 800000, items = { { itemId = 2152, count = 200 } } }, guildRewards = { guildExp = 25000 } },
		{ id = "board_jewelsmith_2", name = "Jewelsmith II", icon = "jewelsmith", type = "profession_activity", profession = "jewelsmith", target = 50, tier = "medium", playerRewards = { exp = 2000000, items = { { itemId = 2152, count = 300 }, { itemId = 2160, count = 2 } } }, guildRewards = { guildExp = 50000 } },
		{ id = "board_jewelsmith_3", name = "Jewelsmith III", icon = "jewelsmith", type = "profession_activity", profession = "jewelsmith", target = 100, tier = "large", playerRewards = { exp = 4250000, items = { { itemId = 2152, count = 600 }, { itemId = 2160, count = 5 } } }, guildRewards = { guildExp = 105000 } }
	}

	local function buildBoardQuestObjective(definition)
		if type(definition) ~= "table" then
			return ""
		end

		local target = tonumber(definition.target) or 0
		if definition.type == "kill_any_monster" then
			return string.format("Kill %s monsters.", target)
		elseif definition.type == "kill_any_player" then
			return string.format("Kill %s players.", target)
		elseif definition.type == "gain_experience" then
			return string.format("Earn %s experience.", target)
		elseif definition.type == "kill_reward_boss" then
			return string.format("Kill %s reward boss%s.", target, target == 1 and "" or "es")
		elseif definition.type == "profession_activity" then
			return string.format("Complete %s successful %s action%s.", target, tostring(definition.profession or "profession"), target == 1 and "" or "s")
		end

		return string.format("Reach target %s.", target)
	end

	local function formatTimeLabel(hour, minute)
		hour = math.max(0, math.min(23, math.floor(tonumber(hour) or 0)))
		minute = math.max(0, math.min(59, math.floor(tonumber(minute) or 0)))
		return string.format("%02d:%02d", hour, minute)
	end

	local function getEventStartHour(eventDefinition)
		return math.max(0, math.min(23, math.floor(tonumber(eventDefinition and eventDefinition.startHour) or 0)))
	end

	local function getEventStartMinute(eventDefinition)
		return math.max(0, math.min(59, math.floor(tonumber(eventDefinition and eventDefinition.startMinute) or 0)))
	end

	local function getEventDurationSeconds(eventDefinition)
		local durationMinutes = tonumber(eventDefinition and eventDefinition.durationMinutes)
		if durationMinutes and durationMinutes > 0 then
			return math.max(60, math.floor(durationMinutes) * 60)
		end

		local durationHours = tonumber(eventDefinition and eventDefinition.durationHours)
		if durationHours and durationHours > 0 then
			return math.max(3600, math.floor(durationHours) * 3600)
		end

		return 3600
	end

	local function buildEventWindow(eventDefinition, year, month, dayNumber)
		local startHour = getEventStartHour(eventDefinition)
		local startMinute = getEventStartMinute(eventDefinition)
		local durationSeconds = getEventDurationSeconds(eventDefinition)
		local durationMinutes = math.max(1, math.floor(durationSeconds / 60))
		local startTime = os.time({
			year = year,
			month = month,
			day = dayNumber,
			hour = startHour,
			min = startMinute,
			sec = 0
		})
		local endTime = startTime + durationSeconds
		local endDate = os.date("*t", endTime)
		local endHour = tonumber(endDate and endDate.hour) or startHour
		local endMinute = tonumber(endDate and endDate.min) or startMinute
		local timeLabel = string.format("%s - %s", formatTimeLabel(startHour, startMinute), formatTimeLabel(endHour, endMinute))

		return startHour, startMinute, endHour, endMinute, durationMinutes, timeLabel
	end

	local function getCurrentTimestampParts()
		local now = os.time()
		local localDate = os.date("*t", now)
		local weekdayIndex = tonumber(localDate.wday) or 1
		weekdayIndex = ((weekdayIndex + 5) % 7) + 1
		return now, localDate, weekdayIndex
	end

	local function getDaysInMonth(year, month)
		local nextMonth = month + 1
		local nextYear = year
		if nextMonth > 12 then
			nextMonth = 1
			nextYear = nextYear + 1
		end

		local firstOfNextMonth = os.time({
			year = nextYear,
			month = nextMonth,
			day = 1,
			hour = 12
		})
		local lastOfCurrentMonth = firstOfNextMonth - 86400
		return tonumber(os.date("%d", lastOfCurrentMonth)) or 30
	end

	local function getMonthStartWeekdayIndex(year, month)
		local firstDay = os.date("*t", os.time({
			year = year,
			month = month,
			day = 1,
			hour = 12
		}))
		local weekdayIndex = tonumber(firstDay and firstDay.wday) or 1
		return ((weekdayIndex + 5) % 7) + 1
	end

	local function resolveMonthOffset(year, month, monthOffset)
		year = math.floor(tonumber(year) or 0)
		month = math.floor(tonumber(month) or 1)
		monthOffset = math.floor(tonumber(monthOffset) or 0)

		month = month + monthOffset
		while month > 12 do
			month = month - 12
			year = year + 1
		end
		while month < 1 do
			month = month + 12
			year = year - 1
		end

		return year, month
	end

	local function getPreviousMonth(year, month)
		return resolveMonthOffset(year, month, -1)
	end

	local function getNextMonth(year, month)
		return resolveMonthOffset(year, month, 1)
	end

	local function getCityLabel(configId)
		local configName = tostring(configId or "")
		return configName ~= "" and (configName:gsub("^dynastie_", ""):gsub("^%l", string.upper)) or "No core selected"
	end

	local function getCityIndex(configId)
		local cityLabel = getCityLabel(configId)
		for index, cityName in pairs(cityDefinitions) do
			if cityName == cityLabel then
				return index
			end
		end

		local nextIndex = #cityDefinitions + 1
		cityDefinitions[nextIndex] = cityLabel ~= "" and cityLabel or "No core selected"
		return nextIndex
	end

	local function buildEventDefinitions()
		local definitions = {}
		for _, eventDefinition in ipairs(eventPool) do
			definitions[eventDefinition.id] = {
				n = eventDefinition.name,
				x = eventDefinition.description,
				s = tostring(eventDefinition.scope or "city")
			}
		end
		return definitions
	end

	local function getBoostedCreatureBonusPercent()
		local cfg = rawget(_G, "GuildHallDynastieConfig") or {}
		return math.max(0, tonumber(cfg.EVENT_BOOSTED_CREATURE_EXP_PERCENT) or 50)
	end

	local function getBoostedCreatureForDateParts(year, month, dayNumber)
		if #boostedCreaturePool == 0 then
			return ""
		end

		local entryTime = os.time({
			year = tonumber(year) or tonumber(os.date("%Y")),
			month = tonumber(month) or tonumber(os.date("%m")),
			day = tonumber(dayNumber) or 1,
			hour = 12
		})
		local dateInfo = os.date("*t", entryTime)
		local yday = tonumber(dateInfo and dateInfo.yday) or 1
		local monthValue = tonumber(dateInfo and dateInfo.month) or tonumber(month) or 1
		local yearValue = tonumber(dateInfo and dateInfo.year) or tonumber(year) or 0
		local seed = yday + monthValue * 17 + yearValue * 7 + (tonumber(dayNumber) or 1) * 13
		local poolIndex = (seed % #boostedCreaturePool) + 1
		return tostring(boostedCreaturePool[poolIndex] or "")
	end

	local function formatBoostedCreatureName(monsterName)
		monsterName = tostring(monsterName or "")
		if monsterName == "" then
			return ""
		end

		return (monsterName:gsub("(%a)([%w_']*)", function(first, rest)
			return first:upper() .. rest
		end))
	end

	local function buildDayEvent(configId, year, month, dayNumber, isCurrentMonth)
		local entryTime = os.time({
			year = year,
			month = month,
			day = dayNumber,
			hour = 12
		})
		local dateInfo = os.date("*t", entryTime)
		local eventDefinition = resolveEventForDateParts(year, month, dayNumber)
		local weekdayIndex = tonumber(dateInfo.wday) or 1
		weekdayIndex = ((weekdayIndex + 5) % 7) + 1
		local startHour, startMinute, endHour, endMinute, durationMinutes, timeLabel = buildEventWindow(eventDefinition, year, month, dayNumber)
		local eventName = tostring(eventDefinition.name or "")
		local eventDescription = tostring(eventDefinition.description or "")
		if tonumber(eventDefinition.id) == EVENT_ID_BOOSTED_CREATURE_HUNT then
			local boostedCreatureName = getBoostedCreatureForDateParts(year, month, dayNumber)
			local boostedCreatureLabel = formatBoostedCreatureName(boostedCreatureName)
			local boostedBonusPercent = getBoostedCreatureBonusPercent()
			if boostedCreatureName ~= "" then
				eventName = string.format("%s: %s", eventName, boostedCreatureLabel)
				eventDescription = string.format(
					"%s\n\nActive target: %s\nBonus: +%d%% experience for guild members\nwho own an active dynasty core.",
					tostring(eventDefinition.description or ""),
					boostedCreatureLabel,
					boostedBonusPercent
				)
			end
		end

		return {
			y = year,
			m = month,
			d = dayNumber,
			w = weekdayIndex,
			c = getCityIndex(configId),
			e = eventDefinition.id,
			i = isCurrentMonth == true and 1 or 0,
			sh = startHour,
			sm = startMinute,
			eh = endHour,
			em = endMinute,
			dm = durationMinutes,
			t = timeLabel,
			n = eventName,
			x = eventDescription
		}
	end

	local function buildPayload(configId, monthOffset)
		local now, dateInfo = getCurrentTimestampParts()
		local days = {}
		local baseYear = tonumber(dateInfo.year) or tonumber(os.date("%Y", now))
		local baseMonth = tonumber(dateInfo.month) or tonumber(os.date("%m", now))
		local currentYear, currentMonth = resolveMonthOffset(baseYear, baseMonth, monthOffset)
		local daysInMonth = getDaysInMonth(currentYear, currentMonth)
		local monthStartWeekdayIndex = getMonthStartWeekdayIndex(currentYear, currentMonth)
		local previousYear, previousMonth = getPreviousMonth(currentYear, currentMonth)
		local nextYear, nextMonth = getNextMonth(currentYear, currentMonth)
		local previousMonthDays = getDaysInMonth(previousYear, previousMonth)
		local referenceTime = os.time({
			year = currentYear,
			month = currentMonth,
			day = 1,
			hour = 12
		})

		for offset = monthStartWeekdayIndex - 2, 0, -1 do
			days[#days + 1] = buildDayEvent(configId, previousYear, previousMonth, previousMonthDays - offset, false)
		end

		for dayNumber = 1, daysInMonth do
			days[#days + 1] = buildDayEvent(configId, currentYear, currentMonth, dayNumber, true)
		end

		local remainder = #days % 7
		if remainder ~= 0 then
			local trailingCount = 7 - remainder
			for dayNumber = 1, trailingCount do
				days[#days + 1] = buildDayEvent(configId, nextYear, nextMonth, dayNumber, false)
			end
		end

		return {
			monthOffset = math.floor(tonumber(monthOffset) or 0),
			currentYear = currentYear,
			currentMonth = currentMonth,
			currentMonthLabel = os.date("%B %Y", referenceTime),
			currentDateLabel = os.date("%A, %d %B %Y", now),
			summary = string.format("Monthly dynastie schedule for %s. Active events rotate between city tax boosts, guild boosts, and special boosted creature hunts.", os.date("%B %Y", referenceTime)),
			weekdays = weekdayNames,
			cities = cityDefinitions,
			events = buildEventDefinitions(),
			days = days
		}
	end

	local function getConfig()
		return rawget(_G, "GuildHallDynastieConfig") or {}
	end

	local function getGuildIdByConfig(configId)
		if not api or type(api.getDynastieState) ~= "function" then
			return 0
		end

		local state = api.getDynastieState(configId)
		return state and tonumber(state.guildId or 0) or 0
	end

	local function getGuildActiveConfigIds(guildId)
		local configIds = {}
		if guildId <= 0 or not api or type(api.getGuildActiveDynastieConfigIds) ~= "function" then
			return configIds
		end

		for _, configId in ipairs(api.getGuildActiveDynastieConfigIds(guildId) or {}) do
			if tostring(configId or "") ~= "" then
				configIds[#configIds + 1] = tostring(configId)
			end
		end

		return configIds
	end

	getEventDefinitionById = function(eventId)
		for _, eventDefinition in ipairs(eventPool) do
			if tonumber(eventDefinition.id) == tonumber(eventId) then
				return eventDefinition
			end
		end
		return nil
	end

	resolveEventForDateParts = function(year, month, dayNumber)
		if tonumber(TEST_FORCE_EVENT_ID) and tonumber(TEST_FORCE_EVENT_ID) > 0 then
			return getEventDefinitionById(TEST_FORCE_EVENT_ID) or eventPool[1]
		end

		local entryTime = os.time({
			year = tonumber(year) or tonumber(os.date("%Y")),
			month = tonumber(month) or tonumber(os.date("%m")),
			day = tonumber(dayNumber) or 1,
			hour = 12
		})
		local yday = tonumber(os.date("*t", entryTime).yday) or 1
		local poolIndex = ((yday or 1) + (tonumber(dayNumber) or 1)) % #eventPool + 1
		return eventPool[poolIndex]
	end

	local function isEventActiveForDay(eventDefinition, year, month, dayNumber, timestamp)
		if not eventDefinition or not timestamp then
			return false
		end

		local startHour = getEventStartHour(eventDefinition)
		local startMinute = getEventStartMinute(eventDefinition)
		local startTime = os.time({
			year = year,
			month = month,
			day = dayNumber,
			hour = startHour,
			min = startMinute,
			sec = 0
		})
		local durationSeconds = getEventDurationSeconds(eventDefinition)
		return timestamp >= startTime and timestamp < (startTime + durationSeconds)
	end

	local function getScheduledEventForConfig(configId, timestamp)
		configId = tostring(configId or "")
		timestamp = tonumber(timestamp) or os.time()
		if configId == "" then
			return nil
		end

		local dateInfo = os.date("*t", timestamp)
		local dayNumber = tonumber(dateInfo and dateInfo.day) or 1
		local currentYear = tonumber(dateInfo and dateInfo.year) or tonumber(os.date("%Y", timestamp))
		local currentMonth = tonumber(dateInfo and dateInfo.month) or tonumber(os.date("%m", timestamp))
		local eventDefinition = resolveEventForDateParts(currentYear, currentMonth, dayNumber)
		if not isEventActiveForDay(eventDefinition, tonumber(dateInfo.year), tonumber(dateInfo.month), dayNumber, timestamp) then
			local previousDayTimestamp = timestamp - 86400
			local previousDateInfo = os.date("*t", previousDayTimestamp)
			local previousDay = tonumber(previousDateInfo and previousDateInfo.day) or dayNumber
			local previousMonth = tonumber(previousDateInfo and previousDateInfo.month) or currentMonth
			local previousYear = tonumber(previousDateInfo and previousDateInfo.year) or currentYear
			local previousEventDefinition = resolveEventForDateParts(previousYear, previousMonth, previousDay)
			if not isEventActiveForDay(previousEventDefinition, previousYear, previousMonth, previousDay, timestamp) then
				return nil
			end
			return previousEventDefinition
		end

		return eventDefinition
	end

	local function getGuildActiveEventIds(guildId, timestamp)
		local eventIds = {}
		for _, configId in ipairs(getGuildActiveConfigIds(guildId)) do
			local eventDefinition = getScheduledEventForConfig(configId, timestamp)
			if eventDefinition then
				eventIds[eventDefinition.id] = true
			end
		end
		return eventIds
	end

	local function syncPlayerStorages(player, timestamp)
		if not player or not api or type(api.resolvePlayerGuildId) ~= "function" then
			return
		end

		timestamp = tonumber(timestamp) or os.time()
		local guildId = tonumber(api.resolvePlayerGuildId(player)) or 0
		local activeEvents = getGuildActiveEventIds(guildId, timestamp)
		local guildExpUntil = activeEvents[EVENT_ID_GUILD_EXP] and (timestamp + 60) or -1
		local petExpUntil = activeEvents[EVENT_ID_PET_DOUBLE_EXP] and (timestamp + 60) or -1
		player:setStorageValue(STORAGE_GUILD_EXP_BOOST_UNTIL, guildExpUntil)
		player:setStorageValue(STORAGE_PET_DOUBLE_EXP_UNTIL, petExpUntil)
	end

	local function hasGuildActiveEvent(player, eventId, timestamp)
		if not player or not api or type(api.resolvePlayerGuildId) ~= "function" then
			return false
		end

		local guildId = tonumber(api.resolvePlayerGuildId(player)) or 0
		if guildId <= 0 then
			return false
		end

		local activeEvents = getGuildActiveEventIds(guildId, timestamp)
		return activeEvents[tonumber(eventId) or 0] == true
	end

	function eventsApi.getGuildExperienceBonusPercent(player, timestamp)
		if not player then
			return 0
		end

		if hasGuildActiveEvent(player, EVENT_ID_GUILD_EXP, timestamp) then
			syncPlayerStorages(player, timestamp)
			return math.max(0, tonumber(getConfig().EVENT_GUILD_EXP_BOOST_PERCENT) or 0)
		end
		player:setStorageValue(STORAGE_GUILD_EXP_BOOST_UNTIL, -1)

		return 0
	end

	function eventsApi.getPetExperienceMultiplier(player, timestamp)
		if not player then
			return 1
		end

		local active = hasGuildActiveEvent(player, EVENT_ID_PET_DOUBLE_EXP, timestamp)
		if active then
			syncPlayerStorages(player, timestamp)
			local multiplier = math.max(1, tonumber(getConfig().EVENT_PET_DOUBLE_EXP_MULTIPLIER) or 1)
			return multiplier
		end
		player:setStorageValue(STORAGE_PET_DOUBLE_EXP_UNTIL, -1)

		return 1
	end

	function eventsApi.getDynastieTokenRateMultiplier(guildId, timestamp)
		guildId = tonumber(guildId) or 0
		if guildId <= 0 then
			return 1
		end

		local activeEvents = getGuildActiveEventIds(guildId, timestamp)
		if activeEvents[EVENT_ID_DYNASTIE_TOKEN_SURGE] then
			return 2
		end

		return 1
	end

	function eventsApi.getBoostedCreatureBonusPercent(player, source, timestamp)
		if not player or not source or not source.isMonster or not source:isMonster() or source:getMaster() then
			return 0
		end
		if not hasGuildActiveEvent(player, EVENT_ID_BOOSTED_CREATURE_HUNT, timestamp) then
			return 0
		end

		local boostedCreatureName = getBoostedCreatureForDateParts(os.date("*t", tonumber(timestamp) or os.time()).year, os.date("*t", tonumber(timestamp) or os.time()).month, os.date("*t", tonumber(timestamp) or os.time()).day)
		if boostedCreatureName == "" then
			return 0
		end
		if source:getName():lower() ~= boostedCreatureName:lower() then
			return 0
		end

		return getBoostedCreatureBonusPercent()
	end

	function eventsApi.getTaxBonusPercent(configId, timestamp)
		local eventDefinition = getScheduledEventForConfig(configId, timestamp)
		if not eventDefinition or tonumber(eventDefinition.id) ~= EVENT_ID_TAX_BOOM then
			return 0
		end

		return math.max(0, tonumber(getConfig().EVENT_TAX_BOOM_BONUS_PERCENT) or 0)
	end

	local function ensureBoardQuestTable()
		db.query("CREATE TABLE IF NOT EXISTS `player_dynastie_board_quests` (" ..
			"`id` INT NOT NULL AUTO_INCREMENT," ..
			"`player_id` INT NOT NULL," ..
			"`guild_id` INT NOT NULL DEFAULT 0," ..
			"`config_id` VARCHAR(64) NOT NULL," ..
			"`event_key` VARCHAR(32) NOT NULL," ..
			"`quest_id` VARCHAR(64) NOT NULL," ..
			"`progress` BIGINT NOT NULL DEFAULT 0," ..
			"`target` BIGINT NOT NULL DEFAULT 0," ..
			"`accepted_at` INT NOT NULL DEFAULT 0," ..
			"`expires_at` INT NOT NULL DEFAULT 0," ..
			"`created_at` INT NOT NULL DEFAULT 0," ..
			"`updated_at` INT NOT NULL DEFAULT 0," ..
			"PRIMARY KEY (`id`)," ..
			"UNIQUE KEY `player_event_quest` (`player_id`, `event_key`, `quest_id`)," ..
			"KEY `player_active` (`player_id`, `expires_at`)" ..
		") ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	end

	local function ensureBoardQuestHistoryTable()
		db.query("CREATE TABLE IF NOT EXISTS `player_dynastie_board_quest_history` (" ..
			"`id` INT NOT NULL AUTO_INCREMENT," ..
			"`player_id` INT NOT NULL," ..
			"`event_key` VARCHAR(32) NOT NULL," ..
			"`quest_id` VARCHAR(64) NOT NULL," ..
			"`completion_count` INT NOT NULL DEFAULT 0," ..
			"`updated_at` INT NOT NULL DEFAULT 0," ..
			"PRIMARY KEY (`id`)," ..
			"UNIQUE KEY `player_event_quest_history` (`player_id`, `event_key`, `quest_id`)" ..
		") ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	end

	local function getBoardPositions()
		return type(getConfig().EVENT_BOARD_POSITIONS) == "table" and getConfig().EVENT_BOARD_POSITIONS or {}
	end

	local function isValidBoardPosition(position)
		return position
			and tonumber(position.x) and tonumber(position.x) > 0
			and tonumber(position.y) and tonumber(position.y) > 0
			and tonumber(position.z) and tonumber(position.z) >= 0
	end

	local function getBoardItemId()
		return math.max(0, tonumber(getConfig().EVENT_BOARD_ITEM_ID) or 0)
	end

	local function findBoardItemOnTile(tile)
		if not tile then
			return nil
		end

		local boardItemId = getBoardItemId()
		if boardItemId <= 0 then
			return nil
		end

		if tile.getItems then
			for _, item in ipairs(tile:getItems() or {}) do
				if item and item:isItem() and item:getId() == boardItemId then
					return item
				end
			end
		end

		local topThing = tile.getTopVisibleThing and tile:getTopVisibleThing() or nil
		if topThing and topThing:isItem() and topThing:getId() == boardItemId then
			return topThing
		end

		return nil
	end

	local function tileHasCreatures(tile)
		if not tile or not tile.getCreatures then
			return false
		end

		for _, creature in ipairs(tile:getCreatures() or {}) do
			if creature then
				return true
			end
		end

		return false
	end

	local function positionsEqual(a, b)
		return a and b and tonumber(a.x) == tonumber(b.x) and tonumber(a.y) == tonumber(b.y) and tonumber(a.z) == tonumber(b.z)
	end

	local function getBoardConfigIdByPosition(position)
		for configId, boardPosition in pairs(getBoardPositions()) do
			if positionsEqual(position, boardPosition) then
				return tostring(configId)
			end
		end
		return ""
	end

	local function buildBoardEventKey(configId, eventDefinition, timestamp)
		local dateInfo = os.date("*t", tonumber(timestamp) or os.time())
		return string.format("%s:%d:%04d%02d%02d", tostring(configId), tonumber(eventDefinition and eventDefinition.id or 0) or 0, tonumber(dateInfo.year) or 0, tonumber(dateInfo.month) or 0, tonumber(dateInfo.day) or 0)
	end

	local function getActiveBoardContext(configId, timestamp)
		local eventDefinition = getScheduledEventForConfig(configId, timestamp)
		if not eventDefinition or tonumber(eventDefinition.id) ~= EVENT_ID_WORLD_BOARD then
			return nil
		end
		local now = tonumber(timestamp) or os.time()
		local dateInfo = os.date("*t", now)
		local startTime = os.time({
			year = dateInfo.year,
			month = dateInfo.month,
			day = dateInfo.day,
			hour = getEventStartHour(eventDefinition),
			min = getEventStartMinute(eventDefinition),
			sec = 0
		})
		local expiresAt = startTime + getEventDurationSeconds(eventDefinition)
		return {
			configId = tostring(configId or ""),
			eventDefinition = eventDefinition,
			eventKey = buildBoardEventKey(configId, eventDefinition, now),
			startsAt = startTime,
			expiresAt = expiresAt
		}
	end

	local function getBoardOfferDefinitions(configId, timestamp)
		local context = getActiveBoardContext(configId, timestamp)
		if not context then
			return {}, nil
		end
		local offers = {}
		local total = #boardQuestPool
		local seed = 0
		for i = 1, #context.eventKey do
			seed = seed + string.byte(context.eventKey, i)
		end
		local startIndex = (seed % math.max(1, total)) + 1
		for offset = 0, math.min(5, total - 1) do
			local index = ((startIndex + offset - 1) % total) + 1
			offers[#offers + 1] = boardQuestPool[index]
		end
		return offers, context
	end

	local function getBoardQuestDefinition(questId)
		for _, quest in ipairs(boardQuestPool) do
			if quest.id == questId then
				return quest
			end
		end
		return nil
	end

	local function getBoardQuestCompletionCount(playerGuid, eventKey, questId)
		ensureBoardQuestHistoryTable()
		local query = db.storeQuery("SELECT `completion_count` FROM `player_dynastie_board_quest_history` WHERE `player_id` = " .. (tonumber(playerGuid) or 0) ..
			" AND `event_key` = " .. db.escapeString(tostring(eventKey or "")) ..
			" AND `quest_id` = " .. db.escapeString(tostring(questId or "")))
		if not query then
			return 0
		end
		local count = tonumber(result.getNumber(query, "completion_count")) or 0
		result.free(query)
		return math.max(0, count)
	end

	local function incrementBoardQuestCompletionCount(playerGuid, eventKey, questId)
		ensureBoardQuestHistoryTable()
		local nextCount = getBoardQuestCompletionCount(playerGuid, eventKey, questId) + 1
		db.query("INSERT INTO `player_dynastie_board_quest_history` (`player_id`, `event_key`, `quest_id`, `completion_count`, `updated_at`) VALUES (" ..
			(tonumber(playerGuid) or 0) .. ", " ..
			db.escapeString(tostring(eventKey or "")) .. ", " ..
			db.escapeString(tostring(questId or "")) .. ", " ..
			nextCount .. ", " .. os.time() ..
			") ON DUPLICATE KEY UPDATE `completion_count` = " .. nextCount .. ", `updated_at` = " .. os.time())
		return nextCount
	end

	local function buildRewardText(rewards)
		rewards = type(rewards) == "table" and rewards or {}
		local parts = {}
		if (tonumber(rewards.exp) or 0) > 0 then
			parts[#parts + 1] = tostring(tonumber(rewards.exp) or 0) .. " exp"
		end
		for _, item in ipairs(rewards.items or {}) do
			local itemId = tonumber(item.itemId) or 0
			local itemCount = tonumber(item.count) or 0
			local itemType = itemId > 0 and ItemType(itemId) or nil
			local itemName = itemType and itemType:getName() or ""
			if itemName == "" then
				itemName = "item #" .. itemId
			end
			parts[#parts + 1] = string.format("%dx %s", itemCount, itemName)
		end
		return table.concat(parts, ", ")
	end

	local function sanitizePayloadText(value)
		value = tostring(value or "")
		value = value:gsub("[%z\1-\8\11\12\14-\31]", " ")
		value = value:gsub("%s+", " ")
		return value:match("^%s*(.-)%s*$")
	end

	local function buildGuildRewardText(rewards)
		rewards = type(rewards) == "table" and rewards or {}
		local parts = {}
		if (tonumber(rewards.guildExp) or 0) > 0 then
			parts[#parts + 1] = tostring(tonumber(rewards.guildExp) or 0) .. " guild exp"
		end
		if (tonumber(rewards.dynastieExp) or 0) > 0 then
			parts[#parts + 1] = tostring(tonumber(rewards.dynastieExp) or 0) .. " dynastie exp"
		end
		if (tonumber(rewards.guildGold) or 0) > 0 then
			parts[#parts + 1] = tostring(tonumber(rewards.guildGold) or 0) .. " guild gold"
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 then
			parts[#parts + 1] = tostring(tonumber(rewards.dynastieTokens) or 0) .. " dynastie tokens"
		end
		return table.concat(parts, ", ")
	end

	local function buildOwnerRewardEntries(rewards)
		rewards = type(rewards) == "table" and rewards or {}
		local entries = {}
		local goldCoinItemId = 2148

		local function addTextEntry(text)
			text = tostring(text or "")
			if text ~= "" then
				entries[#entries + 1] = { type = "text", text = text }
			end
		end

		local function addItemEntry(itemId, count, name)
			itemId = tonumber(itemId) or 0
			count = tonumber(count) or 0
			if itemId <= 0 or count <= 0 then
				return
			end
			local itemType = ItemType(itemId)
			local clientId = (itemType and itemType:getClientId()) or 0
			if clientId > 0 then
				entries[#entries + 1] = {
					type = "item",
					itemId = itemId,
					clientId = clientId,
					count = count,
					name = tostring(name or (itemType and itemType:getName()) or ("Item #" .. itemId))
				}
			end
		end

		if (tonumber(rewards.guildGold) or 0) > 0 then
			addItemEntry(goldCoinItemId, tonumber(rewards.guildGold) or 0, "Guild Gold")
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 then
			entries[#entries + 1] = {
				type = "icon",
				imageSource = "/images/guild_hall/dynasty_tokens",
				count = tonumber(rewards.dynastieTokens) or 0,
				name = "Dynasty Tokens"
			}
		end
		if (tonumber(rewards.dynastieExp) or 0) > 0 then
			addTextEntry(tostring(tonumber(rewards.dynastieExp) or 0) .. " dynasty exp")
		end
		if (tonumber(rewards.guildExp) or 0) > 0 then
			addTextEntry(tostring(tonumber(rewards.guildExp) or 0) .. " guild exp")
		end
		return entries
	end

	local function purgeExpiredBoardQuests(playerGuid, timestamp)
		db.query("DELETE FROM `player_dynastie_board_quests` WHERE `player_id` = " .. (tonumber(playerGuid) or 0) .. " AND `expires_at` <= " .. (tonumber(timestamp) or os.time()))
	end

	local function getAcceptedBoardQuestRows(playerGuid, timestamp)
		ensureBoardQuestTable()
		purgeExpiredBoardQuests(playerGuid, timestamp)
		local rows = {}
		local query = db.storeQuery("SELECT `guild_id`, `config_id`, `event_key`, `quest_id`, `progress`, `target`, `accepted_at`, `expires_at` FROM `player_dynastie_board_quests` WHERE `player_id` = " .. (tonumber(playerGuid) or 0) .. " ORDER BY `accepted_at` ASC")
		if not query then
			return rows
		end
		repeat
			rows[#rows + 1] = {
				guildId = result.getNumber(query, "guild_id"),
				configId = result.getString(query, "config_id"),
				eventKey = result.getString(query, "event_key"),
				questId = result.getString(query, "quest_id"),
				progress = result.getNumber(query, "progress"),
				target = result.getNumber(query, "target"),
				acceptedAt = result.getNumber(query, "accepted_at"),
				expiresAt = result.getNumber(query, "expires_at")
			}
		until not result.next(query)
		result.free(query)
		return rows
	end

	local function sendAcceptedBoardPayload(player)
		if not player or not api or not api.sendGuildPayload then
			return
		end
		local payload = { quests = {} }
		for _, row in ipairs(getAcceptedBoardQuestRows(player:getGuid(), os.time())) do
			local definition = getBoardQuestDefinition(row.questId)
			if definition then
				local ownerRewards = (getConfig().EVENT_BOARD_OWNER_REWARDS or {})[tostring(definition.tier or "small")] or {}
				payload.quests[#payload.quests + 1] = {
					id = definition.id,
					name = sanitizePayloadText(definition.name),
					icon = sanitizePayloadText(definition.icon),
					objective = sanitizePayloadText(buildBoardQuestObjective(definition)),
					type = definition.type,
					target = tonumber(row.target) or tonumber(definition.target) or 0,
					progress = tonumber(row.progress) or 0,
					configId = row.configId,
					expiresAt = tonumber(row.expiresAt) or 0,
					rewardText = sanitizePayloadText(buildRewardText(definition.playerRewards)),
					rewardEntries = api.buildQuestRewardEntries and api.buildQuestRewardEntries(definition.playerRewards) or {},
					guildRewardText = sanitizePayloadText(buildGuildRewardText(definition.guildRewards)),
					ownerRewardText = sanitizePayloadText(buildGuildRewardText(ownerRewards)),
					ownerRewardEntries = buildOwnerRewardEntries(ownerRewards)
				}
			end
		end
		api.sendGuildPayload(player, "dynastieBoardAccepted", payload)
	end

	local function applyGuildRewards(guildId, rewards)
		guildId = tonumber(guildId) or 0
		rewards = type(rewards) == "table" and rewards or {}
		if guildId <= 0 or not api or type(api.getGuildRowById) ~= "function" then
			return
		end
		if (tonumber(rewards.dynastieExp) or 0) > 0 and api.awardDynastieExperience then
			api.awardDynastieExperience(guildId, math.floor(tonumber(rewards.dynastieExp) or 0))
		end
		local updates = {}
		if (tonumber(rewards.guildExp) or 0) > 0 then
			updates[#updates + 1] = "`guild_experience` = `guild_experience` + " .. math.floor(tonumber(rewards.guildExp) or 0)
		end
		if (tonumber(rewards.guildGold) or 0) > 0 then
			updates[#updates + 1] = "`balance` = `balance` + " .. math.floor(tonumber(rewards.guildGold) or 0)
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 then
			updates[#updates + 1] = "`dynastie_tokens` = `dynastie_tokens` + " .. math.floor(tonumber(rewards.dynastieTokens) or 0)
		end
		if #updates > 0 then
			db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guildId)
		end
	end

	local function applyOwnerCoreRewards(configId, rewards)
		configId = tostring(configId or "")
		rewards = type(rewards) == "table" and rewards or {}
		if configId == "" or not api then
			return false
		end
		if type(api.addDynastieCoreRewards) == "function" then
			return api.addDynastieCoreRewards(configId, rewards) == true
		end
		return false
	end

	local function awardPlayerRewards(player, rewards)
		rewards = type(rewards) == "table" and rewards or {}
		if (tonumber(rewards.exp) or 0) > 0 then
			player:addExperience(math.floor(tonumber(rewards.exp) or 0), true)
		end
		for _, item in ipairs(rewards.items or {}) do
			player:addItem(tonumber(item.itemId) or 0, tonumber(item.count) or 1)
		end
	end

	local function completeBoardQuest(player, row, definition)
		db.query("DELETE FROM `player_dynastie_board_quests` WHERE `player_id` = " .. player:getGuid() .. " AND `event_key` = " .. db.escapeString(row.eventKey) .. " AND `quest_id` = " .. db.escapeString(row.questId))
		incrementBoardQuestCompletionCount(player:getGuid(), row.eventKey, row.questId)
		awardPlayerRewards(player, definition.playerRewards)
		applyGuildRewards(row.guildId, definition.guildRewards)
		local ownerRewards = getConfig().EVENT_BOARD_OWNER_REWARDS or {}
		local ownerRewardSet = ownerRewards[tostring(definition.tier or "small")] or {}
		applyOwnerCoreRewards(row.configId, ownerRewardSet)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Board quest completed: %s.", definition.name))
	end

	local function advanceBoardQuestProgress(player, predicate, amount)
		if not player then
			return
		end
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if amount <= 0 then
			return
		end
		local changed = false
		for _, row in ipairs(getAcceptedBoardQuestRows(player:getGuid(), os.time())) do
			local definition = getBoardQuestDefinition(row.questId)
			if definition and predicate(definition, row) then
				local newProgress = math.min(tonumber(row.target) or tonumber(definition.target) or 0, (tonumber(row.progress) or 0) + amount)
				if newProgress >= (tonumber(row.target) or tonumber(definition.target) or 0) then
					completeBoardQuest(player, row, definition)
					changed = true
				else
					db.query("UPDATE `player_dynastie_board_quests` SET `progress` = " .. newProgress .. ", `updated_at` = " .. os.time() .. " WHERE `player_id` = " .. player:getGuid() .. " AND `event_key` = " .. db.escapeString(row.eventKey) .. " AND `quest_id` = " .. db.escapeString(row.questId))
					changed = true
				end
			end
		end
		return changed
	end

	function eventsApi.sendAccepted(player)
		sendAcceptedBoardPayload(player)
	end

	function eventsApi.useBoard(player, position)
		if not player then
			return false
		end
		local guildId = tonumber(api.resolvePlayerGuildId and api.resolvePlayerGuildId(player) or 0) or 0
		if guildId <= 0 then
			if api.sendGuildError then
				api.sendGuildError(player, "You must be in a guild to use this board.")
			end
			return true
		end
		local configId = getBoardConfigIdByPosition(position)
		local offers, context = getBoardOfferDefinitions(configId, os.time())
		if not context then
			if api.sendGuildError then
				api.sendGuildError(player, "No world board event is active here.")
			end
			return true
		end
		local accepted = getAcceptedBoardQuestRows(player:getGuid(), os.time())
		local payload = {
			configId = configId,
			eventName = sanitizePayloadText(context.eventDefinition.name),
			expiresAt = context.expiresAt,
			maxAccepted = math.max(1, tonumber(getConfig().EVENT_BOARD_MAX_ACCEPTED) or 3),
			repeatLimit = BOARD_QUEST_REPEAT_LIMIT,
			acceptedCount = #accepted,
			quests = {}
		}
		for _, definition in ipairs(offers) do
			local repeatCount = getBoardQuestCompletionCount(player:getGuid(), context.eventKey, definition.id)
			local ownerRewards = (getConfig().EVENT_BOARD_OWNER_REWARDS or {})[tostring(definition.tier or "small")] or {}
			payload.quests[#payload.quests + 1] = {
				id = definition.id,
				name = sanitizePayloadText(definition.name),
				icon = sanitizePayloadText(definition.icon),
				objective = sanitizePayloadText(buildBoardQuestObjective(definition)),
				target = definition.target,
				type = definition.type,
				repeatLimit = BOARD_QUEST_REPEAT_LIMIT,
				repeatCount = repeatCount,
				rewardText = sanitizePayloadText(buildRewardText(definition.playerRewards)),
				rewardEntries = api.buildQuestRewardEntries and api.buildQuestRewardEntries(definition.playerRewards) or {},
				guildRewardText = sanitizePayloadText(buildGuildRewardText(definition.guildRewards)),
				ownerRewardText = sanitizePayloadText(buildGuildRewardText(ownerRewards)),
				ownerRewardEntries = buildOwnerRewardEntries(ownerRewards)
			}
		end
		api.sendGuildPayload(player, "dynastieBoardOffers", payload)
		sendAcceptedBoardPayload(player)
		return true
	end

	function eventsApi.acceptBoardQuest(player, data)
		if not player then
			return
		end
		local guildId = tonumber(api.resolvePlayerGuildId and api.resolvePlayerGuildId(player) or 0) or 0
		if guildId <= 0 then
			return
		end
		local configId = tostring(data and data.configId or "")
		local questId = tostring(data and data.questId or "")
		local offers, context = getBoardOfferDefinitions(configId, os.time())
		if not context then
			return
		end
		local definition = nil
		for _, offer in ipairs(offers) do
			if offer.id == questId then
				definition = offer
				break
			end
		end
		if not definition then
			return
		end
		local accepted = getAcceptedBoardQuestRows(player:getGuid(), os.time())
		local maxAccepted = math.max(1, tonumber(getConfig().EVENT_BOARD_MAX_ACCEPTED) or 3)
		if #accepted >= maxAccepted then
			if api.sendGuildError then
				api.sendGuildError(player, string.format("You can only accept %d board quests.", maxAccepted))
			end
			return
		end
		for _, row in ipairs(accepted) do
			if row.questId == questId and row.eventKey == context.eventKey then
				return
			end
		end
		local repeatCount = getBoardQuestCompletionCount(player:getGuid(), context.eventKey, questId)
		if repeatCount >= BOARD_QUEST_REPEAT_LIMIT then
			if api.sendGuildError then
				api.sendGuildError(player, string.format("You already completed this board quest %d times for the current board rotation.", BOARD_QUEST_REPEAT_LIMIT))
			end
			return
		end
		ensureBoardQuestTable()
		local now = os.time()
		db.query("INSERT INTO `player_dynastie_board_quests` (`player_id`, `guild_id`, `config_id`, `event_key`, `quest_id`, `progress`, `target`, `accepted_at`, `expires_at`, `created_at`, `updated_at`) VALUES (" ..
			player:getGuid() .. ", " .. guildId .. ", " .. db.escapeString(configId) .. ", " .. db.escapeString(context.eventKey) .. ", " .. db.escapeString(questId) .. ", 0, " .. (tonumber(definition.target) or 0) .. ", " .. now .. ", " .. context.expiresAt .. ", " .. now .. ", " .. now .. ")")
		sendAcceptedBoardPayload(player)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Accepted board quest: %s.", definition.name))
	end

	function eventsApi.onKill(player, target)
		if not player or not target then
			return
		end
		if target:isPlayer() then
			advanceBoardQuestProgress(player, function(definition)
				return definition.type == "kill_any_player"
			end, 1)
			return
		end
		if target:isMonster() and not target:getMaster() then
			advanceBoardQuestProgress(player, function(definition)
				return definition.type == "kill_any_monster"
			end, 1)
			if target:getType() and target:getType().isRewardBoss and target:getType():isRewardBoss() then
				advanceBoardQuestProgress(player, function(definition)
					return definition.type == "kill_reward_boss"
				end, 1)
			end
		end
	end

	function eventsApi.onGainExperience(player, exp)
		advanceBoardQuestProgress(player, function(definition)
			return definition.type == "gain_experience"
		end, math.max(0, math.floor(tonumber(exp) or 0)))
	end

	function eventsApi.onProfessionActivity(player, profession, amount)
		profession = tostring(profession or ""):lower()
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if profession == "" or amount <= 0 then
			return
		end

		advanceBoardQuestProgress(player, function(definition)
			return definition.type == "profession_activity" and tostring(definition.profession or ""):lower() == profession
		end, amount)
	end

	function eventsApi.refreshBoardSpawns(timestamp)
		local boardItemId = getBoardItemId()
		if boardItemId <= 0 then
			return
		end

		timestamp = tonumber(timestamp) or os.time()
		for configId, position in pairs(getBoardPositions()) do
			if isValidBoardPosition(position) then
				local tile = Tile(Position(position.x, position.y, position.z))
				local existingBoard = findBoardItemOnTile(tile)
				local boardContext = getActiveBoardContext(configId, timestamp)
				local occupiedByCreature = tileHasCreatures(tile)

				if boardContext then
					if not existingBoard and not occupiedByCreature then
						local spawned = Game.createItem(boardItemId, 1, Position(position.x, position.y, position.z))
						if spawned then
							spawned:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Dynasty world quest board")
						end
					end
				elseif existingBoard and not occupiedByCreature then
					existingBoard:remove()
				end
			end
		end
	end

	eventsApi.STORAGE_GUILD_EXP_BOOST_UNTIL = STORAGE_GUILD_EXP_BOOST_UNTIL
	eventsApi.STORAGE_PET_DOUBLE_EXP_UNTIL = STORAGE_PET_DOUBLE_EXP_UNTIL

	function eventsApi.send(player, data)
		if not api or type(api.sendGuildPayload) ~= "function" then
			return
		end

		local configId = tostring(data and data.configId or "")
		local monthOffset = math.floor(tonumber(data and data.monthOffset or 0) or 0)
		api.sendGuildPayload(player, "dynastieEvents", buildPayload(configId, monthOffset))
	end

	return eventsApi
end

return {
	create = create
}
