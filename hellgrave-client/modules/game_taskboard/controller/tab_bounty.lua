local function formatPercent(value)
    if value * 10 == math.floor(value * 10) then
        return string.format('%.1f', value)
    else
        return string.format('%.2f', value)
    end
end

local function normalizeTalismanValues(index, talisman)
    local level = math.max(0, tonumber(talisman and talisman.level) or 0)
    local maxLevel = math.max(0, tonumber(talisman and talisman.maxLevel) or 0)
    local currentValue = level * 0.5
    local nextValue = (maxLevel > 0 and level >= maxLevel) and 0 or ((level + 1) * 0.5)

    return currentValue, nextValue
end

local function formatBountyTimeLeft(expiresAt, isActive, isCompleted)
    expiresAt = tonumber(expiresAt) or 0
    if isCompleted then
        return 'Completed'
    end
    if not isActive or expiresAt <= 0 then
        return 'Timer starts after selection'
    end

    local remaining = math.max(0, expiresAt - os.time())
    if remaining <= 0 then
        return 'Rerolling soon'
    end

    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    if days > 0 then
        return string.format('Expires in %dd %dh', days, hours)
    end
    local minutes = math.floor((remaining % 3600) / 60)
    return string.format('Expires in %dh %dm', hours, minutes)
end


function TaskBoardController:onBountyServerData(header, monsters, talisman, preferred)
    local rerollPoints = tonumber(header.rerollPoints) or 0
    local claimDaily = tonumber(header.claimDaily) or 0
    local difficulty = tonumber(header.difficulty) or 1

    self.claimDailyServerAvailable = claimDaily == 1
    self.rerollPoints = rerollPoints
    self.bountyRerollCost = tonumber(header.rerollCost) or 10
    self.bountyUnlockedSlots = math.max(1, math.min(3, tonumber(header.unlockedSlots) or 1))
    self.bountySlotUnlockCosts = header.unlockCosts or self.bountySlotUnlockCosts or {}
    self.claimDailyAvailable = self.claimDailyServerAvailable and rerollPoints < REROLL_TOKEN_CAP
    self.claimDailyWarning = (rerollPoints >= REROLL_TOKEN_CAP)
    self.bountyDifficulty = difficulty
    self.bountyHasActiveTask = false
    self.preferredData = preferred or self.preferredData or {}
    self.availableMonsters = self.preferredData.availableMonsters or self.availableMonsters or {}
    self.preferredRawSlots = self.preferredData.slots or self.preferredRawSlots or {}
    if self.preferredModal then
        self:rebuildPreferredMonsterList()
        self:rebuildPreferredSlots()
    end

    local tasks = {}

    for _, m in ipairs(monsters) do
        local raceId = tonumber(m.raceId) or 0
        local currentKills = tonumber(m.currentKills) or 0
        local totalKills = tonumber(m.totalKills) or 0
        local rarity = tonumber(m.rarity) or 0
        local isActive = tonumber(m.isActive) == 1
        local isCompleted = tonumber(m.isCompleted) == 1
        if isActive and not isCompleted then
            self.bountyHasActiveTask = true
        end
        local raceData = self:getRaceData(raceId, m)
        local name = raceData and raceData.name or 'Unknown'
        name = name:capitalize()
        if #name > 20 then
            name = name:sub(1, 20) .. '...'
        end

        table.insert(tasks, {
            taskIndex = tonumber(m.taskIndex) or 0,
            raceId = raceId,
            name = name,
            fullName = raceData and raceData.name or name,
            outfit = raceData and raceData.outfit or nil,
            current = currentKills,
            total = totalKills,
            rarity = rarity,
            backdrop = RARITY_BACKDROPS[rarity] or RARITY_BACKDROPS[0],
            xp = comma_value(tonumber(m.rewardXp) or 0),
            points = tostring(tonumber(m.rewardPoints) or 0),
            reroll = tostring(tonumber(m.rewardReroll) or 0),
            isActive = isActive,
            isCompleted = isCompleted,
            timer = formatBountyTimeLeft(m.expiresAt, isActive, isCompleted),
            canClaim = (not isCompleted) and isActive and currentKills >= totalKills,
            locked = (tonumber(m.taskIndex) or 0) > self.bountyUnlockedSlots,
            unlockCost = tonumber(self.bountySlotUnlockCosts[tonumber(m.taskIndex) or 0]) or 0,
            canUnlock = (tonumber(m.taskIndex) or 0) == self.bountyUnlockedSlots + 1
        })
    end

    self.bountyTasks = tasks
    self:syncBountyDifficultySelect()
    local tals = {}
    for i = 1, 4 do
        local s = talisman[i]
        if s then
            local currentValue, nextValue = normalizeTalismanValues(i, s)
            local upgradeCost = tonumber(s.upgradeCost) or 0
            local rawNextValue = tonumber(s.nextValue) or 0
            local isMaxed = rawNextValue == 0 and upgradeCost == 0
            table.insert(tals, {
                icon = TALISMAN_ICONS[i],
                title = TALISMAN_TITLES[i],
                current = string.format('Current: %s%%', formatPercent(currentValue)),
                buttonText = isMaxed and 'MAX' or string.format('Upgrade to %s%%', formatPercent(nextValue)),
                cost = isMaxed and '-' or tostring(upgradeCost),
                costText = isMaxed and 'Maximum' or string.format('Cost: %s', tostring(upgradeCost)),
                costIcon = '/game_taskboard/assets/images/icon-currency-bountypoints',
                costTooltip = 'Bounty Points',
                statType = i - 1,
                isMaxed = isMaxed,
                upgradeable = not isMaxed,
                showSeparator = i > 1
            })
        end
    end
    self.talismans = tals
    self:updateBountyTracker(monsters)
    self:refreshNativeUi()
