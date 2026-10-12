local gameStart = 0
local lootWindow = nil
local categoriesIds = {
	[LOOT_CATEGORY_GOLD] = {'Coins', 15},
	[LOOT_CATEGORY_VALUABLES] = {'Valuables', 16},
	[LOOT_CATEGORY_EQUIPMENT] = {'Equipment', 5},
	[LOOT_CATEGORY_POTIONS] = {'Potions', 27},
	[LOOT_CATEGORY_AMMUNITION] = {'Ammunition', 11},
	[LOOT_CATEGORY_CREATURE_PRODUCTS] = {'Creature Products', 7},
	[LOOT_CATEGORY_FOOD] = {'Food', 23},
	[LOOT_CATEGORY_SPECIAL] = {'Special', 59},
	[LOOT_CATEGORY_MISC] = {'Misc', 35}
}

local OPCODE_RARITY = 209
local RARITY_BASE = 63500
local rarityCache = {}
local forgeTierCache = {}
local pendingClear = {}
local rarityOpcodeChunks = nil
local FORGE_TIER_IMAGE_PATH = '/modules/game_forge/images/'

local function paintForgeTierBadge(itemWidget, tier)
  if not itemWidget then return end
  local oldBadge = itemWidget:getChildById('forgeTierOverlay')
  if oldBadge then oldBadge:destroy() end
  tier = math.floor(tonumber(tier) or 0)
  if not itemWidget:getItem() or tier < 1 or tier > 10 then return end

  local badge = g_ui.createWidget('UIWidget', itemWidget)
  badge:setId('forgeTierOverlay')
  badge:setSize({ width = 32, height = 32 })
  badge:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
  badge:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
  badge:setImageSource(FORGE_TIER_IMAGE_PATH .. tier)
  badge:setPhantom(true)
  badge:setFocusable(false)
end

function findContainerById(id)
  for _, c in pairs(g_game.getContainers()) do
    if c:getId() == id then
      return c
    end
  end
  return nil
end

function clearImage(w)
  if not w then return end
  if w.removeImageSource then
    w:removeImageSource()
  else
    w:setImageSource('')
  end
end

function requestFull(container)
  local pg = g_game.getProtocolGame()
  if pg then
    pg:sendExtendedOpcode(OPCODE_RARITY, json.encode({ a = "reqR", c = container:getId() }))
  end
end

function numberToFrame(num)
  if not num or num < RARITY_BASE then
    return '/images/ui/item'
  end

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

  local path = frames[rid] or '/images/ui/item'
  return path
end

function paintContainerFrames(container)
  local cid = container:getId()
  local win = container.itemsPanel
  if not win then return end
  local cache = rarityCache[cid] or {}
  local tiers = forgeTierCache[cid] or {}

  for slot = 0, container:getCapacity()-1 do
    local child = win:getChildById('item'..slot)
    local frame = numberToFrame(cache[slot] or 0)
    if child then
      if frame then child:setImageSource(frame) else clearImage(child) end
      paintForgeTierBadge(child, tiers[slot] or 0)
    end
  end
end

function cancelPendingClear(cid, slot)
  if pendingClear[cid] and pendingClear[cid][slot] then
    removeEvent(pendingClear[cid][slot])
    pendingClear[cid][slot] = nil
  end
end

function setRarityFrameIfChanged(w, num)
  local frame = numberToFrame(num)
  if w._rarityFrame == frame then return end
  if frame then w:setImageSource(frame) else clearImage(w) end
  w._rarityFrame = frame
end

function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_RARITY then return end

  local prefix = buffer:sub(1, 1)
  if prefix == 'S' then
    rarityOpcodeChunks = buffer:sub(2)
    return
  elseif prefix == 'P' then
    if rarityOpcodeChunks then
      rarityOpcodeChunks = rarityOpcodeChunks .. buffer:sub(2)
    end
    return
  elseif prefix == 'E' then
    if not rarityOpcodeChunks then
      return
    end
    buffer = rarityOpcodeChunks .. buffer:sub(2)
    rarityOpcodeChunks = nil
  end

  local ok, data = pcall(function() return json.decode(buffer) end)
  if not ok or type(data) ~= 'table' then
    return
  end

  if data.a == "rarR" and type(data.c) == "number" and type(data.m) == "table" then
    rarityCache[data.c] = rarityCache[data.c] or {}
    local cache = rarityCache[data.c]
    for _, pair in ipairs(data.m) do
      local slot, num, tier = pair[1], pair[2], tonumber(pair[3]) or 0
      cache[slot] = num
      forgeTierCache[data.c] = forgeTierCache[data.c] or {}
      forgeTierCache[data.c][slot] = tier
    end
    local container = findContainerById(data.c)
    if container then
      paintContainerFrames(container)
    end
  elseif data.a == "rarRS" and type(data.c)=="number" and type(data.s)=="number" and type(data.n)=="number" then
    rarityCache[data.c] = rarityCache[data.c] or {}
    rarityCache[data.c][data.s] = data.n
    forgeTierCache[data.c] = forgeTierCache[data.c] or {}
    forgeTierCache[data.c][data.s] = tonumber(data.t) or 0
    cancelPendingClear(data.c, data.s)
    local container = findContainerById(data.c)
    if container and container.itemsPanel then
      local child = container.itemsPanel:getChildById('item' .. data.s)
      if child then
        setRarityFrameIfChanged(child, data.n)
        paintForgeTierBadge(child, data.t)
      end
    end
  end
