local OPCODE = 231
local NETWORK_ACTION = {}
local extendedOpcodeChunkBuffer = nil
GuildHallLoginPacketGate = GuildHallLoginPacketGate or {
  delay = 1200,
  ready = false,
  event = nil,
  queue = {}
}
local GUILD_FEATURES = {
  storage = true,
  prism = true,
  quests = true,
  achievements = true,
  blackMarket = true,
  dynastie = true
}

local TOTAL_EMBLEMS = 57
local VocationIcon = {
  [1] = { icon = "sorcerer", name = "Sorcerer" },
  [2] = { icon = "druid", name = "Druid" },
  [3] = { icon = "paladin", name = "Paladin" },
  [4] = { icon = "knight", name = "Knight" },
  [5] = { icon = "sorcerer", name = "Master Sorcerer" },
  [6] = { icon = "elder_druid", name = "Elder Druid" },
  [7] = { icon = "royal_paladin", name = "Royal Paladin" },
  [8] = { icon = "elite_knight", name = "Elite Knight" },
  [9] = { icon = "illusionist", name = "Illusionist" },
  [10] = { icon = "arch_illusionist", name = "Arch Illusionist" },
  [11] = { icon = "monk", name = "Monk" },
  [12] = { icon = "exalted_monk", name = "Exalted Monk" },
}

local MESSAGE_STYLES = {}
local DEFAULT_MESSAGE_TYPES = {
  JOIN_INVITATION = 1,
  KICKED_OUT = 2,
  JOIN_REQUEST = 3,
  MEMBER_JOINED = 4,
  MEMBER_LEFT = 5,
  GOLD_DEPOSIT = 6,
  WAR_DECLARATION = 7,
  STORAGE_DEPOSIT = 8,
  STORAGE_WITHDRAW = 9,
  PRISM_ATTACK = 10,
  PRISM_COLLECT = 11,
  PRISM_STOLEN = 12,
  QUEST_REWARD = 13,
  BLACK_MARKET_PURCHASE = 14,
  DYNASTIE_COLLECT = 15,
  DYNASTIE_ATTACK = 16
}

local LANGUAGES = {
  "Any",
  "English",
  "Polish",
  "Portuguese",
  "German",
  "Dutch",
  "Spanish"
}

local JOIN_STATUS = {
  "Public",
  "Invite Only"
}

local maxLevel = 10000
local GUILD_STORAGE_STACK_LIMIT = 1000
local DEFAULT_WINDOW_HEIGHT = 730
local CONTRIBUTION_WINDOW_HEIGHT = 725

local window = nil
local guildsButton = nil
local settings = nil
local emblemList = nil
local emblemRadioGroup = nil
local selectedEmblemWidget = nil

local generalPanel = nil
local generalPanelBtn = nil

local membersPanel = nil
local membersPanelBtn = nil

local ranksPanel = nil
local ranksPanelBtn = nil

local inboxPanel = nil
local inboxPanelBtn = nil
local lastInbox = 0
local maxInbox = 0
local fetchingInbox = false

local topGuildsPanel = nil
local topGuildsPanelBtn = nil
local topGuilds = {}
local guildIdToTop = {}
local lastTop = 0
local maxTop = 0
local fetchingTop = false

local titleEdit = nil
local DEFAULT_CREATE_EMBLEM = 25
local createEmblem = DEFAULT_CREATE_EMBLEM

local GUILDS_CFG = {}
local myGuild = nil
local permissions = 0

local needUpdate = true

local contributionHistory = {}
local selectedContributionCurrency = "gold"
local updatingContributionCurrency = false

local perksPanel = nil
local perksPanelBtn = nil

local storageDepositWindow = nil
local storageDepositItems = {}

local storagePanel = nil
local storagePanelBtn = nil
local storageData = {
  capacity = 10,
  used = 0,
  items = {},
  selectedSlot = 0,
  search = ""
}

local prismPanel = nil
local prismPanelBtn = nil
local prismCountdownEvent = nil
local prismLootWindow = nil
local prismData = {
  capacity = 0,
  used = 0,
  locations = {},
  page = 1,
  lastPage = 1,
  total = 0,
  pageSize = 10
}
local questsPanel = nil
local questsPanelBtn = nil
local questCountdownEvent = nil
local questsData = {
  daily = {},
  weekend = {},
  monthly = {},
  dailyEndsAt = 0,
  weekendEndsAt = 0,
  monthlyEndsAt = 0
}
local achievementsPanel = nil
local achievementsPanelBtn = nil
local achievementsData = {
  achievements = {},
  page = 1,
  lastPage = 1,
  pageSize = 18,
  total = 0,
  totalFiltered = 0,
  completed = 0,
  search = ""
}
local blackMarketPanel = nil
local blackMarketPanelBtn = nil
local blackMarketCountdownEvent = nil
local blackMarketData = {
  refreshAt = 0,
  offers = {},
  fetching = false
}
local dynastiePanel = nil
local dynastiePanelBtn = nil
local dynastieCountdownEvent = nil
local dynastieManageWindow = nil
local dynastieBoardWindow = nil
local dynastieManageEntry = nil
local dynastieManageEntries = {}
local dynastieManageIndex = 1
local dynastieManageCurrentTab = "general"
local dynastieManageSelectedPerkId = nil
local dynastieTaxCooldownUntil = 0
local dynastieEventCalendarData = {
  monthOffset = 0,
  currentYear = 0,
  currentMonth = 0,
  currentDateLabel = "",
  currentMonthLabel = "",
  summary = "",
  weekdays = {},
  cities = {},
  events = {},
  days = {}
}
local dynastieBoardOffersData = {
  configId = "",
  eventName = "",
  expiresAt = 0,
  maxAccepted = 3,
  acceptedCount = 0,
  quests = {}
}
local dynastieBoardAcceptedData = {
  quests = {}
}
local dynastieAchievementData = {
  achievements = {},
  page = 1,
  lastPage = 1,
  pageSize = 18,
  completed = 0,
  total = 0,
  search = ""
}
local dynastieManageQuestData = {
  configId = "",
  daily = {},
  weekend = {},
  monthly = {},
  dailyEndsAt = 0,
  weekendEndsAt = 0,
  monthlyEndsAt = 0
}
local dynastiePassiveTreePreview = {
  defenders = {},
  selectedDefenderId = "paladin",
  selectedNodeId = nil
}
local dynastiePassiveTreeScrollOffset = { x = 0, y = 0 }
local dynastieData = {
  used = 0,
  total = 0,
  locations = {},
  ownedLocations = {},
  perks = {},
  defenders = {},
  achievements = {},
  page = 1,
  lastPage = 1,
  totalLocations = 0,
  pageSize = 6
}
local waitingGuildFetch = false
local applyLocalPlayerGuildTitle
local clearMsgBox
local setupTabButtonIcon

local function formatRemainingTime(seconds)
  seconds = math.max(0, math.floor(tonumber(seconds) or 0))
  local days = math.floor(seconds / 86400)
  seconds = seconds % 86400
  local hours = math.floor(seconds / 3600)
  seconds = seconds % 3600
  local minutes = math.floor(seconds / 60)
  local secs = seconds % 60

  if days > 0 then
    return string.format("%dd %02dh %02dm", days, hours, minutes)
  elseif hours > 0 then
    return string.format("%02dh %02dm %02ds", hours, minutes, secs)
  end

  return string.format("%02dm %02ds", minutes, secs)
end

local function clearRewardRows(container)
  if not container then
    return
  end

  local rewardsItems = container:recursiveGetChildById("rewardsItems")
  if rewardsItems then
    rewardsItems:destroyChildren()
  end

  for _, child in ipairs(container:getChildren() or {}) do
    local childId = child:getId()
    if childId ~= "rewardsFallback" and childId ~= "rewardsItems" and childId ~= "rewardsText" then
      child:destroy()
    end
  end
end

local function formatRewardSlotCount(value)
  value = math.max(1, math.floor(tonumber(value) or 1))
  if value >= 1000000 then
    local millions = value / 1000000
    return string.format(millions >= 10 and "%.0fm" or "%.1fm", millions)
  elseif value >= 1000 then
    local thousands = value / 1000
    return string.format(thousands >= 10 and "%.0fk" or "%.1fk", thousands)
  end
  return tostring(value)
end

