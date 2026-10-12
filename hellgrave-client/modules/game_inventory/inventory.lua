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

InventorySlotStyles = {
  [InventorySlotHead] = "HeadSlot",
  [InventorySlotNeck] = "NeckSlot",
  [InventorySlotBack] = "BackSlot",
  [InventorySlotBody] = "BodySlot",
  [InventorySlotRight] = "RightSlot",
  [InventorySlotLeft] = "LeftSlot",
  [InventorySlotLeg] = "LegSlot",
  [InventorySlotFeet] = "FeetSlot",
  [InventorySlotFinger] = "FingerSlot",
  [InventorySlotAmmo] = "AmmoSlot",
  [InventorySlotDeck] = "DeckSlot",
  [InventorySlotBadge] = "BadgeSlot",
  [InventorySlotShip] = "ShipSlot",
  [InventorySlotBelt] = "BeltSlot",
  [InventorySlotGloves] = "GlovesSlot",
}

inventoryWindow = nil
inventoryPanel = nil
inventoryButton = nil
purseButton = nil

combatControlsWindow = nil
fightOffensiveBox = nil
fightBalancedBox = nil
fightDefensiveBox = nil
chaseModeButton = nil
safeFightButton = nil
mountButton = nil
fightModeRadioGroup = nil
buttonPvp = nil

soulLabel = nil
capLabel = nil
conditionPanel = nil

local OPCODE_INVENTORY = 210
local RARITY_BASE      = 63500
local invCache = {}
local forgeTierCache = {}
local FORGE_TIER_IMAGE_PATH = '/modules/game_forge/images/'

local function paintForgeTierBadge(slotWidget, tier)
  if not slotWidget then return end
  local oldBadge = slotWidget:getChildById('forgeTierOverlay')
  if oldBadge then oldBadge:destroy() end

  tier = math.floor(tonumber(tier) or 0)
  if not slotWidget:getItem() or tier < 1 or tier > 10 then return end

  local badge = g_ui.createWidget('UIWidget', slotWidget)
  badge:setId('forgeTierOverlay')
  badge:setSize({ width = 32, height = 32 })
  badge:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
  badge:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
  badge:setImageSource(FORGE_TIER_IMAGE_PATH .. tier)
  badge:setPhantom(true)
  badge:setFocusable(false)
end


function numberToFrame(num)
  if type(num) ~= 'number' or num < RARITY_BASE then return '/images/ui/item' end
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
  return frames[rid]
end

function clearInventoryFrame(slotWidget)
  if not slotWidget then return end
  if slotWidget.removeImageSource then
    slotWidget:removeImageSource()
  else
    slotWidget:setImageSource('')
  end
end

function paintOverlay(slotWidget, num, forgeTier)
  if not slotWidget then return end
  local oldOverlay = slotWidget:getChildById('rarityOverlay')
  if oldOverlay then
    oldOverlay:destroy()
  end

  if not slotWidget:getItem() then
    paintForgeTierBadge(slotWidget, 0)
    return
  end

  local frame = numberToFrame(num)
  if frame then
    slotWidget:setImageSource(frame)
  else
    clearInventoryFrame(slotWidget)
  end
  paintForgeTierBadge(slotWidget, forgeTier)
end

function paintInventoryFrames(panel)
  if not panel then return end
  for slot = InventorySlotFirst, InventorySlotLast do
    local w = panel:getChildById('slot' .. slot)
    if w then paintOverlay(w, invCache[slot] or 0, forgeTierCache[slot] or 0) end
  end
end

function onExtendedOpcode(_, opcode, buffer)
  if opcode ~= OPCODE_INVENTORY then return end
  local ok, data = pcall(function() return json.decode(buffer) end)
  if not ok or type(data) ~= 'table' then return end

  if data.a == "invR" and type(data.m) == "table" then
  local changed = false
  for _, pair in ipairs(data.m) do
    local slot, num, tier = pair[1], pair[2], tonumber(pair[3]) or 0
    if invCache[slot] ~= num or forgeTierCache[slot] ~= tier then
      invCache[slot] = num
      forgeTierCache[slot] = tier
      changed = true
    end
  end
  if changed then
    paintInventoryFrames(inventoryPanel) 
  end
  elseif data.a == "invRS"
     and type(data.s) == "number"
     and type(data.n) == "number" then
    local prev = invCache[data.s]
    local tier = tonumber(data.t) or 0
    if prev == data.n and forgeTierCache[data.s] == tier then return end
    invCache[data.s] = data.n
    forgeTierCache[data.s] = tier
    local w = inventoryPanel and inventoryPanel:getChildById('slot' .. data.s)
    paintOverlay(w, data.n, tier)
  end
