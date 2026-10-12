local mentorStorage = 405906

local condition = Condition(CONDITION_ATTRIBUTES)
condition:setParameter(CONDITION_PARAM_TICKS, 60000)

function onCastSpell(creature, variant)
    local target = Creature(variant:getNumber())
    for _, player in ipairs({creature, target}) do
        if player and player:isPlayer() then
            player:setStorageValue(mentorStorage, 1)
            player:addCondition(condition)
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
            addEvent(function(pid)
                local p = Player(pid)
                if p then
                    p:setStorageValue(mentorStorage, -1)
                end
            end, 60000, player:getId())
        end
    end
    playSound(creature, "divine_2.ogg")
    return true
end