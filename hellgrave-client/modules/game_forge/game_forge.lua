local ForgeControllerBase = {}
function ForgeControllerBase:new()
  local controller = { _eventConnections = {} }
  setmetatable(controller, { __index = self })
  return controller
end
function ForgeControllerBase:init()
  if self.onInit then self:onInit() end
  if g_game then
    connect(g_game, {
      onGameStart = function() if self.onGameStart then self:onGameStart() end end,
      onGameEnd = function() if self.onGameEnd then self:onGameEnd() end end
    })
  end
end
function ForgeControllerBase:terminate()
  if self.onGameEnd then self:onGameEnd() end
  if self.onTerminate then self:onTerminate() end
end

ForgeController = ForgeControllerBase:new()

local FORGE_OPCODE = 235
local rootWidget = g_ui.getRootWidget()
local resultWindow = nil
local suppressUiEvents = false
local currentForgeTarget = nil
local forgeOpcodeRegistered = false
local balanceRefreshEvent = nil

local DEFAULT_IMPROVE_CORE_COSTS = { [1] = 2, [2] = 5, [3] = 13, [4] = 30, [5] = 70, [6] = 160, [7] = 365, [8] = 450, [9] = 600, [10] = 850 }
local DEFAULT_LOSS_CORE_COSTS = { [1] = 2, [2] = 7, [3] = 19, [4] = 49, [5] = 125, [6] = 311, [7] = 450, [8] = 600, [9] = 850, [10] = 1000 }
local function coreCostFromTable(costs, tier, fallback)
  costs = type(costs) == 'table' and costs or fallback
  return tonumber(costs[tier] or costs[tostring(tier)] or fallback[tier]) or 0
end

local cloneValue = Helpers.cloneValue
local replaceTableContents = Helpers.replaceTableContents
local normalizeClassPriceEntries = Helpers.normalizeClassPriceEntries
local normalizeTierPriceEntries = Helpers.normalizeTierPriceEntries

local ItemsDatabase = rawget(_G, 'ItemsDatabase') or {}
ItemsDatabase.getTierClip = ItemsDatabase.getTierClip or function(tier)
  tier = math.max(1, tonumber(tier) or 1)
  return { x = (tier - 1) * 12, y = 0, width = 12, height = 9 }
end
ItemsDatabase.getClipAndImagePath = ItemsDatabase.getClipAndImagePath or function()
  return nil, nil, nil
end

local function widget(id, parent)
  parent = parent or ForgeController.ui
  if not parent or not id then
    return nil
  end
  return parent:recursiveGetChildById(id)
end

local function showForgeItemTooltip(itemWidget, hovered, actualThing)
  local tooltipModule = modules.game_tooltip
  local tooltip = tooltipModule and tooltipModule.m_TooltipFunction or nil
  if not tooltip then return end
  if not hovered then
    tooltip.destroy()
    return
  end

  local displayItem = itemWidget:getItem()
  if not displayItem then return end
  pcall(function() tooltip.create(itemWidget:getPosition(), displayItem, true) end)
end

local function destroyForgeTooltip()
  local tooltipModule = modules.game_tooltip
  local tooltip = tooltipModule and tooltipModule.m_TooltipFunction or nil
  if tooltip then tooltip.destroy() end
end

local function paintForgeTierBadge(itemWidget, tier)
  if not itemWidget then return end
  local oldBadge = itemWidget:getChildById('forgeTierOverlay')
  if oldBadge then oldBadge:destroy() end
  tier = math.floor(tonumber(tier) or 0)
  if not itemWidget:getItem() or tier < 1 or tier > 10 then return end

  local badge = g_ui.createWidget('UIWidget', itemWidget)
  badge:setId('forgeTierOverlay')
  local largePreview = itemWidget:getWidth() >= 50 and itemWidget:getHeight() >= 50
  local badgeSize = largePreview and 40 or 32
  badge:setSize({ width = badgeSize, height = badgeSize })
  badge:setImageSize(tosize(string.format('%d %d', badgeSize, badgeSize)))
  if largePreview then
    badge:addAnchor(AnchorRight, 'parent', AnchorRight)
    badge:addAnchor(AnchorBottom, 'parent', AnchorBottom)
  else
    badge:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
    badge:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
  end
  badge:setImageSource('/modules/game_forge/images/' .. tier)
  badge:setPhantom(true)
  badge:setFocusable(false)
end

local function requestForgeTierRefresh()
  local protocol = g_game.getProtocolGame()
  if not protocol then return end
  protocol:sendExtendedOpcode(210, json.encode({ a = 'invReq' }))
  for _, container in pairs(g_game.getContainers()) do
    protocol:sendExtendedOpcode(209, json.encode({ a = 'reqR', c = container:getId() }))
  end
end

local function setText(id, text, parent)
  local target = widget(id, parent)
  if target then
    target:setText(tostring(text or ''))
  end
end

local function setEnabled(id, enabled, parent)
  local target = widget(id, parent)
  if target then
    target:setEnabled(enabled == true)
  end
end

local function setVisible(id, visible, parent)
  local target = widget(id, parent)
  if target then
    target:setVisible(visible == true)
  end
end

local function setItem(id, itemId, parent)
  local target = widget(id, parent)
  if target then
    local nextItemId = math.max(0, tonumber(itemId) or 0)
    local currentItem = target:getItem()
    local currentItemId = currentItem and tonumber(currentItem:getId()) or 0
    if currentItemId == nextItemId then return end

    local oldBadge = target:getChildById('forgeTierOverlay')
    if oldBadge then oldBadge:destroy() end
    target:setItem()
    target:setItemId(nextItemId)
  end
end

local function setColor(id, color, parent)
  local target = widget(id, parent)
  if target and color then
    target:setColor(color)
  end
end

local function getItemName(itemId)
  itemId = tonumber(itemId) or 0
  if itemId <= 0 then
    return 'No item selected'
  end

  local ok, name = pcall(function()
    local item = Item.create(itemId)
    local marketData = item and item.getMarketData and item:getMarketData() or nil
    return marketData and marketData.name or nil
  end)
  if ok and name and name ~= '' then
    return name
  end
  return string.format('Item %d', itemId)
end

local function sendForgeRequest(action, data)
  local protocol = g_game.getProtocolGame()
  if not protocol then
    return false
  end
  protocol:sendExtendedOpcode(FORGE_OPCODE, json.encode({
    action = action,
    data = data or {}
  }))
  return true
end

local function cancelBalanceRefresh()
  if balanceRefreshEvent then
    removeEvent(balanceRefreshEvent)
    balanceRefreshEvent = nil
  end
end

local function scheduleBalanceRefresh()
  if not ForgeController.ui or ForgeController.ui:isDestroyed() or not ForgeController.ui:isVisible() then return end
  cancelBalanceRefresh()
  balanceRefreshEvent = scheduleEvent(function()
    balanceRefreshEvent = nil
    if ForgeController.ui and not ForgeController.ui:isDestroyed() and ForgeController.ui:isVisible() then
      sendForgeRequest('balances')
    end
  end, 100)
end

local function registerForgeOpcode()
  if forgeOpcodeRegistered then return end
  ProtocolGame.registerExtendedOpcode(FORGE_OPCODE, function(protocol, opcode, buffer)
    ForgeController:onExtendedOpcode(protocol, opcode, buffer)
  end)
  forgeOpcodeRegistered = true
end

local function unregisterForgeOpcode()
  if not forgeOpcodeRegistered then return end
  if ProtocolGame and ProtocolGame.unregisterExtendedOpcode then
    ProtocolGame.unregisterExtendedOpcode(FORGE_OPCODE)
  end
  forgeOpcodeRegistered = false
end

ForgeController.baseSelected = {
  id = -1,
  clientId = -1,
  tier = 0,
  count = 0,
  countLabel = '0 / 1',
  key = '',
  targetTier = 0
}

ForgeController.currentTab = 'fusion'
ForgeController.currentDust = 0
ForgeController.currentSlivers = 0
ForgeController.currentExaltedCores = 0
ForgeController.rawCurrentGold = 0
ForgeController.currentGold = '0'
ForgeController.rawPrice = 0
ForgeController.formattedPrice = '???'
ForgeController.description = ''
ForgeController.currencyClientIds = { dust = 0, sliver = 0, core = 0 }
ForgeController.waitingForResult = false
ForgeController.result = cloneValue(Helpers.baseResult)

ForgeController.fusion = {
  prices = {},
  convergencePrices = {},
  grades = {},
  dust = 100,
  convergenceDust = 160,
  convergenceCoreCost = 0,
  reduceTierLoss = 50,
  reduceTierLossBase = 100,
  reduceTierLossChecked = false,
  chanceImprovedChecked = false,
  chanceImproved = 15,
  chanceBase = 50,
  improveCoreCosts = {},
  lossCoreCosts = {},
  fusionDustCosts = {},
  hasConvergence = false,
  isConvergence = false,
  title = 'Further Items Needed For Fusion',
  rawPrice = 0,
  formattedPrice = '???',
  items = {},
  convergenceItems = {},
  convergenceTargets = {},
  currentList = {},
  currentPage = 1,
  totalPages = 1,
  totalItems = 0,
  itemsPerPage = 12,
  classification = 0,
  requiredCopies = 1,
  selected = cloneValue(ForgeController.baseSelected),
  selectedTarget = cloneValue(ForgeController.baseSelected),
  canFusion = false
}

