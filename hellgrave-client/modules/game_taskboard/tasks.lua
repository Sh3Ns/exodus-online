local TaskBoardControllerBase = {}

function TaskBoardControllerBase:new()
    local controller = { _eventConnections = {} }
    setmetatable(controller, { __index = self })
    return controller
end

function TaskBoardControllerBase:init()
    if self.onInit then
        self:onInit()
    end

    if g_game then
        self:registerEvents(g_game, {
            onGameStart = function() if self.onGameStart then self:onGameStart() end end,
            onGameEnd = function() if self.onGameEnd then self:onGameEnd() end end
        })

        if g_game.isOnline and g_game.isOnline() and self.onGameStart then
            self:onGameStart()
        end
    end
end

function TaskBoardControllerBase:terminate()
    if self.onGameEnd then
        self:onGameEnd()
    end
    if self.onTerminate then
        self:onTerminate()
    end

    for _, connection in ipairs(self._eventConnections or {}) do
        disconnect(connection.object, connection.events)
    end
    self._eventConnections = {}
end

function TaskBoardControllerBase:registerEvents(object, events)
    if not object or type(events) ~= "table" then
        return
    end
    connect(object, events)
    self._eventConnections = self._eventConnections or {}
    table.insert(self._eventConnections, { object = object, events = events })
end

function TaskBoardControllerBase:scheduleEvent(callback, delay, eventName)
    return scheduleEvent(callback, delay or 1)
end

function TaskBoardControllerBase:findWidget(id)
    if not self.ui or not id then
        return nil
    end
    local cleanId = tostring(id):gsub("^#", "")
    return self.ui.recursiveGetChildById and self.ui:recursiveGetChildById(cleanId) or nil
end

function TaskBoardControllerBase:loadUi()
    self.ui = g_ui.loadUI('/modules/game_taskboard/taskboard.otui', g_ui.getRootWidget())
    if self.ui then
        return self.ui
    end
    if displayErrorBox then
        displayErrorBox(tr("Task Board"), tr("Unable to load the native Task Board window."))
    end
    return nil
end

function TaskBoardControllerBase:unloadUi()
    if self.ui then
        self.ui:destroy()
        self.ui = nil
    end
end

if not string.capitalize then
    function string:capitalize()
        return (self:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end))
    end
end

if not short_text then
    function short_text(text, maxLength)
        text = tostring(text or "")
        maxLength = tonumber(maxLength) or 0
        if maxLength <= 0 or #text <= maxLength then
            return text
        end
        if maxLength <= 3 then
            return text:sub(1, maxLength)
        end
        return text:sub(1, maxLength - 3) .. "..."
    end
end

if not comma_value then
    function comma_value(value)
        local left, num, right = tostring(tonumber(value) or value or 0):match("^([^%d]*%d)(%d*)(.-)$")
        return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
    end
end

TaskBoardController = TaskBoardControllerBase:new()
TaskBoardController.TAB_BOUNTY = 1
TaskBoardController.TAB_WEEKLY = 2
TaskBoardController.TAB_SHOP   = 3
TaskBoardController.OPCODE     = 234

TaskBoardButton = nil
TaskBoardController.activeTab             = 1
TaskBoardController.bountyTasks           = {}
TaskBoardController.talismans             = {}
TaskBoardController.bountyDifficulty      = 1
TaskBoardController.rerollPoints          = 0
TaskBoardController.bountyRerollCost      = 10
TaskBoardController.preferredClearCost    = 300
TaskBoardController.claimDailyAvailable   = false
TaskBoardController.claimDailyWarning     = false
TaskBoardController.claimDailyServerAvailable = false
TaskBoardController.weeklyMonsters        = {}
TaskBoardController.weeklyItems           = {}
TaskBoardController.weeklyHdr             = {}
TaskBoardController.weeklyDifficultyPending = false
TaskBoardController.weeklyDifficulties    = {}
TaskBoardController.diffModalVisible      = false
TaskBoardController.weeklyRewardTokens    = 0
TaskBoardController.weeklyRewardSeals     = 0
TaskBoardController.weeklyRemainingDays   = 0
TaskBoardController.weeklyXpText          = ""
TaskBoardController.weeklyProgressPct     = 0
TaskBoardController.weeklyProgressTooltip = ""
TaskBoardController.weeklyRewardTokensTooltip = ""
TaskBoardController.weeklyRewardSealsTooltip = ""
TaskBoardController.weeklyShowExtraSlotUnlock = false
TaskBoardController.weeklyDifficultySummaryVisible = false
TaskBoardController.weeklyDifficultyKillSummary = ""
TaskBoardController.weeklyDifficultyDeliverySummary = ""
TaskBoardController.weeklyDifficultyPointsEarned = "0"
TaskBoardController.weeklyDifficultySealsEarned = "0"
TaskBoardController.weeklyDifficultyExperienceEarned = "0"
TaskBoardController.shopItems             = {}
TaskBoardController.shopBalance           = 0
TaskBoardController.shopPage              = 1
TaskBoardController.shopTotalPages        = 1
TaskBoardController.shopTotalOffers       = 0
TaskBoardController.soulsealEntries       = {}
TaskBoardController.soulsealSearchText    = ""
TaskBoardController.soulsealCategoryIndex = 1
TaskBoardController.soulsealSelectedIndex = 0
TaskBoardController.soulsealSelectedName  = "No creature selected"
TaskBoardController.soulsealSelectedRaceId= 0
TaskBoardController.soulsealSelectedOutfit= nil
TaskBoardController.soulsealSelectedPoints= "0"
TaskBoardController.soulsealSelectedDone  = false
TaskBoardController.soulsealSelectedCanFight = false
TaskBoardController.soulsealSelectedCategoryLabel = ""
TaskBoardController.soulsealSelectedHint  = "Select a creature from the list."
TaskBoardController.soulsealHasSelection  = false
TaskBoardController.soulsealHasEntries    = false
TaskBoardController.soulsealEmptyText     = "No Soulseal creatures available."
TaskBoardController.soulsealTopSpacerPxA  = 0
TaskBoardController.soulsealTopSpacerPxB  = 0
TaskBoardController.soulsealTopSpacerPxC  = 0
TaskBoardController.soulsealBottomSpacerPxA = 0
TaskBoardController.soulsealBottomSpacerPxB = 0
TaskBoardController.soulsealBottomSpacerPxC = 0
TaskBoardController.bountyPoints          = 0
TaskBoardController.taskShopPoints        = 0
TaskBoardController.soulpitPoints         = 0
TaskBoardController.availableMonsters     = {}
TaskBoardController.allAvailableMonsters  = {}
TaskBoardController.visibleMonsters       = {}
TaskBoardController.monsterTopSpacerPx    = 0
TaskBoardController.monsterBottomSpacerPx = 0
TaskBoardController.monsterTopSpacerPxA   = 0
TaskBoardController.monsterTopSpacerPxB   = 0
TaskBoardController.monsterTopSpacerPxC   = 0
TaskBoardController.monsterBottomSpacerPxA = 0
TaskBoardController.monsterBottomSpacerPxB = 0
TaskBoardController.monsterBottomSpacerPxC = 0
TaskBoardController.preferredSlots        = {}
TaskBoardController.preferredRawSlots     = {}
TaskBoardController.preferredData         = {}
TaskBoardController.preferredPage         = 1
TaskBoardController.preferredTotalPages   = 1
TaskBoardController.preferredTotal        = 0
TaskBoardController.searchText            = ""
TaskBoardController.selectedRaceId        = 0
TaskBoardController.preferredModal        = nil
TaskBoardController.soulsealModal         = nil
TaskBoardController.compatBalances        = {
    task = 0,
    bounty = 0,
    soulseal = 0
}
TaskBoardController.started               = false
TaskBoardController.opcodeRegistered      = false

