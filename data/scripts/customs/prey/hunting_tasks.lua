local OPCODE_HUNTING_TASK = 233
local PREY_CONFIG_FILE = "data/scripts/customs/prey/config.lua"
print(">> [Task Board] Loaded")
HuntingTask = HuntingTask or {
	cache = {},
	choices = {},
	ignored = nil,
}

local function normalizeName(name)
	return tostring(name or ""):lower()
end

local function loadIgnoredMonsters()
	if HuntingTask.ignored then
		return HuntingTask.ignored
	end

	HuntingTask.ignored = {}
	local ok, config = pcall(dofile, PREY_CONFIG_FILE)
	if ok and type(config) == "table" and type(config.ignoredMonsters) == "table" then
		for _, name in ipairs(config.ignoredMonsters) do
			HuntingTask.ignored[normalizeName(name)] = true
		end
	end
	return HuntingTask.ignored
end

local bestiaryRaceIds = nil

local function getBestiaryRaceId(name)
	local key = normalizeName(name)
	if key == "" then
		return 0
	end

	if Bestiary and type(Bestiary.creatureLookUpMap) == "table" then
		local direct = Bestiary.creatureLookUpMap[name]
		if direct and direct.raceId then
			return tonumber(direct.raceId) or 0
		end
	end

	if not bestiaryRaceIds then
		bestiaryRaceIds = {}
		if Bestiary and type(Bestiary.bestiaryData) == "table" then
			for _, categoryData in pairs(Bestiary.bestiaryData) do
				for _, creatureData in ipairs(categoryData.creatures or {}) do
					if creatureData.name and creatureData.raceId then
						bestiaryRaceIds[normalizeName(creatureData.name)] = tonumber(creatureData.raceId) or 0
					end
				end
			end
		end
	end

	return bestiaryRaceIds[key] or 0
end

