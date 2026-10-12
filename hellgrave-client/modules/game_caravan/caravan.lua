local CODE = 220

local window = nil
local upgradeWindow = nil
local visualsPanel = nil
local materialsPanel = nil
local upgradeMaterialsPanel = nil
local currentData = nil
local caravanButton = nil

local COLORS = {
	green = "#00ff00",
	red = "#ff0000",
	white = "#ffffff",
	gray = "#b0b0b0",
	gold = "#ffd700"
}

function init()
	connect(g_game, {
		onGameStart = create,
		onGameEnd = destroy
	})

	ProtocolGame.registerExtendedOpcode(CODE, onExtendedOpcode)

	caravanButton = modules.client_topmenu.addRightGameToggleButton(
		'caravanButton',
		tr('Caravan'),
		'/images/topbuttons/caravan',
		toggleWindow,
		false,
		8
	)

	if g_game.isOnline() then
		create()
	end
end

function toggle()
	if not window then
		return
	end

	if window:isVisible() then
		hide()
	else
		requestOpen()
	end
end

function terminate()
	disconnect(g_game, {
		onGameStart = create,
		onGameEnd = destroy
	})

	ProtocolGame.unregisterExtendedOpcode(CODE, onExtendedOpcode)

	if caravanButton then
		caravanButton:destroy()
		caravanButton = nil
	end

	destroy()
end

function create()
	if window then
		return
	end

	window = g_ui.displayUI("caravan")
	window:hide()
	upgradeWindow = g_ui.createWidget("CaravanUpgradeWindow", rootWidget)
	if upgradeWindow then
		upgradeWindow:setId("caravanUpgradeWindow")
		upgradeWindow:hide()
	end

	visualsPanel = window:recursiveGetChildById("visualsPanel")
	materialsPanel = window:recursiveGetChildById("materialsPanel")
	if upgradeWindow then
		upgradeMaterialsPanel = upgradeWindow:recursiveGetChildById("upgradeMaterialsPanel")
	end
end

function toggleWindow()
	if not window then
		return
	end

	if window:isVisible() then
		hide()
	else
		requestOpen()
	end
end

function destroy()
	if window then
		visualsPanel = nil
		materialsPanel = nil
		upgradeMaterialsPanel = nil
		currentData = nil
		window:destroy()
		window = nil
	end

	if upgradeWindow then
		upgradeWindow:destroy()
		upgradeWindow = nil
	end
end

local function sendAction(action, extra)
	local protocolGame = g_game.getProtocolGame()
	if not protocolGame then
		return
	end

	local payload = extra or {}
	payload.action = action

	protocolGame:sendExtendedOpcode(CODE, json.encode(payload))
end

function requestOpen()
	sendAction("requestOpen")
end

function toggleMode()
	local toggleButton = window and window:getChildById("toggleButton")
	local localPlayer = g_game.getLocalPlayer()
	if currentData and not currentData.enabled and localPlayer and not localPlayer:isMounted() then
		if toggleButton then
			toggleButton:setText("Deactivate")
		end
		localPlayer:mount()

		scheduleEvent(function()
			local player = g_game.getLocalPlayer()
			if not player then
				return
			end

			if player:isMounted() then
				sendAction("toggle")
			else
				if toggleButton then
					toggleButton:setText("Activate")
				end
				setFeedbackMessage("Mount the player first to activate the caravan.", COLORS.red)
			end
		end, 250)
		return
	end

	if toggleButton and currentData then
		toggleButton:setText(currentData.enabled and "Activate" or "Deactivate")
	end
	sendAction("toggle")
end

function openStorage()
	sendAction("openStorage")
end

function upgrade()
	sendAction("upgrade")
end

function openUpgradeWindow()
	if not currentData or not upgradeWindow then
		return
	end

	refreshUpgradeWindow(currentData)
	upgradeWindow:show()
	upgradeWindow:raise()
	upgradeWindow:focus()
end

function closeUpgradeWindow()
	if upgradeWindow then
		upgradeWindow:hide()
	end
end

