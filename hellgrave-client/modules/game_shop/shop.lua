-- private variables
local SHOP_EXTENTED_OPCODE = 201
local currentCategoryPage = {}
shop = nil
transferWindow = nil
local otcv8shop = false
local shopButton = nil
local msgWindow = nil
local browsingHistory = false
local transferValue = 0
local storeUrl = ""
local coinsPacketSize = 0
local CATEGORIES = {}
local HISTORY = {}
local STATUS = {}
local AD = {}
local selectedOffer = {}
local selectedOfferWidget = nil
local searchEvent = nil
local premiumPoints = 0
local rebuildingOffers = false

local function copyOffer(data)
  local copy = {}
  for key, value in pairs(data) do
    copy[key] = value
  end
  return copy
end

local function offerWithOriginalRef(data, category, page, index)
  local offer = copyOffer(data)
  offer.originalCategory = offer.originalCategory or category
  offer.originalPage = offer.originalPage or page
  offer.originalOffer = offer.originalOffer or index
  return offer
end

local function onOfferFocusChange(widget, newOffer)
  if rebuildingOffers then
    return
  end

  if newOffer then
    selectShopOffer(newOffer)
  end
end

local function sendAction(action, data)
  if not g_game.getFeature(GameExtendedOpcode) then
    return
  end

  local protocolGame = g_game.getProtocolGame()
  if data == nil then
    data = {}
  end
  if protocolGame then
    protocolGame:sendExtendedJSONOpcode(SHOP_EXTENTED_OPCODE, {action = action, data = data})
  end 
end

local function reloadFocusedCategory()
  if not shop or not shop.categories then
    return
  end

  local category = shop.categories:getFocusedChild() or shop.categories:getChildByIndex(1)
  if not category then
    return
  end

  local id = tonumber(category:getId():match("category_(%d+)"))
  if id then
    requestPage(id, currentCategoryPage[id] or 1)
  end
end

local function onSearchTextChange(widget)
  local query = widget:getText():trim()
  if searchEvent then
    removeEvent(searchEvent)
    searchEvent = nil
  end

  if query:len() == 0 then
    reloadFocusedCategory()
    return
  end

  if query:len() < 2 then
    return
  end

  browsingHistory = false
  shop.categories:focusChild(nil)
  searchEvent = scheduleEvent(function()
    searchEvent = nil
    sendAction("search", { query = query })
  end, 250)
end

local function renderOffers(category, page, offers)
  local grouped = {}
  local visibleOffers = {}

  for index, data in ipairs(offers) do
    local offer = offerWithOriginalRef(data, category, page, index)
    if offer.group then
      local group = grouped[offer.group]
      if not group then
        group = copyOffer(offer)
        group.title = offer.groupTitle or offer.title
        group.cost = nil
        group.options = {}
        grouped[offer.group] = group
        table.insert(visibleOffers, group)
      end
      table.insert(group.options, offer)
    else
      table.insert(visibleOffers, offer)
    end
  end

  for _, offer in ipairs(visibleOffers) do
    if offer.options and offer.options[1] then
      offer.selectedOption = 1
      offer.cost = offer.options[1].cost
      offer.description = offer.options[1].description or offer.description
      offer.originalCategory = offer.options[1].originalCategory
      offer.originalPage = offer.options[1].originalPage
      offer.originalOffer = offer.options[1].originalOffer
    end
    addOffer(category, offer)
  end
end

function requestPage(categoryId, page)
  sendAction("get_page", { category = categoryId, page = page })
end

function init()
  connect(g_game, {
    onGameStart = check, 
    onGameEnd = hide,
    onStoreInit = onStoreInit,
    onStoreCategories = onStoreCategories,
    onStoreOffers = onStoreOffers,
    onStoreTransactionHistory = onStoreTransactionHistory,    
    onStorePurchase = onStorePurchase,
    onStoreError = onStoreError,
    onCoinBalance = onCoinBalance    
  })

  ProtocolGame.registerExtendedJSONOpcode(SHOP_EXTENTED_OPCODE, onExtendedJSONOpcode)

  if g_game.isOnline() then
    check()
  end
  createShop()
  createTransferWindow()
end

