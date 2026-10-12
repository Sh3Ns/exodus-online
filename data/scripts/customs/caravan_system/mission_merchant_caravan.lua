local STORAGE_MERCHANT_CARAVAN_QUEST = 222260
local MERCHANT_PARCEL_ITEMID = 30642

local merchantMailboxes = {
	[48010] = {storage = 222261, town = "Thais"},
	[48011] = {storage = 222262, town = "Carlin"},
	[48012] = {storage = 222263, town = "Venore"},
	[48013] = {storage = 222264, town = "Edron"},
	[48014] = {storage = 222265, town = "Kazordoon"},
	[48015] = {storage = 222266, town = "Ab'Dendriel"},
	[48016] = {storage = 222267, town = "Darashia"},
}

local function getMerchantDeliveriesDone(player)
	local done = 0

	for _, mailbox in pairs(merchantMailboxes) do
		if player:getStorageValue(mailbox.storage) == 1 then
			done = done + 1
		end
	end

	return done
end

local merchantMailboxAction = Action()

function merchantMailboxAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local mailbox = merchantMailboxes[item:getActionId()]
	if not mailbox then
		return true
	end

	local questState = player:getStorageValue(STORAGE_MERCHANT_CARAVAN_QUEST)
	if questState < 2 or questState >= 9 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "This mailbox is used for merchant deliveries, but you have no parcel to send.")
		return true
	end

	if player:getStorageValue(mailbox.storage) == 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have already delivered a merchant parcel to " .. mailbox.town .. ".")
		return true
	end

	if player:getItemCount(MERCHANT_PARCEL_ITEMID) < 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You need a sealed merchant parcel to make this delivery.")
		return true
	end

	player:removeItem(MERCHANT_PARCEL_ITEMID, 1)
	player:setStorageValue(mailbox.storage, 1)

	local done = getMerchantDeliveriesDone(player)
	player:setStorageValue(STORAGE_MERCHANT_CARAVAN_QUEST, math.min(2 + done, 9))

	player:sendTextMessage(MESSAGE_INFO_DESCR, "You delivered a sealed merchant parcel to " .. mailbox.town .. ".")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

	return true
end

for aid in pairs(merchantMailboxes) do
	merchantMailboxAction:aid(aid)
end

merchantMailboxAction:register()