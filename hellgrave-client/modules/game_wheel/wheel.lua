WheelDestiny = WheelDestiny or {}
Gem_Atelier = Gem_Atelier or {}
Fragment_Workshop = Fragment_Workshop or {}

modules.game_wheel = modules.game_wheel or {}
modules.game_wheel.WheelDestiny = WheelDestiny
modules.game_wheel.Gem_Atelier = Gem_Atelier
modules.game_wheel.Fragment_Workshop = Fragment_Workshop


local WHEEL_OPCODE = 194

local function logWheelError(context, err)
    g_logger.error(string.format("[WheelDestiny] %s: %s", context, tostring(err)))
end

local function safeCall(context, callback, ...)
    if type(callback) ~= "function" then
        logWheelError(context, "handler is not available")
        return false
    end

    local args = { ... }
    local ok, err = pcall(function()
        callback(unpack(args))
    end)
    if not ok then
        logWheelError(context, err)
    end
    return ok
end

local function setRequestPending(pending)
    WheelDestiny.PendingRequest = pending and true or false

    if Gem_Atelier and Gem_Atelier.setPending then
        Gem_Atelier.setPending(WheelDestiny.PendingRequest)
    end
    if Fragment_Workshop and Fragment_Workshop.setPending then
        Fragment_Workshop.setPending(WheelDestiny.PendingRequest)
    end
end

if not torect then
    function torect(value)
        return value
    end
end

local function toggleWheelWindow()
    if WheelDestiny.Create then
        if not WheelDestiny.Create() then
            return
        end
    elseif create then
        if not create() then
            return
        end
    end

    local visible = WheelDestiny.UI and WheelDestiny.UI:isVisible()

    if WheelDestiny.Toggle then
        WheelDestiny.Toggle(visible and nil or true)
    elseif wheelDestinyToggle then
        wheelDestinyToggle(visible and nil or true)
    end
end

local function sendWheelRequest(action, data)
    local protocolGame = g_game.getProtocolGame()
    if not protocolGame then
        return false
    end

    protocolGame:sendExtendedOpcode(WHEEL_OPCODE, json.encode({
        action = action,
        data = data or {}
    }))
    return true
end

local function applyResources(resources, deferRefresh)
    if type(resources) ~= "table" then
        return
    end

    local isObjectArray = type(resources[1]) == "table"
    if isObjectArray then
        for _, resource in ipairs(resources) do
            local resourceType = tonumber(resource.type or resource.resourceType)
            local balance = tonumber(resource.value or resource.balance) or 0
            if resourceType ~= nil then
                onResourceBalance(resourceType, balance, deferRefresh)
            end
        end
        return
    end

    for resourceType, balance in pairs(resources) do
        onResourceBalance(tonumber(resourceType) or resourceType, tonumber(balance) or 0, deferRefresh)
    end
end

local function applyWheelConfig(config)
    if type(config) ~= "table" or type(config.gemItems) ~= "table" then
        return
    end

    Gem_Atelier.VocationGems = Gem_Atelier.VocationGems or {}
    for _, item in ipairs(config.gemItems) do
        local vocation = tonumber(item.vocation)
        local quality = tonumber(item.quality)
        local serverId = tonumber(item.serverId) or 0
        local clientId = tonumber(item.clientId) or 0
        local index = quality and (quality + 1)
        local entry = vocation and index and Gem_Atelier.VocationGems[vocation] and
            Gem_Atelier.VocationGems[vocation][index]

        if entry then
            entry.serverItem = serverId
            entry.clientItem = clientId
            if clientId > 0 then
                entry.item = clientId
            end
        end
    end
end

