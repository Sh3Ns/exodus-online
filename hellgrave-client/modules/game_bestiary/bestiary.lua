------ Initialization and Termination Functions

function Bestiary.init()
	ProtocolGame.registerExtendedOpcode(BESTIARY_OPCODE, Bestiary.onExtendedOpcode)
	connect(g_game, {onGameStart = Bestiary.onStart, onGameEnd = Bestiary.onEnd})
	Bestiary.onStart()
end

function Bestiary.terminate()
	ProtocolGame.unregisterExtendedOpcode(BESTIARY_OPCODE, Bestiary.onExtendedOpcode)
	disconnect(g_game, {onGameStart = Bestiary.onStart, onGameEnd = Bestiary.onEnd})
	Bestiary.onEnd()
end

function Bestiary.onStart()
	if not Bestiary.Button then
		if g_resources.getLayout() == "retro" then
			Bestiary.iconBasedOnLayoutMain = "images/icon2"
		else
			Bestiary.iconBasedOnLayoutMain = "images/bestiary"
		end
		Bestiary.Button = modules.client_topmenu.addLeftGameToggleButton("Bestiary", tr("Bestiary"), Bestiary.iconBasedOnLayoutMain, Bestiary.toggle)
	end
	if not Bestiary.UI then
		Bestiary.UI = g_ui.displayUI("bestiary")
	end
	Bestiary.UI:setVisible(false)
	Bestiary.initCategories()
	Bestiary.setupCharmsPanel()

	if not Bestiary.trackerWindow then
		Bestiary.trackerWindow = g_ui.loadUI("bestiary_tracker", modules.game_interface.getRightPanel())
	end
	local scrollbar = Bestiary.trackerWindow:getChildById("miniwindowScrollBar")
	scrollbar:mergeStyle({["$!on"] = {}})
	Bestiary.trackerWindow:setContentMinimumHeight(73)
	if not Bestiary.TrackerButton then
		if g_resources.getLayout() == "retro" then
			Bestiary.iconBasedOnLayoutTracker = "images/icon1"
		else
			Bestiary.iconBasedOnLayoutTracker = "images/bestiary2"
		end
		Bestiary.TrackerButton = modules.client_topmenu.addLeftGameToggleButton("Bestiary Tracker", tr("Bestiary Tracker"), Bestiary.iconBasedOnLayoutTracker, Bestiary.toggleTracker)
	end
	Bestiary.trackerWindow:setup()

	Bestiary.categoryCreaturesCache = {}
	Bestiary.creatureInfoCache = {}
	Bestiary.killsCache = {}
	Bestiary.trackedCreatures = {}
	Bestiary.charmData = {}
	Bestiary.unlockedCreatures = {}
	Bestiary.sendOpcode({topic = "get-tracked-creatures"})
	Bestiary.sendOpcode({topic = "get-unlocked-creatures"})
	Bestiary.sendOpcode({topic = "get-charmsData"})

	Bestiary.UI.bottomPanel.totalBonusesButton.onClick = function()
		Bestiary.sendOpcode({topic = "total-bonuses-request"})
	end
	Bestiary.UI.bottomPanel.closeButton.onClick = function()
		Bestiary.UI:setVisible(false)
		Bestiary.Button:setOn(false)					  
	end
	Bestiary.UI.bottomPanel.charmsButton.onClick = function()
		Bestiary.UI.bottomPanel.backButton:setVisible(true)
		Bestiary.UI.bottomPanel.charmsPanel:setVisible(true)
		Bestiary.UI.bottomPanel.goldPanel:setVisible(true)
		Bestiary.UI.charmsPanel:setVisible(true)
		Bestiary.UI.bottomPanel.totalBonusesButton:setVisible(false)
		Bestiary.UI.bottomPanel.charmsButton:setVisible(false)
		Bestiary.UI.bottomPanel.totalProgressBarBG:setVisible(false)
	end
	Bestiary.UI.bottomPanel.backButton.onClick = function()
		Bestiary.UI.bottomPanel.backButton:setVisible(false)
		Bestiary.UI.bottomPanel.charmsPanel:setVisible(false)
		Bestiary.UI.bottomPanel.goldPanel:setVisible(false)
		Bestiary.UI.charmsPanel:setVisible(false)
		Bestiary.UI.bottomPanel.totalBonusesButton:setVisible(true)
		Bestiary.UI.bottomPanel.charmsButton:setVisible(true)
		Bestiary.UI.bottomPanel.totalProgressBarBG:setVisible(true)
	end
	Bestiary.UI.creaturesSearch.onTextChange = function(widget, text)
		Bestiary.onCreaturesSearch(widget, text)
	end
end

function Bestiary.onEnd()
	Bestiary.extendedOpcodeChunks = {}

	if Bestiary.UI then
		Bestiary.UI:destroy()
		Bestiary.UI = nil
	end
	if Bestiary.trackerWindow then
		Bestiary.trackerWindow:destroy()
		Bestiary.trackerWindow = nil
	end
	if Bestiary.Button then
		Bestiary.Button:destroy()
		Bestiary.Button = nil
	end
	if Bestiary.TrackerButton then
		Bestiary.TrackerButton:destroy()
		Bestiary.TrackerButton = nil
	end
end

function Bestiary.toggle()
	if Bestiary.UI:isVisible() then
		Bestiary.UI:setVisible(false)
		Bestiary.Button:setOn(false)
	else
		Bestiary.sendOpcode({topic = "base-data-request"})
		Bestiary.setupCharmsPanel()
        Bestiary.setupCharmData()
		Bestiary.UI.creaturePanel:setText("")
		Bestiary.UI.creaturePanel.creatureInfoPanel:setVisible(false)
		Bestiary.UI:setVisible(true)
		Bestiary.UI:focus()
		Bestiary.Button:setOn(true)
	end
end

function Bestiary.getLootPaginationPanel()
  if not Bestiary.UI then return nil end
  return Bestiary.UI:recursiveGetChildById("lootPagination")
end

function Bestiary.updateLootPaginationUI(creatureId, page, totalPages)
  local panel = Bestiary.getLootPaginationPanel()
  if not panel then
    return
  end

  if panel.pageLabel then
    panel.pageLabel:setText(string.format("%d / %d", page, totalPages))
  end

  if panel.prevButton then
    panel.prevButton:setEnabled(page > 1)
    panel.prevButton.onClick = function()
      Bestiary.requestCreatureLoot(creatureId, page - 1)
    end
  end

  if panel.nextButton then
    panel.nextButton:setEnabled(page < totalPages)
    panel.nextButton.onClick = function()
      Bestiary.requestCreatureLoot(creatureId, page + 1)
    end
  end

  if totalPages <= 1 then
    panel:setVisible(false)
  else
    panel:setVisible(true)
  end
end

function Bestiary.updatePaginationUI(categoryId, page, totalPages)
  local panel = Bestiary.UI.pagination
  panel.pageLabel:setText(string.format("Page %d / %d", page, totalPages))

  panel.prevButton:setEnabled(page > 1)
  panel.nextButton:setEnabled(page < totalPages)

  panel.prevButton.onClick = function()
    Bestiary.requestCategoryPage(categoryId, page - 1)
  end

  panel.nextButton.onClick = function()
    Bestiary.requestCategoryPage(categoryId, page + 1)
  end
