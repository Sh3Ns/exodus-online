if not WeaponProficiency then
	WeaponProficiency = {}
	WeaponProficiency.__index = WeaponProficiency
	WeaponProficiency.OPCODE = 236

	WeaponProficiency.window = nil
	WeaponProficiency.button = nil
	WeaponProficiency.warningWindow = nil
	WeaponProficiency.displayItemPanel = nil
	WeaponProficiency.perkPanel = nil
	WeaponProficiency.bonusDetailPanel = nil
	WeaponProficiency.starProgressPanel = nil
	WeaponProficiency.optionFilter = nil
	WeaponProficiency.itemListScroll = nil
	WeaponProficiency.vocationWarning = nil
	WeaponProficiency.treeScroll = nil
	WeaponProficiency.treeContent = nil
	WeaponProficiency.treeColumnWidth = 108
	WeaponProficiency.treeViewportWidth = 754

	WeaponProficiency.itemList = {}
	WeaponProficiency.cacheList = {}


	WeaponProficiency.allProficiencyRequested = false
	WeaponProficiency.openAfterFetch = false
	WeaponProficiency.fetchInProgress = false
	WeaponProficiency.firstItemRequested = nil
	WeaponProficiency.pendingTargetItemId = nil
	WeaponProficiency.pendingTargetCategory = nil
	WeaponProficiency.catalogFetchInProgress = false
	WeaponProficiency.catalogFiltered = false
	WeaponProficiency.catalogConfirmedItemIds = {}
	WeaponProficiency.catalogMetadata = {}
	WeaponProficiency.tooltipRequests = {}

	WeaponProficiency.saveWeaponMissing = false

	WeaponProficiency.ItemCategory = {
		Axes = 17, Clubs = 18, DistanceWeapons = 19,
		Swords = 20, WandsRods = 21, FistWeapons = 27,
	}
	WeaponProficiency.perkPanelsName = {
		"oneBonusIconPanel", "twoBonusIconPanel",
		"threeBonusIconPanel"
	}
	WeaponProficiency.filters = {
		["oneButton"] = false,
		["twoButton"] = false,
	}

	WeaponProficiency.listWidgetHeight = 34
	WeaponProficiency.listCapacity = 0
	WeaponProficiency.listMinWidgets = 0
	WeaponProficiency.listMaxWidgets = 0
	WeaponProficiency.offset = 0
	WeaponProficiency.listPool = {}
	WeaponProficiency.listData = {}
	WeaponProficiency.currentPage = 1
	WeaponProficiency.pageSize = 20
	WeaponProficiency.pageCount = 1
	WeaponProficiency.currentCategory = "Weapons: All"
	WeaponProficiency.currentSearchText = nil
	WeaponProficiency.networkHandlers = {}
end

WeaponProficiency.tooltipRequests = WeaponProficiency.tooltipRequests or {}

local sendPacket
local equipmentRefreshEvent
local MAX_MASTERY_OVERLAY_LEVEL = 20
local MAX_MASTERY_BASE_LEVEL = 7

local function cancelEquipmentRefresh()
	if equipmentRefreshEvent then
		equipmentRefreshEvent:cancel()
		equipmentRefreshEvent = nil
	end
end

local function onProficiencyInventoryChange(player, slot)
	if slot ~= InventorySlotLeft and slot ~= InventorySlotRight then
		return
	end

	cancelEquipmentRefresh()
	equipmentRefreshEvent = scheduleEvent(function()
		equipmentRefreshEvent = nil
		if not WeaponProficiency.window or not WeaponProficiency.window:isVisible() then
			return
		end

		local localPlayer = g_game.getLocalPlayer()
		if not localPlayer then
			return
		end

		for _, inventorySlot in ipairs({InventorySlotLeft, InventorySlotRight}) do
			local equippedItem = localPlayer:getInventoryItem(inventorySlot)
			local itemType = equippedItem and g_things.getThingType(equippedItem:getId(), ThingCategoryItem)
			local marketData = itemType and itemType:getMarketData()
			local marketCategory = marketData and marketData.category
			if equippedItem and marketCategory and WeaponCategoryToString[marketCategory] then
				local displayedItem = WeaponProficiency.displayItemPanel
					and WeaponProficiency.displayItemPanel:getChildById("item"):getItem()
				if not displayedItem or displayedItem:getId() ~= equippedItem:getId() then
					requestOpenWindow(equippedItem)
				end
				return
			end
		end
	end, 100)
end

local function getAllWeaponsMarketCategory()
	return MarketCategory.WeaponsAll
		or (WeaponStringToCategory and WeaponStringToCategory["Weapons: All"])
		or MarketCategory.MetaWeapons
		or MarketCategory.All
end

local function isEmptyTable(value)
	return type(value) ~= "table" or next(value) == nil
end

local function isEmptyString(value)
	return value == nil or tostring(value) == ""
end

local function matchText(searchText, itemText)
	local needle = tostring(searchText or ""):lower()
	if needle == "" then return true end
	return tostring(itemText or ""):lower():find(needle, 1, true) ~= nil
end

local function translateProficiencyVocation(vocation)
	vocation = tonumber(vocation) or 0
	return vocation > 10 and vocation - 10 or vocation
end

function init()
	connect(g_game, {
		onGameStart = create,
		onGameEnd = destroy
	})

	connect(g_game, { onInspection = onInspection })
	connect(LocalPlayer, { onInventoryChange = onProficiencyInventoryChange })
	connect(g_things, { onLoadDat = loadProficiencyJson })
	ProtocolGame.registerExtendedOpcode(WeaponProficiency.OPCODE, onExtendedOpcode)
	WeaponProficiency.networkHandlers = {
		config = onWeaponProficiencyConfig,
		catalog = onWeaponProficiencyCatalog,
		full = onWeaponProficiencyBatch,
		summaries = onWeaponProficiencyBatch,
		item = onWeaponProficiencyData,
		summary = onWeaponProficiencyData,
		notify = onProficiencyNotificationData,
		error = onWeaponProficiencyError
	}

	if g_game.isOnline() then
		create()
	end
end

function terminate()
	disconnect(g_game, {
		onGameStart = create,
		onGameEnd = destroy
	})
	disconnect(g_game, { onInspection = onInspection })
	disconnect(LocalPlayer, { onInventoryChange = onProficiencyInventoryChange })
	disconnect(g_things, { onLoadDat = loadProficiencyJson })
	cancelEquipmentRefresh()
	ProtocolGame.unregisterExtendedOpcode(WeaponProficiency.OPCODE)
	destroy()
end

function create()
	WeaponProficiency.window = g_ui.displayUI('weapon_proficiency')
	if not WeaponProficiency.window then
		return
	end

	WeaponProficiency.displayItemPanel = WeaponProficiency.window:recursiveGetChildById("itemPanel")
	WeaponProficiency.perkPanel = WeaponProficiency.window:recursiveGetChildById("bonusProgressBackground")
	WeaponProficiency.bonusDetailPanel = WeaponProficiency.window:recursiveGetChildById("bonusDetailBackground")
	WeaponProficiency.optionFilter = WeaponProficiency.window:recursiveGetChildById("classFilter")
	WeaponProficiency.starProgressPanel = WeaponProficiency.window:recursiveGetChildById("starsPanelBackground")
	WeaponProficiency.itemListScroll = WeaponProficiency.window:recursiveGetChildById("itemListScroll")
	WeaponProficiency.vocationWarning = WeaponProficiency.window:recursiveGetChildById("vocationWarning")
	WeaponProficiency.treeScroll = WeaponProficiency.window:recursiveGetChildById("proficiencyTreeScroll")
	WeaponProficiency.treeContent = WeaponProficiency.window:recursiveGetChildById("proficiencyTreeContent")
	WeaponProficiency.window:hide()

	WeaponProficiency.button = modules.client_topmenu.addRightGameToggleButton("proficiencyButton", tr("Weapon Proficiency"), "/images/topbuttons/proficiency", toggle)
	WeaponProficiency.button:setOn(false)

	onGameStart()
end

function destroy()
	onGameEnd()

	if WeaponProficiency.button then
		WeaponProficiency.button:destroy()
		WeaponProficiency.button = nil
	end

	if WeaponProficiency.window then
		WeaponProficiency.window:destroy()
		WeaponProficiency.window = nil
	end
