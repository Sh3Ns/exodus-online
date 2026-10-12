preyWindow = nil
preyButton = nil
preyWindowButton = nil
huntingTasksWindowButton = nil
preyTracker = nil

local timeLeftRerrol = {}

local creatureList = {}
local onWildcardValueChange = nil
local itemListMin = {}
local itemListMax = {}
local itemSize = {}
local maxFitItems = {}
local poolSize = {}
local itemsPool = {}
local currentRaces = {}
local currentSearchRaces = {}
local lastSelectedLabel = {}
local selectedMonster = {}
local clientPreyLockTypes = {}

local updateRerollEvent = nil
local supportWindow = nil
local preyTrackerButton
local bankGold = 0
local inventoryGold = 0
local rerollPrice = 0
local bonusRerolls = 0

local PREY_BONUS_DAMAGE_BOOST = 0
local PREY_BONUS_DAMAGE_REDUCTION = 1
local PREY_BONUS_XP_BONUS = 2
local PREY_BONUS_IMPROVED_LOOT = 3
local PREY_BONUS_NONE = 4

local PREY_ACTION_LISTREROLL = 0
local PREY_ACTION_BONUSREROLL = 1
local PREY_ACTION_MONSTERSELECTION = 2
local PREY_ACTION_REQUEST_ALL_MONSTERS = 3
local PREY_ACTION_CHANGE_FROM_ALL = 4
local PREY_ACTION_LOCK_PREY = 5

local ResourceBank = ResourceTypes and ResourceTypes.BANK_BALANCE or 0
local ResourceInventary = ResourceTypes and ResourceTypes.GOLD_EQUIPPED or 1
local ResourcePreyBonus = ResourceTypes and ResourceTypes.PREY_WILDCARDS or 10
local HUNTING_TASK_OPCODE = 233
local HUNTING_TASK_SELECT_WILDCARDS = 3

local SLOT_STATE_LOCKED = 0
local SLOT_STATE_INACTIVE = 1
local SLOT_STATE_ACTIVE = 2
local SLOT_STATE_SELECTION = 3
local SLOT_STATE_WILDCARD = 4

local WILDCARD_LABEL_HEIGHT = 16
local WILDCARD_VISIBLE_LABELS = 11
local FREE_REROLL_SECONDS = 20 * 60 * 60

local preyDescription = {}
local searchFilterText = ''
local activeDialogTab = 'prey'
local huntingTaskState = {
  tokens = 0,
  slots = {}
}

if not short_text then
  function short_text(text, maxLength)
    text = tostring(text or "")
    maxLength = tonumber(maxLength) or 0
    if maxLength <= 0 or #text <= maxLength then
      return text
    end
    if maxLength <= 3 then
      return string.sub(text, 1, maxLength)
    end
    return string.sub(text, 1, maxLength - 3) .. "..."
  end
end

local function setInputLockWidget(widget)
  if g_client and g_client.setInputLockWidget then
    g_client.setInputLockWidget(widget)
  end
end

local function getMonsterList()
  if g_things and g_things.getMonsterList then
    return g_things.getMonsterList()
  end
  return {}
end

local function getRaceInfo(raceId)
  if g_things and g_things.getRaceData then
    local raceData = g_things.getRaceData(raceId)
    if raceData then
      return {
        name = raceData.name or tostring(raceId),
        outfit = raceData.outfit or {}
      }
    end
  end

  local creature = creatureList and creatureList[raceId]
  if creature then
    return {
      name = creature[1] or tostring(raceId),
      outfit = creature[2] or {}
    }
  end

  return {
    name = tostring(raceId),
    outfit = {}
  }
end

local raceInfoNameIndex = nil

local function getRaceInfoByName(name)
  local lookupName = tostring(name or ""):lower()
  if lookupName == "" then
    return nil
  end

  if not raceInfoNameIndex then
    raceInfoNameIndex = {}

    local function addEntry(raceId, entry)
      local entryName
      local entryOutfit = {}
      local entryRaceId = raceId
      if type(entry) == "table" then
        entryName = entry.name or entry[1]
        entryOutfit = entry.outfit or entry[2] or {}
        entryRaceId = entry.raceId or entry.id or raceId
      else
        entryName = entry
      end

      if not entryName or entryName == "" then
        return
      end

      local key = tostring(entryName):lower()
      if raceInfoNameIndex[key] then
        return
      end

      local numericRaceId = tonumber(entryRaceId) or 0
      if numericRaceId > 0 then
        raceInfoNameIndex[key] = getRaceInfo(numericRaceId)
      else
        raceInfoNameIndex[key] = {
          name = entryName,
          outfit = entryOutfit
        }
      end
    end

    for raceId, entry in pairs(getMonsterList() or {}) do
      addEntry(raceId, entry)
    end
    for raceId, entry in pairs(creatureList or {}) do
      addEntry(raceId, entry)
    end
  end

  return raceInfoNameIndex[lookupName]
end

local function hasValidOutfit(outfit)
  return outfit and (tonumber(outfit.type or outfit.lookType) or 0) > 0
end

local function normalizeOutfit(outfit)
  if not outfit then
    return {}
  end

  local shader = outfit.shader or outfit.lookShader or ""
  if tonumber(shader) == 0 then
    shader = ""
  end

  return {
    type = tonumber(outfit.type or outfit.lookType) or 0,
    auxType = tonumber(outfit.auxType or outfit.lookTypeEx) or 0,
    head = tonumber(outfit.head or outfit.lookHead) or 0,
    body = tonumber(outfit.body or outfit.lookBody) or 0,
    legs = tonumber(outfit.legs or outfit.lookLegs) or 0,
    feet = tonumber(outfit.feet or outfit.lookFeet) or 0,
    addons = tonumber(outfit.addons or outfit.lookAddons) or 0,
    mount = tonumber(outfit.mount or outfit.lookMount) or 0,
    wings = tonumber(outfit.wings or outfit.lookWings) or 0,
    aura = tonumber(outfit.aura or outfit.lookAura) or 0,
    shader = shader
  }
end

local function hasOutfitPalette(outfit)
  outfit = normalizeOutfit(outfit)
  return (tonumber(outfit.head) or 0) > 0 or (tonumber(outfit.body) or 0) > 0 or
    (tonumber(outfit.legs) or 0) > 0 or (tonumber(outfit.feet) or 0) > 0 or
    tostring(outfit.shader or "") ~= ""
end

local function resolveHuntingTaskOutfit(data)
  data = data or {}
  local outfit = normalizeOutfit(data.outfit)
  local raceInfo
  local raceId = tonumber(data.raceId or data.id) or 0
  if raceId > 0 then
    raceInfo = getRaceInfo(raceId)
  end
  if not raceInfo then
    raceInfo = getRaceInfoByName(data.name or data.monster)
  end

  local raceOutfit = normalizeOutfit(raceInfo and raceInfo.outfit)
  if hasValidOutfit(raceOutfit) and (not hasValidOutfit(outfit) or not hasOutfitPalette(outfit)) then
    return raceOutfit
  end

  return outfit
end

local function setPreviewCreature(widget, outfit)
  if not widget then
    return
  end

  outfit = normalizeOutfit(outfit)
  if not hasValidOutfit(outfit) then
    widget:hide()
    return
  end

  widget:setOutfit(outfit)
  widget:show()
end

local function normalizeRaceList(races)
  local normalized = {}
  for _, raceId in ipairs(races or {}) do
    raceId = tonumber(raceId) or 0
    if raceId > 0 then
      local raceInfo = getRaceInfo(raceId)
      if raceInfo.name and raceInfo.name ~= "" then
        table.insert(normalized, raceId)
      end
    end
  end

  return normalized
end

local function setWidgetActionId(widget, actionId)
  if not widget then
    return
  end

  if widget.setActionId then
    widget:setActionId(actionId)
    return
  end

  widget.actionId = tonumber(actionId) or 0
end

local function getWidgetActionId(widget)
  if not widget then
    return 0
  end

  if widget.getActionId then
    return widget:getActionId()
  end

  return tonumber(widget.actionId) or 0
end

local function setRerollStrikePrice(pricePanel, text, visible)
  if not pricePanel or not pricePanel.textOff then
    return
  end

  if text ~= nil then
    pricePanel.textOff:setText(text)
  end
  pricePanel.textOff:setVisible(visible)
end

function bonusDescription(bonusType, bonusValue, bonusGrade)
  if bonusType == PREY_BONUS_DAMAGE_BOOST then
    return "Damage bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    return "Damage reduction bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_XP_BONUS then
    return "XP bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    return "Loot bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_DAMAGE_BOOST then
    return "-"
  end
  return "Uknown bonus"
end

function bonusTypeTranslate(bonusType)
   if bonusType == PREY_BONUS_DAMAGE_BOOST then
    return "Damage Boost"
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    return "Damage Reduction"
  elseif bonusType == PREY_BONUS_XP_BONUS then
    return "Bonus XP"
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    return "Improved Loot"
  end
  return "None"
end

function bonusTypeTranslateText(bonusType, percent)
  local text = "No active bonus."
  if bonusType == PREY_BONUS_DAMAGE_BOOST then
    text = tr("You deal +%s%s extra damage against your prey creature.", percent, "%")
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    text = tr("You take %s%s less damage from your prey creature.", percent, "%")
  elseif bonusType == PREY_BONUS_XP_BONUS then
    text = tr("Killing you prey creature rewards +%s%s extra XP.", percent, "%")
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    text = tr("Your prey creature has a +%s%s chance do drop additional loot.", percent, "%")
  end
  return text
end

function timeleftTranslation(timeleft)
  if timeleft == 0 then
    return tr("Free")
  end
  local hours = string.format("%02.f", math.floor(timeleft/3600))
  local mins = string.format("%02.f", math.floor(timeleft/60 - (hours*60)))
  return hours .. ":" .. mins
end

