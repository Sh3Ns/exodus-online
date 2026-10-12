-- local staminaOnTrainer = MoveEvent()

-- local coolDownStorageID = 327144
-- local coolDownSeconds = 120

-- local function Stamina(playerId, ticks)
--     local player = Player(playerId)
--     if not player then
--         return
--     end

--     if ticks <= 0 then
--         return
--     end

--     player:setStamina(math.min(2520, player:getStamina() + 1))
--     player:sendTextMessage(MESSAGE_INFO_DESCR, "Regenerating Stamina.")

--     addEvent(Stamina, 60000, playerId, ticks - 1)
-- end

-- function staminaOnTrainer.onStepIn(player, item, position, fromPosition)
--     local now = os.time()
--     if player:getStorageValue(coolDownStorageID) > now then
--         player:sendCancelMessage("You are exhausted.")
--         return true
--     end

--     player:setStorageValue(coolDownStorageID, now + coolDownSeconds)
--     Stamina(player:getId(), coolDownSeconds)

--     return true
-- end

-- staminaOnTrainer:aid(47777)
-- staminaOnTrainer:register()