end

function Bestiary.requestCreatureLoot(creatureId, page)
  Bestiary.sendOpcode({
    topic = "creature-loot-request",
    creatureId = creatureId,
    page = page
  })
end

function Bestiary.toggleTracker()
	if Bestiary.trackerWindow:isVisible() then
		Bestiary.trackerWindow:setVisible(false)
		Bestiary.TrackerButton:setOn(false)
	else
		Bestiary.trackerWindow:setVisible(true)
		Bestiary.TrackerButton:setOn(true)
	end
end

function Bestiary.updateIconBar(panel, value, enabledImage, disabledImage, maxIcons, idPrefix)
  if not panel then return end

  value = math.floor(tonumber(value) or 0)
  maxIcons = maxIcons or 6
  idPrefix = idPrefix or "icon"

  if value < 0 then value = 0 end
  if value > maxIcons then value = maxIcons end

  for i = 1, maxIcons do
    local icon = panel:getChildById(idPrefix .. i)
    if icon then
      icon:setImageSource(i <= value and enabledImage or disabledImage)
    end
  end
end

------ Category Handling Functions

function Bestiary.initCategories()
	Bestiary.categories = {}
	for id, config in pairs(Bestiary.categoriesDisplay) do
		table.insert(
			Bestiary.categories,
			{
				id = id,
				name = config.name,
				progress = 0,
				maxProgress = 0,
				display = config.display
			}
		)
	end
end

function Bestiary.updateBaseData(data)
	if not data or not data.categories then
		return
	end

	for _, categoryData in pairs(data.categories) do
		for _, category in ipairs(Bestiary.categories) do
			if category.id == categoryData.id then
				category.progress = categoryData.unlockedCreatures or 0
				category.maxProgress = categoryData.totalCreatures or 0
				category.percentageProgress =
					(category.maxProgress > 0) and (category.progress / category.maxProgress * 100) or 0
				category.rawProgressValue =
					string.format(
					"%d / %d (%.2f%%)",
					category.progress,
					category.maxProgress,
					category.percentageProgress
				)
				break
			end
		end
	end

	Bestiary.refreshCategoryUI()

	for _, category in ipairs(Bestiary.categories) do
		local categoryPanel = Bestiary.UI.categoriesPanel:getChildById("category" .. category.id)
		if categoryPanel then
			Bestiary.updateCategoryCircles(categoryPanel, category.percentageProgress)
		end
	end
	Bestiary.updateTotalProgress()
	Bestiary.UI.bottomPanel.goldPanel.amount:setText(math.max(data.gold, 0))
	Bestiary.UI.bottomPanel.charmsPanel.amount:setText(math.max(data.charmPoints, 0))
end

function Bestiary.refreshCategoryUI()
	Bestiary.UI.categoriesPanel:destroyChildren()

	for _, category in ipairs(Bestiary.categories) do
		local categoryPanel = g_ui.createWidget("BestiaryCategoryEntry", Bestiary.UI.categoriesPanel)
		categoryPanel:setId("category" .. category.id)
		categoryPanel.name:setText(category.name or "")
		if category.display then
			if category.display.outfit then
				categoryPanel.card:setVisible(false)
				categoryPanel.creature:setVisible(true)
				categoryPanel.avatar:setVisible(true)
				categoryPanel.creature:setOutfit(category.display.outfit)
				if category.display.offset then
					categoryPanel.creature:setMarginRight(category.display.offset.x or 0)
					categoryPanel.creature:setMarginTop(category.display.offset.y or 0)
				end
			elseif category.display.card then
				categoryPanel.creature:setVisible(false)
				categoryPanel.avatar:setVisible(false)
				categoryPanel.card:setVisible(true)
				categoryPanel.card:setImageSource(category.display.card)
			end
		end
		categoryPanel.onFocusChange = function(widget, focused)
			if focused and not Bestiary.suppressCategoryFocusChange then
				Bestiary.onCategoryFocusChange(category.id)
			end
		end
		categoryPanel.rawProgressValue:setText(category.rawProgressValue)
	end

	local firstCategory = Bestiary.UI.categoriesPanel:getFirstChild()
	if firstCategory then
		Bestiary.suppressCategoryFocusChange = true
		Bestiary.UI.categoriesPanel:focusChild(firstCategory)
		Bestiary.suppressCategoryFocusChange = false

		local categoryId = tonumber(tostring(firstCategory:getId()):match("%d+"))
		if categoryId then
			Bestiary.onCategoryFocusChange(categoryId)
		end
	end
end

function Bestiary.updateCategoryCircles(categoryPanel, progress)
	local circles = 5
	local percentPerCircle = 100 / circles
	local fullCircles = math.floor(progress / percentPerCircle)
	local partialFill = (progress % percentPerCircle) / percentPerCircle * 100

	for i = 1, circles do
		local circle = categoryPanel:getChildById("progressCircle" .. i)
		if not circle then
			break
		end

		local fill = circle:getChildById("progressFill")
		if progress == 0 then
			fill:setImageClip({x = 0, y = 0, width = 0, height = 0})
			fill:setImageRect({x = 0, y = 0, width = 0, height = 0})
			fill:setVisible(false)
		elseif i <= fullCircles then
			fill:setImageClip({x = 0, y = 0, width = fill:getWidth(), height = fill:getHeight()})
			fill:setImageRect({x = 0, y = 0, width = fill:getWidth(), height = fill:getHeight()})
			fill:setVisible(true)
		elseif i == fullCircles + 1 then
			local barWidth = fill:getWidth()
			local barHeight = fill:getHeight()
			local rect = {x = 0, y = 0, width = math.floor(barWidth * (partialFill / 100)), height = barHeight}
			fill:setImageClip(rect)
			fill:setImageRect(rect)
			fill:setVisible(true)
		else
			fill:setImageClip({x = 0, y = 0, width = 0, height = 0})
			fill:setImageRect({x = 0, y = 0, width = 0, height = 0})
			fill:setVisible(false)
		end
	end
end

function Bestiary.updateTotalProgress()
	if not Bestiary.UI or not Bestiary.UI.bottomPanel or not Bestiary.UI.bottomPanel.totalProgressBarBG then
		return
	end

	local totalProgress = 0
	local totalMaxProgress = 0

	for _, category in ipairs(Bestiary.categories) do
		totalProgress = totalProgress + (category.progress or 0)
		totalMaxProgress = totalMaxProgress + (category.maxProgress or 0)
	end

	local percent = (totalMaxProgress > 0) and (totalProgress / totalMaxProgress * 100) or 0
	percent = math.min(percent, 100)

	local progressBar = Bestiary.UI.bottomPanel.totalProgressBarBG.totalProgressBar
	local progressText = Bestiary.UI.bottomPanel.totalProgressBarBG.progressPercent

	if progressBar then
		progressBar:setPercent(percent)
	end

	if progressText then
		local formattedPercent = string.format("%.2f", percent)
		progressText:setText("Total Progress: " .. formattedPercent .. "%")
	end
end

function Bestiary.requestCategoryPage(categoryId, page)
  Bestiary.sendOpcode({
    topic = "category-creatures-request",
    categoryId = categoryId,
    page = page
  })
end

