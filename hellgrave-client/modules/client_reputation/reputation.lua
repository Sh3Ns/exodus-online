local REPUTATION_OPCODE = 99
local reputationWindow = nil
local reputationButton = nil
local reputationData = {}

local reputationTooltip = 'Your Reputation of %s is %d of %d. Your Rank: %s'

local factionImages = {
  Vardenfell = '/images/game/reputation/vardenfell_reputation',
  Dorn = '/images/game/reputation/dorn_reputation',
  Frosthold = '/images/game/reputation/frosthold_reputation',
  Hallowfall = '/images/game/reputation/hallowfall_reputation',
  Vyrsk = '/images/game/reputation/vyrsk_reputation'
}

local rankColors = {
  Unfriendly = '#d95a5a',
  Neutral = '#e68a5e',
  Friendly = '#e6b05e',
  Honored = '#e6df5e',
  Revered = '#c2e65e',
  Exalted = '#5ee660',
  Majestic = '#5ee6cb'
}

local function getFactionImage(name)
  return factionImages[name] or factionImages.Vardenfell
end

local function getRankColor(rank)
  return rankColors[rank] or '#dfdfdf'
end

local function shortText(text, limit)
  text = tostring(text or '')
  limit = limit or 26
  if text:len() > limit then
    return text:sub(1, limit - 3) .. '...'
  end
  return text
end

function init()
  connect(g_game, { onGameStart = updateReputationWindow })

  ProtocolGame.registerExtendedOpcode(REPUTATION_OPCODE, onExtendedOpcode)

  reputationButton = modules.client_topmenu.addRightGameToggleButton('reputationButton', tr('Reputation'), '/images/topbuttons/reputation', toggleReputationWindow)
  reputationButton:setOn(true)

  reputationWindow = g_ui.loadUI('reputation', modules.game_interface.getRightPanel())
  reputationWindow:setup()

  if g_game.isOnline() then
    updateReputationWindow()
  end
end

function terminate()
  disconnect(g_game, { onGameStart = updateReputationWindow })
  ProtocolGame.unregisterExtendedOpcode(REPUTATION_OPCODE)

  if reputationButton then
    reputationButton:destroy()
    reputationButton = nil
  end

  if reputationWindow then
    reputationWindow:destroy()
    reputationWindow = nil
  end
end

function onExtendedOpcode(protocol, code, buffer)
  local jsonStatus, jsonData = pcall(function()
    return json.decode(buffer)
  end)

  if not jsonStatus then
    g_logger.error('[Reputation] JSON error: ' .. jsonData)
    return false
  end

  reputationData = jsonData
  updateReputationWindow()
end

function updateReputationWindow()
  if not reputationWindow then
    return
  end

  local content = reputationWindow:getChildById('contentsPanel')
  content:destroyChildren()

  for _, reputationEntry in ipairs(reputationData) do
    local reputationWidget = g_ui.createWidget('ReputationPanel', content)
    reputationWidget:setId(tostring(reputationEntry.storage))

    local current = tonumber(reputationEntry.current) or 0
    local max = tonumber(reputationEntry.max) or 1
    local percentage = math.max(0, math.min(100, (current / max) * 100))
    local rank = reputationEntry.rank or 'Unknown'
    local rankColor = getRankColor(rank)

    reputationWidget:getChildById('factionImage'):setImageSource(getFactionImage(reputationEntry.name))
    reputationWidget:getChildById('name'):setText(shortText(reputationEntry.name, 24))

    local rankLabel = reputationWidget:getChildById('rank')
    rankLabel:setText(rank)
    rankLabel:setColor(rankColor)

    local progressBar = reputationWidget:getChildById('reputationBar')
    progressBar:setValue(current, 0, max)
    progressBar:setBackgroundColor(getProgressColor(percentage))
    progressBar:setText(comma_value(current) .. ' / ' .. comma_value(max))
    progressBar:setTooltip(tr(reputationTooltip, reputationEntry.name, current, max, rank))

    reputationWidget:getChildById('coinImage'):setImageSource('/images/game/reputation/coins')

    local coinText = string.format('%s: %s', reputationEntry.coin or 'Coins', comma_value(tonumber(reputationEntry.coinValue) or 0))
    local coinLabel = reputationWidget:getChildById('coinLabel')
    coinLabel:setText(coinText)
    coinLabel:setTooltip(coinText)
  end
end

function getProgressColor(percentage)
  if percentage > 75 then
    return '#00BC00FF'
  elseif percentage > 50 then
    return '#50A150FF'
  elseif percentage > 25 then
    return '#A1A100FF'
  elseif percentage > 10 then
    return '#BF0A0AFF'
  end
  return '#FF0000FF'
end

function toggleReputationWindow()
  if reputationWindow:isVisible() then
    reputationWindow:close()
    reputationButton:setOn(false)
  else
    reputationWindow:open()
    reputationButton:setOn(true)
  end
end

function onMiniWindowClose()
  if reputationButton then
    reputationButton:setOn(false)
  end
end