local function bindWheelDragHandle()
    local ui = WheelDestiny.UI
    local handle = ui and (ui.dragHandle or (ui.recursiveGetChildById and ui:recursiveGetChildById("dragHandle")))
    if not ui or not handle then
        return
    end

    local function bindDragWidget(widget, onlyTitleBar)
        if not widget then
            return
        end

        widget.dragging = false
        widget.dragOffset = { x = 0, y = 0 }
        if type(widget.setPhantom) == "function" then
            widget:setPhantom(false)
        end
        if type(widget.setFocusable) == "function" then
            widget:setFocusable(true)
        end

        widget.onMousePress = function(w, mousePos, button)
            if button ~= MouseLeftButton or not WheelDestiny.UI then
                return false
            end
            if onlyTitleBar and mousePos.y > WheelDestiny.UI:getY() + 34 then
                return false
            end

            w.dragging = true
            w.dragOffset.x = mousePos.x - WheelDestiny.UI:getX()
            w.dragOffset.y = mousePos.y - WheelDestiny.UI:getY()
            if type(WheelDestiny.UI.breakAnchors) == "function" then
                WheelDestiny.UI:breakAnchors()
            end
            WheelDestiny.UI:raise()
            return true
        end

        widget.onMouseMove = function(w, mousePos)
            if not w.dragging or not WheelDestiny.UI then
                return false
            end

            if g_mouse and type(g_mouse.isPressed) == "function" and not g_mouse.isPressed(MouseLeftButton) then
                w.dragging = false
                return false
            end

            WheelDestiny.UI:breakAnchors()
            WheelDestiny.UI:setPosition({
                x = mousePos.x - w.dragOffset.x,
                y = mousePos.y - w.dragOffset.y
            })
            if type(WheelDestiny.UI.bindRectToParent) == "function" then
                WheelDestiny.UI:bindRectToParent()
            end
            return true
        end

        widget.onMouseRelease = function(w, _, button)
            if button ~= MouseLeftButton then
                return false
            end

            if w.dragging then
                w.dragging = false
                if WheelDestiny.UI and type(WheelDestiny.UI.bindRectToParent) == "function" then
                    WheelDestiny.UI:bindRectToParent()
                end
                return true
            end

            return false
        end
    end

    if type(handle.setPhantom) == "function" then
        handle:setPhantom(false)
    end
    if type(handle.setDraggable) == "function" then
        handle:setDraggable(false)
    end
    if type(handle.setFocusable) == "function" then
        handle:setFocusable(true)
    end
    if type(handle.raise) == "function" then
        handle:raise()
    end

    bindDragWidget(handle, false)
    bindDragWidget(ui, true)
end

local function makeClickThroughShell()
    if not WheelDestiny.UI then
        return
    end

    if type(WheelDestiny.UI.setPhantom) == "function" then
        WheelDestiny.UI:setPhantom(false)
    end
    if type(WheelDestiny.UI.setDraggable) == "function" then
        WheelDestiny.UI:setDraggable(true)
    end
    if WheelDestiny.UI.main and type(WheelDestiny.UI.main.setPhantom) == "function" then
        WheelDestiny.UI.main:setPhantom(true)
    end

    local categories = { "wheel", "gem", "fragment" }
    for _, category in ipairs(categories) do
        local panel = WheelDestiny.UI.main and WheelDestiny.UI.main[category]
        if panel and type(panel.setPhantom) == "function" then
            panel:setPhantom(true)
        end
    end

    bindWheelDragHandle()
end

local RESOURCE_TOOLTIPS = {
    gold = "Gold\nUsed to pay Wheel of Destiny, Gem Atelier and Fragment Workshop costs.",
    lesserFragments = "Lesser Exalted Fragments\nUsed to enhance Basic Mods in the Fragment Workshop.",
    greaterFragments = "Greater Exalted Fragments\nUsed to enhance Supreme Mods in the Fragment Workshop."
}

local function setWidgetTooltip(widget, text)
    if not widget then
        return
    end
    if type(widget.setTooltip) == "function" then
        widget:setTooltip(text)
    end
    if widget.icon and type(widget.icon.setTooltip) == "function" then
        widget.icon:setTooltip(text)
    end
    if widget.value and type(widget.value.setTooltip) == "function" then
        widget.value:setTooltip(text)
    end
end

local function applyWheelResourceTooltips()
    local main = WheelDestiny.UI and WheelDestiny.UI.main
    if not main then
        return
    end

    setWidgetTooltip(main.goldBalance, RESOURCE_TOOLTIPS.gold)
    setWidgetTooltip(main.lesserFragmentsBalance, RESOURCE_TOOLTIPS.lesserFragments)
    setWidgetTooltip(main.greaterFragmentsBalance, RESOURCE_TOOLTIPS.greaterFragments)
