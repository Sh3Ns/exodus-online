Icons = {}
Icons[PlayerStates.Poison] = { tooltip = tr('You are poisoned'), path = '/images/game/states/poisoned', id = 'condition_poisoned' }
Icons[PlayerStates.Burn] = { tooltip = tr('You are burning'), path = '/images/game/states/burning', id = 'condition_burning' }
Icons[PlayerStates.Energy] = { tooltip = tr('You are electrified'), path = '/images/game/states/electrified', id = 'condition_electrified' }
Icons[PlayerStates.Drunk] = { tooltip = tr('You are drunk'), path = '/images/game/states/drunk', id = 'condition_drunk' }
Icons[PlayerStates.ManaShield] = { tooltip = tr('You are protected by a magic shield'), path = '/images/game/states/magic_shield', id = 'condition_magic_shield' }
Icons[PlayerStates.Paralyze] = { tooltip = tr('You are paralysed'), path = '/images/game/states/slowed', id = 'condition_slowed' }
Icons[PlayerStates.Haste] = { tooltip = tr('You are hasted'), path = '/images/game/states/haste', id = 'condition_haste' }
Icons[PlayerStates.Swords] = { tooltip = tr('You may not logout during a fight'), path = '/images/game/states/logout_block', id = 'condition_logout_block' }
Icons[PlayerStates.Drowning] = { tooltip = tr('You are drowning'), path = '/images/game/states/drowning', id = 'condition_drowning' }
Icons[PlayerStates.Freezing] = { tooltip = tr('You are freezing'), path = '/images/game/states/freezing', id = 'condition_freezing' }
Icons[PlayerStates.Dazzled] = { tooltip = tr('You are dazzled'), path = '/images/game/states/dazzled', id = 'condition_dazzled' }
Icons[PlayerStates.Cursed] = { tooltip = tr('You are cursed'), path = '/images/game/states/cursed', id = 'condition_cursed' }
Icons[PlayerStates.PartyBuff] = { tooltip = tr('You are strengthened'), path = '/images/game/states/strengthened', id = 'condition_strengthened' }
Icons[PlayerStates.PzBlock] = { tooltip = tr('You may not logout or enter a protection zone'), path = '/images/game/states/protection_zone_block', id = 'condition_protection_zone_block' }
Icons[PlayerStates.Pz] = { tooltip = tr('You are within a protection zone'), path = '/images/game/states/protection_zone', id = 'condition_protection_zone' }
Icons[PlayerStates.Bleeding] = { tooltip = tr('You are bleeding'), path = '/images/game/states/bleeding', id = 'condition_bleeding' }
Icons[PlayerStates.Splashed] = { tooltip = tr('You are splashed'), path = '/images/game/states/splashed', id = 'condition_splashed' }
Icons[PlayerStates.Bewitched] = { tooltip = tr('You are bewitched'), path = '/images/game/states/bewitched', id = 'condition_bewitched' }
Icons[PlayerStates.Hungry] = { tooltip = tr('You are hungry'), path = '/images/game/states/hungry', id = 'condition_hungry' }

local HARMONY_OPCODE = 237

healthInfoWindow = nil
healthBar = nil
manaBar = nil
experienceBar = nil
soulLabel = nil
capLabel = nil
healthTooltip = 'Your character health is %d out of %d.'
manaTooltip = 'Your character mana is %d out of %d.'
experienceTooltip = 'You have %d%% to advance to level %d.'

overlay = nil
healthCircleFront = nil
manaCircleFront = nil
healthCircle = nil
manaCircle = nil
arcConditionPanel = nil
harmonyHud = nil
topHealthBar = nil
topManaBar = nil
bottomHealthManaHud = nil
bottomHealthHud = nil
bottomManaHud = nil
bottomHealthBarBackground = nil
bottomManaBarBackground = nil
bottomHealthBarFill = nil
bottomManaBarFill = nil
bottomHealthOrbIcon = nil
bottomManaOrbIcon = nil
bottomHealthValueLabel = nil
bottomManaValueLabel = nil
bottomLevelLabel = nil
bottomExperienceFill = nil
bottomExperienceLabel = nil