end

function init()
  connect(Container, { onOpen = onContainerOpen,
                       onClose = onContainerClose,
                       onSizeChange = onContainerChangeSize,
                       onUpdateItem = onContainerUpdateItem,
                       onUpdate = onContainersUpdate })
  connect(g_game, {
    onGameStart = markStart,
    onGameEnd = clean
  })
  ProtocolGame.registerExtendedOpcode(OPCODE_RARITY, onExtendedOpcode)
  g_ui.importStyle('containers')
  reloadContainers()
end

function terminate()
  disconnect(Container, { onOpen = onContainerOpen,
                          onClose = onContainerClose,
                          onSizeChange = onContainerChangeSize,
                          onUpdateItem = onContainerUpdateItem,
                          onUpdate = onContainersUpdate })
  disconnect(g_game, { 
    onGameStart = markStart,
    onGameEnd = clean
  })
  ProtocolGame.unregisterExtendedOpcode(OPCODE_RARITY)
  destroyLoot()
end

function onContainersUpdate(container)
  if not container.window then return end
  refreshContainerItems(container)
  paintContainerFrames(container)
  requestFull(container)
end

function reloadContainers()
  clean()
  for _,container in pairs(g_game.getContainers()) do
    onContainerOpen(container)
  end
end

function clean()
  destroyLoot()
  rarityCache = {}
  forgeTierCache = {}
  rarityOpcodeChunks = nil
  for containerid,container in pairs(g_game.getContainers()) do
    destroy(container)
  end
end

function markStart()
  gameStart = g_clock.millis()
end

function destroy(container)
  if container.window then
    container.window:destroy()
    container.window = nil
    container.itemsPanel = nil
  end
end

function refreshContainerItems(container)
  if not container.itemsPanel then return end

  for slot = 0, container:getCapacity()-1 do
    local w = container.itemsPanel:getChildById('item' .. slot)
    if w then
      local item = container:getItem(slot)
      w:setItem(item)
      if not item then clearImage(w) end

      local categoryIdWidget = w:getChildById('lootCategoryId')
      if categoryIdWidget then
        categoryIdWidget:hide()
        if item then
          local iconId = getIconId(item:getLootCategory())
          if iconId ~= LOOT_CATEGORY_NONE then
            categoryIdWidget:show()
            setIconImageType(categoryIdWidget, iconId)
          end
        end
      end
    end
  end

  if container:hasPages() then
    refreshContainerPages(container)
  end
end

function toggleContainerPages(containerWindow, hasPages)
  if hasPages == containerWindow.pagePanel:isOn() then
    return
  end
  containerWindow.pagePanel:setOn(hasPages)
  if hasPages then
    containerWindow.miniwindowScrollBar:setMarginTop(containerWindow.miniwindowScrollBar:getMarginTop() + containerWindow.pagePanel:getHeight())
    containerWindow.contentsPanel:setMarginTop(containerWindow.contentsPanel:getMarginTop() + containerWindow.pagePanel:getHeight())  
  else  
    containerWindow.miniwindowScrollBar:setMarginTop(containerWindow.miniwindowScrollBar:getMarginTop() - containerWindow.pagePanel:getHeight())
    containerWindow.contentsPanel:setMarginTop(containerWindow.contentsPanel:getMarginTop() - containerWindow.pagePanel:getHeight())
  end
end

