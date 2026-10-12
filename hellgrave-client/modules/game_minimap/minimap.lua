minimapWidget = nil
minimapButton = nil
minimapWindow = nil
fullmapView = false
loaded = false
oldZoom = nil
oldPos = nil
worldMapWindow = nil
worldMapMinimap = nil
worldMapButton = nil

local function sanitizeMinimapProfileSegment(value)
  value = tostring(value or ''):trim():lower()
  value = value:gsub('[^%w%-_]+', '_')
  value = value:gsub('_+', '_')
  value = value:gsub('^_+', '')
  value = value:gsub('_+$', '')
  return value
end

local function getCharacterMinimapBaseName()
  local characterName = sanitizeMinimapProfileSegment(g_game.getCharacterName())
  if characterName == '' then
    return nil
  end

  local worldName = sanitizeMinimapProfileSegment(g_game.getWorldName and g_game.getWorldName() or '')
  if worldName ~= '' then
    return string.format('/minimap_%s_%s', worldName, characterName)
  end

  return string.format('/minimap_%s', characterName)
end

function init()
  minimapWindow = g_ui.loadUI('minimap', modules.game_interface.getRightPanel())
  minimapWindow:setContentMinimumHeight(64)

  if not minimapWindow.forceOpen then
    minimapButton = modules.client_topmenu.addRightGameToggleButton('minimapButton', 
      tr('Minimap') .. ' (Ctrl+M)', '/images/topbuttons/minimap', toggle)
    minimapButton:setOn(true)
  end

  minimapWidget = minimapWindow:recursiveGetChildById('minimap')
  worldMapWindow = g_ui.loadUI('worldmap', modules.game_interface.getRootPanel())

  if worldMapWindow then
    worldMapWindow:setup()
    worldMapWindow:hide()
    worldMapWindow:centerIn('parent')

    worldMapMinimap = worldMapWindow:recursiveGetChildById('worldMapMinimap')

    if not worldMapMinimap then
      print("WARNING: worldMapMinimap not found in worldmap.otui")
    end
  else
      print("WARNING: worldmap.otui failed to load")
  end

  worldMapButton = modules.client_topmenu.addRightGameToggleButton(
    'worldMapButton',
    tr('World Map'),
    '/images/topbuttons/worldmap',
    toggleFullMap,
    false,
    3
  )
  connect(worldMapWindow, {
    onClose = function()
      fullmapView = false
      if worldMapButton then
        worldMapButton:setOn(false)
      end
    end
  })
  g_keyboard.bindKeyDown('Escape', function()
    if worldMapWindow and worldMapWindow:isVisible() then
      worldMapWindow:hide()
      fullmapView = false
      if worldMapButton then
        worldMapButton:setOn(false)
      end
    end
  end)
  local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.bindKeyPress('Alt+Left', function() minimapWidget:move(1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Right', function() minimapWidget:move(-1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Up', function() minimapWidget:move(0,1) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Down', function() minimapWidget:move(0,-1) end, gameRootPanel)
  g_keyboard.bindKeyDown('Ctrl+M', toggle)
  g_keyboard.bindKeyDown('Ctrl+Shift+M', toggleFullMap)

  minimapWindow:setup()

  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })

  connect(LocalPlayer, {
    onPositionChange = updateCameraPosition
  })

  if g_game.isOnline() then
    online()
  end
end

function terminate()
  if g_game.isOnline() then
    saveMap()
  end

  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })

  disconnect(LocalPlayer, {
    onPositionChange = updateCameraPosition
  })

  local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.unbindKeyPress('Alt+Left', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Right', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Up', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Down', gameRootPanel)
  g_keyboard.unbindKeyDown('Ctrl+M')
  g_keyboard.unbindKeyDown('Ctrl+Shift+M')

  minimapWindow:destroy()
  if minimapButton then
    minimapButton:destroy()
  end
end

function toggle()
  if not minimapButton then return end
  if minimapButton:isOn() then
    minimapWindow:close()
    minimapButton:setOn(false)
  else
    minimapWindow:open()
    minimapButton:setOn(true)
  end
end

function onMiniWindowClose()
  if minimapButton then
    minimapButton:setOn(false)
  end
end

function online()
  loadMap()
  updateCameraPosition()
end

function offline()
  saveMap()
end

function loadMap()
  local clientVersion = g_game.getClientVersion()
  local characterMinimapBaseName = getCharacterMinimapBaseName()

  g_minimap.clean()
  loaded = false

  local minimapFile = '/minimap.otmm'
  local dataMinimapFile = '/data' .. minimapFile
  local versionedMinimapFile = '/minimap' .. clientVersion .. '.otmm'
  local characterVersionedMinimapFile = characterMinimapBaseName and (characterMinimapBaseName .. '_' .. clientVersion .. '.otmm') or nil
  local characterMinimapFile = characterMinimapBaseName and (characterMinimapBaseName .. '.otmm') or nil
  if g_resources.fileExists(dataMinimapFile) then
    loaded = g_minimap.loadOtmm(dataMinimapFile)
  end
  if not loaded and characterVersionedMinimapFile and g_resources.fileExists(characterVersionedMinimapFile) then
    loaded = g_minimap.loadOtmm(characterVersionedMinimapFile)
  end
  if not loaded and characterMinimapFile and g_resources.fileExists(characterMinimapFile) then
    loaded = g_minimap.loadOtmm(characterMinimapFile)
  end
  if not loaded and g_resources.fileExists(versionedMinimapFile) then
    loaded = g_minimap.loadOtmm(versionedMinimapFile)
  end
  if not loaded and g_resources.fileExists(minimapFile) then
    loaded = g_minimap.loadOtmm(minimapFile)
  end
  if not loaded then
    print("Minimap couldn't be loaded, file missing?")
  end
  minimapWidget:load()
  if worldMapMinimap then
    worldMapMinimap:load()
  end
end

function saveMap()
  local clientVersion = g_game.getClientVersion()
  local characterMinimapBaseName = getCharacterMinimapBaseName()
  local minimapFile

  if characterMinimapBaseName then
    minimapFile = characterMinimapBaseName .. '_' .. clientVersion .. '.otmm'
  else
    minimapFile = '/minimap' .. clientVersion .. '.otmm'
  end

  g_minimap.saveOtmm(minimapFile)
  minimapWidget:save()
  g_settings.save()
end

function updateCameraPosition()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  if not pos then return end
  if not minimapWidget:isDragging() then
    if not fullmapView then
      minimapWidget:setCameraPosition(player:getPosition())
    end
    minimapWidget:setCrossPosition(player:getPosition())
  end
end

function toggleFullMap()
  if not worldMapWindow or not worldMapMinimap then return end

  if worldMapWindow:isVisible() then
    worldMapWindow:hide()
    fullmapView = false
    if worldMapButton then
      worldMapButton:setOn(false)
    end
    return
  end

  fullmapView = true
  worldMapWindow:show()
  worldMapWindow:raise()
  worldMapWindow:focus()
  worldMapWindow:centerIn('parent')

  local pos = minimapWidget:getCameraPosition()
  local zoom = minimapWidget:getZoom()

  worldMapMinimap:setCameraPosition(pos)
  worldMapMinimap:setCrossPosition(pos)
  worldMapMinimap:setZoom(zoom)

  if worldMapButton then
    worldMapButton:setOn(true)
  end
end
