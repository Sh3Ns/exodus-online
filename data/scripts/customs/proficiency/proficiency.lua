local OPCODE = 236
local CONFIG_FILE = "data/scripts/customs/proficiency/proficiencies.json"
local PLAYER_COLUMN = "proficiency_data"
local FETCH_BATCH_SIZE = 20
local FETCH_BATCH_DELAY_MS = 40
local CATALOG_BATCH_SIZE = 100
local CATALOG_BATCH_DELAY_MS = 20
local MAX_PROFICIENCY_PERK_LEVELS = 20

WeaponProficiencyExt = WeaponProficiencyExt or {}
local System = WeaponProficiencyExt
System.OPCODE = OPCODE
System.players = System.players or {}
System.profiles = {}
System.profileNames = {}
System.itemProfiles = {}
System.processedKills = {}
System.spellIds = {}
System.homingMissileDamage = {}
System.homingMissileRolls = {}

local XP = {
	regular = {1750, 25000, 100000, 400000, 2000000, 8000000, 30000000, 60000000, 90000000,
		125000000, 165000000, 210000000, 260000000, 315000000, 375000000, 440000000,
		510000000, 585000000, 665000000, 750000000, 840000000, 935000000},
	knight = {1250, 20000, 80000, 300000, 1500000, 6000000, 20000000, 40000000, 60000000,
		85000000, 115000000, 150000000, 190000000, 235000000, 285000000, 340000000,
		400000000, 465000000, 535000000, 610000000, 690000000, 775000000},
	crossbow = {600, 8000, 30000, 150000, 650000, 2500000, 10000000, 20000000, 30000000,
		42500000, 57500000, 75000000, 95000000, 117500000, 142500000, 170000000,
		200000000, 232500000, 267500000, 305000000, 345000000, 387500000}
}
local KILL_XP = {[0] = 1, [1] = 30, [2] = 70, [3] = 100, [4] = 165, [5] = 240}
local BOSS_XP = {bane = 500, archfoe = 2500, nemesis = 5000, apex = 10000}
local WEAPON_TYPES = {[WEAPON_SWORD] = true, [WEAPON_CLUB] = true, [WEAPON_AXE] = true,
	[WEAPON_FIST] = true, [WEAPON_DISTANCE] = true, [WEAPON_WAND] = true}
local KNIGHT_TYPES = {[WEAPON_SWORD] = true, [WEAPON_CLUB] = true, [WEAPON_AXE] = true, [WEAPON_FIST] = true}
local SKILLS = {[1] = SKILL_MAGLEVEL, [6] = SKILL_SHIELD, [7] = SKILL_DISTANCE,
	[8] = SKILL_SWORD, [9] = SKILL_CLUB, [10] = SKILL_AXE, [11] = SKILL_FIST, [13] = SKILL_FISHING}
local ELEMENTS = {[1] = COMBAT_PHYSICALDAMAGE, [4] = COMBAT_PHYSICALDAMAGE, [8] = COMBAT_FIREDAMAGE,
	[16] = COMBAT_EARTHDAMAGE, [32] = COMBAT_ENERGYDAMAGE, [64] = COMBAT_ICEDAMAGE,
	[128] = COMBAT_HOLYDAMAGE, [256] = COMBAT_DEATHDAMAGE,
	[4096] = COMBAT_WATERDAMAGE, [8192] = COMBAT_ARCANEDAMAGE}
local HOMING_MISSILES = {
	[8] = {shoot = CONST_ANI_FIRE, effect = CONST_ME_HITBYFIRE},
	[16] = {shoot = CONST_ANI_EARTH, effect = CONST_ME_SMALLPLANTS},
	[32] = {shoot = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYHIT},
	[64] = {shoot = CONST_ANI_ICE, effect = CONST_ME_ICEATTACK},
	[128] = {shoot = CONST_ANI_HOLY, effect = CONST_ME_HOLYDAMAGE},
	[256] = {shoot = CONST_ANI_DEATH, effect = CONST_ME_MORTAREA}
}
local TIERS = {"water inferniarch", "arcane inferniarch", "gilded eldritch", "grand sanguine",
	"master umbral", "crude umbral", "inferniarch",
	"eldritch", "sanguine", "umbral",
	"amber", "soul", "cobra", "falcon", "naga", "lion", "jungle", "glooth", "destruction", "crypt"}
local CONDITION_SUBID = 51060
local SKILL_PARAMS = {[1] = CONDITION_PARAM_STAT_MAGICPOINTS, [6] = CONDITION_PARAM_SKILL_SHIELD,
	[7] = CONDITION_PARAM_SKILL_DISTANCE, [8] = CONDITION_PARAM_SKILL_SWORD, [9] = CONDITION_PARAM_SKILL_CLUB,
	[10] = CONDITION_PARAM_SKILL_AXE, [11] = CONDITION_PARAM_SKILL_FIST, [13] = CONDITION_PARAM_SKILL_FISHING}
