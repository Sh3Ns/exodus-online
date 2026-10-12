local STORAGE_ANGELIC_CARAVAN_QUEST = 222300
local STORAGE_ANGELIC_CARAVAN_BLESSING = 222301

local angelicShrineAction = Action()

function angelicShrineAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST) ~= 3 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "The shrine glows faintly, but nothing happens.")
		return true
	end

	if player:getStorageValue(STORAGE_ANGELIC_CARAVAN_BLESSING) == 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have already received the blessing of dawn.")
		return true
	end

	player:setStorageValue(STORAGE_ANGELIC_CARAVAN_BLESSING, 1)
	player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 4)

	player:sendTextMessage(MESSAGE_INFO_DESCR, "The corrupted flames recoil as the altar answers your presence. A warm light surrounds you. You have received the blessing of dawn.")
	player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)

	return true
end

angelicShrineAction:aid(48024)
angelicShrineAction:register()