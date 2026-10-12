local function getItemServerName(itemId)
    local thingType = g_things and g_things.getThingType and g_things.getThingType(itemId, ThingCategoryItem)
    if thingType then
        if thingType.getName then
            return thingType:getName()
        end
        if thingType.getMarketData then
            local marketData = thingType:getMarketData()
            if marketData and marketData.name then
                return marketData.name
            end
        end
        if thingType.name then
            return thingType.name
        end
    end
    return "Unknown Item"
end

local function countFinishedEntries(entries)
    local total = 0
    for _, entry in ipairs(entries or {}) do
        if entry.finished then
            total = total + 1
        end
    end
    return total
end

function TaskBoardController:refreshWeeklySummary()
    local header = self.weeklyHdr or {}
    local completedKillTasks = tonumber(header.completedKillTasks)
    if completedKillTasks == nil then
        completedKillTasks = countFinishedEntries(self.weeklyMonsters)
    end
    local completedDeliveryTasks = tonumber(header.completedDeliveryTasks) or 0
    local totalKillSlots = tonumber(header.unlockedKillSlots) or tonumber(header.totalTaskSlots) or WEEKLY_DEFAULT_TASK_SLOTS
    local totalDeliverySlots = tonumber(header.unlockedDeliverySlots) or tonumber(header.totalTaskSlots) or WEEKLY_DEFAULT_TASK_SLOTS
    local maxExperience = tonumber(header.maxExperience) or 0
    local maxDeliveryExperience = tonumber(header.maxDeliveryExperience) or 0
    local difficultyId = tonumber(header.difficulty) or 0
    local killTaskPoints = WEEKLY_KILL_TASK_POINTS[difficultyId] or WEEKLY_KILL_TASK_POINTS[1]
    local deliveryTaskPoints = WEEKLY_DELIVERY_TASK_POINTS
    local soulsealPointsPerTask = WEEKLY_SOULSEAL_POINTS_PER_TASK
    local totalCompleted = completedKillTasks + completedDeliveryTasks
    local pointsEarned = tonumber(header.pointsEarned) or 0
    local soulsealsEarned = tonumber(header.soulsealsEarned) or 0
    local experienceEarned = tonumber(header.experienceEarned) or 0
    local killBase = completedKillTasks * killTaskPoints
    local deliveryBase = completedDeliveryTasks * deliveryTaskPoints
    local basePoints = killBase + deliveryBase
    local rewardMultiplier = (basePoints > 0) and math.max(1, math.floor(pointsEarned / basePoints + 0.5)) or 1

    self.weeklyHdr.completedKillTasks = completedKillTasks

    self.weeklyRewardTokens = comma_value(pointsEarned)
    self.weeklyRewardSeals = comma_value(soulsealsEarned)
    self.weeklyRemainingDays = tonumber(header.remainingDays) or 0
    self.weeklyShowExtraSlotUnlock = not ((tonumber(header.extraSlot) or 0) == 1 or header.extraSlot == true)
    self.weeklyProgressPct = self:calcProgressWidth(totalCompleted)
    self.weeklyXpText = (maxExperience > 0) and
                            tr(
            'Each kill task rewards you with %s XP and each delivery task will reward you with %s XP.',
            comma_value(maxExperience), comma_value(maxDeliveryExperience)) or ""

    self.weeklyProgressTooltip = string.format('Kill Tasks: %d\nDelivery Tasks: %d\nTotal: %d', completedKillTasks,
        completedDeliveryTasks, totalCompleted)

    self.weeklyRewardTokensTooltip = string.format(
        'Hunting Task Points:\n\n   %d * %d  (Kill Tasks)\n+ %d * %d  (Delivery Tasks)\n--------------------------------------\n= %s  base points\nx %d  reward multiplier\n= %s  Hunting Task Points',
        completedKillTasks, killTaskPoints, completedDeliveryTasks, deliveryTaskPoints,
        comma_value(killBase + deliveryBase), rewardMultiplier, comma_value(pointsEarned))

    self.weeklyRewardSealsTooltip = string.format(
        'You receive %d Soulseal for each completed task. Soulseals can be\nused in the Soulpit. Click the obelisk there, then your character to\nopen a menu where you can select a creature you want to\nchallenge on your own.',
        soulsealPointsPerTask)

    self.weeklyDifficultySummaryVisible = completedKillTasks > 0 or completedDeliveryTasks > 0
    self.weeklyDifficultyKillSummary = string.format('You have completed %d / %d kill tasks.', completedKillTasks,
        totalKillSlots)
    self.weeklyDifficultyDeliverySummary = string.format('You have completed %d / %d delivery tasks.',
        completedDeliveryTasks, totalDeliverySlots)
    self.weeklyDifficultyPointsEarned = comma_value(pointsEarned)
    self.weeklyDifficultySealsEarned = comma_value(soulsealsEarned)
    self.weeklyDifficultyExperienceEarned = comma_value(experienceEarned)