function Bestiary.onCategoryFocusChange(categoryId)
  Bestiary.currentCategoryPage = 1
  Bestiary.requestCategoryPage(categoryId, 1)

  Bestiary.currentLootPage = 1
  Bestiary.clearLootItems()
  Bestiary.UI.creaturesSearch:setText("")
  Bestiary.sendOpcode({ topic = "category-progress-request", categoryId = categoryId })
end

function Bestiary.updateCategoryKills(data)
	if not data or not data.categoryId or not data.progress then
		return
	end

	if not Bestiary.killsCache[data.categoryId] then
		Bestiary.killsCache[data.categoryId] = {}
	end

	local creaturesListPanel = Bestiary.UI.creaturesListPanel
	if not creaturesListPanel then
		return
	end

	for _, creatureProgress in ipairs(data.progress) do
		local requiredKills = 0
		for _, creatureListing in pairs(creaturesListPanel:getChildren()) do
			if tonumber(creatureListing.creatureId) == creatureProgress.id then
				requiredKills = creatureListing.requiredKills or 0
				break
			end
		end

		Bestiary.killsCache[data.categoryId][creatureProgress.id] = {
			kills = creatureProgress.kills or 0,
			requiredKills = requiredKills
		}

		for _, creatureListing in pairs(creaturesListPanel:getChildren()) do
			if tonumber(creatureListing.creatureId) == creatureProgress.id then
				local killsInfo = Bestiary.killsCache[data.categoryId][creatureProgress.id]
				local kills = killsInfo.kills

				if kills >= requiredKills and requiredKills > 0 then
					creatureListing.progress:setText("Completed")
					creatureListing.progressPercent:setText("100%")
				else
					creatureListing.progress:setText(string.format("%d / %d", kills, requiredKills))
					local percentage = (requiredKills > 0) and (kills / requiredKills * 100) or 0
					creatureListing.progressPercent:setText(string.format("%.2f%%", percentage))
				end
				break
			end
		end
	end

	local selectedCreatureId = Bestiary.UI.creaturePanel.creatureInfoPanel.selectedCreatureId
	if selectedCreatureId then
		local categoryId = data.categoryId
		local creatureId = tonumber(selectedCreatureId)

		local killsInfo = Bestiary.killsCache[categoryId] and Bestiary.killsCache[categoryId][creatureId]
		if killsInfo then
			if Bestiary.creatureInfoCache[categoryId] and Bestiary.creatureInfoCache[categoryId][creatureId] then
				Bestiary.updateCreatureInfo(Bestiary.creatureInfoCache[categoryId][creatureId])
			end
		end
	end
end

------ Creature List Functions

function Bestiary.selectCreatureListing(creatureListing)
	if not creatureListing then
		return
	end

	local creatureId = tonumber(creatureListing.creatureId)
	local categoryId = tonumber(creatureListing.categoryId)
	if not creatureId or not categoryId then
		return
	end

	Bestiary.onCreatureFocusChange(creatureId, categoryId)
	Bestiary.UI.creaturePanel:setText(creatureListing.name:getText())
	Bestiary.applyOutfit(
		Bestiary.UI.creaturePanel.creatureInfoPanel.focusedCreatureDisplay,
		creatureListing.outfit or {}
	)
end

function Bestiary.updateCreatureList(creatures)
  Bestiary.UI.creaturesListPanel:destroyChildren()

  for _, creature in ipairs(creatures) do
    local creatureListing = g_ui.createWidget("BestiaryCreatureEntry", Bestiary.UI.creaturesListPanel)

    creatureListing.name:setText(creature.name)
    Bestiary.applyOutfit(creatureListing.creature, creature.outfit)

    creatureListing.creatureId = creature.id
    creatureListing.categoryId = creature.categoryId
    creatureListing.outfit = creature.outfit
    creatureListing.requiredKills = creature.requiredKills
	creatureListing.bosstiary = creature.bosstiary
	local categoryId = creature.categoryId
	local killsInfo =
	Bestiary.killsCache[categoryId] and
	Bestiary.killsCache[categoryId][creature.id]

	local kills = (killsInfo and killsInfo.kills) or 0
	local requiredKills = (killsInfo and killsInfo.requiredKills) or 0

	if requiredKills > 0 and kills >= requiredKills then
	creatureListing.progress:setText("Completed")
	creatureListing.progressPercent:setText("100%")
	else
	creatureListing.progress:setText(
		string.format("%d / %d", kills, requiredKills)
	)
	local percent =
		(requiredKills > 0) and (kills / requiredKills * 100) or 0
	creatureListing.progressPercent:setText(string.format("%.2f%%", percent))
	end

	local BOSSTIARY_ICONS = {
		bane     = "images/bane",
		archfoe = "images/archfoe",
		nemesis = "images/nemesis",
		apex = "images/apex",
	}
    if creature.bosstiary and creatureListing.bosstiaryIcon then
      creatureListing.bosstiaryIcon:setImageSource(
        BOSSTIARY_ICONS[creature.bosstiary]
      )
	  creatureListing.bosstiaryIcon:setTooltip(
    	string.format("Bosstiary: %s", creature.bosstiary:upper())
	  )
      creatureListing.bosstiaryIcon:setVisible(true)
    elseif creatureListing.bosstiaryIcon then
      creatureListing.bosstiaryIcon:setVisible(false)
    end

    creatureListing.onFocusChange = function(widget, focused)
      if focused and not Bestiary.suppressCreatureFocusChange then
        Bestiary.selectCreatureListing(widget)
      end
    end
  end

  local firstCreature = Bestiary.UI.creaturesListPanel:getFirstChild()
  if firstCreature then
    Bestiary.suppressCreatureFocusChange = true
    Bestiary.UI.creaturesListPanel:focusChild(firstCreature)
    Bestiary.suppressCreatureFocusChange = false
    Bestiary.selectCreatureListing(firstCreature)
  end
end

function Bestiary.onCreatureFocusChange(creatureId, categoryId)
	if Bestiary.UI and Bestiary.UI.creaturePanel and Bestiary.UI.creaturePanel.creatureInfoPanel then
		local creatureInfoPanel = Bestiary.UI.creaturePanel.creatureInfoPanel
		creatureInfoPanel:setVisible(true)
		creatureInfoPanel.selectedCreatureId = creatureId
		creatureInfoPanel.categoryId = categoryId
		Bestiary.updateTrackerCheckBox(creatureId, categoryId)
	end

	if not Bestiary.creatureInfoCache[categoryId] then
		Bestiary.creatureInfoCache[categoryId] = {}
	end

	if not Bestiary.creatureInfoCache[categoryId][creatureId] then
		Bestiary.sendOpcode(
			{
				topic = "creature-info-request",
				creatureId = creatureId,
				categoryId = categoryId
			}
		)
	else
		Bestiary.updateCreatureInfo(Bestiary.creatureInfoCache[categoryId][creatureId])
	end
	Bestiary.currentLootPage = 1
	Bestiary.requestCreatureLoot(creatureId, 1)
end

------ Creature Information Functions

