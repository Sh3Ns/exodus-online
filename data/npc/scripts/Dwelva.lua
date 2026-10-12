local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local STORAGE_CARAVAN_VISUALS_QUESTLOG = 222239
local STORAGE_WAR_CARAVAN_UNLOCK = 222232
local STORAGE_WAR_CARAVAN_QUEST = 222270

local warCaravanMaterials = {
	{id = 5911, count = 20}, -- red piece of cloth
	{id = 5906, count = 5}, -- demon dusts
	{id = 30271, count = 3},  -- bloodwood
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

local function hasWarCaravanMaterials(player)
	for i = 1, #warCaravanMaterials do
		local material = warCaravanMaterials[i]
		if player:getItemCount(material.id) < material.count then
			return false
		end
	end

	return true
end

local function removeWarCaravanMaterials(player)
	for i = 1, #warCaravanMaterials do
		local material = warCaravanMaterials[i]
		player:removeItem(material.id, material.count)
	end
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local voices = {
	{ text = "The desert remembers every battle fought upon it." },
	{ text = "A caravan built for war must endure more than dust and sun." },
	{ text = "Bandits fear steel. Soldiers fear running out of supplies." }
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

	local warQuestState = player:getStorageValue(STORAGE_WAR_CARAVAN_QUEST)

	if msgcontains(msg, "war caravan") then
		if player:getStorageValue(STORAGE_WAR_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("You have already earned the War Caravan design. May it carry your burdens through any battlefield.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if warQuestState == 1 then
			npcHandler:say({
				"So Marek sent you after the War Caravan design.",
				"I once led supply wagons through these sands, before raiders tore my own caravan apart. A true war caravan is not made with pretty wood and merchant cloth. It needs banners, iron, and a heart that has survived battle.",
				"If you wish to earn that design, gather " .. getMaterialsText(warCaravanMaterials) .. " and bring them to me. Will you do this?"
			}, cid)

			npcHandler.topic[cid] = 40
			return true
		end

		if warQuestState == 2 then
			if hasWarCaravanMaterials(player) then
				npcHandler:say({
					"You have brought everything I asked for.",
					"These materials are scarred, but strong. Good. That is exactly what a War Caravan should be.",
					"Take the design. You have earned the right to use it."
				}, cid)

				removeWarCaravanMaterials(player)
				player:setStorageValue(STORAGE_WAR_CARAVAN_UNLOCK, 1)
				player:setStorageValue(STORAGE_WAR_CARAVAN_QUEST, 3)

				npcHandler.topic[cid] = 0
				return true
			end

			npcHandler:say("You have not brought all the materials yet. I still need " .. getMaterialsText(warCaravanMaterials) .. ".", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if warQuestState == 3 then
			npcHandler:say("The War Caravan design is already yours. Treat it better than the desert treated mine.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end

	if msgcontains(msg, "yes") then
		if npcHandler.topic[cid] == 40 then
			npcHandler:say({
				"Then listen well.",
				"Bring me " .. getMaterialsText(warCaravanMaterials) .. ". The desert still holds everything needed, if you know where to search.",
				"Return when you have gathered them all."
			}, cid)

			player:setStorageValue(STORAGE_CARAVAN_VISUALS_QUESTLOG, 1)
			player:setStorageValue(STORAGE_WAR_CARAVAN_QUEST, 2)

			npcHandler.topic[cid] = 0
			return true
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())