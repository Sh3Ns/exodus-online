local OPCODE = 238
local STASH_CLIENT_ID = 29244
local window
local withdrawCountWindow
local entries = {}
local sellerNames = {}
local stashClientId = STASH_CLIENT_ID
local slotState = { used = 0, total = 0, free = 0 }

local categoryNames = {
  [1] = 'Armors', [2] = 'Amulets', [3] = 'Boots', [4] = 'Containers',
  [5] = 'Decoration', [6] = 'Food', [7] = 'Helmets/Hats', [8] = 'Legs',
  [9] = 'Others', [10] = 'Potions', [11] = 'Rings', [12] = 'Runes',
  [13] = 'Shields', [14] = 'Tools', [15] = 'Valuables', [16] = 'Ammunition',
  [17] = 'Axes', [18] = 'Clubs', [19] = 'Distance Weapons', [20] = 'Swords',
  [21] = 'Wands/Rods', [22] = 'Premium Items', [23] = 'Coins',
  [24] = 'Creature Products', [25] = 'Quivers'
}

local function send(payload)
  local protocol = g_game.getProtocolGame()
  if protocol then
    protocol:sendExtendedOpcode(OPCODE, json.encode(payload))
  end
end

local function getMeta(clientId)
  local thingType = g_things.getThingType(clientId, ThingCategoryItem)
  local name = ''
  local category = 'Others'
  if thingType then
    local preview = Item.create(clientId, 1)
    name = preview and preview:getName() or ''
    if thingType:isMarketable() then
      local market = thingType:getMarketData()
      if market then
        if market.name and market.name:len() > 0 then name = market.name end
        category = categoryNames[market.category] or category
      end
    end
  end
  if name:len() == 0 then name = string.format('Item %d', clientId) end
  return name, category
end

local function normalizeEntry(raw)
  local entry = {
    serverId = tonumber(raw.serverId) or 0,
    clientId = tonumber(raw.clientId) or 0,
    amount = tonumber(raw.amount) or 0,
    sellers = {},
  }
  entry.name, entry.category = getMeta(entry.clientId)
  entry.nameLower = entry.name:lower()
  for _, seller in ipairs(raw.sellers or {}) do
    entry.sellers[tostring(seller):lower()] = true
  end
  return entry
end

local function ensureWindow()
  if window then return true end
  window = g_ui.displayUI('game_supply_stash')
  if not window then return false end
  window:hide()
  window.onDestroy = function() window = nil end

  local itemPanel = window:recursiveGetChildById('items')
  local stashArea = window:recursiveGetChildById('stashArea')
  local function handleDrop(_, draggedWidget)
    return stowDraggedWidget(draggedWidget)
  end
  itemPanel.onDrop = handleDrop
  stashArea.onDrop = handleDrop
  return true
end

local function formatAmount(amount)
  if amount >= 1000000 then return string.format('%.1fM', amount / 1000000) end
  if amount >= 1000 then return string.format('%.1fK', amount / 1000) end
  return tostring(amount)
end

function init()
  ProtocolGame.registerExtendedJSONOpcode(OPCODE, onSupplyStashData)
  connect(g_game, { onGameEnd = close })
  ensureWindow()
end

function terminate()
  disconnect(g_game, { onGameEnd = close })
  if ProtocolGame.unregisterExtendedJSONOpcode then
    ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
  end
  if window then window:destroy() end
  if withdrawCountWindow then withdrawCountWindow:destroy() end
  window = nil
  withdrawCountWindow = nil
  entries = {}
end

function close()
  if window then window:hide() end
  if withdrawCountWindow then
    withdrawCountWindow:destroy()
    withdrawCountWindow = nil
  end
end

function isStashItem(item)
  if not item or not item:isItem() then return false end
  local clientId = item:getId() or 0
  if clientId == STASH_CLIENT_ID or clientId == stashClientId then return true end
  local serverId = item:getServerId() or 0
  if serverId == 31900 then return true end
  local name = item:getName() or ''
  return name:lower() == 'supply stash'
