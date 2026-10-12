local BOSS_TIMERS_OPCODE = 221
local bossTimersWindow = nil
local bossTimersButton = nil
local bossTimersData = { bosses = {}, now = 0, page = 1, totalPages = 1, totalBosses = 0, pageSize = 10 }
local receivedAt = 0
local updateEvent = nil
local bossTimerWidgets = {}
local refreshLocked = false
local refreshDelay = 3000
local currentPage = 1

local statusColors = {
  ready = '#59e35f',
  cooldown = '#ff6666',
  scheduled = '#ffcc66',
  active = '#66ccff',
  unknown = '#b8b8b8'
}

local function shortText(text, limit)
  text = tostring(text or '')
  limit = limit or 28
  if text:len() > limit then
    return text:sub(1, limit - 3) .. '...'
  end
  return text
end

local function formatTime(seconds)
  seconds = math.max(0, tonumber(seconds) or 0)
  local days = math.floor(seconds / 86400)
  seconds = seconds % 86400
  local hours = math.floor(seconds / 3600)
  seconds = seconds % 3600
  local minutes = math.floor(seconds / 60)
  local secs = seconds % 60

  if days > 0 then
    return string.format('%dd %02dh %02dm', days, hours, minutes)
  elseif hours > 0 then
    return string.format('%02dh %02dm %02ds', hours, minutes, secs)
  elseif minutes > 0 then
    return string.format('%02dm %02ds', minutes, secs)
  end
  return string.format('%02ds', secs)
end

local function updatePaginationControls()
  if not bossTimersWindow then
    return
  end

  local page = math.max(1, tonumber(bossTimersData.page) or currentPage or 1)
  local totalPages = math.max(1, tonumber(bossTimersData.totalPages) or 1)
  local totalBosses = math.max(0, tonumber(bossTimersData.totalBosses) or 0)

  local pageLabel = bossTimersWindow:getChildById('pageLabel')
  if pageLabel then
    pageLabel:setText(string.format('%d/%d (%d bosses)', page, totalPages, totalBosses))
  end

  local prevButton = bossTimersWindow:getChildById('prevPageButton')
  if prevButton then
    prevButton:setEnabled(page > 1 and not refreshLocked)
  end

  local nextButton = bossTimersWindow:getChildById('nextPageButton')
  if nextButton then
    nextButton:setEnabled(page < totalPages and not refreshLocked)
  end
end

local function getRemaining(entry)
  local baseRemaining = tonumber(entry.remaining or entry.r) or 0
  local elapsed = math.floor((g_clock.millis() - receivedAt) / 1000)
  return math.max(0, baseRemaining - elapsed)
end

