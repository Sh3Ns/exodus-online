CharacterList = { }

local VocationString = {
  [0] = "None",
  [1] = "Sorcerer",
  [2] = "Druid",
  [3] = "Paladin",
  [4] = "Knight",
  [5] = "Master Sorcerer",
  [6] = "Elder Druid",
  [7] = "Royal Paladin",
  [8] = "Elite Knight",
  [9] = "Illusionist",
  [10] = "Arch Illusionist",
  [11] = "Monk",
  [12] = "Exalted Monk",
}

-- private variables
local charactersWindow
local loadBox
local characterList
local errorBox
local waitingWindow
local autoReconnectButton
local updateWaitEvent
local resendWaitEvent
local loginEvent
local autoReconnectEvent
local enterButtonAnimationEvent
local carouselAnimationEvent
local initialShowEvent
local responsiveLayoutEvent
local responsiveRootWidget
local lastLogout = 0
local characterListHtmlId
local characterEntries = {}
local selectedCharacterIndex = 1
local characterCreatureWidgets = {}
local finalResizeEvent

local VISIBLE_CHARACTER_LIMIT = 9
local visibleCharacterLimit = VISIBLE_CHARACTER_LIMIT
pvinfo = ''

local function getVocationName(vocationId)
  return VocationString[tonumber(vocationId)] or tostring(vocationId or '')
end

local function htmlWidget(id)
  return charactersWindow and charactersWindow:recursiveGetChildById(id) or nil
end

local function updateAutoReconnectVisual()
  if not autoReconnectButton then return end
  local enabled = g_settings.getBoolean('autoReconnect', true)
  autoReconnectButton:setOn(enabled)
  autoReconnectButton:setText(enabled and 'AUTO RECONNECT: ON' or 'AUTO RECONNECT: OFF')
  autoReconnectButton:setColor(enabled and '#a8d6ab' or '#d6a8a8')
  autoReconnectButton:setImageColor(enabled and '#31563bdd' or '#633636dd')
end

local function stopEnterButtonAnimation()
  if enterButtonAnimationEvent then
    removeEvent(enterButtonAnimationEvent)
    enterButtonAnimationEvent = nil
  end
end

local function stopCarouselAnimation()
  if carouselAnimationEvent then
    removeEvent(carouselAnimationEvent)
    carouselAnimationEvent = nil
  end
end

local function stopInitialShowEvent()
  if initialShowEvent then
    removeEvent(initialShowEvent)
    initialShowEvent = nil
  end
end

local function startEnterButtonAnimation()
  stopEnterButtonAnimation()
  local button = htmlWidget('buttonOk')
  if not button then return end
  local selectedName = htmlWidget('characterName')
  local brandTitle = charactersWindow and charactersWindow:recursiveGetChildById('brandTitle') or nil
  local phase = 0
  enterButtonAnimationEvent = cycleEvent(function()
    if not button or button:isDestroyed() then
      stopEnterButtonAnimation()
      return
    end
    phase = (phase + 1) % 20
    local strength = phase <= 10 and (phase / 10) or ((20 - phase) / 10)
    local bgRed = math.floor(24 + (38 * strength))
    local bgGreen = math.floor(48 + (54 * strength))
    local bgBlue = math.floor(18 + (16 * strength))
    local borderRed = math.floor(180 + (75 * strength))
    local borderGreen = math.floor(132 + (72 * strength))
    local borderBlue = math.floor(42 + (66 * strength))
    button:setBackgroundColor(string.format('#%02x%02x%02xee', bgRed, bgGreen, bgBlue))
    button:setBorderColor(string.format('#%02x%02x%02xff', borderRed, borderGreen, borderBlue))
    button:setOpacity(0.90 + (strength * 0.10))
    button:setColor(strength > 0.45 and '#fff5c8' or '#f1d486')
    if selectedName then
      local nameGreen = math.floor(204 + (48 * strength))
      local nameBlue = math.floor(112 + (78 * strength))
      selectedName:setColor(string.format('#ff%02x%02xff', nameGreen, nameBlue))
      selectedName:setOpacity(0.86 + (strength * 0.14))
    end
    for characterIndex, entry in pairs(characterCreatureWidgets) do
      if entry.nameLabel and not entry.nameLabel:isDestroyed() then
        local wavePhase = (phase + ((characterIndex % 5) * 2)) % 20
        local wave = wavePhase <= 10 and (wavePhase / 10) or ((20 - wavePhase) / 10)
        local greenValue = math.floor(188 + (48 * wave))
        local blueValue = math.floor(105 + (55 * wave))
        entry.nameLabel:setColor(string.format('#f5%02x%02xff', greenValue, blueValue))
      end
    end
    if brandTitle then brandTitle:setOpacity(0.82 + (strength * 0.18)) end
  end, 80)
end

local renderSelectedCharacter
local scheduleResponsiveLayout
local onRootGeometryChange

local function detachResponsiveRoot()
  if responsiveRootWidget and onRootGeometryChange then
    disconnect(responsiveRootWidget, { onGeometryChange = onRootGeometryChange })
  end
  responsiveRootWidget = nil
end

