GemsSocketConditionCleanse = GemsSocketConditionCleanse or {}

local removableDebuffs = {}
local removableConditionIds = {
    CONDITIONID_DEFAULT,
    CONDITIONID_COMBAT,
}

local function addRemovableDebuff(conditionType)
    if conditionType then
        removableDebuffs[#removableDebuffs + 1] = conditionType
    end
end

addRemovableDebuff(CONDITION_PARALYZE)
addRemovableDebuff(CONDITION_DRUNK)
addRemovableDebuff(CONDITION_CURSED)
addRemovableDebuff(CONDITION_DAZZLED)
addRemovableDebuff(CONDITION_FREEZING)
addRemovableDebuff(CONDITION_BLEEDING)
addRemovableDebuff(CONDITION_FIRE)
addRemovableDebuff(CONDITION_POISON)
addRemovableDebuff(CONDITION_ENERGY)
addRemovableDebuff(CONDITION_DROWN)
addRemovableDebuff(CONDITION_SPLASHED)
addRemovableDebuff(CONDITION_BEWITCHED)

function GemsSocketConditionCleanse.removeRandomDebuff(player)
    if not player or not player:isPlayer() then
        return false
    end

    local active = {}
    for i = 1, #removableDebuffs do
        local conditionType = removableDebuffs[i]
        if conditionType then
            for idIndex = 1, #removableConditionIds do
                local conditionId = removableConditionIds[idIndex]
                if conditionId and player:getCondition(conditionType, conditionId) then
                    active[#active + 1] = { type = conditionType, id = conditionId }
                end
            end
        end
    end

    if #active == 0 then
        return false
    end

    local condition = active[math.random(#active)]
    player:removeCondition(condition.type, condition.id)
    return true
end

function GemsSocketConditionCleanse.removeAllDebuffs(player)
    if not player or not player:isPlayer() then
        return false
    end

    local removed = false
    for i = 1, #removableDebuffs do
        local conditionType = removableDebuffs[i]
        if conditionType then
            for idIndex = 1, #removableConditionIds do
                local conditionId = removableConditionIds[idIndex]
                if conditionId and player:getCondition(conditionType, conditionId) then
                    player:removeCondition(conditionType, conditionId)
                    removed = true
                end
            end
        end
    end
    return removed
end

function GemsSocket_runPurityGemCleanse(playerId)
    local player = Player(playerId)
    if not player then
        return
    end

    local getBonusTotal = _G.GemsSocket_getEquippedSocketBonusTotal
    if type(getBonusTotal) ~= "function" or getBonusTotal(player, "socket_purity_cleanse") <= 0 then
        return
    end

    if GemsSocketConditionCleanse.removeAllDebuffs(player) then
        player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    end
end

function GemsSocket_tryTriggerPurityGemCleanse(player, totals)
    local getBonusTotal = _G.GemsSocket_getEquippedSocketBonusTotal
    local cleanseEnabled = totals and (totals.socket_purity_cleanse or 0)
        or type(getBonusTotal) == "function" and getBonusTotal(player, "socket_purity_cleanse") or 0
    if not player or not player:isPlayer() or cleanseEnabled <= 0 then
        return
    end

    if GemsSocketConditionCleanse.removeAllDebuffs(player) then
        player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
    end
    addEvent(GemsSocket_runPurityGemCleanse, 100, player:getId())
end

function GemsSocket_removeRandomSocketDebuff(player)
    return GemsSocketConditionCleanse.removeRandomDebuff(player)
end