ForgeController.transfer = {
  prices = {},
  convergencePrices = {},
  grades = {},
  dust = 100,
  convergenceDust = 160,
  hasConvergence = false,
  isConvergence = false,
  title = 'Transfer Requirements',
  rawPrice = 0,
  formattedPrice = '???',
  necessaryExaltedCores = 0,
  items = { donors = {}, receivers = {} },
  convergenceItems = { donors = {}, receivers = {} },
  currentList = { donors = {}, receivers = {} },
  selected = cloneValue(ForgeController.baseSelected),
  selectedTarget = cloneValue(ForgeController.baseSelected),
  canTransfer = false
}

ForgeController.conversion = {
  necessaryDustToSliver = 60,
  dustToSilver = 3,
  sliverToCore = 50,
  disableDustConversion = true,
  disableSliverConversion = true,
  arrowEvents = {}
}

ForgeController.history = {
  currentPage = 1,
  lastPage = 1,
  showPreviousButton = false,
  showNextButton = false,
  list = {}
}

local function resetSelections()
  currentForgeTarget = nil
  ForgeController.rawPrice = 0
  ForgeController.formattedPrice = '???'
  ForgeController.waitingForResult = false
  ForgeController.fusion.selected = cloneValue(ForgeController.baseSelected)
  ForgeController.fusion.selectedTarget = cloneValue(ForgeController.baseSelected)
  ForgeController.fusion.convergenceTargets = {}
  ForgeController.fusion.convergenceCoreCost = 0
  ForgeController.fusion.canFusion = false
  ForgeController.fusion.title = ForgeController.fusion.isConvergence and
    'Convergence Tier Transfer Requirements' or 'Further Items Needed For Fusion'
  ForgeController.fusion.rawPrice = 0
  ForgeController.fusion.formattedPrice = '???'
  ForgeController.fusion.chanceImprovedChecked = false
  ForgeController.fusion.reduceTierLossChecked = false
  ForgeController.transfer.selected = cloneValue(ForgeController.baseSelected)
  ForgeController.transfer.selectedTarget = cloneValue(ForgeController.baseSelected)
  ForgeController.transfer.necessaryExaltedCores = 0
  ForgeController.transfer.canTransfer = false
  ForgeController.transfer.rawPrice = 0
  ForgeController.transfer.formattedPrice = '???'
end

function ForgeController:updateResourceBalances()
  local balances = self.serverBalances or {}
  self.currentDust = math.max(0, tonumber(balances.dust) or 0)
  self.currentSlivers = math.max(0, tonumber(balances.slivers) or 0)
  self.currentExaltedCores = math.max(0, tonumber(balances.cores) or 0)
  self.rawCurrentGold = math.max(0, tonumber(balances.gold) or 0)
  self.currentGold = comma_value(self.rawCurrentGold)
end

local function decorateItem(item, slot)
  item.id = tonumber(item.id) or 0
  item.clientId = tonumber(item.clientId) or item.id
  item.tier = math.max(0, tonumber(item.tier) or 0)
  item.count = math.max(0, tonumber(item.count) or 0)
  item.classification = math.max(0, tonumber(item.classification) or 0)
  item.key = item.key or string.format('%d_%d_%s', item.id, item.tier, tostring(slot or ''))
  item.slot = slot
  item.countLabel = string.format('%d / 1', item.count)
  if item.tier > 0 then
    item.clip = ItemsDatabase.getTierClip(item.tier)
  end
  return item
end

local function sortItems(list)
  table.sort(list, function(a, b)
    local aOwned = (tonumber(a.count) or 0) > 0
    local bOwned = (tonumber(b.count) or 0) > 0
    if aOwned ~= bOwned then
      return aOwned
    end
    if a.tier == b.tier then
      return a.id < b.id
    end
    return a.tier > b.tier
  end)
  return list
end

local function handleFusionItems(data)
  local list = {}
  for _, item in pairs(data or {}) do
    table.insert(list, decorateItem(item))
  end
  return sortItems(list)
end

local function handleConvergenceFusionItems(data)
  local list = {}
  for slot, slotItems in pairs(data or {}) do
    for _, item in pairs(slotItems or {}) do
      table.insert(list, decorateItem(item, slot))
    end
  end
  return sortItems(list)
end

local function handleConvergenceTargets(data)
  local list = {}
  for _, item in pairs(data or {}) do
    table.insert(list, decorateItem(item, item.slot))
  end
  return sortItems(list)
end

local function handleTransferItems(data)
  local list = { donors = {}, receivers = {} }
  for slot, groups in pairs(data or {}) do
    for groupName, items in pairs(groups or {}) do
      if list[groupName] then
        for _, item in pairs(items or {}) do
          table.insert(list[groupName], decorateItem(item, slot))
        end
      end
    end
  end
  sortItems(list.donors)
  sortItems(list.receivers)
  return list
end

function ForgeController:getPrice(prices, itemId, currentTier, isConvergence, isTransfer)
  local price = 0
  local tierIndex = (tonumber(currentTier) or 0) + 1

  if isConvergence then
    for tier, value in pairs(prices or {}) do
      local numericTier = tonumber(tier) or 0
      local matches = isTransfer and numericTier == tonumber(currentTier) or numericTier == tierIndex
      if matches then
        price = tonumber(value) or 0
        break
      end
    end
  else
    local classification = 1
    local item = Item.create(itemId, 1)
    if item and item.getClassification then
      classification = math.max(1, tonumber(item:getClassification()) or 1)
    end
    local classPrices = prices and (prices[classification] or prices[tostring(classification)]) or nil
    for tier, value in pairs(classPrices or {}) do
      local numericTier = tonumber(tier) or 0
      if numericTier == tierIndex or (isTransfer and numericTier == tonumber(currentTier)) then
        price = tonumber(value) or 0
        break
      end
    end
  end

  self.rawPrice = math.max(0, price)
  self.formattedPrice = self.rawPrice > 0 and comma_value(self.rawPrice) or 'Unavailable'
  return self.formattedPrice
end

local function fusionCoreCost()
  local fusion = ForgeController.fusion
  if fusion.isConvergence then
    return math.max(0, tonumber(fusion.convergenceCoreCost) or 0)
  end
  local targetTier = math.max(1, (tonumber(fusion.selected.tier) or 0) + 1)
  local count = 0
  if fusion.chanceImprovedChecked then count = count + coreCostFromTable(fusion.improveCoreCosts, targetTier, DEFAULT_IMPROVE_CORE_COSTS) end
  if fusion.reduceTierLossChecked then count = count + coreCostFromTable(fusion.lossCoreCosts, targetTier, DEFAULT_LOSS_CORE_COSTS) end
  return count
end

local function canUseFusionImprovements(fusion)
  if not fusion or fusion.isConvergence or fusion.selected.id <= 0 then return false end
  local tier = tonumber(fusion.selected.tier) or 0
  local maxTier = tonumber(fusion.selected.maxTier) or 10
  return tier < maxTier
end

local function resolveFusionPrice(fusion)
  if fusion.rawPrice and fusion.rawPrice > 0 then return fusion.rawPrice end
  if not fusion.selected or fusion.selected.id <= 0 then return 0 end
  local classification = tonumber(fusion.selected.classification) or 1
  local targetTier = (tonumber(fusion.selected.tier) or 0) + 1
  local classPrices = fusion.prices[classification] or fusion.prices[tostring(classification)] or {}
  return tonumber(classPrices[targetTier] or classPrices[tostring(targetTier)] or 0) or 0
end

