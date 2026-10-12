local SHOP_EXTENDED_OPCODE = 201
local SHOP_OFFERS = {}
local SHOP_CALLBACKS = {}
local SHOP_CATEGORIES = nil
local SHOP_BUY_URL = "" -- can be empty
local SHOP_AD = { -- can be nil
  image = "",
  url = "",
  text = ""
}
local ITEMS_PER_PAGE = 10


function init()

SHOP_CATEGORIES = {}

local category1 = addCategory({
  type="item",
  item=ItemType(28084):getClientId(),
  count=1,
  name="Miscellaneous"
})
local category2 = addCategory({
  type="outfit",
  name="Outfits",
  outfit={
      mount=0,
      feet=114,
      legs=114,
      body=116,
      type=143,
      auxType=0,
      addons=3,
      head=2,
      rotating=true
  }
})
local category3 = addCategory({
  type="outfit",
  name="Mounts",
  outfit={
      mount=104,
      feet=0,
      legs=0,
      body=0,
      type=928,
      auxType=0,
      addons=0,
      head=2,
      rotating=true
  }
})
local category4 = addCategory({
  type="item",
  item=ItemType(16101):getClientId(),
  count=1,
  name="Premium Time"
})
local category5 = addCategory({
  type="item",
  item=ItemType(27760):getClientId(),
  count=100,
  name="Exercise Weapon"
})
local category6 = addCategory({
  type="item",
  item=ItemType(29627):getClientId(),
  count=1,
  name="Waystone Device"
})
local category7 = addCategory({
  type="item",
  item=ItemType(27751):getClientId(),
  count=1,
  name="Exercise Dummies"
})
local category8 = addCategory({
  type="item",
  item=ItemType(29658):getClientId(),
  count=1,
  name="House Beds"
})
local category9 = addCategory({
  type="item",
  item=ItemType(29677):getClientId(),
  count=1,
  name="House Furnitures"
})
local category10 = addCategory({
  type="item",
  item=ItemType(29734):getClientId(),
  count=1,
  name="House Others"
})
local category11 = addCategory({
  type="image",
  image="/images/game/prey/prey_store",
  name="Prey"
})

--- Category 1: Miscellaneous ---
category1.addItem(50, 28084, 10, "10 Battlepass Points", "Purchase premium battlepass or shuffle missions, you cannot claim premium rewards if you already completed levels.")
category1.addItem(220, 28084, 50, "50 Battlepass Points", "Purchase premium battlepass or shuffle missions, you cannot claim premium rewards if you already completed levels.")
category1.addItem(399, 28084, 100, "100 Battlepass Points", "Purchase premium battlepass or shuffle missions, you cannot claim premium rewards if you already completed levels.")

--- Category 2: Outfits ---
category2.addOutfit(750, {storage = 535968, mount = 0, feet = 114, legs = 114, body = 116, type = 909, auxType = 0, addons = 2, head = 2, rotating = true, name = "Shadowlotus Outfit",}, "Shadowlotus Outfit", "Full Shadowlotus Outfit with addons.")
category2.addOutfit(750, {storage = 535969, mount = 0, feet = 114, legs = 114, body = 116, type = 1237, auxType = 0, addons = 2, head = 2, rotating = true, name = "Blade Dancer Outfit",}, "Blade Dancer Outfit", "Full Blade Dancer Outfit with addons.")
category2.addOutfit(750, {storage = 534155, mount = 0, feet = 114, legs = 114, body = 116, type = 1373, auxType = 0, addons = 2, head = 2, rotating = true, name = "Fiend Slayer Outfit",}, "Fiend Slayer Outfit", "Full Fiend Slayer Outfit with addons.")
category2.addOutfit(800, {storage = 534156, mount = 0, feet = 114, legs = 114, body = 116, type = 1455, auxType = 0, addons = 2, head = 2, rotating = true, name = "Bat Knight Outfit",}, "Bat Knight Outfit", "Full Fiend Slayer Outfit with addons.")
category2.addOutfit(800, {storage = 534157, mount = 0, feet = 114, legs = 114, body = 116, type = 1458, auxType = 0, addons = 2, head = 2, rotating = true, name = "Feral Trapper Outfit",}, "Feral Trapper Outfit", "Full Feral Trapper Outfit with addons.")