function Bestiary.updateCreatureInfo(data)
	if not Bestiary.UI or not Bestiary.UI.creaturePanel or not Bestiary.UI.creaturePanel.creatureInfoPanel then
		return
	end

	local creatureId = data.creatureId
	local categoryId = data.categoryId
	local killsInfo = Bestiary.killsCache[categoryId] and Bestiary.killsCache[categoryId][creatureId]
	local percent = 0

	if killsInfo then
		local kills = killsInfo.kills or 0
		local requiredKills = killsInfo.requiredKills or 0
		percent = (requiredKills > 0) and (kills / requiredKills * 100) or 0
	end

	Bestiary.updateStats(data.stats, percent)
	Bestiary.setupDefensesBars(data.defenses, percent)
	Bestiary.setupBonuses(data.bonuses, data.categoryId, data.creatureId)
	Bestiary.updateCreatureInternalProgressBar(data.creatureId, data.categoryId)
	Bestiary.updateBonusesColoring(data.creatureId, data.categoryId)

	if not Bestiary.creatureInfoCache[data.categoryId] then
		Bestiary.creatureInfoCache[data.categoryId] = {}
	end

	Bestiary.creatureInfoCache[data.categoryId][data.creatureId] = data
end

function Bestiary.updateStats(stats, percent)
	local statsPanel = Bestiary.UI.creaturePanel.creatureInfoPanel.creatureStatsPanel
	if not statsPanel then
		return
	end

	statsPanel.charmPointsTextLabel:setText(stats.charmPoints or 0)
	Bestiary.updateIconBar(statsPanel.difficultyPanel, stats.difficulty, "images/difficulty", "images/difficulty_disabled", 6, "icon")
	Bestiary.updateIconBar(statsPanel.occurrencePanel, stats.occurrence, "images/occurrence", "images/occurrence_disabled", 6,	"ocu")

	if percent >= BESTIARY_DISPLAY_STATS_AT_PERCENT then
		statsPanel.hpTextLabel:setText(Bestiary.formatNumberShort(stats.health) or "?")
		statsPanel.expTextLabel:setText(Bestiary.formatNumberShort(stats.experience) or "?")
		statsPanel.speedTextLabel:setText(Bestiary.formatNumberShort(stats.speed) or "?")
		statsPanel.armorTextLabel:setText(Bestiary.formatNumberShort(stats.armor) or "?")
	else
		statsPanel.hpTextLabel:setText("?")
		statsPanel.expTextLabel:setText("?")
		statsPanel.speedTextLabel:setText("?")
		statsPanel.armorTextLabel:setText("?")
	end
end

function Bestiary.updateCreatureInternalProgressBar(creatureId, categoryId)
	if not (Bestiary.UI and Bestiary.UI.creaturePanel and Bestiary.UI.creaturePanel.creatureInfoPanel) then
		return
	end

	local progressBar = Bestiary.UI.creaturePanel.creatureInfoPanel.progressBarBG.creatureProgressBar
	local selectedCreatureId = Bestiary.UI.creaturePanel.creatureInfoPanel.selectedCreatureId
	if progressBar and tonumber(selectedCreatureId) == creatureId then
		local killsInfo = Bestiary.killsCache[categoryId] and Bestiary.killsCache[categoryId][creatureId]
		if not killsInfo then
			return
		end

		local kills = killsInfo.kills
		local requiredKills = killsInfo.requiredKills

		local percent = (requiredKills > 0) and (kills / requiredKills * 100) or 0
		progressBar:setPercent(math.min(100, percent))

		Bestiary.UI.creaturePanel.creatureInfoPanel.creatureRawKillsValue:setText(
			"Total kills: " ..
				Bestiary.formatNumberShort(kills) ..
					"  |  Unlocked at: " .. Bestiary.formatNumberShort(requiredKills) .. " kills"
		)

		local formattedPercent = string.format("%.2f", math.min(100, percent))
		Bestiary.UI.creaturePanel.creatureInfoPanel.progressBarBG.progressPercent:setText(formattedPercent .. "%")
	end
end

function Bestiary.updateBonusesColoring(creatureId, categoryId)
	if not (Bestiary.UI and Bestiary.UI.creaturePanel and Bestiary.UI.creaturePanel.creatureInfoPanel) then
		return
	end

	local selectedCreatureId = Bestiary.UI.creaturePanel.creatureInfoPanel.selectedCreatureId
	if tonumber(selectedCreatureId) ~= creatureId then
		return
	end

	local bonusesScrollArea = Bestiary.UI.creaturePanel.creatureInfoPanel.bonusesScrollArea
	if not bonusesScrollArea then
		return
	end

	local killsInfo = Bestiary.killsCache[categoryId] and Bestiary.killsCache[categoryId][creatureId]
	if not killsInfo then
		return
	end

	local kills = killsInfo.kills
	local requiredKills = killsInfo.requiredKills
	local unlocked = kills >= requiredKills

	for _, bonusWidget in pairs(bonusesScrollArea:getChildren()) do
		if bonusWidget:getText() == BESTIARY_NO_BONUS_TEXT then
			bonusWidget:setColor("gray")
		else
			bonusWidget:setColor(unlocked and "green" or "red")
		end
	end
end

function Bestiary.setupBonuses(bonuses, categoryId, creatureId)
	local bonusesScrollArea = Bestiary.UI.creaturePanel.creatureInfoPanel.bonusesScrollArea
	if not bonusesScrollArea then
		return
	end

	bonusesScrollArea:destroyChildren()

	if #bonuses == 0 then
		local noBonusWidget = g_ui.createWidget("Label", bonusesScrollArea)
		noBonusWidget:setText(BESTIARY_NO_BONUS_TEXT)
		noBonusWidget:setColor("gray")
		return
	end

	for index, bonus in ipairs(bonuses) do
		local bonusWidget = g_ui.createWidget("Label", bonusesScrollArea)
		bonusWidget:setId("bonus" .. index)
		bonusWidget:setText(index .. ": " .. bonus.name .. " +" .. bonus.value)
		bonusWidget:setColor("red")
	end

	Bestiary.updateBonusesColoring(creatureId, categoryId)
end

function Bestiary.setDefensesBarProgress(defenseBar, elementValue)
	local firstBar = defenseBar.firstBar
	local secondBar = defenseBar.secondBar
	local thirdBar = defenseBar.thirdBar

	if elementValue < 0 then
		firstBar:setBackgroundColor("#900000")
		secondBar:setBackgroundColor("black")
		thirdBar:setBackgroundColor("black")
		firstBar:setValue(elementValue + 100, 0, 100)
		secondBar:setValue(0, 0, 1)
		thirdBar:setValue(0, 0, 1)
	elseif elementValue == 0 then
		firstBar:setBackgroundColor("red")
		secondBar:setBackgroundColor("black")
		thirdBar:setBackgroundColor("black")
		firstBar:setValue(1, 0, 0)
		secondBar:setValue(0, 0, 1)
		thirdBar:setValue(0, 0, 1)
	elseif elementValue < 31 then
		firstBar:setBackgroundColor("red")
		secondBar:setBackgroundColor("red")
		firstBar:setValue(1, 0, 1)
		secondBar:setValue(elementValue, 0, 100)
		thirdBar:setValue(0, 0, 1)
	elseif elementValue < 51 then
		firstBar:setBackgroundColor("orange")
		secondBar:setBackgroundColor("orange")
		firstBar:setValue(1, 0, 1)
		secondBar:setValue(elementValue, 0, 100)
		thirdBar:setValue(0, 0, 1)
	elseif elementValue < 100 then
		firstBar:setBackgroundColor("#ECD900") --yellow
		secondBar:setBackgroundColor("#ECD900")
		firstBar:setValue(1, 0, 1)
		secondBar:setValue(elementValue, 0, 100)
		thirdBar:setValue(0, 0, 1)
	elseif elementValue == 100 then
		firstBar:setBackgroundColor("#FFF5EE") -- white
		secondBar:setBackgroundColor("#FFF5EE")
		firstBar:setValue(1, 0, 1)
		secondBar:setValue(1, 0, 1)
		thirdBar:setValue(0, 0, 1)
	else
		firstBar:setBackgroundColor("green")
		secondBar:setBackgroundColor("green")
		thirdBar:setBackgroundColor("green")
		firstBar:setValue(1, 0, 1)
		secondBar:setValue(1, 0, 1)
		thirdBar:setValue(elementValue - 100, 0, 100)
	end

	defenseBar.rawValue:setText(elementValue .. "%")
