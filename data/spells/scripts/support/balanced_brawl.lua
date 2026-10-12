local area = {
    {0,0,0,0,0,0,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,1,1,0,0,0,0,0},
    {0,0,0,0,1,1,1,1,1,0,0,0,0},
    {0,0,0,1,1,1,1,1,1,1,0,0,0},
    {0,0,1,1,1,1,1,1,1,1,0,0,0},
    {0,1,1,1,1,1,1,1,1,1,1,1,0},
    {0,1,1,1,1,0,3,0,1,1,1,1,0},
    {1,1,1,1,1,0,0,0,1,1,1,1,1},
}

local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setArea(createCombatArea(area))

local TAUNT_DURATION = 16000
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
    playSound(creature, "death.ogg")
    return combat:execute(creature, variant)
end