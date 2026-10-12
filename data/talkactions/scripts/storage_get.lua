function onSay(cid, words, param)
	local player = Player(cid)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local split = splitTalkParam(param, "name n")
	if not split[1] or split[1] == "" or split[2] == nil then
		player:sendCancelMessage("Usage: /get <player> <storage id>   or   /get <player>, <storage id>")
		return false
	end

	local target = Player(split[1])
	if target == nil then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end

	local ch = tonumber(split[2])
	if not ch then
		player:sendCancelMessage("The storage id must be a number.")
		return false
	end

	local sto = target:getStorageValue(ch)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format(
		"The storage with id: %d from player %s is: %s.",
		ch, target:getName(), tostring(sto)))
	return false
end
