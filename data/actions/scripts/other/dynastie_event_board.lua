function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not _G.GuildDynastieEvents or not _G.GuildDynastieEvents.useBoard then
		return true
	end

	_G.GuildDynastieEvents.useBoard(player, toPosition.x and toPosition or item:getPosition())
	return true
end
