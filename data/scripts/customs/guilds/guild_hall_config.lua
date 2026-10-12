local GuildManagement = {
	PERMISSIONS = {
		INVITE_MEMBERS = 0,
		EDIT_MEMBERS = 1,
		EDIT_ROLES = 2,
		EDIT_SETTINGS = 3,
		MANAGE_GOLD = 4,
		MANAGE_PERKS = 5,
		DEPOSIT_STORAGE = 7,
		WITHDRAW_STORAGE = 8,
		MANAGE_PRISM = 9,
		MANAGE_DYNASTIE = 10,
		LAST = 10,
		ALL = -1
	},
	MESSAGE_TYPES = {
		JOIN_INVITATION = 1,
		KICKED_OUT = 2,
		JOIN_REQUEST = 3,
		MEMBER_JOINED = 4,
		MEMBER_LEFT = 5,
		GOLD_DEPOSIT = 6,
		WAR_DECLARATION = 7,
		STORAGE_DEPOSIT = 8,
		STORAGE_WITHDRAW = 9,
		PRISM_ATTACK = 10,
		PRISM_COLLECT = 11,
		PRISM_STOLEN = 12,
		QUEST_REWARD = 13,
		BLACK_MARKET_PURCHASE = 14,
		DYNASTIE_COLLECT = 15,
		DYNASTIE_ATTACK = 16
	}
}
-- Base How many guild members when creating a guild
GuildManagement.MEMBER_BASE_SLOTS = 10
-- Slots for the perk, per level +5 members
GuildManagement.MEMBER_SLOTS_PER_LEVEL = 5
-- Max Slots 100, max members on guild
GuildManagement.MEMBER_MAX_SLOTS = 100
-- Inbox Page to not be huge 20 message is correct
GuildManagement.INBOX_PAGE_SIZE = 20
-- Removing message after 30 days
GuildManagement.INBOX_RETENTION_DAYS = 30
-- Top Page Size , 15 page
GuildManagement.TOP_PAGE_SIZE = 15
-- Experience required per level on guild, then current level * exp required
GuildManagement.NEXT_LEVEL_BASE = 105000
-- Premium points give exp to the guild, how many 1 premium point in exp = 100
GuildManagement.PREMIUM_POINT_EXP = 100
-- Storage of guild, how many slots starting, 10
GuildManagement.STORAGE_BASE_SLOTS = 10
-- Slots per level perk upgrade on storage 5
GuildManagement.STORAGE_SLOTS_PER_LEVEL = 5
-- Prism base slot on new guilds 0, is upgraded with perks
GuildManagement.PRISM_BASE_SLOTS = 0
-- Prism per level upgraded
GuildManagement.PRISM_SLOTS_PER_LEVEL = 1
-- Max prisms, 4 per guild is enough
GuildManagement.PRISM_MAX_SLOTS = 4
-- Base Dynasty slots 0 is default
GuildManagement.DYNASTIE_BASE_SLOTS = 0
-- Dynasty how many unlock per perk upgraded, 1
GuildManagement.DYNASTIE_SLOTS_PER_LEVEL = 1
-- Dynasty max slots 3 per guild
GuildManagement.DYNASTIE_MAX_SLOTS = 3
-- Dynasty per pages on dynasty panel, 10
GuildManagement.PRISM_PAGE_SIZE = 10
-- Storage of Prism (loot), 30 
GuildManagement.PRISM_STORAGE_SLOTS = 30
-- Save Prism Info interval
GuildManagement.PRISM_SAVE_INTERVAL_MS = 30000
-- Teleport button on prism , 300s cooldown
GuildManagement.PRISM_TELEPORT_COOLDOWN = 5 * 60
-- Prism attack preparation in seconds 600s - 10min
GuildManagement.PRISM_ATTACK_PREPARE_SECONDS = 10 * 60
-- Prism attack duration 15min
GuildManagement.PRISM_ATTACK_DURATION_SECONDS = 15 * 60
-- Prism Shield enabled once defenders win, 6h
GuildManagement.PRISM_ATTACK_SHIELD_SECONDS = 6 * 60 * 60
-- Then time to reattack this prism = 6h
GuildManagement.PRISM_ATTACK_REATTACK_SECONDS = 6 * 60 * 60
-- Prism Grace is if you leave the zone radius where is placed the prism , 15s you are kicked from battle
GuildManagement.PRISM_ATTACK_LEAVE_GRACE_SECONDS = 15
-- Minimum attackers on prism
GuildManagement.PRISM_ATTACK_MIN_ATTACKERS = 1
-- Minimum defenders on prism
GuildManagement.PRISM_ATTACK_MIN_DEFENDERS = 0
-- Prism area radius, default 0 because is scripted on the prism lua file
GuildManagement.PRISM_ATTACK_AREA_RADIUS = 0
-- Floots for prism attacks if players move upper or down floor, can continue pvp
GuildManagement.PRISM_ATTACK_AREA_FLOORS = 15
-- Steal percent if attacker win a battle on prism
GuildManagement.PRISM_ATTACK_WIN_STEAL_PERCENT = 25
-- Place cooldown a prism
GuildManagement.PRISM_PLACE_COOLDOWN_SECONDS = 2 * 60 * 60
-- Dynasty prepare battle, 10min
GuildManagement.DYNASTIE_ATTACK_PREPARE_SECONDS = 10 * 60
-- Dynasty attack duration 15min
GuildManagement.DYNASTIE_ATTACK_DURATION_SECONDS = 15 * 60
-- Dynasty Shield, 6h
GuildManagement.DYNASTIE_ATTACK_SHIELD_SECONDS = 6 * 60 * 60
-- Reattack this dynasty per guild, 7 days
GuildManagement.DYNASTIE_ATTACK_REATTACK_SECONDS = 7 * 24 * 60 * 60
-- Leave grace , if you leave the battle radius you are kicked in 15s
GuildManagement.DYNASTIE_ATTACK_LEAVE_GRACE_SECONDS = 15
-- Minimum dynasty attackers
GuildManagement.DYNASTIE_ATTACK_MIN_ATTACKERS = 1
-- Minimum defenders (players) -- because there is also defenders monsters
GuildManagement.DYNASTIE_ATTACK_MIN_DEFENDERS = 0
-- Dynasty attack radius, default is 80, here is 0 if not scripted on the file, but it is
GuildManagement.DYNASTIE_ATTACK_AREA_RADIUS = 0
-- Floors where pvp can occur, 15 floors
GuildManagement.DYNASTIE_ATTACK_AREA_FLOORS = 15
-- Quest Daily 3 
GuildManagement.QUEST_DAILY_COUNT = 3
-- Quests Weekly 3
GuildManagement.QUEST_WEEKEND_COUNT = 3
-- Quests Monthly 3
GuildManagement.QUEST_MONTHLY_COUNT = 3
-- Achievements per page on guild, 9
GuildManagement.ACHIEVEMENT_PAGE_SIZE = 6
-- Black market, items daily count
GuildManagement.BLACK_MARKET_DAILY_COUNT = 10
-- Quests daily duration
GuildManagement.QUEST_DAILY_SECONDS = 24 * 60 * 60
-- Quest weekly duration
GuildManagement.QUEST_WEEKEND_SECONDS = 7 * 24 * 60 * 60
-- Quest monthly duration
GuildManagement.QUEST_MONTHLY_SECONDS = 30 * 24 * 60 * 60
GuildManagement.PERKS = dofile("data/scripts/customs/guilds/guild_hall_perks.lua")

