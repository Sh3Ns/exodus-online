local config = {
	[ITEM_GOLD_COIN]      = {changeTo = ITEM_PLATINUM_COIN},
	[ITEM_PLATINUM_COIN] = {changeBack = ITEM_GOLD_COIN,     changeTo = ITEM_CRYSTAL_COIN},
	[ITEM_CRYSTAL_COIN]  = {changeBack = ITEM_PLATINUM_COIN, changeTo = ITEM_AMBER_COIN},
	[ITEM_AMBER_COIN]    = {changeBack = ITEM_CRYSTAL_COIN,  changeTo = ITEM_DEMONIAC_COIN},
	[ITEM_DEMONIAC_COIN] = {changeBack = ITEM_AMBER_COIN}
}

function onUse(player, item, fromPosition, itemEx, toPosition, isHotkey)
	local coin = config[item.itemid]
	if not coin then
		return false
	end

	if coin.changeTo and item.type >= 1000 then
		item:transform(item.itemid, item.type - 1000)
		player:addItem(coin.changeTo, 1)
		playSoundPlayer(player, "coin.ogg")
		return true
	end

	if coin.changeBack then
		if item.type > 1 then
			item:transform(item.itemid, item.type - 1)
		else
			item:remove()
		end
		player:addItem(coin.changeBack, 1000)
		playSoundPlayer(player, "coin.ogg")
		return true
	end

	return false
end