SKILL_PARAMS[14] = CONDITION_PARAM_SKILL_CRAFTING
SKILL_PARAMS[15] = CONDITION_PARAM_SKILL_WOODCUTTING
SKILL_PARAMS[16] = CONDITION_PARAM_SKILL_MINING
SKILL_PARAMS[17] = CONDITION_PARAM_SKILL_HERBALIST
SKILL_PARAMS[18] = CONDITION_PARAM_SKILL_ARMORSMITH
SKILL_PARAMS[19] = CONDITION_PARAM_SKILL_WEAPONSMITH
SKILL_PARAMS[20] = CONDITION_PARAM_SKILL_JEWELSMITH

local function normalizeName(value)
	return tostring(value or ""):lower():gsub("[^%w%s]", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
end

local function tableSize(value)
	if type(value) ~= "table" then return 0 end
	local count = 0
	for _ in pairs(value) do count = count + 1 end
	return count
end

local function jsonSafeValue(value)
	if type(value) ~= "table" then return value end

	local count, maximum, isArray = 0, 0, true
	for key in pairs(value) do
		count = count + 1
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			isArray = false
		else
			maximum = math.max(maximum, key)
		end
	end
	isArray = isArray and count > 0 and maximum == count

	local output = {}
	if isArray then
		for index = 1, count do output[index] = jsonSafeValue(value[index]) end
	else
		for key, child in pairs(value) do output[tostring(key)] = jsonSafeValue(child) end
	end
	return output
end

local function nowMs()
	return os.mtime and os.mtime() or (os.time() * 1000)
end

local function readProfiles()
	local file = io.open(CONFIG_FILE, "r")
	if not file then
		print("[WeaponProficiency] Cannot open " .. CONFIG_FILE)
		return false
	end
	local raw = file:read("*a")
	file:close()
	local ok, decoded = pcall(json.decode, raw)
	if not ok or type(decoded) ~= "table" then
		print("[WeaponProficiency] Invalid JSON: " .. tostring(decoded))
		return false
	end
	for _, profile in ipairs(decoded) do
		local id = tonumber(profile.ProficiencyId)
		if id and type(profile.Levels) == "table" then
			System.profiles[id] = profile
			System.profileNames[normalizeName(profile.Name)] = id
		end
	end
	local spells = io.open("data/spells/spells.xml", "r")
	if spells then
		for line in spells:lines() do
			local id = line:match('spellid="(%d+)"')
			local name = line:match('name="([^"]+)"')
			if id and name then System.spellIds[normalizeName(name)] = tonumber(id) end
		end
		spells:close()
	end
	print(">> [Weapon Proficiency] Loaded.")
	return true
end

local function getCategory(itemType)
	local weaponType = itemType:getWeaponType()
	local name = normalizeName(itemType:getName())
	if name:find("moonsilver crusher", 1, true) or name:find("moonsilver mace", 1, true) then return "club" end
	if name:find("moonsilver sceptre", 1, true) then return "rod" end
	if weaponType == WEAPON_SWORD then return "sword" end
	if weaponType == WEAPON_CLUB then return "club" end
	if weaponType == WEAPON_AXE then return "axe" end
	if weaponType == WEAPON_FIST then return "fist" end
	if weaponType == WEAPON_WAND then return name:find("%f[%w]rod%f[%W]") and "rod" or "wand" end
	if weaponType == WEAPON_DISTANCE then
		if itemType:getAmmoType() == AMMO_BOLT or name:find("crossbow", 1, true)
			or name:find("arbalest", 1, true) or name:find("bolter", 1, true) then
			return "crossbow"
		end
		if name:find("spear", 1, true) or name:find("star", 1, true) or name:find("knife", 1, true)
			or name:find("stone", 1, true) or name:find("snowball", 1, true) then return "throw" end
		return "bow"
	end
	return nil
end

local function findProfile(itemType)
	if not itemType or not WEAPON_TYPES[itemType:getWeaponType()] then return nil end
	local itemId = itemType:getId()
	if System.itemProfiles[itemId] ~= nil then
		local cached = System.itemProfiles[itemId]
		return cached and System.profiles[cached] or nil
	end
	local itemName = normalizeName(itemType:getName())
	local category = getCategory(itemType)
	local twoHanded = bit.band(itemType:getSlotPosition(), SLOTP_TWO_HAND) ~= 0
	local hand = twoHanded and "2h" or "1h"
	if category == "bow" or category == "crossbow" or category == "fist" then hand = "2h" end
	local candidates = {}
	local function add(name) candidates[#candidates + 1] = normalizeName(name) end
	if category == "throw" then
		add("throw " .. itemName)
		add("distance " .. hand .. " " .. itemName)
	else
		add(category .. " " .. hand .. " " .. itemName)
		if category == "bow" or category == "crossbow" then
			add("distance " .. hand .. " " .. itemName)
		end
		add("caster " .. hand .. " " .. itemName)
	end
	for _, candidate in ipairs(candidates) do
		local id = System.profileNames[candidate]
		if id then System.itemProfiles[itemId] = id return System.profiles[id] end
	end
	local tier
	for _, value in ipairs(TIERS) do if itemName:find(value, 1, true) then tier = value break end end
	local jsonCategory = category
	if category == "throw" then jsonCategory = "distance" end
	if tier then
		local tierCategory = jsonCategory
		if (tier:find("inferniarch", 1, true) or tier:find("eldritch", 1, true) or tier == "cobra"
			or tier == "lion" or tier == "naga") and (category == "bow" or category == "crossbow") then
			tierCategory = category == "crossbow" and "crossbow" or "distance"
		end
		local id = System.profileNames[normalizeName(tierCategory .. " " .. hand .. " " .. tier)]
			or System.profileNames[normalizeName(tier .. " " .. hand .. " " .. tierCategory)]
		if id then System.itemProfiles[itemId] = id return System.profiles[id] end
	end
	local genericCategory = (category == "wand" or category == "rod") and "caster"
		or ((category == "bow" or category == "crossbow" or category == "throw") and "distance") or category
	for _, class in ipairs({1, 2}) do
		local id = System.profileNames[normalizeName("generic " .. hand .. " " .. genericCategory .. " class " .. class)]
		if id then System.itemProfiles[itemId] = id return System.profiles[id] end
	end
	System.itemProfiles[itemId] = false
	return nil
end

local function columnExists()
	if System.columnExists ~= nil then return System.columnExists end
	local query = db.storeQuery("SHOW COLUMNS FROM `players` LIKE " .. db.escapeString(PLAYER_COLUMN))
	System.columnExists = query ~= false and query ~= nil
	if query then result.free(query) end
	return System.columnExists
end

local function normalizePerks(perks)
	local output = {}
	if type(perks) ~= "table" then return output end
	for level, choice in pairs(perks) do
		level, choice = tonumber(level), tonumber(choice)
		if level and choice and level >= 0 and level < MAX_PROFICIENCY_PERK_LEVELS and choice >= 0 then
			output[tostring(level)] = choice
		end
	end
	return output
end

local function normalizeState(state)
	local output = {}
	if type(state) ~= "table" then return output end
	for clientId, value in pairs(state) do
		clientId = tonumber(clientId)
		if clientId and clientId > 0 and type(value) == "table" then
			output[tostring(clientId)] = {exp = math.max(0, math.floor(tonumber(value.exp) or 0)), perks = normalizePerks(value.perks)}
		end
	end
	return output
end

local function loadState(player)
	local guid = player:getGuid()
	if System.players[guid] then return System.players[guid] end
	local state = {}
	if columnExists() then
		local query = db.storeQuery("SELECT `" .. PLAYER_COLUMN .. "` FROM `players` WHERE `id` = " .. guid)
		if query then
			local raw = result.getString(query, PLAYER_COLUMN)
			result.free(query)
			if raw and raw ~= "" then
				local ok, decoded = pcall(json.decode, raw)
				if ok then state = normalizeState(decoded) end
			end
		end
	end
	System.players[guid] = state
	return state
end

local function saveState(player)
	if not player or not columnExists() then return false end
	local state = normalizeState(loadState(player))
	System.players[player:getGuid()] = state
	return db.query("UPDATE `players` SET `" .. PLAYER_COLUMN .. "` = " .. db.escapeString(json.encode(jsonSafeValue(state)))
		.. " WHERE `id` = " .. player:getGuid())
end

local function getItemInfo(clientId)
	clientId = math.floor(tonumber(clientId) or 0)
	if clientId <= 0 then return nil end
	local serverId = Game.getItemIdByClientId(clientId)
	if not serverId then return nil end
	local itemType = ItemType(serverId)
	local profile = findProfile(itemType)
	if not profile then return nil end
	return {clientId = clientId, serverId = serverId, itemType = itemType, profile = profile}
end

local function xpClass(itemType)
	local category = getCategory(itemType)
	if category == "crossbow" then return "crossbow" end
	return KNIGHT_TYPES[itemType:getWeaponType()] and "knight" or "regular"
end

local function maxExperience(info)
	local stages = XP[xpClass(info.itemType)]
	local maximum = math.min(#info.profile.Levels + 2, #stages)
	return stages[maximum]
end

local function unlockedLevels(info, exp)
	local stages, count = XP[xpClass(info.itemType)], 0
	for index = 1, math.min(MAX_PROFICIENCY_PERK_LEVELS, #info.profile.Levels, #stages) do
		if exp >= stages[index] then count = index else break end
	end
	return count
end

local function proficiencyLevel(info, exp)
	local stages, count = XP[xpClass(info.itemType)], 0
	local maximum = math.min(#info.profile.Levels + 2, #stages)
	for index = 1, maximum do
		if exp >= stages[index] then count = index else break end
	end
	return count, maximum
end

local function sanitizeEntry(info, entry)
	entry = entry or {exp = 0, perks = {}}
	entry.exp = math.min(maxExperience(info), math.max(0, math.floor(tonumber(entry.exp) or 0)))
	local unlocked, perks = unlockedLevels(info, entry.exp), {}
	for level, choice in pairs(normalizePerks(entry.perks)) do
		local levelIndex = tonumber(level)
		local row = info.profile.Levels[levelIndex + 1]
		if levelIndex < unlocked and row and row.Perks[choice + 1] then
			perks[tostring(levelIndex)] = choice
		end
	end
	entry.perks = perks
	return entry
end

local function getEntry(player, info, create)
	local state, key = loadState(player), tostring(info.clientId)
	local entry = sanitizeEntry(info, state[key])
	if create or state[key] then state[key] = entry end
	return entry
end

local function vocationMask(itemType)
	local requirement = normalizeName(itemType:getVocationString())
	if requirement == "" then return 0 end
	local mask = 0
	for clientVocation, name in ipairs({"knight", "paladin", "sorcerer", "druid", "illusionist", "monk"}) do
		if requirement:find(name, 1, true) then mask = mask + (2 ^ clientVocation) end
	end
	return mask
end

local function meetsWeaponRequirements(player, itemType)
	if player:hasFlag(PlayerFlag_IgnoreWeaponCheck) then return true end

	local requiredLevel = tonumber(itemType:getMinReqLevel()) or 0
	if player:getLevel() < requiredLevel then
		return false, string.format("level=%d requiredLevel=%d", player:getLevel(), requiredLevel)
	end
	local requirement = normalizeName(itemType:getVocationString())
	if requirement == "" then return true end

	local vocation = player:getVocation()
	local vocationName = normalizeName(vocation:getName())
	local baseVocation = vocation:getBase()
	local baseVocationName = baseVocation and normalizeName(baseVocation:getName()) or ""
	for _, name in ipairs({"knight", "paladin", "sorcerer", "druid", "illusionist", "monk"}) do
		if requirement:find(name, 1, true)
			and (vocationName:find(name, 1, true) or baseVocationName:find(name, 1, true)) then
			return true
		end
	end
	return false, string.format(
		"vocation=%s baseVocation=%s requirement=%s",
		vocationName, baseVocationName, requirement
	)
end

local function send(player, action, data)
	player:sendExtendedOpcode(OPCODE, json.encode(jsonSafeValue({action = action, data = data or {}})))
end

local function sendFullBatches(player, items)
	if #items == 0 then
		send(player, "full", {items = {}, complete = true, canChange = player:getZone() == ZONE_PROTECTION})
		return
	end

	local playerId = player:getId()
	local batchNumber = 0
	for first = 1, #items, FETCH_BATCH_SIZE do
		batchNumber = batchNumber + 1
		local chunk = {}
		for index = first, math.min(first + FETCH_BATCH_SIZE - 1, #items) do
			chunk[#chunk + 1] = items[index]
		end

		local payload = {
			items = chunk,
			complete = first + FETCH_BATCH_SIZE - 1 >= #items,
			canChange = player:getZone() == ZONE_PROTECTION
		}
		local delay = (batchNumber - 1) * FETCH_BATCH_DELAY_MS
		if delay == 0 then
			send(player, "full", payload)
		else
			addEvent(function()
				local target = Player(playerId)
				if target then
					send(target, "full", payload)
				end
			end, delay)
		end
	end
end

local function sendCatalogBatches(player, items)
	if #items == 0 then
		send(player, "catalog", {itemIds = {}, items = {}, complete = true})
		return
	end

	local playerId = player:getId()
	local batchNumber = 0
	for first = 1, #items, CATALOG_BATCH_SIZE do
		batchNumber = batchNumber + 1
		local chunk, itemIds = {}, {}
		for index = first, math.min(first + CATALOG_BATCH_SIZE - 1, #items) do
			chunk[#chunk + 1] = items[index]
			itemIds[#itemIds + 1] = items[index].itemId
		end
		local payload = {
			itemIds = itemIds,
			items = chunk,
			complete = first + CATALOG_BATCH_SIZE - 1 >= #items
		}
		local delay = (batchNumber - 1) * CATALOG_BATCH_DELAY_MS
		if delay == 0 then
			send(player, "catalog", payload)
		else
			addEvent(function()
				local target = Player(playerId)
				if target then send(target, "catalog", payload) end
			end, delay)
		end
	end
end

local function entryPayload(player, info)
	local entry = getEntry(player, info)
	local level, maxLevel = proficiencyLevel(info, entry.exp)
	local weaponType = info.itemType:getWeaponType()
	local marketCategory = weaponType == WEAPON_AXE and 17 or weaponType == WEAPON_CLUB and 18
		or weaponType == WEAPON_DISTANCE and 19 or weaponType == WEAPON_SWORD and 20
		or weaponType == WEAPON_WAND and 21 or weaponType == WEAPON_FIST and 27 or 0
	return {itemId = info.clientId, proficiencyId = info.profile.ProficiencyId, exp = entry.exp,
		perks = normalizePerks(entry.perks), level = level, maxLevel = maxLevel,
		maxExp = maxExperience(info), xpClass = xpClass(info.itemType),
		canChange = player:getZone() == ZONE_PROTECTION, name = info.itemType:getName(),
		marketCategory = marketCategory,
		requiredLevel = info.itemType:getMinReqLevel(), restrictVocation = vocationMask(info.itemType)}
end

local function sendItem(player, info, action)
	send(player, action or "item", entryPayload(player, info))
end

local function sendTooltipSummary(player, info)
	local entry = getEntry(player, info)
	local level, maxLevel = proficiencyLevel(info, entry.exp)
	send(player, "summary", {
		itemId = info.clientId,
		proficiencyId = info.profile.ProficiencyId,
		exp = entry.exp,
		level = level,
		maxLevel = maxLevel,
		maxExp = maxExperience(info),
		xpClass = xpClass(info.itemType)
	})
end

local function sendError(player, message, info)
	send(player, "error", {message = message, item = info and entryPayload(player, info) or nil})
end

local function equippedInfo(player)
	for _, slot in ipairs({CONST_SLOT_LEFT, CONST_SLOT_RIGHT}) do
		local item = player:getSlotItem(slot)
		if item then
			local itemType = ItemType(item:getId())
			if WEAPON_TYPES[itemType:getWeaponType()] then
				local profile = findProfile(itemType)
				if profile then return {clientId = itemType:getClientId(), serverId = item:getId(), itemType = itemType, profile = profile} end
			end
		end
	end
	return nil
end

local function sendTooltipSummaryBatches(player)
	local state = loadState(player)
	local items, seen = {}, {}
	local function append(info)
		if not info or seen[info.clientId] then return end
		seen[info.clientId] = true
		local entry = getEntry(player, info)
		local level, maxLevel = proficiencyLevel(info, entry.exp)
		items[#items + 1] = {
			itemId = info.clientId,
			proficiencyId = info.profile.ProficiencyId,
			exp = entry.exp,
			level = level,
			maxLevel = maxLevel,
			maxExp = maxExperience(info),
			xpClass = xpClass(info.itemType)
		}
	end

	append(equippedInfo(player))
	for clientId in pairs(state) do
		append(getItemInfo(clientId))
	end

	if #items == 0 then return end
	local playerId = player:getId()
	local batchNumber = 0
	for first = 1, #items, FETCH_BATCH_SIZE do
		batchNumber = batchNumber + 1
		local chunk = {}
		for index = first, math.min(first + FETCH_BATCH_SIZE - 1, #items) do
			chunk[#chunk + 1] = items[index]
		end
		local payload = {
			items = chunk,
			complete = first + FETCH_BATCH_SIZE - 1 >= #items
		}
		local delay = (batchNumber - 1) * FETCH_BATCH_DELAY_MS
		if delay == 0 then
			send(player, "summaries", payload)
		else
			addEvent(function()
				local target = Player(playerId)
				if target then send(target, "summaries", payload) end
			end, delay)
		end
	end
end

local function activePerks(player)
	local info = equippedInfo(player)
	if not info then return nil, nil, "no equipped proficiency weapon" end
	local meetsRequirements, inactiveReason = meetsWeaponRequirements(player, info.itemType)
	if not meetsRequirements then return nil, info, inactiveReason end
	local entry, perks = getEntry(player, info), {}
	for level, choice in pairs(entry.perks) do
		local row = info.profile.Levels[tonumber(level) + 1]
		local perk = row and row.Perks[tonumber(choice) + 1]
		if perk then perks[#perks + 1] = perk end
	end
	return perks, info, nil
end

function System.updatePlayerBonuses(player)
	if not player then return end
	player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, CONDITION_SUBID, true)
	local perks = activePerks(player) or {}
	local skillBonuses, rangeBonus, hitChanceBonus = {}, 0, 0
	for _, perk in ipairs(perks) do
		local perkType, value = tonumber(perk.Type), tonumber(perk.Value) or 0
		if perkType == 3 and SKILL_PARAMS[tonumber(perk.SkillId)] then
			local skillId = tonumber(perk.SkillId)
			skillBonuses[skillId] = (skillBonuses[skillId] or 0) + value
		elseif perkType == 23 then hitChanceBonus = hitChanceBonus + math.floor(value * 100 + 0.5)
		elseif perkType == 24 then rangeBonus = rangeBonus + math.floor(value) end
	end
	player:setProficiencyCombatBonuses(math.max(0, rangeBonus), math.max(0, hitChanceBonus))
	if next(skillBonuses) then
		local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
		condition:setParameter(CONDITION_PARAM_SUBID, CONDITION_SUBID)
		condition:setParameter(CONDITION_PARAM_TICKS, -1)
		for skillId, value in pairs(skillBonuses) do
			condition:setParameter(SKILL_PARAMS[skillId], math.floor(value))
		end
		player:addCondition(condition)
	end
end

local function getSkillValue(player, skill)
	if skill == SKILL_MAGLEVEL then return player:getMagicLevel() end
	return player:getSkillLevel(skill) or 0
end

local function getProfileSpellId(perk)
	return tonumber(perk and perk.SpellId)
end

function System.addExperience(player, clientId, amount)
	local info = getItemInfo(clientId)
	if not player or not info then return false end
	local entry, before = getEntry(player, info, true), 0
	before = unlockedLevels(info, entry.exp)
	entry.exp = math.min(maxExperience(info), entry.exp + math.max(0, math.floor(tonumber(amount) or 0)))
	local after = unlockedLevels(info, entry.exp)
	saveState(player)
	local payload = entryPayload(player, info)
	payload.hasUnnusedPerk = after > before or tableSize(entry.perks) < after
	send(player, "notify", payload)
	return true
end

function System.applyOutgoingCombat(player, primaryDamage, primaryType, secondaryDamage, secondaryType, target, origin)
	if not player or not player:isPlayer() or not target or not target:isMonster() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	local playerId = player:getId()
	if System.homingMissileDamage[playerId] then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	local perks = activePerks(player)
	if not perks then return primaryDamage, primaryType, secondaryDamage, secondaryType end
	local multiplier, flat, critChance, critExtra, manaLeech, lifeLeech, manaHit, lifeHit = 1, 0, 0, 0, 0, 0, 0, 0
	local homingMissile
	local auto = origin == ORIGIN_MELEE or origin == ORIGIN_RANGED or (ORIGIN_WAND and origin == ORIGIN_WAND)
	local spell = not auto and origin ~= ORIGIN_CONDITION
	local lastSpell = System.lastSpell and System.lastSpell[player:getId()]
	local spellId = spell and lastSpell and nowMs() - lastSpell.time <= 1500 and lastSpell.id or nil
	local rune = spell and not spellId
	local creatureInfo = Bestiary and Bestiary.creatureLookUpMap and Bestiary.creatureLookUpMap[target:getName()]
	for _, perk in ipairs(perks) do
		local t, value = tonumber(perk.Type), tonumber(perk.Value) or 0
		if t == 0 and auto then flat = flat + value
		elseif t == 4 and spell and (ELEMENTS[tonumber(perk.DamageType)] == primaryType or ELEMENTS[tonumber(perk.DamageType)] == secondaryType) then flat = flat + value
		elseif t == 5 and spellId and getProfileSpellId(perk) == spellId then
			local augment = tonumber(perk.AugmentType)
			if augment == 2 then multiplier = multiplier + value
			elseif augment == 14 then lifeLeech = lifeLeech + value
			elseif augment == 15 then manaLeech = manaLeech + value
			elseif augment == 16 then critExtra = critExtra + value
			elseif augment == 17 then critChance = critChance + value end
		elseif t == 6 and creatureInfo and Bestiary.bestiaryData[creatureInfo.categoryId]
			and normalizeName(Bestiary.bestiaryData[creatureInfo.categoryId].categoryName):find(normalizeName(perk.BestiaryName), 1, true) then multiplier = multiplier + value
		elseif t == 7 and creatureInfo and (creatureInfo.bosstiary or (target.getFiendishStack and target:getFiendishStack() > 0)) then multiplier = multiplier + value
		elseif t == 8 or (t == 10 and rune) or (t == 11 and auto)
			or (t == 9 and (ELEMENTS[tonumber(perk.ElementId)] == primaryType or ELEMENTS[tonumber(perk.ElementId)] == secondaryType)) then critChance = critChance + value
		elseif t == 12 or (t == 14 and rune) or (t == 15 and auto)
			or (t == 13 and (ELEMENTS[tonumber(perk.ElementId)] == primaryType or ELEMENTS[tonumber(perk.ElementId)] == secondaryType)) then critExtra = critExtra + value
		elseif t == 16 then manaLeech = manaLeech + value
		elseif t == 17 then lifeLeech = lifeLeech + value
		elseif t == 18 then manaHit = manaHit + value
		elseif t == 19 then lifeHit = lifeHit + value
		elseif t == 22 and auto and perk.Range then
			local p, q = player:getPosition(), target:getPosition()
			local distance = math.max(math.abs(p.x - q.x), math.abs(p.y - q.y))
			local requiredRange = tonumber(perk.Range)
			local matches = requiredRange and distance >= requiredRange
			if matches then flat = flat + value end
		elseif (t == 25 and auto) or (t == 26 and spell) then
			local skill = SKILLS[tonumber(perk.SkillId)]
			if skill then flat = flat + getSkillValue(player, skill) * value end
		elseif t == 28 and target:getHealth() / math.max(1, target:getMaxHealth()) > 0.95 then multiplier = multiplier + value
		elseif t == 29 and target:getHealth() / math.max(1, target:getMaxHealth()) < 0.30 then multiplier = multiplier + value
		elseif t == 30 and (primaryType == COMBAT_PHYSICALDAMAGE or secondaryType == COMBAT_PHYSICALDAMAGE) then multiplier = multiplier + value
		elseif t == 31 and (ELEMENTS[tonumber(perk.ElementId)] == primaryType or ELEMENTS[tonumber(perk.ElementId)] == secondaryType) then multiplier = multiplier + value
		elseif t == 32 and spellId and lastSpell and System.homingMissileRolls[playerId] ~= lastSpell.time then
			System.homingMissileRolls[playerId] = lastSpell.time
			local elementId = tonumber(perk.ElementId)
			local missile = HOMING_MISSILES[elementId]
			local chance = math.max(0, math.min(1, tonumber(perk.Chance) or 0))
			if missile and math.random() <= chance then
				homingMissile = {
					combatType = ELEMENTS[elementId],
					damage = math.max(0, math.floor(player:getLevel() * value + 0.5)),
					shoot = missile.shoot,
					effect = missile.effect
				}
			end
		end
	end
	if critChance > 0 and math.random() <= math.min(1, critChance) then multiplier = multiplier + 0.5 + critExtra end
	local flatApplied = false
	local function boost(damage)
		if damage == 0 then return 0 end
		local oneTimeFlat = flatApplied and 0 or flat
		flatApplied = true
		local value = math.floor(math.abs(damage) * multiplier + oneTimeFlat + 0.5)
		return damage < 0 and -value or value
	end
	primaryDamage, secondaryDamage = boost(primaryDamage), boost(secondaryDamage)
	local dealt = math.abs(primaryDamage) + math.abs(secondaryDamage)
	if dealt > 0 then
		if manaLeech > 0 then player:addMana(math.max(1, math.floor(dealt * manaLeech))) end
		if lifeLeech > 0 then player:addHealth("healing", math.max(1, math.floor(dealt * lifeLeech))) end
		if manaHit > 0 then player:addMana(math.floor(manaHit)) end
		if lifeHit > 0 then player:addHealth("healing", math.floor(lifeHit)) end
	end
	if homingMissile and homingMissile.damage > 0 then
		local targetId = target:getId()
		addEvent(function(sourceId, victimId, combatType, damage, shootEffect, hitEffect)
			local source, victim = Player(sourceId), Creature(victimId)
			if not source or not victim or victim:isRemoved() then return end

			source:getPosition():sendDistanceEffect(victim:getPosition(), shootEffect)
			System.homingMissileDamage[sourceId] = true
			local ok, err = pcall(
				doTargetCombatHealth,
				source,
				victim,
				combatType,
				-damage,
				-damage,
				hitEffect,
				ORIGIN_NONE
			)
			System.homingMissileDamage[sourceId] = nil
			if not ok then
				print("[WeaponProficiency] Homing missile failed: " .. tostring(err))
			end
		end, 0, playerId, targetId, homingMissile.combatType, homingMissile.damage,
			homingMissile.shoot, homingMissile.effect)
	end
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function System.applyIncomingCombat(player, primaryDamage, primaryType, secondaryDamage, secondaryType, attacker)
	if not player or not player:isPlayer() then return primaryDamage, primaryType, secondaryDamage, secondaryType end
	if (primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING) and attacker and attacker:isPlayer() then
		local sourcePerks = activePerks(attacker)
		local multiplier, flat = 1, 0
		local lastSpell = System.lastSpell and System.lastSpell[attacker:getId()]
		local spellId = lastSpell and nowMs() - lastSpell.time <= 1500 and lastSpell.id or nil
		for _, perk in ipairs(sourcePerks or {}) do
			local t, value = tonumber(perk.Type), tonumber(perk.Value) or 0
			if t == 5 and tonumber(perk.AugmentType) == 3 and spellId and getProfileSpellId(perk) == spellId then
				multiplier = multiplier + value
			elseif t == 27 then
				local skill = SKILLS[tonumber(perk.SkillId)]
				if skill then flat = flat + getSkillValue(attacker, skill) * value end
			end
		end
		local flatApplied = false
		local function boostHealing(value, combatType)
			if combatType ~= COMBAT_HEALING or value == 0 then return value end
			local oneTimeFlat = flatApplied and 0 or flat
			flatApplied = true
			local amount = math.floor(math.abs(value) * multiplier + oneTimeFlat + 0.5)
			return value < 0 and -amount or amount
		end
		return boostHealing(primaryDamage, primaryType), primaryType,
			boostHealing(secondaryDamage, secondaryType), secondaryType
	end
	local perks = activePerks(player)
	if not perks then return primaryDamage, primaryType, secondaryDamage, secondaryType end
	local reduction = 0
	for _, perk in ipairs(perks) do
		local t = tonumber(perk.Type)
		if t == 1 or t == 2 then reduction = reduction + (tonumber(perk.Value) or 0) end
	end
	local function reduce(damage)
		if damage == 0 or reduction <= 0 then return damage end
		local value = math.max(0, math.abs(damage) - reduction)
		return damage < 0 and -value or value
	end
	return reduce(primaryDamage), primaryType, reduce(secondaryDamage), secondaryType
end

function System.onSpellCast(player, spellName)
	System.lastSpell = System.lastSpell or {}
	local name = normalizeName(spellName)
	System.lastSpell[player:getId()] = {name = name, id = System.spellIds[name], time = nowMs()}
end

function System.getSpellCooldown(player, spellName, cooldown)
	local perks = activePerks(player)
	if not perks then return cooldown end
	local spellId = System.spellIds[normalizeName(spellName)]
	for _, perk in ipairs(perks) do
		if tonumber(perk.Type) == 5 and tonumber(perk.AugmentType) == 6 and spellId
			and getProfileSpellId(perk) == spellId then
			cooldown = math.max(0, cooldown - math.floor((tonumber(perk.Value) or 0) * 1000))
		end
	end
	return cooldown
end

local proficiencyPlayerHealth = CreatureEvent("WeaponProficiencyPlayerHealthChange")
function proficiencyPlayerHealth.onHealthChange(creature, attacker, primaryDamage, primaryType,
	secondaryDamage, secondaryType, origin)
	return System.applyIncomingCombat(
		creature, primaryDamage, primaryType, secondaryDamage, secondaryType, attacker, origin
	)
end
proficiencyPlayerHealth:register()

local proficiencyMonsterHealth = CreatureEvent("WeaponProficiencyMonsterHealthChange")
function proficiencyMonsterHealth.onHealthChange(creature, attacker, primaryDamage, primaryType,
	secondaryDamage, secondaryType, origin)
	return System.applyOutgoingCombat(
		attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, creature, origin
	)
end
proficiencyMonsterHealth:register()

local proficiencyTargetCombat = EventCallback
function proficiencyTargetCombat.onTargetCombat(creature, target)
	if creature and creature:isPlayer() and target and target:isMonster() then
		target:registerEvent("WeaponProficiencyMonsterHealthChange")
	end
	return RETURNVALUE_NOERROR
end
proficiencyTargetCombat:register(8)

local extended = CreatureEvent("WeaponProficiencyExtended")
function extended.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= OPCODE then return end
	local ok, payload = pcall(json.decode, buffer)
	if not ok or type(payload) ~= "table" then return end
	local action, data = payload.action, payload.data or {}
	if action == "config" then
		send(player, "config", {
			xp = XP,
			maxPerkLevels = MAX_PROFICIENCY_PERK_LEVELS
		})
	elseif action == "catalog" then
		local items, seen = {}, {}
		for _, clientId in pairs(type(data.itemIds) == "table" and data.itemIds or {}) do
			local info = getItemInfo(clientId)
			if info and not seen[info.clientId] then
				seen[info.clientId] = true
				items[#items + 1] = {
					itemId = info.clientId,
					requiredLevel = tonumber(info.itemType:getMinReqLevel()) or 0,
					restrictVocation = vocationMask(info.itemType)
				}
			end
		end
		sendCatalogBatches(player, items)
	elseif action == "fetch" then
		local items, seen = {}, {}
		for _, clientId in pairs(type(data.itemIds) == "table" and data.itemIds or {}) do
			local info = getItemInfo(clientId)
			if info and not seen[info.clientId] then seen[info.clientId] = true items[#items + 1] = entryPayload(player, info) end
		end
		sendFullBatches(player, items)
	elseif action == "inspect" then
		local info = getItemInfo(data.itemId)
		if info then sendItem(player, info) else sendError(player, "This item has no weapon proficiency profile.") end
	elseif action == "summary" then
		local info = getItemInfo(data.itemId)
		if info then sendTooltipSummary(player, info) end
	elseif action == "apply" or action == "reset" then
		local info = getItemInfo(data.itemId)
		if not info then sendError(player, "Invalid weapon proficiency item.") return end
		local entry, requested = getEntry(player, info, true), action == "reset" and {} or normalizePerks(data.perks)
		local unlocked = unlockedLevels(info, entry.exp)
		for level, choice in pairs(requested) do
			local index, row = tonumber(level), info.profile.Levels[tonumber(level) + 1]
			if index >= unlocked or not row or not row.Perks[choice + 1] then sendError(player, "One or more selected perks are not unlocked.", info) return end
		end
		if player:getZone() ~= ZONE_PROTECTION then
			for level, oldChoice in pairs(entry.perks) do
				if requested[level] ~= oldChoice then sendError(player, "Existing perks can only be changed or removed in a protection zone.", info) return end
			end
		end
		entry.perks = requested
		saveState(player)
		System.updatePlayerBonuses(player)
		sendItem(player, info)
	end
end
extended:type("extendedopcode")
extended:register()

local login = CreatureEvent("WeaponProficiencyLogin")
function login.onLogin(player)
	player:registerEvent("WeaponProficiencyExtended")
	player:registerEvent("WeaponProficiencyLogout")
	player:registerEvent("WeaponProficiencyKill")
	player:registerEvent("WeaponProficiencyPlayerHealthChange")
	loadState(player)
	System.updatePlayerBonuses(player)
	local playerId = player:getId()
	addEvent(function()
		local target = Player(playerId)
		if not target then return end
		sendTooltipSummaryBatches(target)
	end, 1500)
	return true
end
login:type("login")
login:register()

local logout = CreatureEvent("WeaponProficiencyLogout")
function logout.onLogout(player)
	saveState(player)
	System.players[player:getGuid()] = nil
	if System.lastSpell then System.lastSpell[player:getId()] = nil end
	return true
end
logout:type("logout")
logout:register()

local kill = CreatureEvent("WeaponProficiencyKill")
function kill.onKill(player, target)
	if not target or not target:isMonster() or target:getMaster() then return true end
	local creatureInfo = Bestiary and Bestiary.creatureLookUpMap and Bestiary.creatureLookUpMap[target:getName()]
	if not creatureInfo then return true end
	local killId = target:getId()
	if System.processedKills[killId] then return true end
	System.processedKills[killId] = os.time()
	local reward = BOSS_XP[tostring(creatureInfo.bosstiary or ""):lower()] or KILL_XP[tonumber(creatureInfo.difficulty)]
	if not reward then return true end
	local stack = target.getFiendishStack and target:getFiendishStack() or 0
	if stack > 0 then reward = math.floor(reward * (1 + stack * 0.1)) end
	for creatureId in pairs(target:getDamageMap() or {}) do
		local contributor = Player(creatureId)
		if not contributor then
			local source = Creature(creatureId)
			local master = source and source:getMaster()
			if master and master:isPlayer() then contributor = master end
		end
		if contributor then
			local info = equippedInfo(contributor)
			if info then
				for _, perk in ipairs(activePerks(contributor) or {}) do
					if tonumber(perk.Type) == 20 then contributor:addMana(math.floor(tonumber(perk.Value) or 0))
					elseif tonumber(perk.Type) == 21 then contributor:addHealth("healing", math.floor(tonumber(perk.Value) or 0)) end
				end
				System.addExperience(contributor, info.clientId, reward)
			end
		end
	end
	addEvent(function(id) System.processedKills[id] = nil end, 60000, killId)
	return true
end
kill:register()

readProfiles()
