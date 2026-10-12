GemsSocket = GemsSocket or {}

local OPCODE = 232
local window
local button
local socketTabPanel
local forgeTabPanel
local fusionTabPanel
local extractEssenceTabPanel
local gemInfoTabPanel
local currentTarget
local currentTargetThing
local currentPanelData
local currentTargetKey
local windowPositionInitialized = false
local currentGemsPage = 1
local currentGemsPageCount = 1
local GEMS_PER_PAGE = 7
local currentGemInfoPage = 1
local currentGemInfoPageCount = 1
local GEM_INFO_PER_PAGE = 6
local showAllGems = false
local currentMode = 'socket'
local updateGemFilterButton
local currentForgeSocketIndex
local currentForgeSockets = {}
local currentExtractEssenceGem
local currentExtractEssenceQuantity = 1
local currentFusionSelection = {}
local currentFusionResult
local extractConfirmWindow
local activeHoverTooltipWidget
local hoverTooltipWatcherConnected
local currentGemInfoSearchText = ''

local GEM_INFO_GUIDE_TITLE = 'Gem Socketing Guide'
local GEM_INFO_GUIDE_TEXT = 'Socketed gems stay bound to the item.\nUse Remove to destroy the selected gem, or use a Star Extractor to safely recover it.'
local GEM_INFO_GUIDE_STATUS = 'Gems can be upgraded through several tiers in Socket Forge.\nHigher tiers improve their effects, and some special gems unlock hidden content or persistent progression.'

local function stopHoverTooltipWatcher()
  if hoverTooltipWatcherConnected then
    disconnect(rootWidget, { onMouseMove = hoverTooltipWatcherConnected })
    hoverTooltipWatcherConnected = nil
  end
end

local function clearActiveHoverTooltip(widget)
  if widget and activeHoverTooltipWidget ~= widget then
    return
  end

  activeHoverTooltipWidget = nil
  if g_tooltip then
    g_tooltip.hide()
  end
  stopHoverTooltipWatcher()
end

local function ensureHoverTooltipWatcher()
  if hoverTooltipWatcherConnected or not rootWidget then
    return
  end

  hoverTooltipWatcherConnected = function()
    if not activeHoverTooltipWidget then
      stopHoverTooltipWatcher()
      return
    end

    if activeHoverTooltipWidget.isDestroyed and activeHoverTooltipWidget:isDestroyed() then
      clearActiveHoverTooltip()
      return
    end

    if not activeHoverTooltipWidget:isHovered() then
      clearActiveHoverTooltip()
    end
  end

  connect(rootWidget, { onMouseMove = hoverTooltipWatcherConnected })
end

local function bindHoverTooltip(widget, text)
  if not widget then
    return
  end

  widget:setTooltip(text or '')
  widget.onMouseMove = function(self, mousePos, mouseMoved)
    if not g_tooltip or not self.tooltip or self.tooltip == '' then
      return false
    end

    if not g_mouse or not g_mouse.isPressed or not g_mouse.isPressed() then
      activeHoverTooltipWidget = self
      g_tooltip.display(self.tooltip)
      ensureHoverTooltipWatcher()
      return true
    end

    return false
  end
  widget.onHoverChange = function(self, hovered)
    if not g_tooltip then
      return
    end

    if hovered and self.tooltip and self.tooltip ~= '' and (not g_mouse or not g_mouse.isPressed or not g_mouse.isPressed()) then
      activeHoverTooltipWidget = self
      g_tooltip.display(self.tooltip)
      ensureHoverTooltipWatcher()
    else
      clearActiveHoverTooltip(self)
    end
  end
  widget.onDestroy = function()
    clearActiveHoverTooltip(widget)
  end
end

local function getStructuredTooltip()
  if modules.game_tooltip and modules.game_tooltip.m_TooltipFunction then
    return modules.game_tooltip.m_TooltipFunction
  end

  return rawget(_G, 'm_TooltipFunction')
end

local function buildGemTooltipList(gemData)
  local tooltipApi = getStructuredTooltip()
  if not tooltipApi or not gemData then
    return nil
  end

  local level = math.max(1, tonumber(gemData.level) or 1)
  local maxLevel = math.max(level, tonumber(gemData.maxLevel) or level)
  return {
    {
      id = tooltipApi.TOOLTIP_ATTRIBUTE_NAME,
      value = gemData.name or 'Gem',
    },
    {
      id = tooltipApi.TOOLTIP_ATTRIBUTE_GEM_LEVEL,
      value = string.format('%d|%d|%s', level, maxLevel, gemData.tooltip or ''),
    },
  }
end

local function showGemTooltip(widget, gemData)
  local tooltipApi = getStructuredTooltip()
  local list = buildGemTooltipList(gemData)
  if not tooltipApi or not list then
    return false
  end

  clearActiveHoverTooltip()
  if g_tooltip then
    g_tooltip.hide()
  end

  tooltipApi.open(list, {
    itemId = gemData.clientId or gemData.itemId or 0,
    position = (g_window.getMousePosition and g_window.getMousePosition()) or widget:getPosition()
  })
  return true
end

local function bindGemTooltip(widget, gemData)
  if not widget then
    return
  end

  widget.gemTooltipData = gemData
  if widget.setTooltip then
    widget:setTooltip('')
  end

  widget.onHoverChange = function(self, hovered)
    local tooltipApi = getStructuredTooltip()
    if hovered and self.gemTooltipData then
      showGemTooltip(self, self.gemTooltipData)
    elseif tooltipApi then
      tooltipApi.destroy()
    end
  end

  widget.onDestroy = function(self)
    local tooltipApi = getStructuredTooltip()
    if tooltipApi and self and self:isHovered() then
      tooltipApi.destroy()
    end
  end
end

local function send(action, data)
  local protocolGame = g_game.getProtocolGame()
  if not protocolGame then
    return
  end

  protocolGame:sendExtendedOpcode(OPCODE, json.encode({
    action = action,
    data = data or {}
  }))
end

local function requestGemCatalogPage(page)
  currentGemInfoPage = math.max(1, tonumber(page) or 1)
  send('gem_catalog_page', {
    page = currentGemInfoPage,
    pageSize = GEM_INFO_PER_PAGE,
    search = currentGemInfoSearchText or ''
  })
end

local function ensureWindowPosition()
  if not window or windowPositionInitialized then
    return
  end

  local root = rootWidget
  if not root then
    return
  end

  local width = window:getWidth()
  local height = window:getHeight()
  local x = math.max(0, math.floor((root:getWidth() - width) / 2))
  local y = math.max(0, math.floor((root:getHeight() - height) / 2))
  window:breakAnchors()
  window:setPosition({ x = x, y = y })
  windowPositionInitialized = true
end

local function setStatus(text, color)
  if not window then
    return
  end

  local statusLabel = window:recursiveGetChildById('statusLabel')
  if not statusLabel then
    return
  end

  statusLabel:setText(text or '')
  if color then
    statusLabel:setColor(color)
  end
end

local function getModeForPanel(panel)
  if panel == forgeTabPanel then
    return 'forge'
  elseif panel == fusionTabPanel then
    return 'fusion'
  elseif panel == extractEssenceTabPanel then
    return 'extract'
  elseif panel == gemInfoTabPanel then
    return 'gem_info'
  end

  return 'socket'
end

local function getPanelFromTab(tab)
  if not tab then
    return nil
  end
  if type(tab.getTabPanel) == 'function' then
    return tab:getTabPanel()
  end
  return tab.tabPanel or tab.panel or tab.contentWidget or tab
end

local function getModeForTab(tab)
  local panel = getPanelFromTab(tab)
  local mode = getModeForPanel(panel)
  if mode ~= 'socket' or panel == socketTabPanel then
    return mode
  end

  local text = type(tab.getText) == 'function' and tostring(tab:getText() or ''):lower() or ''
  if text:find('forge', 1, true) then
    return 'forge'
  elseif text:find('fusion', 1, true) then
    return 'fusion'
  elseif text:find('extract', 1, true) then
    return 'extract'
  elseif text:find('information', 1, true) then
    return 'gem_info'
  end
  return mode
end

local function isGemInfoTabSelected()
  return currentMode == 'gem_info'
end

local function getCurrentPanelMode()
  return currentMode or 'socket'
end

local function sendPanelRefresh(page)
  if not currentTarget then
    return
  end

  currentGemsPage = math.max(1, tonumber(page) or currentGemsPage or 1)
  send('refresh_panel', {
    target = currentTarget,
    mode = getCurrentPanelMode(),
    gemsPage = currentGemsPage,
    gemsPageSize = GEMS_PER_PAGE,
    showAllGems = showAllGems
  })
end

