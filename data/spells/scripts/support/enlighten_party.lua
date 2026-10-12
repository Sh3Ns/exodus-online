local DURATION = 1 * 30 * 1000
local MANA_TICKS = 2000
local RANGE = 6

local function createRegenCondition()
    local condition = Condition(CONDITION_REGENERATION)
    condition:setParameter(CONDITION_PARAM_TICKS, DURATION)
    condition:setParameter(CONDITION_PARAM_MANATICKS, MANA_TICKS)
    condition:setParameter(CONDITION_PARAM_MANAGAIN, math.random(8, 16))
    return condition
end

function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then
        return false
    end

    player:addCondition(createRegenCondition())
    player:getPosition():sendMagicEffect(203)

    local party = player:getParty()
    if party then
        for _, member in ipairs(party:getMembers()) do
            if member:getPosition():getDistance(player:getPosition()) <= RANGE then
                member:addCondition(createRegenCondition())
                member:getPosition():sendMagicEffect(203)
            end
        end
    end

    playSound(creature, "mana_potion.ogg")
    if type(_G.GemsSocket_tryTriggerBoonstone) == "function" then
        _G.GemsSocket_tryTriggerBoonstone(player)
    end
    return true
end
