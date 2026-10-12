print(">> [Guild Hall System] Perks, Prisms, Storage, Achievements, Quests, Dynasty Loaded")
local GuildHallConfig = dofile("data/scripts/customs/guilds/guild_hall_config.lua")
GUILD_OPCODE = GuildHallConfig.GUILD_OPCODE
GuildManagement = GuildHallConfig.GuildManagement
GUILD_PERK_REGEN_SUBID = GuildHallConfig.GUILD_PERK_REGEN_SUBID
GUILD_PERK_CRIT_CHANCE_SUBID = GuildHallConfig.GUILD_PERK_CRIT_CHANCE_SUBID
GUILD_PERK_CRIT_DAMAGE_SUBID = GuildHallConfig.GUILD_PERK_CRIT_DAMAGE_SUBID
GUILD_PRISM_TELEPORT_STORAGE = GuildHallConfig.GUILD_PRISM_TELEPORT_STORAGE
GUILD_PRISM_LOOT_BACKPACK_ID = GuildHallConfig.GUILD_PRISM_LOOT_BACKPACK_ID
GUILD_PRISM_LOOT_BACKPACK_CAPACITY = GuildHallConfig.GUILD_PRISM_LOOT_BACKPACK_CAPACITY
GUILD_ITEM_STACK_LIMIT = GuildHallConfig.GUILD_ITEM_STACK_LIMIT
PRISM_RARITY_BASE_CHANCE = GuildHallConfig.PRISM_RARITY_BASE_CHANCE
PRISM_RARITY_BONUS_STORAGES = GuildHallConfig.PRISM_RARITY_BONUS_STORAGES
PRISM_RARITIES = GuildHallConfig.PRISM_RARITIES
PrismState = GuildHallConfig.PrismState
PrismAttackState = GuildHallConfig.PrismAttackState
local prismViewerPages = {}
local prismActiveViewers = {}

local GuildQuestPools = dofile("data/scripts/customs/guilds/guild_hall_quests.lua")
_G.GuildQuestPools = GuildQuestPools
for name, value in pairs(dofile("data/scripts/customs/guilds/guild_hall_quest_utils.lua")) do
	_G[name] = value
end
for name, value in pairs(dofile("data/scripts/customs/guilds/guild_hall_core.lua")) do
	_G[name] = value
end
local GuildAchievements = nil
local GuildBlackMarket = nil
local GuildDynastie = nil
local GuildDynastieQuests = nil
local GuildDynastieAchievements = nil
local GuildDynastieEvents = nil
local GUILD_STORAGE_ENABLED = true
local GUILD_PRISM_ENABLED = true
local GUILD_QUESTS_ENABLED = true
local GUILD_ACHIEVEMENTS_ENABLED = true
local GUILD_BLACKMARKET_ENABLED = true
local GUILD_DYNASTIE_ENABLED = true

local refreshGuildPerkState
local refreshGuildForMembers
local refreshDynastieBattleForMembers
local refreshPrismBattleForMembers
local enforceGuildPrismCapacity
local buildPrismAttackPayload
local hasPermission
local getGuildInboxRecipients
local addGuildMessages
local addPrismLootDetailed
local getPrismRarityBonus
local rollPrismRarity
local serializeStorageItemAttributes
local hasTable
local hasColumn
local refreshGuildStorageForGuild
local calculateGuildLevelProgress
local canUsePrismTeleport
local awardGuildQuestProfessionActivity

hasTable = _G.hasTable
hasColumn = _G.hasColumn

local function getPrismConfig()
	return rawget(_G, "GuildHallPrismConfig") or {}
end

local function getGuildById(guildId)
	if not guildId or guildId <= 0 then
		return nil
	end
	return Guild(guildId)
end

local function getOwnedGuildId(playerId)
	local resultId = db.storeQuery("SELECT `id` FROM `guilds` WHERE `ownerid` = " .. playerId)
	if not resultId then
		return 0
	end

	local guildId = result.getNumber(resultId, "id")
	result.free(resultId)
	return guildId
end

local function getOnlineGuildPlayers(guildId)
	local guild = getGuildById(guildId)
	if not guild then
		return {}
	end
	return guild:getMembersOnline()
end

local function getGuildRowById(guildId)
	local fields = { "`id`", "`name`", "`ownerid`", "`motd`" }
	if hasColumn("guilds", "balance") then
		table.insert(fields, "`balance`")
	end
	if hasColumn("guilds", "emblem") then
		table.insert(fields, "`emblem`")
	end
	if hasColumn("guilds", "language") then
		table.insert(fields, "`language`")
	end
	if hasColumn("guilds", "join_status") then
		table.insert(fields, "`join_status`")
	end
	if hasColumn("guilds", "required_level") then
		table.insert(fields, "`required_level`")
	end
	if hasColumn("guilds", "creationdata") then
		table.insert(fields, "`creationdata`")
	end
	if hasColumn("guilds", "guild_level") then
		table.insert(fields, "`guild_level`")
	end
	if hasColumn("guilds", "guild_experience") then
		table.insert(fields, "`guild_experience`")
	end
	if hasColumn("guilds", "contribution") then
		table.insert(fields, "`contribution`")
	end
	if hasColumn("guilds", "premium_balance") then
		table.insert(fields, "`premium_balance`")
	end
	if hasColumn("guilds", "premium_contribution") then
		table.insert(fields, "`premium_contribution`")
	end
	if hasColumn("guilds", "dynastie_tokens") then
		table.insert(fields, "`dynastie_tokens`")
	end
	if hasColumn("guilds", "dynastie_level") then
		table.insert(fields, "`dynastie_level`")
	end
	if hasColumn("guilds", "dynastie_experience") then
		table.insert(fields, "`dynastie_experience`")
	end
	if hasColumn("guilds", "perks") then
		table.insert(fields, "`perks`")
	end

	local resultId = db.storeQuery("SELECT " .. table.concat(fields, ", ") .. " FROM `guilds` WHERE `id` = " .. guildId)
	if not resultId then
		return nil
	end

	local row = {
		id = result.getNumber(resultId, "id"),
		name = result.getString(resultId, "name"),
		ownerid = result.getNumber(resultId, "ownerid"),
		motd = result.getString(resultId, "motd"),
		balance = 0,
		emblem = 0,
		language = 1,
		join_status = 1,
		required_level = 0,
		creationdata = 0,
		guild_level = 1,
		guild_experience = 0,
		contribution = 0,
		premium_balance = 0,
		premium_contribution = 0,
		dynastie_tokens = 0,
		dynastie_level = 1,
		dynastie_experience = 0,
		perks = ""
	}
	if hasColumn("guilds", "balance") then
		row.balance = result.getNumber(resultId, "balance")
	end
	if hasColumn("guilds", "emblem") then
		row.emblem = result.getString(resultId, "emblem")
	end
	if hasColumn("guilds", "language") then
		row.language = result.getNumber(resultId, "language")
	end
	if hasColumn("guilds", "join_status") then
		row.join_status = result.getNumber(resultId, "join_status")
	end
	if hasColumn("guilds", "required_level") then
		row.required_level = result.getNumber(resultId, "required_level")
	end
	if hasColumn("guilds", "creationdata") then
		row.creationdata = result.getNumber(resultId, "creationdata")
	end
	if hasColumn("guilds", "guild_level") then
		row.guild_level = result.getNumber(resultId, "guild_level")
	end
	if hasColumn("guilds", "guild_experience") then
		row.guild_experience = result.getNumber(resultId, "guild_experience")
	end
	if hasColumn("guilds", "contribution") then
		row.contribution = result.getNumber(resultId, "contribution")
	end
	if hasColumn("guilds", "premium_balance") then
		row.premium_balance = result.getNumber(resultId, "premium_balance")
	end
	if hasColumn("guilds", "premium_contribution") then
		row.premium_contribution = result.getNumber(resultId, "premium_contribution")
	end
	if hasColumn("guilds", "dynastie_tokens") then
		row.dynastie_tokens = result.getNumber(resultId, "dynastie_tokens")
	end
	if hasColumn("guilds", "dynastie_level") then
		row.dynastie_level = result.getNumber(resultId, "dynastie_level")
	end
	if hasColumn("guilds", "dynastie_experience") then
		row.dynastie_experience = result.getNumber(resultId, "dynastie_experience")
	end
	if hasColumn("guilds", "perks") then
		row.perks = result.getString(resultId, "perks")
	end
	result.free(resultId)
	return row
end

local function getGuildRankIdByLevel(guildId, level)
	local resultId = db.storeQuery("SELECT `id` FROM `guild_ranks` WHERE `guild_id` = " .. guildId .. " AND `level` = " .. level)
	if not resultId then
		return 0
	end
	local id = result.getNumber(resultId, "id")
	result.free(resultId)
	return id
end

local function getGuildRankRowByLevel(guildId, level)
	local fields = { "`id`", "`name`", "`level`" }
	if hasColumn("guild_ranks", "permissions") then
		table.insert(fields, "`permissions`")
	end

	local resultId = db.storeQuery("SELECT " .. table.concat(fields, ", ") .. " FROM `guild_ranks` WHERE `guild_id` = " .. guildId .. " AND `level` = " .. level .. " LIMIT 1")
	if not resultId then
		return nil
	end

	local row = {
		id = result.getNumber(resultId, "id"),
		name = result.getString(resultId, "name"),
		level = result.getNumber(resultId, "level"),
		permissions = hasColumn("guild_ranks", "permissions") and result.getNumber(resultId, "permissions") or 0
	}
	result.free(resultId)
	return row
end

local function getGuildDefaultRankId(guildId)
	return getGuildRankIdByLevel(guildId, 1)
end

local function getGuildRankCount(guildId)
	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM `guild_ranks` WHERE `guild_id` = " .. guildId)
	if not resultId then
		return 0
	end

	local count = result.getNumber(resultId, "count")
	result.free(resultId)
	return count
end

local function normalizeLegacyGuildDefaultRanks(guildId)
	local query = db.storeQuery("SELECT `id`, `name`, `level` FROM `guild_ranks` WHERE `guild_id` = " .. guildId .. " ORDER BY `level` ASC, `id` ASC")
	if not query then
		return
	end

	local byName = {}
	repeat
		local rankId = result.getNumber(query, "id")
		local rankName = result.getString(query, "name")
		byName[rankName] = {
			id = rankId,
			name = rankName,
			level = result.getNumber(query, "level")
		}
	until not result.next(query)
	result.free(query)

	local replacements = {
		{ duplicate = "Leader", canonical = "the Leader" },
		{ duplicate = "Vice Leader", canonical = "a Vice-Leader" },
		{ duplicate = "Member", canonical = "a Member" }
	}

	for _, replacement in ipairs(replacements) do
		local duplicateRank = byName[replacement.duplicate]
		local canonicalRank = byName[replacement.canonical]
		if duplicateRank and canonicalRank then
			db.query("UPDATE `guild_membership` SET `rank_id` = " .. canonicalRank.id .. " WHERE `guild_id` = " .. guildId .. " AND `rank_id` = " .. duplicateRank.id)
			db.query("DELETE FROM `guild_ranks` WHERE `id` = " .. duplicateRank.id .. " AND `guild_id` = " .. guildId)
		end
	end
end

local function getPlayerGuildMembership(playerId)
	local resultId = db.storeQuery("SELECT `guild_id`, `rank_id`, `nick` FROM `guild_membership` WHERE `player_id` = " .. playerId)
	if not resultId then
		return nil
	end

	local data = {
		guildId = result.getNumber(resultId, "guild_id"),
		rankId = result.getNumber(resultId, "rank_id"),
		nick = result.getString(resultId, "nick")
	}
	result.free(resultId)
	return data
end

local function resolvePlayerGuildId(player)
	if not player then
		return 0
	end

	local guild = player:getGuild()
	if guild then
		local guildId = tonumber(guild:getId()) or 0
		if guildId > 0 then
			return guildId
		end
	end

	local membership = getPlayerGuildMembership(player:getGuid())
	if membership and tonumber(membership.guildId) and tonumber(membership.guildId) > 0 then
		return tonumber(membership.guildId)
	end

	return tonumber(getOwnedGuildId(player:getGuid())) or 0
end

local function broadcastCreatureGuildTitle(targetPlayer, guildId, rankLevel)
	if not targetPlayer or not targetPlayer.getId then
		return
	end

	guildId = tonumber(guildId) or 0
	rankLevel = tonumber(rankLevel) or 0

	local guildName = ""
	if guildId > 0 then
		local guild = getGuildById(guildId)
		if guild and guild.getName then
			guildName = guild:getName()
		end
	end

	local payload = {
		id = targetPlayer:getId(),
		guildName = guildName,
		rankLevel = rankLevel
	}

	for _, onlinePlayer in ipairs(Game.getPlayers()) do
		sendGuildPayload(onlinePlayer, "creatureGuildTitle", payload)
	end
end

local function getGuildMemberLimit(guildLevel, perks)
	local perkLevel = 0
	if type(perks) == "table" then
		perkLevel = tonumber(perks[8] or perks["8"] or 0) or 0
	end
	local memberLimit = GuildManagement.MEMBER_BASE_SLOTS + (perkLevel * GuildManagement.MEMBER_SLOTS_PER_LEVEL)
	if memberLimit > GuildManagement.MEMBER_MAX_SLOTS then
		memberLimit = GuildManagement.MEMBER_MAX_SLOTS
	end
	return memberLimit
end

local function getPerkDefinition(perkId)
	for _, perk in ipairs(GuildManagement.PERKS) do
		if perk.id == perkId then
			return perk
		end
	end

	return nil
end

local function createEmptyGuildPerks()
	local perks = {}
	for _, perk in ipairs(GuildManagement.PERKS) do
		perks[tostring(perk.id)] = 0
	end
	return perks
end

local function normalizeGuildPerks(perks)
	local normalized = createEmptyGuildPerks()
	if type(perks) ~= "table" then
		return normalized
	end

	for _, perk in ipairs(GuildManagement.PERKS) do
		local value = perks[perk.id]
		if value == nil then
			value = perks[tostring(perk.id)]
		end
		value = math.max(0, math.min(perk.maxLevel, tonumber(value) or 0))
		normalized[tostring(perk.id)] = value
	end

	return normalized
end

local function decodeGuildPerks(perksValue)
	if type(perksValue) == "table" then
		return normalizeGuildPerks(perksValue)
	end

	if type(perksValue) ~= "string" or perksValue == "" then
		return createEmptyGuildPerks()
	end

	local ok, decoded = pcall(function()
		return json.decode(perksValue)
	end)
	if not ok then
		return createEmptyGuildPerks()
	end

	return normalizeGuildPerks(decoded)
end

local function encodeGuildPerks(perks)
	return json.encode(normalizeGuildPerks(perks))
end

local function hexEncode(str)
	if type(str) ~= "string" or str == "" then
		return ""
	end

	return (str:gsub(".", function(c)
		return string.format("%02X", string.byte(c))
	end))
end

local function hexDecode(str)
	if type(str) ~= "string" or str == "" then
		return ""
	end

	return (str:gsub("%x%x", function(cc)
		return string.char(tonumber(cc, 16))
	end))
end

local function getGuildPerkLevel(perks, perkId)
	if type(perks) ~= "table" then
		return 0
	end

	return tonumber(perks[perkId] or perks[tostring(perkId)] or 0) or 0
end

local function getGuildStorageCapacityFromPerks(perks)
	return GuildManagement.STORAGE_BASE_SLOTS + (getGuildPerkLevel(perks, 7) * GuildManagement.STORAGE_SLOTS_PER_LEVEL)
end

local function getGuildPrismCapacityFromPerks(perks)
	return math.min(
		GuildManagement.PRISM_MAX_SLOTS,
		GuildManagement.PRISM_BASE_SLOTS + (getGuildPerkLevel(perks, 9) * GuildManagement.PRISM_SLOTS_PER_LEVEL)
	)
end

local function getGuildDynastieCapacityFromPerks(perks)
	return math.min(
		GuildManagement.DYNASTIE_MAX_SLOTS,
		GuildManagement.DYNASTIE_BASE_SLOTS + (getGuildPerkLevel(perks, 10) * GuildManagement.DYNASTIE_SLOTS_PER_LEVEL)
	)
end

local function getPrismConfigList()
	local prismConfig = getPrismConfig()
	return type(prismConfig.LOCATIONS) == "table" and prismConfig.LOCATIONS or {}
end

local function isValidPrismPosition(position)
	return type(position) == "table" and (tonumber(position.x) or 0) > 0 and (tonumber(position.y) or 0) > 0 and (tonumber(position.z) or 0) >= 0
end

local function getPrismConfigById(configId)
	for _, entry in ipairs(getPrismConfigList()) do
		if entry.id == configId then
			return entry
		end
	end
	return nil
end

local function getClientItemId(serverItemId)
	local itemType = ItemType(tonumber(serverItemId) or 0)
	if not itemType or itemType:getId() == 0 then
		return 0
	end
	return tonumber(itemType:getClientId()) or 0
end

local function resolveWorldItemId(rawItemId)
	local itemId = tonumber(rawItemId) or 0
	if itemId <= 0 then
		return 0
	end

	local itemType = ItemType(itemId)
	if itemType and itemType:getId() ~= 0 then
		return itemId
	end

	return getServerItemIdByClientId(itemId)
end

local function cleanupPrismTileItems(config, removeBaseItem)
	if not config or not isValidPrismPosition(config.position) then
		return
	end

	local tile = Tile(config.position)
	if not tile then
		return
	end

	local items = tile:getItems()
	if not items then
		return
	end

	local prismConfig = getPrismConfig()
	local baseItemId = resolveWorldItemId(config.baseItemId or prismConfig.DEFAULT_BASE_ITEM_ID or 0)
	local placedItemId = resolveWorldItemId(config.placedItemId or prismConfig.DEFAULT_PLACED_ITEM_ID or 0)
	for _, item in ipairs(items) do
		local itemId = item:getId()
		if itemId == placedItemId or (removeBaseItem and itemId == baseItemId) then
			item:remove()
		end
	end
end

local function spawnPrismWorldItem(config, state)
	if not config or not isValidPrismPosition(config.position) then
		return
	end

	local prismConfig = getPrismConfig()
	if not state or not state.guildId or state.guildId <= 0 then
		cleanupPrismTileItems(config, false)
		local markerItemId = resolveWorldItemId(config.baseItemId or prismConfig.DEFAULT_BASE_ITEM_ID or 0)
		if markerItemId <= 0 then
			return
		end
		local tile = Tile(config.position)
		if tile then
			local topItem = tile:getTopVisibleThing()
			if topItem and topItem:isItem() and topItem:getId() == markerItemId then
				return
			end
		end
		Game.createItem(markerItemId, 1, config.position)
		return
	end

	cleanupPrismTileItems(config, true)

	local itemId = resolveWorldItemId(state.placedItemId or config.placedItemId or prismConfig.DEFAULT_PLACED_ITEM_ID or 0)
	if itemId <= 0 then
		return
	end

	local tile = Tile(config.position)
	if tile then
		local topItem = tile:getTopVisibleThing()
		if topItem and topItem:isItem() and topItem:getId() == itemId then
			return
		end
	end

	local spawned = Game.createItem(itemId, 1, config.position)
	if spawned then
		spawned:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Guild prism owned by " .. (state.ownerPlayerName or "Unknown"))
	end
end

local function reindexPrismState()
	PrismState.byGuildId = {}
	for configId, state in pairs(PrismState.byConfigId) do
		if state.guildId and state.guildId > 0 then
			PrismState.byGuildId[state.guildId] = PrismState.byGuildId[state.guildId] or {}
			table.insert(PrismState.byGuildId[state.guildId], configId)
		end
	end
end

local function getPrismLootRows(prismId)
	return PrismState.lootByPrismId[prismId] or {}
end

local function countPrismUsedLootSlots(prismId)
	local total = 0
	for _, _ in pairs(getPrismLootRows(prismId)) do
		total = total + 1
	end
	return total
end

local function getFirstFreePrismLootSlot(prismId, limit)
	local rows = getPrismLootRows(prismId)
	for slot = 1, limit do
		if not rows[slot] then
			return slot
		end
	end
	return 0
end