end

local function refreshAllBalances()
    if WheelDestiny.updateBalance then
        WheelDestiny.updateBalance()
    end
    if Gem_Atelier and Gem_Atelier.updateBalance then
        Gem_Atelier.updateBalance()
    end
    if Fragment_Workshop and Fragment_Workshop.updateBalance then
        Fragment_Workshop.updateBalance()
    end
end

local function applyFullPayload(data)
    if not WheelDestiny.UI and not create() then
        return false
    end

    data = type(data) == "table" and data or {}
    applyWheelConfig(data.config)
    applyResources(data.resources, true)
    if type(data.presets) == "table" then
        WheelDestiny.ServerPresets = data.presets
        WheelDestiny.ServerPresetsLoaded = true
        WheelDestiny.PresetsNeedReload = true
    end

    if type(data.base) == "table" and type(data.slots) == "table" then
        safeCall("applying wheel state", WheelDestiny.onParseWheelOfDestiny, data.base, data.slots, true)
    end

    if data.lesserFragments ~= nil or data.greaterFragments ~= nil then
        safeCall("applying fragment state", onParseWheelFragments,
            type(data.lesserFragments) == "table" and data.lesserFragments or {},
            type(data.greaterFragments) == "table" and data.greaterFragments or {})
    end

    if data.activeGems ~= nil or data.revealedGems ~= nil then
        safeCall("applying gem state", onParseWheelGems,
            type(data.activeGems) == "table" and data.activeGems or {},
            type(data.revealedGems) == "table" and data.revealedGems or {})
    end

    if WheelDestiny.update then
        safeCall("refreshing wheel", WheelDestiny.update)
    end
    if WheelDestiny.updateWheelGem then
        safeCall("refreshing wheel gems", WheelDestiny.updateWheelGem)
    end
    if Fragment_Workshop and Fragment_Workshop.updateActivedMods then
        safeCall("refreshing active modifiers", Fragment_Workshop.updateActivedMods)
    end
    if WheelDestiny.CommitPendingPresetSave then
        safeCall("saving current preset", WheelDestiny.CommitPendingPresetSave)
    end
    if WheelDestiny.UpdateCurrentPreset then
        safeCall("refreshing presets", WheelDestiny.UpdateCurrentPreset)
    end
    refreshAllBalances()
    return true
end

local function onWheelExtendedOpcode(protocol, opcode, buffer)
    if opcode ~= WHEEL_OPCODE then
        return
    end

    local ok, payload = pcall(function()
        return json.decode(buffer)
    end)

    if not ok or type(payload) ~= "table" then
        g_logger.error("[Wheel] Invalid wheel payload: " .. tostring(buffer))
        return
    end

    local action = payload.action
    local data = payload.data or {}

    if action == "full" or action == "fetch" then
        setRequestPending(false)
        applyFullPayload(data)

        if WheelDestiny.HideAfterSave then
            WheelDestiny.HideAfterSave = false
            if WheelDestiny.UI and WheelDestiny.UI:isVisible() and WheelDestiny.Toggle then
                WheelDestiny.Toggle()
            end
        end
    elseif action == "wheel" then
        setRequestPending(false)
        safeCall("applying wheel packet", WheelDestiny.onParseWheelOfDestiny, data.base or {}, data.slots or {})
    elseif action == "gems" then
        setRequestPending(false)
        safeCall("applying gems packet", onParseWheelGems, data.activeGems or {}, data.revealedGems or {})
    elseif action == "fragments" then
        setRequestPending(false)
        safeCall("applying fragments packet", onParseWheelFragments, data.lesserFragments or {}, data.greaterFragments or {})
    elseif action == "resources" then
        applyResources(data, false)
    elseif action == "msg" then
        setRequestPending(false)
        WheelDestiny.HideAfterSave = false
        local message = data.message or data.msg or "Wheel update."
        if data.mode == "error" then
            WheelDestiny.PendingPresetSaveName = nil
            displayErrorBox("Wheel of Destiny", message)
        else
            modules.game_textmessage.displayGameMessage(message)
        end
        refreshAllBalances()
    else
        g_logger.warning("[WheelDestiny] Unknown action: " .. tostring(action))
    end
