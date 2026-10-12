local finish = MoveEvent()

function finish.onStepIn(player, item, position, fromPosition)
	if player:isPlayer() then
		local dungeon = player:getDungeon()
		if dungeon then
			local instance = dungeon:getPlayerInstance(player)
			if instance then
				dungeon:onPlayerLeave(player)
				player:teleportTo(player:getTown():getTemplePosition())
			end
		end
	end
	return true
end

finish:type("stepin")
finish:aid(6435)
finish:register()
