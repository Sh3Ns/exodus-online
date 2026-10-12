local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local STORAGE_CARAVAN_UNLOCK = 172545
local STORAGE_CARAVAN_STORAGE_LEVEL = 222229
local STORAGE_CARAVAN_QUEST = 242241
local STORAGE_CARAVAN_VISUALS_QUESTLOG = 222239
local STORAGE_DRAGON_CARAVAN_UNLOCK = 222233
local STORAGE_DRAGON_CARAVAN_QUEST = 222280
local STORAGE_DRAGON_CARAVAN_BOSS_KILL = 222281
local STORAGE_ANGELIC_CARAVAN_UNLOCK = 222235
local STORAGE_ANGELIC_CARAVAN_QUEST = 222300
local STORAGE_ANGELIC_CARAVAN_BLESSING = 222301
local STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT = 222302
local STORAGE_ANGELIC_CARAVAN_BOSS_KILL = 222303
local STORAGE_SKY_CARAVAN_UNLOCK = 222236
local STORAGE_SKY_CARAVAN_QUEST = 222310
local STORAGE_SKY_CARAVAN_BOSS_KILL = 222311

local requiredSkyCaravanVisuals = {
	222230, -- Royal Caravan
	222231, -- Merchant Caravan
	222232, -- War Caravan
	222233, -- Dragon Caravan
	222234, -- Relic Caravan
	222235, -- Angelic Caravan
}

local caravanRepairMaterials = {
	{id = 30633, count = 1}, -- ironbound cargo chest
	{id = 30634, count = 6}, -- treated timber
	{id = 30635, count = 2}, -- reinforced caravan wheel
	{id = 8309, count = 10}, -- nail
}

local function getMaterialName(itemId)
	local itemType = ItemType(itemId)
	local name = itemType and itemType:getName() or ("item " .. itemId)
	return name ~= "" and name or ("item " .. itemId)
end

