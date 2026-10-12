local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end
 
-- Travel
local function addTravelKeyword(keyword, cost, destination)
	local travelKeyword = keywordHandler:addKeyword({keyword}, StdModule.say, {npcHandler = npcHandler, text = 'Do you seek a passage to ' .. keyword:titleCase() .. ' for ' .. cost .. ' gold?', cost = cost, discount = 'postman'})
		travelKeyword:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, cost = cost, discount = 'postman', destination = destination})
		travelKeyword:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, text = 'We would like to serve you some time.', reset = true})
end

addTravelKeyword('gray island', 160, Position(33196, 31984, 7))

-- Kick
keywordHandler:addKeyword({'kick'}, StdModule.kick, {npcHandler = npcHandler, destination = {Position(33288, 32474, 6), Position(33291, 32474, 6), Position(33293, 32471, 6)}})

-- Basic
keywordHandler:addKeyword({'darashia'}, StdModule.say, {npcHandler = npcHandler, text = "That's where we are."})
keywordHandler:addKeyword({'name'}, StdModule.say, {npcHandler = npcHandler, text = 'It\'s Petros.'})
local function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    if not player then
        return false
    end

    if not npcHandler:isFocused(cid) then
        return false
    end

    if msg:lower():find('travel') then
        MapTravel.launchMapTravel(player, "Darashia")
        npcHandler:say("Opening the travel map for you!", cid)
        return true
    end

    return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, 'Welcome on board, |PLAYERNAME|. Where you want to {travel} today?')
npcHandler:setMessage(MESSAGE_FAREWELL, "Bye.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Bye")

npcHandler:addModule(FocusModule:new())
