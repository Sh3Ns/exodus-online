print(">> Bestiary & Bosses System Loading")

Bestiary = Bestiary or {}
Bestiary.unlockedCharms = Bestiary.unlockedCharms or {}
Bestiary.playerTrackedCreatures = Bestiary.playerTrackedCreatures or {}
Bestiary.incomingOpcodeChunks = Bestiary.incomingOpcodeChunks or {}

local BESTIARY_OPCODE_CHUNK_SIZE = 7900

function Bestiary.sendJson(player, payload)
	local encoded = type(payload) == "string" and payload or json.encode(payload)
	if #encoded <= BESTIARY_OPCODE_CHUNK_SIZE then
		player:sendExtendedOpcode(BESTIARY_OPCODE, encoded)
		return
	end

	local index = 1
	local length = #encoded
	while index <= length do
		local chunk = encoded:sub(index, index + BESTIARY_OPCODE_CHUNK_SIZE - 1)
		local prefix = "P"
		if index == 1 then
			prefix = "S"
		elseif index + BESTIARY_OPCODE_CHUNK_SIZE > length then
			prefix = "E"
		end

		player:sendExtendedOpcode(BESTIARY_OPCODE, prefix .. chunk)
		index = index + BESTIARY_OPCODE_CHUNK_SIZE
	end
end

function Bestiary.decodeIncomingJson(player, buffer)
	local playerId = player:getGuid()
	local prefix = buffer:sub(1, 1)

	if prefix == "S" then
		Bestiary.incomingOpcodeChunks[playerId] = buffer:sub(2)
		return nil
	elseif prefix == "P" then
		Bestiary.incomingOpcodeChunks[playerId] = (Bestiary.incomingOpcodeChunks[playerId] or "") .. buffer:sub(2)
		return nil
	elseif prefix == "E" then
		buffer = (Bestiary.incomingOpcodeChunks[playerId] or "") .. buffer:sub(2)
		Bestiary.incomingOpcodeChunks[playerId] = nil
	end

	local ok, data = pcall(json.decode, buffer)
	if not ok or type(data) ~= "table" then
		return nil
	end

	return data
end

local creatureEvent = CreatureEvent("Bestiary_onExtendedOpcode")
function creatureEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode == BESTIARY_OPCODE then
		if not Bestiary.playerUnlockedCreatureCount or not Bestiary.playerBonuses then
			Bestiary.setupBestiaryData()
		end
		if not Bestiary.unlockedCharms then
			Bestiary.loadUnlockedCharms()
		end

		local data = Bestiary.decodeIncomingJson(player, buffer)
		if not data then
			return true
		end
		local topic = data.topic
		if topic == "base-data-request" then
			Bestiary.sendBaseData(player)
		elseif topic == "category-creatures-request" then
			Bestiary.sendCategoryCreaturesList(player, data.categoryId, data.page)
		elseif topic == "creature-info-request" then
			Bestiary.sendCreatureInfo(player, data.creatureId, data.categoryId)
		elseif topic == "category-progress-request" then
			Bestiary.sendCategoryProgress(player, data.categoryId)
		elseif topic == "total-bonuses-request" then
			Bestiary.sendTotalBonuses(player)
		elseif topic == "get-tracked-creatures" then
			Bestiary.sendTrackedCreatures(player)
		elseif topic == "get-unlocked-creatures" then
			Bestiary.sendUnlockedCreatures(player)
		elseif topic == "get-charmsData" then
			Bestiary.sendCharmData(player)
		elseif topic == "add-tracked-creature" then
			Bestiary.addTrackedCreature(player, data.creatureName)
		elseif topic == "remove-tracked-creature" then
			Bestiary.removeTrackedCreature(player, data.creatureName)
		elseif topic == "unlock-charm" then
			Bestiary.unlockCharmAction(player, data.charmId)
		elseif topic == "select-charm-monster" then
			Bestiary.selectCharmMonsterAction(player, data.charmId, data.monster)
		elseif topic == "remove-charm-monster" then
			Bestiary.removeCharmMonsterAction(player, data.charmId)
		elseif topic == "creature-loot-request" then
  			Bestiary.sendCreatureLoot(player, data.creatureId, data.page)
		end
	end
end
creatureEvent:register()

creatureEvent = CreatureEvent("Bestiary_onLogin")
function creatureEvent.onLogin(player)
	if not Bestiary.playerUnlockedCreatureCount or not Bestiary.playerBonuses then
		Bestiary.setupBestiaryData()
	end
	if not Bestiary.unlockedCharms then
		Bestiary.loadUnlockedCharms()
	end
	Bestiary.cachePlayerBonuses(player)
	Bestiary.cachePlayerUnlockedCreaturesCount(player)
	Bestiary.cachePlayerUnlockedCreatureNames(player)
	Bestiary.cachePlayerTrackedCreatures(player)
	Bestiary.applyBonuses(player)
	player:registerEvent("Bestiary_onKill")
	player:registerEvent("Bestiary_onExtendedOpcode")
	player:registerEvent("Bestiary_onKillCharmHandler")
	player:registerEvent("Bestiary_onPlayerManaChange")
	player:registerEvent("Bestiary_onPlayerHealthChange")
	return true
end
creatureEvent:register()