function ForgeController:revalidate()
  local fusion = self.fusion
  local fusionDust = fusion.isConvergence and fusion.convergenceDust or fusion.dust
  local fusionItemsReady = fusion.selected.id > 0 and fusion.selectedTarget.id > 0
  fusionItemsReady = fusionItemsReady and (fusion.isConvergence and fusion.selected.tier > 0 or
    fusion.selected.tier < (tonumber(fusion.selected.maxTier) or 10))
  if fusion.selected.isDropped then
    fusionItemsReady = fusionItemsReady and currentForgeTarget ~= nil and
      (tonumber(fusion.selected.key) or 0) > 0
    local requiredCopies = tonumber(fusion.selected.requiredCopies) or 1
    local availableCopies = tonumber(fusion.selected.availableCopies) or 0
    fusionItemsReady = fusionItemsReady and availableCopies >= requiredCopies
  elseif not fusion.isConvergence then
    local requiredCopies = tonumber(fusion.selected.requiredCopies) or 1
    fusionItemsReady = fusionItemsReady and (tonumber(fusion.selected.count) or 0) >= requiredCopies
  end
  fusion.canFusion = fusionItemsReady and fusion.rawPrice > 0 and
    self.rawCurrentGold >= fusion.rawPrice and self.currentDust >= fusionDust and
    self.currentExaltedCores >= fusionCoreCost() and not self.waitingForResult

  local transfer = self.transfer
  local transferDust = transfer.isConvergence and transfer.convergenceDust or transfer.dust
  local transferItemsReady = transfer.selected.id > 0 and transfer.selectedTarget.id > 0 and
    transfer.selected.tier >= 2 and transfer.selectedTarget.tier == 0 and
    transfer.selected.classification == transfer.selectedTarget.classification and
    (tonumber(transfer.selected.key) or 0) > 0 and
    (tonumber(transfer.selectedTarget.key) or 0) > 0
  transfer.canTransfer = transferItemsReady and
    transfer.rawPrice > 0 and self.rawCurrentGold >= transfer.rawPrice and
    self.currentDust >= transferDust and
    self.currentExaltedCores >= (tonumber(transfer.necessaryExaltedCores) or 0) and
    not self.waitingForResult
end

local function createItemRow(parent, item, selected, callback, compact)
  if not parent then return nil end
  local row = g_ui.createWidget('ForgeItemRow', parent)
  row:setPhantom(false)
  row:setFocusable(true)
  row.itemData = item
  if compact then
    row:setWidth(88)
    row:setHeight(46)
  elseif parent:getWidth() > 0 then
    row:setWidth(math.max(120, parent:getWidth() - 2))
  end

  local itemWidget = row:getChildById('item')
  if itemWidget then
    itemWidget:setItemId(item.clientId)
    paintForgeTierBadge(itemWidget, item.tier)
  end
  local nameLabel = row:getChildById('name')
  if nameLabel then
    nameLabel:setText(compact and ('T' .. item.tier) or getItemName(item.clientId))
    if compact then nameLabel:setVisible(false) end
  end
  local details = row:getChildById('details')
  if details then
    details:setText(compact and '' or string.format('Tier %d', item.tier))
    if compact then details:setVisible(false) end
  end
  local count = row:getChildById('count')
  if count then
    count:setText(compact and ('T' .. item.tier) or ('x' .. item.count))
    if compact then count:setWidth(28) end
  end

  local isSelected = selected and tostring(selected.key or '') == tostring(item.key or '')
  if isSelected then
    row:setBackgroundColor('#554b3f')
    row:setBorderColor('#d8c27a')
    if itemWidget then itemWidget:setBorderColor('#f0c96a') end
    if count then count:setColor('#f0c96a') end
  end

  local function selectRow()
    if (tonumber(item.count) or 0) <= 0 then
      return true
    end
    callback(item)
    return true
  end

  row.onMouseRelease = function(_, _, mouseButton)
    if mouseButton == MouseLeftButton then
      return selectRow()
    end
    return false
  end
  for _, child in ipairs(row:recursiveGetChildren()) do
    child:setPhantom(true)
  end

  if (tonumber(item.count) or 0) <= 0 then
    row:setOpacity(0.4)
  end
  row:setTooltip(string.format('%s\nTier %d - Owned: %d', getItemName(item.clientId), item.tier, item.count))
  return row
end

function ForgeController:renderBalances()
  local values = {
    goldBox = { title = 'Gold', value = self.currentGold },
    dustBox = { title = 'Forge Dust', value = self.currentDust },
    sliverBox = { title = 'Slivers', value = self.currentSlivers },
    coreBox = { title = 'Exalted Cores', value = self.currentExaltedCores }
  }
  for id, data in pairs(values) do
    local box = widget(id)
    if box then
      local title = box:getChildById('title')
      local value = box:getChildById('value')
      if title then title:setText(data.title) end
      if value then value:setText(tostring(data.value)) end
    end
  end
  local currencyIds = self.currencyClientIds or {}
  local currencyBoxes = { goldBox = 3031, dustBox = currencyIds.dust, sliverBox = currencyIds.sliver, coreBox = currencyIds.core }
  for boxId, clientId in pairs(currencyBoxes) do
    local box = widget(boxId)
    local icon = box and box:getChildById('icon') or nil
    if icon then icon:setItemId(tonumber(clientId) or 0) end
  end
end

function ForgeController:renderFusion()
  local fusion = self.fusion
  setVisible('fusionClassificationFilter', not fusion.isConvergence)
  setVisible('fusionItemsPagination', not fusion.isConvergence)
  local list = widget('fusionItemsList')
  if list then
    list:destroyChildren()
    for index, item in ipairs(fusion.currentList or {}) do
      if not fusion.isConvergence and index > fusion.itemsPerPage then break end
      createItemRow(list, item, fusion.selected, function(selected)
        ForgeController:selectFusionItem(selected)
      end)
    end
  end
  local listScroll = widget('fusionItemsScroll')
  if listScroll then
    listScroll:setValue(listScroll:getMinimum())
  end
  setText('fusionItemsPageLabel', string.format('Page %d / %d', fusion.currentPage, fusion.totalPages))
  setEnabled('fusionItemsPreviousPage', fusion.currentPage > 1)
  setEnabled('fusionItemsNextPage', fusion.currentPage < fusion.totalPages)

  local targets = widget('fusionTargetList')
  if targets then
    targets:destroyChildren()
    if fusion.isConvergence and fusion.selected.id > 0 then
      for _, item in ipairs(fusion.convergenceTargets or {}) do
        if item.tier == 0 and item.key ~= fusion.selected.key then
          createItemRow(targets, item, fusion.selectedTarget, function(selected)
            ForgeController:selectTarget(selected, false)
          end, true)
        end
      end
    end
  end

  setText('fusionRequirementsTitle', fusion.title)
  setItem('fusionSourceItem', fusion.selected.clientId)
  setItem('fusionTargetItem', fusion.selectedTarget.clientId)
  paintForgeTierBadge(widget('fusionSourceItem'), fusion.selected.tier)
  paintForgeTierBadge(widget('fusionTargetItem'), fusion.selectedTarget.targetTier or fusion.selectedTarget.tier)
  setText('fusionSourceTier', fusion.selected.id > 0 and string.format('Tier %d', fusion.selected.tier) or 'Select an item')
  setText('fusionTargetTier', fusion.selectedTarget.id > 0 and string.format('Tier %d', fusion.selectedTarget.targetTier or (fusion.selectedTarget.tier + 1)) or 'No target')
  setText('fusionTargetHelp', fusion.isConvergence and
    'Select any Tier 0 Classification 4 item to receive the donor tier' or '')
  setVisible('fusionTargetHelp', fusion.isConvergence)
  setVisible('fusionTargetListCard', fusion.isConvergence)
  local costsCard = widget('fusionCostsCard')
  if costsCard then
    costsCard:breakAnchors()
    costsCard:addAnchor(AnchorTop,
      fusion.isConvergence and 'fusionTargetListCard' or 'fusionTargetHelp', AnchorBottom)
    costsCard:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    costsCard:addAnchor(AnchorRight, 'parent', AnchorRight)
    costsCard:setHeight(fusion.isConvergence and 70 or 150)
  end
  local resolvedPrice = resolveFusionPrice(fusion)
  if resolvedPrice <= 0 then resolvedPrice = tonumber(fusion.rawPrice) or 0 end
  if resolvedPrice > 0 then
    fusion.rawPrice = resolvedPrice
    fusion.formattedPrice = comma_value(resolvedPrice)
  end
  local goldText = fusion.selected.id > 0 and (resolvedPrice > 0 and comma_value(resolvedPrice) or '0') or '0'
  setText('fusionGoldCost', goldText)
  local dustCost = fusion.isConvergence and fusion.convergenceDust or math.max(0, tonumber(fusion.dust) or 0)
  setText('fusionDustCost', tostring(dustCost))
  setItem('fusionGoldIcon', 3031)
  setItem('fusionDustIcon', (self.currencyClientIds or {}).dust)
  setItem('fusionCoreIcon', (self.currencyClientIds or {}).core)
  setColor('fusionGoldCost', fusion.selected.id > 0 and resolvedPrice > 0 and self.rawCurrentGold >= resolvedPrice and '#b8d6b0' or '#d99b9b')
  setColor('fusionDustCost', fusion.selected.id > 0 and self.currentDust >= dustCost and '#b8d6b0' or '#d99b9b')
  local targetTier = math.max(1, (tonumber(fusion.selected.tier) or 0) + 1)
  local improveCores = coreCostFromTable(fusion.improveCoreCosts, targetTier, DEFAULT_IMPROVE_CORE_COSTS)
  local lossCores = coreCostFromTable(fusion.lossCoreCosts, targetTier, DEFAULT_LOSS_CORE_COSTS)
  local requiredCores = fusion.isConvergence and
    math.max(0, tonumber(fusion.convergenceCoreCost) or 0) or
    ((fusion.chanceImprovedChecked and improveCores or 0) +
      (fusion.reduceTierLossChecked and lossCores or 0))
  local displayedCoreRequirement = requiredCores
  setText('fusionCoreCost', tostring(displayedCoreRequirement))
  setColor('fusionCoreCost', self.currentExaltedCores >= displayedCoreRequirement and '#b8d6b0' or '#d99b9b')
  setText('fusionChanceButton', string.format('Improve Chance: %d%% (%s)',
    fusion.chanceBase + (fusion.chanceImprovedChecked and fusion.chanceImproved or 0),
    fusion.chanceImprovedChecked and 'On' or 'Off'))
  setText('fusionLossButton', string.format('Reduce Tier Loss: %s',
    fusion.reduceTierLossChecked and 'On' or 'Off'))
  setEnabled('fusionChanceButton', true)
  setEnabled('fusionLossButton', true)
  setVisible('fusionChanceButton', not fusion.isConvergence)
  setVisible('fusionLossButton', not fusion.isConvergence)
  local requiredCopies = fusion.isConvergence and 1 or (tonumber(fusion.selected.requiredCopies) or 1)
  local availableCopies = fusion.isConvergence and
    (fusion.selectedTarget.id > 0 and 1 or 0) or
    (tonumber(fusion.selected.availableCopies) or tonumber(fusion.selected.count) or 0)
  local costItem = fusion.isConvergence and fusion.selectedTarget or fusion.selected
  local requiredName = costItem.id > 0 and getItemName(costItem.clientId) or 'Receiver item'
  local requiredTier = costItem.id > 0 and costItem.tier or 0
  setText('fusionItemCost', string.format('%d x T%d', requiredCopies, requiredTier))
  local itemCostWidget = widget('fusionItemCost')
  if itemCostWidget then itemCostWidget:setTooltip(requiredName) end
  setColor('fusionItemCost', availableCopies >= requiredCopies and '#b8d6b0' or '#d99b9b')
  setItem('fusionItemIcon', costItem.clientId)
  setText('fusionActionButton', fusion.isConvergence and 'Start Convergence' or 'Start Fusion')
  setEnabled('fusionActionButton', fusion.canFusion)

  local status
  if self.waitingForResult then
    status = 'Waiting for the forge...'
  elseif fusion.selected.id <= 0 then
    status = fusion.isConvergence and
      'Select or drag a tiered Classification 4 donor item.' or
      'Drag any equipable item from your inventory or backpack into the left slot.'
  elseif fusion.selectedTarget.id <= 0 then
    status = fusion.isConvergence and
      'Select a Tier 0 Classification 4 receiver.' or 'Select an item to upgrade.'
  elseif not fusion.canFusion then
    status = 'One or more required resources are missing.'
  else
    status = fusion.isConvergence and
      string.format('Guaranteed transfer of Tier %d to the selected receiver.', fusion.selected.tier) or
      fusion.selected.isDropped and
      string.format('Ready to upgrade forge tier %d to %d.', fusion.selected.tier, fusion.selected.targetTier) or
      string.format('Ready. Success chance: %d%%.', fusion.chanceBase +
        (fusion.chanceImprovedChecked and fusion.chanceImproved or 0))
  end
  setText('fusionStatusLabel', status)