function terminate()
  disconnect(g_game, {
    onGameStart = check, 
    onGameEnd = hide,
    onStoreInit = onStoreInit,
    onStoreCategories = onStoreCategories,
    onStoreOffers = onStoreOffers,
    onStoreTransactionHistory = onStoreTransactionHistory,    
    onStorePurchase = onStorePurchase,
    onStoreError = onStoreError,
    onCoinBalance = onCoinBalance    
  })

  ProtocolGame.unregisterExtendedJSONOpcode(SHOP_EXTENTED_OPCODE, onExtendedJSONOpcode)

  if searchEvent then
    removeEvent(searchEvent)
    searchEvent = nil
  end

  if shopButton then
    shopButton:destroy()
    shopButton = nil
  end
  if shop then
    disconnect(shop.categories, { onChildFocusChange = changeCategory })
    disconnect(shop.offers, { onChildFocusChange = onOfferFocusChange })
    shop:destroy()
    shop = nil
  end
  if msgWindow then
    msgWindow:destroy()
  end
end

function check()
  otcv8shop = false
  sendAction("init")
end

function hide()
  if not shop then
    return
  end
  shop:hide()
end

function show()
  if not shop or not shopButton then
    return
  end
  if g_game.getFeature(GameIngameStore) then
    g_game.openStore(0)
  end
  
  shop:show()
  shop:raise()
  shop:focus()
end

function softHide()
  if not transferWindow then return end

  transferWindow:hide()
  shop:show()
end

function showTransfer()
  if not shop or not transferWindow then return end

  hide()
  transferWindow:show()
  transferWindow:raise()
  transferWindow:focus()
end

function hideTransfer()
  if not shop or not transferWindow then return end

  transferWindow:hide()
  show()
end

function toggle()
  if not shop then
    return
  end
  if shop:isVisible() then
    return hide()
  end
  show()
  check()
end

function createShop()
  if shop then return end
  shop = g_ui.displayUI('shop')
  shop:hide()

  shop.prevPage     = shop:recursiveGetChildById('prevPage')
  shop.nextPage     = shop:recursiveGetChildById('nextPage')
  shop.pageControls = shop:recursiveGetChildById('pageControls')
  shop.offerDetails = shop:recursiveGetChildById('offerDetails')
  shop.categories   = shop:recursiveGetChildById('categories')
  shop.offers       = shop:recursiveGetChildById('offers')
  shop.searchBox    = shop:recursiveGetChildById('searchBox')
  shop.pageControls:hide()
  shop.prevPage:show()
  shop.nextPage:show()
  if shop.prevPage and shop.nextPage then
    shop.nextPage.onClick = function()
      if browsingHistory then return end
      local cat = shop.categories:getFocusedChild()
      if not cat then return end
      local id   = tonumber(cat:getId():match("category_(%d+)"))
      local next = (currentCategoryPage[id] or 1) + 1
      requestPage(id, next)
    end
    shop.prevPage.onClick = function()
      if browsingHistory then return end
      local cat = shop.categories:getFocusedChild()
      if not cat then return end
      local id   = tonumber(cat:getId():match("category_(%d+)"))
      local prev = math.max(1, (currentCategoryPage[id] or 1) - 1)
      requestPage(id, prev)
    end
  end
  shopButton = modules.client_topmenu.addRightGameToggleButton(
    'shopButton', tr('Shop'),
    '/images/topbuttons/shop', toggle, false, 8
  )
  connect(shop.categories, { onChildFocusChange = changeCategory })
  connect(shop.offers, { onChildFocusChange = onOfferFocusChange })
  shop.searchBox.onTextChange = onSearchTextChange
end

function createTransferWindow()
  if transferWindow then return end
  transferWindow = g_ui.displayUI('transfer')
  transferWindow:hide()
end

function onStoreInit(url, coins)
  if otcv8shop then return end
  storeUrl = url
  if storeUrl:len() > 0 then
    if storeUrl:sub(storeUrl:len(), storeUrl:len()) ~= "/" then
      storeUrl = storeUrl .. "/"
    end
    storeUrl = storeUrl .. "64/"
    if storeUrl:sub(1, 4):lower() ~= "http" then
      storeUrl = "http://" .. storeUrl
    end
  end
  coinsPacketSize = coins
  createShop()
  createTransferWindow()
