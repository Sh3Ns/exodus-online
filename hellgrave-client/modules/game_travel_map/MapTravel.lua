

------ Initialization and Termination

function MapTravel.init()
	connect(
		g_game,
		{
			onGameStart = MapTravel.onGameStart,
			onGameEnd = MapTravel.onGameEnd
		}
	)
	ProtocolGame.registerExtendedOpcode(MapTravel_OPCODE, MapTravel.onExtendedOpcode)

	if g_game.isOnline() then
		MapTravel.onGameStart()
	end
end

function MapTravel.terminate()
	disconnect(
		g_game,
		{
			onGameStart = MapTravel.onGameStart,
			onGameEnd = MapTravel.onGameEnd
		}
	)
	ProtocolGame.unregisterExtendedOpcode(MapTravel_OPCODE)
	MapTravel.onGameEnd()
end

function MapTravel.onGameStart()
    if not MapTravel.UI then
        MapTravel.UI = g_ui.displayUI("MapTravel")
        MapTravel.UI:hide()

        MapTravel.UI.NodesTooltip = g_ui.displayUI("MapTravelTooltip")
        MapTravel.UI.NodesTooltip:hide()

        MapTravel.UI.onKeyDown = function(widget, keyCode)
            if keyCode == KeyEscape then
                MapTravel.UI:hide()
            end
            return false
        end

        if MapTravel.devMode then
            MapTravel.setupDevMode()
        end
    end
    local data = {topic = "request-MapTravel-Cache"}
    MapTravel.sendOpcode(data)
end

function MapTravel.onGameEnd()
	if MapTravel.UI then
		MapTravel.UI.NodesTooltip:destroy()
		MapTravel.UI.NodesTooltip = nil

		MapTravel.UI:destroy()
		MapTravel.UI = nil
	end
end


------ UI Management

function MapTravel.toggle()
	if MapTravel.UI and MapTravel.UI:isVisible() then
		MapTravel.hide()
	else
		MapTravel.show()
	end
end

function MapTravel.show()
	if not MapTravel.UI then
		return
	end
	if not MapTravel.UI:isVisible() then
		MapTravel.UI:show()
		MapTravel.UI:raise()
		-- MapTravel.UI:focus() -- Allow walking while map is open
		if MapTravel.UI.mapPanel then
			MapTravel.UI.mapPanel:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
			MapTravel.UI.mapPanel:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)
		end
	end
end

function MapTravel.hide()
	if MapTravel.UI then
		MapTravel.UI:hide()
	end
end

function MapTravel.updateMap()
	if not MapTravel.UI then
		return
	end

	local mapPanel = MapTravel.UI.mapPanel
	if not mapPanel then
		return
	end

	mapPanel:destroyChildren()

	mapPanel:setImageSource(MapTravel.mapDirectory)
	MapTravel.originalWidth = mapPanel:getWidth()
	MapTravel.originalHeight = mapPanel:getHeight()
	mapPanel:setWidth(MapTravel.originalWidth * MapTravel.mapScale)
	mapPanel:setHeight(MapTravel.originalHeight * MapTravel.mapScale)

	if MapTravel.devMode then
		MapTravel.previewNode = g_ui.createWidget("UIWidget", mapPanel)
		MapTravel.previewNode:setBorderWidth(1)
		MapTravel.previewNode:show()
		MapTravel.previewNode:setImageAutoResize(true)
		MapTravel.previewNode:setPhantom(true)
		MapTravel.UI.mapPanel:setBorderWidth(1)
		MapTravel.UI.mapPanel:setBorderColor("red")
		MapTravel.UI.mapPanel.mapImageDev:setImageSource(MapTravel.mapFilledDirectory or "")
	end

	for nodeIndex, nodeConfig in ipairs(MapTravel.mapNodesConfig) do
		local nodeWidget = g_ui.createWidget("MapTravelNode", mapPanel)
		nodeWidget:addAnchor(AnchorTop, "parent", AnchorTop)
		nodeWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)

		nodeWidget:setMarginTop(nodeConfig.modulePos.marginTop * MapTravel.mapScale)
		nodeWidget:setMarginLeft(nodeConfig.modulePos.marginLeft * MapTravel.mapScale)

		nodeWidget.nameId = nodeConfig.nameId
		nodeWidget.nodeConfig = nodeConfig
		nodeWidget.originalMargin = {
			marginTop = nodeConfig.modulePos.marginTop,
			marginLeft = nodeConfig.modulePos.marginLeft
		}

		nodeWidget.onHoverChange = MapTravel.onNodeHoverChange

		local isUnlocked = (not nodeConfig.discoverable) or MapTravel.unlockedNodes[nodeConfig.nameId]

		local nodeImage = ""
		local nodeEnabled = false
		local nodeVisible = true
		if nodeConfig.discoverable and not isUnlocked then
			nodeEnabled = false
			nodeVisible = false
		else
			if nodeConfig.nameId == MapTravel.currentNodeNameId then
				nodeImage = "images/nodes/normal/" .. nodeConfig.nameId
				nodeEnabled = false
				nodeVisible = true
			else
				nodeImage = "images/nodes/normal/" .. nodeConfig.nameId
				nodeEnabled = true
				nodeVisible = true
			end
		end

		nodeWidget:setImageSource(nodeImage)
		nodeWidget:setEnabled(nodeEnabled)
		nodeWidget:setVisible(nodeVisible)

		MapTravel.originalNodeWidgetWidth = nodeWidget:getWidth()
		MapTravel.originalNodeWidgetHeight = nodeWidget:getHeight()
		nodeWidget:setWidth(MapTravel.originalNodeWidgetWidth * MapTravel.mapScale)
		nodeWidget:setHeight(MapTravel.originalNodeWidgetHeight * MapTravel.mapScale)

		if nodeEnabled then
			nodeWidget.onClick = function()
				MapTravel.requestTravel(nodeIndex, MapTravel.currentNodeNameId)
			end
		else
			nodeWidget.onClick = nil
		end
	end
	MapTravel.makeWidgetDraggable(mapPanel, true)