end

function init()
  connect(LocalPlayer, {
    onInventoryChange = onInventoryChange,
    onBlessingsChange = onBlessingsChange
  })
  connect(g_game, { onGameStart = refresh })
  
  g_keyboard.bindKeyDown('Ctrl+I', toggle)


  inventoryWindow = g_ui.loadUI('inventory', modules.game_interface.getRightPanel())
  inventoryWindow:disableResize()
  inventoryPanel = inventoryWindow:getChildById('contentsPanel'):getChildById('inventoryPanel')
  if not inventoryWindow.forceOpen then
    inventoryButton = modules.client_topmenu.addRightGameToggleButton('inventoryButton', tr('Inventory') .. ' (Ctrl+I)', '/images/topbuttons/inventory', toggle)
    inventoryButton:setOn(true)
  end
  
  purseButton = inventoryWindow:recursiveGetChildById('purseButton')
  purseButton.onClick = function()
    local purse = g_game.getLocalPlayer():getInventoryItem(InventorySlotPurse)
    if purse then
      g_game.use(purse)
    end
  end
  
  -- controls
  fightOffensiveBox = inventoryWindow:recursiveGetChildById('fightOffensiveBox')
  fightBalancedBox = inventoryWindow:recursiveGetChildById('fightBalancedBox')
  fightDefensiveBox = inventoryWindow:recursiveGetChildById('fightDefensiveBox')

  chaseModeButton = inventoryWindow:recursiveGetChildById('chaseModeBox')
  safeFightButton = inventoryWindow:recursiveGetChildById('safeFightBox')
  buttonPvp = inventoryWindow:recursiveGetChildById('buttonPvp')

  mountButton = inventoryWindow:recursiveGetChildById('mountButton')
  mountButton.onClick = onMountButtonClick

  whiteDoveBox = inventoryWindow:recursiveGetChildById('whiteDoveBox')
  whiteHandBox = inventoryWindow:recursiveGetChildById('whiteHandBox')
  yellowHandBox = inventoryWindow:recursiveGetChildById('yellowHandBox')
  redFistBox = inventoryWindow:recursiveGetChildById('redFistBox')

  fightModeRadioGroup = UIRadioGroup.create()
  fightModeRadioGroup:addWidget(fightOffensiveBox)
  fightModeRadioGroup:addWidget(fightBalancedBox)
  fightModeRadioGroup:addWidget(fightDefensiveBox)

  connect(fightModeRadioGroup, { onSelectionChange = onSetFightMode })
  connect(chaseModeButton, { onCheckChange = onSetChaseMode })
  connect(safeFightButton, { onCheckChange = onSetSafeFight })
  if buttonPvp then
    connect(buttonPvp, { onClick = onSetSafeFight2 })  
  end
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onFightModeChange = update,
    onChaseModeChange = update,
    onSafeFightChange = update,
    onPVPModeChange   = update,
    onWalk = check,
    onAutoWalk = check
  })
  ProtocolGame.registerExtendedOpcode(OPCODE_INVENTORY, onExtendedOpcode)

  connect(LocalPlayer, { onOutfitChange = onOutfitChange })

  if g_game.isOnline() then
    online()
  end
-- controls end

-- status
  soulLabel = inventoryWindow:recursiveGetChildById('soulLabel')
  capLabel = inventoryWindow:recursiveGetChildById('capLabel')
  conditionPanel = inventoryWindow:recursiveGetChildById('conditionPanel')


  connect(LocalPlayer, { onStatesChange = onStatesChange,
                         onSoulChange = onSoulChange,
                         onFreeCapacityChange = onFreeCapacityChange })
-- status end
  
  refresh()
  inventoryWindow:setup()
end

function terminate()
  disconnect(LocalPlayer, {
    onInventoryChange = onInventoryChange,
    onBlessingsChange = onBlessingsChange
  })
  disconnect(g_game, { onGameStart = refresh })

  g_keyboard.unbindKeyDown('Ctrl+I')

  -- controls
  if g_game.isOnline() then
    offline()
  end

  fightModeRadioGroup:destroy()
  
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onFightModeChange = update,
    onChaseModeChange = update,
    onSafeFightChange = update,
    onPVPModeChange   = update,
    onWalk = check,
    onAutoWalk = check
  })

  disconnect(LocalPlayer, { onOutfitChange = onOutfitChange })
  -- controls end
  -- status
  disconnect(LocalPlayer, { onStatesChange = onStatesChange,
                         onSoulChange = onSoulChange,
                         onFreeCapacityChange = onFreeCapacityChange })
  -- status end
  ProtocolGame.unregisterExtendedOpcode(OPCODE_INVENTORY)
  inventoryWindow:destroy()
  if inventoryButton then
    inventoryButton:destroy()
  end
