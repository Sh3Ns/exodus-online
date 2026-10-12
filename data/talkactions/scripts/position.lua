function onSay(player, words, param)
	if player:getGroup():getAccess() and param ~= "" then
		local split = splitTalkParam(param, "n n n")
		local x, y, z = tonumber(split[1]), tonumber(split[2]), tonumber(split[3])
		if not x or not y or not z then
			player:sendCancelMessage("Usage: /position x y z")
		else
			player:teleportTo(Position(x, y, z))
		end
	else
		local position = player:getPosition()
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your current position is: " .. position.x .. ", " .. position.y .. ", " .. position.z .. ".")
	end
	return false
end
