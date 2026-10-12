local STORAGE_RELIC_CARAVAN_QUEST = 222290

local relics = {
	[48017] = {
		storage = 122391,
		message = "You inspect the old horn relic. Faded markings speak of caravan masters who sounded it before setting out on roads that no longer exist."
	},
	[48018] = {
		storage = 122392,
		message = "You inspect the handle relic. Its worn grip once belonged to a chest carried by ancient travelers, where fragments of a forgotten caravan design were kept safe."
	},
	[48019] = {
		storage = 122393,
		message = "You inspect the decoration relic. Beneath the dust, you find the same wheel-shaped sigil Garrick described, a mark used by the first caravan builders."
	},
	[48020] = {
		storage = 122394,
		message = "You inspect the anubis relic. Its carvings tell of desert caravans that crossed burial sands long before the modern roads of Darama were known."
	},
	[48021] = {
		storage = 122395,
		message = "You inspect the anchor relic. The old inscription suggests that the Relic Caravan was used not only on land, but by traders who followed both roads and sea routes."
	},
	[48022] = {
		storage = 122396,
		message = "You inspect the gold shell relic. Tiny engravings describe distant shores, rare goods, and a caravan famed for returning from journeys no ordinary merchant would dare."
	},
	[48023] = {
		storage = 122397,
		message = "You inspect the turtle relic. Its ancient symbol praises patience, endurance, and the slow strength of a caravan built to survive any road."
	},
}

local function getRelicsFound(player)
	local found = 0

	for _, relic in pairs(relics) do
		if player:getStorageValue(relic.storage) == 1 then
			found = found + 1
		end
	end

	return found
end

local relicCaravanAction = Action()

function relicCaravanAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local relic = relics[item:getActionId()]
	if not relic then
		return true
	end

	local questState = player:getStorageValue(STORAGE_RELIC_CARAVAN_QUEST)

	if questState < 2 or questState >= 9 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "The relic bears old markings, but they mean nothing to you yet.")
		return true
	end

	if player:getStorageValue(relic.storage) == 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have already inspected this relic.")
		return true
	end

	player:setStorageValue(relic.storage, 1)
	player:sendTextMessage(MESSAGE_INFO_DESCR, relic.message)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

	local found = getRelicsFound(player)

	if found >= 7 then
		player:setStorageValue(STORAGE_RELIC_CARAVAN_QUEST, 9)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "With the seven relics inspected, the scattered history of the lost Relic Caravan becomes clear. Return to Garrick.")
	else
		player:setStorageValue(STORAGE_RELIC_CARAVAN_QUEST, 2 + found)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Relics inspected: " .. found .. " / 7.")
	end

	return true
end

for aid in pairs(relics) do
	relicCaravanAction:aid(aid)
end

relicCaravanAction:register()