end

function onStoreCategories(categories)
  if not shop or otcv8shop then return end
  local correctCategories = {}
  for i, category in ipairs(categories) do
    local image = ""
    if category.icon:len() > 0 then
      image = storeUrl .. category.icon
    end
    table.insert(correctCategories, {
      type = "image",
      image = image,
      name = category.name,
      offers = {}
    })
  end
  processCategories(correctCategories)
end

function onStoreOffers(categoryName, offers)
  if not shop or otcv8shop then return end
  local updated = false
  for i, category in ipairs(CATEGORIES) do
    if category.name == categoryName then
      if #category.offers ~= #offers then
        updated = true
      end
      for i=1,#category.offers do
        if category.offers[i].title ~= offers[i].name or category.offers[i].id ~= offers[i].id or category.offers[i].cost ~= offers[i].price then
          updated = true
        end
      end
      if updated then    
        for offer in pairs(category.offers) do
          category.offers[offer] = nil
        end
        for i, offer in ipairs(offers) do
          local image = ""
          if offer.icon:len() > 0 then
            image = storeUrl .. offer.icon
          end
          table.insert(category.offers, {
            id=offer.id,
            type="image",
            image=image,
            cost=offer.price,
            title=offer.name,
            description=offer.description        
          })
        end
      end
    end
  end
  if not updated then
    return
  end
  local activeCategory = shop.categories:getFocusedChild()
  changeCategory(activeCategory, activeCategory)
end

function onStoreTransactionHistory(currentPage, hasNextPage, offers)
  if not shop or otcv8shop then return end
  HISTORY = {}
  for i, offer in ipairs(offers) do
    table.insert(HISTORY, {
      id=offer.id,
      type="image",
      image=storeUrl .. offer.icon,
      cost=offer.price,
      title=offer.name,
      description=offer.description        
    })
  end
  if not browsingHistory then return end  
  clearOffers()
  shop.categories:focusChild(nil)
  for i, transaction in ipairs(HISTORY) do
    addOffer(0, transaction)
  end
end

function onStorePurchase(message)
  if not shop or otcv8shop then return end
  if not transferWindow:isVisible() then
    processMessage({title="Successful shop purchase", msg=message})
  else
    processMessage({title="Successfuly gifted coins", msg=message})
    softHide()
  end
end

function onStoreError(errorType, message)
  if not shop or otcv8shop then return end
  if not transferWindow:isVisible() then
    processMessage({title="Shop Error", msg=message})
  else
    processMessage({title="Gift coins error", msg=message})
  end
end

function onCoinBalance(coins, transferableCoins)
  if not shop or otcv8shop then return end
  shop.infoPanel.points:setText(tr("Premium Points:") .. " " .. coins)
  transferWindow.coinsBalance:setText(tr('Transferable Tibia Coins: ') .. coins)
  transferWindow.coinsAmount:setMaximum(coins)
  shop.infoPanel.buy:hide()
  shop.infoPanel:setHeight(20)
end

function transferCoins()
  if not transferWindow then return end
  local amount = transferWindow.coinsAmount:getValue()
  local recipient = transferWindow.recipient:getText()

  sendAction("gift_coins", {
    name = recipient,
    amount = amount
  })

  transferWindow.recipient:setText('')
  transferWindow.coinsAmount:setValue(0)
end

function onExtendedJSONOpcode(protocol, code, json_data)
  createShop()
  createTransferWindow()

  local action = json_data['action']
  local data = json_data['data']
  local status = json_data['status']
  if not action or not data then
    return false
  end
  
  otcv8shop = true
  if action == 'categories' then
    for i, cat in ipairs(data) do
      cat.offers = {}
      currentCategoryPage[i] = 1
    end
    processCategories(data)
    sendAction("get_page", { category = 1, page = 1 })
  elseif action == 'history' then
    processHistory(data)
  elseif action == "search_results" then
    clearOffers()
    shop.pageControls:hide()
    renderOffers(-1, 1, data.offers)
    local firstOffer = shop.offers:getChildByIndex(1)
    if firstOffer then
      selectShopOffer(firstOffer)
    end
  elseif action == "category_page" then
  local catId = data.category
  local page  = data.page
  local total = CATEGORIES[catId].pages or 1

  currentCategoryPage[catId] = page

  CATEGORIES[catId].offers[page] = {}
  for i, offerData in ipairs(data.offers) do
    CATEGORIES[catId].offers[page][i] = offerData
  end

  clearOffers()
  renderOffers(catId, page, data.offers)
  local firstOffer = shop.offers:getChildByIndex(1)
  if firstOffer then
    selectShopOffer(firstOffer)
  end

  shop.pageControls:setVisible(total > 1)
  shop.prevPage:setEnabled(page > 1)
  shop.nextPage:setEnabled(page < total)
  elseif action == 'message' then
    processMessage(data)
  end

  if status then
    processStatus(status)
  end
