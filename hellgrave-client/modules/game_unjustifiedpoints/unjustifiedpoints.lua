unjustifiedPointsWindow = nil
unjustifiedPointsButton = nil
contentsPanel = nil

openPvpSituationsLabel = nil
currentSkullWidget = nil
skullTimeLabel = nil

dayProgressBar = nil
weekProgressBar = nil
monthProgressBar = nil

daySkullWidget = nil
weekSkullWidget = nil
monthSkullWidget = nil

local function pluralize(value, singular, plural)
  return value == 1 and singular or plural
end

local function formatDuration(hours)
  if not hours or hours <= 0 then
    return 'No skull'
  end

  if hours < 24 then
    return string.format('%d %s', hours, pluralize(hours, 'hour', 'hours'))
  end

  local days = math.floor(hours / 24)
  local remainingHours = hours % 24
  if remainingHours == 0 then
    return string.format('%d %s', days, pluralize(days, 'day', 'days'))
  end

  return string.format('%dd %dh', days, remainingHours)
end

local function formatNextFrag(hours)
  if not hours or hours <= 0 then
    return 'Ready to clear'
  end

  return string.format('%d %s', hours, pluralize(hours, 'hour', 'hours'))
end

function init()
  connect(g_game, { onGameStart = online,
                    onUnjustifiedPointsChange = onUnjustifiedPointsChange,
                    onOpenPvpSituationsChange = onOpenPvpSituationsChange })
  connect(LocalPlayer, { onSkullChange = onSkullChange } )

  unjustifiedPointsButton = modules.client_topmenu.addRightGameToggleButton('unjustifiedPointsButton',
    tr('Unjustified Points'), '/images/topbuttons/unjustifiedpoints', toggle)
  unjustifiedPointsButton:setOn(true)
  unjustifiedPointsButton:hide()

  unjustifiedPointsWindow = g_ui.loadUI('unjustifiedpoints', modules.game_interface.getRightPanel())
  unjustifiedPointsWindow:disableResize()
  unjustifiedPointsWindow:setup()

  contentsPanel = unjustifiedPointsWindow:getChildById('contentsPanel')

  openPvpSituationsLabel = contentsPanel:getChildById('openPvpSituationsLabel')
  currentSkullWidget = contentsPanel:getChildById('currentSkullWidget')
  skullTimeLabel = contentsPanel:getChildById('skullTimeLabel')

  dayProgressBar = contentsPanel:getChildById('dayProgressBar')
  weekProgressBar = contentsPanel:getChildById('weekProgressBar')
  monthProgressBar = contentsPanel:getChildById('monthProgressBar')
  daySkullWidget = contentsPanel:getChildById('daySkullWidget')
  weekSkullWidget = contentsPanel:getChildById('weekSkullWidget')
  monthSkullWidget = contentsPanel:getChildById('monthSkullWidget')

  if g_game.isOnline() then
    online()
  end
end

function terminate()
  disconnect(g_game, { onGameStart = online,
                       onUnjustifiedPointsChange = onUnjustifiedPointsChange,
                       onOpenPvpSituationsChange = onOpenPvpSituationsChange })
  disconnect(LocalPlayer, { onSkullChange = onSkullChange } )

  unjustifiedPointsWindow:destroy()
  unjustifiedPointsButton:destroy()
end

function onMiniWindowClose()
  unjustifiedPointsButton:setOn(false)
end

function toggle()
  if unjustifiedPointsButton:isOn() then
    unjustifiedPointsWindow:close()
    unjustifiedPointsButton:setOn(false)
  else
    unjustifiedPointsWindow:open()
    unjustifiedPointsButton:setOn(true)
  end
end

function online()
  if g_game.getFeature(GameUnjustifiedPoints) then
    unjustifiedPointsButton:show()
  else
    unjustifiedPointsButton:hide()
    unjustifiedPointsWindow:close()
  end

  refresh()
end

function refresh()
  local localPlayer = g_game.getLocalPlayer()

  local unjustifiedPoints = g_game.getUnjustifiedPoints()
  onUnjustifiedPointsChange(unjustifiedPoints)

  onSkullChange(localPlayer, localPlayer:getSkull())
  onOpenPvpSituationsChange(g_game.getOpenPvpSituations())
