SupplyStash = SupplyStash or {}

local config = SupplyStash.config
if not config then
	return
end

local incomingChunks = {}
local normalizedSellers = {}
local sellerNames = {}

local function trim(value)
	return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function decodeXml(value)
	return tostring(value or "")
		:gsub("&quot;", '"')
		:gsub("&apos;", "'")
		:gsub("&lt;", "<")
		:gsub("&gt;", ">")
		:gsub("&amp;", "&")
end

local function getXmlAttribute(attributes, attributeName)
	return attributes:match(attributeName .. '%s*=%s*"(.-)"')
		or attributes:match(attributeName .. "%s*=%s*'(.-)'")
end

local function normalizeSellerConfig()
	local names = {}
	local seenByItem = {}

	local function addSeller(itemId, seller)
		itemId = tonumber(itemId)
		local displayName = trim(seller)
		if not itemId or ItemType(itemId):getId() == 0 or displayName == "" then
			return false
		end
		local key = displayName:lower()
		normalizedSellers[itemId] = normalizedSellers[itemId] or {}
		seenByItem[itemId] = seenByItem[itemId] or {}
		if not seenByItem[itemId][key] then
			seenByItem[itemId][key] = true
			normalizedSellers[itemId][#normalizedSellers[itemId] + 1] = displayName
		end
		names[key] = displayName
		return true
	end

	for _, configuredName in ipairs(SupplyStash.npcSellerNames or {}) do
		local fileName = trim(configuredName)
		if not fileName:find("[\\/]") then
			local path = "data/npc/" .. fileName .. ".xml"
			local file = io.open(path, "rb")
			if file then
				local xml = file:read("*a") or ""
				file:close()
				local npcAttributes = xml:match("<npc%s+([^>]+)>") or ""
				local sellerName = decodeXml(getXmlAttribute(npcAttributes, "name") or fileName)
				for attributes in xml:gmatch("<parameter%s+(.-)/>") do
					local key = getXmlAttribute(attributes, "key")
					if key == "shop_sellable" then
						local value = getXmlAttribute(attributes, "value")
						if value then
							for entry in value:gmatch("([^;]+)") do
								local itemId = entry:match("^%s*.-,%s*(%d+)")
								if itemId then addSeller(itemId, sellerName) end
							end
						end
					end
				end
			end
		end
	end

	for itemId, sellers in pairs(SupplyStash.npcSellerOverrides or {}) do
		for _, seller in ipairs(sellers) do
			addSeller(itemId, seller)
		end
	end

	for _, name in pairs(names) do
		sellerNames[#sellerNames + 1] = name
	end
	table.sort(sellerNames, function(a, b) return a:lower() < b:lower() end)
end

normalizeSellerConfig()

local function sendJson(player, payload)
	local encoded = json.encode(payload)
	local chunkSize = 7900
	if #encoded <= chunkSize then
		player:sendExtendedOpcode(config.opcode, encoded)
		return
	end

	local parts = {}
	for index = 1, #encoded, chunkSize do
		parts[#parts + 1] = encoded:sub(index, index + chunkSize - 1)
	end
	player:sendExtendedOpcode(config.opcode, "S" .. parts[1])
	for index = 2, #parts - 1 do
		player:sendExtendedOpcode(config.opcode, "P" .. parts[index])
	end
	player:sendExtendedOpcode(config.opcode, "E" .. parts[#parts])
end

local function sendMessage(player, message, kind)
	sendJson(player, { action = "message", kind = kind or "error", message = message })
end

local function isNearDepot(player)
	local position = player:getPosition()
	for offsetX = -1, 1 do
		for offsetY = -1, 1 do
			local tile = Tile(Position(position.x + offsetX, position.y + offsetY, position.z))
			if tile and tile:hasFlag(TILESTATE_DEPOT) then
				return true
			end
		end
	end
	return false
end

local function getSlotLimit(player)
	if player:isPremium() then
		return config.premiumAccountSlots
	end
	return config.freeAccountSlots
end

local function loadRows(player)
	local rows = {}
	local usedSlots = 0
	local query = string.format(
		"SELECT `item_id`, `amount` FROM `player_stash` WHERE `player_id` = %d AND `amount` > 0 ORDER BY `item_id` ASC",
		player:getGuid()
	)
	local resultId = db.storeQuery(query)
	if resultId then
		repeat
			local itemId = result.getNumber(resultId, "item_id")
			local amount = result.getNumber(resultId, "amount")
			local itemType = ItemType(itemId)
			if itemType:getId() ~= 0 and itemType:isStackable() and amount > 0 then
				rows[#rows + 1] = {
					serverId = itemId,
					clientId = itemType:getClientId(),
					amount = amount,
					sellers = normalizedSellers[itemId] or {},
				}
				usedSlots = usedSlots + math.ceil(amount / config.unitsPerSlot)
			end
		until not result.next(resultId)
		result.free(resultId)
	end
	return rows, usedSlots
end

function SupplyStash.sendState(player, shouldOpen)
	local rows, usedSlots = loadRows(player)
	local slotLimit = getSlotLimit(player)
	local state = {
		action = "state",
		open = shouldOpen == true,
		stashClientId = ItemType(config.itemId):getClientId(),
		items = rows,
		sellers = sellerNames,
		usedSlots = usedSlots,
		totalSlots = slotLimit,
		freeSlots = math.max(0, slotLimit - usedSlots),
		premium = player:isPremium(),
	}
	sendJson(player, state)
end

local function getRequestedItem(player, data)
	local positionData = data and data.position
	if type(positionData) ~= "table" then
		return nil
	end
	local position = {
		x = tonumber(positionData.x) or 0,
		y = tonumber(positionData.y) or 0,
		z = tonumber(positionData.z) or 0,
		stackpos = tonumber(data.stackpos) or 0,
	}
	if position.x ~= 0xFFFF then
		return nil
	end
	return player:getItem(position)
end

local function stowItem(player, data)
	if not isNearDepot(player) then
		sendMessage(player, "You must be next to a depot to use the Supply Stash.")
		return
	end
	if config.requirePremiumToStow and not player:isPremium() then
		sendMessage(player, "Only premium players can add items to the Supply Stash.")
		return
	end

	local item = getRequestedItem(player, data)
	if not item or item:getId() == config.itemId then
		sendMessage(player, "That item is no longer available.")
		return
	end
	local itemType = item:getType()
	if not itemType:isStackable() then
		sendMessage(player, "Only stackable items can be added to the Supply Stash.")
		return
	end
	if not itemType:isMarketable() then
		sendMessage(player, "Only items registered in the Market can be added to the Supply Stash.")
		return
	end

	local amount = math.floor(tonumber(data.amount) or item:getCount())
	amount = math.min(amount, item:getCount(), config.stackSize)
	if amount < 1 then
		return
	end

	local rows, usedSlots = loadRows(player)
	local currentAmount = 0
	for _, row in ipairs(rows) do
		if row.serverId == item:getId() then
			currentAmount = row.amount
			break
		end
	end
	local oldUnits = math.ceil(currentAmount / config.unitsPerSlot)
	local newUnits = math.ceil((currentAmount + amount) / config.unitsPerSlot)
	if usedSlots - oldUnits + newUnits > getSlotLimit(player) then
		sendMessage(player, "Your Supply Stash does not have enough free slots.")
		return
	end

	local itemId = item:getId()
	if not item:remove(amount) then
		sendMessage(player, "The item could not be moved to your Supply Stash.")
		return
	end

	local query = string.format(
		"INSERT INTO `player_stash` (`player_id`, `item_id`, `amount`) VALUES (%d, %d, %d) " ..
		"ON DUPLICATE KEY UPDATE `amount` = `amount` + VALUES(`amount`)",
		player:getGuid(), itemId, amount
	)
	if not db.query(query) then
		player:addItem(itemId, amount, false)
		sendMessage(player, "The Supply Stash database update failed; your item was returned.")
		return
	end

	SupplyStash.sendState(player, false)
end

local function resolveDestination(player, data)
	local position = data and data.destination
	if type(position) == "table" and tonumber(position.x) == 0xFFFF then
		local encodedY = tonumber(position.y) or 0
		if encodedY >= 0x40 and encodedY <= 0x4F then
			local container = player:getContainerById(encodedY - 0x40)
			if container then
				return container
			end
		end
	end
	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
	return backpack and backpack:isContainer() and backpack or nil
end

local function withdrawItem(player, data)
	if not isNearDepot(player) then
		sendMessage(player, "You must be next to a depot to use the Supply Stash.")
		return
	end
	local itemId = math.floor(tonumber(data.serverId) or 0)
	local amount = math.floor(tonumber(data.amount) or 0)
	amount = math.min(amount, config.maxWithdrawalAmount)
	local itemType = ItemType(itemId)
	if itemId <= 0 or amount <= 0 or itemType:getId() == 0 or not itemType:isStackable() then
		sendMessage(player, "Invalid Supply Stash withdrawal.")
		return
	end

	local query = string.format(
		"SELECT `amount` FROM `player_stash` WHERE `player_id` = %d AND `item_id` = %d LIMIT 1",
		player:getGuid(), itemId
	)
	local resultId = db.storeQuery(query)
	if not resultId then
		sendMessage(player, "That item is no longer in your Supply Stash.")
		return
	end
	local storedAmount = result.getNumber(resultId, "amount")
	result.free(resultId)
	amount = math.min(amount, storedAmount)
	if amount <= 0 then
		return
	end

	local destination = resolveDestination(player, data)
	if not destination then
		sendMessage(player, "Open or equip a backpack before withdrawing items.")
		return
	end

	local availableCount = destination:getEmptySlots(false) * config.stackSize
	for _, destinationItem in ipairs(destination:getItems()) do
		if destinationItem:getId() == itemId and destinationItem:getCount() < config.stackSize then
			availableCount = availableCount + config.stackSize - destinationItem:getCount()
		end
	end
	if availableCount < amount then
		sendMessage(player, "The selected backpack does not have enough room for that amount.")
		return
	end
	if destination:getTopParent() == player and player:getFreeCapacity() < itemType:getWeight() * amount then
		sendMessage(player, "You do not have enough capacity for that amount.")
		return
	end

	local updateQuery
	if amount == storedAmount then
		updateQuery = string.format(
			"DELETE FROM `player_stash` WHERE `player_id` = %d AND `item_id` = %d",
			player:getGuid(), itemId
		)
	else
		updateQuery = string.format(
			"UPDATE `player_stash` SET `amount` = `amount` - %d WHERE `player_id` = %d AND `item_id` = %d AND `amount` >= %d",
			amount, player:getGuid(), itemId, amount
		)
	end
	if not db.query(updateQuery) then
		sendMessage(player, "The Supply Stash database update failed.")
		return
	end

	local remaining = amount
	while remaining > 0 do
		local stackAmount = math.min(config.stackSize, remaining)
		if not destination:addItem(itemId, stackAmount) then
			break
		end
		remaining = remaining - stackAmount
	end
	if remaining > 0 then
		db.query(string.format(
			"INSERT INTO `player_stash` (`player_id`, `item_id`, `amount`) VALUES (%d, %d, %d) " ..
			"ON DUPLICATE KEY UPDATE `amount` = `amount` + VALUES(`amount`)",
			player:getGuid(), itemId, remaining
		))
		sendMessage(player, "Only part of the withdrawal fit; the remainder stayed in your Supply Stash.")
		SupplyStash.sendState(player, false)
		return
	end

	SupplyStash.sendState(player, false)
end

local function decodeIncoming(player, buffer)
	local prefix = buffer:sub(1, 1)
	local guid = player:getGuid()
	if prefix == "S" then
		incomingChunks[guid] = buffer:sub(2)
		return nil
	elseif prefix == "P" then
		incomingChunks[guid] = (incomingChunks[guid] or "") .. buffer:sub(2)
		return nil
	elseif prefix == "E" then
		buffer = (incomingChunks[guid] or "") .. buffer:sub(2)
		incomingChunks[guid] = nil
	end
	local ok, decoded = pcall(json.decode, buffer)
	return ok and decoded or nil
end

local stashAction = Action()
function stashAction.onUse(player)
	if not isNearDepot(player) then
		player:sendCancelMessage("You must be next to a depot to use the Supply Stash.")
		return true
	end
	SupplyStash.sendState(player, true)
	return true
end
stashAction:id(config.itemId)
stashAction:register()

local extendedEvent = CreatureEvent("SupplyStashExtended")
function extendedEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= config.opcode then
		return true
	end
	local data = decodeIncoming(player, buffer)
	if not data or type(data.action) ~= "string" then
		return true
	end
	if data.action == "open" then
		if isNearDepot(player) then
			SupplyStash.sendState(player, true)
		else
			sendMessage(player, "You must be next to a depot to use the Supply Stash.")
		end
	elseif data.action == "refresh" then
		if isNearDepot(player) then SupplyStash.sendState(player, false) end
	elseif data.action == "stow" then
		stowItem(player, data)
	elseif data.action == "withdraw" then
		withdrawItem(player, data)
	end
	return true
end
extendedEvent:type("extendedopcode")
extendedEvent:register()

local loginEvent = CreatureEvent("SupplyStashLogin")
function loginEvent.onLogin(player)
	player:registerEvent("SupplyStashExtended")
	return true
end
loginEvent:type("login")
loginEvent:register()

local logoutEvent = CreatureEvent("SupplyStashLogout")
function logoutEvent.onLogout(player)
	incomingChunks[player:getGuid()] = nil
	return true
end
logoutEvent:type("logout")
logoutEvent:register()