end

function toggleAdventurerStyle(hasBlessing)
  for slot = InventorySlotFirst, InventorySlotLast do
    local itemWidget = inventoryPanel:getChildById('slot' .. slot)
    if itemWidget then
      itemWidget:setOn(hasBlessing)
    end
  end
end

function refresh()
  local player = g_game.getLocalPlayer()
  for i = InventorySlotFirst, InventorySlotLast do
    if g_game.isOnline() then
      onInventoryChange(player, i, player:getInventoryItem(i))
    else
      onInventoryChange(player, i, nil)
    end
    toggleAdventurerStyle(player and Bit.hasBit(player:getBlessings(), Blessings.Adventurer) or false)

  end
  if player then
    onSoulChange(player, player:getSoul())
    onFreeCapacityChange(player, player:getFreeCapacity())
    onStatesChange(player, player:getStates(), 0)
    local pg = g_game.getProtocolGame()
    if pg then
      pg:sendExtendedOpcode(OPCODE_INVENTORY, json.encode({ a="invReq" }))
    end
  end

  purseButton:setVisible(g_game.getFeature(GamePurseSlot))
end

function toggle()
  if not inventoryButton then
    return
  end
  if inventoryButton:isOn() then
    inventoryWindow:close()
    inventoryButton:setOn(false)
  else
    inventoryWindow:open()
    inventoryButton:setOn(true)
  end
end

function onMiniWindowClose()
  if not inventoryButton then
    return
  end
  inventoryButton:setOn(false)
end

-- hooked events
function onInventoryChange(player, slot, item, oldItem)
  if slot > InventorySlotLast then return end
  if slot == InventorySlotPurse then return end

  local w = inventoryPanel:getChildById('slot' .. slot)
  if not w then
    return
  end

  if item then
    w:setStyle('InventoryItem')
    w:setItem(item)
    local pg = g_game.getProtocolGame()
    if pg then
      pg:sendExtendedOpcode(OPCODE_INVENTORY, json.encode({ a="invReqS", s=slot }))
    end
  else
    w:setStyle(InventorySlotStyles[slot])
    w:setItem(nil)
    invCache[slot] = 0
    forgeTierCache[slot] = 0
    paintOverlay(w, 0, 0)
  end

  local pg = g_game.getProtocolGame()
  if pg then
    pg:sendExtendedOpcode(OPCODE_INVENTORY, json.encode({ a="invReqS", s=slot }))
  end
end


function onBlessingsChange(player, blessings, oldBlessings)
  local hasAdventurerBlessing = Bit.hasBit(blessings, Blessings.Adventurer)
  if hasAdventurerBlessing ~= Bit.hasBit(oldBlessings, Blessings.Adventurer) then
    toggleAdventurerStyle(hasAdventurerBlessing)
  end
end


-- controls
function update()
  local fightMode = g_game.getFightMode()
  if fightMode == FightOffensive then
    fightModeRadioGroup:selectWidget(fightOffensiveBox)
  elseif fightMode == FightBalanced then
    fightModeRadioGroup:selectWidget(fightBalancedBox)
  else
    fightModeRadioGroup:selectWidget(fightDefensiveBox)
  end

  local chaseMode = g_game.getChaseMode()
  chaseModeButton:setChecked(chaseMode == ChaseOpponent)

  local safeFight = g_game.isSafeFight()
  safeFightButton:setChecked(not safeFight)
  if buttonPvp then
    if safeFight then
      buttonPvp:setOn(false)
    else
      buttonPvp:setOn(true)  
    end
  end
  
  if g_game.getFeature(GamePVPMode) then
    local pvpMode = g_game.getPVPMode()
    local pvpWidget = getPVPBoxByMode(pvpMode)
  end
end

function check()
  if modules.client_options.getOption('autoChaseOverride') then
    if g_game.isAttacking() and g_game.getChaseMode() == ChaseOpponent then
      g_game.setChaseMode(DontChase)
    end
  end
end

function online()
  local player = g_game.getLocalPlayer()
  if player then
    local char = g_game.getCharacterName()

    local lastCombatControls = g_settings.getNode('LastCombatControls')

    if not table.empty(lastCombatControls) then
      if lastCombatControls[char] then
        g_game.setFightMode(lastCombatControls[char].fightMode)
        g_game.setChaseMode(lastCombatControls[char].chaseMode)
        g_game.setSafeFight(lastCombatControls[char].safeFight)
        if lastCombatControls[char].pvpMode then
          g_game.setPVPMode(lastCombatControls[char].pvpMode)
        end
      end
    end

    if g_game.getFeature(GamePlayerMounts) then
      mountButton:setVisible(true)
      mountButton:setChecked(player:isMounted())
    else
      mountButton:setVisible(false)
    end
  end

  update()
