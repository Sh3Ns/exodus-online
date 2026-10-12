tradeWindow = nil
local OPCODE_RARITY_TRADE = 211
local RARITY_BASE = 63500

local tradeRarityCache = { [0] = {}, [1] = {} }
local tradeForgeTierCache = { [0] = {}, [1] = {} }
local tradeWidgets = { [0] = {}, [1] = {} }
local FORGE_TIER_IMAGE_PATH = '/modules/game_forge/images/'

local function paintForgeTierBadge(itemWidget, tier)
  if not itemWidget then return end
  local oldBadge = itemWidget:getChildById('forgeTierOverlay')
  if oldBadge then oldBadge:destroy() end
  tier = math.floor(tonumber(tier) or 0)
  if not itemWidget:getItem() or tier < 1 or tier > 10 then return end

  local badge = g_ui.createWidget('UIWidget', itemWidget)
  badge:setId('forgeTierOverlay')
  badge:setSize({ width = 32, height = 32 })
  badge:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
  badge:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
  badge:setImageSource(FORGE_TIER_IMAGE_PATH .. tier)
  badge:setPhantom(true)
  badge:setFocusable(false)
end

function init()
  g_ui.importStyle('tradewindow')

  connect(g_game, { onOwnTrade = onGameOwnTrade,
                    onCounterTrade = onGameCounterTrade,
                    onCloseTrade = onGameCloseTrade,
                    onGameEnd = onGameCloseTrade })
                    ProtocolGame.registerExtendedOpcode(OPCODE_RARITY_TRADE, onExtendedOpcode)
end

function terminate()
  disconnect(g_game, { onOwnTrade = onGameOwnTrade,
                       onCounterTrade = onGameCounterTrade,
                       onCloseTrade = onGameCloseTrade,
                       onGameEnd = onGameCloseTrade })
  ProtocolGame.unregisterExtendedOpcode(OPCODE_RARITY_TRADE)
  if tradeWindow then
    tradeWindow:destroy()
  end
end

function createTrade()
  tradeWindow = g_ui.createWidget('TradeWindow', modules.game_interface.getRightPanel())
  tradeWindow.onClose = function()
    g_game.rejectTrade()
    tradeWindow:hide()
  end
  tradeWindow:setup()
  local preview = tradeWindow:recursiveGetChildById('tradeItem')
  if preview then
    if preview.setPhantom then preview:setPhantom(true) end
    if preview.setFocusable then preview:setFocusable(false) end
    if preview.setEnabled   then preview:setEnabled(false)   end
  end
end

local function frameFromRarityNumber(num)
  if not num or num < RARITY_BASE then
    return '/images/ui/item'
  end
  local rid = num - RARITY_BASE
  local frames = {
    [1]  = '/images/rarity_frames/rarity_common_tsp.png',
    [2]  = '/images/rarity_frames/rarity_uncommon_tsp.png',
    [3]  = '/images/rarity_frames/rarity_rare_tsp.png',
    [4]  = '/images/rarity_frames/rarity_epic_tsp.png',
    [5]  = '/images/rarity_frames/rarity_legendary_tsp.png',
    [6]  = '/images/rarity_frames/rarity_exotic_tsp.png',
    [7]  = '/images/rarity_frames/rarity_mythic_tsp.png',
    [8]  = '/images/rarity_frames/rarity_chaos_tsp.png',
    [9]  = '/images/rarity_frames/rarity_eternal_tsp.png',
    [10] = '/images/rarity_frames/rarity_divine_tsp.png',
    [11] = '/images/rarity_frames/rarity_phantasmal_tsp.png',
    [12] = '/images/rarity_frames/rarity_celestial_tsp.png',
    [13] = '/images/rarity_frames/rarity_cosmic_tsp.png',
    [14] = '/images/rarity_frames/rarity_abyssal_tsp.png',
    [15] = '/images/rarity_frames/rarity_transcendent_tsp.png',
  }
  return frames[rid] or '/images/ui/item'
end

