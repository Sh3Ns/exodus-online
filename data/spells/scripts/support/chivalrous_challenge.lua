local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)

function retrieveDistance(creature, target)
    if target:isMonster() then
        local monsterType = target:getType()
        if monsterType then
            local targetDistance = monsterType:targetDistance()
            if not target:getMaster() and targetDistance and targetDistance > 1 then
                return true
            end
        end
    end
    return false
end

combat:setCallback(CALLBACK_PARAM_CHAINPICKER, "retrieveDistance")

function getMonstersTarget(creature)
    return 4, 6, false
end

combat:setCallback(CALLBACK_PARAM_CHAINVALUE, "getMonstersTarget")

local TAUNT_DURATION = 12000
local tauntedTypes = {}

local function releaseTaunt(monsterTypeName)
    local info = tauntedTypes[monsterTypeName]
    if not info then
        return
    end

    info.count = info.count - 1

    if info.count <= 0 then
        if info.mtype then
            info.mtype:setTargetDistance(info.origDist)
        end
        tauntedTypes[monsterTypeName] = nil
    end
end

function setMonsterTargetDistance(creature, target)
    if not target or not target:isMonster() then
        return true
    end

    local monsterType = target:getType()
    if not monsterType then
        return true
    end

    local name = monsterType:getName():lower()
    local current = monsterType:targetDistance()

    if not current or current <= 1 then
        return true
    end

    local info = tauntedTypes[name]

    if not info then
        tauntedTypes[name] = {
            mtype = monsterType,
            origDist = current,
            count = 1
        }
        monsterType:setTargetDistance(1)
    else
        info.count = info.count + 1
    end

    if target:getTarget() ~= creature then
        target:setTarget(creature)
    end

    addEvent(releaseTaunt, TAUNT_DURATION, name)
    return true
end

combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "setMonsterTargetDistance")

function onCastSpell(creature, variant)
    local target = creature:getTarget()
    if not target then
        creature:sendCancelMessage("You need a target.")
        creature:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local targets = {target}
    local targetPosition = target:getPosition()
    local spectators = Game.getSpectators(targetPosition, false, false, 5, 5, 5, 5)

    for _, spectator in ipairs(spectators) do
        if #targets >= 4 then break end
        if spectator and spectator:isMonster() and spectator:getId() ~= target:getId() then
            table.insert(targets, spectator)
        end
    end

    for _, t in ipairs(targets) do
        local var = Variant(t:getId())
        combat:execute(creature, var)
    end

    playSound(creature, "amp.ogg")
    return true
end