local function updateTopPanelMode()
  if not window then
    return
  end

  local targetVisualPanel = window:recursiveGetChildById('targetVisualPanel')
  local targetInfoPanel = window:recursiveGetChildById('targetInfoPanel')
  local targetHeaderName = window:recursiveGetChildById('targetHeaderName')
  local targetInfo = window:recursiveGetChildById('targetInfo')
  local statusLabel = window:recursiveGetChildById('statusLabel')

  if isGemInfoTabSelected() then
    if targetVisualPanel then
      targetVisualPanel:hide()
    end
    if targetInfoPanel then
      targetInfoPanel:setWidth(900)
    end
    if targetHeaderName then
      targetHeaderName:setText(GEM_INFO_GUIDE_TITLE)
    end
    if targetInfo then
      targetInfo:setHeight(34)
      targetInfo:setText(GEM_INFO_GUIDE_TEXT)
    end
    if statusLabel then
      statusLabel:setHeight(34)
      statusLabel:setColor('#9fd38f')
      statusLabel:setText(GEM_INFO_GUIDE_STATUS)
    end
    return
  end

  if targetVisualPanel then
    targetVisualPanel:show()
  end
  if targetInfoPanel then
    targetInfoPanel:setWidth(740)
  end
  if targetHeaderName then
    targetHeaderName:setText((currentPanelData and currentPanelData.name) or 'No Item Selected')
  end
  if targetInfo then
    targetInfo:setHeight(32)
    if currentPanelData and currentPanelData.socketCount then
      local used = 0
      for _, socketData in ipairs(currentPanelData.sockets or {}) do
        if socketData.gem then
          used = used + 1
        end
      end
      targetInfo:setText(string.format('Socket Count: %d\nSockets Used: %d/%d', currentPanelData.socketCount or 0, used, currentPanelData.socketCount or 0))
    else
      targetInfo:setText('Drag an item with sockets here. (Not Equipped)')
    end
  end
  if statusLabel then
    statusLabel:setHeight(48)
    statusLabel:setText('')
  end
end

local function isBackpackItemPosition(position)
  return position and position.x == 65535 and bit.band(position.y or 0, 0x40) ~= 0
end

local function buildTargetReference(item)
  if not item then
    return nil
  end

  local position = item:getPosition()
  if not position then
    return nil
  end

  return {
    position = {
      x = position.x,
      y = position.y,
      z = position.z,
      stackpos = item:getStackPos()
    }
  }
end

local function getTargetKey(target)
  local position = target and target.position
  if not position then
    return nil
  end

  return string.format('%s:%s:%s:%s:%s',
    tostring(target.uid or 0),
    tostring(position.x or 0),
    tostring(position.y or 0),
    tostring(position.z or 0),
    tostring(position.stackpos or 0))
end

local function getWidget(id)
  if window then
    local widget = window:recursiveGetChildById(id)
    if widget then
      return widget
    end
  end

  if socketTabPanel and not socketTabPanel:isDestroyed() then
    local widget = socketTabPanel:recursiveGetChildById(id)
    if widget then
      return widget
    end
  end

  if forgeTabPanel and not forgeTabPanel:isDestroyed() then
    local widget = forgeTabPanel:recursiveGetChildById(id)
    if widget then
      return widget
    end
  end

  if fusionTabPanel and not fusionTabPanel:isDestroyed() then
    local widget = fusionTabPanel:recursiveGetChildById(id)
    if widget then
      return widget
    end
  end

  if extractEssenceTabPanel and not extractEssenceTabPanel:isDestroyed() then
    local widget = extractEssenceTabPanel:recursiveGetChildById(id)
    if widget then
      return widget
    end
  end

  if gemInfoTabPanel and not gemInfoTabPanel:isDestroyed() then
    local widget = gemInfoTabPanel:recursiveGetChildById(id)
    if widget then
      return widget
    end
  end
end

local function refreshCurrentTarget()
  if not window or not window:isVisible() then
    return
  end

  local mode = getCurrentPanelMode()
  if currentTarget then
    sendPanelRefresh(currentGemsPage)
  elseif mode == 'gem_info' then
    requestGemCatalogPage(currentGemInfoPage)
  elseif mode == 'fusion' or mode == 'extract' then
    send('inventory_essence_panel')
  else
    local gemsList = getWidget('gemsList')
    if gemsList then
      gemsList:destroyChildren()
    end
  end
end

local function clearSockets()
  if not window then
    return
  end

  for _, id in ipairs({ 'socketsPanel', 'gemsList' }) do
    local panel = getWidget(id)
    if panel then
      panel:destroyChildren()
    end
  end

  for _, id in ipairs({ 'forgeSocketsList', 'fusionGemsList', 'forgeRequirementsList', 'extractEssenceGemsList' }) do
    local panel = getWidget(id)
    if panel then
      panel:destroyChildren()
    end
  end
end

local function clearTarget()
  currentTarget = nil
  currentTargetThing = nil
  currentPanelData = nil
  currentTargetKey = nil
  currentGemsPage = 1
  currentGemInfoPage = 1
  showAllGems = false
  currentForgeSocketIndex = nil
  currentForgeSockets = {}
  currentExtractEssenceGem = nil
  currentExtractEssenceQuantity = 1
  currentFusionSelection = {}
  currentFusionResult = nil
  local tooltipApi = getStructuredTooltip()
  if tooltipApi then
    tooltipApi.destroy()
  end
  if not window then
    return
  end

  local targetItem = window:recursiveGetChildById('targetItem')
  if targetItem then
    targetItem:setItem()
    targetItem:setItemId(0)
  end

  local targetName = window:recursiveGetChildById('targetName')
  if targetName then
    targetName:setText('')
  end

  local targetHeaderName = getWidget('targetHeaderName')
  if targetHeaderName then
    targetHeaderName:setText('No Item Selected')
  end

  local targetInfo = window:recursiveGetChildById('targetInfo')
  if targetInfo then
    targetInfo:setText('Drag an item with sockets here. (Not Equipped)')
  end

  clearSockets()
  for _, id in ipairs({ 'forgeCurrentItem', 'forgeNextItem' }) do
    local itemWidget = getWidget(id)
    if itemWidget then
      itemWidget:setItem()
      itemWidget:setItemId(0)
      bindGemTooltip(itemWidget, nil)
    end
  end
  for _, id in ipairs({ 'forgeCurrentStars', 'forgeNextStars' }) do
    local starsWidget = getWidget(id)
    if starsWidget then
      starsWidget:destroyChildren()
    end
  end
  for _, id in ipairs({ 'fusionSourceItem1', 'fusionSourceItem2', 'fusionSourceItem3', 'fusionResultItem', 'extractEssenceSourceItem', 'extractEssenceOutputItem' }) do
    local itemWidget = getWidget(id)
    if itemWidget then
      itemWidget:setItem()
      itemWidget:setItemId(0)
      bindGemTooltip(itemWidget, nil)
    end
  end

  local defaults = {
    forgeCurrentName = 'Select a gem',
    forgeNextName = '',
    forgeGemStyle = '',
    forgeGemBestFor = '',
    forgeCurrentTooltip = '',
    forgeNextTooltip = '',
    forgeImprovementPreview = '',
    fusionSourceLabel1 = 'Empty',
    fusionSourceLabel2 = 'Empty',
    fusionSourceLabel3 = 'Empty',
    fusionResultName = 'Random Gem',
    fusionInfo = 'Select 3 gems of the same level.',
    extractEssenceSourceName = 'Select an inventory gem',
    extractEssenceSourceInfo = '',
    extractEssenceQuantityLabel = '',
    extractEssenceOutputInfo = '',
  }
  for id, text in pairs(defaults) do
    local widget = getWidget(id)
    if widget then
      widget:setText(text)
    end
  end

  local forgeUpgradeButton = getWidget('forgeUpgradeButton')
  if forgeUpgradeButton then
    forgeUpgradeButton:disable()
  end

  local fusionConvertButton = getWidget('fusionConvertButton')
  if fusionConvertButton then
    fusionConvertButton:disable()
  end

  local fusionClearButton = getWidget('fusionClearButton')
  if fusionClearButton then
    fusionClearButton:disable()
  end

  for index = 1, 3 do
    local clearButton = getWidget(string.format('fusionSourceClear%d', index))
    if clearButton then
      clearButton:disable()
    end
  end

  for _, id in ipairs({ 'extractEssenceConvertButton', 'extractEssenceMinusButton', 'extractEssencePlusButton' }) do
    local buttonWidget = getWidget(id)
    if buttonWidget then
      buttonWidget:disable()
    end
  end

  updateGemFilterButton()
  updateTopPanelMode()
  if not isGemInfoTabSelected() then
    setStatus('')
  end
end