function setTradeFrameIfChanged(widget, num)
  if not widget then return end
  local frame = frameFromRarityNumber(num)
  if widget._rarityFrame == frame then return end
  widget:setImageSource(frame)
  widget._rarityFrame = frame
  if not widget:getImageSource() then
  end
end

function paintTradeFrames(side)
  local slots = tradeRarityCache[side]
  local tiers = tradeForgeTierCache[side] or {}
  local map   = tradeWidgets[side]
  for slot, num in pairs(slots) do
    local w = map[slot]
    if w then
      setTradeFrameIfChanged(w, num)
      paintForgeTierBadge(w, tiers[slot] or 0)
    end
  end
end

function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_RARITY_TRADE then return end

  local ok, data = pcall(function() return json.decode(buffer) end)
  if not ok or type(data) ~= 'table' then
    return
  end

  if data.a == "rarT" and type(data.s) == "number" and type(data.m) == "table" then
    tradeRarityCache[data.s] = tradeRarityCache[data.s] or {}
    local cache = tradeRarityCache[data.s]
    for _, pair in ipairs(data.m) do
      local slot, num, tier = pair[1], pair[2], tonumber(pair[3]) or 0
      cache[slot] = num
      tradeForgeTierCache[data.s] = tradeForgeTierCache[data.s] or {}
      tradeForgeTierCache[data.s][slot] = tier
    end
    paintTradeFrames(data.s)
  elseif data.a == "rarTS"
     and type(data.s) == "number"
     and type(data.i) == "number"
     and type(data.n) == "number" then

    tradeRarityCache[data.s] = tradeRarityCache[data.s] or {}
    tradeRarityCache[data.s][data.i] = data.n
    tradeForgeTierCache[data.s] = tradeForgeTierCache[data.s] or {}
    tradeForgeTierCache[data.s][data.i] = tonumber(data.t) or 0

    local w = tradeWidgets[data.s] and tradeWidgets[data.s][data.i]
    if w then
      setTradeFrameIfChanged(w, data.n)
      paintForgeTierBadge(w, data.t)
    end
  end
end

function requestTradeFull(side)
  local pg = g_game.getProtocolGame()
  if pg then
    local payload = { a = "reqT", s = side }
    pg:sendExtendedOpcode(OPCODE_RARITY_TRADE, json.encode(payload))
  end
end

local function sendTradeTooltip(w, item, side, index0)
  local tooltip = rawget(_G, 'm_TooltipFunction')
  local tlist   = rawget(_G, 'm_TooltipList')
  if not tooltip or not tlist then return end
  if not tooltip.protocol then
    tooltip.protocol = g_game.getProtocolGame()
    if not tooltip.protocol then return end
  end

  tooltip.lastRefresh = function()
    if w.isHovered and not w:isHovered() then
      return
    end
    sendTradeTooltip(w, item, side, index0)
  end
  if tooltip.startCompareWatcher then
    tooltip.startCompareWatcher()
  end

  local t = (g_clock and g_clock.millis()) or 0
  if w._ttLast and (t - w._ttLast) < 80 then return end
  w._ttLast = t

  if tlist._owner == w and tlist._ownerTag == 'trade' and tlist._pending then
    return
  end

  local pos = g_window.getMousePosition and g_window.getMousePosition()
  if not pos and w.mapToGlobal then
    pos = w:mapToGlobal({ x = math.floor(w:getWidth()/2), y = math.floor(w:getHeight()/2) })
  end
  if not pos then pos = { x = 200, y = 200 } end

  tlist._pending  = { itemId = item:getId(), pos = pos, side = side, index0 = index0 }
  tlist._owner    = w
  tlist._ownerTag = 'trade'
  w._ttItem       = item
  tlist.itemId    = item:getId()
  w._ttSeq = (w._ttSeq or 0) + 1
  tlist._reqOwner = w
  tlist._reqSeq   = w._ttSeq

  w.onMouseMove = function(_, mousePos)
    if w.mapToGlobal and tlist._pending then
      tlist._pending.pos = w:mapToGlobal(mousePos)
    end
  end

  local msg = OutputMessage.create()
  msg:addU8(tooltip.GameServerSendTooltip)
  msg:addU8(2)
  msg:addU8(side)
  msg:addU8(index0)
  msg:addU16(item:getId())
  msg:addU8(tooltip.shouldCompareEquipped and tooltip.shouldCompareEquipped() and 1 or 0)
  tooltip.protocol:send(msg)
