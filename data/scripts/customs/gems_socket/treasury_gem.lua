TreasuryGem = TreasuryGem or {}

TreasuryGem.gemKey = "treasurygem"
TreasuryGem.exactDisplayCap = 99999999999

local TREASURY_COIN_VALUES = {
    [2148] = 1,
    [2152] = 100,
    [2160] = 10000,
    [28872] = 1000000,
    [28873] = 100000000,
}

local function treasuryToNumber(value, fallback)
    local number = tonumber(value)
    if number == nil then
        return fallback or 0
    end
    return number
end

local function getTreasuryGemData()
    return GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[TreasuryGem.gemKey] or nil
end

local function formatThousandsWithDots(value)
    local text = tostring(math.max(0, math.floor(tonumber(value) or 0)))
    local formatted = text
    while true do
        local replaced, count = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        formatted = replaced
        if count == 0 then
            break
        end
    end
    return formatted
end

local function formatLargeGold(value)
    value = math.max(0, tonumber(value) or 0)
    if value <= TreasuryGem.exactDisplayCap then
        return formatThousandsWithDots(value)
    end

    local billion = 1000000000
    local trillion = 1000000000000
    if value >= trillion then
        return string.format("%.2f trillion", value / trillion)
    end
    return string.format("%.2f billion", value / billion)
end

local function getCorpseCoinValue(item)
    if not item or not item.isItem or not item:isItem() then
        return 0
    end

    local total = 0
    local coinValue = TREASURY_COIN_VALUES[item:getId()]
    if coinValue then
        total = total + (coinValue * math.max(1, treasuryToNumber(item:getCount(), 1)))
    end

    if item:isContainer() then
        for index = 0, item:getSize() - 1 do
            total = total + getCorpseCoinValue(item:getItem(index))
        end
    end

    return total
end

function TreasuryGem.isGem(gemKey)
    return gemKey == TreasuryGem.gemKey
end

function TreasuryGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_treasury_", socketIndex)
    end
    return "treasury_"
end

function TreasuryGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = TreasuryGem.getAttributePrefix(socketIndex)
    local totalGold = math.max(0, treasuryToNumber(item:getCustomAttribute(prefix .. "loot_gold_total"), 0))
    if totalGold <= 0 then
        return nil
    end

    return {
        totalGold = totalGold,
    }
end

function TreasuryGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    item:removeCustomAttribute(TreasuryGem.getAttributePrefix(socketIndex) .. "loot_gold_total")
end

function TreasuryGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    TreasuryGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local totalGold = math.max(0, treasuryToNumber(state.totalGold, 0))
    if totalGold <= 0 then
        return
    end

    item:setCustomAttribute(TreasuryGem.getAttributePrefix(socketIndex) .. "loot_gold_total", totalGold)
end

function TreasuryGem.getCompactProgress(state)
    local totalGold = math.max(0, treasuryToNumber(state and state.totalGold, 0))
    return string.format("Gold Looted: %s", formatLargeGold(totalGold))
end

function TreasuryGem.buildTooltip(baseTooltip, state)
    local totalGold = math.max(0, treasuryToNumber(state and state.totalGold, 0))
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    if totalGold <= TreasuryGem.exactDisplayCap then
        lines[#lines + 1] = string.format("Loot Gold Recorded: %s", formatThousandsWithDots(totalGold))
    else
        lines[#lines + 1] = string.format("Loot Gold Recorded: %s", formatLargeGold(totalGold))
    end
    lines[#lines + 1] = "Only gold generated in monster loot is recorded."
    return table.concat(lines, "\n")
end

function TreasuryGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, TreasuryGem.gemKey, callback)
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local item = player:getSlotItem(slot)
        if item and _G.GemsSocket_hasSockets and _G.GemsSocket_hasSockets(item) then
            for socketIndex = 1, _G.GemsSocket_getSocketCount(item) do
                if TreasuryGem.isGem(_G.GemsSocket_getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function TreasuryGem.recordLootGold(item, socketIndex, goldValue)
    goldValue = math.max(0, treasuryToNumber(goldValue, 0))
    if not item or goldValue <= 0 then
        return false
    end

    local state = TreasuryGem.readState(item, socketIndex) or {}
    state.totalGold = math.max(0, treasuryToNumber(state.totalGold, 0)) + goldValue
    TreasuryGem.writeState(item, socketIndex, state)

    if type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, getTreasuryGemData())
    end
    if type(_G.GemsSocket_refreshSocketDisplay) == "function" then
        _G.GemsSocket_refreshSocketDisplay(item)
    elseif type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
    return true
end

function TreasuryGem.recordCorpseLoot(player, corpse)
    if not player or not player:isPlayer() or not corpse or not corpse.isContainer or not corpse:isContainer() then
        return false
    end

    if corpse:getCustomAttribute("treasury_gem_recorded") then
        return false
    end

    local goldValue = getCorpseCoinValue(corpse)
    if goldValue <= 0 then
        return false
    end

    corpse:setCustomAttribute("treasury_gem_recorded", 1)

    TreasuryGem.forEachEquippedSocket(player, function(item, socketIndex)
        TreasuryGem.recordLootGold(item, socketIndex, goldValue)
    end)
    return true
end
