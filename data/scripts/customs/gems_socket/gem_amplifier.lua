local AmplifierGem = {
    key = "amplifiergem",
    fallbackItemId = 30833,
    fallbackData = {
        itemId = 30833,
        name = "Amplifier Gem",
        socketAmplifier = {
            addSockets = 2,
            maxCurrentSockets = 3,
            useConfiguredSocketItems = true,
            allowedItemIds = {},
        },
    },
}

local function getConfiguredGemItemId(gemKey, fallback)
    local gemData = GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[gemKey]
    return tonumber(gemData and gemData.itemId) or fallback
end

local function getAmplifierData()
    if not GemsSocket or not GemsSocket.GEMS then
        return AmplifierGem.fallbackData, AmplifierGem.fallbackData.socketAmplifier
    end

    local gemData = GemsSocket.GEMS[AmplifierGem.key]
    if not gemData then
        return AmplifierGem.fallbackData, AmplifierGem.fallbackData.socketAmplifier
    end

    return gemData, gemData.socketAmplifier or {}
end

local function isAllowedTarget(item, amplifierData)
    if not item or not item:isItem() then
        return false
    end

    local targetId = item:getId()
    local socketCount = tonumber(item:getCustomAttribute("socket_count") or 0) or 0
    local socketEnabled = tonumber(item:getCustomAttribute("socket_enabled") or 0) or 0

    if socketEnabled > 0 or socketCount > 0 then
        return true
    end

    local allowedItemIds = type(amplifierData.allowedItemIds) == "table" and amplifierData.allowedItemIds or {}
    if allowedItemIds[targetId] then
        return true
    end

    if amplifierData.useConfiguredSocketItems and type(GemsSocket.SOCKET_ADDER_ITEMS) == "table" then
        return GemsSocket.SOCKET_ADDER_ITEMS[targetId] ~= nil
    end

    return next(allowedItemIds) == nil
end

local function onUseAmplifierGem(player, item, fromPosition, target, toPosition, isHotkey)
    local gemData, amplifierData = getAmplifierData()
    if not gemData then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Amplifier Gem is not configured correctly.")
        return true
    end

    if not target or not target:isItem() then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this gem on an equipment item.")
        return true
    end

    if not isAllowedTarget(target, amplifierData) then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "This equipment cannot be amplified.")
        return true
    end

    local getSocketCount = _G.GemsSocket_getSocketCount
    local addSocketsToItem = _G.GemsSocket_addSocketsToItem
    local ensureSocketableMetadata = _G.GemsSocket_ensureSocketableMetadata
    if type(getSocketCount) ~= "function" or type(addSocketsToItem) ~= "function" then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Amplifier Gem is not ready yet.")
        return true
    end

    if type(ensureSocketableMetadata) == "function" then
        ensureSocketableMetadata(target)
    end

    local maxCurrentSockets = math.max(0, tonumber(amplifierData.maxCurrentSockets) or 3)
    local currentSockets = getSocketCount(target)
    if currentSockets > maxCurrentSockets then
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("This gem only works on items with %d or fewer sockets.", maxCurrentSockets))
        return true
    end

    local socketsToAdd = math.max(1, tonumber(amplifierData.addSockets) or 2)
    if not addSocketsToItem(player, target, socketsToAdd) then
        return true
    end

    item:remove(1)
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("%s amplifies the item and adds %d sockets.", gemData.name, socketsToAdd))
    return true
end

local function registerAmplifierAction()
    if AmplifierGem.registered then
        return true
    end

    local itemId = getConfiguredGemItemId(AmplifierGem.key, AmplifierGem.fallbackItemId)
    if not itemId then
        return false
    end

    local amplifierAction = Action()
    amplifierAction:allowFarUse(true)

    function amplifierAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
        return onUseAmplifierGem(player, item, fromPosition, target, toPosition, isHotkey)
    end

    amplifierAction:id(itemId)
    amplifierAction:register()
    AmplifierGem.registered = true
    AmplifierGem.registeredItemId = itemId
    return true
end

function _G.GemsSocket_registerAmplifierGem()
    return registerAmplifierAction()
end

registerAmplifierAction()