end

function Bestiary.setupDefensesBars(defenses, percent)
	local knownDefenses = {}
	local defensesBarsPanel = Bestiary.UI.creaturePanel.creatureInfoPanel.defensesBarsPanel
	for defenseName, elementValue in pairs(defenses) do
		local defenseBar = defensesBarsPanel:getChildById(defenseName)
		knownDefenses[defenseName] = true

		if percent >= BESTIARY_DISPLAY_DEFENSES_AT_PERCENT then
			local progress = (elementValue == 0) and 100 or (100 - elementValue)
			Bestiary.setDefensesBarProgress(defenseBar, progress)
		else
			Bestiary.setDefensesBarUnknown(defenseBar)
		end
	end

	for _, defenseBar in pairs(defensesBarsPanel:getChildren()) do
		if not knownDefenses[defenseBar:getId()] then
			if percent >= BESTIARY_DISPLAY_DEFENSES_AT_PERCENT then
				Bestiary.setDefensesBarProgress(defenseBar, 100)
			else
				Bestiary.setDefensesBarUnknown(defenseBar)
			end
		end
	end
end

function Bestiary.setDefensesBarUnknown(defenseBar)
	defenseBar.firstBar:setBackgroundColor("#555555")
	defenseBar.secondBar:setBackgroundColor("#555555")
	defenseBar.thirdBar:setBackgroundColor("#555555")
	defenseBar.firstBar:setValue(1, 0, 1)
	defenseBar.secondBar:setValue(1, 0, 1)
	defenseBar.thirdBar:setValue(1, 0, 1)
	defenseBar.rawValue:setText("?%")
end

function Bestiary.setupLootItems(lootData, percent)
	Bestiary.clearLootItems()
	Bestiary.setLootItems(lootData, percent)
end

function Bestiary.clearLootItems()
	local allItemsPanel = Bestiary.UI.creaturePanel.lootPanel
	allItemsPanel:destroyChildren()
end

function Bestiary.setLootItems(lootData, percent)
	for _, itemData in ipairs(lootData) do
		local itemPanel = g_ui.createWidget("LootItemPanel", Bestiary.UI.creaturePanel.lootPanel)
		Bestiary.setupItemPanel(itemPanel, itemData, percent)
	end
end

function Bestiary.getMinItemChance(progressPercent)
	for _, config in ipairs(Bestiary.lootDisplayConfig) do
		if progressPercent >= config.progressPercent then
			return config.minItemChance
		end
	end
	return nil
end

function Bestiary.setupItemPanel(itemPanel, itemData, percent)
	if not itemData then return end

	local item        = itemPanel.item
	local countLabel = itemPanel.count
	local chanceLabel = itemPanel.chance
	local itemId   = tonumber(itemData.id)
	local chance   = tonumber(itemData.c) or 0
	local maxCount = tonumber(itemData.max) or 1

	local minItemChance = Bestiary.getMinItemChance(percent)
	if not minItemChance then
		item:setItemId(0)
		item:setTooltip("")
		countLabel:setText("")
		chanceLabel:setVisible(false)
		itemPanel:setChecked(true)
		return
	end

	if chance >= minItemChance then
		item:setItemId(itemId)

		if maxCount > 1 then
			countLabel:setText("1-" .. maxCount)
		else
			countLabel:setText("")
		end

		chanceLabel:setVisible(true)
		chanceLabel:setText(string.format("%.3f%%", chance))
		itemPanel:setChecked(false)
	else
		item:setItemId(0)
		item:setTooltip("")
		countLabel:setText("")
		chanceLabel:setVisible(false)
		itemPanel:setChecked(true)
	end
end

------ Tracked Creatures Functions

function Bestiary.updateTrackedCreatures(data)
	Bestiary.trackedCreatures = {}
	Bestiary.trackedCreatureList = {}
	for _, creatureData in ipairs(data.trackedCreatures) do
		Bestiary.trackedCreatures[creatureData.name] = creatureData
		table.insert(Bestiary.trackedCreatureList, creatureData.name)

		Bestiary.killsCache[creatureData.categoryId] = Bestiary.killsCache[creatureData.categoryId] or {}
		Bestiary.killsCache[creatureData.categoryId][creatureData.id] = {
			kills = creatureData.kills,
			requiredKills = creatureData.requiredKills
		}
	end

	Bestiary.updateTrackerWindow()

	local creatureInfoPanel = Bestiary.UI.creaturePanel.creatureInfoPanel
	if creatureInfoPanel and creatureInfoPanel.selectedCreatureId then
		Bestiary.updateTrackerCheckBox(creatureInfoPanel.selectedCreatureId, creatureInfoPanel.categoryId)
	end
end

function Bestiary.updateTrackerCheckBox(creatureId, categoryId)
	local creatureInfoPanel = Bestiary.UI.creaturePanel.creatureInfoPanel
	if not creatureInfoPanel then
		return
	end

	local trackerCheckBox = creatureInfoPanel.trackerCheckBox
	if not trackerCheckBox then
		return
	end

	local creatureData = Bestiary.getCreatureData(creatureId, categoryId)
	if not creatureData then
		return
	end

	local creatureName = creatureData.name

	trackerCheckBox:setChecked(Bestiary.trackedCreatures[creatureName] ~= nil)

	trackerCheckBox.onCheckChange = Bestiary.onTrackerCheckBoxChange
end

function Bestiary.getCreatureData(creatureId, categoryId)
	local categoryData = Bestiary.categoryCreaturesCache[categoryId]
	if not categoryData then
		return nil
	end

	for _, creature in ipairs(categoryData.creatures) do
		if creature.id == creatureId then
			return creature
		end
	end
	return nil
end

