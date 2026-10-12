local CARAVAN_OPCODE = 220
local CARAVAN_MENU = 'Open Caravan'

function init()
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })
  modules.game_interface.addMenuHook('caravan', CARAVAN_MENU, openCaravan, isCaravanCreature)
  if g_game.isOnline() then online() end
end

function terminate()
  modules.game_interface.removeMenuHook('caravan', CARAVAN_MENU)
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })
  offline()
end

function online()
  if g_game.getFeature(GamePlayerMounts) then
    g_keyboard.bindKeyDown('Ctrl+R', toggleMount)
  end
end

function offline()
  if g_game.getFeature(GamePlayerMounts) then
    g_keyboard.unbindKeyDown('Ctrl+R')
  end
end

function toggleMount()
  local player = g_game.getLocalPlayer()
  if player then
    player:toggleMount()
  end
end

function mount()
  local player = g_game.getLocalPlayer()
  if player then
    player:mount()
  end
end

function dismount()
  local player = g_game.getLocalPlayer()
  if player then
    player:dismount()
  end
end

function isCaravanCreature(menuPosition, lookThing, useThing, creatureThing)
  if not creatureThing or creatureThing:isPlayer() then
    return false
  end

  local name = (creatureThing:getName() or ''):lower()
  return name:find('chariot') ~= nil or name:find('caravan') ~= nil
end

function openCaravan(menuPosition, lookThing, useThing, creatureThing)
  local protocolGame = g_game.getProtocolGame()
  if not protocolGame or not creatureThing then
    return
  end

  protocolGame:sendExtendedOpcode(CARAVAN_OPCODE, json.encode({
    action = 'open',
    id = creatureThing:getId()
  }))
end
