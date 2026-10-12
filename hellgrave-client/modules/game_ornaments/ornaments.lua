local OPCODE = 227

local window
local button
local ornamentList
local setButton
local pageLabel
local prevPageButton
local nextPageButton
local selectedCard
local selectedId = 0
local pendingOrnaments = {}
local ornaments = {}
local currentPage = 1
local pageSize = 9
local refreshScheduled = false

local function sendRequest(action, ornamentId)
  local protocol = g_game.getProtocolGame()
  if not protocol then
    return
  end
  protocol:sendExtendedOpcode(OPCODE, json.encode({
    action = action,
    ornamentId = ornamentId or 0
  }))
end

local function scheduleVisibleRefresh()
  if refreshScheduled or not g_game.isOnline() then
    return
  end

  refreshScheduled = true
  scheduleEvent(function()
    refreshScheduled = false
    if g_game.isOnline() then
      sendRequest('refresh')
    end
  end, 200)
end

local function onGameStart()
  sendRequest('refresh')
end

local function onGameEnd()
  pendingOrnaments = {}
  refreshScheduled = false
  hide()
end

local function applyToCreature(creatureId, image)
  creatureId = tonumber(creatureId) or 0
  image = image or ''
  if creatureId <= 0 then
    return
  end

  pendingOrnaments[creatureId] = image
  local creature = g_map.getCreatureById(creatureId)
  if creature then
    creature:setOrnament(image)
  end
end

local function onCreatureAppear(creature)
  if not creature or not creature:isPlayer() then
    return
  end
  local image = pendingOrnaments[creature:getId()]
  if image ~= nil then
    creature:setOrnament(image)
  else
    scheduleVisibleRefresh()
  end
end

local function selectCard(card)
  if not card or not card.ornament or not card.ornament.unlocked then
    return
  end
  selectedCard = card
  card:focus()
  setButton:setEnabled(card.ornament.id ~= selectedId)
end

local function getTotalPages()
  return math.max(1, math.ceil(#ornaments / pageSize))
end

local function createCard(ornament)
  local card = g_ui.createWidget('OrnamentCard', ornamentList)
  if not card then
    return
  end

  card.ornament = ornament
  card:setId('ornament' .. ornament.id)
  card:getChildById('name'):setText(ornament.name)
  card:getChildById('preview'):setImageSource(ornament.image)
  card:setTooltip(ornament.description or ornament.name)

  local status = card:getChildById('status')
  if ornament.unlocked then
    status:setText(ornament.id == selectedId and tr('EQUIPPED') or tr('UNLOCKED'))
    status:setColor(ornament.id == selectedId and '#F4D37A' or '#7EDB8A')
  else
    status:setText(tr('LOCKED'))
    status:setColor('#C46C6C')
    card:getChildById('preview'):setOpacity(0.25)
    card:setOpacity(0.65)
  end

  card.onClick = function()
    selectCard(card)
  end

  if ornament.id == selectedId then
    selectedCard = card
    card:focus()
  end
end

local function updatePagination()
  local totalPages = getTotalPages()
  currentPage = math.max(1, math.min(currentPage, totalPages))
  pageLabel:setText(string.format('%d / %d', currentPage, totalPages))
  prevPageButton:setEnabled(currentPage > 1)
  nextPageButton:setEnabled(currentPage < totalPages)
end

local function renderPage()
  ornamentList:destroyChildren()
  selectedCard = nil

  local startIndex = ((currentPage - 1) * pageSize) + 1
  local endIndex = math.min(#ornaments, startIndex + pageSize - 1)
  for index = startIndex, endIndex do
    createCard(ornaments[index])
  end

  setButton:setEnabled(false)
  updatePagination()
end

local function renderState(payload)
  selectedId = tonumber(payload.selectedId) or 0
  ornaments = payload.ornaments or {}
  table.sort(ornaments, function(a, b)
    local aSelected = a.id == selectedId
    local bSelected = b.id == selectedId
    if aSelected ~= bSelected then
      return aSelected
    end

    local aUnlocked = a.unlocked and 1 or 0
    local bUnlocked = b.unlocked and 1 or 0
    if aUnlocked ~= bUnlocked then
      return aUnlocked > bUnlocked
    end

    local aName = a.name or ''
    local bName = b.name or ''
    if aName ~= bName then
      return aName:lower() < bName:lower()
    end

    return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
  end)
  currentPage = math.max(1, math.min(currentPage, getTotalPages()))
  renderPage()
  for _, entry in ipairs(payload.players or {}) do
    applyToCreature(entry.creatureId, entry.image)
  end
end

local function handlePayload(payload)
  if payload.action == 'apply' then
    applyToCreature(payload.creatureId, payload.image)
  elseif payload.action == 'state' then
    renderState(payload)
  end
end

function init()
  ProtocolGame.registerExtendedJSONOpcode(OPCODE, function(protocol, opcode, payload)
    if type(payload) ~= 'table' then
      return
    end
    handlePayload(payload)
  end)
  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd
  })
  connect(Creature, {
    onAppear = onCreatureAppear
  })

  button = modules.client_topmenu.addRightGameToggleButton(
    'ornamentsButton', tr('Player Ornaments'), '/images/topbuttons/ornaments', toggle)

  window = g_ui.loadUI('ornaments', modules.game_interface.getRootPanel())
  window:hide()
  ornamentList = window:recursiveGetChildById('ornamentList')
  setButton = window:recursiveGetChildById('setButton')
  pageLabel = window:recursiveGetChildById('pageLabel')
  prevPageButton = window:recursiveGetChildById('prevPageButton')
  nextPageButton = window:recursiveGetChildById('nextPageButton')
  setButton:setEnabled(false)
  updatePagination()
end

function terminate()
  ProtocolGame.unregisterExtendedJSONOpcode(OPCODE)
  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd
  })
  disconnect(Creature, {
    onAppear = onCreatureAppear
  })

  pendingOrnaments = {}
  ornaments = {}
  refreshScheduled = false
  if button then
    button:destroy()
    button = nil
  end
  if window then
    window:destroy()
    window = nil
  end
end

function show()
  if not window or not g_game.isOnline() then
    return
  end
  window:show()
  window:raise()
  window:focus()
  button:setOn(true)
  sendRequest('open')
end

function hide()
  if window then
    window:hide()
  end
  if button then
    button:setOn(false)
  end
end

function toggle()
  if window and window:isVisible() then
    hide()
  else
    show()
  end
end

function setSelected()
  if selectedCard and selectedCard.ornament and selectedCard.ornament.unlocked then
    sendRequest('set', selectedCard.ornament.id)
  end
end

function removeOrnament()
  sendRequest('remove')
end

function previousPage()
  if currentPage <= 1 then
    return
  end

  currentPage = currentPage - 1
  renderPage()
end

function nextPage()
  if currentPage >= getTotalPages() then
    return
  end

  currentPage = currentPage + 1
  renderPage()
end