function refreshContainerPages(container)
  local currentPage = 1 + math.floor(container:getFirstIndex() / container:getCapacity())
  local pages = 1 + math.floor(math.max(0, (container:getSize() - 1)) / container:getCapacity())
  container.window:recursiveGetChildById('pageLabel'):setText(string.format('Page %i of %i', currentPage, pages))

  local prevPageButton = container.window:recursiveGetChildById('prevPageButton')
  if currentPage == 1 then
    prevPageButton:setEnabled(false)
  else
    prevPageButton:setEnabled(true)
    prevPageButton.onClick = function() g_game.seekInContainer(container:getId(), container:getFirstIndex() - container:getCapacity()) end
  end

  local nextPageButton = container.window:recursiveGetChildById('nextPageButton')
  if currentPage >= pages then
    nextPageButton:setEnabled(false)
  else
    nextPageButton:setEnabled(true)
    nextPageButton.onClick = function() g_game.seekInContainer(container:getId(), container:getFirstIndex() + container:getCapacity()) end
  end
  
  local pagePanel = container.window:recursiveGetChildById('pagePanel')
  if pagePanel then
    pagePanel.onMouseWheel = function(widget, mousePos, mouseWheel)
      if pages == 1 then return end
      if mouseWheel == MouseWheelUp then
        return prevPageButton.onClick()
      else
        return nextPageButton.onClick()
      end
    end
  end
end

function onContainerOpen(container, previousContainer)
  local containerWindow
  if previousContainer then
    containerWindow = previousContainer.window
    previousContainer.window = nil
    previousContainer.itemsPanel = nil
  else
    containerWindow = g_ui.createWidget('ContainerWindow', modules.game_interface.getContainerPanel())

    -- white border flash effect
    containerWindow:setBorderWidth(2)
    containerWindow:setBorderColor("#FFFFFF")
    scheduleEvent(function() 
      if containerWindow then
        containerWindow:setBorderWidth(0)
      end
    end, 300)
  end
  
  containerWindow:setId('container' .. container:getId())
  if gameStart + 1000 < g_clock.millis() then
    containerWindow:clearSettings()
  end
  
  local containerPanel = containerWindow:getChildById('contentsPanel')
  local containerItemWidget = containerWindow:getChildById('containerItemWidget')
  containerWindow.onClose = function()
    g_game.close(container)
    containerWindow:hide()
  end
  containerWindow.onDrop = function(container, widget, mousePos)
    if containerPanel:getChildByPos(mousePos) then
      return false
    end
    local child = containerPanel:getChildByIndex(-1)
    if child then
      child:onDrop(widget, mousePos, true)        
    end
  end
  
  containerWindow.onMouseRelease = function(widget, mousePos, mouseButton)
    if mouseButton == MouseButton4 then
      if container:hasParent() then
        return g_game.openParent(container)
      end
    elseif mouseButton == MouseButton5 then
      for i, item in ipairs(container:getItems()) do
        if item:isContainer() then
          return g_game.open(item, container)
        end
      end
    end
  end

  -- this disables scrollbar auto hiding
  local scrollbar = containerWindow:getChildById('miniwindowScrollBar')
  scrollbar:mergeStyle({ ['$!on'] = { }})

  local upButton = containerWindow:getChildById('upButton')
  upButton.onClick = function()
    g_game.openParent(container)
  end
  upButton:setVisible(container:hasParent())

  local name = container:getName()
  name = name:sub(1,1):upper() .. name:sub(2)
  containerWindow:setText(name)

  containerItemWidget:setItem(container:getContainerItem())

  containerPanel:destroyChildren()
  for slot=0,container:getCapacity()-1 do
    local itemWidget = g_ui.createWidget('ContainerItem', containerPanel)
    local item = container:getItem(slot)
    itemWidget:setId('item' .. slot)
    itemWidget:setItem(item)
    itemWidget:setMargin(0)
    itemWidget.position = container:getSlotPosition(slot)

    local categoryIdWidget = itemWidget:getChildById('lootCategoryId')
    categoryIdWidget:hide()
    if item then
      local iconId = getIconId(item:getLootCategory())
      if iconId ~= LOOT_CATEGORY_NONE then
        categoryIdWidget:show()
        setIconImageType(categoryIdWidget, iconId)
      end
    end

    if not container:isUnlocked() then
      itemWidget:setBorderColor('red')
    end
  end

  container.window = containerWindow
  container.itemsPanel = containerPanel

  toggleContainerPages(containerWindow, container:hasPages())
  refreshContainerPages(container)

  local layout = containerPanel:getLayout()
  local cellSize = layout:getCellSize()
  containerWindow:setContentMinimumHeight(cellSize.height)
  containerWindow:setContentMaximumHeight(cellSize.height*layout:getNumLines())

  if container:hasPages() then
    local height = containerWindow.miniwindowScrollBar:getMarginTop() + containerWindow.pagePanel:getHeight()+17
    if containerWindow:getHeight() < height then
      containerWindow:setHeight(height)
    end
  end

  if not previousContainer then
    local filledLines = math.max(math.ceil(container:getItemsCount() / layout:getNumColumns()), 1)
    containerWindow:setContentHeight(filledLines*cellSize.height)
  end
  local req = { a = "reqR", c = container:getId() }
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(OPCODE_RARITY, json.encode(req))
  end
  containerWindow:setup()
