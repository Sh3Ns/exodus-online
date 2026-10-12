local STORAGE_CARAVAN_QUEST = 242241

local caravanParts = {
	-- aid = {storage, reward item id, text}
	[48001] = {storage = 222241, itemId = 30633, text = "ironbound cargo chest"}, -- 1 chest

	[48002] = {storage = 222242, itemId = 30634, text = "treated timber"}, -- timber 1
	[48003] = {storage = 222243, itemId = 30634, text = "treated timber"}, -- timber 2
	[48004] = {storage = 222244, itemId = 30634, text = "treated timber"}, -- timber 3
	[48005] = {storage = 222245, itemId = 30634, text = "treated timber"}, -- timber 4
	[48006] = {storage = 222246, itemId = 30634, text = "treated timber"}, -- timber 5
	[48007] = {storage = 222247, itemId = 30634, text = "treated timber"}, -- timber 6

	[48008] = {storage = 222248, itemId = 30635, text = "reinforced caravan wheel"}, -- wheel 1
	[48009] = {storage = 222249, itemId = 30635, text = "reinforced caravan wheel"}, -- wheel 2
}

local caravanPartsAction = Action()

function caravanPartsAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local part = caravanParts[item:getActionId()]
	if not part then
		return true
	end

	local questState = player:getStorageValue(STORAGE_CARAVAN_QUEST)

	if questState ~= 1 then
		if questState < 1 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "The piece looks useful, but you have no reason to take it.")
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You no longer need this caravan part.")
		end
		return true
	end

	if player:getStorageValue(part.storage) == 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have already recovered this caravan part.")
		return true
	end

	local reward = Game.createItem(part.itemId, 1)
	if not reward then
		return true
	end

	if not player:addItemEx(reward) then
		reward:remove()
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You do not have enough room to carry this caravan part.")
		return true
	end

	player:setStorageValue(part.storage, 1)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You recovered " .. part.text .. ".")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

	return true
end

for aid in pairs(caravanParts) do
	caravanPartsAction:aid(aid)
end

caravanPartsAction:register()