end

function MapTravel.makeWidgetDraggable(widget, boundToScreen)
	widget.dragging = false
	widget.dragOffset = {x = 0, y = 0}

	widget.onMousePress = function(w, mousePos, button)
		if button ~= MouseLeftButton then
			return false
		end
		w.dragging = true
		local wPos = w:getPosition()
		w.dragOffset.x = mousePos.x - wPos.x
		w.dragOffset.y = mousePos.y - wPos.y
		return true
	end

	widget.onMouseRelease = function(w, mousePos, button)
		if w.dragging then
			w.dragging = false
			return true
		end
		return false
	end

	widget.onMouseMove = function(w, mousePos, mouseMoved)
		if not w.dragging then
			return false
		end

		local newX = mousePos.x - w.dragOffset.x
		local newY = mousePos.y - w.dragOffset.y

		if boundToScreen then
			local screenSize = g_window.getSize()
			local widgetSize = w:getSize()

			local maxX = screenSize.width - widgetSize.width
			if newX < 0 then
				newX = 0
			end
			if newX > maxX then
				newX = maxX
			end

			local maxY = screenSize.height - widgetSize.height
			if newY < 0 then
				newY = 0
			end
			if newY > maxY then
				newY = maxY
			end
		end
		w:breakAnchors()
		w:setPosition({x = newX, y = newY})
		return true
	end
end


------ Extended Opcode Handling

function MapTravel.onExtendedOpcode(protocol, opcode, buffer)
	if opcode ~= MapTravel_OPCODE then
		return
	end
	local data = json.decode(buffer)
	if not data or not data.topic then
		return
	end

	if data.topic == "full-MapTravel-Cache" then
		MapTravel.buildDiscoveredData(data.discoveredNodes)
		MapTravel.updateMap()
	elseif data.topic == "launch-MapTravel" then
		MapTravel.handleLaunchMapTravel(data)
	elseif data.topic == "close-MapTravel" then
		MapTravel.hide()
	end
end

function MapTravel.handleLaunchMapTravel(data)
	MapTravel.currentNodeNameId = data.currentNode
	MapTravel.updateMap()
	MapTravel.show()
end

function MapTravel.buildDiscoveredData(discoveredNodes)
	MapTravel.unlockedNodes = {}
	if discoveredNodes then
		for _, nodeNameId in ipairs(discoveredNodes) do
			MapTravel.unlockedNodes[nodeNameId] = true
		end
	end
end

function MapTravel.requestTravel(nodeIndex, currentNode)
	local data = {
		topic = "travel",
		nodeIndex = nodeIndex,
		currentNode= currentNode,
	}
	MapTravel.sendOpcode(data)
end

function MapTravel.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(MapTravel_OPCODE, data)
	end
end


------ Node Interaction

function MapTravel.onNodeHoverChange(widget, hovered)
	if not MapTravel.UI then
		return
	end

	if widget.nameId == MapTravel.currentNodeNameId then
		return
	end

	if hovered then
		MapTravel.applyNodeTooltip(widget.nodeConfig)
		connect(rootWidget, {onMouseMove = MapTravel.moveNodeToolTip})
		widget:setImageSource("images/nodes/hover/" .. widget.nameId)
	else
		MapTravel.UI.NodesTooltip:hide()
		disconnect(rootWidget, {onMouseMove = MapTravel.moveNodeToolTip})
		widget:setImageSource("images/nodes/normal/" .. widget.nameId)
	end

	local originalWidth = widget:getWidth()
	local originalHeight = widget:getHeight()
	widget:setWidth(originalWidth * MapTravel.mapScale)
	widget:setHeight(originalHeight * MapTravel.mapScale)
end

function MapTravel.addTooltipLine(text, iconKey)
	local entry = g_ui.createWidget("MapTravelCostEntry", MapTravel.UI.NodesTooltip)
	entry.text:setText(text)

	local iconPath = MapTravel.icons[iconKey or ""]
	if iconPath then
		entry.icon:setImageSource(iconPath)
	else
		entry.icon:setImageSource("")
	end
end

