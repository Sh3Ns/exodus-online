local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local STORAGE_CARAVAN_VISUALS_QUESTLOG = 222239
local STORAGE_MERCHANT_CARAVAN_UNLOCK = 222231
local STORAGE_MERCHANT_CARAVAN_QUEST = 222260

local MERCHANT_PARCEL_ITEMID = 30642
local MERCHANT_PARCEL_COUNT = 7

local merchantDeliveryStorages = {
	222261, -- Thais
	222262, -- Carlin
	222263, -- Venore
	222264, -- Edron
	222265, -- Kazordoon
	222266, -- Ab'Dendriel
	222267, -- Darashia
}

local function getMerchantDeliveriesDone(player)
	local done = 0

	for i = 1, #merchantDeliveryStorages do
		if player:getStorageValue(merchantDeliveryStorages[i]) == 1 then
			done = done + 1
		end
	end

	return done
end

local function hasCompletedMerchantRoute(player)
	return getMerchantDeliveriesDone(player) >= #merchantDeliveryStorages
end

local function initializeMerchantRoute(player)
	for i = 1, #merchantDeliveryStorages do
		if player:getStorageValue(merchantDeliveryStorages[i]) < 0 then
			player:setStorageValue(merchantDeliveryStorages[i], 0)
		end
	end
end

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()		npcHandler:onThink()		end

local voices = {
	{ text = 'Welcome to the post office!' },
	{ text = 'If you need help with letters or parcels, just ask me. I can explain everything.' },
	{ text = 'Hey, send a letter to your friend now and then. Keep in touch, you know.' }
}

npcHandler:addModule(VoiceModule:new(voices))

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end
	if msgcontains(msg, "measurements") then
		local player = Player(cid)
		if player:getStorageValue(Storage.postman.Mission07) >= 1 then
			npcHandler:say("Oh they don't change that much since in the old days as... <tells a boring and confusing story about a cake, a parcel, himself and two squirrels, at least he tells you his measurements in the end> ", cid)
			player:setStorageValue(Storage.postman.Mission07, player:getStorageValue(Storage.postman.Mission07) + 1)
			npcHandler.topic[cid] = 0
		end
	end
		local player = Player(cid)
	if not player then
		return false
	end

	local merchantQuestState = player:getStorageValue(STORAGE_MERCHANT_CARAVAN_QUEST)

		if msgcontains(msg, "merchant caravan") then
		if player:getStorageValue(STORAGE_MERCHANT_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("You have already proven yourself on the merchant roads. The Merchant Caravan design is yours to keep.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if merchantQuestState == 1 then
			npcHandler:say({
				"Oh, the Merchant Caravan? Yes, Marek spoke well of you.",
				"A fine merchant caravan is not earned by wealth alone, but by trust. If you wish to prove you can be trusted on the road, I have a delivery route for you.",
				"Would you like to take it?"
			}, cid)

			npcHandler.topic[cid] = 30
			return true
		end

		if merchantQuestState >= 2 and merchantQuestState <= 9 then
			if hasCompletedMerchantRoute(player) then
				npcHandler:say({
					"Excellent work. Every parcel reached its destination, and not one merchant has complained.",
					"You have shown patience, reliability and a good sense for the road.",
					"By the trust of the merchants, the Merchant Caravan design is now yours."
				}, cid)

				player:setStorageValue(STORAGE_MERCHANT_CARAVAN_UNLOCK, 1)
				player:setStorageValue(STORAGE_MERCHANT_CARAVAN_QUEST, 10)

				npcHandler.topic[cid] = 0
				return true
			end

			local done = getMerchantDeliveriesDone(player)
			local remaining = #merchantDeliveryStorages - done
			local missingParcels = remaining - player:getItemCount(MERCHANT_PARCEL_ITEMID)

			if missingParcels > 0 then
				player:addItem(MERCHANT_PARCEL_ITEMID, missingParcels)
				npcHandler:say("You still have deliveries left to make. It seems you were missing some parcels, so I have replaced them for you. You have delivered " .. done .. " of " .. #merchantDeliveryStorages .. " parcels so far.", cid)
			else
				npcHandler:say("You have delivered " .. done .. " of " .. #merchantDeliveryStorages .. " parcels so far. Continue the route and return when every depot has received its parcel.", cid)
			end

			npcHandler.topic[cid] = 0
			return true
		end

		if merchantQuestState == 10 then
			npcHandler:say("Your merchant route has already been completed. May your caravans always find open roads.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end

	if msgcontains(msg, "yes") then
		if npcHandler.topic[cid] == 30 then
			initializeMerchantRoute(player)

			npcHandler:say({
				"Good, good. Then take these sealed merchant parcels.",
				"Deliver one parcel to the depot mailbox of Thais, Carlin, Venore, Edron, Kazordoon, Ab'Dendriel and Darashia.",
				"Once every parcel has reached its destination, return to me. If you complete the full route, I will vouch that you have earned the Merchant Caravan design."
			}, cid)

			player:addItem(MERCHANT_PARCEL_ITEMID, MERCHANT_PARCEL_COUNT)
			player:setStorageValue(STORAGE_CARAVAN_VISUALS_QUESTLOG, 1)
			player:setStorageValue(STORAGE_MERCHANT_CARAVAN_QUEST, 2)

			npcHandler.topic[cid] = 0
			return true
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello. How may I help you |PLAYERNAME|? Ask me for a {trade} if you want to buy something. I can also explain the {mail} system or probably you are here because you eared about {merchant caravan}?")
npcHandler:setMessage(MESSAGE_FAREWELL, "It was a pleasure to help you, |PLAYERNAME|.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
