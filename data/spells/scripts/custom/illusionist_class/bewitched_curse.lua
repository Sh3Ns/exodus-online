local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ARCANEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 218)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, 84)

local function applyPeriodicDamage(creatureId, targetId, baseDamage, damageIncrement, interval, duration)
    local iterations = math.floor(duration / interval)
    local currentDamage = baseDamage

    for i = 1, iterations do
        addEvent(function(cid, tid)
            local creature = Creature(cid)
            local target = Creature(tid)

            if creature and target and target:getHealth() > 0 then
                doTargetCombatHealth(cid, tid, COMBAT_ARCANEDAMAGE, -currentDamage, -currentDamage, CONST_ME_NONE)
            end
        end, i * interval, creatureId, targetId)

        currentDamage = currentDamage + damageIncrement
    end
end

function onCastSpell(creature, variant)
    local target = Creature(variant:getNumber())
    if not target then
        return false
    end
    
    local baseDamage = 128     
    local damageIncrement = 128   
    local interval = 2000     
    local duration = 8000      
    playSound(creature, "arcane_4.ogg")
    -- Start applying periodic damage
    applyPeriodicDamage(creature:getId(), target:getId(), baseDamage, damageIncrement, interval, duration)
    
    return true
end