end

function open(item)
  if item then
    if not isStashItem(item) then return false end
  end
  send({ action = 'open' })
  return true
end

function isDepotOpen()
  if not g_game.isOnline() then return false end
  for _, container in pairs(g_game.getContainers()) do
    local containerName = (container:getName() or ''):lower()
    if containerName:find('depot box', 1, true) or
       containerName:find('depot chest', 1, true) or
       containerName:find('locker', 1, true) then
      return true
    end
    for _, item in ipairs(container:getItems()) do
      if isStashItem(item) then
        return true
      end
    end
  end
  return false
end

function canStow(item)
  return item and item:isItem() and item:isStackable() and item:isMarketable() and isDepotOpen()
end

function stowItem(item)
  if not canStow(item) then return false end
  local position = item:getPosition()
  send({
    action = 'stow',
    position = { x = position.x, y = position.y, z = position.z },
    stackpos = item:getStackPos(),
    amount = item:getCount()
  })
  return true
end

function stowDraggedWidget(widget)
  if not widget then return false end
  local item = widget.currentDragThing
  if not item and widget.getItem then item = widget:getItem() end
  return stowItem(item)
end

function withdrawEntry(entry, destination, amount)
  if not entry or entry.amount <= 0 then return false end
  amount = math.max(1, math.min(math.floor(tonumber(amount) or entry.amount), entry.amount))
  local payload = {
    action = 'withdraw',
    serverId = entry.serverId,
    amount = amount
  }
  if destination then
    payload.destination = { x = destination.x, y = destination.y, z = destination.z }
  end
  send(payload)
  return true
end

function selectWithdrawAmount(entry, destination)
  if not entry or entry.amount <= 0 then return false end
  if withdrawCountWindow then
    withdrawCountWindow:destroy()
    withdrawCountWindow = nil
  end

  withdrawCountWindow = g_ui.createWidget('CountWindow', g_ui.getRootWidget())
  withdrawCountWindow:setText(tr('Withdraw Item'))
  withdrawCountWindow.onDestroy = function()
    withdrawCountWindow = nil
  end
  local itemBox = withdrawCountWindow:getChildById('item')
  local scrollBar = withdrawCountWindow:getChildById('countScrollBar')
  local spinBox = withdrawCountWindow:getChildById('spinBox')
  local okButton = withdrawCountWindow:getChildById('buttonOk')
  local cancelButton = withdrawCountWindow:getChildById('buttonCancel')

  okButton:setStyle('SupplyStashActionButton')
  cancelButton:setStyle('SupplyStashActionButton')

  itemBox:setItemId(entry.clientId)
  itemBox:setItemCount(entry.amount)
  scrollBar:setMinimum(1)
  scrollBar:setMaximum(entry.amount)
  scrollBar:setValue(entry.amount)
  spinBox:setMinimum(1)
  spinBox:setMaximum(entry.amount)
  spinBox:setValue(entry.amount)
  spinBox:hideButtons()
  spinBox:focus()

  local syncing = false
  spinBox.onValueChange = function(_, value)
    if syncing then return end
    syncing = true
    scrollBar:setValue(value)
    itemBox:setItemCount(value)
    syncing = false
  end
  scrollBar.onValueChange = function(_, value)
    if syncing then return end
    syncing = true
    spinBox:setValue(value)
    itemBox:setItemCount(value)
    syncing = false
  end

  local finish = function(confirm)
    if confirm then withdrawEntry(entry, destination, spinBox:getValue()) end
    if withdrawCountWindow then withdrawCountWindow:destroy() end
    withdrawCountWindow = nil
  end
  okButton.onClick = function() finish(true) end
  cancelButton.onClick = function() finish(false) end
  withdrawCountWindow.onEscape = function() finish(false) end
  g_keyboard.bindKeyPress('Enter', function() finish(true) end, spinBox)
  return true
end

