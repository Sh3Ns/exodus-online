local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local STORAGE_CARAVAN_VISUALS_QUESTLOG = 222239
local STORAGE_RELIC_CARAVAN_UNLOCK = 222234
local STORAGE_RELIC_CARAVAN_QUEST = 222290

local relicStorages = {
	122391,
	122392,
	122393,
	122394,
	122395,
	122396,
	122397
}

local function getRelicsFound(player)
	local found = 0

	for i = 1, #relicStorages do
		if player:getStorageValue(relicStorages[i]) == 1 then
			found = found + 1
		end
	end

	return found
end

local function hasFoundAllRelics(player)
	return getRelicsFound(player) >= #relicStorages
end

local function initializeRelicSearch(player)
	for i = 1, #relicStorages do
		if player:getStorageValue(relicStorages[i]) < 0 then
			player:setStorageValue(relicStorages[i], 0)
		end
	end
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local voices = {
	{ text = "These old maps speak more truth than most living men." },
	{ text = "Ruins do not forget. They only wait." },
	{ text = "Seven marks... seven fragments... the old roads still remember." }
}

npcHandler:addModule(VoiceModule:new(voices))

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	if not player then
		return false
	end

	local relicQuestState = player:getStorageValue(STORAGE_RELIC_CARAVAN_QUEST)

	if msgcontains(msg, "relic caravan") then
		if player:getStorageValue(STORAGE_RELIC_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("You have already uncovered the lost Relic Caravan design. Few travelers ever manage to follow the old trail to its end.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if relicQuestState == 1 then
			npcHandler:say({
				"So Marek sent you after the Relic Caravan... good. Then perhaps this old map has not found me in vain.",
				"The design was never kept in one place. Long ago, its makers carved fragments of it into relics scattered across ancient lands, so that only a true traveler could recover it.",
				"I have traced seven such relics. Find them, inspect them, and return to me once the old marks have answered you. Will you follow the trail?"
			}, cid)

			npcHandler.topic[cid] = 50
			return true
		end

		if relicQuestState >= 2 and relicQuestState <= 9 then
			if hasFoundAllRelics(player) then
				player:setStorageValue(STORAGE_RELIC_CARAVAN_QUEST, 9)

				npcHandler:say({
					"You found them all... every mark from the old road.",
					"Then the pattern is complete. What was lost for ages can be read once more.",
					"The Relic Caravan design is now yours. Guard it well, traveler."
				}, cid)

				player:setStorageValue(STORAGE_RELIC_CARAVAN_UNLOCK, 1)
				player:setStorageValue(STORAGE_RELIC_CARAVAN_QUEST, 10)

				npcHandler.topic[cid] = 0
				return true
			end

			local found = getRelicsFound(player)
			npcHandler:say("The trail is not complete yet. You have inspected " .. found .. " of " .. #relicStorages .. " relics. Search the ancient places marked by the old road, then return to me.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if relicQuestState == 10 then
			npcHandler:say("The lost design has already been uncovered. The Relic Caravan is yours to use.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end

	if msgcontains(msg, "yes") then
		if npcHandler.topic[cid] == 50 then
			initializeRelicSearch(player)

			npcHandler:say({
				"Then take heed of the map.",
				"The first marks I found point toward places older than kingdoms: stone halls, forest ruins, buried tombs and temples swallowed by the wild.",
				"Search the world for the seven ancient relics bearing the caravan wheel, inspect each one, and return when all of them have answered you."
			}, cid)

			player:setStorageValue(STORAGE_CARAVAN_VISUALS_QUESTLOG, 1)
			player:setStorageValue(STORAGE_RELIC_CARAVAN_QUEST, 2)

			npcHandler.topic[cid] = 0
			return true
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())