end


function fillTrade(name, items, counter)
  if not tradeWindow then
    createTrade()
  end

  local tradeItemWidget = tradeWindow:getChildById('tradeItem')
  tradeItemWidget:setItemId(items[1]:getId())

  local tradeContainer, label, countLabel
  if counter then
    tradeContainer = tradeWindow:recursiveGetChildById('counterTradeContainer')
    label          = tradeWindow:recursiveGetChildById('counterTradeLabel')
    countLabel     = tradeWindow:recursiveGetChildById('counterTradeCountLabel')
    tradeWindow:recursiveGetChildById('acceptButton'):enable()
  else
    tradeContainer = tradeWindow:recursiveGetChildById('ownTradeContainer')
    label          = tradeWindow:recursiveGetChildById('ownTradeLabel')
    countLabel     = tradeWindow:recursiveGetChildById('ownTradeCountLabel')
  end

  label:setText(name)
  countLabel:setText(tr("Items") .. ": " .. #items)

  local side = counter and 1 or 0
  tradeWidgets[side] = {}
  tradeRarityCache[side] = tradeRarityCache[side] or {}
  tradeForgeTierCache[side] = tradeForgeTierCache[side] or {}

  for index, item in ipairs(items) do
    local idx0 = index - 1
    local w = g_ui.createWidget('Item', tradeContainer)
    w:setItem(item)
    w:setVirtual(true)
    w:setMargin(0)

    tradeWidgets[side][idx0] = w
    setTradeFrameIfChanged(w, 0)
    local cached = tradeRarityCache[side] and tradeRarityCache[side][idx0]
    if cached ~= nil then
      setTradeFrameIfChanged(w, cached)
    end
    paintForgeTierBadge(w, tradeForgeTierCache[side][idx0] or 0)

    w.onHoverChange = function(self, hovered)
      local tt = rawget(_G, 'm_TooltipFunction')
      local tl = rawget(_G, 'm_TooltipList')

      if hovered then
        if tl then
          tl._owner    = self
          tl._ownerTag = 'trade'
          tl._pending  = nil
        end
        sendTradeTooltip(self, item, side, idx0)
      else
        if tl then
          if tl._owner == self then
            tl._owner, tl._ownerTag = nil, nil
          end
          if tl._pending and tl._pending.side == side and tl._pending.index0 == idx0 then
            tl._pending = nil
          end
        end
        if tt and tt.destroy then tt.destroy() end
      end
    end

    w.onMouseMove = function(_, mousePos)
      local tl = rawget(_G, 'm_TooltipList')
      if w.mapToGlobal and tl and tl._pending then
        tl._pending.pos = w:mapToGlobal(mousePos)
      end
    end

    w.onDestroy = function()
      local tl = rawget(_G, 'm_TooltipList')
      if tl and tl._owner == w then
        tl._owner, tl._ownerTag = nil, nil
      end
    end

    w.onClick = function()
      g_game.inspectTrade(counter, idx0)
    end
  end

  paintTradeFrames(side)

  scheduleEvent(function()
    requestTradeFull(side)
    scheduleEvent(function()
      requestTradeFull(side)
      paintTradeFrames(side)
    end, 150)
  end, 0)
end

function onGameOwnTrade(name, items)
  fillTrade(name, items, false)
end

function onGameCounterTrade(name, items)
  fillTrade(name, items, true)
end

function onGameCloseTrade()
  if tradeWindow then
    tradeWindow:destroy()
    tradeWindow = nil
    tradeWidgets[0], tradeWidgets[1] = {}, {}
    tradeRarityCache[0], tradeRarityCache[1] = {}, {}
    tradeForgeTierCache[0], tradeForgeTierCache[1] = {}, {}
  end
end