local bottomHudDragEnabled = false
local bottomHudPositionRestored = false
local bottomHudSavedPosition = nil
local bottomHudSeparation = 0
local arcConditionsEnabled = false
local harmonyPoints = 0
local harmonyMaximum = 5
local harmonyVisible = false

local function updateHarmonyHud(points, maximum, visible)
  harmonyPoints = math.max(0, tonumber(points) or 0)
  harmonyMaximum = math.max(1, tonumber(maximum) or 5)
  harmonyVisible = visible == true

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer and localPlayer.setHarmony then
    localPlayer:setHarmony(harmonyPoints, harmonyMaximum, harmonyVisible)
  end

  if harmonyHud then
    harmonyHud:setVisible(false)
  end
end

local function onHarmonyOpcode(protocol, opcode, buffer)
  local ok, data = pcall(json.decode, buffer)
  if not ok or type(data) ~= 'table' then
    return
  end
  updateHarmonyHud(data.points, data.max, data.visible)
end

local function requestHarmonyState()
  scheduleEvent(function()
    if not g_game.isOnline() then
      return
    end
    local protocol = g_game.getProtocolGame()
    if protocol then
      protocol:sendExtendedOpcode(HARMONY_OPCODE, 'fetch')
    end
  end, 500)
end

local DEFAULT_BOTTOM_HUD_MARGIN_BOTTOM = 12
local DEFAULT_BOTTOM_HUD_SEPARATION = 0
local MAX_BOTTOM_HUD_SEPARATION = 100
local MAX_BOTTOM_HUD_EFFECTIVE_PERCENT = 81
local DEFAULT_BOTTOM_HEALTH_BAR_MARGIN_LEFT = 45
local DEFAULT_BOTTOM_HEALTH_ICON_MARGIN_LEFT = 0
local DEFAULT_BOTTOM_MANA_BAR_MARGIN_RIGHT = 41
local DEFAULT_BOTTOM_MANA_ICON_MARGIN_RIGHT = 0

local function clamp(value, minValue, maxValue)
  return math.max(minValue, math.min(maxValue, value))
end

local function getDefaultBottomHudPosition()
  if not overlay or not bottomHealthManaHud then
    return { x = 0, y = 0 }
  end

  local x = math.floor((overlay:getWidth() - bottomHealthManaHud:getWidth()) / 2)
  local y = overlay:getHeight() - bottomHealthManaHud:getHeight() - DEFAULT_BOTTOM_HUD_MARGIN_BOTTOM
  return { x = math.max(0, x), y = math.max(0, y) }
end

local function setWidgetPosition(widget, position, bindToParent)
  if not widget or not position then
    return
  end

  widget:breakAnchors()
  widget:setPosition(position)
  if bindToParent == nil or bindToParent then
    widget:bindRectToParent()
  end
end

local function applyDefaultBottomHudPositions()
  setWidgetPosition(bottomHealthManaHud, getDefaultBottomHudPosition())
end

local function applyBottomHudSeparation(value)
  bottomHudSeparation = clamp(value or DEFAULT_BOTTOM_HUD_SEPARATION, 0, 100)

  if not bottomHealthBarBackground or not bottomManaBarBackground or not bottomHealthOrbIcon or not bottomManaOrbIcon then
    return
  end

  local effectiveSeparation = math.floor((MAX_BOTTOM_HUD_EFFECTIVE_PERCENT * bottomHudSeparation) / 100)
  local offset = math.floor((MAX_BOTTOM_HUD_SEPARATION * effectiveSeparation) / MAX_BOTTOM_HUD_EFFECTIVE_PERCENT)

  bottomHealthBarBackground:setMarginLeft(DEFAULT_BOTTOM_HEALTH_BAR_MARGIN_LEFT - offset)
  bottomHealthOrbIcon:setMarginLeft(DEFAULT_BOTTOM_HEALTH_ICON_MARGIN_LEFT - offset)
  bottomManaBarBackground:setMarginRight(DEFAULT_BOTTOM_MANA_BAR_MARGIN_RIGHT - offset)
  bottomManaOrbIcon:setMarginRight(DEFAULT_BOTTOM_MANA_ICON_MARGIN_RIGHT - offset)