local function setFeedbackMessage(text, color)
	if not window then
		return
	end

	local feedbackLabel = window:recursiveGetChildById("feedbackLabel")
	if not feedbackLabel then
		return
	end

	feedbackLabel:setText(text or "")
	feedbackLabel:setColor(color or COLORS.gray)
end

local function setUpgradeStatusMessage(text, color)
	if not upgradeWindow then
		return
	end

	local statusLabel = upgradeWindow:recursiveGetChildById("upgradeWindowStatusLabel")
	if not statusLabel then
		return
	end

	statusLabel:setText(text or "")
	statusLabel:setColor(color or COLORS.gray)
end

function confirmUpgrade()
	if not currentData or not currentData.nextUpgrade or not upgradeWindow then
		return
	end

	local hasAllMaterials = true
	for _, material in ipairs(currentData.nextUpgrade.materials or {}) do
		if material.playerCount < material.count then
			hasAllMaterials = false
			break
		end
	end

	if not hasAllMaterials then
		setUpgradeStatusMessage("You don't have required materials.", COLORS.red)
		return
	end

	setUpgradeStatusMessage("Upgrade requested...", COLORS.white)
	upgrade()
end

function selectVisual(id)
	sendAction("selectVisual", { id = id })
end

function show()
	if not window then
		return
	end

	window:show()
	window:raise()
	window:focus()
end

function hide()
	if window then
		window:hide()
	end

	closeUpgradeWindow()
end

local function setTextColor(widget, text, color)
	if not widget then
		return
	end

	widget:setText(text)
	widget:setColor(color)
end

local function clearVisuals()
	if visualsPanel then
		for i = 1, 8 do
			local widget = visualsPanel:getChildById("visual" .. i)
			if widget then
				widget:hide()
			end
		end
	end
end

local function clearMaterials()
	if materialsPanel then
		for i = 1, 4 do
			local widget = materialsPanel:getChildById("material" .. i)
			if widget then
				widget:hide()
			end
		end
	end
end

local function clearUpgradeMaterials()
	if upgradeMaterialsPanel then
		for i = 1, 6 do
			local widget = upgradeMaterialsPanel:getChildById("upgradeMaterial" .. i)
			if widget then
				widget:hide()
			end
		end
	end
end

local function setContentEnabled(enabled)
	local contentPanel = window:recursiveGetChildById("contentPanel")
	local lockMessage = window:recursiveGetChildById("lockMessage")
	local toggleButton = window:recursiveGetChildById("toggleButton")
	local storageButton = window:recursiveGetChildById("storageButton")
	local upgradeButton = window:recursiveGetChildById("upgradeButton")

	if contentPanel then
		contentPanel:setOpacity(enabled and 1.0 or 0.35)
	end

	if lockMessage then
		lockMessage:setVisible(not enabled)
	end

	if toggleButton then
		toggleButton:setEnabled(enabled)
	end

	if storageButton then
		storageButton:setEnabled(enabled)
	end

	if upgradeButton then
		upgradeButton:setEnabled(enabled)
	end
end

local function renderHeader(data)
	local modeLabel = window:recursiveGetChildById("modeLabel")
	local activeLabel = window:recursiveGetChildById("activeLabel")
	local mountLabel = window:recursiveGetChildById("mountLabel")
	local toggleButton = window:recursiveGetChildById("toggleButton")

	if data.enabled then
		setTextColor(modeLabel, "Mode: Activated", COLORS.green)
		if toggleButton then
			toggleButton:setText("Deactivate")
		end
	else
		setTextColor(modeLabel, "Mode: Deactivated", COLORS.red)
		if toggleButton then
			toggleButton:setText("Activate")
		end
	end

	if data.enabled then
		setTextColor(activeLabel, "Caravan: Active", COLORS.green)
	else
		setTextColor(activeLabel, "Caravan: Inactive", COLORS.red)
	end

	if data.mounted then
		setTextColor(mountLabel, "Mount: Mounted", COLORS.green)
	else
		setTextColor(mountLabel, "Mount: Not mounted", COLORS.red)
	end
