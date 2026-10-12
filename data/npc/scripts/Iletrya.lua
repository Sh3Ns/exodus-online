local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local voices = { {text = 'Waystone Device Expedition'} }
npcHandler:addModule(VoiceModule:new(voices))


local REWARD_ITEM = 29628 -- Waystone Portal Kit
local STORAGE_FINISHED = Expeditions.WaystoneDeviceFinished

local function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end

    local player = Player(cid)
    msg = msg:lower()

    if msgcontains(msg, "help") then
        if player:getStorageValue(STORAGE_FINISHED) >= 1 then
            npcHandler:say(
                "You already helped me repair the waystone device. "
                .."You can now use it to travel to other places at your own house.",
                cid
            )
            return true
        end
        if player:removeItem(28345, 10) then
            npcHandler:say("Thanks! Now I can repair the waystone device. Here is the Waystone Portal Kit.", cid)
            if playSoundPlayer then
                playSoundPlayer(player, "expedition_complete.ogg")
            end
            player:addItem(REWARD_ITEM, 1)
            player:setStorageValue(STORAGE_FINISHED, 1)
        else
            local have = player:getItemCount(28345)
            npcHandler:say(
                string.format(
                    "Collect or craft %d Exalted Core to refill the device's energy. "
                    .."You currently have %d/%d. Come back when you're ready.",
                    10, have, 10
                ),
                cid
            )
        end
        return true
    end

    return true
end

npcHandler:setMessage(MESSAGE_GREET,
'Look at this strange device, I have never seen something like it. Apparently you can use it to travel to other places. To repair it you need to {help} me with a small task. Are you interested?')
npcHandler:setMessage(MESSAGE_FAREWELL, 'Good bye!')
npcHandler:setMessage(MESSAGE_WALKAWAY, 'Good bye then.')
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())