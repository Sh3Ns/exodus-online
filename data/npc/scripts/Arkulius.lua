local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local voices = {
    { text = "...the arithmetical paradox has the same value in a metaphysical way, then..." },
    { text = "Oh my! Alverus!! Did you really...?!?! I have to recalculate it to make sure that I made no mistake." },
    { text = "<mumbles>" },
    { text = "...the minimum square deviation could cause a dislocation, in a matter of fact..." },
    { text = "...it could be possible to bring the sphere to a destination where..." },
    { text = "Yes, that's it! The elementary particle are corresponding to the... the ... UNBELIEVEABLE!!!" }
}

npcHandler:addModule(VoiceModule:new(voices))

local greetMsg = {
    "...if the expected constant is higher than... Hmmm, who are you?? What do you want?",
    "...then I could transform a spell to bend... How can anyone expect me to work under these conditions?? What do you want?",
    "...if my calculations are correct, I will be able to revive... Arrgghh!! What do you want?"
}

local function greetCallback(cid)
    npcHandler:setMessage(MESSAGE_GREET, greetMsg[math.random(#greetMsg)])
    npcHandler.topic[cid] = 0
    return true
end

local function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then return false end

    local player = Player(cid)
    if not player then return false end

    local msgLower = msg:lower()

    if msgcontains(msgLower, "alverus") then
        npcHandler:say({
            "It happened while he carried out an experiment concerning the creation of the elemental {shrines}. I still get goose bumps just by thinking of it. ...",
            "You need to know about the process of creating an elemental shrine to understand it completely, but I don't want to go into detail now. ...",
            "Anyway, his spell had a different outcome than he had planned. He accidentally created an Ice Overlord, pure living elemental ice, who froze him in a blink of an eye."
        }, cid)
        npcHandler.topic[cid] = 0

    elseif msgcontains(msgLower, "shrine") then
        npcHandler:say({
            "The creation of the elemental shrines is a really complex matter. They are actually nodes, locations where the matching elemental sphere is very close. ...",
            "The shrine itself is like a portal between our world and the elemental {sphere} and enables us to use the elemental energy emerging from it."
        }, cid)
        npcHandler.topic[cid] = 0

    elseif msgcontains(msgLower, "sphere") and player:getLevel() >= 80 then
        npcHandler:say({
            "There are four spheres we know of: ice, fire, earth and energy. ....<mumbles> Hmmm, should I ask or not?....The heck with it! Now that you know about the spheres ...",
            "I found a way to visit them. It's VERY dangerous and there is a decent chance that you won't come back BUT if you succeed you'll write history!!! Ask me about that {mission} if you're interested."
        }, cid)
        npcHandler.topic[cid] = 0

    elseif msgcontains(msgLower, "mission") or msgcontains(msgLower, "quest") then
        local value = player:getStorageValue(Storage.ElementalSphere.QuestLine)

        if value < 1 then
            if player:getLevel() >= 80 then
                if player:isSorcerer() or player:isIllusionist() then
                    npcHandler:say({
                        "Okay, listen closely: First of all, you need to gather 20 enchanted rubies in order to go to the fire sphere...",
                        "Once you got there, find a way to gather elemental fire in any form...",
                        "THAT'S what we need!! Are you in on it?"
                    }, cid)
                elseif player:isDruid() then
                    npcHandler:say({
                        "Okay, listen closely: First of all, you need to gather 20 enchanted emeralds in order to go to the earth sphere...",
                        "Once you got there, find a way to gather elemental earth in any form...",
                        "THAT'S what we need!! Are you in on it?"
                    }, cid)
                elseif player:isPaladin() then
                    npcHandler:say({
                        "Okay, listen closely: First of all, you need to gather 20 enchanted sapphires in order to go to the ice sphere...",
                        "Once you got there, find a way to gather elemental ice in any form...",
                        "THAT'S what we need!! Are you in on it?"
                    }, cid)
                elseif player:isKnight() or player:isMonk() then
                    npcHandler:say({
                        "Okay, listen closely: First of all, you need to gather 20 enchanted amethysts in order to go to the energy sphere...",
                        "Once you got there, find a way to gather elemental energy in any form...",
                        "THAT'S what we need!! Are you in on it?"
                    }, cid)
                end
                npcHandler.topic[cid] = 1
            else
                npcHandler:say("I'm sorry this task is highly dangerous and I need experienced people for it.", cid)
                npcHandler.topic[cid] = 0
                return false
            end

        elseif value == 1 then
            local itemId = 0
            if player:isSorcerer() or player:isIllusionist() then itemId = 8304
            elseif player:isDruid() then itemId = 8305
            elseif player:isPaladin() then itemId = 8300
            elseif player:isKnight() or player:isMonk() then itemId = 8306 end

            if itemId > 0 and player:getItemCount(itemId) > 0 then
                player:setStorageValue(Storage.ElementalSphere.QuestLine, 2)

                local elementName =
                    (player:isSorcerer() or player:isIllusionist()) and "an ETERNAL FLAME!" or
                    player:isDruid() and "MOTHER SOIL!" or
                    player:isPaladin() and "a FLAWLESS ICE CRYSTAL!" or
                    player:isKnight() or player:isMonk() and "PURE ENERGY!" or
                    "UNKNOWN ELEMENT!"

                npcHandler:say({
                    "Impressive!! Let me take a look.......Ahh, " .. elementName .. " Now you need to find a knight, a druid, and a paladin who also completed this first task. ...",
                    "Go down in the cellar again. I prepared a room under the academy where it should be safe...",
                    "Use an obsidian knife on the corpse to collect the precious neutral matter. It's the only way to revive my dear friend Alverus!!"
                }, cid)
            else
                local missingElement =
                    (player:isSorcerer() or player:isIllusionist()) and "Fire" or
                    player:isDruid() and "Earth" or
                    player:isPaladin() and "Ice" or
                    player:isKnight() or player:isMonk() and "Energy" or
                    "Unknown"

                npcHandler:say("You need some kind of pure elemental soil from the " .. missingElement .. " Overlord. Come back when you've got it.", cid)
            end
            npcHandler.topic[cid] = 0

        elseif value == 2 then
            if player:getStorageValue(Storage.ElementalSphere.QuestLine) < 3 then
                if player:removeItem(8310, 1) then
                    npcHandler:say("AMAZING!! I'm going to start immediately with the research. If it turns out the way I expect it, Alverus will be revived soon!! Here, take this as a reward and try to collect more of this substance. I'll make you a good offer, I promise.", cid)
                    player:addItem(
                        (player:isSorcerer() or player:isIllusionist()) and 8867 or
                        player:isDruid() and 8869 or
                        player:isPaladin() and 8853 or
                        player:isKnight() or player:isMonk() and 8883 or
                        2160, 1
                    )
                    player:setStorageValue(Storage.ElementalSphere.QuestLine, 3)
                else
                    npcHandler:say("You need to bring me some of that precious neutral matter (item 8310) before we can proceed.", cid)
                end
            end
        end

    elseif npcHandler.topic[cid] == 1 and msgcontains(msgLower, "yes") then
        player:setStorageValue(Storage.ElementalSphere.QuestLine, 1)
        npcHandler:say("Good, don't waste time! Come back here when you have the elemental object!", cid)
        npcHandler.topic[cid] = 0
    end

    return true
end

-- Keyword setup
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = "How dare you asking me this?!? I'm Arkulius - Master of Elements, the HEADMASTER of this academy!!"})
keywordHandler:addKeyword({'name'}, StdModule.say, {npcHandler = npcHandler, text = "I'm Arkulius - Master of Elements, the headmaster of this academy."})
keywordHandler:addKeyword({'help'}, StdModule.say, {npcHandler = npcHandler, text = "I have better things to do than helping you. See that ice statue over there? My dear friend Alverus needs to be revived!"})
keywordHandler:addKeyword({'time'}, StdModule.say, {npcHandler = npcHandler, text = "Time is an illusion and completely irrelevant to me."})
keywordHandler:addKeyword({'weapon'}, StdModule.say, {npcHandler = npcHandler, text = "Weapons are for those people who aren't able to use their heads or better what's INSIDE their heads. No offence <coughs>."})
keywordHandler:addKeyword({'pits of inferno'}, StdModule.say, {npcHandler = npcHandler, text = "Yeye, I believe you almost feel like home among all those brainless creatures!"})

npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye and please stay away, okay?")
npcHandler:setMessage(MESSAGE_FAREWELL, "At last! Good things come to those who wait.")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())