end

function requestFetch()
    local sent = sendWheelRequest("fetch", {})
    if sent then
        setRequestPending(true)
    end
    return sent
end

function requestSave(slots, gems, hide)
    local sent = sendWheelRequest("save", {
        slots = slots,
        gems = gems,
        hide = hide and true or false
    })

    if sent then
        WheelDestiny.HideAfterSave = hide and true or false
        setRequestPending(true)
    end
    return sent
end

function requestPresetSave(presets)
    local sent = sendWheelRequest("presets", {
        presets = type(presets) == "table" and presets or {}
    })
    if sent then
        setRequestPending(true)
    end
    return sent
end

function requestGemAction(mode, value, extra)
    if WheelDestiny.PendingRequest then
        return false
    end

    local sent = sendWheelRequest("gemAction", {
        mode = mode,
        value = value,
        extra = extra
    })
    if sent then
        setRequestPending(true)
    end
    return sent
end

function disable()
    if not WheelDestiny.UI or not WheelDestiny.UI.main or not WheelDestiny.UI.main.wheel then
        return
    end

    for _, widget in ipairs(WheelDestiny.UI.main.wheel.base.front:getChildren()) do
        if widget:getId() ~= "base" then
            if widget.hover then
                widget.hover:setVisible(false)
            end
        end
    end

    for side, _ in pairs(WheelDestiny.Sides or {}) do
        local widget = WheelDestiny.UI.main.wheel.base[side]
        if widget and widget.hover then widget.hover:setVisible(false) end
        if widget and widget.socketHover then widget.socketHover:setVisible(false) end
    end
end