end

function offline()
  local lastCombatControls = g_settings.getNode('LastCombatControls')
  if not lastCombatControls then
    lastCombatControls = {}
  end

  conditionPanel:destroyChildren()

  local player = g_game.getLocalPlayer()
  if player then
    local char = g_game.getCharacterName()
    lastCombatControls[char] = {
      fightMode = g_game.getFightMode(),
      chaseMode = g_game.getChaseMode(),
      safeFight = g_game.isSafeFight()
    }

    if g_game.getFeature(GamePVPMode) then
      lastCombatControls[char].pvpMode = g_game.getPVPMode()
    end

    -- save last combat control settings
    g_settings.setNode('LastCombatControls', lastCombatControls)
  end
end

function onSetFightMode(self, selectedFightButton)
  if selectedFightButton == nil then return end
  local buttonId = selectedFightButton:getId()
  local fightMode
  if buttonId == 'fightOffensiveBox' then
    fightMode = FightOffensive
  elseif buttonId == 'fightBalancedBox' then
    fightMode = FightBalanced
  else
    fightMode = FightDefensive
  end
  g_game.setFightMode(fightMode)
end

function onSetChaseMode(self, checked)
  local chaseMode
  if checked then
    chaseMode = ChaseOpponent
  else
    chaseMode = DontChase
  end
  g_game.setChaseMode(chaseMode)
end

function onSetSafeFight(self, checked)
  g_game.setSafeFight(not checked)
  if buttonPvp then
    if not checked then
      buttonPvp:setOn(false)
    else
      buttonPvp:setOn(true)  
    end
  end
end

function onSetSafeFight2(self)
  onSetSafeFight(self, not safeFightButton:isChecked())
end

function onSetPVPMode(self, selectedPVPButton)
  if selectedPVPButton == nil then
    return
  end

  local buttonId = selectedPVPButton:getId()
  local pvpMode = PVPWhiteDove
  if buttonId == 'whiteDoveBox' then
    pvpMode = PVPWhiteDove
  elseif buttonId == 'whiteHandBox' then
    pvpMode = PVPWhiteHand
  elseif buttonId == 'yellowHandBox' then
    pvpMode = PVPYellowHand
  elseif buttonId == 'redFistBox' then
    pvpMode = PVPRedFist
  end

  g_game.setPVPMode(pvpMode)
end

function onMountButtonClick(self, mousePos)
  local player = g_game.getLocalPlayer()
  if player then
    player:toggleMount()
  end
end

function onOutfitChange(localPlayer, outfit, oldOutfit)
  if outfit.mount == oldOutfit.mount then
    return
  end

  mountButton:setChecked(outfit.mount ~= nil and outfit.mount > 0)
end

function getPVPBoxByMode(mode)
  local widget = nil
  if mode == PVPWhiteDove then
    widget = whiteDoveBox
  elseif mode == PVPWhiteHand then
    widget = whiteHandBox
  elseif mode == PVPYellowHand then
    widget = yellowHandBox
  elseif mode == PVPRedFist then
    widget = redFistBox
  end
  return widget
end

-- status
function toggleIcon(bitChanged)
  local iconData = Icons[bitChanged]
  if not conditionPanel or not iconData then return end

  local icon = conditionPanel:getChildById(iconData.id)
  if icon then
    icon:destroy()
  else
    icon = loadIcon(bitChanged)
    icon:setParent(conditionPanel)
  end
end

function loadIcon(bitChanged)
  local icon = g_ui.createWidget('ConditionWidget', conditionPanel)
  icon:setId(Icons[bitChanged].id)
  icon:setImageSource(Icons[bitChanged].path)
  icon:setTooltip(Icons[bitChanged].tooltip)
  return icon
end

function onSoulChange(localPlayer, soul)
  if not soul then return end
  soulLabel:setText(tr('Soul') .. ':\n' .. soul)
end

function onFreeCapacityChange(player, freeCapacity)
  if not freeCapacity then return end
  if freeCapacity > 99 then
    freeCapacity = math.floor(freeCapacity * 10) / 10
  end
  if freeCapacity > 999 then
    freeCapacity = math.floor(freeCapacity)
  end
  if freeCapacity > 99999 then
    freeCapacity = math.min(9999, math.floor(freeCapacity/1000)) .. "k"
  end
  capLabel:setText(tr('Cap') .. ':\n' .. freeCapacity)
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