local function sendTaskBoardOpcode(action, data)
    local protocol = g_game.getProtocolGame and g_game.getProtocolGame()
    if not protocol or not protocol.sendExtendedOpcode then
        return
    end
    protocol:sendExtendedOpcode(TaskBoardController.OPCODE, json.encode({
        action = action,
        data = data or {}
    }))
end

local function onTaskBoardExtendedOpcode(protocol, opcode, buffer)
    if opcode ~= TaskBoardController.OPCODE then
        return
    end

    local payload = buffer
    if type(payload) ~= "table" then
        local ok, decoded = pcall(json.decode, buffer)
        if not ok or type(decoded) ~= "table" then
            return
        end
        payload = decoded
    end

    if payload.action == "state" then
        TaskBoardController:onTaskBoardCompatState(payload)
    elseif payload.action == "preferredState" then
        TaskBoardController:onPreferredCompatState(payload)
    elseif payload.action == "bountyState" then
        TaskBoardController:onTaskBoardCompatState({
            balances = payload.balances or {},
            bounty = payload.bounty or {}
        })
    elseif payload.action == "weeklyState" then
        TaskBoardController:onTaskBoardCompatState({
            balances = payload.balances or {},
            weekly = payload.weekly or {}
        })
    elseif payload.action == "shopState" then
        TaskBoardController:onTaskBoardCompatState({
            balances = payload.balances or {},
            shop = payload.shop or {}
        })
    elseif payload.action == "shopResult" then
        TaskBoardController:onShopResult(tonumber(payload.itemId) or 0, tonumber(payload.result) or 0)
    elseif payload.action == "weeklyKillUpdate" then
        TaskBoardController:onWeeklyKillUpdate(
            tonumber(payload.raceId) or 0,
            tonumber(payload.current) or 0,
            tonumber(payload.total) or 0,
            tonumber(payload.completed) or 0,
            payload
        )
    elseif payload.action == "bountyKillUpdate" then
        TaskBoardController:onBountyKillUpdate(
            tonumber(payload.raceId) or 0,
            tonumber(payload.current) or 0,
            tonumber(payload.total) or 0,
            tonumber(payload.completed) or 0
        )
    end
end

function TaskBoardController:installCompatProtocol()
    if not g_game then
        return
    end

    if not g_game.bountyTaskAction then
        g_game.bountyTaskAction = function(action, value)
            sendTaskBoardOpcode("bounty", { action = tonumber(action) or 0, value = tonumber(value) or 0 })
        end
    end

    if not g_game.weeklyTaskAction then
        g_game.weeklyTaskAction = function(action, value, amount)
            sendTaskBoardOpcode("weekly", {
                action = tonumber(action) or 0,
                value = tonumber(value) or 0,
                amount = tonumber(amount) or 0
            })
        end
    end

    if not g_game.taskHuntingShopRequest then
        g_game.taskHuntingShopRequest = function(page)
            sendTaskBoardOpcode("shop", { action = "request", page = tonumber(page) or 1 })
        end
    end

    if not g_game.taskHuntingShopPurchase then
        g_game.taskHuntingShopPurchase = function(itemId, page)
            sendTaskBoardOpcode("shop", {
                action = "buy",
                itemId = tonumber(itemId) or 0,
                page = tonumber(page) or 1
            })
        end
    end

    if not g_game.bountyTalismanUpgrade then
        g_game.bountyTalismanUpgrade = function(statType)
            sendTaskBoardOpcode("talisman", { statType = tonumber(statType) or 0 })
        end
    end

    if not g_game.bountyPreferredAction then
        g_game.bountyPreferredAction = function(action, slot, value, search, page)
            sendTaskBoardOpcode("preferred", {
                action = tonumber(action) or 0,
                slot = tonumber(slot) or 0,
                value = tonumber(value) or 0,
                search = tostring(search or ""),
                page = tonumber(page) or 1
            })
        end
    end

    if not g_game.soulsealFightAction then
        g_game.soulsealFightAction = function(raceId)
            sendTaskBoardOpcode("soulseal", { raceId = tonumber(raceId) or 0 })
        end
    end
end

function TaskBoardController:onTaskBoardCompatState(payload)
    local balances = payload.balances or {}
    self.compatBalances = {
        task = tonumber(balances.task) or tonumber(self.compatBalances.task) or 0,
        bounty = tonumber(balances.bounty) or tonumber(self.compatBalances.bounty) or 0,
        soulseal = tonumber(balances.soulseal) or tonumber(self.compatBalances.soulseal) or 0
    }

    if payload.bounty then
        self:onBountyServerData(payload.bounty.header or {}, payload.bounty.monsters or {}, payload.bounty.talisman or {}, payload.bounty.preferred or {})
    end

    if payload.weekly then
        self:onWeeklyServerData(payload.weekly.header or {}, payload.weekly.monsters or {}, payload.weekly.items or {})
    end

    if payload.shop then
        self:onShopData(payload.shop.items or {}, payload.shop)
    end

    self:syncResourceBalances()
    self:refreshNativeUi()
end

function TaskBoardController:onPreferredCompatState(payload)
    local balances = payload.balances or {}
    if balances.bounty ~= nil then
        self.compatBalances.bounty = tonumber(balances.bounty) or tonumber(self.compatBalances.bounty) or 0
        self.bountyBalanceRaw = tonumber(balances.bounty) or tonumber(self.bountyBalanceRaw) or 0
        self.bountyPoints = comma_value(self.bountyBalanceRaw)
    end

    self.preferredData = payload.preferred or {}
    self.availableMonsters = self.preferredData.availableMonsters or {}
    self.preferredRawSlots = self.preferredData.slots or {}
    self.preferredClearCost = tonumber(self.preferredData.clearCost) or 300
    self.preferredPage = tonumber(self.preferredData.page) or 1
    self.preferredTotalPages = tonumber(self.preferredData.totalPages) or 1
    self.preferredTotal = tonumber(self.preferredData.total) or 0
    self.searchText = tostring(self.preferredData.search or self.searchText or "")

    if self.preferredModal then
        self:rebuildPreferredMonsterList()
        self:rebuildPreferredSlots()
    end
    self:refreshNativeUi()
end

function TaskBoardController:getResourceBalance(resourceType, fallback)
    local player = g_game.getLocalPlayer and g_game.getLocalPlayer()
    if player and player.getResourceBalance and resourceType ~= nil then
        return tonumber(player:getResourceBalance(resourceType)) or fallback or 0
    end
    return fallback or 0
end

function TaskBoardController:getRaceData(raceId, fallback)
    raceId = tonumber(raceId) or 0
    fallback = fallback or {}
    local fallbackName = fallback.name or fallback.monsterName

    if raceId > 0 and g_things and g_things.getRaceData then
        local raceData = g_things.getRaceData(raceId)
        if raceData then
            return {
                name = fallbackName or raceData.name or ("Creature " .. raceId),
                outfit = fallback.outfit or raceData.outfit
            }
        end
    end

    if raceId > 0 and g_things and g_things.getMonsterList then
        local monsterList = g_things.getMonsterList()
        local monster = monsterList and monsterList[raceId]
        if monster then
            return {
                name = fallbackName or monster.name or monster[1] or ("Creature " .. raceId),
                outfit = fallback.outfit or monster.outfit or monster[2]
            }
        end
    end

    return {
        name = fallbackName or (raceId == 0 and "Any Creature" or ("Creature " .. raceId)),
        outfit = fallback.outfit
    }