end

function ForgeController:changeFusionPage(direction)
  local fusion = self.fusion
  local nextPage = math.max(1, math.min(fusion.totalPages,
    fusion.currentPage + (tonumber(direction) or 0)))
  if nextPage == fusion.currentPage then return end
  self.description = string.format('Loading forgeable items page %d...', nextPage)
  self:refresh()
  sendForgeRequest('open', { page = nextPage, classification = fusion.classification or 0 })
end

function ForgeController:changeFusionClassification(index)
  local classification = math.max(0, math.min(4, (tonumber(index) or 1) - 1))
  self.fusion.classification = classification
  self.fusion.currentPage = 1
  self.description = 'Loading classification ' .. (classification == 0 and 'all items' or tostring(classification)) .. '...'
  self:refresh()
  sendForgeRequest('open', { page = 1, classification = classification })
end

function ForgeController:renderTransfer()
  local transfer = self.transfer
  local donors = widget('transferDonorList')
  if donors then
    donors:destroyChildren()
    for _, item in ipairs(transfer.currentList.donors or {}) do
      createItemRow(donors, item, transfer.selected, function(selected)
        ForgeController:selectTransferItem(selected)
      end)
    end
  end

  local receivers = widget('transferReceiverList')
  if receivers then
    receivers:destroyChildren()
    for _, item in ipairs(transfer.currentList.receivers or {}) do
      createItemRow(receivers, item, transfer.selectedTarget, function(selected)
        ForgeController:selectTarget(selected, true)
      end, true)
    end
  end

  setText('transferRequirementsTitle', transfer.title)
  setItem('transferSourceItem', transfer.selected.clientId)
  setItem('transferTargetItem', transfer.selectedTarget.clientId)
  paintForgeTierBadge(widget('transferSourceItem'), transfer.selected.tier)
  paintForgeTierBadge(widget('transferTargetItem'), transfer.selectedTarget.targetTier or transfer.selectedTarget.tier)
  setText('transferSourceTier', transfer.selected.id > 0 and string.format('Donor Tier %d', transfer.selected.tier) or 'Select donor')
  setText('transferTargetTier', transfer.selectedTarget.id > 0 and string.format('Result Tier %d', transfer.selectedTarget.targetTier or 0) or 'Select target')
  local transferPrice = math.max(0, tonumber(transfer.rawPrice) or 0)
  setText('transferGoldCost', transfer.selected.id > 0 and
    (transferPrice > 0 and comma_value(transferPrice) or '0') or '0')
  local dustCost = transfer.isConvergence and transfer.convergenceDust or transfer.dust
  local coreCost = math.max(0, tonumber(transfer.necessaryExaltedCores) or 0)
  setText('transferDustCost', tostring(dustCost))
  setText('transferCoreCost', transfer.selected.id > 0 and tostring(coreCost) or '0')
  setItem('transferGoldIcon', 3031)
  setItem('transferDustIcon', (self.currencyClientIds or {}).dust)
  setItem('transferCoreIcon', (self.currencyClientIds or {}).core)
  setColor('transferGoldCost', transfer.selected.id > 0 and transferPrice > 0 and
    self.rawCurrentGold >= transferPrice and '#b8d6b0' or '#d99b9b')
  setColor('transferDustCost', transfer.selected.id > 0 and self.currentDust >= dustCost and '#b8d6b0' or '#d99b9b')
  setColor('transferCoreCost', transfer.selected.id > 0 and self.currentExaltedCores >= coreCost and '#b8d6b0' or '#d99b9b')
  setEnabled('transferActionButton', transfer.canTransfer)

  local status
  if self.waitingForResult then
    status = 'Waiting for the forge...'
  elseif transfer.selected.id <= 0 then
    status = 'Select the donor item whose tier will be transferred.'
  elseif transfer.selectedTarget.id <= 0 then
    status = 'Select a receiving item.'
  elseif not transfer.canTransfer then
    status = 'One or more required resources are missing.'
  else
    status = 'Ready. The donor item will be consumed.'
  end
  setText('transferStatusLabel', status)
end

function ForgeController.conversion:handleButtons()
  local controller = ForgeController
  self.disableDustConversion = controller.currentDust < self.necessaryDustToSliver
  self.disableSliverConversion = controller.currentSlivers < self.sliverToCore
end

function ForgeController:renderConversion()
  self.conversion:handleButtons()
  local conversion = self.conversion
  setText('dustConversionCost', string.format('Cost: %d Forge Dust', conversion.necessaryDustToSliver))
  setText('dustConversionResult', string.format('Receive: %d Slivers', conversion.dustToSilver))
  setText('sliverConversionCost', string.format('Cost: %d Slivers', conversion.sliverToCore))
  setText('sliverConversionResult', 'Receive: 1 Exalted Core')
  setColor('dustConversionCost', self.currentDust >= conversion.necessaryDustToSliver and '#b8d6b0' or '#d99b9b')
  setColor('sliverConversionCost', self.currentSlivers >= conversion.sliverToCore and '#b8d6b0' or '#d99b9b')
  setEnabled('dustConversionButton', not conversion.disableDustConversion)
  setEnabled('sliverConversionButton', not conversion.disableSliverConversion)
  local currencyIds = self.currencyClientIds or {}
  setItem('dustInputItem', currencyIds.dust)
  setItem('dustOutputItem', currencyIds.sliver)
  setItem('sliverInputItem', currencyIds.sliver)
  setItem('sliverOutputItem', currencyIds.core)
end

