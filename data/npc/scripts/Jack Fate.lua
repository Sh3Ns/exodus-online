local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()		npcHandler:onThink()		end
 
local voices = { {text = 'Passages to Edron, Thais, Venore, Darashia, Ankrahmun, Yalahar and Port Hope.'} }
npcHandler:addModule(VoiceModule:new(voices))

-- Kick
keywordHandler:addKeyword({'kick'}, StdModule.kick, {npcHandler = npcHandler, destination = {Position(32275, 32892, 6), Position(32276, 32891, 6), Position(32277, 32895, 6)}})

-- Basic
keywordHandler:addKeyword({'name'}, StdModule.say, {npcHandler = npcHandler, text = 'My name is Jack Fate from the Royal Tibia Line.'})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = 'I\'m the captain of this sailing ship.'})
keywordHandler:addKeyword({'captain'}, StdModule.say, {npcHandler = npcHandler, text = 'I\'m the captain of this sailing ship.'})
keywordHandler:addKeyword({'liberty bay'}, StdModule.say, {npcHandler = npcHandler, text = 'That\'s where we are.'})

npcHandler:setMessage(MESSAGE_GREET, 'Welcome on board, |PLAYERNAME|. Where you want to {travel} today?')
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye. Recommend us if you were satisfied with our service.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye then.")
local function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    if not player then
        return false
    end

    if not npcHandler:isFocused(cid) then
        return false
    end

    if msg:lower():find('travel') then
        MapTravel.launchMapTravel(player, "LibertyBay")
        npcHandler:say("Opening the travel map for you!", cid)
        return true
    end

    return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