function create()
    if WheelDestiny.UI then
        return true
    end

    WheelDestiny.UI = g_ui.displayUI("wheel")
    if not WheelDestiny.UI then
        g_logger.error("[WheelDestiny] Failed to load wheel.otui")
        return false
    end

    g_ui.loadUI("categories/wheel_of_destiny_selection")
    WheelDestiny.UI.main.wheel = g_ui.loadUI("categories/wheel_of_destiny", WheelDestiny.UI.main)
    WheelDestiny.UI.main.gem = g_ui.loadUI("categories/gem_atelier", WheelDestiny.UI.main)
    WheelDestiny.UI.main.fragment = g_ui.loadUI("categories/fragment_workshop", WheelDestiny.UI.main)
    WheelDestiny.PresetNew = g_ui.displayUI("presets/preset_new")
    WheelDestiny.PresetRename = g_ui.displayUI("presets/preset_rename")

    if not WheelDestiny.UI.main.wheel or not WheelDestiny.UI.main.gem or not WheelDestiny.UI.main.fragment or not WheelDestiny.PresetNew or not WheelDestiny.PresetRename then
        g_logger.error("[WheelDestiny] Failed to load one or more wheel category UIs")
        if WheelDestiny.PresetNew then WheelDestiny.PresetNew:destroy() end
        if WheelDestiny.PresetRename then WheelDestiny.PresetRename:destroy() end
        if WheelDestiny.UI then WheelDestiny.UI:destroy() end
        WheelDestiny.PresetNew = nil
        WheelDestiny.PresetRename = nil
        WheelDestiny.UI = nil
        return false
    end

    makeClickThroughShell()
    applyWheelResourceTooltips()

    if presetInit then
        presetInit()
    elseif WheelDestiny.PresetInit then
        WheelDestiny.PresetInit()
    end

    WheelDestiny.UI:hide()
    WheelDestiny.UI.main.wheel:hide()
    WheelDestiny.UI.main.gem:hide()
    WheelDestiny.UI.main.fragment:hide()

    WheelDestiny.PresetNew:hide()
    WheelDestiny.PresetRename:hide()

    Gem_Atelier.UI = WheelDestiny.UI.main.gem
    Gem_Atelier.activeQualityFilter = 1
    Gem_Atelier.activeAffinityFilter = 1
    Gem_Atelier.searchText = ""
    Gem_Atelier.Info = { actualPage = 1, pages = 1, count = 0 }

    Fragment_Workshop.UI = WheelDestiny.UI.main.fragment
    Fragment_Workshop.LesserFragments = {}
    Fragment_Workshop.GreaterFragments = {}
    Fragment_Workshop.Fragments = {
        [1] = {},
        [2] = {}
    }
    Fragment_Workshop.searchText = ""
    Fragment_Workshop.activeFilter = 1
    Fragment_Workshop.Info = { actualPage = 1, pages = 1, count = 0 }

    WheelDestiny.ActivedGem = {
        [0] = nil,
        [1] = nil,
        [2] = nil,
        [3] = nil
    }

    WheelDestiny.ActivedGemSlots = {
        [0] = { [1] = nil, [2] = nil, [3] = nil },
        [1] = { [1] = nil, [2] = nil, [3] = nil },
        [2] = { [1] = nil, [2] = nil, [3] = nil },
        [3] = { [1] = nil, [2] = nil, [3] = nil }
    }
    WheelDestiny.SavedActiveGemIndices = {
        [0] = -1, [1] = -1, [2] = -1, [3] = -1
    }

    WheelDestiny.hoverVerify = false
    WheelDestiny.preview = false
    WheelDestiny.state = 0
    WheelDestiny.slots = {}
    WheelDestiny.usedPoints = 0
    WheelDestiny.availablePoints = 0
    WheelDestiny.totalPoints = 0
    WheelDestiny.vocation = 1
    WheelDestiny.sidePoints = {
        ["topLeft"] = {
            points = 0
        },
        ["topRight"] = {
            points = 0
        },
        ["bottomLeft"] = {
            points = 0
        },
        ["bottomRight"] = {
            points = 0
        }
    }

    WheelDestiny.Resources = {
        [0] = 0,
        [81] = 0,
        [82] = 0,
        [83] = 0,
        [84] = 0,
        [85] = 0
    }

    WheelDestiny.ExternalPreset = {}
    WheelDestiny.InternalPreset = {}
    WheelDestiny.CurrentPreset = {}
    WheelDestiny.ServerPresets = {}
    WheelDestiny.ServerPresetsLoaded = false
    WheelDestiny.PresetsNeedReload = true
    WheelDestiny.LocalPresetsMigratedToServer = false
    WheelDestiny.PendingRequest = false
    WheelDestiny.HideAfterSave = false

    WheelDestiny.UI.main.wheel.onHoverChange = function(self, hovered)
        if not hovered then
            disable()
            WheelDestiny.hoverVerify = false
            WheelDestiny.hoverWidget = nil
            WheelDestiny.selectedHover = nil
            self.test.informationBox:setVisible(false)
            if not self.test.presetBox:isVisible() then
                self.test.defaultBox:setVisible(true)
            end
        end
    end

    if WheelDestiny.changeOption then
        WheelDestiny.changeOption(WheelDestiny.UI.main.wheel.test.buttons.information, true)
    end

    changeHome(WheelDestiny.UI.buttons.wheelButton, true)

    for _, slots in pairs(WheelDestiny.UI.main.wheel.base.selectors.front:getChildren()) do
        slots:setPhantom(true)
        for slotId, slotItem in pairs(slots:getChildren()) do
            if slotItem:getId() ~= "selected" then
                slotItem:destroy()
            end
        end
    end

    return true
end

function init()
    WheelDestiny.Button = modules.client_topmenu.addRightGameToggleButton("wheelButton", tr("Wheel of Destiny"), "/images/topbuttons/wheel", toggleWheelWindow)
    WheelDestiny.Button:setOn(false)

    connect(g_game, {
        onGameStart = onStart,
        onGameEnd = onEnd
    })

    ProtocolGame.registerExtendedOpcode(WHEEL_OPCODE, onWheelExtendedOpcode)

    if g_game.isOnline() then
        onStart()
    end
end