end

local function applyBountyOutfit(widget, outfit)
    if not widget then
        return
    end

    if outfit and next(outfit) then
        -- Match Bestiary.applyOutfit so custom palettes and addons render here.
        widget:setOutfit({
            type = tonumber(outfit.lookType or outfit.type) or 0,
            auxType = tonumber(outfit.lookTypeEx or outfit.auxType) or 0,
            addons = tonumber(outfit.lookAddons or outfit.addons) or 0,
            mount = tonumber(outfit.lookMount or outfit.mount) or 0,
            wings = tonumber(outfit.lookWings or outfit.wings) or 0,
            aura = tonumber(outfit.lookAura or outfit.aura) or 0,
            feet = tonumber(outfit.lookFeet or outfit.feet) or 0,
            legs = tonumber(outfit.lookLegs or outfit.legs) or 0,
            body = tonumber(outfit.lookBody or outfit.body) or 0,
            head = tonumber(outfit.lookHead or outfit.head) or 0
        })
    else
        widget:setOutfit({})
    end
end

local function setLabelText(parent, id, text)
    local widget = parent and parent:recursiveGetChildById(id)
    if widget then
        if widget.value then
            widget.value:setText(tostring(text or ""))
        else
            widget:setText(tostring(text or ""))
        end
    end
end

local function setCurrencyBox(parent, id, text, icon, tooltip)
    local widget = parent and parent:recursiveGetChildById(id)
    if not widget then
        return
    end
    if tooltip then
        widget:setTooltip(tostring(tooltip))
    end
    if widget.value then
        widget.value:setText(tostring(text or "0"))
        if tooltip then
            widget.value:setTooltip(tostring(tooltip))
        end
    end
    if widget.icon and icon then
        widget.icon:setImageSource(icon)
        if tooltip then
            widget.icon:setTooltip(tostring(tooltip))
        end
    end
end

function TaskBoardController:setLabelText(parent, id, text)
    setLabelText(parent, id, text)
end

function TaskBoardController:setCurrencyBox(parent, id, text, icon, tooltip)
    setCurrencyBox(parent, id, text, icon, tooltip)
end

local function clearPanel(panel)
    if panel then
        panel:destroyChildren()
    end
end

local function addBountyCard(parent, task, buttonText, callback, enabled)
    if not parent then
        return nil
    end

    local card = g_ui.createWidget('TaskBoardBountyCard', parent)
    card.title:setText(tostring(task.name or "Unknown"))
    if card.backdrop then
        card.backdrop:setImageSource(task.backdrop or RARITY_BACKDROPS[0])
    end
    if card.lockedOverlay then
        card.lockedOverlay:setVisible(task.locked == true)
    end
    card.progress:setText(string.format("%d / %d kills", tonumber(task.current) or 0, tonumber(task.total) or 0))
    if card.timer then
        card.timer:setText(tostring(task.timer or ""))
    end
    card.reward:setText(string.format("Reward:\n* %s XP\n* %s Hunting Task Points\n* %s Reroll Token",
        tostring(task.xp or 0), tostring(task.points or 0), tostring(task.reroll or 0)))

    if task.outfit then
        applyBountyOutfit(card.creatureBox.creature, task.outfit)
        card.creatureBox.creature:show()
    else
        card.creatureBox.creature:hide()
    end

    if task.locked == true then
        card.title:setText(string.format("Bounty Slot %d", tonumber(task.taskIndex) or 0))
        card.title:setColor("#9f9f9f")
        card.action:setVisible(false)
        card.reward:setColor("#9f9f9f")
        card.progress:setColor("#9f9f9f")
        card.timer:setColor("#9f9f9f")
        setCurrencyBox(card, 'unlockCost', tostring(task.unlockCost or 0), '/game_taskboard/assets/images/icon-currency-bountypoints', 'Bounty Points')
        card.lockedOverlay.unlockAction:setEnabled(task.canUnlock == true)
        card.lockedOverlay.unlockAction.onClick = callback
        return card
    end

    if buttonText then
        card.action:setText(buttonText)
        card.action:setEnabled(enabled ~= false)
        card.action.onClick = callback
    else
        card.action:setText(task.isCompleted and "Completed" or "Active")
        card.action:setEnabled(false)
    end
    return card
end

local function addTalismanCard(parent, talisman)
    if not parent then
        return nil
    end

    local card = g_ui.createWidget('TaskBoardTalismanCard', parent)
    card.icon:setImageSource(talisman.icon or "")
    card.title:setText(tostring(talisman.title or ""))
    card.current:setText(tostring(talisman.current or ""))
    if card.cost then
        card.cost:setText(tostring(talisman.costText or ""))
    end
    if card.costIcon then
        card.costIcon:setImageSource(talisman.costIcon or "/game_taskboard/assets/images/icon-currency-bountypoints")
        card.costIcon:setTooltip(tostring(talisman.costTooltip or "Bounty Points"))
        card.costIcon:setVisible(talisman.isMaxed ~= true)
    end
    card.action:setText(tostring(talisman.buttonText or "Upgrade"))
    card.action:setEnabled(talisman.upgradeable == true)
    card.action.onClick = function()
        if talisman.upgradeable then
            TaskBoardController:upgradeTalisman(talisman.statType)
        end
    end
    return card
end

local function addWeeklyMonsterCard(parent, monster)
    if not parent then
        return nil
    end

    local card = g_ui.createWidget('WeeklyTaskCard', parent)
    local locked = monster.locked == true
    local slotNumber = (tonumber(monster.slotIndex) or 0) + 1
    card.title:setText(locked and string.format("Kill Slot %d", slotNumber) or short_text(monster.fullName or monster.name or "Unknown", 18))
    card.item:hide()
    card.creature:show()
    if monster.outfit then
        applyBountyOutfit(card.creature, monster.outfit)
    else
        card.creature:hide()
    end
    card.check:setText("")
    card.check:setVisible(false)
    if monster.finished == true then
        local checkmark = g_ui.createWidget('UIWidget', card)
        checkmark:setImageSource('/game_taskboard/assets/images/checkmark')
        checkmark:setSize({ width = 14, height = 14 })
        checkmark:addAnchor(AnchorRight, 'parent', AnchorRight)
        checkmark:addAnchor(AnchorVerticalCenter, 'creature', AnchorVerticalCenter)
        checkmark:setMarginRight(12)
    end
    card.action:hide()
    card.progress:setText(locked and "Locked" or (monster.finished and "Completed" or string.format("%d / %d", tonumber(monster.current) or 0, tonumber(monster.total) or 0)))
    if card.lockedOverlay then
        card.lockedOverlay:setVisible(locked)
        if locked then
            setCurrencyBox(card.lockedOverlay, 'unlockCost', tostring(monster.unlockCost or 1000), '/game_taskboard/assets/images/icon-currency-soulseals', 'Soulseals')
        end
    end
    return card
end

