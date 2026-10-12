function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local split = splitTalkParam(param, "n n name")
	if not split[1] or not split[2] or not split[3] or split[3] == "" then
		player:sendCancelMessage("Usage: /setstorage <storage> <value> <player>   or   /setstorage storage, value, playername")
		return false
	end

	local storage = tonumber(split[1])
	local value = tonumber(split[2])
	if not storage or not value then
		player:sendCancelMessage("Storage and value must be numbers.")
		return false
	end

	local target = Player(split[3])
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end

	target:setStorageValue(storage, value)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format(
		"Set storage %d to %d for player %s.",
		storage,
		value,
		target:getName()
	))
	return false
end