function init()
  connect(g_game, {
    onGameStart = check,
    onGameEnd = onGameEnd,
    onResourceBalance = onResourceBalance,
    onPreyFreeRolls = onPreyFreeRolls,
    onPreyTimeLeft = onPreyTimeLeft,
    onPreyPrice = onPreyPrice,
    onPreyRerollPrice = onPreyPrice,
    onPreyLocked = onPreyLocked,
    onPreyWildcard = onPreyWildcard,
    onPreyInactive = onPreyInactive,
    onPreyActive = onPreyActive,
    onPreySelection = onPreySelection,
    onPreySelectionChangeMonster = onPreySelectionChangeMonster,
    onPreyListSelection = onPreyListSelection,
    onPreyWildcardSelection = onPreyWildcardSelection
  })

  preyWindow = g_ui.displayUI('prey')
  if not preyWindow then
    error("Unable to load game_prey/prey.otui")
  end
  preyWindow:hide()
  preyTracker = g_ui.createWidget('PreyTracker', g_ui.getRootWidget())
  preyTracker:setup()
  preyTracker:setContentMaximumHeight(280)
  preyTracker:setContentMinimumHeight(49)
  preyTracker.onOpen = onMiniWindowOpen
  preyTracker.onClose = onMiniWindowClose
  preyTracker:close()

  preyWindowButton = preyWindow:recursiveGetChildById("preyWindowButton")
  huntingTasksWindowButton = preyWindow:recursiveGetChildById("huntingTasksWindowButton")
  if preyWindowButton then
    preyWindowButton.onClick = showPreyTab
  end
  if huntingTasksWindowButton then
    huntingTasksWindowButton.onClick = showHuntingTasksTab
  end
  if ProtocolGame and ProtocolGame.registerExtendedOpcode then
    ProtocolGame.registerExtendedOpcode(HUNTING_TASK_OPCODE, onHuntingTaskExtendedOpcode)
  end
  showPreyTab()

  if g_game.isOnline() then
    check()
  end
end

function requestPreyData()
  if g_game.preyRequest then
    g_game.preyRequest()
  end
end

function requestHuntingTaskData()
  local protocol = g_game.getProtocolGame and g_game.getProtocolGame()
  if protocol and protocol.sendExtendedOpcode then
    protocol:sendExtendedOpcode(HUNTING_TASK_OPCODE, json.encode({ action = "request" }))
  end
end

function sendHuntingTaskAction(action, data)
  local protocol = g_game.getProtocolGame and g_game.getProtocolGame()
  if not protocol or not protocol.sendExtendedOpcode then
    return
  end

  data = data or {}
  data.action = action
  protocol:sendExtendedOpcode(HUNTING_TASK_OPCODE, json.encode(data))
end

local function setHuntingTokens(tokens)
  huntingTaskState.tokens = tonumber(tokens) or 0
  if not preyWindow or not preyWindow.huntingTokens then
    return
  end
  if preyWindow.huntingTokens.text then
    preyWindow.huntingTokens.text:setText(tostring(huntingTaskState.tokens))
  elseif preyWindow.huntingTokens.setText then
    preyWindow.huntingTokens:setText(huntingTaskState.tokens)
  end
end

local function syncPreyResourceBalances()
  local player = g_game.getLocalPlayer and g_game.getLocalPlayer()
  if not player or not player.getResourceBalance then
    return
  end

  local currentBankGold = tonumber(player:getResourceBalance(ResourceBank))
  local currentInventoryGold = tonumber(player:getResourceBalance(ResourceInventary))
  local currentBonusRerolls = tonumber(player:getResourceBalance(ResourcePreyBonus))
  if currentBankGold and bankGold <= 0 then
    bankGold = currentBankGold
  end
  if currentInventoryGold and inventoryGold <= 0 then
    inventoryGold = currentInventoryGold
  end
  if currentBonusRerolls and bonusRerolls <= 0 then
    bonusRerolls = currentBonusRerolls
  end
end

local function parseBalanceText(text)
  local value = tostring(text or ""):gsub("[^%d]", "")
  return tonumber(value) or 0
end

local function getDisplayedBalance(widget)
  if not widget then
    return 0
  end

  if widget.text and widget.text.getText then
    return parseBalanceText(widget.text:getText())
  end
  if widget.getText then
    return parseBalanceText(widget:getText())
  end
  return 0
end

local function updateHuntingTaskPrices(panel)
  if not panel or not panel.buttonsPanel then
    return
  end

  syncPreyResourceBalances()

  local displayedGold = getDisplayedBalance(preyWindow and preyWindow.gold)
  local displayedWildcards = getDisplayedBalance(preyWindow and preyWindow.wildCards)
  if displayedGold > (bankGold + inventoryGold) then
    bankGold = displayedGold
    inventoryGold = 0
  end
  if displayedWildcards > bonusRerolls then
    bonusRerolls = displayedWildcards
  end

  local availableGold = math.max(bankGold + inventoryGold, displayedGold)
  local availableWildcards = math.max(bonusRerolls, displayedWildcards)
  local canReroll = rerollPrice <= 0 or availableGold >= rerollPrice
  local rerollPriceWidget = panel.buttonsPanel.reroll and panel.buttonsPanel.reroll.price and panel.buttonsPanel.reroll.price.text
  if rerollPriceWidget then
    local formattedPrice = rerollPrice < 100000 and comma_value(rerollPrice) or math.ceil(rerollPrice / 1000) .. " k"
    rerollPriceWidget:setText(formattedPrice)
    rerollPriceWidget:setColor(canReroll and "#c0c0c0" or "#d33c3c")
  end

  local rerollButton = panel.buttonsPanel.reroll and panel.buttonsPanel.reroll.button and panel.buttonsPanel.reroll.button.rerollButton
  if rerollButton then
    rerollButton:setOn(canReroll)
  end

  local canSelectWithWildcards = availableWildcards >= HUNTING_TASK_SELECT_WILDCARDS
  local selectPriceWidget = panel.buttonsPanel.select and panel.buttonsPanel.select.price and panel.buttonsPanel.select.price.text
  if selectPriceWidget then
    selectPriceWidget:setText(tostring(HUNTING_TASK_SELECT_WILDCARDS))
    selectPriceWidget:setColor(canSelectWithWildcards and "#c0c0c0" or "#d33c3c")
  end

  local selectButton = panel.buttonsPanel.select and panel.buttonsPanel.select.button and panel.buttonsPanel.select.button.pickSpecificPrey
  if selectButton then
    selectButton:setOn(canSelectWithWildcards)
  end
end

local function setHuntingTaskAmount(panel, amount)
  if not panel then
    return
  end
  panel.selectedAmount = tonumber(amount) or panel.selectedAmount or 0
  local amount500 = panel.amount500 and panel.amount500.check
  local amount1000 = panel.amount1000 and panel.amount1000.check
  if amount500 then
    amount500:setChecked(panel.selectedAmount == tonumber(amount500.amountValue))
  end
  if amount1000 then
    amount1000:setChecked(panel.selectedAmount == tonumber(amount1000.amountValue))
  end
end

local function setHuntingTaskAmountOptions(panel, choice)
  local amount500 = panel.amount500 and panel.amount500.check
  local amount1000 = panel.amount1000 and panel.amount1000.check
  local low = tonumber(choice and choice.required) or 200
  local high = tonumber(choice and choice.highRequired) or low

  if amount500 then
    amount500.amountValue = low
    amount500:setText(tostring(low))
    amount500.onClick = function() setHuntingTaskAmount(panel, low) end
  end
  if amount1000 then
    amount1000.amountValue = high
    amount1000:setText(tostring(high))
    amount1000.onClick = function() setHuntingTaskAmount(panel, high) end
  end

  setHuntingTaskAmount(panel, panel.selectedAmount == high and high or low)
end

local function setHuntingTaskStars(activeTask, filledStars)
  local grade = activeTask and (activeTask.grade or activeTask:recursiveGetChildById("grade"))
  if not grade then
    return
  end

  filledStars = math.max(0, math.min(5, tonumber(filledStars) or 0))
  for index = 1, 5 do
    local star = grade["star" .. index] or grade:recursiveGetChildById("star" .. index)
    if star then
      star:setImageSource(index <= filledStars and "/images/game/prey/prey_star" or "/images/game/prey/prey_nostar")
    end
  end
end

local function updateHuntingTaskTracker()
  local contents = preyTracker and preyTracker.contentsPanel
  if not contents then
    return
  end

  local hasActiveTask = false
  for slot = 1, 3 do
    local trackerSlot = contents["hslot" .. slot]
    local data = huntingTaskState.slots[slot]
    if trackerSlot then
      local active = data and data.state == "active"
      trackerSlot:setVisible(active)

      if active then
        hasActiveTask = true
        local name = capitalFormatStr(data.monster or "Hunting Task")
        local kills = tonumber(data.kills) or 0
        local required = math.max(1, tonumber(data.required) or 1)
        local reward = tonumber(data.reward) or 0
        local percent = math.min(100, math.floor((kills / required) * 100))

        trackerSlot.creature:setOutfit(resolveHuntingTaskOutfit(data))
        trackerSlot.creature:show()
        trackerSlot.noCreature:hide()
        trackerSlot.creatureName:setText(short_text(name, 12))
        trackerSlot.time:setPercent(percent)
        trackerSlot.preyType:setImageSource("/images/game/prey/preyhuntingtask-tokens")
        trackerSlot.preyAutoExtend:hide()

        local tooltip = string.format("Hunting Task: %s\nProgress: %d / %d kills\nReward: %d Hunting Task Tokens\n\nClick in this window to open the hunting task dialog.",
          name, kills, required, reward)
        trackerSlot:setTooltip(tooltip)
        for _, element in pairs({ trackerSlot.creatureName, trackerSlot.creature, trackerSlot.preyType, trackerSlot.time }) do
          element:setTooltip(tooltip)
          element.onClick = function()
            show()
            showHuntingTasksTab()
          end
        end
        trackerSlot.onClick = function()
          show()
          showHuntingTasksTab()
        end
      end
    end
  end

  if contents.huntingTasksLabel then
    contents.huntingTasksLabel:setVisible(hasActiveTask)
  end
  if contents.huntingTasksSeparator then
    contents.huntingTasksSeparator:setVisible(hasActiveTask)
  end
  updateTrackerHeight(hasActiveTask)
end

