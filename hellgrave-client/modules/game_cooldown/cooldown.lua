local ProgressCallback = {
  update = 1,
  finish = 2
}

cooldownWindow = nil
cooldownButton = nil
contentsPanel = nil
cooldownPanel = nil
lastPlayer = nil

cooldown = {}
cooldowns = {}
groupCooldown = {}

function init()
  connect(g_game, { onGameStart = online,
                    onSpellGroupCooldown = onSpellGroupCooldown,
                    onSpellCooldown = onSpellCooldown })

  cooldownButton = modules.client_topmenu.addRightGameToggleButton('cooldownButton', 
    tr('Cooldowns'), '/images/topbuttons/cooldowns', toggle, false, 5)
  cooldownButton:setOn(true)
  cooldownButton:hide()

  cooldownWindow = g_ui.loadUI('cooldown', modules.game_interface.getRightPanel())
  cooldownWindow:disableResize()
  cooldownWindow:setup()

  contentsPanel = cooldownWindow:getChildById('contentsPanel')
  cooldownPanel = contentsPanel:getChildById('cooldownPanel')

  -- preload cooldown images
  for k,v in pairs(SpelllistSettings) do
    g_textures.preload(v.iconFile)
  end

  if g_game.isOnline() then
    online()
  end
end

function terminate()
  disconnect(g_game, { onGameStart = online,
                       onSpellGroupCooldown = onSpellGroupCooldown,
                       onSpellCooldown = onSpellCooldown })
                       
  for key, val in pairs(cooldowns) do
    removeCooldown(key)
  end
  cooldowns = {}

  cooldownWindow:destroy()
  cooldownButton:destroy()
end

function getIconIdBySpellId(spellId)
  local spells = modules.gamelib.SpellInfo['Default']
  for _, spellData in pairs(spells) do
    if spellData.id == spellId then
      return spellData.icon
    end
  end
  return nil
end

function loadIcon(spellId)
  local spellData, spellName
  for name, data in pairs(modules.gamelib.SpellInfo['Default']) do
    if data.id == spellId then
      spellData = data
      spellName = name
      break
    end
  end

  if not spellData then
    return nil
  end

  local iconEntry = SpellIcons[spellData.icon]
  if not iconEntry then
    return nil
  end

  local clientIconIndex = iconEntry[1]
  local profile = spellData.profile or 'Default'

  local icon = cooldownPanel:getChildById("spell_" .. spellId)
  if not icon then
    icon = g_ui.createWidget('SpellIcon')
    icon:setId("spell_" .. spellId)
  end

  local spellSettings = SpelllistSettings[profile]
  if not spellSettings then
    return nil
  end
  icon:setImageSource(spellSettings.iconFile)
  icon:setImageClip(Spells.getImageClip(clientIconIndex, profile))

  icon.spellName = spellName
  return icon
end

function onMiniWindowClose()
  cooldownButton:setOn(false)
end

function toggle()
  if cooldownButton:isOn() then
    cooldownWindow:close()
    cooldownButton:setOn(false)
  else
    cooldownWindow:open()
    cooldownButton:setOn(true)
  end
end

function online()
  if g_game.getFeature(GameSpellList) then
    cooldownButton:show()
  else
    cooldownButton:hide()
    cooldownWindow:close()
  end

  if not lastPlayer or lastPlayer ~= g_game.getCharacterName() then
    refresh()
    lastPlayer = g_game.getCharacterName()
  end
end

function refresh()
  cooldownPanel:destroyChildren()
end

function removeCooldown(progressRect)
  removeEvent(progressRect.event)
  if progressRect.icon then
    progressRect.icon:destroy()
    progressRect.icon = nil
  end
  cooldowns[progressRect] = nil
  progressRect = nil
end

function turnOffCooldown(progressRect)
  removeEvent(progressRect.event)
  if progressRect.icon then
    progressRect.icon:setOn(false)
    progressRect.icon = nil
  end

  -- create particles
  --[[local particle = g_ui.createWidget('GroupCooldownParticles', progressRect)
  particle:fill('parent')
  scheduleEvent(function() particle:destroy() end, 1000) -- hack until onEffectEnd]]

  cooldowns[progressRect] = nil
  progressRect = nil
end

function initCooldown(progressRect, updateCallback, finishCallback)
  progressRect:setPercent(0)

  progressRect.callback = {}
  progressRect.callback[ProgressCallback.update] = updateCallback
  progressRect.callback[ProgressCallback.finish] = finishCallback

  updateCallback()
end

function updateCooldown(progressRect, duration)
  progressRect:setPercent(progressRect:getPercent() + 10000/duration)

  if progressRect:getPercent() < 100 then
    removeEvent(progressRect.event)

    progressRect.event = scheduleEvent(function() 
      if not progressRect.callback then return end
      progressRect.callback[ProgressCallback.update]() 
    end, 100)
  else
    progressRect.callback[ProgressCallback.finish]()
  end
end

function isGroupCooldownIconActive(groupId)
  return groupCooldown[groupId]
end

function isCooldownIconActive(spellId)
  return cooldown[spellId]
end

function onSpellCooldown(spellId, duration)
  if duration <= 0 then
    local icon = cooldownPanel:getChildById("spell_" .. spellId)
    if icon then
      local progressRect = icon:getChildById("cd_" .. spellId)
      if progressRect then
        removeCooldown(progressRect)
      else
        icon:destroy()
      end
    end
    cooldown[spellId] = false
    return
  end

  local icon = loadIcon(spellId)
  if not icon then
    return
  end

  icon:setParent(cooldownPanel)

  local progressRect = icon:getChildById("cd_" .. spellId)
  if not progressRect then
    progressRect = g_ui.createWidget('SpellProgressRect', icon)
    progressRect:setId("cd_" .. spellId)
    progressRect.icon = icon
    progressRect:fill('parent')
  else
    progressRect:setPercent(0)
  end
  local iconId = getIconIdBySpellId(spellId)
  progressRect:setTooltip(icon.spellName or ("Spell #" .. spellId))

  local updateFunc = function()
    updateCooldown(progressRect, duration)
  end

  local finishFunc = function()
    removeCooldown(progressRect)
    cooldown[spellId] = false
  end

  initCooldown(progressRect, updateFunc, finishFunc)
  cooldown[spellId] = true
  cooldowns[progressRect] = true
end

function onSpellGroupCooldown(groupId, duration)
  if not SpellGroups[groupId] then return end

  local icon = contentsPanel:getChildById('groupIcon' .. SpellGroups[groupId])
  local progressRect = contentsPanel:getChildById('progressRect' .. SpellGroups[groupId])
  if duration <= 0 then
    if progressRect then
      turnOffCooldown(progressRect)
    end
    groupCooldown[groupId] = false
    return
  end
  if icon then
    icon:setOn(true)
    removeEvent(icon.event)
  end

  progressRect.icon = icon
  if progressRect then
    removeEvent(progressRect.event)
    local updateFunc = function()
      updateCooldown(progressRect, duration)
    end
    local finishFunc = function()
      turnOffCooldown(progressRect)
      groupCooldown[groupId] = false
    end
    initCooldown(progressRect, updateFunc, finishFunc)
    groupCooldown[groupId] = true
  end
end