function Bestiary.onTrackerCheckBoxChange(widget)
	local creatureInfoPanel = Bestiary.UI.creaturePanel.creatureInfoPanel
	if not creatureInfoPanel then
		return
	end

	local creatureId = creatureInfoPanel.selectedCreatureId
	local categoryId = creatureInfoPanel.categoryId

	local creatureData = Bestiary.getCreatureData(creatureId, categoryId)
	if not creatureData then
		return
	end

	local creatureName = creatureData.name

	if widget:isChecked() then
		local trackedCount = 0
		for _ in pairs(Bestiary.trackedCreatures) do
			trackedCount = trackedCount + 1
		end

		if trackedCount >= BESTIARY_MAX_TRACKED_CREATURES then
			widget:setChecked(false)
			Bestiary.setupMessage(
				"Tracker",
				"You have reached the maximum number of tracked creatures (" ..
					BESTIARY_MAX_TRACKED_CREATURES .. "). Please untrack a creature before adding a new one."
			)
			return
		end

		Bestiary.sendOpcode(
			{
				topic = "add-tracked-creature",
				creatureName = creatureName
			}
		)
	else
		Bestiary.sendOpcode(
			{
				topic = "remove-tracked-creature",
				creatureName = creatureName
			}
		)
	end
end

function Bestiary.onTrackedCreatureAdded(data)
	local creatureName = data.creatureName
	if not creatureName then
		return
	end

	Bestiary.trackedCreatures[creatureName] = {
		name = data.creatureName,
		outfit = data.outfit,
		requiredKills = data.requiredKills,
		kills = data.kills,
		categoryId = data.categoryId,
		id = data.id
	}

	table.insert(Bestiary.trackedCreatureList, creatureName)

	local creatureInfoPanel = Bestiary.UI.creaturePanel.creatureInfoPanel
	if creatureInfoPanel and creatureInfoPanel.selectedCreatureId then
		if creatureInfoPanel.selectedCreatureId == data.id then
			creatureInfoPanel.trackerCheckBox:setChecked(true)
		end
	end

	Bestiary.updateTrackerWindow()
end

function Bestiary.onTrackedCreatureRemoved(data)
	local creatureName = data.creatureName
	if not creatureName then
		return
	end

	Bestiary.trackedCreatures[creatureName] = nil

	for index, name in ipairs(Bestiary.trackedCreatureList) do
		if name == creatureName then
			table.remove(Bestiary.trackedCreatureList, index)
			break
		end
	end

	local creatureInfoPanel = Bestiary.UI.creaturePanel.creatureInfoPanel
	if creatureInfoPanel and creatureInfoPanel.selectedCreatureId then
		local creatureData =
			Bestiary.getCreatureData(creatureInfoPanel.selectedCreatureId, creatureInfoPanel.categoryId)
		if creatureData and creatureData.name == creatureName then
			creatureInfoPanel.trackerCheckBox:setChecked(false)
		end
	end

	Bestiary.updateTrackerWindow()
end

function Bestiary.updateTrackerWindow()
	local contentsPanel = Bestiary.trackerWindow.contentsPanel.bestiaryPanel
	contentsPanel:destroyChildren()
	for _, creatureName in ipairs(Bestiary.trackedCreatureList) do
		local creatureData = Bestiary.trackedCreatures[creatureName]
		if creatureData then
			local creatureWidget = g_ui.createWidget("BestiaryEntry", contentsPanel)

			Bestiary.applyOutfit(creatureWidget.creatureIcon, creatureData.outfit)
			creatureWidget.creatureName:setText(creatureData.name)

			local kills = creatureData.kills or 0
			local requiredKills = creatureData.requiredKills or 0

			Bestiary.updateTrackerProgressBars(creatureWidget, kills, requiredKills)
			creatureWidget.onMouseRelease = function(w, mousePosition, mouseButton)
				if mouseButton == MouseRightButton or mouseButton == MouseLeftButton then
					local menu = g_ui.createWidget("PopupMenu")
					menu:setGameMenu(true)
					local label = string.format("Stop tracking %s", creatureData.name)
					menu:addOption(
						label,
						function()
							Bestiary.sendOpcode(
								{
									topic = "remove-tracked-creature",
									creatureName = creatureData.name
								}
							)
						end
					)
					menu:display(mousePosition)
					return true
				end
				return false
			end
		end
	end
end

function Bestiary.updateTrackerProgressBars(creatureWidget, kills, requiredKills)
	local percent = (requiredKills > 0) and (kills / requiredKills * 100) or 0
	percent = math.min(100, percent)

	creatureWidget.killsBar:setPercent(percent)

	if kills >= requiredKills then
		creatureWidget.killsValue:setText("Completed")
	else
		creatureWidget.killsValue:setText(string.format("%d / %d", kills, requiredKills))
	end

	creatureWidget.killsPercent:setText(string.format("%.1f%%", percent))
end

function Bestiary.onTrackedCreatureKill(data)
  local creatureName = data.creatureName
  if not creatureName then return end

  local panel = Bestiary.UI.creaturePanel.creatureInfoPanel
  if panel and panel.selectedCreatureId then
    Bestiary.sendOpcode({
      topic = "creature-info-request",
      creatureId = panel.selectedCreatureId,
      categoryId = panel.categoryId
    })

    Bestiary.requestCreatureLoot(panel.selectedCreatureId, Bestiary.currentLootPage or 1)
  end
end

------ Message Handling Functions

function Bestiary.setupMessage(title, message)
	Bestiary.UI.MessageBase.ConfirmButton.onClick = function()
		Bestiary.UI.MessageBase:setVisible(false)
		Bestiary.UI.LockUI:setVisible(false)
	end

	Bestiary.UI.LockUI:setVisible(true)
	Bestiary.UI.MessageBase:setVisible(true)
	Bestiary.UI.MessageBase:setText(title)

	if type(message) == "table" then
		local formattedMessage = ""
		for _, bonus in ipairs(message) do
			formattedMessage = formattedMessage .. string.format("%s: +%d\n", bonus.name, bonus.value)
		end
		Bestiary.UI.MessageBase.Text:setText(formattedMessage)
	else
		Bestiary.UI.MessageBase.Text:setText(message)
	end

	Bestiary.UI.MessageBase:setHeight(Bestiary.UI.MessageBase.Text:getTextSize().height + 100)
end

------ Charms Functions

function Bestiary.setupCharmsPanel()
	local charmsPanel = Bestiary.UI.charmsPanel.rightPanel.charms
	charmsPanel:destroyChildren()

	for charmId, charmData in pairs(Bestiary.charmsInfo) do
		local charm = g_ui.createWidget("CharmPanelEntry", charmsPanel)
		charm:setText(charmData.name)
		charm:setId("charm_" .. charmId)
		charm.charmPanel.imagePanel:setImageSource("images/charms/" .. charmData.image)

		charm.onFocusChange = function(widget, focused)
			if focused then
				Bestiary.updateLeftCharmPanel(charmData, charmId)
				Bestiary.UI.charmsPanel.leftPanel.searchTextEdit:setText("")
			end
		end
	end

	Bestiary.UI.charmsPanel.leftPanel.searchTextEdit.onTextChange = function(widget, text)
		Bestiary.onSearchEdit(widget, text, Bestiary.UI.charmsPanel.leftPanel.charmMonsters)
	end

	local actionButton = Bestiary.UI.charmsPanel.leftPanel.actionButton
	actionButton.onClick = Bestiary.onCharmActionButtonClick
end