local function summarizeBonuses(sockets)
  local orderedBonuses = {}
  local bonusTotals = {}

  local function formatBonusAmount(amount)
    if amount == math.floor(amount) then
      return tostring(math.floor(amount))
    end
    return string.format('%.2f', amount):gsub('0+$', ''):gsub('%.$', '')
  end

  for _, socketData in ipairs(sockets or {}) do
    if socketData.gem and socketData.gem.tooltip then
      local firstLine = socketData.gem.tooltip:match('([^\n]+)') or socketData.gem.tooltip
      if firstLine and firstLine ~= '' then
        local sign, amountText, suffix = firstLine:match('^([%+%-]?)(%d+%.?%d*)%%(.+)$')
        local key = firstLine
        local amount = tonumber(amountText)

        if amount and suffix then
          local signedAmount = sign == '-' and -amount or amount
          key = 'percent:' .. suffix
          if not bonusTotals[key] then
            orderedBonuses[#orderedBonuses + 1] = key
            bonusTotals[key] = {
              amount = 0,
              suffix = suffix,
              isPercent = true,
            }
          end
          bonusTotals[key].amount = bonusTotals[key].amount + signedAmount
        else
          if not bonusTotals[key] then
            orderedBonuses[#orderedBonuses + 1] = key
            bonusTotals[key] = {
              text = firstLine,
              count = 0,
            }
          end
          bonusTotals[key].count = bonusTotals[key].count + 1
        end
      end
    end
  end

  if #orderedBonuses == 0 then
    return { 'No active gem bonuses.' }
  end

  local lines = {}
  for _, bonusKey in ipairs(orderedBonuses) do
    local bonus = bonusTotals[bonusKey]
    if bonus and bonus.isPercent then
      local sign = bonus.amount >= 0 and '+' or '-'
      lines[#lines + 1] = string.format('- %s%s%%%s', sign, formatBonusAmount(math.abs(bonus.amount)), bonus.suffix)
    elseif bonus then
      lines[#lines + 1] = bonus.count > 1 and string.format('- %s x%d', bonus.text, bonus.count) or string.format('- %s', bonus.text)
    end
  end

  return lines
end

local function renderActiveBonusColumns(lines)
  local list = getWidget('activeBonusesList')
  if not list then
    return
  end

  list:destroyChildren()

  for _, line in ipairs(lines or {}) do
    local label = g_ui.createWidget('GemBonusPreviewLabel', list)
    label:setText(line)
  end
end

updateGemFilterButton = function()
  if not window then
    return
  end

  local filterButton = getWidget('gemsFilterButton')
  if filterButton then
    filterButton:setText(showAllGems and 'Allowed Only' or 'Show All Gems')
  end

  local helpLabel = getWidget('gemsHelpLabel')
  if helpLabel then
    if showAllGems then
      helpLabel:setText('Showing all gems. Invalid gems are dimmed for this item.')
    else
      helpLabel:setText('Showing only gems that can be socketed into this item.')
    end
  end
end

local function getDisplayedGems(gems)
  local displayed = {}
  for _, gemData in ipairs(gems or {}) do
    if showAllGems or gemData.allowed ~= false then
      displayed[#displayed + 1] = gemData
    end
  end
  return displayed
end

local function getGemPageCount(gems)
  local total = gems and #gems or 0
  return math.max(1, math.ceil(total / GEMS_PER_PAGE))
end

local function updateGemPagination(gems, alreadyPaged)
  if not window then
    return
  end

  local pageCount = alreadyPaged and currentGemsPageCount or getGemPageCount(gems)
  currentGemsPage = math.max(1, math.min(currentGemsPage, pageCount))

  local pageLabel = getWidget('gemsPageLabel')
  if pageLabel then
    pageLabel:setText(string.format('%d / %d', currentGemsPage, pageCount))
  end

  local prevButton = getWidget('gemsPrevButton')
  if prevButton then
    if currentGemsPage > 1 then
      prevButton:enable()
    else
      prevButton:disable()
    end
  end

  local nextButton = getWidget('gemsNextButton')
  if nextButton then
    if currentGemsPage < pageCount then
      nextButton:enable()
    else
      nextButton:disable()
    end
  end
end

local function renderAvailableGems(gems, alreadyPaged)
  local panel = getWidget('gemsList')
  if not panel then
    return
  end

  local displayedGems = alreadyPaged and (gems or {}) or getDisplayedGems(gems)
  panel:destroyChildren()
  updateGemFilterButton()
  updateGemPagination(displayedGems, alreadyPaged)

  local pageStart = alreadyPaged and 1 or (((currentGemsPage - 1) * GEMS_PER_PAGE) + 1)
  local pageEnd = alreadyPaged and #displayedGems or math.min(#displayedGems, pageStart + GEMS_PER_PAGE - 1)

  local function trimLine(text, maxLength)
    text = tostring(text or '')
    maxLength = maxLength or 28
    if #text <= maxLength then
      return text
    end
    return text:sub(1, maxLength - 3) .. '...'
  end

  local function compactTooltipLine(text)
    text = tostring(text or '')
    text = text:gsub('At or below (%d+)%% HP, deal %+(%d+)%% hit damage', 'Below %1%% HP: +%2%% dmg')
    text = text:gsub('Restore (%d+)%% max health when hit', 'Restore %1%% HP on hit')
    text = text:gsub('Restore (%d+)%% max mana when hit', 'Restore %1%% mana on hit')
    text = text:gsub('Reflect (%d+)%% of received damage', 'Reflect %1%% received')
    text = text:gsub('Reflect (%d+) physical damage', 'Reflect %1 physical dmg')
    text = text:gsub('Reduce hit damage by (%d+)%%', 'Reduce hits by %1%%')
    text = text:gsub('Remove 1 random debuff when hit', 'Remove debuff on hit')
    text = text:gsub('Slow target by (%d+)%% for (%d+)s', 'Slow %1%% for %2s')
    return trimLine(text, 28)
  end

  for index = pageStart, pageEnd do
    local gemData = displayedGems[index]
    local row = g_ui.createWidget('GemInventoryRow', panel)
    row.gemData = gemData
    row.gemItemId = gemData.itemId
    local gemItem = row:getChildById('gemItem')
    gemItem:setItemId(gemData.clientId or gemData.itemId or 0)
    gemItem.gemItemId = gemData.itemId
    gemItem.gemData = gemData
    if gemItem.removeTooltip then
      gemItem:removeTooltip()
    end
    bindGemTooltip(gemItem, gemData)

    local fullTooltip = gemData.tooltip or ''
    local tooltipTitle = gemData.name or 'Unknown Gem'
    local hoverTooltip = fullTooltip ~= '' and string.format('%s\n%s', tooltipTitle, fullTooltip) or tooltipTitle
    bindHoverTooltip(row, hoverTooltip)

    local gemTextPanel = row:recursiveGetChildById('gemTextPanel')
    bindHoverTooltip(gemTextPanel, hoverTooltip)

    local gemName = row:recursiveGetChildById('gemName')
    if gemName then
      gemName:setText(gemData.name or 'Unknown Gem')
      bindHoverTooltip(gemName, hoverTooltip)
    end

    local gemTooltip = row:recursiveGetChildById('gemTooltip')
    if gemTooltip then
      if gemData.allowed == false and showAllGems then
        gemTooltip:setText(gemData.invalidText or 'Not valid for this item')
      else
        local firstLine, rest = fullTooltip:match('^([^\n]+)\n?(.*)$')
        local secondLine = rest and rest:match('([^\n]+)') or nil
        local visibleFirstLine = trimLine(firstLine or fullTooltip, 28)
        local visibleSecondLine = secondLine and compactTooltipLine(secondLine) or nil
        gemTooltip:setText(visibleSecondLine and string.format('%s\n%s', visibleFirstLine, visibleSecondLine) or visibleFirstLine)
      end
      bindHoverTooltip(gemTooltip, hoverTooltip)
    end

    local gemCount = row:recursiveGetChildById('gemCount')
    if gemCount then
      gemCount:setText(tostring(gemData.count or 0))
    end

    if gemData.allowed == false and showAllGems then
      row:setOpacity(0.55)
      if gemName then
        gemName:setColor('#a8a8a8')
      end
      if gemTooltip then
        gemTooltip:setColor('#d9a0a0')
      end
      if gemCount then
        gemCount:setColor('#8a8a8a')
      end
    else
      row:setOpacity(1.0)
      if gemName then
        gemName:setColor('#e0e0e0')
      end
      if gemTooltip then
        gemTooltip:setColor('#b8d6b0')
      end
      if gemCount then
        gemCount:setColor('#9fd38f')
      end
    end
  end
end

local function getForgeSocketData()
  if not currentForgeSocketIndex then
    return nil
  end

  for _, socketData in ipairs(currentForgeSockets or {}) do
    if socketData.index == currentForgeSocketIndex then
      return socketData
    end
  end

  if currentPanelData and currentPanelData.forge then
    for _, socketData in ipairs(currentPanelData.forge.sockets or {}) do
      if socketData.index == currentForgeSocketIndex then
        return socketData
      end
    end
  end

  return nil
end

local function normalizeForgeSockets(data)
  local sockets = data and data.sockets or {}
  if #sockets > 0 then
    return sockets
  end

  local fallback = {}
  for _, socketData in ipairs(currentPanelData and currentPanelData.sockets or {}) do
    local gem = socketData.gem
    fallback[#fallback + 1] = {
      index = socketData.index,
      empty = socketData.empty,
      gem = gem,
      nextLevel = nil,
      forgeable = gem and ((gem.maxLevel or 1) > (gem.level or 1)) or false
    }
  end
  return fallback
end

local function renderForgeStars(rowId, level, maxLevel)
  local row = getWidget(rowId)
  if not row then
    return
  end

  row:destroyChildren()
  level = math.max(0, tonumber(level) or 0)
  maxLevel = math.max(0, tonumber(maxLevel) or 0)

  if maxLevel == 0 then
    return
  end

  row:setWidth((maxLevel * 20) + math.max(0, maxLevel - 1) * 2)

  for index = 1, maxLevel do
    local star = g_ui.createWidget('ForgeStarIcon', row)
    star:setImageSource(index <= level and '/images/sockets/star' or '/images/sockets/star_empty')
  end
end

local function renderSocketStars(row, level, maxLevel)
  if not row then
    return
  end

  row:destroyChildren()
  level = math.max(0, tonumber(level) or 0)
  maxLevel = math.max(0, tonumber(maxLevel) or 0)

  if maxLevel == 0 then
    row:setWidth(0)
    return
  end

  row:setWidth((maxLevel * 20) + math.max(0, maxLevel - 1) * 2)

  for index = 1, maxLevel do
    local star = g_ui.createWidget('ForgeStarIcon', row)
    star:setImageSource(index <= level and '/images/sockets/star' or '/images/sockets/star_empty')
  end
end

local function renderForgeDetails(socketData)
  if not window then
    return
  end

  local currentLevel = socketData and socketData.gem and tonumber(socketData.gem.level) or 0
  local currentMaxLevel = socketData and socketData.gem and tonumber(socketData.gem.maxLevel) or 0
  local isMaxForgeLevel = currentMaxLevel > 0 and currentLevel >= currentMaxLevel
  local nextLevel = 0
  local nextMaxLevel = currentMaxLevel
  if socketData and socketData.nextLevel then
    nextLevel = tonumber(socketData.nextLevel.level) or math.min(currentLevel + 1, currentMaxLevel)
    nextMaxLevel = tonumber(socketData.nextLevel.maxLevel) or currentMaxLevel
  elseif socketData and socketData.gem and currentMaxLevel > 0 then
    nextLevel = currentMaxLevel
  end

  local forgeCurrentItem = getWidget('forgeCurrentItem')
  if forgeCurrentItem then
    if socketData and socketData.gem then
      forgeCurrentItem:setItemId(socketData.gem.clientId or socketData.gem.itemId or 0)
      bindGemTooltip(forgeCurrentItem, socketData.gem)
    else
      forgeCurrentItem:setItem()
      forgeCurrentItem:setItemId(0)
      bindGemTooltip(forgeCurrentItem, nil)
    end
  end
  renderForgeStars('forgeCurrentStars', currentLevel, currentMaxLevel)

  local forgeCurrentName = getWidget('forgeCurrentName')
  if forgeCurrentName then
    if socketData and socketData.gem then
      forgeCurrentName:setText(socketData.gem.name or 'Gem')
    else
      forgeCurrentName:setText('Select a gem')
    end
  end

  local forgeNextItem = getWidget('forgeNextItem')
  if forgeNextItem then
    if socketData and socketData.nextLevel and socketData.gem then
      forgeNextItem:setItemId(socketData.gem.clientId or socketData.gem.itemId or 0)
      bindGemTooltip(forgeNextItem, {
        clientId = socketData.gem.clientId,
        itemId = socketData.gem.itemId,
        name = socketData.nextLevel.name or socketData.gem.name,
        tooltip = socketData.nextLevel.tooltip or socketData.gem.tooltip,
        level = socketData.nextLevel.level or nextLevel,
        maxLevel = socketData.nextLevel.maxLevel or nextMaxLevel,
      })
    else
      forgeNextItem:setItem()
      forgeNextItem:setItemId(0)
      bindGemTooltip(forgeNextItem, nil)
    end
  end
  renderForgeStars('forgeNextStars', nextLevel, nextMaxLevel)

  local forgeNextName = getWidget('forgeNextName')
  if forgeNextName then
    if socketData and socketData.nextLevel then
      forgeNextName:setText(socketData.nextLevel.name or 'Next Tier')
    elseif socketData and socketData.gem and isMaxForgeLevel then
      forgeNextName:setText('Max Level')
    else
      forgeNextName:setText('')
    end
  end

  local forgeGemStyle = getWidget('forgeGemStyle')
  if forgeGemStyle then
    if socketData and socketData.gem and socketData.gem.style then
      forgeGemStyle:setText(string.format('Style: %s', socketData.gem.style))
    else
      forgeGemStyle:setText('')
    end
  end

  local forgeGemBestFor = getWidget('forgeGemBestFor')
  if forgeGemBestFor then
    local bestFor = socketData and socketData.gem and socketData.gem.bestFor or nil
    if type(bestFor) == 'table' and #bestFor > 0 then
      forgeGemBestFor:setText(string.format('Best For: %s', table.concat(bestFor, ', ')))
    else
      forgeGemBestFor:setText('')
    end
  end

  local forgeCurrentTooltip = getWidget('forgeCurrentTooltip')
  if forgeCurrentTooltip then
    local tooltip = socketData and socketData.gem and socketData.gem.tooltip or ''
    forgeCurrentTooltip:setText((tooltip:match('([^\n]+)') or tooltip))
  end

  local forgeNextTooltip = getWidget('forgeNextTooltip')
  if forgeNextTooltip then
    if socketData and socketData.nextLevel then
      local tooltip = socketData.nextLevel.tooltip or ''
      forgeNextTooltip:setText((tooltip:match('([^\n]+)') or tooltip))
    elseif socketData and socketData.gem and isMaxForgeLevel then
      forgeNextTooltip:setText('')
    elseif socketData and socketData.gem and socketData.forgeable == false then
      forgeNextTooltip:setText('No forge path configured.')
    else
      forgeNextTooltip:setText('')
    end
  end

  local forgeImprovementPreview = getWidget('forgeImprovementPreview')
  if forgeImprovementPreview then
    if socketData and socketData.gem and socketData.nextLevel then
      local currentText = socketData.gem.tooltip and (socketData.gem.tooltip:match('([^\n]+)') or socketData.gem.tooltip) or ''
      local nextText = socketData.nextLevel.tooltip and (socketData.nextLevel.tooltip:match('([^\n]+)') or socketData.nextLevel.tooltip) or ''
      forgeImprovementPreview:setText(string.format('%s\n> %s', currentText, nextText))
    elseif socketData and socketData.gem and socketData.forgeable == false and not isMaxForgeLevel then
      forgeImprovementPreview:setText('This gem does not have forge tiers yet.')
    else
      forgeImprovementPreview:setText('')
    end
  end

  local requirementsList = getWidget('forgeRequirementsList')
  if requirementsList then
    requirementsList:destroyChildren()
    local requirements = socketData and socketData.nextLevel and socketData.nextLevel.requirements or {}
    if socketData and socketData.nextLevel and #requirements == 0 then
      local row = g_ui.createWidget('GemForgeRequirementRow', requirementsList)
      row:getChildById('item'):setItemId(0)
      row:getChildById('name'):setText('No materials')
      row:getChildById('count'):setText('-')
      if row.setTooltip then
        row:setTooltip('No materials required.')
      end
    end

    for _, requirement in ipairs(requirements) do
      local row = g_ui.createWidget('GemForgeRequirementRow', requirementsList)
      local itemWidget = row:getChildById('item')
      local name = requirement.name or ('Item ' .. tostring(requirement.itemId or 0))
      local tooltip = string.format('%s\n%d / %d', name, requirement.owned or 0, requirement.required or 0)
      itemWidget:setItemId(requirement.clientId or requirement.itemId or 0)
      row:getChildById('name'):setText(name)
      local countLabel = row:getChildById('count')
      countLabel:setText(string.format('%d / %d', requirement.owned or 0, requirement.required or 0))
      countLabel:setColor((requirement.owned or 0) >= (requirement.required or 0) and '#9fd38f' or '#d99b9b')
      if row.setTooltip then
        row:setTooltip(tooltip)
      end
      if itemWidget.setTooltip then
        itemWidget:setTooltip(tooltip)
      end
      if countLabel.setTooltip then
        countLabel:setTooltip(tooltip)
      end
    end
  end

  local forgeUpgradeButton = getWidget('forgeUpgradeButton')
  if forgeUpgradeButton then
    if socketData and socketData.nextLevel then
      if socketData.nextLevel.canUpgrade then
        forgeUpgradeButton:enable()
      else
        forgeUpgradeButton:disable()
      end
    else
      forgeUpgradeButton:disable()
    end
  end
end

local function renderForge(data)
  if not window then
    return
  end

  local list = getWidget('forgeSocketsList')
  if not list then
    return
  end

  list:destroyChildren()

  local sockets = normalizeForgeSockets(data)
  currentForgeSockets = sockets

  for _, socketData in ipairs(sockets) do
    if socketData then
      local row = g_ui.createWidget('GemForgeSocketRow', list)
      local gemItem = row:getChildById('gemItem')
      local socketName = row:recursiveGetChildById('socketName')
      local socketLevel = row:recursiveGetChildById('socketLevel')
      local selectButton = row:recursiveGetChildById('selectButton')

      if socketData.gem then
        if gemItem then
          gemItem:setItemId(socketData.gem.clientId or socketData.gem.itemId or 0)
          bindGemTooltip(gemItem, socketData.gem)
        end
        if socketName then
          socketName:setText(string.format('Socket %d: %s', socketData.index or 0, socketData.gem.name or 'Gem'))
        end
        if socketLevel then
          socketLevel:setText(string.format('Level %d / %d', socketData.gem.level or 1, socketData.gem.maxLevel or 1))
        end
        if socketData.forgeable == false then
          row:setOpacity(0.55)
          if socketName then
            socketName:setColor('#9a9a9a')
          end
          if socketLevel then
            socketLevel:setColor('#7f7f7f')
          end
          if selectButton then
            selectButton:disable()
            selectButton:setText('N/A')
          end
        else
          if selectButton then
            selectButton:enable()
            selectButton:setText('Forge')
            selectButton.onClick = function()
              currentForgeSocketIndex = socketData.index
              renderForgeDetails(getForgeSocketData())
            end
          end
        end
      else
        if gemItem then
          gemItem:setItemId(0)
          bindGemTooltip(gemItem, nil)
        end
        if socketName then
          socketName:setText(string.format('Socket %d: Empty socket', socketData.index or 0))
          socketName:setColor('#9a9a9a')
        end
        if socketLevel then
          socketLevel:setText('Insert a gem to unlock forging')
          socketLevel:setColor('#7f7f7f')
        end
        row:setOpacity(0.65)
        if selectButton then
          selectButton:disable()
          selectButton:setText('Empty')
        end
      end
    end
  end

  if #sockets > 0 then
    local found = false
    if currentForgeSocketIndex then
      for _, socketData in ipairs(sockets) do
        if socketData.index == currentForgeSocketIndex and socketData.gem then
          found = true
          break
        end
      end
    end
    if not found then
      currentForgeSocketIndex = nil
      for _, socketData in ipairs(sockets) do
        if socketData.gem and socketData.forgeable ~= false then
          currentForgeSocketIndex = socketData.index
          break
        end
      end
    end
    renderForgeDetails(getForgeSocketData())
  else
    currentForgeSocketIndex = nil
    renderForgeDetails(nil)
  end
end

local function getDroppedGemItemId(droppedWidget)
  if not droppedWidget then
    return nil
  end

  local item = droppedWidget.currentDragThing
  if not item and type(droppedWidget.getItem) == 'function' then
    item = droppedWidget:getItem()
  end

  local gemItemId = droppedWidget.gemItemId
  if item and not gemItemId then
    if item.getServerId then
      gemItemId = item:getServerId()
    end

    if (not gemItemId or gemItemId <= 0) and currentPanelData and currentPanelData.availableGems then
      local clientId = item:getId()
      for _, gemData in ipairs(currentPanelData.availableGems) do
        if gemData.clientId == clientId then
          gemItemId = gemData.itemId
          break
        end
      end
    end
  end

  return gemItemId
end

local function findDroppedGemData(droppedWidget, gemItemId)
  if not currentPanelData or not currentPanelData.availableGems then
    return nil
  end

  if droppedWidget and droppedWidget.gemData then
    return droppedWidget.gemData
  end

  local parent = droppedWidget and droppedWidget:getParent()
  if parent and parent.gemData then
    return parent.gemData
  end

  if gemItemId and gemItemId > 0 then
    local matchedGem = nil
    for _, gemData in ipairs(currentPanelData.availableGems) do
      if gemData.itemId == gemItemId then
        if matchedGem then
          return nil
        end
        matchedGem = gemData
      end
    end
    if matchedGem then
      return matchedGem
    end
  end

  local item = droppedWidget and droppedWidget.currentDragThing or nil
  if not item and droppedWidget and type(droppedWidget.getItem) == 'function' then
    item = droppedWidget:getItem()
  end
  local clientId = item and item.getId and item:getId() or nil
  if clientId then
    for _, gemData in ipairs(currentPanelData.availableGems) do
      if gemData.clientId == clientId then
        return gemData
      end
    end
  end

  return nil
end

local function getDroppedGemReference(droppedWidget)
  if not droppedWidget then
    return nil
  end

  local item = droppedWidget.currentDragThing
  if not item and type(droppedWidget.getItem) == 'function' then
    item = droppedWidget:getItem()
  end

  return buildTargetReference(item)
end

local function getSelectedFusionCountForGem(gemData)
  local count = 0
  for index = 1, 3 do
    local selectedGem = currentFusionSelection[index]
    if selectedGem and selectedGem.key == gemData.key and tonumber(selectedGem.level) == tonumber(gemData.level) then
      count = count + 1
    end
  end
  return count
end

local function renderFusionDetails()
  local selectedCount = 0
  local selectedLevel = nil

  for index = 1, 3 do
    local selectedGem = currentFusionSelection[index]
    local itemWidget = getWidget(string.format('fusionSourceItem%d', index))
    local labelWidget = getWidget(string.format('fusionSourceLabel%d', index))
    local clearButton = getWidget(string.format('fusionSourceClear%d', index))

    if selectedGem then
      selectedCount = selectedCount + 1
      selectedLevel = selectedLevel or tonumber(selectedGem.level) or 1
      if itemWidget then
        itemWidget:setItemId(selectedGem.clientId or selectedGem.itemId or 0)
        bindGemTooltip(itemWidget, selectedGem)
      end
      if labelWidget then
        labelWidget:setText(string.format('Lv %d / %d', selectedGem.level or 1, selectedGem.maxLevel or 1))
      end
      if clearButton then
        clearButton:enable()
        clearButton.onClick = function()
          currentFusionSelection[index] = nil
          currentFusionResult = nil
          renderFusionDetails()
        end
      end
    else
      if itemWidget then
        itemWidget:setItem()
        itemWidget:setItemId(0)
        bindGemTooltip(itemWidget, nil)
      end
      if labelWidget then
        labelWidget:setText('Empty')
      end
      if clearButton then
        clearButton:disable()
        clearButton.onClick = nil
      end
    end
  end

  local resultItem = getWidget('fusionResultItem')
  local resultName = getWidget('fusionResultName')
  local infoLabel = getWidget('fusionInfo')
  local clearButton = getWidget('fusionClearButton')
  local convertButton = getWidget('fusionConvertButton')

  if clearButton then
    if selectedCount > 0 then
      clearButton:enable()
      clearButton.onClick = function()
        currentFusionSelection = {}
        currentFusionResult = nil
        renderFusionDetails()
      end
    else
      clearButton:disable()
      clearButton.onClick = nil
    end
  end

  if resultItem then
    if currentFusionResult then
      resultItem:setItemId(currentFusionResult.clientId or currentFusionResult.itemId or 0)
      bindGemTooltip(resultItem, currentFusionResult)
    else
      resultItem:setItem()
      resultItem:setItemId(0)
      bindGemTooltip(resultItem, nil)
    end
  end

  if resultName then
    if currentFusionResult then
      resultName:setText(currentFusionResult.name or 'Fused Gem')
    else
      resultName:setText('No Result Yet')
    end
  end

  if infoLabel then
    if currentFusionResult then
      infoLabel:setText(string.format('Obtained: %s - Level %d / %d', currentFusionResult.name or 'Gem', currentFusionResult.level or 1, currentFusionResult.maxLevel or 1))
    elseif selectedCount == 0 then
      infoLabel:setText('Select 3 gems of the same level.')
    elseif selectedCount < 3 then
      infoLabel:setText(string.format('%d / 3 gems selected.', selectedCount))
    else
      infoLabel:setText(string.format('Fuse 3 gems of level %d into 1 random gem of the same level.', selectedLevel or 1))
    end
  end

  if convertButton then
    if selectedCount == 3 and selectedLevel then
      convertButton:enable()
      convertButton.onClick = function()
        local selections = {}
        local groupedSelections = {}

        for index = 1, 3 do
          local gemData = currentFusionSelection[index]
          local selectionKey = string.format('%s|%d', gemData.key or '', gemData.level or 1)
          groupedSelections[selectionKey] = groupedSelections[selectionKey] or {
            key = gemData.key,
            level = gemData.level,
            amount = 0,
          }
          groupedSelections[selectionKey].amount = groupedSelections[selectionKey].amount + 1
        end

        for _, entry in pairs(groupedSelections) do
          selections[#selections + 1] = entry
        end

        currentFusionSelection = {}
        currentFusionResult = nil
        renderFusionDetails()

        send('fuse_inventory_gems', {
          target = currentTarget,
          selections = selections
        })
      end
    else
      convertButton:disable()
      convertButton.onClick = nil
    end
  end
end

local function tryAddFusionGem(gemData)
  if not gemData then
    return
  end

  currentFusionResult = nil

  local selectedLevel = nil
  local selectedCount = 0
  for index = 1, 3 do
    local selectedGem = currentFusionSelection[index]
    if selectedGem then
      selectedCount = selectedCount + 1
      selectedLevel = selectedLevel or tonumber(selectedGem.level) or 1
    end
  end

  if selectedCount >= 3 then
    setStatus('You already selected 3 gems.', '#ff8a8a')
    return
  end

  if selectedLevel and selectedLevel ~= tonumber(gemData.level) then
    setStatus('All 3 gems must have the same level.', '#ff8a8a')
    return
  end

  if getSelectedFusionCountForGem(gemData) >= (tonumber(gemData.count) or 0) then
    setStatus('You do not own more of that exact gem level.', '#ff8a8a')
    return
  end

  for index = 1, 3 do
    if not currentFusionSelection[index] then
      currentFusionSelection[index] = gemData
      break
    end
  end

  renderFusionDetails()
end

local function renderFusion(gems)
  local list = getWidget('fusionGemsList')
  if not list then
    return
  end

  currentFusionResult = nil
  list:destroyChildren()

  for _, gemData in ipairs(gems or {}) do
    if (gemData.count or 0) > 0 then
      local row = g_ui.createWidget('GemExtractInventoryRow', list)
      local gemItem = row:getChildById('gemItem')
      local gemName = row:recursiveGetChildById('gemName')
      local gemPower = row:recursiveGetChildById('gemPower')
      local selectButton = row:recursiveGetChildById('selectButton')

      if gemItem then
        gemItem:setItemId(gemData.clientId or gemData.itemId or 0)
        bindGemTooltip(gemItem, gemData)
      end
      if gemName then
        gemName:setText(gemData.name or 'Gem')
      end
      if gemPower then
        gemPower:setText(string.format('Lv %d / %d  Owned: %d', gemData.level or 1, gemData.maxLevel or 1, gemData.count or 0))
      end
      if selectButton then
        selectButton:enable()
        selectButton:setText('Add')
        selectButton.onClick = function()
          tryAddFusionGem(gemData)
        end
      end
    end
  end

  renderFusionDetails()
end

local function renderExtractEssenceDetails(gemData, quantity)
  currentExtractEssenceGem = gemData
  currentExtractEssenceQuantity = math.max(1, tonumber(quantity) or 1)

  local sourceItem = getWidget('extractEssenceSourceItem')
  local outputItem = getWidget('extractEssenceOutputItem')
  local sourceName = getWidget('extractEssenceSourceName')
  local sourceInfo = getWidget('extractEssenceSourceInfo')
  local quantityLabel = getWidget('extractEssenceQuantityLabel')
  local outputInfo = getWidget('extractEssenceOutputInfo')
  local convertButton = getWidget('extractEssenceConvertButton')
  local minusButton = getWidget('extractEssenceMinusButton')
  local plusButton = getWidget('extractEssencePlusButton')
  local essenceData = currentPanelData and currentPanelData.essence or {}

  if outputItem then
    outputItem:setItemId(essenceData.outputClientId or essenceData.outputItemId or 0)
  end

  if not gemData then
    currentExtractEssenceQuantity = 1
    if sourceItem then
      sourceItem:setItem()
      sourceItem:setItemId(0)
      bindGemTooltip(sourceItem, nil)
    end
    if sourceName then
      sourceName:setText('Select an inventory gem')
    end
    if sourceInfo then
      sourceInfo:setText('')
    end
    if quantityLabel then
      quantityLabel:setText('')
    end
    if outputInfo then
      outputInfo:setText('Gem power preview will appear here.')
    end
    for _, widget in ipairs({ convertButton, minusButton, plusButton }) do
      if widget then
        widget:disable()
        widget.onClick = nil
      end
    end
    return
  end

  local owned = math.max(0, tonumber(gemData.count) or 0)
  local powerEach = math.max(1, tonumber(gemData.essencePower) or 1)
  currentExtractEssenceQuantity = math.max(1, math.min(currentExtractEssenceQuantity, math.max(1, owned)))
  local totalPower = powerEach * currentExtractEssenceQuantity

  if sourceItem then
    sourceItem:setItemId(gemData.clientId or gemData.itemId or 0)
    bindGemTooltip(sourceItem, gemData)
  end
  if sourceName then
    sourceName:setText(gemData.name or 'Gem')
  end
  if sourceInfo then
    sourceInfo:setText(string.format('Level %d / %d - Owned: %d - Power each: %d', gemData.level or 1, gemData.maxLevel or 1, owned, powerEach))
  end
  if quantityLabel then
    quantityLabel:setText(string.format('%d / %d', currentExtractEssenceQuantity, owned))
  end
  if outputInfo then
    outputInfo:setText(string.format('%s x%d', essenceData.outputName or 'Gem Power', totalPower))
  end

  if minusButton then
    if currentExtractEssenceQuantity > 1 then
      minusButton:enable()
    else
      minusButton:disable()
    end
    minusButton.onClick = function()
      if currentExtractEssenceGem then
        renderExtractEssenceDetails(currentExtractEssenceGem, currentExtractEssenceQuantity - 1)
      end
    end
  end

  if plusButton then
    if currentExtractEssenceQuantity < owned then
      plusButton:enable()
    else
      plusButton:disable()
    end
    plusButton.onClick = function()
      if currentExtractEssenceGem then
        renderExtractEssenceDetails(currentExtractEssenceGem, currentExtractEssenceQuantity + 1)
      end
    end
  end

  if convertButton then
    if owned > 0 then
      convertButton:enable()
      convertButton.onClick = function()
        if not currentExtractEssenceGem then
          return
        end

        local selectedGem = currentExtractEssenceGem
        local selectedQuantity = currentExtractEssenceQuantity
        renderExtractEssenceDetails(nil)
        send('essence_inventory_gem', {
          target = currentTarget,
          gemKey = selectedGem.key,
          gemLevel = selectedGem.level,
          amount = selectedQuantity
        })
      end
    else
      convertButton:disable()
      convertButton.onClick = nil
    end
  end
end

local function renderExtractEssence(gems)
  local list = getWidget('extractEssenceGemsList')
  if not list then
    return
  end

  list:destroyChildren()

  for _, gemData in ipairs(gems or {}) do
    if (gemData.count or 0) > 0 then
      local row = g_ui.createWidget('GemExtractInventoryRow', list)
      local gemItem = row:getChildById('gemItem')
      local gemName = row:recursiveGetChildById('gemName')
      local gemPower = row:recursiveGetChildById('gemPower')
      local selectButton = row:recursiveGetChildById('selectButton')

      if gemItem then
        gemItem:setItemId(gemData.clientId or gemData.itemId or 0)
        bindGemTooltip(gemItem, gemData)
      end
      if gemName then
        gemName:setText(gemData.name or 'Gem')
      end
      if gemPower then
        gemPower:setText(string.format('Lv %d / %d  Owned: %d  Power: %d', gemData.level or 1, gemData.maxLevel or 1, gemData.count or 0, gemData.essencePower or 1))
      end
      if selectButton then
        selectButton:enable()
        selectButton:setText('Select')
        selectButton.onClick = function()
          renderExtractEssenceDetails(gemData, 1)
        end
      end
    end
  end

  if currentExtractEssenceGem then
    local refreshedGem = nil
    for _, gemData in ipairs(gems or {}) do
      if gemData.key == currentExtractEssenceGem.key and tonumber(gemData.level) == tonumber(currentExtractEssenceGem.level) and (gemData.count or 0) > 0 then
        refreshedGem = gemData
        break
      end
    end
    renderExtractEssenceDetails(refreshedGem, currentExtractEssenceQuantity)
  else
    renderExtractEssenceDetails(nil)
  end
end

local function getFilteredGemInfoCatalog(catalog)
  catalog = catalog or {}
  local searchText = tostring(currentGemInfoSearchText or ''):lower():gsub('^%s+', ''):gsub('%s+$', '')
  if searchText == '' then
    return catalog
  end

  local filtered = {}
  for _, gemData in ipairs(catalog) do
    local haystack = string.format('%s %s', tostring(gemData.name or ''), tostring(gemData.itemName or '')):lower()
    if haystack:find(searchText, 1, true) then
      filtered[#filtered + 1] = gemData
    end
  end
  return filtered
end

local function getGemInfoPageCount(catalog)
  catalog = getFilteredGemInfoCatalog(catalog or {})
  local total = catalog and #catalog or 0
  return math.max(1, math.ceil(total / GEM_INFO_PER_PAGE))
end

local function trimInfoText(text, maxLength)
  text = tostring(text or '')
  maxLength = maxLength or 90
  text = text:gsub('\n+', ' ')
  if #text <= maxLength then
    return text
  end
  return text:sub(1, maxLength - 3) .. '...'
end

local function buildGemInfoTooltip(gemData)
  local lines = { gemData.name or 'Gem' }
  if gemData.tooltip and gemData.tooltip ~= '' then
    lines[#lines + 1] = gemData.tooltip
  end
  if gemData.nonSocketable then
    lines[#lines + 1] = 'Non-socketable utility gem'
  end
  if gemData.uniqueEquipped then
    lines[#lines + 1] = 'Unique equipped: yes'
  end
  for _, tier in ipairs(gemData.tiers or {}) do
    lines[#lines + 1] = string.format('Tier %d - %s: %s', tier.level or 1, tier.name or gemData.name or 'Gem', tier.tooltip or '')
  end
  return table.concat(lines, '\n')
end

local function updateGemInfoPagination(catalog, alreadyPaged)
  local pageCount = alreadyPaged and currentGemInfoPageCount or getGemInfoPageCount(catalog)
  currentGemInfoPage = math.max(1, math.min(currentGemInfoPage, pageCount))

  local pageLabel = getWidget('gemInfoPageLabel')
  if pageLabel then
    pageLabel:setText(string.format('%d / %d', currentGemInfoPage, pageCount))
  end

  local prevButton = getWidget('gemInfoPrevButton')
  if prevButton then
    if currentGemInfoPage > 1 then
      prevButton:enable()
    else
      prevButton:disable()
    end
  end

  local nextButton = getWidget('gemInfoNextButton')
  if nextButton then
    if currentGemInfoPage < pageCount then
      nextButton:enable()
    else
      nextButton:disable()
    end
  end
end

local function renderGemInformation(catalog, alreadyPaged)
  local panel = getWidget('gemInfoList')
  if not panel then
    return
  end

  catalog = alreadyPaged and (catalog or {}) or getFilteredGemInfoCatalog(catalog or {})
  panel:destroyChildren()
  updateGemInfoPagination(catalog, alreadyPaged)

  local pageStart = alreadyPaged and 1 or (((currentGemInfoPage - 1) * GEM_INFO_PER_PAGE) + 1)
  local pageEnd = alreadyPaged and #catalog or math.min(#catalog, pageStart + GEM_INFO_PER_PAGE - 1)

  for index = pageStart, pageEnd do
    local gemData = catalog[index]
    local card = g_ui.createWidget('GemInfoCard', panel)
    local gemItem = card:recursiveGetChildById('gemInfoItem')
    local gemName = card:recursiveGetChildById('gemInfoName')
    local gemMeta = card:recursiveGetChildById('gemInfoMeta')
    local gemTooltip = card:recursiveGetChildById('gemInfoTooltip')
    local tierList = card:recursiveGetChildById('gemInfoTierList')
    if gemItem then
      gemItem:setItemId(gemData.clientId or gemData.itemId or 0)
      bindGemTooltip(gemItem, nil)
    end
    if gemName then
      gemName:setText(gemData.name or 'Gem')
    end
    if gemMeta then
      local metaText = nil
      if gemData.nonSocketable then
        metaText = 'Non-socketable tool'
      elseif gemData.uniqueEquipped then
        metaText = 'Unique equipped'
      else
        metaText = 'Unique per item'
      end
      gemMeta:setText(string.format('%s  |  %s', gemData.itemName or gemData.name or 'Gem', metaText))
    end
    if gemTooltip then
      gemTooltip:setText('')
    end
    if tierList then
      tierList:destroyChildren()
      for _, tier in ipairs(gemData.tiers or {}) do
        local row = g_ui.createWidget('GemInfoTierRow', tierList)
        local tierName = row:recursiveGetChildById('gemInfoTierName')
        local tierTooltip = row:recursiveGetChildById('gemInfoTierTooltip')
        if tierName then
          tierName:setText(string.format('%d. %s', tier.level or 1, tier.name or gemData.name or 'Gem'))
        end
        if tierTooltip then
          tierTooltip:setText(trimInfoText(tier.tooltip, 150))
        end
      end
    end
  end
end

local function onGemDrop(socketIndex, droppedWidget)
  if not droppedWidget then
    return false
  end

  if not currentTarget then
    setStatus('Select a target item first.', '#ff8a8a')
    return false
  end

  local gemItemId = getDroppedGemItemId(droppedWidget)
  local gemData = findDroppedGemData(droppedWidget, gemItemId)
  local gemReference = getDroppedGemReference(droppedWidget)
  if (not gemItemId or gemItemId <= 0) and not gemReference then
    setStatus(gemData and gemData.invalidText or 'Unable to identify that gem item.', '#ff8a8a')
    return false
  end

  if gemData and gemData.allowed == false then
    setStatus(gemData.invalidText or 'Not valid for this item.', '#ff8a8a')
    return false
  end

  send('insert_gem', {
    target = currentTarget,
    socketIndex = socketIndex,
    gemItemId = gemItemId,
    gemKey = gemData and gemData.key or nil,
    gem = gemReference
  })
  return true
end

local function renderPanel(data)
  if not window then
    return
  end

  local previousInventoryGems = currentPanelData and currentPanelData.inventoryGems
  local nextTargetKey = getTargetKey(data.target)
  local targetChanged = nextTargetKey ~= currentTargetKey
  if targetChanged then
    previousInventoryGems = nil
  end
  currentPanelData = data
  if data.inventoryGems then
    currentPanelData.inventoryGems = data.inventoryGems
  elseif previousInventoryGems then
    currentPanelData.inventoryGems = previousInventoryGems
  end
  currentTarget = data.target
  currentTargetKey = nextTargetKey
  currentGemsPage = tonumber(data.availableGemsPage) or currentGemsPage
  currentGemsPageCount = math.max(1, tonumber(data.availableGemsPageCount) or currentGemsPageCount or 1)
  if targetChanged then
    currentGemsPage = tonumber(data.availableGemsPage) or 1
    currentGemsPageCount = math.max(1, tonumber(data.availableGemsPageCount) or 1)
    currentGemInfoPage = 1
    showAllGems = false
    currentForgeSocketIndex = nil
    currentExtractEssenceGem = nil
    currentExtractEssenceQuantity = 1
    currentFusionSelection = {}
    currentFusionResult = nil
  end

  local targetItem = getWidget('targetItem')
  if targetItem then
    if currentTargetThing then
      targetItem:setItem(currentTargetThing)
    else
      targetItem:setItem()
      targetItem:setItemId(data.clientId)
    end
  end

  local targetName = getWidget('targetName')
  if targetName then
    targetName:setText('')
  end

  local targetHeaderName = getWidget('targetHeaderName')
  if targetHeaderName then
    targetHeaderName:setText(data.name or 'Unknown Item')
  end

  local targetInfo = getWidget('targetInfo')
  local used = 0
  for _, socketData in ipairs(data.sockets or {}) do
    if socketData.gem then
      used = used + 1
    end
  end

  if targetInfo then
    targetInfo:setText(string.format('Socket Count: %d\nSockets Used: %d/%d', data.socketCount or 0, used, data.socketCount or 0))
  end

  updateTopPanelMode()

  clearSockets()
  renderAvailableGems(data.availableGems or {}, data.availableGemsPageCount ~= nil)
  renderForge(data.forge or {})
  renderFusion(currentPanelData.inventoryGems or {})
  renderExtractEssence(currentPanelData.inventoryGems or {})
  if data.gemCatalog then
    renderGemInformation(data.gemCatalog)
  elseif isGemInfoTabSelected() then
    requestGemCatalogPage(currentGemInfoPage)
  end

  local panel = getWidget('socketsPanel')
  if not panel then
    return
  end

  renderActiveBonusColumns(summarizeBonuses(data.sockets))

  for _, socketData in ipairs(data.sockets or {}) do
    local row = g_ui.createWidget('GemSocketRow', panel)
    local socketLabel = row:recursiveGetChildById('socketLabel')
    if socketLabel then
      socketLabel:setText(string.format('Socket %d', socketData.index))
    end

    local gemItem = row:recursiveGetChildById('gemItem')
    local socketIcon = row:recursiveGetChildById('socketIcon')
    local gemText = row:recursiveGetChildById('gemText') or row:recursiveGetChildById('socketName')
    local gemLevel = row:recursiveGetChildById('socketLevel')
    local gemStars = row:recursiveGetChildById('gemStars')
    local removeButton = row:recursiveGetChildById('removeButton')
    local extractButton = row:recursiveGetChildById('extractButton')

    if gemItem then
      gemItem.onDrop = function(_, droppedWidget)
        return onGemDrop(socketData.index, droppedWidget)
      end
    end
    if socketIcon then
      socketIcon.onDrop = function(_, droppedWidget)
        return onGemDrop(socketData.index, droppedWidget)
      end
    end

    if socketData.gem then
      if gemItem then
        gemItem:show()
        gemItem:setItemId(socketData.gem.clientId or socketData.gem.itemId)
        gemItem:setImageSource('')
        bindGemTooltip(gemItem, socketData.gem)
      end
      bindGemTooltip(socketIcon, socketData.gem)
      if gemText then
        local gemTextValue = socketData.gem.name or 'Gem'
        if socketData.gem.compactTooltip and socketData.gem.compactTooltip ~= '' then
          gemTextValue = string.format('%s\n%s', gemTextValue, socketData.gem.compactTooltip)
        end
        gemText:setText(gemTextValue)
      end
      if gemLevel then
        gemLevel:setText(string.format('Level %d / %d', socketData.gem.level or 1, socketData.gem.maxLevel or 1))
      end
      if gemStars then
        renderSocketStars(gemStars, socketData.gem.level or 1, socketData.gem.maxLevel or 1)
      end
      if removeButton then
        removeButton:enable()
        removeButton:setText('Remove')
      end
      if extractButton then
        extractButton:enable()
        extractButton:setText('Extract')
      end
    else
      if gemItem then
        gemItem:setItemId(0)
        gemItem:setImageSource('')
        gemItem:hide()
        bindGemTooltip(gemItem, nil)
      end
      bindGemTooltip(socketIcon, nil)
      if gemText then
        gemText:setText('Empty socket - Insert a gem to apply its bonus.')
      end
      if gemLevel then
        gemLevel:setText('')
      end
      if gemStars then
        renderSocketStars(gemStars, 0, 0)
      end
      if removeButton then
        removeButton:disable()
        removeButton:setText('Remove')
      end
      if extractButton then
        extractButton:disable()
        extractButton:setText('Insert')
      end
    end

    if removeButton then
      removeButton.onClick = function()
        if not currentTarget or not socketData.gem then
          return
        end

        if extractConfirmWindow then
          extractConfirmWindow:destroy()
          extractConfirmWindow = nil
        end

        local function closeConfirmWindow()
          if extractConfirmWindow then
            extractConfirmWindow:destroy()
            extractConfirmWindow = nil
          end
        end

        local function confirmRemove()
          closeConfirmWindow()
          if not currentTarget then
            return
          end

          send('remove_gem', {
            target = currentTarget,
            socketIndex = socketData.index
          })
        end

        extractConfirmWindow = displayGeneralBox(
          tr('Remove Gem'),
          tr('Are you sure you want to remove that gem?\nThe gem will be destroyed from the item.'),
          {
            { text = tr('Yes'), callback = confirmRemove },
            { text = tr('No'), callback = closeConfirmWindow },
            anchor = AnchorHorizontalCenter
          },
          confirmRemove,
          closeConfirmWindow
        )
      end
    end

    if extractButton then
      extractButton.onClick = function()
        if not currentTarget then
          return
        end

        if not socketData.gem then
          return
        end

        if extractConfirmWindow then
          extractConfirmWindow:destroy()
          extractConfirmWindow = nil
        end

        local function closeConfirmWindow()
          if extractConfirmWindow then
            extractConfirmWindow:destroy()
            extractConfirmWindow = nil
          end
        end

        local function confirmExtract()
          closeConfirmWindow()
          if not currentTarget then
            return
          end

          send('extract_gem', {
            target = currentTarget,
            socketIndex = socketData.index
          })
        end

        extractConfirmWindow = displayGeneralBox(
          tr('Extract Gem'),
          tr('Are you sure you want to extract that gem?\nA Sem extractor will be consumed and the gem level will be preserved.'),
          {
            { text = tr('Yes'), callback = confirmExtract },
            { text = tr('No'), callback = closeConfirmWindow },
            anchor = AnchorHorizontalCenter
          },
          confirmExtract,
          closeConfirmWindow
        )
      end
    end
  end
end

local function onTargetDrop(widget, droppedWidget)
  if not droppedWidget or type(droppedWidget.getItem) ~= 'function' then
    return false
  end

  local item = droppedWidget:getItem()
  if not item then
    return false
  end

  local itemPosition = item:getPosition()
  if not isBackpackItemPosition(itemPosition) then
    setStatus('Drag an item with sockets into the slot.', '#ff8a8a')
    return false
  end

  clearTarget()
  currentTargetThing = item
  setStatus('Checking item...', '#d8c27a')
  send('select_target', { target = buildTargetReference(item) })
  return true
end

function GemsSocket.onExtendedOpcode(protocol, opcode, data)
  if data.action == 'panel' then
    renderPanel(data.data or {})
    if not isGemInfoTabSelected() then
      setStatus('', '#9fd38f')
    end
  elseif data.action == 'inventory_essence_panel' then
    currentPanelData = currentPanelData or {}
    currentPanelData.availableGems = data.data and data.data.availableGems or {}
    currentPanelData.inventoryGems = data.data and (data.data.inventoryGems or data.data.availableGems) or {}
    currentPanelData.essence = data.data and data.data.essence or {}
    if data.data and data.data.gemCatalog then
      currentPanelData.gemCatalog = data.data.gemCatalog
    end
    renderFusion(currentPanelData.inventoryGems)
    renderExtractEssence(currentPanelData.inventoryGems)
    if isGemInfoTabSelected() then
      requestGemCatalogPage(currentGemInfoPage)
    end
  elseif data.action == 'gem_catalog_page' then
    currentPanelData = currentPanelData or {}
    currentPanelData.gemCatalog = data.data and data.data.catalog or {}
    currentGemInfoPage = tonumber(data.data and data.data.page) or 1
    currentGemInfoPageCount = math.max(1, tonumber(data.data and data.data.pageCount) or 1)
    renderGemInformation(currentPanelData.gemCatalog, true)
    if not isGemInfoTabSelected() then
      setStatus('', '#9fd38f')
    else
      updateTopPanelMode()
    end
  elseif data.action == 'fusion_result' then
    local payload = data.data or {}
    currentFusionResult = payload.result
    renderFusionDetails()
  elseif data.action == 'message' then
    local payload = data.data or {}
    if payload.type == 'error' then
      setStatus(payload.message or 'Unknown error.', '#ff8a8a')
    else
      setStatus(payload.message or '', '#9fd38f')
    end
  end
end

function GemsSocket.toggle()
  if not window then
    return
  end

  if window:isVisible() then
    GemsSocket.hide()
  else
    GemsSocket.show()
  end
end

function GemsSocket.show()
  if not window then
    return
  end

  ensureWindowPosition()
  window:show()
  window:raise()
  window:focus()
  if isGemInfoTabSelected() then
    requestGemCatalogPage(currentGemInfoPage)
  else
    refreshCurrentTarget()
  end
end

function GemsSocket.hide()
  if not window then
    return
  end

  if extractConfirmWindow then
    extractConfirmWindow:destroy()
    extractConfirmWindow = nil
  end

  window:hide()
  clearTarget()
end

function GemsSocket.init()
  ProtocolGame.registerExtendedJSONOpcode(OPCODE, GemsSocket.onExtendedOpcode)

  window = g_ui.displayUI('gems_socket')
  window:hide()
  window.onDestroy = function()
    window = nil
    socketTabPanel = nil
    forgeTabPanel = nil
    fusionTabPanel = nil
    extractEssenceTabPanel = nil
    gemInfoTabPanel = nil
  end

  local tabBar = window:recursiveGetChildById('mainTabBar')
  if tabBar then
    tabBar:setContentWidget(window:recursiveGetChildById('mainTabContent'))
    socketTabPanel = window:recursiveGetChildById('socketTabPanel')
    forgeTabPanel = window:recursiveGetChildById('forgeTabPanel')
    fusionTabPanel = window:recursiveGetChildById('fusionTabPanel')
    extractEssenceTabPanel = window:recursiveGetChildById('extractEssenceTabPanel')
    gemInfoTabPanel = window:recursiveGetChildById('gemInfoTabPanel')
    if socketTabPanel then
      tabBar:addTab('Socketing', socketTabPanel)
    end
    if forgeTabPanel then
      tabBar:addTab('Socket Forge', forgeTabPanel)
    end
    if fusionTabPanel then
      tabBar:addTab('Gem Fusion', fusionTabPanel)
    end
    if extractEssenceTabPanel then
      tabBar:addTab('Extract Essence', extractEssenceTabPanel)
    end
    if gemInfoTabPanel then
      tabBar:addTab('Gem Information', gemInfoTabPanel)
    end
    currentMode = getModeForPanel(tabBar:getCurrentTabPanel())

    tabBar.onTabChange = function(_, tab)
      currentMode = getModeForTab(tab)
      currentFusionSelection = {}
      currentFusionResult = nil
      renderFusionDetails()
      updateTopPanelMode()
      if isGemInfoTabSelected() then
        requestGemCatalogPage(currentGemInfoPage)
      else
        refreshCurrentTarget()
      end
    end
  end

  local targetItem = window:recursiveGetChildById('targetItem')
  if targetItem then
    targetItem.onDrop = onTargetDrop
    targetItem.onHoverChange = function(self, hovered)
      if not modules.game_tooltip or not modules.game_tooltip.m_TooltipFunction then
        return
      end

      if hovered and currentTargetThing then
        modules.game_tooltip.m_TooltipFunction.create(self:getPosition(), currentTargetThing, false)
      else
        modules.game_tooltip.m_TooltipFunction.destroy()
      end
    end
  end

  local targetPanel = window:recursiveGetChildById('targetPanel')
  if targetPanel then
    targetPanel.onDrop = onTargetDrop
  end

  local prevButton = getWidget('gemsPrevButton')
  if prevButton then
    prevButton.onClick = function()
      if not currentPanelData or not currentPanelData.availableGems then
        return
      end

      sendPanelRefresh(math.max(1, currentGemsPage - 1))
    end
  end

  local nextButton = getWidget('gemsNextButton')
  if nextButton then
    nextButton.onClick = function()
      if not currentPanelData or not currentPanelData.availableGems then
        return
      end

      sendPanelRefresh(math.min(currentGemsPageCount, currentGemsPage + 1))
    end
  end

  local filterButton = getWidget('gemsFilterButton')
  if filterButton then
    filterButton.onClick = function()
      if not currentPanelData or not currentPanelData.availableGems then
        return
      end

      showAllGems = not showAllGems
      currentGemsPage = 1
      sendPanelRefresh(1)
    end
  end

  local gemInfoPrevButton = getWidget('gemInfoPrevButton')
  if gemInfoPrevButton then
    gemInfoPrevButton.onClick = function()
      requestGemCatalogPage(math.max(1, currentGemInfoPage - 1))
    end
  end

  local gemInfoNextButton = getWidget('gemInfoNextButton')
  if gemInfoNextButton then
    gemInfoNextButton.onClick = function()
      requestGemCatalogPage(math.min(currentGemInfoPageCount, currentGemInfoPage + 1))
    end
  end

  local gemInfoSearchInput = getWidget('gemInfoSearchInput')
  if gemInfoSearchInput then
    gemInfoSearchInput.onTextChange = function(widget, text)
      currentGemInfoSearchText = text or ''
      requestGemCatalogPage(1)
    end
  end

  local forgeUpgradeButton = getWidget('forgeUpgradeButton')
  if forgeUpgradeButton then
    forgeUpgradeButton.onClick = function()
      local socketData = getForgeSocketData()
      if not currentTarget or not socketData then
        return
      end

      send('upgrade_gem', {
        target = currentTarget,
        socketIndex = socketData.index
      })
    end
  end

  updateTopPanelMode()

  button = modules.client_topmenu.addLeftGameToggleButton('gemsSocketButton', tr('Gem Sockets'), '/images/topbuttons/gems', GemsSocket.toggle)

  connect(g_game, { onGameEnd = GemsSocket.hide })
end

function GemsSocket.terminate()
  disconnect(g_game, { onGameEnd = GemsSocket.hide })
  ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)

  if button then
    button:destroy()
    button = nil
  end

  if extractConfirmWindow then
    extractConfirmWindow:destroy()
    extractConfirmWindow = nil
  end

  local socketWindow = window
  window = nil
  if socketWindow then
    pcall(function()
      if not socketWindow:isDestroyed() then
        socketWindow:destroy()
      end
    end)
  end

  windowPositionInitialized = false
end
