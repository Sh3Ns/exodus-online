local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local STORAGE_ANGELIC_CARAVAN_QUEST = 222300
local STORAGE_ANGELIC_CARAVAN_BLESSING = 222301
local STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT = 222302
local STORAGE_ANGELIC_CARAVAN_BOSS_KILL = 222303

local REQUIRED_CLEANSE_KILLS = 25

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local voices = {
	{ text = "Light is not proven in comfort, but in darkness." },
	{ text = "Azazel was once radiant... now only judgment remains." },
	{ text = "The old rites are not forgotten while I still breathe." }
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

	local questState = player:getStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST)

	if msgcontains(msg, "angelic caravan") then
		if questState < 2 then
			npcHandler:say("The Angelic Caravan is not a tale I share with every passerby. Speak with Marek first, if you seek that sacred design.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 2 then
			npcHandler:say({
				"So Marek has sent you to me. Then you seek the Angelic Caravan, a design born from faith, sacrifice and light carried through corruption.",
				"Before you can face the fallen seraph's shadow, you must receive a sacred blessing.",
				"Go to the holy shrine and let its light judge your intent. Return to me once the blessing has answered you."
			}, cid)

			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_BLESSING, -1)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT, 0)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_BOSS_KILL, -1)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 3)

			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 3 then
			npcHandler:say("The shrine still awaits you. Receive its sacred blessing, then return to me.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 4 then
			if player:getStorageValue(STORAGE_ANGELIC_CARAVAN_BLESSING) ~= 1 then
				npcHandler:say("Something is wrong. I do not sense the blessing upon you. Return to the holy shrine and receive its light.", cid)
				npcHandler.topic[cid] = 0
				return true
			end

			npcHandler:say({
				"The blessing shines upon you. Good.",
				"But light alone is not enough. Azazel's corruption has spread through his servants, twisting once-sacred souls into weapons of ruin.",
				"Cleanse " .. REQUIRED_CLEANSE_KILLS .. " corrupted servants of the fallen seraph, then return to me."
			}, cid)

			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT, 0)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 5)

			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 5 then
			local kills = math.max(player:getStorageValue(STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT), 0)

			if kills >= REQUIRED_CLEANSE_KILLS then
				player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 6)
				npcHandler:say("You have cleansed enough corrupted servants. The path to the final trial is open. Speak to me again of the angelic caravan.", cid)
				npcHandler.topic[cid] = 0
				return true
			end

			npcHandler:say("The corruption still spreads. You have cleansed " .. kills .. " of " .. REQUIRED_CLEANSE_KILLS .. " corrupted servants. Continue, then return to me.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 6 then
			npcHandler:say({
				"You have done well. The servants are cleansed, and the blessing has not abandoned you.",
				"Only the final trial remains.",
				"Defeat Azazel the Infernal Seraph. When he falls, do not return to me. Return to Marek, for he is the one who can grant you the Angelic Caravan design."
			}, cid)

			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_BOSS_KILL, -1)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 7)

			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 7 then
			npcHandler:say("Azazel the Infernal Seraph still stands. Face him with the blessing you carry, then return to Marek when he has fallen.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 8 then
			npcHandler:say("Azazel has fallen. Your trial is complete. Return to Marek and claim the Angelic Caravan design.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if questState == 9 then
			npcHandler:say("The Angelic Caravan design is already yours. May its light never fade from your road.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())