end

function clearOffers()
  rebuildingOffers = true
  selectedOfferWidget = nil
  if shop.offerDetails then
    shop.offerDetails:hide()
  end
  while shop.offers:getChildCount() > 0 do
    local child = shop.offers:getLastChild()
    shop.offers:destroyChildren(child)
  end
  rebuildingOffers = false
end

function clearCategories()
  CATEGORIES = {}
  clearOffers()
  while shop.categories:getChildCount() > 0 do
    local child = shop.categories:getLastChild()
    shop.categories:destroyChildren(child)
  end
end

function clearHistory()
  HISTORY = {}
  if browsingHistory then
    clearOffers()
  end
end

function processCategories(data)
  if table.equal(CATEGORIES,data) then
    return
  end
  clearCategories()
  CATEGORIES = data
  for i, category in ipairs(data) do
    addCategory(category)
  end
  if not browsingHistory then
    local firstCategory = shop.categories:getChildByIndex(1)
    if firstCategory then
      firstCategory:focus()
    end
  end
end

function processHistory(data)
  if table.equal(HISTORY,data) then
    return
  end
  HISTORY = data
  if browsingHistory then
    showHistory(true)
  end
end

function processMessage(data)
  if msgWindow then
    msgWindow:destroy()
  end

  local title = tr(data["title"])
  local msg = data["msg"]
  msgWindow = displayInfoBox(title, msg)
  msgWindow.onDestroy = function(widget)
    if widget == msgWindow then
      msgWindow = nil
    end
  end
  msgWindow:show()
  msgWindow:raise()
  msgWindow:focus()
end

function processStatus(data)
  if table.equal(STATUS,data) then
    return
  end
  STATUS = data

  if data['ad'] then 
    processAd(data['ad'])
  end
  if data['points'] then
    premiumPoints = tonumber(data['points']) or premiumPoints
    shop.infoPanel.points:setText(tr("Points:") .. " " .. data['points'])
  end
  if data['buyUrl'] and data['buyUrl']:sub(1, 4):lower() == "http" then
    shop.infoPanel.buy:show()
    shop.infoPanel.buy.onMouseRelease = function() 
      scheduleEvent(function() g_platform.openUrl(data['buyUrl']) end, 50)
    end
  else
    shop.infoPanel.buy:hide()
    shop.infoPanel:setHeight(20)
  end
end

function getPremiumPoints()
  return premiumPoints
end

function processAd(data)
  if table.equal(AD,data) then
    return
  end
  AD = data

  if data['image'] and data['image']:sub(1, 4):lower() == "http" then
    HTTP.downloadImage(data['image'], function(path, err) 
      if err then g_logger.warning("HTTP error: " .. err .. " - " .. data['image']) return end
      shop.adPanel:setHeight(shop.infoPanel:getHeight())
      shop.adPanel.ad:setText("")
      shop.adPanel.ad:setImageSource(path)
      shop.adPanel.ad:setImageFixedRatio(true)
      shop.adPanel.ad:setImageAutoResize(true)
      shop.adPanel.ad:setHeight(shop.infoPanel:getHeight())
    end)
  elseif data['text'] and data['text']:len() > 0 then
      shop.adPanel:setHeight(shop.infoPanel:getHeight())
      shop.adPanel.ad:setText(data['text'])
      shop.adPanel.ad:setHeight(shop.infoPanel:getHeight())
  else
      shop.adPanel:setHeight(0)
  end
  if data['url'] and data['url']:sub(1, 4):lower() == "http" then
    shop.adPanel.ad.onMouseRelease = function() 
      scheduleEvent(function() g_platform.openUrl(data['url']) end, 50)
    end
  else
    shop.adPanel.ad.onMouseRelease = nil
  end