function Bestiary.onCharmActionButtonClick(button)
	local charms = Bestiary.UI.charmsPanel.rightPanel.charms
	local focusedCharm = charms:getFocusedChild()
	if not focusedCharm then
		return
	end

	local charmIdStr = focusedCharm:getId()
	local charmId = charmIdStr:match("%d+")
	local charmData = Bestiary.charmsInfo[charmId]
	local btnText = button:getText()

	if btnText == tr("Unlock") then
		Bestiary.unlockCharmAction(charmData.name, charmData, charmId)
	elseif btnText == tr("Select") then
		Bestiary.selectCharmMonsterAction(charmData.name, charmData, charmId)
	elseif btnText == tr("Remove") then
		Bestiary.removeCharmMonsterAction(charmData.name, charmData, charmId)
	end
end

function Bestiary.unlockCharmAction(charmName, charmData, charmId)
	local window
	local yes = function()
		Bestiary.sendOpcode({topic = "unlock-charm", charmId = charmId})
		window:destroy()
	end
	local no = function()
		window:destroy()
	end

	window =
		displayGeneralBox(
		tr("Unlock Charm"),
		string.format("Are you sure you want to unlock %s charm?", charmName),
		{
			{text = tr("Yes"), callback = yes},
			{text = tr("No"), callback = no},
		},
		yes,
		no
	)
end

function Bestiary.selectCharmMonsterAction(charmName, charmData, charmId)
	local leftPanel = Bestiary.UI.charmsPanel.leftPanel
	local focusedMon = leftPanel.charmMonsters:getFocusedChild()

	if not focusedMon then
		displayErrorBox("Error", "Please select a creature first.")
	else
		Bestiary.sendOpcode(
			{
				topic = "select-charm-monster",
				charmId = charmId,
				charmName = charmName,
				monster = focusedMon.name:getText()
			}
		)
	end
end

function Bestiary.removeCharmMonsterAction(charmName, charmData, charmId)
	local window
	local yes = function()
		Bestiary.sendOpcode({topic = "remove-charm-monster", charmId = charmId, charmName = charmName})
		window:destroy()
	end
	local no = function()
		window:destroy()
	end

	local monsterName = Bestiary.charmData[charmId] and Bestiary.charmData[charmId].monster or "?"
	window =
		displayGeneralBox(
		tr("Remove Monster"),
		string.format("Are you sure you want to remove %s from your %s charm?", monsterName, charmName),
		{
			{text = tr("Yes"), callback = yes},
			{text = tr("No"), callback = no},
		},
		yes,
		no
	)
end

function Bestiary.setupCharmData()
	local charmsPanel = Bestiary.UI.charmsPanel.rightPanel.charms

	for charmId, creature in pairs(Bestiary.charmData or {}) do
		local charmWidget = charmsPanel:getChildById("charm_" .. charmId)
		local creaturePanel = charmWidget.creaturePanel
		if charmWidget and creature.outfit then
			if creaturePanel and creaturePanel.creature then
				Bestiary.applyOutfit(creaturePanel.creature, creature.outfit)
			end
		else
			creaturePanel.creature:setOutfit({})
		end
	end

	for charmId, charmDef in pairs(Bestiary.charmsInfo) do
		local widget = charmsPanel:getChildById("charm_" .. charmId)
		if widget and widget.costPanel then
			local costPanel = widget.costPanel
			local unlocked = Bestiary.charmData and Bestiary.charmData[charmId]
			local assigned = unlocked and unlocked.monster and unlocked.monster ~= ""

			if not unlocked then
				costPanel.cost:setText(charmDef.pointsPrice)
				costPanel.charmIcon:setVisible(true)
				costPanel.goldIcon:setVisible(false)
				widget.charmPanel.imagePanel:setOpacity(0.3)
			else
				local price = assigned and g_game.getLocalPlayer():getLevel() * 100 or 0
				costPanel.cost:setText(price)

				costPanel.charmIcon:setVisible(false)
				costPanel.goldIcon:setVisible(true)
				widget.charmPanel.imagePanel:setOpacity(1)
			end
		end
	end
	Bestiary.sortCharms()
	charmsPanel:getChildByIndex(1):focus()
end

function Bestiary.updateLeftCharmPanel(charmData, charmId)
	local leftPanel = Bestiary.UI.charmsPanel.leftPanel
	leftPanel.informationText:setText(charmData.description)
	leftPanel.charmPanel.imagePanel:setImageSource("images/charms/" .. charmData.image)

	local creatureWidget = leftPanel.creaturePanel and leftPanel.creaturePanel.creature
	local creatureInfo = Bestiary.charmData and Bestiary.charmData[charmId]

	if creatureWidget then
		if creatureInfo and creatureInfo.outfit then
			Bestiary.applyOutfit(creatureWidget, creatureInfo.outfit)
		else
			creatureWidget:setOutfit({})
		end
		creatureWidget:setOpacity(1)
	end

	local costPanel = leftPanel.costPanel
	local unlocked = Bestiary.charmData and Bestiary.charmData[charmId]
	local assigned = unlocked and unlocked.monster and unlocked.monster ~= ""

	if costPanel then
		if not unlocked then
			costPanel.cost:setText(charmData.pointsPrice)
			costPanel.charmIcon:setVisible(true)
			costPanel.goldIcon:setVisible(false)
		else
			local price = assigned and g_game.getLocalPlayer():getLevel() * 100 or 0
			costPanel.cost:setText(price)
			costPanel.charmIcon:setVisible(false)
			costPanel.goldIcon:setVisible(true)
		end
	end

	local actionButton = leftPanel.actionButton
	if actionButton then
		if not unlocked then
			actionButton:setText(tr("Unlock"))
		elseif assigned then
			actionButton:setText(tr("Remove"))
		else
			actionButton:setText(tr("Select"))
		end
	end

	local monstersContainer = leftPanel.charmMonsters
	if not monstersContainer then
		return
	end

	if creatureInfo and creatureInfo.monster then
		monstersContainer:destroyChildren()
		local charmMonster = g_ui.createWidget("CharmMonster", monstersContainer)
		charmMonster.name:setText(creatureInfo.monster)
	else
		Bestiary.createSelectCreatureCharmsList()
	end
end

function Bestiary.createSelectCreatureCharmsList()
	local container = Bestiary.UI.charmsPanel.leftPanel.charmMonsters
	container:destroyChildren()

	local inUse = {}
	for _, charm in pairs(Bestiary.charmData or {}) do
		if charm.monster and charm.monster ~= "" then
			inUse[charm.monster] = true
		end
	end
	for monsterName, outfit in pairs(Bestiary.unlockedCreatures or {}) do
		if not inUse[monsterName] then
			local widget = g_ui.createWidget("CharmMonster", container)
			widget.name:setText(monsterName)

			widget.onFocusChange = function(self, focused)
				if not focused then return end

				local creaturePreview = Bestiary.UI.charmsPanel.leftPanel.creaturePanel and Bestiary.UI.charmsPanel.leftPanel.creaturePanel.creature
				if not creaturePreview then return end

				Bestiary.applyOutfit(creaturePreview, outfit)
				creaturePreview:setOpacity(0.30)
			end
		end
	end
end

function Bestiary.onSearchEdit(widget, text, list)
	text = text:lower()

	for _, element in pairs(list:getChildren()) do
		local monsterName = element.name:getText()
		if monsterName:lower():match(text) then
			element:show()
		else
			element:hide()
		end
	end
end

