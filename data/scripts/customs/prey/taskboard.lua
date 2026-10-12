local OPCODE_TASKBOARD = 234

local SHOP_OK = 0
local SHOP_ERR_NOT_FOUND = 1
local SHOP_ERR_ALREADY_BOUGHT = 2
local SHOP_ERR_NO_POINTS = 3
local SHOP_ERR_NEED_BASE = 4
local SHOP_ERR_NO_SPACE = 6

local SHOP_OFFER_TYPE_ITEM = 0
local SHOP_OFFER_TYPE_MOUNT = 1
local SHOP_OFFER_TYPE_OUTFIT = 2
local SHOP_OFFER_TYPE_ITEM_DOUBLE = 3
local SHOP_OFFER_TYPE_AURA = 6
local SHOP_OFFER_TYPE_WINGS = 7
local SHOP_OFFER_TYPE_SHADER = 8

local function isPermanentShopOffer(offerType)
	offerType = tonumber(offerType) or SHOP_OFFER_TYPE_ITEM
	return offerType == SHOP_OFFER_TYPE_MOUNT
		or offerType == SHOP_OFFER_TYPE_OUTFIT
		or offerType == SHOP_OFFER_TYPE_AURA
		or offerType == SHOP_OFFER_TYPE_WINGS
		or offerType == SHOP_OFFER_TYPE_SHADER
end

local WEEKLY_SELECT_DIFFICULTY = 0
local WEEKLY_DELIVER_ITEM = 1
local WEEKLY_UNLOCK_KILL_SLOT = 3
local WEEKLY_UNLOCK_DELIVERY_SLOT = 4

local BOUNTY_ACTION_REROLL = 0
local BOUNTY_ACTION_SELECT = 1
local BOUNTY_ACTION_CLAIM_REWARD = 2
local BOUNTY_ACTION_CHANGE_DIFFICULTY = 3
local BOUNTY_ACTION_REQUEST = 4
local BOUNTY_ACTION_CLAIM_DAILY = 5
local BOUNTY_ACTION_UNLOCK_SLOT = 6
local BOUNTY_PREF_ACTION_REQUEST = 0
local BOUNTY_PREF_ACTION_BUY_SLOT = 1
local BOUNTY_PREF_ACTION_SET_PREFERRED = 2
local BOUNTY_PREF_ACTION_SET_UNWANTED = 3
local BOUNTY_PREF_ACTION_REMOVE_PREFERRED = 4
local BOUNTY_PREF_ACTION_REMOVE_UNWANTED = 5

local bountyTaskSlots = 3
local bountyTaskUnlockCosts = { 0, 300, 600 }
local bountyDifficultyTaskConfig = {
	[1] = { points = 3, minKills = 50, maxKills = 150 },
	[2] = { points = 7, minKills = 150, maxKills = 250 },
	[3] = { points = 16, minKills = 250, maxKills = 500 },
	[4] = { points = 27, minKills = 500, maxKills = 1000 },
	[5] = { points = 45, minKills = 1000, maxKills = 2000 },
}
local bountyRarityMultipliers = {
	[0] = 1,
	[1] = 2,
	[2] = 4,
}
local bountyRerollCap = 10
local bountyRerollCost = 10
local bountyPreferenceSlots = 5
local bountyPreferenceUnlockCosts = { 0, 300, 600, 900, 1200 }
local bountyPreferenceClearCost = 300
local bountyPreferencePageSize = 25
local bountyDifficultyNames = {
	[1] = "Beginner",
	[2] = "Adept",
	[3] = "Expert",
	[4] = "Master",
	[5] = "Extreme",
}
local bountyTalismanMaxLevels = { 50, 50, 20, 50 }
local bountyTalismanBaseValues = { 0, 0, 0, 0 }
local bountyTalismanStepValues = { 50, 50, 50, 50 }
local bountyTalismanUpgradeCosts = {
	25, 50, 100, 150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000,
	1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000
}
local bountyActiveTargetCache = {}
local weeklyKillSaveState = {}
local bountyKillSaveState = {}
local weeklyFinishedSummaryCache = {}
local daySeconds = 24 * 60 * 60

TaskBoard = TaskBoard or {}

local bountyMonsters = dofile("data/scripts/customs/prey/bountymonsters.lua")
if type(bountyMonsters) ~= "table" then
	bountyMonsters = {}
end

local weeklyDefaultTaskSlots = 6
local weeklyTaskSlots = 9
local weeklyKillSlotUnlockCost = 1000
local weeklyDeliverySlotUnlockCost = 500
local weeklyDuration = 4 * 24 * 60 * 60
local weeklyDeliveryPoints = 75
local weeklySoulsealsPerTask = 1
local weeklyKillPoints = {
	[1] = 25,
	[2] = 50,
	[3] = 100,
	[4] = 200,
	[5] = 350,
}
local taskShopRotationSeconds = 24 * 60 * 60
local taskShopMaxOffers = 6
local taskShopPageSize = 6

local weeklyDifficultyConfig = dofile("data/scripts/customs/prey/weekly_tasks.lua")
if type(weeklyDifficultyConfig) ~= "table" then
	weeklyDifficultyConfig = {}
end

local shopOffers = dofile("data/scripts/customs/prey/task_shop_offers.lua")
if type(shopOffers) ~= "table" then
	shopOffers = {}
end

local function getOutfitData(monsterName)
	local monsterType = monsterName and MonsterType(monsterName)
	local outfit = monsterType and (monsterType.outfit and monsterType:outfit() or monsterType.getOutfit and monsterType:getOutfit())
	if not outfit then
		return nil
	end
	return {
		lookType = outfit.lookType or outfit.type or 0,
		lookTypeEx = outfit.lookTypeEx or outfit.auxType or 0,
		lookHead = outfit.lookHead or outfit.head or 0,
		lookBody = outfit.lookBody or outfit.body or 0,
		lookLegs = outfit.lookLegs or outfit.legs or 0,
		lookFeet = outfit.lookFeet or outfit.feet or 0,
		lookAddons = outfit.lookAddons or outfit.addons or 0,
		lookMount = outfit.lookMount or outfit.mount or 0,
		lookWings = outfit.lookWings or outfit.wings or 0,
		lookAura = outfit.lookAura or outfit.aura or 0,
		lookShader = outfit.lookShader or outfit.shader or ""
	}
end

local function withMonsterOutfit(entry)
	local data = {}
	for key, value in pairs(entry) do
		data[key] = value
	end
	data.outfit = data.outfit or getOutfitData(data.name)
	return data
end

