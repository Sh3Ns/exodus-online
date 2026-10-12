local invalidIds = {
	1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 14, 15, 19, 21, 26, 27, 28, 35, 43
}

local function initializeSocketMetadata(item)
	if type(_G.GemsSocket_ensureSocketableMetadata) == "function" and item and item.isItem and item:isItem() then
		_G.GemsSocket_ensureSocketableMetadata(item)
	end
end

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local split = splitTalkParam(param, "name n n")
	if not split[1] or split[1] == "" or not split[3] then
		player:sendCancelMessage("Usage: /irarity <item name/id> <count> <rarityId>   or   /irarity itemId/name, count, rarityId")
		return false
	end

	local itemType = ItemType(split[1])
	if itemType:getId() == 0 then
		itemType = ItemType(tonumber(split[1]))
		if not tonumber(split[1]) or itemType:getId() == 0 then
			player:sendCancelMessage("There is no item with that id or name.")
			return false
		end
	end

	if table.contains(invalidIds, itemType:getId()) then
		return false
	end

	local count = tonumber(split[2])
	if count then
		if itemType:isStackable() then
			count = math.min(10000, math.max(1, count))
		elseif not itemType:isFluidContainer() then
			count = math.min(100, math.max(1, count))
		else
			count = math.max(0, count)
		end
	else
		count = 1
	end

	local rarityId = tonumber(split[3]) or 0
	if rarityId < 1 or rarityId > 15 then
		player:sendCancelMessage("Rarity must be between 1 and 15.")
		return false
	end
	rarityId = math.floor(rarityId)

	local createdCount = 0
	for _ = 1, math.max(1, count) do
		local item = Game.createItemWithRarity(itemType:getId(), itemType:isStackable() and count or 1, rarityId)
		if not item then
			player:sendCancelMessage("The rarity item could not be created.")
			return false
		end

		if player:addItemEx(item) ~= RETURNVALUE_NOERROR then
			item:remove()
			player:sendCancelMessage("You do not have enough room.")
			return false
		end

		initializeSocketMetadata(item)
		if not itemType:isStackable() then
			item:decay()
		end
		createdCount = createdCount + 1

		if itemType:isStackable() then
			break
		end
	end

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Created %d x %s with rarity %d.", createdCount, itemType:getName(), rarityId))
	return false
end