end

function onGameStart()
	WeaponProficiency.allProficiencyRequested = false
	WeaponProficiency.openAfterFetch = false
	WeaponProficiency.fetchInProgress = false
	WeaponProficiency.saveWeaponMissing = false
	WeaponProficiency.firstItemRequested = nil
	WeaponProficiency.pendingTargetItemId = nil
	WeaponProficiency.pendingTargetCategory = nil
	WeaponProficiency.catalogFetchInProgress = false
	WeaponProficiency.catalogFiltered = false
	WeaponProficiency.catalogConfirmedItemIds = {}
	WeaponProficiency.catalogMetadata = {}
	WeaponProficiency.currentPage = 1
	loadProficiencyJson()
	sendPacket("config", {})
end

function onGameEnd()
	cancelEquipmentRefresh()
	if not WeaponProficiency.window then
		return
	end

	WeaponProficiency.window:hide()
	if WeaponProficiency.button then
		WeaponProficiency.button:setOn(false)
	end
	WeaponProficiency:reset()

	if WeaponProficiency.warningWindow then
		WeaponProficiency.warningWindow:destroy()
		WeaponProficiency.warningWindow = nil
	end
end

function loadProficiencyJson()
	ProficiencyData:loadProficiencyJson()
end

sendPacket = function(action, data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedOpcode(WeaponProficiency.OPCODE, json.encode({ action = action, data = data }))
	end
end

function onExtendedOpcode(protocol, opcode, buffer)
	local ok, payload = pcall(function()
		return json.decode(buffer)
	end)

	if not ok or type(payload) ~= "table" then
		g_logger.error("[WeaponProficiency] Failed to decode extended opcode payload.")
		return
	end

	local handler = WeaponProficiency.networkHandlers[payload.action]
	if handler then
		handler(payload.data)
	end
end

function show()
	WeaponProficiency.window:show(true)
	WeaponProficiency.window:raise()
	WeaponProficiency.window:focus()
	if WeaponProficiency.button then
		WeaponProficiency.button:setOn(true)
	end
end

function hide()
	WeaponProficiency.window:hide()
	if WeaponProficiency.button then
		WeaponProficiency.button:setOn(false)
	end
end

function toggle()
	if WeaponProficiency.window:isVisible() then
		hide()
	else
		requestOpenWindow()
	end
end

function getUnknownMarketCategory(itemType)
	local marketData = itemType and itemType:getMarketData()
	return marketData and marketData.category or getAllWeaponsMarketCategory()
end

local function getItemMarketCategory(item)
	if not item then
		return getAllWeaponsMarketCategory()
	end

	local itemType = g_things.getThingType(item:getId(), ThingCategoryItem)
	return getUnknownMarketCategory(itemType)
end

function sortWeaponProficiency(marketCategory)
	local itemList = WeaponProficiency.itemList[marketCategory]
	if not itemList then return false end

	table.sort(itemList, function(a, b)
		local idA, idB = a.marketData.showAs, b.marketData.showAs

		local expA = WeaponProficiency.cacheList[idA] and WeaponProficiency.cacheList[idA].exp or 0
		local expB = WeaponProficiency.cacheList[idB] and WeaponProficiency.cacheList[idB].exp or 0

		if expA == expB then
			return a.marketData.name:lower() < b.marketData.name:lower()
		end
		return expA > expB
	end)
	return true
end

function requestOpenWindow(redirectItem)
	WeaponProficiency.openAfterFetch = false
	local category = "Weapons: All"
	local targetItemId = nil
	local equippedWeapon = nil
	local player = g_game.getLocalPlayer()
	if player then
		for _, slot in ipairs({InventorySlotLeft, InventorySlotRight}) do
			local item = player:getInventoryItem(slot)
			if item and WeaponCategoryToString[getItemMarketCategory(item)] then
				equippedWeapon = item
				break
			end
		end
	end

	if equippedWeapon then
		category = WeaponCategoryToString[getItemMarketCategory(equippedWeapon)]
		targetItemId = equippedWeapon:getId()
	end

	if redirectItem then
		category = WeaponCategoryToString[getItemMarketCategory(redirectItem)]
		targetItemId = redirectItem:getId()
	end

	if WeaponProficiency.firstItemRequested then
		category = WeaponCategoryToString[getItemMarketCategory(WeaponProficiency.firstItemRequested)]
		targetItemId = WeaponProficiency.firstItemRequested:getId()
		WeaponProficiency.firstItemRequested = nil
	end

	WeaponProficiency.pendingTargetItemId = targetItemId
	WeaponProficiency.pendingTargetCategory = category

	WeaponProficiency.allProficiencyRequested = true

	local focusFirstChild = targetItemId == nil
	if category == "Weapons: All" then
		sortWeaponProficiency(getAllWeaponsMarketCategory())
	end

	if not WeaponProficiency.catalogFiltered and not WeaponProficiency.catalogFetchInProgress then
		local itemIds = WeaponProficiency:getKnownItemIds()
		WeaponProficiency.catalogConfirmedItemIds = {}
		WeaponProficiency.catalogMetadata = {}
		WeaponProficiency.catalogFetchInProgress = true
		WeaponProficiency.fetchInProgress = true
		sendPacket("catalog", {itemIds = itemIds})
	end

	WeaponProficiency:onClearSearch(true)
	WeaponProficiency:onWeaponCategoryChange(
		category, nil, targetItemId, focusFirstChild, false,
		WeaponProficiency.catalogFetchInProgress
	)
	if not WeaponProficiency.catalogFetchInProgress then
		WeaponProficiency.pendingTargetItemId = nil
		WeaponProficiency.pendingTargetCategory = nil
	end
	show()
end

function onInspection(inspectType, itemName, item, descriptions)
	if inspectType ~= 1 then
		return
	end

	local infoWidget = WeaponProficiency.window:recursiveGetChildById("infoWidget")
	local text = itemName
	for _, data in pairs(descriptions) do
		text = text .. string.format("\n%s: %s", data[1], wrapTextByWords(data[2], 52))
	end

	infoWidget:setTooltip(text)
end

function onWeaponProficiency(itemId, experience, perks, marketCategory, data)
	local current = WeaponProficiency.cacheList[itemId] or {}
	current.exp = experience
	current.perks = perks
	current.proficiencyId = tonumber(data and data.proficiencyId) or current.proficiencyId
	current.level = tonumber(data and data.level) or current.level or 0
	current.maxLevel = tonumber(data and data.maxLevel) or current.maxLevel or 0
	current.maxExp = tonumber(data and data.maxExp) or current.maxExp or 0
	current.xpClass = data and data.xpClass or current.xpClass
	current.requiredLevel = tonumber(data and data.requiredLevel) or current.requiredLevel or 0
	current.restrictVocation = tonumber(data and data.restrictVocation) or current.restrictVocation or 0
	current.canChange = data and data.canChange == true
	WeaponProficiency.cacheList[itemId] = current
	WeaponProficiency.tooltipRequests[itemId] = nil
	if marketCategory then
		sortWeaponProficiency(marketCategory)
	end
	WeaponProficiency:onUpdateSelectedProficiency(itemId)
end

function onWeaponProficiencyConfig(data)
	if type(data) ~= "table" or type(data.xp) ~= "table" then
		return
	end

	local classes = {"regular", "knight", "crossbow"}
	local maximumStages = 0
	for _, className in ipairs(classes) do
		if type(data.xp[className]) == "table" then
			maximumStages = math.max(maximumStages, #data.xp[className])
		end
	end
	if maximumStages == 0 then
		return
	end

	local synchronized = {}
	for stage = 1, maximumStages do
		local row = {}
		local complete = true
		for _, className in ipairs(classes) do
			local value = tonumber(data.xp[className] and data.xp[className][stage])
			if not value then
				complete = false
				break
			end
			row[className] = value
		end
		if not complete then
			break
		end
		synchronized[#synchronized + 1] = row
	end
	if #synchronized == 0 then
		return
	end

	ExperienceTable = synchronized

	if WeaponProficiency.window and WeaponProficiency.window:isVisible()
		and WeaponProficiency.displayItemPanel then
		local currentItem = WeaponProficiency.displayItemPanel:getChildById("item"):getItem()
		if currentItem then
			WeaponProficiency:onUpdateSelectedProficiency(currentItem:getId())
			WeaponProficiency:refreshVisiblePageProgress()
		end
	end
end

function onProficiencyNotification(itemId, experience, hasUnnusedPerk, thingType, data)
	local itemCache = WeaponProficiency.cacheList[itemId]
	if not itemCache then
		WeaponProficiency.cacheList[itemId] = { exp = experience, perks = {} }
	else
		if experience > 0 then
			itemCache.exp = experience
		end
	end
	local itemCache = WeaponProficiency.cacheList[itemId]
	itemCache.proficiencyId = tonumber(data and data.proficiencyId) or itemCache.proficiencyId
	itemCache.level = tonumber(data and data.level) or itemCache.level or 0
	itemCache.maxLevel = tonumber(data and data.maxLevel) or itemCache.maxLevel or 0
	itemCache.maxExp = tonumber(data and data.maxExp) or itemCache.maxExp or 0
	itemCache.xpClass = data and data.xpClass or itemCache.xpClass
	itemCache.canChange = data and data.canChange == true

	local marketCategory = WeaponProficiency:getMarketCategoryByItemId(itemId)
	if marketCategory then sortWeaponProficiency(marketCategory) end
	if modules.game_interface.StatsBar and modules.game_interface.StatsBar.onUpdateProficiencyData then
		modules.game_interface.StatsBar.onUpdateProficiencyData(WeaponProficiency.cacheList[itemId], hasUnnusedPerk, thingType)
	end
	if modules.game_tooltip and modules.game_tooltip.m_TooltipFunction
		and modules.game_tooltip.m_TooltipFunction.refreshCurrent then
		modules.game_tooltip.m_TooltipFunction.refreshCurrent()
	end
end

function onWeaponProficiencyBatch(data)
	if type(data) ~= "table" then
		return
	end

	for _, entry in ipairs(data.items or {}) do
		onWeaponProficiencyData(entry)
	end
	if data.complete == true then
		WeaponProficiency.fetchInProgress = false
		WeaponProficiency:refreshVisiblePageProgress()
	end
end

function onWeaponProficiencyCatalog(data)
	if type(data) ~= "table" then return end
	for _, itemId in ipairs(data.itemIds or {}) do
		itemId = tonumber(itemId) or 0
		if itemId > 0 then WeaponProficiency.catalogConfirmedItemIds[itemId] = true end
	end
	for _, entry in ipairs(data.items or {}) do
		local itemId = tonumber(entry.itemId) or 0
		if itemId > 0 then
			WeaponProficiency.catalogConfirmedItemIds[itemId] = true
			WeaponProficiency.catalogMetadata[itemId] = {
				requiredLevel = tonumber(entry.requiredLevel) or 0,
				restrictVocation = tonumber(entry.restrictVocation) or 0
			}
		end
	end
	if data.complete == true then
		WeaponProficiency.catalogFetchInProgress = false
		WeaponProficiency.catalogFiltered = true
		WeaponProficiency.fetchInProgress = false
		WeaponProficiency:filterItemsByConfirmedProfiles()
		local targetItemId = WeaponProficiency.pendingTargetItemId
		local targetCategory = WeaponProficiency.pendingTargetCategory
			or WeaponProficiency.currentCategory or "Weapons: All"
		WeaponProficiency:onWeaponCategoryChange(
			targetCategory,
			WeaponProficiency.currentSearchText,
			targetItemId, targetItemId == nil, false, false
		)
		WeaponProficiency.pendingTargetItemId = nil
		WeaponProficiency.pendingTargetCategory = nil
	end
end

function onWeaponProficiencyData(data)
	if type(data) ~= "table" then
		return
	end

	local itemId = tonumber(data.itemId or 0) or 0
	if itemId <= 0 then
		return
	end
	local perks = {}
	if type(data.perks) == "table" then
		for level, choice in pairs(data.perks) do
			level, choice = tonumber(level), tonumber(choice)
			if level and choice then perks[level] = choice end
		end
	end
	local marketCategory = WeaponProficiency:getMarketCategoryByItemId(itemId)

	onWeaponProficiency(itemId, tonumber(data.exp or 0) or 0, perks, marketCategory, data)
	if modules.game_tooltip and modules.game_tooltip.m_TooltipFunction
		and modules.game_tooltip.m_TooltipFunction.refreshCurrent then
		modules.game_tooltip.m_TooltipFunction.refreshCurrent()
	end
end

function onProficiencyNotificationData(data)
	if type(data) ~= "table" then
		return
	end

	local itemId = tonumber(data.itemId or 0) or 0
	local thingType = WeaponProficiency:getThingTypeByItemId(itemId)
	if not thingType then
		return
	end

	onProficiencyNotification(itemId, tonumber(data.exp or 0) or 0, data.hasUnnusedPerk == true, thingType, data)
end

function onWeaponProficiencyError(data)
	if type(data) ~= "table" then return end
	if type(data.item) == "table" then onWeaponProficiencyData(data.item) end
	if data.message and modules.game_textmessage then
		modules.game_textmessage.displayFailureMessage(data.message)
	end
end

local function canChangeWeaponPerks()
	local player = g_game.getLocalPlayer()
	if not player or not g_game.isOnline() then
		return false
	end
	return bit.band(player:getStates(), PlayerStates.Pz) ~= 0
end

local function isMasteryAchieved(targetItem)
	if not targetItem then
		return false
	end
	
	local cached = WeaponProficiency.cacheList[targetItem:getId()]
	local proficiencyId = cached and cached.proficiencyId
	if not proficiencyId then return false end
	local maxExperience = tonumber(cached.maxExp)
		or ProficiencyData:getMaxExperience(ProficiencyData:getPerkLaneCount(proficiencyId), targetItem)
	local weaponEntry = WeaponProficiency.cacheList[targetItem:getId()]
	local currentExperience = weaponEntry and weaponEntry.exp or 0

	return currentExperience >= maxExperience
end

local function enableBonusIcon(bonusIcon, iconGrey, hightLightWidget, borderWidget, bonusDescWidget, bonusTooltip, augmentIconDarker, perkData)
	if bonusIcon.blocked or bonusIcon.active or bonusIcon.locked then
		return true
	end

	local visible = not iconGrey:isVisible()

	iconGrey:setVisible(false)
	hightLightWidget:setVisible(true)
	borderWidget:setImageSource("/modules/game_proficiency/proficiency/border-weaponmasterytreeicons-active")

	bonusDescWidget:setImageSource("")
	bonusDescWidget:setText(bonusTooltip)
	if #tostring(bonusTooltip or "") > 57 then
		bonusDescWidget:setTooltip(bonusTooltip)
	end

	if perkData and perkData.Type == PERK_SPELL_AUGMENT then
		augmentIconDarker:setVisible(false)
	end

	bonusIcon.active = true
end

local function disableBonusIcon(iconGrey, hightLightWidget, borderWidget, bonusDescWidget, augmentIconDarker, perkData)
	iconGrey:setVisible(true)
	iconGrey:setOpacity(1)
	hightLightWidget:setVisible(false)
	borderWidget:setImageSource("/modules/game_proficiency/proficiency/border-weaponmasterytreeicons-inactive")

	bonusDescWidget:setImageSource("/modules/game_proficiency/proficiency/icon-lock-grey")
	bonusDescWidget:setText("")
	bonusDescWidget:removeTooltip()

	if perkData and perkData.Type == PERK_SPELL_AUGMENT then
		augmentIconDarker:setVisible(true)
		augmentIconDarker:setOpacity(1)
	end
end

local function disableOtherBonusIcons(currentPerkPanel, currentBonusIcon)
	for i = 0, 2 do
		local bonusIcon = currentPerkPanel:getChildById("bonusIcon" .. i)
		if bonusIcon and bonusIcon ~= currentBonusIcon and bonusIcon.active then
			bonusIcon.blocked = false
			bonusIcon.active = false
			local iconGrey = bonusIcon:getChildById("icon-grey")
			local hightLightWidget = bonusIcon:getChildById("highlight")
			local borderWidget = bonusIcon:getChildById("border")
			local augmentIconDarker = bonusIcon:getChildById("iconPerks-grey")
			local augmentIcon = bonusIcon:getChildById("iconPerks")

			iconGrey:setVisible(true)
			iconGrey:setOpacity(1)
			hightLightWidget:setVisible(false)
			borderWidget:setImageSource("/modules/game_proficiency/proficiency/border-weaponmasterytreeicons-inactive")
			if augmentIcon:isVisible() then
				augmentIconDarker:setVisible(true)
				augmentIconDarker:setOpacity(1)
			end
		end
	end
end

local function updatePercentWidgets(child, currentExperience, _index, itemType)
	if not child then
		return
	end

	local percentWidget = child:getChildById("bonusSelectProgress")
	local starWidget = WeaponProficiency.starProgressPanel:getChildById("starWidget" .. _index)
	local starProgress = starWidget:getChildById("starProgress")

	local percent = ProficiencyData:getLevelPercent(currentExperience, _index, itemType)
	local maxLevelExperience = ProficiencyData:getMaxExperienceByLevel(_index, itemType)

	percentWidget:setPercent(percent)
	starProgress:setPercent(percent)
	starProgress:setTooltip(string.format("%s / %s", comma_value(currentExperience), comma_value(maxLevelExperience)))

	if percent >= 100 then
		local iconTypo = isMasteryAchieved(itemType) and "gold" or "silver"
		starWidget:getChildById("star"):setImageSource(string.format(
			"/modules/game_proficiency/proficiency/icon-star-tiny-%s", iconTypo))
		for _, widget in pairs(child.currentPerkPanel:getChildren()) do
			widget.blocked = false
		end
	end
end

local function getItemRequirements(itemData)
	local marketData = itemData and itemData.marketData or {}
	local itemId = tonumber(marketData.showAs) or 0
	local metadata = WeaponProficiency.catalogMetadata[itemId]
		or WeaponProficiency.cacheList[itemId]
		or {}
	return tonumber(metadata.requiredLevel) or tonumber(marketData.requiredLevel) or 0,
		tonumber(metadata.restrictVocation) or tonumber(marketData.restrictVocation) or 0
end

local function checkSortOptions(itemData)
	if WeaponProficiency.filters["oneButton"] then
		if itemData.thingType:getClothSlot() ~= 6 then
			return false
		end
	end

	if WeaponProficiency.filters["twoButton"] then
		if itemData.thingType:getClothSlot() ~= 0 then
			return false
		end
	end
	return true
end

local function setupPerkIconGrey(perkData, iconSource, iconClip, iconGrey, augmentIconNormal, augmentIconDarker)
	if perkData.Type == PERK_SPELL_AUGMENT then
		iconGrey:setImageSource(string.format("%s-off", iconSource))
		iconGrey:setImageClip(string.format("%s 64 64", iconClip))
		local augmentIconClip = ProficiencyData:getAugmentIconClip(perkData)
		augmentIconNormal:setVisible(true)
		augmentIconDarker:setVisible(true)
		augmentIconNormal:setImageClip(string.format("%s 32 32", augmentIconClip))
		local x = tonumber(augmentIconClip:match("^(%d+)")) or 0
		augmentIconDarker:setImageClip(string.format("%d 32 32 32", x))
	else
		local x = tonumber(iconClip:match("^(%d+)")) or 0
		iconGrey:setImageSource(iconSource)
		iconGrey:setImageClip(string.format("%d 64 64 64", x))
	end
end

local function createHoverHandler(bonusIcon, iconGrey, augmentIconDarker)
	return function(widget, hovered)
		if not bonusIcon.active and not bonusIcon.locked and not bonusIcon.blocked then
			local opacity = hovered and 0.5 or 1
			iconGrey:setOpacity(opacity)
			augmentIconDarker:setOpacity(opacity)
		end
	end
end

local function createClickHandler(bonusIcon, currentPerkPanel, bonusDetail, hightLightWidget, borderWidget, iconGrey, augmentIconDarker, bonusTooltip, perkData, itemId)
	return function()
		if bonusIcon.blocked or bonusIcon.active or bonusIcon.locked then return end
		disableOtherBonusIcons(currentPerkPanel, bonusIcon)
		enableBonusIcon(bonusIcon, iconGrey, hightLightWidget, borderWidget, bonusDetail:recursiveGetChildById("bonusName"), bonusTooltip, augmentIconDarker, perkData)
		WeaponProficiency:checkPerksMatch(itemId)
	end
end

function WeaponProficiency:reset()
	self.cacheList = {}
	self.allProficiencyRequested = false
	self.openAfterFetch = false
	self.fetchInProgress = false
	self.catalogFetchInProgress = false
	self.catalogFiltered = false
	self.catalogConfirmedItemIds = {}
	self.catalogMetadata = {}
	self.tooltipRequests = {}
	self.pendingTargetItemId = nil
	self.pendingTargetCategory = nil
	self.currentPage = 1
	self.pageCount = 1
end

function WeaponProficiency:getTooltipProgress(itemId)
	itemId = tonumber(itemId) or 0
	local data = self.cacheList[itemId]
	if not data or not data.proficiencyId then
		local thingType = self:getThingTypeByItemId(itemId)
		if thingType and g_game.isOnline() and sendPacket and not self.tooltipRequests[itemId] then
			self.tooltipRequests[itemId] = true
			sendPacket("summary", {itemId = itemId})
		end
		return nil
	end
	local profile = ProficiencyData:getContentById(data.proficiencyId)
	local thingType = self:getThingTypeByItemId(itemId)
	if not profile or not thingType then return nil end
	if #ExperienceTable == 0 then
		local maxLevel = #profile.Levels
		local progressionLevel = math.max(0, tonumber(data.level) or 0)
		local level = math.min(maxLevel, progressionLevel)
		local exp = tonumber(data.exp) or 0
		local maxExp = math.max(1, tonumber(data.maxExp) or exp)
		return {
			exp = exp,
			level = level,
			maxLevel = maxLevel,
			floorExp = 0,
			ceilingExp = maxExp,
			nextExp = maxExp,
			maxExp = maxExp,
			percent = exp >= maxExp and 100 or math.floor((exp / maxExp) * 100)
		}
	end
	local item = Item.create(thingType:getId())
	local vocation = ProficiencyData:getWeaponProfessionType(item)
	local maxLevel = math.min(#profile.Levels, #ExperienceTable)
	local progressionMaximum = math.min(maxLevel + 2, #ExperienceTable)
	local progressionLevel = math.max(0, math.min(progressionMaximum, tonumber(data.level) or 0))
	local level = math.min(maxLevel, progressionLevel)
	local floorExp = progressionLevel > 0 and (ExperienceTable[progressionLevel][vocation] or 0) or 0
	local ceilingExp = progressionLevel < progressionMaximum
		and (ExperienceTable[progressionLevel + 1][vocation] or floorExp + 1)
		or math.max(floorExp, tonumber(data.maxExp) or floorExp)
	local maxExp = math.max(1, tonumber(data.maxExp) or ceilingExp)
	local exp = tonumber(data.exp) or 0
	local stageSize = math.max(1, ceilingExp - floorExp)
	local percent = exp >= maxExp and 100
		or math.floor(math.max(0, math.min(1, (exp - floorExp) / stageSize)) * 100)
	return {exp = tonumber(data.exp) or 0, level = level, maxLevel = maxLevel,
		floorExp = floorExp, ceilingExp = ceilingExp, nextExp = math.min(maxExp, ceilingExp),
		maxExp = maxExp, percent = percent}
end

function WeaponProficiency:getKnownItemIds()
	local itemIds = {}
	local added = {}
	local allItems = self.itemList[getAllWeaponsMarketCategory()] or {}
	for _, entry in ipairs(allItems) do
		local itemId = entry.marketData and entry.marketData.showAs
		if itemId and not added[itemId] then
			added[itemId] = true
			table.insert(itemIds, itemId)
		end
	end
	return itemIds
end

function WeaponProficiency:filterItemsByConfirmedProfiles()
	local confirmed = self.catalogConfirmedItemIds or {}
	for category, entries in pairs(self.itemList) do
		local filtered = {}
		for _, entry in ipairs(entries) do
			local itemId = entry.marketData and tonumber(entry.marketData.showAs) or 0
			if itemId > 0 and confirmed[itemId] then
				filtered[#filtered + 1] = entry
			end
		end
		self.itemList[category] = filtered
	end
end

function WeaponProficiency:getThingTypeByItemId(itemId)
	local allItems = self.itemList[getAllWeaponsMarketCategory()] or {}
	for _, entry in ipairs(allItems) do
		if entry.marketData and entry.marketData.showAs == itemId then
			return entry.thingType
		end
	end
	return nil
end

function WeaponProficiency:getMarketCategoryByItemId(itemId)
	local allItems = self.itemList[getAllWeaponsMarketCategory()] or {}
	for _, entry in ipairs(allItems) do
		if entry.marketData and entry.marketData.showAs == itemId then
			return entry.marketData.category
		end
	end
	return nil
end

function WeaponProficiency:updateMainButtons(currentData)
	local hasPerks = table.size(currentData.perks) > 0
	local enableReset = canChangeWeaponPerks() and hasPerks
	local resetButton = self.window:getChildById("reset")
	local applyButton = self.window:getChildById("apply")
	local okButton = self.window:getChildById("ok")
	local closeButton = self.window:getChildById("close")

	resetButton:setOn(enableReset)
	applyButton:setOn(hasPerks)
	okButton:setOn(hasPerks)

	local resetTooltip = "Reset your perks"
	if not canChangeWeaponPerks() then
		resetTooltip = "You can only reset your perks in a protection zone."
	elseif isEmptyTable(currentData.perks) then
		resetTooltip = "You don't have any perks to reset."
	end

	resetButton:setTooltip(resetTooltip)
	applyButton:setTooltip(hasPerks and "Apply your selected perks." or "No perks are selected.")
	okButton:setTooltip(hasPerks and "Apply your selected perks." or "No perks are selected.")
	closeButton:setText("Close")
end

function WeaponProficiency:createItemCache()
	local allWeaponsCategory = getAllWeaponsMarketCategory()
	if allWeaponsCategory == nil then
		g_logger.error("[WeaponProficiency] No aggregate market category is available for weapons.")
		return
	end

	self.itemList = {}
	self.catalogFetchInProgress = false
	self.catalogFiltered = false
	self.catalogConfirmedItemIds = {}
	self.catalogMetadata = {}
	self.itemList[allWeaponsCategory] = {}
	for _, v in pairs(self.ItemCategory) do
		self.itemList[v] = {}
	end

	local types = g_things.getThingTypes(ThingCategoryItem)
	for index, itemType in pairs(types) do
		if itemType:isMarketable() then
		local item = Item.create(itemType:getId())
		local marketData = itemType:getMarketData()

		if not isEmptyTable(marketData) and marketData.category and self.itemList[marketData.category] then
			local showAs = tonumber(marketData.showAs) or 0
			if showAs <= 0 then
				showAs = itemType:getId()
			end
			marketData.showAs = showAs
			item:setId(marketData.showAs)
			if isEmptyString(marketData.name) then
				marketData.name = g_things.getCyclopediaItemName(itemType:getId())
			end
			if isEmptyString(marketData.name) then
				marketData.name = string.format("Weapon %d", itemType:getId())
			end

			local marketItem = { displayItem = item, thingType = itemType, marketData = marketData }
			table.insert(self.itemList[marketData.category], marketItem)
			table.insert(self.itemList[allWeaponsCategory], marketItem)
		end
		end
	end

	local function sortByName(a, b)
		local nameA = a.marketData.name:lower()
		local nameB = b.marketData.name:lower()
		return nameA < nameB
	end

	for _, v in pairs(self.itemList) do
		table.sort(v, sortByName)
	end
end

function WeaponProficiency:onItemListValueChange(scroll, value, delta)
	if value == self.oldScrollValue and self.oldScrollValue ~= nil then
		return
	end

	self.oldScrollValue = value
	local itemListWidget = self.window:recursiveGetChildById("itemList")

	if #self.listData > 30 and #self.listData <= 35 then
   		itemListWidget:setVirtualOffset({x = 0, y = (delta > 0 and 8 or 0)})
		return true
	end

    local itemsPerRow = 5
    local rowsVisible = 8
    local itemsVisible = itemsPerRow * rowsVisible
    local totalItems = #self.listData

    local startLabel = (value * itemsPerRow) + 1
    local endLabel = startLabel + itemsVisible - 1

    local currentWidgetIndex = startLabel

    self.offset = self.offset + ((value % 5) * 2)

    if self.offset > 64 or value == 0 then
        self.offset = 0
    end

    itemListWidget:setVirtualOffset({x = 0, y = self.offset})

	local currentItem = self.displayItemPanel:getChildById("item"):getItem()

    for k, widget in pairs(itemListWidget:getChildren()) do
		local entry = currentWidgetIndex <= totalItems and self.listData[currentWidgetIndex] or nil
		if not entry then
			widget:setVisible(false)
		else
			widget:getChildById("item"):setItem(entry.displayItem)
			widget:setTooltip(entry.marketData.name)
			widget.cache = entry
			widget:setVisible(true)

			if widget:isFocused() then
				itemListWidget:focusChild(nil, MouseFocusReason, false, true)
			end

			if currentItem and currentItem:getId() == entry.marketData.showAs then
				itemListWidget:focusChild(widget, MouseFocusReason, false, true)
			end

			local cacheEntry = self.cacheList[entry.marketData.showAs] or nil
			local profile = cacheEntry and cacheEntry.proficiencyId
				and ProficiencyData:getContentById(cacheEntry.proficiencyId)
			local perkLevels = profile and #profile.Levels or 0
			local weaponLevel = math.min(
				perkLevels,
				tonumber(cacheEntry and cacheEntry.level)
					or ProficiencyData:getCurrentLevelByExp(entry.displayItem, (cacheEntry and cacheEntry.exp or 0), true)
			)
			local starPanel = widget:getChildById("starsBackground")

			local mastery = isMasteryAchieved(entry.displayItem)
			starPanel:destroyChildren()
			if weaponLevel > 0 then
				for i = 1, weaponLevel do
					local _star = g_ui.createWidget("MiniStar", starPanel)
					if mastery then
						_star:setImageSource("/modules/game_proficiency/proficiency/icon-star-tiny-gold")
					end
				end
			end
			currentWidgetIndex = currentWidgetIndex + 1
		end
    end
end

local function populateProficiencyItemWidget(self, widget, data)
	widget:getChildById("item"):setItem(data.displayItem)
	widget:setVisible(true)
	widget:setTooltip(data.marketData.name)
	widget.cache = data

	local cacheEntry = self.cacheList[data.marketData.showAs]
	local profile = cacheEntry and cacheEntry.proficiencyId
		and ProficiencyData:getContentById(cacheEntry.proficiencyId)
	local perkLevels = profile and #profile.Levels or 0
	local weaponLevel = math.min(
		perkLevels,
		tonumber(cacheEntry and cacheEntry.level)
			or ProficiencyData:getCurrentLevelByExp(data.displayItem, cacheEntry and cacheEntry.exp or 0, true)
	)
	local starPanel = widget:getChildById("starsBackground")
	starPanel:destroyChildren()
	local mastery = isMasteryAchieved(data.displayItem)
	for _ = 1, math.max(0, weaponLevel) do
		local star = g_ui.createWidget("MiniStar", starPanel)
		if mastery then
			star:setImageSource("/modules/game_proficiency/proficiency/icon-star-tiny-gold")
		end
	end
end

local function getProficiencyPageSlot(itemListWidget, slot)
	local widget = itemListWidget:recursiveGetChildById("widget_" .. slot)
	if widget then return widget end

	local children = itemListWidget:getChildren()
	widget = children and children[slot + 1] or nil
	if widget then widget:setId("widget_" .. slot) end
	return widget
end

function WeaponProficiency:requestVisiblePageData()
	if not g_game.isOnline() or #self.listData == 0 then return end
	local first = ((self.currentPage - 1) * self.pageSize) + 1
	local last = math.min(first + self.pageSize - 1, #self.listData)
	local itemIds = {}
	for index = first, last do
		local entry = self.listData[index]
		if entry and entry.marketData and entry.marketData.showAs then
			itemIds[#itemIds + 1] = entry.marketData.showAs
		end
	end
	if #itemIds == 0 then return end

	self.fetchInProgress = true
	sendPacket("fetch", {itemIds = itemIds})
end

function WeaponProficiency:refreshWeaponPage(targetItemId, focusFirstChild, requestData)
	if not self.window then return end
	local itemListWidget = self.window:recursiveGetChildById("itemList")
	if not itemListWidget then return end

	self.pageCount = math.max(1, math.ceil(#self.listData / self.pageSize))
	if targetItemId then
		for index, entry in ipairs(self.listData) do
			if entry.marketData.showAs == targetItemId then
				self.currentPage = math.floor((index - 1) / self.pageSize) + 1
				break
			end
		end
	end
	self.currentPage = math.max(1, math.min(self.currentPage, self.pageCount))

	itemListWidget.onChildFocusChange = nil
	local targetWidget = nil
	local first = ((self.currentPage - 1) * self.pageSize) + 1
	for slot = 0, self.pageSize - 1 do
		local widget = getProficiencyPageSlot(itemListWidget, slot)
		local entry = self.listData[first + slot]
		if widget then
			if entry then
				populateProficiencyItemWidget(self, widget, entry)
				if targetItemId and entry.marketData.showAs == targetItemId then
					targetWidget = widget
				end
			else
				widget.cache = nil
				widget:setVisible(false)
			end
		end
	end

	local pageLabel = self.window:recursiveGetChildById("pageLabel")
	if pageLabel then pageLabel:setText(string.format("%d / %d", self.currentPage, self.pageCount)) end
	local previousPage = self.window:recursiveGetChildById("previousPage")
	local nextPage = self.window:recursiveGetChildById("nextPage")
	if previousPage then previousPage:setOn(self.currentPage > 1) end
	if nextPage then nextPage:setOn(self.currentPage < self.pageCount) end

	itemListWidget.onChildFocusChange = function(_, focused)
		if focused and focused.cache then
			modules.game_proficiency.WeaponProficiency:onItemListFocusChange(focused.cache)
		end
	end

	local firstVisible = getProficiencyPageSlot(itemListWidget, 0)
	if targetWidget or (focusFirstChild and firstVisible and firstVisible:isVisible()) then
		itemListWidget:focusChild(targetWidget or firstVisible, MouseFocusReason, true)
	else
		itemListWidget:focusChild(nil, MouseFocusReason, false, true)
	end

	if requestData ~= false then self:requestVisiblePageData() end
end

function WeaponProficiency:refreshVisiblePageProgress()
	if not self.window or not self.window:isVisible() then return end
	local itemListWidget = self.window:recursiveGetChildById("itemList")
	if not itemListWidget then return end
	for slot = 0, self.pageSize - 1 do
		local widget = getProficiencyPageSlot(itemListWidget, slot)
		if widget and widget:isVisible() and widget.cache then
			populateProficiencyItemWidget(self, widget, widget.cache)
		end
	end
	local focused = itemListWidget:getFocusedChild()
	if focused and focused.cache then self:onItemListFocusChange(focused.cache) end
end

function WeaponProficiency:changeWeaponPage(delta)
	local page = math.max(1, math.min(self.pageCount, self.currentPage + (tonumber(delta) or 0)))
	if page == self.currentPage then return end
	self.currentPage = page
	self:refreshWeaponPage(nil, true, true)
end

function WeaponProficiency:onWeaponCategoryChange(selected, searchText, targetItemId, focusFirstChild, fromOptionChange, suppressFetch)

	if not self.window or not self.optionFilter or not self.displayItemPanel then return end
	local weaponCategory = WeaponStringToCategory[selected]
	if not weaponCategory or not sortWeaponProficiency(weaponCategory) then return end

	self.optionFilter:setCurrentOption(selected, true)
	self.currentCategory = selected
	self.currentSearchText = searchText
	self.currentPage = 1
	self.listData = {}
	for _, data in pairs(self.itemList[weaponCategory]) do
		local matchesSearch = not searchText or isEmptyString(searchText)
			or matchText(searchText:lower(), data.marketData.name:lower())
		if checkSortOptions(data) and matchesSearch then self.listData[#self.listData + 1] = data end
	end

	local currentItem = self.displayItemPanel:getChildById("item"):getItem()
	local focusId = targetItemId
	if not focusId and fromOptionChange and not focusFirstChild and currentItem then focusId = currentItem:getId() end
	self:refreshWeaponPage(focusId, focusFirstChild, not suppressFetch)
end

function WeaponProficiency:updateTreeLayout(levelCount)
	if not self.treeContent or not self.treeScroll then return end

	levelCount = math.max(1, tonumber(levelCount) or 1)
	local measuredWidth = self.treeScroll:getWidth()
	local viewportWidth = measuredWidth and measuredWidth > 0 and measuredWidth or self.treeViewportWidth
	local lanesWidth = (levelCount * self.treeColumnWidth) + 2
	local contentWidth = math.max(viewportWidth, lanesWidth)

	self.treeContent:setWidth(contentWidth)
	for _, id in ipairs({
		"starsPanelBackground", "progressBackground", "bonusProgressBackground",
		"vocationWarning", "bonusDetailBackground"
	}) do
		local widget = self.treeContent:recursiveGetChildById(id)
		if widget then widget:setWidth(contentWidth) end
	end

	local horizontalScroll = self.window:recursiveGetChildById("proficiencyTreeHorizontalScrollbar")
	if horizontalScroll then
		horizontalScroll:setEnabled(contentWidth > viewportWidth)
		horizontalScroll:setValue(0)
	end
	if self.treeScroll.setVirtualOffset then
		self.treeScroll:setVirtualOffset({x = 0, y = 0})
	end
	if self.treeScroll.updateScrollBars then
		self.treeScroll:updateScrollBars()
	end

	scheduleEvent(function()
		if not self.treeScroll then return end
		if self.treeScroll.updateScrollBars then self.treeScroll:updateScrollBars() end
	end, 0)
end

function WeaponProficiency:onItemListFocusChange(selectedCache)
	if not selectedCache or not g_game.isOnline() then return end

	local displayPanel = self.displayItemPanel:getChildById("item")
	local oldItem = displayPanel:getItem()

	if self.saveWeaponMissing and oldItem then
		self:onCloseMessage(false, oldItem, function() self:onItemListFocusChange(selectedCache) end)
		return
	end

	local displayItem = selectedCache.displayItem
	local displayItemId = displayItem:getId()
	displayPanel:setItem(displayItem)
	self.displayItemPanel:getChildById("itemNameTitle"):setText(selectedCache.marketData.name)

	self.perkPanel:destroyChildren()
	self.bonusDetailPanel:destroyChildren()
	self.starProgressPanel:destroyChildren()

	local player = g_game.getLocalPlayer()
	local requiredLevel, itemVocation = getItemRequirements(selectedCache)
	local playerVocation = translateProficiencyVocation(player:getVocation())
	local showVocationWarning = false
	
	if itemVocation > 0 then
		local demotedVoc = playerVocation > 10 and (playerVocation - 10) or playerVocation
		local vocBitMask = Bit.bit(demotedVoc)
		showVocationWarning = not Bit.hasBit(itemVocation, vocBitMask)
	end
	
	showVocationWarning = showVocationWarning or (player:getLevel() < requiredLevel)
	self.vocationWarning:setVisible(showVocationWarning)

	local currentData = self.cacheList[displayItemId] or {exp = 0, perks = {}}
	self.cacheList[displayItemId] = currentData


	if g_game.inspectionObject then
		g_game.inspectionObject(3, displayItemId, 0)
	else
		local infoWidget = self.window:recursiveGetChildById("infoWidget")
		if infoWidget then
			infoWidget:setTooltip(selectedCache.marketData.name or "")
		end
	end

	if self.allProficiencyRequested then
		sendPacket("inspect", { itemId = displayItemId })
	end
	local proficiencyId = currentData.proficiencyId
	local profEntry = ProficiencyData:getContentById(proficiencyId)
	if not profEntry then return end

	self:updateTreeLayout(#profEntry.Levels)
	self:updateExperienceProgress(currentData.exp, #profEntry.Levels, displayItem)
	for i, levelData in ipairs(profEntry.Levels) do
		local widget = g_ui.createWidget("BonusSelectPanel", self.perkPanel)
		local bonusDetail = g_ui.createWidget("BonusDetailPanel", self.bonusDetailPanel)
		bonusDetail:setId("bonusDetail_" .. i)
		local starDetail = g_ui.createWidget("StarWidget", self.starProgressPanel)
		starDetail:setId("starWidget" .. i)
		widget:getChildById("bonusSelectProgress"):setPercent(0)

		local currentPerkPanel = self.perkPanelsName[#levelData.Perks] and widget:getChildById(self.perkPanelsName[#levelData.Perks])
		if currentPerkPanel then
			currentPerkPanel:setVisible(true)
			widget.currentPerkPanel = currentPerkPanel
		end

		local widgetIsBlocked = not canChangeWeaponPerks() and currentData.perks[i - 1]
		for index, perkData in ipairs(levelData.Perks) do
			local bonusIcon = currentPerkPanel:getChildById(string.format("bonusIcon%s", index - 1))
			local icon = bonusIcon:getChildById("icon")
			local iconGrey = bonusIcon:getChildById("icon-grey")
			local borderWidget = bonusIcon:getChildById("border")
			local hightLightWidget = bonusIcon:getChildById("highlight")
			local augmentIconNormal = bonusIcon:getChildById("iconPerks")
			local augmentIconDarker = bonusIcon:getChildById("iconPerks-grey")

			local iconSource, iconClip = ProficiencyData:getImageSourceAndClip(perkData)
			local bonusName, bonusTooltip = ProficiencyData:getBonusNameAndTooltip(perkData)

			bonusIcon:setTooltip(string.format("%s\n\n%s", bonusName, bonusTooltip))
			bonusIcon.blocked, bonusIcon.locked, bonusIcon.active = true, false, false
			bonusIcon.perkData = perkData

			icon:setImageSource(iconSource)
			icon:setImageClip(string.format("%s 64 64", iconClip))

			setupPerkIconGrey(perkData, iconSource, iconClip, iconGrey, augmentIconNormal, augmentIconDarker)

			if currentData.perks[i - 1] == index - 1 then
				bonusIcon.blocked = false
				enableBonusIcon(bonusIcon, iconGrey, hightLightWidget, borderWidget, bonusDetail:recursiveGetChildById("bonusName"), bonusTooltip, augmentIconDarker, perkData)
			end

			if widgetIsBlocked then
				bonusIcon:getChildById("locked-perk"):setVisible(true)
				bonusIcon.locked = true
			end

			bonusIcon.onHoverChange = createHoverHandler(bonusIcon, iconGrey, augmentIconDarker)
			bonusIcon.onClick = createClickHandler(bonusIcon, currentPerkPanel, bonusDetail, hightLightWidget, borderWidget, iconGrey, augmentIconDarker, bonusTooltip, perkData, displayItemId)
		end

		updatePercentWidgets(widget, currentData.exp, i, displayItem)
	end

	if self.treeScroll and self.treeScroll.updateScrollBars then
		self.treeScroll:updateScrollBars()
	end
end

function WeaponProficiency:onUpdateSelectedProficiency(itemId)
	local currentItem = self.displayItemPanel:getChildById("item"):getItem()
	if not currentItem or currentItem:getId() ~= itemId then
		return
	end

	local currentData = self.cacheList[itemId] or {exp = 0, perks = {}}
	local experience = currentData.exp
	self:updateExperienceProgress(experience, #self.perkPanel:getChildren(), currentItem)
	self:updateMainButtons(currentData)

	for i, child in ipairs(self.perkPanel:getChildren()) do
		updatePercentWidgets(child, experience, i, currentItem)

		local widgetIsBlocked = not canChangeWeaponPerks() and currentData.perks[i - 1]
		for _, widget in ipairs(child.currentPerkPanel:getChildren()) do
			if widget.perkData then
				widget.active = false
				widget.blocked = false
				widget.locked = false

				local iconGrey = widget:getChildById("icon-grey")
				local borderWidget = widget:getChildById("border")
				local hightLightWidget = widget:getChildById("highlight")
				local augmentIconDarker = widget:getChildById("iconPerks-grey")
				local bonusDetail = self.bonusDetailPanel:getChildById("bonusDetail_" .. i)

				disableBonusIcon(iconGrey, hightLightWidget, borderWidget,
					bonusDetail:recursiveGetChildById("bonusName"), augmentIconDarker, widget.perkData)
			end
		end
		
		for index, widget in ipairs(child.currentPerkPanel:getChildren()) do
			if widget.perkData and widgetIsBlocked then
				widget:getChildById("locked-perk"):setVisible(true)
				widget.locked = true
			end

			if widget.perkData and currentData.perks[i - 1] == index - 1 then
				widget.blocked = false
				widget.locked = false

				local iconGrey = widget:getChildById("icon-grey")
				local borderWidget = widget:getChildById("border")
				local hightLightWidget = widget:getChildById("highlight")
				local augmentIconDarker = widget:getChildById("iconPerks-grey")
				local bonusDetail = self.bonusDetailPanel:getChildById("bonusDetail_" .. i)
				local _, bonusTooltip = ProficiencyData:getBonusNameAndTooltip(widget.perkData)

				enableBonusIcon(widget, iconGrey, hightLightWidget, borderWidget, bonusDetail:recursiveGetChildById("bonusName"), bonusTooltip, augmentIconDarker, widget.perkData)
			end
		end
	end

	self:checkPerksMatch(itemId)
end

function WeaponProficiency:updateExperienceProgress(currentExp, levelsCount, displayItem)
	local experienceWidget = self.window:recursiveGetChildById("progressDescription")
	local experienceLeftWidget = self.window:recursiveGetChildById("nextLevelDescription")
	local totalProgressWidget = self.window:recursiveGetChildById("proficiencyProgress")

	local maximumStage = math.min(levelsCount + 2, #ExperienceTable)
	local currentCeilExperience = ProficiencyData:getCurrentCeilExperience(currentExp, displayItem, maximumStage)
	local maxExperience = ProficiencyData:getMaxExperience(levelsCount, displayItem)
	local masteryAchieved = currentExp >= maxExperience

	experienceWidget:setText(string.format("%s / %s", comma_value(currentExp), comma_value(currentCeilExperience)))
	
	self:updateItemAddons(currentExp, displayItem, masteryAchieved, levelsCount)

	if masteryAchieved then
		experienceLeftWidget:setText("Mastery achieved")
	else
		experienceLeftWidget:setText(string.format("%s XP for next level", comma_value(currentCeilExperience - currentExp)))
	end

	local treeProgress = 0
	if levelsCount > 0 then
		for level = 1, levelsCount do
			treeProgress = treeProgress + ProficiencyData:getLevelPercent(currentExp, level, displayItem)
		end
		treeProgress = math.floor(treeProgress / levelsCount)
	end
	totalProgressWidget:setPercent(masteryAchieved and 100 or treeProgress)
	totalProgressWidget:setTooltip(string.format("%s / %s", comma_value(currentExp), comma_value(currentCeilExperience)))
end

function WeaponProficiency:updateItemAddons(currentExp, displayItem, masteryAchieved, perkLevels)
	local weaponLevel = math.min(
		MAX_MASTERY_OVERLAY_LEVEL,
		math.max(0, tonumber(perkLevels) or 0),
		ProficiencyData:getCurrentLevelByExp(displayItem, currentExp, true)
	)
	local baseLevel = math.min(MAX_MASTERY_BASE_LEVEL, weaponLevel)
	local iconLevelWidget = self.window:recursiveGetChildById("iconMasteryLevel")
	local weaponLevelWidget = self.window:recursiveGetChildById("itemMasteryLevel")

	iconLevelWidget:setImageSource("/modules/game_proficiency/proficiency/icon-masterylevel-" .. baseLevel)
	weaponLevelWidget:setVisible(weaponLevel > 0)
	if weaponLevel > 0 then
		local color = masteryAchieved and "gold" or "silver"
		weaponLevelWidget:setImageSource(string.format("/modules/game_proficiency/proficiency/icon-masterylevel-%d-%s", weaponLevel, color))
	end
end

function WeaponProficiency:toggleFilterOption(filter)
	local filterId = filter:getId()
	local oneHandButton = self.window:recursiveGetChildById("oneButton")
	local twoHandButton = self.window:recursiveGetChildById("twoButton")

	if filterId == "oneButton" then
		if twoHandButton:isChecked() then
			twoHandButton:setChecked(false, true)
			self.filters["twoButton"] = false
		end
	elseif filterId == "twoButton" then
		if oneHandButton:isChecked() then
			oneHandButton:setChecked(false, true)
			self.filters["oneButton"] = false
		end
	end

	self.filters[filterId] = not filter:isChecked()
	filter:setChecked(not filter:isChecked())

	self:onWeaponCategoryChange(self.optionFilter:getCurrentOption().text)
end

function WeaponProficiency:onSearchTextChange(text)
	local currentCategory = self.optionFilter:getCurrentOption().text
	self:onWeaponCategoryChange(currentCategory, text)
end

function WeaponProficiency:onClearSearch()
	if not self.window then
		return
	end

	local searchField = self.window:recursiveGetChildById("searchText")
	if not isEmptyString(searchField:getText()) then
		searchField:clearText()
	end
end

local function collectUnlockedActivePerks(self, item)
	local selected = {}
	if not item then return selected end

	local currentData = self.cacheList[item:getId()] or {exp = 0, perks = {}}
	local experience = tonumber(currentData.exp) or 0
	for levelIndex, perkRow in ipairs(self.perkPanel:getChildren()) do
		local unlocked = ProficiencyData:getLevelPercent(experience, levelIndex, item) >= 100
		if unlocked and perkRow.currentPerkPanel then
			for perkIndex, widget in ipairs(perkRow.currentPerkPanel:getChildren()) do
				if widget.perkData and widget.active then
					selected[levelIndex - 1] = perkIndex - 1
					break
				end
			end
		end
	end
	return selected
end

function WeaponProficiency:onApplyChanges(button, targetItem)
	if button and not button:isOn() then return end

	local currentItem = self.displayItemPanel:getChildById("item"):getItem()
	if targetItem then
		currentItem = targetItem
	end

	if not currentItem then
		return
	end

	local toSend = collectUnlockedActivePerks(self, currentItem)

	if isEmptyTable(toSend) then
		sendPacket("reset", { itemId = currentItem:getId() })
		self.cacheList[currentItem:getId()].perks = {}
	else
		local packetPerks = {}
		for level, choice in pairs(toSend) do
			packetPerks[tostring(level)] = choice
		end
		sendPacket("apply", { itemId = currentItem:getId(), perks = packetPerks })
		self.cacheList[currentItem:getId()].perks = toSend
	end

	local hasSelection = not isEmptyTable(toSend)
	self.window:getChildById("apply"):setOn(hasSelection)
	self.window:getChildById("ok"):setOn(hasSelection)
	self.window:getChildById("reset"):setOn(canChangeWeaponPerks() and hasSelection)
	self.window:getChildById("close"):setText("Close")
	self.saveWeaponMissing = false
end

function WeaponProficiency:onResetWeapon(button)
	if not canChangeWeaponPerks() or not button:isOn() then
		return
	end

	local currentItem = self.displayItemPanel:getChildById("item"):getItem()
	if not currentItem then
		return
	end

	local applyButton = self.window:getChildById("apply")
	local okButton = self.window:getChildById("ok")
	local closeButton = self.window:getChildById("close")
	local weaponEntry = self.cacheList[currentItem:getId()] or {}
	local perksSize = table.size(weaponEntry.perks)

	button:setOn(false)
	applyButton:setOn(perksSize > 0)
	okButton:setOn(perksSize > 0)

	button:setTooltip("You don't have any perks to reset.")

	if perksSize > 0 then
		local text = "Apply changes to your perks"
		applyButton:setTooltip(text)
		okButton:setTooltip(text)
		closeButton:setText("Cancel")
		self.saveWeaponMissing = true
	else
		local text = "No changes have been made to your perks."
		applyButton:setTooltip(text)
		okButton:setTooltip(text)
		closeButton:setText("Close")
	end

	for i, child in ipairs(self.perkPanel:getChildren()) do
		local bonusDetail = self.bonusDetailPanel:getChildById("bonusDetail_" .. i)

		for index, widget in pairs(child.currentPerkPanel:getChildren()) do
			widget:getChildById("locked-perk"):setVisible(false)

			if widget.active then
				widget.blocked = false
				widget.locked = false
				widget.active = false

				local iconGrey = widget:getChildById("icon-grey")
				local borderWidget = widget:getChildById("border")
				local hightLightWidget = widget:getChildById("highlight")
				local augmentIconDarker = widget:getChildById("iconPerks-grey")
				local detailChild = bonusDetail:recursiveGetChildById("bonusName")
				if detailChild then
					disableBonusIcon(iconGrey, hightLightWidget, borderWidget, detailChild, augmentIconDarker, widget.perkData)
				end
			end
		end
	end
end

function WeaponProficiency:onCloseWindow(button)
	if button:getText() == "Cancel" then
		self.saveWeaponMissing = false
		button:setText("Close")
		local currentItem = self.displayItemPanel:getChildById("item"):getItem()
		if currentItem then
			self:onUpdateSelectedProficiency(currentItem:getId())
		end
		hide()
		return true
	end

	if button:getText() == "Close" then
		hide()
		return true
	end

	self:onCloseMessage(true)
end

local function focusGameRootPanel()
	local gameInterface = modules.game_interface
	local rootPanel = gameInterface and gameInterface.getRootPanel and gameInterface.getRootPanel()
	if rootPanel then rootPanel:focus() end
end

function WeaponProficiency:onCloseMessage(userClosingWindow, targetItem, callbackFunction)
	if self.warningWindow then
		self.warningWindow:destroy()
	end

	self.window:hide()

	local noButton = function()
		if self.warningWindow then
			self.warningWindow:destroy()
			self.warningWindow = nil
		end
		self.saveWeaponMissing = false

		if not userClosingWindow then
			self.window:show()
			if callbackFunction then
				callbackFunction()
			end
		else
			focusGameRootPanel()
		end
	end

  	local yesButton = function()
    	if self.warningWindow then
      		self.warningWindow:destroy()
			self.warningWindow = nil
    	end

		self:onApplyChanges(nil, targetItem)		
		if not userClosingWindow then
			if callbackFunction then
				callbackFunction()
			end
			self.window:show()
		else
			focusGameRootPanel()
		end
  	end

  	self.warningWindow = displayGeneralBox('Save?', "You did not save the changes you have made to your perks.\n\nWould you like to save your perks?",
		{{ text=tr('Yes'), callback = yesButton }, { text=tr('No'), callback = noButton }
	}, yesButton, noButton)
end

function WeaponProficiency:checkPerksMatch(itemId)
	local cacheEntry = self.cacheList[itemId] or {perks = {}}
	local cachePerks = cacheEntry.perks or {}
	local currentItem = self.displayItemPanel:getChildById("item"):getItem()
	local selectedPerks = collectUnlockedActivePerks(self, currentItem)
	local allPerksMatch = true

	for level, choice in pairs(cachePerks) do
		if selectedPerks[tonumber(level)] ~= tonumber(choice) then
			allPerksMatch = false
			break
		end
	end
	if allPerksMatch then
		for level, choice in pairs(selectedPerks) do
			local cachedChoice = cachePerks[level]
			if cachedChoice == nil then cachedChoice = cachePerks[tostring(level)] end
			if tonumber(cachedChoice) ~= tonumber(choice) then
				allPerksMatch = false
				break
			end
		end
	end

	local hasActivePerk = not isEmptyTable(selectedPerks)

    local applyButton = self.window:getChildById("apply")
    local okButton = self.window:getChildById("ok")
	local closeButton = self.window:getChildById("close")

	if canChangeWeaponPerks() and not allPerksMatch then
		local resetButton = self.window:getChildById("reset")
		resetButton:setOn(true)
		resetButton:setTooltip("Reset your perks")
	end

	local tooltip = allPerksMatch and "No changes have been made to your perks." or "Apply changes to your perks"

	applyButton:setOn(not allPerksMatch or hasActivePerk)
	okButton:setOn(not allPerksMatch or hasActivePerk)
	applyButton:setTooltip(tooltip)
	okButton:setTooltip(tooltip)

	closeButton:setText(not allPerksMatch and "Cancel" or "Close")
	self.saveWeaponMissing = not allPerksMatch
end