function dropStashItem(widget, destination)
  if not widget or not widget.stashEntry then return false end
  return selectWithdrawAmount(widget.stashEntry, destination)
end

local function addFilterOptions()
  local categoryCombo = window:recursiveGetChildById('category')
  local sellerCombo = window:recursiveGetChildById('seller')
  local categories = {}
  for _, entry in ipairs(entries) do categories[entry.category] = true end

  categoryCombo:clearOptions()
  categoryCombo:addOption('Show All', '')
  local sorted = {}
  for category in pairs(categories) do sorted[#sorted + 1] = category end
  table.sort(sorted)
  for _, category in ipairs(sorted) do categoryCombo:addOption(category, category) end
  categoryCombo:setCurrentOption('Show All', true)

  sellerCombo:clearOptions()
  sellerCombo:addOption('No Trader Selected', '')
  for _, seller in ipairs(sellerNames) do sellerCombo:addOption('Sell to ' .. seller, seller:lower()) end
  sellerCombo:setCurrentOption('No Trader Selected', true)
end

function render()
  if not window then return end
  local panel = window:recursiveGetChildById('items')
  panel:destroyChildren()
  local search = (window:recursiveGetChildById('search'):getText() or ''):lower()
  local categoryOption = window:recursiveGetChildById('category'):getCurrentOption()
  local sellerOption = window:recursiveGetChildById('seller'):getCurrentOption()
  local category = categoryOption and categoryOption.data or ''
  local seller = sellerOption and sellerOption.data or ''

  local filtered = {}
  for _, entry in ipairs(entries) do
    local matchesSearch = search == '' or entry.nameLower:find(search, 1, true)
    local matchesCategory = category == '' or entry.category == category
    local matchesSeller = seller == '' or entry.sellers[seller] == true
    if matchesSearch and matchesCategory and matchesSeller then
      filtered[#filtered + 1] = entry
    end
  end
  table.sort(filtered, function(a, b)
    if a.nameLower == b.nameLower then return a.serverId < b.serverId end
    return a.nameLower < b.nameLower
  end)

  for _, entry in ipairs(filtered) do
    local box = g_ui.createWidget('SupplyStashItem', panel)
    box:setItemId(entry.clientId)
    box:setItemCount(1)
    box:setText(formatAmount(entry.amount))
    box:setTooltip(string.format('%s\nStored: %s\nRight-click or drag into an open backpack to select an amount.', entry.name, comma_value(entry.amount)))
    box.stashEntry = entry
    box.onMouseRelease = function(self, mousePosition, mouseButton)
      if mouseButton == MouseRightButton and self:containsPoint(mousePosition) then
        return selectWithdrawAmount(self.stashEntry, nil)
      end
      return false
    end
  end

  window:recursiveGetChildById('slots'):setText(string.format(
    'Stash slots: %s / %s used  |  Free: %s',
    comma_value(slotState.used), comma_value(slotState.total), comma_value(slotState.free)))
end

function onSupplyStashData(_, _, data)
  if not ensureWindow() or type(data) ~= 'table' then return end
  if data.action == 'message' then
    if modules.game_textmessage then
      modules.game_textmessage.displayFailureMessage(data.message or 'Supply Stash action failed.')
    end
    return
  end
  if data.action ~= 'state' then return end

  entries = {}
  for _, raw in ipairs(data.items or {}) do
    local entry = normalizeEntry(raw)
    if entry.serverId > 0 and entry.clientId > 0 and entry.amount > 0 then
      entries[#entries + 1] = entry
    end
  end
  sellerNames = data.sellers or {}
  stashClientId = tonumber(data.stashClientId) or STASH_CLIENT_ID
  slotState.used = tonumber(data.usedSlots) or 0
  slotState.total = tonumber(data.totalSlots) or 0
  slotState.free = tonumber(data.freeSlots) or 0
  addFilterOptions()
  render()
  if data.open then
    window:show()
    window:raise()
    window:focus()
  end
end