end

function addCategory(data)
  local category
  if data["type"] == "item" then
    category = g_ui.createWidget('ShopCategoryItem', shop.categories)  
    category.item:setItemId(data["item"])
    category.item:setItemCount(data["count"])
    category.item:setShowCount(false)
  elseif data["type"] == "outfit" then
    category = g_ui.createWidget('ShopCategoryCreature', shop.categories)
    category.creature:setOutfit(data["outfit"])
    if data["outfit"]["rotating"] then
      category.creature:setAutoRotating(true)
    end
  elseif data["type"] == "image" then
    category = g_ui.createWidget('ShopCategoryImage', shop.categories)
    if data["image"] and data["image"]:sub(1, 4):lower() == "http" then
       HTTP.downloadImage(data['image'], function(path, err) 
        if err then g_logger.warning("HTTP error: " .. err .. " - " .. data["image"]) return end
        category.image:setImageSource(path)
      end)
    else
      category.image:setImageSource(data["image"])
    end
  else
    g_logger.error("Invalid shop category type: " .. tostring(data["type"]))
    return
  end
  category:setId("category_" .. shop.categories:getChildCount())
  category.name:setText(data["name"])
end

function showHistory(force)
  -- Fixed Transaction History button
  browsingHistory = true
  if searchEvent then
    removeEvent(searchEvent)
    searchEvent = nil
  end
  if shop.searchBox and shop.searchBox:getText():len() > 0 then
    shop.searchBox.onTextChange = nil
    shop.searchBox:setText("")
    shop.searchBox.onTextChange = onSearchTextChange
  end

  if not force then
    sendAction("history")
  end

  clearOffers()
  shop.pageControls:hide()
  shop.categories:focusChild(nil)
  for i, transaction in ipairs(HISTORY) do
    addOffer(0, transaction)
  end
  local firstOffer = shop.offers:getChildByIndex(1)
  if firstOffer then
    selectShopOffer(firstOffer)
  end
end

local function setDetailPreviewVisible(details, visibleWidget)
  details.previewPanel.item:hide()
  details.previewPanel.creature:hide()
  details.previewPanel.image:hide()

  if visibleWidget then
    visibleWidget:show()
  end
end

local function clearVariantOptions(details)
  while details.variantOptions:getChildCount() > 0 do
    local child = details.variantOptions:getLastChild()
    details.variantOptions:destroyChildren(child)
  end
end

local function selectOfferOption(offer, optionIndex)
  if not offer or not offer.data or not offer.data.options then
    return
  end

  local option = offer.data.options[optionIndex]
  if not option then
    return
  end

  offer.data.selectedOption = optionIndex
  offer.data.cost = option.cost
  offer.data.selectedTitle = option.title
  offer.data.description = option.description or offer.data.description
  offer.data.originalCategory = option.originalCategory
  offer.data.originalPage = option.originalPage
  offer.data.originalOffer = option.originalOffer

  local details = shop.offerDetails
  details.detailPrice:setText(tostring(option.cost or 0))
  details.descriptionBox.description:setText(option.description or offer.data.description or "")

  for i = 1, details.variantOptions:getChildCount() do
    local child = details.variantOptions:getChildByIndex(i)
    child:setOn(i == optionIndex)
  end
end