--- Category 3: Mounts ---
category3.addOutfit(50, {storage = 535983, mount = 104, feet = 0, legs = 0, body = 0, type = 928, auxType = 0, addons = 0, head = 2, rotating = true, name = "Spirit of Purity"}, "Spirit of Purity", "Spirit of Purity mount.")
category3.addOutfit(690, {storage = 535984, mount = 119, feet = 0, legs = 0, body = 0, type = 1234, auxType = 0, addons = 0, head = 2, rotating = true, name = "Glacier Wyrm"}, "Glacier Wyrm", "Glacier Wyrm mount.")
category3.addOutfit(690, {storage = 535985, mount = 120, feet = 0, legs = 0, body = 0, type = 1235, auxType = 0, addons = 0, head = 2, rotating = true, name = "Bog Tyrant"}, "Bog Tyrant", "Bog Tyrant mount.")
category3.addOutfit(690, {storage = 535986, mount = 121, feet = 0, legs = 0, body = 0, type = 1236, auxType = 0, addons = 0, head = 2, rotating = true, name = "Crimson Fang"}, "Crimson Fang", "Crimson Fang mount.")
category3.addOutfit(825, {storage = 535987, mount = 142, feet = 0, legs = 0, body = 0, type = 1452, auxType = 0, addons = 0, head = 2, rotating = true, name = "Tidal Seawater Predator"}, "Tidal Seawater Predator", "Tidal Seawater Predator mount.")
category3.addOutfit(825, {storage = 535988, mount = 143, feet = 0, legs = 0, body = 0, type = 1453, auxType = 0, addons = 0, head = 2, rotating = true, name = "Ashen Coast Predator"}, "Ashen Coast Predator", "Ashen Coast Predator mount.")
category3.addOutfit(825, {storage = 535989, mount = 144, feet = 0, legs = 0, body = 0, type = 1454, auxType = 0, addons = 0, head = 2, rotating = true, name = "Crimson Bay Predator"}, "Crimson Bay Predator", "Crimson Bay Predator mount.")
category3.addOutfit(850, {storage = 535990, mount = 145, feet = 0, legs = 0, body = 0, type = 1460, auxType = 0, addons = 0, head = 2, rotating = true, name = "Battle Werewolf"}, "Battle Werewolf", "Battle Werewolf mount.")
category3.addOutfit(820, {storage = 535991, mount = 146, feet = 0, legs = 0, body = 0, type = 1461, auxType = 0, addons = 0, head = 2, rotating = true, name = "Battlefrazzle"}, "Battlefrazzle", "Battlefrazzle mount.")

--- Category 4: Premium Time ---
category4.addImage(30, "/data/images/premium/premium_time_30.png", "Premium Time 30 Days", "", customImageBuyAction)
category4.addImage(60, "/data/images/premium/premium_time_60.png", "Premium Time 60 Days", "", customImageBuyAction)
category4.addImage(90, "/data/images/premium/premium_time_90.png", "Premium Time 90 Days", "", customImageBuyAction)
category4.addImage(180, "/data/images/premium/premium_time_180.png", "Premium Time 180 Days", "", customImageBuyAction)

--- Category 11: Prey ---
category11.addImage(50, "/images/game/prey/PreyBonusReroll", "5 Wild Prey Cards", "Adds 5 Prey Wildcards to this character.", preyWildcardsBuyAction, { wildcards = 5, group = "prey_wildcard", groupTitle = "Prey Wildcard", optionLabel = "5x" })
category11.addImage(200, "/images/game/prey/PreyBonusReroll", "20 Wild Prey Cards", "Adds 20 Prey Wildcards to this character.", preyWildcardsBuyAction, { wildcards = 20, group = "prey_wildcard", groupTitle = "Prey Wildcard", optionLabel = "20x" })
category11.addImage(250, "/images/game/prey/prey_slot", "Slot 2 Prey", "Permanently unlocks your second prey slot.", preySlot2BuyAction)
category11.addImage(500, "/images/game/prey/prey_slot", "Slot 3 Prey", "Permanently unlocks your third prey slot.", preySlot3BuyAction)
category11.addImage(250, "/images/game/prey/hunting_slot", "Slot 2 Hunting Task", "Permanently unlocks your second hunting task slot.", huntingTaskSlot2BuyAction)
category11.addImage(500, "/images/game/prey/hunting_slot", "Slot 3 Hunting Task", "Permanently unlocks your third hunting task slot.", huntingTaskSlot3BuyAction)