function ForgeController:renderHistory()
  local list = widget('historyList')
  if list then
    list:destroyChildren()
    for _, entry in ipairs(self.history.list or {}) do
      local row = g_ui.createWidget('ForgeHistoryRow', list)
      row:getChildById('date'):setText(tostring(entry.createdAt or ''))
      row:getChildById('action'):setText(tostring(entry.actionType or ''))
      local details = row:getChildById('details')
      details:setTextWrap(true)
      details:setText(tostring(entry.description or ''))
      row:setTooltip(tostring(entry.description or ''))
    end
  end
  setText('historyPageLabel', string.format('Page %d / %d', self.history.currentPage, self.history.lastPage))
  setEnabled('historyPreviousButton', self.history.showPreviousButton)
  setEnabled('historyNextButton', self.history.showNextButton)
end

function ForgeController:refresh()
  if not self.ui or self.ui:isDestroyed() then return end
  self:updateResourceBalances()
  self:revalidate()
  self:renderBalances()
  self:renderFusion()
  self:renderTransfer()
  self:renderConversion()
  self:renderHistory()
  setText('footerStatus', self.description)
end

function ForgeController:selectFusionItem(item)
  local data = self.fusion
  currentForgeTarget = nil
  if data.isConvergence then
    data.selected = cloneValue(item)
    data.selectedTarget = cloneValue(self.baseSelected)
    data.convergenceTargets = {}
    data.convergenceCoreCost = 0
    self.description = string.format('Checking %s as the Convergence donor...', getItemName(item.clientId))
    self:refresh()
    sendForgeRequest('select_convergence', { sourceKey = tostring(item.key or '') })
    return
  end
  data.selected = cloneValue(item)
  data.selected.requiredCopies = data.selected.tier == 0 and 1 or 2
  data.selected.targetTier = math.min(tonumber(data.selected.maxTier) or 10, data.selected.tier + 1)
  local targetTier = math.max(1, (tonumber(data.selected.targetTier) or 1))
  data.dust = tonumber(data.fusionDustCosts[targetTier] or data.fusionDustCosts[tostring(targetTier)]) or 150
  data.selectedTarget = cloneValue(self.baseSelected)
  if item.count >= data.selected.requiredCopies then
    data.selectedTarget = cloneValue(item)
    data.selectedTarget.targetTier = data.selected.targetTier
  end
  local prices = data.isConvergence and data.convergencePrices or data.prices
  self:getPrice(prices, item.clientId, item.tier, data.isConvergence, false)
  data.rawPrice = self.rawPrice
  data.formattedPrice = self.formattedPrice
  self.description = string.format('Selected %s for fusion.', getItemName(item.clientId))
  self:refresh()
end

local function buildForgeTargetReference(item)
  if not item then return nil end
  local ok, position = pcall(function() return item:getPosition() end)
  if not ok then return nil end
  if not position then return nil end
  local okStack, stackpos = pcall(function() return item:getStackPos() end)
  if not okStack then return nil end
  return {
    position = {
      x = position.x,
      y = position.y,
      z = position.z,
      stackpos = stackpos
    }
  }
end

local function isForgeItemPosition(position)
  if not position or tonumber(position.x) ~= 65535 then return false end

  local slot = tonumber(position.y) or 0
  local isContainerSlot = bit.band(slot, 0x40) ~= 0
  local isInventorySlot = slot >= (InventorySlotFirst or 1) and slot <= (InventorySlotLast or 16)
  return isContainerSlot or isInventorySlot
end

function ForgeController:onForgeItemDrop(targetWidget, droppedWidget)
  destroyForgeTooltip()
  if not droppedWidget or type(droppedWidget.getItem) ~= 'function' then return false end
  local item = droppedWidget:getItem()
  if not item then return false end
  local position = item:getPosition()
  if not isForgeItemPosition(position) then
    currentForgeTarget = nil
    self.description = 'Only an item from your inventory or backpack can be forged.'
    self:refresh()
    return false
  end

  local targetReference = buildForgeTargetReference(item)
  if not targetReference then
    self.description = 'The selected equipment is no longer available.'
    self:refresh()
    return false
  end
  currentForgeTarget = targetReference
  self.description = 'Checking the dropped equipment...'
  self:refresh()
  sendForgeRequest('select_item', {
    target = targetReference,
    convergence = self.fusion.isConvergence
  })
  return true
end

function ForgeController:selectTransferItem(item)
  local data = self.transfer
  data.selected = cloneValue(item)
  data.selectedTarget = cloneValue(self.baseSelected)
  data.necessaryExaltedCores = 0
  local targetTier = math.max(0, item.tier - 1)
  for _, grade in pairs(data.grades or {}) do
    if tonumber(grade.tier) == targetTier then
      data.necessaryExaltedCores = math.max(0, tonumber(grade.exaltedCores) or 0)
      break
    end
  end
  data.currentList.receivers = {}
  for _, receiver in ipairs(data.items.receivers or {}) do
    if receiver.tier == 0 and receiver.classification == item.classification and
        tostring(receiver.key or '') ~= tostring(item.key or '') then
      table.insert(data.currentList.receivers, receiver)
    end
  end
  local classPrices = data.prices[item.classification] or
    data.prices[tostring(item.classification)] or {}
  -- Price tables are normalized from protocol tier ids to one-based keys.
  local priceKey = targetTier + 1
  data.rawPrice = math.max(0, tonumber(classPrices[priceKey] or
    classPrices[tostring(priceKey)]) or 0)
  data.formattedPrice = data.rawPrice > 0 and comma_value(data.rawPrice) or 'Unavailable'
  self.rawPrice = data.rawPrice
  self.formattedPrice = data.formattedPrice
  self.description = string.format('Selected %s as the donor.', getItemName(item.clientId))
  self:refresh()
end

function ForgeController:selectTarget(item, isTransfer)
  local data = isTransfer and self.transfer or self.fusion
  data.selectedTarget = cloneValue(item)
  data.selectedTarget.targetTier = isTransfer and
    (data.isConvergence and data.selected.tier or math.max(0, data.selected.tier - 1)) or
    (data.isConvergence and data.selected.tier or (data.selected.tier + 1))
  self.description = string.format('Selected %s as the target.', getItemName(item.clientId))
  self:refresh()
end

function ForgeController:onConvergenceChanged(isTransfer, checked)
  if suppressUiEvents then return end
  local data = isTransfer and self.transfer or self.fusion
  checked = checked == true
  if data.isConvergence == checked then return end
  data.isConvergence = checked
  data.selected = cloneValue(self.baseSelected)
  data.selectedTarget = cloneValue(self.baseSelected)
  if not isTransfer then
    data.convergenceTargets = {}
    data.convergenceCoreCost = 0
  end
  self.rawPrice = 0
  self.formattedPrice = '???'
  data.rawPrice = 0
  data.formattedPrice = '???'
  if isTransfer then
    data.title = checked and 'Convergence Transfer Requirements' or 'Transfer Requirements'
    local source = checked and data.convergenceItems or data.items
    data.currentList = { donors = cloneValue(source.donors or {}), receivers = cloneValue(source.receivers or {}) }
  else
    data.title = checked and 'Convergence Tier Transfer Requirements' or 'Further Items Needed For Fusion'
    replaceTableContents(data.currentList, checked and data.convergenceItems or data.items)
  end
  self.description = checked and 'Convergence mode enabled.' or 'Standard forge mode enabled.'
  self:refresh()
end

function ForgeController:toggleConvergence(isTransfer)
  local data = isTransfer and self.transfer or self.fusion
  self:onConvergenceChanged(isTransfer, not data.isConvergence)
end

function ForgeController:toggleImprovement(kind)
  local fusion = self.fusion
  if fusion.isConvergence then return end
  if kind == 'improve-chance' then
    local nextValue = not fusion.chanceImprovedChecked
    local targetTier = math.max(1, (tonumber(fusion.selected.tier) or 0) + 1)
    local cost = coreCostFromTable(fusion.improveCoreCosts, targetTier, DEFAULT_IMPROVE_CORE_COSTS)
    if nextValue and not canUseFusionImprovements(fusion) then return end
    if nextValue and self.currentExaltedCores < fusionCoreCost() + cost then
      self.description = 'You do not have enough forge cores.'
      self:refresh()
      return
    end
    fusion.chanceImprovedChecked = nextValue
  elseif kind == 'reduce-loss' then
    local nextValue = not fusion.reduceTierLossChecked
    local targetTier = math.max(1, (tonumber(fusion.selected.tier) or 0) + 1)
    local cost = coreCostFromTable(fusion.lossCoreCosts, targetTier, DEFAULT_LOSS_CORE_COSTS)
    if nextValue and not canUseFusionImprovements(fusion) then return end
    if nextValue and self.currentExaltedCores < fusionCoreCost() + cost then
      self.description = 'You do not have enough forge cores.'
      self:refresh()
      return
    end
    fusion.reduceTierLossChecked = nextValue
  end
  self:refresh()
end

ForgeController.fusion.handleSelect = function(item)
  ForgeController:selectFusionItem(item)
end

ForgeController.transfer.handleSelect = function(item)
  ForgeController:selectTransferItem(item)