local function addWeeklyItemCard(parent, item)
    if not parent then
        return nil
    end

    local card = g_ui.createWidget('WeeklyTaskCard', parent)
    local locked = item.locked == true
    local slotNumber = (tonumber(item.slotIndex) or 0) + 1
    card.title:setText(locked and string.format("Delivery Slot %d", slotNumber) or short_text(item.itemName or "Unknown Item", 18))
    card.creature:hide()
    card.item:show()
    card.item:setItemId(tonumber(item.clientId) or tonumber(item.itemId) or 0)
    card.check:setText("")
    card.check:setVisible(false)
    if item.delivered == true then
        local checkmark = g_ui.createWidget('UIWidget', card)
        checkmark:setImageSource('/game_taskboard/assets/images/checkmark')
        checkmark:setSize({ width = 14, height = 14 })
        checkmark:addAnchor(AnchorRight, 'parent', AnchorRight)
        checkmark:addAnchor(AnchorVerticalCenter, 'item', AnchorVerticalCenter)
        checkmark:setMarginRight(12)
    end
    card.progress:setText(locked and "Locked" or (item.delivered and "Delivered" or string.format("%d / %d", tonumber(item.current) or 0, tonumber(item.total) or 0)))
    if item.needsDelivery then
        card.action:show()
        card.action:setText("Deliver")
        card.action:setEnabled(true)
        if item.canDeliver ~= true then
            card.action:setTooltip("You do not have this item in your inventory.")
        else
            card.action:setTooltip(string.format("You have %d available.", tonumber(item.owned) or 0))
        end
    else
        card.action:hide()
    end
    if card.lockedOverlay then
        card.lockedOverlay:setVisible(locked)
        if locked then
            setCurrencyBox(card.lockedOverlay, 'unlockCost', tostring(item.unlockCost or 500), '/game_taskboard/assets/images/icon-currency-soulseals', 'Soulseals')
        end
    end
    return card
end

local function addShopCard(parent, item, callback, enabled)
    if not parent then
        return nil
    end

    local card = g_ui.createWidget('TaskBoardShopCard', parent)
    card.title:setText(tostring(item.title or ""))
    card.description:setText(tostring(item.description or ""))
    card:setOpacity(item.bought and 0.58 or 1)
    if card.boughtOverlay then
        card.boughtOverlay:setVisible(item.bought == true)
    end
    if card.boughtText then
        card.boughtText:setText("Already owned")
    end
    if card.timer then
        card.timer:setText(tostring(item.timerText or ""))
        card.timer:setVisible(tostring(item.timerText or "") ~= "")
    end
    card.backdrop:setImageSource(item.backdrop or "")
    setCurrencyBox(card, 'price', item.displayPrice or item.price or 0, item.currencyIcon or '/game_taskboard/assets/images/task-tokens', item.currencyLabel)

    card.previewBox.creature:hide()
    card.previewBox.item:hide()
    card.previewBox.icon:hide()
    if item.previewType == 'creature' then
        card.previewBox.creature:setOutfit({
            type = item.lookType or 0,
            head = item.lookHead or 0,
            body = item.lookBody or 0,
            legs = item.lookLegs or 0,
            feet = item.lookFeet or 0,
            addons = item.lookAddons or 0,
            mount = item.lookMount or 0,
            wings = item.lookWings or 0,
            aura = item.lookAura or 0,
            shader = item.lookShader or 0
        })
        card.previewBox.creature:show()
    elseif item.previewType == 'item' then
        card.previewBox.item:setItemId(tonumber(item.clientId) or tonumber(item.itemId) or 0)
        card.previewBox.item:show()
    elseif item.previewType == 'icon' then
        card.previewBox.icon:setImageSource(item.imageSource or "")
        card.previewBox.icon:show()
    end

    card.action:setText(item.bought and "Owned" or "Buy")
    card.action:setEnabled(enabled ~= false and item.bought ~= true)
    card.action.onClick = callback
    return card
end

function TaskBoardController:refreshNativeUi()
    if not self.ui then
        return
    end

    setCurrencyBox(self.ui, 'bountyBalance', self.bountyPoints, '/game_taskboard/assets/images/icon-currency-bountypoints', 'Bounty Points')
    setCurrencyBox(self.ui, 'taskBalance', self.taskShopPoints, '/game_taskboard/assets/images/task-tokens', 'Hunting Task Points')
    setCurrencyBox(self.ui, 'soulsealBalance', self.soulpitPoints, '/game_taskboard/assets/images/icon-currency-soulseals', 'Soulseals')

    self:renderNativeBounty()
    self:renderNativeWeekly()
    self:renderNativeShop()
end

function TaskBoardController:bindNativeUi()
    if not self.ui then
        return
    end

    local tabs = {
        tabDaily = self.TAB_BOUNTY,
        tabWeekly = self.TAB_WEEKLY,
        tabShop = self.TAB_SHOP
    }
    for id, tab in pairs(tabs) do
        local button = self.ui:recursiveGetChildById(id)
        if button then
            button.onClick = function()
                self:selectTab(tab)
            end
        end
    end

    local closeButton = self.ui:recursiveGetChildById('closeButton')
    if closeButton then
        closeButton.onClick = function()
            self:hide()
        end
    end

    self.ui.onEscape = function()
        self:hide()
    end
end

