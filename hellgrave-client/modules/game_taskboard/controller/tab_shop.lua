local confirmBox = nil

local SHOP_CURRENCY_LABELS = {
    task = "Hunting Task Points",
    soulseal = "Soulseals",
    bounty = "Bounty Points"
}

local SHOP_CURRENCY_ICONS = {
    task = "/game_taskboard/assets/images/task-tokens",
    soulseal = "/game_taskboard/assets/images/icon-currency-soulseals",
    bounty = "/game_taskboard/assets/images/icon-currency-bountypoints"
}

local function normalizeShopCurrency(currency)
    currency = tostring(currency or "task")
    if currency == "soulseal" or currency == "bounty" then
        return currency
    end
    return "task"
end

local MOUNT_PREVIEW_PALETTES = {
    { head = 78, body = 94, legs = 114, feet = 116 },
    { head = 97, body = 79, legs = 115, feet = 95 },
    { head = 58, body = 92, legs = 120, feet = 114 },
    { head = 115, body = 82, legs = 94, feet = 116 },
    { head = 96, body = 77, legs = 113, feet = 95 },
    { head = 94, body = 116, legs = 78, feet = 114 }
}

local function getMountPreviewPalette(raw)
    local seed = tonumber(raw.id or raw.lookType or raw.mountId) or 0
    if seed <= 0 then
        seed = #tostring(raw.title or "")
    end
    return MOUNT_PREVIEW_PALETTES[(seed % #MOUNT_PREVIEW_PALETTES) + 1]
end

local COSMETIC_PREVIEW_OUTFIT = {
    lookType = 128,
    lookHead = 78,
    lookBody = 78,
    lookLegs = 79,
    lookFeet = 79,
    lookAddons = 0,
    lookMount = 0
}

local SHOP_SHADER_NAMES = {
    [1] = "blue_loohs",
    [2] = "bloohs_green",
    [3] = "bloohs_red",
    [4] = "bloohs_white",
    [5] = "blue Dortmond",
    [6] = "red_dortmond",
    [7] = "white_dortmond",
    [8] = "green_dortmond",
    [9] = "pink_energizer",
    [10] = "blue_energizer",
    [11] = "red_energizer",
    [12] = "yellow _energizer",
    [13] = "white_Energizer",
    [14] = "orange_energizer",
    [15] = "yellow_pixent",
    [16] = "green_pixent",
    [17] = "blue_pixent"
}

local SHOP_AURA_CLIENT_IDS = {
    [1] = 932,
    [2] = 933,
    [3] = 934,
    [4] = 935,
    [5] = 936
}

local SHOP_WINGS_CLIENT_IDS = {
    [1] = 937,
    [2] = 938,
    [3] = 939,
    [4] = 940,
    [5] = 941,
    [6] = 1177,
    [7] = 1178,
    [8] = 1179,
    [9] = 1180,
    [10] = 1181,
    [11] = 1182,
    [12] = 1183,
    [13] = 1184,
    [14] = 1185,
    [15] = 1186
}

local function getAuraClientId(raw)
    return tonumber(raw.lookAura) or SHOP_AURA_CLIENT_IDS[tonumber(raw.auraId) or 0] or 0
end

local function getWingsClientId(raw)
    return tonumber(raw.lookWings) or SHOP_WINGS_CLIENT_IDS[tonumber(raw.wingsId) or 0] or 0
end

local function getShopShaderName(raw)
    local shader = raw.shaderName or raw.shader or raw.lookShader
    if type(shader) == "string" and shader ~= "" then
        return shader
    end
    return SHOP_SHADER_NAMES[tonumber(raw.shaderId or raw.lookShader) or 0] or ""
end

function TaskBoardController:getShopCurrencyBalance(currency)
    currency = normalizeShopCurrency(currency)
    if currency == "soulseal" then
        return tonumber(self.soulpitBalanceRaw) or tonumber(self.compatBalances and self.compatBalances.soulseal) or 0
    elseif currency == "bounty" then
        return tonumber(self.bountyBalanceRaw) or tonumber(self.compatBalances and self.compatBalances.bounty) or 0
    end
    return tonumber(self.taskShopBalanceRaw) or tonumber(self.compatBalances and self.compatBalances.task) or 0
end

function TaskBoardController:onShopData(items, header)
    local parsed = {}
    for _, raw in ipairs(items or {}) do
        table.insert(parsed, self:parseShopItem(raw))
    end
    self.shopItems = parsed
    header = header or {}
    self.shopPage = tonumber(header.page) or self.shopPage or 1
    self.shopTotalPages = tonumber(header.totalPages) or self.shopTotalPages or 1
    self.shopTotalOffers = tonumber(header.total) or self.shopTotalOffers or #parsed
    self:refreshNativeUi()
end

function TaskBoardController:onShopResult(itemId, result)
    if result == 0 then
        return
    end
    local errorMessages = {
        [SHOP_ERR_NOT_FOUND] = "Item not found.",
        [SHOP_ERR_ALREADY_BOUGHT] = "Already purchased.",
        [SHOP_ERR_NO_POINTS] = "Not enough points for this offer.",
        [SHOP_ERR_NEED_BASE] = "You need the base outfit first.",
        [SHOP_ERR_STORE_INBOX] = "Store inbox error.",
        [SHOP_ERR_NO_SPACE] = "You need more capacity or backpack space."
    }
    local msg = errorMessages[result] or ("Purchase failed (code " .. result .. ").")
    local errBox
    local function close()
        if errBox then
            errBox:destroy();
            errBox = nil
        end
    end
    errBox = displayGeneralBox(tr('Purchase Failed'), msg, {{
        text = tr('Ok'),
        callback = close
    }}, close, close)
end

function TaskBoardController:buyItem(itemId)
    local item = nil
    local itemIndex = nil
    for index, it in ipairs(self.shopItems) do
        if it.id == tonumber(itemId) then
            item = it
            itemIndex = index
            break
        end
    end
    if not item then
        return
    end
    local currencyLabel = SHOP_CURRENCY_LABELS[item.currency] or SHOP_CURRENCY_LABELS.task
    local msg = tr("Do you really want to buy '%s' for %s %s?", item.title, comma_value(item.price), currencyLabel)
    local function yes()
        g_game.taskHuntingShopPurchase(item.id, tonumber(self.shopPage) or 1)
        if confirmBox then
            confirmBox:destroy();
            confirmBox = nil
        end
    end
    local function cancel()
        if confirmBox then
            confirmBox:destroy();
            confirmBox = nil
        end
    end
    confirmBox = displayGeneralBox(tr('Confirm Purchase'), msg, {{
        text = tr('Yes'),
        callback = yes
    }, {
        text = tr('Cancel'),
        callback = cancel
    }}, yes, cancel)
end

function TaskBoardController:updateShopBalance(balance)
    self.shopBalance = balance or self.taskShopBalanceRaw or self.shopBalance or 0
    for i, item in ipairs(self.shopItems) do
        self.shopItems[i].canAfford = self:getShopCurrencyBalance(item.currency) >= item.price and not item.bought
    end
    self.shopItems = self.shopItems
    self:refreshNativeUi()
end

function TaskBoardController:parseShopItem(raw)
    local offerType = tonumber(raw.offerType) or SHOP_OFFER_TYPE_ITEM
    local data = {
        id = tonumber(raw.id) or 0,
        title = raw.title or "",
        description = raw.description or "",
        price = tonumber(raw.price) or 0,
        currency = normalizeShopCurrency(raw.currency),
        bought = (tonumber(raw.bought) or 0) == 1,
        offerType = offerType,
        timerText = tostring(raw.timerText or ""),
        backdrop = SHOP_BACKDROP_IMAGES[offerType] or SHOP_BACKDROP_IMAGES[SHOP_OFFER_TYPE_ITEM],
        canAfford = false,
        lookMount = 0,
        previewType = nil
    }

    if offerType == SHOP_OFFER_TYPE_OUTFIT then
        local parsedLookType = tonumber(raw.lookType) or tonumber(raw.maleLookType) or tonumber(raw.femaleLookType) or 0
        if parsedLookType > 0 then
            data.lookType = parsedLookType
        else
            g_logger.warning(string.format("[TaskBoard][Shop] Outfit without lookType (id=%s, title=%s)",
                tostring(data.id), tostring(data.title)))
        end
        data.lookHead = tonumber(raw.lookHead) or 0
        data.lookBody = tonumber(raw.lookBody) or 0
        data.lookLegs = tonumber(raw.lookLegs) or 0
        data.lookFeet = tonumber(raw.lookFeet) or 0
        data.lookAddons = tonumber(raw.lookAddons) or 0
        data.lookMount = 0
        data.isOutfit = parsedLookType > 0
        data.isCreaturePreview = data.isOutfit
        data.previewType = data.isCreaturePreview and 'creature' or nil
    elseif offerType == SHOP_OFFER_TYPE_MOUNT then
        local parsedMountType = tonumber(raw.lookType) or 0
        if parsedMountType > 0 then
            data.lookMount = parsedMountType
        else
            g_logger.warning(string.format("[TaskBoard][Shop] Mount without lookType (id=%s, title=%s)",
                tostring(data.id), tostring(data.title)))
        end
        local palette = getMountPreviewPalette(raw)
        data.lookType = 128
        data.lookHead = tonumber(raw.lookHead) or palette.head
        data.lookBody = tonumber(raw.lookBody) or palette.body
        data.lookLegs = tonumber(raw.lookLegs) or palette.legs
        data.lookFeet = tonumber(raw.lookFeet) or palette.feet
        data.lookAddons = 0
        data.isMount = parsedMountType > 0
        data.isCreaturePreview = data.isMount
        data.previewType = data.isCreaturePreview and 'creature' or nil
    elseif offerType == SHOP_OFFER_TYPE_ITEM or offerType == SHOP_OFFER_TYPE_ITEM_DOUBLE then
        data.itemId = tonumber(raw.itemId) or 0
        data.lookMount = 0
        data.isItem = (data.itemId > 0)
        data.previewType = data.isItem and 'item' or nil
    elseif offerType == SHOP_OFFER_TYPE_AURA or offerType == SHOP_OFFER_TYPE_WINGS or offerType == SHOP_OFFER_TYPE_SHADER then
        data.lookType = tonumber(raw.previewLookType or raw.lookType) or COSMETIC_PREVIEW_OUTFIT.lookType
        data.lookHead = tonumber(raw.lookHead) or COSMETIC_PREVIEW_OUTFIT.lookHead
        data.lookBody = tonumber(raw.lookBody) or COSMETIC_PREVIEW_OUTFIT.lookBody
        data.lookLegs = tonumber(raw.lookLegs) or COSMETIC_PREVIEW_OUTFIT.lookLegs
        data.lookFeet = tonumber(raw.lookFeet) or COSMETIC_PREVIEW_OUTFIT.lookFeet
        data.lookAddons = tonumber(raw.lookAddons) or COSMETIC_PREVIEW_OUTFIT.lookAddons
        data.lookMount = tonumber(raw.lookMount) or COSMETIC_PREVIEW_OUTFIT.lookMount
        data.lookAura = offerType == SHOP_OFFER_TYPE_AURA and getAuraClientId(raw) or 0
        data.lookWings = offerType == SHOP_OFFER_TYPE_WINGS and getWingsClientId(raw) or 0
        data.lookShader = offerType == SHOP_OFFER_TYPE_SHADER and getShopShaderName(raw) or ""
        data.previewType = 'creature'
        data.cosmeticType = offerType
    end

    local balance = self:getShopCurrencyBalance(data.currency)
    data.canAfford = balance >= data.price and not data.bought
    data.displayPrice = comma_value(data.price)
    data.currencyIcon = SHOP_CURRENCY_ICONS[data.currency] or SHOP_CURRENCY_ICONS.task
    data.currencyLabel = SHOP_CURRENCY_LABELS[data.currency] or SHOP_CURRENCY_LABELS.task

    return data
end
