local creatureEvent = CreatureEvent("onVocationsDeathGiftOfLife")

local SECOND_CHANCE_STORAGE = 405900
local COOLDOWN = 300
local HEAL_PERCENT = 10
local HEAL_DOUBLED_PERCENT = 20
local storageDouble = 405905

function creatureEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not creature:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    local player = creature

    local now = os.time()
    local lastUse = player:getStorageValue(SECOND_CHANCE_STORAGE)
    if lastUse == -1 then
        lastUse = 0
    end

    local incomingDamage = primaryDamage + secondaryDamage
    local currentHp = player:getHealth()
    if incomingDamage >= currentHp then
        if now - lastUse >= COOLDOWN then
            if player:getStorageValue(storageDouble) == 1 then
                player:setStorageValue(SECOND_CHANCE_STORAGE, now)
                local maxHp = player:getMaxHealth()
                local healAmount = math.floor(maxHp * HEAL_DOUBLED_PERCENT / 100)
                player:addHealth(healAmount)
                player:getPosition():sendMagicEffect(185)
                player:sendTextMessage(MESSAGE_INFO_DESCR, "Your faith saved you!")
                return 0, primaryType, 0, secondaryType
            else
                player:setStorageValue(SECOND_CHANCE_STORAGE, now)
                local maxHp = player:getMaxHealth()
                local healAmount = math.floor(maxHp * HEAL_PERCENT / 100)
                player:addHealth(healAmount)
                player:getPosition():sendMagicEffect(185)
                player:sendTextMessage(MESSAGE_INFO_DESCR, "Your faith saved you!")
                return 0, primaryType, 0, secondaryType
            end
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

creatureEvent:register()

local LoginEvent = CreatureEvent("VocationsGiftOfLifeLogin")

function LoginEvent.onLogin(player)
  player:registerEvent("onVocationsDeathGiftOfLife")
  return true
end

LoginEvent:type("login")
LoginEvent:register()