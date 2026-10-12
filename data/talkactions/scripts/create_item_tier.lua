local FORGE_TIER_ATTRIBUTE = "forge_tier"
local MAX_TEST_TIER = 10

local ForgeItems = dofile("data/scripts/customs/forge/forge_items.lua")

local function initializeSocketMetadata(item)
	if type(_G.GemsSocket_ensureSocketableMetadata) == "function" and item and item:isItem() then
		_G.GemsSocket_ensureSocketableMetadata(item)
	end
end

local function resolveItemType(value)
	local itemType = ItemType(value)
	if itemType:getId() ~= 0 then return itemType end

	local itemId = tonumber(value)
	if not itemId then return nil end
	itemType = ItemType(itemId)
	return itemType:getId() ~= 0 and itemType or nil
end

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local split = splitTalkParam(param, "name n n")
	if not split[1] or split[1] == "" or not split[2] or not split[3] then
		player:sendCancelMessage("Usage: /itier <item name/id> <count> <tier>   or   /itier itemId/name, count, tier")
		return false
	end

	local itemType = resolveItemType(split[1])
	if not itemType then
		player:sendCancelMessage("There is no item with that id or name.")
		return false
	end

	if not ForgeItems.isAllowedType(itemType) then
		player:sendCancelMessage("Only forgeable weapons, armors, helmets, legs and boots can receive a forge tier.")
		return false
	end

	local count = math.floor(tonumber(split[2]) or 0)
	if count < 1 or count > 100 then
		player:sendCancelMessage("Count must be between 1 and 100.")
		return false
	end

	local tier = tonumber(split[3])
	if not tier or tier ~= math.floor(tier) then
		player:sendCancelMessage("Tier must be a whole number.")
		return false
	end

	local classification = ForgeItems.getClassification(itemType)
	if tier < 0 or tier > MAX_TEST_TIER then
		player:sendCancelMessage(string.format("Tier must be between 0 and %d.", MAX_TEST_TIER))
		return false
	end

	local createdCount = 0
	for _ = 1, count do
		local item = Game.createItem(itemType:getId(), 1)
		if not item then
			player:sendCancelMessage("The tiered item could not be created.")
			return false
		end

		item:setCustomAttribute(FORGE_TIER_ATTRIBUTE, tier)

		if player:addItemEx(item) ~= RETURNVALUE_NOERROR then
			item:remove()
			player:sendCancelMessage(string.format(
				"Created %d item(s), then stopped because you do not have enough room.", createdCount))
			return false
		end

		initializeSocketMetadata(item)
		item:decay()
		createdCount = createdCount + 1
	end

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	player:sendTextMessage(MESSAGE_INFO_DESCR, string.format(
		"Created %d x %s at forge tier %d (Classification %d).",
		createdCount, itemType:getName(), tier, classification))
	return false
end
