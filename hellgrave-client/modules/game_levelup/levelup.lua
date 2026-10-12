local OPCODE_LEVELUP = 127

local levelUpUI = nil

function init()
  ProtocolGame.registerExtendedOpcode(OPCODE_LEVELUP, onExtendedOpcode)

  if not levelUpUI then
    levelUpUI = g_ui.loadUI("levelup", modules.game_interface.getRootPanel())
    levelUpUI:hide()
  end
end


function terminate()
  ProtocolGame.unregisterExtendedOpcode(OPCODE_LEVELUP)
end


function showLevelUpBanner(name, level)
  if not levelUpUI then return end

  levelUpUI:setVisible(true)
  levelUpUI:raise()

  local banner = levelUpUI:recursiveGetChildById('banner')
  local label = levelUpUI:recursiveGetChildById('label')

  if label then
    label:setText(name .. ": " .. level)

    if level % 10 == 0 then
      label:setColor('#77ff00') 
    else
      label:setColor('#ffffff') 
    end
  end

  banner:setVisible(true)
  banner:setOpacity(1.0)

  if banner.hideEvent then removeEvent(banner.hideEvent) end
  banner.hideEvent = scheduleEvent(function()
    g_effects.fadeOut(banner, 500)
    scheduleEvent(function() 
        banner:setVisible(false)
        levelUpUI:setVisible(false) 
    end, 500)
  end, 5000)
end

function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_LEVELUP then
    return
  end

  local ok, parsed = pcall(function()
    return json.decode(buffer)
  end)

  if not ok or not parsed then
    g_logger.error("[LevelUp] Invalid JSON: " .. tostring(buffer))
    return
  end

  if parsed.action == "advance" or parsed.action == "levelup" then
    showLevelUpBanner(parsed.name or "Level", parsed.level)
  end
end