end

ForgeController.fusion.exaltedCoreImprovements = function(kind)
  ForgeController:toggleImprovement(kind)
end

function ForgeController:handleSelect(data, item, isTransfer)
  if isTransfer then self:selectTransferItem(item) else self:selectFusionItem(item) end
end

function ForgeController:handleSelectTarget(item, isTransfer)
  self:selectTarget(item, isTransfer)
end

function ForgeController:toggleFusionMenu()
  self.currentTab = 'fusion'
  local tabBar = widget('forgeTabBar')
  if tabBar and self.tabs and self.tabs.fusion then tabBar:selectTab(self.tabs.fusion) end
end

function ForgeController:toggleTransferMenu()
  self.currentTab = 'transfer'
  local tabBar = widget('forgeTabBar')
  if tabBar and self.tabs and self.tabs.transfer then tabBar:selectTab(self.tabs.transfer) end
end

function ForgeController:toggleConversionMenu()
  self.currentTab = 'conversion'
  local tabBar = widget('forgeTabBar')
  if tabBar and self.tabs and self.tabs.conversion then tabBar:selectTab(self.tabs.conversion) end
end

function ForgeController:toggleHistoryMenu()
  self.currentTab = 'history'
  local tabBar = widget('forgeTabBar')
  if tabBar and self.tabs and self.tabs.history then tabBar:selectTab(self.tabs.history) end
  sendForgeRequest('history', { page = 1 })
end

function ForgeController:handleDescription(currentType)
  Helpers.handleDescription(self, currentType)
  setText('footerStatus', self.description)
end

local function animateConversionArrow(conversionType)
  local arrowId = conversionType == 2 and 'dustConversionArrow' or
    conversionType == 3 and 'sliverConversionArrow' or nil
  if not arrowId then return end

  local conversion = ForgeController.conversion
  if conversion.arrowEvents[arrowId] then
    removeEvent(conversion.arrowEvents[arrowId])
    conversion.arrowEvents[arrowId] = nil
  end

  local arrow = widget(arrowId)
  if not arrow then return end

  arrow:setImageSource(Helpers.filledDownArrow)
  conversion.arrowEvents[arrowId] = scheduleEvent(function()
    conversion.arrowEvents[arrowId] = nil
    local currentArrow = widget(arrowId)
    if currentArrow then
      currentArrow:setImageSource(Helpers.downArrow)
    end
  end, 350)
end

local function resetConversionArrows()
  local conversion = ForgeController.conversion
  for arrowId, event in pairs(conversion.arrowEvents or {}) do
    removeEvent(event)
    conversion.arrowEvents[arrowId] = nil
  end

  for _, arrowId in ipairs({ 'dustConversionArrow', 'sliverConversionArrow' }) do
    local arrow = widget(arrowId)
    if arrow then
      arrow:setImageSource(Helpers.downArrow)
    end
  end
end

function ForgeController.conversion.toggle(conversionType)
  local conversion = ForgeController.conversion
  conversion:handleButtons()
  if conversionType == 2 and conversion.disableDustConversion then return end
  if conversionType == 3 and conversion.disableSliverConversion then return end
  if conversionType ~= 2 and conversionType ~= 3 then return end
  animateConversionArrow(conversionType)
  ForgeController.description = 'Processing resource conversion...'
  ForgeController:refresh()
  sendForgeRequest('convert', { type = conversionType })
end

local function cancelResultTimeout()
  if ForgeController.resultTimeout then
    removeEvent(ForgeController.resultTimeout)
    ForgeController.resultTimeout = nil
  end
end

function ForgeController:forgeAction(isTransfer)
  self:revalidate()
  local data = isTransfer and self.transfer or self.fusion
  local allowed = isTransfer and data.canTransfer or data.canFusion
  if not allowed then
    self.description = 'The forge requirements are not complete.'
    self:refresh()
    return
  end

  self.waitingForResult = true
  self.description = 'The forge is processing your request...'
  self:refresh()
  cancelResultTimeout()
  self.resultTimeout = scheduleEvent(function()
    ForgeController.resultTimeout = nil
    if ForgeController.waitingForResult then
      ForgeController.waitingForResult = false
      ForgeController.description = 'The forge did not answer in time. Refreshing state...'
      ForgeController:refresh()
      sendForgeRequest('open')
    end
  end, 6000)

  sendForgeRequest('forge', {
    type = isTransfer and 1 or 0,
    convergence = data.isConvergence,
    itemId = data.selected.id,
    tier = data.selected.tier,
    targetItemId = data.selectedTarget.id,
    targetTier = data.selectedTarget.tier,
    chanceImproved = not isTransfer and data.chanceImprovedChecked or false,
    reduceTierLoss = not isTransfer and data.reduceTierLossChecked or false,
    target = not isTransfer and currentForgeTarget or nil,
    targetKey = not isTransfer and tostring(data.selected.key or '') or nil,
    convergenceTargetKey = not isTransfer and data.isConvergence and
      tostring(data.selectedTarget.key or '') or nil,
    transferDonorKey = isTransfer and tostring(data.selected.key or '') or nil,
    transferTargetKey = isTransfer and tostring(data.selectedTarget.key or '') or nil
  })
end

local function destroyResultWindow()
  if resultWindow then
    resultWindow:destroy()
    resultWindow = nil
  end
end

function ForgeController:renderResult()
  if not resultWindow then return end
  local result = self.result or {}
  setText('resultTitle', result.title or 'Forge Result', resultWindow)
  setItem('resultLeftItem', result.leftItemId, resultWindow)
  setItem('resultRightItem', result.rightItemId, resultWindow)
  paintForgeTierBadge(widget('resultLeftItem', resultWindow), result.leftTier)
  paintForgeTierBadge(widget('resultRightItem', resultWindow), result.rightTier)
  setText('resultText', result.label and ((result.label or '') .. (result.labelResult or '')) or '', resultWindow)
  setColor('resultText', result.color or '#cfcfcf', resultWindow)
  setText('resultButton', result.buttonLabel or 'Close', resultWindow)
  for index = 1, 3 do
    local arrow = widget('resultArrow' .. index, resultWindow)
    local arrowData = result.arrows and result.arrows[index]
    if arrow and arrowData then arrow:setImageSource(arrowData.arrow) end
  end
end

function ForgeController:resultSystemEvent()
  if not resultWindow then return end
  local result = self.result
  result.eventCount = (result.eventCount or 0) + 1
  if result.eventCount <= 3 then
    result.arrows[result.eventCount] = { arrow = Helpers.filledRightArrow }
    self:renderResult()
    self.resultEvent = scheduleEvent(function() ForgeController:resultSystemEvent() end, 250)
    return
  end

  if result.success then
    result.label = result.actionType == 1 and 'Your transfer attempt was ' or 'Your fusion attempt was '
    result.labelResult = 'successful.'
    if result.bonusLabel and result.bonusLabel ~= '' then
      result.labelResult = result.labelResult .. '\n' .. result.bonusLabel
    end
    result.color = Helpers.green
  else
    result.label = result.actionType == 1 and 'Your transfer attempt ' or 'Your fusion attempt '
    result.labelResult = 'failed.'
    if result.bonusLabel and result.bonusLabel ~= '' then
      result.labelResult = result.labelResult .. '\n' .. result.bonusLabel
    end
    result.color = Helpers.red
  end
  result.buttonLabel = (tonumber(result.bonus) or 0) > 0 and 'Next' or 'Close'
  self:renderResult()
end

function forgeResultData(rawData)
  cancelResultTimeout()
  ForgeController.waitingForResult = false
  ForgeController.result = cloneValue(Helpers.baseResult)
  for key, value in pairs(rawData or {}) do
    ForgeController.result[key] = value
  end
  ForgeController.result.actionType = tonumber(rawData and rawData.actionType) or
    (ForgeController.currentTab == 'transfer' and 1 or 0)
  ForgeController.result.title = ForgeController.result.title or
    (ForgeController.result.actionType == 1 and 'Transfer Result' or 'Fusion Result')
  ForgeController.result.label = 'Forging...'
  ForgeController.result.labelResult = ''
  ForgeController.result.color = '#cfcfcf'
  ForgeController.result.buttonLabel = 'Close'
  ForgeController.result.eventCount = 0
  ForgeController.result.arrows = {
    { arrow = Helpers.rightArrow },
    { arrow = Helpers.rightArrow },
    { arrow = Helpers.rightArrow }
  }

  destroyResultWindow()
  resultWindow = g_ui.createWidget('ForgeResultWindow', rootWidget)
  resultWindow.onEscape = function() ForgeController:closeResult() end
  local resultButton = widget('resultButton', resultWindow)
  if resultButton then
    resultButton.onClick = function() ForgeController:onResultButton() end
  end
  local resultLeftItem = widget('resultLeftItem', resultWindow)
  if resultLeftItem then
    resultLeftItem.onHoverChange = function(itemWidget, hovered)
      showForgeItemTooltip(itemWidget, hovered, nil)
    end
  end
  local resultRightItem = widget('resultRightItem', resultWindow)
  if resultRightItem then
    resultRightItem.onHoverChange = function(itemWidget, hovered)
      showForgeItemTooltip(itemWidget, hovered, nil)
    end
  end
  resultWindow:show()
  resultWindow:raise()
  resultWindow:focus()
  ForgeController:renderResult()
  ForgeController:resultSystemEvent()
  if ForgeController.result.actionType == 1 then
    ForgeController.transfer.selected = cloneValue(ForgeController.baseSelected)
    ForgeController.transfer.selectedTarget = cloneValue(ForgeController.baseSelected)
    ForgeController.transfer.currentList.receivers = {}
    ForgeController.transfer.rawPrice = 0
    ForgeController.transfer.formattedPrice = 'Unavailable'
  else
    currentForgeTarget = nil
    ForgeController.fusion.selected = cloneValue(ForgeController.baseSelected)
    ForgeController.fusion.selectedTarget = cloneValue(ForgeController.baseSelected)
    ForgeController.fusion.convergenceTargets = {}
    ForgeController.fusion.rawPrice = 0
    ForgeController.fusion.formattedPrice = 'Unavailable'
  end
  ForgeController:refresh()
  scheduleEvent(requestForgeTierRefresh, 50)