end

local function renderStorage(data)
	local storage = data.storage
	local storageLevelLabel = window:recursiveGetChildById("storageLevelLabel")
	local storageCapacityLabel = window:recursiveGetChildById("storageCapacityLabel")
	local upgradeInfoLabel = window:recursiveGetChildById("upgradeInfoLabel")
	local upgradeButton = window:recursiveGetChildById("upgradeButton")

	if storageLevelLabel then
		storageLevelLabel:setText(string.format("Storage Level: %d / %d", storage.level, storage.maxLevel))
	end

	if storageCapacityLabel then
		storageCapacityLabel:setText(string.format("Capacity: %d / %d slots", storage.capacity, storage.maxCapacity))
	end

	clearMaterials()

	local nextUpgrade = data.nextUpgrade
	if not nextUpgrade then
		if upgradeInfoLabel then
			upgradeInfoLabel:setText("Storage fully upgraded.")
			upgradeInfoLabel:setColor(COLORS.green)
		end

		if upgradeButton then
			upgradeButton:setText("Max Level")
			upgradeButton:setEnabled(false)
		end

		return
	end

	if upgradeInfoLabel then
		upgradeInfoLabel:setText(string.format(
			"Next Upgrade: Level %d - %d slots",
			nextUpgrade.level,
			nextUpgrade.capacity
		))
		upgradeInfoLabel:setColor(COLORS.white)
	end

	if upgradeButton then
		upgradeButton:setText("Open Upgrade")
		upgradeButton:setEnabled(data.unlocked)
	end

	for i, material in ipairs(nextUpgrade.materials or {}) do
		local widget = materialsPanel:getChildById("material" .. i)
		if not widget then
			break
		end
		widget:show()

		local item = widget:getChildById("item")
		local name = widget:getChildById("name")
		local count = widget:getChildById("count")

		if item then
			item:setItemId(material.clientId)
		end

		if name then
			name:setText(material.name)
		end

		if count then
			count:setText(material.playerCount .. " / " .. material.count)
			count:setColor(material.playerCount >= material.count and COLORS.green or COLORS.red)
		end
	end
end

local function setVisualTooltip(widget, text)
	if not widget then
		return
	end

	widget:setTooltip(text or "")

	local children = widget:getChildren()
	for i = 1, #children do
		children[i]:setTooltip(text or "")
	end
end

local function renderVisuals(data)
	clearVisuals()

	for _, visual in ipairs(data.visuals or {}) do
		local widget = visualsPanel:getChildById("visual" .. (visual.id + 1))
		if not widget then
			break
		end
		widget:show()

		if visual.unlocked then
			setVisualTooltip(widget, "")
		else
			setVisualTooltip(widget, visual.unlockHint or "This caravan visual is locked.")
		end
		local preview = widget:getChildById("preview")
		local name = widget:getChildById("name")
		local unlockStatus = widget:getChildById("unlockStatus")
		local lockedOverlay = widget:getChildById("lockedOverlay")
		local activeStatus = widget:getChildById("activeStatus")
		local selectButton = widget:getChildById("selectButton")

		if preview then
			local outfit = visual.outfit or {
				type = visual.lookType,
				head = 0,
				body = 0,
				legs = 0,
				feet = 0,
				addons = 0,
				mount = 0
			}
			preview:setOutfit(outfit)
			preview:setCenter(true)
			preview:setVisible(true)
			preview:setOpacity(visual.unlocked and 1.0 or 0.35)
		end

		if name then
			name:setText(visual.name)
		end

		if visual.unlocked then
			setTextColor(unlockStatus, "Unlocked", COLORS.green)
		else
			setTextColor(unlockStatus, "Locked", COLORS.red)
		end

		if lockedOverlay then
			lockedOverlay:setVisible(not visual.unlocked)
		end

		if not visual.unlocked then
			setTextColor(activeStatus, "", COLORS.red)
		elseif visual.active then
			setTextColor(activeStatus, "Activated", COLORS.green)
		else
			setTextColor(activeStatus, "Deactivated", COLORS.red)
		end

		if visual.selected then
			widget:setBorderWidth(1)
			widget:setBorderColor(COLORS.gold)
		else
			widget:setBorderWidth(0)
		end

		if selectButton then
			if not visual.unlocked or not data.unlocked then
				selectButton:setText("Locked")
				selectButton:setEnabled(false)
			elseif visual.selected then
				selectButton:setText("Deactivate Visual")
				selectButton:setEnabled(false)
			elseif visual.unlocked and data.unlocked then
				selectButton:setText("Activate Visual")
				selectButton:setEnabled(true)
				selectButton.onClick = function()
					selectVisual(visual.id)
				end
			end
		end
	end