function selectShopOffer(offer)
  if not offer or not shop.offerDetails then
    return
  end
  if offer.getParent and offer:getParent() ~= shop.offers then
    return
  end

  if selectedOfferWidget and selectedOfferWidget.setOn then
    selectedOfferWidget:setOn(false)
  end

  selectedOfferWidget = offer
  if selectedOfferWidget.setOn then
    selectedOfferWidget:setOn(true)
  end

  local data = offer.data or {}
  local details = shop.offerDetails
  details:show()
  details.name:setText(data.title or "")
  details.detailPrice:setText(tostring(data.cost or 0))
  details.descriptionBox.description:setText(data.description or "")
  details.detailBuyButton:setVisible(offer.categoryId ~= 0)
  details.detailBuyButton.onClick = function() buyOffer(offer) end
  clearVariantOptions(details)

  if data.options then
    details.variantOptions:show()
    if details.descriptionBox.setMarginBottom then
      details.descriptionBox:setMarginBottom(128)
    end
    for i, option in ipairs(data.options) do
      local optionWidget = g_ui.createWidget('ShopVariantOption', details.variantOptions)
      optionWidget.quantity:setText(option.optionLabel or ((option.wildcards or i) .. "x"))
      optionWidget.price:setText(tostring(option.cost or 0))
      optionWidget.onClick = function() selectOfferOption(offer, i) end
    end
    selectOfferOption(offer, data.selectedOption or 1)
  else
    details.variantOptions:hide()
    if details.descriptionBox.setMarginBottom then
      details.descriptionBox:setMarginBottom(64)
    end
  end

  if data.type == "item" then
    details.previewPanel.item:setItemId(data.item)
    details.previewPanel.item:setItemCount(data.count or 1)
    details.previewPanel.item:setShowCount(false)
    setDetailPreviewVisible(details, details.previewPanel.item)
  elseif data.type == "outfit" then
    details.previewPanel.creature:setOutfit(data.outfit)
    if data.outfit and data.outfit.rotating then
      details.previewPanel.creature:setAutoRotating(true)
    end
    setDetailPreviewVisible(details, details.previewPanel.creature)
  elseif data.type == "image" then
    if offer.imagePath then
      details.previewPanel.image:setImageSource(offer.imagePath)
    elseif data.image and data.image:len() > 1 then
      details.previewPanel.image:setImageSource(data.image)
    end
    setDetailPreviewVisible(details, details.previewPanel.image)
  else
    setDetailPreviewVisible(details)
  end
end

function addOffer(category, data)
  local offer
  if data["type"] == "item" then
    offer = g_ui.createWidget('ShopOfferItem', shop.offers)  
    offer.item:setItemId(data["item"])
    offer.item:setItemCount(data["count"])
    offer.item:setShowCount(false)
  elseif data["type"] == "outfit" then
    offer = g_ui.createWidget('ShopOfferCreature', shop.offers)
    offer.creature:setOutfit(data["outfit"])
    if data["outfit"]["rotating"] then
      offer.creature:setAutoRotating(true)
    end
  elseif data["type"] == "image" then
    offer = g_ui.createWidget('ShopOfferImage', shop.offers)
    if data["image"] and data["image"]:sub(1, 4):lower() == "http" then
      HTTP.downloadImage(data['image'], function(path, err) 
        if err then g_logger.warning("HTTP error: " .. err .. " - " .. data['image']) return end
        if not offer.image then return end
        offer.imagePath = path
        offer.image:setImageSource(path)
        if selectedOfferWidget == offer then
          selectShopOffer(offer)
        end
      end)
    elseif data["image"] and data["image"]:len() > 1 then
      offer.imagePath = data["image"]
      offer.image:setImageSource(data["image"])
    end
  else
    g_logger.error("Invalid shop offer type: " .. tostring(data["type"]))
    return
  end
  local newIndex = shop.offers:getChildCount() + 1
  offer:setId("offer_" .. category .. "_" .. newIndex)
  offer.title:setText(data["title"])
  if offer.rowPrice then
    offer.rowPrice:setText(tostring(data["cost"] or 0))
  end
  offer.description:setText(data["description"])  
  offer.offerId = data["id"]
  offer.data = data
  offer.categoryId = category
  offer.onClick = function() selectShopOffer(offer) end
  if category ~= 0 then
    offer.onDoubleClick = function() buyOffer(offer) end
    offer.buyButton.onClick = function() buyOffer(offer) end
  else
    offer.buyButton:hide()
    if offer.rowPrice then
      offer.rowPrice:hide()
    end
  end
end

