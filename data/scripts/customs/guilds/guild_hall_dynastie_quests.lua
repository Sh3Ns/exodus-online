local DynastieQuestPools = {
	daily = {
		{ id = "daily_dynasty_tokens_5", icon = "earn_dynasty_tokens", name = "Token Mint", objective = "Earn 5 dynastie tokens.", type = "gain_dynasty_tokens", target = 5, rewards = { gold = 5000, exp = 14500, dynastieTokens = 5 } },
		{ id = "daily_dynasty_tokens_15", icon = "dynasty_tokens", name = "Token Reserve", objective = "Earn 15 dynastie tokens.", type = "gain_dynasty_tokens", target = 15, rewards = { gold = 15000, exp = 44500, dynastieTokens = 10 } },
		{ id = "daily_king_zelos_triad", icon = "dynasty_boss", name = "King Zelos Hunt", objective = "Kill 2 Times King Zelos with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "king zelos", target = 2, minGuildMembers = 2, rewards = { gold = 35000, exp = 35000, dynastieTokens = 20 } },
		{ id = "daily_scarlet_triad", icon = "dynasty_boss", name = "Scarlett Hunt", objective = "Kill 2 Times Scarlet Etzel with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "scarlett etzel", target = 2, minGuildMembers = 2, rewards = { gold = 18500, exp = 22500, dynastieTokens = 12 } },
		{ id = "daily_irgix_triad", icon = "dynasty_boss", name = "Scarlett Hunt", objective = "Kill 2 Times Irgix the Flimsy with 1 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "irgix the flimsy", target = 2, minGuildMembers = 1, rewards = { gold = 12000, exp = 17500, dynastieTokens = 8 } },
		{ id = "daily_tax_small", icon = "dynasty_gold", name = "City Toll", objective = "Generate 1000 dynastie tax gold.", type = "earn_tax_gold", target = 1000, rewards = { gold = 9000, exp = 12500, dynastieTokens = 3 } },
		{ id = "daily_tax_medium", icon = "dynasty_gold", name = "Trade Winds", objective = "Generate 3500 dynastie tax gold.", type = "earn_tax_gold", target = 3500, rewards = { gold = 18000, exp = 30000, dynastieTokens = 6 } },
		{ id = "daily_tax_large", icon = "dynasty_gold", name = "Market Pressure", objective = "Generate 5000 dynastie tax gold.", type = "earn_tax_gold", target = 5000, rewards = { gold = 28000, exp = 45000, dynastieTokens = 10 } },
		{ id = "daily_tax_rich", icon = "dynasty_gold", name = "Rich Quarter", objective = "Generate 7500 dynastie tax gold.", type = "earn_tax_gold", target = 7500, rewards = { gold = 35000, exp = 65000, dynastieTokens = 15 } },
		{ id = "daily_tax_crown", icon = "dynasty_gold", name = "Crown Tariff", objective = "Generate 10000 dynastie tax gold.", type = "earn_tax_gold", target = 10000, rewards = { gold = 50000, exp = 85000, dynastieTokens = 18 } },
		{ id = "daily_dynasty_mining_1", icon = "mining", name = "Mining I", objective = "Complete 20 successful mining actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "mining", target = 20, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } },
		{ id = "daily_dynasty_herbalist_1", icon = "herbalist", name = "Herbalist I", objective = "Complete 20 successful herbalist harvests while your guild owns an active dynasty core.", type = "profession_activity", profession = "herbalist", target = 20, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } },
		{ id = "daily_dynasty_woodcutting_1", icon = "woodcutting", name = "Woodcutting I", objective = "Complete 20 successful woodcutting actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "woodcutting", target = 20, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } },
		{ id = "daily_dynasty_fishing_1", icon = "fishing", name = "Fishing I", objective = "Complete 20 successful fishing actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "fishing", target = 20, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } },
		{ id = "daily_dynasty_crafting_1", icon = "crafting", name = "Crafting I", objective = "Complete 15 successful crafting actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "crafting", target = 15, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } },
		{ id = "daily_dynasty_armorsmith_1", icon = "armorsmith", name = "Armorsmith I", objective = "Complete 15 successful armorsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "armorsmith", target = 15, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } },
		{ id = "daily_dynasty_weaponsmith_1", icon = "weaponsmith", name = "Weaponsmith I", objective = "Complete 15 successful weaponsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "weaponsmith", target = 15, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } },
		{ id = "daily_dynasty_jewelsmith_1", icon = "jewelsmith", name = "Jewelsmith I", objective = "Complete 15 successful jewelsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "jewelsmith", target = 15, rewards = { gold = 5000, exp = 14500, dynastieTokens = 3 } }
	},
	weekend = {
		{ id = "weekend_emberlord_triad", icon = "dynasty_boss", name = "Emberlord Zanarth Hunt", objective = "Kill Emberlord Zanarth with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "emberlord zanarth", target = 1, minGuildMembers = 2, rewards = { gold = 60000, exp = 60000, dynastieTokens = 20 } },
		{ id = "weekend_bakragore_triad", icon = "dynasty_boss", name = "Bakragore Hunt", objective = "Kill 2 Times Bakragore with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "bakragore", target = 2, minGuildMembers = 2, rewards = { gold = 40000, exp = 40000, dynastieTokens = 20 } },
		{ id = "weekend_gnomevil_triad", icon = "dynasty_boss", name = "Gnomevil Hunt", objective = "Kill 2 Times Gnomevil with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "gnomevil", target = 2, minGuildMembers = 2, rewards = { gold = 40000, exp = 40000, dynastieTokens = 20 } },
		{ id = "weekend_fear_feaster_triad", icon = "dynasty_boss", name = "Fear Hunt", objective = "Kill 2 Times The Fear Feaster with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "gnomevil", target = 2, minGuildMembers = 2, rewards = { gold = 40000, exp = 40000, dynastieTokens = 20 } },
		{ id = "weekend_dynasty_tokens_50", icon = "earn_dynasty_tokens", name = "Token Reserve", objective = "Earn 50 dynastie tokens.", type = "gain_dynasty_tokens", target = 50, rewards = { gold = 40000, exp = 75000, dynastieTokens = 35 } },
		{ id = "weekend_dynasty_tokens_100", icon = "dynasty_tokens", name = "Vault of Coin", objective = "Earn 100 dynastie tokens.", type = "gain_dynasty_tokens", target = 100, rewards = { gold = 80000, exp = 150000, dynastieTokens = 55 } },
		{ id = "weekend_defense_hold", icon = "dynasty", name = "Hold the Line", objective = "Win 1 dynastie core defense.", type = "defend_dynastie_win", target = 1, rewards = { gold = 65000, exp = 45000, dynastieTokens = 15 } },
		{ id = "weekend_tax_harbor", icon = "dynasty_gold", name = "Harbor Revenue", objective = "Generate 15000 dynastie tax gold.", type = "earn_tax_gold", target = 15000, rewards = { gold = 65000, exp = 115000, dynastieTokens = 24 } },
		{ id = "weekend_tax_merchant", icon = "dynasty_gold", name = "Merchant Boom", objective = "Generate 20000 dynastie tax gold.", type = "earn_tax_gold", target = 20000, rewards = { gold = 70000, exp = 130000, dynastieTokens = 38 } },
		{ id = "weekend_tax_capital", icon = "dynasty_gold", name = "Capital Demands", objective = "Generate 25000 dynastie tax gold.", type = "earn_tax_gold", target = 25000, rewards = { gold = 85000, exp = 145000, dynastieTokens = 45 } },
		{ id = "weekend_tax_exchequer", icon = "dynasty_gold", name = "Royal Exchequer", objective = "Generate 30000 dynastie tax gold.", type = "earn_tax_gold", target = 30000, rewards = { gold = 100000, exp = 185000, dynastieTokens = 60 } },
		{ id = "weekend_dynasty_mining_2", icon = "mining", name = "Mining II", objective = "Complete 150 successful mining actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "mining", target = 150, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } },
		{ id = "weekend_dynasty_herbalist_2", icon = "herbalist", name = "Herbalist II", objective = "Complete 150 successful herbalist harvests while your guild owns an active dynasty core.", type = "profession_activity", profession = "herbalist", target = 150, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } },
		{ id = "weekend_dynasty_woodcutting_2", icon = "woodcutting", name = "Woodcutting II", objective = "Complete 150 successful woodcutting actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "woodcutting", target = 150, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } },
		{ id = "weekend_dynasty_fishing_2", icon = "fishing", name = "Fishing II", objective = "Complete 150 successful fishing actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "fishing", target = 150, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } },
		{ id = "weekend_dynasty_crafting_2", icon = "crafting", name = "Crafting II", objective = "Complete 75 successful crafting actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "crafting", target = 75, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } },
		{ id = "weekend_dynasty_armorsmith_2", icon = "armorsmith", name = "Armorsmith II", objective = "Complete 75 successful armorsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "armorsmith", target = 75, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } },
		{ id = "weekend_dynasty_weaponsmith_2", icon = "weaponsmith", name = "Weaponsmith II", objective = "Complete 75 successful weaponsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "weaponsmith", target = 75, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } },
		{ id = "weekend_dynasty_jewelsmith_2", icon = "jewelsmith", name = "Jewelsmith II", objective = "Complete 75 successful jewelsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "jewelsmith", target = 75, rewards = { gold = 32500, exp = 80000, dynastieTokens = 12 } }
	},
	monthly = {
		{ id = "monthly_dynasty_tokens_300", icon = "earn_dynasty_tokens", name = "Dynastic Treasury", objective = "Earn 300 dynastie tokens.", type = "gain_dynasty_tokens", target = 300, rewards = { gold = 150000, exp = 300000, dynastieTokens = 60 } },
		{ id = "monthly_dynasty_tokens_500", icon = "dynasty_tokens", name = "Imperial Mint", objective = "Earn 500 dynastie tokens.", type = "gain_dynasty_tokens", target = 500, rewards = { gold = 265000, exp = 485000, dynastieTokens = 180 } },
		{ id = "monthly_duration_week", icon = "dynasty_duration", name = "Steady Reign", objective = "Keep a dynastie core active for 7 days.", type = "active_duration_days", target = 7, rewards = { gold = 50000, exp = 65000, dynastieTokens = 50 } },
		{ id = "monthly_abyssador_triad", icon = "dynasty_boss", name = "Abyssador Hunt", objective = "Kill 4 Times Abyssador with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "abyssador", target = 4, minGuildMembers = 2, rewards = { gold = 80000, exp = 80000, dynastieTokens = 40 } },
		{ id = "monthly_urmahlulu_triad", icon = "dynasty_boss", name = "Urmahlullu Hunt", objective = "Kill 4 Times Urmahlullu the Weakened with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "urmahlullu the weakened", target = 4, minGuildMembers = 2, rewards = { gold = 80000, exp = 80000, dynastieTokens = 40 } },
		{ id = "monthly_gorzindel_triad", icon = "dynasty_boss", name = "Gorzindel Hunt", objective = "Kill 4 Times Gorzindel with 2 guild players nearby while your guild owns an active dynastie core.", type = "boss_kill_with_guild", monster = "gorzindel", target = 2, minGuildMembers = 2, rewards = { gold = 80000, exp = 80000, dynastieTokens = 40 } },
		{ id = "monthly_duration_fortnight", icon = "dynasty_duration", name = "Iron Reign", objective = "Keep a dynastie core active for 14 days.", type = "active_duration_days", target = 14, rewards = { gold = 100000, exp = 125000, dynastieTokens = 100 } },
		{ id = "monthly_tax_empire", icon = "dynasty_gold", name = "Imperial Ledger", objective = "Generate 35000 dynastie tax gold.", type = "earn_tax_gold", target = 35000, rewards = { gold = 125000, exp = 200000, dynastieTokens = 75 } },
		{ id = "monthly_tax_grand", icon = "dynasty_gold", name = "Grand Treasury", objective = "Generate 45000 dynastie tax gold.", type = "earn_tax_gold", target = 45000, rewards = { gold = 150000, exp = 265000, dynastieTokens = 100 } },
		{ id = "monthly_tax_nobles", icon = "dynasty_gold", name = "Nobles' Tribute", objective = "Generate 55000 dynastie tax gold.", type = "earn_tax_gold", target = 55000, rewards = { gold = 175000, exp = 295000, dynastieTokens = 150 } },
		{ id = "monthly_tax_dynasty", icon = "dynasty_gold", name = "Dynasty Revenue", objective = "Generate 70000 dynastie tax gold.", type = "earn_tax_gold", target = 70000, rewards = { gold = 220000, exp = 325000, dynastieTokens = 200 } },
		{ id = "monthly_dynasty_mining_3", icon = "mining", name = "Mining III", objective = "Complete 500 successful mining actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "mining", target = 500, rewards = { gold = 100000, exp = 280000, dynastieTokens = 35 } },
		{ id = "monthly_dynasty_herbalist_3", icon = "herbalist", name = "Herbalist III", objective = "Complete 500 successful herbalist harvests while your guild owns an active dynasty core.", type = "profession_activity", profession = "herbalist", target = 500, rewards = { gold = 100000, exp = 280000, dynastieTokens = 35 } },
		{ id = "monthly_dynasty_woodcutting_3", icon = "woodcutting", name = "Woodcutting III", objective = "Complete 500 successful woodcutting actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "woodcutting", target = 500, rewards = { gold = 100000, exp = 280000, dynastieTokens = 35 } },
		{ id = "monthly_dynasty_fishing_3", icon = "fishing", name = "Fishing III", objective = "Complete 500 successful fishing actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "fishing", target = 500, rewards = { gold = 100000, exp = 280000, dynastieTokens = 35 } },
		{ id = "monthly_dynasty_crafting_3", icon = "crafting", name = "Crafting III", objective = "Complete 200 successful crafting actions while your guild owns an active dynasty core.", type = "profession_activity", profession = "crafting", target = 200, rewards = { gold = 105000, exp = 300000, dynastieTokens = 40 } },
		{ id = "monthly_dynasty_armorsmith_3", icon = "armorsmith", name = "Armorsmith III", objective = "Complete 200 successful armorsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "armorsmith", target = 200, rewards = { gold = 105000, exp = 300000, dynastieTokens = 40 } },
		{ id = "monthly_dynasty_weaponsmith_3", icon = "weaponsmith", name = "Weaponsmith III", objective = "Complete 200 successful weaponsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "weaponsmith", target = 200, rewards = { gold = 105000, exp = 300000, dynastieTokens = 40 } },
		{ id = "monthly_dynasty_jewelsmith_3", icon = "jewelsmith", name = "Jewelsmith III", objective = "Complete 200 successful jewelsmith crafts while your guild owns an active dynasty core.", type = "profession_activity", profession = "jewelsmith", target = 200, rewards = { gold = 105000, exp = 300000, dynastieTokens = 40 } }
	}
}

local function create(api)
	local questApi = {}

	local function escape(value)
		return db.escapeString(value or "")
	end

	local function getCycleStart(cycleType, now)
		now = tonumber(now) or os.time()
		if cycleType == "weekend" then
			return now - (now % (tonumber(api.weekendSeconds) or (7 * 24 * 60 * 60)))
		elseif cycleType == "monthly" then
			return now - (now % (tonumber(api.monthlySeconds) or (30 * 24 * 60 * 60)))
		end
		return now - (now % (tonumber(api.dailySeconds) or (24 * 60 * 60)))
	end

	local function getCycleEndsAt(cycleType, cycleStart)
		local duration = tonumber(api.dailySeconds) or (24 * 60 * 60)
		if cycleType == "weekend" then
			duration = tonumber(api.weekendSeconds) or (7 * 24 * 60 * 60)
		elseif cycleType == "monthly" then
			duration = tonumber(api.monthlySeconds) or (30 * 24 * 60 * 60)
		end
		return (tonumber(cycleStart) or 0) + duration
	end

	local function selectQuestSubset(pool, count, cycleStart)
		local selected = {}
		local total = #pool
		if total == 0 then
			return selected
		end

		local startIndex = (math.floor((tonumber(cycleStart) or 0) / 60) % total) + 1
		for offset = 0, math.min(total, count) - 1 do
			local index = ((startIndex + offset - 1) % total) + 1
			table.insert(selected, pool[index])
		end
		return selected
	end

	local function getActiveDefinitions(now)
		now = tonumber(now) or os.time()
		local dailyStart = getCycleStart("daily", now)
		local weekendStart = getCycleStart("weekend", now)
		local monthlyStart = getCycleStart("monthly", now)
		return {
			daily = {
				cycleStart = dailyStart,
				endsAt = getCycleEndsAt("daily", dailyStart),
				quests = selectQuestSubset(DynastieQuestPools.daily, tonumber(api.dailyCount) or 3, dailyStart)
			},
			weekend = {
				cycleStart = weekendStart,
				endsAt = getCycleEndsAt("weekend", weekendStart),
				quests = selectQuestSubset(DynastieQuestPools.weekend, tonumber(api.weekendCount) or 3, weekendStart)
			},
			monthly = {
				cycleStart = monthlyStart,
				endsAt = getCycleEndsAt("monthly", monthlyStart),
				quests = selectQuestSubset(DynastieQuestPools.monthly, tonumber(api.monthlyCount) or 3, monthlyStart)
			}
		}
	end

	local function getActiveDefinitionById(questId, cycleType, now)
		local active = getActiveDefinitions(now)
		local block = active[cycleType]
		if not block then
			return nil, nil
		end

		for _, quest in ipairs(block.quests or {}) do
			if quest.id == questId then
				return quest, block
			end
		end
		return nil, block
	end

	local function getProgressRows(guildId, configId, cycleType, cycleStart)
		local rows = {}
		if not guildId or guildId <= 0 or not configId or configId == "" or not api.hasTable or not api.hasTable("guild_dynastie_quest_progress") then
			return rows
		end

		local query = db.storeQuery(
			"SELECT `quest_id`, `progress`, `completed_at`, `claimed_at` FROM `guild_dynastie_quest_progress` WHERE `guild_id` = " .. guildId ..
			" AND `config_id` = " .. escape(configId) ..
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

	local function upsertProgress(guildId, configId, cycleType, cycleStart, questId, progress, completedAt, claimedAt)
		if not guildId or guildId <= 0 or not configId or configId == "" or not api.hasTable or not api.hasTable("guild_dynastie_quest_progress") then
			return false
		end

		local now = os.time()
		progress = math.max(0, math.floor(tonumber(progress) or 0))
		completedAt = math.max(0, math.floor(tonumber(completedAt) or 0))
		claimedAt = math.max(0, math.floor(tonumber(claimedAt) or 0))

		return db.query(
			"INSERT INTO `guild_dynastie_quest_progress` (`guild_id`, `config_id`, `cycle_type`, `cycle_start`, `quest_id`, `progress`, `completed_at`, `claimed_at`, `created_at`, `updated_at`) VALUES (" ..
				guildId .. ", " .. escape(configId) .. ", " .. escape(cycleType) .. ", " .. (tonumber(cycleStart) or 0) .. ", " .. escape(questId) .. ", " .. progress .. ", " .. completedAt .. ", " .. claimedAt .. ", " .. now .. ", " .. now .. ")" ..
			" ON DUPLICATE KEY UPDATE `progress` = VALUES(`progress`), `completed_at` = VALUES(`completed_at`), `claimed_at` = VALUES(`claimed_at`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function commaValue(amount)
		local formatted = tostring(math.floor(tonumber(amount) or 0))
		while true do
			local updated, count = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
			formatted = updated
			if count == 0 then
				break
			end
		end
		return formatted
	end

	local function calculateDynastieLevelProgress(level, experience)
		local levelCap = math.max(1, tonumber(api.levelCap) or 10)
		local baseExp = math.max(1, tonumber(api.levelBaseExp) or 2500)
		local currentLevel = math.max(1, math.floor(tonumber(level) or 1))
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

	local function getGuildDynastieProgress(guildId)
		local defaultLevel = 1
		local defaultExp = 0
		guildId = tonumber(guildId) or 0
		if guildId <= 0 or not api.getGuildRowById then
			local level, experience, nextLevelExp = calculateDynastieLevelProgress(defaultLevel, defaultExp)
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

		return calculateDynastieLevelProgress(level, experience)
	end

	local function buildRewardText(rewards)
		rewards = type(rewards) == "table" and rewards or {}
		local parts = {}
		if (tonumber(rewards.gold) or 0) > 0 then
			table.insert(parts, tostring(commaValue(tonumber(rewards.gold) or 0)) .. " gold")
		end
		if (tonumber(rewards.exp) or 0) > 0 then
			table.insert(parts, tostring(commaValue(tonumber(rewards.exp) or 0)) .. " exp")
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 then
			table.insert(parts, tostring(commaValue(tonumber(rewards.dynastieTokens) or 0)) .. " dynastie tokens")
		end
		return table.concat(parts, ", ")
	end

	local function countNearbyGuildPlayers(guildId, position, radius)
		if not guildId or guildId <= 0 or type(position) ~= "table" then
			return 0
		end

		local count = 0
		for _, member in ipairs(api.getOnlineGuildPlayers and api.getOnlineGuildPlayers(guildId) or {}) do
			local memberPos = member:getPosition()
			if memberPos and memberPos.z == position.z and math.abs(memberPos.x - position.x) <= radius and math.abs(memberPos.y - position.y) <= radius then
				count = count + 1
			end
		end
		return count
	end

	local function normalizeMonsterName(name)
		return tostring(name or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	end

	local function normalizeMonsterList(monsters)
		local list = {}
		if type(monsters) == "table" then
			for _, monsterName in ipairs(monsters) do
				local normalized = normalizeMonsterName(monsterName)
				if normalized ~= "" then
					table.insert(list, normalized)
				end
			end
		else
			local normalized = normalizeMonsterName(monsters)
			if normalized ~= "" then
				table.insert(list, normalized)
			end
		end
		return list
	end

	local function getDynamicProgressForQuest(guildId, configId, quest)
		if not quest or quest.type ~= "active_duration_days" or not api.getDynastieState then
			return nil
		end

		local state = api.getDynastieState(configId)
		if not state or tonumber(state.guildId or 0) ~= tonumber(guildId or 0) then
			return 0
		end

		local placedAt = tonumber(state.placedAt or 0) or 0
		if placedAt <= 0 then
			return 0
		end

		local elapsedDays = math.floor(math.max(0, os.time() - placedAt) / (24 * 60 * 60))
		return math.min(tonumber(quest.target) or 0, elapsedDays)
	end

	local function resolveQuestIcon(quest)
		if type(quest) ~= "table" then
			return "dynastie_achievement"
		end
		if type(quest.icon) == "string" and quest.icon ~= "" then
			return quest.icon
		end
		return "dynastie_achievement"
	end

	local function buildPayload(guildId, configId)
		local now = os.time()
		local active = getActiveDefinitions(now)
		local payload = {
			configId = configId,
			dailyEndsAt = active.daily.endsAt,
			weekendEndsAt = active.weekend.endsAt,
			monthlyEndsAt = active.monthly.endsAt,
			daily = {},
			weekend = {},
			monthly = {}
		}

		for cycleType, block in pairs(active) do
			local progressRows = getProgressRows(guildId, configId, cycleType, block.cycleStart)
			for _, quest in ipairs(block.quests or {}) do
				local row = progressRows[quest.id] or {}
				local dynamicProgress = getDynamicProgressForQuest(guildId, configId, quest)
				local progress = math.min(tonumber(dynamicProgress ~= nil and dynamicProgress or row.progress) or 0, tonumber(quest.target) or 0)
				table.insert(payload[cycleType], {
					id = quest.id,
					name = quest.name,
					objective = quest.objective,
					icon = resolveQuestIcon(quest),
					type = quest.type,
					target = tonumber(quest.target) or 0,
					progress = progress,
					completed = progress >= (tonumber(quest.target) or 0),
					claimed = (tonumber(row.claimedAt) or 0) > 0,
					cycleType = cycleType,
					cycleStart = block.cycleStart,
					rewardText = buildRewardText(quest.rewards),
					rewardEntries = api.buildQuestRewardEntries and api.buildQuestRewardEntries(quest.rewards) or {}
				})
			end
		end

		return payload
	end

	function questApi.send(player, configId)
		local guildId = api.resolvePlayerGuildId and api.resolvePlayerGuildId(player) or 0
		if guildId <= 0 or not configId or configId == "" then
			return api.sendGuildPayload(player, "dynastieQuests", nil)
		end
		api.sendGuildPayload(player, "dynastieQuests", buildPayload(guildId, configId))
	end

	function questApi.awardTaxProgress(guildId, configId, amount)
		guildId = tonumber(guildId) or 0
		configId = tostring(configId or "")
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if guildId <= 0 or configId == "" or amount <= 0 then
			return
		end

		local active = getActiveDefinitions(os.time())
		for cycleType, block in pairs(active) do
			local progressRows = getProgressRows(guildId, configId, cycleType, block.cycleStart)
			for _, quest in ipairs(block.quests or {}) do
				if quest.type == "earn_tax_gold" then
					local row = progressRows[quest.id] or {}
					if (tonumber(row.claimedAt) or 0) == 0 then
						local current = tonumber(row.progress) or 0
						local targetCount = tonumber(quest.target) or 0
						if current < targetCount then
							local newProgress = math.min(targetCount, current + amount)
							local completedAt = tonumber(row.completedAt) or 0
							if newProgress >= targetCount and completedAt <= 0 then
								completedAt = os.time()
							end
							upsertProgress(guildId, configId, cycleType, block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
						end
					end
				end
			end
		end
	end

	function questApi.awardDynastieTokenProgress(guildId, configId, amount)
		guildId = tonumber(guildId) or 0
		configId = tostring(configId or "")
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if guildId <= 0 or configId == "" or amount <= 0 then
			return
		end

		local active = getActiveDefinitions(os.time())
		for cycleType, block in pairs(active) do
			local progressRows = getProgressRows(guildId, configId, cycleType, block.cycleStart)
			for _, quest in ipairs(block.quests or {}) do
				if quest.type == "gain_dynasty_tokens" then
					local row = progressRows[quest.id] or {}
					if (tonumber(row.claimedAt) or 0) == 0 then
						local current = tonumber(row.progress) or 0
						local targetCount = tonumber(quest.target) or 0
						if current < targetCount then
							local newProgress = math.min(targetCount, current + amount)
							local completedAt = tonumber(row.completedAt) or 0
							if newProgress >= targetCount and completedAt <= 0 then
								completedAt = os.time()
							end
							upsertProgress(guildId, configId, cycleType, block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
						end
					end
				end
			end
		end
	end

	function questApi.awardBossKill(player, target)
		if not player or not target or not target:isMonster() or target:getMaster() then
			return
		end

		local guild = player:getGuild()
		if not guild or not api.getGuildActiveDynastieConfigIds then
			return
		end

		local activeConfigIds = api.getGuildActiveDynastieConfigIds(guild:getId())
		if type(activeConfigIds) ~= "table" or #activeConfigIds == 0 then
			return
		end

		local killedName = normalizeMonsterName(target:getName())
		if killedName == "" then
			return
		end

		local bossPos = target:getPosition()
		local active = getActiveDefinitions(os.time())
		for _, quest in ipairs(active.daily.quests or {}) do
			if quest.type == "boss_kill_with_guild" then
				for _, bossName in ipairs(normalizeMonsterList(quest.monster)) do
					if bossName == killedName then
						local nearbyCount = countNearbyGuildPlayers(guild:getId(), bossPos, 15)
						if nearbyCount >= (tonumber(quest.minGuildMembers) or 1) then
							for _, configId in ipairs(activeConfigIds) do
								local progressRows = getProgressRows(guild:getId(), configId, "daily", active.daily.cycleStart)
								local row = progressRows[quest.id] or {}
								if (tonumber(row.claimedAt) or 0) == 0 then
									local current = tonumber(row.progress) or 0
									local targetCount = tonumber(quest.target) or 0
									if current < targetCount then
										local newProgress = math.min(targetCount, current + 1)
										local completedAt = tonumber(row.completedAt) or 0
										if newProgress >= targetCount and completedAt <= 0 then
											completedAt = os.time()
										end
										upsertProgress(guild:getId(), configId, "daily", active.daily.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
									end
								end
							end
						end
						break
					end
				end
			end
		end
	end

	function questApi.awardDefenseWin(defenderGuildId, configId)
		defenderGuildId = tonumber(defenderGuildId) or 0
		configId = tostring(configId or "")
		if defenderGuildId <= 0 or configId == "" then
			return
		end

		local active = getActiveDefinitions(os.time())
		local progressRows = getProgressRows(defenderGuildId, configId, "weekend", active.weekend.cycleStart)
		for _, quest in ipairs(active.weekend.quests or {}) do
			if quest.type == "defend_dynastie_win" then
				local row = progressRows[quest.id] or {}
				if (tonumber(row.claimedAt) or 0) == 0 then
					local current = tonumber(row.progress) or 0
					local targetCount = tonumber(quest.target) or 0
					if current < targetCount then
						local newProgress = math.min(targetCount, current + 1)
						local completedAt = tonumber(row.completedAt) or 0
						if newProgress >= targetCount and completedAt <= 0 then
							completedAt = os.time()
						end
						upsertProgress(defenderGuildId, configId, "weekend", active.weekend.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
					end
				end
			end
		end
	end

	function questApi.awardProfessionActivity(player, profession, amount)
		if not player then
			return
		end

		local guild = player:getGuild()
		if not guild or not api.getGuildActiveDynastieConfigIds then
			return
		end

		profession = tostring(profession or ""):lower()
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if profession == "" or amount <= 0 then
			return
		end

		local activeConfigIds = api.getGuildActiveDynastieConfigIds(guild:getId())
		if type(activeConfigIds) ~= "table" or #activeConfigIds == 0 then
			return
		end

		local active = getActiveDefinitions(os.time())
		for _, configId in ipairs(activeConfigIds) do
			for cycleType, block in pairs(active) do
				local progressRows = getProgressRows(guild:getId(), configId, cycleType, block.cycleStart)
				for _, quest in ipairs(block.quests or {}) do
					if quest.type == "profession_activity" and tostring(quest.profession or ""):lower() == profession then
						local row = progressRows[quest.id] or {}
						if (tonumber(row.claimedAt) or 0) == 0 then
							local current = tonumber(row.progress) or 0
							local targetCount = tonumber(quest.target) or 0
							if current < targetCount then
								local newProgress = math.min(targetCount, current + amount)
								local completedAt = tonumber(row.completedAt) or 0
								if newProgress >= targetCount and completedAt <= 0 then
									completedAt = os.time()
								end
								upsertProgress(guild:getId(), configId, cycleType, block.cycleStart, quest.id, newProgress, completedAt, tonumber(row.claimedAt) or 0)
							end
						end
					end
				end
			end
		end
	end

	function questApi.claim(player, data)
		local guild = player and player:getGuild() or nil
		if not guild then
			return api.sendGuildError(player, "You are not in a guild.")
		end
		if api.canManageDynastie and not api.canManageDynastie(player, guild:getId()) then
			return api.sendGuildError(player, "You do not have permission to manage dynastie quests.")
		end

		local configId = tostring(data and data.configId or "")
		local cycleType = tostring(data and data.cycleType or "")
		local questId = tostring(data and data.questId or "")
		if configId == "" then
			return api.sendGuildError(player, "Invalid dynastie core.")
		end
		if cycleType ~= "daily" and cycleType ~= "weekend" and cycleType ~= "monthly" then
			return api.sendGuildError(player, "Invalid dynastie quest cycle.")
		end

		local quest, block = getActiveDefinitionById(questId, cycleType, os.time())
		if not quest or not block then
			return api.sendGuildError(player, "That dynastie quest is no longer active.")
		end

		local rows = getProgressRows(guild:getId(), configId, cycleType, block.cycleStart)
		local row = rows[questId]
		local dynamicProgress = getDynamicProgressForQuest(guild:getId(), configId, quest)
		if not row and dynamicProgress == nil then
			return api.sendGuildError(player, "This dynastie quest has not been progressed yet.")
		end

		local targetCount = tonumber(quest.target) or 0
		local progress = tonumber(dynamicProgress ~= nil and dynamicProgress or row.progress) or 0
		if progress < targetCount then
			return api.sendGuildError(player, "This dynastie quest is not completed yet.")
		end
		if (tonumber(row and row.claimedAt or 0) or 0) > 0 then
			return api.sendGuildError(player, "This dynastie quest reward was already claimed.")
		end

		local guildRow = api.getGuildRowById and api.getGuildRowById(guild:getId())
		if not guildRow then
			return api.sendGuildError(player, "Guild data could not be loaded.")
		end

		local rewards = quest.rewards or {}
		local rewardItems = {}
		if type(rewards.items) == "table" then
			for _, itemReward in ipairs(rewards.items) do
				local itemId = tonumber(itemReward.itemId) or 0
				local count = tonumber(itemReward.count) or 0
				if itemId > 0 and count > 0 then
					rewardItems[#rewardItems + 1] = { itemId = itemId, count = count, tooltip = "", attributes = "" }
				end
			end
		end
		if #rewardItems > 0 and api.canStoreItemsInGuildStorage and not api.canStoreItemsInGuildStorage(guild:getId(), rewardItems) then
			return api.sendGuildError(player, "There is no space in guild storage to claim this dynastie quest reward.")
		end

		local updates = {}
		if (tonumber(rewards.gold) or 0) > 0 and api.hasColumn("guilds", "balance") then
			table.insert(updates, "`balance` = `balance` + " .. (tonumber(rewards.gold) or 0))
		end
		if (tonumber(rewards.exp) or 0) > 0 and api.hasColumn and api.hasColumn("guilds", "dynastie_level") and api.hasColumn("guilds", "dynastie_experience") then
			local currentLevel, currentExp = getGuildDynastieProgress(guild:getId())
			local newLevel, newExp = calculateDynastieLevelProgress(currentLevel, currentExp + (tonumber(rewards.exp) or 0))
			table.insert(updates, "`dynastie_level` = " .. newLevel)
			table.insert(updates, "`dynastie_experience` = " .. newExp)
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 and api.hasColumn("guilds", "dynastie_tokens") then
			table.insert(updates, "`dynastie_tokens` = `dynastie_tokens` + " .. (tonumber(rewards.dynastieTokens) or 0))
		end
		if #updates > 0 then
			db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId())
		end
		if (tonumber(rewards.dynastieTokens) or 0) > 0 then
			questApi.awardDynastieTokenProgress(guild:getId(), configId, tonumber(rewards.dynastieTokens) or 0)
		end

		upsertProgress(guild:getId(), configId, cycleType, block.cycleStart, questId, progress, tonumber(row and row.completedAt or 0) or os.time(), os.time())
		api.addGuildMessages(
			api.getGuildInboxRecipients(guild:getId()),
			guild:getId(),
			api.messageTypes.QUEST_REWARD,
			string.format("[%s] %s claimed dynastie quest rewards: {%s}.", quest.name, player:getName(), buildRewardText(rewards)),
			player:getGuid(),
			guild:getId()
		)

		if api.refreshDynastieForGuildMembers then
			api.refreshDynastieForGuildMembers(guild:getId())
		end
		api.refreshGuildForMembers(guild:getId())
		if api.refreshDynastieWorld then
			api.refreshDynastieWorld()
		end
		if api.sendDynastie then
			api.sendDynastie(player)
		end
		questApi.send(player, configId)
	end

	return questApi
end

return {
	create = create
}