function Bestiary.sortCharms()
	local charmsPanel = Bestiary.UI.charmsPanel.rightPanel.charms
	if not charmsPanel then return end

	local withMonster, withoutMonster, locked = {}, {}, {}

	for _, child in ipairs(charmsPanel:getChildren()) do
		local idNum   = tostring(child:getId()):match("%d+")
		local unlock  = Bestiary.charmData and Bestiary.charmData[idNum]

		if unlock then
			if unlock.monster and unlock.monster ~= "" then
				table.insert(withMonster,   child)
			else
				table.insert(withoutMonster, child)
			end
		else
			table.insert(locked, child)
		end
	end

	local idx = 1
	for _, list in ipairs{withMonster, withoutMonster, locked} do
		for _, w in ipairs(list) do
			charmsPanel:moveChildToIndex(w, idx)
			idx = idx + 1
		end
	end
end

------ Utilities Functions

function Bestiary.formatNumberShort(n)
	local ret = tostring(n)
	if n >= 10 ^ 12 then
		ret = string.format("%.2fT", n / 10 ^ 12)
	elseif n >= 10 ^ 9 then
		ret = string.format("%.2fB", n / 10 ^ 9)
	elseif n >= 10 ^ 6 then
		ret = string.format("%.2fM", n / 10 ^ 6)
	elseif n >= 10 ^ 3 then
		ret = string.format("%.2fK", n / 10 ^ 3)
	end

	ret = ret:gsub("%.00", "")

	return ret
end

function Bestiary.onCreaturesSearch(widget, text)
	text = text:lower()

	local creaturesPanel = Bestiary.UI.creaturesListPanel
	local firstVisibleChild = nil

	for _, creatureWidget in pairs(creaturesPanel:getChildren()) do
		local creatureName = creatureWidget.name:getText():lower()
		if creatureName:match(text) then
			creatureWidget:show()
			if not firstVisibleChild then
				firstVisibleChild = creatureWidget
			end
		else
			creatureWidget:hide()
		end
	end

	if firstVisibleChild then
		creaturesPanel:focusChild(firstVisibleChild)
	else
		creaturesPanel:focusChild(nil)
	end
end

function Bestiary.applyOutfit(widget, outfit)
	if not widget then return end

	if outfit and next(outfit) then
		widget:setOutfit{
			type = outfit.lookType,
			auxType = outfit.lookTypeEx,
			addons = outfit.lookAddons,
			mount = outfit.lookMount,
			wings = outfit.lookWings,
			aura = outfit.lookAura,
			feet = outfit.lookFeet,
			legs = outfit.lookLegs,
			body = outfit.lookBody,
			head = outfit.lookHead
		}
	else
		widget:setOutfit({})
	end
end

function Bestiary.getSelectedCreatureProgressPercent()
    local panel = Bestiary.UI.creaturePanel.creatureInfoPanel
    if not panel then return 0 end

    local creatureId = panel.selectedCreatureId
    local categoryId = panel.categoryId
    local killsInfo = Bestiary.killsCache[categoryId] and Bestiary.killsCache[categoryId][creatureId]

    if not killsInfo or killsInfo.requiredKills == 0 then
        return 0
    end

    return math.min(100, (killsInfo.kills / killsInfo.requiredKills) * 100)
end

------ Communication Functions

Bestiary.extendedOpcodeChunks = Bestiary.extendedOpcodeChunks or {}

function Bestiary.decodeExtendedOpcodeBuffer(buffer)
	local prefix = buffer:sub(1, 1)

	if prefix == "S" then
		Bestiary.extendedOpcodeChunks[BESTIARY_OPCODE] = buffer:sub(2)
		return nil
	elseif prefix == "P" then
		Bestiary.extendedOpcodeChunks[BESTIARY_OPCODE] = (Bestiary.extendedOpcodeChunks[BESTIARY_OPCODE] or "") .. buffer:sub(2)
		return nil
	elseif prefix == "E" then
		buffer = (Bestiary.extendedOpcodeChunks[BESTIARY_OPCODE] or "") .. buffer:sub(2)
		Bestiary.extendedOpcodeChunks[BESTIARY_OPCODE] = nil
	end

	local ok, data = pcall(json.decode, buffer)
	if not ok then
		g_logger.error("[Bestiary] JSON error: " .. tostring(data))
		return nil
	end

	return data
end

function Bestiary.onExtendedOpcode(protocol, opcode, buffer)
	local data = Bestiary.decodeExtendedOpcodeBuffer(buffer)
	if not data then
		return
	end

	local topic = data.topic

	if topic == "base-data-response" then
		Bestiary.updateBaseData(data)
	elseif topic == "category-creatures-response" then
		Bestiary.updateCreatureList(data)
	elseif topic == "creature-info-response" then
		Bestiary.updateCreatureInfo(data)
	elseif topic == "category-progress-response" then
		Bestiary.updateCategoryKills(data)
	elseif topic == "total-bonuses-response" then
		Bestiary.setupMessage("Total Bonuses", data.bonuses)
	elseif topic == "charmData-reply" then
		Bestiary.charmData = data.charmData
		Bestiary.setupCharmData()
	elseif topic == "unlocked-creatures-list" then
		Bestiary.unlockedCreatures = data.unlockedCreatures
	elseif topic == "tracked-creatures-list" then
		Bestiary.updateTrackedCreatures(data)
	elseif topic == "tracked-creature-added" then
		Bestiary.onTrackedCreatureAdded(data)
	elseif topic == "tracked-creature-removed" then
		Bestiary.onTrackedCreatureRemoved(data)
	elseif topic == "tracked-creature-kill" then
		Bestiary.onTrackedCreatureKill(data)
	elseif data.topic == "category-creatures" then
		Bestiary.categoryCreaturesCache[data.categoryId] = data
		Bestiary.killsCache[data.categoryId] =
		Bestiary.killsCache[data.categoryId] or {}

		for _, creature in ipairs(data.creatures) do
		Bestiary.killsCache[data.categoryId][creature.id] =
			Bestiary.killsCache[data.categoryId][creature.id] or {}

		Bestiary.killsCache[data.categoryId][creature.id].requiredKills =
			creature.requiredKills or 0
		end

		Bestiary.updateCreatureList(data.creatures)
		Bestiary.updatePaginationUI(data.categoryId, data.page, data.totalPages)
	elseif data.topic == "creature-loot" then
		if not Bestiary.UI then return end
		local percent = Bestiary.getSelectedCreatureProgressPercent()
    	Bestiary.setupLootItems(data.loot, percent)
		Bestiary.updateLootPaginationUI(data.creatureId, data.page, data.totalPages)
	elseif topic == "error" then
		local function closeBox() window:destroy() end
		window = displayGeneralBox(
			tr("Error"),
			data.message,
			{
				{ text = tr("Okay"), callback = closeBox }
			},
			closeBox,
			closeBox
		)
	elseif topic == "points-update" then
		Bestiary.UI.bottomPanel.goldPanel.amount:setText(math.max(data.gold, 0))
		Bestiary.UI.bottomPanel.charmsPanel.amount:setText(math.max(data.charmPoints, 0))
	elseif topic == "charm-status-update" then
		Bestiary.UI.charmsPanel.rightPanel.charms:focusChild(nil)
		Bestiary.UI.charmsPanel.rightPanel.charms:getChildById("charm_" .. data.charmId):focus()
	end
end

function Bestiary.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(BESTIARY_OPCODE, data)
	end
end