function changeCategory(widget, newCategory)
  if not newCategory then
    return
  end

  browsingHistory = false
  if shop.searchBox and shop.searchBox:getText():len() > 0 then
    shop.searchBox:setText("")
  end

  if g_game.getFeature(GameIngameStore) and widget ~= newCategory and not otcv8shop then
    local serviceType = 0
    if g_game.getFeature(GameTibia12Protocol) then
      serviceType = 2
    end
    g_game.requestStoreOffers(newCategory.name:getText(), serviceType)
  end
  if otcv8shop then
    local id = tonumber(newCategory:getId():match("category_(%d+)"))
    currentCategoryPage[id] = 1
    sendAction("get_page", { category = id, page = 1 })
    return
  end
  local id = tonumber(newCategory:getId():split("_")[2])
  clearOffers()
  local page = currentCategoryPage[id] or 1
  local offers = CATEGORIES[id]["offers"][page]
  if offers then
    renderOffers(id, page, offers)
  end
  local firstOffer = shop.offers:getChildByIndex(1)
  if firstOffer then
    selectShopOffer(firstOffer)
  end
end

function findWidgetIndex(widget)
  local parent = widget:getParent()
  local count  = parent:getChildCount()
  for i = 1, count do
    if parent:getChildByIndex(i) == widget then
      return i
    end
  end
  return nil
end

function buyOffer(widget)
  if not widget then return end

  if widget.data and widget.data.originalCategory then
    selectedOffer = {
      category = widget.data.originalCategory,
      page     = widget.data.originalPage,
      offer    = widget.data.originalOffer,
      title    = widget.data.selectedTitle or widget.data.title,
      cost     = widget.data.cost,
      id       = widget.offerId
    }

    scheduleEvent(function()
      if msgWindow then msgWindow:destroy() end
      local title = tr("Buying from shop")
      local msg   = "Do you want to buy " .. selectedOffer.title .. " for " .. selectedOffer.cost .. " premium points?"
      msgWindow = displayGeneralBox(title, msg, {
        { text = tr('Yes'), callback = buyConfirmed },
        { text = tr('No'),  callback = buyCanceled },
        anchor = AnchorHorizontalCenter
      }, buyConfirmed, buyCanceled)
      msgWindow:show()
      msgWindow:raise()
      msgWindow:focus()
    end, 50)
    return
  end

  local parts = widget:getId():split("_")
  if #parts ~= 3 then return end
  local category = tonumber(parts[2])
  if not category then return end

  local visualRow = findWidgetIndex(widget)
  if not visualRow then
    return
  end

  local currentPage = currentCategoryPage[category] or 1
  local catData     = CATEGORIES[category]
  if not catData or type(catData.offers) ~= "table" then return end

  local pageTable = catData.offers[currentPage]
  if not pageTable or type(pageTable) ~= "table" then return end

  local item = pageTable[visualRow]
  if not item then
    return
  end

  selectedOffer = {
    category = category,
    page     = currentPage,
    offer    = visualRow,
    title    = item.title,
    cost     = item.cost,
    id       = widget.offerId
  }

  scheduleEvent(function()
    if msgWindow then msgWindow:destroy() end
    local title = tr("Buying from shop")
    local msg   = "Do you want to buy " .. item.title .. " for " .. item.cost .. " premium points?"
    msgWindow = displayGeneralBox(title, msg, {
      { text = tr('Yes'), callback = buyConfirmed },
      { text = tr('No'),  callback = buyCanceled },
      anchor = AnchorHorizontalCenter
    }, buyConfirmed, buyCanceled)
    msgWindow:show()
    msgWindow:raise()
    msgWindow:focus()
  end, 50)
end

function buyConfirmed()
  msgWindow:destroy()
  msgWindow = nil
  sendAction("buy", selectedOffer)
  if g_game.getFeature(GameIngameStore) and selectedOffer.id and not otcv8shop then
    local offerName = selectedOffer.title:lower()
    if string.find(offerName, "name") and string.find(offerName, "change") and modules.client_textedit then
      modules.client_textedit.singlelineEditor("", function(newName)
        if newName:len() == 0 then
          return
        end
        g_game.buyStoreOffer(selectedOffer.id, 1, newName)        
      end)
    else
      g_game.buyStoreOffer(selectedOffer.id, 0, "")
    end
  end
end

function buyCanceled()
  msgWindow:destroy()
  msgWindow = nil
  selectedOffer = {}
end