local function flushPrismState()
	if not hasTable("guild_prisms") then
		return
	end

	local expiredConfigIds = {}
	local now = os.time()
	for configId, state in pairs(PrismState.byConfigId) do
		if state and tonumber(state.expiresAt or 0) > 0 and tonumber(state.expiresAt or 0) <= now then
			table.insert(expiredConfigIds, configId)
		end
	end

	local removedAnyExpired = false
	for _, configId in ipairs(expiredConfigIds) do
		releaseExpiredPrism(configId, now)
		removedAnyExpired = true
	end

	for configId, state in pairs(PrismState.byConfigId) do
		if state.dirty and state.id and state.id > 0 then
			db.query(
				"UPDATE `guild_prisms` SET " ..
				"`guild_id` = " .. (tonumber(state.guildId) or 0) .. ", " ..
				"`owner_player_id` = " .. (tonumber(state.ownerPlayerId) or 0) .. ", " ..
				"`owner_player_name` = " .. escape(state.ownerPlayerName or "") .. ", " ..
				"`placed_item_id` = " .. (tonumber(state.placedItemId) or 0) .. ", " ..
				"`base_item_id` = " .. (tonumber(state.baseItemId) or 0) .. ", " ..
				"`x` = " .. (tonumber(state.position and state.position.x) or 0) .. ", " ..
				"`y` = " .. (tonumber(state.position and state.position.y) or 0) .. ", " ..
				"`z` = " .. (tonumber(state.position and state.position.z) or 0) .. ", " ..
				"`radius` = " .. (tonumber(state.radius) or 0) .. ", " ..
				"`gold_buffer` = " .. math.floor(tonumber(state.goldBuffer) or 0) .. ", " ..
				"`exp_buffer` = " .. math.floor(tonumber(state.expBuffer) or 0) .. ", " ..
				"`loot_slots` = " .. (tonumber(state.lootSlots) or GuildManagement.PRISM_STORAGE_SLOTS) .. ", " ..
				"`expires_at` = " .. (tonumber(state.expiresAt) or 0) .. ", " ..
				(hasColumn("guild_prisms", "shield_until") and ("`shield_until` = " .. (tonumber(state.shieldUntil) or 0) .. ", ") or "") ..
				(hasColumn("guild_prisms", "last_attack_at") and ("`last_attack_at` = " .. (tonumber(state.lastAttackAt) or 0) .. ", ") or "") ..
				"`updated_at` = " .. os.time() ..
				" WHERE `id` = " .. state.id
			)
			db.query("DELETE FROM `guild_prism_loot` WHERE `prism_id` = " .. state.id)
			local lootRows = PrismState.lootByPrismId[state.id] or {}
			local hasTooltipColumn = hasColumn("guild_prism_loot", "tooltip")
			local hasAttributesColumn = hasColumn("guild_prism_loot", "attributes")
			for slot, row in pairs(lootRows) do
				local itemId = tonumber(row.itemId) or 0
				local count = tonumber(row.count) or 0
				local tooltip = tostring(row.tooltip or "")
				local attributes = tostring(row.attributes or "")
				if hasTooltipColumn and hasAttributesColumn then
					db.query("INSERT INTO `guild_prism_loot` (`prism_id`, `slot`, `item_id`, `count`, `tooltip`, `attributes`) VALUES (" .. state.id .. ", " .. slot .. ", " .. itemId .. ", " .. count .. ", " .. escape(tooltip) .. ", " .. db.escapeBlob(attributes, #attributes) .. ")")
				elseif hasAttributesColumn then
					db.query("INSERT INTO `guild_prism_loot` (`prism_id`, `slot`, `item_id`, `count`, `attributes`) VALUES (" .. state.id .. ", " .. slot .. ", " .. itemId .. ", " .. count .. ", " .. db.escapeBlob(attributes, #attributes) .. ")")
				elseif hasTooltipColumn then
					db.query("INSERT INTO `guild_prism_loot` (`prism_id`, `slot`, `item_id`, `count`, `tooltip`) VALUES (" .. state.id .. ", " .. slot .. ", " .. itemId .. ", " .. count .. ", " .. escape(tooltip) .. ")")
				else
					db.query("INSERT INTO `guild_prism_loot` (`prism_id`, `slot`, `item_id`, `count`) VALUES (" .. state.id .. ", " .. slot .. ", " .. itemId .. ", " .. count .. ")")
				end
			end
			state.dirty = false
		end
	end

	if removedAnyExpired then
		refreshGuildPrismsForAllViewers()
	end
end

local function schedulePrismFlush()
	if PrismState.flushScheduled then
		return
	end

	PrismState.flushScheduled = true
	addEvent(function()
		PrismState.flushScheduled = false
		flushPrismState()
		schedulePrismFlush()
	end, GuildManagement.PRISM_SAVE_INTERVAL_MS)
end

local function releaseExpiredPrism(configId, cooldownBaseTime)
	local state = PrismState.byConfigId[configId]
	local config = getPrismConfigById(configId)
	if not state or not config then
		return
	end

	PrismAttackState.byConfigId[configId] = nil

	cleanupPrismTileItems(config, false)
	if state.id and state.id > 0 then
		db.query("DELETE FROM `guild_prism_loot` WHERE `prism_id` = " .. state.id)
		db.query("DELETE FROM `guild_prisms` WHERE `id` = " .. state.id)
	end

	PrismState.lootByPrismId[state.id or 0] = nil
	PrismState.byConfigId[configId] = nil
	reindexPrismState()
	local cooldownAt = tonumber(cooldownBaseTime) or 0
	if cooldownAt <= 0 then
		cooldownAt = math.max(os.time(), tonumber(state.expiresAt) or 0)
	end
	if state.guildId and state.guildId > 0 then
		setPrismPlaceCooldown(state.guildId, configId, cooldownAt + GuildManagement.PRISM_PLACE_COOLDOWN_SECONDS)
		enforceGuildPrismCapacity(state.guildId)
	end
	spawnPrismWorldItem(config, nil)
end

local function ensurePrismStateLoaded()
	if PrismState.loaded or not hasTable("guild_prisms") then
		schedulePrismFlush()
		return
	end

	PrismState.loaded = true
	PrismState.byConfigId = {}
	PrismState.byGuildId = {}
	PrismState.lootByPrismId = {}
	local prismConfig = getPrismConfig()

	local resultId = db.storeQuery("SELECT * FROM `guild_prisms`")
	if resultId then
		repeat
			local configId = result.getString(resultId, "config_id")
			local state = {
				id = result.getNumber(resultId, "id"),
				guildId = result.getNumber(resultId, "guild_id"),
				configId = configId,
				ownerPlayerId = result.getNumber(resultId, "owner_player_id"),
				ownerPlayerName = result.getString(resultId, "owner_player_name"),
				placedItemId = result.getNumber(resultId, "placed_item_id"),
				baseItemId = result.getNumber(resultId, "base_item_id"),
				position = {
					x = result.getNumber(resultId, "x"),
					y = result.getNumber(resultId, "y"),
					z = result.getNumber(resultId, "z")
				},
				radius = result.getNumber(resultId, "radius"),
				goldBuffer = result.getNumber(resultId, "gold_buffer"),
				expBuffer = result.getNumber(resultId, "exp_buffer"),
				lootSlots = result.getNumber(resultId, "loot_slots"),
				expiresAt = result.getNumber(resultId, "expires_at"),
				shieldUntil = hasColumn("guild_prisms", "shield_until") and result.getNumber(resultId, "shield_until") or 0,
				lastAttackAt = hasColumn("guild_prisms", "last_attack_at") and result.getNumber(resultId, "last_attack_at") or 0,
				dirty = false
			}
			local cfg = getPrismConfigById(configId)
			if cfg then
				state.radius = tonumber(cfg.radius or prismConfig.DEFAULT_RADIUS or state.radius or 40) or 40
				state.baseItemId = resolveWorldItemId(cfg.baseItemId or prismConfig.DEFAULT_BASE_ITEM_ID or state.baseItemId or 0)
				state.placedItemId = resolveWorldItemId(cfg.placedItemId or prismConfig.DEFAULT_PLACED_ITEM_ID or state.placedItemId or 0)
			end
			PrismState.byConfigId[configId] = state
			PrismState.lootByPrismId[state.id] = {}
		until not result.next(resultId)
		result.free(resultId)
	end

	local lootFields = { "`prism_id`", "`slot`", "`item_id`", "`count`" }
	local hasPrismLootTooltip = hasColumn("guild_prism_loot", "tooltip")
	local hasPrismLootAttributes = hasColumn("guild_prism_loot", "attributes")
	if hasPrismLootTooltip then
		table.insert(lootFields, "`tooltip`")
	end
	if hasPrismLootAttributes then
		table.insert(lootFields, "`attributes`")
	end
	local lootResult = db.storeQuery("SELECT " .. table.concat(lootFields, ", ") .. " FROM `guild_prism_loot` ORDER BY `slot` ASC")
	if lootResult then
		repeat
			local prismId = result.getNumber(lootResult, "prism_id")
			local attributes = ""
			if hasPrismLootAttributes then
				local stream, length = result.getStream(lootResult, "attributes")
				if type(stream) == "string" and tonumber(length or 0) > 0 then
					attributes = stream
				end
			end
			PrismState.lootByPrismId[prismId] = PrismState.lootByPrismId[prismId] or {}
			PrismState.lootByPrismId[prismId][result.getNumber(lootResult, "slot")] = {
				itemId = result.getNumber(lootResult, "item_id"),
				count = result.getNumber(lootResult, "count"),
				tooltip = hasPrismLootTooltip and (result.getString(lootResult, "tooltip") or "") or "",
				attributes = attributes
			}
		until not result.next(lootResult)
		result.free(lootResult)
	end

	for _, config in ipairs(getPrismConfigList()) do
		local state = PrismState.byConfigId[config.id]
		if state and state.expiresAt > 0 and state.expiresAt <= os.time() then
			releaseExpiredPrism(config.id)
		else
			spawnPrismWorldItem(config, state)
		end
	end

	reindexPrismState()
	for guildId, _ in pairs(PrismState.byGuildId) do
		enforceGuildPrismCapacity(guildId)
	end
	reindexPrismState()
	schedulePrismFlush()
end

local function getGuildStorageCapacity(guildId)
	local guildRow = getGuildRowById(guildId)
	local perkLevels = guildRow and decodeGuildPerks(guildRow.perks) or createEmptyGuildPerks()
	return getGuildStorageCapacityFromPerks(perkLevels)
end

local function getGuildStorageRows(guildId)
	local rows = {}
	if not hasTable("guild_storage_items") or not guildId or guildId <= 0 then
		return rows
	end

	local selectFields = { "`slot`", "`item_id`", "`count`" }
	local hasAttributesColumn = hasColumn("guild_storage_items", "attributes")
	if hasColumn("guild_storage_items", "tooltip") then
		table.insert(selectFields, "`tooltip`")
	end
	if hasAttributesColumn then
		table.insert(selectFields, "`attributes`")
	end

	local query = db.storeQuery("SELECT " .. table.concat(selectFields, ", ") .. " FROM `guild_storage_items` WHERE `guild_id` = " .. guildId .. " ORDER BY `slot` ASC")
	if not query then
		return rows
	end

	repeat
		local itemId = result.getNumber(query, "item_id")
		local itemType = ItemType(itemId)
		local tooltip = ""
		if hasColumn("guild_storage_items", "tooltip") then
			tooltip = result.getString(query, "tooltip") or ""
		end
		local attributes = ""
		if hasAttributesColumn then
			local stream, length = result.getStream(query, "attributes")
			if type(stream) == "string" and tonumber(length or 0) > 0 then
				attributes = stream
			end
		end
		rows[result.getNumber(query, "slot")] = {
			slot = result.getNumber(query, "slot"),
			itemId = itemId,
			clientId = itemType and itemType:getClientId() or 0,
			name = itemType and itemType:getName() or ("Item #" .. itemId),
			count = result.getNumber(query, "count"),
			tooltip = tooltip,
			attributes = attributes,
			attributesHex = hexEncode(attributes)
		}
	until not result.next(query)

	result.free(query)
	return rows
end

local function getGuildStorageItemCount(guildId)
	if not hasTable("guild_storage_items") or not guildId or guildId <= 0 then
		return 0
	end

	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM `guild_storage_items` WHERE `guild_id` = " .. guildId)
	if not resultId then
		return 0
	end

	local count = result.getNumber(resultId, "count")
	result.free(resultId)
	return count
end

local function getGuildStorageFreeSlots(guildId, rows)
	rows = rows or getGuildStorageRows(guildId)
	local used = 0
	for _, _ in pairs(rows) do
		used = used + 1
	end
	return math.max(0, (tonumber(getGuildStorageCapacity(guildId)) or 0) - used)
end

local function tryStoreItemsInGuildStorage(guildId, items)
	local summary = {
		storedRows = 0,
		storedItems = 0,
		overflowRows = 0,
		overflowItems = 0,
		overflowNames = {}
	}

	if not guildId or guildId <= 0 or type(items) ~= "table" or not hasTable("guild_storage_items") then
		return summary
	end

	local rows = getGuildStorageRows(guildId)
	local capacity = getGuildStorageCapacity(guildId)
	local hasTooltipColumn = hasColumn("guild_storage_items", "tooltip")
	local hasAttributesColumn = hasColumn("guild_storage_items", "attributes")

	local function pushOverflow(itemId, count)
		summary.overflowRows = summary.overflowRows + 1
		summary.overflowItems = summary.overflowItems + math.max(0, tonumber(count) or 0)
		local itemType = ItemType(tonumber(itemId) or 0)
		local itemName = (itemType and itemType:getName()) or ("Item #" .. tostring(itemId))
		table.insert(summary.overflowNames, string.format("%sx %s", formatCommaValue(tonumber(count) or 0), itemName))
	end

	for _, item in ipairs(items) do
		local itemId = tonumber(item.itemId) or 0
		local count = math.max(0, tonumber(item.count) or 0)
		local tooltip = tostring(item.tooltip or "")
		local attributes = tostring(item.attributes or "")
		if itemId > 0 and count > 0 then
			local itemType = ItemType(itemId)
			local chunks = splitItemCountForStorage(itemId, count, tooltip, attributes)

			for _, chunkEntry in ipairs(chunks) do
				local chunkCount = tonumber(chunkEntry.count) or 0
				local targetSlot = 0

				if itemType and itemType:isStackable() then
					for slot = 1, capacity do
						local row = rows[slot]
						if row and row.itemId == itemId and tostring(row.tooltip or "") == tooltip and tostring(row.attributes or "") == attributes and (tonumber(row.count) or 0) < GUILD_ITEM_STACK_LIMIT then
							targetSlot = slot
							break
						end
					end
				end

				if targetSlot == 0 then
					for slot = 1, capacity do
						if not rows[slot] then
							targetSlot = slot
							break
						end
					end
				end

				if targetSlot == 0 then
					pushOverflow(itemId, chunkCount)
				else
					if rows[targetSlot] then
						local currentRowCount = tonumber(rows[targetSlot].count) or 0
						local spaceLeft = GUILD_ITEM_STACK_LIMIT - currentRowCount
						if itemType and itemType:isStackable() and spaceLeft <= 0 then
							pushOverflow(itemId, chunkCount)
						else
							local addCount = itemType and itemType:isStackable() and math.min(spaceLeft, chunkCount) or chunkCount
							local updates = {
								"`count` = `count` + " .. addCount
							}
							if hasTooltipColumn and tostring(rows[targetSlot].tooltip or "") == "" and tooltip ~= "" then
								table.insert(updates, "`tooltip` = " .. escape(tooltip))
							end
							if hasAttributesColumn and tostring(rows[targetSlot].attributes or "") == "" and attributes ~= "" then
								table.insert(updates, "`attributes` = " .. db.escapeBlob(attributes, #attributes))
							end
							db.query("UPDATE `guild_storage_items` SET " .. table.concat(updates, ", ") .. " WHERE `guild_id` = " .. guildId .. " AND `slot` = " .. targetSlot)
							rows[targetSlot].count = currentRowCount + addCount
							summary.storedRows = summary.storedRows + 1
							summary.storedItems = summary.storedItems + addCount

							local remainder = chunkCount - addCount
							if remainder > 0 then
								pushOverflow(itemId, remainder)
							end
						end
					else
						if hasTooltipColumn and hasAttributesColumn then
							db.query("INSERT INTO `guild_storage_items` (`guild_id`, `slot`, `item_id`, `count`, `tooltip`, `attributes`) VALUES (" .. guildId .. ", " .. targetSlot .. ", " .. itemId .. ", " .. chunkCount .. ", " .. escape(tooltip) .. ", " .. db.escapeBlob(attributes, #attributes) .. ")")
						elseif hasAttributesColumn then
							db.query("INSERT INTO `guild_storage_items` (`guild_id`, `slot`, `item_id`, `count`, `attributes`) VALUES (" .. guildId .. ", " .. targetSlot .. ", " .. itemId .. ", " .. chunkCount .. ", " .. db.escapeBlob(attributes, #attributes) .. ")")
						elseif hasTooltipColumn then
							db.query("INSERT INTO `guild_storage_items` (`guild_id`, `slot`, `item_id`, `count`, `tooltip`) VALUES (" .. guildId .. ", " .. targetSlot .. ", " .. itemId .. ", " .. chunkCount .. ", " .. escape(tooltip) .. ")")
						else
							db.query("INSERT INTO `guild_storage_items` (`guild_id`, `slot`, `item_id`, `count`) VALUES (" .. guildId .. ", " .. targetSlot .. ", " .. itemId .. ", " .. chunkCount .. ")")
						end
						rows[targetSlot] = {
							slot = targetSlot,
							itemId = itemId,
							count = chunkCount,
							tooltip = tooltip,
							attributes = attributes
						}
						summary.storedRows = summary.storedRows + 1
						summary.storedItems = summary.storedItems + chunkCount
					end
				end
			end
		end
	end

	return summary
end

local function canStoreItemsInGuildStorage(guildId, items)
	if not guildId or guildId <= 0 or type(items) ~= "table" or not hasTable("guild_storage_items") then
		return true
	end

	local rows = getGuildStorageRows(guildId)
	local capacity = getGuildStorageCapacity(guildId)
	local simulated = {}
	for slot, row in pairs(rows) do
		simulated[slot] = {
			itemId = tonumber(row.itemId) or 0,
			count = tonumber(row.count) or 0,
			tooltip = tostring(row.tooltip or ""),
			attributes = tostring(row.attributes or "")
		}
	end

	for _, item in ipairs(items) do
		local itemId = tonumber(item.itemId) or 0
		local count = math.max(0, tonumber(item.count) or 0)
		local tooltip = tostring(item.tooltip or "")
		local attributes = tostring(item.attributes or "")
		if itemId > 0 and count > 0 then
			local itemType = ItemType(itemId)
			local chunks = splitItemCountForStorage(itemId, count, tooltip, attributes)

			for _, chunkEntry in ipairs(chunks) do
				local chunkCount = tonumber(chunkEntry.count) or 0
				local targetSlot = 0

				if itemType and itemType:isStackable() then
					for slot = 1, capacity do
						local row = simulated[slot]
						if row and row.itemId == itemId and tostring(row.tooltip or "") == tooltip and tostring(row.attributes or "") == attributes and (tonumber(row.count) or 0) < GUILD_ITEM_STACK_LIMIT then
							targetSlot = slot
							break
						end
					end
				end

				if targetSlot == 0 then
					for slot = 1, capacity do
						if not simulated[slot] then
							targetSlot = slot
							break
						end
					end
				end

				if targetSlot == 0 then
					return false
				end

				local row = simulated[targetSlot]
				if row then
					local currentCount = tonumber(row.count) or 0
					local spaceLeft = GUILD_ITEM_STACK_LIMIT - currentCount
					if itemType and itemType:isStackable() then
						if spaceLeft < chunkCount then
							return false
						end
						row.count = currentCount + chunkCount
					else
						return false
					end
				else
					simulated[targetSlot] = {
						itemId = itemId,
						count = chunkCount,
						tooltip = tooltip,
						attributes = attributes
					}
				end
			end
		end
	end

	return true
end

local function buildGuildStorageData(guildId)
	local rows = getGuildStorageRows(guildId)
	local guildRow = getGuildRowById(guildId)
	local perkLevels = guildRow and decodeGuildPerks(guildRow.perks) or createEmptyGuildPerks()
	local capacity = getGuildStorageCapacityFromPerks(perkLevels)
	local items = {}

	for slot = 1, capacity do
		if rows[slot] then
			table.insert(items, {
				slot = rows[slot].slot,
				itemId = rows[slot].itemId,
				clientId = rows[slot].clientId,
				name = rows[slot].name,
				count = rows[slot].count,
				tooltip = rows[slot].tooltip,
				attributesHex = rows[slot].attributesHex or ""
			})
		end
	end

	return {
		capacity = capacity,
		used = getGuildStorageItemCount(guildId),
		items = items
	}
end

local function getGuildQuestProgressRows(guildId, cycleType, cycleStart)
	local rows = {}
	if not guildId or guildId <= 0 or not hasTable("guild_quest_progress") then
		return rows
	end

	local query = db.storeQuery(
		"SELECT `quest_id`, `progress`, `completed_at`, `claimed_at` FROM `guild_quest_progress` WHERE `guild_id` = " .. guildId ..
		" AND `cycle_type` = " .. escape(cycleType) ..
		" AND `cycle_start` = " .. (tonumber(cycleStart) or 0)
	)
	if not query then
		return rows
	end

	repeat
		rows[result.getString(query, "quest_id")] = {
			progress = result.getNumber(query, "progress"),
			completedAt = result.getNumber(query, "completed_at"),
			claimedAt = result.getNumber(query, "claimed_at")
		}
	until not result.next(query)
	result.free(query)
	return rows
end

local function upsertGuildQuestProgress(guildId, cycleType, cycleStart, questId, progress, completedAt, claimedAt)
	if not guildId or guildId <= 0 or not hasTable("guild_quest_progress") then
		return false
	end

	local now = os.time()
	progress = math.max(0, tonumber(progress) or 0)
	completedAt = math.max(0, tonumber(completedAt) or 0)
	claimedAt = math.max(0, tonumber(claimedAt) or 0)

	return db.query(
		"INSERT INTO `guild_quest_progress` (`guild_id`, `cycle_type`, `cycle_start`, `quest_id`, `progress`, `completed_at`, `claimed_at`, `created_at`, `updated_at`) VALUES (" ..
			guildId .. ", " .. escape(cycleType) .. ", " .. (tonumber(cycleStart) or 0) .. ", " .. escape(questId) .. ", " .. progress .. ", " .. completedAt .. ", " .. claimedAt .. ", " .. now .. ", " .. now .. ")" ..
		" ON DUPLICATE KEY UPDATE `progress` = VALUES(`progress`), `completed_at` = VALUES(`completed_at`), `claimed_at` = VALUES(`claimed_at`), `updated_at` = VALUES(`updated_at`)"
	)
end

local function buildQuestRewardText(rewards)
	rewards = type(rewards) == "table" and rewards or {}
	local parts = {}
	if (tonumber(rewards.gold) or 0) > 0 then
		table.insert(parts, formatCommaValue(rewards.gold) .. " gold")
	end
	if (tonumber(rewards.exp) or 0) > 0 then
		table.insert(parts, formatCommaValue(rewards.exp) .. " exp")
	end
	if type(rewards.items) == "table" then
		for _, itemReward in ipairs(rewards.items) do
			local itemId = tonumber(itemReward.itemId) or 0
			local itemCount = tonumber(itemReward.count) or 0
			if itemId > 0 and itemCount > 0 then
				local itemType = ItemType(itemId)
				table.insert(parts, itemCount .. "x " .. ((itemType and itemType:getName()) or ("Item #" .. itemId)))
			end
		end
	end
	return #parts > 0 and table.concat(parts, ", ") or "No rewards"
end

local function buildQuestRewardEntries(rewards)
	rewards = type(rewards) == "table" and rewards or {}
	local entries = {}
	local goldCoinItemId = 2148

	local function addTextEntry(text)
		text = tostring(text or "")
		if text ~= "" then
			table.insert(entries, { type = "text", text = text })
		end
	end

	local function addItemEntry(itemId, count, fallbackText)
		itemId = tonumber(itemId) or 0
		count = tonumber(count) or 0
		if itemId <= 0 or count <= 0 then
			if fallbackText then
				addTextEntry(fallbackText)
			end
			return
		end

		local itemType = ItemType(itemId)
		local clientId = (itemType and itemType:getClientId()) or 0
		local itemName = (itemType and itemType:getName()) or ("Item #" .. itemId)
		if clientId > 0 then
			table.insert(entries, {
				type = "item",
				itemId = itemId,
				clientId = clientId,
				count = count,
				name = itemName
			})
		elseif fallbackText then
			addTextEntry(fallbackText)
		end
	end

	if (tonumber(rewards.gold) or 0) > 0 then
		addItemEntry(goldCoinItemId, tonumber(rewards.gold) or 0, formatCommaValue(rewards.gold) .. " gold")
	end
	if (tonumber(rewards.exp) or 0) > 0 then
		addTextEntry(formatCommaValue(rewards.exp) .. " exp")
	end
	if (tonumber(rewards.guildExp) or 0) > 0 then
		addTextEntry(formatCommaValue(rewards.guildExp) .. " guild exp")
	end
	if (tonumber(rewards.dynastieExp) or 0) > 0 then
		addTextEntry(formatCommaValue(rewards.dynastieExp) .. " dynastie exp")
	end
	if (tonumber(rewards.guildGold) or 0) > 0 then
		addItemEntry(goldCoinItemId, tonumber(rewards.guildGold) or 0, formatCommaValue(rewards.guildGold) .. " guild gold")
	end
	if (tonumber(rewards.dynastieTokens) or 0) > 0 then
		addTextEntry(formatCommaValue(rewards.dynastieTokens) .. " dynastie tokens")
	end
	if (tonumber(rewards.premium) or tonumber(rewards.premiumPoints) or 0) > 0 then
		addTextEntry(formatCommaValue(tonumber(rewards.premium) or tonumber(rewards.premiumPoints) or 0) .. " premium points")
	end
	if type(rewards.items) == "table" then
		for _, itemReward in ipairs(rewards.items) do
			local itemId = tonumber(itemReward.itemId) or 0
			local itemCount = tonumber(itemReward.count) or 0
			if itemId > 0 and itemCount > 0 then
				local itemType = ItemType(itemId)
				local clientId = (itemType and itemType:getClientId()) or 0
				local itemName = (itemType and itemType:getName()) or ("Item #" .. itemId)
				if clientId > 0 then
					table.insert(entries, {
						type = "item",
						itemId = itemId,
						clientId = clientId,
						count = itemCount,
						name = itemName
					})
				else
					addTextEntry(tostring(itemCount) .. "x " .. itemName)
				end
			end
		end
	end
	if type(rewards.mount) == "string" and rewards.mount ~= "" then
		addTextEntry("Mount: " .. rewards.mount)
	end
	if type(rewards.outfit) == "string" and rewards.outfit ~= "" then
		addTextEntry("Outfit: " .. rewards.outfit)
	end
	if type(rewards.title) == "string" and rewards.title ~= "" then
		addTextEntry(rewards.title)
	end

	return entries
end

GuildAchievements = dofile("data/scripts/customs/guilds/guild_hall_achievements.lua").create({
	pageSize = GuildManagement.ACHIEVEMENT_PAGE_SIZE,
	messageTypes = GuildManagement.MESSAGE_TYPES,
	escape = escape,
	hasTable = function(...)
		return hasTable(...)
	end,
	hasColumn = function(...)
		return hasColumn(...)
	end,
	sendGuildPayload = sendGuildPayload,
	sendGuildError = sendGuildError,
	getOnlineGuildPlayers = getOnlineGuildPlayers,
	getGuildRowById = getGuildRowById,
	normalizeQuestMonsterName = normalizeQuestMonsterName,
	normalizeQuestMonsterList = normalizeQuestMonsterList,
	buildQuestRewardText = buildQuestRewardText,
	buildQuestRewardEntries = buildQuestRewardEntries,
	tryStoreItemsInGuildStorage = tryStoreItemsInGuildStorage,
	canStoreItemsInGuildStorage = canStoreItemsInGuildStorage,
	calculateGuildLevelProgress = function(...)
		return calculateGuildLevelProgress(...)
	end,
	addGuildMessages = function(...)
		return addGuildMessages(...)
	end,
	getGuildInboxRecipients = function(...)
		return getGuildInboxRecipients(...)
	end,
	refreshGuildStorageForGuild = function(...)
		return refreshGuildStorageForGuild(...)
	end,
	refreshGuildForMembers = function(...)
		return refreshGuildForMembers(...)
	end,
	refreshDynastieBattleForMembers = function(...)
		return refreshDynastieBattleForMembers(...)
	end,
	refreshPrismBattleForMembers = function(...)
		return refreshPrismBattleForMembers(...)
	end,
	refreshGuildPerkState = function(...)
		return refreshGuildPerkState(...)
	end
	,
	resolvePlayerGuildId = function(...)
		return resolvePlayerGuildId(...)
	end
})
_G.GuildAchievements = GuildAchievements

GuildBlackMarket = dofile("data/scripts/customs/guilds/guild_hall_blackmarket.lua").create({
	messageTypes = GuildManagement.MESSAGE_TYPES,
	dailyCount = GuildManagement.BLACK_MARKET_DAILY_COUNT,
	hasTable = function(...)
		return hasTable(...)
	end,
	hasColumn = function(...)
		return hasColumn(...)
	end,
	getGuildRowById = getGuildRowById,
	getGuildStorageRows = getGuildStorageRows,
	getGuildStorageCapacity = getGuildStorageCapacity,
	splitItemCountForStorage = splitItemCountForStorage,
	stackLimit = GUILD_ITEM_STACK_LIMIT,
	tryStoreItemsInGuildStorage = tryStoreItemsInGuildStorage,
	canStoreItemsInGuildStorage = canStoreItemsInGuildStorage,
	sendGuildPayload = sendGuildPayload,
	sendGuildError = sendGuildError,
	getGuildInboxRecipients = function(...)
		return getGuildInboxRecipients(...)
	end,
	addGuildMessages = function(...)
		return addGuildMessages(...)
	end,
	refreshGuildStorageForGuild = function(...)
		return refreshGuildStorageForGuild(...)
	end,
	refreshGuildForMembers = function(...)
		return refreshGuildForMembers(...)
	end
	,
	hasPermission = function(...)
		return hasPermission(...)
	end,
	resolvePlayerGuildId = function(...)
		return resolvePlayerGuildId(...)
	end
})

dofile("data/scripts/customs/guilds/guild_hall_dynastie_config.lua")
GuildDynastie = dofile("data/scripts/customs/guilds/guild_hall_dynastie.lua").create({
	messageTypes = GuildManagement.MESSAGE_TYPES,
	hasTable = function(...)
		return hasTable(...)
	end,
	hasColumn = function(...)
		return hasColumn(...)
	end,
	getGuildRowById = getGuildRowById,
	getGuildInboxRecipients = function(...)
		return getGuildInboxRecipients(...)
	end,
	decodeGuildPerks = decodeGuildPerks,
	getGuildDynastieCapacityFromPerks = getGuildDynastieCapacityFromPerks,
	attackPrepareSeconds = GuildManagement.DYNASTIE_ATTACK_PREPARE_SECONDS,
	attackDurationSeconds = GuildManagement.DYNASTIE_ATTACK_DURATION_SECONDS,
	attackShieldSeconds = GuildManagement.DYNASTIE_ATTACK_SHIELD_SECONDS,
	attackReattackSeconds = GuildManagement.DYNASTIE_ATTACK_REATTACK_SECONDS,
	attackLeaveGraceSeconds = GuildManagement.DYNASTIE_ATTACK_LEAVE_GRACE_SECONDS,
	attackMinAttackers = GuildManagement.DYNASTIE_ATTACK_MIN_ATTACKERS,
	attackMinDefenders = GuildManagement.DYNASTIE_ATTACK_MIN_DEFENDERS,
	attackAreaRadius = GuildManagement.DYNASTIE_ATTACK_AREA_RADIUS,
	attackAreaFloors = GuildManagement.DYNASTIE_ATTACK_AREA_FLOORS,
	addGuildMessages = function(...)
		return addGuildMessages(...)
	end,
	sendGuildPayload = sendGuildPayload,
	sendGuildError = sendGuildError,
	refreshGuildForMembers = function(...)
		return refreshGuildForMembers(...)
	end,
	refreshDynastieBattleForMembers = function(...)
		return refreshDynastieBattleForMembers(...)
	end,
	refreshDynastieWorld = function()
		if GuildDynastie and GuildDynastie.refreshWorld then
			GuildDynastie.refreshWorld()
		end
	end,
	refreshDynastieForGuildMembers = function(guildId)
		if not GuildDynastie or not GuildDynastie.send then
			return
		end
		for _, member in ipairs(getOnlineGuildPlayers(guildId)) do
			GuildDynastie.send(member)
		end
	end,
	sendDynastie = function(player)
		if GuildDynastie and GuildDynastie.send and player then
			GuildDynastie.send(player)
		end
	end,
	getDynastieTokenRateMultiplier = function(guildId, timestamp)
		return GuildDynastieEvents and GuildDynastieEvents.getDynastieTokenRateMultiplier and GuildDynastieEvents.getDynastieTokenRateMultiplier(guildId, timestamp) or 1
	end,
	resolvePlayerGuildId = function(...)
		return resolvePlayerGuildId(...)
	end,
	getGuildStorageRows = getGuildStorageRows,
	refreshGuildStorageForGuild = function(...)
		return refreshGuildStorageForGuild(...)
	end,
	canUseTeleport = function(...)
		return canUsePrismTeleport(...)
	end,
	markTeleportUsed = function(player)
		if player then
			player:setStorageValue(GUILD_PRISM_TELEPORT_STORAGE, os.time() + GuildManagement.PRISM_TELEPORT_COOLDOWN)
		end
	end
})
if GuildDynastie and GuildDynastie.refreshWorld then
	GuildDynastie.refreshWorld()
end
GuildDynastieQuests = dofile("data/scripts/customs/guilds/guild_hall_dynastie_quests.lua").create({
	messageTypes = GuildManagement.MESSAGE_TYPES,
	hasTable = function(...)
		return hasTable(...)
	end,
	hasColumn = function(...)
		return hasColumn(...)
	end,
	getGuildRowById = getGuildRowById,
	getGuildInboxRecipients = function(...)
		return getGuildInboxRecipients(...)
	end,
	addGuildMessages = function(...)
		return addGuildMessages(...)
	end,
	sendGuildPayload = sendGuildPayload,
	sendGuildError = sendGuildError,
	refreshGuildForMembers = function(...)
		return refreshGuildForMembers(...)
	end,
	resolvePlayerGuildId = function(...)
		return resolvePlayerGuildId(...)
	end,
	buildQuestRewardEntries = buildQuestRewardEntries,
	calculateGuildLevelProgress = function(...)
		return calculateGuildLevelProgress(...)
	end,
	commaValue = comma_value,
	getOnlineGuildPlayers = getOnlineGuildPlayers,
	getGuildMemberCount = getGuildMemberCount,
	getDynastieState = function(configId)
		return GuildDynastie and GuildDynastie.getState and GuildDynastie.getState(configId) or nil
	end,
	getGuildActiveDynastieConfigIds = function(guildId)
		return GuildDynastie and GuildDynastie.getGuildActiveConfigIds and GuildDynastie.getGuildActiveConfigIds(guildId) or {}
	end,
	dailySeconds = GuildManagement.QUEST_DAILY_SECONDS,
	weekendSeconds = GuildManagement.QUEST_WEEKEND_SECONDS,
	monthlySeconds = GuildManagement.QUEST_MONTHLY_SECONDS,
	dailyCount = GuildManagement.QUEST_DAILY_COUNT,
	weekendCount = GuildManagement.QUEST_WEEKEND_COUNT,
	monthlyCount = GuildManagement.QUEST_MONTHLY_COUNT,
	levelCap = GuildHallDynastieConfig and GuildHallDynastieConfig.DEFAULT_LEVEL_CAP or 10,
	levelBaseExp = GuildHallDynastieConfig and GuildHallDynastieConfig.DEFAULT_LEVEL_BASE_EXP or 2500
})
if GuildDynastie and GuildDynastieQuests and GuildDynastie.setQuestHooks then
	GuildDynastie.setQuestHooks({
		awardTaxProgress = function(...)
			return GuildDynastieQuests.awardTaxProgress(...)
		end,
		awardDefenseWin = function(...)
			return GuildDynastieQuests.awardDefenseWin(...)
		end
	})
end
GuildDynastieAchievements = dofile("data/scripts/customs/guilds/guild_hall_dynastie_achievements.lua").create({
	escape = escape,
	commaValue = comma_value,
	buildQuestRewardEntries = buildQuestRewardEntries,
	hasColumn = function(...)
		return hasColumn(...)
	end,
	sendGuildPayload = sendGuildPayload,
	sendGuildError = sendGuildError,
	getOnlineGuildPlayers = getOnlineGuildPlayers,
	refreshGuildForMembers = function(...)
		return refreshGuildForMembers(...)
	end,
	refreshGuildStorageForGuild = function(...)
		return refreshGuildStorageForGuild(...)
	end,
	tryStoreItemsInGuildStorage = tryStoreItemsInGuildStorage,
	canStoreItemsInGuildStorage = canStoreItemsInGuildStorage,
	resolvePlayerGuildId = function(...)
		return resolvePlayerGuildId(...)
	end,
	canManageDynastie = function(player, guildId)
		return GuildDynastie and GuildDynastie.canManage and GuildDynastie.canManage(player, guildId) or false
	end,
	awardDynastieExperience = function(guildId, amount)
		return GuildDynastie and GuildDynastie.awardExperience and GuildDynastie.awardExperience(guildId, amount) or nil
	end
})
_G.GuildDynastieAchievements = GuildDynastieAchievements
GuildDynastieEvents = dofile("data/scripts/customs/guilds/guild_hall_dynastie_events.lua").create({
	sendGuildPayload = sendGuildPayload,
	sendGuildError = sendGuildError,
	buildQuestRewardEntries = buildQuestRewardEntries,
	getDynastieState = function(configId)
		return GuildDynastie and GuildDynastie.getState and GuildDynastie.getState(configId) or nil
	end,
	getGuildActiveDynastieConfigIds = function(guildId)
		return GuildDynastie and GuildDynastie.getGuildActiveConfigIds and GuildDynastie.getGuildActiveConfigIds(guildId) or {}
	end,
	resolvePlayerGuildId = function(...)
		return resolvePlayerGuildId(...)
	end,
	getGuildRowById = getGuildRowById,
	awardDynastieExperience = function(guildId, amount)
		return GuildDynastie and GuildDynastie.awardExperience and GuildDynastie.awardExperience(guildId, amount) or nil
	end,
	addDynastieCoreRewards = function(configId, rewards)
		return GuildDynastie and GuildDynastie.addCoreRewards and GuildDynastie.addCoreRewards(configId, rewards) or false
	end,
	refreshGuildForMembers = function(...)
		return refreshGuildForMembers(...)
	end
})
_G.GuildDynastieEvents = GuildDynastieEvents
_G.GuildProfession_onActivity = function(player, profession, amount)
	awardGuildQuestProfessionActivity(player, profession, amount)
	local guildId = player and player.getGuild and player:getGuild() and player:getGuild():getId() or 0
	if guildId > 0 and GuildAchievements and GuildAchievements.awardProfessionActivity then
		GuildAchievements.awardProfessionActivity(guildId, profession, amount)
	end
	if GuildDynastieQuests and GuildDynastieQuests.awardProfessionActivity then
		GuildDynastieQuests.awardProfessionActivity(player, profession, amount)
	end
	if GuildDynastieEvents and GuildDynastieEvents.onProfessionActivity then
		GuildDynastieEvents.onProfessionActivity(player, profession, amount)
	end
end

local function buildGuildQuestData(guildId)
	local now = os.time()
	local active = getActiveGuildQuestDefinitions(now)
	local payload = {
		dailyEndsAt = active.daily.endsAt,
		weekendEndsAt = active.weekend.endsAt,
		monthlyEndsAt = active.monthly.endsAt,
		daily = {},
		weekend = {},
		monthly = {}
	}

	local function resolveGuildQuestIcon(quest)
		if type(quest) ~= "table" then
			return "guild_achievement"
		end
		if type(quest.icon) == "string" and quest.icon ~= "" then
			return quest.icon
		end
		return "guild_achievement"
	end

	for cycleType, block in pairs(active) do
		local progressRows = getGuildQuestProgressRows(guildId, cycleType, block.cycleStart)
		for _, quest in ipairs(block.quests) do
			local row = progressRows[quest.id] or {}
			local progress = math.min(tonumber(row.progress) or 0, tonumber(quest.target) or 0)
			table.insert(payload[cycleType], {
				id = quest.id,
				name = quest.name,
				objective = quest.objective,
				icon = resolveGuildQuestIcon(quest),
				type = quest.type,
				monster = quest.monster,
				target = tonumber(quest.target) or 0,
				progress = progress,
				completed = progress >= (tonumber(quest.target) or 0),
				claimed = (tonumber(row.claimedAt) or 0) > 0,
				cycleType = cycleType,
				cycleStart = block.cycleStart,
				rewardText = buildQuestRewardText(quest.rewards),
				rewardEntries = buildQuestRewardEntries(quest.rewards)
			})
		end
	end

	return payload
end

local function sendGuildQuests(player)
	if not GUILD_QUESTS_ENABLED then
		return sendGuildPayload(player, "quests", nil)
	end
	local guildId = resolvePlayerGuildId(player)
	if guildId <= 0 then
		return sendGuildPayload(player, "quests", nil)
	end
	sendGuildPayload(player, "quests", buildGuildQuestData(guildId))
end

local function sendGuildBlackMarket(player)
	if not GUILD_BLACKMARKET_ENABLED or not GuildBlackMarket then
		return sendGuildPayload(player, "blackMarket", nil)
	end
	GuildBlackMarket.send(player)
end

local function sendGuildDynastie(player, page)
	if not GUILD_DYNASTIE_ENABLED or not GuildDynastie then
		return sendGuildPayload(player, "dynastie", nil)
	end
	GuildDynastie.send(player, page)
end

local function awardGuildQuestKill(player, target)
	if not player or not target then
		return
	end

	local guild = player:getGuild()
	if not guild then
		return
	end

	local active = getActiveGuildQuestDefinitions(os.time())
	local touched = false

	local function incrementQuestProgress(progressRows, cycleType, cycleStart, quest)
		local row = progressRows[quest.id] or {}
		if (tonumber(row.claimedAt) or 0) ~= 0 then
			return false
		end

		local current = tonumber(row.progress) or 0
		local targetCount = tonumber(quest.target) or 0
		if current >= targetCount then
			return false
		end

		local newProgress = math.min(targetCount, current + 1)
		local completedAt = tonumber(row.completedAt) or 0
		if completedAt <= 0 and newProgress >= targetCount then
			completedAt = os.time()
		end
		upsertGuildQuestProgress(guild:getId(), cycleType, cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
		return true
	end

	if target:isPlayer() then
		for cycleType, block in pairs(active) do
			local progressRows = getGuildQuestProgressRows(guild:getId(), cycleType, block.cycleStart)
			for _, quest in ipairs(block.quests) do
				if quest.type == "kill_any_player" and incrementQuestProgress(progressRows, cycleType, block.cycleStart, quest) then
					touched = true
				end
			end
		end

		return
	end

	if not target:isMonster() then
		return
	end

	local killedName = normalizeQuestMonsterName(target:getName())
	if killedName == "" then
		return
	end

	local monsterType = target.getType and target:getType() or nil
	local isRewardBoss = monsterType and monsterType.isRewardBoss and monsterType:isRewardBoss() or false
	for cycleType, block in pairs(active) do
		local progressRows = getGuildQuestProgressRows(guild:getId(), cycleType, block.cycleStart)
		for _, quest in ipairs(block.quests) do
			local matchesQuest =
				(quest.type == "kill_any_monster") or
				(quest.type == "kill_reward_boss" and isRewardBoss) or
				questMatchesMonster(quest, killedName)
			if matchesQuest and incrementQuestProgress(progressRows, cycleType, block.cycleStart, quest) then
				touched = true
			end
		end
	end

end

local function awardGuildQuestExperience(guildId, amount)
	if not guildId or guildId <= 0 then
		return
	end

	amount = math.max(0, math.floor(tonumber(amount) or 0))
	if amount <= 0 then
		return
	end

	local active = getActiveGuildQuestDefinitions(os.time())
	local touched = false
	for cycleType, block in pairs(active) do
		local progressRows = getGuildQuestProgressRows(guildId, cycleType, block.cycleStart)
		for _, quest in ipairs(block.quests) do
			if quest.type == "gain_guild_experience" then
				local row = progressRows[quest.id] or {}
				if (tonumber(row.claimedAt) or 0) == 0 then
					local current = tonumber(row.progress) or 0
					local targetCount = tonumber(quest.target) or 0
					if current < targetCount then
						local newProgress = math.min(targetCount, current + amount)
						local completedAt = tonumber(row.completedAt) or 0
						if completedAt <= 0 and newProgress >= targetCount then
							completedAt = os.time()
						end
						upsertGuildQuestProgress(guildId, cycleType, block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
						touched = true
					end
				end
			end
		end
	end

end

local function awardGuildQuestGoldDonation(guildId, amount)
	if not guildId or guildId <= 0 then
		return
	end

	amount = math.max(0, math.floor(tonumber(amount) or 0))
	if amount <= 0 then
		return
	end

	local active = getActiveGuildQuestDefinitions(os.time())
	local touched = false
	for cycleType, block in pairs(active) do
		local progressRows = getGuildQuestProgressRows(guildId, cycleType, block.cycleStart)
		for _, quest in ipairs(block.quests) do
			if quest.type == "donate_gold" then
				local row = progressRows[quest.id] or {}
				if (tonumber(row.claimedAt) or 0) == 0 then
					local current = tonumber(row.progress) or 0
					local targetCount = tonumber(quest.target) or 0
					if current < targetCount then
						local newProgress = math.min(targetCount, current + amount)
						local completedAt = tonumber(row.completedAt) or 0
						if completedAt <= 0 and newProgress >= targetCount then
							completedAt = os.time()
						end
						upsertGuildQuestProgress(guildId, cycleType, block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
						touched = true
					end
				end
			end
		end
	end

end

local function awardGuildQuestPremiumDonation(guildId, amount)
	if not guildId or guildId <= 0 then
		return
	end

	amount = math.max(0, math.floor(tonumber(amount) or 0))
	if amount <= 0 then
		return
	end

	local active = getActiveGuildQuestDefinitions(os.time())
	local touched = false
	for cycleType, block in pairs(active) do
		local progressRows = getGuildQuestProgressRows(guildId, cycleType, block.cycleStart)
		for _, quest in ipairs(block.quests) do
			if quest.type == "donate_premium" then
				local row = progressRows[quest.id] or {}
				if (tonumber(row.claimedAt) or 0) == 0 then
					local current = tonumber(row.progress) or 0
					local targetCount = tonumber(quest.target) or 0
					if current < targetCount then
						local newProgress = math.min(targetCount, current + amount)
						local completedAt = tonumber(row.completedAt) or 0
						if completedAt <= 0 and newProgress >= targetCount then
							completedAt = os.time()
						end
						upsertGuildQuestProgress(guildId, cycleType, block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
						touched = true
					end
				end
			end
		end
	end

end

local function awardGuildQuestPrismDefense(guildId)
	if not guildId or guildId <= 0 then
		return
	end

	local active = getActiveGuildQuestDefinitions(os.time())
	local block = active.weekend
	local touched = false
	if block then
		local progressRows = getGuildQuestProgressRows(guildId, "weekend", block.cycleStart)
		for _, quest in ipairs(block.quests) do
			if quest.type == "defend_prism_win" then
				local row = progressRows[quest.id] or {}
				if (tonumber(row.claimedAt) or 0) == 0 then
					local current = tonumber(row.progress) or 0
					local targetCount = tonumber(quest.target) or 0
					if current < targetCount then
						local newProgress = math.min(targetCount, current + 1)
						local completedAt = tonumber(row.completedAt) or 0
						if completedAt <= 0 and newProgress >= targetCount then
							completedAt = os.time()
						end
						upsertGuildQuestProgress(guildId, "weekend", block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
						touched = true
					end
				end
			end
		end
	end

end

awardGuildQuestProfessionActivity = function(player, profession, amount)
	if not player then
		return
	end

	local guild = player:getGuild()
	if not guild then
		return
	end

	profession = tostring(profession or ""):lower()
	amount = math.max(0, math.floor(tonumber(amount) or 0))
	if profession == "" or amount <= 0 then
		return
	end

	local active = getActiveGuildQuestDefinitions(os.time())
	for cycleType, block in pairs(active) do
		local progressRows = getGuildQuestProgressRows(guild:getId(), cycleType, block.cycleStart)
		for _, quest in ipairs(block.quests) do
			if quest.type == "profession_activity" and tostring(quest.profession or ""):lower() == profession then
				local row = progressRows[quest.id] or {}
				if (tonumber(row.claimedAt) or 0) == 0 then
					local current = tonumber(row.progress) or 0
					local targetCount = tonumber(quest.target) or 0
					if current < targetCount then
						local newProgress = math.min(targetCount, current + amount)
						local completedAt = tonumber(row.completedAt) or 0
						if completedAt <= 0 and newProgress >= targetCount then
							completedAt = os.time()
						end
						upsertGuildQuestProgress(guild:getId(), cycleType, block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
					end
				end
			end
		end
	end
end

local function claimGuildQuestReward(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end

	local cycleType = tostring(data and data.cycleType or "")
	local questId = tostring(data and data.questId or "")
	if cycleType ~= "daily" and cycleType ~= "weekend" and cycleType ~= "monthly" then
		return sendGuildError(player, "Invalid quest cycle.")
	end

	local quest, block = getActiveQuestDefinitionById(questId, cycleType, os.time())
	if not quest or not block then
		return sendGuildError(player, "That quest is no longer active.")
	end

	local progressRows = getGuildQuestProgressRows(guild:getId(), cycleType, block.cycleStart)
	local row = progressRows[questId]
	if not row then
		return sendGuildError(player, "This quest has not been progressed yet.")
	end

	local targetCount = tonumber(quest.target) or 0
	local progress = tonumber(row.progress) or 0
	if progress < targetCount then
		return sendGuildError(player, "This quest is not completed yet.")
	end
	if (tonumber(row.claimedAt) or 0) > 0 then
		return sendGuildError(player, "This quest reward was already claimed.")
	end

	local guildRow = getGuildRowById(guild:getId())
	if not guildRow then
		return sendGuildError(player, "Could not load guild data.")
	end

	local rewards = quest.rewards or {}
	local rewardItems = {}
	if type(rewards.items) == "table" then
		for _, itemReward in ipairs(rewards.items) do
			local itemId = tonumber(itemReward.itemId) or 0
			local count = tonumber(itemReward.count) or 0
			if itemId > 0 and count > 0 then
				table.insert(rewardItems, { itemId = itemId, count = count, tooltip = "", attributes = "" })
			end
		end
	end

	if #rewardItems > 0 and not canStoreItemsInGuildStorage(guild:getId(), rewardItems) then
		return sendGuildError(player, "There is no space in guild storage to claim this quest reward.")
	end

	local storageSummary = tryStoreItemsInGuildStorage(guild:getId(), rewardItems)
	local rewardGold = tonumber(rewards.gold) or 0
	local rewardExp = tonumber(rewards.exp) or 0
	local newLevel = tonumber(guildRow.guild_level) or 1
	local newExp = tonumber(guildRow.guild_experience) or 0
	local nextRequiredExp = math.max(GuildManagement.NEXT_LEVEL_BASE, newLevel * GuildManagement.NEXT_LEVEL_BASE)
	local leveledUp = false

	if rewardExp > 0 then
		local rawExp = newExp + rewardExp
		newLevel, newExp, nextRequiredExp, leveledUp = calculateGuildLevelProgress(newLevel, rawExp)
	end

	local updates = {}
	if rewardGold > 0 and hasColumn("guilds", "balance") then
		table.insert(updates, "`balance` = " .. ((tonumber(guildRow.balance) or 0) + rewardGold))
	end
	if rewardExp > 0 and hasColumn("guilds", "guild_level") then
		table.insert(updates, "`guild_level` = " .. newLevel)
	end
	if rewardExp > 0 and hasColumn("guilds", "guild_experience") then
		table.insert(updates, "`guild_experience` = " .. newExp)
	end
	if #updates > 0 then
		db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId())
	end

	upsertGuildQuestProgress(guild:getId(), cycleType, block.cycleStart, questId, progress, tonumber(row.completedAt) or os.time(), os.time())
	GuildAchievements.awardQuestClaim(guild:getId())
	if rewardExp > 0 then
		awardGuildQuestExperience(guild:getId(), rewardExp)
	end

	local rewardMessage = string.format(
		"[%s] %s claimed guild quest rewards: {%s}.",
		quest.name,
		player:getName(),
		buildQuestRewardText(rewards)
	)
	addGuildMessages(getGuildInboxRecipients(guild:getId()), guild:getId(), GuildManagement.MESSAGE_TYPES.QUEST_REWARD, rewardMessage, player:getGuid(), guild:getId())

	if (tonumber(storageSummary.overflowRows or 0) or 0) > 0 then
		addGuildMessages(
			getGuildInboxRecipients(guild:getId()),
			guild:getId(),
			GuildManagement.MESSAGE_TYPES.QUEST_REWARD,
			string.format(
				"[%s] Storage overflow while claiming quest rewards. {%d loot rows / %d items} could not be stored: %s.",
				quest.name,
				tonumber(storageSummary.overflowRows or 0) or 0,
				tonumber(storageSummary.overflowItems or 0) or 0,
				table.concat(storageSummary.overflowNames or {}, ", ")
			),
			player:getGuid(),
			guild:getId()
		)
	end

	sendGuildQuests(player)
	refreshGuildStorageForGuild(guild:getId())
	refreshGuildForMembers(guild:getId())
	if leveledUp then
		refreshGuildPerkState(guild:getId())
	end
end

local function sendGuildStorage(player)
	local guild = player:getGuild()
	if not guild then
		return sendGuildPayload(player, "storage", nil)
	end

	if not hasTable("guild_storage_items") then
		return sendGuildPayload(player, "storage", {
			capacity = GuildManagement.STORAGE_BASE_SLOTS,
			used = 0,
			items = {},
			error = "Guild storage schema is missing. Run migration 51 first."
		})
	end

	sendGuildPayload(player, "storage", buildGuildStorageData(guild:getId()))
end

local function getGuildPrismCapacity(guildId)
	local guildRow = getGuildRowById(guildId)
	local perkLevels = guildRow and decodeGuildPerks(guildRow.perks) or createEmptyGuildPerks()
	return getGuildPrismCapacityFromPerks(perkLevels)
end

local function getGuildActivePrismCount(guildId)
	ensurePrismStateLoaded()
	local entries = PrismState.byGuildId[guildId]
	return entries and #entries or 0
end

local function getGuildActiveDynastieCount(guildId)
	guildId = tonumber(guildId) or 0
	if guildId <= 0 or not GuildDynastie or not GuildDynastie.getGuildActiveConfigIds then
		return 0
	end

	local configIds = GuildDynastie.getGuildActiveConfigIds(guildId)
	return type(configIds) == "table" and #configIds or 0
end

local function cleanupDisbandedGuildData(guildId)
	guildId = tonumber(guildId) or 0
	if guildId <= 0 then
		return
	end

	local cleanupQueries = {
		{ tableName = "guild_storage_items", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_quest_progress", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_achievement_progress", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_black_market_purchases", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_dynastie_quest_progress", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_dynastie_defenders", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_dynastie_perks", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_dynastie_passives", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_dynastie_cooldowns", whereClause = "`guild_id` = " .. guildId },
		{ tableName = "guild_dynastie_attack_cooldowns", whereClause = "`attacker_guild_id` = " .. guildId }
	}

	for _, cleanup in ipairs(cleanupQueries) do
		if hasTable(cleanup.tableName) then
			db.query("DELETE FROM `" .. cleanup.tableName .. "` WHERE " .. cleanup.whereClause)
		end
	end
end

enforceGuildPrismCapacity = function(guildId)
	if not guildId or guildId <= 0 then
		return
	end

	ensurePrismStateLoaded()
	local entries = PrismState.byGuildId[guildId] or {}
	local capacity = getGuildPrismCapacity(guildId)
	if #entries <= capacity then
		return
	end

	local states = {}
	for _, configId in ipairs(entries) do
		local state = PrismState.byConfigId[configId]
		if state then
			table.insert(states, { configId = configId, state = state })
		end
	end

	table.sort(states, function(a, b)
		return (tonumber(a.state.id) or 0) > (tonumber(b.state.id) or 0)
	end)

	for index = capacity + 1, #states do
		releaseExpiredPrism(states[index].configId)
	end
end

local function buildGuildPrismCard(player, config)
	local state = PrismState.byConfigId[config.id]
	local guild = player:getGuild()
	local guildId = guild and guild:getId() or 0
	local ownerGuildName = ""
	local ownerGuildId = 0
	local usedSlots = 0
	local prismConfig = getPrismConfig()
	local emptyPlacedClientId = getClientItemId(config.placedItemId or prismConfig.DEFAULT_PLACED_ITEM_ID or 0)
	local emptyBaseClientId = getClientItemId(config.baseItemId or prismConfig.DEFAULT_BASE_ITEM_ID or 0)

	if state and state.guildId and state.guildId > 0 then
		ownerGuildId = state.guildId
		local ownerGuild = Guild(state.guildId)
		ownerGuildName = ownerGuild and ownerGuild:getName() or ("Guild #" .. state.guildId)
		usedSlots = countPrismUsedLootSlots(state.id)
	end
	local attackPayload = buildPrismAttackPayload(config.id, guildId)
	local canAttack = state and ownerGuildId > 0 and guildId > 0 and ownerGuildId ~= guildId and not attackPayload and (tonumber(state.shieldUntil or 0) or 0) <= os.time()
	local canTeleportAttack = attackPayload and attackPayload.participant or false
	local placeCooldownUntil = getPrismPlaceCooldownUntil(guildId, config.id)

	return {
		id = config.id,
		name = config.name,
		position = config.position,
		radius = tonumber(config.radius or prismConfig.DEFAULT_RADIUS or 20) or 20,
		baseItemId = emptyBaseClientId,
		placedItemId = state and getClientItemId(tonumber(state.placedItemId) or 0) or ((emptyPlacedClientId > 0) and emptyPlacedClientId or emptyBaseClientId),
		owned = ownerGuildId == guildId and guildId > 0,
		ownerGuildId = ownerGuildId,
		ownerGuildName = ownerGuildName,
		ownerPlayerName = state and (state.ownerPlayerName or "") or "",
		isConfigured = isValidPrismPosition(config.position),
		isEmpty = not state,
		placeCooldownUntil = placeCooldownUntil,
		expiresAt = state and (tonumber(state.expiresAt) or 0) or 0,
		shieldUntil = state and (tonumber(state.shieldUntil) or 0) or 0,
		goldBuffer = state and (tonumber(state.goldBuffer) or 0) or 0,
		expBuffer = state and (tonumber(state.expBuffer) or 0) or 0,
		lootUsed = usedSlots,
		lootLimit = state and (tonumber(state.lootSlots) or GuildManagement.PRISM_STORAGE_SLOTS) or GuildManagement.PRISM_STORAGE_SLOTS,
		attack = attackPayload,
		canAttack = canAttack and true or false,
		canTeleportAttack = canTeleportAttack and true or false
	}
end

local function buildGuildPrismData(player, page)
	ensurePrismStateLoaded()
	local guild = player:getGuild()
	local guildId = guild and guild:getId() or 0
	local capacity = guildId > 0 and getGuildPrismCapacity(guildId) or 0
	local used = guildId > 0 and getGuildActivePrismCount(guildId) or 0

	local allConfigs = getPrismConfigList()
	local pageSize = math.max(1, tonumber(GuildManagement.PRISM_PAGE_SIZE or 10) or 10)
	local total = #allConfigs
	local lastPage = math.max(1, math.ceil(total / pageSize))
	local currentPage = math.max(1, math.min(lastPage, math.floor(tonumber(page) or 1)))
	local startIndex = ((currentPage - 1) * pageSize) + 1
	local endIndex = math.min(total, startIndex + pageSize - 1)

	local cards = {}
	for index = startIndex, endIndex do
		local config = allConfigs[index]
		table.insert(cards, buildGuildPrismCard(player, config))
	end

	return {
		capacity = capacity,
		used = used,
		locations = cards,
		page = currentPage,
		lastPage = lastPage,
		total = total,
		pageSize = pageSize
	}
end

local function sendGuildPrisms(player, page)
	local guid = player and player:getGuid() or 0
	local resolvedPage = math.max(1, tonumber(page) or tonumber(prismViewerPages[guid] or 1) or 1)
	if guid > 0 then
		prismViewerPages[guid] = resolvedPage
	end
	sendGuildPayload(player, "prisms", buildGuildPrismData(player, resolvedPage))
end

local function refreshGuildPrismsForAllViewers()
	for guid, page in pairs(prismViewerPages) do
		local player = Player(guid)
		if player and prismActiveViewers[guid] == true then
			sendGuildPrisms(player, page)
		else
			prismViewerPages[guid] = nil
			prismActiveViewers[guid] = nil
		end
	end
end

local function setPrismViewerActive(player, active)
	local guid = player and player:getGuid() or 0
	if guid <= 0 then
		return
	end
	if active then
		prismActiveViewers[guid] = true
	else
		prismActiveViewers[guid] = nil
	end
end

local function getPrismAttackAreaRadius(state)
	local configured = tonumber(GuildManagement.PRISM_ATTACK_AREA_RADIUS or 0) or 0
	if configured > 0 then
		return configured
	end
	return tonumber(state and state.radius or 0) or 0
end

local function getPrismAttackAreaFloorRange()
	local configured = tonumber(GuildManagement.PRISM_ATTACK_AREA_FLOORS or 0) or 0
	if configured > 0 then
		return configured
	end
	return 0
end

local function isInsidePrismAttackArea(state, position)
	if not state or not position then
		return false
	end

	local radius = getPrismAttackAreaRadius(state)
	if radius <= 0 then
		return false
	end

	local dx = math.abs(position.x - state.position.x)
	local dy = math.abs(position.y - state.position.y)
	local dz = math.abs(position.z - state.position.z)
	return dz <= getPrismAttackAreaFloorRange() and dx <= radius and dy <= radius
end

local function getPrismAttackGuildName(guildId)
	local guild = guildId and Guild(guildId) or nil
	return guild and guild:getName() or ("Guild #" .. tostring(guildId or 0))
end

local function syncPrismAttackParticipants(attack, state)
	if not attack or not state then
		return
	end

	attack.members = attack.members or {}
	for _, participant in ipairs(Game.getPlayers()) do
		local participantGuild = participant:getGuild()
		local participantGuildId = participantGuild and participantGuild:getId() or 0
		if participantGuildId == attack.attackerGuildId or participantGuildId == attack.defenderGuildId then
			local guid = participant:getGuid()
			local member = attack.members[guid]
			if isInsidePrismAttackArea(state, participant:getPosition()) then
				local role = participantGuildId == attack.attackerGuildId and "attacker" or "defender"
					if not member then
						attack.members[guid] = {
							guildId = participantGuildId,
							role = role,
							leaveDeadline = 0,
							removed = false,
							removedReason = nil
						}
					else
						member.guildId = participantGuildId
						member.role = role
						if member.removedReason ~= "left_area" then
							member.removed = false
							member.removedReason = nil
						end
					end
				end
			end
		end
	end

buildPrismAttackPayload = function(configId, viewerGuildId)
	local attack = PrismAttackState.byConfigId[configId]
	if not attack then
		return nil
	end

	local attackerCount = 0
	local defenderCount = 0
	for _, member in pairs(attack.members or {}) do
		if not member.removed then
			if member.role == "attacker" then
				attackerCount = attackerCount + 1
			elseif member.role == "defender" then
				defenderCount = defenderCount + 1
			end
		end
	end

	return {
		status = attack.status,
		attackerGuildId = attack.attackerGuildId,
		attackerGuildName = getPrismAttackGuildName(attack.attackerGuildId),
		defenderGuildId = attack.defenderGuildId,
		defenderGuildName = getPrismAttackGuildName(attack.defenderGuildId),
		startsAt = tonumber(attack.startsAt or 0) or 0,
		endsAt = tonumber(attack.endsAt or 0) or 0,
		attackerCount = attackerCount,
		defenderCount = defenderCount,
		participant = viewerGuildId > 0 and (viewerGuildId == attack.attackerGuildId or viewerGuildId == attack.defenderGuildId) or false
	}
end

local function notifyPrismAttackGuilds(configId, text)
	local attack = PrismAttackState.byConfigId[configId]
	if not attack then
		return
	end

	local config = getPrismConfigById(configId)
	local locationName = config and config.name or "Prism"
	local messageText = "[" .. locationName .. "] " .. text
	addGuildMessages(getGuildInboxRecipients(attack.attackerGuildId), attack.attackerGuildId, GuildManagement.MESSAGE_TYPES.PRISM_ATTACK, messageText, 0, attack.defenderGuildId)
	addGuildMessages(getGuildInboxRecipients(attack.defenderGuildId), attack.defenderGuildId, GuildManagement.MESSAGE_TYPES.PRISM_ATTACK, messageText, 0, attack.attackerGuildId)
end

local function removePrismAttack(configId)
	PrismAttackState.byConfigId[configId] = nil
	refreshGuildPrismsForAllViewers()
end

local function resolvePrismAttack(configId, attackerWon)
	local attack = PrismAttackState.byConfigId[configId]
	local state = PrismState.byConfigId[configId]
	local config = getPrismConfigById(configId)
	if not attack or not state or not config then
		removePrismAttack(configId)
		return
	end

	local now = os.time()
	state.lastAttackAt = now

	if attackerWon then
		local stealPct = math.max(0, math.min(100, tonumber(GuildManagement.PRISM_ATTACK_WIN_STEAL_PERCENT or 25) or 25))
		local stolenGold = math.floor((tonumber(state.goldBuffer) or 0) * stealPct / 100)
		local stolenExp = math.floor((tonumber(state.expBuffer) or 0) * stealPct / 100)
		local lootRows = PrismState.lootByPrismId[state.id] or {}
		local stolenLootRows = {}
		for _, row in pairs(lootRows) do
			local itemId = tonumber(row.itemId) or 0
			local itemCount = tonumber(row.count) or 0
			local stolenCount = math.floor(itemCount * stealPct / 100)
			if itemId > 0 and stolenCount > 0 then
				table.insert(stolenLootRows, {
					itemId = itemId,
					count = stolenCount,
					tooltip = tostring(row.tooltip or ""),
					attributes = tostring(row.attributes or "")
				})
			end
		end

		local storageSummary = tryStoreItemsInGuildStorage(attack.attackerGuildId, stolenLootRows)
		if stolenGold > 0 or stolenExp > 0 then
			db.query(
				"UPDATE `guilds` SET `balance` = `balance` + " .. stolenGold ..
				", `guild_experience` = `guild_experience` + " .. stolenExp ..
				" WHERE `id` = " .. attack.attackerGuildId
			)
		end
		if GuildAchievements and GuildAchievements.awardPrismDestroyed then
			GuildAchievements.awardPrismDestroyed(attack.attackerGuildId, 1)
		end

		notifyPrismAttackGuilds(configId, "Attackers won the prism battle. The prism was destroyed.")
		local attackerGuildName = getPrismAttackGuildName(attack.attackerGuildId)
		local defenderGuildName = getPrismAttackGuildName(attack.defenderGuildId)
		local stolenSummary = string.format(
			"[%s] %s won the prism attack against %s and stole {%s gold}, {%s exp}, and moved {%d loot rows / %d items} to guild storage.",
			config.name or "Prism",
			attackerGuildName,
			defenderGuildName,
					formatCommaValue(stolenGold),
					formatCommaValue(stolenExp),
			tonumber(storageSummary.storedRows or 0) or 0,
			tonumber(storageSummary.storedItems or 0) or 0
		)
		addGuildMessages(
			getGuildInboxRecipients(attack.attackerGuildId),
			attack.attackerGuildId,
			GuildManagement.MESSAGE_TYPES.PRISM_STOLEN,
			stolenSummary,
			0,
			attack.defenderGuildId
		)
		if (tonumber(storageSummary.overflowRows or 0) or 0) > 0 then
			addGuildMessages(
				getGuildInboxRecipients(attack.attackerGuildId),
				attack.attackerGuildId,
				GuildManagement.MESSAGE_TYPES.PRISM_STOLEN,
				string.format(
					"[%s] Not enough guild storage space. {%d loot rows / %d items} from the prism robbery could not be stored: %s.",
					config.name or "Prism",
					tonumber(storageSummary.overflowRows or 0) or 0,
					tonumber(storageSummary.overflowItems or 0) or 0,
					table.concat(storageSummary.overflowNames, ", ")
				),
				0,
				attack.defenderGuildId
			)
		end
		releaseExpiredPrism(configId)
	else
		state.shieldUntil = now + GuildManagement.PRISM_ATTACK_SHIELD_SECONDS
		state.lastAttackAt = now
		state.dirty = true
		awardGuildQuestPrismDefense(attack.defenderGuildId)
		notifyPrismAttackGuilds(configId, "Defenders held the prism. It is now shielded.")
	end

	removePrismAttack(configId)
	if refreshPrismBattleForMembers then
		refreshPrismBattleForMembers(attack.attackerGuildId, attackerWon)
		refreshPrismBattleForMembers(attack.defenderGuildId, false)
	else
		refreshGuildForMembers(attack.attackerGuildId)
		refreshGuildForMembers(attack.defenderGuildId)
	end
end

local function schedulePrismAttackTick()
	if PrismAttackState.tickScheduled then
		return
	end

	PrismAttackState.tickScheduled = true
	addEvent(function()
		PrismAttackState.tickScheduled = false
		local now = os.time()
		for configId, attack in pairs(PrismAttackState.byConfigId) do
			local state = PrismState.byConfigId[configId]
			if not attack or not state then
				PrismAttackState.byConfigId[configId] = nil
			else
				if attack.status == "preparing" and now >= (tonumber(attack.startsAt) or 0) then
					attack.status = "active"
					attack.endsAt = now + GuildManagement.PRISM_ATTACK_DURATION_SECONDS
					notifyPrismAttackGuilds(configId, "Prism battle has started.")
					refreshGuildPrismsForAllViewers()
				end

				if attack.status == "active" then
					syncPrismAttackParticipants(attack, state)
					local attackers = 0
					local defenders = 0
					for guid, member in pairs(attack.members or {}) do
						local participant = Player(guid)
						if not participant or not participant:getGuild() or participant:getGuild():getId() ~= member.guildId then
							member.removed = true
							member.removedReason = "invalid_participant"
						elseif not isInsidePrismAttackArea(state, participant:getPosition()) then
							if not member.leaveDeadline or member.leaveDeadline <= 0 then
								member.leaveDeadline = now + GuildManagement.PRISM_ATTACK_LEAVE_GRACE_SECONDS
								participant:sendTextMessage(MESSAGE_STATUS_WARNING, "Return to the prism battle area or you will be removed from the battle.")
							elseif now >= member.leaveDeadline then
								member.removed = true
								member.removedReason = "left_area"
								member.leaveDeadline = 0
								participant:sendTextMessage(MESSAGE_STATUS_WARNING, "You were removed from the prism battle for leaving the area.")
							end
						else
							member.leaveDeadline = 0
						end

						if not member.removed then
							if member.role == "attacker" then
								attackers = attackers + 1
							elseif member.role == "defender" then
								defenders = defenders + 1
							end
						end
					end

					if now >= (tonumber(attack.endsAt) or 0) then
						for guid, member in pairs(attack.members or {}) do
							if not member.removed then
								local participant = Player(guid)
								if not participant or not isInsidePrismAttackArea(state, participant:getPosition()) then
									member.removed = true
								end
							end
						end

						attackers = 0
						defenders = 0
						for _, member in pairs(attack.members or {}) do
							if not member.removed then
								if member.role == "attacker" then
									attackers = attackers + 1
								elseif member.role == "defender" then
									defenders = defenders + 1
								end
							end
						end

						local attackerWon = false
						if attackers >= GuildManagement.PRISM_ATTACK_MIN_ATTACKERS and defenders < GuildManagement.PRISM_ATTACK_MIN_DEFENDERS then
							attackerWon = true
						elseif attackers >= GuildManagement.PRISM_ATTACK_MIN_ATTACKERS and attackers > defenders then
							attackerWon = true
						end
						resolvePrismAttack(configId, attackerWon)
					end
				end
			end
		end

		if next(PrismAttackState.byConfigId) then
			schedulePrismAttackTick()
		end
	end, 2000)
end

canUsePrismTeleport = function(player)
	if not player then
		return false, "Invalid player."
	end
	if player:hasCondition(CONDITION_INFIGHT) then
		return false, "You cannot teleport while in battle."
	end
	local nextUse = math.max(0, player:getStorageValue(GUILD_PRISM_TELEPORT_STORAGE))
	local now = os.time()
	if nextUse > now then
		return false, "You must wait " .. (nextUse - now) .. " seconds before using prism teleport again."
	end
	return true
end

local function placeGuildPrism(player, configId)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.MANAGE_PRISM) then
		return sendGuildError(player, "You do not have permission to manage prisms.")
	end

	ensurePrismStateLoaded()

	local config = getPrismConfigById(configId)
	if not config then
		return sendGuildError(player, "Unknown prism location.")
	end

	if not isValidPrismPosition(config.position) then
		return sendGuildError(player, "This prism location is not configured yet.")
	end

	local placeCooldownUntil = getPrismPlaceCooldownUntil(guild:getId(), configId)
	if placeCooldownUntil > os.time() then
		return sendGuildError(player, "This prism location is on cooldown.")
	end

	if PrismState.byConfigId[configId] then
		return sendGuildError(player, "This prism location is already occupied.")
	end

	local capacity = getGuildPrismCapacity(guild:getId())
	local used = getGuildActivePrismCount(guild:getId())
	if used >= capacity then
		enforceGuildPrismCapacity(guild:getId())
		used = getGuildActivePrismCount(guild:getId())
	end
	if used >= capacity then
		return sendGuildError(player, "Your guild does not have free prism capacity.")
	end

	local prismConfig = getPrismConfig()
	local requiredItemId = tonumber(config.requiredItemId or prismConfig.DEFAULT_REQUIRED_ITEM_ID or 0) or 0
	local requiredItemCount = math.max(1, tonumber(config.requiredItemCount or prismConfig.DEFAULT_REQUIRED_ITEM_COUNT or 1) or 1)
	if requiredItemId > 0 and player:getItemCount(requiredItemId) < requiredItemCount then
		return sendGuildError(player, "You do not have the required item: Prism Core, go to general crafting table and craft one in order to place a prism.")
	end

	if requiredItemId > 0 and not player:removeItem(requiredItemId, requiredItemCount) then
		return sendGuildError(player, "Failed to consume the required prism item.")
	end

	local now = os.time()
	local durationHours = tonumber(config.durationHours or prismConfig.DEFAULT_DURATION_HOURS or 72) or 72
	local radius = tonumber(config.radius or prismConfig.DEFAULT_RADIUS or 20) or 20
	local baseItemId = resolveWorldItemId(config.baseItemId or prismConfig.DEFAULT_BASE_ITEM_ID or 0)
	local placedItemId = resolveWorldItemId(config.placedItemId or prismConfig.DEFAULT_PLACED_ITEM_ID or 0)
	local lootSlots = tonumber(config.lootSlots or prismConfig.DEFAULT_LOOT_SLOTS or GuildManagement.PRISM_STORAGE_SLOTS) or GuildManagement.PRISM_STORAGE_SLOTS

	if not db.query(
		"INSERT INTO `guild_prisms` (`guild_id`, `config_id`, `owner_player_id`, `owner_player_name`, `placed_item_id`, `base_item_id`, `x`, `y`, `z`, `radius`, `gold_buffer`, `exp_buffer`, `loot_slots`, `expires_at`, `created_at`, `updated_at`) VALUES (" ..
		guild:getId() .. ", " .. escape(config.id) .. ", " .. player:getGuid() .. ", " .. escape(player:getName()) .. ", " .. placedItemId .. ", " .. baseItemId .. ", " ..
		config.position.x .. ", " .. config.position.y .. ", " .. config.position.z .. ", " .. radius .. ", 0, 0, " .. lootSlots .. ", " .. (now + (durationHours * 3600)) .. ", " .. now .. ", " .. now .. ")"
	) then
		PrismState.loaded = false
		ensurePrismStateLoaded()
		refreshGuildPrismsForAllViewers()
		if PrismState.byConfigId[config.id] then
			return sendGuildError(player, "This prism location is already occupied.")
		end
		return sendGuildError(player, "Failed to place guild prism.")
	end

	local prismId = db.lastInsertId()
	PrismState.byConfigId[config.id] = {
		id = prismId,
		guildId = guild:getId(),
		configId = config.id,
		ownerPlayerId = player:getGuid(),
		ownerPlayerName = player:getName(),
		placedItemId = placedItemId,
		baseItemId = baseItemId,
		position = { x = config.position.x, y = config.position.y, z = config.position.z },
		radius = radius,
		goldBuffer = 0,
		expBuffer = 0,
		lootSlots = lootSlots,
		expiresAt = now + (durationHours * 3600),
		dirty = false
	}
	PrismState.lootByPrismId[prismId] = {}
	reindexPrismState()
	spawnPrismWorldItem(config, PrismState.byConfigId[config.id])
	GuildAchievements.awardPrismPlace(guild:getId())
	refreshGuildPrismsForAllViewers()
end

local function teleportToGuildPrism(player, configId)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end

	local ok, err = canUsePrismTeleport(player)
	if not ok then
		return sendGuildError(player, err)
	end

	ensurePrismStateLoaded()

	local state = PrismState.byConfigId[configId]
	local config = getPrismConfigById(configId)
	if not state or not config then
		return sendGuildError(player, "Unknown prism.")
	end

	local attack = PrismAttackState.byConfigId[configId]
	local guildId = guild:getId()
	local ownsPrism = state.guildId == guildId
	local attackRole = nil
	if attack then
		if attack.attackerGuildId == guildId then
			attackRole = "attacker"
		elseif attack.defenderGuildId == guildId then
			attackRole = "defender"
		end
	end

	if not ownsPrism and not attackRole then
		return sendGuildError(player, "Your guild cannot use this prism teleport.")
	end

	if state.expiresAt > 0 and state.expiresAt <= os.time() then
		releaseExpiredPrism(configId)
		refreshGuildPrismsForAllViewers()
		return sendGuildError(player, "That prism has expired.")
	end

	player:teleportTo(config.position)
	local pos = Position(config.position.x, config.position.y, config.position.z)
	pos:sendMagicEffect(CONST_ME_TELEPORT)
	if attack and attackRole then
		attack.members = attack.members or {}
		attack.members[player:getGuid()] = {
			guildId = guildId,
			role = attackRole,
			leaveDeadline = 0,
			removed = false
		}
		refreshGuildPrismsForAllViewers()
		schedulePrismAttackTick()
	end
	player:setStorageValue(GUILD_PRISM_TELEPORT_STORAGE, os.time() + GuildManagement.PRISM_TELEPORT_COOLDOWN)
end

local function collectGuildPrism(player, configId)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.MANAGE_PRISM) then
		return sendGuildError(player, "You do not have permission to manage prisms.")
	end

	ensurePrismStateLoaded()

	local state = PrismState.byConfigId[configId]
	local config = getPrismConfigById(configId)
	if not state or not config or state.guildId ~= guild:getId() then
		return sendGuildError(player, "Your guild does not own that prism.")
	end
	if PrismAttackState.byConfigId[configId] then
		return sendGuildError(player, "You cannot collect from a prism while it is under attack.")
	end

	local lootRows = PrismState.lootByPrismId[state.id] or {}
	local pendingGold = math.floor(tonumber(state.goldBuffer) or 0)
	local pendingExp = math.floor(tonumber(state.expBuffer) or 0)
	local hasLoot = next(lootRows) ~= nil
	if pendingGold <= 0 and pendingExp <= 0 and not hasLoot then
		return sendGuildError(player, "This prism has nothing to collect yet.")
	end

	local backpacks = {}
	local currentBag = nil
	local currentCount = 0
	local backpackCapacity = getPrismLootBackpackCapacity()
	local collectedRarityIds = {}
	for _, row in pairs(lootRows) do
		local rowItemId = tonumber(row.itemId) or 0
		local rowCount = tonumber(row.count) or 1
		local rowAttributes = tostring(row.attributes or "")
		local chunks = splitItemCountForStorage(rowItemId, rowCount, row.tooltip, rowAttributes)
		for _, chunkEntry in ipairs(chunks) do
			if currentBag == nil or currentCount >= backpackCapacity then
				currentBag = createPrismLootBackpack()
				if not currentBag then
					return sendGuildError(player, "Failed to create a loot backpack.")
				end
				table.insert(backpacks, currentBag)
				currentCount = 0
			end

			local chunkCount = tonumber(chunkEntry.count) or 1
			local function tryAddToBag(container)
				if not container or not container.addItemEx then
					return nil
				end

				local tempItem = Game.createItem(rowItemId, chunkCount)
				if tempItem and rowAttributes ~= "" and tempItem.applyAttributes then
					tempItem:applyAttributes(rowAttributes)
					local itemType = ItemType(rowItemId)
					if itemType and itemType:isStackable() then
						tempItem:transform(rowItemId, chunkCount)
					end
				end
				if tempItem and tempItem.getCustomAttribute then
					local rarityId = tonumber(tempItem:getCustomAttribute("rarity")) or 0
					if rarityId > 0 then
						collectedRarityIds[rarityId] = true
					end
				end

				if not tempItem then
					return nil
				end

				local resultCode = container:addItemEx(tempItem)
				if resultCode == RETURNVALUE_NOERROR then
					return true
				end

				if tempItem and tempItem.remove then
					tempItem:remove()
				end
				return nil
			end

			local added = tryAddToBag(currentBag)
			if not added and currentCount > 0 then
				currentBag = createPrismLootBackpack()
				if not currentBag then
					for _, bag in ipairs(backpacks) do
						if bag and bag.remove then
							bag:remove()
						end
					end
					return sendGuildError(player, "Failed to create an additional loot backpack.")
				end
				table.insert(backpacks, currentBag)
				currentCount = 0
				added = tryAddToBag(currentBag)
			end
			if not added then
				for _, bag in ipairs(backpacks) do
					if bag and bag.remove then
						bag:remove()
					end
				end
				return sendGuildError(player, "Could not pack prism loot into backpacks.")
			end
			currentCount = currentCount + 1
		end
	end

	for _, bag in ipairs(backpacks) do
		local ret = player:addItemEx(bag, true)
		if ret ~= RETURNVALUE_NOERROR then
			for _, rollbackBag in ipairs(backpacks) do
				if rollbackBag and rollbackBag.remove then
					rollbackBag:remove()
				end
			end
			return sendGuildError(player, "You do not have enough room to collect prism loot.")
		end
	end

	if pendingGold > 0 or pendingExp > 0 then
		db.query(
			"UPDATE `guilds` SET `balance` = `balance` + " .. pendingGold ..
			", `guild_experience` = `guild_experience` + " .. pendingExp ..
			" WHERE `id` = " .. guild:getId()
		)
	end
	if pendingExp > 0 then
		awardGuildQuestExperience(guild:getId(), pendingExp)
	end
	if GuildAchievements then
		if pendingGold > 0 and GuildAchievements.awardPrismCollectedGold then
			GuildAchievements.awardPrismCollectedGold(guild:getId(), pendingGold)
		end
		if pendingExp > 0 and GuildAchievements.awardPrismCollectedExp then
			GuildAchievements.awardPrismCollectedExp(guild:getId(), pendingExp)
		end
		if GuildAchievements.awardPrismCollectedRarity then
			for rarityId, hasRarity in pairs(collectedRarityIds) do
				if hasRarity then
					GuildAchievements.awardPrismCollectedRarity(guild:getId(), rarityId)
				end
			end
		end
	end

	db.query("DELETE FROM `guild_prism_loot` WHERE `prism_id` = " .. state.id)
	PrismState.lootByPrismId[state.id] = {}
	state.goldBuffer = 0
	state.expBuffer = 0
	local lootBagCount = #backpacks
	local lootRowCount = 0
	local lootItemCount = 0
	for _, row in pairs(lootRows) do
		lootRowCount = lootRowCount + 1
		lootItemCount = lootItemCount + (tonumber(row.count) or 0)
	end
	releaseExpiredPrism(configId, os.time())
	refreshGuildPrismsForAllViewers()
	refreshGuildForMembers(guild:getId())
	addGuildMessages(
		getGuildInboxRecipients(guild:getId()),
		guild:getId(),
		GuildManagement.MESSAGE_TYPES.PRISM_COLLECT,
		string.format(
			"[%s] %s collected prism rewards: {%s gold}, {%s exp}, {%d loot rows / %d items} in {%d backpack(s)}.",
			config.name or "Prism",
			player:getName(),
			formatCommaValue(pendingGold),
			formatCommaValue(pendingExp),
			lootRowCount,
			lootItemCount,
			lootBagCount
		),
		0,
		guild:getId()
	)
	sendGuildPayload(player, "selfBalance", { balance = player:getBankBalance(), premiumPoints = getAccountPremiumPoints(player:getAccountId()) })
end

local function startPrismAttack(player, configId)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.MANAGE_PRISM) then
		return sendGuildError(player, "You do not have permission to manage prisms.")
	end

	ensurePrismStateLoaded()

	local state = PrismState.byConfigId[configId]
	local config = getPrismConfigById(configId)
	if not state or not config then
		return sendGuildError(player, "That prism does not exist.")
	end
	if state.guildId == guild:getId() then
		return sendGuildError(player, "You cannot attack your own prism.")
	end
	if PrismAttackState.byConfigId[configId] then
		return sendGuildError(player, "That prism is already under attack.")
	end

	local now = os.time()
	if tonumber(state.shieldUntil or 0) > now then
		return sendGuildError(player, "That prism is currently shielded.")
	end
	if tonumber(state.lastAttackAt or 0) > 0 and now < (tonumber(state.lastAttackAt or 0) + GuildManagement.PRISM_ATTACK_REATTACK_SECONDS) then
		return sendGuildError(player, "That prism cannot be attacked again yet.")
	end

	PrismAttackState.byConfigId[configId] = {
		configId = configId,
		attackerGuildId = guild:getId(),
		defenderGuildId = state.guildId,
		status = "preparing",
		startsAt = now + GuildManagement.PRISM_ATTACK_PREPARE_SECONDS,
		endsAt = 0,
		members = {}
	}
	syncPrismAttackParticipants(PrismAttackState.byConfigId[configId], state)
	notifyPrismAttackGuilds(configId, player:getName() .. " started a prism attack. Battle begins in 10 minutes.")
	refreshGuildPrismsForAllViewers()
	schedulePrismAttackTick()
end

local function addPrismLoot(prismState, itemId, count)
	if not prismState or not prismState.id or itemId <= 0 or count <= 0 then
		return false
	end
	return addPrismLootDetailed(prismState, {
		itemId = itemId,
		count = count,
		tooltip = "",
		attributes = ""
	})
end

local function addPrismLootDetailed(prismState, entry)
	local itemId = tonumber(entry and entry.itemId) or 0
	local count = tonumber(entry and entry.count) or 0
	local tooltip = tostring(entry and entry.tooltip or "")
	local attributes = tostring(entry and entry.attributes or "")
	if not prismState or not prismState.id or itemId <= 0 or count <= 0 then
		return false
	end

	local lootRows = PrismState.lootByPrismId[prismState.id] or {}
	PrismState.lootByPrismId[prismState.id] = lootRows

	for slot, row in pairs(lootRows) do
		if row.itemId == itemId and tostring(row.tooltip or "") == tooltip and tostring(row.attributes or "") == attributes then
			row.count = row.count + count
			prismState.dirty = true
			return true
		end
	end

	local nextSlot = getFirstFreePrismLootSlot(prismState.id, prismState.lootSlots or GuildManagement.PRISM_STORAGE_SLOTS)
	if nextSlot <= 0 then
		return false
	end

	lootRows[nextSlot] = {
		itemId = itemId,
		count = count,
		tooltip = tooltip,
		attributes = attributes
	}
	prismState.dirty = true
	return true
end

local function awardPrismLootFromMonster(prismState, monster, player)
	local prismConfig = getPrismConfig()
	local chance = tonumber(prismConfig.DEFAULT_LOOT_CHANCE or 2) or 2
	if math.random(100) > chance then
		return
	end

	local monsterType = monster:getType()
	if not monsterType then
		return
	end

	local lootTable = monsterType:getLoot()
	if type(lootTable) ~= "table" or #lootTable == 0 then
		return
	end

	local rolled = {}
	for _, lootData in ipairs(lootTable) do
		if getLootRandom() <= lootData.chance then
			table.insert(rolled, lootData)
		end
	end

	if #rolled == 0 then
		return
	end

	local picked = rolled[math.random(#rolled)]
	local amount = math.random(picked.minCount or 1, picked.maxCount or picked.count or 1)
	amount = math.max(1, amount)

	local itemType = ItemType(tonumber(picked.itemId) or 0)
	if not itemType or itemType:getId() == 0 then
		return
	end

	if itemType:isStackable() then
		addPrismLootDetailed(prismState, {
			itemId = picked.itemId,
			count = amount,
			tooltip = itemType:getName(),
			attributes = ""
		})
		return
	end

	for _ = 1, amount do
		local rarityId = 0
		if not itemType:isContainer() and not itemType:isStackable() then
			rarityId = rollPrismRarity(player)
		end

		local tempItem = nil
		if rarityId > 0 and Game.createItemWithRarity then
			tempItem = Game.createItemWithRarity(picked.itemId, 1, rarityId)
		end
		if not tempItem then
			tempItem = Game.createItem(picked.itemId, 1)
		end
		if tempItem then
			local tooltip = tempItem:getSpecialDescription() or ""
			if tooltip == "" then
				tooltip = itemType:getName()
			end
			local attributes = serializeStorageItemAttributes(tempItem)
			addPrismLootDetailed(prismState, {
				itemId = picked.itemId,
				count = 1,
				tooltip = tooltip,
				attributes = attributes
			})
			tempItem:remove()
		end
	end
end

local function getOwningPrismForKill(player, target)
	if not target then
		return nil
	end

	local pos = target:getPosition()
	if not pos then
		return nil
	end

	for configId, state in pairs(PrismState.byConfigId) do
		if state and state.expiresAt > os.time() then
			local cfg = getPrismConfigById(configId)
			local effectiveRadius = tonumber((cfg and cfg.radius) or state.radius or 0) or 0
			local dx = math.abs(pos.x - state.position.x)
			local dy = math.abs(pos.y - state.position.y)
			local dz = math.abs(pos.z - state.position.z)
			if dz == 0 and dx <= effectiveRadius and dy <= effectiveRadius then
				return state
			end
		end
	end

	return nil
end

refreshGuildStorageForGuild = function(guildId)
	for _, member in ipairs(getOnlineGuildPlayers(guildId)) do
		sendGuildStorage(member)
	end
end

local function getGuildPerkData(guildRow)
	local perkLevels = hasColumn("guilds", "perks") and decodeGuildPerks(guildRow.perks) or createEmptyGuildPerks()
	local perks = {}
	local activePerkLevels = 0
	for _, perk in ipairs(GuildManagement.PERKS) do
		local level = getGuildPerkLevel(perkLevels, perk.id)
		activePerkLevels = activePerkLevels + level
		table.insert(perks, {
			id = perk.id,
			name = perk.name,
			icon = perk.icon,
			bonus = perk.bonus,
			tooltip = perk.tooltip,
			rlevel = perk.rlevel,
			maxLevel = perk.maxLevel,
			level = level,
			cost = perk.costBase * (level + 1),
			premiumPoints = (perk.premiumPointsBase or 0) * (level + 1),
		})
	end

	local guildLevel = tonumber(guildRow.guild_level) or 1
	local nextPerk = guildLevel
	for _, perk in ipairs(GuildManagement.PERKS) do
		if guildLevel < perk.rlevel then
			nextPerk = perk.rlevel
			break
		end
	end
	return {
		basic = {
			guildLevel = guildLevel,
			perks = activePerkLevels,
			nextPerk = nextPerk,
			premiumBalance = tonumber(guildRow.premium_balance) or 0,
			dynastieBalance = tonumber(guildRow.dynastie_tokens) or 0,
		},
		list = perks,
	}
end

local function getGuildOnlineCount(guildId)
	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM `players_online` `po` INNER JOIN `guild_membership` `gm` ON `gm`.`player_id` = `po`.`player_id` WHERE `gm`.`guild_id` = " .. guildId)
	if not resultId then
		return 0
	end
	local count = result.getNumber(resultId, "count")
	result.free(resultId)
	return count
end

local function getGuildMemberCount(guildId)
	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM `guild_membership` WHERE `guild_id` = " .. guildId)
	if not resultId then
		return 0
	end
	local count = result.getNumber(resultId, "count")
	result.free(resultId)
	return count
end

local function getGuildTotalLevels(guildId)
	local resultId = db.storeQuery("SELECT COALESCE(SUM(`p`.`level`), 0) AS `total`, COALESCE(AVG(`p`.`level`), 0) AS `avgLevel` FROM `guild_membership` `gm` INNER JOIN `players` `p` ON `p`.`id` = `gm`.`player_id` WHERE `gm`.`guild_id` = " .. guildId)
	if not resultId then
		return 0, 0
	end
	local total = result.getNumber(resultId, "total")
	local avgLevel = math.floor(result.getNumber(resultId, "avgLevel"))
	result.free(resultId)
	return total, avgLevel
end

local function getGuildLeaderName(guildId, ownerId)
	local resultId = db.storeQuery("SELECT `name` FROM `players` WHERE `id` = " .. ownerId)
	if not resultId then
		return ""
	end
	local name = result.getString(resultId, "name")
	result.free(resultId)
	return name
end

local function getGuildTopRank(guildId, guildLevel, totalLevels, guildName)
	local level = tonumber(guildLevel) or 1
	local total = tonumber(totalLevels) or 0
	local name = guildName or ""
	local escapedName = escape(name)

	local resultId = db.storeQuery([[
		SELECT COUNT(*) AS `count`
		FROM (
			SELECT
				`g`.`id`,
				`g`.`name`,
				`g`.`guild_level`,
				COALESCE(SUM(`p`.`level`), 0) AS `total_levels`
			FROM `guilds` `g`
			LEFT JOIN `guild_membership` `gm` ON `gm`.`guild_id` = `g`.`id`
			LEFT JOIN `players` `p` ON `p`.`id` = `gm`.`player_id`
			GROUP BY `g`.`id`
		) `ranked`
		WHERE
			`ranked`.`guild_level` > ]] .. level .. [[ OR
			(`ranked`.`guild_level` = ]] .. level .. [[ AND `ranked`.`total_levels` > ]] .. total .. [[) OR
			(`ranked`.`guild_level` = ]] .. level .. [[ AND `ranked`.`total_levels` = ]] .. total .. [[ AND `ranked`.`name` < ]] .. escapedName .. [[)
	]])

	if not resultId then
		return 1
	end

	local rank = result.getNumber(resultId, "count") + 1
	result.free(resultId)
	return rank
end

local function getGuildRankPermissions(rankId, ownerId, playerId)
	if ownerId == playerId then
		return GuildManagement.PERMISSIONS.ALL
	end
	if not hasColumn("guild_ranks", "permissions") then
		return 0
	end
	local resultId = db.storeQuery("SELECT `permissions` FROM `guild_ranks` WHERE `id` = " .. rankId)
	if not resultId then
		return 0
	end
	local perms = result.getNumber(resultId, "permissions")
	result.free(resultId)
	return perms
end

hasPermission = function(player, permission)
	local guild = player:getGuild()
	if not guild then
		return false
	end
	local guildRow = getGuildRowById(guild:getId())
	if not guildRow then
		return false
	end
	local membership = getPlayerGuildMembership(player:getGuid())
	if not membership then
		return false
	end
	local perms = getGuildRankPermissions(membership.rankId, guildRow.ownerid, player:getGuid())
	if perms == -1 then
		return true
	end
	return bit.band(perms, math.pow(2, permission)) ~= 0
end

local function getGuildMembersData(guildId)
	local members = {}
	local query = db.storeQuery([[
		SELECT
			`p`.`id`,
			`p`.`name`,
			`p`.`level`,
			`p`.`vocation`,
			`p`.`lastlogin`,
			`gr`.`name` AS `rank_name`,
			`gr`.`level` AS `rank_level`,
			`gm`.`nick`,
			CASE WHEN `po`.`player_id` IS NULL THEN 0 ELSE 1 END AS `online`
		FROM `guild_membership` `gm`
		INNER JOIN `players` `p` ON `p`.`id` = `gm`.`player_id`
		INNER JOIN `guild_ranks` `gr` ON `gr`.`id` = `gm`.`rank_id`
		LEFT JOIN `players_online` `po` ON `po`.`player_id` = `p`.`id`
		WHERE `gm`.`guild_id` = ]] .. guildId .. [[
		ORDER BY `gr`.`level` DESC, `p`.`level` DESC, `p`.`name` ASC
	]])

	if not query then
		return members
	end

	repeat
		table.insert(members, {
			name = result.getString(query, "name"),
			level = result.getNumber(query, "level"),
			proficiencyLevel = result.getNumber(query, "level"),
			voc = result.getNumber(query, "vocation"),
			rank = result.getString(query, "rank_name"),
			online = result.getNumber(query, "online") == 1,
			last = result.getNumber(query, "lastlogin"),
			contribution = 0,
			nick = result.getString(query, "nick")
		})
	until not result.next(query)

	result.free(query)
	return members
end

local function getGuildRanksData(guildId, ownerId)
	normalizeLegacyGuildDefaultRanks(guildId)

	local ranks = {}
	local fields = hasColumn("guild_ranks", "permissions") and "`id`, `name`, `level`, `permissions`" or "`id`, `name`, `level`"
	local query = db.storeQuery("SELECT " .. fields .. " FROM `guild_ranks` WHERE `guild_id` = " .. guildId .. " ORDER BY `level` DESC")
	if not query then
		return ranks
	end

	local defaultLevel = 1
	repeat
		local level = result.getNumber(query, "level")
		table.insert(ranks, {
			id = result.getNumber(query, "id"),
			name = result.getString(query, "name"),
			permissions = level >= 3 and GuildManagement.PERMISSIONS.ALL or (hasColumn("guild_ranks", "permissions") and result.getNumber(query, "permissions") or 0),
			leader = level >= 3,
			default = level == defaultLevel,
			removed = false
		})
	until not result.next(query)
	result.free(query)
	return ranks
end

local function getGuildGeneralData(player, guildId)
	local guildRow = getGuildRowById(guildId)
	if not guildRow then
		return nil
	end

	local memberCount = getGuildMemberCount(guildId)
	local totalLevels, avgLevel = getGuildTotalLevels(guildId)
	local onlineCount = getGuildOnlineCount(guildId)
	local perkLevels = hasColumn("guilds", "perks") and decodeGuildPerks(guildRow.perks) or createEmptyGuildPerks()
	local memberLimit = getGuildMemberLimit(guildRow.guild_level, perkLevels)
	local prismCapacity = getGuildPrismCapacityFromPerks(perkLevels)
	local dynastieCapacity = getGuildDynastieCapacityFromPerks(perkLevels)
	local storageCapacity = getGuildStorageCapacityFromPerks(perkLevels)
	local storageUsed = getGuildStorageItemCount(guildId)
	local completedAchievements = GuildAchievements and GuildAchievements.getCompletedCount and GuildAchievements.getCompletedCount(guildId) or 0
	local totalAchievements = GuildAchievements and GuildAchievements.getDefinitionCount and GuildAchievements.getDefinitionCount() or 0
	local guildKills = GuildAchievements and GuildAchievements.getGuildPlayerKillTotal and GuildAchievements.getGuildPlayerKillTotal(guildId) or 0
	local membership = getPlayerGuildMembership(player:getGuid())
	local permissions = membership and getGuildRankPermissions(membership.rankId, guildRow.ownerid, player:getGuid()) or 0

	local nextLevel = guildRow.guild_level * GuildManagement.NEXT_LEVEL_BASE
	if nextLevel < GuildManagement.NEXT_LEVEL_BASE then
		nextLevel = GuildManagement.NEXT_LEVEL_BASE
	end

	return {
		id = guildRow.id,
		name = guildRow.name,
		ownerid = guildRow.ownerid,
		leader = getGuildLeaderName(guildRow.id, guildRow.ownerid),
		motd = guildRow.motd,
		emblem = tonumber(guildRow.emblem) or guildRow.emblem,
		language = guildRow.language,
		joinStatus = guildRow.join_status,
		reqLevel = guildRow.required_level,
		level = guildRow.guild_level,
		rank = getGuildTopRank(guildRow.id, guildRow.guild_level, totalLevels, guildRow.name),
		total = totalLevels,
		avgLevel = avgLevel,
		members = { memberCount, memberLimit },
		storage = { storageUsed, storageCapacity },
		prisms = { getGuildActivePrismCount(guildId), prismCapacity },
		dynasties = { GuildDynastie and GuildDynastie.getGuildActiveCount and GuildDynastie.getGuildActiveCount(guildId) or 0, dynastieCapacity },
		achievements = { completedAchievements, totalAchievements },
		kills = guildKills,
		created = guildRow.creationdata > 0 and os.date("%d/%m/%Y", guildRow.creationdata) or "-",
		createdAt = tonumber(guildRow.creationdata) or 0,
		permissions = permissions,
		balance = guildRow.balance,
		contribution = guildRow.contribution,
		premiumBalance = guildRow.premium_balance,
		dynastieBalance = guildRow.dynastie_tokens,
		premiumContribution = guildRow.premium_contribution,
		exp = { guildRow.guild_experience, nextLevel },
		expNew = {
			level = guildRow.guild_level,
			exp = guildRow.guild_experience,
			base = nextLevel
		},
		serverTime = os.time() * 1000
	}
end

local function getTopGuilds(offset)
	local top = {}
	local totalGuilds = 0
	local totalQuery = db.storeQuery("SELECT COUNT(*) AS `count` FROM `guilds`")
	if totalQuery then
		totalGuilds = result.getNumber(totalQuery, "count")
		result.free(totalQuery)
	end

	local totalAchievementCount = 0
	if hasTable("guild_achievement_progress") then
		totalAchievementCount = GuildAchievements and GuildAchievements.getDefinitionCount and GuildAchievements.getDefinitionCount() or 0
	end

	local query = db.storeQuery([[
		SELECT
			`g`.`id`,
			`g`.`name`,
			`g`.`ownerid`,
			`g`.`emblem`,
			`g`.`language`,
			`g`.`join_status`,
			`g`.`required_level`,
			`g`.`guild_level`,
			COALESCE(COUNT(`gm`.`player_id`), 0) AS `members`,
			COALESCE(SUM(`p`.`level`), 0) AS `total_levels`
		FROM `guilds` `g`
		LEFT JOIN `guild_membership` `gm` ON `gm`.`guild_id` = `g`.`id`
		LEFT JOIN `players` `p` ON `p`.`id` = `gm`.`player_id`
		GROUP BY `g`.`id`
		ORDER BY `g`.`guild_level` DESC, `total_levels` DESC, `g`.`name` ASC
		LIMIT ]] .. GuildManagement.TOP_PAGE_SIZE .. " OFFSET " .. offset)

	if query then
		repeat
			local guildId = result.getNumber(query, "id")
			local memberCount = result.getNumber(query, "members")
			local totalLevels = result.getNumber(query, "total_levels")
			local guildRow = getGuildRowById(guildId)
			local perkLevels = guildRow and decodeGuildPerks(guildRow.perks) or createEmptyGuildPerks()
			local prismCapacity = getGuildPrismCapacityFromPerks(perkLevels)
			local activePrisms = getGuildActivePrismCount(guildId)
			local completedAchievements = 0
			if hasTable("guild_achievement_progress") then
				local achievementQuery = db.storeQuery("SELECT COUNT(*) AS `count` FROM `guild_achievement_progress` WHERE `guild_id` = " .. guildId .. " AND `completed_at` > 0")
				if achievementQuery then
					completedAchievements = result.getNumber(achievementQuery, "count")
					result.free(achievementQuery)
				end
			end
			local avgLevel = memberCount > 0 and math.floor(totalLevels / memberCount) or 0
			table.insert(top, {
				id = guildId,
				name = result.getString(query, "name"),
				leader = getGuildLeaderName(guildId, result.getNumber(query, "ownerid")),
				emblem = tonumber(result.getString(query, "emblem")) or result.getString(query, "emblem"),
				language = result.getNumber(query, "language"),
				status = result.getNumber(query, "join_status"),
				reqLevel = result.getNumber(query, "required_level"),
				level = result.getNumber(query, "guild_level"),
				members = { memberCount, getGuildMemberLimit(result.getNumber(query, "guild_level"), perkLevels) },
				avgLevel = avgLevel,
				total = totalLevels,
				prisms = { activePrisms, prismCapacity },
				achievements = { completedAchievements, totalAchievementCount },
				won = 0
			})
		until not result.next(query)
		result.free(query)
	end

	return {
		new = offset == 0,
		top = top,
		last = totalGuilds
	}
end

local function addGuildMessage(playerId, guildId, messageType, text, targetId, sourceGuildId)
	local cutoff = os.time() - (GuildManagement.INBOX_RETENTION_DAYS * 24 * 60 * 60)
	db.query("DELETE FROM `guild_messages` WHERE `player_id` = " .. playerId .. " AND `created_at` < " .. cutoff)
	db.query("INSERT INTO `guild_messages` (`player_id`, `guild_id`, `type`, `target_id`, `source_guild_id`, `text`, `created_at`, `finished`) VALUES (" ..
		playerId .. ", " .. (guildId or 0) .. ", " .. messageType .. ", " .. (targetId or 0) .. ", " .. (sourceGuildId or 0) .. ", " ..
		escape(text) .. ", " .. os.time() .. ", 0)")
	local id = db.lastInsertId()

	local player = Player(playerId)
	if player then
		sendGuildPayload(player, "message", {
			id = id,
			type = messageType,
			text = text,
			date = os.time(),
			targetId = targetId or 0,
			guildId = sourceGuildId or guildId or 0,
			finished = 0
		})

		local liveText = "[Guild] " .. tostring(text or "")
		if messageType == GuildManagement.MESSAGE_TYPES.PRISM_ATTACK or messageType == GuildManagement.MESSAGE_TYPES.DYNASTIE_ATTACK then
			player:sendTextMessage(MESSAGE_STATUS_WARNING, liveText)
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, liveText)
		end
	end
end

getGuildInboxRecipients = function(guildId)
	local recipients = {}
	local ownerId = 0
	local ownerQuery = db.storeQuery("SELECT `ownerid` FROM `guilds` WHERE `id` = " .. guildId)
	if ownerQuery then
		ownerId = result.getNumber(ownerQuery, "ownerid")
		result.free(ownerQuery)
	end

	local query = db.storeQuery([[
		SELECT
			`gm`.`player_id`,
			`gm`.`rank_id`
		FROM `guild_membership` `gm`
		WHERE `gm`.`guild_id` = ]] .. guildId)

	if not query then
		return recipients
	end

	repeat
		local playerId = result.getNumber(query, "player_id")
		local rankId = result.getNumber(query, "rank_id")
		local allow = ownerId == playerId

		if not allow then
			local perms = getGuildRankPermissions(rankId, ownerId, playerId)
			allow =
				perms == GuildManagement.PERMISSIONS.ALL or
				bit.band(perms, math.pow(2, GuildManagement.PERMISSIONS.INVITE_MEMBERS)) ~= 0 or
				bit.band(perms, math.pow(2, GuildManagement.PERMISSIONS.EDIT_MEMBERS)) ~= 0
		end

		if allow then
			table.insert(recipients, playerId)
		end
	until not result.next(query)

	result.free(query)
	return recipients
end

addGuildMessages = function(playerIds, guildId, messageType, text, targetId, sourceGuildId)
	local sent = {}
	for _, playerId in ipairs(playerIds) do
		if not sent[playerId] then
			addGuildMessage(playerId, guildId, messageType, text, targetId, sourceGuildId)
			sent[playerId] = true
		end
	end
end

local function addContributionHistoryEntry(guildId, playerId, playerName, value, currency)
	db.query("INSERT INTO `guild_contribution_history` (`guild_id`, `player_id`, `player_name`, `value`, `currency`, `created_at`) VALUES (" ..
		guildId .. ", " .. playerId .. ", " .. escape(playerName) .. ", " .. math.max(0, tonumber(value) or 0) .. ", " .. (tonumber(currency) or 1) .. ", " .. os.time() .. ")")
end

local function getContributionHistory(guildId)
	local dataByName = {}

	local membershipQuery = db.storeQuery([[
		SELECT `p`.`name`
		FROM `guild_membership` `gm`
		INNER JOIN `players` `p` ON `p`.`id` = `gm`.`player_id`
		WHERE `gm`.`guild_id` = ]] .. guildId .. [[
		ORDER BY `p`.`name` ASC
	]])

	if membershipQuery then
		repeat
			local name = result.getString(membershipQuery, "name")
			dataByName[name] = { name = name, history = {}, historyGold = {}, historyPremium = {}, totalGold = 0, totalPremium = 0 }
		until not result.next(membershipQuery)
		result.free(membershipQuery)
	end

	local query = db.storeQuery("SELECT `player_name`, `value`, `currency`, `created_at` FROM `guild_contribution_history` WHERE `guild_id` = " .. guildId .. " ORDER BY `created_at` DESC, `id` DESC")
	if query then
		repeat
			local name = result.getString(query, "player_name")
			local entry = {
				value = result.getNumber(query, "value"),
				currency = result.getNumber(query, "currency"),
				date = result.getNumber(query, "created_at"),
				dateText = os.date("%d/%m/%Y", result.getNumber(query, "created_at"))
			}

			if not dataByName[name] then
				dataByName[name] = { name = name, history = {}, historyGold = {}, historyPremium = {}, totalGold = 0, totalPremium = 0 }
			end

			table.insert(dataByName[name].history, entry)
			if entry.currency == 3 then
				table.insert(dataByName[name].historyPremium, entry)
				dataByName[name].totalPremium = dataByName[name].totalPremium + entry.value
			else
				table.insert(dataByName[name].historyGold, entry)
				dataByName[name].totalGold = dataByName[name].totalGold + entry.value
			end
		until not result.next(query)
		result.free(query)
	end

	local response = {}
	for _, member in ipairs(getGuildMembersData(guildId)) do
		local entry = dataByName[member.name]
		if not entry then
			entry = { name = member.name, history = {}, historyGold = {}, historyPremium = {}, totalGold = 0, totalPremium = 0 }
		end
		table.insert(response, entry)
		dataByName[member.name] = nil
	end

	for _, entry in pairs(dataByName) do
		table.insert(response, entry)
	end

	return response
end

local function fetchInbox(player, offset)
	local cutoff = os.time() - (GuildManagement.INBOX_RETENTION_DAYS * 24 * 60 * 60)
	db.query("DELETE FROM `guild_messages` WHERE `player_id` = " .. player:getGuid() .. " AND `created_at` < " .. cutoff)
	local inbox = {}
	local total = 0
	local totalQuery = db.storeQuery("SELECT COUNT(*) AS `count` FROM `guild_messages` WHERE `player_id` = " .. player:getGuid())
	if totalQuery then
		total = result.getNumber(totalQuery, "count")
		result.free(totalQuery)
	end

	local query = db.storeQuery("SELECT `id`, `type`, `text`, `created_at`, `target_id`, `source_guild_id`, `finished` FROM `guild_messages` WHERE `player_id` = " .. player:getGuid() .. " ORDER BY `id` DESC LIMIT " .. GuildManagement.INBOX_PAGE_SIZE .. " OFFSET " .. offset)
	if query then
		repeat
			table.insert(inbox, {
				id = result.getNumber(query, "id"),
				type = result.getNumber(query, "type"),
				text = result.getString(query, "text"),
				date = result.getNumber(query, "created_at"),
				targetId = result.getNumber(query, "target_id"),
				guildId = result.getNumber(query, "source_guild_id"),
				finished = result.getNumber(query, "finished")
			})
		until not result.next(query)
		result.free(query)
	end

	sendGuildPayload(player, "inbox", {
		new = offset == 0,
		size = #inbox,
		last = total,
		inbox = inbox
	})
end

local function finishGuildMessage(messageId)
	db.query("UPDATE `guild_messages` SET `finished` = 1 WHERE `id` = " .. messageId)
end

local function getGuildPerkLevelsByGuildId(guildId)
	local guildRow = getGuildRowById(guildId)
	if not guildRow then
		return createEmptyGuildPerks(), nil
	end

	if not hasColumn("guilds", "perks") then
		return createEmptyGuildPerks(), guildRow
	end

	return decodeGuildPerks(guildRow.perks), guildRow
end

local function clearGuildPerkEffects(player)
	if not player then
		return
	end

	player:removeCondition(CONDITION_REGENERATION, CONDITIONID_DEFAULT, GUILD_PERK_REGEN_SUBID, true)
	player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, GUILD_PERK_CRIT_CHANCE_SUBID, true)
	player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, GUILD_PERK_CRIT_DAMAGE_SUBID, true)
	player:removeSpecializedMagicLevel(COMBAT_HEALING, 0)
	player:setStorageValue(405793, 0)
	if _G.GuildHall_refreshRarityEquipmentBonuses then
		_G.GuildHall_refreshRarityEquipmentBonuses(player)
	end
	if player.updateClientStats then
		player:updateClientStats()
	end
end

local function applyGuildPerkEffects(player)
	if not player then
		return
	end

	clearGuildPerkEffects(player)

	local guild = player:getGuild()
	if not guild then
		return
	end

	local perkLevels = getGuildPerkLevelsByGuildId(guild:getId())
	local healthRegenLevel = getGuildPerkLevel(perkLevels, 1)
	local manaRegenLevel = getGuildPerkLevel(perkLevels, 2)
	local criticalChanceLevel = getGuildPerkLevel(perkLevels, 3)
	local criticalDamageLevel = getGuildPerkLevel(perkLevels, 4)

	if healthRegenLevel > 0 or manaRegenLevel > 0 then
		local vocation = player:getVocation()
		local healthTicks = math.max(1000, tonumber(vocation:getHealthGainTicks()) or 6000)
		local manaTicks = math.max(1000, tonumber(vocation:getManaGainTicks()) or 6000)
		local healthBase = math.max(1, tonumber(vocation:getHealthGainAmount()) or 1)
		local manaBase = math.max(1, tonumber(vocation:getManaGainAmount()) or 1)
		local healthGain = math.max(0, math.ceil(healthBase * 0.02 * healthRegenLevel))
		local manaGain = math.max(0, math.ceil(manaBase * 0.02 * manaRegenLevel))

		if healthGain > 0 or manaGain > 0 then
			local condition = Condition(CONDITION_REGENERATION, CONDITIONID_DEFAULT)
			condition:setParameter(CONDITION_PARAM_SUBID, GUILD_PERK_REGEN_SUBID)
			condition:setParameter(CONDITION_PARAM_TICKS, -1)
			condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
			condition:setParameter(CONDITION_PARAM_HEALTHTICKS, healthTicks)
			condition:setParameter(CONDITION_PARAM_MANATICKS, manaTicks)
			condition:setParameter(CONDITION_PARAM_HEALTHGAIN, healthGain)
			condition:setParameter(CONDITION_PARAM_MANAGAIN, manaGain)
			player:addCondition(condition)
		end
	end

	if criticalChanceLevel > 0 then
		local chanceCondition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
		chanceCondition:setParameter(CONDITION_PARAM_SUBID, GUILD_PERK_CRIT_CHANCE_SUBID)
		chanceCondition:setParameter(CONDITION_PARAM_TICKS, -1)
		chanceCondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, criticalChanceLevel)
		player:addCondition(chanceCondition)
	end

	if criticalDamageLevel > 0 then
		local damageCondition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
		damageCondition:setParameter(CONDITION_PARAM_SUBID, GUILD_PERK_CRIT_DAMAGE_SUBID)
		damageCondition:setParameter(CONDITION_PARAM_TICKS, -1)
		damageCondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, criticalDamageLevel)
		player:addCondition(damageCondition)
	end

	local dynastiePhysicalBonus = 0
	local dynastieHealingBonus = 0
	if _G.GuildDynastie_getPlayerElementBonuses then
		local dynastieBonuses = _G.GuildDynastie_getPlayerElementBonuses(player) or {}
		dynastiePhysicalBonus = math.max(0, tonumber(dynastieBonuses.physical) or 0)
		dynastieHealingBonus = math.max(0, tonumber(dynastieBonuses.healing) or 0)
	end
	if dynastiePhysicalBonus > 0 then
		player:addSpecializedMagicLevel(COMBAT_PHYSICALDAMAGE, dynastiePhysicalBonus)
	end
	if dynastieHealingBonus > 0 then
		player:addSpecializedMagicLevel(COMBAT_HEALING, dynastieHealingBonus)
	end

	local dynastieRarityBonus = 0
	if _G.GuildDynastie_getPlayerRarityLootBonus then
		dynastieRarityBonus = math.max(0, tonumber(_G.GuildDynastie_getPlayerRarityLootBonus(player)) or 0)
	end
	player:setStorageValue(405793, dynastieRarityBonus)

	if _G.GuildHall_refreshRarityEquipmentBonuses then
		_G.GuildHall_refreshRarityEquipmentBonuses(player)
	end

	if player.updateClientStats then
		player:updateClientStats()
	end
end

local function refreshGuildPerksForGuild(guildId)
	for _, member in ipairs(getOnlineGuildPlayers(guildId)) do
		applyGuildPerkEffects(member)
	end
end

local function getPlayerPerkLevels(player)
	if not player then
		return createEmptyGuildPerks()
	end

	local guild = player:getGuild()
	if not guild then
		return createEmptyGuildPerks()
	end

	local levels = getGuildPerkLevelsByGuildId(guild:getId())
	return levels
end

local function resolveAttackerPlayer(attacker)
	if not attacker then
		return nil
	end

	if attacker:isPlayer() then
		return attacker
	end

	local master = attacker:getMaster()
	if master and master:isPlayer() then
		return master
	end

	return nil
end

local function scaleDamageValue(damage, percent, increase)
	if not damage or damage == 0 or percent <= 0 then
		return damage
	end

	local sign = damage < 0 and -1 or 1
	local absDamage = math.abs(damage)
	local multiplier = increase and (1 + percent / 100) or math.max(0, 1 - percent / 100)
	local scaled = math.floor(absDamage * multiplier + 0.5)
	if absDamage > 0 and scaled == 0 then
		scaled = 1
	end

	return sign * scaled
end

local GuildPerkCombat = CreatureEvent("GuildManagementPerkCombat")

function GuildPerkCombat.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if creature:isMonster() then
		if _G.GuildDynastie_filterDamageToDefender then
			local adjustedPrimary, adjustedPrimaryType, adjustedSecondary, adjustedSecondaryType =
				_G.GuildDynastie_filterDamageToDefender(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
			primaryDamage, primaryType, secondaryDamage, secondaryType =
				adjustedPrimary, adjustedPrimaryType, adjustedSecondary, adjustedSecondaryType
		end

		local player = resolveAttackerPlayer(attacker)
		if not player then
			return primaryDamage, primaryType, secondaryDamage, secondaryType
		end

		local monsterDamageLevel = getGuildPerkLevel(getPlayerPerkLevels(player), 5)
		if monsterDamageLevel > 0 then
			local bonusPercent = monsterDamageLevel * 2
			primaryDamage = scaleDamageValue(primaryDamage, bonusPercent, true)
			secondaryDamage = scaleDamageValue(secondaryDamage, bonusPercent, true)
		end
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if not creature:isPlayer() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local protectionLevel = getGuildPerkLevel(getPlayerPerkLevels(creature), 6)
	if protectionLevel <= 0 then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local reductionPercent = protectionLevel * 2
	if bit.band(primaryType or 0, COMBAT_PHYSICALDAMAGE) ~= 0 then
		primaryDamage = scaleDamageValue(primaryDamage, reductionPercent, false)
	end
	if bit.band(secondaryType or 0, COMBAT_PHYSICALDAMAGE) ~= 0 then
		secondaryDamage = scaleDamageValue(secondaryDamage, reductionPercent, false)
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

GuildPerkCombat:register()

local GuildDynastieDefenderDamage = CreatureEvent("GuildDynastieDefenderDamage")

function GuildDynastieDefenderDamage.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not creature:isPlayer() or not attacker or not attacker:isMonster() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if not _G.GuildDynastie_filterDefenderDamage then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	return _G.GuildDynastie_filterDefenderDamage(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end

GuildDynastieDefenderDamage:register()

local GuildPerkTarget = EventCallback

function GuildPerkTarget.onTargetCombat(creature, target)
	if creature and creature:isPlayer() and target and target:isMonster() then
		target:registerEvent("GuildManagementPerkCombat")
	end
	if creature and creature:isMonster() and target and target:isPlayer() and _G.GuildDynastie_canDefenderTarget then
		if not _G.GuildDynastie_canDefenderTarget(creature, target) then
			return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
		end
	end
	return RETURNVALUE_NOERROR
end

GuildPerkTarget:register(7)

local function saveGuildPerks(guildId, perkLevels)
	if not hasColumn("guilds", "perks") then
		return false
	end

	return db.query("UPDATE `guilds` SET `perks` = " .. escape(encodeGuildPerks(perkLevels)) .. " WHERE `id` = " .. guildId)
end

local function sendPerkResult(player, title, text)
	sendGuildPayload(player, "perkResult", { title = title, text = text })
end

local function sendFullGuildState(player)
	sendGuildPayload(player, "config", GuildManagement)

	local guild = player:getGuild()
	local guildId = guild and guild:getId() or 0
	if guildId <= 0 then
		local membership = getPlayerGuildMembership(player:getGuid())
		if membership then
			guildId = membership.guildId
		else
			guildId = getOwnedGuildId(player:getGuid())
		end
	end

	if guildId <= 0 then
		sendGuildPayload(player, "general", nil)
		if GUILD_STORAGE_ENABLED then
			sendGuildPayload(player, "storage", nil)
		end
		sendGuildPayload(player, "top", getTopGuilds(0))
		fetchInbox(player, 0)
		return
	end

	local general = getGuildGeneralData(player, guildId)
	if not general then
		sendGuildPayload(player, "general", nil)
		if GUILD_STORAGE_ENABLED then
			sendGuildPayload(player, "storage", nil)
		end
		sendGuildPayload(player, "top", getTopGuilds(0))
		fetchInbox(player, 0)
		return
	end
	local guildRow = getGuildRowById(guildId) or { guild_level = general.level }
	sendGuildPayload(player, "general", general)
	sendGuildPayload(player, "members", getGuildMembersData(guildId))
	sendGuildPayload(player, "ranks", getGuildRanksData(guildId, general.ownerid))
	local perks = getGuildPerkData(guildRow)
	sendGuildPayload(player, "perkBasic", perks.basic)
	sendGuildPayload(player, "perks", perks.list)
	if GUILD_STORAGE_ENABLED then
		sendGuildPayload(player, "storage", buildGuildStorageData(guildId))
	end
	sendGuildPayload(player, "top", getTopGuilds(0))
	fetchInbox(player, 0)
	sendGuildPayload(player, "selfBalance", { balance = player:getBankBalance(), premiumPoints = getAccountPremiumPoints(player:getAccountId()) })
end

refreshGuildForMembers = function(guildId)
	for _, member in ipairs(getOnlineGuildPlayers(guildId)) do
		applyGuildPerkEffects(member)
		sendFullGuildState(member)
	end
end

refreshDynastieBattleForMembers = function(guildId)
	for _, member in ipairs(getOnlineGuildPlayers(guildId)) do
		local general = getGuildGeneralData(member, guildId)
		sendGuildPayload(member, "general", general)
		fetchInbox(member, 0)
		if GuildDynastie and GuildDynastie.send then
			GuildDynastie.send(member)
		end
	end
end

refreshPrismBattleForMembers = function(guildId, includeStorage)
	for _, member in ipairs(getOnlineGuildPlayers(guildId)) do
		local general = getGuildGeneralData(member, guildId)
		sendGuildPayload(member, "general", general)
		if includeStorage and GUILD_STORAGE_ENABLED then
			sendGuildStorage(member)
		end
		fetchInbox(member, 0)
		sendGuildPrisms(member)
	end
end

local function setPlayerGuild(player, guildId, rankLevel, rankId)
	local guild = getGuildById(guildId)
	if not guild then
		return false
	end
	player:setGuild(guild)
	player:setGuildLevel(rankLevel)
	if rankId and rankId > 0 then
		db.query("UPDATE `guild_membership` SET `rank_id` = " .. rankId .. " WHERE `player_id` = " .. player:getGuid())
	end
	return true
end

local function createGuild(player, data)
	if player:getGuild() then
		return sendGuildError(player, "You are already in a guild.")
	end
	local existingMembership = getPlayerGuildMembership(player:getGuid())
	if existingMembership then
		sendFullGuildState(player)
		return sendGuildError(player, "You are already in a guild.")
	end
	local existingOwnedGuildId = getOwnedGuildId(player:getGuid())
	if existingOwnedGuildId > 0 then
		sendFullGuildState(player)
		return sendGuildError(player, "You already own a guild. Reopen it or relog if it does not appear yet.")
	end

	local name = (data.name or ""):trim()
	if #name < 3 or #name > 24 then
		return sendGuildError(player, "Guild name must contain between 3 and 24 characters.")
	end

	local exists = db.storeQuery("SELECT `id` FROM `guilds` WHERE LOWER(`name`) = LOWER(" .. escape(name) .. ")")
	if exists then
		result.free(exists)
		return sendGuildError(player, "This guild name is already taken.")
	end

	local columns = { "`name`", "`ownerid`", "`motd`" }
	local values = { escape(name), tostring(player:getGuid()), escape("") }
	if hasColumn("guilds", "creationdata") then
		table.insert(columns, "`creationdata`")
		table.insert(values, tostring(os.time()))
	end
	if hasColumn("guilds", "balance") then
		table.insert(columns, "`balance`")
		table.insert(values, "0")
	end
	if hasColumn("guilds", "emblem") then
		table.insert(columns, "`emblem`")
		table.insert(values, escape(tostring(data.emblem or "0")))
	end
	if hasColumn("guilds", "language") then
		table.insert(columns, "`language`")
		table.insert(values, tostring(math.max(1, tonumber(data.lang) or 1)))
	end
	if hasColumn("guilds", "join_status") then
		table.insert(columns, "`join_status`")
		table.insert(values, tostring(math.max(1, tonumber(data.status) or 1)))
	end
	if hasColumn("guilds", "required_level") then
		table.insert(columns, "`required_level`")
		table.insert(values, tostring(math.max(0, tonumber(data.reqLevel) or 0)))
	end
	if hasColumn("guilds", "guild_level") then
		table.insert(columns, "`guild_level`")
		table.insert(values, "1")
	end
	if hasColumn("guilds", "guild_experience") then
		table.insert(columns, "`guild_experience`")
		table.insert(values, "0")
	end
	if hasColumn("guilds", "contribution") then
		table.insert(columns, "`contribution`")
		table.insert(values, "0")
	end
	if hasColumn("guilds", "premium_balance") then
		table.insert(columns, "`premium_balance`")
		table.insert(values, "0")
	end
	if hasColumn("guilds", "premium_contribution") then
		table.insert(columns, "`premium_contribution`")
		table.insert(values, "0")
	end
	if hasColumn("guilds", "dynastie_tokens") then
		table.insert(columns, "`dynastie_tokens`")
		table.insert(values, "0")
	end
	if hasColumn("guilds", "perks") then
		table.insert(columns, "`perks`")
		table.insert(values, escape(encodeGuildPerks(createEmptyGuildPerks())))
	end

	if not db.query("INSERT INTO `guilds` (" .. table.concat(columns, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")") then
		return sendGuildError(player, "Failed to create guild. Please check the database guild schema.")
	end
	local guildId = db.lastInsertId()
	if not guildId or guildId <= 0 then
		return sendGuildError(player, "Failed to create guild. Invalid guild id returned by database.")
	end

	if getGuildRankCount(guildId) == 0 then
		if hasColumn("guild_ranks", "permissions") then
			if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`, `permissions`) VALUES ('a Member', " .. guildId .. ", 1, " ..
				math.pow(2, GuildManagement.PERMISSIONS.DEPOSIT_STORAGE) .. ")") then
				return sendGuildError(player, "Failed to create default guild ranks.")
			end
			if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`, `permissions`) VALUES ('a Vice-Leader', " .. guildId .. ", 2, " ..
				(math.pow(2, GuildManagement.PERMISSIONS.INVITE_MEMBERS) +
				 math.pow(2, GuildManagement.PERMISSIONS.EDIT_MEMBERS) +
				 math.pow(2, GuildManagement.PERMISSIONS.EDIT_SETTINGS) +
				 math.pow(2, GuildManagement.PERMISSIONS.MANAGE_GOLD) +
				 math.pow(2, GuildManagement.PERMISSIONS.MANAGE_PERKS) +
				 math.pow(2, GuildManagement.PERMISSIONS.DEPOSIT_STORAGE) +
				 math.pow(2, GuildManagement.PERMISSIONS.WITHDRAW_STORAGE)) .. ")") then
				return sendGuildError(player, "Failed to create default guild ranks.")
			end
			if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`, `permissions`) VALUES ('the Leader', " .. guildId .. ", 3, -1)") then
				return sendGuildError(player, "Failed to create default guild ranks.")
			end
		else
			if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`) VALUES ('a Member', " .. guildId .. ", 1)") then
				return sendGuildError(player, "Failed to create default guild ranks.")
			end
			if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`) VALUES ('a Vice-Leader', " .. guildId .. ", 2)") then
				return sendGuildError(player, "Failed to create default guild ranks.")
			end
			if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`) VALUES ('the Leader', " .. guildId .. ", 3)") then
				return sendGuildError(player, "Failed to create default guild ranks.")
			end
		end
	end

	normalizeLegacyGuildDefaultRanks(guildId)

	local leaderRankId = getGuildRankIdByLevel(guildId, 3)
	if not leaderRankId or leaderRankId <= 0 then
		return sendGuildError(player, "Failed to create guild leader rank.")
	end
	if not db.query("INSERT INTO `guild_membership` (`player_id`, `guild_id`, `rank_id`, `nick`) VALUES (" .. player:getGuid() .. ", " .. guildId .. ", " .. leaderRankId .. ", '')") then
		return sendGuildError(player, "Failed to add the guild owner to the new guild.")
	end
	setPlayerGuild(player, guildId, 3, leaderRankId)
	applyGuildPerkEffects(player)
	broadcastCreatureGuildTitle(player, guildId, 3)
	sendFullGuildState(player)
end

local function invitePlayerToGuild(player, targetName)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.INVITE_MEMBERS) then
		return sendGuildError(player, "You do not have permission to invite members.")
	end

	local resultId = db.storeQuery("SELECT `id`, `level`, `name` FROM `players` WHERE LOWER(`name`) = LOWER(" .. escape(targetName) .. ")")
	if not resultId then
		return sendGuildError(player, "Player not found.")
	end

	local targetId = result.getNumber(resultId, "id")
	local targetLevel = result.getNumber(resultId, "level")
	local targetNameResolved = result.getString(resultId, "name")
	result.free(resultId)

	if getPlayerGuildMembership(targetId) then
		return sendGuildError(player, "This player already belongs to a guild.")
	end

	local guildRow = getGuildRowById(guild:getId())
	db.query("INSERT IGNORE INTO `guild_invites` (`player_id`, `guild_id`) VALUES (" .. targetId .. ", " .. guild:getId() .. ")")
	addGuildMessage(targetId, guild:getId(), GuildManagement.MESSAGE_TYPES.JOIN_INVITATION, player:getName() .. " invited you to join {" .. guild:getName() .. "}.", targetId, guild:getId())
	sendGuildError(player, "Invitation sent to " .. targetNameResolved .. ".")
end

local function requestJoinGuild(player, guildId)
	if player:getGuild() then
		return sendGuildError(player, "You are already in a guild.")
	end

	local guildRow = getGuildRowById(guildId)
	if not guildRow then
		return sendGuildError(player, "Guild not found.")
	end
	if guildRow.join_status ~= 1 then
		return sendGuildError(player, "This guild is invite only.")
	end
	if player:getLevel() < guildRow.required_level then
		return sendGuildError(player, "You do not meet the required level.")
	end
	if getGuildMemberCount(guildId) >= getGuildMemberLimit(guildRow.guild_level, decodeGuildPerks(guildRow.perks)) then
		return sendGuildError(player, "This guild is full.")
	end

	addGuildMessage(guildRow.ownerid, guildId, GuildManagement.MESSAGE_TYPES.JOIN_REQUEST, player:getName() .. " requested to join {" .. guildRow.name .. "}.", player:getGuid(), guildId)
	sendGuildError(player, "Join request sent.")
end

local function joinGuild(player, guildId)
	local guildRow = getGuildRowById(guildId)
	if not guildRow then
		return false, "Guild not found."
	end
	if getPlayerGuildMembership(player:getGuid()) then
		return false, "You are already in a guild."
	end
	if getGuildMemberCount(guildId) >= getGuildMemberLimit(guildRow.guild_level, decodeGuildPerks(guildRow.perks)) then
		return false, "This guild is full."
	end

	local memberRankId = getGuildRankIdByLevel(guildId, 1)
	db.query("DELETE FROM `guild_invites` WHERE `player_id` = " .. player:getGuid())
	db.query("INSERT INTO `guild_membership` (`player_id`, `guild_id`, `rank_id`, `nick`) VALUES (" .. player:getGuid() .. ", " .. guildId .. ", " .. memberRankId .. ", '')")
	setPlayerGuild(player, guildId, 1, memberRankId)
	applyGuildPerkEffects(player)
	if GuildAchievements and GuildAchievements.syncPlayerCosmetics then
		GuildAchievements.syncPlayerCosmetics(player)
	end
	broadcastCreatureGuildTitle(player, guildId, 1)

	local member = {
		name = player:getName(),
		level = player:getLevel(),
		proficiencyLevel = player:getLevel(),
		voc = player:getVocation():getId(),
		rank = "Member",
		online = true,
		last = os.time(),
		contribution = 0,
		nick = ""
	}
	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guildId)) do
		if guildPlayer:getGuid() ~= player:getGuid() then
			local totalLevels = select(1, getGuildTotalLevels(guildId))
			sendGuildPayload(guildPlayer, "joined", {
				member = member,
				levels = totalLevels,
				members = { getGuildMemberCount(guildId), getGuildMemberLimit(guildRow.guild_level, decodeGuildPerks(guildRow.perks)) }
			})
		end
	end

	addGuildMessages(
		getGuildInboxRecipients(guildId),
		guildId,
		GuildManagement.MESSAGE_TYPES.MEMBER_JOINED,
		player:getName() .. " has joined {" .. guildRow.name .. "}.",
		player:getGuid(),
		guildId
	)

	return true
end

local function removeMemberFromGuild(targetId, guildId)
	db.query("DELETE FROM `guild_membership` WHERE `player_id` = " .. targetId .. " AND `guild_id` = " .. guildId)
	local targetPlayer = Player(targetId)
	if targetPlayer and targetPlayer:getGuild() and targetPlayer:getGuild():getId() == guildId then
		targetPlayer:setGuild(nil)
		clearGuildPerkEffects(targetPlayer)
		if GuildAchievements and GuildAchievements.syncPlayerCosmetics then
			GuildAchievements.syncPlayerCosmetics(targetPlayer)
		end
		broadcastCreatureGuildTitle(targetPlayer, 0, 0)
		sendGuildPayload(targetPlayer, "left", {})
	end
end

local function handleAccept(player, data)
	if data.type == GuildManagement.MESSAGE_TYPES.JOIN_INVITATION then
		local ok, err = joinGuild(player, tonumber(data.guildId) or 0)
		if not ok then
			return sendGuildError(player, err)
		end
	elseif data.type == GuildManagement.MESSAGE_TYPES.JOIN_REQUEST then
		local guild = player:getGuild()
		if not guild then
			return sendGuildError(player, "You are not in a guild.")
		end
		if not hasPermission(player, GuildManagement.PERMISSIONS.INVITE_MEMBERS) then
			return sendGuildError(player, "You do not have permission to manage requests.")
		end
		local targetPlayer = Player(tonumber(data.targetId) or 0)
		if not targetPlayer then
			return sendGuildError(player, "Requested player must be online to accept the invitation right now.")
		end
		local ok, err = joinGuild(targetPlayer, guild:getId())
		if not ok then
			return sendGuildError(player, err)
		end
		sendGuildPayload(targetPlayer, "finished", data.id)
	end

	finishGuildMessage(data.id)
	sendGuildPayload(player, "finished", data.id)
	refreshGuildForMembers(player:getGuild() and player:getGuild():getId() or tonumber(data.guildId) or 0)
end

local function handleReject(player, data)
	if data.type == GuildManagement.MESSAGE_TYPES.JOIN_INVITATION then
		db.query("DELETE FROM `guild_invites` WHERE `player_id` = " .. player:getGuid() .. " AND `guild_id` = " .. (tonumber(data.guildId) or 0))
	end
	finishGuildMessage(data.id)
	sendGuildPayload(player, "finished", data.id)
end

local function kickGuildMember(player, targetName)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.EDIT_MEMBERS) then
		return sendGuildError(player, "You do not have permission to kick members.")
	end

	local resultId = db.storeQuery("SELECT `p`.`id`, `p`.`name` FROM `players` `p` INNER JOIN `guild_membership` `gm` ON `gm`.`player_id` = `p`.`id` WHERE LOWER(`p`.`name`) = LOWER(" .. escape(targetName) .. ") AND `gm`.`guild_id` = " .. guild:getId())
	if not resultId then
		return sendGuildError(player, "Guild member not found.")
	end

	local targetId = result.getNumber(resultId, "id")
	local resolvedName = result.getString(resultId, "name")
	result.free(resultId)

	if targetId == player:getGuid() then
		return sendGuildError(player, "Use leave instead.")
	end

	removeMemberFromGuild(targetId, guild:getId())
	addGuildMessage(targetId, guild:getId(), GuildManagement.MESSAGE_TYPES.KICKED_OUT, "You were removed from {" .. guild:getName() .. "}.", targetId, guild:getId())
	addGuildMessages(
		getGuildInboxRecipients(guild:getId()),
		guild:getId(),
		GuildManagement.MESSAGE_TYPES.MEMBER_LEFT,
		resolvedName .. " was removed from {" .. guild:getName() .. "}.",
		targetId,
		guild:getId()
	)

	local guildRow = getGuildRowById(guild:getId())
	local totalLevels = select(1, getGuildTotalLevels(guild:getId()))
	local members = { getGuildMemberCount(guild:getId()), getGuildMemberLimit(guildRow.guild_level, decodeGuildPerks(guildRow.perks)) }
	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		sendGuildPayload(guildPlayer, "kicked", { name = resolvedName, levels = totalLevels, members = members })
	end
end

local function leaveGuild(player)
	local guild = player:getGuild()
	local guildId = guild and guild:getId() or resolvePlayerGuildId(player)
	if guildId <= 0 then
		return sendGuildError(player, "You are not in a guild.")
	end

	local guildRow = getGuildRowById(guildId)
	if not guildRow then
		return sendGuildError(player, "Your guild could not be loaded.")
	end
	if not guild then
		guild = getGuildById(guildId)
	end
	local guildName = (guild and guild.getName and guild:getName()) or guildRow.name or "Unknown Guild"
	if guildRow.ownerid == player:getGuid() then
		local activeDynastieCount = getGuildActiveDynastieCount(guildId)
		if activeDynastieCount > 0 then
			return sendGuildError(player, "You cannot disband a guild that owns a dynastie core. Collect all active dynastie cores first.")
		end

		local activePrismCount = getGuildActivePrismCount(guildId)
		if activePrismCount > 0 then
			return sendGuildError(player, "You cannot disband a guild that owns an active prism. Collect or remove all active prisms first.")
		end

		local storageItemCount = getGuildStorageItemCount(guildId)
		if storageItemCount > 0 then
			return sendGuildError(player, "You cannot disband a guild while items remain in guild storage. Remove all storage items first.")
		end

		for _, guildPlayer in ipairs(getOnlineGuildPlayers(guildId)) do
			if guildPlayer:getGuid() ~= player:getGuid() then
				guildPlayer:setGuild(nil)
				if GuildAchievements and GuildAchievements.syncPlayerCosmetics then
					GuildAchievements.syncPlayerCosmetics(guildPlayer)
				end
				broadcastCreatureGuildTitle(guildPlayer, 0, 0)
				sendGuildPayload(guildPlayer, "disbanded", {})
			end
		end
		db.query("DELETE FROM `guild_membership` WHERE `guild_id` = " .. guildId)
		db.query("DELETE FROM `guild_invites` WHERE `guild_id` = " .. guildId)
		db.query("DELETE FROM `guild_messages` WHERE `guild_id` = " .. guildId .. " OR `source_guild_id` = " .. guildId)
		db.query("DELETE FROM `guild_ranks` WHERE `guild_id` = " .. guildId)
		cleanupDisbandedGuildData(guildId)
		db.query("DELETE FROM `guilds` WHERE `id` = " .. guildId)
		player:setGuild(nil)
		clearGuildPerkEffects(player)
		if GuildAchievements and GuildAchievements.syncPlayerCosmetics then
			GuildAchievements.syncPlayerCosmetics(player)
		end
		broadcastCreatureGuildTitle(player, 0, 0)
		sendGuildPayload(player, "disbanded", {})
		return
	end

	removeMemberFromGuild(player:getGuid(), guildId)
	addGuildMessages(
		getGuildInboxRecipients(guildId),
		guildId,
		GuildManagement.MESSAGE_TYPES.MEMBER_LEFT,
		player:getName() .. " has left {" .. guildName .. "}.",
		player:getGuid(),
		guildId
	)
	local members = { getGuildMemberCount(guildId), getGuildMemberLimit(guildRow.guild_level, decodeGuildPerks(guildRow.perks)) }
	local totalLevels = select(1, getGuildTotalLevels(guildId))
	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guildId)) do
		sendGuildPayload(guildPlayer, "kicked", { name = player:getName(), levels = totalLevels, members = members })
	end
end

local function updateGuildSettings(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.EDIT_SETTINGS) then
		return sendGuildError(player, "You do not have permission to edit settings.")
	end

	local updates = { "`motd` = " .. escape(data.motd or "") }
	if hasColumn("guilds", "join_status") then
		table.insert(updates, "`join_status` = " .. math.max(1, tonumber(data.status) or 1))
	end
	if hasColumn("guilds", "required_level") then
		table.insert(updates, "`required_level` = " .. math.max(0, tonumber(data.reqLevel) or 0))
	end
	if hasColumn("guilds", "language") then
		table.insert(updates, "`language` = " .. math.max(1, tonumber(data.language) or 1))
	end
	if hasColumn("guilds", "emblem") then
		table.insert(updates, "`emblem` = " .. escape(tostring(data.emblem or "0")))
	end
	db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId())

	local payload = {
		status = math.max(1, tonumber(data.status) or 1),
		reqLevel = math.max(0, tonumber(data.reqLevel) or 0),
		language = math.max(1, tonumber(data.language) or 1),
		emblem = tonumber(data.emblem) or tostring(data.emblem or "0"),
		motd = data.motd or ""
	}
	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		sendGuildPayload(guildPlayer, "settings", payload)
	end
end

local function saveRanks(player, ranks)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.EDIT_ROLES) then
		return sendGuildError(player, "You do not have permission to edit ranks.")
	end

	local defaultRankId = 0
	for _, rank in ipairs(ranks) do
		if rank.default and not rank.removed then
			defaultRankId = tonumber(rank.id) or 0
			break
		end
	end

	if defaultRankId == 0 then
		defaultRankId = getGuildDefaultRankId(guild:getId())
	end

	local saveFailed = false

	for _, rank in ipairs(ranks) do
		if not rank.leader then
			if rank.removed and rank.id == 0 then
				-- New unsaved rank removed on client side, nothing to persist.
			elseif rank.removed and rank.id > 0 then
				if defaultRankId > 0 then
					if not db.query("UPDATE `guild_membership` SET `rank_id` = " .. defaultRankId .. " WHERE `guild_id` = " .. guild:getId() .. " AND `rank_id` = " .. rank.id) then
						saveFailed = true
					end
				end
				if not db.query("DELETE FROM `guild_ranks` WHERE `id` = " .. rank.id .. " AND `guild_id` = " .. guild:getId()) then
					saveFailed = true
				end
			elseif rank.id == 0 then
				local level = rank.default and 1 or 2
				if hasColumn("guild_ranks", "permissions") then
					if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`, `permissions`) VALUES (" .. escape(rank.name) .. ", " .. guild:getId() .. ", " .. level .. ", " .. tonumber(rank.permissions or 0) .. ")") then
						saveFailed = true
					else
						rank.id = db.lastInsertId()
					end
				else
					if not db.query("INSERT INTO `guild_ranks` (`name`, `guild_id`, `level`) VALUES (" .. escape(rank.name) .. ", " .. guild:getId() .. ", " .. level .. ")") then
						saveFailed = true
					else
						rank.id = db.lastInsertId()
					end
				end
			else
				local level = rank.default and 1 or 2
				if hasColumn("guild_ranks", "permissions") then
					if not db.query("UPDATE `guild_ranks` SET `name` = " .. escape(rank.name) .. ", `level` = " .. level .. ", `permissions` = " .. tonumber(rank.permissions or 0) .. " WHERE `id` = " .. rank.id .. " AND `guild_id` = " .. guild:getId()) then
						saveFailed = true
					end
				else
					if not db.query("UPDATE `guild_ranks` SET `name` = " .. escape(rank.name) .. ", `level` = " .. level .. " WHERE `id` = " .. rank.id .. " AND `guild_id` = " .. guild:getId()) then
						saveFailed = true
					end
				end
			end
		end
	end

	if saveFailed then
		return sendGuildError(player, "Failed to save guild ranks.")
	end

end

local function setMemberRank(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.EDIT_MEMBERS) then
		return sendGuildError(player, "You do not have permission to set ranks.")
	end

	local rankId = tonumber(data.rankId) or 0
	local rank = guild:getRankById(rankId)
	if not rank then
		return sendGuildError(player, "Rank not found.")
	end

	local resultId = db.storeQuery("SELECT `p`.`id`, `p`.`name` FROM `players` `p` INNER JOIN `guild_membership` `gm` ON `gm`.`player_id` = `p`.`id` WHERE LOWER(`p`.`name`) = LOWER(" .. escape(data.name or "") .. ") AND `gm`.`guild_id` = " .. guild:getId())
	if not resultId then
		return sendGuildError(player, "Guild member not found.")
	end
	local targetId = result.getNumber(resultId, "id")
	local targetName = result.getString(resultId, "name")
	result.free(resultId)

	db.query("UPDATE `guild_membership` SET `rank_id` = " .. rankId .. " WHERE `player_id` = " .. targetId .. " AND `guild_id` = " .. guild:getId())
	local targetPlayer = Player(targetId)
	if targetPlayer and targetPlayer:getGuild() and targetPlayer:getGuild():getId() == guild:getId() then
		targetPlayer:setGuildLevel(rank.level)
		broadcastCreatureGuildTitle(targetPlayer, guild:getId(), rank.level)
	end

	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		sendGuildPayload(guildPlayer, "memberRank", { name = targetName, rank = rank.name })
		if guildPlayer:getGuid() == targetId then
			local guildRow = getGuildRowById(guild:getId())
			sendGuildPayload(guildPlayer, "perms", getGuildRankPermissions(rankId, guildRow.ownerid, targetId))
		end
	end
end

local function updateSelfBalance(player)
	sendGuildPayload(player, "selfBalance", { balance = player:getBankBalance(), premiumPoints = getAccountPremiumPoints(player:getAccountId()) })
end

calculateGuildLevelProgress = function(currentLevel, currentExp)
	local level = math.max(1, tonumber(currentLevel) or 1)
	local exp = math.max(0, tonumber(currentExp) or 0)
	local leveled = false

	while true do
		local requiredExp = math.max(GuildManagement.NEXT_LEVEL_BASE, level * GuildManagement.NEXT_LEVEL_BASE)
		if exp < requiredExp then
			return level, exp, requiredExp, leveled
		end

		exp = exp - requiredExp
		level = level + 1
		leveled = true
	end
end

local function donateToGuild(player, amount)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	amount = tonumber(amount) or 0
	if amount <= 0 then
		return sendGuildError(player, "Invalid amount.")
	end
	if player:getBankBalance() < amount then
		return sendGuildError(player, "You do not have enough gold in your bank account.")
	end

	player:setBankBalance(player:getBankBalance() - amount)
	local guildRow = getGuildRowById(guild:getId())
	local newBalance = guildRow.balance + amount
	local newContribution = guildRow.contribution + amount
	local updates = {}
	if hasColumn("guilds", "balance") then
		table.insert(updates, "`balance` = " .. newBalance)
	end
	if hasColumn("guilds", "contribution") then
		table.insert(updates, "`contribution` = " .. newContribution)
	end
	if #updates > 0 then
		db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId())
	end
	awardGuildQuestExperience(guild:getId(), gainedExp)
	awardGuildQuestPremiumDonation(guild:getId(), amount)

	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		sendGuildPayload(guildPlayer, "balance", { balance = newBalance })
		sendGuildPayload(guildPlayer, "contribution", newContribution)
	end

	addGuildMessages(
		getGuildInboxRecipients(guild:getId()),
		guild:getId(),
		GuildManagement.MESSAGE_TYPES.GOLD_DEPOSIT,
		player:getName() .. " deposited {" .. amount .. "} gold into {" .. guild:getName() .. "}.",
		player:getGuid(),
		guild:getId()
	)
	addContributionHistoryEntry(guild:getId(), player:getGuid(), player:getName(), amount, 1)
	awardGuildQuestGoldDonation(guild:getId(), amount)
	updateSelfBalance(player)
end

local function donatePremiumToGuild(player, amount)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasColumn("guilds", "premium_balance") or not hasColumn("guilds", "premium_contribution") then
		return sendGuildError(player, "Guild premium schema is missing. Run migration 50 first.")
	end

	amount = tonumber(amount) or 0
	if amount <= 0 then
		return sendGuildError(player, "Invalid amount.")
	end

	local accountId = player:getAccountId()
	local premiumPoints = getAccountPremiumPoints(accountId)
	if premiumPoints < amount then
		return sendGuildError(player, "You do not have enough premium points.")
	end

	if not setAccountPremiumPoints(accountId, premiumPoints - amount) then
		return sendGuildError(player, "Failed to update your premium points.")
	end

	local guildRow = getGuildRowById(guild:getId())
	local newPremiumBalance = (tonumber(guildRow.premium_balance) or 0) + amount
	local gainedExp = amount * GuildManagement.PREMIUM_POINT_EXP
	local rawExp = (tonumber(guildRow.guild_experience) or 0) + gainedExp
	local newLevel, newExp, nextRequiredExp, leveledUp = calculateGuildLevelProgress(guildRow.guild_level, rawExp)
	local newPremiumContribution = (tonumber(guildRow.premium_contribution) or 0) + amount
	local updates = {}

	if hasColumn("guilds", "premium_balance") then
		table.insert(updates, "`premium_balance` = " .. newPremiumBalance)
	end
	if hasColumn("guilds", "guild_level") then
		table.insert(updates, "`guild_level` = " .. newLevel)
	end
	if hasColumn("guilds", "guild_experience") then
		table.insert(updates, "`guild_experience` = " .. newExp)
	end
	if hasColumn("guilds", "premium_contribution") then
		table.insert(updates, "`premium_contribution` = " .. newPremiumContribution)
	end

	if #updates > 0 then
		db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId())
	end

	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		sendGuildPayload(guildPlayer, "premiumBalance", { balance = newPremiumBalance })
		sendGuildPayload(guildPlayer, "gold", { exp = newExp, next = nextRequiredExp })
		sendGuildPayload(guildPlayer, "premiumContribution", newPremiumContribution)
		if leveledUp then
			sendGuildPayload(guildPlayer, "level", {
				level = newLevel,
				members = { getGuildMemberCount(guild:getId()), getGuildMemberLimit(newLevel, decodeGuildPerks(guildRow.perks)) },
				gold = tonumber(guildRow.contribution) or 0,
				premiumContribution = newPremiumContribution,
				exp = newExp,
				next = nextRequiredExp
			})
		end
	end

	addGuildMessages(
		getGuildInboxRecipients(guild:getId()),
		guild:getId(),
		GuildManagement.MESSAGE_TYPES.GOLD_DEPOSIT,
		player:getName() .. " deposited {" .. amount .. "} premium points into {" .. guild:getName() .. "}.",
		player:getGuid(),
		guild:getId()
	)
	addContributionHistoryEntry(guild:getId(), player:getGuid(), player:getName(), amount, 3)
	updateSelfBalance(player)
	if leveledUp then
		refreshGuildPerkState(guild:getId())
	end
end

local function levelUpGuild(player)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.MANAGE_GOLD) then
		return sendGuildError(player, "You do not have permission to level up the guild.")
	end

	local guildRow = getGuildRowById(guild:getId())
	if not guildRow then
		return sendGuildError(player, "Guild data could not be loaded.")
	end

	local currentLevel = tonumber(guildRow.guild_level) or 1
	local currentExp = tonumber(guildRow.guild_experience) or 0
	local requiredExp = math.max(GuildManagement.NEXT_LEVEL_BASE, currentLevel * GuildManagement.NEXT_LEVEL_BASE)

	if currentExp < requiredExp then
		return sendGuildError(player, "The guild does not have enough experience to level up.")
	end

	local newLevel = currentLevel + 1
	local newExp = currentExp - requiredExp
	local updates = {}

	if hasColumn("guilds", "guild_level") then
		table.insert(updates, "`guild_level` = " .. newLevel)
	end
	if hasColumn("guilds", "guild_experience") then
		table.insert(updates, "`guild_experience` = " .. newExp)
	end

	if #updates > 0 and not db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId()) then
		return sendGuildError(player, "Failed to level up the guild.")
	end

local members = { getGuildMemberCount(guild:getId()), getGuildMemberLimit(newLevel, decodeGuildPerks(guildRow.perks)) }
	local nextRequiredExp = math.max(GuildManagement.NEXT_LEVEL_BASE, newLevel * GuildManagement.NEXT_LEVEL_BASE)
	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		sendGuildPayload(guildPlayer, "level", {
			level = newLevel,
			members = members,
			gold = tonumber(guildRow.contribution) or 0,
			exp = newExp,
			next = nextRequiredExp
		})
	end

	refreshGuildPerkState(guild:getId())
end

local function withdrawFromGuild(player, amount)
	return sendGuildError(player, "Guild gold withdraw is disabled.")
end

local function passLeader(player, targetName)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end

	local guildRow = getGuildRowById(guild:getId())
	if not guildRow then
		return sendGuildError(player, "Guild data could not be loaded.")
	end

	if guildRow.ownerid ~= player:getGuid() then
		return sendGuildError(player, "Only the guild leader can pass leadership.")
	end

	local targetResult = db.storeQuery("SELECT `p`.`id`, `p`.`name` FROM `players` `p` INNER JOIN `guild_membership` `gm` ON `gm`.`player_id` = `p`.`id` WHERE LOWER(`p`.`name`) = LOWER(" .. escape(targetName or "") .. ") AND `gm`.`guild_id` = " .. guild:getId() .. " LIMIT 1")
	if not targetResult then
		return sendGuildError(player, "Guild member not found.")
	end

	local targetId = result.getNumber(targetResult, "id")
	local targetNameResolved = result.getString(targetResult, "name")
	result.free(targetResult)

	if targetId == player:getGuid() then
		return sendGuildError(player, "You are already the guild leader.")
	end

	local leaderRank = getGuildRankRowByLevel(guild:getId(), 3)
	local defaultRank = getGuildRankRowByLevel(guild:getId(), 1)
	if not leaderRank or not defaultRank then
		return sendGuildError(player, "Guild ranks could not be loaded.")
	end

	if not db.query("UPDATE `guild_membership` SET `rank_id` = " .. leaderRank.id .. " WHERE `player_id` = " .. targetId .. " AND `guild_id` = " .. guild:getId()) then
		return sendGuildError(player, "Failed to promote the new guild leader.")
	end
	if not db.query("UPDATE `guild_membership` SET `rank_id` = " .. defaultRank.id .. " WHERE `player_id` = " .. player:getGuid() .. " AND `guild_id` = " .. guild:getId()) then
		return sendGuildError(player, "Failed to update the old guild leader rank.")
	end
	if not db.query("UPDATE `guilds` SET `ownerid` = " .. targetId .. " WHERE `id` = " .. guild:getId()) then
		return sendGuildError(player, "Failed to pass guild leadership.")
	end

	local oldLeaderName = player:getName()
	local targetPlayer = Player(targetId)
	if targetPlayer and targetPlayer:getGuild() and targetPlayer:getGuild():getId() == guild:getId() then
		targetPlayer:setGuildLevel(leaderRank.level)
		broadcastCreatureGuildTitle(targetPlayer, guild:getId(), leaderRank.level)
	end
	player:setGuildLevel(defaultRank.level)
	broadcastCreatureGuildTitle(player, guild:getId(), defaultRank.level)

	local payload = {
		newLeader = targetNameResolved,
		newLeaderRank = leaderRank.name,
		oldLeader = oldLeaderName,
		oldLeaderRank = defaultRank.name
	}

	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		sendGuildPayload(guildPlayer, "newLeader", payload)
	end
	sendGuildPayload(player, "perms", getGuildRankPermissions(defaultRank.id, targetId, player:getGuid()))
	if targetPlayer then
		sendGuildPayload(targetPlayer, "perms", getGuildRankPermissions(leaderRank.id, targetId, targetId))
	end

	refreshGuildForMembers(guild:getId())
end

refreshGuildPerkState = function(guildId)
	refreshGuildPerksForGuild(guildId)
	refreshGuildForMembers(guildId)
end

local function unlockGuildPerk(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.MANAGE_PERKS) then
		return sendGuildError(player, "You do not have permission to manage perks.")
	end
	if not hasColumn("guilds", "perks") then
		return sendGuildError(player, "Guild perks schema is missing. Run the latest migration first.")
	end

	local perkId = tonumber(data and data.perkId) or 0
	local perk = getPerkDefinition(perkId)
	if not perk then
		return sendGuildError(player, "Invalid perk.")
	end

	local perkLevels, guildRow = getGuildPerkLevelsByGuildId(guild:getId())
	if not guildRow then
		return sendGuildError(player, "Guild data could not be loaded.")
	end

	local currentLevel = getGuildPerkLevel(perkLevels, perkId)
	if currentLevel >= perk.maxLevel then
		return sendPerkResult(player, "Perk Upgrade Result", "This perk has already reached the maximum level.")
	end

	local guildLevel = tonumber(guildRow.guild_level) or 1
	if guildLevel < perk.rlevel then
		return sendPerkResult(player, "Perk Upgrade Result", "Your guild does not have the required level for the upgrade. (Lv. " .. perk.rlevel .. ")")
	end

	local cost = (perk.costBase or 0) * (currentLevel + 1)
	local premiumCost = (perk.premiumPointsBase or 0) * (currentLevel + 1)
	local balance = tonumber(guildRow.balance) or 0
	local premiumBalance = tonumber(guildRow.premium_balance) or 0
	if premiumCost > 0 and not hasColumn("guilds", "premium_balance") then
		return sendGuildError(player, "Guild premium schema is missing. Run migration 50 first.")
	end
	if premiumCost > 0 and premiumBalance < premiumCost then
		return sendPerkResult(player, "Perk Upgrade Result", "The guild does not have enough premium points.")
	end
	if premiumCost <= 0 and balance < cost then
		return sendPerkResult(player, "Perk Upgrade Result", "The guild does not have enough gold.")
	end

	perkLevels[tostring(perkId)] = currentLevel + 1
	if not saveGuildPerks(guild:getId(), perkLevels) then
		return sendGuildError(player, "Failed to save guild perks.")
	end
	local balanceUpdates = {}
	if premiumCost > 0 then
		if hasColumn("guilds", "premium_balance") then
			table.insert(balanceUpdates, "`premium_balance` = " .. (premiumBalance - premiumCost))
		end
	else
		if hasColumn("guilds", "balance") then
			table.insert(balanceUpdates, "`balance` = " .. (balance - cost))
		end
	end
	if #balanceUpdates > 0 and not db.query("UPDATE `guilds` SET " .. table.concat(balanceUpdates, ", ") .. " WHERE `id` = " .. guild:getId()) then
		return sendGuildError(player, "Failed to update guild balance.")
	end

	local newGoldBalance = balance
	local newPremiumBalance = premiumBalance
	if premiumCost > 0 then
		newPremiumBalance = premiumBalance - premiumCost
	else
		newGoldBalance = balance - cost
	end

	for _, guildPlayer in ipairs(getOnlineGuildPlayers(guild:getId())) do
		if premiumCost > 0 then
			sendGuildPayload(guildPlayer, "premiumBalance", { balance = newPremiumBalance })
		else
			sendGuildPayload(guildPlayer, "balance", { balance = newGoldBalance })
		end
	end

	sendPerkResult(player, "Perk Upgrade Result", perk.name .. " upgraded to level " .. (currentLevel + 1) .. ".")
	refreshGuildPerkState(guild:getId())
end

local function resetGuildPerks(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.MANAGE_PERKS) then
		return sendGuildError(player, "You do not have permission to manage perks.")
	end
	if not hasColumn("guilds", "perks") then
		return sendGuildError(player, "Guild perks schema is missing. Run the latest migration first.")
	end

	local perkLevels = getGuildPerkLevelsByGuildId(guild:getId())
	local perkId = data and data.perkId or "all"
	local changed = false
	local resultText = "All guild perks have been reset to level 0."
	local storageHasItems = getGuildStorageItemCount(guild:getId()) > 0

	if perkId == "all" then
		if storageHasItems and getGuildPerkLevel(perkLevels, 7) > 0 then
			return sendPerkResult(player, "Perk Reset Result", "Guild storage must be empty before resetting Storage Expansion.")
		end
		if getGuildActivePrismCount(guild:getId()) > 0 and getGuildPerkLevel(perkLevels, 9) > 0 then
			return sendPerkResult(player, "Perk Reset Result", "All prisms must be removed before resetting Prism Capacity.")
		end
		for _, perk in ipairs(GuildManagement.PERKS) do
			if getGuildPerkLevel(perkLevels, perk.id) > 0 then
				perkLevels[tostring(perk.id)] = 0
				changed = true
			end
		end
	else
		local numericPerkId = tonumber(perkId) or 0
		local perk = getPerkDefinition(numericPerkId)
		if not perk then
			return sendGuildError(player, "Invalid perk.")
		end
		if numericPerkId == 7 and storageHasItems then
			return sendPerkResult(player, "Perk Reset Result", "Guild storage must be empty before resetting Storage Expansion.")
		end
		if numericPerkId == 9 and getGuildActivePrismCount(guild:getId()) > 0 then
			return sendPerkResult(player, "Perk Reset Result", "All prisms must be removed before resetting Prism Capacity.")
		end
		if getGuildPerkLevel(perkLevels, numericPerkId) > 0 then
			perkLevels[tostring(numericPerkId)] = 0
			changed = true
			resultText = perk.name .. " has been reset to level 0."
		end
	end

	if not changed then
		return sendPerkResult(player, "Perk Reset Result", "The selected perk is already at level 0.")
	end

	if not saveGuildPerks(guild:getId(), perkLevels) then
		return sendGuildError(player, "Failed to save guild perks.")
	end

	sendPerkResult(player, "Perk Reset Result", resultText)
	refreshGuildPerkState(guild:getId())
end

local function sendContributionHistory(player)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end

	sendGuildPayload(player, "contributionhistory", getContributionHistory(guild:getId()))
end

local function getFirstFreeStorageSlot(guildId, capacity, currentRows)
	currentRows = currentRows or getGuildStorageRows(guildId)
	for slot = 1, capacity do
		if not currentRows[slot] then
			return slot
		end
	end

	return 0
end

local function resolvePlayerStorageSourceItem(player, entry)
	if not player or type(entry) ~= "table" or type(entry.position) ~= "table" then
		return nil
	end

	local position = {
		x = tonumber(entry.position.x) or 0,
		y = tonumber(entry.position.y) or 0,
		z = tonumber(entry.position.z) or 0,
		stackpos = tonumber(entry.stackPos or entry.position.stackpos) or 0
	}

	if position.x == 0 and position.y == 0 and position.z == 0 then
		return nil
	end

	return player:getItem(position)
end

serializeStorageItemAttributes = function(item)
	if not item or not item.serializeAttributes then
		return ""
	end

	local ok, blob = pcall(function()
		return item:serializeAttributes()
	end)

	if not ok or type(blob) ~= "string" then
		return ""
	end

	return blob
end

getPrismRarityBonus = function(player)
	if not player then
		return 0
	end

	local total = 0
	for _, storageId in ipairs(PRISM_RARITY_BONUS_STORAGES) do
		local value = tonumber(player:getStorageValue(storageId)) or 0
		if value > 0 then
			total = total + value
		end
	end
	return total
end

rollPrismRarity = function(player)
	local bonus = getPrismRarityBonus(player)
	local baseChance = math.min(100, PRISM_RARITY_BASE_CHANCE + bonus)
	if math.random(100) > baseChance then
		return 0
	end

	for _, rarity in ipairs(PRISM_RARITIES) do
		local finalChance = math.min(100, tonumber(rarity.chance or 0) + (bonus * 0.5))
		if math.random(100) <= finalChance then
			return rarity.id
		end
	end

	return 0
end

local function giveStorageItemsToPlayer(player, itemId, amount, attributes)
	local itemType = ItemType(itemId)
	if not itemType or itemType:getId() == 0 then
		return false, "Invalid stored item."
	end

	if itemType:isStackable() then
		local created = {}
		local remaining = math.max(1, math.floor(tonumber(amount) or 1))

		while remaining > 0 do
			local chunkAmount = math.min(remaining, GUILD_ITEM_STACK_LIMIT)
			local item = Game.createItem(itemId, chunkAmount)
			if not item then
				for _, createdItem in ipairs(created) do
					createdItem:remove()
				end
				return false, "Failed to create the selected item."
			end

			if type(attributes) == "string" and attributes ~= "" and item.applyAttributes then
				item:applyAttributes(attributes)
				item:transform(itemId, chunkAmount)
			end

			local ret = player:addItemEx(item, true)
			if ret ~= RETURNVALUE_NOERROR then
				item:remove()
				for _, createdItem in ipairs(created) do
					createdItem:remove()
				end
				return false, Game.getReturnMessage(ret)
			end

			table.insert(created, item)
			remaining = remaining - chunkAmount
		end

		return true
	elseif amount <= 1 then
		local item = Game.createItem(itemId, 1)
		if not item then
			return false, "Failed to create the selected item."
		end

		if type(attributes) == "string" and attributes ~= "" and item.applyAttributes then
			item:applyAttributes(attributes)
		end

		local ret = player:addItemEx(item, true)
		if ret ~= RETURNVALUE_NOERROR then
			item:remove()
			return false, Game.getReturnMessage(ret)
		end

		return true
	end

	local created = {}
	for _ = 1, amount do
		local item = Game.createItem(itemId, 1)
		if not item then
			for _, createdItem in ipairs(created) do
				createdItem:remove()
			end
			return false, "Failed to create the selected item."
		end

		if type(attributes) == "string" and attributes ~= "" and item.applyAttributes then
			item:applyAttributes(attributes)
		end

		local ret = player:addItemEx(item, true)
		if ret ~= RETURNVALUE_NOERROR then
			item:remove()
			for _, createdItem in ipairs(created) do
				createdItem:remove()
			end
			return false, Game.getReturnMessage(ret)
		end

		table.insert(created, item)
	end

	return true
end

local function depositGuildStorage(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.DEPOSIT_STORAGE) then
		return sendGuildError(player, "You do not have permission to deposit items into guild storage.")
	end
	if not hasTable("guild_storage_items") then
		return sendGuildError(player, "Guild storage schema is missing. Run migration 51 first.")
	end

	local itemId = tonumber(data and data.itemId) or 0
	local amount = math.max(1, math.floor(tonumber(data and data.count) or 0))

	local itemType = ItemType(itemId)
	if not itemType or itemType:getId() == 0 then
		return sendGuildError(player, "Invalid item selected.")
	end
	if not itemType:isPickupable() then
		return sendGuildError(player, "This item cannot be stored.")
	end
	if itemType:isStackable() then
		amount = math.min(amount, GUILD_ITEM_STACK_LIMIT)
	else
		amount = math.min(amount, 1)
	end
	if player:getItemCount(itemId) < amount then
		return sendGuildError(player, "You do not have enough of that item.")
	end

	local tooltip = tostring(data and data.tooltip or "")
	local attributes = ""
	local sourceItem = nil
	if itemType:isStackable() then
		tooltip = itemType:getName()
	else
		amount = 1
		sourceItem = resolvePlayerStorageSourceItem(player, data or {})
		if not sourceItem then
			return sendGuildError(player, "Failed to identify the dragged item.")
		end

		if sourceItem:getId() ~= itemId then
			return sendGuildError(player, "Dragged item no longer matches the selected item.")
		end

		attributes = serializeStorageItemAttributes(sourceItem)
		if tooltip == "" then
			tooltip = sourceItem:getSpecialDescription() or ""
		end
		if tooltip == "" then
			tooltip = itemType:getName()
		end
	end

	local storageItems = {
		{
			itemId = itemId,
			count = amount,
			tooltip = tooltip,
			attributes = attributes
		}
	}

	if not canStoreItemsInGuildStorage(guild:getId(), storageItems) then
		return sendGuildError(player, "Guild storage is full.")
	end

	if itemType:isStackable() then
		if not player:removeItem(itemId, amount) then
			return sendGuildError(player, "You do not have enough of that item.")
		end
	elseif not sourceItem:remove(1) then
		return sendGuildError(player, "Failed to remove the selected item.")
	end

	local storageSummary = tryStoreItemsInGuildStorage(guild:getId(), storageItems)
	if (tonumber(storageSummary.storedItems) or 0) < amount then
		return sendGuildError(player, "Failed to store the selected item.")
	end

	refreshGuildStorageForGuild(guild:getId())
	addGuildMessages(
		getGuildInboxRecipients(guild:getId()),
		guild:getId(),
		GuildManagement.MESSAGE_TYPES.STORAGE_DEPOSIT,
		player:getName() .. " deposited {" .. amount .. "x " .. itemType:getName() .. "} into guild storage.",
		player:getGuid(),
		guild:getId()
	)
	sendGuildPayload(player, "selfBalance", { balance = player:getBankBalance(), premiumPoints = getAccountPremiumPoints(player:getAccountId()) })
end

local function depositGuildStorageBatch(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.DEPOSIT_STORAGE) then
		return sendGuildError(player, "You do not have permission to deposit items into guild storage.")
	end

	if not hasTable("guild_storage_items") then
		return sendGuildError(player, "Guild storage schema is missing. Run migration 51 first.")
	end

	if type(data) ~= "table" or type(data.items) ~= "table" then
		return sendGuildError(player, "Invalid deposit data.")
	end

	local depositItems = {}

	for _, entry in ipairs(data.items) do
		local clientId = tonumber(entry.clientId or entry.itemId) or 0
		local itemId = getServerItemIdByClientId(clientId)
		local amount = math.max(1, math.floor(tonumber(entry.count) or 1))
		local tooltip = tostring(entry.tooltip or "")

		if itemId <= 0 then
			print("[GuildStorage] failed clientId conversion:", clientId)
			return sendGuildError(player, "Invalid item selected.")
		end

		local itemType = ItemType(itemId)
		if not itemType or itemType:getId() == 0 then
			return sendGuildError(player, "Invalid item selected.")
		end

		if not itemType:isPickupable() then
			return sendGuildError(player, "This item cannot be stored.")
		end

		local sourceItem = nil
		local attributes = ""
		if itemType:isStackable() then
			amount = math.min(amount, GUILD_ITEM_STACK_LIMIT)
			tooltip = itemType:getName()
		else
			amount = 1
			sourceItem = resolvePlayerStorageSourceItem(player, entry)
			if not sourceItem then
				return sendGuildError(player, "Failed to identify one dragged item.")
			end

			if sourceItem:getId() ~= itemId then
				return sendGuildError(player, "One dragged item no longer matches its expected item.")
			end

			attributes = serializeStorageItemAttributes(sourceItem)
			if tooltip == "" then
				tooltip = sourceItem:getSpecialDescription() or ""
			end
			if tooltip == "" then
				tooltip = itemType:getName()
			end
		end

		table.insert(depositItems, {
			itemId = itemId,
			clientId = clientId,
			count = amount,
			tooltip = tooltip,
			attributes = attributes,
			sourceItem = sourceItem
		})

		if #depositItems >= 5 then
			break
		end
	end

	if #depositItems == 0 then
		return sendGuildError(player, "No valid items selected.")
	end

	local requiredByItem = {}
	for _, entry in ipairs(depositItems) do
		requiredByItem[entry.itemId] = (requiredByItem[entry.itemId] or 0) + entry.count
	end

	for itemId, amount in pairs(requiredByItem) do
		local checkItemType = ItemType(itemId)
		local playerCount = player:getItemCount(itemId)

		if playerCount < amount then
			return sendGuildError(player, "You do not have enough of one selected item.")
		end
	end

	local storageItems = {}
	for _, entry in ipairs(depositItems) do
		table.insert(storageItems, {
			itemId = entry.itemId,
			count = entry.count,
			tooltip = entry.tooltip or "",
			attributes = entry.attributes or ""
		})
	end

	if not canStoreItemsInGuildStorage(guild:getId(), storageItems) then
		return sendGuildError(player, "Guild storage does not have enough free slots.")
	end

	local logEntries = {}
	for _, entry in ipairs(depositItems) do
		table.insert(logEntries, {
			itemId = entry.itemId,
			count = entry.count
		})
	end

	for _, entry in ipairs(depositItems) do
		local entryType = ItemType(entry.itemId)
		if entryType and entryType:isStackable() then
			if not player:removeItem(entry.itemId, entry.count) then
				return sendGuildError(player, "Failed to remove selected items.")
			end
		elseif not entry.sourceItem or not entry.sourceItem:remove(1) then
			return sendGuildError(player, "Failed to remove selected items.")
		end
	end

	local storageSummary = tryStoreItemsInGuildStorage(guild:getId(), storageItems)
	local expectedItems = 0
	for _, entry in ipairs(depositItems) do
		expectedItems = expectedItems + (tonumber(entry.count) or 0)
	end
	if (tonumber(storageSummary.storedItems) or 0) < expectedItems then
		return sendGuildError(player, "Failed to store the selected items.")
	end

	refreshGuildStorageForGuild(guild:getId())
	for _, entry in ipairs(logEntries) do
		local itemType = ItemType(entry.itemId)
		addGuildMessages(
			getGuildInboxRecipients(guild:getId()),
			guild:getId(),
			GuildManagement.MESSAGE_TYPES.STORAGE_DEPOSIT,
			player:getName() .. " deposited {" .. entry.count .. "x " .. ((itemType and itemType:getName()) or ("Item #" .. entry.itemId)) .. "} into guild storage.",
			player:getGuid(),
			guild:getId()
		)
	end
end

local function withdrawGuildStorage(player, data)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end
	if not hasPermission(player, GuildManagement.PERMISSIONS.WITHDRAW_STORAGE) then
		return sendGuildError(player, "You do not have permission to withdraw items from guild storage.")
	end
	if not hasTable("guild_storage_items") then
		return sendGuildError(player, "Guild storage schema is missing. Run migration 51 first.")
	end

	local slot = tonumber(data and data.slot) or 0
	if slot <= 0 then
		return sendGuildError(player, "No storage slot selected.")
	end

	local rows = getGuildStorageRows(guild:getId())
	local row = rows[slot]
	if not row then
		return sendGuildError(player, "Selected storage slot is empty.")
	end

	local amount = math.max(1, math.floor(tonumber(data and data.count) or row.count or 1))
	amount = math.min(amount, row.count or amount)

	local ok, err = giveStorageItemsToPlayer(player, row.itemId, amount, row.attributes)
	if not ok then
		return sendGuildError(player, err or "You do not have enough capacity.")
	end

	local remaining = (row.count or 0) - amount
	if remaining > 0 then
		db.query("UPDATE `guild_storage_items` SET `count` = " .. remaining .. " WHERE `guild_id` = " .. guild:getId() .. " AND `slot` = " .. slot)
	else
		db.query("DELETE FROM `guild_storage_items` WHERE `guild_id` = " .. guild:getId() .. " AND `slot` = " .. slot)
	end

	refreshGuildStorageForGuild(guild:getId())
	local itemType = ItemType(row.itemId)
	addGuildMessages(
		getGuildInboxRecipients(guild:getId()),
		guild:getId(),
		GuildManagement.MESSAGE_TYPES.STORAGE_WITHDRAW,
		player:getName() .. " withdrew {" .. amount .. "x " .. ((itemType and itemType:getName()) or ("Item #" .. row.itemId)) .. "} from guild storage.",
		player:getGuid(),
		guild:getId()
	)
end

local function sendPrismView(player, configId)
	local guild = player:getGuild()
	if not guild then
		return sendGuildError(player, "You are not in a guild.")
	end

	ensurePrismStateLoaded()
	local state = PrismState.byConfigId[configId]
	local config = getPrismConfigById(configId)
	if not state or not config then
		return sendGuildError(player, "Unknown prism.")
	end

	local items = {}
	local lootRows = PrismState.lootByPrismId[state.id] or {}
	for slot = 1, tonumber(state.lootSlots or GuildManagement.PRISM_STORAGE_SLOTS) or GuildManagement.PRISM_STORAGE_SLOTS do
		local row = lootRows[slot]
		if row then
			local itemType = ItemType(tonumber(row.itemId) or 0)
			table.insert(items, {
				slot = slot,
				itemId = tonumber(row.itemId) or 0,
				clientId = itemType and itemType:getClientId() or 0,
				name = itemType and itemType:getName() or ("Item #" .. tostring(row.itemId)),
				count = tonumber(row.count) or 1,
				tooltip = tostring(row.tooltip or ""),
				attributesHex = hexEncode(tostring(row.attributes or ""))
			})
		end
	end

	sendGuildPayload(player, "prismView", {
		configId = configId,
		name = config.name,
		gold = tonumber(state.goldBuffer) or 0,
		exp = tonumber(state.expBuffer) or 0,
		capacity = tonumber(state.lootSlots or GuildManagement.PRISM_STORAGE_SLOTS) or GuildManagement.PRISM_STORAGE_SLOTS,
		items = items
	})
end

local GuildExtended = CreatureEvent("GuildManagementExtended")

function GuildExtended.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= GUILD_OPCODE then
		return
	end

	local ok, payload = pcall(function() return json.decode(buffer) end)
	if not ok or type(payload) ~= "table" then
		return
	end

	local action = payload.action
	local data = payload.data

	local dispatched, dispatchError = pcall(function()
	if action == "fetch" then
		sendFullGuildState(player)
	elseif action == "create" then
		createGuild(player, data or {})
	elseif action == "invite" then
		invitePlayerToGuild(player, data)
	elseif action == "request" then
		requestJoinGuild(player, tonumber(data) or 0)
	elseif action == "accept" then
		handleAccept(player, data or {})
	elseif action == "reject" then
		handleReject(player, data or {})
	elseif action == "kick" then
		kickGuildMember(player, data)
	elseif action == "leave" then
		leaveGuild(player)
	elseif action == "saveRanks" then
		saveRanks(player, data or {})
	elseif action == "setRank" then
		setMemberRank(player, data or {})
	elseif action == "settings" then
		updateGuildSettings(player, data or {})
	elseif action == "top" then
		sendGuildPayload(player, "top", getTopGuilds(tonumber(data) or 0))
	elseif action == "inbox" then
		fetchInbox(player, tonumber(data) or 0)
	elseif action == "updateSelfBalance" then
		updateSelfBalance(player)
	elseif action == "donate" then
		donateToGuild(player, data)
	elseif action == "premiumDonate" then
		donatePremiumToGuild(player, data)
	elseif action == "withdraw" then
		withdrawFromGuild(player, data)
	elseif action == "levelUp" then
		levelUpGuild(player)
	elseif action == "perkUnlock" then
		unlockGuildPerk(player, data or {})
	elseif action == "perkReset" then
		resetGuildPerks(player, data or {})
	elseif action == "contributionhistory" then
		sendContributionHistory(player)
	elseif action == "storageFetch" then
		if not GUILD_STORAGE_ENABLED then
			return
		end
		sendGuildStorage(player)
	elseif action == "questsFetch" then
		if not GUILD_QUESTS_ENABLED then
			return
		end
		sendGuildQuests(player)
	elseif action == "blackMarketFetch" then
		if not GUILD_BLACKMARKET_ENABLED then
			return
		end
		sendGuildBlackMarket(player)
	elseif action == "blackMarketPurchase" then
		if not GUILD_BLACKMARKET_ENABLED then
			return
		end
		GuildBlackMarket.purchase(player, data or {})
	elseif action == "dynastieFetch" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		sendGuildDynastie(player, tonumber(data and data.page) or 1)
	elseif action == "dynastieViewState" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		if GuildDynastie and GuildDynastie.setViewerActive then
			GuildDynastie.setViewerActive(player, data and data.active == true)
		end
	elseif action == "dynastiePanelFetch" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		if GuildDynastie and GuildDynastie.sendPanel then
			GuildDynastie.sendPanel(player)
		end
	elseif action == "dynastiePlace" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.place(player, data or {})
	elseif action == "dynastieCollect" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.collect(player, data or {})
	elseif action == "dynastieTax" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.setTax(player, data or {})
	elseif action == "dynastieAttack" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.attack(player, data or {})
	elseif action == "dynastieTeleport" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.teleport(player, data or {})
	elseif action == "dynastieDefenderUpgrade" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.upgradeDefender(player, data or {})
	elseif action == "dynastiePerkUpgrade" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.upgradePerk(player, data or {})
	elseif action == "dynastiePassiveUnlock" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.unlockPassiveNode(player, data or {})
	elseif action == "dynastiePassiveReset" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastie.resetPassiveTree(player, data or {})
	elseif action == "dynastieQuestsFetch" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastieQuests.send(player, tostring(data and data.configId or ""))
	elseif action == "dynastieQuestClaim" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		GuildDynastieQuests.claim(player, data or {})
	elseif action == "dynastieAchievementsFetch" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		if GuildDynastie and GuildDynastie.sendAchievements then
			GuildDynastie.sendAchievements(player, tonumber(data and data.page) or 1, tostring(data and data.search or ""))
		end
	elseif action == "dynastieEventsFetch" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		if GuildDynastieEvents and GuildDynastieEvents.send then
			GuildDynastieEvents.send(player, data or {})
		end
	elseif action == "dynastieBoardAcceptedFetch" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		if GuildDynastieEvents and GuildDynastieEvents.sendAccepted then
			GuildDynastieEvents.sendAccepted(player)
		end
	elseif action == "dynastieBoardQuestAccept" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		if GuildDynastieEvents and GuildDynastieEvents.acceptBoardQuest then
			GuildDynastieEvents.acceptBoardQuest(player, data or {})
		end
	elseif action == "dynastieAchievementClaim" then
		if not GUILD_DYNASTIE_ENABLED then
			return
		end
		if GuildDynastie and GuildDynastie.claimAchievement then
			GuildDynastie.claimAchievement(player, data or {})
		end
	elseif action == "questClaim" then
		claimGuildQuestReward(player, data or {})
	elseif action == "achievementsFetch" then
		if not GUILD_ACHIEVEMENTS_ENABLED then
			return
		end
		GuildAchievements.send(player, tonumber(data and data.page) or 1, tostring(data and data.search or ""))
	elseif action == "achievementClaim" then
		if not GUILD_ACHIEVEMENTS_ENABLED then
			return
		end
		GuildAchievements.claimReward(player, data or {})
	elseif action == "prismFetch" then
		if not GUILD_PRISM_ENABLED then
			return
		end
		sendGuildPrisms(player, tonumber(data and data.page) or 1)
	elseif action == "prismViewState" then
		if not GUILD_PRISM_ENABLED then
			return
		end
		setPrismViewerActive(player, data and data.active == true)
	elseif action == "prismPlace" then
		if not GUILD_PRISM_ENABLED then
			return
		end
		placeGuildPrism(player, tostring(data and data.configId or ""))
	elseif action == "prismTeleport" then
		if not GUILD_PRISM_ENABLED then
			return
		end
		teleportToGuildPrism(player, tostring(data and data.configId or ""))
	elseif action == "prismCollect" then
		if not GUILD_PRISM_ENABLED then
			return
		end
		collectGuildPrism(player, tostring(data and data.configId or ""))
	elseif action == "prismAttack" then
		if not GUILD_PRISM_ENABLED then
			return
		end
		startPrismAttack(player, tostring(data and data.configId or ""))
	elseif action == "prismView" then
		if not GUILD_PRISM_ENABLED then
			return
		end
		sendPrismView(player, tostring(data and data.configId or ""))
	elseif action == "storageDeposit" then
		depositGuildStorage(player, data or {})
	elseif action == "storageDepositBatch" then
		depositGuildStorageBatch(player, data or {})
	elseif action == "storageWithdraw" then
		withdrawGuildStorage(player, data or {})
	elseif action == "passLeader" then
		passLeader(player, data)
	end
	end)

	if not dispatched then
		print("[GuildManagement] Extended opcode action '" .. tostring(action) .. "' failed: " .. tostring(dispatchError))
	end
end

GuildExtended:type("extendedopcode")
GuildExtended:register()

local GuildLogin = CreatureEvent("GuildManagementLogin")

function GuildLogin.onLogin(player)
	player:registerEvent("GuildManagementExtended")
	player:registerEvent("GuildManagementPerkCombat")
	player:registerEvent("GuildManagementPrismKill")
	player:registerEvent("GuildDynastieDefenderDamage")
	applyGuildPerkEffects(player)
	if GuildAchievements and GuildAchievements.syncPlayerCosmetics then
		GuildAchievements.syncPlayerCosmetics(player)
	end
	ensurePrismStateLoaded()
	return true
end

GuildLogin:type("login")
GuildLogin:register()

local GuildPrismKill = CreatureEvent("GuildManagementPrismKill")

function GuildPrismKill.onKill(player, target)
	if not player or not target then
		return true
	end

	ensurePrismStateLoaded()
	if GuildDynastie and GuildDynastie.onKill then
		GuildDynastie.onKill(player, target)
	end
	if target:isPlayer() then
		if GuildDynastieEvents and GuildDynastieEvents.onKill then
			GuildDynastieEvents.onKill(player, target)
		end
		local killerGuild = player:getGuild()
		local killerGuildId = killerGuild and killerGuild:getId() or 0
		if killerGuildId > 0 and GuildAchievements and GuildAchievements.awardGlobalPlayerKill then
			GuildAchievements.awardGlobalPlayerKill(killerGuildId, 1)
		end
		local targetGuild = target:getGuild()
		local targetGuildId = targetGuild and targetGuild:getId() or 0
		if killerGuildId > 0 and targetGuildId > 0 then
			local killerPosition = player:getPosition()
			local targetPosition = target:getPosition()
			for configId, attack in pairs(PrismAttackState.byConfigId) do
				local state = PrismState.byConfigId[configId]
				if state and attack and isInsidePrismAttackArea(state, killerPosition) and isInsidePrismAttackArea(state, targetPosition) then
					if killerGuildId == attack.attackerGuildId and targetGuildId == attack.defenderGuildId then
						if GuildAchievements and GuildAchievements.awardPrismAttackPlayerKill then
							GuildAchievements.awardPrismAttackPlayerKill(killerGuildId, 1)
						end
						break
					elseif killerGuildId == attack.defenderGuildId and targetGuildId == attack.attackerGuildId then
						if GuildAchievements and GuildAchievements.awardPrismDefensePlayerKill then
							GuildAchievements.awardPrismDefensePlayerKill(killerGuildId, 1)
						end
						break
					end
				end
			end
		end
		return true
	end
	if not target:isMonster() or target:getMaster() then
		return true
	end

	if GuildDynastieEvents and GuildDynastieEvents.onKill then
		GuildDynastieEvents.onKill(player, target)
	end

	local killerGuild = player:getGuild()
	local killerGuildId = killerGuild and killerGuild:getId() or 0
	if killerGuildId > 0 and GuildAchievements and GuildAchievements.awardMonsterKill then
		GuildAchievements.awardMonsterKill(killerGuildId, 1)
	end

	GuildAchievements.awardBossKill(player, target)
	if GuildDynastieQuests and GuildDynastieQuests.awardBossKill then
		GuildDynastieQuests.awardBossKill(player, target)
	end

	local prismState = getOwningPrismForKill(player, target)
	if not prismState then
		awardGuildQuestKill(player, target)
		return true
	end

	local prismConfig = getPrismConfig()
	local goldPerKill = tonumber(prismConfig.DEFAULT_GOLD_PER_KILL or 2) or 2
	local expPerKill = tonumber(prismConfig.DEFAULT_EXP_PER_KILL or 2) or 2

	prismState.goldBuffer = (tonumber(prismState.goldBuffer) or 0) + goldPerKill
	prismState.expBuffer = (tonumber(prismState.expBuffer) or 0) + expPerKill
	prismState.dirty = true

	awardPrismLootFromMonster(prismState, target, player)
	awardGuildQuestKill(player, target)
	return true
end

GuildPrismKill:register()

local GuildPrismStartup = GlobalEvent("GuildManagementPrismStartup")

function GuildPrismStartup.onStartup()
	ensurePrismStateLoaded()
	return true
end

GuildPrismStartup:type("startup")
GuildPrismStartup:register()

local GuildDynastieStartup = GlobalEvent("GuildManagementDynastieStartup")

function GuildDynastieStartup.onStartup()
	if GuildDynastie and GuildDynastie.refreshWorld then
		GuildDynastie.refreshWorld()
	end
	if GuildDynastieEvents and GuildDynastieEvents.refreshBoardSpawns then
		GuildDynastieEvents.refreshBoardSpawns()
	end
	return true
end

GuildDynastieStartup:type("startup")
GuildDynastieStartup:register()

local GuildDynastieBoardWorld = GlobalEvent("GuildManagementDynastieBoardWorld")

function GuildDynastieBoardWorld.onThink(interval)
	if GuildDynastieEvents and GuildDynastieEvents.refreshBoardSpawns then
		GuildDynastieEvents.refreshBoardSpawns()
	end
	return true
end

GuildDynastieBoardWorld:interval(60 * 1000)
GuildDynastieBoardWorld:register()

-- Expone el modulo de dinastia al talkaction de administracion /guild.
_G.GuildHallDynastie = GuildDynastie

-- Reenvia el estado completo del guild a todos sus miembros conectados.
-- Usado por el talkaction de administracion /guild.
function GuildHallRefresh(guildId)
	guildId = tonumber(guildId) or 0
	if guildId <= 0 then
		return false
	end
	local ok, err = pcall(function()
		if refreshGuildPerkState then
			refreshGuildPerkState(guildId)
		end
		if refreshDynastieBattleForMembers then
			refreshDynastieBattleForMembers(guildId)
		end
		if refreshPrismBattleForMembers then
			refreshPrismBattleForMembers(guildId, true)
		end
	end)
	if not ok then
		print("[GuildHallRefresh] " .. tostring(err))
	end
	return true
end