end

function ForgeController:onResultButton()
  local result = self.result or {}
  if (tonumber(result.bonus) or 0) > 0 and not result.showingBonus then
    result.showingBonus = true
    result.buttonLabel = 'Close'
    result.leftItemId = result.bonusItem or result.leftItemId
    result.rightItemId = 0
    result.label = result.bonusLabel or 'Bonus reward preserved.'
    result.labelResult = ''
    result.color = '#f0c96a'
    self:renderResult()
    return
  end
  self:closeResult()
end

function ForgeController:closeResult()
  if self.resultEvent then
    removeEvent(self.resultEvent)
    self.resultEvent = nil
  end
  destroyResultWindow()
  sendForgeRequest('open')
end

function onOpenForge(data)
  data = data or {}
  ForgeController.rawOpenForgeData = data
  ForgeController.fusion.currentPage = math.max(1, tonumber(data.page) or 1)
  ForgeController.fusion.classification = math.max(0, math.min(4, tonumber(data.classification) or ForgeController.fusion.classification or 0))
  local classificationFilter = widget('fusionClassificationFilter')
  if classificationFilter then
    classificationFilter:setCurrentIndex(ForgeController.fusion.classification + 1, true)
  end
  ForgeController.fusion.totalPages = math.max(1, tonumber(data.totalPages) or 1)
  ForgeController.fusion.totalItems = math.max(0, tonumber(data.totalItems) or 0)
  ForgeController.fusion.itemsPerPage = math.max(1, tonumber(data.itemsPerPage) or 12)
  ForgeController.fusion.items = handleFusionItems(cloneValue(data.fusionItems or {}))
  ForgeController.fusion.convergenceItems = handleConvergenceFusionItems(cloneValue(data.convergenceFusion or {}))
  ForgeController.transfer.items = handleTransferItems(cloneValue(data.transfers or {}))
  ForgeController.transfer.convergenceItems = handleTransferItems(cloneValue(data.convergenceTransfers or {}))

  replaceTableContents(ForgeController.fusion.currentList,
    ForgeController.fusion.isConvergence and ForgeController.fusion.convergenceItems or ForgeController.fusion.items)
  local transferSource = ForgeController.transfer.isConvergence and
    ForgeController.transfer.convergenceItems or ForgeController.transfer.items
  ForgeController.transfer.currentList = {
    donors = cloneValue(transferSource.donors or {}),
    receivers = {}
  }

  resetSelections()
  ForgeController:refresh()
end

function forgeData(data)
  data = data or {}
  ForgeController.rawData = data
  local classPrices = normalizeClassPriceEntries(data.classPrices)
  if next(classPrices) then ForgeController.fusion.prices = classPrices end
  local transferPrices = normalizeClassPriceEntries(data.transferPrices)
  if next(transferPrices) then ForgeController.transfer.prices = transferPrices end
  local convergenceFusion = normalizeTierPriceEntries(data.convergenceFusionPrices)
  if next(convergenceFusion) then ForgeController.fusion.convergencePrices = convergenceFusion end
  local convergenceTransfer = normalizeTierPriceEntries(data.convergenceTransferPrices)
  if next(convergenceTransfer) then ForgeController.transfer.convergencePrices = convergenceTransfer end

  ForgeController.fusion.grades = data.fusionGrades or {}
  ForgeController.fusion.convergenceDust = tonumber(data.convergenceFusionDust) or 160
  ForgeController.fusion.dust = tonumber(data.normalDustFusion) or 100
  ForgeController.fusion.reduceTierLoss = tonumber(data.fusionReduceTierLoss) or 50
  ForgeController.fusion.chanceImproved = tonumber(data.fusionChanceImproved) or 15
  ForgeController.fusion.chanceBase = tonumber(data.fusionChanceBase) or 50
  ForgeController.fusion.improveCoreCosts = data.improveCoreCosts or {}
  ForgeController.fusion.lossCoreCosts = data.lossCoreCosts or {}
  ForgeController.fusion.fusionDustCosts = data.fusionDustCosts or {}
  ForgeController.fusion.hasConvergence = data.hasConvergence == true

  ForgeController.transfer.grades = data.fusionGrades or {}
  ForgeController.transfer.convergenceDust = tonumber(data.convergenceDustTransfer) or 160
  ForgeController.transfer.dust = tonumber(data.normalDustTransfer) or 100
  ForgeController.transfer.hasConvergence = data.hasConvergence == true

  ForgeController.conversion.necessaryDustToSliver = tonumber(data.necessaryDustToSliver) or 60
  ForgeController.conversion.dustToSilver = tonumber(data.dustToSilver) or 3
  ForgeController.conversion.sliverToCore = tonumber(data.sliverToCore) or 50
  if type(data.currencyClientIds) == 'table' then
    ForgeController.currencyClientIds = data.currencyClientIds
  end
  ForgeController:refresh()
end

local historyActionLabels = {
  [0] = 'Fusion',
  [1] = 'Transfer',
  [2] = 'Conversion',
  [3] = 'System',
  [4] = 'System'
}

function onBrowseForgeHistory(page, lastPage, currentCount, historyList)
  local history = ForgeController.history
  history.currentPage = math.max(1, tonumber(page) or 1)
  history.lastPage = math.max(1, tonumber(lastPage) or 1)
  history.showPreviousButton = history.currentPage > 1
  history.showNextButton = history.currentPage < history.lastPage
  history.list = historyList or {}
  for _, entry in ipairs(history.list) do
    entry.createdAt = Helpers.formatHistoryDate(entry.createdAt)
    entry.actionType = historyActionLabels[tonumber(entry.actionType)] or tostring(entry.actionType or 'Unknown')
  end
  ForgeController:renderHistory()
end

function ForgeController.history.onHistoryPreviousPage()
  local page = ForgeController.history.currentPage
  if page > 1 then sendForgeRequest('history', { page = page - 1 }) end
end

function ForgeController.history.onHistoryNextPage()
  local history = ForgeController.history
  if history.currentPage < history.lastPage then
    sendForgeRequest('history', { page = history.currentPage + 1 })
  end
end

