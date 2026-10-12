local config = {
	[ITEM_GOLD_COIN]      = {changeTo = ITEM_PLATINUM_COIN},
	[ITEM_PLATINUM_COIN] = {changeBack = ITEM_GOLD_COIN,     changeTo = ITEM_CRYSTAL_COIN},
	[ITEM_CRYSTAL_COIN]  = {changeBack = ITEM_PLATINUM_COIN, changeTo = ITEM_AMBER_COIN},
	[ITEM_AMBER_COIN]    = {changeBack = ITEM_CRYSTAL_COIN,  changeTo = ITEM_DEMONIAC_COIN},
	[ITEM_DEMONIAC_COIN] = {changeBack = ITEM_AMBER_COIN}
}

local goldConverter = Action()

function goldConverter.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local coin = config[target.itemid]
	if not coin then
		return false
	end

	local charges = item:getCharges()

	if coin.changeTo and target.type >= 100 then
		target:transform(target.itemid, target.type - 100)
		player:addItem(coin.changeTo, 1)
	elseif coin.changeBack then
		if target.type > 1 then
			target:transform(target.itemid, target.type - 1)
		else
			target:remove()
		end
		player:addItem(coin.changeBack, 100)

	else
		return false
	end

	if charges > 1 then
		item:transform(item:getId(), charges - 1)
	else
		item:remove()
	end

	playSoundPlayer(player, "coin.ogg")
	return true
end

goldConverter:id(26378)
goldConverter:register()