end

function refreshUpgradeWindow(data)
	if not upgradeWindow or not data then
		return
	end

	local nextUpgrade = data.nextUpgrade
	local levelLabel = upgradeWindow:recursiveGetChildById("upgradeWindowLevelLabel")
	local capacityLabel = upgradeWindow:recursiveGetChildById("upgradeWindowCapacityLabel")
	local confirmButton = upgradeWindow:recursiveGetChildById("upgradeConfirmButton")

	clearUpgradeMaterials()

	if not nextUpgrade then
		if levelLabel then
			levelLabel:setText(string.format("Storage Level: %d / %d", data.storage.level, data.storage.maxLevel))
		end
		if capacityLabel then
			capacityLabel:setText("Your caravan storage is already at max level.")
		end
		if confirmButton then
			confirmButton:setEnabled(false)
			confirmButton:setText("Max Level")
		end

		setUpgradeStatusMessage("Storage fully upgraded.", COLORS.green)
		return
	end

	if levelLabel then
		levelLabel:setText(string.format("Upgrade to Level %d / %d", nextUpgrade.level, data.storage.maxLevel))
	end
	if capacityLabel then
		capacityLabel:setText(string.format("Capacity after upgrade: %d slots", nextUpgrade.capacity))
	end

	local hasAllMaterials = true
	for i, material in ipairs(nextUpgrade.materials or {}) do
		local widget = upgradeMaterialsPanel:getChildById("upgradeMaterial" .. i)
		if not widget then
			break
		end
		widget:show()

		local item = widget:getChildById("item")
		local name = widget:getChildById("name")
		local count = widget:getChildById("count")

		if item then
			item:setItemId(material.clientId)
		end
		if name then
			name:setText(material.name)
		end
		if count then
			count:setText(material.playerCount .. " / " .. material.count)
			count:setColor(material.playerCount >= material.count and COLORS.green or COLORS.red)
		end

		if material.playerCount < material.count then
			hasAllMaterials = false
		end
	end

	if confirmButton then
		confirmButton:setEnabled(data.unlocked)
		confirmButton:setText("Upgrade")
	end

	if hasAllMaterials then
		setUpgradeStatusMessage("Upgrade available.", COLORS.green)
	else
		setUpgradeStatusMessage("You don't have required materials.", COLORS.red)
	end
end

function refresh(data)
	if not window or not data then
		return
	end

	currentData = data

	setContentEnabled(data.unlocked)
	renderHeader(data)
	renderStorage(data)
	renderVisuals(data)
	refreshUpgradeWindow(data)
end

function onExtendedOpcode(protocol, opcode, buffer)
	if opcode ~= CODE then
		return
	end

	local ok, payload = pcall(function()
		return json.decode(buffer)
	end)

	if not ok or not payload or not payload.action then
		g_logger.error("[Caravan] Invalid opcode payload: " .. tostring(buffer))
		return
	end

	if payload.action == "show" then
		refresh(payload.data)
		show()
	elseif payload.action == "state" then
		refresh(payload.data)
	elseif payload.action == "message" then
		setFeedbackMessage(payload.text or "", payload.color or COLORS.gray)

		if upgradeWindow and upgradeWindow:isVisible() then
			setUpgradeStatusMessage(payload.text or "", payload.color or COLORS.gray)
		end
	end
end