function ForgeController:onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= FORGE_OPCODE then return end
  local ok, payload = pcall(json.decode, buffer)
  if not ok or type(payload) ~= 'table' then
    pwarning('[game_forge] Invalid server response: ' .. tostring(buffer))
    return
  end

  local data = payload.data or {}
  if data.balances then
    self.serverBalances = data.balances
    self:updateResourceBalances()
  end

  if payload.action == 'open' or payload.action == 'state' then
    forgeData(data.config or {})
    onOpenForge(data.forge or {})
    self:show(true)
  elseif payload.action == 'history' then
    onBrowseForgeHistory(data.page, data.lastPage, data.currentCount, data.list or {})
  elseif payload.action == 'balances' then
    self:refresh()
  elseif payload.action == 'result' then
    forgeResultData(data)
  elseif payload.action == 'item_state' then
    destroyForgeTooltip()
    local convergence = data.convergence == true
    local selected = {
      id = tonumber(data.itemId) or 0,
      clientId = tonumber(data.clientId) or 0,
      tier = math.max(0, tonumber(data.tier) or 0),
      count = 1,
      countLabel = '1 / 1',
      key = tostring(data.key or 'dropped-item'),
      targetTier = convergence and
        math.max(0, tonumber(data.targetTier) or tonumber(data.tier) or 0) or
        math.min(10, (tonumber(data.tier) or 0) + 1),
      requiredCopies = math.max(1, tonumber(data.requiredCopies) or 1),
      availableCopies = math.max(0, tonumber(data.availableCopies) or 1),
      classification = tonumber(data.classification) or 1,
      maxTier = tonumber(data.maxTier) or 10,
      improveCoreCost = tonumber(data.improveCoreCost) or 0,
      lossCoreCost = tonumber(data.lossCoreCost) or 0,
      slot = data.equipmentKind,
      isDropped = currentForgeTarget ~= nil
    }
    self.fusion.selected = selected
    self.fusion.selectedTarget = convergence and
      cloneValue(self.baseSelected) or cloneValue(selected)
    if not convergence then
      self.fusion.selectedTarget.targetTier = selected.targetTier
    end
    self.fusion.convergenceTargets = convergence and
      handleConvergenceTargets(cloneValue(data.convergenceTargets or {})) or {}
    self.fusion.convergenceCoreCost = convergence and
      math.max(0, tonumber(data.coreCost) or 0) or 0
    self.fusion.rawPrice = math.max(0, tonumber(data.price) or 0)
    self.fusion.formattedPrice = self.fusion.rawPrice > 0 and comma_value(self.fusion.rawPrice) or 'Unavailable'
    local targetTier = math.max(1, (tonumber(selected.targetTier) or (selected.tier + 1)))
    local serverDust = tonumber(data.dustCost) or 0
    local configuredDust = self.fusion.fusionDustCosts[targetTier] or
      self.fusion.fusionDustCosts[tostring(targetTier)] or 0
    self.fusion.dust = math.max(0, serverDust > 0 and serverDust or tonumber(configuredDust) or 150)
    self.fusion.title = convergence and
      'Convergence Tier Transfer Requirements' or 'Equipment Upgrade Requirements'
    self.description = tostring(data.message or string.format('Equipment accepted. Current forge tier: %d.', selected.tier))
    self:refresh()
  elseif payload.action == 'error' then
    cancelResultTimeout()
    self.waitingForResult = false
    self.description = tostring(data.message or 'The forge request failed.')
    local errorText = self.description:lower()
    local transferInvalid = errorText:find('transfer donor', 1, true) or
      errorText:find('transfer receiver', 1, true)
    local targetInvalid = errorText:find('selected equipment', 1, true) or
      errorText:find('drop an item', 1, true) or
      errorText:find('only equipable', 1, true) or
      errorText:find('maximum tier', 1, true) or
      errorText:find('convergence donor', 1, true) or
      errorText:find('convergence receiver', 1, true)
    if transferInvalid then
      self.transfer.selected = cloneValue(self.baseSelected)
      self.transfer.selectedTarget = cloneValue(self.baseSelected)
      self.transfer.currentList.receivers = {}
      self.transfer.rawPrice = 0
      self.transfer.formattedPrice = 'Unavailable'
    elseif targetInvalid then
      currentForgeTarget = nil
      self.fusion.selected = cloneValue(self.baseSelected)
      self.fusion.selectedTarget = cloneValue(self.baseSelected)
      self.fusion.rawPrice = 0
      self.fusion.formattedPrice = 'Unavailable'
    end
    self:refresh()
  end
end

function ForgeController:setupTabs()
  local tabBar = widget('forgeTabBar')
  if not tabBar then return end
  tabBar:setContentWidget(widget('tabContent'))
  self.tabs = {
    fusion = tabBar:addTab('Fusion', widget('fusionPanel'), '/modules/game_forge/images/fusion'),
    convergence = tabBar:addTab('Convergence', widget('fusionPanel'), '/modules/game_forge/images/fusion'),
    transfer = tabBar:addTab('Transfer', widget('transferPanel'), '/modules/game_forge/images/transfer'),
    conversion = tabBar:addTab('Conversion', widget('conversionPanel'), '/modules/game_forge/images/conversion'),
    history = tabBar:addTab('History', widget('historyPanel'), '/modules/game_forge/images/history')
  }

  for _, tab in pairs(self.tabs) do
    tab:setWidth(140)
    tab:setHeight(32)
  end
  tabBar.onTabChange = function(_, tab)
    if tab == ForgeController.tabs.fusion then
      ForgeController.currentTab = 'fusion'
      ForgeController:onConvergenceChanged(false, false)
    elseif tab == ForgeController.tabs.convergence then
      ForgeController.currentTab = 'convergence'
      ForgeController:onConvergenceChanged(false, true)
    elseif tab == ForgeController.tabs.transfer then
      ForgeController.currentTab = 'transfer'
    elseif tab == ForgeController.tabs.conversion then
      ForgeController.currentTab = 'conversion'
    elseif tab == ForgeController.tabs.history then
      ForgeController.currentTab = 'history'
      sendForgeRequest('history', { page = ForgeController.history.currentPage or 1 })
    end
    ForgeController:refresh()
  end
end

function ForgeController:bindUiCallbacks()
  local function bindClick(id, callback)
    local target = widget(id)
    if target then target.onClick = callback end
  end

  self.ui.onEscape = function() ForgeController:hide() end
  bindClick('fusionItemsPreviousPage', function() ForgeController:changeFusionPage(-1) end)
  bindClick('fusionItemsNextPage', function() ForgeController:changeFusionPage(1) end)
  local classificationFilter = widget('fusionClassificationFilter')
  if classificationFilter then
    classificationFilter:addOption('Show all')
    for i = 1, 4 do classificationFilter:addOption('Classification ' .. i) end
    classificationFilter.onOptionChange = function(combo)
      ForgeController:changeFusionClassification(combo.currentIndex)
    end
    classificationFilter:setCurrentIndex(1, true)
  end
  bindClick('fusionChanceButton', function() ForgeController:toggleImprovement('improve-chance') end)
  bindClick('fusionLossButton', function() ForgeController:toggleImprovement('reduce-loss') end)
  bindClick('fusionActionButton', function() ForgeController:forgeAction(false) end)
  bindClick('transferActionButton', function() ForgeController:forgeAction(true) end)
  bindClick('dustConversionButton', function() ForgeController.conversion.toggle(2) end)
  bindClick('sliverConversionButton', function() ForgeController.conversion.toggle(3) end)
  bindClick('historyPreviousButton', function() ForgeController.history.onHistoryPreviousPage() end)
  bindClick('historyNextButton', function() ForgeController.history.onHistoryNextPage() end)
  bindClick('closeButton', function() ForgeController:hide() end)

  local fusionSource = widget('fusionSourceItem')
  if fusionSource then
    fusionSource.onDrop = function(target, droppedWidget)
      return ForgeController:onForgeItemDrop(target, droppedWidget)
    end
    fusionSource.onHoverChange = function(itemWidget, hovered)
      showForgeItemTooltip(itemWidget, hovered, nil)
    end
  end

  local fusionTarget = widget('fusionTargetItem')
  if fusionTarget then
    fusionTarget.onHoverChange = function(itemWidget, hovered)
      showForgeItemTooltip(itemWidget, hovered, nil)
    end
  end
end

function ForgeController:show(skipRequest)
  if not self.ui or self.ui:isDestroyed() then return end
  registerForgeOpcode()
  self.ui:show()
  self.ui:raise()
  self.ui:focus()
  self:refresh()
  if not skipRequest then sendForgeRequest('open') end
end

function ForgeController:hide()
  destroyForgeTooltip()
  destroyResultWindow()
  cancelResultTimeout()
  resetConversionArrows()
  cancelBalanceRefresh()
  self.waitingForResult = false
  if self.ui and not self.ui:isDestroyed() then self.ui:hide() end
end

function ForgeController:toggle()
  if not self.ui or self.ui:isDestroyed() then return end
  if self.ui:isVisible() then self:hide() else self:show() end
end

function ForgeController:onGameStart()
  self.currentTab = 'fusion'
end

function ForgeController:onGameEnd()
  self:hide()
end

function ForgeController:onInit()
  self.ui = g_ui.displayUI('game_forge')
  if not self.ui then
    displayErrorBox(tr('Exaltation Forge'), tr('Unable to load the native forge interface.'))
    return
  end
  self.ui:hide()
  registerForgeOpcode()
  self:setupTabs()
  self:bindUiCallbacks()
  self:refresh()
  connect(LocalPlayer, { onInventoryChange = scheduleBalanceRefresh })
  connect(Container, {
    onAddItem = scheduleBalanceRefresh,
    onUpdateItem = scheduleBalanceRefresh,
    onRemoveItem = scheduleBalanceRefresh
  })

end

function ForgeController:onTerminate()
  cancelResultTimeout()
  cancelBalanceRefresh()
  disconnect(LocalPlayer, { onInventoryChange = scheduleBalanceRefresh })
  disconnect(Container, {
    onAddItem = scheduleBalanceRefresh,
    onUpdateItem = scheduleBalanceRefresh,
    onRemoveItem = scheduleBalanceRefresh
  })
  if self.resultEvent then removeEvent(self.resultEvent) self.resultEvent = nil end
  destroyResultWindow()
  unregisterForgeOpcode()
  if self.ui then self.ui:destroy() self.ui = nil end
end
