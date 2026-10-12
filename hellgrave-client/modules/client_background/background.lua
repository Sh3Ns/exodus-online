-- private variables
local background
local clientVersionLabel

-- public functions
function init()
  background = g_ui.displayUI('background')
  -- background:lower()

  clientVersionLabel = background:getChildById('clientVersionLabel')
  -- clientVersionLabel:setText('Hellgrave Exodus')
  if clientVersionLabel then
    clientVersionLabel:hide()
  end
  
  if clientVersionLabel and not g_game.isOnline() then
    addEvent(function() g_effects.fadeIn(clientVersionLabel, 1500) end)
  end

  connect(g_game, { onGameStart = hide })
  connect(g_game, { onGameEnd = show })
end

function terminate()
  disconnect(g_game, { onGameStart = hide })
  disconnect(g_game, { onGameEnd = show })

  if clientVersionLabel then
    g_effects.cancelFade(clientVersionLabel)
  end
  background:destroy()

  Background = nil
end

function hide()
  background:hide()
end

function show()
  background:show()
end

function hideVersionLabel()
  if clientVersionLabel then
    clientVersionLabel:hide()
  end
end

function setVersionText(text)
  if clientVersionLabel then
    clientVersionLabel:setText(text)
    clientVersionLabel:hide()
  end
end

function getBackground()
  return background
end
