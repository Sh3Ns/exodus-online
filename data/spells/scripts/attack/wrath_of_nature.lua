local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_SMALLPLANTS)
combat:setArea(createCombatArea(AREA_CIRCLE6X6))

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 3) + 32
	local max = (level / 5) + (magicLevel * 9) + 40
	local helmet = player:getSlotItem(CONST_SLOT_HEAD)
    if helmet and helmet:getId() == 30015 then
        min = math.floor(min * 1.05)
        max = math.floor(max * 1.05)
    end
	local armor = player:getSlotItem(CONST_SLOT_ARMOR)
    if armor and armor:getId() == 30020 then
        min = math.floor(min * 1.08)
        max = math.floor(max * 1.08)
    end
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local COOLDOWN_STORAGE = 309457
local COOLDOWN_TIME = 40

function onCastSpell(creature, variant)
	local currentTime = os.time()
    local lastCastTime = creature:getStorageValue(COOLDOWN_STORAGE)
    if lastCastTime < currentTime then
        creature:setStorageValue(COOLDOWN_STORAGE, currentTime + COOLDOWN_TIME)
		playSound(creature, "earth_3.ogg")
		return combat:execute(creature, variant)
	else
		local remainingCooldown = lastCastTime - currentTime
        creature:sendTextMessage(MESSAGE_INFO_DESCR, "You must wait " .. remainingCooldown .. " seconds.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
	end
end