local function buildEllipseLayout(count)
  local layout = {}
  if count <= 1 then
    layout[1] = { x = 50, y = 52, scale = 1.16, depth = 100, angle = math.pi / 2 }
    return layout
  end

  local angleStep = (math.pi * 2) / count
  for role = 1, count do
    local angle
    if role == 1 then
      angle = math.pi / 2
    else
      local distance = math.floor(role / 2)
      local direction = role % 2 == 0 and 1 or -1
      angle = (math.pi / 2) + (direction * distance * angleStep)
    end
    local depthFactor = (math.sin(angle) + 1) / 2
    layout[role] = {
      x = 42 + (22 * math.cos(angle)),
      y = 25 + (18 * math.sin(angle)),
      scale = role == 1 and 1.16 or (0.48 + (0.25 * depthFactor)),
      depth = math.floor(10 + (80 * depthFactor)),
      angle = angle
    }
  end
  layout[1].depth = 100
  return layout
end

local function buildVisualOrder()
  local totalCharacters = #characterEntries
  if totalCharacters == 0 then return {} end

  local visualOrder = { selectedCharacterIndex }
  local visibleCount = math.min(totalCharacters, visibleCharacterLimit)
  local used = { [selectedCharacterIndex] = true }
  for distance = 1, totalCharacters do
    local previousIndex = ((selectedCharacterIndex - distance - 1) % totalCharacters) + 1
    if not used[previousIndex] and #visualOrder < visibleCount then
      visualOrder[#visualOrder + 1] = previousIndex
      used[previousIndex] = true
    end
    local nextIndex = ((selectedCharacterIndex + distance - 1) % totalCharacters) + 1
    if not used[nextIndex] and #visualOrder < visibleCount then
      visualOrder[#visualOrder + 1] = nextIndex
      used[nextIndex] = true
    end
    if #visualOrder >= visibleCount then break end
  end
  return visualOrder
end

local function positionWarbandCharacters()
  local slotsContainer = htmlWidget('characterSlots')
  if not slotsContainer then return end

  local parentWidth = slotsContainer:getWidth()
  local parentHeight = slotsContainer:getHeight()
  if parentWidth < 1 or parentHeight < 1 then return end

  local visualOrder = buildVisualOrder()
  local layout = buildEllipseLayout(#visualOrder)

  for role, characterIndex in ipairs(visualOrder) do
    local entry = characterCreatureWidgets[characterIndex]
    local slot = layout[role]

    if entry and slot and entry.container and not entry.container:isDestroyed() then
      entry.container:setPosition({
        x = math.floor((parentWidth * slot.x) / 100) - 88 + 36,
        y = math.floor((parentHeight * slot.y) / 100) - 149
      })

      entry.angle = slot.angle
      entry.depth = slot.depth
    end
  end
end

local function animateOpacity(widget, targetOpacity, duration, onComplete)
  if not widget or widget:isDestroyed() then return end
  if widget.hoverOpacityEvent then removeEvent(widget.hoverOpacityEvent) end
  local startOpacity = widget:getOpacity()
  local elapsed = 0
  local interval = 20
  duration = duration or 140
  widget.hoverOpacityEvent = cycleEvent(function()
    if not widget or widget:isDestroyed() then
      if widget and widget.hoverOpacityEvent then removeEvent(widget.hoverOpacityEvent) end
      return
    end
    elapsed = math.min(duration, elapsed + interval)
    local progress = elapsed / duration
    widget:setOpacity(startOpacity + ((targetOpacity - startOpacity) * progress))
    if elapsed >= duration then
      removeEvent(widget.hoverOpacityEvent)
      widget.hoverOpacityEvent = nil
      if onComplete then onComplete() end
    end
  end, interval)
end

local function createCharacterSlot(parent, characterIndex, slot, selected)
  local characterInfo = characterEntries[characterIndex]
  if not characterInfo then return nil end

  local stateClass = selected and 'warband-character-selected' or 'warband-character-dim'
  local fragment = string.format([[
    <div class="warband-character %s" style="left: %.2f%%; top: %.2f%%; margin-left: -88; margin-top: -149;">
      <Creature id="warbandCreature%d" class="warband-creature"></Creature>
      <Label id="warbandGuild%d" class="warband-guild"></Label>
      <Label id="warbandName%d" class="warband-name"></Label>
      <Label id="warbandLevel%d" class="warband-level"></Label>
    </div>
  ]], stateClass, slot.x, slot.y, characterIndex, characterIndex, characterIndex, characterIndex)

  local container = g_html.createWidgetFromHTML(fragment, parent, characterListHtmlId)
  if not container then return nil end

  local creature = container:recursiveGetChildById('warbandCreature' .. characterIndex)
  local guildLabel = container:recursiveGetChildById('warbandGuild' .. characterIndex)
  local nameLabel = container:recursiveGetChildById('warbandName' .. characterIndex)
  local levelLabel = container:recursiveGetChildById('warbandLevel' .. characterIndex)
  if not creature or not guildLabel or not nameLabel or not levelLabel then
    container:destroy()
    return nil
  end
  if characterInfo.outfit then
    creature:setOutfit(characterInfo.outfit)
    creature:setScale(slot.scale)
    creature:setCenter(true)
    creature:setOldScaling(true)
    creature:setAnimate(true)
  end
  creature.carouselBaseScale = slot.scale
  creature:setOpacity(selected and 1.0 or 0.68)
  creature:setImageColor(selected and '#ffffffff' or '#aab1b9ff')

  local guildName = characterInfo.guildName or characterInfo.guild or characterInfo.guild_name or ''
  guildLabel:setText(guildName ~= '' and ('[' .. guildName .. ']') or '')
  guildLabel:setVisible(guildName ~= '')
  nameLabel:setText(characterInfo.name or characterInfo.characterName or 'Unknown')
  levelLabel:setText('Level ' .. tostring(characterInfo.level or 1))
  guildLabel:setOpacity(selected and 1.0 or 0.48)
  nameLabel:setOpacity(selected and 1.0 or 0.55)
  levelLabel:setOpacity(selected and 1.0 or 0.50)
  guildLabel:setPhantom(true)
  nameLabel:setPhantom(true)
  levelLabel:setPhantom(true)

  local function updateHover(hovered)
    if carouselAnimationEvent then return end
    local hoverScale = selected and 1.03 or 1.10
    local displayScale = creature.carouselBaseScale or slot.scale
    creature:setScale(displayScale * (hovered and hoverScale or 1.0))
    animateOpacity(creature, selected and 1.0 or (hovered and 0.9 or 0.60), 120)
    creature:setImageColor((selected or hovered) and '#ffffffff' or '#a0a7b0ff')
    animateOpacity(nameLabel, (selected or hovered) and 1.0 or 0.55, 140)
    animateOpacity(guildLabel, (selected or hovered) and 1.0 or 0.48, 140)
    animateOpacity(levelLabel, (selected or hovered) and 1.0 or 0.50, 140)
  end
  container.onHoverChange = function(_, hovered) updateHover(hovered) end
  creature.onHoverChange = function(_, hovered) updateHover(hovered) end

  local function selectCharacter()
    addEvent(function()
      if CharacterList and charactersWindow then CharacterList.selectIndex(characterIndex) end
    end)
    return true
  end
  container.onClick = selectCharacter
  creature.onClick = selectCharacter

  return {
    container = container,
    creature = creature,
    guildLabel = guildLabel,
    nameLabel = nameLabel,
    levelLabel = levelLabel,
    characterIndex = characterIndex,
    baseScale = slot.scale,
    angle = slot.angle,
    depth = slot.depth
  }
end

local function renderWarbandCharacters()
  local slotsContainer = htmlWidget('characterSlots')
  if not slotsContainer or not characterListHtmlId then return end

  slotsContainer:destroyChildren()
  characterCreatureWidgets = {}

  local visualOrder = buildVisualOrder()
  local layout = buildEllipseLayout(#visualOrder)
  local pending = {}
  for role, characterIndex in ipairs(visualOrder) do
    pending[#pending + 1] = {
      characterIndex = characterIndex,
      slot = layout[role],
      selected = role == 1
    }
  end
  table.sort(pending, function(a, b) return a.slot.depth < b.slot.depth end)

  for _, entry in ipairs(pending) do
    local created = createCharacterSlot(slotsContainer, entry.characterIndex, entry.slot, entry.selected)
    if created then characterCreatureWidgets[entry.characterIndex] = created end
  end

  positionWarbandCharacters()
end

renderSelectedCharacter = function()
  local count = #characterEntries
  if count == 0 then return end

  if selectedCharacterIndex < 1 then selectedCharacterIndex = count end
  if selectedCharacterIndex > count then selectedCharacterIndex = 1 end
  local characterInfo = characterEntries[selectedCharacterIndex]
  if not characterInfo then return end

  local name = characterInfo.name or characterInfo.characterName or 'Unknown Character'
  local guildName = characterInfo.guildName or characterInfo.guild or characterInfo.guild_name or ''

  local fields = {
    characterGuild = guildName ~= '' and ('[' .. guildName .. ']') or '',
    characterName = name,
    characterLevel = string.format('Level %s', tostring(characterInfo.level or 1)),
    characterVocation = getVocationName(characterInfo.vocation),
    characterCounter = string.format('%d / %d', selectedCharacterIndex, count)
  }
  for id, value in pairs(fields) do
    local target = htmlWidget(id)
    if target then
      target:setText(value)
      if id == 'characterGuild' then target:setVisible(value ~= '') end
    end
  end

  renderWarbandCharacters()
  if scheduleResponsiveLayout then scheduleResponsiveLayout() end
end

local function playCharacterListIntro()
  local widgets = {
    htmlWidget('topHud'),
    htmlWidget('accountBadge'),
    htmlWidget('selectionConsole'),
    htmlWidget('bottomActions')
  }

  for _, widget in ipairs(widgets) do
    if widget and not widget:isDestroyed() then
      widget:setOpacity(0)
      animateOpacity(widget, 1.0, 240)
    end
  end

  local delay = 0
  for _, entry in pairs(characterCreatureWidgets) do
    if entry.container and not entry.container:isDestroyed() then
      entry.container:setOpacity(0)
      scheduleEvent(function()
        if entry.container and not entry.container:isDestroyed() then
          animateOpacity(entry.container, 1.0, 260)
        end
      end, delay)
      delay = delay + 35
    end
  end
end

local function animateCharacterSelection(newIndex)
  if carouselAnimationEvent or newIndex == selectedCharacterIndex or #characterEntries == 0 then return end
  local slotsContainer = htmlWidget('characterSlots')
  if not slotsContainer then
    selectedCharacterIndex = newIndex
    renderSelectedCharacter()
    return
  end

  selectedCharacterIndex = newIndex
  local visualOrder = buildVisualOrder()
  local layout = buildEllipseLayout(#visualOrder)
  local motions = {}
  local parentX = slotsContainer:getX()
  local parentY = slotsContainer:getY()
  local parentWidth = slotsContainer:getWidth()
  local parentHeight = slotsContainer:getHeight()
  local selectedInfo = htmlWidget('selectedCharacterInfo')
  if selectedInfo then animateOpacity(selectedInfo, 0.18, 110) end

  for role, characterIndex in ipairs(visualOrder) do
    local entry = characterCreatureWidgets[characterIndex]
    if entry and entry.container and not entry.container:isDestroyed() then
      local startPosition = entry.container:getPosition()
      local slot = layout[role]
      local angleDelta = slot.angle - (entry.angle or slot.angle)
      while angleDelta > math.pi do angleDelta = angleDelta - (math.pi * 2) end
      while angleDelta < -math.pi do angleDelta = angleDelta + (math.pi * 2) end
      motions[#motions + 1] = {
        entry = entry,
        startX = startPosition.x,
        startY = startPosition.y,
        targetX = math.floor((parentWidth * slot.x) / 100) - 88 + 36,
        targetY = math.floor((parentHeight * slot.y) / 100) - 149,
        startAngle = entry.angle,
        angleDelta = angleDelta,
        startScale = entry.creature:getScale(),
        targetScale = slot.scale,
        startOpacity = entry.creature:getOpacity(),
        targetOpacity = role == 1 and 1.0 or 0.60,
        startContainerOpacity = entry.container:getOpacity(),
        targetContainerOpacity = role == 1 and 1.0 or 0.72
      }
      entry.creature:setImageColor(role == 1 and '#ffffffff' or '#a0a7b0ff')
      if role == 1 then entry.container:raise() end
      entry.container:setPhantom(true)
    end
  end

  if #motions == 0 then
    renderSelectedCharacter()
    return
  end

  local frame = 0
  local totalFrames = 14
  carouselAnimationEvent = cycleEvent(function()
    frame = frame + 1
    local progress = math.min(1, frame / totalFrames)
    local eased = 1 - ((1 - progress) ^ 3)
    for _, motion in ipairs(motions) do
      if motion.entry.container and not motion.entry.container:isDestroyed() then
        local x
        local y
        if motion.startAngle then
          local angle = motion.startAngle + (motion.angleDelta * eased)
          x = math.floor(parentWidth * (0.50 + (0.28 * math.cos(angle)))) - 88 + 36
          y = math.floor(parentHeight * (0.34 + (0.18 * math.sin(angle)))) - 149
        else
          x = math.floor(motion.startX + ((motion.targetX - motion.startX) * eased))
          y = math.floor(motion.startY + ((motion.targetY - motion.startY) * eased))
        end
        motion.entry.container:setPosition({ x = x, y = y })
        motion.entry.creature:setScale(motion.startScale + ((motion.targetScale - motion.startScale) * eased))
        motion.entry.creature:setOpacity(motion.startOpacity + ((motion.targetOpacity - motion.startOpacity) * eased))
        local fadeWave = progress < 0.50 and (1 - (progress * 1.20)) or (0.40 + ((progress - 0.50) * 1.20))
        motion.entry.container:setOpacity(math.min(1.0, motion.targetContainerOpacity * fadeWave))
      end
    end
    if frame >= totalFrames then
      stopCarouselAnimation()
      renderSelectedCharacter()
      local refreshedInfo = htmlWidget('selectedCharacterInfo')
      if refreshedInfo then
        refreshedInfo:setOpacity(0.25)
        animateOpacity(refreshedInfo, 1.0, 160)
      end
    end
  end, 16)
end

local function applyResponsiveLayout()
  responsiveLayoutEvent = nil
  if not charactersWindow or charactersWindow:isDestroyed() then return end

  local applicationRoot = g_ui.getRootWidget()
  if not applicationRoot then return end
  local rootWidth = applicationRoot:getWidth()
  local rootHeight = applicationRoot:getHeight()
  if rootWidth < 1 or rootHeight < 1 then return end

  charactersWindow:setPosition({ x = 0, y = 0 })
  charactersWindow:setSize({ width = rootWidth, height = rootHeight })

  local compact = rootWidth < 1000 or rootHeight < 650
  local tiny = rootWidth < 760 or rootHeight < 500
  local sceneWidth = rootWidth
  local sceneHeight = rootHeight

  local scene = htmlWidget('warbandScene')
  if scene then
    scene:setPosition({ x = 0, y = 0 })
    scene:setSize({ width = sceneWidth, height = sceneHeight })
  end

  local topHud = htmlWidget('topHud')
  local accountBadge = htmlWidget('accountBadge')
  local slots = htmlWidget('characterSlots')
  local bottomHud = htmlWidget('bottomHud')
  local bottomFade = htmlWidget('sceneBottomFade')
  local selectionConsole = htmlWidget('selectionConsole')
  local selectedInfo = htmlWidget('selectedCharacterInfo')
  local selectedGuild = htmlWidget('characterGuild')
  local selectedVocation = htmlWidget('characterVocation')
  local selectedLevel = htmlWidget('characterLevel')
  local selectedCounter = htmlWidget('characterCounter')
  local bottomActions = htmlWidget('bottomActions')
  local previousButton = htmlWidget('previousCharacter')
  local nextButton = htmlWidget('nextCharacter')

  if topHud then
    topHud:setVisible(not tiny)
    topHud:setTop(compact and 10 or 22)
    topHud:setLeft(compact and 16 or 34)
    topHud:setRight(compact and 16 or 34)
    topHud:setHeight(compact and 52 or 70)
  end
  if accountBadge then accountBadge:setVisible(not compact and sceneWidth >= 900) end

  local footerHeight = tiny and 132 or (compact and 180 or 206)
  if bottomHud then
    bottomHud:setLeft(tiny and 18 or math.max(80, math.floor(sceneWidth * 0.07)))
    bottomHud:setRight(tiny and 18 or math.max(80, math.floor(sceneWidth * 0.07)))
    bottomHud:setBottom(tiny and 6 or (compact and 12 or 24))
    bottomHud:setHeight(footerHeight)
  end
  if bottomFade then bottomFade:setHeight(footerHeight + (tiny and 80 or 100)) end

  if slots then
    local slotInset = tiny and 12 or math.max(48, math.floor(sceneWidth * 0.05))
    slots:setLeft(slotInset)
    slots:setRight(slotInset)
    slots:setTop(tiny and 12 or (compact and 58 or 92))
    slots:setBottom(footerHeight + (tiny and 42 or (compact and 54 or 70)))
  end

  if selectionConsole then
    local consoleWidth = tiny and math.min(360, math.max(280, math.floor(sceneWidth * 0.62))) or
      (compact and math.min(620, math.floor(sceneWidth * 0.48)) or 680)
    selectionConsole:setWidth(consoleWidth)
    selectionConsole:setMarginLeft(0)
    selectionConsole:setHeight(tiny and 94 or 130)
  end
  if previousButton then
    previousButton:setWidth(tiny and 82 or 112)
    previousButton:setText(tiny and 'PREV' or 'PREVIOUS')
  end
  if nextButton then
    nextButton:setWidth(tiny and 82 or 112)
    nextButton:setText('NEXT')
  end
  if selectedInfo then selectedInfo:setHeight(tiny and 92 or 126) end

  if selectedGuild then
    selectedGuild:setVisible(selectedGuild:getText() ~= '')
  end
  if selectedVocation then selectedVocation:setVisible(true) end
  if selectedLevel then selectedLevel:setVisible(true) end
  if selectedCounter then selectedCounter:setVisible(true) end

  if bottomActions then
    local actionWidth = tiny and math.min(360, math.max(300, math.floor(sceneWidth * 0.88))) or
      (compact and math.min(600, math.floor(sceneWidth * 0.58)) or 660)
    bottomActions:setWidth(actionWidth)
    bottomActions:setMarginLeft(0)
  end
  if autoReconnectButton then autoReconnectButton:setVisible(not tiny and sceneWidth >= 720) end

  local newLimit = tiny and 5 or VISIBLE_CHARACTER_LIMIT
  if newLimit ~= visibleCharacterLimit then
    visibleCharacterLimit = newLimit
    renderWarbandCharacters()
  end

  local scaleFactor = tiny and 0.72 or 1.0
  for _, entry in pairs(characterCreatureWidgets) do
    if entry.creature and not entry.creature:isDestroyed() then
      entry.creature:setScale(entry.baseScale * scaleFactor)
      entry.creature.carouselBaseScale = entry.baseScale * scaleFactor
    end
  end
  positionWarbandCharacters()
end

scheduleResponsiveLayout = function()
  if responsiveLayoutEvent then removeEvent(responsiveLayoutEvent) end
  responsiveLayoutEvent = addEvent(applyResponsiveLayout)
end

onRootGeometryChange = function()
  scheduleResponsiveLayout()

  if finalResizeEvent then
    removeEvent(finalResizeEvent)
  end

  finalResizeEvent = scheduleEvent(function()
    finalResizeEvent = nil

    if not charactersWindow or charactersWindow:isDestroyed() then
      return
    end

    applyResponsiveLayout()

    -- Rebuild using the final characterSlots geometry.
    renderWarbandCharacters()

    -- Ensure final positions after recreation.
    positionWarbandCharacters()
  end, 120)
end

function CharacterList.selectRelative(direction)
  if #characterEntries == 0 then return end
  local newIndex = selectedCharacterIndex + (tonumber(direction) or 0)
  if newIndex < 1 then newIndex = #characterEntries end
  if newIndex > #characterEntries then newIndex = 1 end
  animateCharacterSelection(newIndex)
end

function CharacterList.selectIndex(index)
  local newIndex = tonumber(index)
  if not newIndex or not characterEntries[newIndex] then return end
  animateCharacterSelection(newIndex)
end

local function focusCharacterSibling(widget, direction)
  if not characterList or not widget then
    return false
  end

  local children = characterList:getChildren()
  local childCount = #children
  if childCount == 0 then
    return false
  end

  local currentIndex
  for i = 1, childCount do
    if children[i] == widget then
      currentIndex = i
      break
    end
  end

  if not currentIndex then
    return false
  end

  local targetIndex = currentIndex + direction
  if targetIndex < 1 or targetIndex > childCount then
    return true
  end

  local targetWidget = children[targetIndex]
  if not targetWidget then
    return false
  end

  characterList:focusChild(targetWidget, KeyboardFocusReason)
  characterList:ensureChildVisible(targetWidget)
  return true
end

local function handleCharacterListKeyPress(widget, keyCode)
  if keyCode == KeyUp then
    return focusCharacterSibling(widget, -1)
  elseif keyCode == KeyDown then
    return focusCharacterSibling(widget, 1)
  elseif keyCode == KeyEnter then
    CharacterList.doLogin()
    return true
  elseif keyCode == KeyEscape then
    CharacterList.hide(true)
    return true
  end

  return false
end

-- private functions
local function tryLogin(charInfo, tries)
  tries = tries or 1

  if tries > 50 then
    return
  end

  if g_game.isOnline() then
    if tries == 1 then
      g_game.safeLogout()
    end
    loginEvent = scheduleEvent(function() tryLogin(charInfo, tries+1) end, 100)
    return
  end

  CharacterList.hide()
  g_game.loginWorld(G.account, G.password, charInfo.worldName, charInfo.worldHost, charInfo.worldPort, charInfo.characterName, G.authenticatorToken, G.sessionKey)
  g_logger.info("Login to " .. charInfo.worldHost .. ":" .. charInfo.worldPort)
  loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to game server...'))
  connect(loadBox, { onCancel = function()
        loadBox = nil
        g_game.cancelLogin()
        CharacterList.show()
      end })

  -- save last used character
  g_settings.set('last-used-character', charInfo.characterName)
  g_settings.set('last-used-world', charInfo.worldName)
end

local function updateWait(timeStart, timeEnd)
  if waitingWindow then
    local time = g_clock.seconds()
    if time <= timeEnd then
      local percent = ((time - timeStart) / (timeEnd - timeStart)) * 100
      local timeStr = string.format("%.0f", timeEnd - time)

      local progressBar = waitingWindow:getChildById('progressBar')
      progressBar:setPercent(percent)

      local label = waitingWindow:getChildById('timeLabel')
      label:setText(tr('Trying to reconnect in %s seconds.', timeStr))

      updateWaitEvent = scheduleEvent(function() updateWait(timeStart, timeEnd) end, 1000 * progressBar:getPercentPixels() / 100 * (timeEnd - timeStart))
      return true
    end
  end

  if updateWaitEvent then
    updateWaitEvent:cancel()
    updateWaitEvent = nil
  end
end

local function resendWait()
  if waitingWindow then
    waitingWindow:destroy()
    waitingWindow = nil

    if updateWaitEvent then
      updateWaitEvent:cancel()
      updateWaitEvent = nil
    end

    if charactersWindow then
      local selected = characterEntries[selectedCharacterIndex]
      if selected then
        local charInfo = { worldHost = selected.worldIp or selected.worldHost,
          worldPort = selected.worldPort,
          worldName = selected.worldName,
          characterName = selected.name or selected.characterName }
        tryLogin(charInfo)
      end
    end
  end
end

local function onLoginWait(message, time)
  CharacterList.destroyLoadBox()

  waitingWindow = g_ui.displayUI('waitinglist')

  local label = waitingWindow:getChildById('infoLabel')
  label:setText(message)

  updateWaitEvent = scheduleEvent(function() updateWait(g_clock.seconds(), g_clock.seconds() + time) end, 0)
  resendWaitEvent = scheduleEvent(resendWait, time * 1000)
end

function onGameLoginError(message)
  CharacterList.destroyLoadBox()
  errorBox = displayErrorBox(tr("Login Error"), message)
  errorBox.onOk = function()
    errorBox = nil
    CharacterList.showAgain()
  end
  scheduleAutoReconnect()
end

function onGameLoginToken(unknown)
  CharacterList.destroyLoadBox()
  -- TODO: make it possible to enter a new token here / prompt token
  errorBox = displayErrorBox(tr("Two-Factor Authentification"), 'A new authentification token is required.\nPlease login again.')
  errorBox.onOk = function()
    errorBox = nil
    EnterGame.show()
  end
end

function onGameConnectionError(message, code)
  CharacterList.destroyLoadBox()
  if (not g_game.isOnline() or code ~= 2) and not errorBox then -- code 2 is normal disconnect, end of file
    local text = translateNetworkError(code, g_game.getProtocolGame() and g_game.getProtocolGame():isConnecting(), message)
    errorBox = displayErrorBox(tr("Connection Error"), text)
    errorBox.onOk = function()
      errorBox = nil
      CharacterList.showAgain()
    end
  end
  scheduleAutoReconnect()
end

function onGameUpdateNeeded(signature)
  CharacterList.destroyLoadBox()
  errorBox = displayErrorBox(tr("Update needed"), tr('Enter with your account again to update your client.'))
  errorBox.onOk = function()
    errorBox = nil
    CharacterList.showAgain()
  end
end

function onGameEnd()
  scheduleAutoReconnect()
  CharacterList.showAgain()
end

function onLogout()
  lastLogout = g_clock.millis()
end

function scheduleAutoReconnect()
  if lastLogout + 2000 > g_clock.millis() then
    return
  end
  if autoReconnectEvent then
    removeEvent(autoReconnectEvent)
  end
  autoReconnectEvent = scheduleEvent(executeAutoReconnect, 2500)
end

function executeAutoReconnect()
  if not autoReconnectButton or not autoReconnectButton:isOn() or g_game.isOnline() then
    return
  end
  if errorBox then
    errorBox:destroy()
    errorBox = nil
  end
  CharacterList.doLogin()
end

-- public functions
function CharacterList.init()
  if USE_NEW_ENERGAME then return end
  connect(g_game, { onLoginError = onGameLoginError })
  connect(g_game, { onLoginToken = onGameLoginToken })
  connect(g_game, { onUpdateNeeded = onGameUpdateNeeded })
  connect(g_game, { onConnectionError = onGameConnectionError })
  connect(g_game, { onGameStart = CharacterList.destroyLoadBox })
  connect(g_game, { onLoginWait = onLoginWait })
  connect(g_game, { onGameEnd = onGameEnd })
  connect(g_game, { onLogout = onLogout })

  if G.characters then
    CharacterList.create(G.characters, G.characterAccount)
  end
end

function CharacterList.terminate()
 if USE_NEW_ENERGAME then return end
  stopEnterButtonAnimation()
  stopCarouselAnimation()
  stopInitialShowEvent()
  if responsiveLayoutEvent then
    removeEvent(responsiveLayoutEvent)
    responsiveLayoutEvent = nil
  end
  if finalResizeEvent then
    removeEvent(finalResizeEvent)
    finalResizeEvent = nil
  end
  detachResponsiveRoot()
  disconnect(g_game, { onLoginError = onGameLoginError })
  disconnect(g_game, { onLoginToken = onGameLoginToken })
  disconnect(g_game, { onUpdateNeeded = onGameUpdateNeeded })
  disconnect(g_game, { onConnectionError = onGameConnectionError })
  disconnect(g_game, { onGameStart = CharacterList.destroyLoadBox })
  disconnect(g_game, { onLoginWait = onLoginWait })
  disconnect(g_game, { onGameEnd = onGameEnd })
  disconnect(g_game, { onLogout = onLogout })

  if characterListHtmlId then
    g_html.destroy(characterListHtmlId)
    characterListHtmlId = nil
    characterList = nil
    charactersWindow = nil
    characterEntries = {}
    characterCreatureWidgets = {}
  elseif charactersWindow then
    characterList = nil
    charactersWindow:destroy()
    charactersWindow = nil
    characterCreatureWidgets = {}
  end

  if loadBox then
    g_game.cancelLogin()
    loadBox:destroy()
    loadBox = nil
  end

  if waitingWindow then
    waitingWindow:destroy()
    waitingWindow = nil
  end

  if updateWaitEvent then
    removeEvent(updateWaitEvent)
    updateWaitEvent = nil
  end

  if resendWaitEvent then
    removeEvent(resendWaitEvent)
    resendWaitEvent = nil
  end

  if loginEvent then
    removeEvent(loginEvent)
    loginEvent = nil
  end
  

  CharacterList = nil
end

function CharacterList.create(characters, account, otui)
  stopEnterButtonAnimation()
  stopCarouselAnimation()
  stopInitialShowEvent()
  detachResponsiveRoot()
  if characterListHtmlId then
    g_html.destroy(characterListHtmlId)
    characterListHtmlId = nil
  elseif charactersWindow then
    charactersWindow:destroy()
  end
  if finalResizeEvent then
    removeEvent(finalResizeEvent)
    finalResizeEvent = nil
  end
  characterListHtmlId = g_html.load('client_entergame', 'characterlist.html', g_ui.getRootWidget())
  charactersWindow = characterListHtmlId and g_html.getRootWidget(characterListHtmlId) or nil
  characterList = nil
  characterEntries = characters or {}
  selectedCharacterIndex = 1
  visibleCharacterLimit = VISIBLE_CHARACTER_LIMIT
  characterCreatureWidgets = {}

  if not charactersWindow then
    g_logger.error('Unable to load the HTML character selector.')
    characterListHtmlId = nil
    return
  end

  autoReconnectButton = htmlWidget('autoReconnect')
  local characterSlots = htmlWidget('characterSlots')
  local previousButton = htmlWidget('previousCharacter')
  local nextButton = htmlWidget('nextCharacter')
  local enterButton = htmlWidget('buttonOk')
  local cancelButton = htmlWidget('buttonCancel')

  if not autoReconnectButton or not characterSlots or not previousButton or
      not nextButton or not enterButton or not cancelButton then
    g_logger.error('The HTML character selector is missing required widgets.')
    g_html.destroy(characterListHtmlId)
    characterListHtmlId = nil
    charactersWindow = nil
    return
  end

  G.characters = characterEntries
  G.characterAccount = account

  local lastCharacter = g_settings.get('last-used-character')
  local lastWorld = g_settings.get('last-used-world')
  for index, characterInfo in ipairs(characterEntries) do
    local name = characterInfo.name or characterInfo.characterName or tostring(index)
    if name == lastCharacter and characterInfo.worldName == lastWorld then
      selectedCharacterIndex = index
    end
  end

  previousButton.onClick = function()
    CharacterList.selectRelative(-1)
    return true
  end
  nextButton.onClick = function()
    CharacterList.selectRelative(1)
    return true
  end
  enterButton.onClick = function()
    CharacterList.doLogin()
    return true
  end
  cancelButton.onClick = function()
    CharacterList.hide(true)
    return true
  end
  autoReconnectButton.onClick = function()
    g_settings.set('autoReconnect', not g_settings.getBoolean('autoReconnect', true))
    updateAutoReconnectVisual()
    return true
  end

  responsiveRootWidget = g_ui.getRootWidget()
  if responsiveRootWidget then
    connect(responsiveRootWidget, { onGeometryChange = onRootGeometryChange })
  end

  g_keyboard.bindKeyPress('Left', function() CharacterList.selectRelative(-1) return true end, charactersWindow)
  g_keyboard.bindKeyPress('Right', function() CharacterList.selectRelative(1) return true end, charactersWindow)
  g_keyboard.bindKeyPress('Up', function() CharacterList.selectRelative(-1) return true end, charactersWindow)
  g_keyboard.bindKeyPress('Down', function() CharacterList.selectRelative(1) return true end, charactersWindow)
  g_keyboard.bindKeyPress('Enter', function() CharacterList.doLogin() return true end, charactersWindow)
  g_keyboard.bindKeyPress('Escape', function() CharacterList.hide(true) return true end, charactersWindow)

  local accountStatusLabel = htmlWidget('accountStatusLabel')
  local status = ''
  if account.status == AccountStatus.Frozen then
    status = tr(' (Frozen)')
  elseif account.status == AccountStatus.Suspended then
    status = tr(' (Suspended)')
  end

  local accountText
  if account.subStatus == SubscriptionStatus.Free and account.premDays < 1 then
    accountText = ('%s%s'):format(tr('Free Account'), status)
  elseif account.premDays == 0 or account.premDays == 65535 then
    accountText = ('%s%s'):format(tr('Heldor Premium'), status)
  else
    accountText = ('%s%s'):format(tr('Premium Account (%s) days left', account.premDays), status)
  end
  if accountStatusLabel then
    accountStatusLabel:setText(accountText)
    accountStatusLabel:setColor(account.premDays > 0 and account.premDays <= 7 and '#ef9a78' or '#dce7d6')
  end

  updateAutoReconnectVisual()
  applyResponsiveLayout()
  renderSelectedCharacter()
  applyResponsiveLayout()
  charactersWindow:hide()
end

function CharacterList.destroy()
  CharacterList.hide(true)
  detachResponsiveRoot()

  if characterListHtmlId then
    g_html.destroy(characterListHtmlId)
    characterListHtmlId = nil
    characterList = nil
    charactersWindow = nil
    characterEntries = {}
    characterCreatureWidgets = {}
  elseif charactersWindow then
    characterList = nil
    charactersWindow:destroy()
    charactersWindow = nil
    characterCreatureWidgets = {}
  end
end

function CharacterList.show()
  if loadBox or errorBox or not charactersWindow then return end
  stopInitialShowEvent()
  charactersWindow:hide()
  updateAutoReconnectVisual()
  applyResponsiveLayout()
  initialShowEvent = addEvent(function()
    initialShowEvent = nil
    if not charactersWindow or charactersWindow:isDestroyed() then return end
    renderSelectedCharacter()
    applyResponsiveLayout()
    charactersWindow:show()
    charactersWindow:raise()
    charactersWindow:focus()
    playCharacterListIntro()
    startEnterButtonAnimation()
  end)
end

function CharacterList.hide(showLogin)
  stopEnterButtonAnimation()
  stopCarouselAnimation()
  stopInitialShowEvent()
  removeEvent(autoReconnectEvent)
  autoReconnectEvent = nil

  showLogin = showLogin or false
  if charactersWindow then charactersWindow:hide() end

  if showLogin and EnterGame and not g_game.isOnline() then
    EnterGame.show()
  end
end

function CharacterList.showAgain()
  if charactersWindow and #characterEntries > 0 then
    CharacterList.show()
  end
end

function CharacterList.isVisible()
  if charactersWindow and charactersWindow:isVisible() then
    return true
  end
  return false
end

function CharacterList.doLogin()
  removeEvent(autoReconnectEvent)
  autoReconnectEvent = nil

  local selected = characterEntries[selectedCharacterIndex]
  if selected then
    local charInfo = { worldHost = selected.worldIp or selected.worldHost,
      worldPort = selected.worldPort,
      worldName = selected.worldName,
      characterName = selected.name or selected.characterName }
    charactersWindow:hide()
    if loginEvent then
      removeEvent(loginEvent)
      loginEvent = nil
    end
    tryLogin(charInfo)
  else
    displayErrorBox(tr('Error'), tr('You must select a character to login!'))
  end
end

function CharacterList.destroyLoadBox()
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end
end

function CharacterList.cancelWait()
  if waitingWindow then
    waitingWindow:destroy()
    waitingWindow = nil
  end

  if updateWaitEvent then
    removeEvent(updateWaitEvent)
    updateWaitEvent = nil
  end

  if resendWaitEvent then
    removeEvent(resendWaitEvent)
    resendWaitEvent = nil
  end

  CharacterList.destroyLoadBox()
  CharacterList.showAgain()
end
