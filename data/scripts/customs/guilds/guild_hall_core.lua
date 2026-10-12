local schemaColumnCache = {}
local schemaTableCache = {}
local clientIdToServerIdCache = nil
local MAX_GUILD_OPCODE_CHUNK = 6000
local MAX_SERVER_ITEM_ID_SCAN = 35000
local function sanitizeGuildPayloadString(value)
	value = tostring(value or "")
	value = value:gsub("[%z\1-\8\11\12\14-\31]", " ")
	return value
end

local function sanitizeGuildPayloadValue(value, seen)
	local valueType = type(value)
	if valueType == "string" then
		return sanitizeGuildPayloadString(value)
	end

	if valueType ~= "table" then
		return value
	end

	seen = seen or {}
	if seen[value] then
		return {}
	end
	seen[value] = true

	local sanitized = {}
	for key, nestedValue in pairs(value) do
		local sanitizedKey = type(key) == "string" and sanitizeGuildPayloadString(key) or key
		sanitized[sanitizedKey] = sanitizeGuildPayloadValue(nestedValue, seen)
	end
	return sanitized
end

local function sendGuildOpcodeBuffer(player, buffer)
	if not player.isUsingOtClient or not player:isUsingOtClient() then
		return false
	end

	return player:sendExtendedOpcode(GUILD_OPCODE, buffer)
end

local function sendGuildPayload(player, action, data)
	if not player then
		return false
	end

	local sanitizedAction = sanitizeGuildPayloadString(action)
	local sanitizedData = sanitizeGuildPayloadValue(data)

	local ok, encoded = pcall(function()
		return json.encode({ action = sanitizedAction, data = sanitizedData })
	end)
	if not ok then
		print(string.format("[GuildHall] Failed to encode payload for action '%s': %s", tostring(action), tostring(encoded)))
		return false
	end

	if type(encoded) ~= "string" then
		print(string.format("[GuildHall] Invalid encoded payload type for action '%s': %s", tostring(action), type(encoded)))
		return false
	end

	if #encoded <= MAX_GUILD_OPCODE_CHUNK then
		return sendGuildOpcodeBuffer(player, encoded)
	end

	local sent = sendGuildOpcodeBuffer(player, "S" .. encoded:sub(1, MAX_GUILD_OPCODE_CHUNK))
	local pos = MAX_GUILD_OPCODE_CHUNK + 1

	while pos <= #encoded do
		local chunk = encoded:sub(pos, pos + MAX_GUILD_OPCODE_CHUNK - 1)
		pos = pos + MAX_GUILD_OPCODE_CHUNK

		if pos > #encoded then
			sent = sendGuildOpcodeBuffer(player, "E" .. chunk) and sent
		else
			sent = sendGuildOpcodeBuffer(player, "P" .. chunk) and sent
		end
	end

	return sent
end

local function sendGuildError(player, message)
	sendGuildPayload(player, "error", message)
end

local function dbBoolean(value)
	return value and 1 or 0
end

local function formatCommaValue(value)
	local formatted = tostring(math.floor(tonumber(value) or 0))
	local k
	repeat
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
	until k == 0
	return formatted
end

local function splitItemCountForStorage(itemId, count, tooltip, attributes)
	itemId = tonumber(itemId) or 0
	count = math.max(0, tonumber(count) or 0)
	tooltip = tostring(tooltip or "")
	attributes = tostring(attributes or "")

	local chunks = {}
	if itemId <= 0 or count <= 0 then
		return chunks
	end

	local itemType = ItemType(itemId)
	local limit = count
	if itemType and itemType:isStackable() then
		limit = GUILD_ITEM_STACK_LIMIT
	end

	while count > 0 do
		local chunk = math.min(limit, count)
		table.insert(chunks, {
			itemId = itemId,
			count = chunk,
			tooltip = tooltip,
			attributes = attributes
		})
		count = count - chunk
	end

	return chunks
end

local function getPrismLootBackpackCapacity()
	local itemType = ItemType(GUILD_PRISM_LOOT_BACKPACK_ID)
	if itemType and itemType.getCapacity then
		local capacity = tonumber(itemType:getCapacity()) or 0
		if capacity > 0 then
			return capacity
		end
	end
	return math.max(1, tonumber(GUILD_PRISM_LOOT_BACKPACK_CAPACITY) or 20)
end

local function createPrismLootBackpack()
	local bag = Game.createItem(GUILD_PRISM_LOOT_BACKPACK_ID, 1)
	if bag and bag.addItemEx then
		return bag
	end

	if bag and bag.remove then
		bag:remove()
	end

	local fallbackBag = Game.createItem(1988, 1)
	if fallbackBag and fallbackBag.addItemEx then
		return fallbackBag
	end

	if fallbackBag and fallbackBag.remove then
		fallbackBag:remove()
	end

	return nil
end

local function escape(value)
	return db.escapeString(value or "")
end

local function getAccountPremiumPoints(accountId)
	if not accountId or accountId <= 0 then
		return 0
	end

	local resultId = db.storeQuery("SELECT `points` FROM `znote_accounts` WHERE `id` = " .. accountId)
	if not resultId then
		return 0
	end

	local points = result.getNumber(resultId, "points")
	result.free(resultId)
	return math.max(0, tonumber(points) or 0)