local function renderRewardEntries(container, rewardEntries, fallbackText)
  if not container then
    return
  end

  clearRewardRows(container)
  local fallback = container:recursiveGetChildById("rewardsFallback")
  local rewardsItems = container:recursiveGetChildById("rewardsItems")
  local rewardsText = container:recursiveGetChildById("rewardsText")
  rewardEntries = type(rewardEntries) == "table" and rewardEntries or {}
  local itemsWidth = math.max(
    tonumber((rewardsItems and rewardsItems:getWidth()) or 0) or 0,
    tonumber(container:getWidth() or 0) or 0,
    ((container:getParent() and tonumber(container:getParent():getWidth() or 0)) or 0) - 16,
    220
  )

  if #rewardEntries <= 0 then
    if fallback then
      fallback:setVisible(true)
      fallback:setWidth(itemsWidth)
      fallback:setText(tostring(fallbackText or "-"))
    end
    if rewardsText then
      rewardsText:setText("")
      rewardsText:setVisible(false)
    end
    return
  end

  if fallback then
    fallback:setVisible(false)
    fallback:setWidth(itemsWidth)
  end
  if rewardsItems then
    rewardsItems:setWidth(itemsWidth)
  end
  if rewardsText then
    rewardsText:setWidth(itemsWidth)
  end

  local itemRewards = {}
  local textRewards = {}
  for _, reward in ipairs(rewardEntries) do
    if type(reward) == "table" then
      if reward.type == "item" and (tonumber(reward.clientId or reward.itemId) or 0) > 0 then
        itemRewards[#itemRewards + 1] = reward
      elseif reward.type == "icon" and tostring(reward.imageSource or "") ~= "" then
        itemRewards[#itemRewards + 1] = reward
      elseif reward.type == "text" and tostring(reward.text or "") ~= "" then
        textRewards[#textRewards + 1] = tostring(reward.text or "")
      end
    end
  end

  if #textRewards > 0 then
    if rewardsText then
      rewardsText:setVisible(true)
      rewardsText:setText(table.concat(textRewards, ", "))
    else
      local textLabel = g_ui.createWidget("Label", container)
      textLabel:setWidth(itemsWidth)
      textLabel:setHeight(18)
      textLabel:setTextAlign(AlignCenter)
      textLabel:setColor("#c7c1b6")
      textLabel:setTextWrap(false)
      textLabel:setText(table.concat(textRewards, ", "))
    end
  elseif rewardsText then
    rewardsText:setText("")
    rewardsText:setVisible(false)
  end

  if #itemRewards > 0 then
    local gridParent = rewardsItems or container
    local slotSize = 48
    local slotSpacing = 4
    local maxPerRow = math.max(1, math.min(4, math.floor((itemsWidth + slotSpacing) / (slotSize + slotSpacing))))
    local rowCount = math.max(1, math.ceil(#itemRewards / maxPerRow))
    local gridHeight = rowCount * slotSize + math.max(0, rowCount - 1) * slotSpacing
    if rewardsItems then
      rewardsItems:setHeight(gridHeight)
    end

    local previousRow = nil
    for rowIndex = 0, rowCount - 1 do
      local startIndex = rowIndex * maxPerRow + 1
      local endIndex = math.min(#itemRewards, startIndex + maxPerRow - 1)
      local itemsInRow = endIndex - startIndex + 1
      local rowWidth = itemsInRow * slotSize + math.max(0, itemsInRow - 1) * slotSpacing
      local row = g_ui.createWidget("Panel", gridParent)
      local rowLayout = UIHorizontalLayout.create(row)
      rowLayout:setSpacing(slotSpacing)
      rowLayout:setFitChildren(true)
      row:setLayout(rowLayout)
      row:setWidth(rowWidth)
      row:setHeight(slotSize)
      row:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
      if previousRow then
        row:addAnchor(AnchorTop, "prev", AnchorBottom)
        row:setMarginTop(slotSpacing)
      else
        row:addAnchor(AnchorTop, "parent", AnchorTop)
      end
      previousRow = row

      for index = startIndex, endIndex do
        local reward = itemRewards[index]
        local slot = g_ui.createWidget("GuildRewardSlot", row)

        slot.count:setText("x" .. formatRewardSlotCount(reward.count))
        slot.count:setTooltip(formatNumber(math.max(1, tonumber(reward.count) or 1)))
        if slot.icon then
          slot.icon:setVisible(false)
          if slot.icon.setImageSource then
            slot.icon:setImageSource("")
          end
        end
        if reward.type == "icon" and slot.icon and tostring(reward.imageSource or "") ~= "" then
          slot.item:setVisible(false)
          slot.icon:setVisible(true)
          if slot.icon.setImageSource then
            slot.icon:setImageSource(tostring(reward.imageSource))
          end
        else
          slot.item:setVisible(true)
          if slot.item.setVirtual then
            slot.item:setVirtual(true)
          end
          slot.item:setItemId(tonumber(reward.clientId or reward.itemId) or 0)
          if slot.item.setTooltip then
            slot.item:setTooltip(tostring(reward.name or ("Item #" .. tostring(reward.itemId or 0))))
          end
        end
        if slot.setTooltip then
          slot:setTooltip(string.format("%s x%s", tostring(reward.name or reward.text or ("Item #" .. tostring(reward.itemId or 0))), comma_value(math.max(1, tonumber(reward.count) or 1))))
        end
      end
    end
  elseif rewardsItems then
    rewardsItems:setHeight(0)
  end
end

local function stopPrismCountdown()
  if prismCountdownEvent then
    removeEvent(prismCountdownEvent)
    prismCountdownEvent = nil
  end
end

local function stopQuestCountdown()
  if questCountdownEvent then
    removeEvent(questCountdownEvent)
    questCountdownEvent = nil
  end
end

local function stopBlackMarketCountdown()
  if blackMarketCountdownEvent then
    removeEvent(blackMarketCountdownEvent)
    blackMarketCountdownEvent = nil
  end
end

local function stopDynastieCountdown()
  if dynastieCountdownEvent then
    removeEvent(dynastieCountdownEvent)
    dynastieCountdownEvent = nil
  end
end

function stopDynastieManageQuestCountdown()
  if type(dynastieManageQuestData) == "table" and dynastieManageQuestData.countdownEvent then
    removeEvent(dynastieManageQuestData.countdownEvent)
    dynastieManageQuestData.countdownEvent = nil
  end
end

local function closeDynastieManageWindowImpl()
  stopDynastieManageQuestCountdown()
  dynastieManageEntry = nil
  dynastieManageEntries = {}
  dynastieManageIndex = 1
  dynastieManageCurrentTab = "general"
  dynastieManageSelectedPerkId = nil
  dynastieTaxCooldownUntil = 0
  dynastieAchievementData = {
    achievements = {},
    page = 1,
    lastPage = 1,
    pageSize = 18,
    completed = 0,
    total = 0
  }
  dynastieManageQuestData = {
    configId = "",
    daily = {},
    weekend = {},
    monthly = {},
    dailyEndsAt = 0,
    weekendEndsAt = 0,
    monthlyEndsAt = 0,
    entrySnapshot = nil,
    pendingTaxConfigId = ""
  }
  if dynastieManageWindow then
    dynastieManageWindow:destroy()
    dynastieManageWindow = nil
  end
  if dynastieBoardWindow then
    dynastieBoardWindow:destroy()
    dynastieBoardWindow = nil
  end
end

function closeDynastieManageWindow()
  closeDynastieManageWindowImpl()
end

local refreshDynastieManageWindow
local openDynastieManageWindow
local showDynastieManageTab
local renderDynastieManageQuestTab
local renderDynastieAchievementsTab
local renderDynastieDefendersTab
local renderDynastiePerksTab
local renderDynastieBoardAcceptedTab
local renderDynastiePassiveTreeTab

local function requestDynastieAchievementsPage(page)
  page = math.max(1, math.floor(tonumber(page) or 1))
  dynastieAchievementData.page = page
  sendPacket("dynastieAchievementsFetch", { page = page, search = dynastieAchievementData.search or "" })
end

local function hasDynastieManagePermission()
  if GUILDS_CFG and GUILDS_CFG.PERMISSIONS and GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE ~= nil then
    return hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE)
  end

  return false
end

local function canManageCurrentDynastieEntry(entry)
  entry = entry or dynastieManageEntry
  if not entry or entry.id == "" then
    return false
  end

  return hasDynastieManagePermission() and entry.viewerCanManage == true and entry.ownedByViewer == true
end

local function hasOwnedDynastieSelection()
  if not dynastieManageEntry or dynastieManageEntry.id == "" then
    return false
  end

  if dynastieManageEntry.ownedByViewer == true then
    return true
  end

  if type(dynastieManageQuestData) == "table" and type(dynastieManageQuestData.entrySnapshot) == "table" then
    if tostring(dynastieManageQuestData.entrySnapshot.id or "") == tostring(dynastieManageEntry.id or "")
      and dynastieManageQuestData.entrySnapshot.ownedByViewer == true then
      return true
    end
  end

  return #(dynastieManageEntries or {}) > 0
end

local function updateDynastiePerksUpgradeButtonState()
  if not dynastieManageWindow then
    return
  end

  local upgradeButton = dynastieManageWindow:recursiveGetChildById("perksUpgradeButton")
  if not upgradeButton then
    return
  end

  if not hasOwnedDynastieSelection() then
    upgradeButton:setEnabled(false)
    if upgradeButton.disable then
      upgradeButton:disable()
    end
    return
  end

  local selectedPerk = nil
  for _, entry in ipairs(dynastieData.perks or {}) do
    if entry.id == dynastieManageSelectedPerkId then
      selectedPerk = entry
      break
    end
  end

  local canUpgrade = selectedPerk ~= nil and selectedPerk.canUpgrade == true
  upgradeButton:setEnabled(canUpgrade)
  if canUpgrade and upgradeButton.enable then
    upgradeButton:enable()
  elseif upgradeButton.disable then
    upgradeButton:disable()
  end
end

local function buildEmptyDynastieManageEntry()
  local previewEntry = (dynastieData and dynastieData.ownedLocations and dynastieData.ownedLocations[1]) or (dynastieData and dynastieData.locations and dynastieData.locations[1]) or {}
  return {
    id = "",
    name = tr("Dynasty Core"),
    city = tr("No City"),
    owned = false,
    ownedByViewer = false,
    ownedByGuild = false,
    viewerCanManage = false,
    isEmpty = true,
    isConfigured = false,
    ownerGuildName = "",
    ownerPlayerName = "",
    baseItemId = tonumber(previewEntry.baseItemId or 0) or 0,
    placedItemId = tonumber(previewEntry.placedItemId or 0) or 0,
    clientId = tonumber(previewEntry.clientId or previewEntry.placedItemId or previewEntry.baseItemId or 0) or 0,
    radius = 0,
    taxRate = 0,
    gold = 0,
    tokens = 0,
    level = 1,
    levelCap = 10,
    experience = 0,
    nextLevelExp = 1,
    maxTaxRate = 0,
    collectAvailableAt = 0,
    placedAt = 0,
    shieldUntil = 0,
    placeCooldownUntil = 0,
    canOpenPanel = true,
    canCollect = false,
    canPlace = false,
    canSetTax = false,
    canAttack = false,
    canTeleportAttack = false,
    attackCooldownUntil = 0,
    attack = nil
  }
end

local function resolveDynastieManageSelection(entries, preferredEntry, preferredIndex)
  entries = type(entries) == "table" and entries or {}
  local count = #entries
  if count <= 0 then
    return buildEmptyDynastieManageEntry(), {}, 1
  end

  local resolvedIndex = math.max(1, math.min(count, tonumber(preferredIndex) or 1))
  local resolvedEntry = entries[resolvedIndex]
  if preferredEntry and preferredEntry.id and preferredEntry.id ~= "" then
    for index, entry in ipairs(entries) do
      if entry.id == preferredEntry.id then
        resolvedIndex = index
        resolvedEntry = entry
        break
      end
    end
  end

  return resolvedEntry or entries[1], entries, resolvedIndex
end

local function syncCurrentDynastieManageEntryFromData()
  if not dynastieManageEntry or dynastieManageEntry.id == "" then
    return dynastieManageEntry
  end

  local pendingTaxConfigId = tostring(dynastieManageQuestData and dynastieManageQuestData.pendingTaxConfigId or "")
  local latestEntries = type(dynastieData and dynastieData.ownedLocations) == "table" and dynastieData.ownedLocations or {}
  local locationEntries = type(dynastieData and dynastieData.locations) == "table" and dynastieData.locations or {}
  if #latestEntries <= 0 then
    for index, entry in ipairs(locationEntries) do
      if entry.id == dynastieManageEntry.id then
        dynastieManageEntry = entry
        dynastieManageQuestData.configId = tostring(entry.id or "")
        return dynastieManageEntry
      end
    end
    return dynastieManageEntry
  end

  for index, entry in ipairs(latestEntries) do
    if entry.id == dynastieManageEntry.id then
      if pendingTaxConfigId ~= "" and tostring(entry.id or "") == pendingTaxConfigId then
        dynastieManageEntry.taxRate = tonumber(entry.taxRate or dynastieManageEntry.taxRate or 0) or 0
        dynastieManageEntry.maxTaxRate = tonumber(entry.maxTaxRate or dynastieManageEntry.maxTaxRate or 0) or 0
        dynastieManageEntry.canSetTax = entry.canSetTax
        dynastieManageEntries = latestEntries
        dynastieManageIndex = math.max(1, math.min(#dynastieManageEntries, index))
        dynastieManageEntries[index] = dynastieManageEntry
        dynastieManageQuestData.configId = tostring(dynastieManageEntry.id or "")
        if type(dynastieManageQuestData.entrySnapshot) == "table" and tostring(dynastieManageQuestData.entrySnapshot.id or "") == pendingTaxConfigId then
          dynastieManageQuestData.entrySnapshot.taxRate = dynastieManageEntry.taxRate
          dynastieManageQuestData.entrySnapshot.maxTaxRate = dynastieManageEntry.maxTaxRate
          dynastieManageQuestData.entrySnapshot.canSetTax = dynastieManageEntry.canSetTax
        end
        return dynastieManageEntry
      end
      dynastieManageEntry = entry
      dynastieManageEntries = latestEntries
      dynastieManageIndex = math.max(1, math.min(#dynastieManageEntries, index))
      dynastieManageQuestData.configId = tostring(entry.id or "")
      return dynastieManageEntry
    end
  end

  for _, entry in ipairs(locationEntries) do
    if entry.id == dynastieManageEntry.id then
      dynastieManageEntry = entry
      dynastieManageQuestData.configId = tostring(entry.id or "")
      return dynastieManageEntry
    end
  end

  return dynastieManageEntry
end

local function applyLocalDynastieTaxRate(configId, taxRate)
  configId = tostring(configId or "")
  taxRate = math.max(0, math.floor(tonumber(taxRate) or 0))
  if configId == "" then
    return
  end

  local function updateEntries(entries)
    if type(entries) ~= "table" then
      return
    end

    for _, entry in ipairs(entries) do
      if tostring(entry.id or "") == configId then
        entry.taxRate = taxRate
      end
    end
  end

  updateEntries(dynastieData and dynastieData.locations)
  updateEntries(dynastieData and dynastieData.ownedLocations)
  updateEntries(dynastieManageEntries)

  if dynastieManageEntry and tostring(dynastieManageEntry.id or "") == configId then
    dynastieManageEntry.taxRate = taxRate
  end
  if dynastieManageQuestData and type(dynastieManageQuestData.entrySnapshot) == "table" and tostring(dynastieManageQuestData.entrySnapshot.id or "") == configId then
    dynastieManageQuestData.entrySnapshot.taxRate = taxRate
  end
end

local msgBox = nil

local playerBalance = 0
local playerPremiumPoints = 0
local guildBalance = 0

local GUILD_UI_ICON_CLIPS = {
  leader = { x = 0, y = 55, width = 110, height = 110 },
  members = { x = 115, y = 55, width = 110, height = 110 },
  storage = { x = 115, y = 205, width = 110, height = 110 },
  prisms = { source = "/images/guild_hall/icons3", x = 231, y = 116, width = 115, height = 115, rect = { x = -3, y = -5, width = 18, height = 18 } },
  dynasties = { source = "/images/guild_hall/icons3", x = 346, y = 0, width = 115, height = 115, rect = { x = -3, y = -5, width = 18, height = 18 } },
  achievements = { source = "/images/guild_hall/icons3", x = 0, y = 0, width = 115, height = 115, rect = { x = -3, y = -5, width = 18, height = 18 } },
  kills = { source = "/images/guild_hall/icons2", x = 288, y = 144, width = 115, height = 115, rect = { x = -3, y = -5, width = 18, height = 18 } }, 
  created = { source = "/images/guild_hall/icons3", x = 115, y = 0, width = 115, height = 115, rect = { x = -3, y = -5, width = 18, height = 18 } },
  joinStatus = { x = 230, y = 55, width = 110, height = 110 },
  language = { x = 345, y = 55, width = 110, height = 110 },
  reqLevel = { x = 460, y = 55, width = 110, height = 110 },
  rank = { x = 0, y = 55, width = 110, height = 110 },
  total = { x = 460, y = 55, width = 110, height = 110 },
  level = { x = 0, y = 205, width = 110, height = 110 },
  contribution = { x = 115, y = 205, width = 110, height = 110 },
  donate = { x = 230, y = 205, width = 110, height = 110 },
  withdraw = { x = 345, y = 205, width = 110, height = 110 },
  premiumContribution = { x = 115, y = 205, width = 110, height = 110 },
  premiumDonate = { x = 230, y = 205, width = 110, height = 110 }
}

local GUILD_TAB_ICON_CLIPS = {
  general = {
    source = "/images/guild_hall/icons2",
    clip = { x = 144, y = 288, width = 144, height = 144 },
    marginLeft = 16,
    marginTop = 3
  },

  members = {
    source = "/images/guild_hall/icons",
    clip = { x = 117, y = 55, width = 96, height = 96 },
    marginLeft = 7,
    marginTop = -6
  },

  ranks = {
    source = "/images/guild_hall/icons2",
    clip = { x = 0, y = -2, width = 144, height = 144 },
    marginLeft = 16,
    marginTop = -3
  },

  perks = {
    source = "/images/guild_hall/icons2",
    clip = { x = 144, y = 144, width = 144, height = 144 },
    marginLeft = 20,
    marginTop = -1
  },

  storage = {
    source = "/images/guild_hall/icons2",
    clip = { x = 288, y = 0, width = 144, height = 144 },
    marginLeft = 11,
    marginTop = -3
  },

  prism = {
    source = "/images/guild_hall/icons3",
    clip = { x = 231, y = 116, width = 115, height = 115 },
    marginLeft = 17,
    marginTop = 1
  },

  quests = {
    source = "/images/guild_hall/icons2",
    clip = { x = 144, y = 288, width = 144, height = 144 },
    marginLeft = 14,
    marginTop = 3
  },

  achievements = {
    source = "/images/guild_hall/icons3",
    clip = { x = 0, y = 0, width = 115, height = 115 },
    marginLeft = -7,
    marginTop = -1
  },

  blackmarket = {
    source = "/images/guild_hall/icons3",
    clip = { x = 0, y = 116, width = 115, height = 115 },
    marginLeft = -4,
    marginTop = 2
  },

  dynastie = {
    source = "/images/guild_hall/icons3",
    clip = { x = 346, y = 0, width = 115, height = 115 },
    marginLeft = 15,
    marginTop = -1
  },

  inbox = {
    source = "/images/guild_hall/icons2",
    clip = { x = 432, y = 0, width = 144, height = 144 },
    marginLeft = 22,
    marginTop = -4
  },

  top = {
    source = "/images/guild_hall/icons3",
    clip = { x = 346, y = 116, width = 115, height = 115 },
    marginLeft = 10,
    marginTop = 1
  }
}

local DYNASTIE_MANAGE_TAB_ICON_CLIPS = {
  general = {
    source = "/images/guild_hall/icons3",
    clip = { x = 462, y = 0, width = 115, height = 115 },
    marginLeft = 56,
    marginTop = -1
  },
  quests = {
    source = "/images/guild_hall/icons3",
    clip = { x = 115, y = 0, width = 115, height = 115 },
    marginLeft = 25,
    marginTop = -1
  },
  achievements = {
    source = "/images/guild_hall/icons3",
    clip = { x = 0, y = 0, width = 115, height = 115 },
    marginLeft = 32,
    marginTop = -1
  },
  perks = {
    source = "/images/guild_hall/icons2",
    clip = { x = 144, y = 144, width = 144, height = 144 },
    marginLeft = 34,
    marginTop = -1
  },
  defenders = {
    source = "/images/guild_hall/icons3",
    clip = { x = 231, y = 0, width = 115, height = 115 },
    marginLeft = 39,
    marginTop = 0
  },
  passivetree = {
    source = "/images/guild_hall/icons2",
    clip = { x = 0, y = 144, width = 144, height = 144 },
    marginLeft = 34,
    marginTop = -1
  },
  events = {
    source = "/images/guild_hall/icons3",
    clip = { x = 115, y = 0, width = 115, height = 115 },
    marginLeft = 31,
    marginTop = -1
  },
  boardquests = {
    source = "/images/guild_hall/icons3",
    clip = { x = 115, y = 0, width = 115, height = 115 },
    marginLeft = 31,
    marginTop = -1
  }
}

local function fitTabPanel(panel)
  if not panel or not window or not window.content then
    return
  end

  panel:setSize(window.content:getSize())
end

local function fitAllTabPanels()
  fitTabPanel(generalPanel)
  fitTabPanel(membersPanel)
  fitTabPanel(ranksPanel)
  fitTabPanel(perksPanel)
  fitTabPanel(storagePanel)
  fitTabPanel(prismPanel)
  fitTabPanel(questsPanel)
  fitTabPanel(achievementsPanel)
  fitTabPanel(blackMarketPanel)
  fitTabPanel(dynastiePanel)
  fitTabPanel(inboxPanel)
  fitTabPanel(topGuildsPanel)
end

local function setStorageTabActive(active)
  if not storagePanelBtn then
    return
  end

  storagePanelBtn:setChecked(active)
  storagePanelBtn:setImageColor(active and "#dfdfdf" or "#817d77")
end

local function setPrismTabActive(active)
  if not prismPanelBtn then
    return
  end

  prismPanelBtn:setChecked(active)
  prismPanelBtn:setImageColor(active and "#dfdfdf" or "#817d77")
end

local function setQuestsTabActive(active)
  if not questsPanelBtn then
    return
  end

  questsPanelBtn:setChecked(active)
  questsPanelBtn:setImageColor(active and "#dfdfdf" or "#817d77")
end

local function setAchievementsTabActive(active)
  if not achievementsPanelBtn then
    return
  end

  achievementsPanelBtn:setChecked(active)
  achievementsPanelBtn:setImageColor(active and "#dfdfdf" or "#817d77")
end

local function setBlackMarketTabActive(active)
  if not blackMarketPanelBtn then
    return
  end

  blackMarketPanelBtn:setChecked(active)
  blackMarketPanelBtn:setImageColor(active and "#dfdfdf" or "#817d77")
end

local function setDynastieTabActive(active)
  if not dynastiePanelBtn then
    return
  end

  dynastiePanelBtn:setChecked(active)
  dynastiePanelBtn:setImageColor(active and "#dfdfdf" or "#817d77")
end

local function applyBlackMarketButtonState(button, canBuy, purchased)
  if not button then
    return
  end

  if button.setEnabled then
    button:setEnabled(canBuy)
  end
  if canBuy and button.enable then
    button:enable()
  elseif (not canBuy) and button.disable then
    button:disable()
  end

  button:setOpacity(canBuy and 1.0 or 0.55)
  button:setText(purchased and tr("Purchased") or tr("Purchase"))

  if canBuy then
    button:setTooltip("")
  elseif purchased then
    button:setTooltip(tr("Your guild already purchased this offer."))
  else
    button:setTooltip(tr("This offer is not currently available."))
  end
end

local function clearSecondaryGuildTabSelection()
  local secondaryTabs = window and window:recursiveGetChildById("secondaryTabs")
  if not secondaryTabs then
    return
  end

  for _, child in ipairs(secondaryTabs:getChildren()) do
    child:setOn(false)
    child:setChecked(false)
    child:setImageColor("#817d77")
  end
end

local function setGuildFooterVisible(visible)
  if not window or not window.balanceBase then
    return
  end

  visible = visible and not window.balanceBase.locked
  window.balanceBase:setVisible(visible)
  window.balanceLabel:setVisible(visible)
  if window.balanceIcon then window.balanceIcon:setVisible(visible) end
  window.premiumBalanceBase:setVisible(visible)
  window.premiumBalanceLabel:setVisible(visible)
  if window.premiumBalanceIcon then window.premiumBalanceIcon:setVisible(visible) end
  window.dynastieTokenBase:setVisible(visible)
  window.dynastieTokenLabel:setVisible(visible)
  if window.dynastieTokenIcon then window.dynastieTokenIcon:setVisible(visible) end
end

local function getStorageSlotEntries()
  if not storageData or type(storageData.items) ~= "table" then
    return {}
  end

  local entries = {}
  local query = (storageData.search or ""):lower():trim()
  for slot = 1, storageData.capacity or 0 do
    local entry = storageData.items[slot]
    if query == "" then
      table.insert(entries, { slot = slot, data = entry })
    elseif entry then
      local name = tostring(entry.name or ""):lower()
      local id = tostring(entry.itemId or "")
      if name:find(query, 1, true) or id:find(query, 1, true) then
        table.insert(entries, { slot = slot, data = entry })
      end
    end
  end

  return entries
end

local function updateSelectedStorageLabel()
  if not storagePanel then
    return
  end

  local label = storagePanel:recursiveGetChildById("selectedItemLabel")
  if not label then
    return
  end

  local selected = storageData.items and storageData.items[storageData.selectedSlot]
  if not selected then
    label:setText(tr("Select a storage slot to withdraw an item."))
    return
  end

  label:setText(string.format("%s x%s (slot %d)", selected.name or ("Item #" .. selected.itemId), comma_value(selected.count or 0), storageData.selectedSlot))
end

local function renderStorageGrid()
  if not storagePanel then
    return
  end

  local grid = storagePanel:recursiveGetChildById("storageGrid")
  local capacityLabel = storagePanel:recursiveGetChildById("capacityLabel")
  if not grid then
    return
  end

  if capacityLabel then
    capacityLabel:setText(string.format("%s %d / %d", tr("Slots:"), tonumber(storageData.used or 0) or 0, tonumber(storageData.capacity or 0) or 0))
  end

  grid:destroyChildren()

  for _, slotEntry in ipairs(getStorageSlotEntries()) do
    local widget = g_ui.createWidget("GuildStorageSlot", grid)
    widget.slot = slotEntry.slot
    local itemData = slotEntry.data
    if widget.slotNumber then
      widget.slotNumber:setText(tostring(slotEntry.slot))
    end

    if widget.count then
      widget.count:setText("")
    end

    if itemData then
      widget.item:setItemId(itemData.clientId or 0)
      widget.item:setItemCount(itemData.count or 0)
      local tooltip = itemData.tooltip
      if not tooltip or tooltip == "" then
        tooltip = string.format("%s (%s)", itemData.name or ("Item #" .. itemData.itemId), comma_value(itemData.count or 0))
      end
      widget:setTooltip(tooltip)
      widget.item:setTooltip(tooltip)
      widget.count:setText("")

      if itemData.attributesHex and itemData.attributesHex ~= "" then
        widget.onHoverChange = function(self, hovered)
          if hovered and modules.game_tooltip and modules.game_tooltip.m_TooltipFunction then
            modules.game_tooltip.m_TooltipFunction.createGuildStorage(self:getPosition(), self.item:getItem(), itemData.attributesHex, itemData.count or 1)
          elseif not hovered and modules.game_tooltip and modules.game_tooltip.m_TooltipFunction then
            modules.game_tooltip.m_TooltipFunction.destroy()
          end
        end
      else
        widget.onHoverChange = nil
      end
    else
      widget:setTooltip(tr("Empty slot"))
      widget.item:setItemId(0)
      widget.item:setItemCount(0)
      widget.item:setTooltip(tr("Empty slot"))
    end

    local function selectStorageSlot(self)
      for _, child in ipairs(grid:getChildren()) do
        child:setChecked(false)
      end

      self:setChecked(true)
      storageData.selectedSlot = self.slot

      updateSelectedStorageLabel()
    end

    widget.onClick = selectStorageSlot
    widget.onMousePress = function(self, mousePos, button)
      if button == MouseLeftButton then
        selectStorageSlot(self)
        return true
      end
      return false
    end

    if storageData.selectedSlot == slotEntry.slot then
      widget:onClick()
    end
  end

  if storageData.selectedSlot > 0 and not storageData.items[storageData.selectedSlot] then
    storageData.selectedSlot = 0
  end
  updateSelectedStorageLabel()
end

function onStorageSearchChange(text)
  storageData.search = text or ""
  renderStorageGrid()
end

function onGuildStorageData(data)
  storageData.items = {}
  storageData.used = 0
  storageData.capacity = 10
  storageData.selectedSlot = 0

  if type(data) == "table" then
    storageData.capacity = tonumber(data.capacity or 10) or 10
    storageData.used = tonumber(data.used or 0) or 0
    if type(data.items) == "table" then
      for _, entry in ipairs(data.items) do
        local slot = tonumber(entry.slot) or 0
        if slot > 0 then
          storageData.items[slot] = entry
        end
      end
    end
  end

  renderStorageGrid()
end

function openStorageDeposit()
  if storageDepositWindow then
    storageDepositWindow:destroy()
    storageDepositWindow = nil
  end

  storageDepositItems = {}

  storageDepositWindow = g_ui.createWidget("GuildStorageDepositWindow", rootWidget)
  if not storageDepositWindow then
    return
  end

  storageDepositWindow:raise()
  storageDepositWindow:focus()

  local slotsPanel = storageDepositWindow:recursiveGetChildById("depositSlots")
  if not slotsPanel then
    return
  end

  for i = 1, 5 do
    local slot = slotsPanel:getChildById("depositSlot" .. i)
    if slot then
      slot.depositIndex = i
      slot:setItemId(0)
      slot:setItemCount(0)
      slot:setTooltip(tr("Drag an item here."))

      slot.onDrop = function(self, draggedWidget, mousePos)
        if not draggedWidget then
          return false
        end

        local serverId = 0
        local itemId = 0
        local clientId = 0
        local count = 1

        if draggedWidget.getItemId then
          clientId = tonumber(draggedWidget:getItemId()) or 0
        end

        if draggedWidget.getItemCount then
          count = tonumber(draggedWidget:getItemCount()) or 1
        end

        if clientId <= 0 then
          return false
        end

        if count <= 0 then
          count = 1
        end

        if count > GUILD_STORAGE_STACK_LIMIT then
          count = GUILD_STORAGE_STACK_LIMIT
        end

        local tooltip = ""
        local draggedThing = draggedWidget.currentDragThing
        if draggedThing and draggedThing.getTooltip then
          tooltip = tostring(draggedThing:getTooltip() or "")
        end

        local itemPosition = nil
        local itemStackPos = 0
        if draggedThing then
          if draggedThing.getPosition then
            local pos = draggedThing:getPosition()
            if pos then
              itemPosition = { x = pos.x, y = pos.y, z = pos.z }
            end
          end
          if draggedThing.getStackPos then
            itemStackPos = tonumber(draggedThing:getStackPos()) or 0
          end
        end

        if tooltip == "" and draggedWidget.getTooltip then
          tooltip = tostring(draggedWidget:getTooltip() or "")
        end

        if tooltip == "" then
          tooltip = string.format("Client ID: %d\nCount: %d", clientId, count)
        end

        storageDepositItems[self.depositIndex] = {
          clientId = clientId,
          itemId = clientId,
          count = count,
          tooltip = tooltip,
          position = itemPosition,
          stackPos = itemStackPos,
          thing = draggedThing
        }

        self:setItemId(clientId)
        self:setItemCount(count)
        self:setTooltip(tooltip)

        return true
      end

      slot.onHoverChange = function(self, hovered)
        local entry = storageDepositItems[self.depositIndex]
        if hovered and entry and entry.thing and modules.game_tooltip and modules.game_tooltip.m_TooltipFunction then
          modules.game_tooltip.m_TooltipFunction.create(self:getPosition(), entry.thing, false)
        elseif not hovered and modules.game_tooltip and modules.game_tooltip.m_TooltipFunction then
          modules.game_tooltip.m_TooltipFunction.destroy()
        end
      end

      slot.onClick = function(self)
        self:setChecked(true)
      end

      slot.onDoubleClick = function(self)
        storageDepositItems[self.depositIndex] = nil
        self:setItemId(0)
        self:setItemCount(0)
        self:setTooltip(tr("Drag an item here."))
      end
    end
  end
end

function clearGuildStorageDepositWindow()
  storageDepositItems = {}

  if not storageDepositWindow then
    return
  end

  local slotsPanel = storageDepositWindow:recursiveGetChildById("depositSlots")
  if not slotsPanel then
    return
  end

  for i = 1, 5 do
    local slot = slotsPanel:getChildById("depositSlot" .. i)
    if slot then
      slot:setItemId(0)
      slot:setItemCount(0)
      slot:setTooltip(tr("Drag an item here."))
    end
  end
end

function confirmGuildStorageDeposit()
  local items = {}

  for i = 1, 5 do
    local entry = storageDepositItems[i]
    if entry and entry.itemId and entry.itemId > 0 then
      table.insert(items, {
        itemId = entry.itemId,
        clientId = entry.clientId,
        count = entry.count or 1,
        tooltip = entry.tooltip or "",
        position = entry.position,
        stackPos = entry.stackPos
      })
    end
  end

  if #items == 0 then
    displayInfoBox(tr("Guild Storage"), tr("Drag at least one item from your backpack."))
    return
  end

  sendPacket("storageDepositBatch", {
    items = items
  })

  if storageDepositWindow then
    storageDepositWindow:destroy()
    storageDepositWindow = nil
  end

  storageDepositItems = {}
end

function withdrawSelectedStorageItem()
  local slot = tonumber(storageData.selectedSlot or 0) or 0

  if slot <= 0 then
    displayInfoBox(tr("Guild Storage"), tr("Select a stored item first."))
    return
  end

  local selected = storageData.items and storageData.items[slot]
  if not selected then
    displayInfoBox(tr("Guild Storage"), tr("Selected storage slot is empty."))
    return
  end

  sendPacket("storageWithdraw", {
    slot = slot,
    count = selected.count or 1
  })
end

local function clearMainGuildTabSelection()
  local buttonsPanel = window and window.tabBar and window.tabBar:getChildById("buttonsPanel")
  if not buttonsPanel then
    return
  end

  for _, child in ipairs(buttonsPanel:getChildren()) do
    child:setOn(false)
    child:setChecked(false)
    child:setImageColor("#817d77")
  end
end

local function showStorageTab()
  if not storagePanel or not window then
    return
  end

  stopPrismCountdown()
  stopQuestCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()

  if generalPanel then generalPanel:hide() end
  if membersPanel then membersPanel:hide() end
  if ranksPanel then ranksPanel:hide() end
  if perksPanel then perksPanel:hide() end
  if prismPanel then prismPanel:hide() end
  if questsPanel then questsPanel:hide() end
  if achievementsPanel then achievementsPanel:hide() end
  if blackMarketPanel then blackMarketPanel:hide() end
  if dynastiePanel then dynastiePanel:hide() end
  if inboxPanel then inboxPanel:hide() end
  if topGuildsPanel then topGuildsPanel:hide() end
  clearMainGuildTabSelection()
  clearSecondaryGuildTabSelection()
  if window and window.tabBar then
    window.tabBar.currentTab = nil
  end
  storagePanel:show()
  storagePanel:raise()
  fitTabPanel(storagePanel)

  storageData.capacity = tonumber(storageData.capacity or 10) or 10
  storageData.used = tonumber(storageData.used or 0) or 0
  storageData.items = storageData.items or {}
  storageData.selectedSlot = tonumber(storageData.selectedSlot or 0) or 0
  storageData.search = storageData.search or ""

  renderStorageGrid()
  sendPacket("storageFetch")

  window.inboxFilterBtn:hide()
  setGuildFooterVisible(true)
  setStorageTabActive(true)
  setPrismTabActive(false)
  setQuestsTabActive(false)
  setAchievementsTabActive(false)
  setBlackMarketTabActive(false)
  setDynastieTabActive(false)
end

local function renderPrismCards()
  if not prismPanel then
    return
  end

  local list = prismPanel:recursiveGetChildById("prismList")
  local capacityLabel = prismPanel:recursiveGetChildById("capacityLabel")
  local pageLabel = prismPanel:recursiveGetChildById("pageLabel")
  local prevPageButton = prismPanel:recursiveGetChildById("prevPageButton")
  local nextPageButton = prismPanel:recursiveGetChildById("nextPageButton")
  if not list then
    return
  end

  list:destroyChildren()

  if capacityLabel then
    capacityLabel:setText(string.format("Prisms: %d / %d", tonumber(prismData.used or 0) or 0, tonumber(prismData.capacity or 0) or 0))
  end
  if pageLabel then
    pageLabel:setText(string.format("%d / %d", tonumber(prismData.page or 1) or 1, tonumber(prismData.lastPage or 1) or 1))
  end
  if prevPageButton then
    prevPageButton:setEnabled((tonumber(prismData.page or 1) or 1) > 1)
    prevPageButton.onClick = function()
      local currentPage = tonumber(prismData.page or 1) or 1
      if currentPage > 1 then
        sendPacket("prismFetch", { page = currentPage - 1 })
      end
    end
  end
  if nextPageButton then
    nextPageButton:setEnabled((tonumber(prismData.page or 1) or 1) < (tonumber(prismData.lastPage or 1) or 1))
    nextPageButton.onClick = function()
      local currentPage = tonumber(prismData.page or 1) or 1
      local lastPage = tonumber(prismData.lastPage or 1) or 1
      if currentPage < lastPage then
        sendPacket("prismFetch", { page = currentPage + 1 })
      end
    end
  end

  for _, entry in ipairs(prismData.locations or {}) do
    local card = g_ui.createWidget("GuildPrismCard", list)
    card.configId = entry.id
    card.entry = entry
    card.location:setText(entry.name or "Prism")
    card.owner:setText(entry.isEmpty and tr("Empty") or tr("Owned by %s", entry.ownerGuildName or "Unknown"))
    card.placer:setText((entry.ownerPlayerName and entry.ownerPlayerName ~= "") and tr("Placed by %s", entry.ownerPlayerName) or "")
    card.prismItem:setItemId(tonumber(entry.placedItemId) or tonumber(entry.baseItemId) or 0)
    if card.prismItem.setOpacity then
      card.prismItem:setOpacity(entry.isEmpty and 0.45 or 1.0)
    end

    if not entry.isConfigured then
      card.status:setText(tr("Not configured yet."))
    elseif entry.isEmpty then
      if tonumber(entry.placeCooldownUntil or 0) > os.time() then
        card.status:setText(string.format("Place cooldown: %s", formatRemainingTime((tonumber(entry.placeCooldownUntil) or 0) - os.time())))
      else
        card.status:setText(tr("Available prism location"))
      end
    else
      local statusText
      if entry.attack and entry.attack.status == "preparing" then
        statusText = string.format("Attack in: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.startsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0)
      elseif entry.attack and entry.attack.status == "active" then
        statusText = string.format("Battle: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.endsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0)
      elseif tonumber(entry.shieldUntil or 0) > os.time() then
        statusText = string.format("Shielded: %s", formatRemainingTime((tonumber(entry.shieldUntil) or 0) - os.time()))
      else
        local remainingText = "-"
        if tonumber(entry.expiresAt or 0) > 0 then
          remainingText = formatRemainingTime((tonumber(entry.expiresAt) or 0) - os.time())
        end
        statusText = string.format("Radius: %d | Remaining: %s", tonumber(entry.radius) or 0, remainingText)
      end
      card.status:setText(statusText)
    end

    card.loot:setText(string.format("Loot: %d / %d", tonumber(entry.lootUsed or 0) or 0, tonumber(entry.lootLimit or 0) or 0))
    card.stored:setText(string.format("Gold: %s | Exp: %s", comma_value(tonumber(entry.goldBuffer or 0) or 0), comma_value(tonumber(entry.expBuffer or 0) or 0)))
    local canManagePrism = false
    if GUILDS_CFG and GUILDS_CFG.PERMISSIONS and GUILDS_CFG.PERMISSIONS.MANAGE_PRISM ~= nil then
      canManagePrism = hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_PRISM)
    end
    local canPlaceNow = entry.isConfigured and entry.isEmpty and myGuild ~= nil and canManagePrism and (tonumber(entry.placeCooldownUntil or 0) or 0) <= os.time()
    local showCollect = entry.owned == true and not entry.attack and canManagePrism
    local showView = not entry.isEmpty
    local showTeleport = entry.owned == true or entry.canTeleportAttack == true
    local showAttack = entry.canAttack == true and canManagePrism

    card.placeButton:setVisible(canPlaceNow)
    card.collectButton:setVisible(showCollect)
    card.viewButton:setVisible(showView)
    card.teleportButton:setVisible(showTeleport)
    card.attackButton:setVisible(showAttack)

    if showView and showAttack then
      card.viewButton:breakAnchors()
      card.viewButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
      card.viewButton:addAnchor(AnchorLeft, 'parent', AnchorLeft)
      card.viewButton:setMarginLeft(10)
      card.viewButton:setMarginBottom(5)
      card.viewButton:setWidth(84)

      card.attackButton:breakAnchors()
      card.attackButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
      card.attackButton:addAnchor(AnchorRight, 'parent', AnchorRight)
      card.attackButton:setMarginRight(10)
      card.attackButton:setMarginBottom(5)
      card.attackButton:setWidth(84)
    else
      card.viewButton:breakAnchors()
      card.viewButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
      card.viewButton:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
      card.viewButton:setMarginBottom(5)
      card.viewButton:setWidth(60)

      card.attackButton:breakAnchors()
      card.attackButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
      card.attackButton:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
      card.attackButton:setMarginBottom(5)
      card.attackButton:setWidth(74)
    end

    card.placeButton.onClick = function()
      sendPacket("prismPlace", { configId = entry.id })
    end

    card.collectButton.onClick = function()
      clearMsgBox()
      msgBox = displayGeneralBox(
        tr("Prism"),
        tr("Are you sure you want to collect the %s prism?", entry.name or tr("Prism")),
        {
          { text = tr("No"), callback = function() clearMsgBox() end },
          { text = tr("Yes"), imageColor = "red", callback = function()
            sendPacket("prismCollect", { configId = entry.id })
            clearMsgBox()
          end }
        }
      )
    end

    card.viewButton.onClick = function()
      sendPacket("prismView", { configId = entry.id })
    end

    card.teleportButton.onClick = function()
      sendPacket("prismTeleport", { configId = entry.id })
    end

    card.attackButton.onClick = function()
      sendPacket("prismAttack", { configId = entry.id })
    end
  end
end

local function updatePrismCardCountdowns()
  if not prismPanel then
    return
  end

  local list = prismPanel:recursiveGetChildById("prismList")
  if not list then
    return
  end

  for _, card in ipairs(list:getChildren()) do
    local entry = card.entry
    if entry then
      if not entry.isConfigured then
        card.status:setText(tr("Not configured yet."))
      elseif entry.isEmpty then
        if tonumber(entry.placeCooldownUntil or 0) > os.time() then
          card.status:setText(string.format("Place cooldown: %s", formatRemainingTime((tonumber(entry.placeCooldownUntil) or 0) - os.time())))
        else
          card.status:setText(tr("Available prism location"))
        end
      else
        if entry.attack and entry.attack.status == "preparing" then
          card.status:setText(string.format("Attack in: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.startsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
        elseif entry.attack and entry.attack.status == "active" then
          card.status:setText(string.format("Battle: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.endsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
        elseif tonumber(entry.shieldUntil or 0) > os.time() then
          card.status:setText(string.format("Shielded: %s", formatRemainingTime((tonumber(entry.shieldUntil) or 0) - os.time())))
        else
          local remainingText = "-"
          if tonumber(entry.expiresAt or 0) > 0 then
            remainingText = formatRemainingTime((tonumber(entry.expiresAt) or 0) - os.time())
          end
          card.status:setText(string.format("Radius: %d | Remaining: %s", tonumber(entry.radius) or 0, remainingText))
        end
      end
    end
  end
end

local function showPrismLootWindow(data)
  if prismLootWindow then
    prismLootWindow:destroy()
    prismLootWindow = nil
  end

  prismLootWindow = g_ui.createWidget("GuildPrismLootWindow", rootWidget)
  if not prismLootWindow then
    return
  end

  prismLootWindow:raise()
  prismLootWindow:focus()
  local prismNameLabel = prismLootWindow:recursiveGetChildById("prismName")
  local totalsLabel = prismLootWindow:recursiveGetChildById("totals")
  if prismNameLabel then
    prismNameLabel:setText(data.name or "Prism")
  end
  if totalsLabel then
    totalsLabel:setText(string.format("Gold: %s | Exp: %s", comma_value(tonumber(data.gold or 0) or 0), comma_value(tonumber(data.exp or 0) or 0)))
  end

  local grid = prismLootWindow:recursiveGetChildById("lootGrid")
  if not grid then
    return
  end
  grid:destroyChildren()

  local itemsBySlot = {}
  for _, item in ipairs(data.items or {}) do
    itemsBySlot[tonumber(item.slot) or 0] = item
  end

  local capacity = tonumber(data.capacity or 30) or 30
  for slot = 1, capacity do
    local cell = g_ui.createWidget("GuildStorageSlot", grid)
    if cell.setFocusable then
      cell:setFocusable(false)
    end
    if cell.setCheckable then
      cell:setCheckable(false)
    end
    cell.slotNumber:setText(tostring(slot))
    local item = itemsBySlot[slot]
    if item then
      cell.item:setItemId(tonumber(item.clientId) or 0)
      cell.item:setItemCount(tonumber(item.count) or 0)
      cell.count:setText("")
      local tooltip = item.tooltip
      if not tooltip or tooltip == "" then
        tooltip = string.format("%s\nCount: %d", item.name or ("Item #" .. tostring(item.itemId or 0)), tonumber(item.count) or 1)
      end
      cell:setTooltip(tooltip)
      cell.item:setTooltip(tooltip)
      if item.attributesHex and item.attributesHex ~= "" then
        cell.onHoverChange = function(self, hovered)
          if hovered and modules.game_tooltip and modules.game_tooltip.m_TooltipFunction then
            modules.game_tooltip.m_TooltipFunction.createGuildStorage(self:getPosition(), self.item:getItem(), item.attributesHex, item.count or 1)
          elseif not hovered and modules.game_tooltip and modules.game_tooltip.m_TooltipFunction then
            modules.game_tooltip.m_TooltipFunction.destroy()
          end
        end
      else
        cell.onHoverChange = nil
      end
    else
      cell.item:setItemId(0)
      cell.count:setText("")
      cell:setTooltip("")
      cell.item:setTooltip("")
      cell.onHoverChange = nil
    end
  end
end

local function startPrismCountdown()
  stopPrismCountdown()
  if not prismPanel or not prismPanel:isVisible() then
    return
  end

  prismCountdownEvent = scheduleEvent(function()
    prismCountdownEvent = nil
    if prismPanel and prismPanel:isVisible() then
      updatePrismCardCountdowns()
      startPrismCountdown()
    end
  end, 1000)
end

function onGuildPrismData(data)
  prismData.capacity = 0
  prismData.used = 0
  prismData.locations = {}
  prismData.page = 1
  prismData.lastPage = 1
  prismData.total = 0
  prismData.pageSize = 10

  if type(data) == "table" then
    prismData.capacity = tonumber(data.capacity or 0) or 0
    prismData.used = tonumber(data.used or 0) or 0
    prismData.locations = type(data.locations) == "table" and data.locations or {}
    prismData.page = tonumber(data.page or 1) or 1
    prismData.lastPage = tonumber(data.lastPage or 1) or 1
    prismData.total = tonumber(data.total or 0) or 0
    prismData.pageSize = tonumber(data.pageSize or 10) or 10
  end

  renderPrismCards()
end

function onGuildPrismView(data)
  if type(data) ~= "table" then
    return
  end
  showPrismLootWindow(data)
end

local function updateQuestResetLabels()
  if not questsPanel then
    return
  end

  local dailyResetLabel = questsPanel:recursiveGetChildById("dailyResetLabel")
  local weekendResetLabel = questsPanel:recursiveGetChildById("weekendResetLabel")
  local monthlyResetLabel = questsPanel:recursiveGetChildById("monthlyResetLabel")
  local now = os.time()

  if dailyResetLabel then
    dailyResetLabel:setText(tr("Daily reset: ") .. formatRemainingTime(math.max(0, (tonumber(questsData.dailyEndsAt) or 0) - now)))
  end

  if weekendResetLabel then
    weekendResetLabel:setText(tr("Weekend reset: ") .. formatRemainingTime(math.max(0, (tonumber(questsData.weekendEndsAt) or 0) - now)))
  end

  if monthlyResetLabel then
    monthlyResetLabel:setText(tr("Monthly reset: ") .. formatRemainingTime(math.max(0, (tonumber(questsData.monthlyEndsAt) or 0) - now)))
  end
end

local function startQuestCountdown()
  stopQuestCountdown()
  if not questsPanel or not questsPanel:isVisible() then
    return
  end

  updateQuestResetLabels()
  questCountdownEvent = scheduleEvent(startQuestCountdown, 1000)
end

local function renderQuestCards(container, quests)
  if not container then
    return
  end

  container:destroyChildren()

  for _, quest in ipairs(quests or {}) do
    local card = g_ui.createWidget("GuildQuestCard", container)
    card.title:setText(quest.name or tr("Quest"))
    if card.icon then
      card.icon:setImageSource("/images/guild_hall/" .. tostring((quest.icon and quest.icon ~= "" and quest.icon) or "guild_achievement"))
      if card.icon.setTooltip then
        card.icon:setTooltip(quest.name or tr("Quest"))
      end
    end
    card.objective:setText(quest.objective or "")
    card.progress:setText(string.format("%s %s / %s", tr("Progress:"), comma_value(quest.progress or 0), comma_value(quest.target or 0)))
    renderRewardEntries(card.rewardsContainer, quest.rewardEntries, tr("Rewards: ") .. tostring(quest.rewardText or "-"))

    if quest.claimed then
      card.state:setText(tr("Claimed"))
    elseif quest.completed then
      card.state:setText(tr("Ready to claim"))
    else
      card.state:setText(tr("In progress"))
    end

    card.claimButton:setVisible(not quest.claimed)
    card.claimButton:setEnabled(quest.completed and not quest.claimed)
    card.claimButton.onClick = function()
      sendPacket("questClaim", { questId = quest.id, cycleType = quest.cycleType })
    end
  end

  if container.setHeight then
    container:setHeight(392)
  end
end

local function renderQuestTab()
  if not questsPanel then
    return
  end

  renderQuestCards(questsPanel:recursiveGetChildById("dailyList"), questsData.daily)
  renderQuestCards(questsPanel:recursiveGetChildById("weekendList"), questsData.weekend)
  renderQuestCards(questsPanel:recursiveGetChildById("monthlyList"), questsData.monthly)

  local questsBody = questsPanel:recursiveGetChildById("questsBody")
  if questsBody and questsBody.setHeight then
    local sectionHeight = 414
    questsBody:setHeight((sectionHeight * 3) + 56)
  end

  updateQuestResetLabels()
end

function onGuildQuestData(data)
  questsData = {
    daily = {},
    weekend = {},
    monthly = {},
    dailyEndsAt = 0,
    weekendEndsAt = 0,
    monthlyEndsAt = 0
  }

  if type(data) == "table" then
    questsData.daily = type(data.daily) == "table" and data.daily or {}
    questsData.weekend = type(data.weekend) == "table" and data.weekend or {}
    questsData.monthly = type(data.monthly) == "table" and data.monthly or {}
    questsData.dailyEndsAt = tonumber(data.dailyEndsAt) or 0
    questsData.weekendEndsAt = tonumber(data.weekendEndsAt) or 0
    questsData.monthlyEndsAt = tonumber(data.monthlyEndsAt) or 0
  end

  renderQuestTab()
end

local function fetchAchievementsPage(page)
  achievementsData.page = math.max(1, math.floor(tonumber(page) or 1))
  sendPacket("achievementsFetch", { page = achievementsData.page, search = achievementsData.search or "" })
end

local function renderAchievementTab()
  if not achievementsPanel then
    return
  end

  local summaryLabel = achievementsPanel:recursiveGetChildById("progressSummary")
  local fill = achievementsPanel:recursiveGetChildById("progressBarFill")
  local pageLabel = achievementsPanel:recursiveGetChildById("pageLabel")
  local prevPageButton = achievementsPanel:recursiveGetChildById("prevPageButton")
  local nextPageButton = achievementsPanel:recursiveGetChildById("nextPageButton")
  local grid = achievementsPanel:recursiveGetChildById("achievementsList")

  if summaryLabel then
    summaryLabel:setText(string.format("%s %d / %d", tr("Achievements:"), tonumber(achievementsData.completed or 0) or 0, tonumber(achievementsData.total or 0) or 0))
  end

  if fill then
    local base = fill:getParent()
    local width = base and base:getWidth() or 280
    local total = math.max(1, tonumber(achievementsData.total or 0) or 0)
    local completed = math.max(0, tonumber(achievementsData.completed or 0) or 0)
    fill:setWidth(math.floor(width * math.min(1, completed / total)))
  end

  if pageLabel then
    pageLabel:setText(string.format("%d / %d", tonumber(achievementsData.page or 1) or 1, tonumber(achievementsData.lastPage or 1) or 1))
  end

  if prevPageButton then
    prevPageButton:setEnabled((tonumber(achievementsData.page or 1) or 1) > 1)
    prevPageButton.onClick = function()
      fetchAchievementsPage((tonumber(achievementsData.page or 1) or 1) - 1)
    end
  end

  if nextPageButton then
    nextPageButton:setEnabled((tonumber(achievementsData.page or 1) or 1) < (tonumber(achievementsData.lastPage or 1) or 1))
    nextPageButton.onClick = function()
      fetchAchievementsPage((tonumber(achievementsData.page or 1) or 1) + 1)
    end
  end

  if not grid then
    return
  end

  grid:destroyChildren()

  for _, achievement in ipairs(achievementsData.achievements or {}) do
    local card = g_ui.createWidget("GuildAchievementCard", grid)
    card.title:setText(achievement.name or tr("Achievement"))
    card.objective:setText(achievement.objective or "")
    card.progress:setText(string.format("%s %s / %s", tr("Progress:"), comma_value(achievement.progress or 0), comma_value(achievement.target or 0)))
    renderRewardEntries(card.rewardsContainer, achievement.rewardEntries, tr("Rewards: ") .. tostring(achievement.rewardText or "-"))

    if achievement.claimed then
      card.state:setText(tr("Claimed"))
      if card.state.setColor then
        card.state:setColor("#7CFF7A")
      end
    elseif achievement.completed then
      card.state:setText(tr("Completed"))
      if card.state.setColor then
        card.state:setColor("#7CFF7A")
      end
    else
      card.state:setText(tr("In progress"))
      if card.state.setColor then
        card.state:setColor("#b9b2a8")
      end
    end

    if card.icon then
      card.icon:setOpacity(achievement.completed and 1 or 0.45)
      if card.icon.setTooltip then
        card.icon:setTooltip(achievement.name or "")
      end
    end

    card.claimButton:setVisible(not achievement.claimed)
    card.claimButton:setEnabled(achievement.completed and not achievement.claimed)
    card.claimButton.onClick = function()
      sendPacket("achievementClaim", { achievementId = achievement.id })
    end
  end

  local entryCount = #(achievementsData.achievements or {})
  local rows = math.max(1, math.ceil(entryCount / 3))
  if grid.setHeight then
      grid:setHeight(math.max(492, (rows * 492) - 12))
  end
end

function onGuildAchievementData(data)
  achievementsData = {
    achievements = {},
    page = 1,
    lastPage = 1,
    pageSize = 18,
    total = 0,
    totalFiltered = 0,
    completed = 0,
    search = achievementsData.search or ""
  }

  if type(data) == "table" then
    achievementsData.achievements = type(data.achievements) == "table" and data.achievements or {}
    achievementsData.page = tonumber(data.page or 1) or 1
    achievementsData.lastPage = tonumber(data.lastPage or 1) or 1
    achievementsData.pageSize = tonumber(data.pageSize or 18) or 18
    achievementsData.total = tonumber(data.total or 0) or 0
    achievementsData.totalFiltered = tonumber(data.totalFiltered or 0) or 0
    achievementsData.completed = tonumber(data.completed or 0) or 0
    achievementsData.search = tostring(data.search or achievementsData.search or "")
  end

  renderAchievementTab()
end

local function showPrismTab()
  if not prismPanel or not window then
    return
  end

  stopQuestCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()

  if generalPanel then generalPanel:hide() end
  if membersPanel then membersPanel:hide() end
  if ranksPanel then ranksPanel:hide() end
  if perksPanel then perksPanel:hide() end
  if storagePanel then storagePanel:hide() end
  if questsPanel then questsPanel:hide() end
  if achievementsPanel then achievementsPanel:hide() end
  if blackMarketPanel then blackMarketPanel:hide() end
  if dynastiePanel then dynastiePanel:hide() end
  if inboxPanel then inboxPanel:hide() end
  if topGuildsPanel then topGuildsPanel:hide() end
  clearMainGuildTabSelection()
  clearSecondaryGuildTabSelection()
  if window and window.tabBar then
    window.tabBar.currentTab = nil
  end

  prismPanel:show()
  prismPanel:raise()
  fitTabPanel(prismPanel)
  window.inboxFilterBtn:hide()
  setGuildFooterVisible(true)
  setStorageTabActive(false)
  setPrismTabActive(true)
  setQuestsTabActive(false)
  setAchievementsTabActive(false)
  setBlackMarketTabActive(false)
  setDynastieTabActive(false)
  sendPacket("dynastieViewState", { active = false })
  sendPacket("prismViewState", { active = true })
  renderPrismCards()
  startPrismCountdown()
  sendPacket("prismFetch", { page = tonumber(prismData.page or 1) or 1 })
end

local function showQuestsTab()
  if not questsPanel or not window then
    return
  end

  stopPrismCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()

  if generalPanel then generalPanel:hide() end
  if membersPanel then membersPanel:hide() end
  if ranksPanel then ranksPanel:hide() end
  if perksPanel then perksPanel:hide() end
  if storagePanel then storagePanel:hide() end
  if prismPanel then prismPanel:hide() end
  if achievementsPanel then achievementsPanel:hide() end
  if blackMarketPanel then blackMarketPanel:hide() end
  if dynastiePanel then dynastiePanel:hide() end
  if inboxPanel then inboxPanel:hide() end
  if topGuildsPanel then topGuildsPanel:hide() end
  clearMainGuildTabSelection()
  clearSecondaryGuildTabSelection()
  if window and window.tabBar then
    window.tabBar.currentTab = nil
  end

  questsPanel:show()
  questsPanel:raise()
  fitTabPanel(questsPanel)
  window.inboxFilterBtn:hide()
  setGuildFooterVisible(true)
  setStorageTabActive(false)
  setPrismTabActive(false)
  setQuestsTabActive(true)
  setAchievementsTabActive(false)
  setBlackMarketTabActive(false)
  setDynastieTabActive(false)
  renderQuestTab()
  startQuestCountdown()
  sendPacket("questsFetch")
end

local function showAchievementsTab()
  if not achievementsPanel or not window then
    return
  end

  stopPrismCountdown()
  stopQuestCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()

  if generalPanel then generalPanel:hide() end
  if membersPanel then membersPanel:hide() end
  if ranksPanel then ranksPanel:hide() end
  if perksPanel then perksPanel:hide() end
  if storagePanel then storagePanel:hide() end
  if prismPanel then prismPanel:hide() end
  if questsPanel then questsPanel:hide() end
  if blackMarketPanel then blackMarketPanel:hide() end
  if dynastiePanel then dynastiePanel:hide() end
  if inboxPanel then inboxPanel:hide() end
  if topGuildsPanel then topGuildsPanel:hide() end
  clearMainGuildTabSelection()
  clearSecondaryGuildTabSelection()
  if window and window.tabBar then
    window.tabBar.currentTab = nil
  end

  achievementsPanel:show()
  achievementsPanel:raise()
  fitTabPanel(achievementsPanel)
  window.inboxFilterBtn:hide()
  setGuildFooterVisible(true)
  setStorageTabActive(false)
  setPrismTabActive(false)
  setQuestsTabActive(false)
  setAchievementsTabActive(true)
  setBlackMarketTabActive(false)
  setDynastieTabActive(false)
  renderAchievementTab()
  fetchAchievementsPage(tonumber(achievementsData.page or 1) or 1)
end

local function updateBlackMarketTimers()
  if not blackMarketPanel then
    stopBlackMarketCountdown()
    return
  end

  local now = os.time()
  local refreshLabel = blackMarketPanel:recursiveGetChildById("refreshLabel")
  if refreshLabel then
    local remainingRefresh = math.max(0, (tonumber(blackMarketData.refreshAt) or 0) - now)
    refreshLabel:setText(tr("Next rotation: ") .. formatRemainingTime(remainingRefresh))
    if remainingRefresh <= 0 and not blackMarketData.fetching then
      blackMarketData.fetching = true
      sendPacket("blackMarketFetch")
    end
  end

  local list = blackMarketPanel:recursiveGetChildById("marketList")
  if list then
    for _, card in ipairs(list:getChildren()) do
      local offer = card.offerData
      if offer then
        local remaining = math.max(0, (tonumber(offer.expiresAt) or 0) - now)
        if remaining > 0 then
          card.timer:setText(tr("Rotates in: ") .. formatRemainingTime(remaining))
        else
          card.timer:setText(tr("Rotating..."))
          if not blackMarketData.fetching then
            blackMarketData.fetching = true
            sendPacket("blackMarketFetch")
          end
        end
        local canBuy = remaining > 0 and (offer.affordable ~= false) and not offer.purchased
        applyBlackMarketButtonState(card.buyButton, canBuy, offer.purchased)
      end
    end
  end

  blackMarketCountdownEvent = scheduleEvent(updateBlackMarketTimers, 1000)
end

local function renderBlackMarket()
  if not blackMarketPanel then
    return
  end

  local list = blackMarketPanel:recursiveGetChildById("marketList")
  if not list then
    return
  end

  list:destroyChildren()
  local now = os.time()

  for _, offer in ipairs(blackMarketData.offers or {}) do
    local card = g_ui.createWidget("GuildBlackMarketCard", list)
    card.offerData = offer
    card.title:setText(offer.name or "")
    card.item:setItemId(tonumber(offer.clientId) or 0)
    card.item:setItemCount(tonumber(offer.count) or 1)
    card.item:setTooltip(offer.description or offer.name or "")
    card.quantity:setText(string.format("%dx", tonumber(offer.count) or 1))
    card.price:setText(tonumber(offer.gold or 0) > 0 and (comma_value(tonumber(offer.gold) or 0) .. " gold") or (comma_value(tonumber(offer.premium) or 0) .. " premium points"))

    local remaining = math.max(0, (tonumber(offer.expiresAt) or 0) - now)
    local durationLabel = tonumber(offer.durationLabel or offer.duration) or 0
    if remaining > 0 then
      card.timer:setText(tr("Duration: ") .. formatRemainingTime(durationLabel) .. "\n" .. tr("Rotates in: ") .. formatRemainingTime(remaining))
    else
      card.timer:setText(tr("Rotating..."))
    end
    local canBuy = remaining > 0 and (offer.affordable ~= false) and not offer.purchased
    applyBlackMarketButtonState(card.buyButton, canBuy, offer.purchased)
    card.buyButton.onClick = function()
      if canBuy then
        sendPacket("blackMarketPurchase", { offerId = offer.id, offerInstanceId = offer.instanceId })
      end
    end
  end

  updateBlackMarketTimers()
end

local function onGuildBlackMarketData(data)
  stopBlackMarketCountdown()
  blackMarketData.fetching = false
  if not data then
    blackMarketData = { refreshAt = 0, offers = {}, fetching = false }
    if blackMarketPanel then
      local list = blackMarketPanel:recursiveGetChildById("marketList")
      if list then
        list:destroyChildren()
      end
    end
    return
  end

  blackMarketData.refreshAt = tonumber(data.refreshAt) or 0
  blackMarketData.offers = type(data.offers) == "table" and data.offers or {}
  renderBlackMarket()
end

local function showBlackMarketTab()
  if not blackMarketPanelBtn or not blackMarketPanel or not window then
    return
  end

  stopPrismCountdown()
  stopQuestCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()

  generalPanel:hide()
  membersPanel:hide()
  ranksPanel:hide()
  perksPanel:hide()
  inboxPanel:hide()
  topGuildsPanel:hide()
  if storagePanel then storagePanel:hide() end
  if prismPanel then prismPanel:hide() end
  if questsPanel then questsPanel:hide() end
  if achievementsPanel then achievementsPanel:hide() end
  if dynastiePanel then dynastiePanel:hide() end
  clearMainGuildTabSelection()
  clearSecondaryGuildTabSelection()
  if window and window.tabBar then
    window.tabBar.currentTab = nil
  end
  setStorageTabActive(false)
  setPrismTabActive(false)
  setQuestsTabActive(false)
  setAchievementsTabActive(false)
  setBlackMarketTabActive(true)
  setDynastieTabActive(false)
  blackMarketPanel:show()
  window.inboxFilterBtn:hide()
  setGuildFooterVisible(true)
  blackMarketData.fetching = true
  sendPacket("blackMarketFetch")
end

local function renderDynastieCards()
  if not dynastiePanel then
    return
  end

  local list = dynastiePanel:recursiveGetChildById("dynastieList")
  local capacityLabel = dynastiePanel:recursiveGetChildById("capacityLabel")
  local pageLabel = dynastiePanel:recursiveGetChildById("pageLabel")
  local prevPageButton = dynastiePanel:recursiveGetChildById("prevPageButton")
  local nextPageButton = dynastiePanel:recursiveGetChildById("nextPageButton")
  local managePanelButton = dynastiePanel:recursiveGetChildById("managePanelButton")
  local dynastieScroll = dynastiePanel:recursiveGetChildById("dynastieScroll")
  if not list then
    return
  end

  local previousScrollValue = nil
  if dynastieScroll and dynastieScroll.getValue then
    previousScrollValue = dynastieScroll:getValue()
  end

  if capacityLabel then
    capacityLabel:setText(string.format("Dynasty: %d / %d", tonumber(dynastieData.used or 0) or 0, tonumber(dynastieData.total or 0) or 0))
  end

  if pageLabel then
    pageLabel:setText(string.format("%d / %d", tonumber(dynastieData.page or 1) or 1, tonumber(dynastieData.lastPage or 1) or 1))
  end
  if prevPageButton then
    prevPageButton:setEnabled((tonumber(dynastieData.page or 1) or 1) > 1)
    prevPageButton.onClick = function()
      local currentPage = tonumber(dynastieData.page or 1) or 1
      if currentPage > 1 then
        sendPacket("dynastieFetch", { page = currentPage - 1 })
      end
    end
  end
  if nextPageButton then
    nextPageButton:setEnabled((tonumber(dynastieData.page or 1) or 1) < (tonumber(dynastieData.lastPage or 1) or 1))
    nextPageButton.onClick = function()
      local currentPage = tonumber(dynastieData.page or 1) or 1
      local lastPage = tonumber(dynastieData.lastPage or 1) or 1
      if currentPage < lastPage then
        sendPacket("dynastieFetch", { page = currentPage + 1 })
      end
    end
  end
  if managePanelButton then
    managePanelButton:setVisible(myGuild ~= nil)
    managePanelButton.onClick = function()
      local ownedEntries = {}
      for _, locationEntry in ipairs(dynastieData.locations or {}) do
        if locationEntry.ownedByViewer then
          table.insert(ownedEntries, locationEntry)
        end
      end
      if #ownedEntries <= 0 then
        ownedEntries = dynastieData.ownedLocations or {}
      end
      if #ownedEntries > 0 then
        openDynastieManageWindow(ownedEntries[1], ownedEntries, 1)
      else
        openDynastieManageWindow(buildEmptyDynastieManageEntry(), {}, 1)
      end
    end
  end

  list:destroyChildren()
  local now = os.time()
  for _, entry in ipairs(dynastieData.locations or {}) do
    local card = g_ui.createWidget("GuildDynastieCard", list)
    card.entry = entry
    card.location:setText(entry.name or "Dynasty")
    card.owner:setText(entry.owned and ("Owned by " .. (entry.ownerGuildName or "Unknown Guild")) or "Empty")
    card.placer:setText(entry.owned and ("Placed by " .. (entry.ownerPlayerName or "Unknown")) or (entry.city or "City"))
    card.dynastieItem:setItemId(tonumber(entry.clientId or entry.placedItemId or entry.baseItemId) or 0)
    card.dynastieItem:setItemCount(1)
    if card.dynastieItem.setOpacity then
      card.dynastieItem:setOpacity(entry.owned and 1.0 or 0.45)
    end

    if entry.ownedByViewer then
      if entry.attack and entry.attack.status == "preparing" then
        card.status:setText(string.format("Attack in: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.startsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
      elseif entry.attack and entry.attack.status == "active" then
        card.status:setText(string.format("Battle: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.endsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
      elseif tonumber(entry.shieldUntil or 0) > now then
        card.status:setText(string.format("Shielded: %s", formatRemainingTime((tonumber(entry.shieldUntil) or 0) - now)))
      else
      local collectAt = tonumber(entry.collectAvailableAt or 0) or 0
      local remaining = math.max(0, collectAt - now)
      if remaining > 0 then
        card.status:setText(string.format("Collect in: %s", formatRemainingTime(remaining)))
      else
        card.status:setText("Ready to collect")
      end
      end
    else
      if entry.attack and entry.attack.status == "preparing" then
        card.status:setText(string.format("Attack in: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.startsAt) or 0) - now), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
      elseif entry.attack and entry.attack.status == "active" then
        card.status:setText(string.format("Battle: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.endsAt) or 0) - now), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
      elseif tonumber(entry.shieldUntil or 0) > now then
        card.status:setText(string.format("Shielded: %s", formatRemainingTime((tonumber(entry.shieldUntil) or 0) - now)))
      elseif tonumber(entry.attackCooldownUntil or 0) > now then
        card.status:setText(string.format("Attack cooldown: %s", formatRemainingTime((tonumber(entry.attackCooldownUntil) or 0) - now)))
      elseif tonumber(entry.placeCooldownUntil or 0) > now then
        card.status:setText(string.format("Place cooldown: %s", formatRemainingTime((tonumber(entry.placeCooldownUntil) or 0) - now)))
      else
        card.status:setText(entry.isConfigured and "Available city dynastie" or "Location not configured")
      end
    end

    card.tax:setText(string.format("Tax: %d%%", tonumber(entry.taxRate or 0) or 0))
    card.stored:setText(string.format("Stored Gold: %s | Tokens: %s", comma_value(tonumber(entry.gold or 0) or 0), comma_value(tonumber(entry.tokens or 0) or 0)))

    local canPlace = entry.canPlace == true
    local canManageDynastie = entry.viewerCanManage == true
    local teleportVisible = entry.ownedByViewer == true or entry.canAttack == true or entry.canTeleportAttack == true
    local teleportEnabled = entry.ownedByViewer == true or entry.canTeleportAttack == true

    card.placeButton:setVisible(canPlace)
    card.panelButton:setVisible(entry.canOpenPanel == true)
    card.teleportButton:setVisible(teleportVisible)
    card.teleportButton:setEnabled(teleportEnabled)
    card.attackButton:setVisible(entry.canAttack == true and canManageDynastie)

    card.placeButton.onClick = function()
      sendPacket("dynastiePlace", { configId = entry.id })
    end
    card.panelButton.onClick = function()
      local selectedIndex = 1
      local ownedEntries = {}
      for _, locationEntry in ipairs(dynastieData.locations or {}) do
        if locationEntry.ownedByViewer then
          table.insert(ownedEntries, locationEntry)
        end
      end
      if #ownedEntries <= 0 then
        ownedEntries = dynastieData.ownedLocations or {}
      end
      for index, ownedEntry in ipairs(ownedEntries) do
        if ownedEntry.id == entry.id then
          selectedIndex = index
          break
        end
      end
      openDynastieManageWindow(entry, ownedEntries, selectedIndex)
    end
    card.teleportButton.onClick = function()
      if not teleportEnabled then
        return
      end
      sendPacket("dynastieTeleport", { configId = entry.id })
    end
    card.attackButton.onClick = function()
      sendPacket("dynastieAttack", { configId = entry.id })
    end
  end

  if dynastieScroll and dynastieScroll.setValue and previousScrollValue ~= nil then
    dynastieScroll:setValue(previousScrollValue)
  end
end

local function updateDynastieCountdowns()
  if not dynastiePanel then
    stopDynastieCountdown()
    return
  end

  local list = dynastiePanel:recursiveGetChildById("dynastieList")
  local now = os.time()
  if list then
    for _, card in ipairs(list:getChildren()) do
      local entry = card.entry
      if entry then
        if entry.ownedByViewer then
          if entry.attack and entry.attack.status == "preparing" then
            card.status:setText(string.format("Attack in: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.startsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
          elseif entry.attack and entry.attack.status == "active" then
            card.status:setText(string.format("Battle: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.endsAt) or 0) - os.time()), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
          elseif tonumber(entry.shieldUntil or 0) > now then
            card.status:setText(string.format("Shielded: %s", formatRemainingTime((tonumber(entry.shieldUntil) or 0) - now)))
          else
            local collectAt = tonumber(entry.collectAvailableAt or 0) or 0
            local remaining = math.max(0, collectAt - now)
            if remaining > 0 then
              card.status:setText(string.format("Collect in: %s", formatRemainingTime(remaining)))
            else
              card.status:setText("Ready to collect")
            end
          end
        else
          if entry.attack and entry.attack.status == "preparing" then
            card.status:setText(string.format("Attack in: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.startsAt) or 0) - now), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
          elseif entry.attack and entry.attack.status == "active" then
            card.status:setText(string.format("Battle: %s\nA:%d D:%d", formatRemainingTime((tonumber(entry.attack.endsAt) or 0) - now), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0))
          elseif tonumber(entry.shieldUntil or 0) > now then
            card.status:setText(string.format("Shielded: %s", formatRemainingTime((tonumber(entry.shieldUntil) or 0) - now)))
          elseif tonumber(entry.attackCooldownUntil or 0) > now then
            card.status:setText(string.format("Attack cooldown: %s", formatRemainingTime((tonumber(entry.attackCooldownUntil) or 0) - now)))
          elseif tonumber(entry.placeCooldownUntil or 0) > now then
            card.status:setText(string.format("Place cooldown: %s", formatRemainingTime((tonumber(entry.placeCooldownUntil) or 0) - now)))
          else
            card.status:setText(entry.isConfigured and "Available city dynastie" or "Location not configured")
          end
        end
      end
    end
  end

  if dynastieManageWindow and dynastieManageEntry then
    refreshDynastieManageWindow()
  end

  dynastieCountdownEvent = scheduleEvent(updateDynastieCountdowns, 1000)
end

local function onGuildDynastieData(data)
  stopDynastieCountdown()
  local previousManageEntry = dynastieManageEntry
  local previousSnapshot = type(dynastieManageQuestData) == "table" and type(dynastieManageQuestData.entrySnapshot) == "table" and dynastieManageQuestData.entrySnapshot or nil
  local pendingTaxConfigId = tostring(dynastieManageQuestData and dynastieManageQuestData.pendingTaxConfigId or "")
  dynastieData = {
    used = tonumber(data and data.used or 0) or 0,
    total = tonumber(data and data.total or 0) or 0,
    locations = type(data and data.locations) == "table" and data.locations or {},
    ownedLocations = type(data and data.ownedLocations) == "table" and data.ownedLocations or {},
    perks = dynastieData and dynastieData.perks or {},
    defenders = dynastieData and dynastieData.defenders or {},
    achievements = dynastieData and dynastieData.achievements or {},
    page = tonumber(data and data.page or 1) or 1,
    lastPage = tonumber(data and data.lastPage or 1) or 1,
    totalLocations = tonumber(data and data.totalLocations or 0) or 0,
    pageSize = tonumber(data and data.pageSize or 6) or 6
  }
  if dynastieManageEntry then
    local preserveTaxOnly = false
    local preserveOwnedSelection = false
    local matchingIncomingEntry = nil
    local matchingLocationEntry = nil
    if previousManageEntry and previousManageEntry.id ~= "" and #(dynastieData.ownedLocations or {}) > 0 then
      for _, ownedEntry in ipairs(dynastieData.ownedLocations or {}) do
        if tostring(ownedEntry.id or "") == tostring(previousManageEntry.id or "") then
          matchingIncomingEntry = ownedEntry
          break
        end
      end
    end
    if previousManageEntry and previousManageEntry.id ~= "" and #(dynastieData.locations or {}) > 0 then
      for _, locationEntry in ipairs(dynastieData.locations or {}) do
        if tostring(locationEntry.id or "") == tostring(previousManageEntry.id or "") then
          matchingLocationEntry = locationEntry
          break
        end
      end
    end
    if not preserveTaxOnly and previousManageEntry and tostring(previousManageEntry.id or "") ~= "" then
      local snapshotOwnsEntry = previousSnapshot
        and tostring(previousSnapshot.id or "") == tostring(previousManageEntry.id or "")
        and previousSnapshot.ownedByViewer == true
      local previouslyOwnedEntry = previousManageEntry.ownedByViewer == true or snapshotOwnsEntry
      if previouslyOwnedEntry then
        local mergedOwnedEntry = {}
        if snapshotOwnsEntry then
          for key, value in pairs(previousSnapshot) do
            mergedOwnedEntry[key] = value
          end
        end
        for key, value in pairs(previousManageEntry) do
          mergedOwnedEntry[key] = value
        end
        if type(matchingLocationEntry) == "table" then
          for key, value in pairs(matchingLocationEntry) do
            mergedOwnedEntry[key] = value
          end
        end
        if type(matchingIncomingEntry) == "table" then
          for key, value in pairs(matchingIncomingEntry) do
            mergedOwnedEntry[key] = value
          end
        end

        mergedOwnedEntry.id = tostring(mergedOwnedEntry.id or previousManageEntry.id or "")
        mergedOwnedEntry.ownedByViewer = true
        mergedOwnedEntry.ownedByGuild = true
        mergedOwnedEntry.owned = true
        if (tonumber(mergedOwnedEntry.clientId) or 0) <= 0 then
          mergedOwnedEntry.clientId = tonumber(previousManageEntry.clientId or previousSnapshot and previousSnapshot.clientId or 0) or 0
        end
        if (tonumber(mergedOwnedEntry.placedItemId) or 0) <= 0 then
          mergedOwnedEntry.placedItemId = tonumber(previousManageEntry.placedItemId or previousSnapshot and previousSnapshot.placedItemId or 0) or 0
        end
        if (tonumber(mergedOwnedEntry.baseItemId) or 0) <= 0 then
          mergedOwnedEntry.baseItemId = tonumber(previousManageEntry.baseItemId or previousSnapshot and previousSnapshot.baseItemId or 0) or 0
        end
        if (tonumber(mergedOwnedEntry.level) or 0) <= 0 then
          mergedOwnedEntry.level = tonumber(previousManageEntry.level or previousSnapshot and previousSnapshot.level or 1) or 1
        end
        if (tonumber(mergedOwnedEntry.levelCap) or 0) <= 0 then
          mergedOwnedEntry.levelCap = tonumber(previousManageEntry.levelCap or previousSnapshot and previousSnapshot.levelCap or 10) or 10
        end
        if (tonumber(mergedOwnedEntry.nextLevelExp) or 0) <= 0 then
          mergedOwnedEntry.nextLevelExp = tonumber(previousManageEntry.nextLevelExp or previousSnapshot and previousSnapshot.nextLevelExp or 1) or 1
        end
        if mergedOwnedEntry.ownerGuildName == nil or mergedOwnedEntry.ownerGuildName == "" then
          mergedOwnedEntry.ownerGuildName = previousManageEntry.ownerGuildName or previousSnapshot and previousSnapshot.ownerGuildName or ""
        end
        if mergedOwnedEntry.ownerPlayerName == nil or mergedOwnedEntry.ownerPlayerName == "" then
          mergedOwnedEntry.ownerPlayerName = previousManageEntry.ownerPlayerName or previousSnapshot and previousSnapshot.ownerPlayerName or ""
        end

        dynastieManageEntry = mergedOwnedEntry
        dynastieManageEntries = { mergedOwnedEntry }
        dynastieManageIndex = 1
        dynastieManageQuestData.configId = tostring(mergedOwnedEntry.id or "")
        preserveOwnedSelection = true
      end
    end
    if pendingTaxConfigId ~= "" and previousManageEntry and tostring(previousManageEntry.id or "") == pendingTaxConfigId then
      preserveTaxOnly = true
      if matchingIncomingEntry then
        previousManageEntry.taxRate = tonumber(matchingIncomingEntry.taxRate or previousManageEntry.taxRate or 0) or 0
        previousManageEntry.maxTaxRate = tonumber(matchingIncomingEntry.maxTaxRate or previousManageEntry.maxTaxRate or 0) or 0
        previousManageEntry.canSetTax = matchingIncomingEntry.canSetTax
        for index, ownedEntry in ipairs(dynastieData.ownedLocations or {}) do
          if tostring(ownedEntry.id or "") == pendingTaxConfigId then
            dynastieManageEntries = dynastieData.ownedLocations
            dynastieManageIndex = math.max(1, math.min(#dynastieManageEntries, index))
            dynastieManageEntries[index] = previousManageEntry
            break
          end
        end
      end
      dynastieManageEntry = previousManageEntry
      dynastieManageQuestData.configId = tostring(previousManageEntry.id or "")
      if type(dynastieManageQuestData.entrySnapshot) == "table" and tostring(dynastieManageQuestData.entrySnapshot.id or "") == pendingTaxConfigId then
        dynastieManageQuestData.entrySnapshot = previousManageEntry
      end
      dynastieManageQuestData.pendingTaxConfigId = ""
    end
    if preserveTaxOnly then
      local taxLabel = dynastieManageWindow and dynastieManageWindow:recursiveGetChildById("tax")
      local taxButton = dynastieManageWindow and dynastieManageWindow:recursiveGetChildById("taxButton")
      if taxLabel then
        taxLabel:setText(string.format("Tax: %d%%", tonumber(dynastieManageEntry.taxRate or 0) or 0))
      end
      if taxButton then
        local cooldownActive = (g_clock and g_clock.millis and g_clock.millis() or 0) < (dynastieTaxCooldownUntil or 0)
        local canSetTax = (dynastieManageEntry.attack == nil) and (dynastieManageEntry.ownedByViewer == true or canManageCurrentDynastieEntry(dynastieManageEntry))
        taxButton:setText(cooldownActive and tr("Wait a moment...") or string.format("Tax %d%%", tonumber(dynastieManageEntry.taxRate or 0) or 0))
        taxButton:setEnabled(canSetTax and not cooldownActive)
        if canSetTax and not cooldownActive and taxButton.enable then
          taxButton:enable()
        elseif taxButton.disable then
          taxButton:disable()
        end
        taxButton:setOpacity((canSetTax and not cooldownActive) and 1.0 or 0.55)
      end
    elseif preserveOwnedSelection then
      dynastieManageQuestData.configId = tostring(dynastieManageEntry and dynastieManageEntry.id or "")
    elseif #(dynastieData.ownedLocations or {}) > 0 then
      dynastieManageEntry, dynastieManageEntries, dynastieManageIndex = resolveDynastieManageSelection(dynastieData.ownedLocations, dynastieManageEntry, dynastieManageIndex)
      dynastieManageQuestData.configId = tostring(dynastieManageEntry and dynastieManageEntry.id or "")
    elseif matchingLocationEntry then
      dynastieManageEntry = matchingLocationEntry
      dynastieManageQuestData.configId = tostring(dynastieManageEntry.id or "")
    elseif dynastieManageEntry.id ~= "" then
      dynastieManageEntry = previousManageEntry
      dynastieManageQuestData.configId = tostring(dynastieManageEntry.id or "")
    else
      dynastieManageEntry, dynastieManageEntries, dynastieManageIndex = resolveDynastieManageSelection({}, nil, 1)
      dynastieManageQuestData.configId = ""
    end
    if not preserveTaxOnly then
      refreshDynastieManageWindow()
    end
    if dynastieManageCurrentTab == "defenders" and not preserveTaxOnly then
      renderDynastieDefendersTab()
    elseif dynastieManageCurrentTab == "perks" and not preserveTaxOnly then
      renderDynastiePerksTab()
    elseif dynastieManageCurrentTab == "quests" and not preserveTaxOnly then
      renderDynastieManageQuestTab()
    elseif dynastieManageCurrentTab == "achievements" and not preserveTaxOnly then
      renderDynastieAchievementsTab()
    end
  end
  renderDynastieCards()
  updateDynastieCountdowns()
end

local function onGuildDynastiePanelData(data)
  if type(data) ~= "table" then
    dynastieData.perks = {}
    dynastieData.defenders = {}
  else
    dynastieData.perks = type(data.perks) == "table" and data.perks or {}
    dynastieData.defenders = type(data.defenders) == "table" and data.defenders or {}
    if type(data.passiveTree) == "table" then
      dynastiePassiveTreePreview = {
        defenders = type(data.passiveTree.defenders) == "table" and data.passiveTree.defenders or {},
        selectedDefenderId = data.passiveTree.selectedDefenderId or "paladin",
        selectedNodeId = data.passiveTree.selectedNodeId
      }
    end
  end

  if dynastieManageCurrentTab == "perks" then
    renderDynastiePerksTab()
  elseif dynastieManageCurrentTab == "defenders" then
    renderDynastieDefendersTab()
  elseif dynastieManageCurrentTab == "passivetree" then
    renderDynastiePassiveTreeTab()
  end
end

local function setDynastieTabOwnedMessage(viewId, text)
  if not dynastieManageWindow then
    return
  end

  local view = dynastieManageWindow:recursiveGetChildById(viewId)
  if not view then
    return
  end

  local label = view:recursiveGetChildById("dynastieOwnedRequiredLabel")
  if not label then
    label = g_ui.createWidget("Label", view)
    label:setId("dynastieOwnedRequiredLabel")
    label:setWidth(920)
    label:setHeight(48)
    label:setTextWrap(true)
    label:setTextAlign(AlignCenter)
    label:setColor("#c7c1b6")
    if label.centerIn then
      label:centerIn(view)
    end
  end

  label:setText(text or tr("You do not own a Dynastie Core yet."))
  label:show()
end

local function clearDynastieTabOwnedMessage(viewId)
  if not dynastieManageWindow then
    return
  end

  local view = dynastieManageWindow:recursiveGetChildById(viewId)
  if not view then
    return
  end

  local label = view:recursiveGetChildById("dynastieOwnedRequiredLabel")
  if label then
    label:hide()
  end
end

renderDynastieAchievementsTab = function()
  if not dynastieManageWindow then
    return
  end

  local summaryLabel = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsSummary")
  local pageLabel = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsPageLabel")
  local prevButton = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsPrevButton")
  local nextButton = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsNextButton")
  local searchInput = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsSearchInput")
  local fill = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsProgressBarFill")
  local list = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsList")
  local scroll = dynastieManageWindow:recursiveGetChildById("dynastieAchievementsScroll")

  if not hasOwnedDynastieSelection() then
    if summaryLabel then
      summaryLabel:setText(tr("You do not own a Dynastie Core yet."))
    end
    if list then
      list:destroyChildren()
    end
    if scroll then
      scroll:setVisible(false)
    end
    setDynastieTabOwnedMessage("achievementsView")
    return
  end

  clearDynastieTabOwnedMessage("achievementsView")
  if scroll then
    scroll:setVisible(true)
  end

  if summaryLabel then
    summaryLabel:setText(string.format("%s %d / %d", tr("Achievements:"), tonumber(dynastieAchievementData.completed or 0) or 0, tonumber(dynastieAchievementData.total or 0) or 0))
  end

  if pageLabel then
    pageLabel:setText(string.format("%d / %d", tonumber(dynastieAchievementData.page or 1) or 1, tonumber(dynastieAchievementData.lastPage or 1) or 1))
  end

  if prevButton then
    prevButton:setEnabled((tonumber(dynastieAchievementData.page or 1) or 1) > 1)
    prevButton.onClick = function()
      requestDynastieAchievementsPage((tonumber(dynastieAchievementData.page or 1) or 1) - 1)
    end
  end

  if nextButton then
    nextButton:setEnabled((tonumber(dynastieAchievementData.page or 1) or 1) < (tonumber(dynastieAchievementData.lastPage or 1) or 1))
    nextButton.onClick = function()
      requestDynastieAchievementsPage((tonumber(dynastieAchievementData.page or 1) or 1) + 1)
    end
  end

  if searchInput then
    if searchInput:getText() ~= tostring(dynastieAchievementData.search or "") then
      searchInput:setText(tostring(dynastieAchievementData.search or ""))
    end
    searchInput.onTextChange = function(widget, text)
      dynastieAchievementData.search = tostring(text or widget:getText() or "")
      requestDynastieAchievementsPage(1)
    end
  end

  if fill then
    local base = fill:getParent()
    local width = base and base:getWidth() or 280
    local total = math.max(1, tonumber(dynastieAchievementData.total or 0) or 0)
    local completed = math.max(0, tonumber(dynastieAchievementData.completed or 0) or 0)
    fill:setWidth(math.floor(width * math.min(1, completed / total)))
  end

  if not list then
    return
  end

  list:destroyChildren()
  for _, achievement in ipairs(dynastieAchievementData.achievements or {}) do
    local card = g_ui.createWidget("DynastieAchievementCard", list)
    card.title:setText(achievement.name or tr("Dynastie Achievement"))
    card.objective:setText(achievement.objective or "")
    card.progress:setText(string.format("%s %s / %s", tr("Progress:"), comma_value(achievement.progress or 0), comma_value(achievement.target or 0)))
    renderRewardEntries(card.rewardsContainer, achievement.rewardEntries, tr("Rewards: ") .. tostring(achievement.rewardText or "-"))

    if achievement.claimed then
      card.state:setText(tr("Claimed"))
      if card.state.setColor then
        card.state:setColor("#7CFF7A")
      end
    elseif achievement.completed then
      card.state:setText(tr("Ready to claim"))
      if card.state.setColor then
        card.state:setColor("#7CFF7A")
      end
    else
      card.state:setText(tr("In progress"))
      if card.state.setColor then
        card.state:setColor("#b9b2a8")
      end
    end

    if card.icon then
      card.icon:setOpacity(achievement.completed and 1 or 0.45)
      if card.icon.setTooltip then
        card.icon:setTooltip(achievement.name or "")
      end
    end

    card.claimButton:setVisible(not achievement.claimed)
    card.claimButton:setEnabled(achievement.completed and not achievement.claimed and canManageCurrentDynastieEntry())
    card.claimButton.onClick = function()
      if not canManageCurrentDynastieEntry() then
        return
      end
      sendPacket("dynastieAchievementClaim", { achievementId = achievement.id })
    end
  end

  local rows = math.max(1, math.ceil(#(dynastieAchievementData.achievements or {}) / 3))
  if list.setHeight then
      list:setHeight((rows * 432) + math.max(0, rows - 1) * 8 + 12)
  end
end

local function onGuildDynastieAchievementsData(data)
  dynastieAchievementData = {
    achievements = {},
    page = 1,
    lastPage = 1,
    pageSize = 18,
    completed = 0,
    total = 0,
    search = dynastieAchievementData.search or ""
  }

  if type(data) == "table" then
    dynastieAchievementData.achievements = type(data.achievements) == "table" and data.achievements or {}
    dynastieAchievementData.page = tonumber(data.page or 1) or 1
    dynastieAchievementData.lastPage = tonumber(data.lastPage or 1) or 1
    dynastieAchievementData.pageSize = tonumber(data.pageSize or 18) or 18
    dynastieAchievementData.completed = tonumber(data.completed or 0) or 0
    dynastieAchievementData.total = tonumber(data.total or 0) or 0
    dynastieAchievementData.search = tostring(data.search or dynastieAchievementData.search or "")
  end

  if dynastieManageCurrentTab == "achievements" then
    renderDynastieAchievementsTab()
  end
end

local function requestDynastieEventsMonth(monthOffset)
  monthOffset = math.floor(tonumber(monthOffset) or 0)
  dynastieEventCalendarData.monthOffset = monthOffset
  sendPacket("dynastieEventsFetch", {
    configId = dynastieManageEntry and dynastieManageEntry.id or "",
    monthOffset = monthOffset
  })
end

local function renderDynastieEventsTab()
  if not dynastieManageWindow then
    return
  end

  local weekdayNames = dynastieEventCalendarData.weekdays or {}
  if #weekdayNames == 0 then
    weekdayNames = {
      tr("Monday"),
      tr("Tuesday"),
      tr("Wednesday"),
      tr("Thursday"),
      tr("Friday"),
      tr("Saturday"),
      tr("Sunday")
    }
  end

  local monthLabel = dynastieManageWindow:recursiveGetChildById("dynastieEventsMonthLabel")
  local dateLabel = dynastieManageWindow:recursiveGetChildById("dynastieEventsDateLabel")
  local summaryLabel = dynastieManageWindow:recursiveGetChildById("dynastieEventsSummary")
  local weekdayHeader = dynastieManageWindow:recursiveGetChildById("dynastieEventsWeekdayHeader")
  local monthList = dynastieManageWindow:recursiveGetChildById("dynastieEventsMonthList")
  local bodyPanel = dynastieManageWindow:recursiveGetChildById("dynastieEventsBody")
  local prevMonthButton = dynastieManageWindow:recursiveGetChildById("dynastieEventsPrevMonthButton")
  local nextMonthButton = dynastieManageWindow:recursiveGetChildById("dynastieEventsNextMonthButton")
  local scroll = dynastieManageWindow:recursiveGetChildById("dynastieEventsScroll")
  local todayYear = tonumber(os.date("%Y")) or 0
  local todayMonth = tonumber(os.date("%m")) or 0
  local todayDay = tonumber(os.date("%d")) or 0

  if not hasOwnedDynastieSelection() then
    if monthLabel then monthLabel:setText(tr("Dynastie Schedule")) end
    if dateLabel then dateLabel:setText(tr("You do not own a Dynastie Core yet.")) end
    if summaryLabel then summaryLabel:setText(tr("You do not own a Dynastie Core yet.")) end
    if weekdayHeader then weekdayHeader:destroyChildren() end
    if monthList then monthList:destroyChildren() end
    if scroll then scroll:setVisible(false) end
    setDynastieTabOwnedMessage("eventsView")
    return
  end

  clearDynastieTabOwnedMessage("eventsView")
  if scroll then scroll:setVisible(true) end

  if monthLabel then
    monthLabel:setText(dynastieEventCalendarData.currentMonthLabel ~= "" and dynastieEventCalendarData.currentMonthLabel or tr("Dynastie Schedule"))
  end

  if dateLabel then
    dateLabel:setText(dynastieEventCalendarData.currentDateLabel ~= "" and dynastieEventCalendarData.currentDateLabel or tr("No event date loaded"))
  end

  if summaryLabel then
    summaryLabel:setText(dynastieEventCalendarData.summary ~= "" and dynastieEventCalendarData.summary or tr("This calendar tracks rotating dynastie city events for the full current month."))
  end

  if prevMonthButton then
    prevMonthButton.onClick = function()
      requestDynastieEventsMonth((tonumber(dynastieEventCalendarData.monthOffset or 0) or 0) - 1)
    end
  end

  if nextMonthButton then
    nextMonthButton.onClick = function()
      requestDynastieEventsMonth((tonumber(dynastieEventCalendarData.monthOffset or 0) or 0) + 1)
    end
  end

  if weekdayHeader then
    weekdayHeader:destroyChildren()
    for _, weekdayName in ipairs(weekdayNames) do
      local label = g_ui.createWidget("Label", weekdayHeader)
      label:setText(weekdayName)
      label:setHeight(22)
      label:setWidth(134)
      label:setColor("#dfdfdf")
    end
  end

  if not monthList then
    return
  end

  monthList:destroyChildren()
  for _, day in ipairs(dynastieEventCalendarData.days or {}) do
    local card = g_ui.createWidget("DynastieCalendarDayCard", monthList)
    local displayYear = tonumber(day.y or dynastieEventCalendarData.currentYear or 0) or 0
    local displayMonth = tonumber(day.m or dynastieEventCalendarData.currentMonth or 0) or 0
    local displayDay = tonumber(day.d or 0) or 0
    local weekdayIndex = tonumber(day.w or 0) or 0
    local cityLabel = tostring((dynastieEventCalendarData.cities or {})[tonumber(day.c or 0) or 0] or tr("No city event"))
    local eventInfo = (dynastieEventCalendarData.events or {})[tonumber(day.e or 0) or 0] or {}
    local weekdayLabel = tostring(weekdayNames[weekdayIndex] or "")
    local eventName = tostring(day.n or eventInfo.n or tr("No event"))
    local eventDescription = tostring(day.x or eventInfo.x or tr("No scheduled dynastie event yet."))
    local timeLabelText = tostring(day.t or "")
    if timeLabelText == "" then
      timeLabelText = tostring(eventInfo.t or "")
    end
    local fullDateLabel = ""
    if displayYear > 0 and displayMonth > 0 and displayDay > 0 then
      local ts = os.time({
        year = displayYear,
        month = displayMonth,
        day = displayDay,
        hour = 12
      })
      if ts then
        fullDateLabel = os.date("%d %b %Y", ts)
      end
    end

    local tooltipLines = {
      weekdayLabel,
      fullDateLabel,
      cityLabel,
      "",
      eventName,
      timeLabelText,
      "",
      eventDescription
    }
    if eventInfo.s == "guild" then
      table.insert(tooltipLines, 4, tr("Scope: Guild-wide"))
    else
      table.insert(tooltipLines, 4, tr("Scope: City"))
    end
    local compactEventName = eventName
    if #compactEventName > 28 then
      compactEventName = compactEventName:sub(1, 25) .. "..."
    end
    local compactTimeLabel = timeLabelText
    if #compactTimeLabel > 22 then
      compactTimeLabel = compactTimeLabel:sub(1, 19) .. "..."
    end

    if card.weekday then card.weekday:setText(weekdayLabel) end
    if card.dayNumber then card.dayNumber:setText(tostring(displayDay)) end
    if card.city then card.city:setText(cityLabel) end
    if card.eventName then card.eventName:setText(compactEventName) end
    if card.time then card.time:setText(compactTimeLabel) end
    if card.description then card.description:setText("") end
    if card.setTooltip then
      card:setTooltip(table.concat(tooltipLines, "\n"))
    end

    local isCurrentMonth = tonumber(day.i or 0) == 1
    local isPastCurrentMonthDay = isCurrentMonth
      and displayYear == todayYear
      and displayMonth == todayMonth
      and displayDay < todayDay
    local isToday = isCurrentMonth
      and displayYear == todayYear
      and displayMonth == todayMonth
      and displayDay == todayDay
    local isDimmed = (not isCurrentMonth) or isPastCurrentMonthDay

    card:setOpacity(isDimmed and 0.55 or 1.0)
    card:setBackgroundColor(isToday and "#5a4a2f" or "#4a443d")
    card:setBorderColor(isToday and "#FFDC96" or "#5a5248")
    card:setBorderWidth(isToday and 2 or 1)
    if card.weekday then
      card.weekday:setColor(isToday and "#FFDC96" or "#dfdfdf")
    end
    if card.dayNumber then
      card.dayNumber:setColor(isToday and "#FFF1B8" or "#dfdfdf")
    end
    if card.city then
      card.city:setColor(isDimmed and "#b9b2a8" or (isToday and "#FFF1B8" or "#FFDC96"))
    end
    if card.eventName then
      card.eventName:setColor(isDimmed and "#b9b2a8" or (isToday and "#fff6dd" or "#dfdfdf"))
    end
    if card.time then
      card.time:setColor(isDimmed and "#8f8a84" or (isToday and "#e7d7ab" or "#b9b2a8"))
    end
  end

  local visibleCellCount = math.max(1, #(dynastieEventCalendarData.days or {}))
  local rowCount = math.max(1, math.ceil(visibleCellCount / 7))
  local monthListHeight = rowCount * 132
  if monthList.setHeight then
    monthList:setHeight(monthListHeight)
  end
  if bodyPanel and bodyPanel.setHeight then
    bodyPanel:setHeight(42 + 10 + 22 + 10 + monthListHeight + 24)
  end
end

local function onGuildDynastieEventsData(data)
  dynastieEventCalendarData = {
    monthOffset = dynastieEventCalendarData.monthOffset or 0,
    currentYear = 0,
    currentMonth = 0,
    currentDateLabel = "",
    currentMonthLabel = "",
    summary = "",
    weekdays = {},
    cities = {},
    events = {},
    days = {}
  }

  if type(data) == "table" then
    dynastieEventCalendarData.monthOffset = math.floor(tonumber(data.monthOffset or dynastieEventCalendarData.monthOffset or 0) or 0)
    dynastieEventCalendarData.currentYear = tonumber(data.currentYear or 0) or 0
    dynastieEventCalendarData.currentMonth = tonumber(data.currentMonth or 0) or 0
    dynastieEventCalendarData.currentDateLabel = tostring(data.currentDateLabel or "")
    dynastieEventCalendarData.currentMonthLabel = tostring(data.currentMonthLabel or "")
    dynastieEventCalendarData.summary = tostring(data.summary or "")
    dynastieEventCalendarData.weekdays = type(data.weekdays) == "table" and data.weekdays or {}
    dynastieEventCalendarData.cities = type(data.cities) == "table" and data.cities or {}
    dynastieEventCalendarData.events = type(data.events) == "table" and data.events or {}
    dynastieEventCalendarData.days = type(data.days) == "table" and data.days or {}
  end

  if dynastieManageCurrentTab == "events" then
    renderDynastieEventsTab()
  end
end

local function renderDynastieBoardOffersWindow()
  if not dynastieBoardWindow then
    dynastieBoardWindow = g_ui.createWidget("GuildDynastieBoardWindow", rootWidget)
  end
  if not dynastieBoardWindow then
    return
  end

  local title = dynastieBoardWindow:recursiveGetChildById("boardEventTitle")
  local info = dynastieBoardWindow:recursiveGetChildById("boardAcceptedInfo")
  local repeatInfo = dynastieBoardWindow:recursiveGetChildById("boardRepeatInfo")
  local list = dynastieBoardWindow:recursiveGetChildById("boardOffersList")
  local closeButton = dynastieBoardWindow:recursiveGetChildById("closeButton")
  if closeButton then
    closeButton.onClick = function()
      if dynastieBoardWindow then
        dynastieBoardWindow:destroy()
        dynastieBoardWindow = nil
      end
    end
  end
  local acceptedQuestIds = {}
  for _, acceptedQuest in ipairs(dynastieBoardAcceptedData.quests or {}) do
    acceptedQuestIds[tostring(acceptedQuest.id or "")] = true
  end
  if title then
    title:setText(dynastieBoardOffersData.eventName ~= "" and dynastieBoardOffersData.eventName or tr("Dynastie Event Board"))
  end
  if info then
    info:setText(string.format("%s %d / %d | %s %s",
      tr("Accepted:"),
      tonumber(dynastieBoardOffersData.acceptedCount or 0) or 0,
      tonumber(dynastieBoardOffersData.maxAccepted or 3) or 3,
      tr("Time left:"),
      formatRemainingTime((tonumber(dynastieBoardOffersData.expiresAt or 0) or 0) - os.time())))
  end
  if repeatInfo then
    repeatInfo:setText(string.format("%s %d", tr("Each board quest can be completed up to"), tonumber(dynastieBoardOffersData.repeatLimit or 3) or 3) .. tr(" times during the current board rotation."))
  end
  if list then
    list:destroyChildren()
    for _, quest in ipairs(dynastieBoardOffersData.quests or {}) do
      local card = g_ui.createWidget("DynastieBoardOfferCard", list)
      local questId = tostring(quest.id or "")
      local alreadyAccepted = acceptedQuestIds[questId] == true
      local repeatLimit = tonumber(quest.repeatLimit or dynastieBoardOffersData.repeatLimit or 3) or 3
      local repeatCount = tonumber(quest.repeatCount or 0) or 0
      local repeatReached = repeatCount >= repeatLimit
      local limitReached = (tonumber(dynastieBoardOffersData.acceptedCount or 0) or 0) >= (tonumber(dynastieBoardOffersData.maxAccepted or 3) or 3)
      card.title:setText(quest.name or tr("Board Quest"))
      card.objective:setText(quest.objective or string.format("%s %s", tr("Target:"), comma_value(quest.target or 0)))
      renderRewardEntries(card.rewardsContainer, quest.rewardEntries, tr("Rewards: ") .. tostring(quest.rewardText or "-"))
      if card.ownerRewardsContainer then
        renderRewardEntries(card.ownerRewardsContainer, quest.ownerRewardEntries, tr("Core rewards: ") .. tostring(quest.ownerRewardText or "-"))
      end
      if card.repeatInfo then
        card.repeatInfo:setText(string.format("%s %d / %d", tr("Completed this rotation:"), repeatCount, repeatLimit))
      end
      if card.icon then
        card.icon:setImageSource("/images/guild_hall/" .. tostring((quest.icon and quest.icon ~= "" and quest.icon) or "dynasty_achievement"))
      end
      card.acceptButton:setEnabled((not alreadyAccepted) and (not limitReached) and (not repeatReached))
      card.acceptButton:setText(alreadyAccepted and tr("Accepted") or (repeatReached and tr("Maxed") or tr("Accept")))
      card.acceptButton:setOpacity(((not alreadyAccepted) and (not limitReached) and (not repeatReached)) and 1.0 or 0.65)
      card.acceptButton.onClick = function()
        if alreadyAccepted or limitReached or repeatReached then
          return
        end
        sendPacket("dynastieBoardQuestAccept", { configId = dynastieBoardOffersData.configId, questId = quest.id })
        dynastieBoardOffersData.acceptedCount = math.min((tonumber(dynastieBoardOffersData.maxAccepted or 3) or 3), (tonumber(dynastieBoardOffersData.acceptedCount or 0) or 0) + 1)
        acceptedQuestIds[questId] = true
        if dynastieBoardAcceptedData and dynastieBoardAcceptedData.quests then
          dynastieBoardAcceptedData.quests[#dynastieBoardAcceptedData.quests + 1] = {
            id = quest.id,
            name = quest.name,
            icon = quest.icon,
            objective = quest.objective,
            target = quest.target,
            progress = 0,
            rewardText = quest.rewardText,
            rewardEntries = quest.rewardEntries,
            expiresAt = dynastieBoardOffersData.expiresAt
          }
        end
        card.acceptButton:setEnabled(false)
        card.acceptButton:setText(tr("Accepted"))
        card.acceptButton:setOpacity(0.65)
        if modules and modules.game_textmessage and modules.game_textmessage.displayGameMessage then
          modules.game_textmessage.displayGameMessage(tr("You accepted the quest: %s", tostring(quest.name or tr("Board Quest"))))
        end
        sendPacket("dynastieBoardAcceptedFetch", {})
        renderDynastieBoardAcceptedTab()
        renderDynastieBoardOffersWindow()
      end
    end
    if list.setHeight then
      local rows = math.max(1, math.ceil(#(dynastieBoardOffersData.quests or {}) / 3))
      list:setHeight(rows * 425 + 8)
    end
  end
  dynastieBoardWindow:show()
  dynastieBoardWindow:raise()
  dynastieBoardWindow:focus()
end

renderDynastieBoardAcceptedTab = function()
  if not dynastieManageWindow then
    return
  end
  local summary = dynastieManageWindow:recursiveGetChildById("dynastieBoardQuestsSummary")
  local emptyLabel = dynastieManageWindow:recursiveGetChildById("dynastieBoardQuestsEmptyLabel")
  local scroll = dynastieManageWindow:recursiveGetChildById("dynastieBoardQuestsScroll")
  local list = dynastieManageWindow:recursiveGetChildById("dynastieBoardQuestsList")
  if not hasOwnedDynastieSelection() then
    if summary then
      summary:setText(tr("You do not own a Dynastie Core yet."))
    end
    if emptyLabel then
      emptyLabel:setVisible(false)
    end
    if scroll then
      scroll:setVisible(false)
    end
    if list then
      list:destroyChildren()
    end
    setDynastieTabOwnedMessage("boardQuestsView")
    return
  end
  clearDynastieTabOwnedMessage("boardQuestsView")
  local hasQuests = #(dynastieBoardAcceptedData.quests or {}) > 0
  if summary then
    summary:setText(string.format("%s %d", tr("Accepted board quests:"), #(dynastieBoardAcceptedData.quests or {})))
  end
  if emptyLabel then
    emptyLabel:setVisible(not hasQuests)
  end
  if scroll then
    scroll:setVisible(hasQuests)
  end
  if not list then
    return
  end
  list:destroyChildren()
  for _, quest in ipairs(dynastieBoardAcceptedData.quests or {}) do
    local card = g_ui.createWidget("DynastieBoardQuestCard", list)
    card.title:setText(quest.name or tr("Board Quest"))
    card.progress:setText(string.format("%s %s / %s", tr("Progress:"), comma_value(quest.progress or 0), comma_value(quest.target or 0)))
    renderRewardEntries(card.rewardsContainer, quest.rewardEntries, tr("Rewards: ") .. tostring(quest.rewardText or "-"))
    if card.ownerRewardsContainer then
      renderRewardEntries(card.ownerRewardsContainer, quest.ownerRewardEntries, tr("Core rewards: ") .. tostring(quest.ownerRewardText or "-"))
    end
    card.timer:setText(string.format("%s %s", tr("Time left:"), formatRemainingTime((tonumber(quest.expiresAt or 0) or 0) - os.time())))
    if card.icon then
      card.icon:setImageSource("/images/guild_hall/" .. tostring((quest.icon and quest.icon ~= "" and quest.icon) or "dynasty_achievement"))
    end
  end
  if list.setHeight then
    local rows = math.max(1, math.ceil(#(dynastieBoardAcceptedData.quests or {}) / 3))
      list:setHeight(rows * 350)
  end
end

local function onGuildDynastieBoardOffersData(data)
  dynastieBoardOffersData = {
    configId = "",
    eventName = "",
    expiresAt = 0,
    maxAccepted = 3,
    repeatLimit = 3,
    acceptedCount = 0,
    quests = {}
  }
  if type(data) == "table" then
    dynastieBoardOffersData.configId = tostring(data.configId or "")
    dynastieBoardOffersData.eventName = tostring(data.eventName or "")
    dynastieBoardOffersData.expiresAt = tonumber(data.expiresAt or 0) or 0
    dynastieBoardOffersData.maxAccepted = tonumber(data.maxAccepted or 3) or 3
    dynastieBoardOffersData.repeatLimit = tonumber(data.repeatLimit or 3) or 3
    dynastieBoardOffersData.acceptedCount = tonumber(data.acceptedCount or 0) or 0
    dynastieBoardOffersData.quests = type(data.quests) == "table" and data.quests or {}
  end
  renderDynastieBoardOffersWindow()
end

local function onGuildDynastieBoardAcceptedData(data)
  dynastieBoardAcceptedData = {
    quests = {}
  }
  if type(data) == "table" then
    dynastieBoardAcceptedData.quests = type(data.quests) == "table" and data.quests or {}
  end
  if dynastieManageCurrentTab == "boardquests" then
    renderDynastieBoardAcceptedTab()
  end
  if dynastieBoardWindow and dynastieBoardWindow:isVisible() then
    dynastieBoardOffersData.acceptedCount = #(dynastieBoardAcceptedData.quests or {})
    renderDynastieBoardOffersWindow()
  end
end

local function showDynastieTab()
  if not dynastiePanelBtn or not dynastiePanel or not window then
    return
  end

  stopPrismCountdown()
  stopQuestCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()

  if generalPanel then generalPanel:hide() end
  if membersPanel then membersPanel:hide() end
  if ranksPanel then ranksPanel:hide() end
  if perksPanel then perksPanel:hide() end
  if storagePanel then storagePanel:hide() end
  if prismPanel then prismPanel:hide() end
  if questsPanel then questsPanel:hide() end
  if achievementsPanel then achievementsPanel:hide() end
  if blackMarketPanel then blackMarketPanel:hide() end
  if inboxPanel then inboxPanel:hide() end
  if topGuildsPanel then topGuildsPanel:hide() end
  clearMainGuildTabSelection()
  clearSecondaryGuildTabSelection()
  if window and window.tabBar then
    window.tabBar.currentTab = nil
  end
  setStorageTabActive(false)
  setPrismTabActive(false)
  setQuestsTabActive(false)
  setAchievementsTabActive(false)
  setBlackMarketTabActive(false)
  setDynastieTabActive(true)
  sendPacket("prismViewState", { active = false })
  sendPacket("dynastieViewState", { active = true })
  dynastiePanel:show()
  window.inboxFilterBtn:hide()
  setGuildFooterVisible(true)
  sendPacket("dynastieFetch", { page = tonumber(dynastieData.page or 1) or 1 })
end

local function updateDynastieManageQuestResetLabels()
  if not dynastieManageWindow then
    return
  end

  local now = os.time()
  local dailyResetLabel = dynastieManageWindow:recursiveGetChildById("dynastieDailyResetLabel")
  local weekendResetLabel = dynastieManageWindow:recursiveGetChildById("dynastieWeekendResetLabel")
  local monthlyResetLabel = dynastieManageWindow:recursiveGetChildById("dynastieMonthlyResetLabel")
  if dailyResetLabel then
    dailyResetLabel:setText(tr("Daily reset: ") .. formatRemainingTime(math.max(0, (tonumber(dynastieManageQuestData.dailyEndsAt) or 0) - now)))
  end
  if weekendResetLabel then
    weekendResetLabel:setText(tr("Weekend reset: ") .. formatRemainingTime(math.max(0, (tonumber(dynastieManageQuestData.weekendEndsAt) or 0) - now)))
  end
  if monthlyResetLabel then
    monthlyResetLabel:setText(tr("Monthly reset: ") .. formatRemainingTime(math.max(0, (tonumber(dynastieManageQuestData.monthlyEndsAt) or 0) - now)))
  end
end

local function startDynastieManageQuestCountdown()
  stopDynastieManageQuestCountdown()
  if not dynastieManageWindow or dynastieManageCurrentTab ~= "quests" then
    return
  end

  updateDynastieManageQuestResetLabels()
  dynastieManageQuestData.countdownEvent = scheduleEvent(startDynastieManageQuestCountdown, 1000)
end

local function renderDynastieManageQuestCards(container, quests)
  if not container then
    return
  end

  container:destroyChildren()
  local canManageDynastie = canManageCurrentDynastieEntry()
  if not dynastieManageEntry or not dynastieManageEntry.ownedByViewer or dynastieManageEntry.id == "" then
    local emptyLabel = g_ui.createWidget("Label", container)
    emptyLabel:setWidth(container:getWidth() > 0 and container:getWidth() or 820)
    emptyLabel:setHeight(40)
    emptyLabel:setText(tr("You do not own a Dynastie Core yet."))
    emptyLabel:setTextWrap(true)
    emptyLabel:setTextAlign(AlignCenter)
    emptyLabel:setColor("#c7c1b6")
    return
  end

  for _, quest in ipairs(quests or {}) do
    local card = g_ui.createWidget("DynastieQuestCard", container)
    card.title:setText(quest.name or tr("Dynastie Quest"))
    if card.icon then
      card.icon:setImageSource("/images/guild_hall/" .. tostring((quest.icon and quest.icon ~= "" and quest.icon) or "dynasty_achievement"))
      if card.icon.setTooltip then
        card.icon:setTooltip(quest.name or tr("Dynastie Quest"))
      end
    end
    card.objective:setText(quest.objective or "")
    card.progress:setText(string.format("%s %s / %s", tr("Progress:"), comma_value(quest.progress or 0), comma_value(quest.target or 0)))
    renderRewardEntries(card.rewardsContainer, quest.rewardEntries, tr("Rewards: ") .. tostring(quest.rewardText or "-"))
    if quest.claimed then
      card.state:setText(tr("Claimed"))
    elseif quest.completed then
      card.state:setText(tr("Ready to claim"))
    else
      card.state:setText(tr("In progress"))
    end
    card.claimButton:setVisible(canManageDynastie and not quest.claimed)
    card.claimButton:setEnabled(canManageDynastie and quest.completed and not quest.claimed)
    card.claimButton.onClick = function()
      if dynastieManageEntry and canManageCurrentDynastieEntry() then
        sendPacket("dynastieQuestClaim", { configId = dynastieManageEntry.id, questId = quest.id, cycleType = quest.cycleType })
        local currentConfigId = dynastieManageEntry.id
        local currentPage = dynastieData and tonumber(dynastieData.page or 1) or 1
        scheduleEvent(function()
          sendPacket("dynastieFetch", { page = currentPage })
          sendPacket("dynastieQuestsFetch", { configId = currentConfigId })
        end, 150)
      end
    end
  end

  if container.setHeight then
    local childCount = #container:getChildren()
    local rows = math.max(1, math.ceil(childCount / 3))
      container:setHeight(rows * 396)
  end
end

local function renderDynastieManageQuestTab()
  if not dynastieManageWindow then
    return
  end

  local emptyLabel = dynastieManageWindow:recursiveGetChildById("dynastieQuestEmptyLabel")
  if emptyLabel then
    emptyLabel:setVisible(not hasOwnedDynastieSelection())
  end
  renderDynastieManageQuestCards(dynastieManageWindow:recursiveGetChildById("dynastieDailyList"), dynastieManageQuestData.daily)
  renderDynastieManageQuestCards(dynastieManageWindow:recursiveGetChildById("dynastieWeekendList"), dynastieManageQuestData.weekend)
  renderDynastieManageQuestCards(dynastieManageWindow:recursiveGetChildById("dynastieMonthlyList"), dynastieManageQuestData.monthly)

  local questsBody = dynastieManageWindow:recursiveGetChildById("dynastieQuestsBody")
  if questsBody and questsBody.setHeight then
    local dailyList = dynastieManageWindow:recursiveGetChildById("dynastieDailyList")
    local weekendList = dynastieManageWindow:recursiveGetChildById("dynastieWeekendList")
    local monthlyList = dynastieManageWindow:recursiveGetChildById("dynastieMonthlyList")
    local totalHeight = 56
    totalHeight = totalHeight + (dailyList and dailyList:getHeight() or 338)
    totalHeight = totalHeight + (weekendList and weekendList:getHeight() or 338)
    totalHeight = totalHeight + (monthlyList and monthlyList:getHeight() or 338)
    questsBody:setHeight(totalHeight)
  end

  updateDynastieManageQuestResetLabels()
end

renderDynastieDefendersTab = function()
  if not dynastieManageWindow then
    return
  end

  local list = dynastieManageWindow:recursiveGetChildById("defendersList")
  local scroll = dynastieManageWindow:recursiveGetChildById("defendersScroll")
  if not list then
    return
  end

  list:destroyChildren()
  if not hasOwnedDynastieSelection() then
    if scroll then
      scroll:setVisible(false)
    end
    setDynastieTabOwnedMessage("defendersView")
    return
  end
  clearDynastieTabOwnedMessage("defendersView")
  if scroll then
    scroll:setVisible(true)
  end
  local canManageDynastie = canManageCurrentDynastieEntry()
  for _, defender in ipairs(dynastieData.defenders or {}) do
    local card = g_ui.createWidget("DynastieDefenderCard", list)
    if card then
      local creature = card:recursiveGetChildById("creature")
      if creature then
        creature:setOutfit({})
        creature:setOutfit({
          type = tonumber(defender.lookType) or 0,
          auxType = tonumber(defender.lookTypeEx) or 0,
          head = tonumber(defender.lookHead) or 0,
          body = tonumber(defender.lookBody) or 0,
          legs = tonumber(defender.lookLegs) or 0,
          feet = tonumber(defender.lookFeet) or 0,
          addons = tonumber(defender.lookAddons) or 0,
          mount = 0
        })
        creature:setAnimate(true)
      end

      local name = card:recursiveGetChildById("name")
      if name then
        name:setText(tostring(defender.name or "Dynasty Defender"))
      end

      local role = card:recursiveGetChildById("role")
      if role then
        role:setText(tostring(defender.role or "Defender"))
      end

      local quantity = card:recursiveGetChildById("quantity")
      if quantity then
        quantity:setText(string.format(
          "Defenders: %d / %d",
          tonumber(defender.unlockedCount) or 0,
          tonumber(defender.maxUnlockedCount) or 0
        ))
      end

      local level = card:recursiveGetChildById("level")
      if level then
        level:setText(string.format("Defender Level: %d / %d", tonumber(defender.level) or 0, tonumber(defender.levelCap) or 20))
      end

      local health = card:recursiveGetChildById("health")
      if health then
        health:setText(string.format("HP: %s", comma_value(tonumber(defender.maxHealth) or 0)))
      end

      local distance = card:recursiveGetChildById("distance")
      if distance then
        distance:setText(string.format("Target Distance: %d", tonumber(defender.targetDistance) or 1))
      end

      local speed = card:recursiveGetChildById("speed")
      if speed then
        speed:setText(string.format("Speed: %s", comma_value(tonumber(defender.speed) or 0)))
      end

      local mitigation = card:recursiveGetChildById("mitigation")
      if mitigation then
        mitigation:setText(string.format("Defense / Armor: %d / %d", tonumber(defender.defense) or 0, tonumber(defender.armor) or 0))
      end

      local damage = card:recursiveGetChildById("damage")
      if damage then
        damage:setText(string.format("Damage: %s - %s", comma_value(tonumber(defender.damageMin) or 0), comma_value(tonumber(defender.damageMax) or 0)))
      end

      local attacks = card:recursiveGetChildById("attacks")
      if attacks then
        attacks:setText(tostring(defender.attackSummary or ""))
      end

      local costs = card:recursiveGetChildById("costs")
      if costs then
        local upgradeCost = defender.upgradeCost or {}
        if defender.isUnlocked == false then
          costs:setText("Unlock this defender in the Perks tab.")
        elseif (tonumber(defender.level) or 0) >= (tonumber(defender.levelCap) or 20) then
          costs:setText(tr("Maximum level reached"))
        else
          costs:setText(tostring(upgradeCost.text or string.format(
            "Next: %s gold, %s tokens, %dx %s",
            comma_value(tonumber(upgradeCost.gold) or 0),
            comma_value(tonumber(upgradeCost.dynastieTokens) or 0),
            tonumber(upgradeCost.itemCount) or 0,
            tostring(upgradeCost.itemName or "material")
          )))
        end
      end

      local upgradeButton = card:recursiveGetChildById("upgradeButton")
      if upgradeButton then
        local canUpgrade = defender.canUpgrade == true
        if defender.isUnlocked == false then
          upgradeButton:setText(tr("Locked"))
          upgradeButton:setEnabled(false)
        elseif (tonumber(defender.level) or 0) >= (tonumber(defender.levelCap) or 20) then
          upgradeButton:setText(tr("Max Level"))
          upgradeButton:setEnabled(false)
        else
          upgradeButton:setText(tr("Upgrade"))
          upgradeButton:setEnabled(canUpgrade)
        end
        upgradeButton.onClick = function()
          if not canUpgrade then
            return
          end
          sendPacket("dynastieDefenderUpgrade", { defenderId = defender.id })
          scheduleEvent(function()
            sendPacket("dynastiePanelFetch", {})
          end, 150)
        end
      end
    end
  end

  if list.setHeight then
    local rows = math.max(1, math.ceil(#(dynastieData.defenders or {}) / 3))
    list:setHeight(rows * 420)
  end
end

renderDynastiePerksTab = function()
  if not dynastieManageWindow then
    return
  end

  local list = dynastieManageWindow:recursiveGetChildById("perksList")
  local upgradeButton = dynastieManageWindow:recursiveGetChildById("perksUpgradeButton")
  local dynastiePerksLevelValue = dynastieManageWindow:recursiveGetChildById("dynastiePerksLevelValue")
  if not list then
    return
  end

  if not hasOwnedDynastieSelection() then
    if dynastiePerksLevelValue then
      dynastiePerksLevelValue:setText("Lv 0")
    end
    list:destroyChildren()
    if upgradeButton then
      upgradeButton:setEnabled(false)
      if upgradeButton.disable then upgradeButton:disable() end
    end
    setDynastieTabOwnedMessage("perksView")
    return
  end

  clearDynastieTabOwnedMessage("perksView")

  if dynastiePerksLevelValue and dynastieManageEntry then
    dynastiePerksLevelValue:setText(string.format("Lv %d", tonumber(dynastieManageEntry.level) or 1))
  end

  list:destroyChildren()
  local selectedCard = nil
  for _, perk in ipairs(dynastieData.perks or {}) do
    local card = g_ui.createWidget("DynastieGuildPerkItem", list)
    if card then
      local name = card:recursiveGetChildById("name")
      if name then
        name:setText(tostring(perk.name or "Dynasty Perk"))
      end

      local level = card:recursiveGetChildById("level")
      if level then
        level:setText(string.format("Lv. %d - (%d/%d)", tonumber(perk.level) or 0, tonumber(perk.unlockedCount) or 0, tonumber(perk.levelCap) or 4))
      end

      local bonus = card:recursiveGetChildById("bonus")
      if bonus then
        bonus:setText(string.format("%s\n\nUnlocked defenders: %d / %d",
          tostring(perk.description or ""):gsub(" dynastie%.", " dynastie.\n"),
          tonumber(perk.unlockedCount) or 0,
          tonumber(perk.levelCap) or 4))
      end

      local costs = card:recursiveGetChildById("costs")
      local costLabel = card:recursiveGetChildById("costLabel")
      local costValue = card:recursiveGetChildById("costValue")
      local premiumCostLabel = card:recursiveGetChildById("premiumCostLabel")
      local premiumCostValue = card:recursiveGetChildById("premiumCostValue")
      local requiredLevel = card:recursiveGetChildById("requiredLevel")
      local icon = card:recursiveGetChildById("icon")
      local costLayer = card:recursiveGetChildById("costLayer")
      if icon then
        icon:setImageSource("/images/guild_hall/" .. tostring((perk.icon and perk.icon ~= "" and perk.icon) or "crit_damage"))
      end
      if requiredLevel then
        requiredLevel:setText(string.format("Unlocked: %d / %d", tonumber(perk.unlockedCount) or 0, tonumber(perk.levelCap) or 4))
      end
      if costLabel and costValue then
        local upgradeCost = perk.upgradeCost or {}
        if (tonumber(perk.level) or 0) >= (tonumber(perk.levelCap) or 4) then
          costLabel:setVisible(false)
          costValue:setVisible(false)
          if premiumCostLabel then premiumCostLabel:setVisible(false) end
          if premiumCostValue then premiumCostValue:setVisible(false) end
          if requiredLevel then requiredLevel:setText("Maximum level reached") end
        else
          costLabel:setVisible(true)
          costValue:setVisible(true)
          costLabel:setText("Tokens: ")
          costValue:setText(comma_value(tonumber(upgradeCost.dynastieTokens) or 0))
          if premiumCostLabel and premiumCostValue then
            premiumCostLabel:setVisible(true)
            premiumCostValue:setVisible(true)
            premiumCostLabel:setText("Item: ")
            premiumCostValue:setText(string.format("%dx %s", tonumber(upgradeCost.itemCount) or 0, tostring(upgradeCost.itemName or "Material")))
          end
          if costLayer then
            costLayer:setTooltip(string.format("%s tokens, %dx %s",
              comma_value(tonumber(upgradeCost.dynastieTokens) or 0),
              tonumber(upgradeCost.itemCount) or 0,
              tostring(upgradeCost.itemName or "Material")))
          end
        end
      end
      card.perkId = perk.id
      card.data = perk
      card:setFocusable(true)
      card:setTooltip(string.format("%s\n\n%s\nUnlocked defenders: %d / %d",
        tostring(perk.name or "Dynasty Perk"),
        tostring(perk.description or ""),
        tonumber(perk.unlockedCount) or 0,
        tonumber(perk.levelCap) or 4))
      card.onClick = function(widget)
        dynastieManageSelectedPerkId = widget.perkId
        widget:focus()
        updateDynastiePerksUpgradeButtonState()
      end
      if dynastieManageSelectedPerkId == perk.id then
        selectedCard = card
      end
    end
  end

  if not selectedCard then
    selectedCard = list:getChildByIndex(1)
    if selectedCard then
      dynastieManageSelectedPerkId = selectedCard.perkId
    end
  end
  if selectedCard and selectedCard.focus then
    selectedCard:focus()
  end

  updateDynastiePerksUpgradeButtonState()

  if upgradeButton then
    upgradeButton.onClick = function()
      local perk = nil
      for _, entry in ipairs(dynastieData.perks or {}) do
        if entry.id == dynastieManageSelectedPerkId then
          perk = entry
          break
        end
      end
      if not perk or perk.canUpgrade ~= true then
        return
      end
      sendPacket("dynastiePerkUpgrade", { perkId = perk.id })
      scheduleEvent(function()
        sendPacket("dynastiePanelFetch", {})
      end, 150)
    end
  end
end

function onGuildDynastieQuestsData(data)
  dynastieManageQuestData = {
    configId = "",
    daily = {},
    weekend = {},
    monthly = {},
    dailyEndsAt = 0,
    weekendEndsAt = 0,
    monthlyEndsAt = 0
  }

  if type(data) == "table" then
    dynastieManageQuestData.configId = tostring(data.configId or "")
    dynastieManageQuestData.daily = type(data.daily) == "table" and data.daily or {}
    dynastieManageQuestData.weekend = type(data.weekend) == "table" and data.weekend or {}
    dynastieManageQuestData.monthly = type(data.monthly) == "table" and data.monthly or {}
    dynastieManageQuestData.dailyEndsAt = tonumber(data.dailyEndsAt) or 0
    dynastieManageQuestData.weekendEndsAt = tonumber(data.weekendEndsAt) or 0
    dynastieManageQuestData.monthlyEndsAt = tonumber(data.monthlyEndsAt) or 0
  end

  if dynastieManageCurrentTab == "quests" then
    renderDynastieManageQuestTab()
  end
end

refreshDynastieManageWindow = function()
  if not dynastieManageWindow or not dynastieManageEntry then
    return
  end

  syncCurrentDynastieManageEntryFromData()

  if dynastieManageEntry.id == "" and #dynastieManageEntries > 0 then
    dynastieManageEntry, dynastieManageEntries, dynastieManageIndex = resolveDynastieManageSelection(dynastieManageEntries, nil, dynastieManageIndex)
    dynastieManageQuestData.configId = tostring(dynastieManageEntry.id or "")
  end

  local entry = dynastieManageEntry
  local snapshot = dynastieManageQuestData and dynastieManageQuestData.entrySnapshot or nil
  if type(entry) == "table" and type(snapshot) == "table" and tostring(snapshot.id or "") == tostring(entry.id or "") then
    local displayEntry = {}
    for key, value in pairs(snapshot) do
      displayEntry[key] = value
    end
    for key, value in pairs(entry) do
      displayEntry[key] = value
    end

    if snapshot.ownedByViewer == true then
      if displayEntry.ownedByViewer ~= true then
        displayEntry.ownedByViewer = true
      end
      if displayEntry.ownedByGuild ~= true then
        displayEntry.ownedByGuild = true
      end
      if displayEntry.owned ~= true then
        displayEntry.owned = true
      end
      if (displayEntry.ownerGuildName == nil or displayEntry.ownerGuildName == "") and snapshot.ownerGuildName and snapshot.ownerGuildName ~= "" then
        displayEntry.ownerGuildName = snapshot.ownerGuildName
      end
      if (displayEntry.ownerPlayerName == nil or displayEntry.ownerPlayerName == "") and snapshot.ownerPlayerName and snapshot.ownerPlayerName ~= "" then
        displayEntry.ownerPlayerName = snapshot.ownerPlayerName
      end
      if (tonumber(displayEntry.clientId) or 0) <= 0 then
        displayEntry.clientId = tonumber(snapshot.clientId or snapshot.placedItemId or snapshot.baseItemId) or 0
      end
      if (tonumber(displayEntry.placedItemId) or 0) <= 0 then
        displayEntry.placedItemId = tonumber(snapshot.placedItemId or snapshot.clientId or snapshot.baseItemId) or 0
      end
      if (tonumber(displayEntry.baseItemId) or 0) <= 0 then
        displayEntry.baseItemId = tonumber(snapshot.baseItemId or snapshot.clientId or snapshot.placedItemId) or 0
      end
      if (tonumber(displayEntry.level) or 0) <= 0 then
        displayEntry.level = tonumber(snapshot.level or 1) or 1
      end
      if (tonumber(displayEntry.levelCap) or 0) <= 0 then
        displayEntry.levelCap = tonumber(snapshot.levelCap or 10) or 10
      end
      if (tonumber(displayEntry.nextLevelExp) or 0) <= 0 then
        displayEntry.nextLevelExp = tonumber(snapshot.nextLevelExp or 1) or 1
      end
      if displayEntry.experience == nil and snapshot.experience ~= nil then
        displayEntry.experience = snapshot.experience
      end
      if displayEntry.gold == nil and snapshot.gold ~= nil then
        displayEntry.gold = snapshot.gold
      end
      if displayEntry.tokens == nil and snapshot.tokens ~= nil then
        displayEntry.tokens = snapshot.tokens
      end
    end

    entry = displayEntry
    dynastieManageEntry = displayEntry
  end
  if type(entry) == "table" then
    dynastieManageQuestData.entrySnapshot = {}
    for key, value in pairs(entry) do
      dynastieManageQuestData.entrySnapshot[key] = value
    end
  end
  local ownsDisplayedCore = hasOwnedDynastieSelection()
  local now = os.time()
  local title = dynastieManageWindow:recursiveGetChildById("title")
  local dynastieItem = dynastieManageWindow:recursiveGetChildById("dynastieItem")
  local owner = dynastieManageWindow:recursiveGetChildById("owner")
  local placer = dynastieManageWindow:recursiveGetChildById("placer")
  local emptyState = dynastieManageWindow:recursiveGetChildById("emptyState")
  local timer = dynastieManageWindow:recursiveGetChildById("timer")
  local tax = dynastieManageWindow:recursiveGetChildById("tax")
  local stored = dynastieManageWindow:recursiveGetChildById("stored")
  local storedTokens = dynastieManageWindow:recursiveGetChildById("storedTokens")
  local collectButton = dynastieManageWindow:recursiveGetChildById("collectButton")
  local taxButton = dynastieManageWindow:recursiveGetChildById("taxButton")
  local levelLabel = dynastieManageWindow:recursiveGetChildById("levelLabel")
  local expLabel = dynastieManageWindow:recursiveGetChildById("expLabel")
  local progressFill = dynastieManageWindow:recursiveGetChildById("progressBarFill")
  local dynastieFooterTokenBase = dynastieManageWindow:recursiveGetChildById("dynastieFooterTokenBase")
  local ownedCoreLabel = dynastieManageWindow:recursiveGetChildById("ownedCoreLabel")
  local ownedPrevCoreButton = dynastieManageWindow:recursiveGetChildById("ownedPrevCoreButton")
  local ownedNextCoreButton = dynastieManageWindow:recursiveGetChildById("ownedNextCoreButton")

  if title then title:setText(entry.name or "Dynasty") end
  if dynastieItem then
    dynastieItem:setItemId(tonumber(entry.clientId or entry.placedItemId or entry.baseItemId) or 0)
    dynastieItem:setItemCount(1)
    if dynastieItem.setOpacity then
      dynastieItem:setOpacity(entry.ownedByViewer and 1.0 or 0.45)
    end
  end
  if owner then owner:setText(ownsDisplayedCore and ("Owned by " .. (entry.ownerGuildName or "Unknown Guild")) or tr("No Dynastie Core Owned")) end
  if placer then placer:setText(ownsDisplayedCore and ("Placed by " .. (entry.ownerPlayerName or "Unknown")) or tr("Place a core in any configured city to begin.")) end
  if emptyState then emptyState:setVisible(not ownsDisplayedCore) end
  if ownedCoreLabel then
    if #dynastieManageEntries > 0 then
      ownedCoreLabel:setText(string.format("%d / %d", math.max(1, dynastieManageIndex), #dynastieManageEntries))
    else
      ownedCoreLabel:setText(tr("No Core Owned"))
    end
  end
  if ownedPrevCoreButton then
    ownedPrevCoreButton:setVisible(#dynastieManageEntries > 1)
    ownedPrevCoreButton:setEnabled(dynastieManageIndex > 1)
  end
  if ownedNextCoreButton then
    ownedNextCoreButton:setVisible(#dynastieManageEntries > 1)
    ownedNextCoreButton:setEnabled(dynastieManageIndex < #dynastieManageEntries)
  end

  local remaining = math.max(0, (tonumber(entry.collectAvailableAt or 0) or 0) - now)
  if entry.attack and entry.attack.status == "preparing" then
    if timer then timer:setText(string.format("Attack in: %s | A:%d D:%d", formatRemainingTime((tonumber(entry.attack.startsAt) or 0) - now), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0)) end
  elseif entry.attack and entry.attack.status == "active" then
    if timer then timer:setText(string.format("Battle: %s | A:%d D:%d", formatRemainingTime((tonumber(entry.attack.endsAt) or 0) - now), tonumber(entry.attack.attackerCount or 0) or 0, tonumber(entry.attack.defenderCount or 0) or 0)) end
  elseif ownsDisplayedCore then
    if remaining > 0 then
      if timer then timer:setText(string.format("Collect in: %s", formatRemainingTime(remaining))) end
    else
      if timer then timer:setText("Ready to collect") end
    end
  elseif tonumber(entry.shieldUntil or 0) > now then
    if timer then timer:setText(string.format("Shielded: %s", formatRemainingTime((tonumber(entry.shieldUntil) or 0) - now))) end
  else
    if timer then timer:setText(entry.isConfigured and "Available city dynastie" or "Location not configured") end
  end

  if tax then tax:setText(string.format("Tax: %d%%", tonumber(entry.taxRate or 0) or 0)) end
  if stored then stored:setText(string.format("Stored Gold: %s", comma_value(tonumber(entry.gold or 0) or 0))) end
  if storedTokens then storedTokens:setText(string.format("Stored Tokens: %s", comma_value(tonumber(entry.tokens or 0) or 0))) end
  if levelLabel then
    levelLabel:setText(string.format("Dynastie Level %d / %d", tonumber(entry.level or 1) or 1, tonumber(entry.levelCap or 10) or 10))
  end
  if expLabel then
    expLabel:setText(string.format("Core Experience: %s / %s", comma_value(tonumber(entry.experience or 0) or 0), comma_value(tonumber(entry.nextLevelExp or 0) or 0)))
  end
  if progressFill then
    local base = progressFill:getParent()
    local width = base and base:getWidth() or 280
    local maxExp = math.max(1, tonumber(entry.nextLevelExp or 1) or 1)
    local currentExp = math.max(0, tonumber(entry.experience or 0) or 0)
    progressFill:setWidth(math.floor(width * math.min(1, currentExp / maxExp)))
  end
  if dynastieFooterTokenBase then
    dynastieFooterTokenBase:setText(comma_value((myGuild and tonumber(myGuild.dynastieBalance)) or 0))
    dynastieFooterTokenBase:setTooltip(formatNumber((myGuild and tonumber(myGuild.dynastieBalance)) or 0))
  end

  local canManageDynastie = canManageCurrentDynastieEntry(entry)
  local canCollect = (entry.attack == nil) and (entry.canCollect == true or (entry.ownedByViewer == true and math.max(0, (tonumber(entry.collectAvailableAt or 0) or 0) - now) <= 0))
  local canTax = (entry.attack == nil) and (ownsDisplayedCore or canManageCurrentDynastieEntry(entry))
  if collectButton then
    collectButton:setVisible(ownsDisplayedCore)
    collectButton:setEnabled(canCollect)
    if canCollect and collectButton.enable then
      collectButton:enable()
    elseif (not canCollect) and collectButton.disable then
      collectButton:disable()
    end
  end
  if taxButton then
    local taxCooldownActive = (g_clock and g_clock.millis and g_clock.millis() or 0) < (dynastieTaxCooldownUntil or 0)
    taxButton:setVisible(ownsDisplayedCore)
    taxButton:setText(taxCooldownActive and tr("Wait a moment...") or string.format("Tax %d%%", tonumber(entry.taxRate or 0) or 0))
    taxButton:setEnabled(canTax and not taxCooldownActive)
    if canTax and not taxCooldownActive and taxButton.enable then
      taxButton:enable()
    elseif taxButton.disable then
      taxButton:disable()
    end
    taxButton:setOpacity((canTax and not taxCooldownActive) and 1.0 or 0.55)
  end

  renderDynastieManageQuestTab()
end

local function updateDynastiePassiveTreeDetails(node)
  if not dynastieManageWindow then
    return
  end

  local nameLabel = dynastieManageWindow:recursiveGetChildById("passiveTreeDetailName")
  local descriptionLabel = dynastieManageWindow:recursiveGetChildById("passiveTreeDetailDescription")
  local costLabel = dynastieManageWindow:recursiveGetChildById("passiveTreeDetailCost")
  local statusLabel = dynastieManageWindow:recursiveGetChildById("passiveTreeDetailStatus")
  local unlockButton = dynastieManageWindow:recursiveGetChildById("passiveTreeUnlockButton")

  if not node then
    if nameLabel then nameLabel:setText(tr("Select a passive node")) end
    if descriptionLabel then descriptionLabel:setText(tr("Choose a defender above, then click a milestone node to inspect the passive bonus and upgrade cost.")) end
    if costLabel then costLabel:setText(tr("Cost: -")) end
    if statusLabel then statusLabel:setText(tr("Status: Waiting for server passive tree data")) end
    if unlockButton then
      unlockButton:setText(tr("Locked"))
      if unlockButton.disable then unlockButton:disable() end
      unlockButton:setEnabled(false)
    end
    return
  end

  if nameLabel then
    nameLabel:setText(string.format("%s - %s", tostring(node.name or ""), tostring(node.bonus or "")))
  end
  if descriptionLabel then
    descriptionLabel:setText(node.description or "")
  end
  if costLabel then
    costLabel:setText(string.format("%s %s", tr("Cost:"), tostring(node.cost or "-")))
  end
  if statusLabel then
    statusLabel:setText(string.format("%s %s | %s %s | %s %s", tr("Defender:"), tostring(node.defenderName or "-"), tr("Milestone unlock:"), tostring(node.milestone or 0), tr("State:"), tostring(node.stateText or node.state or "-")))
  end
  if unlockButton then
    local canUnlock = node.canUnlock == true
    unlockButton:setText(canUnlock and tr("Unlock Selected") or tr("Locked"))
    unlockButton:setTooltip(canUnlock and string.format("%s\n%s", tostring(node.name or tr("Passive Node")), string.format("%s %s", tr("Cost:"), tostring(node.cost or "-"))) or tr("Select an unlockable passive node first."))
    if canUnlock and unlockButton.enable then
      unlockButton:enable()
    elseif unlockButton.disable then
      unlockButton:disable()
    end
    unlockButton:setEnabled(canUnlock)
    unlockButton.onClick = function()
      if not canUnlock then
        return
      end
      sendPacket("dynastiePassiveUnlock", {
        defenderId = tostring(node.defenderId or ""),
        nodeId = tostring(node.id or "")
      })
    end
  end
end

local function openDynastiePassiveResetDialog()
  local defenders = dynastiePassiveTreePreview and dynastiePassiveTreePreview.defenders or {}
  local resetCandidates = {}
  for _, defender in ipairs(defenders) do
    if (tonumber(defender.spentPoints or 0) or 0) > 0 then
      resetCandidates[#resetCandidates + 1] = defender
    end
  end

  if #resetCandidates <= 0 then
    displayInfoBox(tr("Passive Tree"), tr("There are no allocated passive points to reset."))
    return
  end

  clearMsgBox()
  local buttons = {}
  for _, defender in ipairs(resetCandidates) do
    buttons[#buttons + 1] = {
      text = tostring(defender.id and defender.id:gsub("^%l", string.upper) or defender.name or tr("Defender")),
      callback = function()
        clearMsgBox()
        local defenderId = tostring(defender.id or "")
        local defenderName = tostring(defender.name or tr("Defender"))
        msgBox = displayGeneralBox(
          tr("Reset Passive Tree"),
          tr("Reset all allocated passive nodes for %s?\n\nCost: 1 dynastie token.\nThis only resets that defender branch.", defenderName),
          {
            { text = tr("No"), callback = function() clearMsgBox() end },
            {
              text = tr("Yes"),
              imageColor = "red",
              callback = function()
                clearMsgBox()
                sendPacket("dynastiePassiveReset", { defenderId = defenderId })
              end
            }
          },
          nil,
          function() clearMsgBox() end
        )
      end
    }
  end
  buttons[#buttons + 1] = { text = tr("Cancel"), callback = function() clearMsgBox() end }

  msgBox = displayGeneralBox(
    tr("Reset Passive Tree"),
    tr("Which passive branch do you want to reset?"),
    buttons,
    nil,
    function() clearMsgBox() end
  )
end

local function buildPassiveTreeTooltip(defenderName, node)
  if not node then
    return defenderName and string.format("%s\nNo passive unlocked at this milestone.", defenderName) or tr("No passive node.")
  end

  local lines = {
    string.format("%s: %s", tr("Defender"), tostring(defenderName or "-")),
    string.format("%s %s", tr("Milestone"), tostring(node.milestone or 0)),
    tostring(node.name or tr("Passive")),
    tostring(node.bonus or ""),
    tostring(node.description or ""),
    string.format("%s: %s", tr("Cost"), tostring(node.cost or "-"))
  }
  return table.concat(lines, "\n")
end

renderDynastiePassiveTreeTab = function()
  if not dynastieManageWindow then
    return
  end

  local pointsLabel = dynastieManageWindow:recursiveGetChildById("passiveTreePointsLabel")
  local totalPointsLabel = dynastieManageWindow:recursiveGetChildById("passiveTreeTotalPointsLabel")
  local resetButton = dynastieManageWindow:recursiveGetChildById("passiveTreeResetButton")
  local content = dynastieManageWindow:recursiveGetChildById("passiveTreeTableContent")
  local headerBand = dynastieManageWindow:recursiveGetChildById("passiveTreeHeaderBand")
  local rowsBand = dynastieManageWindow:recursiveGetChildById("passiveTreeRowsBand")
  local scrollArea = dynastieManageWindow:recursiveGetChildById("passiveTreeScroll")
  local horizontalScrollbar = dynastieManageWindow:recursiveGetChildById("passiveTreeHorizontalScrollbar")
  local verticalScrollbar = dynastieManageWindow:recursiveGetChildById("passiveTreeVerticalScrollbar")

  if not headerBand or not rowsBand then
    return
  end

  if not hasOwnedDynastieSelection() then
    headerBand:destroyChildren()
    rowsBand:destroyChildren()
    if pointsLabel then
      pointsLabel:setText(string.format("%s %d", tr("Available Points:"), 0))
    end
    if totalPointsLabel then
      totalPointsLabel:setText(string.format("%s %d / %d", tr("Total Points:"), 0, 0))
    end
    if resetButton then
      resetButton:setEnabled(false)
      if resetButton.disable then resetButton:disable() end
    end
    updateDynastiePassiveTreeDetails(nil)
    setDynastieTabOwnedMessage("passiveTreeView")
    return
  end

  clearDynastieTabOwnedMessage("passiveTreeView")

  if not content then
    content = headerBand:getParent()
  end

  local defenders = dynastiePassiveTreePreview.defenders or {}
  if #defenders <= 0 then
    if pointsLabel then
      pointsLabel:setText(string.format("%s %d", tr("Available Points:"), 0))
    end
    if totalPointsLabel then
      totalPointsLabel:setText(string.format("%s %d / %d", tr("Total Points:"), 0, 0))
    end
    headerBand:destroyChildren()
    rowsBand:destroyChildren()
    updateDynastiePassiveTreeDetails(nil)
    if resetButton then
      resetButton:setEnabled(false)
      if resetButton.disable then resetButton:disable() end
    end
    return
  end

  if resetButton then
    local hasSpentPoints = false
    for _, entry in ipairs(defenders) do
      if (tonumber(entry.spentPoints or 0) or 0) > 0 then
        hasSpentPoints = true
        break
      end
    end
    resetButton:setEnabled(hasSpentPoints)
    if hasSpentPoints and resetButton.enable then
      resetButton:enable()
    elseif resetButton.disable then
      resetButton:disable()
    end
    resetButton.onClick = openDynastiePassiveResetDialog
  end

  local defender = nil
  local wantedId = dynastiePassiveTreePreview.selectedDefenderId
  for _, entry in ipairs(defenders) do
    if entry.id == wantedId then
      defender = entry
      break
    end
  end
  defender = defender or defenders[1]
  dynastiePassiveTreePreview.selectedDefenderId = defender and defender.id or nil
  if not dynastiePassiveTreePreview.selectedNodeId and defender and defender.nodes and defender.nodes[1] then
    dynastiePassiveTreePreview.selectedNodeId = string.format("%s:%s", defender.id, tostring(defender.nodes[1].milestone or ""))
  end

  if pointsLabel then
    local availablePoints = 0
    local spentPoints = 0
    local maxPoints = 0
    for _, entry in ipairs(defenders) do
      availablePoints = availablePoints + (tonumber(entry.points or 0) or 0)
      spentPoints = spentPoints + (tonumber(entry.spentPoints or 0) or 0)
      maxPoints = maxPoints + (tonumber(entry.maxPoints or 0) or 0)
    end
    pointsLabel:setText(string.format("%s %d", tr("Available Points:"), availablePoints))
    if totalPointsLabel then
      totalPointsLabel:setText(string.format("%s %d / %d", tr("Total Points:"), spentPoints, maxPoints))
    end
  elseif totalPointsLabel then
    totalPointsLabel:setText(string.format("%s %d / %d", tr("Total Points:"), 0, 0))
  end

  headerBand:destroyChildren()
  rowsBand:destroyChildren()

  local allMilestones = {}
  local seenMilestones = {}
  for _, entry in ipairs(defenders) do
    for _, node in ipairs(entry.nodes or {}) do
      local milestone = tonumber(node.milestone or 0) or 0
      if milestone > 0 and not seenMilestones[milestone] then
        seenMilestones[milestone] = true
        table.insert(allMilestones, milestone)
      end
    end
  end
  table.sort(allMilestones)

  local leftColumnWidth = 180
  local cellWidth = 154
  local cellHeight = 108
  local headerHeight = 30
  local contentWidth = leftColumnWidth + (#allMilestones * cellWidth)
  local contentHeight = headerHeight + (#defenders * cellHeight)

  for _, milestone in ipairs(allMilestones) do
    local headerCell = g_ui.createWidget("DynastiePassiveHeaderCell", headerBand)
    local headerText = headerCell:recursiveGetChildById("text")
    if headerText then
      headerText:setText(string.format("%s %d", tr("Level"), milestone))
    end
  end

  local selectedNode = nil
  for _, entry in ipairs(defenders) do
    local row = g_ui.createWidget("DynastiePassiveDefenderRow", rowsBand)
    row:setHeight(cellHeight)
    row:setWidth(contentWidth)

    local defenderLabel = g_ui.createWidget("DynastiePassiveDefenderLabel", row)
    defenderLabel:setWidth(leftColumnWidth)
    local defenderNameLabel = defenderLabel:recursiveGetChildById("name")
    local defenderPointsLabel = defenderLabel:recursiveGetChildById("points")
    if defenderNameLabel then
      defenderNameLabel:setText(entry.name or tr("Defender"))
    end
    if defenderPointsLabel then
      defenderPointsLabel:setText(string.format("%s %d", tr("Points:"), tonumber(entry.points or 0) or 0))
    end

    local nodeByMilestone = {}
    for _, node in ipairs(entry.nodes or {}) do
      nodeByMilestone[tonumber(node.milestone or 0) or 0] = node
    end

    for _, milestone in ipairs(allMilestones) do
      local node = nodeByMilestone[milestone]
      local cell = g_ui.createWidget("DynastiePassiveNodeCell", row)
      cell:setWidth(cellWidth)
      cell:setHeight(cellHeight)
      local nodeId = string.format("%s:%s", entry.id or "", tostring(milestone or ""))
      local square = cell:recursiveGetChildById("square")
      local iconWidget = square and square:recursiveGetChildById("icon") or nil
      local shortLabel = square and square:recursiveGetChildById("short") or nil
      local nameLabel = cell:recursiveGetChildById("name")
      local statusLabel = cell:recursiveGetChildById("status")
      if node then
        local state = tostring(node.state or "locked")
        local isLocked = state == "locked"
        local isUnlocked = state == "unlocked"
        local isActive = state == "active"
        local isSelected = tostring(dynastiePassiveTreePreview.selectedNodeId or "") == nodeId

        if iconWidget then
          local imageSource = tostring(node.iconSource or "")
          if imageSource == "" then
            imageSource = tostring(node.icon or "")
          end
          if imageSource ~= "" then
            if not imageSource:find("/") then
              imageSource = "/images/guild_hall/" .. imageSource
            end
            iconWidget:setImageSource(imageSource)
            iconWidget:setVisible(true)
            iconWidget:setOpacity(isLocked and 0.18 or (isUnlocked and not isActive and 0.58 or 1.0))
          else
            iconWidget:setVisible(false)
            iconWidget:setImageSource("")
          end
        end
        if shortLabel then
          shortLabel:setText((iconWidget and iconWidget:isVisible()) and "" or (node.short or "?"))
          shortLabel:setOpacity(isLocked and 0.35 or (isUnlocked and not isActive and 0.7 or 1.0))
        end
        if nameLabel then nameLabel:setText(node.name or tr("Passive")) end
        if statusLabel then
          local stateText = tostring(node.stateText or (isActive and tr("Active") or (isUnlocked and tr("Unlocked") or tr("Locked"))))
          statusLabel:setText(stateText)
          statusLabel:setColor(isActive and "#98f098" or (isUnlocked and "#d7c78e" or "#8b8479"))
        end
        cell:setBackgroundColor(isSelected and "#3b3428" or (isActive and "#3a3228" or (isUnlocked and "#35312c" or "#262320")))
        cell:setBorderColor(isSelected and "#d7af57" or (isActive and "#8f7a56" or (isUnlocked and "#7c6f5d" or "#5d5448")))
        cell:setOpacity(isLocked and 0.62 or (isUnlocked and not isActive and 0.82 or 1.0))
        local tooltip = buildPassiveTreeTooltip(entry.name or tr("Defender"), node)
        cell:setTooltip(tooltip)
        if square then square:setTooltip(tooltip) end
        if iconWidget then iconWidget:setTooltip(tooltip) end
        if shortLabel then shortLabel:setTooltip(tooltip) end
        if nameLabel then nameLabel:setTooltip(tooltip) end
        if statusLabel then statusLabel:setTooltip(tooltip) end
        cell.onClick = function()
          dynastiePassiveTreePreview.selectedDefenderId = entry.id
          dynastiePassiveTreePreview.selectedNodeId = nodeId
          renderDynastiePassiveTreeTab()
        end
        if isSelected then
          node.id = node.id or ""
          node.defenderId = entry.id or ""
          node.defenderName = entry.name or tr("Defender")
          selectedNode = node
        end
      else
        if iconWidget then
          iconWidget:setVisible(false)
          iconWidget:setImageSource("")
        end
        if shortLabel then shortLabel:setText("-") end
        if nameLabel then nameLabel:setText(entry.name or tr("No Node")) end
        if statusLabel then statusLabel:setText("") end
        cell:setOpacity(0.55)
        local tooltip = buildPassiveTreeTooltip(entry.name or tr("Defender"), nil)
        cell:setTooltip(tooltip)
        if square then square:setTooltip(tooltip) end
        if iconWidget then iconWidget:setTooltip(tooltip) end
        if shortLabel then shortLabel:setTooltip(tooltip) end
        if nameLabel then nameLabel:setTooltip(tooltip) end
        if statusLabel then statusLabel:setTooltip(tooltip) end
      end
    end
  end

  headerBand:setWidth(math.max(1, #allMilestones * cellWidth))
  headerBand:setHeight(headerHeight)
  rowsBand:setWidth(contentWidth)
  rowsBand:setHeight(math.max(1, #defenders * cellHeight))
  if content then
    content:setWidth(math.max(1080, contentWidth + 16))
    content:setHeight(math.max(360, contentHeight + 16))
    content:setMarginLeft(0)
    content:setMarginTop(0)
    content:setX(0)
    content:setY(0)
  end
  if scrollArea and horizontalScrollbar and verticalScrollbar then
    local viewportWidth = math.max(1, (scrollArea:getWidth() or 0) - 24)
    local viewportHeight = math.max(1, (scrollArea:getHeight() or 0) - 24)
    local maxX = math.max(0, math.floor((content and content:getWidth() or contentWidth) - viewportWidth))
    local maxY = math.max(0, math.floor((content and content:getHeight() or contentHeight) - viewportHeight))

    scrollArea.onScrollChange = function(widget, virtualOffset)
      dynastiePassiveTreeScrollOffset.x = tonumber(virtualOffset.x) or 0
      dynastiePassiveTreeScrollOffset.y = tonumber(virtualOffset.y) or 0
    end

    if scrollArea.updateScrollBars then
      scrollArea:updateScrollBars()
    end

    local clampedX = math.max(0, math.min(maxX, tonumber(dynastiePassiveTreeScrollOffset.x) or 0))
    local clampedY = math.max(0, math.min(maxY, tonumber(dynastiePassiveTreeScrollOffset.y) or 0))
    dynastiePassiveTreeScrollOffset.x = clampedX
    dynastiePassiveTreeScrollOffset.y = clampedY
    if scrollArea.setVirtualOffset then
      scrollArea:setVirtualOffset({ x = clampedX, y = clampedY })
    end

  end

  updateDynastiePassiveTreeDetails(selectedNode)
end

showDynastieManageTab = function(tabName)
  if not dynastieManageWindow then
    return
  end

  if tabName ~= "general" and tabName ~= "quests" and tabName ~= "perks" and tabName ~= "defenders" and tabName ~= "passivetree" and tabName ~= "achievements" and tabName ~= "events" and tabName ~= "boardquests" then
    tabName = "general"
  end
  dynastieManageCurrentTab = tabName
  if tabName ~= "quests" then
    stopDynastieManageQuestCountdown()
  end

  local generalTabBtn = dynastieManageWindow:recursiveGetChildById("generalTabBtn")
  local questsTabBtn = dynastieManageWindow:recursiveGetChildById("questsTabBtn")
  local perksTabBtn = dynastieManageWindow:recursiveGetChildById("perksTabBtn")
  local defendersTabBtn = dynastieManageWindow:recursiveGetChildById("defendersTabBtn")
  local passiveTreeTabBtn = dynastieManageWindow:recursiveGetChildById("passiveTreeTabBtn")
  local achievementsTabBtn = dynastieManageWindow:recursiveGetChildById("achievementsTabBtn")
  local eventCalendarTabBtn = dynastieManageWindow:recursiveGetChildById("eventCalendarTabBtn")
  local boardQuestsTabBtn = dynastieManageWindow:recursiveGetChildById("boardQuestsTabBtn")
  local generalView = dynastieManageWindow:recursiveGetChildById("generalView")
  local questsView = dynastieManageWindow:recursiveGetChildById("questsView")
  local perksView = dynastieManageWindow:recursiveGetChildById("perksView")
  local defendersView = dynastieManageWindow:recursiveGetChildById("defendersView")
  local passiveTreeView = dynastieManageWindow:recursiveGetChildById("passiveTreeView")
  local achievementsView = dynastieManageWindow:recursiveGetChildById("achievementsView")
  local eventsView = dynastieManageWindow:recursiveGetChildById("eventsView")
  local boardQuestsView = dynastieManageWindow:recursiveGetChildById("boardQuestsView")

  if generalView then generalView:setVisible(tabName == "general") end
  if questsView then questsView:setVisible(tabName == "quests") end
  if perksView then perksView:setVisible(tabName == "perks") end
  if defendersView then defendersView:setVisible(tabName == "defenders") end
  if passiveTreeView then passiveTreeView:setVisible(tabName == "passivetree") end
  if achievementsView then achievementsView:setVisible(tabName == "achievements") end
  if eventsView then eventsView:setVisible(tabName == "events") end
  if boardQuestsView then boardQuestsView:setVisible(tabName == "boardquests") end

  if generalTabBtn then
    generalTabBtn:setOn(tabName == "general")
    generalTabBtn:setChecked(tabName == "general")
  end
  if questsTabBtn then
    questsTabBtn:setOn(tabName == "quests")
    questsTabBtn:setChecked(tabName == "quests")
  end
  if perksTabBtn then
    perksTabBtn:setOn(tabName == "perks")
    perksTabBtn:setChecked(tabName == "perks")
  end
  if defendersTabBtn then
    defendersTabBtn:setOn(tabName == "defenders")
    defendersTabBtn:setChecked(tabName == "defenders")
  end
  if passiveTreeTabBtn then
    passiveTreeTabBtn:setOn(tabName == "passivetree")
    passiveTreeTabBtn:setChecked(tabName == "passivetree")
  end
  if achievementsTabBtn then
    achievementsTabBtn:setOn(tabName == "achievements")
    achievementsTabBtn:setChecked(tabName == "achievements")
  end
  if eventCalendarTabBtn then
    eventCalendarTabBtn:setOn(tabName == "events")
    eventCalendarTabBtn:setChecked(tabName == "events")
  end
  if boardQuestsTabBtn then
    boardQuestsTabBtn:setOn(tabName == "boardquests")
    boardQuestsTabBtn:setChecked(tabName == "boardquests")
  end
  if tabName == "quests" then
    renderDynastieManageQuestTab()
    startDynastieManageQuestCountdown()
  elseif tabName == "perks" then
    renderDynastiePerksTab()
  elseif tabName == "defenders" then
    renderDynastieDefendersTab()
  elseif tabName == "passivetree" then
    dynastiePassiveTreeScrollOffset.x = 0
    dynastiePassiveTreeScrollOffset.y = 0
    renderDynastiePassiveTreeTab()
    if dynastieManageEntry and dynastieManageEntry.id ~= "" then
      sendPacket("dynastiePanelFetch", {})
    end
  elseif tabName == "achievements" then
    renderDynastieAchievementsTab()
  elseif tabName == "events" then
    renderDynastieEventsTab()
  elseif tabName == "boardquests" then
    sendPacket("dynastieBoardAcceptedFetch", {})
    renderDynastieBoardAcceptedTab()
  end
end

openDynastieManageWindow = function(entry, entries, selectedIndex)
	if not entry then
		return
	end

	closeDynastieManageWindow()
  dynastieManageCurrentTab = "general"
  dynastieManageEntry, dynastieManageEntries, dynastieManageIndex = resolveDynastieManageSelection(
    type(entries) == "table" and entries or ((entry.ownedByViewer and entry.id ~= "") and { entry } or {}),
    entry,
    selectedIndex
  )
  dynastieManageQuestData = {
    configId = tostring(dynastieManageEntry.id or ""),
    daily = {},
    weekend = {},
    monthly = {},
    dailyEndsAt = 0,
    weekendEndsAt = 0,
    monthlyEndsAt = 0,
    entrySnapshot = nil,
    pendingTaxConfigId = "",
    countdownEvent = nil
  }
  if type(dynastieManageEntry) == "table" then
    dynastieManageQuestData.entrySnapshot = {}
    for key, value in pairs(dynastieManageEntry) do
      dynastieManageQuestData.entrySnapshot[key] = value
    end
  end
  dynastieManageWindow = g_ui.createWidget("GuildDynastieManageWindow", rootWidget)
  if not dynastieManageWindow then
    dynastieManageEntry = nil
    return
  end

  dynastieManageWindow:raise()
  dynastieManageWindow:focus()
  local collectButton = dynastieManageWindow:recursiveGetChildById("collectButton")
  local taxButton = dynastieManageWindow:recursiveGetChildById("taxButton")
  if dynastieManageWindow:recursiveGetChildById("closeButton") then
    dynastieManageWindow:recursiveGetChildById("closeButton").onClick = closeDynastieManageWindow
  end
  if dynastieManageWindow:recursiveGetChildById("generalTabBtn") then
    dynastieManageWindow:recursiveGetChildById("generalTabBtn").onClick = function()
      showDynastieManageTab("general")
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("generalTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.general)
  end
  if dynastieManageWindow:recursiveGetChildById("questsTabBtn") then
    dynastieManageWindow:recursiveGetChildById("questsTabBtn").onClick = function()
      showDynastieManageTab("quests")
      renderDynastieManageQuestTab()
      if dynastieManageEntry and dynastieManageEntry.id ~= "" and dynastieManageEntry.ownedByViewer then
        sendPacket("dynastieQuestsFetch", { configId = dynastieManageEntry.id })
      end
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("questsTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.quests)
  end
  if dynastieManageWindow:recursiveGetChildById("perksTabBtn") then
    dynastieManageWindow:recursiveGetChildById("perksTabBtn").onClick = function()
      showDynastieManageTab("perks")
      if dynastieManageEntry and dynastieManageEntry.id ~= "" then
        sendPacket("dynastiePanelFetch", {})
      end
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("perksTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.perks)
  end
  if dynastieManageWindow:recursiveGetChildById("defendersTabBtn") then
    dynastieManageWindow:recursiveGetChildById("defendersTabBtn").onClick = function()
      showDynastieManageTab("defenders")
      if dynastieManageEntry and dynastieManageEntry.id ~= "" then
        sendPacket("dynastiePanelFetch", {})
      end
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("defendersTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.defenders)
  end
  if dynastieManageWindow:recursiveGetChildById("passiveTreeTabBtn") then
    dynastieManageWindow:recursiveGetChildById("passiveTreeTabBtn").onClick = function()
      showDynastieManageTab("passivetree")
      if dynastieManageEntry and dynastieManageEntry.id ~= "" then
        sendPacket("dynastiePanelFetch", {})
      end
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("passiveTreeTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.passivetree)
  end
  if dynastieManageWindow:recursiveGetChildById("achievementsTabBtn") then
    dynastieManageWindow:recursiveGetChildById("achievementsTabBtn").onClick = function()
      showDynastieManageTab("achievements")
      if dynastieManageEntry and dynastieManageEntry.id ~= "" then
        requestDynastieAchievementsPage(tonumber(dynastieAchievementData.page or 1) or 1)
      end
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("achievementsTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.achievements)
  end
  if dynastieManageWindow:recursiveGetChildById("eventCalendarTabBtn") then
    dynastieManageWindow:recursiveGetChildById("eventCalendarTabBtn").onClick = function()
      showDynastieManageTab("events")
      requestDynastieEventsMonth(dynastieEventCalendarData.monthOffset or 0)
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("eventCalendarTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.events)
  end
  if dynastieManageWindow:recursiveGetChildById("boardQuestsTabBtn") then
    dynastieManageWindow:recursiveGetChildById("boardQuestsTabBtn").onClick = function()
      showDynastieManageTab("boardquests")
      sendPacket("dynastieBoardAcceptedFetch", {})
    end
    setupTabButtonIcon(dynastieManageWindow:recursiveGetChildById("boardQuestsTabBtn"), DYNASTIE_MANAGE_TAB_ICON_CLIPS.boardquests)
  end
    if dynastieManageWindow:recursiveGetChildById("ownedPrevCoreButton") then
      dynastieManageWindow:recursiveGetChildById("ownedPrevCoreButton").onClick = function()
        if dynastieManageIndex > 1 and dynastieManageEntries[dynastieManageIndex - 1] then
          dynastieManageEntry, dynastieManageEntries, dynastieManageIndex = resolveDynastieManageSelection(dynastieManageEntries, dynastieManageEntries[dynastieManageIndex - 1], dynastieManageIndex - 1)
          dynastieManageQuestData = {
            configId = tostring(dynastieManageEntry.id or ""),
            daily = {},
          weekend = {},
          monthly = {},
          dailyEndsAt = 0,
          weekendEndsAt = 0,
          monthlyEndsAt = 0
        }
        refreshDynastieManageWindow()
        if dynastieManageCurrentTab == "quests" and dynastieManageEntry.id ~= "" then
          sendPacket("dynastieQuestsFetch", { configId = dynastieManageEntry.id })
        elseif dynastieManageCurrentTab == "achievements" then
          requestDynastieAchievementsPage(1)
        elseif dynastieManageCurrentTab == "events" then
          requestDynastieEventsMonth(dynastieEventCalendarData.monthOffset or 0)
        elseif dynastieManageCurrentTab == "boardquests" then
          sendPacket("dynastieBoardAcceptedFetch", {})
        end
      end
    end
  end
    if dynastieManageWindow:recursiveGetChildById("ownedNextCoreButton") then
      dynastieManageWindow:recursiveGetChildById("ownedNextCoreButton").onClick = function()
        if dynastieManageIndex < #dynastieManageEntries and dynastieManageEntries[dynastieManageIndex + 1] then
          dynastieManageEntry, dynastieManageEntries, dynastieManageIndex = resolveDynastieManageSelection(dynastieManageEntries, dynastieManageEntries[dynastieManageIndex + 1], dynastieManageIndex + 1)
          dynastieManageQuestData = {
            configId = tostring(dynastieManageEntry.id or ""),
            daily = {},
          weekend = {},
          monthly = {},
          dailyEndsAt = 0,
          weekendEndsAt = 0,
          monthlyEndsAt = 0
        }
        refreshDynastieManageWindow()
        if dynastieManageCurrentTab == "quests" and dynastieManageEntry.id ~= "" then
          sendPacket("dynastieQuestsFetch", { configId = dynastieManageEntry.id })
        elseif dynastieManageCurrentTab == "achievements" then
          requestDynastieAchievementsPage(1)
        elseif dynastieManageCurrentTab == "events" then
          requestDynastieEventsMonth(dynastieEventCalendarData.monthOffset or 0)
        elseif dynastieManageCurrentTab == "boardquests" then
          sendPacket("dynastieBoardAcceptedFetch", {})
        end
      end
    end
  end
  if collectButton then
    collectButton.onClick = function()
      local currentEntry = dynastieManageEntry
      local canManageDynastie = false
      if GUILDS_CFG and GUILDS_CFG.PERMISSIONS and GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE ~= nil then
        canManageDynastie = hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE)
      end
      local canCollectNow = currentEntry and (
        currentEntry.canCollect == true or
        (canManageDynastie and currentEntry.ownedByViewer == true and math.max(0, (tonumber(currentEntry.collectAvailableAt or 0) or 0) - os.time()) <= 0)
      )
      if not currentEntry or currentEntry.id == "" or not canCollectNow then
        return
      end

      local storedGold = tonumber(currentEntry.gold or 0) or 0
      local storedTokens = tonumber(currentEntry.tokens or 0) or 0
      local confirmMessage
      if storedGold <= 0 and storedTokens <= 0 then
        confirmMessage = tr("There is nothing to collect.\n\nAre you sure you want to collect the %s core and remove it?", currentEntry.name or tr("Dynasty"))
      else
        confirmMessage = tr("Are you sure you want to collect the %s core?\n\nStored Gold: %s\nStored Tokens: %s", currentEntry.name or tr("Dynasty"), comma_value(storedGold), comma_value(storedTokens))
      end

      clearMsgBox()
      msgBox = displayGeneralBox(
        tr("Dynasty"),
        confirmMessage,
        {
          { text = tr("No"), callback = function() clearMsgBox() end },
          { text = tr("Yes"), imageColor = "red", callback = function()
            sendPacket("dynastieCollect", { configId = currentEntry.id })
            closeDynastieManageWindow()
            clearMsgBox()
          end }
        }
      )
    end
  end
  if taxButton then
    taxButton.onClick = function()
      local currentEntry = syncCurrentDynastieManageEntryFromData() or dynastieManageEntry
      local now = g_clock and g_clock.millis and g_clock.millis() or 0
      if now < (dynastieTaxCooldownUntil or 0) then
        return
      end
      local canSetTaxNow = currentEntry and (
        currentEntry.canSetTax == true or currentEntry.ownedByViewer == true
      )
      if not currentEntry or currentEntry.id == "" or not canSetTaxNow then
        return
      end
      local currentTax = tonumber(currentEntry.taxRate or 0) or 0
      local maxTax = math.max(0, tonumber(currentEntry.maxTaxRate or currentEntry.level or 0) or 0)
      local nextTax = currentTax + 1
      if nextTax > maxTax then
        nextTax = 0
      end
      applyLocalDynastieTaxRate(currentEntry.id, nextTax)
      dynastieManageQuestData.pendingTaxConfigId = tostring(currentEntry.id or "")
      dynastieTaxCooldownUntil = now + 2000
      local taxLabel = dynastieManageWindow and dynastieManageWindow:recursiveGetChildById("tax")
      if taxLabel then
        taxLabel:setText(string.format("Tax: %d%%", nextTax))
      end
      if taxButton then
        taxButton:setText(tr("Wait a moment..."))
        taxButton:setEnabled(false)
        if taxButton.disable then
          taxButton:disable()
        end
        taxButton:setOpacity(0.55)
      end
      scheduleEvent(function()
        if dynastieManageWindow then
          local activeEntry = syncCurrentDynastieManageEntryFromData() or dynastieManageEntry
          local activeTaxButton = dynastieManageWindow:recursiveGetChildById("taxButton")
          local activeTaxLabel = dynastieManageWindow:recursiveGetChildById("tax")
          local cooldownActive = (g_clock and g_clock.millis and g_clock.millis() or 0) < (dynastieTaxCooldownUntil or 0)
          if activeTaxLabel and activeEntry then
            activeTaxLabel:setText(string.format("Tax: %d%%", tonumber(activeEntry.taxRate or 0) or 0))
          end
          if activeTaxButton and activeEntry then
            local canSetTaxLater = (activeEntry.attack == nil) and (activeEntry.ownedByViewer == true or canManageCurrentDynastieEntry(activeEntry))
            activeTaxButton:setText(cooldownActive and tr("Wait a moment...") or string.format("Tax %d%%", tonumber(activeEntry.taxRate or 0) or 0))
            activeTaxButton:setEnabled(canSetTaxLater and not cooldownActive)
            if canSetTaxLater and not cooldownActive and activeTaxButton.enable then
              activeTaxButton:enable()
            elseif activeTaxButton.disable then
              activeTaxButton:disable()
            end
            activeTaxButton:setOpacity((canSetTaxLater and not cooldownActive) and 1.0 or 0.55)
          end
        end
      end, 2100)
      sendPacket("dynastieTax", { configId = currentEntry.id, taxRate = nextTax })
    end
  end

  showDynastieManageTab(dynastieManageCurrentTab)
  refreshDynastieManageWindow()
  if dynastieManageEntry.id ~= "" and dynastieManageEntry.ownedByViewer then
      sendPacket("dynastiePanelFetch", {})
      sendPacket("dynastieQuestsFetch", { configId = dynastieManageEntry.id })
      if dynastieManageCurrentTab == "achievements" then
        requestDynastieAchievementsPage(tonumber(dynastieAchievementData.page or 1) or 1)
      elseif dynastieManageCurrentTab == "events" then
      requestDynastieEventsMonth(dynastieEventCalendarData.monthOffset or 0)
    end
  else
    renderDynastieManageQuestTab()
    if dynastieManageCurrentTab == "events" then
      requestDynastieEventsMonth(dynastieEventCalendarData.monthOffset or 0)
    end
  end
end

local function setWidgetEnabled(widget, enabled)
  if not widget then
    return
  end

  if widget.setEnabled then
    widget:setEnabled(enabled)
    return
  end

  if enabled then
    if widget.enable then
      widget:enable()
    end
  else
    if widget.disable then
      widget:disable()
    end
  end
end

clearMsgBox = function()
  if not msgBox then
    return
  end

  local box = msgBox
  msgBox = nil
  if box.destroy then
    box:destroy()
  end
end

local function setGuildUiIcon(widget, clip)
  if not widget or not clip then
    return
  end

  widget:setImageSource(clip.source or "/images/guild_hall/icons")
  widget:setImageClip(clip)
  widget:setImageRect(clip.rect or { x = -5, y = -7, width = 21, height = 21 })
end

setupTabButtonIcon = function(button, iconData)
  if not button or not iconData or not iconData.clip then
    return
  end

  local icon = button:getChildById("tabIcon")
  if not icon then
    icon = g_ui.createWidget("GuildTabIcon", button)
    icon:setId("tabIcon")
  end

  icon:breakAnchors()
  icon:addAnchor(AnchorLeft, "parent", AnchorLeft)
  icon:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)

  icon:setSize({ width = 24, height = 24 })
  icon:setImageSource(iconData.source or "/images/guild_hall/icons2")
  icon:setImageClip(iconData.clip)
  icon:setImageRect({ x = -7, y = 0, width = 24, height = 24 })
  if icon.setPhantom then
    icon:setPhantom(true)
  end

  icon:setMarginLeft(iconData.marginLeft or 18)
  icon:setMarginTop(iconData.marginTop or 0)
end

local function setupGeneralTabIcons()
  if not generalPanel or not generalPanel.general then
    return
  end

  setGuildUiIcon(generalPanel.general:recursiveGetChildById("leaderIcon"), GUILD_UI_ICON_CLIPS.leader)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("membersIcon"), GUILD_UI_ICON_CLIPS.members)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("storageIcon"), GUILD_UI_ICON_CLIPS.storage)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("prismsIcon"), GUILD_UI_ICON_CLIPS.prisms)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("dynastiesIcon"), GUILD_UI_ICON_CLIPS.dynasties)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("achievementsIcon"), GUILD_UI_ICON_CLIPS.achievements)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("killsIcon"), GUILD_UI_ICON_CLIPS.kills)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("joinStatusIcon"), GUILD_UI_ICON_CLIPS.joinStatus)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("languageIcon"), GUILD_UI_ICON_CLIPS.language)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("reqLevelIcon"), GUILD_UI_ICON_CLIPS.reqLevel)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("createdIcon"), GUILD_UI_ICON_CLIPS.created)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("rankIcon"), GUILD_UI_ICON_CLIPS.rank)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("totalIcon"), GUILD_UI_ICON_CLIPS.total)
  local levelIcon = generalPanel.general:recursiveGetChildById("levelIcon")
  setGuildUiIcon(levelIcon, GUILD_UI_ICON_CLIPS.level)
  if levelIcon then
    levelIcon:setSize({ width = 18, height = 18 })
    levelIcon:setImageRect({ x = -3, y = -5, width = 18, height = 18 })
  end

  local contributionIcon = generalPanel.general:recursiveGetChildById("contributionIcon")
  setGuildUiIcon(contributionIcon, GUILD_UI_ICON_CLIPS.contribution)
  if contributionIcon then
    contributionIcon:setSize({ width = 18, height = 18 })
    contributionIcon:setImageRect({ x = -3, y = -5, width = 18, height = 18 })
  end
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("donateIcon"), GUILD_UI_ICON_CLIPS.donate)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("premiumDonateIcon"), GUILD_UI_ICON_CLIPS.premiumDonate)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("withdrawIcon"), GUILD_UI_ICON_CLIPS.withdraw)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("contributionButtonIcon"), GUILD_UI_ICON_CLIPS.contribution)
  setGuildUiIcon(generalPanel.general:recursiveGetChildById("premiumContributionIcon"), GUILD_UI_ICON_CLIPS.premiumContribution)
end

local function updateGuildExpBar(current, maximum)
  if not generalPanel or not generalPanel.general or not generalPanel.general.stats then
    return
  end

  local guildExp = generalPanel.general.stats.guildExp
  if not guildExp then
    return
  end

  local bar = guildExp:getChildById("bar")
  local label = guildExp:getChildById("text")
  local maxValue = math.max(tonumber(maximum) or 0, 1)
  local currentValue = math.max(0, tonumber(current) or 0)
  local width = math.ceil((guildExp:getWidth() - 4) * math.min(currentValue, maxValue) / maxValue)

  if bar then
    bar:setWidth(width)
    bar:setImageClip("0 0 110 15")
  end

  if label then
    label:setText(currentValue .. "/" .. maxValue)
  end
end

local function setSelectedEmblemWidget(widget)
  if selectedEmblemWidget and selectedEmblemWidget ~= widget then
    selectedEmblemWidget:setChecked(false)
  end

  selectedEmblemWidget = widget

  if selectedEmblemWidget then
    selectedEmblemWidget:setChecked(true)
    if emblemList and emblemList.listBase and emblemList.listBase.list then
      emblemList.listBase.list:focusChild(selectedEmblemWidget)
    end
  end
end

local function cloneTable(value)
  if type(value) ~= "table" then
    return value
  end

  local copy = {}
  for k, v in pairs(value) do
    copy[k] = cloneTable(v)
  end
  return copy
end

local function getPermissionColumnIndex(permission)
  local visiblePermissions = {
    GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS,
    GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS,
    GUILDS_CFG.PERMISSIONS.EDIT_ROLES,
    GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS,
    GUILDS_CFG.PERMISSIONS.MANAGE_GOLD,
    GUILDS_CFG.PERMISSIONS.MANAGE_PERKS,
    GUILDS_CFG.PERMISSIONS.DEPOSIT_STORAGE,
    GUILDS_CFG.PERMISSIONS.WITHDRAW_STORAGE,
    GUILDS_CFG.PERMISSIONS.MANAGE_PRISM,
    GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE
  }

  for index, value in ipairs(visiblePermissions) do
    if value == permission then
      return index + 1
    end
  end

  return nil
end

local function getVisibleRankPermissions()
  return {
    GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS,
    GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS,
    GUILDS_CFG.PERMISSIONS.EDIT_ROLES,
    GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS,
    GUILDS_CFG.PERMISSIONS.MANAGE_GOLD,
    GUILDS_CFG.PERMISSIONS.MANAGE_PERKS,
    GUILDS_CFG.PERMISSIONS.DEPOSIT_STORAGE,
    GUILDS_CFG.PERMISSIONS.WITHDRAW_STORAGE,
    GUILDS_CFG.PERMISSIONS.MANAGE_PRISM,
    GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE
  }
end

local function getTempRankForRow(row)
  if not row or not myGuild or not myGuild.tempRanks then
    return nil
  end

  local title = row:getChildByIndex(1):getText():gsub("^%s+", "")
  for _, rank in ipairs(myGuild.tempRanks) do
    if (rank.id ~= 0 and rank.id == row.rankId) or (rank.id == 0 and rank.name == title) then
      return rank
    end
  end

  return nil
end

local function applyRankTitleColor(row, rank)
  if not row or not rank then
    return
  end

  local title = row:getChildByIndex(1)
  if not title then
    return
  end

  if rank.leader then
    title:setColor("green")
  elseif rank.default then
    title:setColor("orange")
  else
    title:setColor("#dfdfdf")
  end
end

local function setupRankTitleCell(row)
  if not row then
    return
  end

  local title = row:getChildByIndex(1)
  if not title then
    return
  end

  local rawText = title:getText():gsub("^%s+", "")
  if rawText ~= "" then
    title:setText("     " .. rawText)
  end

  local refreshColor = function()
    applyRankTitleColor(row, getTempRankForRow(row))
  end

  row.onHoverChange = function()
    refreshColor()
  end
  title.onHoverChange = function()
    refreshColor()
  end
  title.onFocusChange = function()
    refreshColor()
  end
end

function init()
  connect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )  
  ProtocolGame.registerExtendedOpcode(OPCODE, onExtendedOpcode)
  g_keyboard.bindKeyDown("Ctrl+Shift+G", toggle)

  if g_game.isOnline() then
    create()
  end

  NETWORK_ACTION = {
    ["config"] = onGuildsConfig,
    ["general"] = onGeneralGuildData,
    ["members"] = onGuildMembersData,
    ["ranks"] = onGuildRanksData,
    ["inbox"] = onGuildInboxData,
    ["top"] = onTopGuildsData,
    ["message"] = onGuildInboxMessage,
    ["perms"] = onGuildPermissionsUpdate,
    ["memberRank"] = onGuildMemberRankUpdate,
    ["gold"] = onGuildGoldUpdate,
    ["balance"] = onGuildBalanceUpdate,
    ["contribution"] = onContributionUpdate,
    ["premiumBalance"] = onGuildPremiumBalanceUpdate,
    ["dynastieBalance"] = onGuildDynastieTokenBalanceUpdate,
    ["premiumContribution"] = onPremiumContributionUpdate,
    ["level"] = onGuildLevelUpdate,
    ["settings"] = onGuildSettingsUpdate,
    ["topUpdate"] = onTopGuildUpdate,
    ["online"] = onGuildMemberOnline,
    ["offline"] = onGuildMemberOffline,
    ["joined"] = onGuildMemberJoined,
    ["kicked"] = onGuildMemberKicked,
    ["left"] = onLeftGuild,
    ["creatureGuildTitle"] = onCreatureGuildTitle,
    ["removeEmblem"] = onRemoveEmblem,
    ["emblems"] = onUpdateEmblems,
    ["disbanded"] = onGuildDisbanded,
    ["finished"] = onMessageFinished,
    ["newLeader"] = onNewLeader,
    ["updateExp"] = onExpUpdate,
    ["perks"] = onPerkList,
    ["perkBasic"] = onPerkBasic,
    ["perkResult"] = onPerkResult,
    ["storage"] = onGuildStorageData,
    ["quests"] = onGuildQuestData,
    ["achievements"] = onGuildAchievementData,
    ["blackMarket"] = onGuildBlackMarketData,
    ["dynastie"] = onGuildDynastieData,
    ["dynastiePanel"] = onGuildDynastiePanelData,
    ["dynastieAchievements"] = onGuildDynastieAchievementsData,
    ["dynastieEvents"] = onGuildDynastieEventsData,
    ["dynastieBoardOffers"] = onGuildDynastieBoardOffersData,
    ["dynastieBoardAccepted"] = onGuildDynastieBoardAcceptedData,
    ["dynastieQuests"] = onGuildDynastieQuestsData,
    ["prisms"] = onGuildPrismData,
    ["prismView"] = onGuildPrismView,
    ["contributionhistory"] = onContributionHistory,
    ["contributionhistoryReset"] = onContributionHistoryReset,
    ["selfBalance"] = onSelfBalance,
    ["error"] = function(data)
      local result = false
      if data and (string.find(data:lower(), "successfully") or string.find(data:lower(), "invitation sent") or string.find(data:lower(), "join request sent")) then
        result = true
      end
      local box = displayErrorBox(result and tr("Result") or tr("Error"), data)
      box:raise()
    end
  }
end

function terminate()
  disconnect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  g_keyboard.unbindKeyDown("Ctrl+Shift+G")

  if membersPanel and membersPanel.list then
    for _, entry in pairs(membersPanel.list:getChildren()) do
      disconnect(
        entry.status,
        "onHoverChange"
      )
    end
  end
  ProtocolGame.unregisterExtendedOpcode(OPCODE, onExtendedOpcode)

  destroy()
end

function onSelfBalance(data)
  playerBalance = tonumber(data.balance) or 0
  playerPremiumPoints = tonumber(data.premiumPoints) or 0

  if generalPanel and generalPanel.general and generalPanel.general.deposit then
    local depositPanel = generalPanel.general.deposit

    depositPanel.gold:setMaximum(playerBalance)

    if depositPanel.playerBalanceLabel then
      depositPanel.playerBalanceLabel:setText(tr("Your Balance: ") .. comma_value(playerBalance))
      depositPanel.playerBalanceLabel:setTooltip(formatNumber(playerBalance))
    end
  end

  if generalPanel and generalPanel.general and generalPanel.general.premiumDeposit then
    local premiumDepositPanel = generalPanel.general.premiumDeposit

    premiumDepositPanel.points:setMaximum(playerPremiumPoints)

    if premiumDepositPanel.playerPremiumBalanceLabel then
      premiumDepositPanel.playerPremiumBalanceLabel:setText(tr("Your Premium Points: ") .. comma_value(playerPremiumPoints))
      premiumDepositPanel.playerPremiumBalanceLabel:setTooltip(formatNumber(playerPremiumPoints))
    end
  end
end

local function createPrimaryGuildTabs()
  generalPanel = g_ui.loadUI("general")
  if not generalPanel then
    g_logger.error("[Guild Management] Failed to load general.otui")
    return false
  end
  generalPanelBtn = window.tabBar:addTab(tr("General"), generalPanel)
  generalPanelBtn:setWidth(132)
  setupTabButtonIcon(generalPanelBtn, GUILD_TAB_ICON_CLIPS.general)
  setupGeneralTabIcons()

  local status = generalPanel.noGuild:recursiveGetChildById("status")
  for i = 1, #JOIN_STATUS do
    status:addOption(tr(JOIN_STATUS[i]), i)
  end

  local language = generalPanel.noGuild:recursiveGetChildById("language")
  for i = 1, #LANGUAGES do
    language:addOption(tr(LANGUAGES[i]), i)
  end

  membersPanel = g_ui.loadUI("members")
  if not membersPanel then
    g_logger.error("[Guild Management] Failed to load members.otui")
    return false
  end
  membersPanelBtn = window.tabBar:addTab(tr("Members"), membersPanel)
  membersPanelBtn:setWidth(132)
  setupTabButtonIcon(membersPanelBtn, GUILD_TAB_ICON_CLIPS.members)

  ranksPanel = g_ui.loadUI("ranks")
  if not ranksPanel then
    g_logger.error("[Guild Management] Failed to load ranks.otui")
    return false
  end
  ranksPanelBtn = window.tabBar:addTab(tr("Ranks"), ranksPanel)
  ranksPanelBtn:setWidth(132)
  setupTabButtonIcon(ranksPanelBtn, GUILD_TAB_ICON_CLIPS.ranks)

  perksPanel = g_ui.loadUI("perks")
  if not perksPanel then
    g_logger.error("[Guild Management] Failed to load perks.otui")
    return false
  end
  perksPanelBtn = window.tabBar:addTab(tr("Perks"), perksPanel)
  perksPanelBtn:setWidth(132)
  setupTabButtonIcon(perksPanelBtn, GUILD_TAB_ICON_CLIPS.perks)
  return true
end

local function createSecondaryGuildTabs()
  storagePanelBtn = window:recursiveGetChildById("storageSecondaryBtn")
  if not GUILD_FEATURES.storage then
    storagePanel = nil
    if storagePanelBtn then
      storagePanelBtn:hide()
      storagePanelBtn:disable()
    end
  else
    storagePanel = g_ui.loadUI("storage", window.content)
    if not storagePanel then
      g_logger.error("[Guild Management] Failed to load storage.otui")
      return false
    end
    storagePanel:hide()
    if storagePanelBtn then
      setupTabButtonIcon(storagePanelBtn, GUILD_TAB_ICON_CLIPS.storage)
      storagePanelBtn.onClick = showStorageTab
      setStorageTabActive(false)
    end
    local storageProxy = storagePanel:recursiveGetChildById("depositProxyItem")
    if storageProxy then
      storageProxy.onItemChange = function(widget)
        local itemId = widget:getItemId()
        local count = widget:getItemCount()
        if itemId and itemId > 0 and count and count > 0 then
          sendPacket("storageDeposit", { itemId = itemId, count = count })
        end
      end
    end
    renderStorageGrid()
  end

  prismPanelBtn = window:recursiveGetChildById("prismSecondaryBtn")
  if not GUILD_FEATURES.prism then
    prismPanel = nil
    if prismPanelBtn then
      prismPanelBtn:hide()
      prismPanelBtn:disable()
    end
  else
    prismPanel = g_ui.loadUI("prism", window.content)
    if not prismPanel then
      g_logger.error("[Guild Management] Failed to load prism.otui")
      return false
    end
    prismPanel:hide()
    if prismPanelBtn then
      setupTabButtonIcon(prismPanelBtn, GUILD_TAB_ICON_CLIPS.prism)
      prismPanelBtn.onClick = showPrismTab
      setPrismTabActive(false)
    end
    renderPrismCards()
  end

  questsPanelBtn = window:recursiveGetChildById("questsSecondaryBtn")
  if not GUILD_FEATURES.quests then
    questsPanel = nil
    if questsPanelBtn then
      questsPanelBtn:hide()
      questsPanelBtn:disable()
    end
  else
    questsPanel = g_ui.loadUI("quests", window.content)
    if not questsPanel then
      g_logger.error("[Guild Management] Failed to load quests.otui")
      return false
    end
    questsPanel:hide()
    if questsPanelBtn then
      setupTabButtonIcon(questsPanelBtn, GUILD_TAB_ICON_CLIPS.quests)
      questsPanelBtn.onClick = showQuestsTab
      setQuestsTabActive(false)
    end
    renderQuestTab()
  end

  achievementsPanelBtn = window:recursiveGetChildById("achievementsSecondaryBtn")
  if not GUILD_FEATURES.achievements then
    achievementsPanel = nil
    if achievementsPanelBtn then
      achievementsPanelBtn:hide()
      achievementsPanelBtn:disable()
    end
  else
    achievementsPanel = g_ui.loadUI("achievements", window.content)
    if not achievementsPanel then
      g_logger.error("[Guild Management] Failed to load achievements.otui")
      return false
    end
    achievementsPanel:hide()
    if achievementsPanelBtn then
      setupTabButtonIcon(achievementsPanelBtn, GUILD_TAB_ICON_CLIPS.achievements)
      achievementsPanelBtn.onClick = showAchievementsTab
      setAchievementsTabActive(false)
    end
    local achievementsSearchInput = achievementsPanel:recursiveGetChildById("searchInput")
    if achievementsSearchInput then
      achievementsSearchInput.onTextChange = function(widget, text)
        achievementsData.search = tostring(text or widget:getText() or "")
        fetchAchievementsPage(1)
      end
    end
    renderAchievementTab()
  end

  blackMarketPanelBtn = window:recursiveGetChildById("blackMarketSecondaryBtn")
  if not GUILD_FEATURES.blackMarket then
    blackMarketPanel = nil
    if blackMarketPanelBtn then
      blackMarketPanelBtn:hide()
      blackMarketPanelBtn:disable()
    end
  else
    blackMarketPanel = g_ui.loadUI("blackmarket", window.content)
    if not blackMarketPanel then
      g_logger.error("[Guild Management] Failed to load blackmarket.otui")
      return false
    end
    blackMarketPanel:hide()
    if blackMarketPanelBtn then
      setupTabButtonIcon(blackMarketPanelBtn, GUILD_TAB_ICON_CLIPS.blackmarket)
      blackMarketPanelBtn.onClick = showBlackMarketTab
      setBlackMarketTabActive(false)
    end
    renderBlackMarket()
  end

  dynastiePanelBtn = window:recursiveGetChildById("dynastieSecondaryBtn")
  if not GUILD_FEATURES.dynastie then
    dynastiePanel = nil
    if dynastiePanelBtn then
      dynastiePanelBtn:hide()
      dynastiePanelBtn:disable()
    end
    return true
  end

  dynastiePanel = g_ui.loadUI("dynastie", window.content)
  if not dynastiePanel then
    g_logger.error("[Guild Management] Failed to load dynastie.otui")
    return false
  end
  dynastiePanel:hide()
  if dynastiePanelBtn then
    setupTabButtonIcon(dynastiePanelBtn, GUILD_TAB_ICON_CLIPS.dynastie)
    dynastiePanelBtn.onClick = showDynastieTab
    setDynastieTabActive(false)
  end
  renderDynastieCards()
  return true
end

local function createInfoGuildTabs()
  inboxPanel = g_ui.loadUI("inbox")
  if not inboxPanel then
    g_logger.error("[Guild Management] Failed to load inbox.otui")
    return false
  end
  inboxPanelBtn = window.tabBar:addTab(tr("Inbox"), inboxPanel)
  inboxPanelBtn:setWidth(132)
  setupTabButtonIcon(inboxPanelBtn, GUILD_TAB_ICON_CLIPS.inbox)

  topGuildsPanel = g_ui.loadUI("topguilds")
  if not topGuildsPanel then
    g_logger.error("[Guild Management] Failed to load topguilds.otui")
    return false
  end
  topGuildsPanelBtn = window.tabBar:addTab(tr("Top Guilds"), topGuildsPanel)
  topGuildsPanelBtn:setWidth(144)
  setupTabButtonIcon(topGuildsPanelBtn, GUILD_TAB_ICON_CLIPS.top)

  fitAllTabPanels()
  topGuildsPanel.list.onScrollChange = onTopGuildsScroll
  inboxPanel.list.onScrollChange = onGuildInboxScroll
  return true
end

local function createGuildAuxWindows()
  settings = g_ui.displayUI("settings")
  if not settings then
    g_logger.error("[Guild Management] Failed to load settings.otui")
    return false
  end
  settings:hide()

  emblemList = g_ui.displayUI("emblemlist")
  if not emblemList then
    g_logger.error("[Guild Management] Failed to load emblemlist.otui")
    return false
  end
  emblemList:hide()
  return true
end

function create()
  GuildHallLoginPacketGate.ready = false
  GuildHallLoginPacketGate.queue = {}
  if GuildHallLoginPacketGate.event then
    removeEvent(GuildHallLoginPacketGate.event)
    GuildHallLoginPacketGate.event = nil
  end

  g_ui.importStyle("passive_tree")
  g_ui.importStyle("dynastie_manage")
  window = g_ui.displayUI("guild_hall")
  window:setHeight(DEFAULT_WINDOW_HEIGHT)
  guildsButton = modules.client_topmenu.addRightGameToggleButton("guildButton", tr("Guilds"), "/images/topbuttons/guilds", toggle)
  guildsButton:setOn(false)
  window:hide()

  window.tabBar:setContentWidget(window.content)

  if not createPrimaryGuildTabs() then
    return
  end

  if not createSecondaryGuildTabs() then
    return
  end

  if not createInfoGuildTabs() then
    return
  end

  if not createGuildAuxWindows() then
    return
  end

  needUpdate = true

  window.tabBar.onTabChange = function(self, tab)
    stopPrismCountdown()
    stopQuestCountdown()
    stopBlackMarketCountdown()
    stopDynastieCountdown()
    if storagePanel then
      storagePanel:hide()
    end
    if prismPanel then
      prismPanel:hide()
    end
    if questsPanel then
      questsPanel:hide()
    end
    if achievementsPanel then
      achievementsPanel:hide()
    end
    if blackMarketPanel then
      blackMarketPanel:hide()
    end
    if dynastiePanel then
      dynastiePanel:hide()
    end

    setStorageTabActive(false)
    setPrismTabActive(false)
    setQuestsTabActive(false)
    setAchievementsTabActive(false)
    setBlackMarketTabActive(false)
    setDynastieTabActive(false)
    sendPacket("prismViewState", { active = false })
    sendPacket("dynastieViewState", { active = false })
    window.inboxFilterBtn:hide()
    hideContributions()
    fitAllTabPanels()

    if tab == generalPanelBtn and generalPanel then
      generalPanel:show()
      generalPanel:raise()
      fitTabPanel(generalPanel)

    elseif tab == membersPanelBtn and membersPanel then
      membersPanel:show()
      membersPanel:raise()
      fitTabPanel(membersPanel)

    elseif tab == ranksPanelBtn and ranksPanel then
      ranksPanel:show()
      ranksPanel:raise()
      fitTabPanel(ranksPanel)

    elseif tab == perksPanelBtn and perksPanel then
      perksPanel:show()
      perksPanel:raise()
      fitTabPanel(perksPanel)

    elseif tab == inboxPanelBtn and inboxPanel then
      inboxPanel:show()
      inboxPanel:raise()
      fitTabPanel(inboxPanel)

    elseif tab == topGuildsPanelBtn and topGuildsPanel then
      topGuildsPanel:show()
      topGuildsPanel:raise()
      fitTabPanel(topGuildsPanel)
    end

    if not window.balanceBase.locked then
      window.balanceBase:show()
      window.balanceLabel:show()
      if window.balanceIcon then window.balanceIcon:show() end
      window.premiumBalanceBase:show()
      window.premiumBalanceLabel:show()
      if window.premiumBalanceIcon then window.premiumBalanceIcon:show() end
      window.dynastieTokenBase:show()
      window.dynastieTokenLabel:show()
      if window.dynastieTokenIcon then window.dynastieTokenIcon:show() end
    end
    if tab:getText() == tr("Perks") then
      perksPanel.unlockButton:setVisible(false)
      perksPanel.resetButton:setVisible(false)
      if hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_PERKS) then
        perksPanel.unlockButton:setVisible(true)
        perksPanel.resetButton:setVisible(true)
      end
    end

    if tab:getText() == tr("Inbox") then
      window.inboxFilterBtn:show()
      window.balanceBase:hide()
      window.balanceLabel:hide()
      if window.balanceIcon then window.balanceIcon:hide() end
      window.premiumBalanceBase:hide()
      window.premiumBalanceLabel:hide()
      if window.premiumBalanceIcon then window.premiumBalanceIcon:hide() end
      window.dynastieTokenBase:hide()
      window.dynastieTokenLabel:hide()
      if window.dynastieTokenIcon then window.dynastieTokenIcon:hide() end
    end

    if tab:getText() == tr("Members") then
      membersPanel.inviteButton:setVisible(false)
      membersPanel.inviteEdit:setVisible(false)
      membersPanel.inviteEdit:setHeight(1)
      if hasPermission(GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS) then
        membersPanel.inviteButton:setVisible(true)
        membersPanel.inviteEdit:setVisible(true)
        membersPanel.inviteEdit:setHeight(22)
      end
    end
  end

  membersPanel.inviteButton.onClick = function(self)
    local name = membersPanel.inviteEdit:getText()
    if string.len(name) >= 1 and canInvite(name) then
      invitePlayer(name)
    end
  end

  GuildHallLoginPacketGate.event = scheduleEvent(function()
    GuildHallLoginPacketGate.ready = true
    GuildHallLoginPacketGate.event = nil
    local pendingPackets = GuildHallLoginPacketGate.queue
    GuildHallLoginPacketGate.queue = {}
    for _, packet in ipairs(pendingPackets) do
      sendPacket(packet.action, packet.data, true)
    end
  end, GuildHallLoginPacketGate.delay)
end

function destroy()
  extendedOpcodeChunkBuffer = nil
  GuildHallLoginPacketGate.ready = false
  GuildHallLoginPacketGate.queue = {}
  if GuildHallLoginPacketGate.event then
    removeEvent(GuildHallLoginPacketGate.event)
    GuildHallLoginPacketGate.event = nil
  end
  needUpdate = true
  lastTop = 0
  maxTop = 0
  fetchingTop = false
  topGuilds = {}
  guildIdToTop = {}

  lastInbox = 0
  maxInbox = 0
  fetchingInbox = false

  permissions = 0
  myGuild = nil
  storageData = {
    capacity = 10,
    used = 0,
    items = {},
    selectedSlot = 0,
    search = ""
  }
  prismData = {
    capacity = 0,
    used = 0,
    locations = {}
  }
  questsData = {
    daily = {},
    weekend = {},
    monthly = {},
    dailyEndsAt = 0,
    weekendEndsAt = 0,
    monthlyEndsAt = 0
  }
  achievementsData = {
    achievements = {},
    page = 1,
    lastPage = 1,
    pageSize = 18,
    total = 0,
    totalFiltered = 0,
    completed = 0,
    search = ""
  }
  blackMarketData = {
    refreshAt = 0,
    offers = {},
    fetching = false
  }
  dynastieData = {
    used = 0,
    total = 0,
    locations = {},
    ownedLocations = {},
    perks = {},
    defenders = {},
    achievements = {},
    page = 1,
    lastPage = 1,
    totalLocations = 0,
    pageSize = 6
  }
  stopQuestCountdown()
  stopPrismCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()
  closeDynastieManageWindow()

  createEmblem = DEFAULT_CREATE_EMBLEM

  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end

  if window then
    window:destroy()
    window = nil
  end
  if guildsButton then
    guildsButton:destroy()
    guildsButton = nil
  end
  if settings then
    settings:destroy()
    settings = nil
  end

  if emblemList then
    emblemList:destroy()
    emblemList = nil
  end
  
  clearMsgBox()
end

function onExtendedOpcode(protocol, code, buffer)
  if type(buffer) == "string" and #buffer > 0 then
    local chunkType = buffer:sub(1, 1)
    if chunkType == "S" then
      extendedOpcodeChunkBuffer = buffer:sub(2)
      return
    elseif chunkType == "P" then
      if extendedOpcodeChunkBuffer then
        extendedOpcodeChunkBuffer = extendedOpcodeChunkBuffer .. buffer:sub(2)
      end
      return
    elseif chunkType == "E" then
      if extendedOpcodeChunkBuffer then
        buffer = extendedOpcodeChunkBuffer .. buffer:sub(2)
        extendedOpcodeChunkBuffer = nil
      else
        buffer = buffer:sub(2)
      end
    end
  end

  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )

  if not json_status then
    g_logger.error("[Guild Management] JSON error: " .. json_data)
    return false
  end

  if type(json_data) ~= "table" then
    g_logger.error("[Guild Management] Invalid opcode payload type: " .. type(json_data))
    return false
  end

  local action = json_data.action
  local data = json_data.data
  if NETWORK_ACTION[action] then
    local ok, err = pcall(NETWORK_ACTION[action], data)
    if not ok then
      g_logger.error("[Guild Management] Action error (" .. tostring(action) .. "): " .. tostring(err))
      return false
    end
  end
end

function sendPacket(action, data, force)
  if not force and not GuildHallLoginPacketGate.ready then
    table.insert(GuildHallLoginPacketGate.queue, { action = action, data = data })
    return
  end

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(OPCODE, json.encode({action = action, data = data}))
  end
end

function onGuildsConfig(data)
  GUILDS_CFG = data

  MESSAGE_STYLES = {}

  local messageStylePairs = {
    {"JOIN_INVITATION", "InviteInbox"},
    {"KICKED_OUT", "KickedInbox"},
    {"JOIN_REQUEST", "RequestInbox"},
    {"MEMBER_JOINED", "JoinedInbox"},
    {"MEMBER_LEFT", "LeftInbox"},
    {"GOLD_DEPOSIT", "DepositInbox"},
    {"STORAGE_DEPOSIT", "StorageDepositInbox"},
    {"STORAGE_WITHDRAW", "StorageWithdrawInbox"},
    {"PRISM_ATTACK", "PrismAttackInbox"},
    {"PRISM_COLLECT", "PrismCollectInbox"},
    {"PRISM_STOLEN", "PrismStolenInbox"},
    {"QUEST_REWARD", "QuestRewardInbox"},
    {"BLACK_MARKET_PURCHASE", "BlackMarketInbox"},
    {"DYNASTIE_COLLECT", "DynastieCollectInbox"},
    {"DYNASTIE_ATTACK", "DynastieAttackInbox"}
  }

  for _, pair in ipairs(messageStylePairs) do
    local messageType = (GUILDS_CFG.MESSAGE_TYPES and GUILDS_CFG.MESSAGE_TYPES[pair[1]]) or DEFAULT_MESSAGE_TYPES[pair[1]]
    if messageType then
      MESSAGE_STYLES[messageType] = pair[2]
    end
  end

  for key, messageType in pairs(DEFAULT_MESSAGE_TYPES) do
    if not MESSAGE_STYLES[messageType] then
      for _, pair in ipairs(messageStylePairs) do
        if pair[1] == key then
          MESSAGE_STYLES[messageType] = pair[2]
          break
        end
      end
    end
  end
end

function onGeneralGuildData(data)
  waitingGuildFetch = false
  if not data then
    if membersPanelBtn then membersPanelBtn:hide() end
    if ranksPanelBtn then ranksPanelBtn:hide() end
    if perksPanelBtn then perksPanelBtn:hide() end
    if storagePanelBtn then storagePanelBtn:hide() end
    if prismPanelBtn then prismPanelBtn:hide() end
    if questsPanelBtn then questsPanelBtn:hide() end
    if achievementsPanelBtn then achievementsPanelBtn:hide() end
    if blackMarketPanelBtn then blackMarketPanelBtn:hide() end
    if dynastiePanelBtn then dynastiePanelBtn:hide() end
    if inboxPanelBtn then inboxPanelBtn:show() end
    if topGuildsPanelBtn then topGuildsPanelBtn:show() end

    membersPanelBtn:disable()
    ranksPanelBtn:disable()
    perksPanelBtn:disable()
    storagePanelBtn:disable()
    if prismPanelBtn then prismPanelBtn:disable() end
    if questsPanelBtn then questsPanelBtn:disable() end
    if achievementsPanelBtn then achievementsPanelBtn:disable() end
    if blackMarketPanelBtn then blackMarketPanelBtn:disable() end
    if dynastiePanelBtn then dynastiePanelBtn:disable() end
    if inboxPanelBtn then inboxPanelBtn:enable() end
    if topGuildsPanelBtn then topGuildsPanelBtn:enable() end

    generalPanel.noGuild:show()
    local createEmblemWidget = generalPanel.noGuild:recursiveGetChildById("emblemPreview")
    if createEmblemWidget then
      setGuildEmblem(createEmblemWidget, createEmblem)
    end
    generalPanel.general:hide()
    window.leaveBtn:hide()
    window.settingsBtn:hide()
    window.inboxFilterBtn:hide()
    if storagePanel then
      local depositButton = storagePanel:recursiveGetChildById("depositItemsButton")
      local withdrawButton = storagePanel:recursiveGetChildById("withdrawItemsButton")
      if depositButton then depositButton:setVisible(false) end
      if withdrawButton then withdrawButton:setVisible(false) end
    end

    window.balanceBase:setVisible(false)
    window.balanceLabel:setVisible(false)
    if window.balanceIcon then window.balanceIcon:setVisible(false) end
    window.premiumBalanceBase:setVisible(false)
    window.premiumBalanceLabel:setVisible(false)
    if window.premiumBalanceIcon then window.premiumBalanceIcon:setVisible(false) end
    window.dynastieTokenBase:setVisible(false)
    window.dynastieTokenLabel:setVisible(false)
    if window.dynastieTokenIcon then window.dynastieTokenIcon:setVisible(false) end
    window.balanceBase.locked = true
    applyLocalPlayerGuildTitle("", 0)
  else
    if membersPanelBtn then membersPanelBtn:show() end
    if ranksPanelBtn then ranksPanelBtn:show() end
    if perksPanelBtn then perksPanelBtn:show() end
    if storagePanelBtn then storagePanelBtn:show() end
    if prismPanelBtn then prismPanelBtn:show() end
    if questsPanelBtn then questsPanelBtn:show() end
    if achievementsPanelBtn then achievementsPanelBtn:show() end
    if blackMarketPanelBtn then blackMarketPanelBtn:show() end
    if dynastiePanelBtn then dynastiePanelBtn:show() end
    if inboxPanelBtn then inboxPanelBtn:show() end
    if topGuildsPanelBtn then topGuildsPanelBtn:show() end

    membersPanelBtn:enable()
    ranksPanelBtn:enable()
    perksPanelBtn:enable()
    storagePanelBtn:enable()
    if prismPanelBtn then prismPanelBtn:enable() end
    if questsPanelBtn then questsPanelBtn:enable() end
    if achievementsPanelBtn then achievementsPanelBtn:enable() end
    if blackMarketPanelBtn then blackMarketPanelBtn:enable() end
    if dynastiePanelBtn then dynastiePanelBtn:enable() end
    if inboxPanelBtn then inboxPanelBtn:enable() end
    if topGuildsPanelBtn then topGuildsPanelBtn:enable() end

    window.balanceBase:setVisible(true)
    window.balanceLabel:setVisible(true)
    if window.balanceIcon then window.balanceIcon:setVisible(true) end
    window.premiumBalanceBase:setVisible(true)
    window.premiumBalanceLabel:setVisible(true)
    if window.premiumBalanceIcon then window.premiumBalanceIcon:setVisible(true) end
    window.dynastieTokenBase:setVisible(true)
    window.dynastieTokenLabel:setVisible(true)
    if window.dynastieTokenIcon then window.dynastieTokenIcon:setVisible(true) end
    window.balanceBase.locked = false

    generalPanel.noGuild:hide()
    generalPanel.general:show()

    permissions = data.permissions
    myGuild = data
    applyLocalPlayerGuildTitle(data.name, data.leader == g_game.getCharacterName() and 3 or 1)

    ranksPanelBtn:setEnabled(hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_ROLES))
    window.settingsBtn:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS))
    generalPanel.general.stats.withdrawButton:setVisible(false)
    if storagePanel then
      local depositButton = storagePanel:recursiveGetChildById("depositItemsButton")
      local withdrawButton = storagePanel:recursiveGetChildById("withdrawItemsButton")
      if depositButton then depositButton:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.DEPOSIT_STORAGE)) end
      if withdrawButton then withdrawButton:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.WITHDRAW_STORAGE)) end
    end
    window.leaveBtn:setText(myGuild.leader == g_game.getCharacterName() and tr("Disband") or tr("Leave"))
    window.leaveBtn:show()
    generalPanel.general.guildName:setText(data.name)

    for key, value in pairs(data) do
      if not table.contains({"emblem", "permissions", "exp", "expNew"}, key) then
        local w = generalPanel.general:recursiveGetChildById(key)
        if w then
          if key == "members" then
            w:setText(value[1] .. " / " .. value[2])
          elseif key == "storage" or key == "prisms" or key == "dynasties" or key == "achievements" then
            w:setText((tonumber(value[1]) or 0) .. " / " .. (tonumber(value[2]) or 0))
          elseif key == "kills" then
            w:setText(comma_value(value))
          elseif key == "language" then
            w:setText(tr(LANGUAGES[value]))
          elseif key == "joinStatus" then
            w:setText(tr(JOIN_STATUS[value]))
          elseif key == "reqLevel" then
            w:setText((value > 0 and value or tr("None")))
          elseif key == "contribution" then
            w:setText(comma_value(value))
            generalPanel.general.stats.contributionBase:setTooltip(formatNumber(value))
          elseif key == "premiumContribution" then
            w:setText(comma_value(value))
            generalPanel.general.stats.premiumContributionBase:setTooltip(formatNumber(value))
          else
            w:setText(value)
          end
        end
      end
    end

    setGuildEmblem(generalPanel.general:recursiveGetChildById("emblem"), data.emblem)

    local InfoBase = generalPanel.general:recursiveGetChildById("InfoBase")

    generalPanel.general.stats.levelBase.level:setText(data["expNew"].level)
    updateGuildExpBar(data["expNew"].exp, data["expNew"].base)

    guildBalance = data["balance"]
    myGuild.premiumBalance = tonumber(data["premiumBalance"]) or 0
    myGuild.dynastieBalance = tonumber(data["dynastieBalance"]) or 0
    window.balanceBase:setText(comma_value(data["balance"]))
    window.balanceBase:setTooltip(data["balance"] >= 1000 and formatNumber(data["balance"]) or "")
    generalPanel.general.stats.goldBase.gold:setText(comma_value(data["balance"]))

    window.balanceBase.balanceValue = data["balance"]
    window.premiumBalanceBase:setText(comma_value(myGuild.premiumBalance or 0))
    window.premiumBalanceBase:setTooltip(formatNumber(myGuild.premiumBalance or 0))
    window.dynastieTokenBase:setText(comma_value(myGuild.dynastieBalance or 0))
    window.dynastieTokenBase:setTooltip(formatNumber(myGuild.dynastieBalance or 0))

    generalPanel.general.stats:recursiveGetChildById("nextLevel"):setText(data.exp[2])

    for i = 1, #topGuilds do
      local guild = topGuilds[i]
      local entry = topGuildsPanel.list[tostring(guild.id)]
      local requestBtn = entry.info:recursiveGetChildById("request")
      requestBtn:setVisible(false)
    end
  end
end

function onGuildMembersData(data)
  if not myGuild then
    return
  end
  myGuild.membersList = data
  membersPanel.list:destroyChildren()
  for i, member in ipairs(data) do
    local entry = g_ui.createWidget("EntryPanel", membersPanel.list)
    entry:setId(member.name)
    if member.name == g_game.getCharacterName() then
      entry:setOn(true)
    end
    entry.position:setText(i .. ".")
    local vocationData = VocationIcon[member.voc]
    entry.vocation:setImageSource("/images/guild_hall/" .. ((vocationData and vocationData.icon) or "unknown"))
    entry.vocation:setTooltip((vocationData and vocationData.name) or "Unknown")
    entry.name:setText(member.name)
    entry.options.chat:setVisible(member.name ~= g_game.getCharacterName() and member.online)
    entry.options.chat.onClick = function()
      g_game.openPrivateChannel(member.name)
    end
    entry.rank:setText(member.rank)
    entry.level:setText(member.level)
    entry.level:setColor("white")
    if tonumber(member.level) >= maxLevel then
      entry.level:setText(member.proficiencyLevel)
      entry.level:setColor("yellow")
    end

    entry.status.online = member.online
    entry.status.last = member.last
    entry.data = member
    entry.status:setTooltip(member.online and tr("Online") or tr("Offline for %s", getOfflineTime(member.last)))
    entry.online:setColor("red")
    if member.online then
      entry.online:setColor("green")
    end

    entry.online:setText(member.online and tr("Online") or tr("%s", getOfflineTime(member.last)))
    connect(
      entry.status,
      "onHoverChange",
      function(w, hover)
        if hover and w.last then
          w:getParent().online:setText(w.online and tr("Online") or tr("%s", getOfflineTime(w.last)))
          w:getParent().online:setColor("red")
          if w.online then
            w:getParent().online:setColor("green")
          end

          w:setTooltip(w.online and tr("Online") or tr("Offline for %s", getOfflineTime(w.last)))
        end
      end
    )
    local canOpenMenu = member.name ~= g_game.getCharacterName() and canKick(member.name)
    entry.options.menu:setVisible(canOpenMenu)
    if canOpenMenu then
      entry.options.menu.onClick = function()
        createMemberMenu(i)
      end
    else
      entry.options.menu.onClick = nil
    end
  end
end

function onGuildRanksData(data)
  if not myGuild then
    return
  end
  myGuild.ranks = {}
  myGuild.tempRanks = {}
  for k, v in pairs(data) do
    myGuild.ranks[k] = cloneTable(v)
    myGuild.tempRanks[k] = cloneTable(v)
  end

  for _, rank in ipairs(myGuild.ranks) do
    if type(rank.leader) == "number" then
      rank.leader = rank.leader == 1
    end
    if type(rank.default) == "number" then
      rank.default = rank.default == 1
    end
    if type(rank.removed) == "number" then
      rank.removed = rank.removed == 1
    end
  end

  for _, rank in ipairs(myGuild.tempRanks) do
    if type(rank.leader) == "number" then
      rank.leader = rank.leader == 1
    end
    if type(rank.default) == "number" then
      rank.default = rank.default == 1
    end
    if type(rank.removed) == "number" then
      rank.removed = rank.removed == 1
    end
  end

  ranksPanel.ranksTable:clearData()
  if not ranksPanel.ranksTable.dataSpace then
    ranksPanel.ranksTable:setTableData(ranksPanel.ranksTableData)
  end
  for _, rank in ipairs(data) do
    if not rank.removed then
      local row = 
        ranksPanel.ranksTable:addRow(
        {
          {style = "RankTitleColumn", text = "   " .. rank.name},
          {
            checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS),
            imageOffset = "28 3",
            permission = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS
          },

          {
            checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS),
            imageOffset = "26 3",
            permission = GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS
          },

          {checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.EDIT_ROLES), permission = GUILDS_CFG.PERMISSIONS.EDIT_ROLES},
          
          {
            checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS),
            imageOffset = "23 3",
            permission = GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS
          },

          {checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.MANAGE_GOLD), permission = GUILDS_CFG.PERMISSIONS.MANAGE_GOLD},

          {checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.MANAGE_PERKS), permission = GUILDS_CFG.PERMISSIONS.MANAGE_PERKS},

          {
            checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.DEPOSIT_STORAGE),
            permission = GUILDS_CFG.PERMISSIONS.DEPOSIT_STORAGE
          },
          {
            checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.WITHDRAW_STORAGE),
            permission = GUILDS_CFG.PERMISSIONS.WITHDRAW_STORAGE
          },
          {
            checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.MANAGE_PRISM),
            permission = GUILDS_CFG.PERMISSIONS.MANAGE_PRISM
          },
          {
            checked = rankHasPermission(rank.permissions, GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE),
            permission = GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE
          },
        },
        nil,
        {
          rankId = rank.id
        }
      )

      if row then
        row.rankId = rank.id
        setupRankTitleCell(row)
        local isLeader = false
  
        if rank.leader then
          isLeader = true
          for _, permission in ipairs(getVisibleRankPermissions()) do
            local childIndex = getPermissionColumnIndex(permission)
            if childIndex and row:getChildByIndex(childIndex) then
              row:getChildByIndex(childIndex):disable()
            end
          end
        end
        applyRankTitleColor(row, rank)
  
        row:getChildByIndex(1):setPhantom(false)
        row:getChildByIndex(1):setTooltip(tr"Double click to edit title")
        row:getChildByIndex(1).onDoubleClick = editRankTitle

        for _, permission in ipairs(getVisibleRankPermissions()) do
          local checkbox = row:getChildByIndex(getPermissionColumnIndex(permission))
          if checkbox then
            checkbox:setChecked(rankHasPermission(rank.permissions, permission))
          end
        end
  
        if not isLeader then
          for _, permission in ipairs(getVisibleRankPermissions()) do
            local childIndex = getPermissionColumnIndex(permission)
            if childIndex and row:getChildByIndex(childIndex) then
              row:getChildByIndex(childIndex).onCheckChange = onRankPermissionCheck
            end
          end
        end
      end
    end
  end

  ranksPanel.ranksTable.onSelectionChange = onRankRowSelected
end

function onTopGuildsData(data)
  fetchingTop = false
  if not topGuildsPanel or not topGuildsPanel.list then
    return
  end
  if data.new then
    topGuildsPanel.list.onScrollChange = nil
    topGuildsPanel.list:destroyChildren()
    lastTop = 0
    topGuilds = {}
  end

  for i = 1, #data.top do
    local guild = data.top[i]
    table.insert(topGuilds, guild)
    guildIdToTop[guild.id] = i + lastTop
    local entry = g_ui.createWidget("GuildEntry", topGuildsPanel.list)
    entry:setId(guild.id)
    entry.guildName:setText(guild.name)
    setGuildEmblem(entry.logo, guild.emblem)
    entry.position:setText(i + lastTop)
    entry.info:recursiveGetChildById("leader"):setText(guild.leader)
    entry.info:recursiveGetChildById("level"):setText(guild.level)
    entry.info:recursiveGetChildById("members"):setText(guild.members[1] .. " / " .. guild.members[2])
    entry.info:recursiveGetChildById("avgLevel"):setText(guild.avgLevel)
    entry.info:recursiveGetChildById("levels"):setText(guild.total)
    entry.info:recursiveGetChildById("language"):setText(tr(LANGUAGES[guild.language]))
    entry.info:recursiveGetChildById("status"):setText(tr(JOIN_STATUS[guild.status]))
    entry.info:recursiveGetChildById("reqLevel"):setText(guild.reqLevel)
    entry.info:recursiveGetChildById("prisms"):setText((guild.prisms and (guild.prisms[1] .. " / " .. guild.prisms[2])) or "0 / 0")
    entry.info:recursiveGetChildById("achievements"):setText((guild.achievements and (guild.achievements[1] .. " / " .. guild.achievements[2])) or "0 / 0")
    local requestBtn = entry.info:recursiveGetChildById("request")
    requestBtn:setVisible(not myGuild and guild.status == 1)
    if guild.status == 1 then
      requestBtn.onClick = requestJoin
      requestBtn.guild = guild.id
    end
  end

  lastTop = lastTop + #data.top
  maxTop = data.last

  if data.new then
    topGuildsPanel.list.onScrollChange = onTopGuildsScroll
  end
end

function requestJoin(btn)
  local guildId = btn.guild
  sendPacket("request", guildId)
end

function onTopGuildsScroll(scrollarea, virtualOffset)
  if lastTop < maxTop then
    local maximum = scrollarea.verticalScrollBar:getMaximum()
    local value = virtualOffset.y
    if value + 120 >= maximum and not fetchingTop then
      fetchingTop = true
      sendPacket("top", lastTop)
    end
  end
end

function onGuildInboxData(data)
  fetchingInbox = false
  if not inboxPanel or not inboxPanel.list then
    return
  end
  if data.new or lastInbox == 0 then
    inboxPanel.list:destroyChildren()
    lastInbox = 0
  end
  lastInbox = data.new and data.size or (lastInbox + data.size)
  maxInbox = data.last
  for i = 1, #data.inbox do
    if not inboxPanel.list:getChildById("msg" .. data.inbox[i].id) then
      local entry = createMessageWidget(data.inbox[i])
      if entry then
      inboxPanel.list:addChild(entry)
      end
    end
  end
end

function onGuildInboxScroll(scrollarea, virtualOffset)
  if lastInbox < maxInbox then
    local maximum = scrollarea.verticalScrollBar:getMaximum()
    local value = virtualOffset.y
    if value + 120 >= maximum and not fetchingInbox then
      fetchingInbox = true
      sendPacket("inbox", lastInbox)
    end
  end
end

function onGuildInboxMessage(message)
  if inboxPanel.list:getChildById("msg" .. message.id) then
    return
  end
  local entry = createMessageWidget(message)
  if entry then
    inboxPanel.list:insertChild(1, entry)
    maxInbox = maxInbox + 1
  end
end

function createMessageWidget(message)
  local messageTypes = (GUILDS_CFG and GUILDS_CFG.MESSAGE_TYPES) or DEFAULT_MESSAGE_TYPES

  if not MESSAGE_STYLES[message.type] then
    g_logger.info("[Guild] invalid inbox message type " .. message.type)
    return
  end

  local inboxEntry = g_ui.createWidget(MESSAGE_STYLES[message.type])
  inboxEntry:setId("msg" .. message.id)
  inboxEntry.date:setText(os.date("%X %x", message.date))
  inboxEntry.msgId = message.id
  inboxEntry.type = message.type
  inboxEntry.targetId = message.targetId
  inboxEntry.guildId = message.guildId
  inboxEntry.date = message.date
  if message.type == messageTypes.JOIN_INVITATION or message.type == messageTypes.JOIN_REQUEST then
    if message.finished == 1 then
      inboxEntry.acceptBtn:disable()
      inboxEntry.rejectBtn:disable()
      inboxEntry:setHeight(95)
    else
      inboxEntry.acceptBtn.onClick = acceptMessage
      inboxEntry.rejectBtn.onClick = rejectMessage
      inboxEntry:setHeight(116)
    end
  end

  local inboxText = generateInboxText(message.text, "#FFFFFF", "#FFAA00")

  if message.type == messageTypes.GOLD_DEPOSIT then
    local inboxValue = tonumber(inboxText[3])

    if inboxValue then
      inboxText[3] = comma_value(tonumber(inboxText[3]))
      inboxEntry.panel:setTooltip(formatNumber(inboxValue))
    end
  end

  inboxEntry.panel.text:setColoredText(inboxText)
  inboxEntry:setVisible(false)
  if window.inboxFilterBtn:isChecked() then
    if message.type == messageTypes.JOIN_INVITATION or message.type == messageTypes.JOIN_REQUEST then
      inboxEntry:setVisible(true)
    end
  else
    inboxEntry:setVisible(true)
  end
  return inboxEntry
end

function inboxRequestFilter(state)
    local messageTypes = (GUILDS_CFG and GUILDS_CFG.MESSAGE_TYPES) or DEFAULT_MESSAGE_TYPES
    local childList = inboxPanel.list:getChildren()

    window.inboxFilterBtn:setChecked(state)

    if state then 
      for _, widget in pairs(childList) do
        widget:setVisible(false)
        if widget.type == messageTypes.JOIN_INVITATION or widget.type == messageTypes.JOIN_REQUEST then
          widget:setVisible(true)
        end
      end
      return
    end

    for _, widget in pairs(childList) do
      widget:setVisible(true)
    end
end

function acceptMessage(button)
  local parent = button:getParent()
  local targetId = parent.targetId
  local guildId = parent.guildId
  sendPacket("accept", {id = parent.msgId, type = parent.type, targetId = targetId, guildId = guildId})
end

function rejectMessage(button)
  local parent = button:getParent()
  local targetId = parent.targetId
  local guildId = parent.guildId
  sendPacket("reject", {id = parent.msgId, type = parent.type, targetId = targetId, guildId = guildId})
end

function onGuildGoldUpdate(data)
  updateGoldInfo(data)
end

function onGuildBalanceUpdate(data)
  updateBalanceInfo(data)
end

function onContributionUpdate(data)
  if type(data) == "number" then
    myGuild.gold = data
    generalPanel.general.stats:recursiveGetChildById("contribution"):setText(comma_value(data))
    generalPanel.general.stats.contributionBase:setTooltip(formatNumber(data))
  else
    if not myGuild or not myGuild.membersList then
      return
    end

    if data.historyEntry then
      if not contributionHistory then
        contributionHistory = {}
      end

      if not contributionHistory[data.name] then
        contributionHistory[data.name] = { name = data.name, history = {}, historyExp = {}}
      end

      if data.historyEntry.currency == 1 then
          local history = contributionHistory[data.name].history
          local found = false
          
          for i, entry in ipairs(history) do
              if entry.dateText == data.historyEntry.dateText then
                  history[i].value = history[i].value + data.historyEntry.value
                  history[i].date = data.historyEntry.date
                  found = true
                  break
              end
          end
          
          if not found then
              table.insert(history, data.historyEntry)
          end
        
          table.sort(history, function(value1, value2) return value1.date > value2.date end)
      else
          local historyExp = contributionHistory[data.name].historyExp
          local found = false
          

          for i, entry in ipairs(historyExp) do
              if entry.dateText == data.historyEntry.dateText then
                  historyExp[i].value = historyExp[i].value + data.historyEntry.value
                  historyExp[i].date = data.historyEntry.date
                  found = true
                  break
              end
          end
          
          if not found then
              table.insert(historyExp, data.historyEntry)
          end
          
          table.sort(historyExp, function(value1, value2) return value1.date > value2.date end)
      end
    end

    for _, m in ipairs(myGuild.membersList) do
      if m.name == data.name then
        m.contribution = data.contribution
        break
      end
    end
  end
end

function onPremiumContributionUpdate(data)
  if type(data) ~= "number" then
    return
  end

  if myGuild then
    myGuild.premiumContribution = data
  end

  generalPanel.general.stats:recursiveGetChildById("premiumContribution"):setText(comma_value(data))
  generalPanel.general.stats.premiumContributionBase:setTooltip(formatNumber(data))
end

function onGuildLevelUpdate(data)
  myGuild.level = data.level
  myGuild.members = data.members
  myGuild.gold = data.gold
  if data.premiumContribution ~= nil then
    myGuild.premiumContribution = data.premiumContribution
    generalPanel.general.stats:recursiveGetChildById("premiumContribution"):setText(comma_value(data.premiumContribution))
    generalPanel.general.stats.premiumContributionBase:setTooltip(formatNumber(data.premiumContribution))
  end
  myGuild.next = data.next
  generalPanel.general.stats:recursiveGetChildById("level"):setText(data.level)
  generalPanel.general:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])
  updateGoldInfo(data)

  perksPanel.topBar.guildLevel:setText("Lv " .. data.level)

end

function updateGoldInfo(data)
  local guildExp = generalPanel.general.stats.guildExp
  updateGuildExpBar(data.exp, data.next)

  local need = math.max(0, data.next - data.exp)
  guildExp:setBackgroundColor("#28221d")

  if need == 0 then
    guildExp:setTooltip(tr("Guild has enough exp to level up."))
    if hasPermission(GUILDS_CFG.PERMISSIONS.MANAGE_GOLD) then
      generalPanel.general.stats.levelUp:enable()
    end
  else
    guildExp:setTooltip(tr("Gain at least %d exp to level up.", need))
    generalPanel.general.stats.levelUp:disable()
  end

  generalPanel.general.stats:recursiveGetChildById("nextLevel"):setText(data.next)
end

function updateBalanceInfo(data)
  guildBalance = data.balance
  generalPanel.general.stats.goldBase.gold:setText(data.balance)
  window.balanceBase:setText(comma_value(data.balance))
  window.balanceBase:setTooltip(formatNumber(data.balance))
  window.balanceBase.balanceValue = data.balance
end

function onGuildPremiumBalanceUpdate(data)
  if myGuild then
    myGuild.premiumBalance = tonumber(data.balance) or 0
  end

  if window and window.premiumBalanceBase then
    window.premiumBalanceBase:setText(comma_value(tonumber(data.balance) or 0))
    window.premiumBalanceBase:setTooltip(formatNumber(tonumber(data.balance) or 0))
  end
end

function onGuildDynastieTokenBalanceUpdate(data)
  if myGuild then
    myGuild.dynastieBalance = tonumber(data.balance) or 0
  end

  if window and window.dynastieTokenBase then
    window.dynastieTokenBase:setText(comma_value(tonumber(data.balance) or 0))
    window.dynastieTokenBase:setTooltip(formatNumber(tonumber(data.balance) or 0))
  end
  if dynastieManageWindow then
    local dynastieFooterTokenBase = dynastieManageWindow:recursiveGetChildById("dynastieFooterTokenBase")
    if dynastieFooterTokenBase then
      dynastieFooterTokenBase:setText(comma_value(tonumber(data.balance) or 0))
      dynastieFooterTokenBase:setTooltip(formatNumber(tonumber(data.balance) or 0))
    end
  end
end

function onGuildSettingsUpdate(data)
  generalPanel.general:recursiveGetChildById("joinStatus"):setText(tr(JOIN_STATUS[data.status]))
  generalPanel.general:recursiveGetChildById("language"):setText(tr(LANGUAGES[data.language]))
  generalPanel.general:recursiveGetChildById("reqLevel"):setText(data.reqLevel)
  generalPanel.general:recursiveGetChildById("motd"):setText(data.motd)

  setGuildEmblem(generalPanel.general:recursiveGetChildById("emblem"), data.emblem, true)

  myGuild.joinStatus = data.status
  myGuild.language = data.language
  myGuild.reqLevel = data.reqLevel
  myGuild.motd = data.motd
  myGuild.emblem = data.emblem
  myGuild.tempEmblem = data.emblem
end

function getTopGuildByGID(guildId)
  return topGuilds[guildIdToTop[guildId]]
end

function onTopGuildUpdate(data)
  local widget = topGuildsPanel.list[tostring(data.id)]
  if not widget then
    return
  end

  local guild = getTopGuildByGID(data.id)
  if guild then
    for k, v in pairs(data) do
      guild[k] = v
    end
  end

  if data.members then
    widget.info:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])
    local requestBtn = widget.info:recursiveGetChildById("request")
    if requestBtn:isVisible() and data.members[1] < data.members[2] then
      if guild then
        requestBtn:setVisible(not myGuild and guild.status == 1)
      end
    elseif data.members[1] >= data.members[2] then
      requestBtn:setVisible(false)
    end
  end

  if data.emblem then
    setGuildEmblem(widget.logo, data.emblem, true)

    widget.info:recursiveGetChildById("language"):setText(tr(LANGUAGES[data.language]))
    widget.info:recursiveGetChildById("status"):setText(tr(JOIN_STATUS[data.status]))
    widget.info:recursiveGetChildById("request"):setVisible(not myGuild and data.status == 1)
    widget.info:recursiveGetChildById("reqLevel"):setText(data.reqLevel)
  end

  if data.level then
    widget.info:recursiveGetChildById("level"):setText(data.level)
  end

  if data.avgLevel then
    widget.info:recursiveGetChildById("avgLevel"):setText(data.avgLevel)
    widget.info:recursiveGetChildById("levels"):setText(data.levels)
  end

  if data.prisms then
    widget.info:recursiveGetChildById("prisms"):setText(data.prisms[1] .. " / " .. data.prisms[2])
  end

  if data.achievements then
    widget.info:recursiveGetChildById("achievements"):setText(data.achievements[1] .. " / " .. data.achievements[2])
  end
end

function onGuildMemberOnline(name)
  local widget = membersPanel.list[name]
  if not widget then
    return
  end

  widget.options.chat:show()
  widget.options.chat.onClick = function()
    g_game.openPrivateChannel(name)
  end
  widget.status.online = true
  widget.status.last = os.time()
  widget.status:setTooltip(tr("Online"))
end

function onGuildMemberOffline(name)
  local widget = membersPanel.list[name]
  if not widget then
    return
  end

  widget.options.chat:hide()
  widget.options.chat.onClick = nil
  widget.status.online = false
  widget.status.last = os.time()
  widget.status:setTooltip(tr("Offline for %s", getOfflineTime(os.time())))
end

function invitePlayer(name)
  if not hasPermission(GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS) then
    return
  end

  sendPacket("invite", name)
end

function kickPlayer(name)
  if not hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS) then
    return
  end

  sendPacket("kick", name)
end

function onGuildMemberKicked(data)
  local widget = membersPanel.list[data.name]
  if not widget then
    return
  end

  for i = 1, #myGuild.membersList do
    if myGuild.membersList[i].name == data.name then
      table.remove(myGuild.membersList, i)
      break
    end
  end

  myGuild.total = data.levels
  myGuild.members = data.members

  generalPanel.general:recursiveGetChildById("total"):setText(data.levels)
  generalPanel.general:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])

  membersPanel.list:destroyChildren()
  onGuildMembersData(myGuild.membersList)
end

function onGuildMemberJoined(data)
  table.insert(myGuild.membersList, data.member)

  myGuild.total = data.levels
  myGuild.members = data.members

  generalPanel.general:recursiveGetChildById("total"):setText(data.levels)
  generalPanel.general:recursiveGetChildById("members"):setText(data.members[1] .. " / " .. data.members[2])

  membersPanel.list:destroyChildren()
  onGuildMembersData(myGuild.membersList)
end

function onLeftGuild()
  myGuild = nil
  permissions = 0
  storageData = {
    capacity = 10,
    used = 0,
    items = {},
    selectedSlot = 0,
    search = ""
  }
  prismData = {
    capacity = 0,
    used = 0,
    locations = {},
    page = 1,
    lastPage = 1,
    total = 0,
    pageSize = 10
  }
  questsData = {
    daily = {},
    weekend = {},
    monthly = {},
    dailyEndsAt = 0,
    weekendEndsAt = 0,
    monthlyEndsAt = 0
  }
  achievementsData = {
    achievements = {},
    page = 1,
    lastPage = 1,
    pageSize = 18,
    total = 0,
    totalFiltered = 0,
    completed = 0,
    search = ""
  }
  blackMarketData = {
    refreshAt = 0,
    offers = {},
    fetching = false
  }
  dynastieData = {
    used = 0,
    total = 0,
    locations = {},
    ownedLocations = {},
    perks = {},
    defenders = {},
    achievements = {},
    page = 1,
    lastPage = 1,
    totalLocations = 0,
    pageSize = 6
  }
  stopQuestCountdown()
  stopPrismCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()
  closeDynastieManageWindow()

  membersPanel.list:destroyChildren()

  window.balanceBase:setVisible(false)
  window.balanceLabel:setVisible(false)
  if window.balanceIcon then window.balanceIcon:setVisible(false) end
  window.premiumBalanceBase:setVisible(false)
  window.premiumBalanceLabel:setVisible(false)
  if window.premiumBalanceIcon then window.premiumBalanceIcon:setVisible(false) end
  window.dynastieTokenBase:setVisible(false)
  window.dynastieTokenLabel:setVisible(false)
  if window.dynastieTokenIcon then window.dynastieTokenIcon:setVisible(false) end
  window.balanceBase.locked = true
  guildBalance = 0

  if membersPanel then membersPanel:hide() end
  if ranksPanel then ranksPanel:hide() end
  if perksPanel then perksPanel:hide() end
  if storagePanel then storagePanel:hide() end
  if prismPanel then prismPanel:hide() end
  if questsPanel then questsPanel:hide() end
  if achievementsPanel then achievementsPanel:hide() end
  if blackMarketPanel then blackMarketPanel:hide() end
  if dynastiePanel then dynastiePanel:hide() end
  if inboxPanel then inboxPanel:hide() end
  if topGuildsPanel then topGuildsPanel:hide() end
  clearMainGuildTabSelection()
  clearSecondaryGuildTabSelection()
  onGeneralGuildData(nil)
  window.tabBar:selectTab(generalPanelBtn)

  for i = 1, #topGuilds do
    local guild = topGuilds[i]
    local entry = topGuildsPanel.list[tostring(guild.id)]
    local requestBtn = entry.info:recursiveGetChildById("request")
    requestBtn:setVisible(guild.status == 1)
  end
end

function onGuildDisbanded()
  onLeftGuild()
end

function onMessageFinished(data)
  local widget = inboxPanel.list:getChildById("msg" .. data)
  if not widget then
    return
  end

  widget.acceptBtn.onClick = nil
  widget.rejectBtn.onClick = nil

  widget.acceptBtn:disable()
  widget.rejectBtn:disable()

  widget.acceptBtn:setVisible(false)
  widget.rejectBtn:setVisible(false)
  widget:setHeight(95)
end

function onRemoveEmblem(data)
  if type(data) == "table" then
    for _, pid in ipairs(data) do
      local player = g_map.getCreatureById(pid)
      if player then
        player:setEmblem(EmblemNone)
      end
    end
  else
    local player = g_map.getCreatureById(data)
    if player then
      player:setEmblem(EmblemNone)
    end
  end
end

function onUpdateEmblems(data)
  for _, pid in ipairs(data.players) do
    local player = g_map.getCreatureById(pid)
    if player then
      player:setEmblem(data.emblem)
    end
  end
end

local function getGuildTitleColor(rankLevel)
  rankLevel = tonumber(rankLevel) or 0
  if rankLevel >= 3 then
    return "#FF4800"
  elseif rankLevel == 2 then
    return "#FFAA00"
  end
  return "#3FD927"
end

applyLocalPlayerGuildTitle = function(guildName, rankLevel)
  local localPlayer = g_game.getLocalPlayer()
  if not localPlayer then
    return
  end

  guildName = tostring(guildName or "")
  if guildName ~= "" then
    localPlayer:setTitle("[" .. guildName .. "]", "verdana-11px-rounded", getGuildTitleColor(rankLevel))
  else
    localPlayer:setTitle("", "verdana-11px-rounded", "#FFFFFF")
  end
end

function onCreatureGuildTitle(data)
  if type(data) ~= "table" then
    return
  end

  local creatureId = tonumber(data.id) or 0
  if creatureId <= 0 then
    return
  end

  local creature = g_map.getCreatureById(creatureId)
  if not creature then
    return
  end

  local guildName = tostring(data.guildName or "")
  if guildName ~= "" then
    creature:setTitle("[" .. guildName .. "]", "verdana-11px-rounded", getGuildTitleColor(data.rankLevel))
  else
    creature:setTitle("", "verdana-11px-rounded", "#FFFFFF")
  end
end

function onGuildPermissionsUpdate(perms)
  permissions = perms
  local hasRankPerms = hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_ROLES)
  setWidgetEnabled(ranksPanelBtn, hasRankPerms)
  if not hasRankPerms then
    if window.tabBar:getCurrentTab() == ranksPanelBtn then
      window.tabBar:selectPrevTab()
    end
  end
  window.settingsBtn:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS))
  generalPanel.general.stats.withdrawButton:setVisible(false)
  if storagePanel then
    local depositButton = storagePanel:recursiveGetChildById("depositItemsButton")
    local withdrawButton = storagePanel:recursiveGetChildById("withdrawItemsButton")
    if depositButton then depositButton:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.DEPOSIT_STORAGE)) end
    if withdrawButton then withdrawButton:setVisible(hasPermission(GUILDS_CFG.PERMISSIONS.WITHDRAW_STORAGE)) end
  end
  window.leaveBtn:setText(myGuild.leader == g_game.getCharacterName() and tr("Disband") or tr("Leave"))
end

function onGuildMemberRankUpdate(data)
  local widget = membersPanel.list[data.name]
  if not widget then
    return
  end

  widget.rank:setText(data.rank)
end

function onRankRowSelected(widget, selectedRow, oldSelectedRow)
  setWidgetEnabled(ranksPanel.default, selectedRow ~= nil)
  setWidgetEnabled(ranksPanel.delete, selectedRow ~= nil)
  if oldSelectedRow then
    applyRankTitleColor(oldSelectedRow, getTempRankForRow(oldSelectedRow))
  end
  if selectedRow then
    applyRankTitleColor(selectedRow, getTempRankForRow(selectedRow))
  end
end

function onRankPermissionCheck(widget, checked)
  if widget.oldCheck == nil then
    widget.oldCheck = not checked
    widget:setImageColor("green")
  else
    if widget.oldCheck ~= checked then
      widget:setImageColor("green")
    else
      widget:setImageColor("white")
    end
  end
  ranksPanel.save:enable()
  ranksPanel.reset:enable()
end

function editRankTitle(widget)
  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end

  local rankId = widget:getParent().rankId
  for _, rank in ipairs(myGuild.tempRanks) do
    if rank.id == rankId then
      titleEdit =
        modules.client_textedit.show(
        widget:getText():gsub("^%s+", ""),
        {title = tr("Edit rank title"), description = tr("Use a-z, A-Z, 0-9 and space. Min 3, max 12 characters.")},
        function(newTitle)
          newTitle = newTitle:trim()
          if newTitle:len() < 3 then
            displayErrorBox(tr("Error"), tr("Rank title needs at least 3 characters."))
            titleEdit = nil
            return
          end

          if newTitle:len() > 12 then
            displayErrorBox(tr("Error"), tr("Rank title is too long, max 12 characters."))
            titleEdit = nil
            return
          end

          if not newTitle:find("^[A-Za-z0-9 ]+$") then
            displayErrorBox(tr("Error"), tr("Rank title contains invalid characters."))
            titleEdit = nil
            return
          end

          if not widget.oldTitle then
            widget.oldTitle = widget:getText():gsub("^%s+", "")
          end

          if widget.oldTitle == newTitle then
            applyRankTitleColor(widget:getParent(), rank)
          else
            widget:setColor("red")
          end

          widget:setText("   " .. newTitle)
          rank.name = newTitle
          ranksPanel.save:enable()
          ranksPanel.reset:enable()
          titleEdit = nil
        end
      )

      titleEdit:setImageSource("/images/ui/miniwindow.png")

      addEvent(
        function()
          titleEdit:focus()
          titleEdit:raise()
        end
      )
      break
    end
  end
end

function createRank()
  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end

  local newRank = ranksPanel.newRank:getText():trim()
  if newRank:len() < 3 then
    displayErrorBox(tr("Error"), tr("Rank title needs at least 3 characters."))
    return
  end

  if newRank:len() > 12 then
    displayErrorBox(tr("Error"), tr("Rank title is too long, max 12 characters."))
    return
  end

  if not newRank:find("^[A-Za-z0-9 ]+$") then
    displayErrorBox(tr("Error"), tr("Rank title contains invalid characters."))
    return
  end

  for _, rank in ipairs(myGuild.tempRanks) do
    if rank.name == newRank then
      displayErrorBox(tr("Error"), tr("Rank title in use."))
      return
    end
  end

  local row =
    ranksPanel.ranksTable:addRow(
    {
      {style = "RankTitleColumn", text = "   " .. newRank, rankId = 0},
      {checked = false, imageOffset = "28 3", permission = GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS},
      {checked = false, imageOffset = "26 3", permission = GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.EDIT_ROLES},
      {checked = false, imageOffset = "23 3", permission = GUILDS_CFG.PERMISSIONS.EDIT_SETTINGS},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.MANAGE_GOLD},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.MANAGE_PERKS},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.DEPOSIT_STORAGE},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.WITHDRAW_STORAGE},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.MANAGE_PRISM},
      {checked = false, permission = GUILDS_CFG.PERMISSIONS.MANAGE_DYNASTIE}
    }
  )

  if row then
    row.rankId = 0
    setupRankTitleCell(row)
    row:getChildByIndex(1):setPhantom(false)
    row:getChildByIndex(1):setTooltip(tr("Double click to edit title"))
    row:getChildByIndex(1).onDoubleClick = editRankTitle
    for _, permission in ipairs(getVisibleRankPermissions()) do
      local checkbox = row:getChildByIndex(getPermissionColumnIndex(permission))
      if checkbox then
        checkbox:setChecked(false)
        checkbox.onCheckChange = onRankPermissionCheck
      end
    end

    table.insert(myGuild.tempRanks, {new = true, id = 0, name = newRank, permissions = 0, default = false})
    ranksPanel.newRank:setText("")
    ranksPanel.save:enable()
    ranksPanel.reset:enable()
  end
end

function makeDefault()
  local row = ranksPanel.ranksTable.selectedRow
  local selectedRank = getTempRankForRow(row)
  if not selectedRank then
    return
  end

  if selectedRank.leader then
    displayErrorBox(tr("Error"), tr("You can't make Leader rank as Default."))
    return
  end

  if selectedRank.default then
    return
  end

  for _, oldRow in ipairs(ranksPanel.ranksTable.rows) do
    local rank = getTempRankForRow(oldRow)
    if rank and rank.default then
      rank.default = false
      applyRankTitleColor(oldRow, rank)
    end
  end

  selectedRank.default = true
  applyRankTitleColor(row, selectedRank)

  ranksPanel.save:enable()
  ranksPanel.reset:enable()
end

function deleteRank()
  local activeRanks = 0
  for _, rank in ipairs(myGuild.tempRanks) do
    if not rank.removed then
      activeRanks = activeRanks + 1
    end
  end
  if activeRanks <= 2 then
    displayErrorBox(tr("Error"), tr("You need at least 2 ranks, Leader and Default."))
    return
  end

  local row = ranksPanel.ranksTable.selectedRow
  local rank = getTempRankForRow(row)
  if not rank then
    return
  end

  if rank.leader then
    displayErrorBox(tr("Error"), tr("You can't delete Leader rank."))
    return
  end

  if rank.default then
    displayErrorBox(tr("Error"), tr("You can't delete Default rank."))
    return
  end

  rank.removed = true
  ranksPanel.delete:disable()
  ranksPanel.reset:enable()
  ranksPanel.save:enable()

  row:disable()
  ranksPanel.ranksTableData:focusChild(nil)
  ranksPanel.ranksTable:selectRow(nil)

  if titleEdit then
    titleEdit:destroy()
    titleEdit = nil
  end
end

function resetRanks()
  local tempData = cloneTable(myGuild.ranks)
  onGuildRanksData(tempData)

  ranksPanel.default:disable()
  ranksPanel.reset:disable()
  ranksPanel.delete:disable()
  ranksPanel.save:disable()
end

function saveRanks()
  if not hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_ROLES) then
    return
  end

  for _, row in ipairs(ranksPanel.ranksTable.rows) do
    local rank = getTempRankForRow(row)
    if rank and not rank.leader and not rank.removed then
      rank.permissions = 0
      local all = true
      for _, permission in ipairs(getVisibleRankPermissions()) do
        local childIndex = getPermissionColumnIndex(permission)
        local checked = childIndex and row:getChildByIndex(childIndex) and row:getChildByIndex(childIndex):isChecked() or false
        rank.permissions = rank.permissions + (checked and math.pow(2, permission) or 0)
        if not checked then
          all = false
        end
      end
      if all then
        rank.permissions = GUILDS_CFG.PERMISSIONS.ALL
      end
    end

    if titleEdit then
      titleEdit:destroy()
      titleEdit = nil
    end
  end

  ranksPanel.delete:disable()
  ranksPanel.save:disable()
  ranksPanel.reset:disable()
  ranksPanel.default:disable()
  sendPacket("saveRanks", myGuild.tempRanks)
end

function openRankMenu(pos, name)
  local menu = g_ui.createWidget("PopupMenu")
  menu:setGameMenu(true)
  for _, rank in ipairs(myGuild.ranks) do
    if not rank.leader then
      menu:addOption(
        rank.name,
        function()
          sendPacket("setRank", {name = name, rankId = rank.id})
        end
      )
    end
  end
  menu:display(pos)
end

function createGuild()
  local statusWidget = generalPanel and generalPanel.noGuild and generalPanel.noGuild:recursiveGetChildById("status")
  local reqLevelWidget = generalPanel and generalPanel.noGuild and generalPanel.noGuild:recursiveGetChildById("reqLevel")
  local languageWidget = generalPanel and generalPanel.noGuild and generalPanel.noGuild:recursiveGetChildById("language")
  local nameWidget = generalPanel and generalPanel.noGuild and generalPanel.noGuild:recursiveGetChildById("name")
  if not statusWidget or not reqLevelWidget or not languageWidget or not nameWidget then
    return
  end

  local status = tonumber(statusWidget:getCurrentOption().data)
  local reqLevel = tonumber(reqLevelWidget:getText())
  local language = tonumber(languageWidget:getCurrentOption().data)
  local name = nameWidget:getText()

  local data = {
    name = name,
    status = status,
    reqLevel = reqLevel,
    lang = language,
    emblem = tostring(createEmblem)
  }

  sendPacket("create", data)
end

function leave()
  if not myGuild then
    return
  end

  clearMsgBox()
  local onConfirm = function()
    confirmLeave()
    clearMsgBox()
  end
  local onCancel = function()
    clearMsgBox()
  end
  local title = ""
  local text = ""
  if myGuild.leader == g_game.getCharacterName() then
    title = tr("Disband your guild?")
    text = tr("Are you sure you want to disband your guild?\n\nThis action is permanent and cannot be undone.\nAll guild gold, premium points, achievements progress, quest progress, dynastie progress and other guild data will be lost.\nYou must first collect all dynastie cores, remove all active prisms, and empty guild storage before disbanding.")
  else
    title = tr("Leave your guild?")
    text = tr("Are you sure you want to leave your guild?")
  end
  msgBox = displayGeneralBox(title, text, {{text = tr("No"), callback = onCancel}, {text = tr("Yes"), imageColor = "red", callback = onConfirm}}, onConfirm, onCancel)
end

function confirmLeave()
  if not myGuild then
    return
  end

  sendPacket("leave")
end

function showSettings()
  settings:show()
  settings:raise()
  settings:focus()

  local status = settings:recursiveGetChildById("status")
  status:clear()
  for i = 1, #JOIN_STATUS do
    status:addOption(tr(JOIN_STATUS[i]), i)
  end
  status:setCurrentOption(tr(JOIN_STATUS[myGuild.joinStatus]))

  local reqLevel = settings:recursiveGetChildById("reqLevel")
  reqLevel:setValidCharacters("0123456789")
  reqLevel:setText(myGuild.reqLevel)

  local language = settings:recursiveGetChildById("language")
  language:clear()
  for i = 1, #LANGUAGES do
    language:addOption(tr(LANGUAGES[i]), i)
  end
  language:setCurrentOption(tr(LANGUAGES[myGuild.language]))

  local widget = settings:recursiveGetChildById("emblem")
  setGuildEmblem(widget, myGuild.emblem)
  myGuild.tempEmblem = myGuild.emblem

  local motd = settings:recursiveGetChildById("motd")
  motd:setText(myGuild.motd)
end

function closeSettings()
  settings:hide()
end

function saveSettings()
  local data = {
    status = settings:recursiveGetChildById("status"):getCurrentOption().data,
    reqLevel = tonumber(settings:recursiveGetChildById("reqLevel"):getText()),
    language = settings:recursiveGetChildById("language"):getCurrentOption().data,
    emblem = myGuild.tempEmblem,
    motd = settings:recursiveGetChildById("motd"):getText()
  }

  sendPacket("settings", data)
  settings:hide()
end

function settingsNextEmblem()
  local widget = settings:recursiveGetChildById("emblem")
  myGuild.tempEmblem = myGuild.tempEmblem + 1
  if myGuild.tempEmblem > TOTAL_EMBLEMS - 1 then
    myGuild.tempEmblem = 0
  end
  local logoX = 128 * (myGuild.tempEmblem % 5)
  local logoY = 128 * math.floor(myGuild.tempEmblem / 5)
  widget:setImageClip({x = logoX, y = logoY, width = 128, height = 128})
end

function settingsPrevEmblem()
  local widget = settings:recursiveGetChildById("emblem")
  myGuild.tempEmblem = myGuild.tempEmblem - 1
  if myGuild.tempEmblem < 0 then
    myGuild.tempEmblem = TOTAL_EMBLEMS - 1
  end
  local logoX = 128 * (myGuild.tempEmblem % 5)
  local logoY = 128 * math.floor(myGuild.tempEmblem / 5)
  widget:setImageClip({x = logoX, y = logoY, width = 128, height = 128})
end

function createNextEmblem()
  local widget = generalPanel and generalPanel.noGuild and generalPanel.noGuild:recursiveGetChildById("emblemPreview")
  if not widget then
    return
  end
  createEmblem = createEmblem + 1
  if createEmblem > TOTAL_EMBLEMS - 1 then
    createEmblem = 0
  end
  setGuildEmblem(widget, createEmblem)
end

function createPrevEmblem()
  local widget = generalPanel and generalPanel.noGuild and generalPanel.noGuild:recursiveGetChildById("emblemPreview")
  if not widget then
    return
  end
  createEmblem = createEmblem - 1
  if createEmblem < 0 then
    createEmblem = TOTAL_EMBLEMS - 1
  end
  setGuildEmblem(widget, createEmblem)
end

function showDeposit()
  local depositPanel = generalPanel.general.deposit

  depositPanel.gold:setText("0")
  depositPanel.gold:setMaximum(playerBalance or 0)

  if depositPanel.playerBalanceLabel then
    depositPanel.playerBalanceLabel:setText(tr("Your Balance: ") .. comma_value(playerBalance or 0))
    depositPanel.playerBalanceLabel:setTooltip(formatNumber(playerBalance or 0))
  end

  sendPacket("updateSelfBalance")

  depositPanel.gold.onTextChange = function(self, text, oldText)
    if string.len(text) < 1 then
      return true
    end

    text = string.gsub(text, "%.", "")

    if not tonumber(text) then
      self:setText(oldText, true)
      return true
    end

    if tonumber(text) < 0 then
      self:setText(oldText, true)
      return true
    end

    if tonumber(text) > self.maximum then
      self:setText(comma_value(self.maximum), true)
      return true
    end

    self:setText(comma_value(text), true)
  end

  depositPanel:show()
end

function showPremiumDeposit()
  local depositPanel = generalPanel.general.premiumDeposit

  depositPanel.points:setText("0")
  depositPanel.points:setMaximum(playerPremiumPoints or 0)

  if depositPanel.playerPremiumBalanceLabel then
    depositPanel.playerPremiumBalanceLabel:setText(tr("Your Premium Points: ") .. comma_value(playerPremiumPoints or 0))
    depositPanel.playerPremiumBalanceLabel:setTooltip(formatNumber(playerPremiumPoints or 0))
  end

  sendPacket("updateSelfBalance")

  depositPanel.points.onTextChange = function(self, text, oldText)
    if string.len(text) < 1 then
      return true
    end

    text = string.gsub(text, "%.", "")

    if not tonumber(text) then
      self:setText(oldText, true)
      return true
    end

    if tonumber(text) < 0 then
      self:setText(oldText, true)
      return true
    end

    if tonumber(text) > self.maximum then
      self:setText(comma_value(self.maximum), true)
      return true
    end

    self:setText(comma_value(text), true)
  end

  depositPanel:show()
end

local function getContributionEntriesForMember(memberName)
  if not contributionHistory or not contributionHistory[memberName] then
    return {}
  end

  local historyData = contributionHistory[memberName]
  local source = selectedContributionCurrency == "premium" and historyData.historyPremium or historyData.historyGold
  local list = {}

  if source then
    for _, entry in ipairs(source) do
      table.insert(list, entry)
    end
  end

  table.sort(list, function(a, b)
    if a.date == b.date then
      return (tonumber(a.currency) or 0) < (tonumber(b.currency) or 0)
    end
    return (tonumber(a.date) or 0) > (tonumber(b.date) or 0)
  end)

  return list
end

local function renderContributionMember(memberName)
  if not generalPanel or not generalPanel.general then
    return
  end

  local page = generalPanel.general:recursiveGetChildById("contributionPage")
  if not page then
    return
  end

  local contributionBase = page:recursiveGetChildById("contributionHistoryBase")
  local totalBase = page:recursiveGetChildById("contributionTotalBase")
  local contributionList = contributionBase and contributionBase:recursiveGetChildById("contributionHistoryList")

  if not contributionBase or not totalBase or not contributionList then
    return
  end

  contributionList:destroyChildren()

  local list = getContributionEntriesForMember(memberName)
  local total = 0
  local average = 0

  if #list > 0 then
    for i = 1, #list do
      local contributeItem = g_ui.createWidget("GuildContributeItem", contributionList)
      contributeItem.date:setText(os.date("%d/%m/%Y", list[i].date))
      contributeItem.value:setText(comma_value(list[i].value) .. (selectedContributionCurrency == "premium" and " Premium" or " Gold"))
      contributeItem:setTooltip(formatNumber(list[i].value))
      contributeItem:setChecked(i % 2 == 0)
      total = total + list[i].value
    end

    average = total / #list
  end

  totalBase.total:setText(comma_value(total))
  totalBase.totalLayer:setTooltip(formatNumber(total))
  totalBase.average:setText(comma_value(average))
  totalBase.averageLayer:setTooltip(formatNumber(average))
end

function selectContributionCurrency(currency)
  if updatingContributionCurrency then
    return
  end

  if currency ~= "gold" and currency ~= "premium" then
    return
  end

  selectedContributionCurrency = currency

  if not generalPanel or not generalPanel.general then
    return
  end

  local page = generalPanel.general:recursiveGetChildById("contributionPage")
  if not page then
    return
  end

  local showGold = page:recursiveGetChildById("showGold")
  local showPremium = page:recursiveGetChildById("showPremium")
  updatingContributionCurrency = true
  if showGold then
    local shouldCheckGold = currency == "gold"
    if showGold:isChecked() ~= shouldCheckGold then
      showGold:setChecked(shouldCheckGold)
    end
  end
  if showPremium then
    local shouldCheckPremium = currency == "premium"
    if showPremium:isChecked() ~= shouldCheckPremium then
      showPremium:setChecked(shouldCheckPremium)
    end
  end
  updatingContributionCurrency = false

  local selectedPlayer = nil
  local playersBase = page:recursiveGetChildById("contributionPlayersBase")
  local playerList = playersBase and playersBase:recursiveGetChildById("contributionPlayerList")
  local contributionBase = page:recursiveGetChildById("contributionHistoryBase")
  local contributionList = contributionBase and contributionBase:recursiveGetChildById("contributionHistoryList")
  local totalBase = page:recursiveGetChildById("contributionTotalBase")
  if not playerList then
    return
  end

  for _, child in ipairs(playerList:getChildren()) do
    if child:isChecked() then
      selectedPlayer = child
      break
    end
  end

  if not selectedPlayer then
    selectedPlayer = playerList:getChildByIndex(1)
  end

  if selectedPlayer and selectedPlayer.name then
    renderContributionMember(selectedPlayer.name)
  else
    if contributionList then
      contributionList:destroyChildren()
    end
    if totalBase then
      totalBase.total:setText("0")
      totalBase.average:setText("0")
    end
  end
end

function resetDeposit()
  generalPanel.general.deposit.gold:setText(0)
end

function resetPremiumDeposit()
  generalPanel.general.premiumDeposit.points:setText(0)
end

function deposit()
  local gold = generalPanel.general.deposit.gold:getText()

  if gold:len() < 1 then
    return
  end

  gold = string.gsub(gold, "%.", "")
  gold = tonumber(gold)

  if not gold or gold < 1 then
    return
  end

  sendPacket("donate", gold)
  generalPanel.general.deposit:hide()
  generalPanel.general.stats.donateButton:setText(tr("Wait a moment"))
  generalPanel.general.stats.donateButton:disable()
  scheduleEvent(function() 
    generalPanel.general.stats.donateButton:enable()
    generalPanel.general.stats.donateButton:setText(tr("Donate"))
  end, 3000)
end

function premiumDeposit()
  local points = generalPanel.general.premiumDeposit.points:getText()

  if points:len() < 1 then
    return
  end

  points = string.gsub(points, "%.", "")
  points = tonumber(points)

  if not points or points < 1 then
    return
  end

  sendPacket("premiumDonate", points)
  generalPanel.general.premiumDeposit:hide()
  generalPanel.general.stats.premiumDonateButton:setText(tr("Wait a moment"))
  generalPanel.general.stats.premiumDonateButton:disable()
  scheduleEvent(function()
    generalPanel.general.stats.premiumDonateButton:enable()
    generalPanel.general.stats.premiumDonateButton:setText(tr("Premium Donate"))
  end, 3000)
end

function showWithdraw()
  generalPanel.general.withdraw.gold:setText("0")
  generalPanel.general.withdraw.gold:setMaximum(guildBalance or 0)
  generalPanel.general.withdraw.guildBalanceLabel:setText(tr("Guild Balance: ") .. comma_value(guildBalance or 0))

  generalPanel.general.withdraw.gold.onTextChange = function(self, text, oldText)
    if string.len(text) < 1 then
      return true
    end

    text = string.gsub(text, "%.", "")

    if not tonumber(text) then
      self:setText(oldText, true)
      return true
    end

    if tonumber(text) < 0 then
      self:setText(oldText, true)
      return true
    end

    if tonumber(text) > self.maximum then
      self:setText(comma_value(self.maximum), true)
      return true
    end

    self:setText(comma_value(text), true)
  end

  generalPanel.general.withdraw:show()
end

function resetWithdraw()
  generalPanel.general.withdraw.gold:setText(0)
end

function withdraw()
  local gold = generalPanel.general.withdraw.gold:getText()

  if gold:len() < 1 then
    return
  end

  gold = string.gsub(gold, "%.", "")
  gold = tonumber(gold)

  if not gold or gold < 1 then
    return
  end

  sendPacket("withdraw", gold)
  generalPanel.general.withdraw:hide()
  generalPanel.general.stats.withdrawButton:setText(tr("Wait..."))
  generalPanel.general.stats.withdrawButton:disable()
  scheduleEvent(function() 
    generalPanel.general.stats.withdrawButton:enable()
    generalPanel.general.stats.withdrawButton:setText(tr("Withdraw"))
  end, 3000)
end

function levelUp()
  sendPacket("levelUp")
end

function createMemberMenu(index)
  if not myGuild or not myGuild.membersList then
    return
  end

  local member = myGuild.membersList[index]
  if not member then
    return
  end

  local myName = g_game.getCharacterName()
  local memberLeader = myGuild.leader == member.name
  local pos = g_window.getMousePosition()
  local menu = g_ui.createWidget("PopupMenu")
  menu:setGameMenu(true)

  --menu:addText("Contribution: " .. member.contribution)
  if hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS) then
    local added = false
    if not memberLeader then
      menu:addSeparator()
      added = true
      menu:addOption(
        tr("Set Rank"),
        function()
          openRankMenu(pos, member.name)
        end
      )
    end
    if member.name ~= myName then
      if not added then
        menu:addSeparator()
        added = true
      end
      menu:addOption(
        tr("Kick"),
        function()
          kickPlayer(member.name)
        end
      )
    end
  end

  if myGuild.leader == myName and not memberLeader then
    menu:addSeparator()
    menu:addOption(
      tr("Pass Leader"),
      function()
        passLeader(member.name)
      end
    )
  end

  menu:display(pos)
end

function passLeader(name)
  if permissions ~= -1 or myGuild.leader ~= g_game.getCharacterName() then
    return
  end

  clearMsgBox()

  local onCancel = function()
    clearMsgBox()
  end

  local onConfirm = function()
    clearMsgBox()
    sendPacket("passLeader", name)
  end

  msgBox =
    displayGeneralBox(
    tr("Pass Leader"),
    tr("Are you sure you want to pass guild leadership to %s?", name),
    {
      {text = tr("No"), callback = onCancel},
      {text = tr("Yes"), imageColor = "red", callback = onConfirm}
    },
    onConfirm,
    onCancel
  )
  msgBox:raise()
end

function onNewLeader(data)
  do
    local widget = membersPanel.list[data.newLeader]
    if not widget then
      return
    end

    widget.rank:setText(data.newLeaderRank)
  end

  do
    local widget = membersPanel.list[data.oldLeader]
    if not widget then
      return
    end

    widget.rank:setText(data.oldLeaderRank)
  end

  myGuild.leader = data.newLeader
end

function onExpUpdate(data)
  local InfoBase = generalPanel.general.stats
  if myGuild then
    myGuild.level = data.level
    perksPanel.topBar.guildLevel:setText("Lv " .. data.level)
  end
  InfoBase.levelBase.level:setText(data.level)
  updateGuildExpBar(data.exp, data.baseExp)
end

function toggleEmblemList(force, isCreate)
  if not emblemList then
  return false
  end

  if emblemList:isVisible() then
    emblemList:hide()
    return false
  end

  if force then
    emblemList:show()
    emblemList:raise()

    emblemList.isCreate = isCreate

    if emblemList.listBase.list:getChildCount() <= 0 then
      emblemRadioGroup = UIRadioGroup.create()
      for emblemId = 1,TOTAL_EMBLEMS do
        local emblem = g_ui.createWidget("EmblemListItem", emblemList.listBase.list)
        local logoX = 128 * (emblemId % 5)
        local logoY = 128 * math.floor(emblemId / 5)
        emblem.icon:setImageClip({x = logoX, y = logoY, width = 128, height = 128})
        emblem.icon:setImageRect({x = 0, y = 0, width = 80, height = 80})
        emblem.index = emblemId
        emblemRadioGroup:addWidget(emblem)
        emblem.onClick = function(widget)
          setSelectedEmblemWidget(widget)
        end
      end
    elseif not emblemRadioGroup then
      emblemRadioGroup = UIRadioGroup.create()
      for _, emblem in ipairs(emblemList.listBase.list:getChildren()) do
        emblemRadioGroup:addWidget(emblem)
        emblem.onClick = function(widget)
          setSelectedEmblemWidget(widget)
        end
      end
    end

    if isCreate then
      local selected = emblemList.listBase.list:getChildByIndex(tonumber(createEmblem))
      if selected then
        setSelectedEmblemWidget(selected)
      end
    else
      local tempId = tonumber(myGuild.tempEmblem)
      if tempId and tempId > 0 then
        local selected = emblemList.listBase.list:getChildByIndex(tempId)
        if selected then
          setSelectedEmblemWidget(selected)
        end
      else
        local selected = emblemList.listBase.list:getChildByIndex(1)
        if selected then
          setSelectedEmblemWidget(selected)
        end
      end
    end

  end
end

function saveEmblemList()
  local selected = selectedEmblemWidget or (emblemRadioGroup and emblemRadioGroup:getSelectedWidget()) or emblemList.listBase.list:getFocusedChild()
  if not selected then
    return
  end

  local index = selected.index
  if emblemList.isCreate and emblemList.isCreate == true then
    createEmblem = index
    local createEmblemWidget = generalPanel and generalPanel.noGuild and generalPanel.noGuild:recursiveGetChildById("emblemPreview")
    if createEmblemWidget then
      setGuildEmblem(createEmblemWidget, createEmblem)
    end
  else
    setGuildEmblem(settings:recursiveGetChildById("emblem"), index)
    myGuild.tempEmblem = index
  end
  toggleEmblemList()
end

function setGuildEmblem(widget, emblem, forceUpdate)
  widget:setVisible(false)
  if tonumber(emblem) then
    widget:setImageSource("/images/guild_hall/emblems")
    local logoX = 128 * (emblem % 5)
    local logoY = 128 * math.floor(emblem / 5)
    widget:setImageClip({x = logoX, y = logoY, width = 128, height = 128})
    widget:setVisible(true)
    return true
  end
end

function canInvite(name)
  if not myGuild then
    return false
  end

  if not hasPermission(GUILDS_CFG.PERMISSIONS.INVITE_MEMBERS) then
    return false
  end

  for _, member in ipairs(myGuild.membersList) do
    if member.name == name then
      return false
    end
  end

  return true
end

function canKick(name)
  if not myGuild then
    return false
  end

  if not hasPermission(GUILDS_CFG.PERMISSIONS.EDIT_MEMBERS) then
    return false
  end

  for _, member in ipairs(myGuild.membersList) do
    if member.name == name then
      return true
    end
  end

  return false
end

function toggle()
  if guildsButton:isOn() then
    hide()
    guildsButton:setOn(false)
  else
    show()
    if needUpdate then
      sendPacket("fetch")
      needUpdate = false
    end
    guildsButton:setOn(true)
  end
end

function show()
  if not window then
    return
  end

  if needUpdate then
    waitingGuildFetch = true
    if generalPanel then
      if generalPanel.noGuild then generalPanel.noGuild:hide() end
      if generalPanel.general then generalPanel.general:hide() end
    end
    if membersPanel then membersPanel:hide() end
    if ranksPanel then ranksPanel:hide() end
    if perksPanel then perksPanel:hide() end
    if storagePanel then storagePanel:hide() end
    if prismPanel then prismPanel:hide() end
    if questsPanel then questsPanel:hide() end
    if achievementsPanel then achievementsPanel:hide() end
    if inboxPanel then inboxPanel:hide() end
    if topGuildsPanel then topGuildsPanel:hide() end
    membersPanelBtn:disable()
    ranksPanelBtn:disable()
    perksPanelBtn:disable()
    storagePanelBtn:disable()
    if prismPanelBtn then prismPanelBtn:disable() end
    if questsPanelBtn then questsPanelBtn:disable() end
    if achievementsPanelBtn then achievementsPanelBtn:disable() end
    if inboxPanelBtn then inboxPanelBtn:disable() end
    if topGuildsPanelBtn then topGuildsPanelBtn:disable() end
    window.leaveBtn:hide()
    window.settingsBtn:hide()
    window.inboxFilterBtn:hide()
    window.balanceBase:setVisible(false)
    window.balanceLabel:setVisible(false)
    if window.balanceIcon then window.balanceIcon:setVisible(false) end
    window.premiumBalanceBase:setVisible(false)
    window.premiumBalanceLabel:setVisible(false)
    if window.premiumBalanceIcon then window.premiumBalanceIcon:setVisible(false) end
    window.dynastieTokenBase:setVisible(false)
    window.dynastieTokenLabel:setVisible(false)
    if window.dynastieTokenIcon then window.dynastieTokenIcon:setVisible(false) end
  end

  window:show()
  window:raise()
  window:focus()
  if generalPanelBtn and window.tabBar then
    window.tabBar.currentTab = nil
    window.tabBar:selectTab(generalPanelBtn)
  end
  hideContributions()
end

function hide()
  if not window then
    return
  end
  stopPrismCountdown()
  stopQuestCountdown()
  stopBlackMarketCountdown()
  stopDynastieCountdown()
  sendPacket("prismViewState", { active = false })
  sendPacket("dynastieViewState", { active = false })
  if generalPanel then generalPanel:hide() end
  if membersPanel then membersPanel:hide() end
  if ranksPanel then ranksPanel:hide() end
  if perksPanel then perksPanel:hide() end
  if inboxPanel then inboxPanel:hide() end
  if topGuildsPanel then topGuildsPanel:hide() end
  if storagePanel then storagePanel:hide() end
  if prismPanel then prismPanel:hide() end
  if questsPanel then questsPanel:hide() end
  if achievementsPanel then achievementsPanel:hide() end
  if blackMarketPanel then blackMarketPanel:hide() end
  if dynastiePanel then dynastiePanel:hide() end
  window:hide()
  
  clearMsgBox()
end

function hasPermission(value)
  if permissions == -1 then
    return true
  end

  return bit.band(permissions, math.pow(2, value)) ~= 0
end

function rankHasPermission(perms, value)
  if perms == -1 then
    return true
  end

  return bit.band(perms, math.pow(2, value)) ~= 0
end

function toTime(time)
  local weeks = math.floor(time / 604800)
  local days = math.floor(math.fmod(time, 604800) / 86400)
  local hours = math.floor(math.fmod(time, 86400) / 3600)
  local minutes = math.floor(math.fmod(time, 3600) / 60)
  local seconds = math.floor(math.fmod(time, 60))

  local space = false
  local str = ""
  if weeks > 0 then
    str = string.format("%d week%s", weeks, (weeks > 1 and "s" or ""))
    space = true
  end
  if days > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d day%s", str, days, (days > 1 and "s" or ""))
    space = true
  end
  if hours > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d hour%s", str, hours, (hours > 1 and "s" or ""))
    space = true
  end
  if minutes > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d minute%s", str, minutes, (minutes > 1 and "s" or ""))
    space = true
  end
  if seconds > 0 then
    if space then
      str = string.format("%s ", str)
      space = false
    end
    str = string.format("%s%d second%s", str, seconds, (seconds > 1 and "s" or ""))
  end
  return str
end

function getOfflineTime(last)
  last = os.time() - last
  local days = math.floor((last / (24 * 60 * 60)) + 0.5)
  local hours = math.floor((last / (60 * 60)) + 0.5)
  local minutes = math.floor((last / 60) + 0.5)
  local seconds = last
  if seconds < 60 then
    return seconds .. " second" .. (seconds > 1 and "s." or ".")
  end
  if minutes < 60 then
    return minutes .. " minute" .. (minutes > 1 and "s." or ".")
  end
  if hours < 24 then
    return hours .. " hour" .. (hours > 1 and "s." or ".")
  end

  return days .. " day" .. (days > 1 and "s." or ".")
end

function generateInboxText(text, color, highlightColor)
  local tmpData = {}

  for i, part in ipairs(text:split("{")) do
    if i == 1 then
      table.insert(tmpData, part)
      table.insert(tmpData, color)
    else
      for j, part2 in ipairs(part:split("}")) do
        if j == 1 then
          table.insert(tmpData, part2)
          table.insert(tmpData, highlightColor)
        else
          table.insert(tmpData, part2)
          table.insert(tmpData, color)
        end
      end
    end
  end

  return tmpData
end

function parseTimeTable(time)
  local duration = 0

  duration = duration + time.WEEKS * 7 * 24 * 60 * 60
  duration = duration + time.DAYS * 24 * 60 * 60
  duration = duration + time.HOURS * 60 * 60
  duration = duration + time.MINUTES * 60
  duration = duration + time.SECONDS

  return duration
end

function formatNumber(num)
	local suffixes = { 
		{ "", "" },
		{ tr("Thousand"), tr("Thousands") }, 
		{ tr("Million"), tr("Millions") }, 
		{ tr("Billion"), tr("Billions") }, 
		{ tr("Trillion"), tr("Trillions") }, 
		{ tr("Quadrillion"), tr("Quadrillions") }, 
		{ tr("Quintillion"), tr("Quintillions") }
	}
	local index = 1
  
	while num >= 1000 and index < #suffixes do
		num = num / 1000
		index = index + 1
	end
	
	local suffix = (num >= 1 and num < 2) and suffixes[index][1] or suffixes[index][2]
	return string.format("%.2f %s", num, suffix)
end

function comma_value(n)
  local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
  return left .. (num:reverse():gsub("(%d%d%d)", "%1."):reverse()) .. right
end

function onPerkBasic(data)
  perksPanel.data = data
  perksPanel.topBar.guildLevel:setText("Lv " .. data.guildLevel)
  perksPanel.topBar.perks:setText(data.perks)
  perksPanel.topBar.nextPerk:setText("Lv " .. data.nextPerk)
  if myGuild then
    myGuild.premiumBalance = tonumber(data.premiumBalance) or myGuild.premiumBalance or 0
  end
end

function onPerkList(data)
  perksPanel.perkList:destroyChildren()
  if not data or #data < 1 then
    return
  end

  perksPanel.perkList.amount = 0

  for i = 1,#data do
    local perkItem = g_ui.createWidget("GuildPerkItem", perksPanel.perkList)
    perkItem.perkId = data[i].id
    perkItem.name:setText(data[i].name)
    perkItem.level:setText("Lv. " .. data[i].level .. " - (" .. data[i].level .. "/" .. data[i].maxLevel .. ")")
    perkItem.bonus:setText(data[i].bonus)
    perkItem.costValue:setText(comma_value(data[i].cost))
    perkItem.costLayer:setTooltip(formatNumber(data[i].cost))
    if tonumber(data[i].premiumPoints or 0) > 0 then
      perkItem.premiumCostLabel:setVisible(true)
      perkItem.premiumCostValue:setVisible(true)
      perkItem.premiumCostValue:setText(comma_value(data[i].premiumPoints))
      perkItem.premiumCostValue:setTooltip(formatNumber(data[i].premiumPoints))
      if tonumber(data[i].cost or 0) > 0 then
        perkItem.costLabel:setVisible(true)
        perkItem.costValue:setVisible(true)
        perkItem.costLabel:setText(tr("Gold") .. ": ")
      else
        perkItem.costLabel:setVisible(false)
        perkItem.costValue:setVisible(false)
      end
    else
      perkItem.premiumCostLabel:setVisible(false)
      perkItem.premiumCostValue:setVisible(false)
      perkItem.costLabel:setVisible(true)
      perkItem.costValue:setVisible(true)
      perkItem.costLabel:setText(tr("Cost") .. ": ")
    end

    perkItem.requiredLevel:setText("Require Guild Lv. " .. data[i].rlevel)
    perkItem.icon:setImageSource("/images/guild_hall/" .. data[i].icon)

    if data[i].level > 0 then
      perksPanel.perkList.amount = perksPanel.perkList.amount + 1
    end

    if data[i].level >= data[i].maxLevel then
      perkItem.requiredLevel:setVisible(false)
      perkItem.costLabel:setVisible(false)
      perkItem.costValue:setVisible(false)
      perkItem.premiumCostLabel:setVisible(false)
      perkItem.premiumCostValue:setVisible(false)
    end

    perkItem:setTooltip(tr(data[i].tooltip))

    perkItem.data = data[i]
  end
end

function upgradePerk()
  local perkItem = perksPanel.perkList:getFocusedChild()
  
  if not perkItem then
    return
  end

  if perkItem.data.level >= perkItem.data.maxLevel then
    perkWarn(tr("Perk Upgrade Result"), tr("This perk has already reached the maximum level."))
    return
  end

  if perksPanel.data.guildLevel < perkItem.data.rlevel then
    perkWarn(tr("Perk Upgrade Result"), tr("Your guild does not have the required level for the upgrade. (Lv. %s)", perkItem.data.rlevel))
    return
  end

  local premiumCost = tonumber(perkItem.data.premiumPoints or 0) or 0
  if premiumCost > 0 and (not myGuild or (tonumber(myGuild.premiumBalance) or 0) < premiumCost) then
    perkWarn(tr("Perk Upgrade Result"), tr("The guild does not have enough premium points."))
    return
  end

  if premiumCost <= 0 and window.balanceBase.balanceValue < perkItem.data.cost then
    perkWarn(tr("Perk Upgrade Result"), tr("The guild does not have enough gold."))
    return
  end

  sendPacket("perkUnlock", {perkId = perkItem.perkId})
end 

function resetPerks(sendId)
  local perkItem = perksPanel.perkList:getFocusedChild()
  local perkId = "all"
  if sendId and perkItem then
    perkId = perkItem.perkId
  end

  if perkId == "all" then
    if perksPanel.perkList.amount == 0 then
      perkWarn(tr("Perk Reset Result"), tr("The guild does not have any active perks."))
      return
    end
  end

  sendPacket("perkReset", {perkId = perkId})
end 

function showContributions()
  if not generalPanel or not generalPanel.general then
    return
  end

  local contributionPage = generalPanel.general:recursiveGetChildById("contributionPage")
  local sidePanel = generalPanel.general:recursiveGetChildById("sidePanel")
  local stats = generalPanel.general:recursiveGetChildById("stats")
  local motdPanel = generalPanel.general:recursiveGetChildById("motdPanel")
  local playersBase = contributionPage and contributionPage:recursiveGetChildById("contributionPlayersBase")
  local contributionBase = contributionPage and contributionPage:recursiveGetChildById("contributionHistoryBase")
  local playerList = playersBase and playersBase:recursiveGetChildById("contributionPlayerList")
  local contributionList = contributionBase and contributionBase:recursiveGetChildById("contributionHistoryList")

  if not contributionPage or not playersBase or not contributionBase or not playerList or not contributionList then
    return
  end

  sendPacket("contributionhistory")
  window:setHeight(CONTRIBUTION_WINDOW_HEIGHT)
  if sidePanel then sidePanel:hide() end
  if stats then stats:hide() end
  if motdPanel then motdPanel:hide() end
  contributionPage:setVisible(true)
  playerList:destroyChildren()
  contributionList:destroyChildren()
  selectedContributionCurrency = "gold"
  local showGold = contributionPage:recursiveGetChildById("showGold")
  local showPremium = contributionPage:recursiveGetChildById("showPremium")
  if showGold then
    showGold:setChecked(true)
  end
  if showPremium then
    showPremium:setChecked(false)
  end

  for i = 1,#myGuild.membersList do
    local playerItem = g_ui.createWidget("GuildContributePlayerItem", playerList)
    playerItem:setChecked(i%2 == 0 )
    playerItem:setText(myGuild.membersList[i].name)
    playerItem.name = myGuild.membersList[i].name

    playerItem.onClick = function(self)
      for _, child in ipairs(playerList:getChildren()) do
        child:setChecked(false)
      end
      self:setChecked(true)
      renderContributionMember(self.name)
    end

    if i == 1 then
      playerItem.onClick(playerItem)
    end
  end
end

function hideContributions()
  if not generalPanel or not generalPanel.general then
    if window then
      window:setHeight(DEFAULT_WINDOW_HEIGHT)
    end
    return
  end

  local contributionPage = generalPanel.general:recursiveGetChildById("contributionPage")
  local sidePanel = generalPanel.general:recursiveGetChildById("sidePanel")
  local stats = generalPanel.general:recursiveGetChildById("stats")
  local motdPanel = generalPanel.general:recursiveGetChildById("motdPanel")

  if contributionPage then
    contributionPage:setVisible(false)
  end
  if sidePanel then
    sidePanel:show()
  end
  if stats then
    stats:show()
  end
  if motdPanel then
    motdPanel:show()
  end
  window:setHeight(DEFAULT_WINDOW_HEIGHT)
end


function onContributionHistory(data)
  contributionHistory = {}
  for i = 1,#data do
    contributionHistory[data[i].name] = data[i]
  end
end

function selectContributionPage(self, page)
  if not generalPanel or not generalPanel.general then
    return
  end

  local contributionPage = generalPanel.general:recursiveGetChildById("contributionPage")
  local playersBase = contributionPage and contributionPage:recursiveGetChildById("contributionPlayersBase")
  local playerList = playersBase and playersBase:recursiveGetChildById("contributionPlayerList")
  if not playerList then
    return
  end

  local firstPlayer = playerList:getChildByIndex(1)
  if firstPlayer then
    firstPlayer:onClick()
  end
end
  
function perkWarn(title, text)

  clearMsgBox()

  local onCancel = function()
    clearMsgBox()
    if dynastieManageWindow and (dynastieManageCurrentTab == "perks" or dynastieManageCurrentTab == "defenders" or dynastieManageCurrentTab == "passivetree") then
      sendPacket("dynastiePanelFetch", {})
    end
  end

  msgBox = displayGeneralBox(title, text, {{text = "Ok", callback = onCancel}}, onCancel, onCancel)
  msgBox:raise()
end

function onPerkResult(result)
  perkWarn(result.title, result.text)
end

function getUI()
  return window
end