local function clearPlayerBestiaryCache(player)
	local playerGuid = player:getGuid()

	if Bestiary.playerBonuses then
		Bestiary.playerBonuses[playerGuid] = nil
	end
	if Bestiary.playerUnlockedCreatureCount then
		Bestiary.playerUnlockedCreatureCount[playerGuid] = nil
	end
	if Bestiary.playerUnlockedCreatureNames then
		Bestiary.playerUnlockedCreatureNames[playerGuid] = nil
	end
	if Bestiary.playerTrackedCreatures then
		Bestiary.playerTrackedCreatures[playerGuid] = nil
	end
	if Bestiary.incomingOpcodeChunks then
		Bestiary.incomingOpcodeChunks[playerGuid] = nil
	end
end

creatureEvent = CreatureEvent("Bestiary_onLogout")
function creatureEvent.onLogout(player)
	clearPlayerBestiaryCache(player)
	return true
end
creatureEvent:type("logout")
creatureEvent:register()

local globalEvent = GlobalEvent("Bestiary_onStartup")
function globalEvent.onStartup()
	Bestiary.setupBestiaryData()
	Bestiary.loadUnlockedCharms()
	return true
end
globalEvent:register()


local creatureEvent = CreatureEvent("Bestiary_onKill")
function creatureEvent.onKill(player, target)
	if not (target and target:isMonster()) then
		return true
	end

	local creatureInfo = Bestiary.creatureLookUpMap[target:getName()]
	if not creatureInfo then
		return true
	end

	local party = player:getParty()
	local shareAll = BESTIARY_PARTY_KILL_DISTRIBUIT_LOGIC
	local maxShare = 5
	local function credit(p)
        Bestiary.addBestiaryKills(p, creatureInfo)
        if type(_G.TaskBoard) == "table" and type(_G.TaskBoard.rollDoubleBestiaryProgress) == "function"
			and _G.TaskBoard.rollDoubleBestiaryProgress(p, target) then
			Bestiary.addBestiaryKills(p, creatureInfo)
		end
        Bestiary.sendTrackedCreatures(p)
    end
	if party then
		local credited = 0

		credit(party:getLeader() or player)
		credited = credited + 1

		for _, member in ipairs(party:getMembers()) do
			if credited >= maxShare then break end
			credit(member)
			credited = credited + 1
		end
	else
		credit(player)
	end

	return true
end
creatureEvent:register()

local ec = EventCallback
function ec.onSpawn(monster, position, startup, artificial)
	monster:registerEvent('Bestiary_onMonsterHealthChange')
	return true
end
ec:register()

------ Initialization Functions

function Bestiary.setupBestiaryData()
	Bestiary.playerUnlockedCreatureCount = {}
	Bestiary.playerUnlockedCreatureNames = {}
	Bestiary.playerBonuses = {}

	for categoryID, categoryData in pairs(Bestiary.bestiaryData) do
		categoryData.totalCreatures = 0

		for creatureIndex, creatureData in ipairs(categoryData.creatures) do
			creatureData.id = creatureData.raceId

			local monsterType = MonsterType(creatureData.name)
			if monsterType then
				Bestiary.setOutfit(creatureData, monsterType)
				Bestiary.setStats(creatureData, monsterType)
				Bestiary.setDefenses(creatureData, monsterType)
				Bestiary.setLoot(creatureData, monsterType)
			end

			categoryData.totalCreatures = categoryData.totalCreatures + 1
		end
	end

	Bestiary.createLookupMap()
end