end

local function setAccountPremiumPoints(accountId, points)
	if not accountId or accountId <= 0 then
		return false
	end

	points = math.max(0, math.floor(tonumber(points) or 0))
	return db.query("UPDATE `znote_accounts` SET `points` = " .. points .. " WHERE `id` = " .. accountId)
end

local function getServerItemIdByClientId(clientId)
	clientId = tonumber(clientId) or 0
	if clientId <= 0 then
		return 0
	end

	if not clientIdToServerIdCache then
		clientIdToServerIdCache = {}

		for serverId = 1, MAX_SERVER_ITEM_ID_SCAN do
			local ok, itemType = pcall(ItemType, serverId)
			if ok and itemType and itemType:getId() ~= 0 then
				local currentClientId = tonumber(itemType:getClientId()) or 0
				if currentClientId > 0 and not clientIdToServerIdCache[currentClientId] then
					clientIdToServerIdCache[currentClientId] = serverId
				end
			end
		end

		print(string.format("[GuildStorage] Built clientId -> serverId cache up to item id %d.", MAX_SERVER_ITEM_ID_SCAN))
	end

	return clientIdToServerIdCache[clientId] or 0
end

local function hasTable(tableName)
	if schemaTableCache[tableName] ~= nil then
		return schemaTableCache[tableName]
	end

	local resultId = db.storeQuery("SHOW TABLES LIKE " .. escape(tableName))
	local exists = resultId ~= false and resultId ~= nil
	if exists then
		result.free(resultId)
	end

	schemaTableCache[tableName] = exists
	return exists
end

local function hasColumn(tableName, columnName)
	local cacheKey = tableName .. "." .. columnName
	if schemaColumnCache[cacheKey] ~= nil then
		return schemaColumnCache[cacheKey]
	end

	local resultId = db.storeQuery("SHOW COLUMNS FROM `" .. tableName .. "` LIKE " .. escape(columnName))
	local exists = resultId ~= false and resultId ~= nil
	if exists then
		result.free(resultId)
	end

	schemaColumnCache[cacheKey] = exists
	return exists
end

local function getPrismPlaceCooldownUntil(guildId, configId)
	guildId = tonumber(guildId) or 0
	if guildId <= 0 or not configId or configId == "" or not hasTable("guild_prism_cooldowns") then
		return 0
	end

	local query
	if hasColumn("guild_prism_cooldowns", "guild_id") then
		query = "SELECT `cooldown_until` FROM `guild_prism_cooldowns` WHERE `guild_id` = " .. guildId .. " AND `config_id` = " .. escape(configId)
	else
		query = "SELECT `cooldown_until` FROM `guild_prism_cooldowns` WHERE `config_id` = " .. escape(configId)
	end

	local resultId = db.storeQuery(query)
	if not resultId then
		return 0
	end

	local cooldownUntil = tonumber(result.getNumber(resultId, "cooldown_until")) or 0
	result.free(resultId)
	return cooldownUntil
end

local function setPrismPlaceCooldown(guildId, configId, cooldownUntil)
	guildId = tonumber(guildId) or 0
	if guildId <= 0 or not configId or configId == "" or not hasTable("guild_prism_cooldowns") then
		return false
	end

	cooldownUntil = math.max(0, tonumber(cooldownUntil) or 0)
	local now = os.time()
	if hasColumn("guild_prism_cooldowns", "guild_id") then
		return db.query(
			"INSERT INTO `guild_prism_cooldowns` (`guild_id`, `config_id`, `cooldown_until`, `updated_at`) VALUES (" ..
			guildId .. ", " .. escape(configId) .. ", " .. cooldownUntil .. ", " .. now .. ") " ..
			"ON DUPLICATE KEY UPDATE `cooldown_until` = VALUES(`cooldown_until`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	return db.query(
		"INSERT INTO `guild_prism_cooldowns` (`config_id`, `cooldown_until`, `updated_at`) VALUES (" ..
		escape(configId) .. ", " .. cooldownUntil .. ", " .. now .. ") " ..
		"ON DUPLICATE KEY UPDATE `cooldown_until` = VALUES(`cooldown_until`), `updated_at` = VALUES(`updated_at`)"
	)
end

return {
	sendGuildPayload = sendGuildPayload,
	sendGuildError = sendGuildError,
	dbBoolean = dbBoolean,
	formatCommaValue = formatCommaValue,
	splitItemCountForStorage = splitItemCountForStorage,
	getPrismLootBackpackCapacity = getPrismLootBackpackCapacity,
	createPrismLootBackpack = createPrismLootBackpack,
	escape = escape,
	getAccountPremiumPoints = getAccountPremiumPoints,
	setAccountPremiumPoints = setAccountPremiumPoints,
	getServerItemIdByClientId = getServerItemIdByClientId,
	hasTable = hasTable,
	hasColumn = hasColumn,
	getPrismPlaceCooldownUntil = getPrismPlaceCooldownUntil,
	setPrismPlaceCooldown = setPrismPlaceCooldown
}