function setupHuntingTaskSlot(slot, data)
  local panel = preyWindow and preyWindow["huntingSlot" .. slot]
  if not panel or not panel.list then
    return
  end

  data = data or {}
  panel.list:destroyChildren()
  panel.title:setText("Select hunting creature")
  panel.selectedChoice = nil
  panel.selectedBox = nil
  panel.selectedAmount = nil
  panel.list:show()
  panel.buttonsPanel:show()
  panel.amount500:show()
  panel.amount1000:show()
  if panel.activeTask then
    panel.activeTask:hide()
  end
  if panel.locked then
    panel.locked:hide()
  end

  local added = 0
  for _, choice in ipairs(data.choices or {}) do
    if added >= 9 then
      break
    end
    if choice and choice.outfit then
      local box = g_ui.createWidget("PreyCreatureBox", panel.list)
      local name = capitalFormatStr(choice.name or "")
      box.choice = choice
      box.creature:setTooltip(name)
      box.creature:setOutfit(resolveHuntingTaskOutfit(choice))
      local function selectHuntingChoice()
        if panel.selectedBox and panel.selectedBox.highlight then
          panel.selectedBox.highlight:setBackgroundColor("alpha")
        end
        if panel.selectedBox then
          panel.selectedBox:setChecked(false)
          panel.selectedBox:setBorderWidth(0)
          panel.selectedBox:setBorderColor("alpha")
        end
        if box.highlight then
          box.highlight:setBackgroundColor("white")
        end
        box:setChecked(true)
        box:setBorderWidth(1)
        box:setBorderColor("white")
        panel.selectedBox = box
        panel.title:setText("Selected: " .. short_text(name, 18))
        panel.selectedChoice = choice
        setHuntingTaskAmountOptions(panel, choice)
        updateHuntingTaskPrices(panel)
      end
      box.onClick = selectHuntingChoice
      box.onMousePress = function()
        selectHuntingChoice()
        return true
      end
      box.creature.onClick = selectHuntingChoice
      box.creature.onMousePress = function()
        selectHuntingChoice()
        return true
      end
      if added == 0 then
        selectHuntingChoice()
      end
      added = added + 1
    end
  end

  if panel.buttonsPanel and panel.buttonsPanel.reroll and panel.buttonsPanel.reroll.button then
    panel.buttonsPanel.reroll.button.rerollButton.onClick = function()
      if not panel.buttonsPanel.reroll.button.rerollButton:isOn() then
        return
      end
      sendHuntingTaskAction("reroll", { slot = slot })
    end
  end

  local selectButton = panel.buttonsPanel and panel.buttonsPanel.select and panel.buttonsPanel.select.button and panel.buttonsPanel.select.button.pickSpecificPrey
  if selectButton then
    selectButton.onClick = function()
      if not selectButton:isOn() or bonusRerolls < HUNTING_TASK_SELECT_WILDCARDS then
        return
      end
      sendHuntingTaskAction("reroll", { slot = slot, wildcard = true })
    end
  end

  local chooseButton = panel.buttonsPanel and panel.buttonsPanel.choose and panel.buttonsPanel.choose.button and panel.buttonsPanel.choose.button.choosePreyButton
  if chooseButton then
    chooseButton:setOn(added > 0)
    chooseButton.onClick = function()
      if not panel.selectedChoice then
        return
      end
      sendHuntingTaskAction("select", {
        slot = slot,
        monster = panel.selectedChoice.name,
        required = panel.selectedAmount
      })
    end
  end
  updateHuntingTaskPrices(panel)
end

function setHuntingTaskActiveSlot(slot, data)
  local panel = preyWindow and preyWindow["huntingSlot" .. slot]
  if not panel then
    return
  end

  panel.title:setText("Currently hunting: " .. short_text(capitalFormatStr(data.monster or ""), 17))
  panel.list:hide()
  panel.amount500:hide()
  panel.amount1000:hide()
  if panel.locked then
    panel.locked:hide()
  end
  if panel.buttonsPanel then
    panel.buttonsPanel:show()
  end
  if panel.activeTask then
    panel.activeTask:show()
    local activeCreature = panel.activeTask.creature or panel.activeTask:recursiveGetChildById("creature")
    local rewardLabel = panel.activeTask.rewardLabel or panel.activeTask:recursiveGetChildById("rewardLabel")
    local progress = panel.activeTask.progress or panel.activeTask:recursiveGetChildById("progress")
    local textLabel = panel.activeTask.textLabel or panel.activeTask:recursiveGetChildById("textLabel")
    setPreviewCreature(activeCreature, resolveHuntingTaskOutfit(data))
    if rewardLabel then
      rewardLabel:setText(tostring(data.reward or 0))
    end
    local kills = tonumber(data.kills) or 0
    local required = math.max(1, tonumber(data.required) or 1)
    local filledStars = math.max(0, math.min(5, math.floor((tonumber(data.reward) or 0) / 100)))
    setHuntingTaskStars(panel.activeTask, filledStars)
    if progress then
      progress:setPercent(math.min(100, math.floor((kills / required) * 100)))
    end
    if textLabel then
      textLabel:setText(string.format("%d / %d", kills, required))
    end
  end

  if panel.buttonsPanel and panel.buttonsPanel.reroll and panel.buttonsPanel.reroll.button then
    panel.buttonsPanel.reroll.button.rerollButton.onClick = function()
      if not panel.buttonsPanel.reroll.button.rerollButton:isOn() then
        return
      end
      sendHuntingTaskAction("reroll", { slot = slot, replace = true })
    end
  end
  local selectButton = panel.buttonsPanel and panel.buttonsPanel.select and panel.buttonsPanel.select.button and panel.buttonsPanel.select.button.pickSpecificPrey
  if selectButton then
    selectButton.onClick = function()
      if not selectButton:isOn() or bonusRerolls < HUNTING_TASK_SELECT_WILDCARDS then
        return
      end
      sendHuntingTaskAction("reroll", { slot = slot, replace = true, wildcard = true })
    end
  end
  local chooseButton = panel.buttonsPanel and panel.buttonsPanel.choose and panel.buttonsPanel.choose.button and panel.buttonsPanel.choose.button.choosePreyButton
  if chooseButton then
    chooseButton:setOn(false)
    chooseButton.onClick = nil
  end
  updateHuntingTaskPrices(panel)
end

function setHuntingTaskSlotState(slot, data)
  local panel = preyWindow and preyWindow["huntingSlot" .. slot]
  if not panel then
    return
  end

  data = data or { state = "locked" }
  if data.state == "locked" then
    panel.title:setText("Locked")
    panel.list:hide()
    panel.buttonsPanel:hide()
    panel.amount500:hide()
    panel.amount1000:hide()
    if panel.activeTask then
      panel.activeTask:hide()
    end
    panel.locked:show()
  elseif data.state == "active" then
    panel.locked:hide()
    setHuntingTaskActiveSlot(slot, data)
  else
    panel.locked:hide()
    setupHuntingTaskSlot(slot, data)
  end
end

function setDialogTab(tab)
  activeDialogTab = tab
  local showPrey = tab == 'prey'

  if preyWindowButton then
    preyWindowButton:setChecked(showPrey)
  end
  if huntingTasksWindowButton then
    huntingTasksWindowButton:setChecked(not showPrey)
  end
  if preyWindow and preyWindow.wildCards then
    preyWindow.wildCards:setVisible(true)
  end
  if preyWindow and preyWindow.huntingTokens then
    preyWindow.huntingTokens:setVisible(not showPrey)
    setHuntingTokens(huntingTaskState.tokens)
  end

  for i = 1, 3 do
    local preySlot = preyWindow and preyWindow["slot" .. i]
    local huntingSlot = preyWindow and preyWindow["huntingSlot" .. i]
    if preySlot then
      preySlot:setVisible(showPrey)
    end
    if huntingSlot then
      huntingSlot:setVisible(not showPrey)
    end
  end

  if not showPrey then
    for i = 1, 3 do
      setHuntingTaskSlotState(i, huntingTaskState.slots[i] or { state = i == 1 and "selection" or "locked" })
    end
    if preyWindow and preyWindow.description then
      preyWindow.description:setText("Select your hunting task creature from the list of available creatures.")
    end
  elseif preyWindow and preyWindow.description then
    preyWindow.description:setText("Select your prey creature from the list of available creatures.")
  end
end

function showPreyTab()
  setDialogTab('prey')
  requestPreyData()
end

function showHuntingTasksTab()
  setDialogTab('hunting')
  requestHuntingTaskData()
end

function onHuntingTaskExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= HUNTING_TASK_OPCODE then
    return
  end

  local ok, data = pcall(json.decode, buffer)
  if not ok or type(data) ~= "table" then
    return
  end

  if data.action == "state" then
    huntingTaskState.slots = {}
    for _, slotData in ipairs(data.slots or {}) do
      local slot = tonumber(slotData.slot) or (#huntingTaskState.slots + 1)
      huntingTaskState.slots[slot] = slotData
    end
    setHuntingTokens(data.tokens or 0)
    if activeDialogTab == 'hunting' then
      for i = 1, 3 do
        setHuntingTaskSlotState(i, huntingTaskState.slots[i] or { state = "locked" })
      end
    end
    updateHuntingTaskTracker()
  elseif data.action == "progress" then
    local slot = tonumber(data.slot) or 0
    if huntingTaskState.slots[slot] then
      huntingTaskState.slots[slot].kills = tonumber(data.kills) or 0
      huntingTaskState.slots[slot].required = tonumber(data.required) or huntingTaskState.slots[slot].required
    end
    setHuntingTokens(data.tokens or huntingTaskState.tokens)
    if activeDialogTab == 'hunting' and slot > 0 then
      setHuntingTaskActiveSlot(slot, huntingTaskState.slots[slot] or data)
    end
    updateHuntingTaskTracker()
  end
end

local descriptionTable = {
  ["shopPermButton"] = "Go to the Store to purchase the Permanent Prey Slot. Once you have completed the purchase, you can activate a prey here, no matter if your character is on a free or a Premium account.",
  ["shopTempButton"] = "You can activate this prey whenever your account has Premium Status.",
  ["preyWindow"] = "",
  ["noBonusIcon"] = "This prey is not available for your character yet.\nCheck the large blue button(s) to learn how to unlock this prey slot",
  ["selectPrey"] = "Click here to get a bonus with a higher value. The bonus for your prey will be selected randomly from one of the following: damage boost, damage reduction, bonus XP, improved loot. Your prey will be active for 2 hours hunting time again. Your prey creature will stay the same.",
  ["pickSpecificPrey"] = "If you like to select another prey creature, click here to choose from all available creatures.\nThe newly selected prey will be active for 2 hours hunting time again.",
  ["rerollButton"] = "If you like to select another prey crature, click here to get a new list with 9 creatures to choose from.\nThe newly selected prey will be active for 2 hours hunting time again.",
  ["rerollButtonBonus"] = "If you like to select another prey crature, click here to get a new list with 9 creatures to choose from.\nThe newly selected prey will be active for 2 hours hunting time again.",
  ["preyCandidate"] = "Select a new prey creature for the next 2 hours hunting time.",
  ["choosePreyButton"] = "Click on this button to confirm selected monsters as your prey creature for the next 2 hours hunting time.",
  ["choosePreyButtonBonus"] = "Click on this button to confirm %s as your prey creature for the next 2 hours hunting time. You will benefit from the following bonus: %s",
  ["selectionList"] = "Select a new prey creature for the next 2 hours hunting time. You will benefit from the following bonus:",
  ["rerollBonus"] = "Click here to get a bonus with a higher value. The bonus for your prey will be selected randomly from one of the following: damage boost, damage reduction, bonus XP, improved loot. Your prey will be active for 2 hours hunting time again. Your prey creature will stay the same.",
  ["autoRerollCheck"] = "If you tick this option, you will automatically roll for a new prey bonus whenever your prey is about to expire. This will also extend the hunting time of your active prey creature for another 2 hours.",
  ["lockPreyCheck"] = "If you tick this option, you will lock your prey creature and prey bonus. This means whenever your prey is about to expire its hunting time is simply extended by another 2 hours.",
  ["time"] = "You will get your next Free List Reroll in %s.\nYou get a Free List Reroll every 20 hours for each slot.",
  ["time_free"] = "Your next List Reroll is free of charge.\nYou get a Free List Reroll every 20 hours for each slot."
}

function onHover(widget)
  if type(widget) == "string" then
    return preyWindow.description:setText(descriptionTable[widget])
  elseif type(widget) == "number" then
    local preySlot = preyWindow["slot" .. (widget + 1)]
    local creatureAndBonus = preySlot.active.creatureAndBonus
    local preyName = preySlot.title:getText()
    local timeleft = timeleftTranslation(preySlot.timeLeft)
    local typeDesc = bonusTypeTranslate(preySlot.bonusType)
    local bonusDescription = bonusTypeTranslateText(preySlot.bonusType, preySlot.bonusValue)
    local starBonus = ""
    for i = 1, 10 do
      if i <= preySlot.bonusGrade then
        starBonus = starBonus .. "^"
      else
        starBonus = starBonus .. ";"
      end
    end

    local text = tr("Creature: %s\nDuration: %s\nValue: %s\nType: %s\n%s", preyName, timeleft, starBonus, typeDesc, bonusDescription)
    return preyWindow.description:setText(text)
  end

  if not widget:isVisible() then
    return false
  end

  local id = widget:getId()
  local desc = descriptionTable[id]
  if not desc then
    return
  end

  if id == "choosePreyButton" and getWidgetActionId(widget) > 0 then
    local preySlot = preyWindow["slot" .. getWidgetActionId(widget)]
    local bonusType = preySlot.bonusType
    local bonusValue = preySlot.bonusValue
    if bonusType > 0 then
      -- wildcard
      if preySlot.wildcard:isVisible() and preySlot.wildcard.monsterList:getFocusedChild() then
        local name = preySlot.wildcard.monsterList:getFocusedChild():getText()
        local bonusDesc = tr("+%s%s %s", bonusValue, "%", getBonusDescription(bonusType))
        desc = tr(descriptionTable["choosePreyButtonBonus"], name, bonusDesc)
      elseif preySlot.select:isVisible() then
        local focusedChild = preySlot.select.list:getFocusedChild()
        if not focusedChild then
          focusedChild = preySlot.select.list:getFirstChild()
        end
        if focusedChild then
          local bonusDesc = tr("+%s%s %s", bonusValue, "%", getBonusDescription(bonusType))
          desc = tr(descriptionTable["choosePreyButtonBonus"], focusedChild.creature:getTooltip(), bonusDesc)
        end
      end
    end
  elseif id == "time" then
    local widgetText = widget:getText()
    if widgetText == "Free" then
      desc = descriptionTable["time_free"]
    else
      desc = tr(desc, widget:getText())
    end
  end

  preyWindow.description:setText(desc)
end

function onSpecialHover(widget, bonusType, bonusValue)
	local message = descriptionTable[widget]
	if widget == "selectionList" then
    if bonusType == PREY_BONUS_NONE then
      preyWindow.description:setText(descriptionTable["selectPrey"])
    else
      message = tr("%s +%s%s %s", message, bonusValue, "%", getBonusDescription(bonusType))
      preyWindow.description:setText(message)
    end
	end
end

function terminate()
  if ProtocolGame and ProtocolGame.unregisterExtendedOpcode then
    ProtocolGame.unregisterExtendedOpcode(HUNTING_TASK_OPCODE)
  end

  disconnect(g_game, {
    onGameStart = check,
    onGameEnd = onGameEnd,
    onResourceBalance = onResourceBalance,
    onPreyFreeRolls = onPreyFreeRolls,
    onPreyTimeLeft = onPreyTimeLeft,
    onPreyPrice = onPreyPrice,
    onPreyRerollPrice = onPreyPrice,
    onPreyLocked = onPreyLocked,
    onPreyWildcard = onPreyWildcard,
    onPreyInactive = onPreyInactive,
    onPreyActive = onPreyActive,
    onPreySelection = onPreySelection,
    onPreySelectionChangeMonster = onPreySelectionChangeMonster,
    onPreyListSelection = onPreyListSelection,
    onPreyWildcardSelection = onPreyWildcardSelection
  })

  if preyButton then
    preyButton:destroy()
  end
  if preyTrackerButton then
    preyTrackerButton:destroy()
  end
  preyWindow:destroy()
  preyTracker:destroy()
  if supportWindow then
    supportWindow:destroy()
    supportWindow = nil
  end
end

function setUnsupportedSettings()
  local t = {"slot1", "slot2", "slot3"}
  for i, slot in pairs(t) do
    local panel = preyWindow[slot]
    for j, state in pairs({panel.active, panel.inactive, panel.select}) do
      state.buttonsPanel.select.price.text:setText("5")
      state:recursiveGetChildById("pickSpecificPrey"):setOn(true)
      state.buttonsPanel.select.price.text:setColor("#c0c0c0")
      if bonusRerolls < 5 then
        state.buttonsPanel.select.price.text:setColor("#d33c3c")
        state:recursiveGetChildById("pickSpecificPrey"):setOn(false)
      end

      state:recursiveGetChildById("pickSpecificPrey").onClick = function()
        if not state:recursiveGetChildById("pickSpecificPrey"):isOn() then
          return
        end

        if bonusRerolls - 5 < 0 then
          return
        end
        onConfirmUsingWildcard(i - 1, 5, PREY_ACTION_REQUEST_ALL_MONSTERS)
      end

      state.buttonsPanel.reroll.button.rerollButton:setOn(true)
      state.buttonsPanel.reroll.price.text:setColor("#c0c0c0")
      local progressBar = state.buttonsPanel.reroll.button.time
      if progressBar:getText() ~= "Free" then
        state.buttonsPanel.reroll.button.rerollButton:setOn(false)
      elseif (bankGold + inventoryGold < rerollPrice and progressBar:getText() ~= "Free") then
        state.buttonsPanel.reroll.price.text:setColor("#d33c3c")
        state.buttonsPanel.reroll.button.rerollButton:setOn(false)
      end
      -- hotfix
      progressBar:setPercent(progressBar:getPercent())
    end

    for k, state in pairs({panel.active, panel.inactive}) do
      state.buttonsPanel.choose.price.text:setText("1")
      state.buttonsPanel.choose.price.text:setColor("#c0c0c0")
      state:recursiveGetChildById("rerollBonus"):setOn(true)
      state:recursiveGetChildById("rerollBonus").onClick = function()
        if not state:recursiveGetChildById("rerollBonus"):isOn() then
          return
        end
        onConfirmUsingWildcard(i - 1, 1, PREY_ACTION_BONUSREROLL)
      end

      if bonusRerolls < 1 then
        state.buttonsPanel.choose.price.text:setColor("#d33c3c")
        state:recursiveGetChildById("rerollBonus"):setOn(false)
      end

      state.buttonsPanel.autoRerollPrice.text:setText("1")
      state.buttonsPanel.autoRerollPrice.text:setColor("#c0c0c0")
      if bonusRerolls < 1 then
        state.buttonsPanel.autoRerollPrice.text:setColor("#d33c3c")
      end

      state.buttonsPanel.lockPreyPrice.text:setText("5")
      state.buttonsPanel.lockPreyPrice.text:setColor("#c0c0c0")
      if bonusRerolls < 5 then
        state.buttonsPanel.lockPreyPrice.text:setColor("#d33c3c")
      end

      local autoRerollCheck = state.buttonsPanel.autoReroll.autoRerollCheck
      local lockPreyCheck = state.buttonsPanel.lockPrey.lockPreyCheck

      local function disablePreyLock()
        clientPreyLockTypes[i - 1] = 0
        panel.lockType = 0
        autoRerollCheck:setChecked(false)
        lockPreyCheck:setChecked(false)
        g_game.preyAction(i - 1, PREY_ACTION_LOCK_PREY, 0)
      end

      state.buttonsPanel.autoReroll.onClick = function()
        if panel.lockType == 1 then
          disablePreyLock()
        elseif bonusRerolls >= 1 then
          onEnableAutoReroll(i - 1)
        else
          autoRerollCheck:setChecked(false)
        end
      end

      autoRerollCheck.onClick = function()
        if state.buttonsPanel.autoReroll.onClick then
          state.buttonsPanel.autoReroll.onClick()
        end
      end

      state.buttonsPanel.lockPrey.onClick = function()
        if panel.lockType == 2 then
          disablePreyLock()
        elseif bonusRerolls >= 5 then
          onEnableLockPrey(i - 1)
        else
          lockPreyCheck:setChecked(false)
        end
      end

      lockPreyCheck.onClick = function()
        if state.buttonsPanel.lockPrey.onClick then
          state.buttonsPanel.lockPrey.onClick()
        end
      end

      autoRerollCheck:setChecked(false)
      lockPreyCheck:setChecked(false)
      if panel.lockType == 1 then
        autoRerollCheck:setChecked(true)
      elseif panel.lockType == 2 then
        lockPreyCheck:setChecked(true)
      end
    end
  end
end

function check()
  creatureList = getMonsterList()
  if g_game.getFeature(GamePrey) then
    if not preyButton then
      preyButton = modules.client_topmenu.addRightGameToggleButton('preyButton', tr('Prey Dialog'), '/images/topbuttons/prey_window', toggle)
    end
    if not preyTrackerButton then
      preyTrackerButton = modules.client_topmenu.addRightGameToggleButton('preyTrackerButton', tr('Kill Tracker'), '/images/topbuttons/prey', toggleTracker)
    end
  elseif preyButton then
    preyButton:destroy()
    preyButton = nil
  end
end

function requestBountyAndWeeklyData()
  if g_game.bountyTaskAction then
    g_game.bountyTaskAction(4, 0)
  end
  if g_game.weeklyTaskAction then
    g_game.weeklyTaskAction(2, 0)
  end
end

function toggleTracker()
  if preyTracker:isVisible() then
    preyTracker:close()
  else
    if not preyTracker:getParent() or preyTracker:getParent() == g_ui.getRootWidget() then
      local panel = nil
      if modules.game_interface.findContentPanelAvailable then
        panel = modules.game_interface.findContentPanelAvailable(preyTracker, preyTracker:getMinimumHeight())
      elseif modules.game_interface.getRightPanel then
        panel = modules.game_interface.getRightPanel()
      elseif modules.game_interface.getRootPanel then
        panel = modules.game_interface.getRootPanel()
      end
      if not panel then
        return false
      end

      panel:addChild(preyTracker)
    end
    preyTracker:open()
  end
end

function onMiniWindowOpen()
  if preyTrackerButton then
    preyTrackerButton:setOn(true)
  end
  requestBountyAndWeeklyData()
  requestHuntingTaskData()
  updateHuntingTaskTracker()
end

function onMiniWindowClose()
  if preyTrackerButton then
    preyTrackerButton:setOn(false)
  end
end

function onGameEnd()
  preyWindow["slot3"].lockType = nil
  huntingTaskState = {
    tokens = 0,
    slots = {}
  }
  hide()
end

function hide(ignoreTracker)
  creatureList = nil
  preyWindow:hide()
  if not ignoreTracker then
    preyTracker:close()
    preyTracker:setParent(nil)
  end
  setInputLockWidget(nil)
  if preyWindowButton then
    preyWindowButton:setChecked(false)
  end
  if supportWindow then
    supportWindow:destroy()
    supportWindow = nil
  end

  if updateRerollEvent then
    removeEvent(updateRerollEvent)
    updateRerollEvent = nil
  end
end

function show(position)
  if preyWindowButton then
    preyWindowButton:setChecked(true)
  end
  setUnsupportedSettings()
  preyWindow:show(true)
  preyWindow:raise()
  preyWindow:focus()
  setInputLockWidget(preyWindow)
  if position ~= nil then
    preyWindow:setPosition(position)
  end

  if creatureList == nil then
    creatureList = getMonsterList()
  end
  updateWildCardWindow()
  if activeDialogTab == 'prey' then
    requestPreyData()
  else
    showHuntingTasksTab()
  end

  updateRerollEvent = cycleEvent(function() updateRerollTime() end, 1000)
end

function toggle()
  if preyWindow:isVisible() then
    return hide(true)
  end
  show()
end

function onPreyFreeRolls(slot, timeleft)
  local prey = preyWindow["slot" .. (slot + 1)]
  timeleft = tonumber(timeleft) or 0
  if timeleft > FREE_REROLL_SECONDS then
    timeleft = 0
  end

  local percent = (timeleft / FREE_REROLL_SECONDS) * 100
  local desc = timeleftTranslation(timeleft)
  if not prey then return end
  for i, panel in pairs({prey.active, prey.inactive}) do
    local progressBar = panel.reroll.button.time
    local price = panel.reroll.price.text
    progressBar:setText(desc)
    if timeleft == 0 then
      price:setText("Free")
    end
    progressBar:setPercent(percent)
  end
end

function onPreyTimeLeft(slot, timeLeft)
  -- description
  preyDescription[slot] = preyDescription[slot] or {one = "", two = ""}
  local text = preyDescription[slot].one .. timeleftTranslation(timeLeft) .. preyDescription[slot].two
  -- tracker
  local preyTrackerSlot = preyTracker.contentsPanel["slot" .. (slot + 1)]
  local updatedTime = string.gsub(preyTrackerSlot:getTooltip(), "[^\n]*Duration: [^\n]*\n?", "Duration: " .. timeleftTranslation(timeLeft) .. "\n")
  preyTrackerSlot:setTooltip(updatedTime)

  local percent = (timeLeft / (2 * 60 * 60)) * 100
  slot = "slot" .. (slot + 1)
  local tracker = preyTracker.contentsPanel[slot]
  tracker.time:setPercent(percent)
  for i, element in pairs({tracker.creatureName, tracker.creature, tracker.preyType, tracker.time}) do
    element:setTooltip(text)
    element.onClick = function()
      show()
    end
  end
  -- main window
  local prey = preyWindow[slot]
  if not prey then return end
  local progressbar = prey.active.creatureAndBonus.timeLeft
  local textLabel = prey.active.creatureAndBonus.textLabel
  local desc = timeleftTranslation(timeLeft, true)
  textLabel:setText(desc)
  progressbar:setPercent(percent)
end

function onPreyPrice(price)
  price = tonumber(price) or 0
  if price <= 0 then
    local player = g_game.getLocalPlayer()
    if player and player.getLevel then
      price = player:getLevel() * 150
    end
  end

  rerollPrice = price
  local t = {"slot1", "slot2", "slot3"}
  for i, slot in pairs(t) do
    local panel = preyWindow[slot]
    for j, state in pairs({panel.active, panel.inactive, panel.select}) do
      local priceWidget = state.buttonsPanel.reroll.price.text
      local progressBar = state.buttonsPanel.reroll.button.time
      if progressBar:getText() ~= "Free" then
        local formatedPrice = price < 100000 and comma_value(price) or math.ceil(price / 1000) .. "  k"
        priceWidget:setText(formatedPrice)
        setRerollStrikePrice(state.buttonsPanel.reroll.price, nil, false)
      else
        priceWidget:setText(0)
        setRerollStrikePrice(state.buttonsPanel.reroll.price, math.ceil(price / 1000) .. " k", true)
        progressBar:setPercent(0)
      end
    end
  end
  for i = 1, 3 do
    updateHuntingTaskPrices(preyWindow and preyWindow["huntingSlot" .. i])
  end

  setUnsupportedSettings()
end

function setTimeUntilFreeReroll(slot, timeUntilFreeReroll) -- seconds
  timeUntilFreeReroll = tonumber(timeUntilFreeReroll) or 0
  if timeUntilFreeReroll > FREE_REROLL_SECONDS then
    timeUntilFreeReroll = 0
  end

  timeLeftRerrol[slot] = {secondsLeft = timeUntilFreeReroll, startTime = os.time()}

  local prey = preyWindow["slot"..(slot + 1)]
  if not prey then return end
  local percent = (timeUntilFreeReroll / FREE_REROLL_SECONDS) * 100
  local desc = timeleftTranslation(timeUntilFreeReroll)
  for i, panel in pairs({prey.active, prey.inactive, prey.select}) do
    local reroll = panel.buttonsPanel.reroll.button.time
    reroll:setPercent(percent)
    reroll:setText(desc)
    local price = panel.buttonsPanel.reroll.price.text
    if timeUntilFreeReroll > 0 then
      local formatedPrice = rerollPrice < 100000 and comma_value(rerollPrice) or math.ceil(rerollPrice / 1000) .. "  k"
      price:setText(formatedPrice)
      setRerollStrikePrice(panel.buttonsPanel.reroll.price, nil, false)
      panel.buttonsPanel.reroll.button.rerollButton:setOn(false)
    else
      price:setText(0)
      setRerollStrikePrice(panel.buttonsPanel.reroll.price, math.ceil(rerollPrice / 1000) .. " k", true)
      panel.buttonsPanel.reroll.button.rerollButton:setOn(true)
    end

    panel.buttonsPanel.reroll.button.rerollButton.onClick = function()
      if not panel.buttonsPanel.reroll.button.rerollButton:isOn() then
        return
      end
      if timeUntilFreeReroll > 0 then
        return
      end
      onRerollButtonAction(slot, timeUntilFreeReroll <= 0)
    end
  end
end

function setBonusGradeStars(slot, grade)
  local prey = preyWindow["slot"..(slot + 1)]
  local gradePanel = prey.active.creatureAndBonus.bonus.grade

  gradePanel:destroyChildren()
  for i=1,10 do
    if i <= grade then
      local widget = g_ui.createWidget("Star", gradePanel)
      widget.onHoverChange = function()
        onHover(slot)
      end
    else
      local widget = g_ui.createWidget("NoStar", gradePanel)
      widget.onHoverChange = function()
        onHover(slot)
      end
    end
  end
end

function getBigIconPath(bonusType)
  local path = "/images/game/prey/"
  if bonusType == PREY_BONUS_DAMAGE_BOOST then
    return path.."prey_bigdamage"
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    return path.."prey_bigdefense"
  elseif bonusType == PREY_BONUS_XP_BONUS then
    return path.."prey_bigxp"
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    return path.."prey_bigloot"
  end
end

function getSmallIconPath(bonusType)
  local path = "/images/game/prey/"
  if bonusType == PREY_BONUS_DAMAGE_BOOST then
    return path.."prey_damage"
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    return path.."prey_defense"
  elseif bonusType == PREY_BONUS_XP_BONUS then
    return path.."prey_xp"
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    return path.."prey_loot"
  end
  return path .. "prey_no_bonus"
end

function getExtendIcon(lockType)
  local path = "/images/game/prey/"
  return path .. "prey-auto-extend-disabled"
end

function getBonusDescription(bonusType)
  if bonusType == PREY_BONUS_DAMAGE_BOOST then
    return "Damage Boost"
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    return "Damage Reduction"
  elseif bonusType == PREY_BONUS_XP_BONUS then
    return "XP Bonus"
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    return "Improved Loot"
  end
  return "None"
end

function getTooltipBonusDescription(bonusType, bonusValue)
  if bonusType == PREY_BONUS_DAMAGE_BOOST then
    return "You deal +"..bonusValue.."% extra damage against your prey creature."
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    return "You take "..bonusValue.."% less damage from your prey creature."
  elseif bonusType == PREY_BONUS_XP_BONUS then
    return "Killing your prey creature rewards +"..bonusValue.."% extra XP."
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    return "Your creature has a +"..bonusValue.."% chance to drop additional loot."
  end
end

function capitalFormatStr(str)
  local formatted = ""
  str = string.split(str, " ")
  for i, word in ipairs(str) do
    formatted = formatted .. " " .. (string.gsub(word, "^%l", string.upper))
  end
  return formatted:trim()
end

function onItemBoxChecked(widget, lastWidget, slot)
  if not widget then
    return
  end

  if lastWidget and lastWidget.highlight then
    lastWidget.highlight:setBackgroundColor("alpha")
    lastWidget:setBorderWidth(0)
    lastWidget:setBorderColor("alpha")
  end

  if widget.creature then
    local name = tr("Selected: %s", widget.creature:getTooltip())
    preyWindow["slot" .. slot].title:setText(short_text(name, 28))
    preyWindow["slot" .. slot].select:recursiveGetChildById('choosePreyButton'):setOn(true)
    setWidgetActionId(preyWindow["slot" .. slot].select:recursiveGetChildById('choosePreyButton'), slot)
  end

  if widget.highlight then
    widget.highlight:setBackgroundColor("white")
    widget:setChecked(true)
  end

  widget:setBorderWidth(1)
  widget:setBorderColor("white")
end

function onResourceBalance(resourceType, balance)
  balance = tonumber(balance) or 0
  if resourceType == ResourceBank then -- bank gold
    bankGold = balance
  elseif resourceType == ResourceInventary then -- inventory gold
    inventoryGold = balance
  elseif resourceType == ResourcePreyBonus then -- bonus rerolls
    bonusRerolls = balance
    if preyWindow.wildCards.setText then
      preyWindow.wildCards:setText(bonusRerolls)
    elseif preyWindow.wildCards.text then
      preyWindow.wildCards.text:setText(bonusRerolls)
    end
  end

  setUnsupportedSettings()
  if resourceType == ResourceBank or resourceType == ResourceInventary then
    if preyWindow.gold.setText then
      preyWindow.gold:setText(comma_value(bankGold + inventoryGold))
    elseif preyWindow.gold.text then
      preyWindow.gold.text:setText(comma_value(bankGold + inventoryGold))
    end
  end
  for i = 1, 3 do
    updateHuntingTaskPrices(preyWindow and preyWindow["huntingSlot" .. i])
  end
end

function onWildcardChange(prey, selected, lastSelected, slot)
  if not prey then return end

  if not selected then
    prey.wildcard.choose.button.choosePreyButton:setOn(false)
    setWidgetActionId(prey.wildcard.choose.button.choosePreyButton, 0)
    lastSelectedLabel[slot] = nil
    selectedMonster[slot] = nil
    prey.title:setText("Select your prey creature")
    setPreviewCreature(prey.wildcard.panel.creature, nil)
    return
  end

  prey.wildcard.choose.button.choosePreyButton:setOn(true)
  setWidgetActionId(prey.wildcard.choose.button.choosePreyButton, string.match(prey:getId(), "%d+$"))
  selected:setBackgroundColor("#585858")
  if lastSelected then
    lastSelected:setBackgroundColor(lastSelected.background)
  end

  if lastSelectedLabel[slot] then
    lastSelectedLabel[slot]:setBackgroundColor(lastSelectedLabel[slot].background)
    lastSelectedLabel[slot]:setColor("#c0c0c0")
  end

  lastSelectedLabel[slot] = selected
  selectedMonster[slot] = tonumber(selected:getId())
  local creature = getRaceInfo(selectedMonster[slot])
  prey.title:setText("Selected: " .. short_text(capitalFormatStr(creature.name), 18))
  setPreviewCreature(prey.wildcard.panel.creature, creature.outfit)
end

function onTextEdit(widget)
  searchFilterText = widget:getText()
  updateSearchWildcard(widget:getParent():getParent())
end

function move(panel, height, minimized)
  preyTracker:setParent(panel)
  preyTracker:open()

  if minimized then
    preyTracker:setHeight(height)
    preyTracker:minimize()
  else
    preyTracker:maximize()
    preyTracker:setHeight(height)
  end
  return preyTracker
end

function isThirdSlotLocked()
  local preySlot = preyWindow["slot3"]
  local lockType = preySlot.lockType
  if lockType == nil then
    return true
  end

  if lockType ~= nil and lockType >= 0 then
    return false
  end
  return true
end

function updatePreyWidget(slot, state)
  local preyTrackerSlot = preyTracker.contentsPanel["slot" .. (slot + 1)]
  if state == SLOT_STATE_LOCKED then
    preyTrackerSlot:setVisible(false)
    return
  end

  local preySlot = preyWindow["slot" .. (slot + 1)]
  if slot == 2 then
    preyTrackerSlot:setVisible(true)
  end

  if state == SLOT_STATE_ACTIVE then
    local creatureAndBonus = preySlot.active.creatureAndBonus
    preyTrackerSlot.creature:setOutfit(normalizeOutfit(preySlot.currentHolderOutfit))
    preyTrackerSlot.creatureName:setText(short_text(preySlot.title:getText(), 12))
    preyTrackerSlot.time:setPercent(creatureAndBonus.timeLeft:getPercent())
    preyTrackerSlot.preyType:setImageSource(getSmallIconPath(preySlot.bonusType))
    preyTrackerSlot.preyAutoExtend:hide()
    preyTrackerSlot.creature:show()
    preyTrackerSlot.noCreature:hide()

    local preyName = preySlot.title:getText()
    local timeleft = timeleftTranslation(preySlot.timeLeft)
    local typeDesc = bonusTypeTranslate(preySlot.bonusType)
    local extendedDesc = preySlot.lockType == 0 and "false" or "true"
    local bonusDescription = bonusTypeTranslateText(preySlot.bonusType, preySlot.bonusValue)
    local starBonus = ""
    for i = 1, 10 do
      if i <= preySlot.bonusGrade then
        starBonus = starBonus .. "^"
      else
        starBonus = starBonus .. ";"
      end
    end

    local text = "Creature: %s\nDuration: %s\nValue: %s\nType: %s\nAutomatic Extend Prey: %s\n%s\n\nClick in this window to open the prey dialog."
    preyTrackerSlot:setTooltip(tr(text, preyName, timeleft, starBonus, typeDesc, extendedDesc, bonusDescription))
    preyTrackerSlot.onClick = function() show() end

  else
    preyTrackerSlot.creature:hide()
    preyTrackerSlot.noCreature:show()
    preyTrackerSlot.creatureName:setText("Inactive")
    preyTrackerSlot.time:setPercent(0)
    preyTrackerSlot.preyAutoExtend:hide()
    preyTrackerSlot.preyType:setImageSource(getSmallIconPath(preySlot.bonusType))
    preyTrackerSlot:setTooltip("Inactive Prey. \n\nUse the prey dialog to activate it. You can open the prey dialog by cliking in this window.")
    preyTrackerSlot.onClick = function() show() end
  end
end

function onRerollButtonAction(slot, freeReroll)
  if supportWindow then
    return
  end

  setInputLockWidget(nil)
  preyWindow:hide()
  local okFunc = function()
    g_game.preyAction(slot, PREY_ACTION_LISTREROLL, 0)
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
    setUnsupportedSettings()
  end

  local cancelFunc = function()
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
    setUnsupportedSettings()
  end

  local confirmText = "Are you sure you want to use the Free List Reroll?"
  if not freeReroll then
    confirmText = tr("Do you want to spend %s gold for a List Reroll?\nYou currently have %s gold available for the purchase.", comma_value(rerollPrice), (comma_value(bankGold + inventoryGold)))
  end

	supportWindow = displayGeneralBox(tr("Confirm of Using List Reroll"), confirmText,
    { { text=tr('Yes'), callback=okFunc },
    { text=tr('No'), callback=cancelFunc }
  }, okFunc, cancelFunc)
end

function onConfirmUsingWildcard(slot, price, action)
  if supportWindow then
    return
  end

  setInputLockWidget(nil)
  preyWindow:hide()

  local okFunc = function()
    g_game.preyAction(slot, action, 0)
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
  end

  local cancelFunc = function()
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
  end

  local confirmText = tr("Are you sure you want to use %s of your remaining %s Prey Wildcards?", price, bonusRerolls)
	supportWindow = displayGeneralBox(tr("Confirmation of Using Prey Wildcards"), confirmText,
    { { text=tr('Yes'), callback=okFunc },
    { text=tr('No'), callback=cancelFunc }
  }, okFunc, cancelFunc)
end

function onEnableAutoReroll(slot)
  if supportWindow then
    return
  end

  setInputLockWidget(nil)
  preyWindow:hide()
  local okFunc = function()
    clientPreyLockTypes[slot] = 1
    local prey = preyWindow and preyWindow["slot" .. (slot + 1)]
    if prey then
      prey.lockType = 1
    end
    g_game.preyAction(slot, PREY_ACTION_LOCK_PREY, 1)
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
  end

  local cancelFunc = function()
    local prey = preyWindow and preyWindow["slot" .. (slot + 1)]
    if prey then
      prey.lockType = clientPreyLockTypes[slot] or 0
    end
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
    setUnsupportedSettings()
  end

  local confirmText = tr("Do you want to enable the Automatic Bonus Reroll?\nEach time the Automatic Bonus Reroll is triggered, 1 of your Prey Wildcards will be consumed.")
	supportWindow = displayGeneralBox(tr("Confirmation of Using Prey Wildcards"), confirmText,
    { { text=tr('Yes'), callback=okFunc },
    { text=tr('No'), callback=cancelFunc }
  }, okFunc, cancelFunc)
end

function onEnableLockPrey(slot)
   if supportWindow then
    return
  end

  setInputLockWidget(nil)
  preyWindow:hide()
  local okFunc = function()
    clientPreyLockTypes[slot] = 2
    local prey = preyWindow and preyWindow["slot" .. (slot + 1)]
    if prey then
      prey.lockType = 2
    end
    g_game.preyAction(slot, PREY_ACTION_LOCK_PREY, 2)
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
  end

  local cancelFunc = function()
    local prey = preyWindow and preyWindow["slot" .. (slot + 1)]
    if prey then
      prey.lockType = clientPreyLockTypes[slot] or 0
    end
    supportWindow:destroy()
    supportWindow = nil
    preyWindow:show(true)
    preyWindow:raise()
    preyWindow:focus()
    setInputLockWidget(preyWindow)
    setUnsupportedSettings()
  end

  local confirmText = tr("Do you want to enable the Lock Prey?\nEach time the Lock Prey is triggered, 5 of your Prey Wildcards will be consumed.")
	supportWindow = displayGeneralBox(tr("Confirmation of Using Prey Wildcards"), confirmText,
    { { text=tr('Yes'), callback=okFunc },
    { text=tr('No'), callback=cancelFunc }
  }, okFunc, cancelFunc)
end

function onPreyActive(slot, currentHolderName, currentHolderOutfit, bonusType, bonusValue, bonusGrade, timeLeft, timeUntilFreeReroll, wildcards, option)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then
    return
  end
  option = option or 0
  if option == 0 and clientPreyLockTypes[slot] and clientPreyLockTypes[slot] > 0 then
    option = clientPreyLockTypes[slot]
  end

  local percent = (timeLeft / (2 * 60 * 60)) * 100
  prey.inactive:hide()
  prey.locked:hide()
  prey.wildcard:hide()
  prey.select:hide()
  prey.active:show()
  prey.title:setText(capitalFormatStr(currentHolderName))
  local creatureAndBonus = prey.active.creatureAndBonus
  creatureAndBonus.creature:setOutfit(normalizeOutfit(currentHolderOutfit))
  setTimeUntilFreeReroll(slot, timeUntilFreeReroll)
  creatureAndBonus.bonus.icon:setImageSource(getBigIconPath(bonusType))

  creatureAndBonus.bonus.icon.onHoverChange = function(widget, hovered)
    onHover(slot)
  end

  setBonusGradeStars(slot, bonusGrade)
  creatureAndBonus.timeLeft:setPercent(percent)
  creatureAndBonus.textLabel:setText(timeleftTranslation(timeLeft))

  prey.active.buttonsPanel.reroll.button.rerollButton.onClick = function()
    if not prey.active.buttonsPanel.reroll.button.rerollButton:isOn() then
      return
    end
    onRerollButtonAction(slot, timeUntilFreeReroll <= 0)
  end

  prey.bonusType = bonusType
  prey.bonusValue = bonusValue
  prey.bonusGrade = bonusGrade
  prey.lockType = option or 0
  prey.timeLeft = timeLeft
  prey.currentHolderOutfit = currentHolderOutfit
  setUnsupportedSettings()
  updatePreyWidget(slot, SLOT_STATE_ACTIVE)
end

function onPreySelection(slot, bonusType, bonusValue, bonusGrade, names, outfits, timeUntilFreeReroll, lockType)
  if type(bonusType) == 'table' then
    names, outfits, timeUntilFreeReroll = bonusType, bonusValue, bonusGrade
    bonusType, bonusValue, bonusGrade, lockType = PREY_BONUS_NONE, 0, 0, 0
  end
  lockType = lockType or 0
  if lockType == 0 and clientPreyLockTypes[slot] and clientPreyLockTypes[slot] > 0 then
    lockType = clientPreyLockTypes[slot]
  end

  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then
    return
  end

  prey.active:hide()
  prey.locked:hide()
  prey.wildcard:hide()
  prey.inactive:hide()
  prey.select:show()
  prey.title:setText(tr("Select your prey creature"))

  local list = prey.select.list
  list:destroyChildren()

  prey.select.buttonsPanel.choose.button.choosePreyButton:setOn(false)
  setWidgetActionId(prey.select.buttonsPanel.choose.button.choosePreyButton, slot + 1)
  for i, name in ipairs(names) do
    local box = g_ui.createWidget("PreyCreatureBox", list)
    box.onHoverChange = function() onSpecialHover("selectionList", bonusType, bonusValue) end
    name = capitalFormatStr(name)
    box.creature:setTooltip(name)
    box.creature:setOutfit(normalizeOutfit(outfits[i]))
    if i == 1 then
      onItemBoxChecked(box, nil, slot + 1)
    end
  end

  list.onChildFocusChange = function(list, selected, lastSelected)
    if not lastSelected then
      lastSelected = list:getFirstChild()
    end
    onItemBoxChecked(selected, lastSelected, slot + 1)
   end

  prey.select.buttonsPanel.choose.button.choosePreyButton.onClick = function()
    if not prey.select.buttonsPanel.choose.button.choosePreyButton:isOn() then
      return true
    end

    g_game.preyAction(slot, PREY_ACTION_MONSTERSELECTION, list:getChildIndex(list:getFocusedChild()) - 1)
  end

  prey.select.buttonsPanel.reroll.button.rerollButton.onClick = function()
    if not prey.select.buttonsPanel.reroll.button.rerollButton:isOn() then
      return
    end
    onRerollButtonAction(slot, timeUntilFreeReroll <= 0)
  end

  prey.lockType = lockType
  prey.bonusType = bonusType
  prey.bonusValue = bonusValue
  setTimeUntilFreeReroll(slot, timeUntilFreeReroll)
  setUnsupportedSettings()
  updatePreyWidget(slot, SLOT_STATE_SELECTION)
end

function onPreySelectionChangeMonster(slot, names, outfits, bonusType, bonusValue, bonusGrade, timeUntilFreeReroll, wildcards, option)
  onPreySelection(slot, bonusType, bonusValue, bonusGrade, names, outfits, timeUntilFreeReroll, option or 0)
end

function onPreyListSelection(slot, races, timeUntilFreeReroll, wildcards, option)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then
    return
  end

  currentRaces[slot] = normalizeRaceList(races)
  currentSearchRaces[slot] = {}
  itemListMin[slot] = 0
  itemListMax[slot] = #currentRaces[slot]
  itemSize[slot] = WILDCARD_LABEL_HEIGHT
  maxFitItems[slot] = 0
  poolSize[slot] = WILDCARD_VISIBLE_LABELS
  itemsPool[slot] = {}
  selectedMonster[slot] = nil
  lastSelectedLabel[slot] = nil

  prey.title:setText("Select your prey creature")
  prey.inactive:hide()
  prey.active:hide()
  prey.locked:hide()
  prey.select:hide()
  prey.wildcard:show()

  prey.wildcard.monsterList:focusChild(nil)
  prey.wildcard.monsterList:destroyChildren()
  setPreviewCreature(prey.wildcard.panel.creature, nil)
  prey.wildcard:recursiveGetChildById("searchText"):clearText(true)
  prey.wildcard.monsterList.onChildFocusChange = function(self, selected, lastSelected)
    onWildcardChange(prey, selected, lastSelected, slot)
  end

  prey.wildcard.panel.onHoverChange = function()
    onSpecialHover("selectionList", PREY_BONUS_NONE, 0)
  end

  prey.wildcard.choose.button.choosePreyButton:setOn(false)
  setWidgetActionId(prey.wildcard.choose.button.choosePreyButton, slot + 1)
  prey.wildcard.choose.button.choosePreyButton.onClick = function()
    if not prey.wildcard.choose.button.choosePreyButton:isOn() or not selectedMonster[slot] then
      return true
    end

    return g_game.preyAction(slot, PREY_ACTION_CHANGE_FROM_ALL, selectedMonster[slot])
  end

  prey.lockType = option or 0
  prey.bonusType = PREY_BONUS_NONE
  prey.bonusValue = 0
  setTimeUntilFreeReroll(slot, timeUntilFreeReroll)
  updatePreyWidget(slot, SLOT_STATE_WILDCARD)
  updateWildCardWindow()
  setUnsupportedSettings()
end

function onPreyWildcardSelection(slot, races, timeUntilFreeReroll, wildcards, option)
  onPreyListSelection(slot, races, timeUntilFreeReroll, wildcards, option)
end

function updateSearchWildcard(prey)
  prey.wildcard.monsterList:focusChild(nil)
  if searchFilterText == '' then
    updateWildCardWindow()
    return
  end

  local slot = tonumber(prey:getId():match("%d+")) - 1
  currentSearchRaces[slot] = {}
  for _, raceId in pairs(currentRaces[slot]) do
    local creature = getRaceInfo(raceId)
    local searchFilterTextEscaped = string.searchEscape(searchFilterText:lower())
    if string.find((creature.name or ""):lower(), searchFilterTextEscaped) then
      table.insert(currentSearchRaces[slot], raceId)
    end
  end

  for i, monsterLabel in ipairs(itemsPool[slot]) do
    if i > #currentSearchRaces[slot] then
      monsterLabel:setBackgroundColor("alpha")
      monsterLabel:setText('')
      monsterLabel.icon:setVisible(false)
      monsterLabel:setFocusable(false)
    else
      local monsterInfo = currentSearchRaces[slot][i]
      local color = ((i % 2 == 0) and '#484848' or '#414141')
      monsterLabel:setFocusable(true)
      monsterLabel:setBackgroundColor(color)
      monsterLabel.background = color
      monsterLabel:setId(monsterInfo)
      monsterLabel:setColor('#c0c0c0')
      local creature = getRaceInfo(monsterInfo)
      if creature then
        monsterLabel:setText(capitalFormatStr(creature.name))
      end

      monsterLabel.icon:setVisible(false)
      monsterLabel:setTextOffset("0 0")
    end
  end

  local scrollbar = prey.wildcard:recursiveGetChildById('monsterListScrollBar')
  scrollbar:setMinimum(itemListMin[slot])
  scrollbar:setMaximum(#currentSearchRaces[slot])
  scrollbar.onValueChange = function(self, value, delta) onSearchValueChange(self, value, delta, slot) end
end

function onSearchValueChange(scrollbar, value, delta, slot)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  local startItem = math.max(itemListMin[slot], value)
  local endItem = startItem + maxFitItems[slot] - 1

  if endItem > #currentSearchRaces[slot] then
    endItem = #currentSearchRaces[slot]
    startItem = endItem - maxFitItems[slot] + 1
  end

  for i, monsterLabel in ipairs(itemsPool[slot]) do
    local itemId = value > 0 and (startItem + i - 1) or (startItem + i)
    local monsterInfo = currentSearchRaces[slot][itemId]
    if not monsterInfo then
      monsterLabel:setBackgroundColor("alpha")
      monsterLabel:setText('')
      monsterLabel.icon:setVisible(false)
      monsterLabel:setFocusable(false)
    else
      local color = ((itemId % 2 == 0) and '#484848' or '#414141')
      monsterLabel:setFocusable(true)
      monsterLabel:setBackgroundColor(color)
      monsterLabel.background = color
      monsterLabel:setId(monsterInfo)
      monsterLabel:setColor('#c0c0c0')
      local creature = getRaceInfo(monsterInfo)
      if creature then
        monsterLabel:setText(capitalFormatStr(creature.name))
      end

      if selectedMonster[slot] == monsterInfo then
        prey.wildcard.monsterList:focusChild(monsterLabel)
        monsterLabel:setBackgroundColor('#585858')
        monsterLabel:setColor('#f4f4f4')
        lastSelectedLabel[slot] = monsterLabel
      end

      monsterLabel.icon:setVisible(false)
      monsterLabel:setTextOffset("0 0")
    end
  end
end

function onWildcardValueChange(_, value, _, slot)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  local startItem = math.max(itemListMin[slot], value)
  local endItem = startItem + maxFitItems[slot] - 1

  if endItem > itemListMax[slot] then
    endItem = itemListMax[slot]
    startItem = endItem - maxFitItems[slot] + 1
  end

  for i, monsterLabel in ipairs(itemsPool[slot]) do
    local itemId = value > 0 and (startItem + i - 1) or (startItem + i)
    local monsterInfo = currentRaces[slot][itemId]
    if not monsterInfo then
      monsterLabel:setBackgroundColor("alpha")
      monsterLabel:setText('')
      monsterLabel.icon:setVisible(false)
      monsterLabel:setFocusable(false)
    else
      local color = ((itemId % 2 == 0) and '#484848' or '#414141')
      monsterLabel:setFocusable(true)
      monsterLabel:setBackgroundColor(color)
      monsterLabel.background = color
      monsterLabel:setId(monsterInfo)
      monsterLabel:setColor('#c0c0c0')
      local creature = getRaceInfo(monsterInfo)
      if creature then
        monsterLabel:setText(capitalFormatStr(creature.name))
      end

      if selectedMonster[slot] == monsterInfo then
        prey.wildcard.monsterList:focusChild(monsterLabel)
        monsterLabel:setBackgroundColor('#585858')
        monsterLabel:setColor('#f4f4f4')
        lastSelectedLabel[slot] = monsterLabel
      end

      monsterLabel.icon:setVisible(false)
      monsterLabel:setTextOffset("0 0")
    end
  end
end

function updateWildCardWindow()
  for i = 0, 2 do
    local prey = preyWindow["slot" .. i + 1]
    if prey and prey.wildcard:isVisible() then
      table.sort(currentRaces[i], function(a, b)
        local creatureA = getRaceInfo(a)
        local creatureB = getRaceInfo(b)
        return creatureA.name < creatureB.name
      end)

      itemsPool[i] = {}
      prey.wildcard.monsterList:destroyChildren()

      local count = 0
      for k = 1, poolSize[i] do
        local monsterInfo = currentRaces[i][k]
        if monsterInfo == nil then
          break
        end

        local monster = g_ui.createWidget("WildcardLabel", prey.wildcard.monsterList)
        monster:setId(monsterInfo)
        setWidgetActionId(monster, i + 1)
        monster:setTextAlign(AlignLeft)
        count = count + 1
        local color = ((count % 2 == 0) and '#484848' or '#414141')
        monster:setBackgroundColor(color)
        monster.background = color
        local creature = getRaceInfo(monsterInfo)
        if creature then
          monster:setText(capitalFormatStr(creature.name))
        end

        monster:setTextOffset("0 0")
        monster.onHoverChange = function(monster, hovered) onSpecialHover("selectionList", PREY_BONUS_NONE, 0) end
        table.insert(itemsPool[i], monster)
      end

      prey.wildcard:recursiveGetChildById('monsterListScrollBar'):setValue(0)
      maxFitItems[i] = math.floor(prey.wildcard.monsterList:getHeight() / itemSize[i])
      local scrollbar = prey.wildcard:recursiveGetChildById('monsterListScrollBar')
      scrollbar:setMinimum(itemListMin[i])
      scrollbar:setMaximum(itemListMax[i])
      scrollbar.onValueChange = function(self, value, delta) onWildcardValueChange(self, value, delta, i) end
    end
  end
end

function onPreyWildcard(slot, races, _, lockType, bonusType, bonusValue, bonusGrade)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then
    return
  end

  itemListMin[slot] = 0
  currentRaces[slot] = normalizeRaceList(races)
  itemListMax[slot] = #currentRaces[slot]
  currentSearchRaces[slot] = {}
  itemSize[slot] = WILDCARD_LABEL_HEIGHT
  maxFitItems[slot] = 0
  poolSize[slot] = WILDCARD_VISIBLE_LABELS
  itemsPool[slot] = {}

  prey.title:setText("Select your prey creature")
  prey.inactive:hide()
  prey.active:hide()
  prey.locked:hide()
  prey.select:hide()
  prey.wildcard:show()

  prey.wildcard.monsterList:focusChild(nil)
  prey.wildcard.monsterList:destroyChildren()
  setPreviewCreature(prey.wildcard.panel.creature, nil)

  local count = 0
  for i = 1, poolSize[slot] do
    local monster = g_ui.createWidget("WildcardLabel", prey.wildcard.monsterList)
    table.insert(itemsPool[slot], monster)
  end

  maxFitItems[slot] = math.floor(prey.wildcard.monsterList:getHeight() / itemSize[slot])

  local scrollbar = prey.wildcard:recursiveGetChildById('monsterListScrollBar')
  scrollbar:setMinimum(itemListMin[slot])
  scrollbar:setMaximum(itemListMax[slot])
  scrollbar.onValueChange = function(self, value, delta) onWildcardValueChange(self, value, delta, slot) end

  prey.wildcard:recursiveGetChildById("searchText"):clearText(true)
  prey.wildcard.monsterList.onChildFocusChange = function(self, selected, lastSelected) onWildcardChange(prey, selected, lastSelected, slot) end

  local preyPanel = prey.wildcard.panel
  preyPanel.onHoverChange = function() onSpecialHover("selectionList", bonusType, bonusValue) end

  monsterList = prey.wildcard.monsterList
  setWidgetActionId(prey.wildcard.choose.button.choosePreyButton, slot + 1)
  prey.wildcard.choose.button.choosePreyButton.onClick = function()
    return g_game.preyAction(slot, 4, selectedMonster[slot])
  end

  prey.lockType = lockType
  prey.bonusValue = bonusValue
  prey.bonusType = bonusType
  setUnsupportedSettings()
  updatePreyWidget(slot, SLOT_STATE_WILDCARD)
  updateWildCardWindow()
end

function onPreyLocked(slot)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then
    return
  end

  prey.title:setText("Locked")
  prey.inactive:hide()
  prey.active:hide()
  prey.select:hide()
  prey.locked:show()
  setUnsupportedSettings()
  updatePreyWidget(slot, SLOT_STATE_LOCKED)
end

function onPreyInactive(slot, timeUntilFreeReroll, lockType)
  local prey = preyWindow["slot"..(slot + 1)]
  if not prey then
    return
  end
  lockType = lockType or 0
  if lockType == 0 and clientPreyLockTypes[slot] and clientPreyLockTypes[slot] > 0 then
    lockType = clientPreyLockTypes[slot]
  end

  prey.title:setText("Inactive")
  setTimeUntilFreeReroll(slot, timeUntilFreeReroll)
  prey.active:hide()
  prey.locked:hide()
  prey.wildcard:hide()
  prey.select:hide()
  prey.inactive:show()

  prey.inactive.buttonsPanel.reroll.button.rerollButton.onClick = function()
    if not prey.inactive.buttonsPanel.reroll.button.rerollButton:isOn() then
      return
    end
    onRerollButtonAction(slot, timeUntilFreeReroll <= 0)
  end

  prey.lockType = lockType
  setUnsupportedSettings()
  updatePreyWidget(slot, SLOT_STATE_INACTIVE)
end

function storeRedirect(offerType)
  setInputLockWidget(nil)
  local opened = false
  if modules.game_shop and modules.game_shop.show then
    modules.game_shop.show()
    opened = true
  elseif modules.game_store and modules.game_store.show then
    modules.game_store.show()
    opened = true
  end

  if g_game.openStore then
    g_game.openStore(0)
    opened = true
  end

  if opened then
    preyWindow:hide()
  end

  scheduleEvent(function()
    if g_game.requestStoreOffers then
      local serviceType = 0
      if g_game.getFeature(GameTibia12Protocol) then
        serviceType = 2
      end
      g_game.requestStoreOffers("Prey", serviceType)
    end
  end, 250)
end

function focusPrevWildcardLabel(list)
  local c = list:getFocusedChild()
  if not c then return end
  local cIndex = list:getChildIndex(c)

  if cIndex > 1 then
    list:focusPreviousChild(KeyboardFocusReason)
  else
    local scrollbar = list:getParent():recursiveGetChildById('monsterListScrollBar')
    scrollbar:setValue(scrollbar:getValue() - 1)
    if cIndex == 1 then
      list:focusPreviousChild(KeyboardFocusReason)
    end
  end
end

function focusNextWildcardLabel(list)
  local c = list:getFocusedChild()
  local cIndex = list:getChildIndex(c)
  local cCount = list:getChildCount()
  if cIndex < cCount then
    list:focusNextChild(KeyboardFocusReason)
  else
    local scrollbar = list:getParent():recursiveGetChildById('monsterListScrollBar')
    scrollbar:setValue(scrollbar:getValue() + 1)
    if cIndex == cCount then
      list:focusNextChild(KeyboardFocusReason)
    end
  end
end

function updateRerollTime()
  if not g_game.isOnline() or not preyWindow:isVisible() then
    removeEvent(updateRerollEvent)
    updateRerollEvent = nil
    return
  end

  for slot, data in pairs(timeLeftRerrol) do
    local startTime = data.startTime
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    if elapsedTime > 0 then
      setTimeUntilFreeReroll(slot, math.max(0, data.secondsLeft - elapsedTime))
    end
  end
end

function updateTrackerHeight(extraSize)
  -- FLAMENGO CAMPEAO 1998 2019 2022
  if not preyTracker then
    return
  end

  local size = 200
  local thirdSlotLocked = isThirdSlotLocked()

  if thirdSlotLocked and not extraSize then
    size = 280
  elseif thirdSlotLocked and extraSize then
    size = 340
  elseif not thirdSlotLocked and not extraSize then
    size = 305
  elseif not thirdSlotLocked and extraSize then
    size = 365
  end

  preyTracker:setContentMaximumHeight(size)
end