end

local function getHealthInfoSettings()
  return g_settings.getNode('game_healthinfo') or {}
end

local function restoreBottomHudPosition()
  local settings = getHealthInfoSettings()
  if bottomHealthManaHud and settings.bottomHudX ~= nil and settings.bottomHudY ~= nil then
    bottomHudSavedPosition = { x = settings.bottomHudX, y = settings.bottomHudY }
    setWidgetPosition(bottomHealthManaHud, bottomHudSavedPosition)
  else
    setWidgetPosition(bottomHealthManaHud, getDefaultBottomHudPosition())
  end
  applyBottomHudSeparation(settings.bottomHudSeparation or DEFAULT_BOTTOM_HUD_SEPARATION)

  bottomHudPositionRestored = true
end

local function hasSavedBottomHudPosition()
  local settings = getHealthInfoSettings()
  return settings.bottomHudX ~= nil and settings.bottomHudY ~= nil
end

function save()
  local settings = getHealthInfoSettings()

  if bottomHudSavedPosition then
    settings.bottomHudX = bottomHudSavedPosition.x
    settings.bottomHudY = bottomHudSavedPosition.y
  elseif bottomHealthManaHud then
    local pos = bottomHealthManaHud:getPosition()
    settings.bottomHudX = pos.x
    settings.bottomHudY = pos.y
  end
  settings.bottomHudSeparation = bottomHudSeparation
  settings.bottomHealthHudX = nil
  settings.bottomHealthHudY = nil
  settings.bottomManaHudX = nil
  settings.bottomManaHudY = nil

  g_settings.setNode('game_healthinfo', settings)
  bottomHudPositionRestored = true
end

function load()
  restoreBottomHudPosition()
end

local function makeBottomHudDraggable(widget, canDragFn, onStopDragging)
  if not widget then
    return
  end

  widget.dragging = false
  widget.dragOffset = { x = 0, y = 0 }

  widget.onMousePress = function(w, mousePos, button)
    if button ~= MouseLeftButton or not canDragFn() then
      return false
    end

    w.dragging = true
    local wPos = w:getPosition()
    w.dragOffset.x = mousePos.x - wPos.x
    w.dragOffset.y = mousePos.y - wPos.y
    return true
  end

  widget.onMouseRelease = function(w, mousePos, button)
    if button ~= MouseLeftButton or not canDragFn() then
      return false
    end

    if w.dragging then
      w.dragging = false
      w:bindRectToParent()
      onStopDragging(w)
      return true
    end

    return false
  end

  widget.onMouseMove = function(w, mousePos, mouseMoved)
    if not w.dragging or not canDragFn() then
      return false
    end

    if not g_mouse.isPressed(MouseLeftButton) then
      w.dragging = false
      w:bindRectToParent()
      onStopDragging(w)
      return false
    end

    local newX = mousePos.x - w.dragOffset.x
    local newY = mousePos.y - w.dragOffset.y
    w:breakAnchors()
    w:setPosition({ x = newX, y = newY })
    w:bindRectToParent()
    return true
  end
end

function setBottomHudUnlocked(value)
  bottomHudDragEnabled = value and true or false
  if bottomHealthManaHud then
    bottomHealthManaHud:setFocusable(bottomHudDragEnabled)
    bottomHealthManaHud:setPhantom(not bottomHudDragEnabled)
  end
  if bottomHealthHud then
    bottomHealthHud:setFocusable(false)
    bottomHealthHud:setPhantom(true)
  end
  if bottomManaHud then
    bottomManaHud:setFocusable(false)
    bottomManaHud:setPhantom(true)
  end
end

function setBottomHudSeparation(value)
  applyBottomHudSeparation(value)
  save()
end

function resetBottomHudPositions()
  bottomHudSavedPosition = nil
  bottomHudSeparation = DEFAULT_BOTTOM_HUD_SEPARATION
  applyDefaultBottomHudPositions()
  applyBottomHudSeparation(DEFAULT_BOTTOM_HUD_SEPARATION)
  save()
end