end

function onSkullChange(localPlayer, skull)
  if not localPlayer:isLocalPlayer() then return end
  local currentThresholdSkull = SkullWhite
  if skull == SkullRed or skull == SkullBlack then
    currentThresholdSkull = skull
  end

  if skull == SkullRed or skull == SkullBlack then
    currentSkullWidget:setIcon(getSkullImagePath(skull))
    currentSkullWidget:setTooltip('Remaining skull time')
  else
    currentSkullWidget:setIcon('')
    currentSkullWidget:setTooltip('You have no skull')
  end

  daySkullWidget:setIcon(getSkullImagePath(SkullRed))
  weekSkullWidget:setIcon(getSkullImagePath(SkullBlack))
  monthSkullWidget:setIcon(getSkullImagePath(currentThresholdSkull))
end

function onOpenPvpSituationsChange(amount)
  openPvpSituationsLabel:setText(amount)
end

local function getColorByKills(kills)
  if kills < 2 then
    return 'red'
  elseif kills < 3 then
    return 'yellow'
  end

  return 'green'
end

function onUnjustifiedPointsChange(unjustifiedPoints)
  local localPlayer = g_game.getLocalPlayer()
  local skull = localPlayer and localPlayer:getSkull() or SkullNone
  local isRedSkull = skull == SkullRed
  local isBlackSkull = skull == SkullBlack

  skullTimeLabel:setText(formatDuration(unjustifiedPoints.skullTime))
  skullTimeLabel:setTooltip(unjustifiedPoints.skullTime == 0 and 'You have no skull' or 'Remaining skull time')

  dayProgressBar:setValue(unjustifiedPoints.killsDay, 0, 100)
  dayProgressBar:setBackgroundColor(getColorByKills(unjustifiedPoints.killsDayRemaining))
  if isRedSkull or isBlackSkull then
    dayProgressBar:setTooltip('You already have Red Skull.')
    dayProgressBar:setText('Red Skull: Active')
  else
    dayProgressBar:setTooltip(string.format('Kills remaining before Red Skull.\n%i %s left.', unjustifiedPoints.killsDayRemaining, pluralize(unjustifiedPoints.killsDayRemaining, 'kill', 'kills')))
    dayProgressBar:setText(string.format('Red Skull: %i %s left', unjustifiedPoints.killsDayRemaining, pluralize(unjustifiedPoints.killsDayRemaining, 'kill', 'kills')))
  end

  weekProgressBar:setValue(unjustifiedPoints.killsWeek, 0, 100)
  weekProgressBar:setBackgroundColor(getColorByKills(unjustifiedPoints.killsWeekRemaining))
  if isBlackSkull then
    weekProgressBar:setTooltip('You already have Black Skull.')
    weekProgressBar:setText('Black Skull: Active')
  else
    weekProgressBar:setTooltip(string.format('Kills remaining before Black Skull.\n%i %s left.', unjustifiedPoints.killsWeekRemaining, pluralize(unjustifiedPoints.killsWeekRemaining, 'kill', 'kills')))
    weekProgressBar:setText(string.format('Black Skull: %i %s left', unjustifiedPoints.killsWeekRemaining, pluralize(unjustifiedPoints.killsWeekRemaining, 'kill', 'kills')))
  end

  monthProgressBar:setValue(math.min(unjustifiedPoints.killsMonth * 15, 100), 0, 100)
  monthProgressBar:setBackgroundColor(getColorByKills(math.max(0, 3 - unjustifiedPoints.killsMonth)))
  monthProgressBar:setTooltip(string.format('Current unjustified frags: %i.\nNext frag drops in %s.', unjustifiedPoints.killsMonth, formatNextFrag(unjustifiedPoints.killsMonthRemaining)))
  monthProgressBar:setText(string.format('Frags: %i | Next: %s', unjustifiedPoints.killsMonth, formatNextFrag(unjustifiedPoints.killsMonthRemaining)))
end