--- Category 5: Exercise Weapons ---
category5.addItem(5, 27761, 1, "1 Exercise Sword", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(5, 27762, 1, "1 Exercise Axe", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(5, 27763, 1, "1 Exercise Club", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(5, 27764, 1, "1 Exercise Bow", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(5, 27765, 1, "1 Exercise Rod", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(5, 27766, 1, "1 Exercise Wand", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(5, 27767, 1, "1 Exercise Shield", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(5, 30026, 1, "1 Exercise Wraps", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 27768, 1, "1 Durable Exercise Sword", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 27769, 1, "1 Durable Exercise Axe", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 27770, 1, "1 Durable Exercise Club", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 27771, 1, "1 Durable Exercise Bow", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 27772, 1, "1 Durable Exercise Rod", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 27773, 1, "1 Durable Exercise Wand", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 27774, 1, "1 Durable Exercise Shield", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(15, 30027, 1, "1 Durable Exercise Wraps", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 27775, 1, "1 Lasting Exercise Sword", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 27776, 1, "1 Lasting Exercise Axe", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 27777, 1, "1 Lasting Exercise Club", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 27778, 1, "1 Lasting Exercise Bow", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 27779, 1, "1 Lasting Exercise Rod", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 27780, 1, "1 Lasting Exercise Wand", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 27781, 1, "1 Lasting Exercise Shield", "You will receive a box, use it to obtain the exercise weapon.")
category5.addItem(140, 30028, 1, "1 Lasting Exercise Wraps", "You will receive a box, use it to obtain the exercise weapon.")

--- Category 6: Waystone Device Visual Portals ---

category6.addItem(199, 29642, 1, "Stone Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29629)
category6.addItem(199, 29643, 1, "Golden Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29630)
category6.addItem(199, 29644, 1, "Blood Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29631)
category6.addItem(199, 29645, 1, "Poisonous Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29632)
category6.addItem(199, 29646, 1, "Maze Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.",  nil, 29633)
category6.addItem(199, 29647, 1, "Royal Gold Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29634)
category6.addItem(199, 29648, 1, "Demonic Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29635)
category6.addItem(199, 29649, 1, "Palace Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29636)
category6.addItem(199, 29650, 1, "Lion Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.",  nil, 29637)
category6.addItem(199, 29651, 1, "Underwater Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29638)
category6.addItem(199, 29652, 1, "Divine Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.",  nil, 29639)
category6.addItem(199, 29653, 1, "Inferno Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.", nil, 29640)
category6.addItem(199, 29654, 1, "Jade Portal Waystone Kit", "Activate the effect of Stone portal on your Waystone Portal device.",  nil, 29641)

--- Category 7: Exercise Dummies ---
category7.addItem(150, 29655, 1, "Ferumbras Exercise Dummy Kit", "Place a Ferumbras Exercise Dummy in your house to train your skills.", nil, 27751)
category7.addItem(150, 29656, 1, "Demon Exercise Dummy Kit", "Place a Demon Exercise Dummy in your house to train your skills.", nil, 27753)
category7.addItem(150, 29657, 1, "Monk Exercise Dummy Kit", "Place a Monk Exercise Dummy in your house to train your skills.", nil, 27755)
category7.addItem(199, 29787, 1, "Eldritch Exercise Dummy Kit", "Place a Eldritch Exercise Dummy in your house to train your skills.", nil, 29785)
category7.addItem(199, 29820, 1, "Halloween Exercise Dummy Kit", "Place a Halloween Exercise Dummy in your house to train your skills.", nil, 29819)
category7.addItem(199, 29838, 1, "Snowball Exercise Dummy Kit", "Place a Snowball Exercise Dummy in your house to train your skills.", nil, 29828)

--- Category 8: House Beds ---
category8.addItem(150, 29670, 1, "Knightly Bed Kit", "Replace your bed with a Knightly Bed at your house.", nil, 29658)
category8.addItem(150, 29715, 1, "Seafarer Bed Kit", "Replace your bed with a Seafarer Bed at your house.", nil, 29690)
category8.addItem(150, 29750, 1, "Opulent Kline Bed Kit", "Replace your bed with a Opulent Kline Bed at your house.", nil, 29735)
category8.addItem(150, 29783, 1, "Ember Bed Kit", "Replace your bed with a Ember Bed at your house.", nil, 29767)
category8.addItem(150, 29811, 1, "Halloween Bed Kit", "Replace your bed with a Halloween Bed at your house.", nil, 29788)

--- Category 9: House Furnitures ---
category9.addItem(35, 29679, 1, "Knightly Chair Kit", "Place a Knightly Chair to style your house.", nil, 29673)
category9.addItem(50, 29680, 1, "Knightly Table Kit", "Place a Knightly Table to style your house.", nil, 29675)
category9.addItem(50, 29681, 1, "Knightly Table Kit", "Place a Knightly Table to style your house.", nil, 29677)
category9.addItem(100, 29687, 1, "Knightly Cabinet Kit", "Place a Knightly Cabinet to style your house.", nil, 29682)
category9.addItem(65, 29688, 1, "Knightly Brasero Kit", "Place a Knightly Brasero to style your house.", nil, 29685)
category9.addItem(50, 29689, 1, "Knightly Flag Kit", "Place a Knightly Flag to style your house.", nil, 29686)
category9.addItem(35, 29717, 1, "Seafarer Chair Kit", "Place a Seafarer Chair to style your house.", nil, 29705)
category9.addItem(50, 29716, 1, "Seafarer Chest Kit", "Place a Seafarer Chest to style your house.", nil, 29702)
category9.addItem(50, 29718, 1, "Seafarer Table Kit", "Place a Seafarer Table to style your house.", nil, 29708)
category9.addItem(100, 29719, 1, "Seafarer Cabinet Kit", "Place a Seafarer Cabinet to style your house.", nil, 29709)
category9.addItem(65, 29720, 1, "Seafarer Lamp Kit", "Place a Seafarer Lamp to style your house.", nil, 29712)
category9.addItem(100, 29747, 1, "Opulent Bookcase Kit", "Place a Opulent Bookcase to style your house.", nil, 29721)
category9.addItem(100, 29748, 1, "Opulent Spice Rack Kit", "Place a Opulent Spice Rack to style your house.", nil, 29723)
category9.addItem(65, 29749, 1, "Opulent Floor Lamp Kit", "Place a Opulent Floor Lamp to style your house.", nil, 29726)
category9.addItem(35, 29759, 1, "Opulent Chair Kit", "Place a Opulent Chair to style your house.", nil, 29753)
category9.addItem(50, 29760, 1, "Opulent Table Kit", "Place a Opulent Table to style your house.", nil, 29757)
category9.addItem(35, 29781, 1, "Ember Chair Kit", "Place a Ember Chair to style your house.", nil, 29764)
category9.addItem(50, 29782, 1, "Ember Table Kit", "Place a Ember Table to style your house.", nil, 29766)
category9.addItem(65, 29784, 1, "Ember Lava Lamp Kit", "Place a Ember Lamp to style your house.", nil, 29780)
category9.addItem(50, 29812, 1, "Halloween Spider Web Kit", "Place a Halloween Spider Web to style your house.", nil, 29800)
category9.addItem(50, 29813, 1, "Halloween Roots Kit", "Place a Halloween Roots to style your house.", nil, 29801)
category9.addItem(50, 29814, 1, "Halloween Eye Kit", "Place a Halloween Eye to style your house.", nil, 29802)
category9.addItem(35, 29815, 1, "Halloween Tomb Kit", "Place a Halloween Tomb to style your house.", nil, 29803)
category9.addItem(35, 29816, 1, "Halloween Tomb n2 Kit", "Place a Halloween Tomb n2 to style your house.", nil, 29805)
category9.addItem(100, 29817, 1, "Halloween Pumpkin Kit", "Place a Halloween Pumpkin to style your house.", nil, 29809)
category9.addItem(65, 29834, 1, "Christmas Gift Kit", "Place a Christmas Gift to style your house.", nil, 29821)
category9.addItem(50, 29835, 1, "Christmas Gift Kit", "Place a Christmas Gift to style your house.", nil, 29823)
category9.addItem(35, 29836, 1, "Christmas Gift Kit", "Place a Christmas Gift to style your house.", nil, 29825)
category9.addItem(100, 29837, 1, "Christmas Three Kit", "Place a Christmas Three to style your house.", nil, 29827)
category9.addItem(100, 29839, 1, "Christmas Mailbox Kit", "Place a Mailbox Three to style your house.", nil, 29830)
category9.addItem(100, 29840, 1, "Christmas Chest Kit", "Place a Chest Three to style your house.", nil, 29833)


--- Category 10: House Others ---
category10.addItem(15, 29729, 1, "Opulent Wood Floor Plank", "Place a Opulent Floor Plank inside your ground house to change the visual style.", nil, 29730)
category10.addItem(15, 29731, 1, "Lose Opulent Floor Intarsia", "Place a Opulent Floor Intarsia inside your ground house to change the visual style.", nil, 29732)
category10.addItem(15, 29733, 1, "Rolled-Up Opulent Carpet", "Place a Opulent Carpet inside your ground house to change the visual style.", nil, 29734)


end

function addCategory(data)
  data['offers'] = {}
  table.insert(SHOP_CATEGORIES, data)
  table.insert(SHOP_CALLBACKS, {})
  local index = #SHOP_CATEGORIES
  return {
    addItem = function(cost, itemId, count, title, description, callback, displayItemId)
    if not callback then
        callback = defaultItemBuyAction
      end
      local currentPage = #SHOP_CATEGORIES[index]['offers']
      if currentPage == 0 or #SHOP_CATEGORIES[index]['offers'][currentPage] >= ITEMS_PER_PAGE then
        table.insert(SHOP_CATEGORIES[index]['offers'], {})
        currentPage = #SHOP_CATEGORIES[index]['offers']
      end
      table.insert(SHOP_CATEGORIES[index]['offers'][currentPage], {
        cost = cost,
        type = "item",
        item = ItemType(displayItemId or itemId):getClientId(),
        itemId = itemId,
        count = count,
        title = title,
        description = description
      })
      table.insert(SHOP_CALLBACKS[index], callback)
    end,
    addOutfit = function(cost, outfit, title, description, callback)
      if not callback then
        callback = defaultOutfitBuyAction
      end
      local currentPage = #SHOP_CATEGORIES[index]['offers']
      if currentPage == 0 or #SHOP_CATEGORIES[index]['offers'][currentPage] >= ITEMS_PER_PAGE then
        table.insert(SHOP_CATEGORIES[index]['offers'], {})
        currentPage = #SHOP_CATEGORIES[index]['offers']
      end
      table.insert(SHOP_CATEGORIES[index]['offers'][currentPage], {
        cost = cost,
        type = "outfit",
        outfit = outfit,
        title = title,
        description = description
      })
      table.insert(SHOP_CALLBACKS[index], callback)
      end,
    addImage = function(cost, image, title, description, callback, extraData)
      if not callback then
        callback = defaultImageBuyAction
      end
      local currentPage = #SHOP_CATEGORIES[index]['offers']
      if currentPage == 0 or #SHOP_CATEGORIES[index]['offers'][currentPage] >= ITEMS_PER_PAGE then
        table.insert(SHOP_CATEGORIES[index]['offers'], {})
        currentPage = #SHOP_CATEGORIES[index]['offers']
      end
      local offer = {
        cost = cost,
        type = "image",
        image = image,
        title = title,
        description = description
      }
      if extraData then
        for key, value in pairs(extraData) do
          offer[key] = value
        end
      end
      table.insert(SHOP_CATEGORIES[index]['offers'][currentPage], offer)
      table.insert(SHOP_CALLBACKS[index], callback)
    end
  }
end

function getStorePoints(player)
  local points = 0
  local resultId = db.storeQuery("SELECT `points` FROM `znote_accounts` WHERE `id` = " .. player:getAccountId())
  if resultId ~= false then
    points = result.getDataInt(resultId, "points")
    result.free(resultId)
  end
  return points
end

function getStatus(player)
  local status = {
    ad = SHOP_AD,
    points = getStorePoints(player),
    buyUrl = SHOP_BUY_URL
  }
  return status
end

local function getCategoriesShop()
  local skel = {}
  for i, cat in ipairs(SHOP_CATEGORIES) do
    local totalOffers = 0
    for _, pageTable in ipairs(cat.offers) do
      totalOffers = totalOffers + #pageTable
    end
    skel[i] = {
      type  = cat.type,
      name  = cat.name,
      item  = cat.item,
      count = cat.count,
      outfit= cat.outfit,
      image = cat.image,
      pages = math.ceil(totalOffers / ITEMS_PER_PAGE)
    }
  end
  return skel
end

function sendJSON(player, action, data, forceStatus)
  -- recalc status if needed
  local status = nil
  if not player:getStorageValue(1150001)
     or player:getStorageValue(1150001) + 10 < os.time()
     or forceStatus then
    status = getStatus(player)
  end
  player:setStorageValue(1150001, os.time())

  local payload = json.encode({ action = action, data = data, status = status })
  local msg = NetworkMessage()
  msg:addByte(50)
  msg:addByte(SHOP_EXTENDED_OPCODE)
  msg:addString(payload)
  msg:sendToPlayer(player)
end

function sendMessage(player, title, msg, forceStatus)
  sendJSON(player, "message", {title=title, msg=msg}, forceStatus)
end

local function getCallbackIndex(categoryId, pageNum, offerIdx)
  local callbackIndex = offerIdx
  for page = 1, pageNum - 1 do
    callbackIndex = callbackIndex + #SHOP_CATEGORIES[categoryId].offers[page]
  end
  return callbackIndex
end

local function searchOffers(player, query)
  query = tostring(query or ""):lower():match("^%s*(.-)%s*$")
  if query:len() < 2 then
    return sendJSON(player, "search_results", { offers = {} })
  end

  local matches = {}
  local maxResults = 12
  for categoryId, category in ipairs(SHOP_CATEGORIES) do
    for pageNum, pageTable in ipairs(category.offers) do
      for offerIdx, offer in ipairs(pageTable) do
        local title = tostring(offer.title or ""):lower()
        local description = tostring(offer.description or ""):lower()
        if title:find(query, 1, true) or description:find(query, 1, true) then
          local result = {}
          for key, value in pairs(offer) do
            if key ~= "description" then
              result[key] = value
            end
          end
          result.description = tostring(offer.description or ""):sub(1, 700)
          result.originalCategory = categoryId
          result.originalPage = pageNum
          result.originalOffer = offerIdx
          table.insert(matches, result)
          if #matches >= maxResults then
            return sendJSON(player, "search_results", { offers = matches })
          end
        end
      end
    end
  end

  sendJSON(player, "search_results", { offers = matches })
end

function onExtendedOpcode(player, opcode, buffer)
  if opcode ~= SHOP_EXTENDED_OPCODE then
    return false
  end
  local status, json_data = pcall(function() return json.decode(buffer) end)
  if not status then
    print("DEBUG Server: failed to decode buffer")
    return false
  end 

  local action = json_data['action']
  local data = json_data['data']
  if not action or not data then
    return false
  end

  if SHOP_CATEGORIES == nil then
    init()  
  end

  if action == 'init' then
    sendJSON(player, "categories", getCategoriesShop())
  elseif action == 'buy' then
    processBuy(player, data)
  elseif action == "search" then
    searchOffers(player, data["query"])
  elseif action == "get_page" then
  local catId = tonumber(data["category"])
  local page = tonumber(data["page"]) or 1
  if SHOP_CATEGORIES[catId] and SHOP_CATEGORIES[catId]['offers'][page] then
    sendJSON(player, "category_page", {
      category = catId,
      page = page,
      offers = SHOP_CATEGORIES[catId]['offers'][page]
    })
  end

  elseif action == "history" then
    sendHistory(player)
  --- New Transfer tibia coins + History Log
  elseif action == "gift_coins" then
  local recipientName = data["name"]
  local amount = tonumber(data["amount"])
  if not recipientName or not amount or amount <= 0 then
    return sendMessage(player, "Error!", "Invalid data provided.")
  end

  local senderAccountId = player:getAccountId()
  local senderPoints = getStorePoints(player)
  if senderPoints < amount then
    return sendMessage(player, "Error!", "You do not have enough coins.")
  end

  local resultId = db.storeQuery("SELECT `account_id` FROM `players` WHERE LOWER(`name`) = LOWER(" .. db.escapeString(recipientName) .. ")")
  if not resultId then
    return sendMessage(player, "Error!", "Recipient not found.")
  end

  local recipientAccountId = result.getDataInt(resultId, "account_id")
  result.free(resultId)

  if recipientAccountId == senderAccountId then
    return sendMessage(player, "Error!", "You cannot send coins to yourself.")
  end
  db.query("UPDATE `znote_accounts` SET `points` = `points` - " .. amount .. " WHERE `id` = " .. senderAccountId)
  db.query("UPDATE `znote_accounts` SET `points` = `points` + " .. amount .. " WHERE `id` = " .. recipientAccountId)

  local senderAccountId = player:getAccountId()
  local senderGuid = tostring(player:getGuid())

  local rawTitle = "Gifted to " .. recipientName
  local rawCost = tonumber(amount) or 0

  local coinItemId = 22118 -- Visual item ID for Tibia Coins
  local visualItemId = 22118 -- Visual item ID for Tibia Coins

  local rawJson = json.encode({
    description = "Gifted " .. amount .. " points to " .. recipientName,
    title = rawTitle,
    count = amount,
    type = "item",
    item = coinItemId,
    cost = rawCost,
    itemId = visualItemId
  })

  local escGuid  = db.escapeString(senderGuid):gsub("^'(.*)'$", "%1")
  local escTitle = db.escapeString(rawTitle):gsub("^'(.*)'$", "%1")
  local escJson  = db.escapeString(rawJson):gsub("^'(.*)'$", "%1")
  local insertSql = string.format([[
    INSERT INTO `shop_history`
      (`account`, `player`, `date`, `title`, `cost`, `details`)
    VALUES
      (%d, '%s', NOW(), '%s', %d, '%s');
  ]],
    senderAccountId,
    escGuid,
    escTitle,
    rawCost,
    escJson
  )

  db.asyncQuery(insertSql)

  return sendMessage(player, "Success!", "You have sent " .. amount .. " Tibia Coins to " .. recipientName .. ".")
  end
  return true
end

function processBuy(player, data)
  local categoryId = tonumber(data["category"])
  local pageNum    = tonumber(data["page"])  or 1
  local offerIdx   = tonumber(data["offer"]) or 1

  if not SHOP_CATEGORIES[categoryId] then
    return sendMessage(player, "Error!", "Invalid category")
  end
  local pages = SHOP_CATEGORIES[categoryId].offers
  if not pages or not pages[pageNum] then
    return sendMessage(player, "Error!", "Invalid page")
  end
  local offer    = pages[pageNum][offerIdx]
  local callback = SHOP_CALLBACKS[categoryId][getCallbackIndex(categoryId, pageNum, offerIdx)]
  if not offer or not callback
     or data["title"] ~= offer["title"]
     or data["cost"]  ~= offer["cost"] 
  then
    sendJSON(player, "categories", getCategoriesShop())
    return sendMessage(player, "Error!", "Invalid offer")
  end

  local points = getStorePoints(player)
  if not offer.cost or offer.cost > points or points < 1 then
    return sendMessage(player, "Error!",
      "You don't have enough points to buy " .. offer.title .. "!", true)
  end

  local status = callback(player, offer)
  if status == true then
    db.query("UPDATE `znote_accounts` " ..
             "SET `points` = `points` - " .. offer.cost ..
             " WHERE `id` = " .. player:getAccountId())

    local accountId = player:getAccountId()
    local rawGuid   = tostring(player:getGuid())
    local rawTitle  = offer.title
    local rawCost   = tonumber(offer.cost) or 0
    local rawJson   = json.encode(offer)
    local quotedGuid  = db.escapeString(rawGuid)
    local escGuid     = quotedGuid:gsub("^'(.*)'$", "%1")
    local quotedTitle = db.escapeString(rawTitle)
    local escTitle    = quotedTitle:gsub("^'(.*)'$", "%1")
    local quotedJson  = db.escapeString(rawJson)
    local escJson     = quotedJson:gsub("^'(.*)'$", "%1")
    local insertSql = string.format([[
      INSERT INTO `shop_history`
        (`account`,`player`,`date`,`title`,`cost`,`details`)
      VALUES
        (%d, '%s', NOW(), '%s', %d, '%s');
    ]],
      accountId,
      escGuid,
      escTitle,
      rawCost,
      escJson
    )

    db.asyncQuery(insertSql)

    return sendMessage(player, "Success!", "You bought " .. offer.title .. "!", true)
  end
  if not status then
    status = "Unknown error while buying " .. offer.title
  end
  sendMessage(player, "Error!", status)
end

function sendHistory(player)
  if player:getStorageValue(1150002) and player:getStorageValue(1150002) + 10 > os.time() then
    return -- min 10s delay
  end
  player:setStorageValue(1150002, os.time())
 
  local history = {}
  local resultId = db.storeQuery("SELECT * FROM `shop_history` WHERE `account` = " .. player:getAccountId() .. " order by `id` DESC")

  if resultId ~= false then
    repeat
      local details = result.getDataString(resultId, "details")
      local status, json_data = pcall(function() return json.decode(details) end)
      if not status then  
        json_data = {
          type = "image",
          title = result.getDataString(resultId, "title"),
          cost = result.getDataInt(resultId, "cost")
        }
      end
      table.insert(history, json_data)
      history[#history]["description"] = "Bought on " .. result.getDataString(resultId, "date") .. " for " .. result.getDataInt(resultId, "cost") .. " points."
    until not result.next(resultId)
    result.free(resultId)
  end
 
  sendJSON(player, "history", history)
end

function defaultItemBuyAction(player, offer)
  -- todo: check if has capacity
  if player:addStoreItem(offer["itemId"], offer["count"], false) then
    playSoundPlayer(player, "purchase.ogg")
    return true
  end
  return "Can't add items! Do you have enough space?";
end
-------------------------------------------------------

function defaultOutfitBuyAction(player, offer)
  local outfit = offer['outfit']
  local mountId = outfit['mount']

  if player:getStorageValue(outfit['storage']) > 0 then
      local message = "You already have this " .. outfit['name'] .. "!"
      player:sendTextMessage(MESSAGE_INFO_DESCR, message)
      return false
  end

  local points = getStorePoints(player)
  if offer['cost'] > points or points < 1 then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have enough points to buy this outfit")
      return false
  end

  if mountId ~= 0 then
    player:addMount(mountId) -- Adding the mount to the player
  end

  local outfit = offer["outfit"]
  local outfitId = player:addOutfit(outfit["type"], outfit["id"], outfit["addons"], mountId) -- Use the specified mountId

  if outfitId ~= 0 then
    player:setStorageValue(outfit['storage'], 1)

    -- Check if addons should be added
    if outfit["addons"] == 1 then
      player:addOutfitAddon(outfit["type"], 1) -- Add addon 1
      playSoundPlayer(player, "purchase.ogg")
    elseif outfit["addons"] == 2 then
      player:addOutfitAddon(outfit["type"], 1) -- Add addon 1
      player:addOutfitAddon(outfit["type"], 2) -- Add addon 2
      playSoundPlayer(player, "purchase.ogg")
    end

    local message = "You bought the " .. outfit['name'] .. "!"
    player:sendTextMessage(MESSAGE_INFO_DESCR, message)
    return true
  else
    return "Couldn't add the outfit to the player."
  end
end

function defaultImageBuyAction(player, offer)
  return "default image buy action is not implemented"
end

function customImageBuyAction(player, offer)
  local premiumDays = offer['cost'] 
  if not premiumDays or premiumDays <= 0 then
    return "Error: Invalid premium days"
  end
  playSoundPlayer(player, "purchase.ogg")
  player:addPremiumDays(premiumDays)
  player:sendTextMessage(MESSAGE_INFO_DESCR, "You bought " .. premiumDays .. " premium days!")
  return true
end

function preyWildcardsBuyAction(player, offer)
  local wildcards = tonumber(offer.wildcards) or 10
  if wildcards <= 0 then
    return "Invalid wildcard amount."
  end

  player:addPreyWildcards(wildcards)
  player:save()
  playSoundPlayer(player, "purchase.ogg")
  player:sendTextMessage(MESSAGE_INFO_DESCR, "You bought " .. wildcards .. " Wild Prey " .. (wildcards == 1 and "Card." or "Cards."))
  return true
end

function preySlot2BuyAction(player, offer)
  if player:getPreyUnlockedSlots() >= 2 then
    return "You already have prey slot 2 unlocked."
  end

  player:setPreyUnlockedSlots(2)
  player:save()
  playSoundPlayer(player, "purchase.ogg")
  player:sendTextMessage(MESSAGE_INFO_DESCR, "You permanently unlocked prey slot 2.")
  return true
end

function preySlot3BuyAction(player, offer)
  if player:getPreyUnlockedSlots() >= 3 then
    return "You already have prey slot 3 unlocked."
  end

  if player:getPreyUnlockedSlots() < 2 then
    return "You need to unlock prey slot 2 first."
  end

  player:setPreyUnlockedSlots(3)
  player:save()
  playSoundPlayer(player, "purchase.ogg")
  player:sendTextMessage(MESSAGE_INFO_DESCR, "You permanently unlocked prey slot 3.")
  return true
end

function huntingTaskSlot2BuyAction(player, offer)
  if player:getHuntingTaskUnlockedSlots() >= 2 then
    return "You already have hunting task slot 2 unlocked."
  end

  player:setHuntingTaskUnlockedSlots(2)
  player:save()
  playSoundPlayer(player, "purchase.ogg")
  player:sendTextMessage(MESSAGE_INFO_DESCR, "You permanently unlocked hunting task slot 2.")
  return true
end

function huntingTaskSlot3BuyAction(player, offer)
  if player:getHuntingTaskUnlockedSlots() >= 3 then
    return "You already have hunting task slot 3 unlocked."
  end

  if player:getHuntingTaskUnlockedSlots() < 2 then
    return "You need to unlock hunting task slot 2 first."
  end

  player:setHuntingTaskUnlockedSlots(3)
  player:save()
  playSoundPlayer(player, "purchase.ogg")
  player:sendTextMessage(MESSAGE_INFO_DESCR, "You permanently unlocked hunting task slot 3.")
  return true
end