end


function TaskBoardController:onBountyKillUpdate(raceId, currentKills, totalKills, isCompleted)
    self:onBountyTrackerKillUpdate(raceId, currentKills, totalKills, isCompleted)

    local changed = false
    for i, task in ipairs(self.bountyTasks) do
        if task.raceId == raceId then
            self.bountyTasks[i].current = currentKills
            self.bountyTasks[i].total = totalKills
            self.bountyTasks[i].canClaim = (not self.bountyTasks[i].isCompleted) and task.isActive and currentKills >=
                                               totalKills
            self.bountyTasks = self.bountyTasks
            changed = true
            break
        end
    end

    if changed then
        local updatedCache = self:updateCachedBountyCards(raceId, currentKills, totalKills, isCompleted)
        if isCompleted == 1 or not updatedCache then
            self:queueNativePanelRender('bounty')
        end
    end
end

function TaskBoardController:rerollMonsters()
    local cost = tonumber(self.bountyRerollCost) or 10
    if (tonumber(self.bountyBalanceRaw) or 0) < cost or (tonumber(self.rerollPoints) or 0) <= 0 then
        return
    end
    local msgBox
    local function yes()
        if msgBox then
            msgBox:destroy();
            msgBox = nil
        end
        g_game.bountyTaskAction(BOUNTY_ACTION_REROLL, 0)
    end
    local function cancel()
        if msgBox then
            msgBox:destroy();
            msgBox = nil
        end
    end
    msgBox = displayGeneralBox(tr('Reroll Tasks'),
        tr('Do you want to reroll all bounty tasks? This costs %d bounty points and 1 reroll token.', cost), {{
            text = tr('Yes'),
            callback = yes
        }, {
            text = tr('Cancel'),
            callback = cancel
        }}, yes, cancel)
end

function TaskBoardController:selectTask(taskIndex)
    local parsedTaskIndex = tonumber(taskIndex) or 0
    g_game.bountyTaskAction(BOUNTY_ACTION_SELECT, parsedTaskIndex)
end

function TaskBoardController:claimReward(taskIndex)
    local parsedTaskIndex = tonumber(taskIndex) or 0
    local msgBox
    local function yes()
        if msgBox then
            msgBox:destroy();
            msgBox = nil
        end
        g_game.bountyTaskAction(BOUNTY_ACTION_CLAIM_REWARD, parsedTaskIndex)
    end
    local function cancel()
        if msgBox then
            msgBox:destroy();
            msgBox = nil
        end
    end
    msgBox = displayGeneralBox(tr('Claim Reward'), tr('Claim reward for completing the bounty task?'), {{
        text = tr('Yes'),
        callback = yes
    }, {
        text = tr('Cancel'),
        callback = cancel
    }}, yes, cancel)
end

function TaskBoardController:changeDifficulty(event)
    local diffId = event and (tonumber(event.data) or tonumber(event.value)) or nil
    if not diffId then
        return
    end
    if self.bountyHasActiveTask then
        return
    end
    g_game.bountyTaskAction(BOUNTY_ACTION_CHANGE_DIFFICULTY, diffId)
end

function TaskBoardController:claimDaily()
    if self.claimDailyWarning then
        local msgBox
        local function yes()
            if msgBox then
                msgBox:destroy();
                msgBox = nil
            end
            g_game.bountyTaskAction(BOUNTY_ACTION_CLAIM_DAILY, 0)
        end
        local function cancel()
            if msgBox then
                msgBox:destroy();
                msgBox = nil
            end
        end
        msgBox = displayGeneralBox(tr('Reroll Token Cap'), tr(
            'You already have 10 reroll tokens. Claiming another will discard the oldest. Continue?'), {{
            text = tr('Yes'),
            callback = yes
        }, {
            text = tr('Cancel'),
            callback = cancel
        }}, yes, cancel)
    else
        g_game.bountyTaskAction(BOUNTY_ACTION_CLAIM_DAILY, 0)
    end
end

function TaskBoardController:upgradeTalisman(statType)
    g_game.bountyTalismanUpgrade(statType)
end

function TaskBoardController:updateBountyTracker(monsters)
    if not Tracker or not Tracker.Bounty then
        return
    end
    if Tracker.Bounty.loadFromServerData then
        Tracker.Bounty.loadFromServerData(monsters)
    else
        Tracker.Bounty.setInactive()
    end
end

function TaskBoardController:onBountyTrackerKillUpdate(raceId, currentKills, totalKills, isCompleted)
    if not Tracker or not Tracker.Bounty then
        return
    end
    Tracker.Bounty.onKillUpdate(raceId, currentKills, totalKills, isCompleted)
end
