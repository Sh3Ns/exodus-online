local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
condition:setParameter(CONDITION_PARAM_TICKS, -1)
condition:setParameter(CONDITION_PARAM_SKILL_FISTPERCENT, 108)
condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
condition:setParameter(CONDITION_PARAM_SUBID, 14700)

combat:addCondition(condition)

local storage_virtue = 405901
local storage_sustain = 405902
local storage_harmony = 405903
local subId = 14701
local subId2 = 14702
function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then return false end

    if player:getStorageValue(storage_sustain) == 1 then
        player:setStorageValue(storage_sustain, 0)
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, subId, true)
    end
    if player:getStorageValue(storage_harmony) == 1 then
        player:setStorageValue(storage_harmony, 0)
        player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, subId2, true)
    end

    player:setStorageValue(storage_virtue, 1)
    playSound(player, "utito.ogg")
    local result = combat:execute(player, variant)
    if result and type(_G.GemsSocket_tryTriggerBoonstone) == "function" then
        _G.GemsSocket_tryTriggerBoonstone(player)
    end
    return result
end
