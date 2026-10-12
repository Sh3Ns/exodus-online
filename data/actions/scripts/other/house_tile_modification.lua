local grounds = {
	[26192] = 26193,
	[29729] = 29730,
	[29731] = 29732,
	[29733] = 29734,
}

local function internalGroundTransform(item, pos, toId)
	Game.createItem(toId, 1, pos)
	pos:sendMagicEffect(CONST_ME_POFF)
	item:remove(1)
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local groundTransformId = grounds[item.itemid]
	if not groundTransformId then
		return false
	end

	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local house = tile:getHouse()
	if not house or house:getOwnerGuid() ~= player:getGuid() then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only use this item inside a house you own.")
		return true
	end

	local ground = tile:getGround()
	if not ground then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only use this on ground.")
		return true
	end

	internalGroundTransform(item, toPosition, groundTransformId)
	return true
end