function init()
  ProtocolGame.registerExtendedOpcode(HARMONY_OPCODE, onHarmonyOpcode)

  connect(LocalPlayer, { onHealthChange = onHealthChange,
                         onManaChange = onManaChange,
                         onLevelChange = onLevelChange,
                         onStatesChange = onStatesChange,
                         onSoulChange = onSoulChange,
                         onFreeCapacityChange = onFreeCapacityChange })

  connect(g_game, { onGameStart = requestHarmonyState,
                    onGameEnd = offline })

  healthInfoWindow = g_ui.loadUI('healthinfo', modules.game_interface.getRightPanel())
  healthInfoWindow:disableResize()
  
  if not healthInfoWindow.forceOpen then
    healthInfoButton = modules.client_topmenu.addRightGameToggleButton('healthInfoButton', tr('Health Information'), '/images/topbuttons/healthinfo', toggle)
    if g_app.isMobile() then
      healthInfoButton:hide()
    else
      healthInfoButton:setOn(true)
    end
  end

  healthBar = healthInfoWindow:recursiveGetChildById('healthBar')
  manaBar = healthInfoWindow:recursiveGetChildById('manaBar')
  experienceBar = healthInfoWindow:recursiveGetChildById('experienceBar')
  soulLabel = healthInfoWindow:recursiveGetChildById('soulLabel')
  capLabel = healthInfoWindow:recursiveGetChildById('capLabel')

  overlay = g_ui.createWidget('HealthOverlay', modules.game_interface.getMapPanel())  
  healthCircleFront = overlay:getChildById('healthCircleFront')
  manaCircleFront = overlay:getChildById('manaCircleFront')
  healthCircle = overlay:getChildById('healthCircle')
  manaCircle = overlay:getChildById('manaCircle')
  arcConditionPanel = overlay:getChildById('arcConditionPanel')
  harmonyHud = overlay:getChildById('harmonyHud')
  topHealthBar = overlay:getChildById('topHealthBar')
  topManaBar = overlay:getChildById('topManaBar')
  bottomHealthManaHud = overlay:getChildById('bottomHealthManaHud')
  bottomHealthHud = overlay:getChildById('bottomHealthHud')
  bottomManaHud = overlay:getChildById('bottomManaHud')
  bottomHealthBarBackground = overlay:recursiveGetChildById('bottomHealthBarBackground')
  bottomManaBarBackground = overlay:recursiveGetChildById('bottomManaBarBackground')
  bottomHealthBarFill = overlay:recursiveGetChildById('bottomHealthBarFill')
  bottomManaBarFill = overlay:recursiveGetChildById('bottomManaBarFill')
  bottomHealthOrbIcon = overlay:recursiveGetChildById('bottomHealthOrbIcon')
  bottomManaOrbIcon = overlay:recursiveGetChildById('bottomManaOrbIcon')
  bottomHealthValueLabel = overlay:recursiveGetChildById('bottomHealthValueLabel')
  bottomManaValueLabel = overlay:recursiveGetChildById('bottomManaValueLabel')
  bottomLevelLabel = overlay:recursiveGetChildById('bottomLevelLabel')
  bottomExperienceFill = overlay:recursiveGetChildById('bottomExperienceFill')
  bottomExperienceLabel = overlay:recursiveGetChildById('bottomExperienceLabel')
  makeBottomHudDraggable(bottomHealthManaHud,
    function() return bottomHudDragEnabled end,
    function(w)
      local pos = w:getPosition()
      bottomHudSavedPosition = { x = pos.x, y = pos.y }
      save()
    end)
  load()
  setBottomHudUnlocked(modules.client_options and modules.client_options.getOption('unlockBottomHealthManaHud'))
  if modules.client_options and modules.client_options.getOption then
    applyBottomHudSeparation(modules.client_options.getOption('bottomHealthManaHudSeparation'))
  end
  
  connect(overlay, { onGeometryChange = onOverlayGeometryChange })
  
  -- load condition icons
  for k,v in pairs(Icons) do
    g_textures.preload(v.path)
  end

  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    onHealthChange(localPlayer, localPlayer:getHealth(), localPlayer:getMaxHealth())
    onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
    onLevelChange(localPlayer, localPlayer:getLevel(), localPlayer:getLevelPercent())
    onStatesChange(localPlayer, localPlayer:getStates(), 0)
    onSoulChange(localPlayer, localPlayer:getSoul())
    onFreeCapacityChange(localPlayer, localPlayer:getFreeCapacity())
  end

  local showArcs = modules.client_options and modules.client_options.getOption and
    modules.client_options.getOption('showHealthManaCircle') or false
  setArcConditionPanelEnabled(showArcs)
  local localPlayer = g_game.getLocalPlayer()
  local isMonk = localPlayer and tonumber(localPlayer:getVocation()) == 6
  updateHarmonyHud(harmonyPoints, harmonyMaximum, harmonyVisible or isMonk)
  if g_game.isOnline() then
    requestHarmonyState()
  end


  hideLabels()
  hideExperience()

  healthInfoWindow:setup()
  
  if g_app.isMobile() then
    healthInfoWindow:close()
    healthInfoButton:setOn(false)  
  end
