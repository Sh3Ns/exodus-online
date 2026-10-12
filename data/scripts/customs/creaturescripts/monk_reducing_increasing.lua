local creatureEvent = CreatureEvent("onMonkandKnightReducingDamage")

local mentorStorage = 405906

function creatureEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not creature:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
     if creature:isPlayer() and creature:getStorageValue(mentorStorage) == 1 then
        if creature:isKnight() or creature:isMonk() then
            primaryDamage = math.floor(primaryDamage * 0.97) -- Wikipedia 3% Reduction
        end
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

creatureEvent:register()


local creatureEvent = CreatureEvent("onPaladinDamageBoost")

local mentorStorage = 405906

function creatureEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if attacker and attacker:isPlayer() then
        if attacker:getStorageValue(mentorStorage) == 1 and attacker:isPaladin() then
            primaryDamage = math.floor(primaryDamage * 1.05) --- Wikipedia 5% Increase damage of paladins
        end
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

creatureEvent:register()

local LoginEvent = CreatureEvent("MonkKnightReducing")

function LoginEvent.onLogin(player)
  player:registerEvent("onMonkandKnightReducingDamage")
  player:registerEvent("onPaladinDamageBoost")
  return true
end

LoginEvent:type("login")
LoginEvent:register()

--- For Sorc & Druids is scripted directly on each spell, with a storage increasing damage & heal