function MapTravel.applyNodeTooltip(nodeConfig)
	MapTravel.UI.NodesTooltip:destroyChildren()

	MapTravel.UI.NodesTooltip:setText(nodeConfig.displayName)

	if nodeConfig.premium then
		MapTravel.addTooltipLine("Requires Premium Account", "premium")
	end

	if nodeConfig.storagesReqs and #nodeConfig.storagesReqs > 0 then
		for _, storReq in ipairs(nodeConfig.storagesReqs) do
			MapTravel.addTooltipLine(storReq.name, "progressReq")
		end
	end

	if nodeConfig.cost then
		if nodeConfig.cost.gold and nodeConfig.cost.gold > 0 then
			MapTravel.addTooltipLine("Gold: " .. nodeConfig.cost.gold, "gold")
		end

		if nodeConfig.cost.items and #nodeConfig.cost.items > 0 then
			for _, itemInfo in ipairs(nodeConfig.cost.items) do
				local lineText = string.format("%dx %s", itemInfo.amount, itemInfo.name)
				MapTravel.addTooltipLine(lineText, "item")
			end
		end

		if nodeConfig.cost.storage and #nodeConfig.cost.storage > 0 then
			for _, sInfo in ipairs(nodeConfig.cost.storage) do
				local lineText = string.format("%d %s", sInfo.amount, sInfo.name)
				MapTravel.addTooltipLine(lineText, "storage")
			end
		end
	end

	MapTravel.UI.NodesTooltip:show()
	MapTravel.moveNodeToolTip()
end

function MapTravel.moveNodeToolTip()
	if not MapTravel.UI or not MapTravel.UI.NodesTooltip or not MapTravel.UI.NodesTooltip:isVisible() then
		return
	end

	local pos = g_window.getMousePosition()
	local windowSize = g_window.getSize()
	local tipSize = MapTravel.UI.NodesTooltip:getSize()

	pos.x = pos.x + 1
	pos.y = pos.y + 1

	if (windowSize.width - (pos.x + tipSize.width)) < 10 then
		pos.x = pos.x - tipSize.width - 3
	else
		pos.x = pos.x + 10
	end

	if (windowSize.height - (pos.y + tipSize.height)) < 10 then
		pos.y = pos.y - tipSize.height - 3
	else
		pos.y = pos.y + 10
	end

	MapTravel.UI.NodesTooltip:setPosition(pos)
	MapTravel.UI.NodesTooltip:raise()
end


------ Development Mode

function MapTravel.onDevModeHoverChange(widget, hovered)
	if MapTravel.UI and MapTravel.devMode then
		if hovered then
			connect(rootWidget, {onMouseMove = MapTravel.updateDevNodePreviewNodePosition})
		else
			disconnect(rootWidget, {onMouseMove = MapTravel.updateDevNodePreviewNodePosition})
		end
	end
end

function MapTravel.setupDevMode()
	local mapPanel = MapTravel.UI.mapPanel
	if not mapPanel then
		return
	end

	mapPanel.devModePanel:setVisible(true)
	mapPanel.nodesComboBox:setVisible(true)
	mapPanel.mapImageDev:setVisible(true)

	mapPanel.nodesComboBox:clear()

	for _, nodeConfig in ipairs(MapTravel.mapNodesConfig) do
		mapPanel.nodesComboBox:addOption(nodeConfig.nameId)
	end

	mapPanel.nodesComboBox.onOptionChange = function()
		if MapTravel.previewNode then
			MapTravel.previewNode:setImageSource("images/nodes/normal/" .. mapPanel.nodesComboBox:getText())
			MapTravel.previewNode:setWidth(MapTravel.previewNode:getWidth() * MapTravel.mapScale)
			MapTravel.previewNode:setHeight(MapTravel.previewNode:getHeight() * MapTravel.mapScale)
		end
	end

	mapPanel.mapImageDev.onHoverChange = MapTravel.onDevModeHoverChange

	mapPanel.mapImageDev.onClick = function(widget, mousePos)
		local globalMouse = g_window.getMousePosition()
		local mapPos = mapPanel:getPosition()

		local marginLeft = globalMouse.x - mapPos.x
		local marginTop = globalMouse.y - mapPos.y
		local marginsText = "{marginTop = " .. marginTop .. ", marginLeft = " .. marginLeft .. "}"

		print("Clicked at: " .. marginsText)
		g_window.setClipboardText(marginsText)
	end
end

function MapTravel.updateDevNodePreviewNodePosition()
	if not MapTravel.previewNode or not MapTravel.previewNode:isVisible() then
		return
	end

	local mousePos = g_window.getMousePosition()
	local mapImage = MapTravel.UI.mapPanel

	if mapImage then
		local mapPos = mapImage:getPosition()
		local marginLeft = mousePos.x - mapPos.x
		local marginTop = mousePos.y - mapPos.y

		MapTravel.UI.mapPanel.devModePanel:setText(
			"Dev Mode\nMargin Top: " .. marginTop .. "\nMargin Left: " .. marginLeft
		)

		MapTravel.previewNode:setPosition(
			{
				x = mapPos.x + marginLeft,
				y = mapPos.y + marginTop
			}
		)
	end
end
