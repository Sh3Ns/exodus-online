local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combat:setArea(createCombatArea(AREA_CIRCLE5X5))

local mentorStorage = 405906

function onGetFormulaValues(player, level, magicLevel)
    local handWeapon = player:getSlotItem(CONST_SLOT_LEFT)
    local itemMultipliers = {
        [27476] = 1.10,
        [27477] = 1.20,
    }

    local min = (level / 5) + (magicLevel * 8) + 50
    local max = (level / 5) + (magicLevel * 12) + 75

    if handWeapon and itemMultipliers[handWeapon.itemid] then
        local multiplier = itemMultipliers[handWeapon.itemid]
        min = min * multiplier
        max = max * multiplier
    end

    if player:getStorageValue(mentorStorage) == 1 then
        min = min * 1.05
        max = max * 1.05
    end

    return -math.floor(min), -math.floor(max)
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local COOLDOWN_STORAGE = 309456
local COOLDOWN_TIME = 40

function onCastSpell(creature, variant)
    local currentTime = os.time()
    local lastCastTime = creature:getStorageValue(COOLDOWN_STORAGE)

    if lastCastTime < currentTime then
        creature:setStorageValue(COOLDOWN_STORAGE, currentTime + COOLDOWN_TIME)
        playSound(creature, "fire_3.ogg")
        return combat:execute(creature, variant)
    else
        local remainingCooldown = lastCastTime - currentTime
        creature:sendTextMessage(MESSAGE_INFO_DESCR, "You must wait " .. remainingCooldown .. " seconds.")
        creature:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
end