return {
	GUILD_OPCODE = 231,
	GuildManagement = GuildManagement,
	-- Subid for perks
	GUILD_PERK_REGEN_SUBID = 938100,
	GUILD_PERK_CRIT_CHANCE_SUBID = 938101,
	GUILD_PERK_CRIT_DAMAGE_SUBID = 938102,
	GUILD_PRISM_TELEPORT_STORAGE = 938103,
	-- Bag ID for collect the loot of prism that goes to the player who collect it and not on storage of guild
	GUILD_PRISM_LOOT_BACKPACK_ID = 30653,
	-- Capacity of the bag 35 slots (to split on more bags if needed)
	GUILD_PRISM_LOOT_BACKPACK_CAPACITY = 35,
	-- Stack limit x1000
	GUILD_ITEM_STACK_LIMIT = 1000,
	-- Rarity Chance on prism 2%
	PRISM_RARITY_BASE_CHANCE = 2,
	-- Bonuses storage, do not edit is related to rarity
	PRISM_RARITY_BONUS_STORAGES = {405790, 405793},
	-- Default rarity percents - increased for the guild system a little bit
	PRISM_RARITIES = {
		{ id = 1,  chance = 35.0, name = "Common" },
		{ id = 2,  chance = 24.0, name = "Uncommon" },
		{ id = 3,  chance = 19.0, name = "Rare" },
		{ id = 4,  chance = 16.0, name = "Epic" },
		{ id = 5,  chance = 11.5, name = "Legendary" },
		{ id = 6,  chance = 9.5, name = "Exotic" },
		{ id = 7,  chance = 8.0, name = "Mythic" },
		{ id = 8,  chance = 7.5, name = "Chaos" },
		{ id = 9,  chance = 6.8, name = "Eternal" },
		{ id = 10, chance = 5.0, name = "Divine" },
		{ id = 11, chance = 4.3, name = "Phantasmal" },
		{ id = 12, chance = 3.7, name = "Celestial" },
		{ id = 13, chance = 2.2, name = "Cosmic" },
		{ id = 14, chance = 1.8, name = "Abyssal" },
		{ id = 15, chance = 0.5, name = "Transcendent" }
	},
	PrismState = {
		loaded = false,
		flushScheduled = false,
		byConfigId = {},
		byGuildId = {},
		lootByPrismId = {}
	},
	PrismAttackState = {
		byConfigId = {},
		tickScheduled = false
	}
}