end

function terminate()
  save()
  ProtocolGame.unregisterExtendedOpcode(HARMONY_OPCODE)

  disconnect(LocalPlayer, { onHealthChange = onHealthChange,
                            onManaChange = onManaChange,
                            onLevelChange = onLevelChange,
                            onStatesChange = onStatesChange,
                            onSoulChange = onSoulChange,
                            onFreeCapacityChange = onFreeCapacityChange })

  disconnect(g_game, { onGameStart = requestHarmonyState,
                       onGameEnd = offline })
  disconnect(overlay, { onGeometryChange = onOverlayGeometryChange })
  
  healthInfoWindow:destroy()
  if healthInfoButton then
    healthInfoButton:destroy()
  end
  overlay:destroy()
end

function toggle()
  if not healthInfoButton then return end
  if healthInfoButton:isOn() then
    healthInfoWindow:close()
    healthInfoButton:setOn(false)
  else
    healthInfoWindow:open()
    healthInfoButton:setOn(true)
  end
end

local function toggleConditionIcon(panel, bitChanged, idPrefix, styleName)
  local iconData = Icons[bitChanged]
  if not panel or not iconData then
    return
  end

  local iconId = (idPrefix or '') .. iconData.id
  local icon = panel:getChildById(iconId)
  if icon then
    icon:destroy()
  else
    icon = g_ui.createWidget(styleName or 'ConditionWidget', panel)
    icon:setId(iconId)
    icon:setImageSource(iconData.path)
    icon:setTooltip(iconData.tooltip)
  end
end

local function updateArcConditionPanel()
  if not arcConditionPanel then
    return
  end

  local iconCount = arcConditionPanel:getChildCount()
  arcConditionPanel:setHeight(8 + (iconCount * 18))
  arcConditionPanel:setVisible(arcConditionsEnabled and iconCount > 0)
end

function setArcConditionPanelEnabled(enabled)
  arcConditionsEnabled = enabled == true
  updateArcConditionPanel()
end

function toggleIcon(bitChanged)
  local content = healthInfoWindow and healthInfoWindow:recursiveGetChildById('conditionPanel')
  toggleConditionIcon(content, bitChanged)
  toggleConditionIcon(arcConditionPanel, bitChanged, 'arc_', 'ArcConditionWidget')
  updateArcConditionPanel()
end

function offline()
  local content = healthInfoWindow and healthInfoWindow:recursiveGetChildById('conditionPanel')
  if content then
    content:destroyChildren()
  end
  if arcConditionPanel then
    arcConditionPanel:destroyChildren()
  end
  updateArcConditionPanel()
  updateHarmonyHud(0, 5, false)
end

-- hooked events
function onMiniWindowClose()
  if healthInfoButton then
    healthInfoButton:setOn(false)
  end
end