end

function onContainerClose(container)
  rarityCache[container:getId()] = nil
  forgeTierCache[container:getId()] = nil
  destroy(container)
end

function onContainerChangeSize(container, _)
  if not container.window then return end
  if container.itemsPanel then
    for slot = 0, container:getCapacity()-1 do
      clearImage(container.itemsPanel:getChildById('item'..slot))
    end
  end
  refreshContainerItems(container)
  paintContainerFrames(container)
  requestFull(container)
end

function onContainerUpdateItem(container, slot, item, oldItem)
  if not container.window then return end
  local itemWidget = container.itemsPanel:getChildById('item' .. slot)
  itemWidget:setItem(item)

  local cid = container:getId()
  rarityCache[cid] = rarityCache[cid] or {}
  forgeTierCache[cid] = forgeTierCache[cid] or {}

  if not item then
    clearImage(itemWidget)
    rarityCache[cid][slot] = 0
    forgeTierCache[cid][slot] = 0
    paintForgeTierBadge(itemWidget, 0)
  end

  local categoryIdWidget = itemWidget:getChildById('lootCategoryId')
  categoryIdWidget:hide()
  if item then
    local iconId = getIconId(item:getLootCategory())
    if iconId ~= LOOT_CATEGORY_NONE then
      categoryIdWidget:show()
      setIconImageType(categoryIdWidget, iconId)
    end
  end

  local pg = g_game.getProtocolGame()
  if pg then
    pg:sendExtendedOpcode(OPCODE_RARITY, json.encode({ a = "reqRS", c = cid, s = slot }))
  end
end

function destroyLoot()
	if lootWindow then
		lootWindow:destroy()
		lootWindow = nil
		categoriesList = nil
		currentSelect = nil
		acceptButton = nil
	end
end

function addLootCategory()
	if not lootWindow then
		return false
	end

	if not currentSelect or currentSelect == 0 then
		return false
	end

	g_game.addLootCategory(lootWindow.item, currentSelect)
	destroyLoot()
end

function onRemoveLootCategory(item)
	g_game.removeLootCategory(item)
end

function getIconId(flags)
	local iconId = LOOT_CATEGORY_NONE
	for k, v in pairs(categoriesIds) do
		local bitValue = 2 ^ k
		if g_game.bitoper(flags, bitValue, AND) then
			if iconId ~= LOOT_CATEGORY_NONE then
				return 52
			end

			iconId = v[2]
		end
	end

	return iconId
end

function getCategoryIcon(flags)
	local description = ""
	for k, v in pairs(categoriesIds) do
		local bitValue = 2 ^ k
		if g_game.bitoper(flags, bitValue, AND) then
			if description ~= "" then
				description = description .. ", "
			end

			description = description .. v[1]
		end
	end

	return description
end

function selectCategoryId(self, mousePosition, mouseButton)
	if not lootWindow then
		return false
	end

	if not currentSelect then
		currentSelect = 0
	end

	local bitValue = 2 ^ tonumber(self:getId())
	if g_game.bitoper(currentSelect, bitValue, AND) then
		currentSelect = currentSelect - bitValue
		self:setChecked(false)
	else
		currentSelect = currentSelect + bitValue
		self:setChecked(true)
	end

	acceptButton:setEnabled(currentSelect ~= 0)
end

function getImageClip(id)
	return (((id - 1) % 8) * 19) .. ' ' .. ((math.ceil(id / 8) - 1) * 19) .. ' ' .. 19 .. ' ' .. 19
end

function setIconImageType(widget, id)
	widget:setImageClip(getImageClip(id))
end

function onLootCategory(item)
	if not lootWindow then
		lootWindow = g_ui.displayUI('container_loot_category')
		lootWindow.item = item
		categoriesList = lootWindow:getChildById('categoriesList')
		acceptButton = lootWindow:getChildById('button')

		local categoryFlags = item:getLootCategory()
    for i = LOOT_CATEGORY_FIRST, LOOT_CATEGORY_LAST do
			local widget = g_ui.createWidget('LootCategory', categoriesList)
			widget:setText(categoriesIds[i][1])
			widget:setId(i)
			setIconImageType(widget:getChildById('categoryIcon'), categoriesIds[i][2])
			widget.onMouseRelease = selectCategoryId

			local bitValue = 2 ^ i
			if g_game.bitoper(categoryFlags, bitValue, AND) then
				selectCategoryId(widget)
			end
		end
	end
end
