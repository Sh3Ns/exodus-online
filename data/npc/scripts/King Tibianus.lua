 local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local STORAGE_CARAVAN_VISUALS_QUESTLOG = 222239
local STORAGE_ROYAL_CARAVAN_UNLOCK = 222230
local STORAGE_ROYAL_CARAVAN_QUEST = 222250
local ROYAL_SEAL_ITEMID = 30639
local ROYAL_SEAL_COUNT = 10

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

--[[ Promotion
local promoteKeyword = keywordHandler:addKeyword({'promot'}, StdModule.say, {npcHandler = npcHandler, text = '{Log out and log in} to be promoted. No need to buy, it is automatic at level 20.'})
	promoteKeyword:addChildKeyword({'yes'}, StdModule.promotePlayer, {npcHandler = npcHandler, level = 20, cost = 20000})
	promoteKeyword:addChildKeyword({''}, StdModule.say, {npcHandler = npcHandler, text = 'Ok, whatever.', reset = true})
]]--
	 
local node1 = keywordHandler:addKeyword({'promot'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can promote you for 20000 gold coins. Do you want me to promote you?'})
	node1:addChildKeyword({'yes'}, StdModule.promotePlayer, {npcHandler = npcHandler, cost = 20000, level = 20, text = 'Congratulations! You are now promoted.'})
	node1:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Alright then, come back when you are ready.', reset = true})
-- The New Frontier
-- Incorrect
local bribeKeyword = keywordHandler:addKeyword({'farmine'}, StdModule.say, {npcHandler = npcHandler, text = 'Ah, I vaguely remember that our little allies were eager to build some base. So speak up, what do you want?'}, function(player) return player:getStorageValue(Storage.TheNewFrontier.Questline) <= 15 end)
	bribeKeyword:addChildKeyword({'flatter'}, StdModule.say, {npcHandler = npcHandler, text = 'Indeed, indeed. Without the help of Thais, our allies stand no chance! Well, I\'ll send some money to support their cause.', reset = true},
		function(player) return player:getStorageValue(Storage.TheNewFrontier.BribeKing) ~= 1 end,
		function(player) player:setStorageValue(Storage.TheNewFrontier.BribeKing, 1) player:setStorageValue(Storage.TheNewFrontier.Mission05, player:getStorageValue(Storage.TheNewFrontier.Mission05) + 1) end
	)

-- Basic
keywordHandler:addKeyword({'eremo'}, StdModule.say, {npcHandler = npcHandler, text = 'It is said that he lives on a small island near Edron. Maybe the people there know more about him.'})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = 'I am your sovereign, King Tibianus III, and it\'s my duty to uphold {justice} and provide guidance for my subjects.'})
keywordHandler:addKeyword({'justice'}, StdModule.say, {npcHandler = npcHandler, text = 'I try my best to be just and fair to our citizens. The army and the {TBI} are a great help in fulfilling this duty.'})
keywordHandler:addKeyword({'name'}, StdModule.say, {npcHandler = npcHandler, text = 'Preposterous! You must know the name of your own King!'})
keywordHandler:addKeyword({'news'}, StdModule.say, {npcHandler = npcHandler, text = 'The latest news is usually brought to our magnificent town by brave adventurers. They recount tales of their journeys at Frodo\'s tavern.'})
keywordHandler:addKeyword({'how', 'are', 'you'}, StdModule.say, {npcHandler = npcHandler, text = 'Thank you, I\'m fine.'})
keywordHandler:addKeyword({'castle'}, StdModule.say, {npcHandler = npcHandler, text = 'Rain Castle is my home.'})
keywordHandler:addKeyword({'sell'}, StdModule.say, {npcHandler = npcHandler, text = 'Sell? Sell what? My kingdom isn\'t for sale!'})
keywordHandler:addKeyword({'god'}, StdModule.say, {npcHandler = npcHandler, text = 'Honour the Gods and above all pay your {taxes}.'})
keywordHandler:addKeyword({'zathroth'}, StdModule.say, {npcHandler = npcHandler, text = 'Please ask a priest about the gods.'})
keywordHandler:addKeyword({'citizen'}, StdModule.say, {npcHandler = npcHandler, text = 'The citizens of Tibia are my subjects. Ask the old monk Quentin if you want to learn more about them.'})
keywordHandler:addKeyword({'sam'}, StdModule.say, {npcHandler = npcHandler, text = 'He is a skilled blacksmith and a loyal subject.'})
keywordHandler:addKeyword({'frodo'}, StdModule.say, {npcHandler = npcHandler, text = 'He is the owner of Frodo\'s Hut and a faithful tax-payer.'})
keywordHandler:addKeyword({'gorn'}, StdModule.say, {npcHandler = npcHandler, text = 'He was once one of Tibia\'s greatest fighters. Now he sells equipment.'})
keywordHandler:addKeyword({'benjamin'}, StdModule.say, {npcHandler = npcHandler, text = 'He was once my greatest general. Now he is very old and senile so we assigned him to work for the Royal Tibia Mail.'})
keywordHandler:addKeyword({'noodles'}, StdModule.say, {npcHandler = npcHandler, text = 'The royal poodle Noodles is my greatest {treasure}!'})
keywordHandler:addKeyword({'ferumbras'}, StdModule.say, {npcHandler = npcHandler, text = 'He is a follower of the evil God Zathroth and responsible for many attacks on us. Kill him on sight!'})
keywordHandler:addKeyword({'bozo'}, StdModule.say, {npcHandler = npcHandler, text = 'He is my royal jester and cheers me up now and then.'})
keywordHandler:addKeyword({'treasure'}, StdModule.say, {npcHandler = npcHandler, text = 'The royal poodle Noodles is my greatest treasure!'})
keywordHandler:addKeyword({'monster'}, StdModule.say, {npcHandler = npcHandler, text = 'Go and hunt them! For king and country!'})
keywordHandler:addKeyword({'help'}, StdModule.say, {npcHandler = npcHandler, text = 'Visit Quentin the monk for help.'})
keywordHandler:addKeyword({'sewer'}, StdModule.say, {npcHandler = npcHandler, text = 'What a disgusting topic!'})
keywordHandler:addKeyword({'dungeon'}, StdModule.say, {npcHandler = npcHandler, text = 'Dungeons are no places for kings.'})
keywordHandler:addKeyword({'equipment'}, StdModule.say, {npcHandler = npcHandler, text = 'Feel free to buy it in our town\'s fine shops.'})
keywordHandler:addKeyword({'food'}, StdModule.say, {npcHandler = npcHandler, text = 'Ask the royal cook for some food.'})
keywordHandler:addKeyword({'tax collector'}, StdModule.say, {npcHandler = npcHandler, text = 'That tax collector is the bane of my life. He is so lazy. I bet you haven\'t payed any taxes at all.'})
keywordHandler:addKeyword({'king'}, StdModule.say, {npcHandler = npcHandler, text = 'I am the king, so watch what you say!'})
keywordHandler:addKeyword({'army'}, StdModule.say, {npcHandler = npcHandler, text = 'Ask the soldiers about that.'})
keywordHandler:addKeyword({'shop'}, StdModule.say, {npcHandler = npcHandler, text = 'Visit the shops of our merchants and craftsmen.'})
keywordHandler:addKeyword({'guild'}, StdModule.say, {npcHandler = npcHandler, text = 'The four major guilds are the knights, the paladins, the druids, and the sorcerers.'})
keywordHandler:addKeyword({'minotaur'}, StdModule.say, {npcHandler = npcHandler, text = 'Vile monsters, but I must admit they are strong and sometimes even cunning ... in their own bestial way.'})
keywordHandler:addKeyword({'good'}, StdModule.say, {npcHandler = npcHandler, text = 'The forces of good are hard pressed in these dark times.'})
keywordHandler:addKeyword({'evil'}, StdModule.say, {npcHandler = npcHandler, text = 'We need all strength we can muster to smite evil!'})
keywordHandler:addKeyword({'order'}, StdModule.say, {npcHandler = npcHandler, text = 'We need order to survive!'})
keywordHandler:addKeyword({'chaos'}, StdModule.say, {npcHandler = npcHandler, text = 'Chaos arises from selfishness.'})
keywordHandler:addKeyword({'excalibug'}, StdModule.say, {npcHandler = npcHandler, text = 'It\'s the sword of the Kings. If you return this weapon to me I will {reward} you beyond your wildest dreams.'})
keywordHandler:addKeyword({'reward'}, StdModule.say, {npcHandler = npcHandler, text = 'Well, if you want a reward, go on a quest to bring me Excalibug!'})
keywordHandler:addKeyword({'chester'}, StdModule.say, {npcHandler = npcHandler, text = 'A very competent person. A little nervous but very competent.'})
keywordHandler:addKeyword({'tbi'}, StdModule.say, {npcHandler = npcHandler, text = 'This organisation is an essential tool for holding our enemies in check. Its headquarter is located in the bastion in the northwall.'})
keywordHandler:addKeyword({'tibia'}, StdModule.say, {npcHandler = npcHandler, text = 'Soon the whole land will be ruled by me once again!'})
keywordHandler:addAliasKeyword({'land'})
keywordHandler:addKeyword({'harkath'}, StdModule.say, {npcHandler = npcHandler, text = 'Harkath Bloodblade is the general of our glorious {army}.'})
keywordHandler:addAliasKeyword({'bloodblade'})
keywordHandler:addAliasKeyword({'general'})
keywordHandler:addKeyword({'quest'}, StdModule.say, {npcHandler = npcHandler, text = 'I will call for heroes as soon as the need arises again and then reward them appropriately.'})
keywordHandler:addAliasKeyword({'mission'})
keywordHandler:addKeyword({'gold'}, StdModule.say, {npcHandler = npcHandler, text = 'To pay your taxes, visit the royal tax collector.'})
keywordHandler:addAliasKeyword({'money'})
keywordHandler:addAliasKeyword({'tax'})
keywordHandler:addAliasKeyword({'collector'})
keywordHandler:addKeyword({'time'}, StdModule.say, {npcHandler = npcHandler, text = 'It\'s a time for heroes!'})
keywordHandler:addAliasKeyword({'hero'})
keywordHandler:addAliasKeyword({'adventurer'})
keywordHandler:addKeyword({'enemy'}, StdModule.say, {npcHandler = npcHandler, text = 'Our enemies are numerous. The evil minotaurs, Ferumbras, and the renegade city of Carlin to the north are just some of them.'})
keywordHandler:addAliasKeyword({'enemies'})
keywordHandler:addKeyword({'carlin'}, StdModule.say, {npcHandler = npcHandler, text = 'They dare to reject my reign over the whole continent!'})
keywordHandler:addKeyword({'thais'}, StdModule.say, {npcHandler = npcHandler, text = 'Our beloved city has some fine shops, guildhouses and a modern sewerage system.'})
keywordHandler:addAliasKeyword({'city'})
keywordHandler:addKeyword({'merchant'}, StdModule.say, {npcHandler = npcHandler, text = 'Ask around about them.'})
keywordHandler:addAliasKeyword({'craftsmen'})
keywordHandler:addKeyword({'paladin'}, StdModule.say, {npcHandler = npcHandler, text = 'The paladins are great protectors for Thais.'})
keywordHandler:addAliasKeyword({'elane'})
keywordHandler:addKeyword({'knight'}, StdModule.say, {npcHandler = npcHandler, text = 'The brave knights are necessary for human survival in Thais.'})
keywordHandler:addAliasKeyword({'gregor'})
keywordHandler:addKeyword({'sorcerer'}, StdModule.say, {npcHandler = npcHandler, text = 'The magic of the sorcerers is a powerful tool to smite our enemies.'})
keywordHandler:addAliasKeyword({'muriel'})
keywordHandler:addKeyword({'druid'}, StdModule.say, {npcHandler = npcHandler, text = 'We need the druidic healing powers to fight evil.'})
keywordHandler:addAliasKeyword({'marvik'})

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	if not player then
		return false
	end

	local royalQuestState = player:getStorageValue(STORAGE_ROYAL_CARAVAN_QUEST)

	if msgcontains(msg, "royal caravan") then
		if player:getStorageValue(STORAGE_ROYAL_CARAVAN_UNLOCK) == 1 then
			npcHandler:say("The Royal Caravan design has already been granted to you. Carry the colors of Thais with dignity.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if royalQuestState == 1 then
			npcHandler:say({
				"A Royal Caravan is not a common wagon, but a symbol once reserved for the house of Thais.",
				"Such a design may only be granted to subjects who have proven useful to the crown.",
				"If thou wishest to earn the right to bear it, I may have a task worthy of thee. Dost thou accept?"
			}, cid)

			npcHandler.topic[cid] = 20
			return true
		end

		if royalQuestState == 2 then
			npcHandler:say("The stolen seals of the crown must be recovered. Bring me 10 royal seals, and I shall consider thy request for the Royal Caravan. Hast thou brought them?", cid)
			npcHandler.topic[cid] = 21
			return true
		end

		if royalQuestState == 3 then
			npcHandler:say("The Royal Caravan design has already been granted to you. Carry the colors of Thais with dignity.", cid)
			npcHandler.topic[cid] = 0
			return true
		end
	end

	if msgcontains(msg, "yes") then
		if npcHandler.topic[cid] == 20 then
			npcHandler:say({
				"Very well.",
				"Royal couriers travelling the roads of Thais have recently been attacked, and several seals of the crown were stolen.",
				"Recover 10 royal seals from Renegade Knights, Vicious Squires and Vile Grandmasters, and return them to me.",
				"Fulfil this duty, and the right to use the Royal Caravan shall be thine."
			}, cid)

			player:setStorageValue(STORAGE_CARAVAN_VISUALS_QUESTLOG, 1)
			player:setStorageValue(STORAGE_ROYAL_CARAVAN_QUEST, 2)

			npcHandler.topic[cid] = 0
			return true
		end

		if npcHandler.topic[cid] == 21 then
			if player:getItemCount(ROYAL_SEAL_ITEMID) < ROYAL_SEAL_COUNT then
				npcHandler:say("Thou hast not recovered enough royal seals yet. I still require 10 royal seals.", cid)
				npcHandler.topic[cid] = 0
				return true
			end

			player:removeItem(ROYAL_SEAL_ITEMID, ROYAL_SEAL_COUNT)
			player:setStorageValue(STORAGE_ROYAL_CARAVAN_UNLOCK, 1)
			player:setStorageValue(STORAGE_ROYAL_CARAVAN_QUEST, 3)

			npcHandler:say({
				"These are indeed the stolen seals of the crown. Thou hast served Thais well.",
				"By my will, the right to bear the colors of Thais upon thy caravan shall be thine.",
				"Accept this honor, and let thy passage remind all who see it that the crown still watches over the roads."
			}, cid)

			npcHandler.topic[cid] = 0
			return true
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:setMessage(MESSAGE_GREET, 'I greet thee, my loyal subject |PLAYERNAME|. Are you looking for the {Royal Caravan} ?')
npcHandler:setMessage(MESSAGE_FAREWELL, 'Good bye, |PLAYERNAME|!')
npcHandler:setMessage(MESSAGE_WALKAWAY, 'How rude!')

local focusModule = FocusModule:new()
focusModule:addGreetMessage('hail king')
focusModule:addGreetMessage('salutations king')
npcHandler:addModule(focusModule)
