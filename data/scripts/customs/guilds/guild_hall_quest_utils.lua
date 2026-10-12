local function getGuildQuestCycleStart(cycleType, now)
	now = tonumber(now) or os.time()
	if cycleType == "weekend" then
		return now - (now % GuildManagement.QUEST_WEEKEND_SECONDS)
	elseif cycleType == "monthly" then
		return now - (now % GuildManagement.QUEST_MONTHLY_SECONDS)
	end
	return now - (now % GuildManagement.QUEST_DAILY_SECONDS)
end

local function getGuildQuestCycleEndsAt(cycleType, cycleStart)
	local duration = GuildManagement.QUEST_DAILY_SECONDS
	if cycleType == "weekend" then
		duration = GuildManagement.QUEST_WEEKEND_SECONDS
	elseif cycleType == "monthly" then
		duration = GuildManagement.QUEST_MONTHLY_SECONDS
	end
	return (tonumber(cycleStart) or 0) + duration
end

local function normalizeQuestMonsterName(name)
	return tostring(name or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalizeQuestMonsterList(monsters)
	local list = {}
	if type(monsters) == "table" then
		for _, monsterName in ipairs(monsters) do
			local normalized = normalizeQuestMonsterName(monsterName)
			if normalized ~= "" then
				table.insert(list, normalized)
			end
		end
	else
		local normalized = normalizeQuestMonsterName(monsters)
		if normalized ~= "" then
			table.insert(list, normalized)
		end
	end
	return list
end

local function questMatchesMonster(quest, killedName)
	if not quest or quest.type ~= "kill_monster" then
		return false
	end

	for _, monsterName in ipairs(normalizeQuestMonsterList(quest.monster)) do
		if monsterName == killedName then
			return true
		end
	end

	return false
end

local function selectQuestSubset(pool, count, cycleStart)
	local selected = {}
	local total = #pool
	if total == 0 or count <= 0 then
		return selected
	end

	local seed = math.floor((tonumber(cycleStart) or 0) / 60)
	local index = (seed % total) + 1
	while #selected < math.min(count, total) do
		table.insert(selected, pool[index])
		index = index + 1
		if index > total then
			index = 1
		end
	end
	return selected
end

local function getActiveGuildQuestDefinitions(now)
	now = tonumber(now) or os.time()
	local dailyStart = getGuildQuestCycleStart("daily", now)
	local weekendStart = getGuildQuestCycleStart("weekend", now)
	local monthlyStart = getGuildQuestCycleStart("monthly", now)

	return {
		daily = {
			cycleStart = dailyStart,
			endsAt = getGuildQuestCycleEndsAt("daily", dailyStart),
			quests = selectQuestSubset(GuildQuestPools.daily, GuildManagement.QUEST_DAILY_COUNT, dailyStart)
		},
		weekend = {
			cycleStart = weekendStart,
			endsAt = getGuildQuestCycleEndsAt("weekend", weekendStart),
			quests = selectQuestSubset(GuildQuestPools.weekend, GuildManagement.QUEST_WEEKEND_COUNT, weekendStart)
		},
		monthly = {
			cycleStart = monthlyStart,
			endsAt = getGuildQuestCycleEndsAt("monthly", monthlyStart),
			quests = selectQuestSubset(GuildQuestPools.monthly, GuildManagement.QUEST_MONTHLY_COUNT, monthlyStart)
		}
	}
end

local function getActiveQuestDefinitionById(questId, cycleType, now)
	local active = getActiveGuildQuestDefinitions(now)
	local block = active[cycleType]
	if not block or type(block.quests) ~= "table" then
		return nil, block
	end
	for _, quest in ipairs(block.quests) do
		if quest.id == questId then
			return quest, block
		end
	end
	return nil, block
end

return {
	getGuildQuestCycleStart = getGuildQuestCycleStart,
	getGuildQuestCycleEndsAt = getGuildQuestCycleEndsAt,
	normalizeQuestMonsterName = normalizeQuestMonsterName,
	normalizeQuestMonsterList = normalizeQuestMonsterList,
	questMatchesMonster = questMatchesMonster,
	selectQuestSubset = selectQuestSubset,
	getActiveGuildQuestDefinitions = getActiveGuildQuestDefinitions,
	getActiveQuestDefinitionById = getActiveQuestDefinitionById
}
