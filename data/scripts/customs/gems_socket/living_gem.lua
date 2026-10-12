LivingGem = LivingGem or {}

LivingGem.gemKey = "livinggem"

local function livingToNumber(value, fallback)
    local number = tonumber(value)
    if number == nil then
        return fallback or 0
    end
    return number
end

local function getLivingGemData()
    return GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[LivingGem.gemKey] or nil
end

local function getLivingStages()
    local gemData = getLivingGemData()
    local stages = gemData and gemData.living and gemData.living.stages or nil
    if type(stages) ~= "table" then
        return {}
    end

    local ordered = {}
    for stageIndex, stageData in pairs(stages) do
        if type(stageData) == "table" then
            ordered[#ordered + 1] = {
                index = math.max(1, tonumber(stageIndex) or (#ordered + 1)),
                form = stageData.form or ("Stage " .. tostring(stageIndex)),
                requiredKills = math.max(0, livingToNumber(stageData.requiredKills, 0)),
                damagePercent = math.max(0, livingToNumber(stageData.damagePercent, 0)),
            }
        end
    end

    table.sort(ordered, function(left, right)
        if left.requiredKills ~= right.requiredKills then
            return left.requiredKills < right.requiredKills
        end
        return left.index < right.index
    end)

    return ordered
end

function LivingGem.isGem(gemKey)
    return gemKey == LivingGem.gemKey
end

function LivingGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_living_", socketIndex)
    end
    return "living_"
end

function LivingGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = LivingGem.getAttributePrefix(socketIndex)
    local kills = math.max(0, livingToNumber(item:getCustomAttribute(prefix .. "kills"), 0))
    if kills <= 0 then
        return nil
    end

    return {
        kills = kills,
    }
end

function LivingGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = LivingGem.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "kills")
end

function LivingGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    LivingGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local kills = math.max(0, livingToNumber(state.kills, 0))
    if kills <= 0 then
        return
    end

    local prefix = LivingGem.getAttributePrefix(socketIndex)
    item:setCustomAttribute(prefix .. "kills", kills)
end

function LivingGem.getProgress(state)
    local kills = math.max(0, livingToNumber(state and state.kills, 0))
    local stages = getLivingStages()
    if #stages == 0 then
        return {
            kills = kills,
            currentStage = nil,
            nextStage = nil,
            percent = 100,
            bar = "[..........]",
        }
    end

    local currentStage = stages[1]
    local nextStage = nil
    for index, stage in ipairs(stages) do
        if kills >= stage.requiredKills then
            currentStage = stage
            nextStage = stages[index + 1]
        else
            nextStage = stage
            break
        end
    end

    local percent = 100
    local filled = 10
    local currentFloor = currentStage and currentStage.requiredKills or 0
    if nextStage then
        local span = math.max(1, nextStage.requiredKills - currentFloor)
        percent = math.max(0, math.min(100, math.floor(((kills - currentFloor) / span) * 100)))
        filled = math.max(0, math.min(10, math.floor(percent / 10)))
    end

    return {
        kills = kills,
        currentStage = currentStage,
        nextStage = nextStage,
        percent = percent,
        bar = string.format("[%s%s]", string.rep("#", filled), string.rep(".", 10 - filled)),
    }
end

function LivingGem.getCompactProgress(state)
    local progress = LivingGem.getProgress(state)
    local currentForm = progress.currentStage and progress.currentStage.form or "Dormant"
    return string.format("Living: %s %s %d%%", currentForm, progress.bar, progress.percent)
end

function LivingGem.buildTooltip(baseTooltip, state)
    local progress = LivingGem.getProgress(state)
    local currentStage = progress.currentStage
    local currentForm = currentStage and currentStage.form or "Dormant"
    local currentPower = currentStage and currentStage.damagePercent or 0
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    lines[#lines + 1] = string.format("Living Form: %s", currentForm)
    lines[#lines + 1] = string.format("Kills Absorbed: %d", progress.kills)
    lines[#lines + 1] = string.format("Current Evolution: %s", currentForm)

    if progress.nextStage then
        lines[#lines + 1] = string.format("Next: %s (%d kills)", progress.nextStage.form, progress.nextStage.requiredKills)
        lines[#lines + 1] = string.format("Progress: %s %d%%", progress.bar, progress.percent)
    else
        lines[#lines + 1] = "Next: Final Evolution"
        lines[#lines + 1] = string.format("Progress: %s MAX", progress.bar)
    end

    lines[#lines + 1] = string.format("Power: +%d%% damage", currentPower)
    return table.concat(lines, "\n")
end

function LivingGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" or type(GemsSocket.EQUIPPED_SOCKET_SLOTS) ~= "table" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, LivingGem.gemKey, callback)
        return
    end

    local hasSockets = _G.GemsSocket_hasSockets
    local getSocketCount = _G.GemsSocket_getSocketCount
    local getSocketGemKey = _G.GemsSocket_getSocketGemKey
    if type(hasSockets) ~= "function" or type(getSocketCount) ~= "function" or type(getSocketGemKey) ~= "function" then
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local item = player:getSlotItem(slot)
        if item and hasSockets(item) then
            for socketIndex = 1, getSocketCount(item) do
                if LivingGem.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function LivingGem.recordKill(item, socketIndex)
    if not item then
        return false
    end

    local state = LivingGem.readState(item, socketIndex) or {}
    local oldProgress = LivingGem.getProgress(state)
    state.kills = math.max(0, livingToNumber(state.kills, 0)) + 1
    LivingGem.writeState(item, socketIndex, state)

    local gemData = getLivingGemData()
    if gemData and type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, gemData)
    end
    local newProgress = LivingGem.getProgress(state)
    local oldDamage = oldProgress.currentStage and oldProgress.currentStage.damagePercent or 0
    local newDamage = newProgress.currentStage and newProgress.currentStage.damagePercent or 0
    if newDamage ~= oldDamage and type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    elseif type(_G.GemsSocket_refreshSocketDisplay) == "function" then
        _G.GemsSocket_refreshSocketDisplay(item)
    elseif type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
    return newDamage ~= oldDamage
end

function LivingGem.addBonuses(item, socketIndex, totals)
    if type(totals) ~= "table" then
        return
    end

    local progress = LivingGem.getProgress(LivingGem.readState(item, socketIndex))
    local currentStage = progress.currentStage
    local damagePercent = currentStage and currentStage.damagePercent or 0
    if damagePercent > 0 then
        totals.socket_living_damage_percent = (totals.socket_living_damage_percent or 0) + damagePercent
    end
end