function Bestiary.sendCreatureLoot(player, creatureId, page)
  page = tonumber(page) or 1

  local PAGE_SIZE = 15
  local HARD_CAP  = 1000

  local creatureData
	for _, category in pairs(Bestiary.bestiaryData) do
		for _, creature in ipairs(category.creatures) do
			if creature.id == creatureId then
				creatureData = creature
				break
			end
		end
		if creatureData then break end
	end

  if not creatureData or not creatureData.loot then
    return
  end

  local lootList   = creatureData.loot
  local totalItems = math.min(#lootList, HARD_CAP)
  local totalPages = math.max(1, math.ceil(totalItems / PAGE_SIZE))

  page = math.max(1, math.min(page, totalPages))

  local startIndex = (page - 1) * PAGE_SIZE + 1
  local endIndex   = math.min(startIndex + PAGE_SIZE - 1, totalItems)

  local lootPage = {}

  for i = startIndex, endIndex do
    local loot = lootList[i]
    if loot then
      table.insert(lootPage, {
        id  = loot.itemId,
        c   = tonumber(loot.chance) or 0,
        max = tonumber(loot.maxCount) or 1
      })
    end
  end

  Bestiary.sendJson(player, {
    topic      = "creature-loot",
    creatureId = creatureId,
    page       = page,
    totalPages = totalPages,
    loot       = lootPage
  })
end


function Bestiary.createLookupMap()
	Bestiary.raceIdToNameMap = {}
	Bestiary.creatureLookUpMap = {}
	for categoryId, categoryData in pairs(Bestiary.bestiaryData) do
		for _, creatureData in ipairs(categoryData.creatures) do
			Bestiary.creatureLookUpMap[creatureData.name] = {
				name = creatureData.name,
				raceId = creatureData.raceId,
				requiredKills = creatureData.requiredKills,
				charmPoints = creatureData.charmPoints,
				difficulty = creatureData.difficulty or 0,
				occurrence = creatureData.occurrence or 0,
				bosstiary = creatureData.bosstiary,
				bonuses = creatureData.bonuses,
				outfit = creatureData.outfit,
				categoryId = categoryId,
				id = creatureData.id
			}
			Bestiary.raceIdToNameMap[creatureData.raceId] = creatureData.name
		end
	end
end

function Bestiary.loadUnlockedCharms()
	Bestiary.unlockedCharms = {}
	local sql = "SELECT `player_id`, `charm_id`, `monster_name` FROM `player_charms`;"
	local resultId = db.storeQuery(sql)
	if resultId then
		repeat
			local playerId = result.getNumber(resultId, "player_id")
			local charmId = result.getString(resultId, "charm_id")
			local monsterName = result.getString(resultId, "monster_name")

			if not Bestiary.unlockedCharms[playerId] then
				Bestiary.unlockedCharms[playerId] = {}
			end

			if not Bestiary.unlockedCharms[playerId][charmId] then
				Bestiary.unlockedCharms[playerId][charmId] = {}
			end

			if monsterName ~= "" then
				local monsterType = MonsterType(monsterName)
				if monsterType then
					Bestiary.unlockedCharms[playerId][charmId]["monster"] = monsterName
					Bestiary.unlockedCharms[playerId][charmId]["outfit"] = Bestiary.getOutfit(monsterType)
				end
			end
		until not result.next(resultId)

		result.free(resultId)
	end
end

function Bestiary.cachePlayerTrackedCreatures(player)
	local playerId = player:getGuid()
	Bestiary.playerTrackedCreatures[playerId] = {}

	local resultId = db.storeQuery("SELECT creature_name FROM player_tracked_creatures WHERE player_id = " .. playerId)

	if resultId then
		repeat
			local creatureName = result.getDataString(resultId, "creature_name")
			table.insert(Bestiary.playerTrackedCreatures[playerId], creatureName)
		until not result.next(resultId)
		result.free(resultId)
	end
end

function Bestiary.cachePlayerBonuses(player)
	local playerGuid = player:getGuid()
	local playerBonuses = {}

	for categoryID, categoryData in pairs(Bestiary.bestiaryData) do
		for _, creatureData in ipairs(categoryData.creatures) do
			local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureData.raceId
			local kills = player:getStorageValue(killsStorageId)

			if kills >= creatureData.requiredKills then
				for _, bonus in ipairs(creatureData.bonuses or {}) do
					if playerBonuses[bonus.name] then
						playerBonuses[bonus.name] = playerBonuses[bonus.name] + bonus.value
					else
						playerBonuses[bonus.name] = bonus.value
					end
				end
			end
		end
	end

	Bestiary.playerBonuses[playerGuid] = {}

	for name, value in pairs(playerBonuses) do
		table.insert(Bestiary.playerBonuses[playerGuid], {name = name, value = value})
	end
end

function Bestiary.cachePlayerUnlockedCreaturesCount(player)
	local playerGuid = player:getGuid()
	Bestiary.playerUnlockedCreatureCount[playerGuid] = {}

	for categoryID, categoryData in pairs(Bestiary.bestiaryData) do
		local unlockedCount = 0

		for _, creatureData in ipairs(categoryData.creatures) do
			local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureData.raceId
			local kills = player:getStorageValue(killsStorageId)

			if kills >= creatureData.requiredKills then
				unlockedCount = unlockedCount + 1
			end
		end

		Bestiary.playerUnlockedCreatureCount[playerGuid][categoryID] = unlockedCount
	end
end

function Bestiary.cachePlayerUnlockedCreatureNames(player)
	local playerGuid = player:getGuid()
	Bestiary.playerUnlockedCreatureNames[playerGuid] = {}

	for _, categoryData in pairs(Bestiary.bestiaryData) do
		for _, creatureData in ipairs(categoryData.creatures) do
			local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureData.raceId
			if player:getStorageValue(killsStorageId) >= creatureData.requiredKills then
				local info   = Bestiary.creatureLookUpMap[creatureData.name]
				local outfit = info and info.outfit or {}
				Bestiary.playerUnlockedCreatureNames[playerGuid][creatureData.name] = outfit
			end
		end
	end
end

------ Data Sending Functions

function Bestiary.sendBaseData(player)
	local playerGuid = player:getGuid()
	local categories = {}

	for categoryID, categoryData in pairs(Bestiary.bestiaryData) do
		local unlocked =
			Bestiary.playerUnlockedCreatureCount[playerGuid] and Bestiary.playerUnlockedCreatureCount[playerGuid][categoryID] or 0

		table.insert(
			categories,
			{
				id = categoryID,
				totalCreatures = categoryData.totalCreatures,
				unlockedCreatures = unlocked
			}
		)
	end

	local response = {
		topic = "base-data-response",
		categories = categories,
		gold = player:getTotalMoney(),
		charmPoints = player:getStorageValue(BESTIARY_CHARMS_POINTS_STORAGE)
	}
	Bestiary.sendJson(player, response)
end

function Bestiary.sendPointsUpdate(player)
	local message = {
		topic = "points-update",
		gold = player:getTotalMoney(),
		charmPoints = player:getStorageValue(BESTIARY_CHARMS_POINTS_STORAGE)
	}
	Bestiary.sendJson(player, message)
end

function Bestiary.sendTrackedCreatures(player)
	local playerId = player:getGuid()
	local trackedCreatures = Bestiary.playerTrackedCreatures[playerId] or {}

	local trackedCreatureData = {}
	for _, creatureName in ipairs(trackedCreatures) do
		local creatureInfo = Bestiary.creatureLookUpMap[creatureName]
		if creatureInfo then
			local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureInfo.raceId
			local kills = player:getStorageValue(killsStorageId)
			if kills == -1 then
				kills = 0
			end

			local creatureData = {
				name = creatureName,
				outfit = creatureInfo.outfit,
				requiredKills = creatureInfo.requiredKills,
				kills = kills,
				categoryId = creatureInfo.categoryId,
				id = creatureInfo.id
			}

			table.insert(trackedCreatureData, creatureData)
		end
	end

	local response = {
		topic = "tracked-creatures-list",
		trackedCreatures = trackedCreatureData
	}
	Bestiary.sendJson(player, response)
end

function Bestiary.sendCategoryCreaturesList(player, categoryId, page)
  local category = Bestiary.bestiaryData[categoryId]
  if not category then return end

  page = page or 1
  local limit = BESTIARY_FETCH_LIMIT
  local startIndex = (page - 1) * limit + 1
  local endIndex = math.min(startIndex + limit - 1, #category.creatures)

  local creatures = {}

  for i = startIndex, endIndex do
    local c = category.creatures[i]
    if c then
      table.insert(creatures, {
        id = c.id,
        name = c.name,
        raceId = c.raceId,
        requiredKills = c.requiredKills,
        difficulty = c.difficulty,
        occurrence = c.occurrence,
		bosstiary = c.bosstiary,
        outfit = c.outfit,
        categoryId = categoryId
      })
    end
  end

  Bestiary.sendJson(player, {
    topic = "category-creatures",
    categoryId = categoryId,
    page = page,
    totalPages = math.ceil(#category.creatures / limit),
    creatures = creatures
  })
end

function Bestiary.sendCreatureInfo(player, creatureId, categoryId)
	if not categoryId or not Bestiary.bestiaryData[categoryId] then
		return
	end

	local category = Bestiary.bestiaryData[categoryId]
	local creatureData = nil

	for _, creature in ipairs(category.creatures) do
		if creature.id == creatureId then
			creatureData = creature
			break
		end
	end

	if not creatureData then
		return
	end

	local bonuses = Bestiary.getCreatureBonuses(creatureData)

	local response = {
		topic = "creature-info-response",
		creatureId = creatureId,
		categoryId = categoryId,
		stats = creatureData.stats or {},
		defenses = creatureData.defenses or {},
		bonuses = bonuses
		}
	Bestiary.sendJson(player, response)
end

function Bestiary.sendCategoryProgress(player, categoryId)
	if not categoryId or not Bestiary.bestiaryData[categoryId] then
		return
	end

	local category = Bestiary.bestiaryData[categoryId]
	local creatureProgress = {}

	for _, creatureData in ipairs(category.creatures) do
		local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureData.raceId
		local kills = player:getStorageValue(killsStorageId)

		if kills == -1 then
			kills = 0
		end

		table.insert(
			creatureProgress,
			{
				id = creatureData.id,
				kills = kills
			}
		)
	end

	local response = {
		topic = "category-progress-response",
		categoryId = categoryId,
		progress = creatureProgress
	}
	Bestiary.sendJson(player, response)
end

function Bestiary.sendTotalBonuses(player)
	local playerGuid = player:getGuid()
	local response = {
		topic = "total-bonuses-response",
		bonuses = Bestiary.playerBonuses[playerGuid]
	}
	Bestiary.sendJson(player, response)
end

function Bestiary.sendUnlockedCreatures(player)
	local playerId = player:getGuid()
	if not Bestiary.playerUnlockedCreatureNames[playerId] then
		Bestiary.cachePlayerUnlockedCreatureNames(player)
	end

	local response = {
		topic = "unlocked-creatures-list",
		unlockedCreatures = Bestiary.playerUnlockedCreatureNames[playerId]
	}
	Bestiary.sendJson(player, response)
end

function Bestiary.sendError(player, msg)
	Bestiary.sendJson(player, {
		topic = "error",
		message = msg
	})
end

------ Player Action Functions

function Bestiary.addTrackedCreature(player, creatureName)
	local playerId = player:getGuid()
	if not Bestiary.playerTrackedCreatures[playerId] then
		Bestiary.cachePlayerTrackedCreatures(player)
	end

	local trackedCreatures = Bestiary.playerTrackedCreatures[playerId]

	for _, trackedCreatureName in ipairs(trackedCreatures) do
		if trackedCreatureName == creatureName then
			return
		end
	end

	if #trackedCreatures >= BESTIARY_MAX_TRACKED_CREATURES then
		return
	end

	table.insert(trackedCreatures, creatureName)
	db.query(
		"INSERT INTO `player_tracked_creatures` (`player_id`, `creature_name`) VALUES (" ..
			playerId .. ", " .. db.escapeString(creatureName) .. ")"
	)

	local creatureInfo = Bestiary.creatureLookUpMap[creatureName]
	if creatureInfo then
		local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureInfo.raceId
		local kills = player:getStorageValue(killsStorageId)
		if kills == -1 then
			kills = 0
		end

		local response = {
			topic = "tracked-creature-added",
			creatureName = creatureName,
			outfit = creatureInfo.outfit,
			requiredKills = creatureInfo.requiredKills,
			kills = kills,
			categoryId = creatureInfo.categoryId,
			id = creatureInfo.id
		}
		Bestiary.sendJson(player, response)
	end
end

function Bestiary.removeTrackedCreature(player, creatureName)
	local playerId = player:getGuid()
	if not Bestiary.playerTrackedCreatures[playerId] then
		Bestiary.cachePlayerTrackedCreatures(player)
	end

	local trackedCreatures = Bestiary.playerTrackedCreatures[playerId]

	for index, trackedCreatureName in ipairs(trackedCreatures) do
		if trackedCreatureName == creatureName then
			table.remove(trackedCreatures, index)
			break
		end
	end

	db.query(
		"DELETE FROM `player_tracked_creatures` WHERE `player_id` = " ..
			playerId .. " AND `creature_name` = " .. db.escapeString(creatureName)
	)

	local response = {
		topic = "tracked-creature-removed",
		creatureName = creatureName
	}
	Bestiary.sendJson(player, response)
end

function Bestiary.addBestiaryKills(player, creatureInfo)
	local storageId = BESTIARY_KILLS_STORAGE_BASE + creatureInfo.raceId

	local kills = player:getStorageValue(storageId)
	if kills < 0 then
		kills = 0
	end

	kills = kills + 1
	player:setStorageValue(storageId, kills)

	if kills == creatureInfo.requiredKills then
		Bestiary.cachePlayerBonuses(player)
		Bestiary.cachePlayerUnlockedCreaturesCount(player)
		Bestiary.applyBonuses(player)
		Bestiary.cachePlayerUnlockedCreatureNames(player)
		Bestiary.sendUnlockedCreatures(player)

		local points = player:getStorageValue(BESTIARY_CHARMS_POINTS_STORAGE)
		if points < 0 then points = 0 end
		player:setStorageValue(
			BESTIARY_CHARMS_POINTS_STORAGE,
			points + creatureInfo.charmPoints
		)
	end

	if kills <= creatureInfo.requiredKills then
		Bestiary.notifyTrackedCreatureKill(player, creatureInfo)
	end
end

function Bestiary.notifyTrackedCreatureKill(player, creatureInfo)
	local playerId = player:getGuid()
	local trackedCreatures = Bestiary.playerTrackedCreatures[playerId]
	if not trackedCreatures then
		return
	end

	local creatureName = creatureInfo.name

	for _, trackedCreatureName in ipairs(trackedCreatures) do
		if trackedCreatureName == creatureName then
			local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureInfo.raceId
			local kills = player:getStorageValue(killsStorageId)
			if kills == -1 then
				kills = 0
			end

			local response = {
				topic = "tracked-creature-kill",
				creatureName = creatureName,
				kills = kills
			}
			Bestiary.sendJson(player, response)
			break
		end
	end
end

------ Charms Functions (non-effect processing)

function Bestiary.sendCharmData(player)
	local playerId = player:getGuid()

	local response = {
		topic = "charmData-reply",
		charmData = Bestiary.unlockedCharms[playerId]
	}
	Bestiary.sendJson(player, response)
end

function Bestiary.unlockCharmAction(player, charmId)
	charmId = tostring(charmId)
	local charm = Bestiary.charmsInfo[charmId]
	if not charm then
		return Bestiary.sendError(player, "Charm not found")
	end
	local playerGuid = player:getGuid()
	Bestiary.unlockedCharms[playerGuid] = Bestiary.unlockedCharms[playerGuid] or {}

	if Bestiary.unlockedCharms[playerGuid][charmId] then
		return Bestiary.sendError(player, "You already own this charm")
	end
	local price = charm.pointsPrice
	local points = player:getStorageValue(BESTIARY_CHARMS_POINTS_STORAGE)
	if price > points then
		return Bestiary.sendError(player, "Not enough charm points")
	end

	Bestiary.unlockedCharms[playerGuid][charmId] = {}
	db.query(Bestiary.insertCharmSql:format(playerGuid, charmId))
	player:setStorageValue(BESTIARY_CHARMS_POINTS_STORAGE, points - price)

	Bestiary.sendPointsUpdate(player)
	Bestiary.sendCharmData(player)
	Bestiary.sendJson(player, {topic = "charm-status-update", charmId = charmId})
end

function Bestiary.removeCharmMonsterAction(player, charmId)
	charmId = tostring(charmId)
	local playerGuid = player:getGuid()
	local charm = Bestiary.charmsInfo[charmId]
	if not charm then
		return Bestiary.sendError(player, "Charm not found")
	end
	local uc = Bestiary.unlockedCharms[playerGuid] and Bestiary.unlockedCharms[playerGuid][charmId]
	if not uc then
		return Bestiary.sendError(player, "Charm not unlocked")
	end
	if not uc.monster then
		return Bestiary.sendError(player, "No monster assigned")
	end
	local removeFee = player:getLevel() * 100
	if player:getTotalMoney() < removeFee then
		return Bestiary.sendError(player, "Not enough money. Removing a charm costs your level multiplied by 100 gold.")
	end
	player:removeTotalMoney(removeFee)
	player:popupFYI("Charm monster removed. You have paid " .. removeFee .. " gold.")

	local playerGuid = player:getGuid()
	Bestiary.unlockedCharms[playerGuid][charmId] = {}
	db.query(Bestiary.deleteCharmMonsterSql:format(playerGuid, charmId))

	Bestiary.sendPointsUpdate(player)
	Bestiary.sendCharmData(player)
	Bestiary.sendJson(player, {topic = "charm-status-update", charmId = charmId})
end

function Bestiary.selectCharmMonsterAction(player, charmId, monsterName)
	charmId = tostring(charmId)
	local playerGuid = player:getGuid()
	local charm = Bestiary.charmsInfo[charmId]
	if not charm then
		return Bestiary.sendError(player, "Charm not found")
	end
	local uc = Bestiary.unlockedCharms[playerGuid] and Bestiary.unlockedCharms[playerGuid][charmId]
	if not uc then
		return Bestiary.sendError(player, "Charm not unlocked")
	end
	if uc.monster then
		return Bestiary.sendError(player, "Remove current monster first")
	end

	if not Bestiary.playerUnlockedCreatureNames[playerGuid][monsterName] then
		return Bestiary.sendError(player, "You haven't unlocked that creature")
	end
	for _, c in pairs(Bestiary.unlockedCharms[playerGuid]) do
		if c.monster == monsterName then
			return Bestiary.sendError(player, "That monster is already in use")
		end
	end

	Bestiary.unlockedCharms[playerGuid][charmId].monster = monsterName
	local creatureInfo = Bestiary.creatureLookUpMap[monsterName]
	local outfit = creatureInfo and creatureInfo.outfit or {}
	Bestiary.unlockedCharms[playerGuid][charmId].outfit  = outfit
	db.query(Bestiary.saveCharmMonsterSql:format(monsterName, playerGuid, charmId))

	Bestiary.sendPointsUpdate(player)
	Bestiary.sendCharmData(player)
	Bestiary.sendJson(player, {topic = "charm-status-update", charmId = charmId})
end

function Bestiary.getUnlockedCharmId(playerGuid, monsterName)
    local uc = Bestiary.unlockedCharms
    if not uc or not monsterName then
        return nil
    end

    local pCharms = uc[playerGuid]
    if not pCharms then
        return nil
    end

    local target = monsterName:lower()
    for id, data in pairs(pCharms) do
        local assigned = data.monster and data.monster:lower()
        if assigned == target then
            return id
        end
    end
    return nil
end

------ Bonus Application Functions
function Bestiary.clearBestiaryConditions(player)
  for subId = BESTIARY_CONDITIONS_SUBID_START,
              BESTIARY_CONDITIONS_SUBID_START + 500 do
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, subId)
  end
end

function Bestiary.applyBonuses(player)
	local healthBefore = player:getHealth()
	Bestiary.clearBestiaryConditions(player)
	local playerGuid = player:getGuid()
	local totalStorages = {}
	local conditionsToAdd = {}

	for categoryID, categoryData in pairs(Bestiary.bestiaryData) do
		for _, creatureData in ipairs(categoryData.creatures) do
			local killsStorageId = BESTIARY_KILLS_STORAGE_BASE + creatureData.raceId
			local kills = player:getStorageValue(killsStorageId)

			if kills >= creatureData.requiredKills then
				for _, bonus in ipairs(creatureData.bonuses or {}) do
					if bonus.type == "condition" then
						table.insert(conditionsToAdd, bonus)
					elseif bonus.type == "storage" then
						local storageId = bonus.storage
						if totalStorages[storageId] then
							totalStorages[storageId] = totalStorages[storageId] + bonus.value
						else
							totalStorages[storageId] = bonus.value
						end
					end
				end
			end
		end
	end

	local subIdCounter = BESTIARY_CONDITIONS_SUBID_START
	for _, bonus in ipairs(conditionsToAdd) do
		local condition = Condition(bonus.conditionType)
		if condition and bonus.param then
			condition:setParameter(CONDITION_PARAM_TICKS, -1)
			condition:setParameter(CONDITION_PARAM_SUBID, subIdCounter)
			condition:setParameter(bonus.param, bonus.value)
			player:addCondition(condition)
			subIdCounter = subIdCounter + 1
		end
	end

	for storageId, totalValue in pairs(totalStorages) do
		player:setStorageValue(storageId, totalValue)
	end

	local targetHealth = math.min(healthBefore, player:getMaxHealth())
	if targetHealth > player:getHealth() then
		player:addHealth(targetHealth - player:getHealth())
	end
end

------ Creature Data Processing Functions

function Bestiary.setOutfit(creatureData, monsterType)
	creatureData.outfit = Bestiary.getOutfit(monsterType)
end

function Bestiary.getOutfit(monsterType)
	local outfitData = {}
	for key, value in pairs(monsterType:getOutfit()) do
		if key == "lookTypeEx" and value > 0 then
			outfitData[key] = ItemType(value):getClientId()
		else
			outfitData[key] = value
		end
	end
	return outfitData
end

function Bestiary.setStats(creatureData, monsterType)
	creatureData.stats = {
		health = monsterType:maxHealth(),
		experience = monsterType:experience(),
		speed = monsterType:baseSpeed(),
		armor = monsterType:armor(),
		charmPoints = creatureData.charmPoints,
		difficulty = creatureData.difficulty or 0,
		occurrence = creatureData.occurrence or 0
	}
end

function Bestiary.setDefenses(creatureData, monsterType)
	creatureData.defenses = {}
	local elementsList = monsterType:getElementList()
	local combatImmunities = monsterType:combatImmunities()
	for elementId, elementName in pairs(Bestiary.elementsNames) do
		local elementValue = elementsList[elementId]
		if elementValue then
			creatureData.defenses[elementName] = elementValue
		end

		if bit.band(combatImmunities, elementId) ~= 0 then
			creatureData.defenses[elementName] = 0
		end
	end
end

function Bestiary.setLoot(creatureData, monsterType)
	creatureData.loot = {}

	for _, itemData in pairs(monsterType:getLoot()) do
		Bestiary.addLootItem(creatureData, itemData)
	end

	table.sort(
		creatureData.loot,
		function(a, b)
			return tonumber(a.chance) > tonumber(b.chance)
		end
	)
end

function Bestiary.addLootItem(creatureData, itemData)
    local itemType = ItemType(itemData.itemId)
    local childLoot = itemData.childLoot

    if not itemType:isContainer() or not childLoot or #childLoot == 0 then
        local rawChance = itemData.chance * configManager.getNumber(configKeys.RATE_LOOT)

        local percentChance = rawChance / 1000

        local item = {
            itemId   = itemType:getClientId(),
            maxCount = itemData.maxCount or 1,
            tooltip  = itemType:getName(),
            chance   = string.format("%.3f", percentChance)
        }

        creatureData.loot = creatureData.loot or {}
        table.insert(creatureData.loot, item)
    end

    if childLoot then
        for _, nestedItemData in pairs(childLoot) do
            Bestiary.addLootItem(creatureData, nestedItemData)
        end
    end
end


function Bestiary.getCreatureBonuses(creatureData)
	local bonuses = {}
	for _, bonus in ipairs(creatureData.bonuses or {}) do
		table.insert(bonuses, {name = bonus.name, value = bonus.value})
	end
	return bonuses
end

------ Charms Effects Processing

function Bestiary.handleOffensiveCharm(player, monster, charmid, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN or primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if origin == ORIGIN_CONDITION then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local data = Bestiary.combatCharmsData[charmid]
	if not data then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if data["chance"] < math.random(data["maxRandomValue"]) then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if data["elementAttack"] then
		local dmg = math.min(monster:getHealth(), math.floor(monster:getMaxHealth() * data.healthPercent / 100))
		if data["maxDamage"] then
			dmg = math.min(dmg, data["maxDamage"])
		end
		doTargetCombat(0, monster, data["element"], -dmg, -dmg, data["effect"])
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if charmid == "7" and data["selfHealthPercent"] then -- Overpower
		local dmg = math.floor(player:getMaxHealth() * (data["selfHealthPercent"] / 100))
		if data["maxDamage"] then
			dmg = math.min(dmg, data["maxDamage"])
		end
		doTargetCombat(player, monster, COMBAT_PHYSICALDAMAGE, -dmg, -dmg, data["effect"])
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	elseif charmid == "8" and data["selfManaPercent"] then -- Overflux
		local dmg = math.floor(player:getMaxMana() * (data["selfManaPercent"] / 100))
		if data["maxDamage"] then
			dmg = math.min(dmg, data["maxDamage"])
		end
		doTargetCombat(player, monster, COMBAT_PHYSICALDAMAGE, -dmg, -dmg, data["effect"])
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	elseif charmid == "15" and data["speedPercent"] then -- Cripple
		monster:addCondition(Bestiary.buildParalyseCondition(data["speedPercent"], data["duration"]))
		monster:getPosition():sendMagicEffect(data["effect"])
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function Bestiary.handleDefensiveCharm(player, monster, charmid, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if primaryType == COMBAT_LIFEDRAIN or secondaryType == COMBAT_LIFEDRAIN or primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if origin == ORIGIN_CONDITION then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local data = Bestiary.combatCharmsData[charmid]
	if not data then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	if data["chance"] < math.random(data["maxRandomValue"]) then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	if charmid == "1" then -- Adrenaline Burst (speed)
		player:say("ADRENALINE RUSH!", TALKTYPE_MONSTER_SAY)
		local cond = Condition(CONDITION_HASTE)
		cond:setParameter(CONDITION_PARAM_TICKS, data["duration"] * 1000)
		local boost = data["speedPercent"] / 100
		cond:setFormula(boost, boost, boost, boost)
		player:addCondition(cond)
		player:getPosition():sendMagicEffect(data["effect"])
	elseif charmid == "12" then -- Dodge
		player:say("DODGE!", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(data["effect"])
		return 0, primaryType, 0, secondaryType
	elseif charmid == "6" then -- Parry (reflect)
		player:say("PARRY!", TALKTYPE_MONSTER_SAY)
		doTargetCombat(0, monster, COMBAT_PHYSICALDAMAGE, -primaryDamage, -primaryDamage)
		monster:getPosition():sendMagicEffect(data["effect"])
	elseif charmid == "9" and data["speedPercent"] then -- Numb
		monster:addCondition(Bestiary.buildParalyseCondition(data["speedPercent"], data["duration"]))
		monster:getPosition():sendMagicEffect(data["effect"])
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function Bestiary.handleVoidInversionCharm(player, manaDrain, cdata)
	if cdata["chance"] < math.random(cdata["maxRandomValue"]) then
		return
	end

	player:addMana(manaDrain)
	player:getPosition():sendMagicEffect(cdata["effect"])
	return true
end

function Bestiary.handleCarnageCharm(player, deadMonster, cdata)
	if cdata["chance"] and cdata["chance"] < math.random(cdata["maxRandomValue"]) then
		return true
	end

	local dmg = math.floor(deadMonster:getMaxHealth() * (cdata["healthPercent"] / 100))
	local centre = deadMonster:getPosition()

	for _, m in ipairs(Game.getSpectators(centre, false, false, 1, 1, 1, 1)) do
		if m:isMonster() and m ~= deadMonster and not m:getMaster() then
			doTargetCombat(player, m, cdata["element"], -dmg, -dmg, cdata["effect"])
		end
	end
end

local evt = CreatureEvent("Bestiary_onMonsterHealthChange") --  Event:  player → monster
function evt.onHealthChange(creature, attacker, primDmg, primType, secDmg, secType, origin)
	if not creature:isMonster() then
		return primDmg, primType, secDmg, secType
	end
	if not attacker or not attacker:isPlayer() then
		return primDmg, primType, secDmg, secType
	end

	local charmid = Bestiary.getUnlockedCharmId(attacker:getGuid(), creature:getName())
	if not charmid then
		return primDmg, primType, secDmg, secType
	end

	local cdata = Bestiary.combatCharmsData[charmid]
	if cdata and cdata["type"] == OFFENSIVE_CHARM then
		return Bestiary.handleOffensiveCharm(attacker, creature, charmid, primDmg, primType, secDmg, secType, origin)
	end
	return primDmg, primType, secDmg, secType
end
evt:register()

local evt2 = CreatureEvent("Bestiary_onPlayerHealthChange") --  Event:  monster → player
function evt2.onHealthChange(creature, attacker, primDmg, primType, secDmg, secType, origin)
	if not creature:isPlayer() then
		return primDmg, primType, secDmg, secType
	end
	if not attacker or not attacker:isMonster() then
		return primDmg, primType, secDmg, secType
	end

	local charmid = Bestiary.getUnlockedCharmId(creature:getGuid(), attacker:getName())
	if not charmid then
		return primDmg, primType, secDmg, secType
	end

	local cdata = Bestiary.combatCharmsData[charmid]
	if cdata and (cdata["type"] == DEFENSIVE_CHARM) then
		return Bestiary.handleDefensiveCharm(creature, attacker, charmid, primDmg, primType, secDmg, secType, origin)
	end
	return primDmg, primType, secDmg, secType
end
evt2:register()

local evtMana = CreatureEvent("Bestiary_onPlayerManaChange") --  Event:  monster → player
function evtMana.onManaChange(creature, attacker, primDmg, primType, secDmg, secType, origin)
	if not creature:isPlayer() then
		return primDmg, primType, secDmg, secType
	end
	if not attacker or not attacker:isMonster() then
		return primDmg, primType, secDmg, secType
	end

	local charmid = Bestiary.getUnlockedCharmId(creature:getGuid(), attacker:getName())
	if not charmid then
		return primDmg, primType, secDmg, secType
	end

	local cdata = Bestiary.combatCharmsData[charmid]
	if not cdata then
		return primDmg, primType, secDmg, secType
	end

	if charmid == "4" and primType == COMBAT_MANADRAIN then
		if Bestiary.handleVoidInversionCharm(creature, primDmg, cdata) then
			return 0
		end
	end

	local cdata = Bestiary.combatCharmsData[charmid]
	if cdata and (cdata["type"] == DEFENSIVE_CHARM) then
		return Bestiary.handleDefensiveCharm(creature, attacker, charmid, primDmg, primType, secDmg, secType, origin)
	end
	return primDmg, primType, secDmg, secType
end
evtMana:register()

local killEvt = CreatureEvent("Bestiary_onKillCharmHandler")
function killEvt.onKill(player, target, lastHit)
	if not (player and player:isPlayer()
			and target and target:isMonster()) then
		return true
	end

	local charmid = Bestiary.getUnlockedCharmId(player:getGuid(), target:getName())
	if not charmid then return true end

	local cdata = Bestiary.combatCharmsData[charmid]
	if not cdata or cdata["type"] ~= ONKILL_CHARM then
		return true
	end

	if charmid == "16" then -- Carnage
		Bestiary.handleCarnageCharm(player, target, cdata)
	end

	return true
end
killEvt:register()

function Bestiary.buildParalyseCondition(percent, seconds)
	local cond = Condition(CONDITION_PARALYZE)
	cond:setParameter(CONDITION_PARAM_TICKS, seconds * 1000)
	local frac = -math.abs(percent) / 100
	cond:setFormula(frac, frac, frac, frac)
	return cond
end