end

function TaskBoardController:onWeeklyServerData(header, monsters, items)
    if Tracker and Tracker.Weekly then
        local trackerMonsters = {}
        for _, monster in ipairs(monsters or {}) do
            if (tonumber(monster.locked) or 0) ~= 1 then
                table.insert(trackerMonsters, monster)
            end
        end
        Tracker.Weekly.loadFromServerData(trackerMonsters)
    end

    local playerLevel = tonumber(header.currentPlayerLevel) or
                            (g_game.getLocalPlayer() and g_game.getLocalPlayer():getLevel() or 0)
    local data = {
        difficulty = tonumber(header.difficulty) or 0,
        remainingDays = tonumber(header.remainingDays) or 7,
        totalTaskSlots = tonumber(header.totalTaskSlots) or WEEKLY_DEFAULT_TASK_SLOTS,
        unlockedKillSlots = tonumber(header.unlockedKillSlots) or WEEKLY_DEFAULT_TASK_SLOTS,
        unlockedDeliverySlots = tonumber(header.unlockedDeliverySlots) or WEEKLY_DEFAULT_TASK_SLOTS,
        killSlotUnlockCost = tonumber(header.killSlotUnlockCost) or 1000,
        deliverySlotUnlockCost = tonumber(header.deliverySlotUnlockCost) or 500,
        maxExperience = tonumber(header.maxExperience) or 0,
        maxDeliveryExperience = tonumber(header.maxDeliveryExperience) or 0,
        completedKillTasks = tonumber(header.completedKillTasks) or 0,
        completedDeliveryTasks = tonumber(header.completedDeliveryTasks) or 0,
        pointsEarned = tonumber(header.pointsEarned) or 0,
        soulsealsEarned = tonumber(header.soulsealsEarned) or 0,
        experienceEarned = tonumber(header.experienceEarned) or 0,
        extraSlot = (tonumber(header.extraSlot) or 0) == 1,
        weeklyProgressFinished = (tonumber(header.weeklyProgressFinished) or 0) == 1
    }

    local monsterList = {}
    for _, m in ipairs(monsters) do
        local raceId = tonumber(m.raceId) or 0
        local raceData = self:getRaceData(raceId, m)
        local fullName = raceId == 0 and 'Any Creature' or ((raceData and raceData.name) or 'Unknown')
        if raceId > 0 then
            fullName = fullName:capitalize()
        end
        local shortName = fullName
        if #shortName > 20 then
            shortName = shortName:sub(1, 17) .. '...'
        end
        local finished = (tonumber(m.state) or 0) == 1
        table.insert(monsterList, {
            slotIndex = tonumber(m.slotIndex) or (#monsterList),
            raceId = raceId,
            name = shortName,
            fullName = fullName,
            outfit = raceData and raceData.outfit or nil,
            current = tonumber(m.current) or 0,
            total = tonumber(m.total) or 0,
            locked = (tonumber(m.locked) or 0) == 1,
            unlockCost = tonumber(m.unlockCost) or tonumber(header.killSlotUnlockCost) or 1000,
            finished = finished,
            showProgress = not finished,
            anyCreature = raceId == 0
        })
    end
    self.weeklyMonsters = monsterList
    local itemList = {}
    for i, it in ipairs(items) do
        local itemId = tonumber(it.itemId) or 0
        local itemName = it.name or (itemId > 0 and (getItemServerName(itemId) or tostring(itemId)) or
                             "Unknown Item"
        )
        local current = tonumber(it.current) or 0
        local total = tonumber(it.total) or 0
        local owned = tonumber(it.owned) or 0
        local delivered = (tonumber(it.claimed) or 0) == 1
        local finished = (tonumber(it.state) or 0) == 1
        local locked = (tonumber(it.locked) or 0) == 1
        local needsDelivery = not locked and not delivered and current < total
        local canDeliver = needsDelivery and owned > 0
        table.insert(itemList, {
            itemId = itemId,
            clientId = tonumber(it.clientId) or itemId,
            itemName = itemName,
            current = current,
            total = total,
            owned = owned,
            delivered = delivered,
            finished = finished,
            slotIndex = tonumber(it.slotIndex) or (i - 1),
            locked = locked,
            unlockCost = tonumber(it.unlockCost) or tonumber(header.deliverySlotUnlockCost) or 500,
            needsDelivery = needsDelivery,
            canDeliver = canDeliver,
            showProgress = not delivered
        })
    end
    self.weeklyItems = itemList

    local diffList = {}
    for _, d in ipairs(WEEKLY_DIFFICULTIES) do
        local canSelect = playerLevel >= d.minLevel
        table.insert(diffList, {
            id = d.id,
            name = d.name,
            minLevel = d.minLevel,
            canSelect = canSelect,
            tooltip = (not canSelect) and
                string.format('The minimum level to start this difficulty is %d', d.minLevel) or nil
        })
    end
    self.weeklyDifficulties = diffList
    self.weeklyHdr = data
    self:refreshWeeklySummary()
    self.weeklyDifficultyPending = data.difficulty == 0 or data.weeklyProgressFinished
    self.diffModalVisible = false
    self:onWeeklyTabSelected()
    self:refreshNativeUi()
end

function TaskBoardController:onWeeklyKillUpdate(raceId, currentKills, totalKills, isCompleted, payload)
    if Tracker and Tracker.Weekly then
        Tracker.Weekly.onKillUpdate(raceId, currentKills, totalKills, isCompleted, payload and tonumber(payload.slotIndex) or nil)
    end
    if type(self.weeklyMonsters) ~= "table" then
        self.weeklyMonsters = {}
        return
    end

    local found = false
    local slotIndex = payload and tonumber(payload.slotIndex) or nil
    for i, m in ipairs(self.weeklyMonsters) do
        if (slotIndex ~= nil and tonumber(m.slotIndex) == slotIndex) or (slotIndex == nil and (m.raceId == raceId or (raceId == 0 and m.anyCreature))) then
            self.weeklyMonsters[i].current = currentKills
            self.weeklyMonsters[i].total = totalKills
            self.weeklyMonsters[i].finished = isCompleted == 1
            self.weeklyMonsters[i].showProgress = isCompleted ~= 1
            self.weeklyMonsters = self.weeklyMonsters
            found = true
        end
    end

    if not found then
        return
    end

    local completedKillTasks = tonumber(payload and payload.completedKillTasks) or countFinishedEntries(self.weeklyMonsters)
    self.weeklyHdr.completedKillTasks = completedKillTasks
    if payload then
        if payload.pointsEarned ~= nil then
            self.weeklyHdr.pointsEarned = tonumber(payload.pointsEarned) or tonumber(self.weeklyHdr.pointsEarned) or 0
        end
        if payload.soulsealsEarned ~= nil then
            self.weeklyHdr.soulsealsEarned = tonumber(payload.soulsealsEarned) or tonumber(self.weeklyHdr.soulsealsEarned) or 0
        end
    end
    self:refreshWeeklySummary()
    self:setCurrencyBox(self.ui, 'weeklyTaskReward', self.weeklyRewardTokens, '/game_taskboard/assets/images/task-tokens', 'Hunting Task Points')
    self:setCurrencyBox(self.ui, 'weeklySoulsealReward', self.weeklyRewardSeals, '/game_taskboard/assets/images/icon-currency-soulseals', 'Soulseals')
    self:setLabelText(self.ui, 'weeklyProgressText', self.weeklyProgressTooltip)
    local progress = self.ui and self.ui:recursiveGetChildById('weeklyProgress')
    if progress then
        progress:setPercent(tonumber(self.weeklyProgressPct) or 0)
    end

    local updatedCache = self:updateCachedWeeklyCards(raceId, currentKills, totalKills, isCompleted, slotIndex)
    if isCompleted == 1 or not updatedCache then
        self:queueNativePanelRender('weekly')
    end
end

function TaskBoardController:onWeeklyTabSelected()
    if not self.ui or not self.ui:isVisible() then
        return
    end
    self.diffModalVisible = self.activeTab == self.TAB_WEEKLY and self.weeklyDifficultyPending
end

function TaskBoardController:selectDifficulty(diffId)
    local parsedId = tonumber(diffId) or 0
    if parsedId <= 0 then
        return
    end
    g_game.weeklyTaskAction(WEEKLY_ACTION_SELECT_DIFFICULTY, parsedId)
    self.weeklyDifficultyPending = false
    self.diffModalVisible = false
end

function TaskBoardController:deliverItem(item)
    if type(item) ~= "table" then
        return
    end

    local remaining = math.max(0, (tonumber(item.total) or 0) - (tonumber(item.current) or 0))
    local owned = math.max(0, tonumber(item.owned) or 0)
    local defaultAmount = math.min(remaining, owned)
    if defaultAmount <= 0 then
        local box
        local function close()
            if box then
                box:destroy()
                box = nil
            end
        end
        box = displayGeneralBox(tr('Deliver Item'), tr('You do not have any %s to deliver.', tostring(item.itemName or "items")), {{
            text = tr('Ok'),
            callback = close
        }}, close, close)
        return
    end

    local window = g_ui.createWidget('TaskBoardDeliveryWindow', rootWidget)
    window.message:setText(string.format("You have %d. Deliver how many %s?\nRemaining: %d", owned,
        tostring(item.itemName or "items"), remaining))
    window.amount:setText(tostring(defaultAmount))
    window.amount:focus()
    window.amount:selectAll()

    local function close()
        if window then
            window:destroy()
            window = nil
        end
    end

    local function submit()
        if not window then
            return
        end
        local amount = math.floor(tonumber(window.amount:getText()) or 0)
        if amount <= 0 then
            close()
            return
        end
        amount = math.min(amount, defaultAmount)
        g_game.weeklyTaskAction(WEEKLY_ACTION_DELIVER_ITEM, tonumber(item.slotIndex) or 0, amount)
        close()
    end

    local okButton = window.ok or window:recursiveGetChildById('ok')
    local cancelButton = window.cancel or window:recursiveGetChildById('cancel')
    if okButton then
        okButton.onClick = submit
    end
    if cancelButton then
        cancelButton.onClick = close
    end
    if window.amount then
        window.amount.onEnter = submit
        window.amount.onEscape = close
    end
    window.onEnter = submit
    window.onEscape = close
end

function TaskBoardController:onDeliveryItemsRendered()
    local container = self:findWidget("#deliveryTasksBox")
    if not container then return end
    local ctrl = self
    for i = 1, container:getChildCount() do
        local card = container:getChildByIndex(i)
        if card and not card:isDestroyed() and card.__for_values then
            local item = card.__for_values[1]
            if item then
                local itemId = tonumber(item.itemId) or 0
                local itemName = tostring(item.itemName or "")
                if itemId > 0 then
                    card.onMouseRelease = function(widget, mousePos, mouseButton)
                        if mouseButton == MouseRightButton then
                            ctrl:showDeliveryItemMenu(itemId, itemName, mousePos)
                            return true
                        end
                    end
                end
            end
        end
    end
end

function TaskBoardController:showDeliveryItemMenu(itemId, itemName, mousePos)
    local menu = g_ui.createWidget('PopupMenu')
    menu:addOption(tr('Cyclopedia'), function()
        local cyc = modules.game_cyclopedia
        if not cyc then
            return
        end
        if controllerCyclopedia and controllerCyclopedia.ui and controllerCyclopedia.ui:isVisible() then
            cyc.SelectWindow('items', false)
        else
            cyc.show('items')
        end
        TaskBoardController:scheduleEvent(function()
            if cyc.Cyclopedia and cyc.Cyclopedia.ItemSearch then
                cyc.Cyclopedia.ItemSearch(itemName, false)
            end
        end, 100, "showDeliveryItemCyclopedia")
    end)
    menu:addOption(tr('Show in Market'), function()
        local market = modules.game_market
        if not market or not market.onShowRedirect then
            return
        end
        local thingType = g_things.getThingType(itemId, ThingCategoryItem)
        if not thingType then
            return
        end
        market.onMarketEnter({}, 0, 0, 0)
        TaskBoardController:scheduleEvent(function()
            market.onShowRedirect(thingType)
        end, 100, "showDeliveryItemMarket")
    end)
    menu:display(mousePos)
end

function TaskBoardController:calcProgressWidth(completedTasks)
    local sectionIndex = 0
    for i = 1, WEEKLY_SECTIONS do
        if completedTasks >= WEEKLY_THRESHOLDS[i + 1] then
            sectionIndex = i
        else
            break
        end
    end

    local sectionWidth = 100 / WEEKLY_SECTIONS

    if sectionIndex >= WEEKLY_SECTIONS then
        return 100
    end

    local sectionStart = WEEKLY_THRESHOLDS[sectionIndex + 1]
    local sectionEnd = WEEKLY_THRESHOLDS[sectionIndex + 2]
    local fraction = (completedTasks - sectionStart) / (sectionEnd - sectionStart)
    return math.min(math.floor((sectionIndex + fraction) * sectionWidth), 100)
end
