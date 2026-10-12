local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()		npcHandler:onThink()		end
 
local voices = { {text = 'By direct edict of the honorable Henricus, we are ordered to give passage for all recruits to the Continent.'} }
npcHandler:addModule(VoiceModule:new(voices))


-- Kick
keywordHandler:addKeyword({'kick'}, StdModule.kick, {npcHandler = npcHandler, destination = {Position(33495, 32564, 7), Position(33495, 32563, 7), Position(33496, 32562, 7)}})

-- Basically
keywordHandler:addKeyword({'name'}, StdModule.say, {npcHandler = npcHandler, text = "My name is Chelop and I am a captain of this {inquisition} ship."})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = "Can't you see? I'm captain of the Pesadilla, the proud {inquisition} ship which anchors here."})
keywordHandler:addKeyword({'inquisition'}, StdModule.say, {npcHandler = npcHandler, text = "By edict of the honorable Henricus himself, we are ordered to give passage to all recruits of the Roshamuul mission for a small fee."})
keywordHandler:addKeyword({'roshamuul'}, StdModule.say, {npcHandler = npcHandler, text = "This is the island you are currently on, just in case you forgot."})

local function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    if not player then
        return false
    end

    if not npcHandler:isFocused(cid) then
        return false
    end

    if msg:lower():find('travel') then
        MapTravel.launchMapTravel(player, "Roshamuul")
        npcHandler:say("Opening the travel map for you!", cid)
        return true
    end

    return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:setMessage(MESSAGE_GREET, 'Welcome on board, |PLAYERNAME|. Where you want to {travel} today?')
npcHandler:setMessage(MESSAGE_FAREWELL, "On behalf of the inquisition, I bid you farewell.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye then.")
npcHandler:addModule(FocusModule:new())
