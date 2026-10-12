local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

local allBlessNode = keywordHandler:addKeyword(
    {'all bless'},
    StdModule.say,
    {
        npcHandler = npcHandler,
        onlyFocus = true,
        text = 'Do you want to buy all five blessings for 50000 gold?'
    }
)

allBlessNode:addChildKeyword(
    {'yes'},
    function(cid)
        local player = Player(cid)
        if not player then
            return false
        end

        local hasAll = true
        for i = 1, 5 do
            if not player:hasBlessing(i) then
                hasAll = false
                break
            end
        end

        if hasAll then
            npcHandler:say('You already have all five blessings.', cid)
            npcHandler:resetNpc()
            return true
        end

        local cost = 50000
        if not player:removeMoney(cost) then
            npcHandler:say('You do not have enough money.', cid)
            npcHandler:resetNpc()
            return true
        end

        for i = 1, 5 do
            if not player:hasBlessing(i) then
                player:addBlessing(i)
            end
        end

        npcHandler:say('You are now blessed with all five blessings!', cid)
        npcHandler:resetNpc()
        return true
    end
)

allBlessNode:addChildKeyword(
    {'no'},
    StdModule.say,
    {
        npcHandler = npcHandler,
        onlyFocus = true,
        reset = true,
        text = 'Maybe another time then.'
    }
)

npcHandler:addModule(FocusModule:new())