local function updateEntryWidget(widget, entry)
  local name = entry.name or entry.n or 'Unknown Boss'
  local status = entry.status or entry.s or 'unknown'
  local category = entry.category or entry.c or entry.type or entry.t or 'Boss'

  local lookType = tonumber(entry.lookType or entry.outfit or entry.l) or 0
  local lookTypeEx = tonumber(entry.lookTypeEx or entry.x) or 0

  local remaining = getRemaining(entry)

  local nameLabel = widget:getChildById('bossName')
  if nameLabel then
    nameLabel:setText(shortText(name, 24))
    nameLabel:setTooltip(name)
  end

  local categoryLabel = widget:getChildById('category')
  if categoryLabel then
    categoryLabel:setText(shortText(category, 24))
    categoryLabel:setTooltip(category)
  end

  local statusLabel = widget:getChildById('statusText')
  local timerLabel = widget:getChildById('timerValue')

  if statusLabel and timerLabel then
    if status == 'cooldown' then
      statusLabel:setText('Cooldown')
      timerLabel:setText(formatTime(remaining))

    elseif status == 'scheduled' then
      statusLabel:setText('Appears in')
      timerLabel:setText(formatTime(remaining))

    elseif status == 'ready' then
      statusLabel:setText('Status')
      timerLabel:setText('Ready')

    elseif status == 'active' then
      statusLabel:setText('Status')
      timerLabel:setText('Active')

    else
      statusLabel:setText('Status')
      timerLabel:setText(entry.timerText or 'Unknown')
    end

    local color = statusColors[status] or statusColors.unknown
    statusLabel:setColor(color)
    timerLabel:setColor(color)
  end

  local outfitCreature = widget:getChildById('outfitCreature')
  local outfitItem = widget:getChildById('outfitItem')

  if outfitCreature then
    outfitCreature:setVisible(false)
  end

  if outfitItem then
    outfitItem:setVisible(false)
  end

    if lookTypeEx > 0 and outfitItem then
    outfitItem:setVisible(true)

    pcall(function()
      outfitItem:setVirtual(true)
    end)

    pcall(function()
      outfitItem:setItemId(lookTypeEx)
    end)

    pcall(function()
      outfitItem:setItemCount(1)
    end)

    pcall(function()
      outfitItem:setShowCount(false)
    end)

    pcall(function()
      outfitItem:setTooltip(name .. ' item id: ' .. lookTypeEx)
    end)

  elseif lookType > 0 and outfitCreature then
    outfitCreature:setVisible(true)

    pcall(function()
      outfitCreature:setOutfit({
        type = lookType,
        auxType = 0,

        head = tonumber(entry.lookHead or entry.h) or 0,
        body = tonumber(entry.lookBody or entry.b) or 0,
        legs = tonumber(entry.lookLegs or entry.g) or 0,
        feet = tonumber(entry.lookFeet or entry.f) or 0,

        addons = tonumber(entry.lookAddons or entry.a) or 0,
        mount = tonumber(entry.lookMount or entry.m) or 0,

        wings = tonumber(entry.lookWings or entry.w) or 0,
        aura = tonumber(entry.lookAura or entry.u) or 0
      })
    end)

    local scale = tonumber(entry.scale or entry.z) or 1

    pcall(function()
      outfitCreature:setAnimate(true)
    end)

    pcall(function()
      outfitCreature:setScale(scale)
    end)

    pcall(function()
      outfitCreature:setCreatureScale(scale)
    end)

    pcall(function()
      outfitCreature:setZoom(scale)
    end)
  end
end

function requestBossTimers()
  requestBossTimersPage(currentPage, true)
end

function requestBossTimersPage(page, lockRefresh)
  if refreshLocked then
    return
  end

  if not g_game.isOnline() then
    return
  end

  local protocolGame = g_game.getProtocolGame()
  if not protocolGame then
    return
  end

  page = math.max(1, tonumber(page) or 1)
  currentPage = page
  refreshLocked = lockRefresh ~= false

  if bossTimersButton then
    bossTimersButton:setEnabled(false)
  end

  if bossTimersWindow then
    local refreshButton = bossTimersWindow:getChildById('refreshButton')
    if refreshButton then
      refreshButton:setEnabled(not refreshLocked)
      refreshButton:setText(refreshLocked and 'Wait...' or 'Refresh')
    end
  end

  updatePaginationControls()

  protocolGame:sendExtendedOpcode(BOSS_TIMERS_OPCODE, string.format('page:%d', page))

  scheduleEvent(function()
    refreshLocked = false

    if bossTimersButton then
      bossTimersButton:setEnabled(true)
    end

    if bossTimersWindow then
      local refreshButton = bossTimersWindow:getChildById('refreshButton')
      if refreshButton then
        refreshButton:setEnabled(true)
        refreshButton:setText('Refresh')
      end
    end

    updatePaginationControls()
  end, refreshDelay)
end

function changeBossTimerPage(delta)
  local totalPages = math.max(1, tonumber(bossTimersData.totalPages) or 1)
  local targetPage = math.max(1, math.min(totalPages, currentPage + (tonumber(delta) or 0)))
  if targetPage == currentPage then
    return
  end

  requestBossTimersPage(targetPage, false)
end