local function createTables()
	db.query("CREATE TABLE IF NOT EXISTS `player_hunting_tasks` (`player_id` int NOT NULL, `slot` tinyint unsigned NOT NULL, `monster_name` varchar(255) NOT NULL DEFAULT '', `current_kills` int unsigned NOT NULL DEFAULT 0, `required_kills` int unsigned NOT NULL DEFAULT 0, `reward_points` int unsigned NOT NULL DEFAULT 0, `updated_at` bigint unsigned NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`, `slot`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
	local resultId = db.storeQuery("SHOW COLUMNS FROM `player_prey_resources` LIKE 'hunting_task_tokens'")
	if resultId then
		result.free(resultId)
	else
		db.query("ALTER TABLE `player_prey_resources` ADD COLUMN `hunting_task_tokens` int unsigned NOT NULL DEFAULT 0 AFTER `wildcards`;")
	end
end

local function getOutfitData(monsterType)
	local outfit = monsterType and monsterType:outfit()
	if not outfit then
		return nil
	end

	return {
		type = outfit.lookType or outfit.type or 0,
		auxType = outfit.lookTypeEx or outfit.auxType or 0,
		head = outfit.lookHead or outfit.head or 0,
		body = outfit.lookBody or outfit.body or 0,
		legs = outfit.lookLegs or outfit.legs or 0,
		feet = outfit.lookFeet or outfit.feet or 0,
		addons = outfit.lookAddons or outfit.addons or 0,
		mount = outfit.lookMount or outfit.mount or 0,
		wings = outfit.lookWings or outfit.wings or 0,
		aura = outfit.lookAura or outfit.aura or 0,
		shader = outfit.lookShader or outfit.shader or "",
	}
end

local function roundToHundred(value)
	return math.floor((value + 50) / 100) * 100
end

local function taskValues(maxHealth, multiplier)
	maxHealth = math.max(1, tonumber(maxHealth) or 1)
	multiplier = math.max(1, tonumber(multiplier) or 1)
	local required = math.max(200, math.min(5000, roundToHundred(maxHealth / 10)))
	required = math.max(200, math.min(5000, roundToHundred(required * multiplier)))
	local reward = math.max(1, math.min(500, math.floor((maxHealth / 25) * multiplier + 0.5)))
	return required, reward
end

local function buildMonsterPool()
	local ignored = loadIgnoredMonsters()
	local pool = {}

	for _, monsterType in pairs(Game.getMonsterTypes()) do
		local name = monsterType:name()
		local key = normalizeName(name)
		local maxHealth = tonumber(monsterType:maxHealth()) or 0
		if name and name ~= "" and maxHealth > 0 and not ignored[key] and not monsterType:isRewardBoss() and not monsterType:isBoss() then
			local outfit = getOutfitData(monsterType)
			if outfit and ((tonumber(outfit.type) or 0) > 0 or (tonumber(outfit.auxType) or 0) > 0) then
				local required, reward = taskValues(maxHealth, 1)
				local highRequired, highReward = taskValues(maxHealth, 2)
				pool[#pool + 1] = {
					name = name,
					raceId = getBestiaryRaceId(name),
					health = maxHealth,
					required = required,
					reward = reward,
					highRequired = highRequired,
					highReward = highReward,
					outfit = outfit,
				}
			end
		end
	end

	return pool
end

local monsterPool = nil

local function getMonsterPool()
	if not monsterPool then
		monsterPool = buildMonsterPool()
	end
	return monsterPool
end

local function getTokens(player)
	local resultId = db.storeQuery("SELECT `hunting_task_tokens` FROM `player_prey_resources` WHERE `player_id` = " .. player:getGuid())
	if not resultId then
		return 0
	end
	local tokens = result.getDataInt(resultId, "hunting_task_tokens")
	result.free(resultId)
	return math.max(0, tokens)
end

local function addTokens(player, amount)
	amount = math.max(0, tonumber(amount) or 0)
	if amount <= 0 then
		return
	end

	db.query(string.format("INSERT INTO `player_prey_resources` (`player_id`, `hunting_task_tokens`, `updated_at`) VALUES (%d, %d, %d) ON DUPLICATE KEY UPDATE `hunting_task_tokens` = `hunting_task_tokens` + VALUES(`hunting_task_tokens`), `updated_at` = VALUES(`updated_at`)", player:getGuid(), amount, os.time()))
end

local function getSlotChoices(player, slot)
	local guid = player:getGuid()
	HuntingTask.choices[guid] = HuntingTask.choices[guid] or {}
	if HuntingTask.choices[guid][slot] then
		return HuntingTask.choices[guid][slot]
	end

	local activeNames = {}
	local cache = HuntingTask.cache[guid] or {}
	for activeSlot, task in pairs(cache) do
		if activeSlot ~= slot and task.monsterName then
			activeNames[normalizeName(task.monsterName)] = true
		end
	end

	local pool = getMonsterPool()
	local picked = {}
	local attempts = 0
	while #picked < 9 and attempts < 200 and #pool > 0 do
		attempts = attempts + 1
		local candidate = pool[math.random(1, #pool)]
		if not activeNames[normalizeName(candidate.name)] then
			local duplicate = false
			for _, choice in ipairs(picked) do
				if normalizeName(choice.name) == normalizeName(candidate.name) then
					duplicate = true
					break
				end
			end
			if not duplicate then
				picked[#picked + 1] = candidate
			end
		end
	end

	HuntingTask.choices[guid][slot] = picked
	return picked
end

local function loadPlayerTasks(player)
	local guid = player:getGuid()
	HuntingTask.cache[guid] = {}
	local resultId = db.storeQuery("SELECT `slot`, `monster_name`, `current_kills`, `required_kills`, `reward_points` FROM `player_hunting_tasks` WHERE `player_id` = " .. guid)
	if not resultId then
		return HuntingTask.cache[guid]
	end

	repeat
		local slot = result.getDataInt(resultId, "slot")
		HuntingTask.cache[guid][slot] = {
			monsterName = result.getDataString(resultId, "monster_name"),
			currentKills = result.getDataInt(resultId, "current_kills"),
			requiredKills = result.getDataInt(resultId, "required_kills"),
			rewardPoints = result.getDataInt(resultId, "reward_points"),
			dirty = false,
		}
	until not result.next(resultId)
	result.free(resultId)
	return HuntingTask.cache[guid]
end

local function getPlayerTasks(player)
	local guid = player:getGuid()
	return HuntingTask.cache[guid] or loadPlayerTasks(player)
end

local function saveTask(player, slot)
	local guid = player:getGuid()
	local task = HuntingTask.cache[guid] and HuntingTask.cache[guid][slot]
	if not task then
		return
	end

	db.query(string.format("UPDATE `player_hunting_tasks` SET `current_kills` = %d, `updated_at` = %d WHERE `player_id` = %d AND `slot` = %d", task.currentKills, os.time(), guid, slot))
	task.dirty = false
end

local function saveDirtyTasks(player)
	local tasks = HuntingTask.cache[player:getGuid()]
	if not tasks then
		return
	end
	for slot, task in pairs(tasks) do
		if task.dirty then
			saveTask(player, slot)
		end
	end
end

local function findChoice(player, slot, name)
	for _, choice in ipairs(getSlotChoices(player, slot)) do
		if normalizeName(choice.name) == normalizeName(name) then
			return choice
		end
	end
	return nil
end

function HuntingTask.sendState(player)
	local tasks = getPlayerTasks(player)
	local unlockedSlots = math.max(1, math.min(3, tonumber(player:getHuntingTaskUnlockedSlots()) or 1))
	local response = {
		action = "state",
		tokens = getTokens(player),
		unlockedSlots = unlockedSlots,
		slots = {},
	}

	for slot = 1, 3 do
		local slotData = { slot = slot }
		if slot > unlockedSlots then
			slotData.state = "locked"
		elseif tasks[slot] then
			local task = tasks[slot]
			local monsterType = MonsterType(task.monsterName)
			slotData.state = "active"
			slotData.monster = task.monsterName
			slotData.kills = task.currentKills
			slotData.required = task.requiredKills
			slotData.reward = task.rewardPoints
			slotData.outfit = getOutfitData(monsterType)
			slotData.raceId = getBestiaryRaceId(task.monsterName)
		else
			slotData.state = "selection"
			slotData.choices = getSlotChoices(player, slot)
		end
		response.slots[#response.slots + 1] = slotData
	end

	player:sendExtendedOpcode(OPCODE_HUNTING_TASK, json.encode(response))
end

local function selectTask(player, data)
	local slot = math.max(1, math.min(3, tonumber(data.slot) or 1))
	if slot > (tonumber(player:getHuntingTaskUnlockedSlots()) or 1) then
		HuntingTask.sendState(player)
		return
	end

	if getPlayerTasks(player)[slot] then
		HuntingTask.sendState(player)
		return
	end

	local choice = findChoice(player, slot, data.monster)
	if not choice then
		HuntingTask.choices[player:getGuid()] = nil
		HuntingTask.sendState(player)
		return
	end

	local requested = tonumber(data.required) or choice.required
	local required = choice.required
	local reward = choice.reward
	if requested == choice.highRequired then
		required = choice.highRequired
		reward = choice.highReward
	end

	db.query(string.format("REPLACE INTO `player_hunting_tasks` (`player_id`, `slot`, `monster_name`, `current_kills`, `required_kills`, `reward_points`, `updated_at`) VALUES (%d, %d, %s, 0, %d, %d, %d)", player:getGuid(), slot, db.escapeString(choice.name), required, reward, os.time()))
	HuntingTask.cache[player:getGuid()] = nil
	HuntingTask.choices[player:getGuid()] = nil
	HuntingTask.sendState(player)
end

local extendedEvent = CreatureEvent("HuntingTaskExtended")
function extendedEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= OPCODE_HUNTING_TASK then
		return true
	end

	local ok, data = pcall(json.decode, buffer)
	if not ok or type(data) ~= "table" then
		return true
	end

	if data.action == "request" then
		HuntingTask.sendState(player)
	elseif data.action == "reroll" then
		local slot = math.max(1, math.min(3, tonumber(data.slot) or 1))
		if slot <= (tonumber(player:getHuntingTaskUnlockedSlots()) or 1) and getPlayerTasks(player)[slot] then
			db.query(string.format("DELETE FROM `player_hunting_tasks` WHERE `player_id` = %d AND `slot` = %d", player:getGuid(), slot))
			HuntingTask.cache[player:getGuid()] = nil
		end
		HuntingTask.choices[player:getGuid()] = HuntingTask.choices[player:getGuid()] or {}
		HuntingTask.choices[player:getGuid()][slot] = nil
		HuntingTask.sendState(player)
	elseif data.action == "select" then
		selectTask(player, data)
	end
	return true
end
extendedEvent:type("extendedopcode")
extendedEvent:register()

local killEvent = CreatureEvent("HuntingTaskKill")
function killEvent.onKill(player, target)
	if not target or not target:isMonster() or target:getMaster() then
		return true
	end

	local tasks = getPlayerTasks(player)
	local killedName = normalizeName(target:getName())
	for slot, task in pairs(tasks) do
		if normalizeName(task.monsterName) == killedName then
			task.currentKills = math.min(task.requiredKills, task.currentKills + 1)
			task.dirty = true
			if task.currentKills >= task.requiredKills then
				saveTask(player, slot)
				addTokens(player, task.rewardPoints)
				db.query(string.format("DELETE FROM `player_hunting_tasks` WHERE `player_id` = %d AND `slot` = %d", player:getGuid(), slot))
				HuntingTask.cache[player:getGuid()] = nil
				HuntingTask.choices[player:getGuid()] = nil
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("[Hunting Task] Finished %s and received %d hunting task tokens.", task.monsterName, task.rewardPoints))
				HuntingTask.sendState(player)
			elseif task.currentKills % 10 == 0 then
				saveTask(player, slot)
				HuntingTask.sendState(player)
			else
				player:sendExtendedOpcode(OPCODE_HUNTING_TASK, json.encode({ action = "progress", slot = slot, kills = task.currentKills, required = task.requiredKills, tokens = getTokens(player) }))
			end
			break
		end
	end
	return true
end
killEvent:type("kill")
killEvent:register()

local loginEvent = CreatureEvent("HuntingTaskLogin")
function loginEvent.onLogin(player)
	player:registerEvent("HuntingTaskExtended")
	player:registerEvent("HuntingTaskKill")
	player:registerEvent("HuntingTaskLogout")
	loadPlayerTasks(player)
	return true
end
loginEvent:type("login")
loginEvent:register()

local logoutEvent = CreatureEvent("HuntingTaskLogout")
function logoutEvent.onLogout(player)
	saveDirtyTasks(player)
	HuntingTask.cache[player:getGuid()] = nil
	HuntingTask.choices[player:getGuid()] = nil
	return true
end
logoutEvent:type("logout")
logoutEvent:register()

local startupEvent = GlobalEvent("HuntingTaskStartup")
function startupEvent.onStartup()
	createTables()
	monsterPool = nil
	loadIgnoredMonsters()
	return true
end
startupEvent:register()