local function updateBottomBarFill(widget, percent, alignRight)
  if not widget then
    return
  end

  percent = clamp(percent or 0, 0, 100)
  local totalWidth = 229
  local visibleWidth = math.floor(totalWidth * percent / 100)

  if visibleWidth <= 0 then
    widget:setVisible(false)
    return
  end

  widget:setVisible(true)
  widget:setWidth(visibleWidth)
  if alignRight then
    widget:breakAnchors()
    widget:addAnchor(AnchorTop, 'bottomManaBarBackground', AnchorTop)
    widget:addAnchor(AnchorRight, 'bottomManaBarBackground', AnchorRight)
    widget:setMarginRight(4)
    widget:setMarginTop(6)
  else
    widget:breakAnchors()
    widget:addAnchor(AnchorTop, 'bottomHealthBarBackground', AnchorTop)
    widget:addAnchor(AnchorLeft, 'bottomHealthBarBackground', AnchorLeft)
    widget:setMarginLeft(4)
    widget:setMarginTop(6)
  end
  widget:setImageClip({ x = 0, y = 0, width = visibleWidth, height = widget:getHeight() })
  widget:setImageRect({ x = 0, y = 0, width = visibleWidth, height = widget:getHeight() })
end

local function updateBottomExperience(percent)
  if not bottomExperienceFill then
    return
  end

  percent = clamp(percent or 0, 0, 100)
  local totalWidth = 129
  local visibleWidth = math.floor(totalWidth * percent / 100)

  if visibleWidth <= 0 then
    bottomExperienceFill:setVisible(false)
    return
  end

  bottomExperienceFill:setVisible(true)
  local rect = { x = 0, y = 0, width = visibleWidth, height = 8 }
  bottomExperienceFill:setImageClip(rect)
  bottomExperienceFill:setImageRect(rect)
end

function onHealthChange(localPlayer, health, maxHealth)
  if health > maxHealth then
    maxHealth = health
  end

  healthBar:setText(comma_value(health) .. ' / ' .. comma_value(maxHealth))
  healthBar:setTooltip(tr(healthTooltip, health, maxHealth))
  healthBar:setValue(health, 0, maxHealth)

  topHealthBar:setText(comma_value(health) .. ' / ' .. comma_value(maxHealth))
  topHealthBar:setTooltip(tr(healthTooltip, health, maxHealth))
  topHealthBar:setValue(health, 0, maxHealth)

  local healthPercent = math.floor(g_game.getLocalPlayer():getHealthPercent())
  local Yhppc = math.floor(208 * (1 - (healthPercent / 100)))
  local rect = { x = 0, y = Yhppc, width = 63, height = 208 - Yhppc + 1 }
  healthCircleFront:setImageClip(rect)
  healthCircleFront:setImageRect(rect)

  if healthPercent > 92 then
    healthCircleFront:setImageColor("#00BC00FF")
  elseif healthPercent > 60 then
    healthCircleFront:setImageColor("#50A150FF")
  elseif healthPercent > 30 then
    healthCircleFront:setImageColor("#A1A100FF")
  elseif healthPercent > 8 then
    healthCircleFront:setImageColor("#BF0A0AFF")
  elseif healthPercent > 3 then
    healthCircleFront:setImageColor("#910F0FFF")
  else
    healthCircleFront:setImageColor("#850C0CFF")
  end

  updateBottomBarFill(bottomHealthBarFill, healthPercent, false)
  if bottomHealthValueLabel then
    bottomHealthValueLabel:setText(comma_value(health) .. ' / ' .. comma_value(maxHealth))
  end
end

function onManaChange(localPlayer, mana, maxMana)
  if mana > maxMana then
    maxMana = mana
  end
  
  manaBar:setText(comma_value(mana) .. ' / ' .. comma_value(maxMana))
  manaBar:setTooltip(tr(manaTooltip, mana, maxMana))
  manaBar:setValue(mana, 0, maxMana)

  topManaBar:setText(comma_value(mana) .. ' / ' .. comma_value(maxMana))
  topManaBar:setTooltip(tr(manaTooltip, mana, maxMana))
  topManaBar:setValue(mana, 0, maxMana)

  local Ymppc = math.floor(208 * (1 - (math.floor((maxMana - (maxMana - mana)) * 100 / maxMana) / 100)))
  local rect = { x = 0, y = Ymppc, width = 63, height = 208 - Ymppc + 1 }
  manaCircleFront:setImageClip(rect)
  manaCircleFront:setImageRect(rect)

  local manaPercent = 0
  if maxMana > 0 then
    manaPercent = math.floor((mana * 100) / maxMana)
  end

  updateBottomBarFill(bottomManaBarFill, manaPercent, true)
  if bottomManaValueLabel then
    bottomManaValueLabel:setText(comma_value(mana) .. ' / ' .. comma_value(maxMana))
  end
