local function create(api)
	local dynastieApi = {}
	local DynastieAttackState = {
		byConfigId = {},
		tickScheduled = false
	}
	local dynastieDefenderConfig = dofile("data/scripts/customs/guilds/guild_hall_dynastie_defenders.lua")
	local dynastiePassiveTreeConfig = dofile("data/scripts/customs/guilds/defender_passive_tree.lua")
	local DEFENDER_LEVEL_CAP = math.max(1, math.floor(tonumber(dynastieDefenderConfig.DEFENDER_LEVEL_CAP) or 20))
	local DEFENDER_PERK_LEVEL_CAP = math.max(1, math.floor(tonumber(dynastieDefenderConfig.DEFENDER_PERK_LEVEL_CAP) or 4))
	local DEFENDER_CHASE_RADIUS = math.max(1, math.floor(tonumber(dynastieDefenderConfig.DEFENDER_CHASE_RADIUS) or 18))
	local MONSTER_LEVEL_BONUS_HEALTH = tonumber(dynastieDefenderConfig.MONSTER_LEVEL_BONUS_HEALTH) or 0.0074
	local MONSTER_LEVEL_BONUS_SPEED = tonumber(dynastieDefenderConfig.MONSTER_LEVEL_BONUS_SPEED) or 0.0085
	local MONSTER_LEVEL_BONUS_DAMAGE = tonumber(dynastieDefenderConfig.MONSTER_LEVEL_BONUS_DAMAGE) or 0.0015
	local dynastieViewerPages = {}
	local dynastieActiveViewers = {}
	local questHooks = {}
	local calculateLevelProgress
	local loadDefenderPerkLevels

	local function getConfig()
		return rawget(_G, "GuildHallDynastieConfig") or {}
	end

	local function getConfigList()
		local cfg = getConfig()
		return cfg.LOCATIONS or {}
	end

	local function getConfigById(configId)
		for _, entry in ipairs(getConfigList()) do
			if entry.id == configId then
				return entry
			end
		end
		return nil
	end

	local DefenderTemplates = type(dynastieDefenderConfig.defenders) == "table" and dynastieDefenderConfig.defenders or {}
	local DefenderPerkTemplates = type(dynastieDefenderConfig.perks) == "table" and dynastieDefenderConfig.perks or {}
	local DefenderPassiveTreeTemplates = type(dynastiePassiveTreeConfig) == "table" and dynastiePassiveTreeConfig or { milestones = {}, nodes = {} }

	local function getDefenderTemplate(defenderId)
		for _, entry in ipairs(DefenderTemplates) do
			if entry.id == defenderId then
				return entry
			end
		end
		return nil
	end

	local function getDefenderPerkTemplate(defenderId)
		for _, entry in ipairs(DefenderPerkTemplates) do
			if entry.id == defenderId then
				return entry
			end
		end
		return nil
	end

	local function getDefenderLevelCap()
		return DEFENDER_LEVEL_CAP
	end

	local function getDefenderPerkLevelCap()
		return DEFENDER_PERK_LEVEL_CAP
	end

	local function getPerkLevelCap(template)
		if type(template) == "table" then
			local maxLevel = math.max(0, tonumber(template.maxLevel) or 0)
			if maxLevel > 0 then
				return maxLevel
			end
		end
		return getDefenderPerkLevelCap()
	end

	local function getPassiveTokenRatePerHour(guildId, timestamp)
		local cfg = getConfig()
		local baseRate = math.max(0, math.floor(tonumber(cfg.DEFAULT_TOKENS_PER_HOUR) or 1))
		local multiplier = 1
		if api and type(api.getDynastieTokenRateMultiplier) == "function" then
			multiplier = math.max(1, tonumber(api.getDynastieTokenRateMultiplier(guildId, timestamp)) or 1)
		end
		return math.max(0, math.floor(baseRate * multiplier))
	end

	local function ensureDynastieBonusTokenColumn()
		if not api or not api.hasTable or not api.hasTable("guild_dynasties") or not api.hasColumn then
			return
		end
		if api.hasColumn("guild_dynasties", "bonus_tokens") then
			return
		end
		db.query("ALTER TABLE `guild_dynasties` ADD COLUMN `bonus_tokens` BIGINT NOT NULL DEFAULT 0")
	end

	local function getStoredDynastieTokens(state, timestamp)
		if not state then
			return 0
		end

		local tokenRate = getPassiveTokenRatePerHour(state.guildId, timestamp)
		if tokenRate <= 0 then
			return 0
		end

		local placedAt = tonumber(state.placedAt) or 0
		local now = math.max(0, tonumber(timestamp) or os.time())
		local passiveTokens = 0
		if placedAt > 0 and now > placedAt then
			local elapsedHours = math.floor((now - placedAt) / 3600)
			if elapsedHours > 0 then
				passiveTokens = elapsedHours * tokenRate
			end
		end

		return passiveTokens + math.max(0, tonumber(state.bonusTokens) or 0)
	end

	local function sendDynastiePerkResult(player, text)
		if not player or not api.sendGuildPayload then
			return
		end
		api.sendGuildPayload(player, "perkResult", {
			title = "Dynasty Perk Upgrade Result",
			text = tostring(text or "")
		})
	end

	local function getActiveDynastiePerkBonuses(guildId)
		local bonuses = {
			physical = 0,
			fire = 0,
			ice = 0,
			energy = 0,
			earth = 0,
			water = 0,
			holy = 0,
			death = 0,
			arcane = 0,
			healing = 0,
			rarityLoot = 0
		}

		guildId = tonumber(guildId) or 0
		if guildId <= 0 or type(dynastieApi.getGuildActiveConfigIds) ~= "function" then
			return bonuses
		end

		local activeConfigIds = dynastieApi.getGuildActiveConfigIds(guildId)
		if type(activeConfigIds) ~= "table" or #activeConfigIds <= 0 then
			return bonuses
		end

		local levels = loadDefenderPerkLevels(guildId)
		bonuses.physical = math.max(0, tonumber(levels.element_physical) or 0)
		bonuses.fire = math.max(0, tonumber(levels.element_fire) or 0)
		bonuses.ice = math.max(0, tonumber(levels.element_ice) or 0)
		bonuses.energy = math.max(0, tonumber(levels.element_energy) or 0)
		bonuses.earth = math.max(0, tonumber(levels.element_earth) or 0)
		bonuses.water = math.max(0, tonumber(levels.element_water) or 0)
		bonuses.holy = math.max(0, tonumber(levels.element_holy) or 0)
		bonuses.death = math.max(0, tonumber(levels.element_death) or 0)
		bonuses.arcane = math.max(0, tonumber(levels.element_arcane) or 0)
		bonuses.healing = math.max(0, tonumber(levels.element_healing) or 0)
		bonuses.rarityLoot = math.max(0, tonumber(levels.rarity_loot) or 0)
		return bonuses
	end

	local function isCoreBoundPerk(perkId)
		perkId = tostring(perkId or "")
		return perkId == "rarity_loot" or perkId:find("^element_") ~= nil
	end

	local function guildHasActiveDynastieCore(guildId)
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or type(dynastieApi.getGuildActiveConfigIds) ~= "function" then
			return false
		end
		local activeConfigIds = dynastieApi.getGuildActiveConfigIds(guildId)
		return type(activeConfigIds) == "table" and #activeConfigIds > 0
	end

	local function normalizeUpgradeCost(template, rawCost, nextLevel)
		local cost = type(rawCost) == "table" and rawCost or {}
		local normalized = {
			gold = math.max(0, math.floor(tonumber(cost.gold) or 0)),
			dynastieTokens = math.max(0, math.floor(tonumber(cost.dynastieTokens) or 0)),
			items = {}
		}

		if type(cost.items) == "table" then
			for _, entry in ipairs(cost.items) do
				local itemId = math.max(0, math.floor(tonumber(entry.itemId) or 0))
				local itemCount = math.max(0, math.floor(tonumber(entry.count) or 0))
				if itemId > 0 and itemCount > 0 then
					local itemType = ItemType(itemId)
					normalized.items[#normalized.items + 1] = {
						itemId = itemId,
						count = itemCount,
						itemName = tostring(entry.itemName or (itemType and itemType:getName()) or ("Item #" .. itemId))
					}
				end
			end
		else
			local itemId = math.max(0, math.floor(tonumber(cost.itemId or template.upgradeItemId) or 0))
			local itemCount = math.max(0, math.floor(tonumber(cost.itemCount) or 0))
			if itemId > 0 and itemCount > 0 then
				normalized.items[1] = {
					itemId = itemId,
					count = itemCount,
					itemName = tostring(cost.itemName or template.upgradeItemName or ("Item #" .. itemId))
				}
			end
		end

		local parts = {}
		if normalized.gold > 0 then
			parts[#parts + 1] = string.format("%s gold", tostring(normalized.gold))
		end
		if normalized.dynastieTokens > 0 then
			parts[#parts + 1] = string.format("%s tokens", tostring(normalized.dynastieTokens))
		end
		for _, item in ipairs(normalized.items) do
			parts[#parts + 1] = string.format("%dx %s", item.count, item.itemName)
		end

		normalized.itemId = normalized.items[1] and normalized.items[1].itemId or 0
		normalized.itemCount = normalized.items[1] and normalized.items[1].count or 0
		normalized.itemName = normalized.items[1] and normalized.items[1].itemName or (template.upgradeItemName or "Material")
		normalized.text = #parts > 0 and ("Level " .. tostring(nextLevel) .. ": " .. table.concat(parts, ", ")) or ("Level " .. tostring(nextLevel))
		return normalized
	end

	local function getDefenderUpgradeCost(template, nextLevel)
		nextLevel = math.max(1, math.floor(tonumber(nextLevel) or 1))
		local configuredCost = type(template.upgradeCosts) == "table" and template.upgradeCosts[nextLevel] or nil
		if configuredCost then
			return normalizeUpgradeCost(template, configuredCost, nextLevel)
		end

		return normalizeUpgradeCost(template, {
			gold = tonumber(template.upgradeGold) or (nextLevel * 50000),
			dynastieTokens = tonumber(template.upgradeDynastieTokens) or (nextLevel * 5),
			itemId = tonumber(template.upgradeItemId) or 0,
			itemCount = tonumber(template.upgradeItemCount) or math.max(1, math.ceil(nextLevel / 2)),
			itemName = template.upgradeItemName or "Material"
		}, nextLevel)
	end

	local function getDefenderPerkUpgradeCost(template, nextLevel)
		nextLevel = math.max(1, math.floor(tonumber(nextLevel) or 1))
		local configuredCost = type(template.upgradeCosts) == "table" and template.upgradeCosts[nextLevel] or nil
		if configuredCost then
			return normalizeUpgradeCost(template, configuredCost, nextLevel)
		end

		return normalizeUpgradeCost(template, {
			dynastieTokens = tonumber(template.upgradeDynastieTokens) or (nextLevel * 10),
			itemId = tonumber(template.upgradeItemId) or 0,
			itemCount = tonumber(template.upgradeItemCount) or nextLevel,
			itemName = template.upgradeItemName or "Material"
		}, nextLevel)
	end

	local function getGuildStorageItemCountByItemId(guildId, itemId)
		if guildId <= 0 or itemId <= 0 or not api.getGuildStorageRows then
			return 0
		end

		local total = 0
		for _, row in pairs(api.getGuildStorageRows(guildId) or {}) do
			if tonumber(row.itemId) == itemId then
				total = total + math.max(0, tonumber(row.count) or 0)
			end
		end
		return total
	end

	local function removeItemsFromGuildStorage(guildId, items)
		if guildId <= 0 or type(items) ~= "table" or #items == 0 then
			return true
		end
		if not api.hasTable or not api.hasTable("guild_storage_items") or not api.getGuildStorageRows then
			return false, "Guild storage schema is missing. Run migration 51 first."
		end

		for _, item in ipairs(items) do
			local itemId = math.max(0, tonumber(item.itemId) or 0)
			local amount = math.max(0, tonumber(item.count) or 0)
			local itemType = itemId > 0 and ItemType(itemId) or nil
			local itemName = tostring(item.itemName or (itemType and itemType:getName()) or "material")
			if itemId > 0 and amount > 0 and getGuildStorageItemCountByItemId(guildId, itemId) < amount then
				return false, string.format("Guild storage needs {%dx %s}.", amount, itemName)
			end
		end

		local rows = api.getGuildStorageRows(guildId) or {}
		local orderedSlots = {}
		for slot in pairs(rows) do
			orderedSlots[#orderedSlots + 1] = slot
		end
		table.sort(orderedSlots)

		for _, item in ipairs(items) do
			local itemId = math.max(0, tonumber(item.itemId) or 0)
			local remaining = math.max(0, tonumber(item.count) or 0)
			for _, slot in ipairs(orderedSlots) do
				local row = rows[slot]
				if row and tonumber(row.itemId) == itemId and remaining > 0 then
					local rowCount = math.max(0, tonumber(row.count) or 0)
					local removeCount = math.min(rowCount, remaining)
					local newCount = rowCount - removeCount
					if newCount > 0 then
						db.query("UPDATE `guild_storage_items` SET `count` = " .. newCount .. " WHERE `guild_id` = " .. guildId .. " AND `slot` = " .. slot)
						row.count = newCount
					else
						db.query("DELETE FROM `guild_storage_items` WHERE `guild_id` = " .. guildId .. " AND `slot` = " .. slot)
						rows[slot] = nil
					end
					remaining = remaining - removeCount
				end
			end
		end

		if api.refreshGuildStorageForGuild then
			api.refreshGuildStorageForGuild(guildId)
		end
		return true
	end

	local function scaleDefenderStats(template, level)
		level = math.max(0, math.floor(tonumber(level) or 0))
		local baseHealth = tonumber(template.maxHealth) or 0
		local baseSpeed = tonumber(template.baseSpeed) or 0
		local baseDamageMin = tonumber(template.damageMin) or 0
		local baseDamageMax = tonumber(template.damageMax) or 0
		local baseDefense = tonumber(template.defense) or 0
		local baseArmor = tonumber(template.armor) or 0
		local bonusHealth = MONSTER_LEVEL_BONUS_HEALTH * level
		local bonusSpeed = MONSTER_LEVEL_BONUS_SPEED * level
		local bonusDamage = MONSTER_LEVEL_BONUS_DAMAGE * level
		return {
			maxHealth = math.floor(baseHealth + (baseHealth * bonusHealth)),
			speed = math.floor(baseSpeed + (baseSpeed * bonusSpeed)),
			defense = baseDefense,
			armor = baseArmor,
			damageMin = math.floor(baseDamageMin + (baseDamageMin * bonusDamage)),
			damageMax = math.floor(baseDamageMax + (baseDamageMax * bonusDamage))
		}
	end

	local function loadDefenderLevels(guildId)
		local levels = {}
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.hasTable or not api.hasTable("guild_dynastie_defenders") then
			return levels
		end

		local resultId = db.storeQuery("SELECT `defender_id`, `level` FROM `guild_dynastie_defenders` WHERE `guild_id` = " .. guildId)
		if not resultId then
			return levels
		end

		repeat
			levels[result.getString(resultId, "defender_id")] = math.max(0, result.getNumber(resultId, "level"))
		until not result.next(resultId)
		result.free(resultId)
		return levels
	end

	loadDefenderPerkLevels = function(guildId)
		local levels = {}
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.hasTable or not api.hasTable("guild_dynastie_perks") then
			return levels
		end

		local resultId = db.storeQuery("SELECT `perk_id`, `level` FROM `guild_dynastie_perks` WHERE `guild_id` = " .. guildId)
		if not resultId then
			return levels
		end

		repeat
			levels[result.getString(resultId, "perk_id")] = math.max(0, result.getNumber(resultId, "level"))
		until not result.next(resultId)
		result.free(resultId)
		return levels
	end

	local function saveDefenderLevel(guildId, defenderId, level)
		guildId = tonumber(guildId) or 0
		level = math.max(0, math.floor(tonumber(level) or 0))
		if guildId <= 0 or defenderId == "" or not api.hasTable or not api.hasTable("guild_dynastie_defenders") then
			return false
		end

		return db.query(
			"INSERT INTO `guild_dynastie_defenders` (`guild_id`, `defender_id`, `level`, `created_at`, `updated_at`) VALUES (" ..
				guildId .. ", " .. escape(defenderId) .. ", " .. level .. ", " .. os.time() .. ", " .. os.time() .. ") " ..
			"ON DUPLICATE KEY UPDATE `level` = VALUES(`level`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function saveDefenderPerkLevel(guildId, perkId, level)
		guildId = tonumber(guildId) or 0
		level = math.max(0, math.floor(tonumber(level) or 0))
		if guildId <= 0 or perkId == "" or not api.hasTable or not api.hasTable("guild_dynastie_perks") then
			return false
		end

		return db.query(
			"INSERT INTO `guild_dynastie_perks` (`guild_id`, `perk_id`, `level`, `created_at`, `updated_at`) VALUES (" ..
				guildId .. ", " .. escape(perkId) .. ", " .. level .. ", " .. os.time() .. ", " .. os.time() .. ") " ..
			"ON DUPLICATE KEY UPDATE `level` = VALUES(`level`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function loadUnlockedPassiveNodes(guildId)
		local unlocked = {}
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.hasTable or not api.hasTable("guild_dynastie_passives") then
			return unlocked
		end

		local resultId = db.storeQuery("SELECT `defender_id`, `node_id` FROM `guild_dynastie_passives` WHERE `guild_id` = " .. guildId)
		if not resultId then
			return unlocked
		end

		repeat
			local defenderId = result.getString(resultId, "defender_id")
			local nodeId = result.getString(resultId, "node_id")
			unlocked[defenderId] = unlocked[defenderId] or {}
			unlocked[defenderId][nodeId] = true
		until not result.next(resultId)
		result.free(resultId)
		return unlocked
	end

	local function getClaimedDynastieAchievementRows(guildId)
		local rows = {}
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.hasTable or not api.hasTable("guild_dynastie_achievement_progress") then
			return rows
		end

		local resultId = db.storeQuery("SELECT `achievement_id`, `claimed_at` FROM `guild_dynastie_achievement_progress` WHERE `guild_id` = " .. guildId .. " AND `claimed_at` > 0")
		if not resultId then
			return rows
		end

		repeat
			rows[result.getString(resultId, "achievement_id")] = {
				claimedAt = result.getNumber(resultId, "claimed_at")
			}
		until not result.next(resultId)
		result.free(resultId)
		return rows
	end

	local function saveUnlockedPassiveNode(guildId, defenderId, nodeId)
		guildId = tonumber(guildId) or 0
		defenderId = tostring(defenderId or "")
		nodeId = tostring(nodeId or "")
		if guildId <= 0 or defenderId == "" or nodeId == "" or not api.hasTable or not api.hasTable("guild_dynastie_passives") then
			return false
		end

		local now = os.time()
		return db.query(
			"INSERT INTO `guild_dynastie_passives` (`guild_id`, `defender_id`, `node_id`, `created_at`, `updated_at`) VALUES (" ..
				guildId .. ", " .. escape(defenderId) .. ", " .. escape(nodeId) .. ", " .. now .. ", " .. now .. ") " ..
			"ON DUPLICATE KEY UPDATE `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function getPassiveNodeTemplate(defenderId, nodeId)
		local templateNodes = type(DefenderPassiveTreeTemplates.nodes) == "table" and DefenderPassiveTreeTemplates.nodes[defenderId] or nil
		if type(templateNodes) ~= "table" then
			return nil, nil
		end

		for index, node in ipairs(templateNodes) do
			if node.id == nodeId then
				return node, index
			end
		end
		return nil, nil
	end

	local function countUnlockedPassiveNodes(unlockedNodes, defenderId)
		local count = 0
		local nodes = type(unlockedNodes) == "table" and unlockedNodes[defenderId] or nil
		if type(nodes) ~= "table" then
			return 0
		end
		for _ in pairs(nodes) do
			count = count + 1
		end
		return count
	end

	local function getAggregatedPassiveEffects(guildId, defenderId)
		local effects = {
			hpPercent = 0,
			damagePercent = 0,
			speedPercent = 0,
			defenseFlat = 0,
			armorFlat = 0,
			attackSummaryAppend = {},
			cleave = false,
			holyVolley = false,
			arcaneNova = false,
			radiantBurst = false,
			sanctuary = false,
			judgmentChain = false,
			divineStorm = false,
			shieldBash = false,
			warStomp = false,
			earthshatter = false,
			execution = false,
			flameBurst = false,
			frostWave = false,
			chainLightning = false,
			astralCataclysm = false
		}

		local unlockedNodes = loadUnlockedPassiveNodes(guildId)
		local unlockedByDefender = unlockedNodes[defenderId] or {}
		local templateNodes = type(DefenderPassiveTreeTemplates.nodes) == "table" and DefenderPassiveTreeTemplates.nodes[defenderId] or {}
		for _, node in ipairs(templateNodes) do
			if unlockedByDefender[node.id] then
				local nodeEffects = type(node.effects) == "table" and node.effects or {}
				effects.hpPercent = effects.hpPercent + (tonumber(nodeEffects.hpPercent) or 0)
				effects.damagePercent = effects.damagePercent + (tonumber(nodeEffects.damagePercent) or 0)
				effects.speedPercent = effects.speedPercent + (tonumber(nodeEffects.speedPercent) or 0)
				effects.defenseFlat = effects.defenseFlat + (tonumber(nodeEffects.defenseFlat) or 0)
				effects.armorFlat = effects.armorFlat + (tonumber(nodeEffects.armorFlat) or 0)
				effects.cleave = effects.cleave or nodeEffects.cleave == true
				effects.holyVolley = effects.holyVolley or nodeEffects.holyVolley == true
				effects.arcaneNova = effects.arcaneNova or nodeEffects.arcaneNova == true
				effects.radiantBurst = effects.radiantBurst or nodeEffects.radiantBurst == true
				effects.sanctuary = effects.sanctuary or nodeEffects.sanctuary == true
				effects.judgmentChain = effects.judgmentChain or nodeEffects.judgmentChain == true
				effects.divineStorm = effects.divineStorm or nodeEffects.divineStorm == true
				effects.shieldBash = effects.shieldBash or nodeEffects.shieldBash == true
				effects.warStomp = effects.warStomp or nodeEffects.warStomp == true
				effects.earthshatter = effects.earthshatter or nodeEffects.earthshatter == true
				effects.execution = effects.execution or nodeEffects.execution == true
				effects.flameBurst = effects.flameBurst or nodeEffects.flameBurst == true
				effects.frostWave = effects.frostWave or nodeEffects.frostWave == true
				effects.chainLightning = effects.chainLightning or nodeEffects.chainLightning == true
				effects.astralCataclysm = effects.astralCataclysm or nodeEffects.astralCataclysm == true
				if tostring(nodeEffects.attackSummaryAppend or "") ~= "" then
					effects.attackSummaryAppend[#effects.attackSummaryAppend + 1] = tostring(nodeEffects.attackSummaryAppend)
				end
			end
		end

		return effects
	end

	local function getAchievementPassivePointDefinitions()
		if _G.GuildDynastieAchievements and type(_G.GuildDynastieAchievements.getPassivePointDefinitions) == "function" then
			return _G.GuildDynastieAchievements.getPassivePointDefinitions()
		end
		return {}
	end

	local function getAvailablePassivePointsForDefender(guildId, defenderId)
		local defenderLevels = loadDefenderLevels(guildId)
		local defenderLevel = math.max(0, tonumber(defenderLevels[defenderId]) or 0)
		local unlockedNodes = loadUnlockedPassiveNodes(guildId)
		local spentPoints = countUnlockedPassiveNodes(unlockedNodes, defenderId)
		local totalPoints = math.floor(defenderLevel / 50)
		if defenderLevel >= 25 then totalPoints = totalPoints + 1 end
		if defenderLevel >= 50 then totalPoints = totalPoints + 2 end
		if defenderLevel >= 100 then totalPoints = totalPoints + 2 end
		if defenderLevel >= 250 then totalPoints = totalPoints + 3 end
		if defenderLevel >= 500 then totalPoints = totalPoints + 3 end
		if defenderLevel >= 1000 then totalPoints = totalPoints + 4 end
		return math.max(0, totalPoints - spentPoints), totalPoints, spentPoints
	end

	local function getMonsterPreviewOutfit(monsterName, fallbackEntry)
		local outfit = {}
		local monsterType = monsterName and MonsterType(monsterName) or nil
		if monsterType then
			for key, value in pairs(monsterType:getOutfit() or {}) do
				if key == "lookTypeEx" and value > 0 then
					local itemType = ItemType(value)
					outfit[key] = itemType and itemType:getId() > 0 and itemType:getClientId() or value
				else
					outfit[key] = value
				end
			end
		end

		if next(outfit) then
			return outfit
		end

		return {
			lookType = fallbackEntry.lookType,
			lookTypeEx = fallbackEntry.lookTypeEx,
			lookHead = fallbackEntry.lookHead,
			lookBody = fallbackEntry.lookBody,
			lookLegs = fallbackEntry.lookLegs,
			lookFeet = fallbackEntry.lookFeet,
			lookAddons = fallbackEntry.lookAddons,
			lookMount = fallbackEntry.lookMount,
			lookWings = fallbackEntry.lookWings,
			lookAura = fallbackEntry.lookAura,
			lookShader = fallbackEntry.lookShader
		}
	end

	local function buildDefenderData(guildId, canManage)
		local defenders = {}
		local levels = loadDefenderLevels(guildId)
		local perkLevels = loadDefenderPerkLevels(guildId)
		local unlockedNodes = loadUnlockedPassiveNodes(guildId)
		for _, entry in ipairs(DefenderTemplates) do
			local level = math.min(getDefenderLevelCap(), math.max(0, tonumber(levels[entry.id]) or 0))
			local perkLevel = math.min(getPerkLevelCap(getDefenderPerkTemplate(entry.id)), math.max(0, tonumber(perkLevels[entry.id]) or 0))
			local scaled = scaleDefenderStats(entry, level)
			local upgradeCost = getDefenderUpgradeCost(entry, level + 1)
			local previewOutfit = getMonsterPreviewOutfit(entry.monsterName, entry)
			local passiveEffects = getAggregatedPassiveEffects(guildId, entry.id)
			local unlockedPassiveCount = countUnlockedPassiveNodes(unlockedNodes, entry.id)
			defenders[#defenders + 1] = {
				id = entry.id,
				name = entry.name,
				monsterName = entry.monsterName,
				lookType = previewOutfit.lookType,
				lookTypeEx = previewOutfit.lookTypeEx,
				lookHead = previewOutfit.lookHead,
				lookBody = previewOutfit.lookBody,
				lookLegs = previewOutfit.lookLegs,
				lookFeet = previewOutfit.lookFeet,
				lookAddons = previewOutfit.lookAddons,
				lookMount = previewOutfit.lookMount,
				lookWings = previewOutfit.lookWings,
				lookAura = previewOutfit.lookAura,
				lookShader = previewOutfit.lookShader,
				level = level,
				levelCap = getDefenderLevelCap(),
				targetDistance = entry.targetDistance,
				maxHealth = math.floor(scaled.maxHealth * (1 + ((tonumber(passiveEffects.hpPercent) or 0) / 100))),
				speed = math.floor(scaled.speed * (1 + ((tonumber(passiveEffects.speedPercent) or 0) / 100))),
				defense = scaled.defense + (tonumber(passiveEffects.defenseFlat) or 0),
				armor = scaled.armor + (tonumber(passiveEffects.armorFlat) or 0),
				damageMin = math.floor(scaled.damageMin * (1 + ((tonumber(passiveEffects.damagePercent) or 0) / 100))),
				damageMax = math.floor(scaled.damageMax * (1 + ((tonumber(passiveEffects.damagePercent) or 0) / 100))),
				attackSummary = table.concat({ entry.attackSummary, table.concat(passiveEffects.attackSummaryAppend or {}, " | ") }, " | "):gsub(" | $", ""),
				role = entry.role,
				perkLevel = perkLevel,
				unlockedCount = perkLevel,
				maxUnlockedCount = getPerkLevelCap(getDefenderPerkTemplate(entry.id)),
				isUnlocked = perkLevel > 0,
				upgradeCost = upgradeCost,
				canUpgrade = guildId > 0 and canManage and perkLevel > 0 and level < getDefenderLevelCap()
			}
		end
		return defenders
	end

	local function buildDefenderPerkData(guildId, canManage)
		local perks = {}
		local levels = loadDefenderPerkLevels(guildId)
		local hasActiveCore = guildHasActiveDynastieCore(guildId)
		for _, entry in ipairs(DefenderPerkTemplates) do
			local levelCap = getPerkLevelCap(entry)
			local level = math.min(levelCap, math.max(0, tonumber(levels[entry.id]) or 0))
			local upgradeCost = getDefenderPerkUpgradeCost(entry, level + 1)
			local coreRequirementMet = (not isCoreBoundPerk(entry.id)) or hasActiveCore
			perks[#perks + 1] = {
				id = entry.id,
				name = entry.name,
				icon = entry.icon or "",
				lookType = entry.lookType,
				role = entry.role,
				description = entry.description,
				level = level,
				levelCap = levelCap,
				unlockedCount = level,
				maxUnlockedCount = levelCap,
				upgradeCost = upgradeCost,
				canUpgrade = guildId > 0 and canManage and coreRequirementMet and level < levelCap
			}
		end
		return perks
	end

	local function formatPassiveTreeCost(cost)
		if type(cost) ~= "table" then
			return "-"
		end

		local parts = {}
		local dynastieTokens = tonumber(cost.dynastieTokens) or 0
		local gold = tonumber(cost.gold) or 0
		local itemId = tonumber(cost.itemId) or 0
		local itemCount = math.max(0, tonumber(cost.itemCount) or 0)

		if dynastieTokens > 0 then
			parts[#parts + 1] = string.format("%d tokens", dynastieTokens)
		end
		if gold > 0 then
			parts[#parts + 1] = string.format("%dk gold", math.floor(gold / 1000))
		end
		if itemId > 0 and itemCount > 0 then
			local itemType = ItemType(itemId)
			local itemName = itemType and itemType:getName() or ""
			if itemName == "" then
				itemName = "core shard"
			end
			parts[#parts + 1] = string.format("%d %s", itemCount, itemName)
		end

		return #parts > 0 and table.concat(parts, ", ") or "-"
	end

	local function buildDefenderPassiveTreeData(guildId, canManage)
		local defenders = {}
		local unlockedNodes = loadUnlockedPassiveNodes(guildId)
		local defenderLevels = loadDefenderLevels(guildId)
		local passiveNodesByDefender = type(DefenderPassiveTreeTemplates.nodes) == "table" and DefenderPassiveTreeTemplates.nodes or {}

		for _, entry in ipairs(DefenderTemplates) do
			local defenderLevel = math.min(getDefenderLevelCap(), math.max(0, tonumber(defenderLevels[entry.id]) or 0))
			local availablePoints, totalPoints, spentPoints = getAvailablePassivePointsForDefender(guildId, entry.id)
			local nodes = {}
			local templateNodes = type(passiveNodesByDefender[entry.id]) == "table" and passiveNodesByDefender[entry.id] or {}

			for index, node in ipairs(templateNodes) do
				local state = "locked"
				local stateText = "Locked"
				local isUnlocked = unlockedNodes[entry.id] and unlockedNodes[entry.id][node.id] or false
				local milestone = tonumber(node.milestone) or 0
				local milestoneReached = milestone <= 0 or defenderLevel >= milestone
				local canUnlock = (not isUnlocked) and milestoneReached and availablePoints > 0 and index == (spentPoints + 1)
				if isUnlocked then
					state = "active"
					stateText = "Active"
				elseif canUnlock then
					state = "unlocked"
					stateText = "Unlocked"
				elseif not milestoneReached then
					stateText = string.format("Requires level %d", milestone)
				end

				local effects = type(node.effects) == "table" and node.effects or {}
				local bonus = effects.attackSummaryAppend or "-"
				if tonumber(effects.hpPercent) and tonumber(effects.damagePercent) then
					bonus = string.format("+%d%% Health, +%d%% Damage", tonumber(effects.hpPercent) or 0, tonumber(effects.damagePercent) or 0)
				elseif tonumber(effects.hpPercent) then
					bonus = string.format("+%d%% Max Health", tonumber(effects.hpPercent) or 0)
				elseif tonumber(effects.damagePercent) then
					bonus = string.format("+%d%% Damage", tonumber(effects.damagePercent) or 0)
				elseif tonumber(effects.speedPercent) then
					bonus = string.format("+%d%% Speed", tonumber(effects.speedPercent) or 0)
				elseif tonumber(effects.defenseFlat) or tonumber(effects.armorFlat) then
					bonus = string.format("+%d Defense, +%d Armor", tonumber(effects.defenseFlat) or 0, tonumber(effects.armorFlat) or 0)
				end

				nodes[#nodes + 1] = {
					id = node.id,
					milestone = milestone,
					short = node.short or "",
					icon = node.icon or "",
					state = state,
					stateText = stateText,
					name = node.name or "",
					bonus = bonus,
					description = node.description or "",
					cost = formatPassiveTreeCost(node.costs),
					canUnlock = guildId > 0 and canManage and canUnlock
				}
			end

			defenders[#defenders + 1] = {
				id = entry.id,
				name = entry.name,
				level = defenderLevel,
				points = availablePoints,
				spentPoints = spentPoints,
				maxPoints = totalPoints,
				nodes = nodes
			}
		end

		return {
			defenders = defenders,
			selectedDefenderId = defenders[1] and defenders[1].id or nil,
			selectedNodeId = nil
		}
	end

	local function getLevelConfigValue(config, prefix, level, fallback)
		local cfg = getConfig()
		level = math.max(1, math.floor(tonumber(level) or tonumber(cfg.DEFAULT_LEVEL) or 1))
		local configKey = prefix .. "_LVL" .. tostring(level)
		local value = config and config[configKey] or nil
		if value == nil then
			value = cfg[configKey]
		end
		if value == nil and config then
			value = config[prefix]
		end
		if value == nil then
			value = cfg[prefix]
		end
		if value == nil then
			value = fallback
		end
		return tonumber(value) or tonumber(fallback) or 0
	end

	local function getGuildDynastieProgress(guildId)
		local cfg = getConfig()
		local defaultLevel = math.max(1, tonumber(cfg.DEFAULT_LEVEL) or 1)
		local defaultExp = 0
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.getGuildRowById then
			local level, experience, nextLevelExp = calculateLevelProgress(defaultLevel, defaultExp)
			return level, experience, nextLevelExp
		end

		local guildRow = api.getGuildRowById(guildId)
		local level = defaultLevel
		local experience = defaultExp
		if guildRow then
			if api.hasColumn and api.hasColumn("guilds", "dynastie_level") then
				level = math.max(1, tonumber(guildRow.dynastie_level) or defaultLevel)
			end
			if api.hasColumn and api.hasColumn("guilds", "dynastie_experience") then
				experience = math.max(0, tonumber(guildRow.dynastie_experience) or defaultExp)
			end
		end

		return calculateLevelProgress(level, experience)
	end

	local function saveGuildDynastieProgress(guildId, level, experience)
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.hasColumn or not api.hasColumn("guilds", "dynastie_level") or not api.hasColumn("guilds", "dynastie_experience") then
			return false
		end

		level = math.max(1, math.floor(tonumber(level) or 1))
		experience = math.max(0, math.floor(tonumber(experience) or 0))
		return db.query(
			"UPDATE `guilds` SET `dynastie_level` = " .. level ..
			", `dynastie_experience` = " .. experience ..
			" WHERE `id` = " .. guildId
		)
	end

	local function awardGuildDynastieExperience(guildId, amount)
		guildId = tonumber(guildId) or 0
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if guildId <= 0 or amount <= 0 then
			return getGuildDynastieProgress(guildId)
		end

		local currentLevel, currentExp = getGuildDynastieProgress(guildId)
		local newLevel, newExp = calculateLevelProgress(currentLevel, currentExp + amount)
		saveGuildDynastieProgress(guildId, newLevel, newExp)
		return newLevel, newExp, newLevel > currentLevel
	end

	local function getPlacedItemIdForGuild(config, guildId)
		local level = select(1, getGuildDynastieProgress(guildId))
		return getLevelConfigValue(config, "DEFAULT_PLACED_ITEM_ID", level, getConfig().DEFAULT_PLACED_ITEM_ID)
	end

	local function getRequiredItemIdForGuild(config, guildId)
		local level = select(1, getGuildDynastieProgress(guildId))
		return getLevelConfigValue(config, "DEFAULT_REQUIRED_ITEM_ID", level, getConfig().DEFAULT_REQUIRED_ITEM_ID)
	end

	local function isValidPosition(pos)
		return pos and tonumber(pos.x) and tonumber(pos.y) and tonumber(pos.z) and (tonumber(pos.x) or 0) > 0 and (tonumber(pos.y) or 0) > 0
	end

	local function escape(value)
		return db.escapeString(value or "")
	end

	local function getClientItemId(serverItemId)
		local itemType = ItemType(tonumber(serverItemId) or 0)
		if not itemType or itemType:getId() == 0 then
			return 0
		end
		return tonumber(itemType:getClientId()) or 0
	end

	local clientIdToServerIdCache = nil

	local function getServerItemIdByClientId(clientId)
		clientId = tonumber(clientId) or 0
		if clientId <= 0 then
			return 0
		end

		if not clientIdToServerIdCache then
			clientIdToServerIdCache = {}
			for serverId = 1, 70000 do
				local itemType = ItemType(serverId)
				if itemType and itemType:getId() ~= 0 then
					local currentClientId = tonumber(itemType:getClientId()) or 0
					if currentClientId > 0 and not clientIdToServerIdCache[currentClientId] then
						clientIdToServerIdCache[currentClientId] = serverId
					end
				end
			end
		end

		return clientIdToServerIdCache[clientId] or 0
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

	local function cleanupTileItems(config, removeBase, state)
		if not config or not isValidPosition(config.position) then
			return
		end

		local tile = Tile(config.position)
		if not tile then
			return
		end

		local cfg = getConfig()
		local baseItemId = resolveWorldItemId(config.baseItemId or cfg.DEFAULT_BASE_ITEM_ID)
		local placedItemId = resolveWorldItemId(getPlacedItemIdForGuild(config, state and state.guildId or 0))
		for _, item in ipairs(tile:getItems() or {}) do
			local itemId = item:getId()
			if itemId == placedItemId or (removeBase and itemId == baseItemId) then
				item:remove()
			end
		end
	end

	local function spawnWorldItem(config, state)
		if not config or not isValidPosition(config.position) then
			return
		end

		local cfg = getConfig()
		if not state or not state.guildId or state.guildId <= 0 then
			cleanupTileItems(config, false, state)
			local markerItemId = resolveWorldItemId(config.baseItemId or cfg.DEFAULT_BASE_ITEM_ID or 0)
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

		cleanupTileItems(config, true, state)

		local itemId = resolveWorldItemId(getPlacedItemIdForGuild(config, state.guildId))
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
			spawned:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Guild dynastie owned by " .. (state.ownerPlayerName or "Unknown"))
		end
	end

	local function loadStateByConfigId()
		local byConfigId = {}
		if not api.hasTable or not api.hasTable("guild_dynasties") then
			return byConfigId
		end

		local resultId = db.storeQuery("SELECT * FROM `guild_dynasties`")
		if not resultId then
			return byConfigId
		end

		repeat
			local configId = result.getString(resultId, "config_id")
			byConfigId[configId] = {
				id = result.getNumber(resultId, "id"),
				guildId = result.getNumber(resultId, "guild_id"),
				configId = configId,
				ownerPlayerId = result.getNumber(resultId, "owner_player_id"),
				ownerPlayerName = result.getString(resultId, "owner_player_name"),
				baseItemId = result.getNumber(resultId, "base_item_id"),
				placedItemId = result.getNumber(resultId, "placed_item_id"),
				x = result.getNumber(resultId, "x"),
				y = result.getNumber(resultId, "y"),
				z = result.getNumber(resultId, "z"),
				radius = result.getNumber(resultId, "radius"),
			taxRate = result.getNumber(resultId, "tax_rate"),
			goldBuffer = result.getNumber(resultId, "gold_buffer"),
			bonusTokens = api.hasColumn and api.hasColumn("guild_dynasties", "bonus_tokens") and result.getNumber(resultId, "bonus_tokens") or 0,
			collectAvailableAt = result.getNumber(resultId, "collect_available_at"),
			placedAt = result.getNumber(resultId, "placed_at"),
				shieldUntil = api.hasColumn and api.hasColumn("guild_dynasties", "shield_until") and result.getNumber(resultId, "shield_until") or 0,
				updatedAt = result.getNumber(resultId, "updated_at")
			}
		until not result.next(resultId)
		result.free(resultId)
		return byConfigId
	end

	local function getPlaceCooldownUntil(guildId, configId)
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not configId or configId == "" or not api.hasTable or not api.hasTable("guild_dynastie_cooldowns") then
			return 0
		end

		local query = "SELECT `cooldown_until` FROM `guild_dynastie_cooldowns` WHERE `guild_id` = " .. guildId .. " AND `config_id` = " .. escape(configId)
		local resultId = db.storeQuery(query)
		if not resultId then
			return 0
		end

		local cooldownUntil = tonumber(result.getNumber(resultId, "cooldown_until")) or 0
		result.free(resultId)
		return cooldownUntil
	end

	local function setPlaceCooldown(guildId, configId, cooldownUntil)
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not configId or configId == "" or not api.hasTable or not api.hasTable("guild_dynastie_cooldowns") then
			return false
		end

		cooldownUntil = math.max(0, tonumber(cooldownUntil) or 0)
		local now = os.time()
		return db.query(
			"INSERT INTO `guild_dynastie_cooldowns` (`guild_id`, `config_id`, `cooldown_until`, `updated_at`) VALUES (" ..
			guildId .. ", " .. escape(configId) .. ", " .. cooldownUntil .. ", " .. now .. ") " ..
			"ON DUPLICATE KEY UPDATE `cooldown_until` = VALUES(`cooldown_until`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function getAttackCooldownUntil(attackerGuildId, configId)
		attackerGuildId = tonumber(attackerGuildId) or 0
		if attackerGuildId <= 0 or not configId or configId == "" or not api.hasTable or not api.hasTable("guild_dynastie_attack_cooldowns") then
			return 0
		end

		local query = "SELECT `cooldown_until` FROM `guild_dynastie_attack_cooldowns` WHERE `attacker_guild_id` = " .. attackerGuildId .. " AND `config_id` = " .. escape(configId)
		local resultId = db.storeQuery(query)
		if not resultId then
			return 0
		end

		local cooldownUntil = tonumber(result.getNumber(resultId, "cooldown_until")) or 0
		result.free(resultId)
		return cooldownUntil
	end

	local function setAttackCooldown(attackerGuildId, configId, cooldownUntil)
		attackerGuildId = tonumber(attackerGuildId) or 0
		if attackerGuildId <= 0 or not configId or configId == "" or not api.hasTable or not api.hasTable("guild_dynastie_attack_cooldowns") then
			return false
		end

		cooldownUntil = math.max(0, tonumber(cooldownUntil) or 0)
		local now = os.time()
		return db.query(
			"INSERT INTO `guild_dynastie_attack_cooldowns` (`attacker_guild_id`, `config_id`, `cooldown_until`, `updated_at`) VALUES (" ..
			attackerGuildId .. ", " .. escape(configId) .. ", " .. cooldownUntil .. ", " .. now .. ") " ..
			"ON DUPLICATE KEY UPDATE `cooldown_until` = VALUES(`cooldown_until`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function refreshWorld()
		local byConfigId = loadStateByConfigId()
		for _, config in ipairs(getConfigList()) do
			spawnWorldItem(config, byConfigId[config.id])
		end
	end

	local function refreshAllDynastieViewers()
		for guid, page in pairs(dynastieViewerPages) do
			local player = Player(guid)
			if player and dynastieActiveViewers[guid] == true then
				dynastieApi.send(player, page)
			else
				dynastieViewerPages[guid] = nil
				dynastieActiveViewers[guid] = nil
			end
		end
	end

	local function resolveDynastieAtPosition(position)
		if not position then
			return nil, nil
		end

		local px = tonumber(position.x) or 0
		local py = tonumber(position.y) or 0
		local pz = tonumber(position.z) or -1
		if px <= 0 or py <= 0 or pz < 0 then
			return nil, nil
		end

		local byConfigId = loadStateByConfigId()
		for _, config in ipairs(getConfigList()) do
			local state = byConfigId[config.id]
			if state then
				local cx = tonumber(state.x or (config.position and config.position.x) or 0) or 0
				local cy = tonumber(state.y or (config.position and config.position.y) or 0) or 0
				local cz = tonumber(state.z or (config.position and config.position.z) or 0) or 0
				local radius = tonumber(state.radius or config.radius or getConfig().DEFAULT_RADIUS or 80) or 80
				if math.abs(cz - pz) <= 15 and math.abs(px - cx) <= radius and math.abs(py - cy) <= radius then
					return state, config
				end
			end
		end

		return nil, nil
	end

	local function computeTradeTaxAmount(baseAmount, taxRate)
		baseAmount = math.max(0, math.floor(tonumber(baseAmount) or 0))
		taxRate = math.max(0, math.floor(tonumber(taxRate) or 0))
		if baseAmount <= 0 or taxRate <= 0 then
			return 0
		end

		local taxAmount = math.floor((baseAmount * taxRate) / 100)
		if taxAmount <= 0 and baseAmount > 0 then
			taxAmount = 1
		end
		if taxAmount > baseAmount then
			taxAmount = baseAmount
		end
		return taxAmount
	end

	local function getTradeDisplayValues(player, buyPrice, sellPrice)
		if not player then
			return math.max(0, math.floor(tonumber(buyPrice) or 0)), math.max(0, math.floor(tonumber(sellPrice) or 0)), 0, nil, nil
		end

		local state, config = resolveDynastieAtPosition(player:getPosition())
		if not state or not config then
			return math.max(0, math.floor(tonumber(buyPrice) or 0)), math.max(0, math.floor(tonumber(sellPrice) or 0)), 0, nil, nil
		end

		local taxRate = math.max(0, math.floor(tonumber(state.taxRate) or 0))
		local adjustedBuy = math.max(0, math.floor(tonumber(buyPrice) or 0))
		local adjustedSell = math.max(0, math.floor(tonumber(sellPrice) or 0))
		if taxRate > 0 then
			local buyTaxAmount = computeTradeTaxAmount(adjustedBuy, taxRate)
			local sellTaxAmount = computeTradeTaxAmount(adjustedSell, taxRate)
			local taxBoomBonusPercent = _G.GuildDynastieEvents and _G.GuildDynastieEvents.getTaxBonusPercent and _G.GuildDynastieEvents.getTaxBonusPercent(state.configId, os.time()) or 0
			if taxBoomBonusPercent > 0 then
				if buyTaxAmount > 0 then
					buyTaxAmount = math.floor(buyTaxAmount * (1 + (taxBoomBonusPercent / 100)))
				end
				if sellTaxAmount > 0 then
					sellTaxAmount = math.floor(sellTaxAmount * (1 + (taxBoomBonusPercent / 100)))
				end
			end
			adjustedBuy = adjustedBuy + buyTaxAmount
			adjustedSell = math.max(0, adjustedSell - sellTaxAmount)
		end

		return adjustedBuy, adjustedSell, taxRate, state, config
	end

	local function applyTradeTax(player, baseAmount)
		if not player then
			return 0, nil, nil
		end

		baseAmount = math.max(0, math.floor(tonumber(baseAmount) or 0))
		if baseAmount <= 0 then
			return 0, nil, nil
		end

		local state, config = resolveDynastieAtPosition(player:getPosition())
		if not state or not config then
			return 0, nil, nil
		end

		local taxRate = math.max(0, math.floor(tonumber(state.taxRate) or 0))
		if taxRate <= 0 then
			return 0, state, config
		end

		local taxAmount = computeTradeTaxAmount(baseAmount, taxRate)
		local taxBoomBonusPercent = _G.GuildDynastieEvents and _G.GuildDynastieEvents.getTaxBonusPercent and _G.GuildDynastieEvents.getTaxBonusPercent(state.configId, os.time()) or 0
		if taxAmount > 0 and taxBoomBonusPercent > 0 then
			taxAmount = math.floor(taxAmount * (1 + (taxBoomBonusPercent / 100)))
		end

		if taxAmount > 0 then
			local updates = {
				"`gold_buffer` = `gold_buffer` + " .. taxAmount,
				"`updated_at` = " .. os.time()
			}
			db.query("UPDATE `guild_dynasties` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. tonumber(state.id or 0))
			local _, _, leveledUp = awardGuildDynastieExperience(state.guildId, taxAmount)
			if leveledUp then
				refreshWorld()
				refreshAllDynastieViewers()
				api.refreshGuildForMembers(state.guildId)
			end
			if questHooks.awardTaxProgress then
				questHooks.awardTaxProgress(state.guildId, state.configId, taxAmount)
			end
		end

		return taxAmount, state, config
	end

	local function getGuildName(guildId)
		local row = api.getGuildRowById and api.getGuildRowById(guildId)
		if row and tostring(row.name or "") ~= "" then
			return tostring(row.name)
		end
		return "Guild #" .. tostring(guildId)
	end

	local function resolveOwnerPlayerName(state)
		if type(state) ~= "table" then
			return ""
		end

		local storedName = tostring(state.ownerPlayerName or "")
		if storedName ~= "" then
			return storedName
		end

		local ownerPlayerId = tonumber(state.ownerPlayerId or 0) or 0
		if ownerPlayerId > 0 then
			local resultId = db.storeQuery("SELECT `name` FROM `players` WHERE `id` = " .. ownerPlayerId .. " LIMIT 1")
			if resultId then
				local name = tostring(result.getString(resultId, "name") or "")
				result.free(resultId)
				return name
			end
		end

		return ""
	end

	calculateLevelProgress = function(level, experience)
		local cfg = getConfig()
		local levelCap = math.max(1, tonumber(cfg.DEFAULT_LEVEL_CAP) or 10)
		local baseExp = math.max(1, tonumber(cfg.DEFAULT_LEVEL_BASE_EXP) or 2500)
		local currentLevel = math.max(1, math.floor(tonumber(level) or tonumber(cfg.DEFAULT_LEVEL) or 1))
		local currentExp = math.max(0, math.floor(tonumber(experience) or 0))

		while currentLevel < levelCap do
			local required = math.max(baseExp, currentLevel * baseExp)
			if currentExp < required then
				return currentLevel, currentExp, required
			end
			currentExp = currentExp - required
			currentLevel = currentLevel + 1
		end

		return levelCap, currentExp, math.max(baseExp, levelCap * baseExp)
	end

	local function resolvePlayerGuildId(player)
		if not player or not api.resolvePlayerGuildId then
			return 0
		end
		return tonumber(api.resolvePlayerGuildId(player)) or 0
	end

	local function isGuildOwner(player, guildId)
		guildId = tonumber(guildId) or 0
		if not player or guildId <= 0 or not api.getGuildRowById then
			return false
		end
		local guildRow = api.getGuildRowById(guildId)
		return guildRow and tonumber(guildRow.ownerid or 0) == tonumber(player:getGuid() or 0) or false
	end

	local function canManageDynastie(player, guildId)
		if player and player.getGuildLevel and tonumber(player:getGuildLevel() or 0) >= 3 then
			return true
		end
		if isGuildOwner(player, guildId) then
			return true
		end
		return api.hasPermission and api.hasPermission(player, 10) or false
	end

	local function getAttackAreaRadius(state)
		local configured = tonumber(api.attackAreaRadius or 0) or 0
		if configured > 0 then
			return configured
		end
		return tonumber(state and state.radius or 0) or 0
	end

	local function getAttackAreaFloorRange()
		local configured = tonumber(api.attackAreaFloors or 0) or 0
		if configured > 0 then
			return configured
		end
		return 0
	end

	local function isInsideAttackArea(state, position)
		if not state or not position then
			return false
		end

		local radius = getAttackAreaRadius(state)
		if radius <= 0 then
			return false
		end

		local center = { x = tonumber(state.x) or 0, y = tonumber(state.y) or 0, z = tonumber(state.z) or 0 }
		local dx = math.abs((tonumber(position.x) or 0) - center.x)
		local dy = math.abs((tonumber(position.y) or 0) - center.y)
		local dz = math.abs((tonumber(position.z) or 0) - center.z)
		return dz <= getAttackAreaFloorRange() and dx <= radius and dy <= radius
	end

	local function isBattleEligiblePosition(state, position)
		if not isInsideAttackArea(state, position) then
			return false
		end

		local tile = Tile(position)
		if not tile then
			return false
		end

		if tile:hasFlag(TILESTATE_PROTECTIONZONE) then
			return false
		end

		return true
	end

	local function getAttackGuildName(guildId)
		local guild = guildId and Guild(guildId) or nil
		return guild and guild:getName() or ("Guild #" .. tostring(guildId or 0))
	end

	local function getDefenderSpawnOffsets()
		return {
			{ x = -3, y = -3 }, { x = 0, y = -3 }, { x = 3, y = -3 },
			{ x = -3, y = 0 }, { x = 3, y = 0 },
			{ x = -3, y = 3 }, { x = 0, y = 3 }, { x = 3, y = 3 },
			{ x = -5, y = -2 }, { x = 5, y = -2 }, { x = -5, y = 2 }, { x = 5, y = 2 },
			{ x = -2, y = -5 }, { x = 2, y = -5 }, { x = -2, y = 5 }, { x = 2, y = 5 }
		}
	end

	local function getDefenderAnchorPosition(state, slotIndex)
		local offsets = getDefenderSpawnOffsets()
		local offset = offsets[((slotIndex - 1) % #offsets) + 1]
		return Position((tonumber(state.x) or 0) + offset.x, (tonumber(state.y) or 0) + offset.y, tonumber(state.z) or 0)
	end

	local function buildDefenderSlots(attack, guildId)
		local perkLevels = loadDefenderPerkLevels(guildId)
		local slots = {}
		for _, template in ipairs(DefenderTemplates) do
			local unlockedCount = math.min(getPerkLevelCap(getDefenderPerkTemplate(template.id)), math.max(0, tonumber(perkLevels[template.id]) or 0))
			for count = 1, unlockedCount do
				slots[#slots + 1] = {
					slotId = template.id .. ":" .. count,
					defenderId = template.id,
					monsterName = template.monsterName,
					order = #slots + 1,
					monsterId = 0,
					respawnAt = 0,
					deadAt = 0
				}
			end
		end
		attack.defenders = attack.defenders or {}
		attack.defenders.slots = slots
		attack.defenders.byMonsterId = attack.defenders.byMonsterId or {}
	end

	local function cleanupAttackDefenders(attack)
		if not attack or not attack.defenders then
			return
		end

		for _, slot in ipairs(attack.defenders.slots or {}) do
			local defender = slot.monsterId > 0 and Monster(slot.monsterId) or nil
			if defender and not defender:isRemoved() then
				defender:remove()
			end
			slot.monsterId = 0
			slot.respawnAt = 0
			slot.deadAt = 0
		end
		attack.defenders.byMonsterId = {}
	end

	local function buildActiveAttackerTargets(attack, state)
		local targets = {}
		for guid, member in pairs(attack.members or {}) do
			local participant = Player(guid)
			if participant and not member.removed and member.role == "attacker" and member.guildId == attack.attackerGuildId and isBattleEligiblePosition(state, participant:getPosition()) then
				targets[#targets + 1] = participant
			end
		end
		return targets
	end

	local function getNearestTarget(originPosition, targets)
		local nearestTarget = nil
		local nearestDistance = nil
		for _, target in ipairs(targets or {}) do
			local pos = target:getPosition()
			local dx = math.abs((originPosition.x or 0) - (pos.x or 0))
			local dy = math.abs((originPosition.y or 0) - (pos.y or 0))
			local distance = dx + dy
			if not nearestDistance or distance < nearestDistance then
				nearestDistance = distance
				nearestTarget = target
			end
		end
		return nearestTarget
	end

	local function isWithinDefenderChaseRadius(anchorPosition, targetPosition)
		if not anchorPosition or not targetPosition then
			return false
		end

		local dx = math.abs((anchorPosition.x or 0) - (targetPosition.x or 0))
		local dy = math.abs((anchorPosition.y or 0) - (targetPosition.y or 0))
		local dz = math.abs((anchorPosition.z or 0) - (targetPosition.z or 0))
		return dz == 0 and dx <= DEFENDER_CHASE_RADIUS and dy <= DEFENDER_CHASE_RADIUS
	end

	local function getTileDistance(fromPosition, toPosition)
		if not fromPosition or not toPosition then
			return 999
		end

		local dz = math.abs((fromPosition.z or 0) - (toPosition.z or 0))
		if dz > 0 then
			return 999
		end

		local dx = math.abs((fromPosition.x or 0) - (toPosition.x or 0))
		local dy = math.abs((fromPosition.y or 0) - (toPosition.y or 0))
		return math.max(dx, dy)
	end

	local function computeDefenderDamageRange(meta)
		local template = meta and getDefenderTemplate(meta.defenderId) or nil
		if not template then
			return 50, 100
		end

		local level = math.min(getDefenderLevelCap(), math.max(0, tonumber(loadDefenderLevels(meta.defenderGuildId)[meta.defenderId]) or 0))
		local scaled = scaleDefenderStats(template, level)
		local damagePercent = tonumber(meta.passiveEffects and meta.passiveEffects.damagePercent) or 0
		local multiplier = 1 + (damagePercent / 100)
		local min = math.max(1, math.floor((tonumber(scaled.damageMin) or 1) * multiplier))
		local max = math.max(min, math.floor((tonumber(scaled.damageMax) or min) * multiplier))
		return min, max
	end

	local function dealDefenderSpellDamage(caster, target, combatType, minDamage, maxDamage, effect)
		if not caster or caster:isRemoved() or not target or target:isRemoved() then
			return false
		end
		doTargetCombatHealth(caster, target, combatType, -minDamage, -maxDamage, effect or CONST_ME_NONE)
		return true
	end

	local function collectEnemyTargetsAroundPosition(centerPosition, radius, defender, limit, preferredTarget)
		local targets = {}
		local used = {}

		local function addTarget(candidate)
			if not candidate or candidate:isRemoved() or not candidate:isPlayer() then
				return false
			end
			if _G.GuildDynastie_canDefenderTarget and not _G.GuildDynastie_canDefenderTarget(defender, candidate) then
				return false
			end
			local candidateId = candidate:getId()
			if used[candidateId] then
				return false
			end
			used[candidateId] = true
			targets[#targets + 1] = candidate
			return limit and #targets >= limit or false
		end

		if preferredTarget and addTarget(preferredTarget) then
			return targets
		end

		for _, spectator in ipairs(Game.getSpectators(centerPosition, false, false, radius, radius, radius, radius) or {}) do
			if addTarget(spectator) then
				break
			end
		end

		return targets
	end

	local function castDefenderMultiShot(defender, targets, combatType, minDamage, maxDamage, effect, distanceEffect)
		local hitCount = 0
		local origin = defender:getPosition()
		for _, target in ipairs(targets or {}) do
			if distanceEffect then
				origin:sendDistanceEffect(target:getPosition(), distanceEffect)
			end
			if dealDefenderSpellDamage(defender, target, combatType, minDamage, maxDamage, effect) then
				hitCount = hitCount + 1
			end
		end
		return hitCount > 0
	end

	local function castDefenderAreaBurst(defender, centerPosition, radius, combatType, minDamage, maxDamage, effect, areaEffect, primaryTarget)
		if areaEffect then
			centerPosition:sendMagicEffect(areaEffect)
		end
		local targets = collectEnemyTargetsAroundPosition(centerPosition, radius, defender, nil, primaryTarget)
		return castDefenderMultiShot(defender, targets, combatType, minDamage, maxDamage, effect, nil)
	end

	local function castDefenderSelfHeal(defender, healPercent, effect)
		if not defender or defender:isRemoved() then
			return false
		end

		local maxHealth = math.max(1, tonumber(defender:getMaxHealth()) or 1)
		local currentHealth = math.max(0, tonumber(defender:getHealth()) or 0)
		if currentHealth >= maxHealth then
			return false
		end

		local healAmount = math.max(1, math.floor(maxHealth * healPercent))
		defender:addHealth(healAmount)
		if effect then
			defender:getPosition():sendMagicEffect(effect)
		end
		return true
	end

	local function setDefenderIdleState(defender, anchor)
		if not defender or defender:isRemoved() then
			return
		end

		defender:setTarget(nil)
		if defender.setFollowCreature then
			pcall(function()
				defender:setFollowCreature(nil)
			end)
		end
		if defender.setNoMove then
			pcall(function()
				defender:setNoMove(true)
			end)
		end

		if anchor then
			local defenderPos = defender:getPosition()
			local dx = math.abs((defenderPos.x or 0) - (anchor.x or 0))
			local dy = math.abs((defenderPos.y or 0) - (anchor.y or 0))
			if dx > 0 or dy > 0 or (defenderPos.z or 0) ~= (anchor.z or 0) then
				defender:teleportTo(anchor, true)
			end
		end
	end

	local function engageDefenderTarget(defender, target)
		if not defender or defender:isRemoved() or not target or target:isRemoved() then
			return false
		end

		if defender.setNoMove then
			pcall(function()
				defender:setNoMove(false)
			end)
		end
		if defender.setFollowCreature then
			pcall(function()
				defender:setFollowCreature(target)
			end)
		end
		if defender.selectTarget then
			local selected = false
			pcall(function()
				selected = defender:selectTarget(target)
			end)
			if selected then
				return true
			end
		end
		defender:setTarget(target)
		return true
	end

	local function castKnightCleave(defender, target, meta)
		local defenderPos = defender:getPosition()
		local targets = Game.getSpectators(defenderPos, false, false, 1, 1, 1, 1) or {}
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		local hitCount = 0

		for _, spectator in ipairs(targets) do
			if spectator and spectator:isPlayer() and _G.GuildDynastie_canDefenderTarget and _G.GuildDynastie_canDefenderTarget(defender, spectator) then
				if dealDefenderSpellDamage(defender, spectator, COMBAT_PHYSICALDAMAGE, math.floor(minDamage * 0.75), math.floor(maxDamage * 0.85), CONST_ME_EXPLOSIONAREA) then
					hitCount = hitCount + 1
				end
			end
		end

		if hitCount > 0 then
			defenderPos:sendMagicEffect(CONST_ME_EXPLOSIONAREA)
			return true
		end
		return false
	end

	local function castPaladinHolyVolley(defender, target, meta)
		local targets = {}
		local currentTargetPos = target:getPosition()
		targets[#targets + 1] = target
		for _, spectator in ipairs(Game.getSpectators(currentTargetPos, false, false, 2, 2, 2, 2) or {}) do
			if spectator and spectator:isPlayer() and spectator ~= target and _G.GuildDynastie_canDefenderTarget and _G.GuildDynastie_canDefenderTarget(defender, spectator) then
				targets[#targets + 1] = spectator
				if #targets >= 3 then
					break
				end
			end
		end

		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		local hitCount = 0
		for _, volleyTarget in ipairs(targets) do
			defender:getPosition():sendDistanceEffect(volleyTarget:getPosition(), CONST_ANI_HOLY)
			if dealDefenderSpellDamage(defender, volleyTarget, COMBAT_HOLYDAMAGE, math.floor(minDamage * 0.6), math.floor(maxDamage * 0.75), CONST_ME_HOLYDAMAGE) then
				hitCount = hitCount + 1
			end
		end
		return hitCount > 0
	end

	local function castMageArcaneNova(defender, target, meta)
		local center = target:getPosition()
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return castDefenderAreaBurst(defender, center, 1, COMBAT_ENERGYDAMAGE, math.floor(minDamage * 0.7), math.floor(maxDamage * 0.9), CONST_ME_ENERGYHIT, CONST_ME_ENERGYAREA, target)
	end

	local function castPaladinRadiantBurst(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return castDefenderAreaBurst(defender, target:getPosition(), 1, COMBAT_HOLYDAMAGE, math.floor(minDamage * 0.85), math.floor(maxDamage * 1.00), CONST_ME_HOLYDAMAGE, CONST_ME_HOLYDAMAGE, target)
	end

	local function castPaladinSanctuary(defender, target, meta)
		local currentHealth = math.max(0, tonumber(defender:getHealth()) or 0)
		local maxHealth = math.max(1, tonumber(defender:getMaxHealth()) or 1)
		if currentHealth > math.floor(maxHealth * 0.7) then
			return false
		end
		return castDefenderSelfHeal(defender, 0.18, CONST_ME_HOLYAREA)
	end

	local function castPaladinJudgmentChain(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		local targets = collectEnemyTargetsAroundPosition(target:getPosition(), 3, defender, 4, target)
		return castDefenderMultiShot(defender, targets, COMBAT_HOLYDAMAGE, math.floor(minDamage * 0.7), math.floor(maxDamage * 0.9), CONST_ME_HOLYDAMAGE, CONST_ANI_HOLY)
	end

	local function castPaladinDivineStorm(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return castDefenderAreaBurst(defender, target:getPosition(), 2, COMBAT_HOLYDAMAGE, math.floor(minDamage * 1.05), math.floor(maxDamage * 1.25), CONST_ME_HOLYDAMAGE, CONST_ME_HOLYAREA, target)
	end

	local function castKnightShieldBash(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return dealDefenderSpellDamage(defender, target, COMBAT_PHYSICALDAMAGE, math.floor(minDamage * 1.0), math.floor(maxDamage * 1.2), CONST_ME_DRAWBLOOD)
	end

	local function castKnightWarStomp(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return castDefenderAreaBurst(defender, defender:getPosition(), 1, COMBAT_PHYSICALDAMAGE, math.floor(minDamage * 0.9), math.floor(maxDamage * 1.05), CONST_ME_EXPLOSIONAREA, CONST_ME_EXPLOSIONAREA, nil)
	end

	local function castKnightEarthshatter(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return castDefenderAreaBurst(defender, target:getPosition(), 1, COMBAT_PHYSICALDAMAGE, math.floor(minDamage * 1.0), math.floor(maxDamage * 1.15), CONST_ME_GROUNDSHAKER, CONST_ME_GROUNDSHAKER, target)
	end

	local function castKnightExecution(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		local multiplier = target:getHealth() <= math.floor(target:getMaxHealth() * 0.4) and 1.65 or 1.25
		return dealDefenderSpellDamage(defender, target, COMBAT_PHYSICALDAMAGE, math.floor(minDamage * multiplier), math.floor(maxDamage * (multiplier + 0.15)), CONST_ME_DRAWBLOOD)
	end

	local function castMageFlameBurst(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return castDefenderAreaBurst(defender, target:getPosition(), 1, COMBAT_FIREDAMAGE, math.floor(minDamage * 0.85), math.floor(maxDamage * 1.00), CONST_ME_HITBYFIRE, CONST_ME_FIREAREA, target)
	end

	local function castMageFrostWave(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		return castDefenderAreaBurst(defender, defender:getPosition(), 2, COMBAT_ICEDAMAGE, math.floor(minDamage * 0.75), math.floor(maxDamage * 0.95), CONST_ME_ICEATTACK, CONST_ME_ICEATTACK, target)
	end

	local function castMageChainLightning(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		local targets = collectEnemyTargetsAroundPosition(target:getPosition(), 3, defender, 4, target)
		return castDefenderMultiShot(defender, targets, COMBAT_ENERGYDAMAGE, math.floor(minDamage * 0.75), math.floor(maxDamage * 0.95), CONST_ME_ENERGYHIT, CONST_ANI_ENERGY)
	end

	local function castMageAstralCataclysm(defender, target, meta)
		local minDamage, maxDamage = computeDefenderDamageRange(meta)
		local hitEnergy = castDefenderAreaBurst(defender, target:getPosition(), 2, COMBAT_ENERGYDAMAGE, math.floor(minDamage * 0.9), math.floor(maxDamage * 1.05), CONST_ME_ENERGYHIT, CONST_ME_MORTAREA, target)
		local hitFire = castDefenderAreaBurst(defender, target:getPosition(), 2, COMBAT_FIREDAMAGE, math.floor(minDamage * 0.9), math.floor(maxDamage * 1.05), CONST_ME_FIREAREA, CONST_ME_FIREAREA, target)
		return hitEnergy or hitFire
	end

	local function tryCastDefenderPassiveSkill(defender, target, meta, now)
		if not defender or defender:isRemoved() or not target or target:isRemoved() or not meta then
			return
		end

		meta.abilityCooldowns = meta.abilityCooldowns or {}
		local passiveEffects = meta.passiveEffects or {}
		local distanceToTarget = getTileDistance(defender:getPosition(), target:getPosition())

		if passiveEffects.divineStorm and (tonumber(meta.abilityCooldowns.divineStorm) or 0) <= now then
			if distanceToTarget <= 5 and castPaladinDivineStorm(defender, target, meta) then
				meta.abilityCooldowns.divineStorm = now + 16
				return
			end
		end

		if passiveEffects.execution and (tonumber(meta.abilityCooldowns.execution) or 0) <= now then
			if distanceToTarget <= 1 and castKnightExecution(defender, target, meta) then
				meta.abilityCooldowns.execution = now + 14
				return
			end
		end

		if passiveEffects.astralCataclysm and (tonumber(meta.abilityCooldowns.astralCataclysm) or 0) <= now then
			if distanceToTarget <= 5 and castMageAstralCataclysm(defender, target, meta) then
				meta.abilityCooldowns.astralCataclysm = now + 16
				return
			end
		end

		if passiveEffects.cleave and (tonumber(meta.abilityCooldowns.cleave) or 0) <= now then
			if distanceToTarget <= 1 and castKnightCleave(defender, target, meta) then
				meta.abilityCooldowns.cleave = now + 6
				return
			end
		end

		if passiveEffects.holyVolley and (tonumber(meta.abilityCooldowns.holyVolley) or 0) <= now then
			if distanceToTarget <= 5 and castPaladinHolyVolley(defender, target, meta) then
				meta.abilityCooldowns.holyVolley = now + 7
				return
			end
		end

		if passiveEffects.arcaneNova and (tonumber(meta.abilityCooldowns.arcaneNova) or 0) <= now then
			if distanceToTarget <= 4 and castMageArcaneNova(defender, target, meta) then
				meta.abilityCooldowns.arcaneNova = now + 8
				return
			end
		end

		if passiveEffects.radiantBurst and (tonumber(meta.abilityCooldowns.radiantBurst) or 0) <= now then
			if distanceToTarget <= 5 and castPaladinRadiantBurst(defender, target, meta) then
				meta.abilityCooldowns.radiantBurst = now + 10
				return
			end
		end

		if passiveEffects.sanctuary and (tonumber(meta.abilityCooldowns.sanctuary) or 0) <= now then
			if castPaladinSanctuary(defender, target, meta) then
				meta.abilityCooldowns.sanctuary = now + 18
				return
			end
		end

		if passiveEffects.judgmentChain and (tonumber(meta.abilityCooldowns.judgmentChain) or 0) <= now then
			if distanceToTarget <= 5 and castPaladinJudgmentChain(defender, target, meta) then
				meta.abilityCooldowns.judgmentChain = now + 12
				return
			end
		end

		if passiveEffects.shieldBash and (tonumber(meta.abilityCooldowns.shieldBash) or 0) <= now then
			if distanceToTarget <= 1 and castKnightShieldBash(defender, target, meta) then
				meta.abilityCooldowns.shieldBash = now + 10
				return
			end
		end

		if passiveEffects.warStomp and (tonumber(meta.abilityCooldowns.warStomp) or 0) <= now then
			if distanceToTarget <= 1 and castKnightWarStomp(defender, target, meta) then
				meta.abilityCooldowns.warStomp = now + 12
				return
			end
		end

		if passiveEffects.earthshatter and (tonumber(meta.abilityCooldowns.earthshatter) or 0) <= now then
			if distanceToTarget <= 4 and castKnightEarthshatter(defender, target, meta) then
				meta.abilityCooldowns.earthshatter = now + 13
				return
			end
		end

		if passiveEffects.flameBurst and (tonumber(meta.abilityCooldowns.flameBurst) or 0) <= now then
			if distanceToTarget <= 5 and castMageFlameBurst(defender, target, meta) then
				meta.abilityCooldowns.flameBurst = now + 10
				return
			end
		end

		if passiveEffects.frostWave and (tonumber(meta.abilityCooldowns.frostWave) or 0) <= now then
			if distanceToTarget <= 3 and castMageFrostWave(defender, target, meta) then
				meta.abilityCooldowns.frostWave = now + 12
				return
			end
		end

		if passiveEffects.chainLightning and (tonumber(meta.abilityCooldowns.chainLightning) or 0) <= now then
			if distanceToTarget <= 5 and castMageChainLightning(defender, target, meta) then
				meta.abilityCooldowns.chainLightning = now + 13
				return
			end
		end
	end

	local function spawnDefenderForSlot(attack, state, slot)
		local spawnPosition = getDefenderAnchorPosition(state, slot.order)
		local monster = Game.createMonster(slot.monsterName, spawnPosition, false, true)
		if not monster then
			local fallbackOffsets = getDefenderSpawnOffsets()
			for _, offset in ipairs(fallbackOffsets) do
				local fallback = Position((tonumber(state.x) or 0) + offset.x, (tonumber(state.y) or 0) + offset.y, tonumber(state.z) or 0)
				monster = Game.createMonster(slot.monsterName, fallback, false, true)
				if monster then
					break
				end
			end
		end

		if not monster then
			slot.respawnAt = os.time() + 10
			return
		end

		slot.monsterId = monster:getId()
		slot.deadAt = 0
		slot.respawnAt = 0
		local passiveEffects = getAggregatedPassiveEffects(attack.defenderGuildId, slot.defenderId)
		local template = getDefenderTemplate(slot.defenderId)
		if template then
			local level = math.min(getDefenderLevelCap(), math.max(0, tonumber(loadDefenderLevels(attack.defenderGuildId)[slot.defenderId]) or 0))
			local scaled = scaleDefenderStats(template, level)
			if monster.rename then
				pcall(function()
					monster:rename(string.format("%s [%d]", tostring(template.name or slot.monsterName), level))
				end)
			end
			local targetMaxHealth = math.max(1, scaled.maxHealth)
			local bonusHealth = math.max(0, math.floor(scaled.maxHealth * ((tonumber(passiveEffects.hpPercent) or 0) / 100)))
			local finalMaxHealth = targetMaxHealth + bonusHealth
			local targetSpeed = math.max(0, scaled.speed)
			local bonusSpeed = math.max(0, math.floor(targetSpeed * ((tonumber(passiveEffects.speedPercent) or 0) / 100)))
			local finalSpeed = targetSpeed + bonusSpeed
			local currentMaxHealth = monster:getMaxHealth()
			if currentMaxHealth ~= finalMaxHealth then
				monster:setMaxHealth(finalMaxHealth)
			end
			monster:setHealth(finalMaxHealth)
			local currentSpeed = monster:getSpeed()
			if currentSpeed ~= finalSpeed then
				monster:changeSpeed(finalSpeed - currentSpeed)
			end
		end
		attack.defenders.byMonsterId[slot.monsterId] = {
			configId = attack.configId,
			defenderGuildId = attack.defenderGuildId,
			attackerGuildId = attack.attackerGuildId,
			slotId = slot.slotId,
			defenderId = slot.defenderId,
			passiveEffects = passiveEffects,
			abilityCooldowns = {}
		}
		setDefenderIdleState(monster, spawnPosition)
	end

	local function maintainAttackDefenders(attack, state)
		if not attack or not state then
			return
		end

		if not attack.defenders or not attack.defenders.slots then
			buildDefenderSlots(attack, attack.defenderGuildId)
		end

		local now = os.time()
		local validTargets = buildActiveAttackerTargets(attack, state)
		for _, slot in ipairs(attack.defenders.slots or {}) do
			local defender = slot.monsterId > 0 and Monster(slot.monsterId) or nil
			if defender and defender:isRemoved() then
				defender = nil
			end

			if not defender then
				if slot.monsterId > 0 then
					attack.defenders.byMonsterId[slot.monsterId] = nil
					slot.monsterId = 0
					slot.deadAt = now
					slot.respawnAt = now + 60
				end
				if slot.respawnAt <= 0 or now >= slot.respawnAt then
					spawnDefenderForSlot(attack, state, slot)
				end
			else
				local anchor = getDefenderAnchorPosition(state, slot.order)
				local defenderPos = defender:getPosition()
				local dx = math.abs((defenderPos.x or 0) - (anchor.x or 0))
				local dy = math.abs((defenderPos.y or 0) - (anchor.y or 0))
				if (defenderPos.z or 0) ~= (anchor.z or 0) or dx > 10 or dy > 10 then
					defender:teleportTo(anchor, true)
				end

				local filteredTargets = {}
				for _, target in ipairs(validTargets) do
					if isWithinDefenderChaseRadius(anchor, target:getPosition()) then
						filteredTargets[#filteredTargets + 1] = target
					end
				end

				local target = getNearestTarget(defender:getPosition(), filteredTargets)
				if target then
					engageDefenderTarget(defender, target)
					local meta = attack.defenders.byMonsterId[slot.monsterId]
					if meta then
						tryCastDefenderPassiveSkill(defender, target, meta, now)
					end
				else
					setDefenderIdleState(defender, anchor)
				end
			end
		end
	end

	local function syncAttackParticipants(attack, state)
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
				if isBattleEligiblePosition(state, participant:getPosition()) then
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

	local function buildAttackPayload(configId, viewerGuildId)
		local attack = DynastieAttackState.byConfigId[configId]
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
			attackerGuildName = getAttackGuildName(attack.attackerGuildId),
			defenderGuildId = attack.defenderGuildId,
			defenderGuildName = getAttackGuildName(attack.defenderGuildId),
			startsAt = tonumber(attack.startsAt or 0) or 0,
			endsAt = tonumber(attack.endsAt or 0) or 0,
			attackerCount = attackerCount,
			defenderCount = defenderCount,
			participant = viewerGuildId > 0 and (viewerGuildId == attack.attackerGuildId or viewerGuildId == attack.defenderGuildId) or false
		}
	end

	local function notifyAttackGuilds(configId, text)
		local attack = DynastieAttackState.byConfigId[configId]
		if not attack then
			return
		end

		local config = getConfigById(configId)
		local locationName = config and config.name or "Dynasty"
		local messageText = "[" .. locationName .. "] " .. text
		api.addGuildMessages(api.getGuildInboxRecipients(attack.attackerGuildId), attack.attackerGuildId, api.messageTypes.DYNASTIE_ATTACK, messageText, 0, attack.defenderGuildId)
		api.addGuildMessages(api.getGuildInboxRecipients(attack.defenderGuildId), attack.defenderGuildId, api.messageTypes.DYNASTIE_ATTACK, messageText, 0, attack.attackerGuildId)
	end

	local function removeAttack(configId)
		local attack = DynastieAttackState.byConfigId[configId]
		if attack then
			cleanupAttackDefenders(attack)
		end
		DynastieAttackState.byConfigId[configId] = nil
		refreshAllDynastieViewers()
	end

	local function resolveAttack(configId, attackerWon)
		local attack = DynastieAttackState.byConfigId[configId]
		local byConfigId = loadStateByConfigId()
		local state = byConfigId[configId]
		local config = getConfigById(configId)
		if not attack or not state or not config then
			removeAttack(configId)
			return
		end

		local now = os.time()
		if attackerWon then
			local stolenGold = tonumber(state.goldBuffer or 0) or 0
			local stolenTokens = getStoredDynastieTokens(state, now)
			if stolenGold > 0 and api.hasColumn and api.hasColumn("guilds", "balance") then
				db.query("UPDATE `guilds` SET `balance` = `balance` + " .. stolenGold .. " WHERE `id` = " .. attack.attackerGuildId)
			end
			if stolenTokens > 0 and api.hasColumn and api.hasColumn("guilds", "dynastie_tokens") then
				db.query("UPDATE `guilds` SET `dynastie_tokens` = `dynastie_tokens` + " .. stolenTokens .. " WHERE `id` = " .. attack.attackerGuildId)
			end
			if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardCoreDestroyed then
				_G.GuildDynastieAchievements.awardCoreDestroyed(attack.attackerGuildId, 1)
			end
			db.query("DELETE FROM `guild_dynasties` WHERE `config_id` = " .. escape(configId))
			refreshWorld()
			notifyAttackGuilds(configId, string.format("Attackers won the dynastie battle. The core was destroyed and stole {%s gold, %s dynastie tokens}.", stolenGold, stolenTokens))
		else
			local shieldUntil = now + (tonumber(api.attackShieldSeconds or 6 * 60 * 60) or (6 * 60 * 60))
			if api.hasColumn and api.hasColumn("guild_dynasties", "shield_until") then
				db.query("UPDATE `guild_dynasties` SET `shield_until` = " .. shieldUntil .. ", `updated_at` = " .. now .. " WHERE `config_id` = " .. escape(configId))
			end
			setAttackCooldown(attack.attackerGuildId, configId, now + (tonumber(api.attackReattackSeconds or 3 * 24 * 60 * 60) or (3 * 24 * 60 * 60)))
			if questHooks.awardDefenseWin then
				questHooks.awardDefenseWin(attack.defenderGuildId, configId)
			end
			if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardDefenseWin then
				_G.GuildDynastieAchievements.awardDefenseWin(attack.defenderGuildId)
			end
			notifyAttackGuilds(configId, "Defenders held the dynastie. It is now shielded.")
		end

		removeAttack(configId)
		if api.refreshDynastieBattleForMembers then
			api.refreshDynastieBattleForMembers(attack.attackerGuildId)
			api.refreshDynastieBattleForMembers(attack.defenderGuildId)
		else
			api.refreshGuildForMembers(attack.attackerGuildId)
			api.refreshGuildForMembers(attack.defenderGuildId)
		end
	end

	local function scheduleAttackTick()
		if DynastieAttackState.tickScheduled then
			return
		end

		DynastieAttackState.tickScheduled = true
		addEvent(function()
			DynastieAttackState.tickScheduled = false
			local now = os.time()
			for configId, attack in pairs(DynastieAttackState.byConfigId) do
				local byConfigId = loadStateByConfigId()
				local state = byConfigId[configId]
				if not attack or not state then
					DynastieAttackState.byConfigId[configId] = nil
				else
					if attack.status == "preparing" and now >= (tonumber(attack.startsAt) or 0) then
						attack.status = "active"
						attack.endsAt = now + (tonumber(api.attackDurationSeconds or 15 * 60) or (15 * 60))
						buildDefenderSlots(attack, attack.defenderGuildId)
						maintainAttackDefenders(attack, state)
						if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardDefenseParticipation then
							_G.GuildDynastieAchievements.awardDefenseParticipation(attack.defenderGuildId)
						end
						notifyAttackGuilds(configId, "Dynasty battle has started.")
						refreshAllDynastieViewers()
					end

				if attack.status == "active" then
					syncAttackParticipants(attack, state)
					maintainAttackDefenders(attack, state)
					local attackers = 0
					local defenders = 0
						for guid, member in pairs(attack.members or {}) do
							local participant = Player(guid)
							if not participant or not participant:getGuild() or participant:getGuild():getId() ~= member.guildId then
								member.removed = true
								member.removedReason = "invalid_participant"
							elseif not isBattleEligiblePosition(state, participant:getPosition()) then
								if not member.leaveDeadline or member.leaveDeadline <= 0 then
									member.leaveDeadline = now + (tonumber(api.attackLeaveGraceSeconds or 15) or 15)
									participant:sendTextMessage(MESSAGE_STATUS_WARNING, "Return to the dynastie battle area or you will be removed from the battle.")
								elseif now >= member.leaveDeadline then
									member.removed = true
									member.removedReason = "left_area"
									member.leaveDeadline = 0
									participant:sendTextMessage(MESSAGE_STATUS_WARNING, "You were removed from the dynastie battle for leaving the area.")
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
									if not participant or not isBattleEligiblePosition(state, participant:getPosition()) then
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
							if attackers >= (tonumber(api.attackMinAttackers or 1) or 1) and defenders < (tonumber(api.attackMinDefenders or 0) or 0) then
								attackerWon = true
							elseif attackers >= (tonumber(api.attackMinAttackers or 1) or 1) and attackers > defenders then
								attackerWon = true
							end
							resolveAttack(configId, attackerWon)
						else
							refreshAllDynastieViewers()
						end
					end
				end
			end

			if next(DynastieAttackState.byConfigId) then
				scheduleAttackTick()
			end
		end, 2000)
	end

	local function buildCard(player, config, state)
		local guildId = resolvePlayerGuildId(player)
		local canManageDynastieValue = canManageDynastie(player, guildId)
		local ownedByGuild = state and state.guildId == guildId or false
		local cfg = getConfig()
		local collectAt = tonumber(state and state.collectAvailableAt or 0) or 0
		local placeCooldownUntil = getPlaceCooldownUntil(guildId, config.id)
		local attackPayload = buildAttackPayload(config.id, guildId)
		local ownerGuildId = state and tonumber(state.guildId or 0) or 0
		local attackCooldownUntil = getAttackCooldownUntil(guildId, config.id)
		local progressGuildId = ownerGuildId > 0 and ownerGuildId or guildId
		local level, levelExp, nextLevelExp = getGuildDynastieProgress(progressGuildId)
		local maxTaxRate = math.min(math.max(0, tonumber(cfg.DEFAULT_MAX_TAX) or 10), math.max(0, level))
		local placedClientId = getClientItemId(getPlacedItemIdForGuild(config, progressGuildId))
		local storedTokens = getStoredDynastieTokens(state)

		return {
			id = config.id,
			name = config.name or config.city or "Dynasty",
			city = config.city or config.name or "City",
			owned = state ~= nil,
			ownedByViewer = ownedByGuild,
			ownedByGuild = ownedByGuild,
			viewerCanManage = canManageDynastieValue,
			isEmpty = state == nil,
			isConfigured = isValidPosition(config.position),
			ownerGuildName = state and getGuildName(state.guildId) or "",
			ownerPlayerName = resolveOwnerPlayerName(state),
			baseItemId = getClientItemId(tonumber(config.baseItemId or cfg.DEFAULT_BASE_ITEM_ID) or 0),
			placedItemId = placedClientId,
			clientId = placedClientId,
			radius = tonumber(state and state.radius or config.radius or cfg.DEFAULT_RADIUS) or 80,
			taxRate = tonumber(state and state.taxRate or cfg.DEFAULT_TAX_RATE) or 0,
			gold = tonumber(state and state.goldBuffer or 0) or 0,
			tokens = storedTokens,
			level = level,
			levelCap = math.max(1, tonumber(cfg.DEFAULT_LEVEL_CAP) or 10),
			experience = levelExp,
			nextLevelExp = nextLevelExp,
			maxTaxRate = maxTaxRate,
			collectAvailableAt = collectAt,
			placedAt = tonumber(state and state.placedAt or 0) or 0,
			shieldUntil = tonumber(state and state.shieldUntil or 0) or 0,
			placeCooldownUntil = placeCooldownUntil,
			canOpenPanel = ownedByGuild,
			canCollect = ownedByGuild and not attackPayload and canManageDynastieValue and os.time() >= collectAt or false,
			canPlace = state == nil and guildId > 0 and canManageDynastieValue and isValidPosition(config.position) and placeCooldownUntil <= os.time(),
			canSetTax = ownedByGuild and not attackPayload and canManageDynastieValue,
			canAttack = state and ownerGuildId > 0 and guildId > 0 and ownerGuildId ~= guildId and not attackPayload and (tonumber(state.shieldUntil or 0) or 0) <= os.time() and attackCooldownUntil <= os.time() and canManageDynastieValue or false,
			canTeleportAttack = attackPayload and attackPayload.participant or false,
			attackCooldownUntil = attackCooldownUntil,
			attack = attackPayload
		}
	end

	local function buildData(player, page)
		local byConfigId = loadStateByConfigId()
		local guildId = resolvePlayerGuildId(player)
		local used = 0
		local cards = {}
		local ownedCards = {}
		local total = 0
		local pageSize = 6

		if guildId > 0 and api.getGuildRowById and api.decodeGuildPerks and api.getGuildDynastieCapacityFromPerks then
			local guildRow = api.getGuildRowById(guildId)
			local perkLevels = api.decodeGuildPerks(guildRow and guildRow.perks or "")
			total = api.getGuildDynastieCapacityFromPerks(perkLevels)
		end

		for _, config in ipairs(getConfigList()) do
			local state = byConfigId[config.id]
			local card = buildCard(player, config, state)
			if state and state.guildId == guildId then
				used = used + 1
				table.insert(ownedCards, card)
			end
			table.insert(cards, card)
		end

		local totalLocations = #cards
		local lastPage = math.max(1, math.ceil(totalLocations / pageSize))
		page = math.max(1, math.min(lastPage, tonumber(page) or 1))
		local fromIndex = ((page - 1) * pageSize) + 1
		local toIndex = math.min(totalLocations, fromIndex + pageSize - 1)
		local pagedCards = {}
		for index = fromIndex, toIndex do
			if cards[index] then
				table.insert(pagedCards, cards[index])
			end
		end

		local canManageDynastieValue = guildId > 0 and canManageDynastie(player, guildId) or false

		return {
			used = used,
			total = total,
			locations = pagedCards,
			ownedLocations = ownedCards,
			page = page,
			lastPage = lastPage,
			totalLocations = totalLocations,
			pageSize = pageSize
		}
	end

	local function buildPanelData(player)
		local guildId = resolvePlayerGuildId(player)
		local canManageDynastieValue = guildId > 0 and canManageDynastie(player, guildId) or false
		return {
			perks = buildDefenderPerkData(guildId, canManageDynastieValue),
			defenders = buildDefenderData(guildId, canManageDynastieValue),
			passiveTree = buildDefenderPassiveTreeData(guildId, canManageDynastieValue)
		}
	end

	function dynastieApi.send(player, page)
		local guid = player and player:getGuid() or 0
		local resolvedPage = math.max(1, tonumber(page) or tonumber(dynastieViewerPages[guid] or 1) or 1)
		if guid > 0 then
			dynastieViewerPages[guid] = resolvedPage
		end
		local ok, payload = pcall(buildData, player, resolvedPage)
		if not ok then
			print(string.format("[GuildHall] Failed to build dynastie payload for %s: %s", player and player:getName() or "unknown", tostring(payload)))
			return
		end
		api.sendGuildPayload(player, "dynastie", payload)
	end

	function dynastieApi.setViewerActive(player, active)
		local guid = player and player:getGuid() or 0
		if guid <= 0 then
			return
		end
		if active then
			dynastieActiveViewers[guid] = true
		else
			dynastieActiveViewers[guid] = nil
		end
	end

	function dynastieApi.sendPanel(player)
		local ok, payload = pcall(buildPanelData, player)
		if not ok then
			print(string.format("[GuildHall] Failed to build dynasty panel payload for %s: %s", player and player:getName() or "unknown", tostring(payload)))
			return
		end
		api.sendGuildPayload(player, "dynastiePanel", payload)
	end

	function dynastieApi.place(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasty.")
		end

		local configId = tostring(data and data.configId or "")
		local config = getConfigById(configId)
		if not config then
			return api.sendGuildError(player, "Invalid dynastie location.")
		end
		if not isValidPosition(config.position) then
			return api.sendGuildError(player, "Dynasty location is not configured yet.")
		end
		if getPlaceCooldownUntil(guildId, configId) > os.time() then
			return api.sendGuildError(player, "This dynasty town is on cooldown for your guild.")
		end

		local byConfigId = loadStateByConfigId()
		if byConfigId[configId] then
			return api.sendGuildError(player, "This city already has an active dynasty.")
		end

		local guildRow = api.getGuildRowById and api.getGuildRowById(guildId)
		local perkLevels = api.decodeGuildPerks and api.decodeGuildPerks(guildRow and guildRow.perks or "") or {}
		local dynastieCapacity = api.getGuildDynastieCapacityFromPerks and api.getGuildDynastieCapacityFromPerks(perkLevels) or 0
		local activeCount = 0
		for _, state in pairs(byConfigId) do
			if state.guildId == guildId then
				activeCount = activeCount + 1
			end
		end
		if activeCount >= dynastieCapacity then
			return api.sendGuildError(player, "Your guild has no free dynastie slots.")
		end

		local cfg = getConfig()
		local requiredItemId = getRequiredItemIdForGuild(config, guildId)
		local requiredItemCount = math.max(1, tonumber(config.requiredItemCount or cfg.DEFAULT_REQUIRED_ITEM_COUNT) or 1)
		if requiredItemId > 0 and not player:removeItem(requiredItemId, requiredItemCount) then
			local itemType = ItemType(requiredItemId)
			local itemName = itemType and itemType:getName() or ("item #" .. tostring(requiredItemId))
			local requiredText = requiredItemCount > 1 and (tostring(requiredItemCount) .. "x " .. itemName) or itemName
			return api.sendGuildError(player, "You do not have the required item to place this dynastie: " .. requiredText .. ".")
		end

		local now = os.time()
		local baseItemId = tonumber(config.baseItemId or cfg.DEFAULT_BASE_ITEM_ID) or 0
		local placedItemId = getPlacedItemIdForGuild(config, guildId)
		local radius = tonumber(config.radius or cfg.DEFAULT_RADIUS) or 80
		local taxRate = tonumber(cfg.DEFAULT_TAX_RATE or 0) or 0
		local collectAvailableAt = now + math.max(60, tonumber(cfg.DEFAULT_COLLECT_SECONDS) or (7 * 24 * 60 * 60))

		local columns = {
			"`guild_id`", "`config_id`", "`owner_player_id`", "`owner_player_name`", "`placed_item_id`", "`base_item_id`",
			"`x`", "`y`", "`z`", "`radius`", "`tax_rate`", "`gold_buffer`"
		}
		local values = {
			tostring(guildId), escape(configId), tostring(player:getGuid()), escape(player:getName()), tostring(placedItemId), tostring(baseItemId),
			tostring(tonumber(config.position.x)), tostring(tonumber(config.position.y)), tostring(tonumber(config.position.z)), tostring(radius), tostring(taxRate), "0"
		}
		table.insert(columns, "`collect_available_at`")
		table.insert(values, tostring(collectAvailableAt))
		if api.hasColumn and api.hasColumn("guild_dynasties", "bonus_tokens") then
			table.insert(columns, "`bonus_tokens`")
			table.insert(values, "0")
		end
		table.insert(columns, "`placed_at`")
		table.insert(values, tostring(now))
		table.insert(columns, "`updated_at`")
		table.insert(values, tostring(now))

		db.query("INSERT INTO `guild_dynasties` (" .. table.concat(columns, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")")

		refreshWorld()
		if _G.GuildAchievements and _G.GuildAchievements.awardDynastiePlace then
			_G.GuildAchievements.awardDynastiePlace(guildId)
		end
		if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardCorePlaced then
			_G.GuildDynastieAchievements.awardCorePlaced(guildId)
		end
		api.refreshGuildForMembers(guildId)
		dynastieApi.send(player)
	end

	function dynastieApi.collect(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasties.")
		end

		local configId = tostring(data and data.configId or "")
		local byConfigId = loadStateByConfigId()
		local state = byConfigId[configId]
		local config = getConfigById(configId)
		if not state or not config then
			return api.sendGuildError(player, "Dynasty not found.")
		end
		if state.guildId ~= guildId then
			return api.sendGuildError(player, "Your guild does not own this dynastie.")
		end
		if DynastieAttackState.byConfigId[configId] then
			return api.sendGuildError(player, "You cannot collect from a dynastie while it is under attack.")
		end
		if os.time() < (tonumber(state.collectAvailableAt) or 0) then
			return api.sendGuildError(player, "This dynastie must remain active for at least 7 days before collection.")
		end

		local gold = tonumber(state.goldBuffer) or 0
		local tokens = getStoredDynastieTokens(state)
		if gold > 0 and api.hasColumn("guilds", "balance") then
			db.query("UPDATE `guilds` SET `balance` = `balance` + " .. gold .. " WHERE `id` = " .. guildId)
		end
		if tokens > 0 and api.hasColumn("guilds", "dynastie_tokens") then
			db.query("UPDATE `guilds` SET `dynastie_tokens` = `dynastie_tokens` + " .. tokens .. " WHERE `id` = " .. guildId)
		end
		if _G.GuildDynastieAchievements then
			if gold > 0 and _G.GuildDynastieAchievements.awardCollectedGold then
				_G.GuildDynastieAchievements.awardCollectedGold(guildId, gold)
			end
			if tokens > 0 and _G.GuildDynastieAchievements.awardCollectedTokens then
				_G.GuildDynastieAchievements.awardCollectedTokens(guildId, tokens)
			end
		end

		db.query("DELETE FROM `guild_dynasties` WHERE `config_id` = " .. escape(configId))
		local cfg = getConfig()
		local cooldownSeconds = math.max(60, tonumber(cfg.DEFAULT_PLACE_COOLDOWN_SECONDS) or (24 * 60 * 60))
		setPlaceCooldown(guildId, configId, os.time() + cooldownSeconds)
		refreshWorld()
		api.refreshGuildForMembers(guildId)
		api.addGuildMessages(
			api.getGuildInboxRecipients(guildId),
			guildId,
			api.messageTypes.DYNASTIE_COLLECT,
			string.format("[%s] %s collected dynastie rewards: {%s gold, %s dynastie tokens}.", config.name or "Dynasty", player:getName(), tostring(gold), tostring(tokens)),
			player:getGuid(),
			guildId
		)
		dynastieApi.send(player)
	end

	function dynastieApi.addCoreRewards(configId, rewards)
		configId = tostring(configId or "")
		rewards = type(rewards) == "table" and rewards or {}
		if configId == "" or not api or not api.hasTable or not api.hasTable("guild_dynasties") then
			return false
		end

		local state = loadStateByConfigId()[configId]
		if not state or (tonumber(state.guildId) or 0) <= 0 then
			return false
		end

		local updates = {}
		local guildGold = math.max(0, math.floor(tonumber(rewards.guildGold) or 0))
		local dynastieTokens = math.max(0, math.floor(tonumber(rewards.dynastieTokens) or 0))
		local dynastieExp = math.max(0, math.floor(tonumber(rewards.dynastieExp) or 0))

		if guildGold > 0 then
			updates[#updates + 1] = "`gold_buffer` = `gold_buffer` + " .. guildGold
		end
		if dynastieTokens > 0 and api.hasColumn and api.hasColumn("guild_dynasties", "bonus_tokens") then
			updates[#updates + 1] = "`bonus_tokens` = `bonus_tokens` + " .. dynastieTokens
		end
		if #updates > 0 then
			updates[#updates + 1] = "`updated_at` = " .. os.time()
			db.query("UPDATE `guild_dynasties` SET " .. table.concat(updates, ", ") .. " WHERE `config_id` = " .. escape(configId))
		end
		if dynastieExp > 0 then
			dynastieApi.awardExperience(state.guildId, dynastieExp)
			if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardCollectedExp then
				_G.GuildDynastieAchievements.awardCollectedExp(state.guildId, dynastieExp)
			end
		end
		refreshAllDynastieViewers()
		if api.refreshGuildForMembers then
			api.refreshGuildForMembers(state.guildId)
		end
		return true
	end

	function dynastieApi.setTax(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasties.")
		end

		local configId = tostring(data and data.configId or "")
		local taxRate = math.floor(tonumber(data and data.taxRate) or 0)
		local cfg = getConfig()
		local minTax = tonumber(cfg.DEFAULT_MIN_TAX or 0) or 0
		local maxTax = tonumber(cfg.DEFAULT_MAX_TAX or 10) or 10

		local byConfigId = loadStateByConfigId()
		local state = byConfigId[configId]
		if not state or state.guildId ~= guildId then
			return api.sendGuildError(player, "Your guild does not own this dynastie.")
		end
		local level = select(1, getGuildDynastieProgress(guildId))
		maxTax = math.min(maxTax, level)
		if taxRate < minTax or taxRate > maxTax then
			return api.sendGuildError(player, string.format("Tax for this core must be between %d%% and %d%%.", minTax, maxTax))
		end

		db.query("UPDATE `guild_dynasties` SET `tax_rate` = " .. taxRate .. ", `updated_at` = " .. os.time() .. " WHERE `config_id` = " .. escape(configId))
		if api.refreshDynastieForGuildMembers then
			api.refreshDynastieForGuildMembers(guildId)
		else
			dynastieApi.send(player)
		end
	end

	function dynastieApi.upgradeDefender(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasties.")
		end

		local defenderId = tostring(data and data.defenderId or "")
		local template = getDefenderTemplate(defenderId)
		if not template then
			return api.sendGuildError(player, "Unknown dynastie defender.")
		end

		local currentLevel = math.max(0, tonumber(loadDefenderLevels(guildId)[defenderId]) or 0)
		local levelCap = getDefenderLevelCap()
		if currentLevel >= levelCap then
			return api.sendGuildError(player, "This defender has already reached the maximum level.")
		end

		local nextLevel = currentLevel + 1
		local cost = getDefenderUpgradeCost(template, nextLevel)
		local guildRow = api.getGuildRowById and api.getGuildRowById(guildId)
		local guildGold = tonumber(guildRow and guildRow.balance) or 0
		local dynastieTokens = tonumber(guildRow and guildRow.dynastie_tokens) or 0
		if guildGold < (tonumber(cost.gold) or 0) then
			return api.sendGuildError(player, string.format("Your guild needs %s gold to upgrade this defender.", tostring(cost.gold)))
		end
		if dynastieTokens < (tonumber(cost.dynastieTokens) or 0) then
			return api.sendGuildError(player, string.format("Your guild needs %s dynastie tokens to upgrade this defender.", tostring(cost.dynastieTokens)))
		end
		local removedItems, removeError = removeItemsFromGuildStorage(guildId, cost.items)
		if not removedItems then
			return api.sendGuildError(player, removeError or "Guild storage does not contain the required upgrade materials.")
		end

		if api.hasColumn and api.hasColumn("guilds", "balance") then
			db.query("UPDATE `guilds` SET `balance` = `balance` - " .. (tonumber(cost.gold) or 0) .. " WHERE `id` = " .. guildId)
		end
		if api.hasColumn and api.hasColumn("guilds", "dynastie_tokens") then
			db.query("UPDATE `guilds` SET `dynastie_tokens` = `dynastie_tokens` - " .. (tonumber(cost.dynastieTokens) or 0) .. " WHERE `id` = " .. guildId)
		end

		saveDefenderLevel(guildId, defenderId, nextLevel)
		if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardDefenderLevel then
			_G.GuildDynastieAchievements.awardDefenderLevel(guildId, defenderId, nextLevel)
		end
		api.refreshGuildForMembers(guildId)
		dynastieApi.send(player)
		dynastieApi.sendPanel(player)
	end

	function dynastieApi.upgradePerk(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasties.")
		end

		local perkId = tostring(data and data.perkId or "")
		local template = getDefenderPerkTemplate(perkId)
		if not template then
			return api.sendGuildError(player, "Unknown dynastie perk.")
		end
		if isCoreBoundPerk(perkId) and not guildHasActiveDynastieCore(guildId) then
			return sendDynastiePerkResult(player, "Your guild must own an active dynastie core before upgrading this perk.")
		end
		if not api.hasTable or not api.hasTable("guild_dynastie_perks") then
			return api.sendGuildError(player, "Dynasty perks are not available yet. Run migration 60.")
		end

		local currentLevel = math.max(0, tonumber(loadDefenderPerkLevels(guildId)[perkId]) or 0)
		local levelCap = getPerkLevelCap(template)
		if currentLevel >= levelCap then
			return sendDynastiePerkResult(player, "This dynastie perk has already reached the maximum level.")
		end

		local nextLevel = currentLevel + 1
		local cost = getDefenderPerkUpgradeCost(template, nextLevel)
		local guildRow = api.getGuildRowById and api.getGuildRowById(guildId)
		local guildGold = tonumber(guildRow and guildRow.balance) or 0
		local dynastieTokens = tonumber(guildRow and guildRow.dynastie_tokens) or 0
		if guildGold < (tonumber(cost.gold) or 0) then
			return sendDynastiePerkResult(player, string.format("Your guild needs %s gold to upgrade this perk.", tostring(cost.gold)))
		end
		if dynastieTokens < (tonumber(cost.dynastieTokens) or 0) then
			return sendDynastiePerkResult(player, string.format("Your guild needs %s dynastie tokens to upgrade this perk.", tostring(cost.dynastieTokens)))
		end
		local removedItems, removeError = removeItemsFromGuildStorage(guildId, cost.items)
		if not removedItems then
			return sendDynastiePerkResult(player, removeError or "Guild storage does not contain the required perk upgrade materials.")
		end

		if api.hasColumn and api.hasColumn("guilds", "balance") then
			db.query("UPDATE `guilds` SET `balance` = `balance` - " .. (tonumber(cost.gold) or 0) .. " WHERE `id` = " .. guildId)
		end
		if api.hasColumn and api.hasColumn("guilds", "dynastie_tokens") then
			db.query("UPDATE `guilds` SET `dynastie_tokens` = `dynastie_tokens` - " .. (tonumber(cost.dynastieTokens) or 0) .. " WHERE `id` = " .. guildId)
		end

		if not saveDefenderPerkLevel(guildId, perkId, nextLevel) then
			return api.sendGuildError(player, "Could not save dynastie perk progress.")
		end
		sendDynastiePerkResult(player, string.format("%s upgraded to level %d.", tostring(template.name or "Dynasty Perk"), nextLevel))
		api.refreshGuildForMembers(guildId)
		dynastieApi.send(player)
		dynastieApi.sendPanel(player)
	end

	function dynastieApi.unlockPassiveNode(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasties.")
		end
		if not api.hasTable or not api.hasTable("guild_dynastie_passives") then
			return api.sendGuildError(player, "Dynasty passive tree is not available yet. Run migration.")
		end

		local defenderId = tostring(data and data.defenderId or "")
		local nodeId = tostring(data and data.nodeId or "")
		local node, nodeIndex = getPassiveNodeTemplate(defenderId, nodeId)
		if not node or not nodeIndex then
			return api.sendGuildError(player, "Unknown passive node.")
		end

		local unlockedNodes = loadUnlockedPassiveNodes(guildId)
		if unlockedNodes[defenderId] and unlockedNodes[defenderId][nodeId] then
			return api.sendGuildError(player, "This passive node is already active.")
		end

		local availablePoints, _, spentPoints = getAvailablePassivePointsForDefender(guildId, defenderId)
		if availablePoints <= 0 then
			return api.sendGuildError(player, "Your guild has no available passive points for this defender.")
		end
		if nodeIndex ~= (spentPoints + 1) then
			return api.sendGuildError(player, "Unlock passive nodes in order for this defender.")
		end
		local defenderLevels = loadDefenderLevels(guildId)
		local defenderLevel = math.min(getDefenderLevelCap(), math.max(0, tonumber(defenderLevels[defenderId]) or 0))
		local milestone = tonumber(node.milestone) or 0
		if milestone > 0 and defenderLevel < milestone then
			return api.sendGuildError(player, string.format("This passive requires defender level %d.", milestone))
		end

		local cost = type(node.costs) == "table" and node.costs or {}
		local guildRow = api.getGuildRowById and api.getGuildRowById(guildId)
		local guildGold = tonumber(guildRow and guildRow.balance) or 0
		local dynastieTokens = tonumber(guildRow and guildRow.dynastie_tokens) or 0
		if guildGold < (tonumber(cost.gold) or 0) then
			return api.sendGuildError(player, string.format("Your guild needs %s gold to unlock this passive.", tostring(cost.gold)))
		end
		if dynastieTokens < (tonumber(cost.dynastieTokens) or 0) then
			return api.sendGuildError(player, string.format("Your guild needs %s dynastie tokens to unlock this passive.", tostring(cost.dynastieTokens)))
		end
		if tonumber(cost.itemId) > 0 and not player:removeItem(tonumber(cost.itemId), tonumber(cost.itemCount) or 1) then
			local itemType = ItemType(tonumber(cost.itemId) or 0)
			local itemName = itemType and itemType:getName() or "item"
			return api.sendGuildError(player, string.format("You need {%dx %s} to unlock this passive.", tonumber(cost.itemCount) or 1, itemName))
		end

		if api.hasColumn and api.hasColumn("guilds", "balance") then
			db.query("UPDATE `guilds` SET `balance` = `balance` - " .. (tonumber(cost.gold) or 0) .. " WHERE `id` = " .. guildId)
		end
		if api.hasColumn and api.hasColumn("guilds", "dynastie_tokens") then
			db.query("UPDATE `guilds` SET `dynastie_tokens` = `dynastie_tokens` - " .. (tonumber(cost.dynastieTokens) or 0) .. " WHERE `id` = " .. guildId)
		end
		if not saveUnlockedPassiveNode(guildId, defenderId, nodeId) then
			return api.sendGuildError(player, "Could not save passive node progress.")
		end

		api.refreshGuildForMembers(guildId)
		dynastieApi.send(player)
		dynastieApi.sendPanel(player)
	end

	function dynastieApi.resetPassiveTree(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasties.")
		end
		if not api.hasTable or not api.hasTable("guild_dynastie_passives") then
			return api.sendGuildError(player, "Dynasty passive tree is not available yet. Run migration 58.")
		end

		local defenderId = tostring(data and data.defenderId or "")
		if not getDefenderTemplate(defenderId) then
			return api.sendGuildError(player, "Unknown dynastie defender.")
		end

		local unlockedNodes = loadUnlockedPassiveNodes(guildId)
		if countUnlockedPassiveNodes(unlockedNodes, defenderId) <= 0 then
			return api.sendGuildError(player, "That passive branch has no allocated points to reset.")
		end

		local guildRow = api.getGuildRowById and api.getGuildRowById(guildId)
		local dynastieTokens = tonumber(guildRow and guildRow.dynastie_tokens) or 0
		if dynastieTokens < 1 then
			return api.sendGuildError(player, "Your guild needs 1 dynastie token to reset this passive branch.")
		end

		if api.hasColumn and api.hasColumn("guilds", "dynastie_tokens") then
			db.query("UPDATE `guilds` SET `dynastie_tokens` = `dynastie_tokens` - 1 WHERE `id` = " .. guildId)
		end

		db.query("DELETE FROM `guild_dynastie_passives` WHERE `guild_id` = " .. guildId .. " AND `defender_id` = " .. escape(defenderId))
		api.refreshGuildForMembers(guildId)
		dynastieApi.send(player)
		dynastieApi.sendPanel(player)
	end

	function dynastieApi.attack(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if not canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynasties.")
		end

		local configId = tostring(data and data.configId or "")
		local byConfigId = loadStateByConfigId()
		local state = byConfigId[configId]
		local config = getConfigById(configId)
		if not state or not config then
			return api.sendGuildError(player, "Dynasty not found.")
		end
		if state.guildId == guildId then
			return api.sendGuildError(player, "You cannot attack your own dynastie.")
		end
		if DynastieAttackState.byConfigId[configId] then
			return api.sendGuildError(player, "That dynastie is already under attack.")
		end
		local now = os.time()
		if tonumber(state.shieldUntil or 0) > now then
			return api.sendGuildError(player, "That dynastie is currently shielded.")
		end
		if getAttackCooldownUntil(guildId, configId) > now then
			return api.sendGuildError(player, "Your guild cannot attack this dynastie again yet.")
		end

		DynastieAttackState.byConfigId[configId] = {
			configId = configId,
			status = "preparing",
			attackerGuildId = guildId,
			defenderGuildId = tonumber(state.guildId or 0) or 0,
			startsAt = now + (tonumber(api.attackPrepareSeconds or 10 * 60) or (10 * 60)),
			endsAt = 0,
			members = {}
		}
		if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardAttackStarted then
			_G.GuildDynastieAchievements.awardAttackStarted(guildId)
		end
		notifyAttackGuilds(configId, player:getName() .. " started a dynastie attack. Battle begins in 10 minutes.")
		refreshAllDynastieViewers()
		scheduleAttackTick()
	end

	function dynastieApi.teleport(player, data)
		local guildId = resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end

		if not api.canUseTeleport then
			return api.sendGuildError(player, "Teleport is not available.")
		end
		local ok, err = api.canUseTeleport(player)
		if not ok then
			return api.sendGuildError(player, err)
		end

		local configId = tostring(data and data.configId or "")
		local byConfigId = loadStateByConfigId()
		local state = byConfigId[configId]
		local config = getConfigById(configId)
		if not state or not config then
			return api.sendGuildError(player, "Unknown dynastie.")
		end

		local attack = DynastieAttackState.byConfigId[configId]
		local ownsDynastie = tonumber(state.guildId or 0) == guildId
		local attackRole = nil
		if attack then
			if attack.attackerGuildId == guildId then
				attackRole = "attacker"
			elseif attack.defenderGuildId == guildId then
				attackRole = "defender"
			end
		end

		if not ownsDynastie and not attackRole then
			return api.sendGuildError(player, "Your guild cannot use this dynastie teleport.")
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
			refreshAllDynastieViewers()
			scheduleAttackTick()
		end
		if api.markTeleportUsed then
			api.markTeleportUsed(player)
		end
	end

	function dynastieApi.refreshWorld()
		refreshWorld()
	end

	function dynastieApi.getTradeTaxForPlayer(player, baseAmount)
		return applyTradeTax(player, baseAmount)
	end

	function dynastieApi.setQuestHooks(hooks)
		questHooks = type(hooks) == "table" and hooks or {}
	end

	function dynastieApi.getState(configId)
		return loadStateByConfigId()[tostring(configId or "")]
	end

	function dynastieApi.getGuildActiveConfigIds(guildId)
		guildId = tonumber(guildId) or 0
		local configIds = {}
		if guildId <= 0 then
			return configIds
		end

		for configId, state in pairs(loadStateByConfigId()) do
			if tonumber(state.guildId or 0) == guildId then
				table.insert(configIds, configId)
			end
		end
		table.sort(configIds)
		return configIds
	end

	_G.GuildDynastie_getPlayerElementBonuses = function(player)
		local emptyBonuses = {
			physical = 0,
			fire = 0,
			ice = 0,
			energy = 0,
			earth = 0,
			water = 0,
			holy = 0,
			death = 0,
			arcane = 0,
			healing = 0
		}
		if not player or not player.getGuild then
			return emptyBonuses
		end

		local guild = player:getGuild()
		if not guild then
			return emptyBonuses
		end

		local bonuses = getActiveDynastiePerkBonuses(guild:getId())
		return {
			physical = math.max(0, tonumber(bonuses.physical) or 0),
			fire = math.max(0, tonumber(bonuses.fire) or 0),
			ice = math.max(0, tonumber(bonuses.ice) or 0),
			energy = math.max(0, tonumber(bonuses.energy) or 0),
			earth = math.max(0, tonumber(bonuses.earth) or 0),
			water = math.max(0, tonumber(bonuses.water) or 0),
			holy = math.max(0, tonumber(bonuses.holy) or 0),
			death = math.max(0, tonumber(bonuses.death) or 0),
			arcane = math.max(0, tonumber(bonuses.arcane) or 0),
			healing = math.max(0, tonumber(bonuses.healing) or 0)
		}
	end

	_G.GuildDynastie_getPlayerRarityLootBonus = function(player)
		if not player or not player.getGuild then
			return 0
		end

		local guild = player:getGuild()
		if not guild then
			return 0
		end

		local bonuses = getActiveDynastiePerkBonuses(guild:getId())
		return math.max(0, tonumber(bonuses.rarityLoot) or 0)
	end

	function dynastieApi.canManage(player, guildId)
		return canManageDynastie(player, guildId)
	end

	function dynastieApi.awardExperience(guildId, amount)
		local level, experience, leveledUp = awardGuildDynastieExperience(guildId, amount)
		if leveledUp then
			refreshWorld()
			refreshAllDynastieViewers()
			if api.refreshGuildForMembers then
				api.refreshGuildForMembers(guildId)
			end
		end
		return level, experience, leveledUp
	end

	function dynastieApi.sendAchievements(player, page, search)
		if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.send then
			_G.GuildDynastieAchievements.send(player, page, search)
		else
			api.sendGuildPayload(player, "dynastieAchievements", { achievements = {}, page = 1, lastPage = 1, pageSize = 18, completed = 0, total = 0, search = "" })
		end
	end

	function dynastieApi.claimAchievement(player, data)
		if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.claimReward then
			return _G.GuildDynastieAchievements.claimReward(player, data or {})
		end
		return api.sendGuildError(player, "Dynasty achievements are not available.")
	end

	function dynastieApi.onKill(player, target)
		if not player or not target then
			return
		end

		local guild = player:getGuild()
		if not guild then
			return
		end

		local guildId = guild:getId()
		local playerPosition = player:getPosition()
		local byConfigId = loadStateByConfigId()

		if target:isPlayer() then
			local targetPosition = target:getPosition()
			for configId, attack in pairs(DynastieAttackState.byConfigId) do
				local state = byConfigId[configId]
				if state and attack and isBattleEligiblePosition(state, playerPosition) and isBattleEligiblePosition(state, targetPosition) then
					local targetGuild = target:getGuild()
					local targetGuildId = targetGuild and targetGuild:getId() or 0
					if guildId == attack.attackerGuildId and targetGuildId == attack.defenderGuildId then
						if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardAttackPlayerKill then
							_G.GuildDynastieAchievements.awardAttackPlayerKill(guildId, 1)
						end
						break
					elseif guildId == attack.defenderGuildId and targetGuildId == attack.attackerGuildId then
						if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardDefensePlayerKill then
							_G.GuildDynastieAchievements.awardDefensePlayerKill(guildId, 1)
						end
						break
					end
				end
			end
			return
		end

		if not target:isMonster() or target:getMaster() then
			return
		end

		local targetPosition = target:getPosition()
		for _, state in pairs(byConfigId) do
			if tonumber(state.guildId or 0) == guildId and isBattleEligiblePosition(state, playerPosition) and isBattleEligiblePosition(state, targetPosition) then
				if _G.GuildDynastieAchievements and _G.GuildDynastieAchievements.awardMonsterKill then
					_G.GuildDynastieAchievements.awardMonsterKill(guildId, 1)
				end
				break
			end
		end
	end

	_G.GuildDynastie_getTradeTaxForPlayer = function(player, baseAmount)
		return applyTradeTax(player, baseAmount)
	end

	_G.GuildDynastie_getTradeDisplayValuesForPlayer = function(player, buyPrice, sellPrice)
		return getTradeDisplayValues(player, buyPrice, sellPrice)
	end

	_G.GuildDynastie_isDefenderMonster = function(monster)
		if not monster or not monster:isMonster() then
			return false
		end
		local monsterId = monster:getId()
		for _, attack in pairs(DynastieAttackState.byConfigId) do
			local byMonsterId = attack and attack.defenders and attack.defenders.byMonsterId or nil
			if byMonsterId and byMonsterId[monsterId] then
				return true
			end
		end
		return false
	end

	_G.GuildDynastie_filterDefenderDamage = function(target, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
		if not target or not target:isPlayer() or not attacker or not attacker:isMonster() then
			return primaryDamage, primaryType, secondaryDamage, secondaryType
		end

		for _, attack in pairs(DynastieAttackState.byConfigId) do
			local byMonsterId = attack and attack.defenders and attack.defenders.byMonsterId or nil
			local meta = byMonsterId and byMonsterId[attacker:getId()] or nil
			if meta then
				local targetGuild = target:getGuild()
				local targetGuildId = targetGuild and targetGuild:getId() or 0
				local state = loadStateByConfigId()[meta.configId]
				if not state or targetGuildId ~= meta.attackerGuildId or not isBattleEligiblePosition(state, target:getPosition()) then
					return 0, primaryType, 0, secondaryType
				end
				local damagePercent = tonumber(meta.passiveEffects and meta.passiveEffects.damagePercent) or 0
				if damagePercent > 0 then
					local multiplier = 1 + (damagePercent / 100)
					if primaryDamage and primaryDamage ~= 0 then
						primaryDamage = (primaryDamage < 0 and -1 or 1) * math.max(1, math.floor(math.abs(primaryDamage) * multiplier + 0.5))
					end
					if secondaryDamage and secondaryDamage ~= 0 then
						secondaryDamage = (secondaryDamage < 0 and -1 or 1) * math.max(1, math.floor(math.abs(secondaryDamage) * multiplier + 0.5))
					end
				end
				return primaryDamage, primaryType, secondaryDamage, secondaryType
			end
		end

		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	_G.GuildDynastie_filterDamageToDefender = function(target, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
		if not target or not target:isMonster() or not attacker or not attacker:isPlayer() then
			return primaryDamage, primaryType, secondaryDamage, secondaryType
		end

		for _, attack in pairs(DynastieAttackState.byConfigId) do
			local meta = attack and attack.defenders and attack.defenders.byMonsterId and attack.defenders.byMonsterId[target:getId()] or nil
			if meta then
				local state = loadStateByConfigId()[meta.configId]
				if not state or not isBattleEligiblePosition(state, attacker:getPosition()) then
					return 0, primaryType, 0, secondaryType
				end

				local defenseFlat = tonumber(meta.passiveEffects and meta.passiveEffects.defenseFlat) or 0
				local armorFlat = tonumber(meta.passiveEffects and meta.passiveEffects.armorFlat) or 0
				local allReductionPercent = math.min(40, defenseFlat * 2)
				local physicalReductionPercent = math.min(55, armorFlat * 3 + allReductionPercent)

				if primaryDamage and primaryDamage ~= 0 then
					local reduction = bit.band(primaryType or 0, COMBAT_PHYSICALDAMAGE) ~= 0 and physicalReductionPercent or allReductionPercent
					local multiplier = math.max(0, 1 - (reduction / 100))
					primaryDamage = (primaryDamage < 0 and -1 or 1) * math.max(1, math.floor(math.abs(primaryDamage) * multiplier + 0.5))
				end
				if secondaryDamage and secondaryDamage ~= 0 then
					local reduction = bit.band(secondaryType or 0, COMBAT_PHYSICALDAMAGE) ~= 0 and physicalReductionPercent or allReductionPercent
					local multiplier = math.max(0, 1 - (reduction / 100))
					secondaryDamage = (secondaryDamage < 0 and -1 or 1) * math.max(1, math.floor(math.abs(secondaryDamage) * multiplier + 0.5))
				end
				return primaryDamage, primaryType, secondaryDamage, secondaryType
			end
		end

		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	_G.GuildDynastie_canDefenderTarget = function(attacker, target)
		if not attacker or not attacker:isMonster() or not target or not target:isPlayer() then
			return true
		end

		for _, attack in pairs(DynastieAttackState.byConfigId) do
			local byMonsterId = attack and attack.defenders and attack.defenders.byMonsterId or nil
			local meta = byMonsterId and byMonsterId[attacker:getId()] or nil
			if meta then
				local targetGuild = target:getGuild()
				local targetGuildId = targetGuild and targetGuild:getId() or 0
				local state = loadStateByConfigId()[meta.configId]
				if not state or not isBattleEligiblePosition(state, target:getPosition()) then
					return false
				end
				return targetGuildId == meta.attackerGuildId
			end
		end

		return true
	end

	ensureDynastieBonusTokenColumn()

	return dynastieApi
end

return {
	create = create
}