local function getMaterialsText(materials)
	local parts = {}

	for i = 1, #materials do
		local material = materials[i]
		parts[#parts + 1] = material.count .. "x " .. getMaterialName(material.id)
	end

	return table.concat(parts, ", ")
end

local function hasMaterials(player, materials)
	for i = 1, #materials do
		local material = materials[i]
		if player:getItemCount(material.id) < material.count then
			return false
		end
	end

	return true
end

local function removeMaterials(player, materials)
	for i = 1, #materials do
		local material = materials[i]
		player:removeItem(material.id, material.count)
	end
end

local function hasAllSkyCaravanRequirements(player)
	for i = 1, #requiredSkyCaravanVisuals do
		if player:getStorageValue(requiredSkyCaravanVisuals[i]) ~= 1 then
			return false
		end
	end

	return true
end

local requiredSkyCaravanNames = {
	{storage = 222230, name = "Royal Caravan"},
	{storage = 222231, name = "Merchant Caravan"},
	{storage = 222232, name = "War Caravan"},
	{storage = 222233, name = "Dragon Caravan"},
	{storage = 222234, name = "Relic Caravan"},
	{storage = 222235, name = "Angelic Caravan"},
}

local function getMissingSkyCaravanText(player)
	local missing = {}

	for i = 1, #requiredSkyCaravanNames do
		local requirement = requiredSkyCaravanNames[i]
		if player:getStorageValue(requirement.storage) ~= 1 then
			missing[#missing + 1] = requirement.name
		end
	end

	if #missing == 0 then
		return ""
	end

	return table.concat(missing, ", ")
end

function onCreatureAppear(cid)
	npcHandler:onCreatureAppear(cid)
end

function onCreatureDisappear(cid)
	npcHandler:onCreatureDisappear(cid)
end

function onCreatureSay(cid, type, msg)
	npcHandler:onCreatureSay(cid, type, msg)
end

function onThink()
	npcHandler:onThink()
end

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	if not player then
		return false
	end

	local questState = player:getStorageValue(STORAGE_CARAVAN_QUEST)
		if msgcontains(msg, "visuals") or msgcontains(msg, "designs") then
		npcHandler:say({
			"A caravan is more than a cart on wheels. Many peoples of this world shaped them after their own roads and stories.",
			"If you seek other designs, ask me about the {royal caravan}, {merchant caravan}, {war caravan}, {dragon caravan}, {relic caravan}, {angelic caravan} or {sky caravan}."
		}, cid)
		return true
	end

	if msgcontains(msg, "royal caravan") then
		npcHandler:say("The Royal Caravan once bore the colors of Thais itself. If anyone still grants the right to use that design, it would be King Tibianus.", cid)
		return true
	end

	if msgcontains(msg, "merchant caravan") then
		npcHandler:say("Merchant caravans are earned through trust, not coin alone. If you wish to prove yourself on the roads, speak with Benjamin at the Thais depot.", cid)
		return true
	end

	if msgcontains(msg, "war caravan") then
		npcHandler:say("War caravans were made for battlefields, not markets. Soldiers and commanders may know what is needed to claim one.", cid)
		return true
	end

	if msgcontains(msg, "dragon caravan") then
		local dragonQuestState = player:getStorageValue(STORAGE_DRAGON_CARAVAN_QUEST)

		if player:getStorageValue(STORAGE_DRAGON_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("You have already proven yourself against Vorondor The Eternal Flames. The Dragon Caravan design is yours to keep.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if dragonQuestState == 1 then
			npcHandler:say({
				"A Dragon Caravan is no common craft. Many hunters gather scales and claws, but that alone does not grant the right to bear such a design.",
				"If you truly seek it, you must prove yourself against a dragon whose flames have endured beyond generations.",
				"Defeat Vorondor The Eternal Flames, then return to me. Only then will I grant you the Dragon Caravan design."
			}, cid)
			player:setStorageValue(STORAGE_DRAGON_CARAVAN_BOSS_KILL, -1)
			player:setStorageValue(STORAGE_DRAGON_CARAVAN_QUEST, 2)
			npcHandler.topic[cid] = 0
			return true
		end

		if dragonQuestState == 2 then
			if player:getStorageValue(STORAGE_DRAGON_CARAVAN_BOSS_KILL) == 1 then
				npcHandler:say({
					"So... the flames of Vorondor did not consume you.",
					"Then you have done more than gather trophies. You have faced the wrath of a true dragon and returned alive.",
					"The Dragon Caravan design is now yours."
				}, cid)

				player:setStorageValue(STORAGE_DRAGON_CARAVAN_UNLOCK, 1)
				player:setStorageValue(STORAGE_DRAGON_CARAVAN_QUEST, 3)

				npcHandler.topic[cid] = 0
				return true
			end

			npcHandler:say("Vorondor The Eternal Flames still stands. Defeat him, then return to me if you wish to claim the Dragon Caravan design.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if dragonQuestState == 3 then
			npcHandler:say("You have already defeated Vorondor The Eternal Flames. The Dragon Caravan design is yours.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end

	if msgcontains(msg, "relic caravan") then
		npcHandler:say("The Relic Caravan is an old design, older than many roads still walked today. If you wish to seek it, find Garrick at his excavation camp at north of Edron. He has spent years following its trail.", cid)
		return true
	end

	if msgcontains(msg, "angelic caravan") then
		local angelicQuestState = player:getStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST)

		if player:getStorageValue(STORAGE_ANGELIC_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("You have already completed the holy trial and earned the Angelic Caravan design.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if angelicQuestState == 1 then
			npcHandler:say({
				"The Angelic Caravan is not built for just anyone. It belongs to those who can carry light through corruption without losing themselves.",
				"Long ago, its blessing was guarded by a sacred order, but their trial was broken when Azazel the Infernal Seraph fell into fire and madness.",
				"If you seek this design, find Seraphina. She still keeps the old rites and can guide you through the holy trial."
			}, cid)

			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_BLESSING, -1)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT, 0)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_BOSS_KILL, -1)
			player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 2)

			npcHandler.topic[cid] = 0
			return true
		end

		if angelicQuestState >= 2 and angelicQuestState <= 7 then
			npcHandler:say("Seraphina is guiding your holy trial. Follow her instructions before returning to me.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if angelicQuestState == 8 then
			if player:getStorageValue(STORAGE_ANGELIC_CARAVAN_BOSS_KILL) == 1 then
				npcHandler:say({
					"So Azazel the Infernal Seraph has fallen...",
					"You carried light through corruption and returned with your spirit unbroken.",
					"The Angelic Caravan design is now yours."
				}, cid)

				player:setStorageValue(STORAGE_ANGELIC_CARAVAN_UNLOCK, 1)
				player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 9)

				npcHandler.topic[cid] = 0
				return true
			end

			npcHandler:say("Azazel still stands. Defeat him, then return to me.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if angelicQuestState == 9 then
			npcHandler:say("The Angelic Caravan design is already yours. May it carry light wherever you travel.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end

	if msgcontains(msg, "sky caravan") then
		local skyQuestState = player:getStorageValue(STORAGE_SKY_CARAVAN_QUEST)

		if player:getStorageValue(STORAGE_SKY_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("You have already mastered the caravan journey and earned the Sky Caravan design.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if skyQuestState == 1 then
			npcHandler:say({
				"The Sky Caravan... now that is a legend even among caravan masters.",
				"It is not granted for one deed, one battle, or one road. It belongs only to those who have mastered every caravan path before it.",
				"Unlock the Royal, Merchant, War, Dragon, Relic and Angelic Caravan designs first. Then return to me."
			}, cid)

			player:setStorageValue(STORAGE_SKY_CARAVAN_BOSS_KILL, -1)
			player:setStorageValue(STORAGE_SKY_CARAVAN_QUEST, 2)

			npcHandler.topic[cid] = 0
			return true
		end

		if skyQuestState == 2 then
			if not hasAllSkyCaravanRequirements(player) then
				npcHandler:say("You are not yet ready for the Sky Caravan. You are still missing: " .. getMissingSkyCaravanText(player) .. ".", cid)
				npcHandler.topic[cid] = 0
				return true
			end

			npcHandler:say({
				"You have walked every road I know. Royal trust, merchant patience, war endurance, dragon fire, ancient relics and angelic light...",
				"Only one trial remains.",
				"Defeat Rathmora Ascendant Tyrant, then return to me. If you survive, the Sky Caravan design will be yours."
			}, cid)

			player:setStorageValue(STORAGE_SKY_CARAVAN_BOSS_KILL, -1)
			player:setStorageValue(STORAGE_SKY_CARAVAN_QUEST, 3)

			npcHandler.topic[cid] = 0
			return true
		end

		if skyQuestState == 3 then
			npcHandler:say("The final trial still awaits. Defeat Rathmora Ascendant Tyrant, then return to me.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if skyQuestState == 4 then
			if player:getStorageValue(STORAGE_SKY_CARAVAN_BOSS_KILL) == 1 then
				npcHandler:say({
					"Rathmora Ascendant Tyrant has fallen...",
					"Then your journey is complete. You have mastered every caravan path and overcome the final trial.",
					"The Sky Caravan design is now yours."
				}, cid)

				player:setStorageValue(STORAGE_SKY_CARAVAN_UNLOCK, 1)
				player:setStorageValue(STORAGE_SKY_CARAVAN_QUEST, 5)

				npcHandler.topic[cid] = 0
				return true
			end

			npcHandler:say("Rathmora Ascendant Tyrant must fall before I can grant you the Sky Caravan design.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if skyQuestState == 5 then
			npcHandler:say("The Sky Caravan design is already yours. Few travelers will ever reach the road you now walk.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end
	if msgcontains(msg, "caravan") then
		if player:getStorageValue(STORAGE_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("You already know the ways of the caravan, traveler. Take good care of yours, and it will carry your burdens far.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if questState < 1 then
			npcHandler:say({
				"Aye... a caravan. I once led them across every road of this land, carrying goods from town to town.",
				"But cyclops ambushed my last convoy in the mountain passage north of Thais and left my old caravan in pieces.",
				"If you are willing to help me recover what remains of it, I could teach you how to keep a caravan of your own. Will you help me?"
			}, cid)

			npcHandler.topic[cid] = 1
			return true
		end

		if questState == 1 then
			npcHandler:say("To restore the caravan, I still need " .. getMaterialsText(caravanRepairMaterials) .. ". Have you brought everything?", cid)
			npcHandler.topic[cid] = 2
			return true
		end
	end

	if msgcontains(msg, "yes") then
		if npcHandler.topic[cid] == 1 then
			npcHandler:say({
				"Good. Then listen carefully.",
				"The cyclops ambushed me in the mountain passage north of Thais, and parts of the caravan were scattered all along the road.",
				"Search the passage and recover what you can. I will need " .. getMaterialsText(caravanRepairMaterials) .. " before I can rebuild it.",
				"You can get nails from War Golems, Worker Golems and Rustheap Golems."
			}, cid)

			player:setStorageValue(STORAGE_CARAVAN_QUEST, 1)
			npcHandler.topic[cid] = 0
			return true
		end

		if npcHandler.topic[cid] == 2 then
			if not hasMaterials(player, caravanRepairMaterials) then
				npcHandler:say("You do not have everything yet. I still need " .. getMaterialsText(caravanRepairMaterials) .. ".", cid)
				npcHandler.topic[cid] = 0
				return true
			end

			removeMaterials(player, caravanRepairMaterials)

			player:setStorageValue(STORAGE_CARAVAN_UNLOCK, 1)
			player:setStorageValue(STORAGE_CARAVAN_STORAGE_LEVEL, 1)
			player:setStorageValue(STORAGE_CARAVAN_QUEST, 2)
			player:setStorageValue(STORAGE_CARAVAN_VISUALS_QUESTLOG, 1)
			player:setStorageValue(222250, 1)
			player:setStorageValue(222260, 1)
			player:setStorageValue(222270, 1)
			player:setStorageValue(222280, 1)
			player:setStorageValue(222290, 1)
			player:setStorageValue(222300, 1)
			player:setStorageValue(222310, 1)

			npcHandler:say({
				"Perfect. With these, I can finally restore the old frame.",
				"There... your first caravan is ready. It is simple, but sturdy, and it will serve you well on the road.",
				"From now on, when you travel mounted, you may call upon your own caravan. Take good care of it, traveler."
			}, cid)

			npcHandler.topic[cid] = 0
			return true
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())