function updateBossTimersWindow()
  if not bossTimersWindow then
    return
  end

  local content = bossTimersWindow:getChildById('contentsPanel')
  if not content then
    return
  end

  local searchEdit = bossTimersWindow:getChildById('searchEdit')
  local filter = ''
  if searchEdit then
    filter = searchEdit:getText():lower()
  end

  bossTimerWidgets = {}
  content:destroyChildren()

  for index, entry in ipairs(bossTimersData.bosses or {}) do
    local haystack = (
      (entry.name or entry.n or '') .. ' ' ..
      (entry.category or entry.c or '') .. ' ' ..
      (entry.status or entry.s or '')
    ):lower()

    if filter == '' or haystack:find(filter, 1, true) then
      local widget = g_ui.createWidget('BossTimerPanel', content)
      widget:setId('bossTimer' .. index)
      widget.entry = entry
      bossTimerWidgets[#bossTimerWidgets + 1] = widget
      updateEntryWidget(widget, entry)
    end
  end

  updatePaginationControls()
end

local function tick()
  if bossTimersWindow and bossTimersWindow:isVisible() then
    for _, widget in ipairs(bossTimerWidgets) do
      if widget and not widget:isDestroyed() and widget.entry then
        updateEntryWidget(widget, widget.entry)
      end
    end
  end

  updateEvent = scheduleEvent(tick, 1000)
end

function init()
  connect(g_game, { onGameStart = requestBossTimers })
  ProtocolGame.registerExtendedOpcode(BOSS_TIMERS_OPCODE, onExtendedOpcode)

  bossTimersButton = modules.client_topmenu.addRightGameToggleButton('bossTimersButton', tr('Boss Timers'), '/images/topbuttons/bosstimer', toggleBossTimersWindow)
  bossTimersButton:setOn(false)

  bossTimersWindow = g_ui.loadUI('bosstimers', modules.game_interface.getRightPanel())

  if not bossTimersWindow then
    g_logger.error('[BossTimers] Failed to load bosstimers.otui')
    return
  end

  bossTimersWindow:setup()
  bossTimersWindow:hide()
  updatePaginationControls()

  tick()
end

function terminate()
  disconnect(g_game, { onGameStart = requestBossTimers })
  ProtocolGame.unregisterExtendedOpcode(BOSS_TIMERS_OPCODE)

  if updateEvent then
  removeEvent(updateEvent)
  updateEvent = nil
  end

  bossTimerWidgets = {}

  if bossTimersButton then
    bossTimersButton:destroy()
    bossTimersButton = nil
  end

  if bossTimersWindow then
    bossTimersWindow:destroy()
    bossTimersWindow = nil
  end
end

function onExtendedOpcode(protocol, code, buffer)
  if not buffer or buffer:len() == 0 then
    g_logger.error('[BossTimers] Empty opcode buffer')
    return false
  end

  if buffer:sub(1, 1) ~= '{' then
    g_logger.error('[BossTimers] Invalid JSON buffer start: ' .. tostring(buffer:byte(1)))
    return false
  end

  local ok, data = pcall(function()
    return json.decode(buffer)
  end)

  if not ok or type(data) ~= 'table' then
    g_logger.error('[BossTimers] JSON error: ' .. tostring(data))
    return false
  end

  if type(data.bosses) ~= 'table' then
    g_logger.error('[BossTimers] Missing bosses table in payload')
    return false
  end

  bossTimersData = data
  currentPage = math.max(1, tonumber(data.page) or currentPage or 1)
  receivedAt = g_clock.millis()
  updateBossTimersWindow()
end

function toggleBossTimersWindow()
  if bossTimersWindow:isVisible() then
    bossTimersWindow:close()
    bossTimersButton:setOn(false)
  else
    bossTimersWindow:open()
    bossTimersButton:setOn(true)
    requestBossTimers()
  end
end

function onMiniWindowClose()
  if bossTimersButton then
    bossTimersButton:setOn(false)
  end
end