function terminate()
    disconnect(g_game, {
        onGameStart = onStart,
        onGameEnd = onEnd
    })

    ProtocolGame.unregisterExtendedOpcode(WHEEL_OPCODE, onWheelExtendedOpcode)

    if WheelDestiny.Button then
        WheelDestiny.Button:destroy()
        WheelDestiny.Button = nil
    end

    setRequestPending(false)

    if WheelDestiny.ExportCodeWindow then
        WheelDestiny.ExportCodeWindow:destroy()
        WheelDestiny.ExportCodeWindow = nil
    end

    if WheelDestiny.SelectedNewPresetRadio then
        WheelDestiny.SelectedNewPresetRadio:destroy()
        WheelDestiny.SelectedNewPresetRadio = nil
    end

    if WheelDestiny.PresetNew then
        WheelDestiny.PresetNew:destroy()
        WheelDestiny.PresetNew = nil
    end

    if WheelDestiny.PresetRename then
        WheelDestiny.PresetRename:destroy()
        WheelDestiny.PresetRename = nil
    end

    if WheelDestiny.UI then
        WheelDestiny.UI.main.gem = nil
        WheelDestiny.UI.main.fragment = nil
        WheelDestiny.UI.main.wheel = nil
        WheelDestiny.UI:destroy()
        WheelDestiny.UI = nil
    end

end

function onStart()
    setRequestPending(false)
    if WheelDestiny.Button then
        WheelDestiny.Button:setOn(false)
    end
end

function onEnd()
    if not WheelDestiny.UI then
        return
    end

    if reset then
        reset()
    elseif WheelDestiny.reset then
        WheelDestiny.reset()
    end

    if Gem_Atelier.reset then
        Gem_Atelier.reset()
    end

    if WheelDestiny.UI:isVisible() and WheelDestiny.Toggle then
        WheelDestiny.Toggle()
    end

    if WheelDestiny.PresetNew then
        WheelDestiny.PresetNew:unlock()
        WheelDestiny.PresetNew:hide()
    end

    if WheelDestiny.PresetRename then
        WheelDestiny.PresetRename:unlock()
        WheelDestiny.PresetRename:hide()
    end
end

function changeHome(self, force)
    if not self or not WheelDestiny.UI then
        return
    end
    local options = {
        ["wheelButton"] = "wheel",
        ["gemButton"] = "gem",
        ["fragmentButton"] = "fragment"
    }

    local parent = self:getParent()
    for _, child in pairs(parent:getChildren()) do
        child:setChecked(false)

        local option = options[child:getId()]
        if option then
            WheelDestiny.UI.main[option]:hide()
        end
    end

    local option = options[self:getId()]
    if option then
        WheelDestiny.UI.main[option]:show()
        WheelDestiny.UI.main[option]:raise()
    end

    self:setChecked(true)
end

function onParseWheelGems(gems, revealedGems)
    if Gem_Atelier and Gem_Atelier.onReceiveData then
        Gem_Atelier.onReceiveData(gems, revealedGems, WheelDestiny.vocation)
    end
end

function onParseWheelFragments(lesserFragments, greaterFragments)
    Fragment_Workshop.onReceiveData(lesserFragments, greaterFragments)
end

function onResourceBalance(resourceType, balance, deferRefresh)
    if WheelDestiny.Resources[resourceType] ~= nil then
        WheelDestiny.Resources[resourceType] = math.max(0, tonumber(balance) or 0)

        if deferRefresh then
            return
        end

        if Gem_Atelier.updateBalance then
            Gem_Atelier.updateBalance()
        end

        if WheelDestiny.updateBalance then
            WheelDestiny.updateBalance()
        end

        if Fragment_Workshop.updateBalance then
            Fragment_Workshop.updateBalance()
        end
    end
end

WheelDestiny.requestFetch = requestFetch
WheelDestiny.requestSave = requestSave
WheelDestiny.requestPresetSave = requestPresetSave
WheelDestiny.requestGemAction = requestGemAction
WheelDestiny.disable = disable
WheelDestiny.Create = create
WheelDestiny.OnStart = onStart
WheelDestiny.OnEnd = onEnd
WheelDestiny.changeHome = changeHome
WheelDestiny.onParseWheelGems = onParseWheelGems
WheelDestiny.onParseWheelFragments = onParseWheelFragments
WheelDestiny.onResourceBalance = onResourceBalance
WheelDestiny.Toggle = wheelDestinyToggle or WheelDestiny.Toggle
WheelDestiny.Create = create
