local CODE = 107

local IInventorySlotStyles = {
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

local inspectWindow = nil

function init()
  connect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.registerExtendedOpcode(CODE, onExtendedOpcode)

  if g_game.isOnline() then
    create()
  end
end

function terminate()
  disconnect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.unregisterExtendedOpcode(CODE, onExtendedOpcode)

  destroy()
end

function create()
  inspectWindow = g_ui.displayUI("inspect")
  inspectWindow:hide()
end

function onExtendedOpcode(protocol, code, buffer)
  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )

  if not json_status then
    g_logger.error("[Inspect] JSON error: " .. data)
    return false
  end

  local action = json_data.action
  local data = json_data.data

  if action == "stats" then
    addStats(data)
  elseif action == "item" then
    addItem(data.slot, data.item)
  end
end

function inspect(creature)
  if creature then
    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
      protocolGame:sendExtendedOpcode(CODE, json.encode({action = "inspect", data = creature:getName()}))
    end

    local outfitCreatureBox = inspectWindow:recursiveGetChildById("outfitInspectBox")
    outfitCreatureBox:setCreature(creature)
  end
end

function addStats(data)
  for key, value in pairs(data) do
    local w = inspectWindow:recursiveGetChildById(key)
    if w then
      w:setText(type(value) == "number" and comma_value(value) or value)
    end
  end
  local healthBar = inspectWindow:recursiveGetChildById("healthBar")
  healthBar:setText(data.health .. "/" .. data.maxHealth)
  healthBar:setValue(data.health, 0, data.maxHealth)
  local manaBar = inspectWindow:recursiveGetChildById("manaBar")
  manaBar:setText(data.mana .. "/" .. data.maxMana)
  manaBar:setValue(data.mana, 0, data.maxMana)

  for i = 1, #data.skills do
    local skill = data.skills[i]
    local w = inspectWindow:recursiveGetChildById("skill" .. i)
    if w then
      local valueWidget = w:getChildById("value")
      valueWidget:setText(skill.total)
      if skill.bonus > 0 then
        valueWidget:setColor("#008b00")
        w:setTooltip(skill.total - skill.bonus .. " +" .. skill.bonus)
      else
        valueWidget:setColor("#bbbbbb")
        w:removeTooltip()
      end
      local percentWidget = w:getChildById("percent")
      percentWidget:setPercent(math.floor(skill.percent))
      percentWidget:setTooltip(tr("%s percent to go", 100 - skill.percent))
    end
  end

  for i = 1, #data.stats do
    local stat = data.stats[i]
    local w = inspectWindow:recursiveGetChildById("stat" .. i)
    if w then
      local valueWidget = w:getChildById("value")
      valueWidget:setText(stat.value)
      local percentWidget = w:getChildById("percent")
      percentWidget:setValue(stat.value, 0, stat.max)
      percentWidget:setTooltip(stat.value .. " / " .. stat.max)
    end
  end
  if data.specialSkills then
    local ss = data.specialSkills
    local critChancePanel = inspectWindow:recursiveGetChildById("criticalHitChance")
    if critChancePanel then
      local valueWidget = critChancePanel:getChildById("value")
      valueWidget:setText(ss.criticalHitChance)
      local bar = critChancePanel:recursiveGetChildById("critChanceBar")
      if bar then
        bar:setValue(ss.criticalHitChance, 0, 100)  -- Adjust max value if needed
      end
    end
    local critAmountPanel = inspectWindow:recursiveGetChildById("criticalHitAmount")
    if critAmountPanel then
      local valueWidget = critAmountPanel:getChildById("value")
      valueWidget:setText(ss.criticalHitAmount)
      local bar = critAmountPanel:recursiveGetChildById("critAmountBar")
      if bar then
        bar:setValue(ss.criticalHitAmount, 0, 100)
      end
    end
    local lifeLeechChancePanel = inspectWindow:recursiveGetChildById("lifeLeechChance")
    if lifeLeechChancePanel then
      local valueWidget = lifeLeechChancePanel:getChildById("value")
      valueWidget:setText(ss.lifeLeechChance)
      local bar = lifeLeechChancePanel:recursiveGetChildById("lifeLeechChanceBar")
      if bar then
        bar:setValue(ss.lifeLeechChance, 0, 100)
      end
    end
    local lifeLeechAmountPanel = inspectWindow:recursiveGetChildById("lifeLeechAmount")
    if lifeLeechAmountPanel then
      local valueWidget = lifeLeechAmountPanel:getChildById("value")
      valueWidget:setText(ss.lifeLeechAmount)
      local bar = lifeLeechAmountPanel:recursiveGetChildById("lifeLeechAmountBar")
      if bar then
        bar:setValue(ss.lifeLeechAmount, 0, 100)
      end
    end
    local manaLeechChancePanel = inspectWindow:recursiveGetChildById("manaLeechChance")
    if manaLeechChancePanel then
      local valueWidget = manaLeechChancePanel:getChildById("value")
      valueWidget:setText(ss.manaLeechChance)
      local bar = manaLeechChancePanel:recursiveGetChildById("manaLeechChanceBar")
      if bar then
        bar:setValue(ss.manaLeechChance, 0, 100)
      end
    end
    local manaLeechAmountPanel = inspectWindow:recursiveGetChildById("manaLeechAmount")
    if manaLeechAmountPanel then
      local valueWidget = manaLeechAmountPanel:getChildById("value")
      valueWidget:setText(ss.manaLeechAmount)
      local bar = manaLeechAmountPanel:recursiveGetChildById("manaLeechAmountBar")
      if bar then
        bar:setValue(ss.manaLeechAmount, 0, 100)
      end
    end
  end

  inspectWindow:show()
end

function addItem(slot, clientId)
  local panel = inspectWindow:getChildById("inventoryPanel")
  local slotW = panel:getChildById("slot"..slot)
  if not slotW then return end

  if clientId then
    slotW:setStyle("InventoryItem")
    slotW:setVirtual(true)
    slotW:setDraggable(false)
    slotW:setItemId(clientId)
    slotW:setItemCount(1)
    slotW.onMouseEnter = function(self)
      modules.game_interface.showItemTooltip(self, Item.create(clientId,1))
    end
    slotW.onMouseLeave = function()
      modules.game_interface.hideItemTooltip()
    end
  else
    slotW.onMouseEnter = nil
    slotW.onMouseLeave = nil
    slotW:setItem(nil)
    slotW:setStyle(IInventorySlotStyles[slot])
  end
end


function destroy()
  if inspectWindow then
    inspectWindow:destroy()
    inspectWindow = nil
  end
end

function toggle()
  if not inspectWindow then
    return
  end
  if inspectWindow:isVisible() then
    return hide()
  end
  show()
end

function show()
  if not inspectWindow then
    return
  end
  inspectWindow:show()
  inspectWindow:raise()
  inspectWindow:focus()
end

function hide()
  if not inspectWindow then
    return
  end
  inspectWindow:hide()
end
