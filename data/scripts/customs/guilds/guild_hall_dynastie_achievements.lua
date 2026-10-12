local function create(api)
	local achievementApi = {}
	local function buildScaledRewards(index, rewardType)
		local rewardSets = {
			-- 10, 25, 50, 100, 200, 500, 1000
			attack_player_kill_total = {
				{ gold = 7000, dynastieTokens = 14, dynastieExp = 2500, items = {  } },
				{ gold = 10000, dynastieTokens = 20, dynastieExp = 5000, items = {  } },
				{ gold = 15000, dynastieTokens = 30, dynastieExp = 10000, items = {  } },
				{ gold = 25000, dynastieTokens = 48, dynastieExp = 20000, items = {  } },
				{ gold = 38000, dynastieTokens = 70, dynastieExp = 40000, items = {  } },
				{ gold = 80000, dynastieTokens = 140, dynastieExp = 80000, items = {  } },
				{ gold = 170000, dynastieTokens = 260, dynastieExp = 160000, items = {  } }
			},
			-- 10, 25, 50, 100, 200, 500, 1000
			defense_player_kill_total = {
				{ gold = 7000, dynastieTokens = 14, dynastieExp = 2500, items = {  } },
				{ gold = 10000, dynastieTokens = 20, dynastieExp = 5000, items = {  } },
				{ gold = 15000, dynastieTokens = 30, dynastieExp = 10000, items = {  } },
				{ gold = 25000, dynastieTokens = 48, dynastieExp = 20000, items = {  } },
				{ gold = 38000, dynastieTokens = 70, dynastieExp = 40000, items = {  } },
				{ gold = 80000, dynastieTokens = 140, dynastieExp = 80000, items = {  } },
				{ gold = 170000, dynastieTokens = 260, dynastieExp = 160000, items = {  } }
			},
			-- 1, 5, 10, 25, 50, 100, 200, 500, 1000
			core_destroy_total = {
				{ gold = 8000, dynastieTokens = 5, dynastieExp = 10000, items = { { itemId = 30654, count = 1 } } },
				{ gold = 11000, dynastieTokens = 16, dynastieExp = 20000, items = { { itemId = 30654, count = 2 } } },
				{ gold = 17000, dynastieTokens = 30, dynastieExp = 40000, items = { { itemId = 30654, count = 2 } } },
				{ gold = 26000, dynastieTokens = 55, dynastieExp = 80000, items = { { itemId = 30654, count = 3 } } },
				{ gold = 40000, dynastieTokens = 80, dynastieExp = 160000, items = {{ itemId = 30654, count = 3 } } },
				{ gold = 90000, dynastieTokens = 130, dynastieExp = 320000, items = { { itemId = 30654, count = 4 } } },
				{ gold = 180000, dynastieTokens = 220, dynastieExp = 640000, items = { { itemId = 30654, count = 4 } } },
				{ gold = 360000, dynastieTokens = 400, dynastieExp = 1280000, items = { { itemId = 30654, count = 5 } } },
				{ gold = 700000, dynastieTokens = 750, dynastieExp = 2560000, items = { { itemId = 30654, count = 5 } } }
			}
		}

		local rewards = rewardSets[rewardType]
		return rewards and rewards[index] or { gold = 0, dynastieTokens = 0, dynastieExp = 0, items = {} }
	end

	local function appendThresholdAchievements(definitions, options)
		local numerals = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" }
		for index, target in ipairs(options.targets or {}) do
			local rewards = buildScaledRewards(index, options.type)
			if type(options.buildRewards) == "function" then
				rewards = options.buildRewards(index, target, rewards)
			end
			definitions[#definitions + 1] = {
				id = string.format("%s_%d", options.idPrefix, target),
				name = string.format("%s %s", options.namePrefix, numerals[index] or tostring(index)),
				objective = string.format(options.objectiveTemplate, target),
				type = options.type,
				target = target,
				rewards = rewards,
				defenderId = options.defenderId
			}
		end
	end
	-- Defender passive rewards, so points gived per upgraded on defenders, they had 1000 maximum upgrade level each one..
	local function appendDefenderPassiveAchievements(definitions, defenderId, defenderName)
		local numerals = {
			"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
			"XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI"
		}
		local masteryBonus = {
			[25] = 1,
			[50] = 2,
			[100] = 2,
			[250] = 3,
			[500] = 3,
			[1000] = 4
		}
		local targets = { 25, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000 }

		for index, target in ipairs(targets) do
			local passivePoints = 0
			if target == 25 then
				passivePoints = passivePoints + 1
			end
			if target % 50 == 0 then
				passivePoints = passivePoints + 1
			end
			passivePoints = passivePoints + (masteryBonus[target] or 0)

			definitions[#definitions + 1] = {
				id = string.format("dynastie_%s_growth_%d", defenderId, target),
				name = string.format("%s Growth %s", defenderName, numerals[index] or tostring(index)),
				objective = string.format("Raise %s to level %d.", defenderName, target),
				type = string.format("defender_level_%s", defenderId),
				target = target,
				defenderId = defenderId,
				rewards = { passivePoints = passivePoints }
			}
		end
	end

	local definitions = {
		{ id = "dynastie_core_1", name = "Dynasty Founder I", objective = "Place 1 dynastie core.", type = "core_place_total", target = 1, rewards = { gold = 5000, dynastieTokens = 10, dynastieExp = 12500, items = { { itemId = 30654, count = 1 }, { itemId = 30657, count =  2} } } },
		{ id = "dynastie_core_5", name = "Dynasty Founder II", objective = "Place 5 dynastie cores.", type = "core_place_total", target = 5, rewards = { gold = 15000, dynastieTokens = 25, dynastieExp = 25000, items = { { itemId = 30654, count = 2 }, { itemId = 30657, count =  3} } } },
		{ id = "dynastie_core_20", name = "Dynasty Founder III", objective = "Place 20 dynastie cores.", type = "core_place_total", target = 20, rewards = { gold = 15000, dynastieTokens = 50, dynastieExp = 80000, items = { { itemId = 30654, count = 3}, { itemId = 30657, count =  4} } } },
		{ id = "dynastie_core_50", name = "Dynasty Founder IV", objective = "Place 50 dynastie cores.", type = "core_place_total", target = 50, rewards = { gold = 15000, dynastieTokens = 75, dynastieExp = 160000, items = { { itemId = 30654, count = 5 }, { itemId = 30657, count = 8 } } } },
		{ id = "dynastie_core_100", name = "Dynasty Founder V", objective = "Place 100 dynastie cores.", type = "core_place_total", target = 100, rewards = { gold = 15000, dynastieTokens = 120, dynastieExp = 320000, items = { { itemId = 30654, count = 8 }, { itemId = 30657, count = 15 } } } },
		{ id = "dynastie_attack_5", name = "War Council I", objective = "Launch 5 dynastie attacks.", type = "attack_start_total", target = 5, rewards = { gold = 8000, dynastieTokens = 15, dynastieExp = 35000, items = { } } },
		{ id = "dynastie_attack_10", name = "War Council II", objective = "Launch 10 dynastie attacks.", type = "attack_start_total", target = 10, rewards = { gold = 8000, dynastieTokens = 30, dynastieExp = 70000, items = {  } } },
		{ id = "dynastie_attack_20", name = "War Council III", objective = "Launch 20 dynastie attacks.", type = "attack_start_total", target = 20, rewards = { gold = 8000, dynastieTokens = 60, dynastieExp = 140000, items = {  } } },
		{ id = "dynastie_attack_50", name = "War Council IV", objective = "Launch 50 dynastie attacks.", type = "attack_start_total", target = 50, rewards = { gold = 8000, dynastieTokens = 120, dynastieExp = 280000, items = {  } } },
		{ id = "dynastie_attack_100", name = "War Council V", objective = "Launch 100 dynastie attacks.", type = "attack_start_total", target = 100, rewards = { gold = 8000, dynastieTokens = 240, dynastieExp = 560000, items = {  } } },
		{ id = "dynastie_defend_5", name = "Shieldwall I", objective = "Defend a dynastie core 5 times.", type = "defense_participation_total", target = 5, rewards = { gold = 30000, dynastieTokens = 15, dynastieExp = 125, items = {  } } },
		{ id = "dynastie_defend_10", name = "Shieldwall II", objective = "Defend a dynastie core 10 times.", type = "defense_participation_total", target = 10, rewards = { gold = 60000, dynastieTokens = 30, dynastieExp = 125, items = {  } } },
		{ id = "dynastie_defend_20", name = "Shieldwall III", objective = "Defend a dynastie core 20 times.", type = "defense_participation_total", target = 20, rewards = { gold = 120000, dynastieTokens = 60, dynastieExp = 125, items = {  } } },
		{ id = "dynastie_defend_50", name = "Shieldwall IV", objective = "Defend a dynastie core 50 times.", type = "defense_participation_total", target = 50, rewards = { gold = 240000, dynastieTokens = 120, dynastieExp = 125, items = {  } } },
		{ id = "dynastie_defend_100", name = "Shieldwall V", objective = "Defend a dynastie core 100 times.", type = "defense_participation_total", target = 100, rewards = { gold = 480000, dynastieTokens = 240, dynastieExp = 125, items = {  } } },
		{ id = "dynastie_monster_100", name = "Core Hunt I", objective = "Kill 100 monsters in dynastie combat areas.", type = "monster_kill_total", target = 100, rewards = { gold = 7000, dynastieTokens = 5, dynastieExp = 12500, items = {  } } },
		{ id = "dynastie_monster_500", name = "Core Hunt II", objective = "Kill 500 monsters in dynastie combat areas.", type = "monster_kill_total", target = 500, rewards = { gold = 25000, dynastieTokens = 10, dynastieExp = 25000, items = {  } } },
		{ id = "dynastie_monster_1000", name = "Core Hunt III", objective = "Kill 1000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 1000, rewards = { gold = 25000, dynastieTokens = 20, dynastieExp = 50000, items = {  } } },
		{ id = "dynastie_monster_2000", name = "Core Hunt IV", objective = "Kill 2000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 2000, rewards = { gold = 25000, dynastieTokens = 45, dynastieExp = 100000, items = {  } } },
		{ id = "dynastie_monster_5000", name = "Core Hunt V", objective = "Kill 5000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 5000, rewards = { gold = 25000, dynastieTokens = 90, dynastieExp = 250000, items = {  } } },
		{ id = "dynastie_monster_10000", name = "Core Hunt VI", objective = "Kill 10000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 10000, rewards = { gold = 25000, dynastieTokens = 140, dynastieExp = 550000, items = {  } } },
		{ id = "dynastie_monster_25000", name = "Core Hunt VII", objective = "Kill 25000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 25000, rewards = { gold = 25000, dynastieTokens = 300, dynastieExp = 1000000, items = {  } } },
		{ id = "dynastie_monster_50000", name = "Core Hunt VIII", objective = "Kill 50000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 50000, rewards = { gold = 25000, dynastieTokens = 450, dynastieExp = 2200000, items = {  } } },
		{ id = "dynastie_monster_100000", name = "Core Hunt IX", objective = "Kill 100000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 100000, rewards = { gold = 25000, dynastieTokens = 650, dynastieExp = 4500000, items = {  } } },
		{ id = "dynastie_monster_250000", name = "Core Hunt X", objective = "Kill 250000 monsters in dynastie combat areas.", type = "monster_kill_total", target = 250000, rewards = { gold = 25000, dynastieTokens = 1000, dynastieExp = 10000000, items = {  } } }
	}

	appendThresholdAchievements(definitions, {
		idPrefix = "dynastie_collect_gold",
		namePrefix = "Royal Treasury",
		objectiveTemplate = "Obtain %d gold from collected dynastie cores.",
		type = "collect_gold_total",
		targets = { 20000, 50000, 100000, 250000, 500000, 1000000, 2500000, 10000000 },
		buildRewards = function(index)
			local rewardSets = {
				{ gold = 5000, dynastieTokens = 10, dynastieExp = 12000, items = { } },
				{ gold = 8000, dynastieTokens = 16, dynastieExp = 24000, items = { } },
				{ gold = 12000, dynastieTokens = 24, dynastieExp = 48000, items = { } },
				{ gold = 22000, dynastieTokens = 40, dynastieExp = 96000, items = {  } },
				{ gold = 36000, dynastieTokens = 65, dynastieExp = 192000, items = { } },
				{ gold = 65000, dynastieTokens = 110, dynastieExp = 384000, items = { } },
				{ gold = 150000, dynastieTokens = 220, dynastieExp = 768000, items = { } },
				{ gold = 400000, dynastieTokens = 450, dynastieExp = 1536000, items = { } }
			}
			return rewardSets[index] or { gold = 0, dynastieTokens = 0, dynastieExp = 0, items = {} }
		end
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "dynastie_collect_tokens",
		namePrefix = "Token Treasury",
		objectiveTemplate = "Obtain %d dynastie tokens from collected dynastie cores.",
		type = "collect_tokens_total",
		targets = { 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000 },
		buildRewards = function(index)
			local rewardSets = {
				{ gold = 4000, dynastieTokens = 3, dynastieExp = 25000, items = { } },
				{ gold = 7000, dynastieTokens = 6, dynastieExp = 50000, items = { } },
				{ gold = 11000, dynastieTokens = 12, dynastieExp = 100000, items = { } },
				{ gold = 18000, dynastieTokens = 24, dynastieExp = 200000, items = { } },
				{ gold = 30000, dynastieTokens = 48, dynastieExp = 300000, items = {  } },
				{ gold = 55000, dynastieTokens = 96, dynastieExp = 600000, items = { } },
				{ gold = 100000, dynastieTokens = 192, dynastieExp = 1200000, items = {  } },
				{ gold = 220000, dynastieTokens = 384, dynastieExp = 2400000, items = {  } },
				{ gold = 500000, dynastieTokens = 768, dynastieExp = 4800000, items = {  } }
			}
			return rewardSets[index] or { gold = 0, dynastieTokens = 0, dynastieExp = 0, items = {} }
		end
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "dynastie_collect_exp",
		namePrefix = "Core Wisdom",
		objectiveTemplate = "Obtain %d dynastie experience through dynastie world board quests.",
		type = "collect_exp_total",
		targets = { 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 2000000, 5000000 },
		buildRewards = function(index)
			local rewardSets = {
				{ gold = 4000, dynastieTokens = 10, dynastieExp = 5000, items = {  } },
				{ gold = 6500, dynastieTokens = 16, dynastieExp = 10000, items = {  } },
				{ gold = 10000, dynastieTokens = 24, dynastieExp = 25000, items = { } },
				{ gold = 16000, dynastieTokens = 36, dynastieExp = 50000, items = {  } },
				{ gold = 26000, dynastieTokens = 60, dynastieExp = 100000, items = { } },
				{ gold = 48000, dynastieTokens = 105, dynastieExp = 250000, items = {  } },
				{ gold = 90000, dynastieTokens = 180, dynastieExp = 500000, items = { } },
				{ gold = 180000, dynastieTokens = 320, dynastieExp = 1000000, items = {  } },
				{ gold = 320000, dynastieTokens = 550, dynastieExp = 2000000, items = { } },
				{ gold = 700000, dynastieTokens = 950, dynastieExp = 5000000, items = {  } }
			}
			return rewardSets[index] or { gold = 0, dynastieTokens = 0, dynastieExp = 0, items = {} }
		end
	})

	appendThresholdAchievements(definitions, {
		idPrefix = "dynastie_attack_kill",
		namePrefix = "Siegeblood",
		objectiveTemplate = "Kill %d players while attacking dynastie cores.",
		type = "attack_player_kill_total",
		targets = { 10, 25, 50, 100, 200, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "dynastie_defense_kill",
		namePrefix = "Last Bastion",
		objectiveTemplate = "Kill %d players while defending dynastie cores.",
		type = "defense_player_kill_total",
		targets = { 10, 25, 50, 100, 200, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "dynastie_core_destroy",
		namePrefix = "Corebreaker",
		objectiveTemplate = "Destroy %d dynastie cores.",
		type = "core_destroy_total",
		targets = { 1, 5, 10, 25, 50, 100, 200, 500, 1000 }
	})
	appendDefenderPassiveAchievements(definitions, "paladin", "Defender Paladin")
	appendDefenderPassiveAchievements(definitions, "knight", "Defender Knight")
	appendDefenderPassiveAchievements(definitions, "mage", "Defender Mage")

	local definitionsById = {}
	local passivePointDefinitions = {}
	for _, definition in ipairs(definitions) do
		definitionsById[definition.id] = definition
		if (tonumber(definition.rewards and definition.rewards.passivePoints) or 0) > 0 and tostring(definition.defenderId or "") ~= "" then
			passivePointDefinitions[#passivePointDefinitions + 1] = {
				id = definition.id,
				defenderId = definition.defenderId,
				passivePoints = tonumber(definition.rewards.passivePoints) or 0
			}
		end
	end

	local pageSize = 12

	local function ensureTables()
		db.query([[
			CREATE TABLE IF NOT EXISTS `guild_dynastie_achievement_progress` (
				`guild_id` int(11) NOT NULL,
				`achievement_id` varchar(64) NOT NULL,
				`progress` bigint(20) NOT NULL DEFAULT 0,
				`completed_at` int(11) NOT NULL DEFAULT 0,
				`claimed_at` int(11) NOT NULL DEFAULT 0,
				`created_at` int(11) NOT NULL DEFAULT 0,
				`updated_at` int(11) NOT NULL DEFAULT 0,
				PRIMARY KEY (`guild_id`, `achievement_id`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8;
		]])
	end

	local function buildRewardText(rewards)
		local function formatValue(value)
			value = math.floor(tonumber(value) or 0)
			local negative = value < 0
			local text = tostring(math.abs(value))
			while true do
				local replaced, count = text:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
				text = replaced
				if count == 0 then
					break
				end
			end
			return negative and ("-" .. text) or text
		end

		rewards = type(rewards) == "table" and rewards or {}
		local parts = {}
		if (tonumber(rewards.gold) or 0) > 0 then
			parts[#parts + 1] = formatValue(rewards.gold) .. " gold"
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 then
			parts[#parts + 1] = formatValue(rewards.dynastieTokens) .. " dynastie tokens"
		end
		if (tonumber(rewards.dynastieExp) or 0) > 0 then
			parts[#parts + 1] = formatValue(rewards.dynastieExp) .. " dynastie exp"
		end
		if type(rewards.items) == "table" then
			for _, itemReward in ipairs(rewards.items) do
				local itemId = tonumber(itemReward.itemId) or 0
				local itemCount = tonumber(itemReward.count) or 0
				if itemId > 0 and itemCount > 0 then
					local itemType = ItemType(itemId)
					parts[#parts + 1] = tostring(itemCount) .. "x " .. ((itemType and itemType:getName()) or ("Item #" .. itemId))
				end
			end
		end
		if type(rewards.mount) == "string" and rewards.mount ~= "" then
			parts[#parts + 1] = "Mount: " .. rewards.mount
		end
		if type(rewards.outfit) == "string" and rewards.outfit ~= "" then
			parts[#parts + 1] = "Outfit: " .. rewards.outfit
		end
		if (tonumber(rewards.passivePoints) or 0) > 0 then
			parts[#parts + 1] = formatValue(rewards.passivePoints) .. " passive point(s)"
		end
		return #parts > 0 and table.concat(parts, ", ") or "No rewards"
	end

	local function getProgressRows(guildId)
		local rows = {}
		guildId = tonumber(guildId) or 0
		if guildId <= 0 then
			return rows
		end

		local resultId = db.storeQuery("SELECT `achievement_id`, `progress`, `completed_at`, `claimed_at` FROM `guild_dynastie_achievement_progress` WHERE `guild_id` = " .. guildId)
		if not resultId then
			return rows
		end

		repeat
			rows[result.getString(resultId, "achievement_id")] = {
				progress = result.getNumber(resultId, "progress"),
				completedAt = result.getNumber(resultId, "completed_at"),
				claimedAt = result.getNumber(resultId, "claimed_at")
			}
		until not result.next(resultId)
		result.free(resultId)
		return rows
	end

	local function upsertProgress(guildId, achievementId, progress, completedAt, claimedAt)
		guildId = tonumber(guildId) or 0
		if guildId <= 0 then
			return false
		end

		local now = os.time()
		progress = math.max(0, tonumber(progress) or 0)
		completedAt = math.max(0, tonumber(completedAt) or 0)
		claimedAt = math.max(0, tonumber(claimedAt) or 0)
		return db.query(
			"INSERT INTO `guild_dynastie_achievement_progress` (`guild_id`, `achievement_id`, `progress`, `completed_at`, `claimed_at`, `created_at`, `updated_at`) VALUES (" ..
				guildId .. ", " .. api.escape(achievementId) .. ", " .. progress .. ", " .. completedAt .. ", " .. claimedAt .. ", " .. now .. ", " .. now .. ")" ..
			" ON DUPLICATE KEY UPDATE `progress` = VALUES(`progress`), `completed_at` = VALUES(`completed_at`), `claimed_at` = VALUES(`claimed_at`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function incrementProgress(guildId, achievementType, amount)
		guildId = tonumber(guildId) or 0
		amount = math.max(1, math.floor(tonumber(amount) or 1))
		if guildId <= 0 then
			return false
		end

		local rows = getProgressRows(guildId)
		local touched = false
		for _, definition in ipairs(definitions) do
			if definition.type == achievementType then
				local row = rows[definition.id] or {}
				local current = tonumber(row.progress) or 0
				local target = tonumber(definition.target) or 0
				if current < target then
					local newProgress = math.min(target, current + amount)
					local completedAt = tonumber(row.completedAt) or 0
					if completedAt <= 0 and newProgress >= target then
						completedAt = os.time()
					end
					if upsertProgress(guildId, definition.id, newProgress, completedAt, tonumber(row.claimedAt) or 0) then
						touched = true
					end
				end
			end
		end

		return touched
	end

	local function getAchievementSortBucket(entry)
		if entry.completed and not entry.claimed then
			return 0
		end
		if not entry.completed then
			return 1
		end
		return 2
	end

	local function buildData(guildId, page, search)
		page = math.max(1, math.floor(tonumber(page) or 1))
		search = tostring(search or ""):lower():trim()
		local rows = getProgressRows(guildId)
		local payload = {
			achievements = {},
			page = 1,
			lastPage = 1,
			pageSize = pageSize,
			completed = 0,
			total = #definitions
		}

		local entries = {}
		for _, definition in ipairs(definitions) do
			local row = rows[definition.id] or {}
			local progress = math.min(tonumber(row.progress) or 0, tonumber(definition.target) or 0)
			local completed = progress >= (tonumber(definition.target) or 0)
			local claimed = (tonumber(row.claimedAt) or 0) > 0
			if completed then
				payload.completed = payload.completed + 1
			end

			local searchableText = (tostring(definition.name or "") .. " " .. tostring(definition.objective or "")):lower()
			if search == "" or searchableText:find(search, 1, true) then
				entries[#entries + 1] = {
					id = definition.id,
					name = definition.name,
					objective = definition.objective,
					target = tonumber(definition.target) or 0,
					progress = progress,
					completed = completed,
					claimed = claimed,
					rewardText = buildRewardText(definition.rewards),
					rewardEntries = api.buildQuestRewardEntries and api.buildQuestRewardEntries(definition.rewards) or {}
				}
			end
		end

		table.sort(entries, function(a, b)
			local bucketA = getAchievementSortBucket(a)
			local bucketB = getAchievementSortBucket(b)
			if bucketA ~= bucketB then
				return bucketA < bucketB
			end
			if bucketA == 1 then
				local ratioA = (tonumber(a.target) or 1) > 0 and ((tonumber(a.progress) or 0) / math.max(1, tonumber(a.target) or 1)) or 0
				local ratioB = (tonumber(b.target) or 1) > 0 and ((tonumber(b.progress) or 0) / math.max(1, tonumber(b.target) or 1)) or 0
				if ratioA ~= ratioB then
					return ratioA > ratioB
				end
			end
			return tostring(a.name or "") < tostring(b.name or "")
		end)

		payload.lastPage = math.max(1, math.ceil(#entries / pageSize))
		if page > payload.lastPage then
			page = payload.lastPage
		end
		payload.page = page

		local offset = (page - 1) * pageSize
		for index = offset + 1, math.min(offset + pageSize, #entries) do
			payload.achievements[#payload.achievements + 1] = entries[index]
		end
		payload.search = search

		return payload
	end

	local function grantRewards(guildId, rewards)
		rewards = type(rewards) == "table" and rewards or {}
		if (tonumber(rewards.gold) or 0) > 0 and api.hasColumn("guilds", "balance") then
			db.query("UPDATE `guilds` SET `balance` = `balance` + " .. (tonumber(rewards.gold) or 0) .. " WHERE `id` = " .. guildId)
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 and api.hasColumn("guilds", "dynastie_tokens") then
			db.query("UPDATE `guilds` SET `dynastie_tokens` = `dynastie_tokens` + " .. (tonumber(rewards.dynastieTokens) or 0) .. " WHERE `id` = " .. guildId)
		end
		if (tonumber(rewards.dynastieExp) or 0) > 0 and api.awardDynastieExperience then
			api.awardDynastieExperience(guildId, tonumber(rewards.dynastieExp) or 0)
		end
		if type(rewards.items) == "table" and api.tryStoreItemsInGuildStorage then
			api.tryStoreItemsInGuildStorage(guildId, rewards.items)
		end
	end

	local function setProgressForType(guildId, achievementType, value)
		guildId = tonumber(guildId) or 0
		value = math.max(0, math.floor(tonumber(value) or 0))
		if guildId <= 0 then
			return false
		end

		local rows = getProgressRows(guildId)
		local touched = false
		for _, definition in ipairs(definitions) do
			if definition.type == achievementType then
				local row = rows[definition.id] or {}
				local current = tonumber(row.progress) or 0
				local target = tonumber(definition.target) or 0
				local newProgress = math.min(target, math.max(current, value))
				if newProgress ~= current then
					local completedAt = tonumber(row.completedAt) or 0
					if completedAt <= 0 and newProgress >= target then
						completedAt = os.time()
					end
					if upsertProgress(guildId, definition.id, newProgress, completedAt, tonumber(row.claimedAt) or 0) then
						touched = true
					end
				end
			end
		end
		return touched
	end

	local function syncDefenderLevelAchievements(guildId)
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.hasTable or not api.hasTable("guild_dynastie_defenders") then
			return false
		end

		local resultId = db.storeQuery("SELECT `defender_id`, `level` FROM `guild_dynastie_defenders` WHERE `guild_id` = " .. guildId)
		if not resultId then
			return false
		end

		local touched = false
		repeat
			local defenderId = result.getString(resultId, "defender_id")
			local level = result.getNumber(resultId, "level")
			if defenderId ~= "" then
				if setProgressForType(guildId, string.format("defender_level_%s", defenderId), level) then
					touched = true
				end
			end
		until not result.next(resultId)
		result.free(resultId)
		return touched
	end

	function achievementApi.send(player, page, search)
		page = math.max(1, math.floor(tonumber(page) or 1))
		local guildId = api.resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildPayload(player, "dynastieAchievements", { achievements = {}, page = 1, lastPage = 1, pageSize = pageSize, completed = 0, total = 0, search = "" })
		end
		syncDefenderLevelAchievements(guildId)
		api.sendGuildPayload(player, "dynastieAchievements", buildData(guildId, page, search))
	end

	function achievementApi.claimReward(player, data)
		local guildId = api.resolvePlayerGuildId(player)
		if guildId <= 0 then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if api.canManageDynastie and not api.canManageDynastie(player, guildId) then
			return api.sendGuildError(player, "You do not have permission to manage dynastie achievements.")
		end
		syncDefenderLevelAchievements(guildId)

		local achievementId = tostring(data and data.achievementId or "")
		local definition = definitionsById[achievementId]
		if not definition then
			return api.sendGuildError(player, "Unknown dynastie achievement.")
		end

		local row = getProgressRows(guildId)[achievementId] or {}
		local progress = tonumber(row.progress) or 0
		if progress < (tonumber(definition.target) or 0) then
			return api.sendGuildError(player, "This dynastie achievement is not completed yet.")
		end
		if (tonumber(row.claimedAt) or 0) > 0 then
			return api.sendGuildError(player, "This dynastie achievement reward has already been claimed.")
		end

		local rewardItems = {}
		local rewards = definition.rewards or {}
		if type(rewards.items) == "table" then
			for _, itemReward in ipairs(rewards.items) do
				local itemId = tonumber(itemReward.itemId) or 0
				local count = tonumber(itemReward.count) or 0
				if itemId > 0 and count > 0 then
					rewardItems[#rewardItems + 1] = { itemId = itemId, count = count, tooltip = "", attributes = "" }
				end
			end
		end
		if #rewardItems > 0 and api.canStoreItemsInGuildStorage and not api.canStoreItemsInGuildStorage(guildId, rewardItems) then
			return api.sendGuildError(player, "There is no space in guild storage to claim this dynastie achievement reward.")
		end

		grantRewards(guildId, rewards)
		upsertProgress(guildId, achievementId, progress, tonumber(row.completedAt) or os.time(), os.time())
		if api.refreshGuildStorageForGuild then
			api.refreshGuildStorageForGuild(guildId)
		end
		if api.refreshGuildForMembers then
			api.refreshGuildForMembers(guildId)
		end
		achievementApi.send(player, 1)
	end

	function achievementApi.awardCorePlaced(guildId)
		incrementProgress(guildId, "core_place_total", 1)
	end

	function achievementApi.awardAttackStarted(guildId)
		incrementProgress(guildId, "attack_start_total", 1)
	end

	function achievementApi.awardDefenseParticipation(guildId)
		incrementProgress(guildId, "defense_participation_total", 1)
	end

	function achievementApi.awardDefenseWin(guildId)
		incrementProgress(guildId, "defense_win_total", 1)
	end

	function achievementApi.awardMonsterKill(guildId, amount)
		incrementProgress(guildId, "monster_kill_total", amount or 1)
	end

	function achievementApi.awardAttackPlayerKill(guildId, amount)
		incrementProgress(guildId, "attack_player_kill_total", amount or 1)
	end

	function achievementApi.awardDefensePlayerKill(guildId, amount)
		incrementProgress(guildId, "defense_player_kill_total", amount or 1)
	end

	function achievementApi.awardCoreDestroyed(guildId, amount)
		incrementProgress(guildId, "core_destroy_total", amount or 1)
	end

	function achievementApi.awardCollectedGold(guildId, amount)
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if amount <= 0 then
			return false
		end
		return incrementProgress(guildId, "collect_gold_total", amount)
	end

	function achievementApi.awardCollectedTokens(guildId, amount)
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if amount <= 0 then
			return false
		end
		return incrementProgress(guildId, "collect_tokens_total", amount)
	end

	function achievementApi.awardCollectedExp(guildId, amount)
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if amount <= 0 then
			return false
		end
		return incrementProgress(guildId, "collect_exp_total", amount)
	end

	function achievementApi.awardDefenderLevel(guildId, defenderId, level)
		defenderId = tostring(defenderId or "")
		level = math.max(0, math.floor(tonumber(level) or 0))
		if defenderId == "" then
			return false
		end
		return setProgressForType(guildId, string.format("defender_level_%s", defenderId), level)
	end

	function achievementApi.getDefinitionCount()
		return #definitions
	end

	function achievementApi.getPassivePointDefinitions()
		return passivePointDefinitions
	end

	ensureTables()
	return achievementApi
end

return {
	create = create
}