end

function onLevelChange(localPlayer, value, percent)
  experienceBar:setText(percent .. '%')
  experienceBar:setTooltip(tr(experienceTooltip, percent, value+1))
  experienceBar:setPercent(percent)

  if bottomLevelLabel then
    bottomLevelLabel:setText(tostring(value))
  end

  if bottomExperienceLabel then
    bottomExperienceLabel:setText(percent .. '%')
  end

  updateBottomExperience(percent)
end

function onSoulChange(localPlayer, soul)
  soulLabel:setText(tr('Soul') .. ': ' .. soul)
end

function onFreeCapacityChange(player, freeCapacity)
  capLabel:setText(tr('Cap') .. ': ' .. freeCapacity)
end

function onStatesChange(localPlayer, now, old)
  if now == old then return end

  local bitsChanged = bit32.bxor(now, old)
  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > bitsChanged then break end
    local bitChanged = bit32.band(bitsChanged, pow)
    if bitChanged ~= 0 then
      toggleIcon(bitChanged)
    end
  end
end

-- personalization functions
function hideLabels()
  local content = healthInfoWindow:recursiveGetChildById('conditionPanel')
  local removeHeight = math.max(capLabel:getMarginRect().height, soulLabel:getMarginRect().height) + content:getMarginRect().height - 3
  capLabel:setOn(false)
  soulLabel:setOn(false)
  content:setVisible(false)
  healthInfoWindow:setHeight(math.max(healthInfoWindow.minimizedHeight, healthInfoWindow:getHeight() - removeHeight))
end

function hideExperience()
  local removeHeight = experienceBar:getMarginRect().height
  experienceBar:setOn(false)
  healthInfoWindow:setHeight(math.max(healthInfoWindow.minimizedHeight, healthInfoWindow:getHeight() - removeHeight))
end

function setHealthTooltip(tooltip)
  healthTooltip = tooltip

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    healthBar:setTooltip(tr(healthTooltip, localPlayer:getHealth(), localPlayer:getMaxHealth()))
  end
end

function setManaTooltip(tooltip)
  manaTooltip = tooltip

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    manaBar:setTooltip(tr(manaTooltip, localPlayer:getMana(), localPlayer:getMaxMana()))
  end
end

function setExperienceTooltip(tooltip)
  experienceTooltip = tooltip

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    experienceBar:setTooltip(tr(experienceTooltip, localPlayer:getLevelPercent(), localPlayer:getLevel()+1))
  end
end

function onOverlayGeometryChange() 
  if g_app.isMobile() then
    topHealthBar:setMarginTop(35)
    topManaBar:setMarginTop(35)
    local width = overlay:getWidth() 
    local margin = width / 3 + 10
    topHealthBar:setMarginLeft(margin)
    topManaBar:setMarginRight(margin)    
    return
  end

  local classic = g_settings.getBoolean("classicView")
  local minMargin = 40
  if classic then
    topHealthBar:setMarginTop(15)
    topManaBar:setMarginTop(15)
  else
    topHealthBar:setMarginTop(45 - overlay:getParent():getMarginTop())
    topManaBar:setMarginTop(45 - overlay:getParent():getMarginTop())  
    minMargin = 200
  end

  local height = overlay:getHeight()
  local width = overlay:getWidth()
     
  topHealthBar:setMarginLeft(math.max(minMargin, (width - height + 50) / 2 + 2))
  topManaBar:setMarginRight(math.max(minMargin, (width - height + 50) / 2 + 2))

  if bottomHealthManaHud then
    if hasSavedBottomHudPosition() or not bottomHudPositionRestored then
      restoreBottomHudPosition()
    else
      applyDefaultBottomHudPositions()
      applyBottomHudSeparation(bottomHudSeparation)
    end
  end
end