function TaskBoardController:renderNativeBounty()
    local list = self.ui and self.ui:recursiveGetChildById('bountyList')
    clearPanel(list)
    self.bountyTaskCards = {}
    if not list then
        return
    end

    local combo = self.ui and self.ui:recursiveGetChildById('dailyDifficultySelect')
    if combo and combo.getOptionsCount and combo:getOptionsCount() == 0 then
        combo:addOption('Beginner', '1')
        combo:addOption('Adept', '2')
        combo:addOption('Expert', '3')
        combo:addOption('Master', '4')
        combo:addOption('Extreme', '5')
        combo.onOptionChange = function(widget, text, data)
            self:changeDifficulty({ data = data })
        end
    end
    self:syncBountyDifficultySelect()
    if combo then
        combo:setEnabled(self.bountyHasActiveTask ~= true)
        combo:setTooltip(self.bountyHasActiveTask and "Reroll tasks to change difficulty." or "")
    end

    local preferredButton = self.ui and self.ui:recursiveGetChildById('preferredButton')
    if preferredButton then
        preferredButton.onClick = function() self:showPreferred() end
    end

    local rerollButton = self.ui and self.ui:recursiveGetChildById('rerollButton')
    if rerollButton then
        local canReroll = (tonumber(self.bountyBalanceRaw) or 0) >= (tonumber(self.bountyRerollCost) or 10)
            and (tonumber(self.rerollPoints) or 0) > 0
        rerollButton:setEnabled(canReroll)
        rerollButton:setTooltip(canReroll and '' or 'Requires bounty points and a reroll token.')
        rerollButton.onClick = function() self:rerollMonsters() end
    end
    setCurrencyBox(self.ui, 'rerollCost', tostring(self.bountyRerollCost or 10), '/game_taskboard/assets/images/icon-currency-bountypoints', 'Bounty Points')
    setCurrencyBox(self.ui, 'rerollRemaining', string.format("%d / %d", tonumber(self.rerollPoints) or 0, REROLL_TOKEN_CAP), '/game_taskboard/assets/images/icon-currency-taskreroll', 'Reroll Tokens Remaining')

    local grid = g_ui.createWidget('TaskBoardBountyGrid', list)
    for _, task in ipairs(self.bountyTasks or {}) do
        local buttonText = task.canClaim and "Claim" or ((not task.locked and not task.isActive and not task.isCompleted) and "Select" or nil)
        local callback = nil
        if task.locked then
            callback = function()
                g_game.bountyTaskAction(BOUNTY_ACTION_UNLOCK_SLOT, task.taskIndex)
            end
        elseif task.canClaim then
            callback = function() self:claimReward(task.taskIndex) end
        elseif buttonText == "Select" then
            callback = function() self:selectTask(task.taskIndex) end
        end
        local card = addBountyCard(grid, task, buttonText, callback, true)
        if card and not task.locked then
            local raceId = tonumber(task.raceId) or 0
            self.bountyTaskCards[raceId] = self.bountyTaskCards[raceId] or {}
            self.bountyTaskCards[raceId][#self.bountyTaskCards[raceId] + 1] = card
        end
    end

    local talismanPanel = g_ui.createWidget('TaskBoardTalismanPanel', list)
    local talismanList = talismanPanel and talismanPanel:recursiveGetChildById('talismanList')
    for _, talisman in ipairs(self.talismans or {}) do
        addTalismanCard(talismanList, talisman)
    end
end

function TaskBoardController:renderNativeWeekly()
    local killList = self.ui and self.ui:recursiveGetChildById('weeklyKillList')
    local deliveryList = self.ui and self.ui:recursiveGetChildById('weeklyDeliveryList')
    local difficultyPanel = self.ui and self.ui:recursiveGetChildById('weeklyDifficultyPanel')
    clearPanel(killList)
    clearPanel(deliveryList)
    self.weeklyMonsterCards = {}

    for _, monster in ipairs(self.weeklyMonsters or {}) do
        local card = addWeeklyMonsterCard(killList, monster)
        if card then
            local slotIndex = tonumber(monster.slotIndex) or 0
            self.weeklyMonsterCards[slotIndex] = card
            if monster.locked and card.lockedOverlay and card.lockedOverlay.unlockAction then
                card.lockedOverlay.unlockAction.onClick = function()
                    g_game.weeklyTaskAction(WEEKLY_ACTION_UNLOCK_KILL_SLOT, slotIndex + 1)
                end
            end
        end
    end

    for _, item in ipairs(self.weeklyItems or {}) do
        local card = addWeeklyItemCard(deliveryList, item)
        if card and item.locked and card.lockedOverlay and card.lockedOverlay.unlockAction then
            local slotIndex = tonumber(item.slotIndex) or 0
            card.lockedOverlay.unlockAction.onClick = function()
                g_game.weeklyTaskAction(WEEKLY_ACTION_UNLOCK_DELIVERY_SLOT, slotIndex + 1)
            end
        elseif card and item.needsDelivery then
            card.action.onClick = function()
                self:deliverItem(item)
            end
        end
    end

    setLabelText(self.ui, 'weeklyXp', self.weeklyXpText)
    setLabelText(self.ui, 'weeklyProgressText', self.weeklyProgressTooltip)
    local progress = self.ui and self.ui:recursiveGetChildById('weeklyProgress')
    if progress then
        progress:setPercent(tonumber(self.weeklyProgressPct) or 0)
    end
    setCurrencyBox(self.ui, 'weeklyTaskReward', self.weeklyRewardTokens, '/game_taskboard/assets/images/task-tokens', 'Hunting Task Points')
    setCurrencyBox(self.ui, 'weeklySoulsealReward', self.weeklyRewardSeals, '/game_taskboard/assets/images/icon-currency-soulseals', 'Soulseals')
    setLabelText(self.ui, 'weeklyRemaining', string.format("%d day(s) remaining", tonumber(self.weeklyRemainingDays) or 0))

    if difficultyPanel then
        difficultyPanel:setVisible(self.weeklyDifficultyPending == true)
        local summary = string.format("You have completed 0 / %d kill tasks.\nYou have completed 0 / %d delivery tasks.",
            tonumber(self.weeklyHdr.unlockedKillSlots) or WEEKLY_DEFAULT_TASK_SLOTS,
            tonumber(self.weeklyHdr.unlockedDeliverySlots) or WEEKLY_DEFAULT_TASK_SLOTS)
        if self.weeklyDifficultySummaryVisible then
            summary = string.format("%s\n%s",
                self.weeklyDifficultyKillSummary or "",
                self.weeklyDifficultyDeliverySummary or "")
        end
        difficultyPanel.difficultySummary:setText(summary)
        setLabelText(difficultyPanel, 'difficultyRewardTokens', tostring(self.weeklyDifficultyPointsEarned or "0"))
        setLabelText(difficultyPanel, 'difficultyRewardSoulseals', tostring(self.weeklyDifficultySealsEarned or "0"))
        setLabelText(difficultyPanel, 'difficultyRewardExperience', tostring(self.weeklyDifficultyExperienceEarned or "0"))

        local buttons = {
            difficultyBeginner = 1,
            difficultyAdept = 2,
            difficultyExpert = 3,
            difficultyMaster = 4,
            difficultyExtreme = 5
        }
        for id, diffId in pairs(buttons) do
            local button = difficultyPanel:recursiveGetChildById(id)
            local difficulty = self.weeklyDifficulties and self.weeklyDifficulties[diffId]
            if button then
                button:setEnabled(not difficulty or difficulty.canSelect ~= false)
                button.onClick = function()
                    self:selectDifficulty(diffId)
                end
            end
        end
    end
end

function TaskBoardController:renderNativeShop()
    local list = self.ui and self.ui:recursiveGetChildById('shopList')
    clearPanel(list)

    local pager = self.ui and self.ui:recursiveGetChildById('shopPager')
    if pager then
        local page = tonumber(self.shopPage) or 1
        local totalPages = tonumber(self.shopTotalPages) or 1
        pager.pageText:setText(string.format("%d / %d", page, totalPages))
        pager.prevPage:setEnabled(page > 1)
        pager.nextPage:setEnabled(page < totalPages)
        pager.prevPage.onClick = function()
            if g_game.taskHuntingShopRequest then
                g_game.taskHuntingShopRequest(math.max(1, page - 1))
            end
        end
        pager.nextPage.onClick = function()
            if g_game.taskHuntingShopRequest then
                g_game.taskHuntingShopRequest(math.min(totalPages, page + 1))
            end
        end
    end

    for _, item in ipairs(self.shopItems or {}) do
        local bought = item.bought == true
        local canBuy = (item.canAfford == true) and not bought
        addShopCard(list, item, function()
            if canBuy then
                self:buyItem(item.id)
            end
        end, canBuy)
    end
end

function TaskBoardController:queueNativePanelRender(panelName)
    if not self.ui or not self.ui:isVisible() then
        return
    end

    if panelName == 'weekly' then
        if self.pendingWeeklyRender then
            return
        end
        self.pendingWeeklyRender = self:scheduleEvent(function()
            self.pendingWeeklyRender = nil
            if self.ui and self.ui:isVisible() then
                self:renderNativeWeekly()
            end
        end, 250, "taskBoardWeeklyRender")
    elseif panelName == 'bounty' then
        if self.pendingBountyRender then
            return
        end
        self.pendingBountyRender = self:scheduleEvent(function()
            self.pendingBountyRender = nil
            if self.ui and self.ui:isVisible() then
                self:renderNativeBounty()
            end
        end, 250, "taskBoardBountyRender")
    end
end

function TaskBoardController:updateCachedWeeklyCards(raceId, currentKills, totalKills, isCompleted, slotIndex)
    local card = self.weeklyMonsterCards and self.weeklyMonsterCards[tonumber(slotIndex) or -1]
    if not card then
        return false
    end

    if card and not card:isDestroyed() and card.progress then
        card.progress:setText(isCompleted == 1 and "Completed" or string.format("%d / %d", tonumber(currentKills) or 0, tonumber(totalKills) or 0))
    end
    return true
end

function TaskBoardController:updateCachedBountyCards(raceId, currentKills, totalKills, isCompleted)
    local cards = self.bountyTaskCards and self.bountyTaskCards[tonumber(raceId) or 0]
    if not cards then
        return false
    end

    for _, card in ipairs(cards) do
        if card and not card:isDestroyed() and card.progress then
            card.progress:setText(string.format("%d / %d kills", tonumber(currentKills) or 0, tonumber(totalKills) or 0))
        end
    end
    return true
end

function TaskBoardController:resetSessionState()
    self.activeTab = self.TAB_BOUNTY

    self.bountyTasks = {}
    self.bountyTaskCards = {}
    self.talismans = {}
    self.bountyDifficulty = 1
    self.rerollPoints = 0
    self.bountyRerollCost = 10
    self.claimDailyAvailable = false
    self.claimDailyWarning = false
    self.claimDailyServerAvailable = false

    self.weeklyMonsters = {}
    self.weeklyMonsterCards = {}
    self.weeklyItems = {}
    self.weeklyHdr = {}
    self.weeklyDifficultyPending = false
    self.weeklyDifficulties = {}
    self.diffModalVisible = false
    self.weeklyRewardTokens = 0
    self.weeklyRewardSeals = 0
    self.weeklyRemainingDays = 0
    self.weeklyXpText = ""
    self.weeklyProgressPct = 0
    self.weeklyProgressTooltip = ""
    self.weeklyRewardTokensTooltip = ""
    self.weeklyRewardSealsTooltip = ""
    self.weeklyShowExtraSlotUnlock = false
    self.weeklyDifficultySummaryVisible = false
    self.weeklyDifficultyKillSummary = ""
    self.weeklyDifficultyDeliverySummary = ""
    self.weeklyDifficultyPointsEarned = "0"
    self.weeklyDifficultySealsEarned = "0"
    self.weeklyDifficultyExperienceEarned = "0"

    self.shopItems = {}
    self.shopBalance = 0
    self.shopPage = 1
    self.shopTotalPages = 1
    self.shopTotalOffers = 0

    self.availableMonsters = {}
    self.allAvailableMonsters = {}
    self.visibleMonsters = {}
    self.monsterTopSpacerPx = 0
    self.monsterBottomSpacerPx = 0
    self.monsterTopSpacerPxA = 0
    self.monsterTopSpacerPxB = 0
    self.monsterTopSpacerPxC = 0
    self.monsterBottomSpacerPxA = 0
    self.monsterBottomSpacerPxB = 0
    self.monsterBottomSpacerPxC = 0
    self.preferredSlots = {}
    self.preferredRawSlots = {}
    self.preferredData = {}
    self.preferredPage = 1
    self.preferredTotalPages = 1
    self.preferredTotal = 0
    self.searchText = ""
    self.selectedRaceId = 0
    self.pendingWeeklyRender = nil
    self.pendingBountyRender = nil
    self.pendingTabRequest = nil

    if self.resetSoulsealState then
        self:resetSoulsealState(true)
    end

    self.bountyPoints = 0
    self.taskShopPoints = 0
    self.soulpitPoints = 0
end

function TaskBoardController:onInit()
end

function TaskBoardController:onGameStart()
    if self.started then
        self:syncResourceBalances()
        return
    end

    self:installCompatProtocol()
    if ProtocolGame and ProtocolGame.registerExtendedJSONOpcode then
        local ok = pcall(function()
            ProtocolGame.registerExtendedJSONOpcode(self.OPCODE, onTaskBoardExtendedOpcode)
        end)
        self.opcodeRegistered = ok
    end
    self:registerEvents(g_game, {
        onResourcesBalanceChange = function(...) self:onResourceBalance(...) end,
        onTaskHuntingShopData    = function(...) self:onShopData(...) end,
        onTaskHuntingShopResult  = function(...) self:onShopResult(...) end,
        onWeeklyTaskData         = function(...) self:onWeeklyServerData(...) end,
        onBountyTaskData         = function(...) self:onBountyServerData(...) end,
        onBountyKillUpdate       = function(...) self:onBountyKillUpdate(...) end,
        onWeeklyKillUpdate       = function(...) self:onWeeklyKillUpdate(...) end,
    })
    if not TaskBoardButton and modules.client_topmenu and modules.client_topmenu.addRightGameToggleButton then
        TaskBoardButton = modules.client_topmenu.addRightGameToggleButton("taskHuntButton", tr("Task Board"),
            "/images/topbuttons/taskboard", function()
                self:toggle()
            end, false, 1006)
    end

    self:initTracker()
    self:syncResourceBalances()
    self.started = true
end

function TaskBoardController:onGameEnd()
    if self.pendingTabRequest then
        removeEvent(self.pendingTabRequest)
        self.pendingTabRequest = nil
    end
    if self.pendingWeeklyRender then
        removeEvent(self.pendingWeeklyRender)
        self.pendingWeeklyRender = nil
    end
    if self.pendingBountyRender then
        removeEvent(self.pendingBountyRender)
        self.pendingBountyRender = nil
    end
    self:hide()
    if self.hideSoulseal then
        self:hideSoulseal()
    end
    self:resetSessionState()
    self.started = false
end

function TaskBoardController:onTerminate()
    if ProtocolGame and ProtocolGame.unregisterExtendedJSONOpcode and self.opcodeRegistered then
        pcall(function()
            ProtocolGame.unregisterExtendedJSONOpcode(self.OPCODE)
        end)
        if ProtocolGame.unregisterExtendedOpcode then
            pcall(function()
                ProtocolGame.unregisterExtendedOpcode(self.OPCODE)
            end)
        end
        self.opcodeRegistered = false
    end
    if TaskBoardButton then
        TaskBoardButton:destroy()
        TaskBoardButton = nil
    end
    if self.hidePreferred then
        self:hidePreferred()
    end
    if self.hideSoulseal then
        self:hideSoulseal()
    end
    if self.ui then
        self:unloadUi()
    end
    self:terminateTracker()
end

function TaskBoardController:show()
    if not self.ui then
        self:loadUi()
    end
    if not self.ui then
        return
    end
    self:bindNativeUi()
    self:syncResourceBalances()
    self:refreshNativeUi()
    self.ui:show()
    self.ui:raise()
    self.ui:focus()
    if TaskBoardButton then
        TaskBoardButton:setOn(true)
    end
    local tabToShow = self.weeklyDifficultyPending and self.TAB_WEEKLY or self.activeTab
    self:selectTab(tabToShow)
    self:syncBountyDifficultySelect()
end

function TaskBoardController:hide()
    if self.hidePreferred then
        self:hidePreferred()
    end
    if self.pendingTabRequest then
        removeEvent(self.pendingTabRequest)
        self.pendingTabRequest = nil
    end
    self.shopItems = {}
    if self.ui then
        self:unloadUi()
    end
    if TaskBoardButton then
        TaskBoardButton:setOn(false)
    end
end

function TaskBoardController:toggle()
    if self.ui and self.ui:isVisible() then
        self:hide()
    else
        self:show()
    end
end

function TaskBoardController:requestTabData(tab, delay)
    if self.pendingTabRequest then
        removeEvent(self.pendingTabRequest)
        self.pendingTabRequest = nil
    end

    self.pendingTabRequest = self:scheduleEvent(function()
        self.pendingTabRequest = nil
        if not self.ui or not self.ui:isVisible() or self.activeTab ~= tab then
            return
        end

        if tab == self.TAB_BOUNTY and g_game.bountyTaskAction then
            g_game.bountyTaskAction(BOUNTY_ACTION_REQUEST, 0)
            self:syncBountyDifficultySelect()
        elseif tab == self.TAB_WEEKLY and g_game.weeklyTaskAction then
            g_game.weeklyTaskAction(WEEKLY_ACTION_REFRESH_DATA, 0)
            self:onWeeklyTabSelected()
        elseif tab == self.TAB_SHOP and g_game.taskHuntingShopRequest then
            g_game.taskHuntingShopRequest(tonumber(self.shopPage) or 1)
        end
    end, delay or 150, "taskBoardTabRequest")
end

function TaskBoardController:selectTab(n)
    if self.weeklyDifficultyPending and n ~= self.TAB_WEEKLY then
        return
    end
    self.activeTab = n
    local tabDaily = self:findWidget("#tabDaily")
    local tabWeekly = self:findWidget("#tabWeekly")
    local tabShop = self:findWidget("#tabShop")
    if tabDaily then
        tabDaily:setChecked(n == self.TAB_BOUNTY)
    end
    if tabWeekly then
        tabWeekly:setChecked(n == self.TAB_WEEKLY)
    end
    if tabShop then
        tabShop:setChecked(n == self.TAB_SHOP)
    end

    local bountyPanel = self:findWidget("#bountyPanel")
    local weeklyPanel = self:findWidget("#weeklyPanel")
    local shopPanel = self:findWidget("#shopPanel")
    if bountyPanel then
        bountyPanel:setVisible(n == self.TAB_BOUNTY)
    end
    if weeklyPanel then
        weeklyPanel:setVisible(n == self.TAB_WEEKLY)
    end
    if shopPanel then
        shopPanel:setVisible(n == self.TAB_SHOP)
    end

    if n == self.TAB_BOUNTY then
        self:syncBountyDifficultySelect()
    elseif n == self.TAB_WEEKLY then
        self:onWeeklyTabSelected()
    end

    self:requestTabData(n, 150)
end

function TaskBoardController:syncBountyDifficultySelect()
    local combo = self:findWidget("#dailyDifficultySelect")
    if not combo then
        return
    end

    local optionText = ({
        [1] = 'Beginner',
        [2] = 'Adept',
        [3] = 'Expert',
        [4] = 'Master',
        [5] = 'Extreme'
    })[tonumber(self.bountyDifficulty) or 1]

    if combo.setCurrentOptionByData then
        combo:setCurrentOptionByData(tostring(self.bountyDifficulty), true)
    end

    if optionText and combo.setCurrentOption then
        combo:setCurrentOption(optionText, true)
    end
end

function TaskBoardController:openTaskStore()
    modules.game_store.toggle()
    g_game.sendRequestUsefulThings(StoreConst.TASKHUNTING_THIRDSLOT)
end

function TaskBoardController:syncResourceBalances()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    local taskResource = ResourceTypes and ResourceTypes.TASK_HUNTING or nil
    local soulsealResource = ResourceTypes and ResourceTypes.SOULSEALS or nil
    local bountyResource = ResourceTypes and ResourceTypes.BOUNTY_POINTS or nil
    local taskBalance = self:getResourceBalance(taskResource, tonumber(self.compatBalances.task) or 0)
    local soulsealBalance = self:getResourceBalance(soulsealResource, tonumber(self.compatBalances.soulseal) or 0)
    local bountyBalance = self:getResourceBalance(bountyResource, tonumber(self.compatBalances.bounty) or 0)

    self.taskShopBalanceRaw = taskBalance
    self.soulpitBalanceRaw = soulsealBalance
    self.bountyBalanceRaw = bountyBalance
    self.taskShopPoints = comma_value(taskBalance)
    self.soulpitPoints = comma_value(soulsealBalance)
    self.bountyPoints = comma_value(bountyBalance)

    local rerollBalance = tonumber(self.rerollPoints) or 0
    self.rerollPoints = rerollBalance
    self.claimDailyWarning = rerollBalance >= REROLL_TOKEN_CAP
    self.claimDailyAvailable = self.claimDailyServerAvailable and rerollBalance < REROLL_TOKEN_CAP

    if self.preferredModal then
        self:rebuildPreferredSlots()
    end

    self:updateShopBalance()
end

function TaskBoardController:onResourceBalance(balance, oldBalance, resourceType)
    if not self.ui or not self.ui:isVisible() then
        return
    end
    if resourceType == nil then
        return
    end

    if ResourceTypes and resourceType == ResourceTypes.TASK_HUNTING then
        self.taskShopBalanceRaw = balance
        self.taskShopPoints = comma_value(balance)
        self:updateShopBalance()
    elseif ResourceTypes and resourceType == ResourceTypes.SOULSEALS then
        self.soulpitBalanceRaw = balance
        self.soulpitPoints = comma_value(balance)
        self:updateShopBalance()
        if self.refreshSoulsealAffordability then
            self:refreshSoulsealAffordability()
        end
    elseif ResourceTypes and resourceType == ResourceTypes.BOUNTY_POINTS then
        self.bountyBalanceRaw = balance
        self.bountyPoints = comma_value(balance)
        if self.preferredModal then
            self:rebuildPreferredSlots()
        end
    end
end

local function findMonsterByRaceId(list, raceId)
    raceId = tonumber(raceId) or 0
    for _, monster in ipairs(list or {}) do
        if (tonumber(monster.raceId) or 0) == raceId then
            return monster
        end
    end
    return nil
end

function TaskBoardController:showPreferred()
    if self.preferredModal then
        self.preferredModal:raise()
        self.preferredModal:focus()
        return
    end

    self.preferredModal = g_ui.createWidget('TaskBoardPreferredWindow', rootWidget)
    if not self.preferredModal then
        return
    end
    self.preferredModal.closeButton.onClick = function() self:hidePreferred() end
    self.preferredModal.onEscape = function() self:hidePreferred() end
    if self.preferredModal.preferredSearch then
        self.preferredModal.preferredSearch.onTextChange = function(widget, text)
            self.searchText = tostring(text or "")
            self:requestPreferredPage(1)
        end
    end
    if self.preferredModal.preferredPager then
        self.preferredModal.preferredPager.prevPage.onClick = function()
            self:requestPreferredPage(math.max(1, (tonumber(self.preferredPage) or 1) - 1))
        end
        self.preferredModal.preferredPager.nextPage.onClick = function()
            self:requestPreferredPage(math.min(tonumber(self.preferredTotalPages) or 1, (tonumber(self.preferredPage) or 1) + 1))
        end
    end
    self:requestPreferredPage(1)
    self:rebuildPreferredMonsterList()
    self:rebuildPreferredSlots()
end

function TaskBoardController:hidePreferred()
    if self.preferredModal then
        self.preferredModal:destroy()
        self.preferredModal = nil
    end
    self.searchText = ""
    self.selectedRaceId = 0
end

function TaskBoardController:requestPreferredPage(page)
    if not g_game.bountyPreferredAction then
        return
    end
    self.preferredPage = math.max(1, tonumber(page) or 1)
    g_game.bountyPreferredAction(BOUNTY_PREF_ACTION_REQUEST, 0, 0, self.searchText or "", self.preferredPage)
end

function TaskBoardController:confirmClearPreference(slot, action, monsterName)
    local cost = tonumber(self.preferredClearCost) or 300
    if (tonumber(self.bountyBalanceRaw) or 0) < cost then
        return
    end

    local msgBox
    local function close()
        if msgBox then
            msgBox:destroy()
            msgBox = nil
        end
    end
    local function yes()
        close()
        g_game.bountyPreferredAction(action, slot, 0, self.searchText or '', self.preferredPage or 1)
    end
    msgBox = displayGeneralBox(tr('Clear Monster'),
        tr('Are you sure you want to clear %s? This costs %d bounty points.', tostring(monsterName), cost), {{
            text = tr('Yes'),
            callback = yes
        }, {
            text = tr('No'),
            callback = close
        }}, yes, close)
end

function TaskBoardController:rebuildPreferredMonsterList()
    local modal = self.preferredModal
    local list = modal and modal:recursiveGetChildById('preferredMonsterList')
    clearPanel(list)
    if not list then
        return
    end

    local pager = modal and modal:recursiveGetChildById('preferredPager')
    if pager then
        local page = tonumber(self.preferredPage) or 1
        local totalPages = tonumber(self.preferredTotalPages) or 1
        pager.pageText:setText(string.format("%d / %d (%d)", page, totalPages, tonumber(self.preferredTotal) or 0))
        pager.prevPage:setEnabled(page > 1)
        pager.nextPage:setEnabled(page < totalPages)
    end

    for _, monster in ipairs(self.availableMonsters or {}) do
        local raceId = tonumber(monster.raceId) or 0
        local raceData = self:getRaceData(raceId, monster)
        local name = tostring(raceData.name or monster.name or ("Creature " .. raceId)):capitalize()
        if raceId > 0 then
            local row = g_ui.createWidget('TaskBoardPreferredMonsterRow', list)
            row.name:setText(name)
            if row.difficulty then
                row.difficulty:setText(short_text(tostring(monster.difficultyText or ""), 28))
            end
            row:setTooltip(string.format("%s\nDifficulty: %s", name, tostring(monster.difficultyText or "")))
            if raceData.outfit then
                applyBountyOutfit(row.creature, raceData.outfit)
            end
            if raceId == tonumber(self.selectedRaceId) then
                row:setBackgroundColor("#443f39")
                row:setBorderWidth(1)
                row:setBorderColor("#ffffff")
                row.name:setColor("#dfdfdf")
                if row.difficulty then
                    row.difficulty:setColor("#f0d575")
                end
            else
                row:setBackgroundColor("#443f39")
                row:setBorderWidth(1)
                row:setBorderColor("#5d564d")
                row.name:setColor("#dfdfdf")
                if row.difficulty then
                    row.difficulty:setColor("#f0d575")
                end
            end
            row.onClick = function()
                self.selectedRaceId = raceId
                self:rebuildPreferredMonsterList()
                self:rebuildPreferredSlots()
            end
        end
    end
end

function TaskBoardController:rebuildPreferredSlots()
    local modal = self.preferredModal
    local list = modal and modal:recursiveGetChildById('preferredSlotList')
    clearPanel(list)
    if not list then
        return
    end

    local balance = tonumber(self.bountyBalanceRaw) or 0
    local selectedRaceId = tonumber(self.selectedRaceId) or 0
    for index = 1, 5 do
        local slot = (self.preferredRawSlots or {})[index] or { slot = index, locked = index == 1 and 0 or 1, price = 0 }
        local locked = tonumber(slot.locked) == 1
        local preferredId = tonumber(slot.preferred) or 0
        local unwantedId = tonumber(slot.unwanted) or 0
        local price = tonumber(slot.price) or 0

        local row = g_ui.createWidget('TaskBoardPreferredSlotRow', list)
        row.title:setText(index == 1 and "Main Slot" or ("Slot " .. index))
        row.unlock:setVisible(locked)
        if row.unlockCost then
            row.unlockCost:setVisible(locked)
            setCurrencyBox(row, 'unlockCost', tostring(price), '/game_taskboard/assets/images/icon-currency-bountypoints', 'Bounty Points')
        end
        row.content:setVisible(not locked)
        row.unlock:setText("Unlock")
        row.unlock:setEnabled(balance >= price)
        row.unlock.onClick = function()
            g_game.bountyPreferredAction(BOUNTY_PREF_ACTION_BUY_SLOT, index, 0, self.searchText or "", self.preferredPage or 1)
        end

        if not locked then
            local prefMonster = findMonsterByRaceId(self.availableMonsters, preferredId)
            local unwMonster = findMonsterByRaceId(self.availableMonsters, unwantedId)
            local prefData = self:getRaceData(preferredId, prefMonster or { name = slot.preferredName, outfit = slot.preferredOutfit })
            local unwData = self:getRaceData(unwantedId, unwMonster or { name = slot.unwantedName, outfit = slot.unwantedOutfit })
            prefData.name = prefData.name or slot.preferredName
            prefData.outfit = prefData.outfit or slot.preferredOutfit
            unwData.name = unwData.name or slot.unwantedName
            unwData.outfit = unwData.outfit or slot.unwantedOutfit
            local prefName = preferredId > 0 and (prefData.name or ("Creature " .. preferredId)) or "Empty"
            local unwName = unwantedId > 0 and (unwData.name or ("Creature " .. unwantedId)) or "Empty"
            row.content.preferredName:setVisible(false)
            row.content.unwantedName:setVisible(false)
            row.content.preferredBox:setTooltip(tostring(prefName):capitalize())
            row.content.unwantedBox:setTooltip(tostring(unwName):capitalize())
            if row.content.preferredBox and row.content.preferredBox.preferredCreature then
                row.content.preferredBox.preferredCreature:setVisible(preferredId > 0 and prefData.outfit ~= nil)
                if preferredId > 0 and prefData.outfit then
                    applyBountyOutfit(row.content.preferredBox.preferredCreature, prefData.outfit)
                end
            end
            if row.content.unwantedBox and row.content.unwantedBox.unwantedCreature then
                row.content.unwantedBox.unwantedCreature:setVisible(unwantedId > 0 and unwData.outfit ~= nil)
                if unwantedId > 0 and unwData.outfit then
                    applyBountyOutfit(row.content.unwantedBox.unwantedCreature, unwData.outfit)
                end
            end

            row.content.preferredAction:setText(preferredId > 0 and "Clear" or "Set")
            row.content.preferredAction:setEnabled(preferredId > 0 or selectedRaceId > 0)
            row.content.preferredClearCost:setVisible(preferredId > 0)
            if preferredId > 0 then
                setCurrencyBox(row.content, 'preferredClearCost', tostring(self.preferredClearCost or 300), '/game_taskboard/assets/images/icon-currency-bountypoints', 'Bounty Points')
                row.content.preferredAction:setEnabled(balance >= (tonumber(self.preferredClearCost) or 300))
            end
            row.content.preferredAction.onClick = function()
                if preferredId > 0 then
                    self:confirmClearPreference(index, BOUNTY_PREF_ACTION_REMOVE_PREFERRED, prefName)
                elseif selectedRaceId > 0 then
                    g_game.bountyPreferredAction(BOUNTY_PREF_ACTION_SET_PREFERRED, index, selectedRaceId, self.searchText or "", self.preferredPage or 1)
                    self.selectedRaceId = 0
                end
            end

            row.content.unwantedAction:setText(unwantedId > 0 and "Clear" or "Set")
            row.content.unwantedAction:setEnabled(unwantedId > 0 or selectedRaceId > 0)
            row.content.unwantedClearCost:setVisible(unwantedId > 0)
            if unwantedId > 0 then
                setCurrencyBox(row.content, 'unwantedClearCost', tostring(self.preferredClearCost or 300), '/game_taskboard/assets/images/icon-currency-bountypoints', 'Bounty Points')
                row.content.unwantedAction:setEnabled(balance >= (tonumber(self.preferredClearCost) or 300))
            end
            row.content.unwantedAction.onClick = function()
                if unwantedId > 0 then
                    self:confirmClearPreference(index, BOUNTY_PREF_ACTION_REMOVE_UNWANTED, unwName)
                elseif selectedRaceId > 0 then
                    g_game.bountyPreferredAction(BOUNTY_PREF_ACTION_SET_UNWANTED, index, selectedRaceId, self.searchText or "", self.preferredPage or 1)
                    self.selectedRaceId = 0
                end
            end
        end
    end
end