local function copyMonsterList(list)
	local copied = {}
	for _, entry in ipairs(list or {}) do
		copied[#copied + 1] = withMonsterOutfit(entry)
	end
	return copied
end

local function copyWeeklyItems(player, list)
	local copied = {}
	for _, entry in ipairs(list or {}) do
		local itemType = entry.itemId and ItemType(entry.itemId)
		if itemType and itemType:isPickupable() then
			local data = {}
			for key, value in pairs(entry) do
				data[key] = value
			end
			data.clientId = itemType:getClientId()
			data.name = itemType:getName()
			data.current = math.min(tonumber(data.current) or 0, tonumber(data.total) or 0)
			data.owned = player:getItemCount(data.itemId)
			data.state = data.current >= (tonumber(data.total) or 0) and 1 or 0
			data.claimed = data.state
			copied[#copied + 1] = data
		end
	end
	return copied
end

local function normalizeWeeklySlots(value)
	return math.max(weeklyDefaultTaskSlots, math.min(weeklyTaskSlots, tonumber(value) or weeklyDefaultTaskSlots))
end

local function getWeeklyUnlocks(player)
	local resultId = db.storeQuery("SELECT `kill_slots`, `delivery_slots` FROM `player_taskboard_weekly_unlocks` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		return {
			killSlots = weeklyDefaultTaskSlots,
			deliverySlots = weeklyDefaultTaskSlots,
		}
	end

	local unlocks = {
		killSlots = normalizeWeeklySlots(result.getDataInt(resultId, "kill_slots")),
		deliverySlots = normalizeWeeklySlots(result.getDataInt(resultId, "delivery_slots")),
	}
	result.free(resultId)
	return unlocks
end

local function saveWeeklyUnlocks(player, unlocks)
	db.query(string.format(
		"REPLACE INTO `player_taskboard_weekly_unlocks` (`player_id`, `kill_slots`, `delivery_slots`, `updated_at`) VALUES (%d, %d, %d, %d)",
		player:getGuid(),
		normalizeWeeklySlots(unlocks.killSlots),
		normalizeWeeklySlots(unlocks.deliverySlots),
		os.time()
	))
end

local function markWeeklySlotLocks(monsters, items, unlocks)
	local killSlots = normalizeWeeklySlots(unlocks and unlocks.killSlots)
	local deliverySlots = normalizeWeeklySlots(unlocks and unlocks.deliverySlots)
	for _, monster in ipairs(monsters or {}) do
		local slot = (tonumber(monster.slotIndex) or 0) + 1
		monster.locked = slot > killSlots and 1 or 0
		monster.unlockCost = weeklyKillSlotUnlockCost
	end
	for _, item in ipairs(items or {}) do
		local slot = (tonumber(item.slotIndex) or 0) + 1
		item.locked = slot > deliverySlots and 1 or 0
		item.unlockCost = weeklyDeliverySlotUnlockCost
		if item.locked == 1 then
			item.needsDelivery = false
			item.canDeliver = false
		end
	end
end

local function createTables()
	db.query("CREATE TABLE IF NOT EXISTS `player_taskboard_shop_purchases` (`player_id` int NOT NULL, `offer_id` int NOT NULL, `amount` int unsigned NOT NULL DEFAULT 1, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`, `offer_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	db.query("CREATE TABLE IF NOT EXISTS `player_taskboard_weekly` (`player_id` int NOT NULL, `difficulty` tinyint unsigned NOT NULL DEFAULT 0, `expires_at` bigint unsigned NOT NULL DEFAULT 0, `monsters` text NOT NULL, `items` text NOT NULL, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	db.query("CREATE TABLE IF NOT EXISTS `player_taskboard_weekly_unlocks` (`player_id` int NOT NULL, `kill_slots` tinyint unsigned NOT NULL DEFAULT 6, `delivery_slots` tinyint unsigned NOT NULL DEFAULT 6, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	db.query("CREATE TABLE IF NOT EXISTS `player_taskboard_bounty` (`player_id` int NOT NULL, `difficulty` tinyint unsigned NOT NULL DEFAULT 3, `reroll_points` int unsigned NOT NULL DEFAULT 1, `claim_daily` tinyint unsigned NOT NULL DEFAULT 1, `unlocked_slots` tinyint unsigned NOT NULL DEFAULT 1, `monsters` text NOT NULL, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	db.query("CREATE TABLE IF NOT EXISTS `player_taskboard_bounty_preferences` (`player_id` int NOT NULL, `unlocked_slots` tinyint unsigned NOT NULL DEFAULT 1, `preferred` text NOT NULL, `unwanted` text NOT NULL, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	db.query("CREATE TABLE IF NOT EXISTS `player_taskboard_bounty_talisman` (`player_id` int NOT NULL, `stat1` tinyint unsigned NOT NULL DEFAULT 0, `stat2` tinyint unsigned NOT NULL DEFAULT 0, `stat3` tinyint unsigned NOT NULL DEFAULT 0, `stat4` tinyint unsigned NOT NULL DEFAULT 0, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	db.query("CREATE TABLE IF NOT EXISTS `player_prey_resources` (`player_id` int NOT NULL, `wildcards` int unsigned NOT NULL DEFAULT 0, `hunting_task_tokens` int unsigned NOT NULL DEFAULT 0, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	local resultId = db.storeQuery("SHOW COLUMNS FROM `player_prey_resources` LIKE 'hunting_task_tokens'")
	if resultId then
		result.free(resultId)
	else
		db.query("ALTER TABLE `player_prey_resources` ADD COLUMN `hunting_task_tokens` int unsigned NOT NULL DEFAULT 0 AFTER `wildcards`;")
	end
	resultId = db.storeQuery("SHOW COLUMNS FROM `player_prey_resources` LIKE 'bounty_points'")
	if resultId then
		result.free(resultId)
	else
		db.query("ALTER TABLE `player_prey_resources` ADD COLUMN `bounty_points` int unsigned NOT NULL DEFAULT 0 AFTER `hunting_task_tokens`;")
	end
	resultId = db.storeQuery("SHOW COLUMNS FROM `player_taskboard_bounty` LIKE 'unlocked_slots'")
	if resultId then
		result.free(resultId)
	else
		db.query("ALTER TABLE `player_taskboard_bounty` ADD COLUMN `unlocked_slots` tinyint unsigned NOT NULL DEFAULT 1 AFTER `claim_daily`;")
	end
	resultId = db.storeQuery("SHOW COLUMNS FROM `player_prey_resources` LIKE 'soulseal_points'")
	if resultId then
		result.free(resultId)
	else
		db.query("ALTER TABLE `player_prey_resources` ADD COLUMN `soulseal_points` int unsigned NOT NULL DEFAULT 0 AFTER `bounty_points`;")
	end
end

local function getTaskTokens(player)
	local resultId = db.storeQuery("SELECT `hunting_task_tokens` FROM `player_prey_resources` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		return 0
	end

	local tokens = result.getDataInt(resultId, "hunting_task_tokens")
	result.free(resultId)
	return math.max(0, tokens)
end

local function ensureResourceRow(player)
	db.query(string.format("INSERT IGNORE INTO `player_prey_resources` (`player_id`, `wildcards`, `hunting_task_tokens`, `bounty_points`, `soulseal_points`, `updated_at`) VALUES (%d, 0, 0, 0, 0, %d)", player:getGuid(), os.time()))
end

local function getBountyPoints(player)
	local resultId = db.storeQuery("SELECT `bounty_points` FROM `player_prey_resources` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		return 0
	end

	local points = result.getDataInt(resultId, "bounty_points")
	result.free(resultId)
	return math.max(0, points)
end

local function addBountyPoints(player, amount)
	amount = math.max(0, tonumber(amount) or 0)
	if amount <= 0 then
		return
	end
	ensureResourceRow(player)
	db.query(string.format("UPDATE `player_prey_resources` SET `bounty_points` = `bounty_points` + %d, `updated_at` = %d WHERE `player_id` = %d", amount, os.time(), player:getGuid()))
end

local function removeBountyPoints(player, amount)
	amount = math.max(0, tonumber(amount) or 0)
	if amount <= 0 then
		return true
	end

	if getBountyPoints(player) < amount then
		return false
	end

	db.query(string.format("UPDATE `player_prey_resources` SET `bounty_points` = `bounty_points` - %d, `updated_at` = %d WHERE `player_id` = %d", amount, os.time(), player:getGuid()))
	return true
end

local function getSoulsealPoints(player)
	local resultId = db.storeQuery("SELECT `soulseal_points` FROM `player_prey_resources` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		return 0
	end

	local points = result.getDataInt(resultId, "soulseal_points")
	result.free(resultId)
	return math.max(0, points)
end

local function addSoulsealPoints(player, amount)
	amount = math.max(0, tonumber(amount) or 0)
	if amount <= 0 then
		return
	end
	ensureResourceRow(player)
	db.query(string.format("UPDATE `player_prey_resources` SET `soulseal_points` = `soulseal_points` + %d, `updated_at` = %d WHERE `player_id` = %d", amount, os.time(), player:getGuid()))
end

local function removeSoulsealPoints(player, amount)
	amount = math.max(0, tonumber(amount) or 0)
	if amount <= 0 then
		return true
	end

	if getSoulsealPoints(player) < amount then
		return false
	end

	db.query(string.format("UPDATE `player_prey_resources` SET `soulseal_points` = `soulseal_points` - %d, `updated_at` = %d WHERE `player_id` = %d", amount, os.time(), player:getGuid()))
	return true
end

local function addTaskTokens(player, amount)
	amount = math.max(0, tonumber(amount) or 0)
	if amount <= 0 then
		return
	end
	ensureResourceRow(player)
	db.query(string.format("UPDATE `player_prey_resources` SET `hunting_task_tokens` = `hunting_task_tokens` + %d, `updated_at` = %d WHERE `player_id` = %d", amount, os.time(), player:getGuid()))
end

local function removeTaskTokens(player, amount)
	amount = math.max(0, tonumber(amount) or 0)
	if amount <= 0 then
		return true
	end

	if getTaskTokens(player) < amount then
		return false
	end

	db.query(string.format("UPDATE `player_prey_resources` SET `hunting_task_tokens` = `hunting_task_tokens` - %d, `updated_at` = %d WHERE `player_id` = %d", amount, os.time(), player:getGuid()))
	return true
end

local function decodeJson(raw, fallback)
	if type(raw) ~= "string" or raw == "" then
		return fallback
	end
	local ok, decoded = pcall(json.decode, raw)
	if ok and type(decoded) == "table" then
		return decoded
	end
	return fallback
end

local chooseEntries

local function isBountyMonsterAvailable(entry, difficulty)
	local difficulties = entry and entry.difficulties
	if difficulties == nil then
		return true
	end
	if type(difficulties) == "number" then
		return difficulties == difficulty
	end
	if type(difficulties) == "table" then
		for _, allowedDifficulty in ipairs(difficulties) do
			if tonumber(allowedDifficulty) == difficulty then
				return true
			end
		end
	end
	return false
end

local function getBountyMonsterPool(difficulty)
	difficulty = math.max(1, math.min(5, tonumber(difficulty) or 3))
	local pool = {}
	for _, entry in ipairs(bountyMonsters) do
		if (tonumber(entry.raceId) or 0) > 0 and isBountyMonsterAvailable(entry, difficulty) then
			pool[#pool + 1] = entry
		end
	end
	if #pool > 0 then
		return pool
	end

	local weeklyConfig = weeklyDifficultyConfig[math.max(1, math.min(5, tonumber(difficulty) or 3))]
	if not weeklyConfig or type(weeklyConfig.monsters) ~= "table" then
		return bountyMonsters
	end

	local generated = {}
	for _, entry in ipairs(weeklyConfig.monsters) do
		if (tonumber(entry.raceId) or 0) > 0 then
			local total = tonumber(entry.total) or 100
			generated[#generated + 1] = {
				raceId = tonumber(entry.raceId) or 0,
				name = entry.name,
				currentKills = 0,
				totalKills = total,
				rarity = 0,
				rewardXp = math.max(50000, total * 1800),
				rewardPoints = 1,
				rewardReroll = 1,
				isActive = 0,
				isCompleted = 0,
			}
		end
	end
	return #generated > 0 and generated or pool
end

local function normalizePreferenceList(list, unlockedSlots)
	local normalized = {}
	local seen = {}
	unlockedSlots = math.max(1, math.min(bountyPreferenceSlots, tonumber(unlockedSlots) or 1))
	for slot = 1, unlockedSlots do
		local raceId = tonumber((list or {})[slot]) or 0
		raceId = tonumber(raceId) or 0
		if raceId > 0 and not seen[raceId] then
			normalized[slot] = raceId
			seen[raceId] = true
		else
			normalized[slot] = 0
		end
	end
	return normalized
end

local function getBountyPreferences(player)
	local resultId = db.storeQuery("SELECT `unlocked_slots`, `preferred`, `unwanted` FROM `player_taskboard_bounty_preferences` WHERE `player_id` = " .. player:getGuid())
	if resultId then
		local unlockedSlots = math.max(1, math.min(bountyPreferenceSlots, result.getDataInt(resultId, "unlocked_slots")))
		local preferences = {
			unlockedSlots = unlockedSlots,
			preferred = normalizePreferenceList(decodeJson(result.getDataString(resultId, "preferred"), {}), unlockedSlots),
			unwanted = normalizePreferenceList(decodeJson(result.getDataString(resultId, "unwanted"), {}), unlockedSlots),
		}
		result.free(resultId)
		return preferences
	end

	return {
		unlockedSlots = 1,
		preferred = {},
		unwanted = {},
	}
end

local function saveBountyPreferences(player, preferences)
	local unlockedSlots = math.max(1, math.min(bountyPreferenceSlots, tonumber(preferences.unlockedSlots) or 1))
	db.query(string.format(
		"REPLACE INTO `player_taskboard_bounty_preferences` (`player_id`, `unlocked_slots`, `preferred`, `unwanted`, `updated_at`) VALUES (%d, %d, %s, %s, %d)",
		player:getGuid(),
		unlockedSlots,
		db.escapeString(json.encode(normalizePreferenceList(preferences.preferred, unlockedSlots))),
		db.escapeString(json.encode(normalizePreferenceList(preferences.unwanted, unlockedSlots))),
		os.time()
	))
end

local function listHasRaceId(list, raceId)
	raceId = tonumber(raceId) or 0
	for _, value in ipairs(list or {}) do
		if (tonumber(value) or 0) == raceId then
			return true
		end
	end
	return false
end

local function getBountyPreferenceMonsterPage(preferences, search, page)
	local used = {}
	for _, raceId in ipairs(preferences and preferences.preferred or {}) do
		raceId = tonumber(raceId) or 0
		if raceId > 0 then
			used[raceId] = true
		end
	end
	for _, raceId in ipairs(preferences and preferences.unwanted or {}) do
		raceId = tonumber(raceId) or 0
		if raceId > 0 then
			used[raceId] = true
		end
	end

	local byRace = {}
	local difficultyLookup = {}
	for difficulty = 1, 5 do
		for _, entry in ipairs(getBountyMonsterPool(difficulty)) do
			local raceId = tonumber(entry.raceId) or 0
			if raceId > 0 and not used[raceId] then
				local data = byRace[raceId]
				if not data then
					data = {}
					for key, value in pairs(entry) do
						data[key] = value
					end
					data.difficulties = {}
					data.difficultyText = ""
					byRace[raceId] = data
					difficultyLookup[raceId] = {}
				end
				if not difficultyLookup[raceId][difficulty] then
					difficultyLookup[raceId][difficulty] = true
					data.difficulties[#data.difficulties + 1] = difficulty
				end
			end
		end
	end

	local filter = tostring(search or ""):lower()
	local monsters = {}
	for _, entry in pairs(byRace) do
		local name = tostring(entry.name or "")
		if filter == "" or name:lower():find(filter, 1, true) then
			local names = {}
			for _, difficulty in ipairs(entry.difficulties or {}) do
				names[#names + 1] = bountyDifficultyNames[difficulty] or tostring(difficulty)
			end
			entry.difficultyText = table.concat(names, ", ")
			monsters[#monsters + 1] = withMonsterOutfit(entry)
		end
	end

	table.sort(monsters, function(a, b)
		return tostring(a.name or ""):lower() < tostring(b.name or ""):lower()
	end)

	local total = #monsters
	local totalPages = math.max(1, math.ceil(total / bountyPreferencePageSize))
	page = math.max(1, math.min(totalPages, tonumber(page) or 1))
	local offset = (page - 1) * bountyPreferencePageSize
	local paged = {}
	for index = offset + 1, math.min(offset + bountyPreferencePageSize, total) do
		paged[#paged + 1] = monsters[index]
	end

	return {
		monsters = paged,
		page = page,
		totalPages = totalPages,
		total = total,
		pageSize = bountyPreferencePageSize,
		search = search or "",
	}
end

local function getBountyPreferenceMonsterDisplay(raceId)
	raceId = tonumber(raceId) or 0
	if raceId <= 0 then
		return nil
	end

	local found
	local difficulties = {}
	local difficultyLookup = {}
	for difficulty = 1, 5 do
		for _, entry in ipairs(getBountyMonsterPool(difficulty)) do
			if (tonumber(entry.raceId) or 0) == raceId then
				if not found then
					found = {}
					for key, value in pairs(entry) do
						found[key] = value
					end
				end
				if not difficultyLookup[difficulty] then
					difficultyLookup[difficulty] = true
					difficulties[#difficulties + 1] = bountyDifficultyNames[difficulty] or tostring(difficulty)
				end
				break
			end
		end
	end

	if not found then
		return { raceId = raceId, name = "Creature " .. raceId, difficultyText = "" }
	end

	found.difficultyText = table.concat(difficulties, ", ")
	return withMonsterOutfit(found)
end

local function saveBountyRecord(player, record)
	bountyActiveTargetCache[player:getGuid()] = nil
	db.query(string.format(
		"REPLACE INTO `player_taskboard_bounty` (`player_id`, `difficulty`, `reroll_points`, `claim_daily`, `unlocked_slots`, `monsters`, `updated_at`) VALUES (%d, %d, %d, %d, %d, %s, %d)",
		player:getGuid(),
		tonumber(record.difficulty) or 3,
		tonumber(record.rerollPoints) or 0,
		tonumber(record.claimDaily) or 0,
		math.max(1, math.min(bountyTaskSlots, tonumber(record.unlockedSlots) or 1)),
		db.escapeString(json.encode(record.monsters or {})),
		os.time()
	))
end

local function getBountyTaskDuration(totalKills)
	totalKills = tonumber(totalKills) or 0
	if totalKills <= 250 then
		return daySeconds
	elseif totalKills <= 800 then
		return 2 * daySeconds
	end
	return 3 * daySeconds
end

local function buildBountyTask(entry, taskIndex, difficulty)
	local task = {}
	for key, value in pairs(entry) do
		task[key] = value
	end
	difficulty = math.max(1, math.min(5, tonumber(difficulty) or 3))
	local config = bountyDifficultyTaskConfig[difficulty] or bountyDifficultyTaskConfig[3]
	local rarityRoll = math.random(1, 100)
	local rarity = rarityRoll <= 10 and 2 or (rarityRoll <= 50 and 1 or 0)
	local multiplier = bountyRarityMultipliers[rarity] or 1
	local totalKills = math.random(config.minKills, config.maxKills)
	task.taskIndex = taskIndex
	task.currentKills = 0
	task.totalKills = totalKills
	task.rarity = rarity
	task.rewardXp = math.floor(math.max(50000, totalKills * 1800) * multiplier)
	task.rewardPoints = math.max(1, math.floor((tonumber(config.points) or 1) * multiplier))
	task.rewardReroll = tonumber(entry.rewardReroll) or 1
	task.isActive = 0
	task.isCompleted = 0
	task.expiresAt = 0
	return task
end

local function chooseWeightedBountyEntries(pool, count, preferences)
	local available = {}
	local preferred = preferences and preferences.preferred or {}
	local unwanted = preferences and preferences.unwanted or {}

	for _, entry in ipairs(pool or {}) do
		if not listHasRaceId(unwanted, entry.raceId) then
			local weight = listHasRaceId(preferred, entry.raceId) and 5 or 1
			available[#available + 1] = { entry = entry, weight = weight }
		end
	end
	if #available == 0 then
		for _, entry in ipairs(pool or {}) do
			available[#available + 1] = { entry = entry, weight = 1 }
		end
	end

	local chosen = {}
	while #available > 0 and #chosen < count do
		local totalWeight = 0
		for _, weighted in ipairs(available) do
			totalWeight = totalWeight + weighted.weight
		end
		local roll = math.random(1, math.max(1, totalWeight))
		local index = 1
		for i, weighted in ipairs(available) do
			roll = roll - weighted.weight
			if roll <= 0 then
				index = i
				break
			end
		end
		chosen[#chosen + 1] = available[index].entry
		table.remove(available, index)
	end
	return chosen
end

local function rollSingleBountyTask(difficulty, taskIndex, preferences)
	local pool = getBountyMonsterPool(difficulty)
	local chosen = chooseWeightedBountyEntries(pool, 1, preferences)
	local entry = chosen[1] or pool[math.random(1, #pool)]
	return buildBountyTask(entry, taskIndex, difficulty)
end

local function rollBountyTasks(difficulty, preferences)
	local chosen = chooseWeightedBountyEntries(getBountyMonsterPool(difficulty), bountyTaskSlots, preferences)
	local tasks = {}
	for index, entry in ipairs(chosen) do
		tasks[#tasks + 1] = buildBountyTask(entry, index, difficulty)
	end
	return tasks
end

local function getBountyRecord(player)
	local resultId = db.storeQuery("SELECT `difficulty`, `reroll_points`, `claim_daily`, `unlocked_slots`, `monsters` FROM `player_taskboard_bounty` WHERE `player_id` = " .. player:getGuid())
	if resultId then
		local record = {
			difficulty = math.max(1, math.min(5, result.getDataInt(resultId, "difficulty"))),
			rerollPoints = math.max(0, result.getDataInt(resultId, "reroll_points")),
			claimDaily = math.max(0, result.getDataInt(resultId, "claim_daily")),
			unlockedSlots = math.max(1, math.min(bountyTaskSlots, result.getDataInt(resultId, "unlocked_slots"))),
			monsters = decodeJson(result.getDataString(resultId, "monsters"), {}),
		}
		result.free(resultId)
		if #record.monsters > 0 then
			return record
		end
	end

	local record = {
		difficulty = 3,
		rerollPoints = 1,
		claimDaily = 1,
		unlockedSlots = 1,
		monsters = rollBountyTasks(3, getBountyPreferences(player)),
	}
	saveBountyRecord(player, record)
	return record
end

local function refreshExpiredBountyTasks(player, record)
	local changed = false
	local now = os.time()
	local preferences = getBountyPreferences(player)
	for index, task in ipairs(record.monsters or {}) do
		local expiresAt = tonumber(task.expiresAt) or 0
		if expiresAt > 0 and expiresAt <= now and tonumber(task.isCompleted) ~= 1 then
			record.monsters[index] = rollSingleBountyTask(record.difficulty, tonumber(task.taskIndex) or index, preferences)
			changed = true
		end
	end
	if changed then
		saveBountyRecord(player, record)
	end
	return record
end

function TaskBoard.getActiveBountyTasks(player)
	if not player or not player:isPlayer() then
		return {}
	end

	local guid = player:getGuid()
	if bountyActiveTargetCache[guid] ~= nil then
		return bountyActiveTargetCache[guid]
	end

	local record = refreshExpiredBountyTasks(player, getBountyRecord(player))
	local tasks = {}
	local unlockedSlots = math.max(1, math.min(bountyTaskSlots, tonumber(record.unlockedSlots) or 1))
	for _, task in ipairs(record.monsters or {}) do
		if (tonumber(task.taskIndex) or 0) <= unlockedSlots and tonumber(task.isActive) == 1 and tonumber(task.isCompleted) ~= 1 then
			tasks[#tasks + 1] = task
		end
	end

	bountyActiveTargetCache[guid] = tasks
	return tasks
end

function TaskBoard.isActiveBountyTarget(player, target)
	if not target or not target:isMonster() then
		return false
	end

	local tasks = TaskBoard.getActiveBountyTasks(player)
	if #tasks == 0 then
		return false
	end

	local targetName = tostring(target:getName() or ""):lower()
	for _, task in ipairs(tasks) do
		if (tonumber(task.raceId) or 0) == 0 or tostring(task.name or ""):lower() == targetName then
			return true
		end
	end
	return false
end

local function saveTalismanLevels(player, levels)
	db.query(string.format(
		"REPLACE INTO `player_taskboard_bounty_talisman` (`player_id`, `stat1`, `stat2`, `stat3`, `stat4`, `updated_at`) VALUES (%d, %d, %d, %d, %d, %d)",
		player:getGuid(),
		math.max(0, math.min(bountyTalismanMaxLevels[1] or 0, tonumber(levels[1]) or 0)),
		math.max(0, math.min(bountyTalismanMaxLevels[2] or 0, tonumber(levels[2]) or 0)),
		math.max(0, math.min(bountyTalismanMaxLevels[3] or 0, tonumber(levels[3]) or 0)),
		math.max(0, math.min(bountyTalismanMaxLevels[4] or 0, tonumber(levels[4]) or 0)),
		os.time()
	))
end

local function getTalismanLevels(player)
	local resultId = db.storeQuery("SELECT `stat1`, `stat2`, `stat3`, `stat4` FROM `player_taskboard_bounty_talisman` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		local levels = { 0, 0, 0, 0 }
		saveTalismanLevels(player, levels)
		return levels
	end

	local levels = {
		result.getDataInt(resultId, "stat1"),
		result.getDataInt(resultId, "stat2"),
		result.getDataInt(resultId, "stat3"),
		result.getDataInt(resultId, "stat4"),
	}
	result.free(resultId)
	return levels
end

local function getTalismanMaxLevel(index)
	return math.max(0, tonumber(bountyTalismanMaxLevels[index]) or 0)
end

local function getTalismanUpgradeCost(level, index)
	level = math.max(0, tonumber(level) or 0)
	index = math.max(1, math.min(4, tonumber(index) or 1))
	local maxLevel = getTalismanMaxLevel(index)
	if level >= maxLevel then
		return 0
	end

	local explicitCost = bountyTalismanUpgradeCosts[level + 1]
	if explicitCost then
		return explicitCost
	end

	if maxLevel <= 25 then
		return 2000
	end

	local remainingLevels = maxLevel - 25
	local progress = math.max(0, math.min(remainingLevels, level - 25 + 1))
	return math.floor(2000 + ((5000 - 2000) * progress / remainingLevels))
end

local function getTalismanPayload(player)
	local levels = getTalismanLevels(player)
	local payload = {}
	for index = 1, 4 do
		local maxLevel = getTalismanMaxLevel(index)
		local level = math.max(0, math.min(maxLevel, tonumber(levels[index]) or 0))
		local base = bountyTalismanBaseValues[index] or 0
		local step = bountyTalismanStepValues[index] or 0
		payload[index] = {
			level = level,
			maxLevel = maxLevel,
			currentValue = base + (step * level),
			nextValue = level >= maxLevel and 0 or base + (step * (level + 1)),
			upgradeCost = level >= maxLevel and 0 or getTalismanUpgradeCost(level, index),
		}
	end
	return payload
end

local function getBountyPreferencePayload(player, difficulty, search, page)
	local preferences = getBountyPreferences(player)
	local monsterPage = getBountyPreferenceMonsterPage(preferences, search, page)
	local prefSlots = {}
	for slot = 1, bountyPreferenceSlots do
		local preferredId = tonumber(preferences.preferred[slot]) or 0
		local unwantedId = tonumber(preferences.unwanted[slot]) or 0
		local preferredData = getBountyPreferenceMonsterDisplay(preferredId)
		local unwantedData = getBountyPreferenceMonsterDisplay(unwantedId)
		prefSlots[#prefSlots + 1] = {
			slot = slot,
			locked = slot > preferences.unlockedSlots and 1 or 0,
			price = bountyPreferenceUnlockCosts[slot] or 0,
			preferred = preferredId,
			preferredName = preferredData and preferredData.name or "",
			preferredOutfit = preferredData and preferredData.outfit or nil,
			preferredDifficultyText = preferredData and preferredData.difficultyText or "",
			unwanted = unwantedId,
			unwantedName = unwantedData and unwantedData.name or "",
			unwantedOutfit = unwantedData and unwantedData.outfit or nil,
			unwantedDifficultyText = unwantedData and unwantedData.difficultyText or "",
		}
	end
	return {
		clearCost = bountyPreferenceClearCost,
		slots = prefSlots,
		removeCost = 0,
		availableMonsters = monsterPage.monsters,
		page = monsterPage.page,
		totalPages = monsterPage.totalPages,
		total = monsterPage.total,
		pageSize = monsterPage.pageSize,
		search = monsterPage.search,
	}
end

local function getBountyPayload(player)
	local record = refreshExpiredBountyTasks(player, getBountyRecord(player))
	return {
		header = {
			rerollPoints = record.rerollPoints,
			claimDaily = record.claimDaily,
			difficulty = record.difficulty,
			rerollCost = bountyRerollCost,
			unlockedSlots = math.max(1, math.min(bountyTaskSlots, tonumber(record.unlockedSlots) or 1)),
			unlockCosts = bountyTaskUnlockCosts,
		},
		monsters = copyMonsterList(record.monsters),
		talisman = getTalismanPayload(player),
	}
end

local function getWeeklyRecord(player)
	local resultId = db.storeQuery("SELECT `difficulty`, `expires_at`, `monsters`, `items` FROM `player_taskboard_weekly` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		return nil
	end

	local record = {
		difficulty = result.getDataInt(resultId, "difficulty"),
		expiresAt = result.getDataInt(resultId, "expires_at"),
		monsters = decodeJson(result.getDataString(resultId, "monsters"), {}),
		items = decodeJson(result.getDataString(resultId, "items"), {}),
	}
	result.free(resultId)
	return record
end

local function countCompleted(list, unlockedSlots)
	local completed = 0
	for _, entry in ipairs(list or {}) do
		local slot = (tonumber(entry.slotIndex) or 0) + 1
		if slot <= normalizeWeeklySlots(unlockedSlots) and ((tonumber(entry.state) or 0) == 1 or entry.finished == true or (tonumber(entry.claimed) or 0) == 1) then
			completed = completed + 1
		end
	end
	return completed
end

local function calcWeeklyRewards(record, unlocks)
	local difficulty = tonumber(record and record.difficulty) or 0
	local killPoints = weeklyKillPoints[difficulty] or weeklyKillPoints[1]
	local completedKills = countCompleted(record and record.monsters, unlocks and unlocks.killSlots)
	local completedDeliveries = countCompleted(record and record.items, unlocks and unlocks.deliverySlots)
	local config = weeklyDifficultyConfig[difficulty] or weeklyDifficultyConfig[1] or {}
	local completedTasks = completedKills + completedDeliveries
	return {
		kills = completedKills,
		deliveries = completedDeliveries,
		points = completedKills * killPoints + completedDeliveries * weeklyDeliveryPoints,
		soulseals = completedTasks * weeklySoulsealsPerTask,
		experience = completedTasks * (tonumber(config.xp) or 0),
	}
end

local function finishExpiredWeekly(player, record)
	if not record or record.expiresAt <= 0 or record.expiresAt > os.time() then
		return record, nil
	end

	local rewards = calcWeeklyRewards(record, getWeeklyUnlocks(player))
	addTaskTokens(player, rewards.points)
	addSoulsealPoints(player, rewards.soulseals)
	if player.addExperience and (tonumber(rewards.experience) or 0) > 0 then
		player:addExperience(tonumber(rewards.experience) or 0, true)
	end
	weeklyFinishedSummaryCache[player:getGuid()] = {
		record = record,
		rewards = rewards,
		time = os.time(),
	}
	db.query("DELETE FROM `player_taskboard_weekly` WHERE `player_id` = " .. player:getGuid())
	return nil, rewards, record
end

function chooseEntries(pool, count)
	local available = {}
	for _, entry in ipairs(pool or {}) do
		available[#available + 1] = entry
	end

	local chosen = {}
	while #available > 0 and #chosen < count do
		local index = math.random(1, #available)
		chosen[#chosen + 1] = available[index]
		table.remove(available, index)
	end
	return chosen
end

local function rollEntryTotal(entry)
	local minTotal = tonumber(entry and entry.minTotal)
	local maxTotal = tonumber(entry and entry.maxTotal)
	if minTotal and maxTotal then
		minTotal = math.max(1, math.floor(minTotal))
		maxTotal = math.max(minTotal, math.floor(maxTotal))
		return math.random(minTotal, maxTotal)
	end
	return tonumber(entry and entry.total) or 0
end

local function getValidWeeklyItems(config)
	local items = {}
	for _, entry in ipairs(config and config.items or {}) do
		local itemType = entry.itemId and ItemType(entry.itemId)
		if itemType and itemType:isPickupable() then
			items[#items + 1] = entry
		end
	end
	return items
end

local function appendWeeklyItemTask(items, entry)
	items[#items + 1] = {
		slotIndex = #items,
		itemId = entry.itemId,
		current = 0,
		total = rollEntryTotal(entry),
		state = 0,
		claimed = 0,
	}
end

local function ensureWeeklyDeliverySlots(player, record)
	if record then
		record.items = record.items or {}
	end
	if not record or #(record.items or {}) >= weeklyTaskSlots then
		return false
	end

	local config = weeklyDifficultyConfig[record.difficulty] or weeklyDifficultyConfig[1]
	local pool = getValidWeeklyItems(config)
	while #(record.items or {}) < weeklyTaskSlots and #pool > 0 do
		local index = math.random(1, #pool)
		appendWeeklyItemTask(record.items, pool[index])
		table.remove(pool, index)
	end

	return #(record.items or {}) >= weeklyTaskSlots
end

local function rollWeeklyTasks(player, difficulty)
	local config = weeklyDifficultyConfig[difficulty]
	if not config then
		return false
	end
	weeklyFinishedSummaryCache[player:getGuid()] = nil

	local monsters = {}
	for slotIndex, entry in ipairs(chooseEntries(config.monsters, weeklyTaskSlots)) do
		monsters[#monsters + 1] = {
			slotIndex = slotIndex - 1,
			raceId = entry.raceId,
			name = entry.name,
			current = 0,
			total = rollEntryTotal(entry),
			state = 0,
		}
	end

	local items = {}
	for _, entry in ipairs(chooseEntries(getValidWeeklyItems(config), weeklyTaskSlots)) do
		appendWeeklyItemTask(items, entry)
	end

	db.query(string.format(
		"REPLACE INTO `player_taskboard_weekly` (`player_id`, `difficulty`, `expires_at`, `monsters`, `items`, `updated_at`) VALUES (%d, %d, %d, %s, %s, %d)",
		player:getGuid(),
		difficulty,
		os.time() + weeklyDuration,
		db.escapeString(json.encode(monsters)),
		db.escapeString(json.encode(items)),
		os.time()
	))
	return true
end

local function saveWeeklyItems(player, difficulty, expiresAt, monsters, items)
	db.query(string.format(
		"REPLACE INTO `player_taskboard_weekly` (`player_id`, `difficulty`, `expires_at`, `monsters`, `items`, `updated_at`) VALUES (%d, %d, %d, %s, %s, %d)",
		player:getGuid(),
		difficulty,
		expiresAt,
		db.escapeString(json.encode(monsters or {})),
		db.escapeString(json.encode(items or {})),
		os.time()
	))
end

local function getPurchases(player)
	local purchases = {}
	local resultId = db.storeQuery("SELECT `offer_id`, `amount` FROM `player_taskboard_shop_purchases` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		return purchases
	end

	repeat
		purchases[result.getDataInt(resultId, "offer_id")] = result.getDataInt(resultId, "amount")
	until not result.next(resultId)
	result.free(resultId)
	return purchases
end

local function getOffer(offerId)
	for _, offer in ipairs(shopOffers or {}) do
		if offer.id == offerId then
			return offer
		end
	end
	return nil
end

local function copyOffer(offer, purchases)
	local data = {}
	for key, value in pairs(offer) do
		data[key] = value
	end

	local amount = tonumber(purchases[offer.id]) or 0
	local rotationRemaining = taskShopRotationSeconds - (os.time() % taskShopRotationSeconds)
	if rotationRemaining > 0 then
		local days = math.floor(rotationRemaining / daySeconds)
		local hours = math.floor((rotationRemaining % daySeconds) / 3600)
		local minutes = math.floor((rotationRemaining % 3600) / 60)
		if days > 0 then
			data.timerText = string.format("Rerolls in %dd %dh", days, hours)
		elseif hours > 0 then
			data.timerText = string.format("Rerolls in %dh %dm", hours, minutes)
		else
			data.timerText = string.format("Rerolls in %dm", math.max(1, minutes))
		end
	else
		data.timerText = ""
	end
	data.bought = isPermanentShopOffer(data.offerType) and amount > 0 and 1 or 0
	if tonumber(data.maxPurchases) and tonumber(data.maxPurchases) > 0 then
		data.currentPurchases = amount
		data.bought = amount >= (tonumber(data.maxPurchases) or 0) and 1 or 0
	end
	return data
end

local function getRotatingShopOffers()
	local rotationIndex = math.floor(os.time() / taskShopRotationSeconds)
	local offers = {}
	local offerCount = math.min(#shopOffers, taskShopMaxOffers)
	for offset = 0, offerCount - 1 do
		local index = ((rotationIndex + offset) % #shopOffers) + 1
		offers[#offers + 1] = shopOffers[index]
	end
	return offers
end

local function getShopPage(player, page)
	local purchases = getPurchases(player)
	local offers = getRotatingShopOffers()
	local total = #offers
	local totalPages = math.max(1, math.ceil(total / taskShopPageSize))
	page = math.max(1, math.min(totalPages, tonumber(page) or 1))
	local firstIndex = ((page - 1) * taskShopPageSize) + 1
	local pageOffers = {}
	for index = firstIndex, math.min(total, firstIndex + taskShopPageSize - 1) do
		pageOffers[#pageOffers + 1] = copyOffer(offers[index], purchases)
	end
	return {
		items = pageOffers,
		page = page,
		totalPages = totalPages,
		total = total,
		pageSize = taskShopPageSize,
	}
end

local function getWeeklyPayload(player)
	local unlocks = getWeeklyUnlocks(player)
	local record, expiredRewards, expiredRecord = finishExpiredWeekly(player, getWeeklyRecord(player))
	if not record then
		local cachedSummary = weeklyFinishedSummaryCache[player:getGuid()]
		if cachedSummary then
			expiredRewards = expiredRewards or cachedSummary.rewards
			expiredRecord = expiredRecord or cachedSummary.record
		end
		local expiredDifficulty = tonumber(expiredRecord and expiredRecord.difficulty) or 0
		local expiredConfig = weeklyDifficultyConfig[expiredDifficulty] or weeklyDifficultyConfig[1] or {}
		return {
			header = {
				difficulty = expiredDifficulty,
				remainingDays = 0,
				totalTaskSlots = weeklyTaskSlots,
				unlockedKillSlots = unlocks.killSlots,
				unlockedDeliverySlots = unlocks.deliverySlots,
				defaultTaskSlots = weeklyDefaultTaskSlots,
				killSlotUnlockCost = weeklyKillSlotUnlockCost,
				deliverySlotUnlockCost = weeklyDeliverySlotUnlockCost,
				maxExperience = expiredConfig.xp or 0,
				maxDeliveryExperience = expiredConfig.xp or 0,
				completedKillTasks = expiredRewards and expiredRewards.kills or 0,
				completedDeliveryTasks = expiredRewards and expiredRewards.deliveries or 0,
				pointsEarned = expiredRewards and expiredRewards.points or 0,
				soulsealsEarned = expiredRewards and expiredRewards.soulseals or 0,
				experienceEarned = expiredRewards and expiredRewards.experience or 0,
				extraSlot = 0,
				weeklyProgressFinished = 1,
				currentPlayerLevel = player:getLevel(),
			},
			monsters = {},
			items = {},
		}
	end

	local config = weeklyDifficultyConfig[record.difficulty] or weeklyDifficultyConfig[1]
	if ensureWeeklyDeliverySlots(player, record) then
		saveWeeklyItems(player, record.difficulty, record.expiresAt, record.monsters, record.items)
	end
	local monsters = copyMonsterList(record.monsters)
	local items = copyWeeklyItems(player, record.items)
	markWeeklySlotLocks(monsters, items, unlocks)
	local rewards = calcWeeklyRewards({
		difficulty = record.difficulty,
		monsters = record.monsters,
		items = items,
	}, unlocks)

	return {
		header = {
			difficulty = record.difficulty,
			remainingDays = math.max(1, math.ceil((record.expiresAt - os.time()) / 86400)),
			totalTaskSlots = weeklyTaskSlots,
			unlockedKillSlots = unlocks.killSlots,
			unlockedDeliverySlots = unlocks.deliverySlots,
			defaultTaskSlots = weeklyDefaultTaskSlots,
			killSlotUnlockCost = weeklyKillSlotUnlockCost,
			deliverySlotUnlockCost = weeklyDeliverySlotUnlockCost,
			maxExperience = config.xp or 0,
			maxDeliveryExperience = config.xp or 0,
			completedKillTasks = rewards.kills,
			completedDeliveryTasks = rewards.deliveries,
			pointsEarned = rewards.points,
			soulsealsEarned = rewards.soulseals,
			experienceEarned = rewards.experience,
			extraSlot = 0,
			weeklyProgressFinished = 0,
			currentPlayerLevel = player:getLevel(),
		},
		monsters = monsters,
		items = items,
	}
end

local function buildState(player)
	return {
		action = "state",
		balances = {
			task = getTaskTokens(player),
			bounty = getBountyPoints(player),
			soulseal = getSoulsealPoints(player),
		},
	}
end

local function sendTaskBoardPayload(player, payload)
	local encoded = json.encode(payload)
	local maxChunkSize = 60000
	if #encoded <= maxChunkSize then
		player:sendExtendedOpcode(OPCODE_TASKBOARD, encoded)
		return
	end

	local chunks = {}
	for index = 1, #encoded, maxChunkSize do
		chunks[#chunks + 1] = encoded:sub(index, index + maxChunkSize - 1)
	end
	player:sendExtendedOpcode(OPCODE_TASKBOARD, "S" .. chunks[1])
	for index = 2, #chunks - 1 do
		player:sendExtendedOpcode(OPCODE_TASKBOARD, "P" .. chunks[index])
	end
	player:sendExtendedOpcode(OPCODE_TASKBOARD, "E" .. chunks[#chunks])
end

function TaskBoard.getBountyTalismanBonus(player, statType)
	local index = (tonumber(statType) or 0) + 1
	if index < 1 or index > 4 then
		return 0
	end

	local levels = getTalismanLevels(player)
	local level = math.max(0, math.min(getTalismanMaxLevel(index), tonumber(levels[index]) or 0))
	return (bountyTalismanBaseValues[index] or 0) + ((bountyTalismanStepValues[index] or 0) * level)
end

function TaskBoard.getBountyTalismanPercent(player, statType)
	return (TaskBoard.getBountyTalismanBonus(player, statType) or 0) / 100
end

local function scaleBountyDamage(damage, multiplier)
	damage = tonumber(damage) or 0
	multiplier = tonumber(multiplier) or 1
	if damage == 0 or multiplier == 1 then
		return damage
	end

	local scaled = math.floor(math.abs(damage) * multiplier)
	if scaled <= 0 then
		return 0
	end
	return damage < 0 and -scaled or scaled
end

function TaskBoard.applyBountyTalismanCombat(player, target, primaryDamage, primaryType, secondaryDamage, secondaryType)
	if not player or not player:isPlayer() or not target or not target:isMonster() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if not TaskBoard.isActiveBountyTarget(player, target) then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local damagePercent = TaskBoard.getBountyTalismanPercent(player, 0)
	if damagePercent > 0 then
		local multiplier = 1 + (damagePercent / 100)
		if primaryType ~= COMBAT_HEALING then
			primaryDamage = scaleBountyDamage(primaryDamage, multiplier)
		end
		if secondaryType ~= COMBAT_HEALING then
			secondaryDamage = scaleBountyDamage(secondaryDamage, multiplier)
		end
	end

	local leechPercent = TaskBoard.getBountyTalismanPercent(player, 1)
	local totalDamage = (primaryType ~= COMBAT_HEALING and math.abs(tonumber(primaryDamage) or 0) or 0)
		+ (secondaryType ~= COMBAT_HEALING and math.abs(tonumber(secondaryDamage) or 0) or 0)
	if leechPercent > 0 and totalDamage > 0 then
		local healAmount = math.floor(totalDamage * (leechPercent / 100))
		if healAmount > 0 then
			player:addHealth("healing", healAmount)
		end
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local bountyCombatEvent = CreatureEvent("TaskBoardBountyMonsterHealth")
function bountyCombatEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not creature:isMonster() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if not attacker or not attacker:isPlayer() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	return TaskBoard.applyBountyTalismanCombat(attacker, creature, primaryDamage, primaryType, secondaryDamage, secondaryType)
end
bountyCombatEvent:register()

local bountyTargetCombatEvent = EventCallback
function bountyTargetCombatEvent.onTargetCombat(creature, target)
	if creature and target and creature:isPlayer() and target:isMonster() then
		target:registerEvent("TaskBoardBountyMonsterHealth")
	end
	return RETURNVALUE_NOERROR
end
bountyTargetCombatEvent:register(7)

function TaskBoard.getBountyLootMultiplier(player, target)
	if not player or not player:isPlayer() or not TaskBoard.isActiveBountyTarget(player, target) then
		return 1
	end
	return 1 + ((TaskBoard.getBountyTalismanPercent(player, 2) or 0) / 100)
end

function TaskBoard.rollDoubleBestiaryProgress(player, target)
	if not player or not player:isPlayer() or not TaskBoard.isActiveBountyTarget(player, target) then
		return false
	end
	local chance = TaskBoard.getBountyTalismanPercent(player, 3)
	return chance > 0 and math.random(10000) <= math.floor(chance * 100)
end

function TaskBoard.sendState(player)
	sendTaskBoardPayload(player, buildState(player))
end

local function sendBountyState(player)
	sendTaskBoardPayload(player, {
		action = "bountyState",
		balances = {
			task = getTaskTokens(player),
			bounty = getBountyPoints(player),
			soulseal = getSoulsealPoints(player),
		},
		bounty = getBountyPayload(player),
	})
end

local function sendWeeklyState(player)
	sendTaskBoardPayload(player, {
		action = "weeklyState",
		balances = {
			task = getTaskTokens(player),
			bounty = getBountyPoints(player),
			soulseal = getSoulsealPoints(player),
		},
		weekly = getWeeklyPayload(player),
	})
end

local function sendShopState(player, page)
	sendTaskBoardPayload(player, {
		action = "shopState",
		balances = {
			task = getTaskTokens(player),
			bounty = getBountyPoints(player),
			soulseal = getSoulsealPoints(player),
		},
		shop = getShopPage(player, page),
	})
end

local function shouldPersistKillProgress(state, player, force)
	if force then
		state[player:getGuid()] = nil
		return true
	end

	local guid = player:getGuid()
	local data = state[guid] or { count = 0, time = 0 }
	data.count = (tonumber(data.count) or 0) + 1
	local now = os.time()
	local persist = data.count >= 5 or (now - (tonumber(data.time) or 0)) >= 3
	if persist then
		state[guid] = { count = 0, time = now }
	else
		state[guid] = data
	end
	return persist
end

local function sendWeeklyKillUpdate(player, task, record)
	local rewards = calcWeeklyRewards(record, getWeeklyUnlocks(player))
	sendTaskBoardPayload(player, {
		action = "weeklyKillUpdate",
		slotIndex = tonumber(task.slotIndex) or 0,
		raceId = tonumber(task.raceId) or 0,
		current = tonumber(task.current) or 0,
		total = tonumber(task.total) or 0,
		completed = tonumber(task.state) or 0,
		completedKillTasks = rewards.kills,
		pointsEarned = rewards.points,
		soulsealsEarned = rewards.soulseals,
	})
end

local function sendBountyKillUpdate(player, task)
	sendTaskBoardPayload(player, {
		action = "bountyKillUpdate",
		raceId = tonumber(task.raceId) or 0,
		current = tonumber(task.currentKills) or 0,
		total = tonumber(task.totalKills) or 0,
		completed = tonumber(task.isCompleted) or 0,
	})
end

local function sendPreferredState(player, search, page)
	local record = refreshExpiredBountyTasks(player, getBountyRecord(player))
	sendTaskBoardPayload(player, {
		action = "preferredState",
		balances = {
			bounty = getBountyPoints(player),
		},
		preferred = getBountyPreferencePayload(player, record.difficulty, search, page),
	})
end

local function sendShopResult(player, itemId, resultCode)
	sendTaskBoardPayload(player, {
		action = "shopResult",
		itemId = itemId,
		result = resultCode,
	})
end

local function getOfferOutfits(offer)
	local outfits = {}
	if tonumber(offer.maleLookType) and tonumber(offer.maleLookType) > 0 then
		outfits[#outfits + 1] = tonumber(offer.maleLookType)
	end
	if tonumber(offer.femaleLookType) and tonumber(offer.femaleLookType) > 0 then
		outfits[#outfits + 1] = tonumber(offer.femaleLookType)
	end
	if #outfits == 0 and tonumber(offer.lookType) and tonumber(offer.lookType) > 0 then
		outfits[#outfits + 1] = tonumber(offer.lookType)
	end
	return outfits
end

local function hasAllOutfitRewards(player, offer)
	local addons = tonumber(offer.lookAddons) or 0
	for _, lookType in ipairs(getOfferOutfits(offer)) do
		if not player:hasOutfit(lookType, addons) then
			return false
		end
	end
	return true
end

local function addOutfitReward(player, offer)
	local addons = tonumber(offer.lookAddons) or 0
	for _, lookType in ipairs(getOfferOutfits(offer)) do
		if addons > 0 and not player:hasOutfit(lookType, 0) then
			return false, SHOP_ERR_NEED_BASE
		end
	end

	for _, lookType in ipairs(getOfferOutfits(offer)) do
		if addons <= 0 then
			player:addOutfit(lookType)
		elseif addons == 3 then
			player:addOutfitAddon(lookType, 1)
			player:addOutfitAddon(lookType, 2)
		else
			player:addOutfitAddon(lookType, addons)
		end
	end
	return true
end

local function addItemReward(player, offer)
	local itemId = tonumber(offer.itemId) or 0
	local count = math.max(1, tonumber(offer.count or offer.amount) or 1)
	local itemType = itemId > 0 and ItemType(itemId)
	if not itemType then
		return false, SHOP_ERR_NOT_FOUND
	end
	if player:getFreeCapacity() < itemType:getWeight(count) then
		return false, SHOP_ERR_NO_SPACE
	end

	local item = Game.createItem(itemId, count)
	if not item then
		return false, SHOP_ERR_NOT_FOUND
	end
	local resultCode = player:addItemEx(item, false)
	if resultCode ~= RETURNVALUE_NOERROR then
		item:remove()
		return false, SHOP_ERR_NO_SPACE
	end
	return true
end

local function grantOfferReward(player, offer)
	local offerType = tonumber(offer.offerType) or SHOP_OFFER_TYPE_ITEM
	if offerType == SHOP_OFFER_TYPE_ITEM or offerType == SHOP_OFFER_TYPE_ITEM_DOUBLE then
		return addItemReward(player, offer)
	elseif offerType == SHOP_OFFER_TYPE_MOUNT then
		local mountId = tonumber(offer.mountId or offer.lookType) or 0
		if mountId <= 0 then
			return false, SHOP_ERR_NOT_FOUND
		end
		if player:hasMount(mountId) then
			return false, SHOP_ERR_ALREADY_BOUGHT
		end
		player:addMount(mountId)
		return true
	elseif offerType == SHOP_OFFER_TYPE_OUTFIT then
		if hasAllOutfitRewards(player, offer) then
			return false, SHOP_ERR_ALREADY_BOUGHT
		end
		return addOutfitReward(player, offer)
	elseif offerType == SHOP_OFFER_TYPE_AURA then
		local auraId = tonumber(offer.auraId or offer.lookAura) or 0
		if auraId <= 0 then
			return false, SHOP_ERR_NOT_FOUND
		end
		return player:addAura(auraId), SHOP_ERR_ALREADY_BOUGHT
	elseif offerType == SHOP_OFFER_TYPE_WINGS then
		local wingsId = tonumber(offer.wingsId or offer.lookWings) or 0
		if wingsId <= 0 then
			return false, SHOP_ERR_NOT_FOUND
		end
		return player:addWings(wingsId), SHOP_ERR_ALREADY_BOUGHT
	elseif offerType == SHOP_OFFER_TYPE_SHADER then
		local shaderId = tonumber(offer.shaderId or offer.lookShader) or 0
		if shaderId <= 0 then
			return false, SHOP_ERR_NOT_FOUND
		end
		return player:addShader(shaderId), SHOP_ERR_ALREADY_BOUGHT
	end
	return false, SHOP_ERR_NOT_FOUND
end

local function validateOfferReward(player, offer)
	local offerType = tonumber(offer.offerType) or SHOP_OFFER_TYPE_ITEM
	if offerType == SHOP_OFFER_TYPE_ITEM or offerType == SHOP_OFFER_TYPE_ITEM_DOUBLE then
		local itemId = tonumber(offer.itemId) or 0
		local count = math.max(1, tonumber(offer.count or offer.amount) or 1)
		local itemType = itemId > 0 and ItemType(itemId)
		if not itemType then
			return false, SHOP_ERR_NOT_FOUND
		end
		if player:getFreeCapacity() < itemType:getWeight(count) then
			return false, SHOP_ERR_NO_SPACE
		end
		return true
	elseif offerType == SHOP_OFFER_TYPE_MOUNT then
		local mountId = tonumber(offer.mountId or offer.lookType) or 0
		if mountId <= 0 then
			return false, SHOP_ERR_NOT_FOUND
		end
		if player:hasMount(mountId) then
			return false, SHOP_ERR_ALREADY_BOUGHT
		end
		return true
	elseif offerType == SHOP_OFFER_TYPE_OUTFIT then
		if hasAllOutfitRewards(player, offer) then
			return false, SHOP_ERR_ALREADY_BOUGHT
		end
		local addons = tonumber(offer.lookAddons) or 0
		if addons > 0 then
			for _, lookType in ipairs(getOfferOutfits(offer)) do
				if not player:hasOutfit(lookType, 0) then
					return false, SHOP_ERR_NEED_BASE
				end
			end
		end
		return true
	elseif offerType == SHOP_OFFER_TYPE_AURA then
		return (tonumber(offer.auraId or offer.lookAura) or 0) > 0, SHOP_ERR_NOT_FOUND
	elseif offerType == SHOP_OFFER_TYPE_WINGS then
		return (tonumber(offer.wingsId or offer.lookWings) or 0) > 0, SHOP_ERR_NOT_FOUND
	elseif offerType == SHOP_OFFER_TYPE_SHADER then
		return (tonumber(offer.shaderId or offer.lookShader) or 0) > 0, SHOP_ERR_NOT_FOUND
	end
	return false, SHOP_ERR_NOT_FOUND
end

local function refundShopCurrency(player, currency, amount)
	if currency == "soulseal" then
		addSoulsealPoints(player, amount)
	elseif currency == "bounty" then
		addBountyPoints(player, amount)
	else
		addTaskTokens(player, amount)
	end
end

local function buyOffer(player, itemId, page)
	local offer = getOffer(itemId)
	if not offer then
		sendShopResult(player, itemId, SHOP_ERR_NOT_FOUND)
		return
	end

	local purchases = getPurchases(player)
	local boughtAmount = tonumber(purchases[itemId]) or 0
	local maxPurchases = tonumber(offer.maxPurchases)
	if not maxPurchases then
		maxPurchases = isPermanentShopOffer(offer.offerType) and 1 or 0
	end
	if maxPurchases > 0 and boughtAmount >= maxPurchases then
		sendShopResult(player, itemId, SHOP_ERR_ALREADY_BOUGHT)
		return
	end

	local ok, errCode = validateOfferReward(player, offer)
	if not ok then
		sendShopResult(player, itemId, errCode or SHOP_ERR_NOT_FOUND)
		return
	end

	local price = tonumber(offer.price) or 0
	local currency = tostring(offer.currency or "task")
	local paid
	if currency == "soulseal" then
		paid = removeSoulsealPoints(player, price)
	elseif currency == "bounty" then
		paid = removeBountyPoints(player, price)
	else
		paid = removeTaskTokens(player, price)
	end
	if not paid then
		sendShopResult(player, itemId, SHOP_ERR_NO_POINTS)
		return
	end

	ok, errCode = grantOfferReward(player, offer)
	if not ok then
		refundShopCurrency(player, currency, price)
		sendShopResult(player, itemId, errCode or SHOP_ERR_NOT_FOUND)
		return
	end

	db.query(string.format("INSERT INTO `player_taskboard_shop_purchases` (`player_id`, `offer_id`, `amount`, `updated_at`) VALUES (%d, %d, 1, %d) ON DUPLICATE KEY UPDATE `amount` = `amount` + 1, `updated_at` = VALUES(`updated_at`)", player:getGuid(), itemId, os.time()))
	sendShopResult(player, itemId, SHOP_OK)
	sendShopState(player, page)
end

local function handleWeeklyAction(player, data)
	local action = tonumber(data.action) or 0
	if action == WEEKLY_SELECT_DIFFICULTY then
		local difficulty = math.max(1, math.min(5, tonumber(data.value) or 0))
		if weeklyDifficultyConfig[difficulty] then
			rollWeeklyTasks(player, difficulty)
		end
	elseif action == WEEKLY_DELIVER_ITEM then
		local slotIndex = tonumber(data.value) or 0
		local requested = math.max(0, math.floor(tonumber(data.amount) or 0))
		local record = finishExpiredWeekly(player, getWeeklyRecord(player))
		if record then
			local unlocks = getWeeklyUnlocks(player)
			if slotIndex + 1 > unlocks.deliverySlots then
				player:sendTextMessage(MESSAGE_INFO_DESCR, "[Weekly Tasks] Unlock this delivery task slot first.")
				sendWeeklyState(player)
				return
			end
			for _, item in ipairs(record.items or {}) do
				if (tonumber(item.slotIndex) or 0) == slotIndex then
					local total = tonumber(item.total) or 0
					local current = math.min(tonumber(item.current) or 0, total)
					local remaining = math.max(0, total - current)
					local owned = math.max(0, player:getItemCount(item.itemId))
					local count = math.min(requested, remaining, owned)
					if count > 0 and player:removeItem(item.itemId, count) then
						item.current = current + count
						item.state = item.current >= total and 1 or 0
						item.claimed = item.state
						saveWeeklyItems(player, record.difficulty, record.expiresAt, record.monsters, record.items)
					end
					break
				end
			end
		end
	elseif action == WEEKLY_UNLOCK_KILL_SLOT then
		local unlocks = getWeeklyUnlocks(player)
		if unlocks.killSlots < weeklyTaskSlots then
			if removeSoulsealPoints(player, weeklyKillSlotUnlockCost) then
				unlocks.killSlots = unlocks.killSlots + 1
				saveWeeklyUnlocks(player, unlocks)
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Weekly Tasks] Kill task slot %d unlocked.", unlocks.killSlots))
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Weekly Tasks] You need %d Soulseals to unlock the next kill task slot.", weeklyKillSlotUnlockCost))
			end
		end
	elseif action == WEEKLY_UNLOCK_DELIVERY_SLOT then
		local unlocks = getWeeklyUnlocks(player)
		if unlocks.deliverySlots < weeklyTaskSlots then
			if removeSoulsealPoints(player, weeklyDeliverySlotUnlockCost) then
				unlocks.deliverySlots = unlocks.deliverySlots + 1
				saveWeeklyUnlocks(player, unlocks)
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Weekly Tasks] Delivery task slot %d unlocked.", unlocks.deliverySlots))
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Weekly Tasks] You need %d Soulseals to unlock the next delivery task slot.", weeklyDeliverySlotUnlockCost))
			end
		end
	end
	sendWeeklyState(player)
end

local function handleBountyAction(player, data)
	local action = tonumber(data.action) or BOUNTY_ACTION_REQUEST
	local record = refreshExpiredBountyTasks(player, getBountyRecord(player))

	if action == BOUNTY_ACTION_SELECT then
		local taskIndex = tonumber(data.value) or 0
		if taskIndex > (tonumber(record.unlockedSlots) or 1) then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "[Bounty] Unlock this bounty task slot first.")
			sendBountyState(player)
			return
		end
		for _, task in ipairs(record.monsters or {}) do
			if (tonumber(task.taskIndex) or 0) == taskIndex and tonumber(task.isCompleted) ~= 1 then
				task.isActive = 1
				if (tonumber(task.expiresAt) or 0) <= 0 then
					task.expiresAt = os.time() + getBountyTaskDuration(task.totalKills)
				end
				saveBountyRecord(player, record)
				break
			end
		end
	elseif action == BOUNTY_ACTION_CLAIM_REWARD then
		local requestedTaskIndex = tonumber(data.value) or 0
		for _, task in ipairs(record.monsters or {}) do
			local currentKills = tonumber(task.currentKills) or 0
			local totalKills = tonumber(task.totalKills) or 0
			if (requestedTaskIndex <= 0 or (tonumber(task.taskIndex) or 0) == requestedTaskIndex)
				and tonumber(task.isActive) == 1 and tonumber(task.isCompleted) ~= 1 and currentKills >= totalKills then
				task.isCompleted = 1
				task.isActive = 0
				addBountyPoints(player, tonumber(task.rewardPoints) or 0)
				local rewardReroll = math.max(0, tonumber(task.rewardReroll) or 0)
				record.rerollPoints = math.min(bountyRerollCap, (tonumber(record.rerollPoints) or 0) + rewardReroll)
				if player.addExperience and (tonumber(task.rewardXp) or 0) > 0 then
					player:addExperience(tonumber(task.rewardXp) or 0, true)
				end
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty] Claimed %s and received %d bounty points.", tostring(task.name or "task"), tonumber(task.rewardPoints) or 0))
				saveBountyRecord(player, record)
				break
			end
		end
	elseif action == BOUNTY_ACTION_REROLL then
		local rerollsRemaining = math.max(0, tonumber(record.rerollPoints) or 0)
		if rerollsRemaining <= 0 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "[Bounty] You do not have any reroll tokens remaining.")
		elseif removeBountyPoints(player, bountyRerollCost) then
			record.rerollPoints = rerollsRemaining - 1
			record.monsters = rollBountyTasks(record.difficulty, getBountyPreferences(player))
			saveBountyRecord(player, record)
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty] You need %d bounty points to reroll tasks.", bountyRerollCost))
		end
	elseif action == BOUNTY_ACTION_UNLOCK_SLOT then
		local slot = math.max(1, math.min(bountyTaskSlots, tonumber(data.value) or 1))
		local unlockedSlots = math.max(1, math.min(bountyTaskSlots, tonumber(record.unlockedSlots) or 1))
		if slot == unlockedSlots + 1 then
			local cost = bountyTaskUnlockCosts[slot] or 0
			if cost <= 0 or removeBountyPoints(player, cost) then
				record.unlockedSlots = slot
				saveBountyRecord(player, record)
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty] Bounty task slot %d unlocked.", slot))
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty] You need %d bounty points to unlock this bounty task slot.", cost))
			end
		end
	elseif action == BOUNTY_ACTION_CHANGE_DIFFICULTY then
		for _, task in ipairs(record.monsters or {}) do
			if tonumber(task.isActive) == 1 and tonumber(task.isCompleted) ~= 1 then
				player:sendTextMessage(MESSAGE_INFO_DESCR, "[Bounty] You cannot change difficulty while a bounty task is active. Use reroll instead.")
				sendBountyState(player)
				return
			end
		end
		local difficulty = math.max(1, math.min(5, tonumber(data.value) or tonumber(record.difficulty) or 3))
		record.difficulty = difficulty
		record.monsters = rollBountyTasks(difficulty, getBountyPreferences(player))
		saveBountyRecord(player, record)
	elseif action == BOUNTY_ACTION_CLAIM_DAILY then
		if tonumber(record.claimDaily) == 1 then
			record.rerollPoints = math.min(bountyRerollCap, (tonumber(record.rerollPoints) or 0) + 1)
			record.claimDaily = 0
			saveBountyRecord(player, record)
		end
	end

	sendBountyState(player)
end

local function handleTalismanAction(player, data)
	local statType = tonumber(data.statType) or 0
	local index = statType + 1
	if index < 1 or index > 4 then
		sendBountyState(player)
		return
	end

	local levels = getTalismanLevels(player)
	local maxLevel = getTalismanMaxLevel(index)
	local level = math.max(0, math.min(maxLevel, tonumber(levels[index]) or 0))
	if level < maxLevel then
		local cost = getTalismanUpgradeCost(level, index)
		if removeBountyPoints(player, cost) then
			levels[index] = level + 1
			saveTalismanLevels(player, levels)
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty Talisman] Upgrade purchased for %d bounty points.", cost))
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty Talisman] You need %d bounty points for this upgrade.", cost))
		end
	end

	sendBountyState(player)
end

local function handlePreferredAction(player, data)
	local action = tonumber(data.action) or BOUNTY_PREF_ACTION_REQUEST
	local slot = math.max(1, math.min(bountyPreferenceSlots, tonumber(data.slot) or 1))
	local raceId = math.max(0, tonumber(data.value) or 0)
	local search = tostring(data.search or "")
	local page = tonumber(data.page) or 1
	local preferences = getBountyPreferences(player)

	if action == BOUNTY_PREF_ACTION_BUY_SLOT then
		if slot == preferences.unlockedSlots + 1 and slot <= bountyPreferenceSlots then
			local cost = bountyPreferenceUnlockCosts[slot] or 0
			if cost <= 0 or removeBountyPoints(player, cost) then
				preferences.unlockedSlots = slot
				saveBountyPreferences(player, preferences)
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty] You need %d bounty points to unlock this preferred slot.", cost))
			end
		end
	elseif slot <= preferences.unlockedSlots then
		if action == BOUNTY_PREF_ACTION_SET_PREFERRED and raceId > 0 then
			preferences.preferred[slot] = raceId
			if preferences.unwanted[slot] == raceId then
				preferences.unwanted[slot] = 0
			end
			saveBountyPreferences(player, preferences)
		elseif action == BOUNTY_PREF_ACTION_SET_UNWANTED and raceId > 0 then
			preferences.unwanted[slot] = raceId
			if preferences.preferred[slot] == raceId then
				preferences.preferred[slot] = 0
			end
			saveBountyPreferences(player, preferences)
		elseif action == BOUNTY_PREF_ACTION_REMOVE_PREFERRED then
			if (tonumber(preferences.preferred[slot]) or 0) > 0 then
				if removeBountyPoints(player, bountyPreferenceClearCost) then
					preferences.preferred[slot] = 0
					saveBountyPreferences(player, preferences)
				else
					player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty] You need %d bounty points to clear this preferred monster.", bountyPreferenceClearCost))
				end
			end
		elseif action == BOUNTY_PREF_ACTION_REMOVE_UNWANTED then
			if (tonumber(preferences.unwanted[slot]) or 0) > 0 then
				if removeBountyPoints(player, bountyPreferenceClearCost) then
					preferences.unwanted[slot] = 0
					saveBountyPreferences(player, preferences)
				else
					player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("[Bounty] You need %d bounty points to clear this avoided monster.", bountyPreferenceClearCost))
				end
			end
		end
	end

	sendPreferredState(player, search, page)
end

local extendedEvent = CreatureEvent("TaskBoardExtended")
function extendedEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= OPCODE_TASKBOARD then
		return true
	end

	local ok, request = pcall(json.decode, buffer)
	if not ok or type(request) ~= "table" then
		return true
	end

	local action = tostring(request.action or "")
	local data = type(request.data) == "table" and request.data or {}
	if action == "shop" then
		if data.action == "buy" then
			buyOffer(player, tonumber(data.itemId) or 0, tonumber(data.page) or 1)
		else
			sendShopState(player, tonumber(data.page) or 1)
		end
	elseif action == "weekly" then
		handleWeeklyAction(player, data)
	elseif action == "bounty" then
		handleBountyAction(player, data)
	elseif action == "talisman" then
		handleTalismanAction(player, data)
	elseif action == "preferred" then
		handlePreferredAction(player, data)
	else
		TaskBoard.sendState(player)
	end
	return true
end
extendedEvent:type("extendedopcode")
extendedEvent:register()

local killEvent = CreatureEvent("TaskBoardKill")
function killEvent.onKill(player, target)
	if not target or not target:isMonster() or target:getMaster() then
		return true
	end

	local killedName = tostring(target:getName() or ""):lower()
	local weeklyChanged = false
	local weeklyForceSave = false
	local bountyChanged = false
	local bountyForceSave = false

	local weeklyRecord = finishExpiredWeekly(player, getWeeklyRecord(player))
	if weeklyRecord then
		local weeklyUnlocks = getWeeklyUnlocks(player)
		for _, task in ipairs(weeklyRecord.monsters or {}) do
			local slot = (tonumber(task.slotIndex) or 0) + 1
			local total = tonumber(task.total) or 0
			local current = math.min(tonumber(task.current) or 0, total)
			local taskName = tostring(task.name or ""):lower()
			if slot <= weeklyUnlocks.killSlots and total > 0 and current < total and ((tonumber(task.raceId) or 0) == 0 or taskName == killedName) then
				task.current = math.min(total, current + 1)
				task.state = task.current >= total and 1 or 0
				task.claimed = task.state
				weeklyForceSave = weeklyForceSave or task.current >= total
				weeklyChanged = true
				sendWeeklyKillUpdate(player, task, weeklyRecord)
			end
		end
		if weeklyChanged then
			if shouldPersistKillProgress(weeklyKillSaveState, player, weeklyForceSave) then
				saveWeeklyItems(player, weeklyRecord.difficulty, weeklyRecord.expiresAt, weeklyRecord.monsters, weeklyRecord.items)
			end
		end
	end

	local record = refreshExpiredBountyTasks(player, getBountyRecord(player))
	for _, task in ipairs(record.monsters or {}) do
		if tonumber(task.isActive) == 1 and tonumber(task.isCompleted) ~= 1 then
			local totalKills = tonumber(task.totalKills) or 0
			local currentKills = tonumber(task.currentKills) or 0
			local taskName = tostring(task.name or ""):lower()
			if totalKills > 0 and currentKills < totalKills and ((tonumber(task.raceId) or 0) == 0 or taskName == killedName) then
				task.currentKills = math.min(totalKills, currentKills + 1)
				bountyForceSave = bountyForceSave or task.currentKills >= totalKills
				sendBountyKillUpdate(player, task)
				bountyChanged = true
			end
		end
	end
	if bountyChanged then
		if shouldPersistKillProgress(bountyKillSaveState, player, bountyForceSave) then
			saveBountyRecord(player, record)
		end
	end

	return true
end
killEvent:type("kill")
killEvent:register()

local loginEvent = CreatureEvent("TaskBoardLogin")
function loginEvent.onLogin(player)
	player:registerEvent("TaskBoardExtended")
	player:registerEvent("TaskBoardKill")
	return true
end
loginEvent:type("login")
loginEvent:register()

local startupEvent = GlobalEvent("TaskBoardStartup")
function startupEvent.onStartup()
	createTables()
	return true
end
startupEvent:register()

-- Exported so other scripts (GM talkactions included) can credit the three
-- Task Board currencies and refresh the open window. They live in the global
-- table because every script interface shares a single lua_State.
TaskBoard.getTaskTokens = getTaskTokens
TaskBoard.getBountyPoints = getBountyPoints
TaskBoard.getSoulsealPoints = getSoulsealPoints
TaskBoard.addTaskTokens = addTaskTokens
TaskBoard.addBountyPoints = addBountyPoints
TaskBoard.addSoulsealPoints = addSoulsealPoints
TaskBoard.removeTaskTokens = removeTaskTokens
TaskBoard.removeBountyPoints = removeBountyPoints
TaskBoard.removeSoulsealPoints = removeSoulsealPoints
