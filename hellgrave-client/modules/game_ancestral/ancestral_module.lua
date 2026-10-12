dofile('ui/uistoreacceptbox')

local storeWindow = nil
local indexDescription = nil
local indexList = nil
local imageDesc = nil
local titleDesc = nil
local description = nil
local productList = nil
local productsTitle = nil
local acceptWindow = nil
local ancestralButton = nil
local selectedCategoryIndex = 1

local function short(value, limit)
  local text = tostring(value or '')
  limit = limit or 22
  if text:len() > limit then
    return text:sub(1, limit - 3) .. '...'
  end
  return text
end

local function formatNumbers(number)
  local ret = tostring(number or 0)
  while true do
    local formatted, changes = ret:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
    ret = formatted
    if changes == 0 then
      break
    end
  end
  return ret
end

local function clearPanel(panel)
  if not panel then
    return
  end

  local children = panel:getChildren()
  for i = 1, #children do
    children[i]:destroy()
  end
end

local function closeAcceptWindow()
  if acceptWindow then
    acceptWindow:destroy()
    acceptWindow = nil
  end
end

local function getBalance()
  local balanceLabel = storeWindow:getChildById('balanceInfo'):getChildById('coinBalance')
  local balance = balanceLabel:getText():gsub(',', '')
  return tonumber(balance) or 0
end

local function setBalance(value)
  local balanceLabel = storeWindow:getChildById('balanceInfo'):getChildById('coinBalance')
  balanceLabel:setText(formatNumbers(value))
end

local function selectCategory(index)
  selectedCategoryIndex = index

  for i = 1, #storeIndex do
    local categoryButton = indexList:getChildById('category' .. i)
    if categoryButton then
      categoryButton:setChecked(i == index)
    end
  end
end

local function buyProduct(category, product)
  if acceptWindow then
    return true
  end

  local acceptFunc = function()
    local balance = getBalance()
    if balance >= product.price then
      g_game.talk(COMMAND_BUYITEM .. ' ' .. category.id .. ', ' .. product.id)
      setBalance(balance - product.price)
    end
    closeAcceptWindow()
  end

  local cancelFunc = function()
    closeAcceptWindow()
  end

  acceptWindow = displayAcceptBox(tr('Buy ' .. product.name), tr(product.description),
    {
      { text = tr('Buy'), callback = acceptFunc },
      { text = tr('Cancel'), callback = cancelFunc },
      anchor = AnchorHorizontalCenter
    }, acceptFunc, cancelFunc)
  return true
end

local function renderProducts(categoryIndex)
  local category = storeIndex[categoryIndex]
  if not category then
    return
  end

  selectCategory(categoryIndex)
  imageDesc:setImageSource(category.image)
  titleDesc:setText(category.name)
  description:setText(category.description)
  productsTitle:setText(tr(category.name .. ' Offers'))

  clearPanel(productList)

  for i = 1, #storeProducts do
    local product = storeProducts[i]
    if product.category_id == category.id then
      local productLabel = g_ui.createWidget('ProductButton', productList)
      productLabel:setId('product' .. i)
      productLabel:setTooltip(product.tooltip or product.name)

      productLabel:getChildById('productLabelTitle'):setText(short(product.name))
      productLabel:getChildById('productLabelImage'):setImageSource(product.image)
      productLabel:getChildById('pricePanel'):getChildById('productLabelTokenPrice'):setText(formatNumbers(product.price))

      productLabel.onClick = function()
        return buyProduct(category, product)
      end
    end
  end
end

local function buildCategories()
  clearPanel(indexList)

  for i = 1, #storeIndex do
    local category = storeIndex[i]
    local button = g_ui.createWidget('StoreCategoryButton', indexList)
    button:setId('category' .. i)
    button:setIcon(category.imageList)
    button:setText(tr(category.name))
    button:setTooltip(category.description)
    button.onClick = function()
      renderProducts(i)
    end
  end
end

function init()
  g_ui.importStyle('ui/acceptwindow')
  ancestralButton = modules.client_topmenu.addRightGameToggleButton('ancestralButton', tr('Ancestral Shop'), '/images/topbuttons/ancestral', toggle, false, 8)
  storeWindow = g_ui.displayUI('ancestral_module')
  storeWindow:hide()

  g_keyboard.bindKeyPress('Ctrl+Y', toggle)
  ProtocolGame.registerExtendedOpcode(COINS_OPCODE, coinsBalance)

  indexList = storeWindow:getChildById('indexList')
  indexDescription = storeWindow:getChildById('indexDescription')
  imageDesc = indexDescription:getChildById('imageDesc')
  titleDesc = indexDescription:getChildById('titleDesc')
  description = indexDescription:getChildById('description')
  productList = storeWindow:getChildById('productList')
  productsTitle = storeWindow:getChildById('productsTitle')

  buildCategories()
  renderProducts(selectedCategoryIndex)

  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline
  })

  refresh()
end

function terminate()
  closeAcceptWindow()

  if storeWindow then
    storeWindow:destroy()
    storeWindow = nil
  end

  g_keyboard.unbindKeyPress('Ctrl+Y')
  ProtocolGame.unregisterExtendedOpcode(COINS_OPCODE)

  if ancestralButton then
    ancestralButton:destroy()
    ancestralButton = nil
  end

  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline
  })
end

function coinsBalance(protocol, opcode, buffer)
  setBalance(buffer)
end

function refresh()
  local player = g_game.getLocalPlayer()
  if not player then
    return
  end
end

function offline()
  onCloseStore()
end

function toggle()
  if storeWindow:isVisible() then
    onCloseStore()
  else
    onOpenStore()
  end
end

function onOpenStore()
  storeWindow:show()
  storeWindow:raise()
  storeWindow:focus()
  renderProducts(selectedCategoryIndex)
end

function onCloseStore()
  storeWindow:hide()
  closeAcceptWindow()
end
