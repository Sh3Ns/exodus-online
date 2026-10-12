local window, view, decoView, nodesView = nil
local pointsOwned = 0
CODE_SKILLTREE = 65
local DEBUG = false
local focusedNode = nil
local currentPreset = 0
local currentSelected = 0
local confirmationDialog = nil
local importPreviewDialog = nil
local importPreviewBackup = nil
local pendingImportBuild = nil
STARTOFFSET = {
	x = 0,
	y = -200
}
LASTPOS = {
	x = 0,
	y = 0
}
local LIMIT_X = 8000
local LIMIT_Y = 7000
local SCROLL_X = -700
local SCROLL_Y = 1200
local t_insert = table.insert
local m_pi = math.pi
local m_sin = math.sin
local m_cos = math.cos
local m_tan = math.tan
local m_atan2 = math.atan2
local m_sqrt = math.sqrt
local m_max = math.max


local function getPlayerVocation()
  local player = g_game.getLocalPlayer()
  local cid = player:getVocation()
  if cid == 1 then
    return "knight"
  elseif cid == 2 then
    return "paladin"
  elseif cid == 3 then
    return "sorcerer"
  elseif cid == 4 then
    return "druid"
  elseif cid == 5 then
	return "illusionist"
  elseif cid == 6 then
	return "monk"
  end
  return nil
end

local orbitDist = {
	[0] = 0,
	60,
	80,
	120,
	191,
	250,
	290
}
local allocNodes = {}
local nodeMap = {}
local treeData = {}

passiveButton, VocationSelected = nil


function init()
	passiveButton = modules.client_topmenu.addRightGameToggleButton('passiveButton', tr('Passive Tree'), '/images/topbuttons/passive_tree', toggle, false, 8)

	if not passiveButton then
		return
	end
	modules.game_passivetree.hide()

	connect(g_game, {
		onGameStart = create,
		onGameEnd = destroy
	})
	ProtocolGame.registerExtendedOpcode(CODE_SKILLTREE, onExtendedOpcode)

	if g_game.isOnline() then
		create()
		show()
	end

	return 
end

function isVisible()
    return window and window:isVisible()
end

function toggle()
	if modules.game_passivetree.isVisible() then
	  close()
	else
	  show()
	end
  end

function changeVocation(button)
	VocationSelected = button.getText(button):lower()

	createNodes()

	return 
end

function terminate()
	disconnect(g_game, {
		onGameStart = create,
		onGameEnd = destroy
	})
	ProtocolGame.unregisterExtendedOpcode(CODE_SKILLTREE, onExtendedOpcode)

	if passiveButton then
		passiveButton:destroy()

		passiveButton = nil
	end

	VocationSelected = nil

	destroy()

	return 
end

function create()
	if window then
		return 
	end

	local treeX = getTreeData()

	for k, v in pairs(treeX) do
		treeData[k] = v
	end

	window = g_ui.loadUI("passivetree", modules.game_interface.getRootPanel())
	window.onMouseWheel = function (self, mousePos, mouseWheel)
		-- if mouseWheel == MouseWheelUp then
		-- 	zoomPlus()
		-- else
		-- 	zoomLess()
		-- end

		return 
	end

	window.pWindow.points:setText(pointsOwned .. " points")

	view = window:recursiveGetChildById("view")
	background = window:recursiveGetChildById("background")
	decoView = window:recursiveGetChildById("decoView")
	nodesView = window:recursiveGetChildById("nodesView")

	background:setWidth(LIMIT_X)
	background:setHeight(LIMIT_Y)
	decoView:setWidth(LIMIT_X)
	decoView:setHeight(LIMIT_Y)
	nodesView:setWidth(LIMIT_X)
	nodesView:setHeight(LIMIT_Y)
	background:setMarginLeft(SCROLL_X)
	background:setMarginTop(SCROLL_Y)
	decoView:setMarginLeft(SCROLL_X)
	decoView:setMarginTop(SCROLL_Y)
	nodesView:setMarginLeft(SCROLL_X)
	nodesView:setMarginTop(SCROLL_Y)

	view.onDragEnter = onDragEnter
	view.onDragLeave = onDragLeave
	view.onDragMove = onDragMove

	for _, child in pairs(nodesView:getChildren()) do
		child.setHeight(child, child.getHeight(child)*SCALE)
		child.setWidth(child, child.getWidth(child)*SCALE)
		child.setImageHeight(child, child.getImageHeight(child)*SCALE)
		child.setImageWidth(child, child.getImageWidth(child)*SCALE)
		child.setIconWidth(child, child.getIconWidth(child)*SCALE)
		child.setIconHeight(child, child.getIconHeight(child)*SCALE)
	end

	for _, child in pairs(decoView:getChildren()) do
		child.setHeight(child, child.getHeight(child)*SCALE)
		child.setWidth(child, child.getWidth(child)*SCALE)
		child.setImageHeight(child, child.getImageHeight(child)*SCALE)
		child.setImageWidth(child, child.getImageWidth(child)*SCALE)
	end

	for i = 1, 3, 1 do
		local slots = window.presets.slots
		local presetItem = slots["preset" .. i]
		if presetItem then
			presetItem.onClick = function (self)
				if self.unlocked then
					window.presets.presetsSave.presetName:setText(presetItem:getText())
					currentSelected = i

					if i ~= currentPreset then
						sendAction("switchPreset", { preset = i })
					end
				else
					return
				end

				return
			end
		end
	end

	window.presets.presetsSave.savePresetButton.onClick = function()
		renamePreset()
	end

	hide()

	return 
end

local function updateAllConnectors()
  for _, node in pairs(nodeMap) do
    for _, otherId in pairs(node.out or {}) do
      local connector =
        decoView:getChildById(node.id .. "-" .. otherId) or
        decoView:getChildById(otherId .. "-" .. node.id)

      if connector then
        local other = nodeMap[otherId]
        local lineType = "Normal"

        if node.alloc and other.alloc then
          lineType = "Active"
        elseif node.alloc ~= other.alloc then
          lineType = "Intermediate"
        end

        if node.groupX == other.groupX and node.orbit == other.orbit then
          local dist = math.sqrt((other.x - node.x)^2 + (other.y - node.y)^2)
          connector:setStyle("Orbit" .. getOrbitType(node.orbit, dist) .. lineType)
        else
          connector:setStyle("LineConnector" .. lineType)
        end
      end
    end
  end
end

function createNodes()
	local totalNodes = 0

	-- if SCALE_MAX <= SCALE then
	-- 	window.zoomPlus:setEnabled(false)
	-- else
	-- 	window.zoomPlus:setEnabled(true)
	-- end

	-- if SCALE <= SCALE_MIN then
	-- 	window.zoomLess:setEnabled(false)
	-- else
	-- 	window.zoomLess:setEnabled(true)
	-- end

	allocNodes = {}

	decoView:destroyChildren()
	nodesView:destroyChildren()

	local widget = nil

	for _, group in pairs(treeData.groups) do
		if group.orbit ~= 0 then
			widget = g_ui.createWidget("DecorationCircle", decoView)

			widget.setMarginLeft(widget, group.x*SCALE)
			widget.setMarginTop(widget, group.y*SCALE)

			if group.bgOffsetY then
				widget.setMarginBottom(widget, group.bgOffsetY*SCALE)
			end

			widget.setImageSource(widget, "/images/passivetree/PSGroupBackground" .. group.orbit)

			if DEBUG then
				widget.setText(widget, _)
			end

			widget = nil

			if group.mastery then
				widget = g_ui.createWidget("DecorationCircle", decoView)

				widget.setMarginLeft(widget, group.x*SCALE)
				widget.setMarginTop(widget, group.y*SCALE)

				local masteryIcon = treeData.icons[group.mastery]

				widget.setImageSource(widget, masteryIcon.file)
				widget.setWidth(widget, masteryIcon.w*SCALE)
				widget.setHeight(widget, masteryIcon.h*SCALE)
				widget.setImageClip(widget, masteryIcon.x .. " " .. masteryIcon.y .. " " .. masteryIcon.w .. " " .. masteryIcon.h)

				if DEBUG then
					widget.setText(widget, _)
				end
			end
		end
	end

	local NODES_MAX = 700

	for id = 1, NODES_MAX, 1 do
		local node = treeData.nodes[id]

		if node or false then
			local group = treeData.groups[node.group]
			local vocationNode = node[getPlayerVocation()]
			local icon = treeData.icons[node.icon]

			if not node.isStartNode and vocationNode then
				icon = treeData.icons[vocationNode.icon] or icon
			end

			node.id = id
			node.linkedId = {}
			node.groupX = group

			if node.isStartNode then
				node.alloc = true
				allocNodes[node.id] = node
				widget = g_ui.createWidget("DecorationCircle", decoView)

				widget.setMarginLeft(widget, group.x*SCALE)
				widget.setMarginTop(widget, group.y*SCALE)
				widget.setImageSource(widget, icon.file)
				widget.setImageClip(widget, icon.x .. " " .. icon.y .. " " .. icon.w .. " " .. icon.h)
			else
				node.alloc = false

				if group then
					node.angle = (node.orbitIndex * m_pi) / 180
					local defaultDist = orbitDist[node.orbit]
					local customDist = node.orbitDist and node.orbitDist > 0 and node.orbitDist or 0
					local dist = customDist > 0 and customDist or defaultDist
					node.x = group.x + m_sin(node.angle) * dist
					node.y = group.y - m_cos(node.angle) * dist
				end				

				local nodeClass = "CommonNode"

				if node.isUncommon then
					nodeClass = "UncommonNode"
				elseif node.isRare then
					nodeClass = "RareNode"
				elseif node.isVeryRare then
					nodeClass = "VeryRareNode"
				elseif node.isMythic then
					nodeClass = "MythicNode"
				elseif node.isDivine then
					nodeClass = "DivineNode"
				end

				widget = g_ui.createWidget(nodeClass, nodesView)

				widget.setId(widget, node.id)
				widget.setMarginLeft(widget, node.x*SCALE)
				widget.setMarginTop(widget, node.y*SCALE)
				widget.setIconOffsetX(widget, widget.getIconOffsetX(widget)*SCALE)
				widget.setIconOffsetY(widget, widget.getIconOffsetY(widget)*SCALE)
				widget.setImageClip(widget, icon.x .. " " .. icon.y .. " " .. icon.w .. " " .. icon.h)

				local tooltipType = 1
				
				if node.isUncommon then
					tooltipType = 2
				elseif node.isRare then
					tooltipType = 3
				elseif node.isVeryRare then
					tooltipType = 7
				elseif node.isMythic then
					tooltipType = 6
				elseif node.isDivine then
					tooltipType = 8
				end

				if DEBUG then
					widget.setText(widget, id)
				end

				local customStats = (vocationNode and vocationNode.customStats) or node.customStats
				local nodeName = (vocationNode and vocationNode.name) or node.name

				if customStats then
					local texts = getCustomStatString(customStats)

					widget.setExtendedTooltip(widget, nodeName .. ((DEBUG and " (ID: " .. id .. ")") or ""), texts, tooltipType)
				elseif node.stats then
					widget.setExtendedTooltip(widget, nodeName .. ((DEBUG and " (ID: " .. id .. ")") or ""), node.stats, tooltipType)
				end

				widget.onClick = onClickNode
			end

			nodeMap[node.id] = node
			widget = nil
			totalNodes = totalNodes + 1
		end
	end

	local function BuildConnector(node1, node2)
		if node1.groupX == node2.groupX and node1.orbit == node2.orbit then
			if node2.angle < node1.angle then
			  node1, node2 = node2, node1
			end
		
			local angle1 = node1.angle
			local angle2 = node2.angle
			local arcAngle = angle2 - angle1
		
			if arcAngle < 0 then
			  arcAngle = arcAngle + 2 * m_pi
			end
		
			local flip = false
			if arcAngle > m_pi then
			  arcAngle = 2 * m_pi - arcAngle
			  flip = true
			end
		
			if arcAngle < m_pi * 0.9 then
			  local lineType = "Normal"
			  if node1.alloc and node2.alloc then
				lineType = "Active"
			  elseif node1.alloc and not node2.alloc then
				lineType = "Intermediate"
			  end
		
			  local distX = (node2.x - node1.x) / SCALE
			  local distY = (node2.y - node1.y) / SCALE
			  local dist  = m_sqrt(distX * distX + distY * distY)
		
			  local orbitType = getOrbitType(node1.orbit, dist, node1.id)
			  local widget = g_ui.createWidget("Orbit" .. orbitType .. lineType, decoView)
			  widget:setId(node1.id .. "-" .. node2.id)
		
			  local avgAngle = angle1 + (arcAngle / 2)
			  local rotation = (avgAngle * 180 / m_pi) + (flip and -45 or 45)
			  widget:setRotation(rotation)
		
			  local midX = (node1.x + node2.x) / 2
			  local midY = (node1.y + node2.y) / 2
			  widget:setMarginLeft(midX * SCALE)
			  widget:setMarginTop(midY * SCALE)

				widget = nil

				return 
			end
		end

		local vX = (node2.x - node1.x) / SCALE
  		local vY = (node2.y - node1.y) / SCALE
  		local dist = m_sqrt(vX * vX + vY * vY)
  		local endS = dist / 256
  		local angle = (m_atan2(vY, vX) * 180 / m_pi)

  		local x = (node1.x + node2.x) / 2
  		local y = (node1.y + node2.y) / 2
  		local lineType = "Normal"
  		if node1.alloc and node2.alloc then
    		lineType = "Active"
  		elseif node1.alloc and not node2.alloc then
    		lineType = "Intermediate"
  		end

  		local widget = g_ui.createWidget("LineConnector" .. lineType, decoView)
  		widget:setId(node1.id .. "-" .. node2.id)
  		widget:setMarginLeft(x * SCALE)
  		widget:setMarginTop(y * SCALE)
  		widget:setRotation(angle)
  		widget:setWidth(endS * 256 * SCALE)

		widget = nil

		return 
	end

	for k, node in pairs(treeData.nodes) do
		slot9 = pairs
		slot10 = node.out or {}

		for _, otherId in slot9(slot10) do
			local other = nodeMap[otherId]

			t_insert(node.linkedId, otherId)
			t_insert(other.linkedId, node.id)

			if not node.isStartNode and not other.isStartNode then
				BuildConnector(node, other)
			end
		end
	end

	return 
end

function showConfirmationDialog(data)
    if confirmationDialog then
        confirmationDialog:destroy()
        confirmationDialog = nil
    end

    local function confirmFunc()
        if confirmationDialog then
            confirmationDialog:destroy()
            confirmationDialog = nil
        end

        sendAction("confirmAllocate", { nodeId = data.nodeId })
    end

    local function cancelFunc()
        if confirmationDialog then
            confirmationDialog:destroy()
            confirmationDialog = nil
        end
    end

    local text = "This node allocation is permanent until you reset your entire tree.\n\nDo you wish to allocate this node?\n\nCost: 1 point."

    confirmationDialog = displayGeneralBox(
        "Confirm Node Allocation",
        text,
        {
            { text = tr("Confirm"), callback = confirmFunc },
            { text = tr("Cancel"), callback = cancelFunc },
            anchor = AnchorHorizontalCenter
        },
        cancelFunc
    )
end

function onExtendedOpcode(protocol, code, buffer)
	if not g_game.isOnline() then
		return 
	end

	local json_status, json_data = pcall(function ()
		return json.decode(buffer)
	end)

	if not json_status then
		g_logger.error("[Passive tree Bar] JSON error: " .. data)

		return false
	end

	local action = json_data.action
	local data = json_data.data

	if action == "sendPoints" then
		setPoints(data)
	elseif action == "sendNodes" or action == "syncTree" then
		updateNodes(data)
	elseif action == "sendMessage" then
		sendMessageBox(data.title, data.message)
	elseif action == "requestConfirmation" then
		showConfirmationDialog(data)
	end

	return 
end

function updateNodes(data)
  if not window then return end

  importPreviewBackup = nil
  pendingImportBuild = nil
  if importPreviewDialog then
    importPreviewDialog:destroy()
    importPreviewDialog = nil
  end

  currentPreset   = data.preset
  currentSelected = currentPreset

  for i = 1, 3 do
    local presetItem = window.presets.slots["preset" .. i]
    local preset = data.presetsTable and (data.presetsTable[i] or data.presetsTable[tostring(i)])
    if presetItem and preset then
      presetItem:setText(preset.name or ("Preset " .. i))
      presetItem:setColor(i == currentPreset and "#d47b06" or "#ffffff")
      presetItem.unlocked = true
    elseif presetItem then
      presetItem:setText("Locked")
      presetItem:setColor("#888888")
      presetItem.unlocked = false
    end

    if i == currentPreset then
      window.presets.presetsSave.presetName:setText(preset and preset.name or ("Preset " .. i))
    end
  end

  window.presets.presetSlots:setColoredText({
    "Slots: ", "#ffffff",
    "3/3", "#d47b06"
  })

  for _, child in pairs(nodesView:getChildren()) do
    child.blocked = false
    child:setOn(false)
  end

  allocNodes = {}
  for _, node in pairs(nodeMap) do
    node.alloc = false
  end

  for _, nodeId in ipairs(data.nodes or {}) do
    local node = nodeMap[nodeId]
    if node then
      node.alloc = true
      allocNodes[nodeId] = node

      local widget = nodesView:recursiveGetChildById(nodeId)
      if widget then
        widget:setOn(true)
      end
    end
  end

  updateAllConnectors()
  calculateStats()
end

ISUPDATINGLOCAL = false

function updateLocal()
  updateAllConnectors()
end

function onClickNode(widget)
    local nodeId = tonumber(widget:getId())
    if not nodeId or widget.blocked then return false end

    local node = nodeMap[nodeId]
    if not node then return false end

    if node.alloc then
        sendMessageBox(
            "Cannot Deallocate",
            "This node is already allocated.\n\nNodes cannot be individually deallocated. Use the Reset button to reset your entire tree."
        )
        return false
    end

    sendAction("toggleNode", { nodeId = nodeId })
    return true
end

local CLIENT_START_NODES = {
  [1] = true,
  [2] = true,
  [3] = true,
  [4] = true,
  [5] = true,
  [6] = true,
  [7] = true,
}

local function collectAllocatedNodeIds()
  local nodes = {}
  for nodeId in pairs(allocNodes) do
    table.insert(nodes, tonumber(nodeId))
  end
  table.sort(nodes)
  return nodes
end

local function applyNodePreview(nodeIds)
  if not window or not nodesView then
    return
  end

  for _, child in pairs(nodesView:getChildren()) do
    child.blocked = false
    child:setOn(false)
  end

  allocNodes = {}
  for _, node in pairs(nodeMap) do
    node.alloc = false
  end

  local previewNodes = {}
  for _, rawNodeId in ipairs(nodeIds or {}) do
    local nodeId = tonumber(rawNodeId)
    if nodeId and nodeMap[nodeId] then
      previewNodes[nodeId] = true
    end
  end

  for nodeId in pairs(CLIENT_START_NODES) do
    if nodeMap[nodeId] then
      previewNodes[nodeId] = true
    end
  end

  for nodeId in pairs(previewNodes) do
    local node = nodeMap[nodeId]
    if node then
      node.alloc = true
      allocNodes[nodeId] = node

      local widget = nodesView:recursiveGetChildById(nodeId)
      if widget then
        widget:setOn(true)
      end
    end
  end

  updateAllConnectors()
  calculateStats()
end

local function restoreImportPreview()
  if importPreviewBackup then
    applyNodePreview(importPreviewBackup)
  end

  importPreviewBackup = nil
  pendingImportBuild = nil

  if importPreviewDialog then
    importPreviewDialog:destroy()
    importPreviewDialog = nil
  end
end

local function decodeImportPreview(build)
  if type(build) ~= "string" or build:gsub("^%s+", ""):gsub("%s+$", "") == "" then
    return nil, "Paste a passive tree export first."
  end

  local ok, decoded = pcall(function()
    return json.decode(build)
  end)

  if not ok or type(decoded) ~= "table" then
    return nil, "Invalid passive tree export format."
  end

  local rawNodes = decoded.nodes or decoded.nodeIds or decoded
  if type(rawNodes) ~= "table" then
    return nil, "This export does not contain any nodes."
  end

  local nodes = {}
  local seen = {}
  local requiredPoints = 0

  for _, rawNodeId in ipairs(rawNodes) do
    local nodeId = tonumber(rawNodeId)
    if not nodeId or not nodeMap[nodeId] then
      return nil, "This export contains an unknown node."
    end

    if not seen[nodeId] then
      seen[nodeId] = true
      table.insert(nodes, nodeId)

      if not CLIENT_START_NODES[nodeId] then
        requiredPoints = requiredPoints + 1
      end
    end
  end

  if #nodes == 0 then
    return nil, "This export does not contain any nodes."
  end

  table.sort(nodes)

  return {
    name = decoded.name or "Imported Build",
    nodes = nodes,
    requiredPoints = requiredPoints
  }
end

local function showImportPreview(build, preview)
  if importPreviewDialog then
    restoreImportPreview()
  end

  importPreviewBackup = collectAllocatedNodeIds()
  pendingImportBuild = build
  applyNodePreview(preview.nodes)

  local text = string.format(
    "Previewing preset: %s\n\nNodes: %d\nPassive points needed: %d\n\nWould you like to import this preset into the first empty preset slot?",
    preview.name,
    #preview.nodes,
    preview.requiredPoints
  )

  local function importFunc()
    local confirmedBuild = pendingImportBuild
    restoreImportPreview()
    sendAction("importBuild", { build = confirmedBuild })
  end

  local function cancelFunc()
    restoreImportPreview()
  end

  importPreviewDialog = displayGeneralBox(
    "Import Passive Preset",
    text,
    {
      { text = tr("Import"), callback = importFunc },
      { text = tr("Cancel"), callback = cancelFunc },
      anchor = AnchorHorizontalCenter
    },
    cancelFunc
  )
end

function hasPathToStart(node, visited)
  if visited[node.id] then return false end
  visited[node.id] = true

  if CLIENT_START_NODES[node.id] then
    return true
  end

  for _, otherId in pairs(node.out or {}) do
    local other = nodeMap[otherId]
    if other and other.alloc and hasPathToStart(other, visited) then
      return true
    end
  end

  for _, otherId in pairs(node.inputs or {}) do
    local other = nodeMap[otherId]
    if other and other.alloc and hasPathToStart(other, visited) then
      return true
    end
  end

  return false
end

function getOrbitType(orbit, dist, nodeId)
	local orbitType = orbit
	dist = math.floor(dist)

	if orbitType == 4 and dist < SCALE/120 then
		orbitType = 3
	elseif orbitType == 1 and SCALE/80 < dist then
		orbitType = 6
	elseif orbitType ~= 4 and SCALE/80 < dist then
		orbitType = 5
	end

	return orbitType
end

function onDragEnter(widget, mousePos)
	local childCount = widget.getChildCount(widget)

	for i = 1, childCount, 1 do
		local child = widget.getChildByIndex(widget, i)
		child.hotSpot = {
			x = mousePos.x - child.getMarginLeft(child),
			y = mousePos.y - child.getMarginTop(child)
		}
	end

	return true
end

function onDragLeave(widget)
	return true
end

function onDragMove(widget, mousePos, mouseMoved)
	local childCount = widget.getChildCount(widget)

	for i = 1, childCount, 1 do
		local child = widget.getChildByIndex(widget, i)
		local offsetX = mousePos.x - child.hotSpot.x
		local offsetY = mousePos.y - child.hotSpot.y

		if offsetX < -LIMIT_X/4 then
			offsetX = -LIMIT_X/4
		end

		if offsetY < -LIMIT_Y/4 then
			offsetY = -LIMIT_Y/4
		end

		if LIMIT_X/4 < offsetX then
			offsetX = LIMIT_X/4
		end

		if LIMIT_Y/4 < offsetY then
			offsetY = LIMIT_Y/4
		end

		child.setMarginLeft(child, offsetX)
		child.setMarginTop(child, offsetY)
	end

	return 
end

function toggleStats()
	local stats = window:recursiveGetChildById("stats")

	if stats.getHeight(stats) == 30 then
		stats.setHeight(stats, 400)
	else
		stats.setHeight(stats, 30)
	end

	return 
end

function onSelectSpell()
	calculateStats()

	return 
end

function onSpellLevelChange(widget, value)
	calculateStats()

	return 
end

function getSkillTreeBonuses()
	local nodes = {}

	for k, v in pairs(allocNodes) do
		table.insert(nodes, k)
	end

	local bonusTable = {}

	for k, id in pairs(nodes) do
		local node = nodeMap[id]

		if node then
			local vocationNode = node[getPlayerVocation()]
			local customStats = (vocationNode and vocationNode.customStats) or node.customStats

			if customStats then
				for name, value in pairs(customStats) do
					if not bonusTable[name] then
						bonusTable[name] = value
					else
						bonusTable[name] = bonusTable[name] + value
					end
				end
			end
		end
	end

	return bonusTable
end

local vocationSpecials = {

	knight = {
		{
			{
				"Knights & Elite Knights: ",
				"#FFA500",
				"\nKnights & Elite Knights embody timeless \nvalor and chivalry on the battlefield.",
				"#f8f8f8"
			},
			height = 55
		}
	},
	paladin = {
        {
            {
                "Paladins & Royal Paladins: ",
                "#FFFF00",
                "\nPaladins & Royal Paladins embody noble honor \nand unwavering courage on the battlefield.",
                "#f8f8f8"
            },
            height = 55
        }
    },
	sorcerer = {
        {
            {
                "Sorcerers & Master Sorcerers: ",
                "#00FFFF",
                "\nSorcerers & Master Sorcerers command elemental forces with unparalleled mystical\nprowess.",
                "#f8f8f8"
            },
            height = 55
        }
    },
    druid = {
        {
            {
                "Druids & Elder Druids: ",
                "#32CD32",
                "\nDruids & Elder Druids embody nature's \nresilience and healing power in every battle.",
                "#f8f8f8"
            },
            height = 55
        }
    },
    illusionist = {
        {
            {
                "Illusionist & Arch Illusionist: ",
                "#800080",
                "\nIllusionists & Arch Illusionists weave \narcane illusions to confound their foes.",
                "#f8f8f8"
            },
            height = 55
        }
    },
	monk = {
		{
			{
				"Monk & Exalted Monk: ",
				"FFECA41F",
				"\nMasters of unarmed combat, Monks channel inner strength through disciplined strikes.\nTheir fists become weapons of pure focus and spiritual energy.",
				"#f8f8f8"
			},
			height = 55
		}
    }
}

function calculateStats()
	local bonuses = getSkillTreeBonuses()
	local bonusText = getCustomStatString(bonuses)
	local stats = window:recursiveGetChildById("stats")
	local labels = stats.recursiveGetChildById(stats, "labels")

	labels.destroyChildren(labels)
	local vocation = getPlayerVocation()
	if not vocation then
	return
	end

	if vocationSpecials[vocation] then
		for _, sp in pairs(vocationSpecials[getPlayerVocation()]) do
			local label = g_ui.createWidget("InfoLabel", labels)

			label.setColoredText(label, sp[1])
			label.setHeight(label, sp.height)
		end
	end

	label = g_ui.createWidget("InfoLabel", labels)

	label:setText("---------------- CURRENT BONUSES ----------------")

	for k, v in pairs(bonusText) do
		label = g_ui.createWidget("InfoLabel", labels)

		label:setText(v)
	end

	return 
end

function destroy()
	if window then
		view = nil
		decoView = nil
		nodesView = nil
		background = nil
		treeData = {}

		window:destroy()

		window = nil
		pointsOwned = 0

		g_extendedtooltip.hide()
	end

	return 
end

function show()
	SCALE = SCALE_MAX
	createNodes()

	if not window then
		return 
	end

	sendAction("requestPoints")
	sendAction("requestNodesUnlocked")
	window:show()
	window:raise()
	window:focus()
	updateZoom()
	for _, child in pairs(view:getChildren()) do
		child.setMarginLeft(child, STARTOFFSET.x)
		child.setMarginTop(child, STARTOFFSET.y)
	end

	return 
end

function hide()
	if not window then
		return 
	end

	window.presets:hide()
	window:hide()

	if messageBox then
		messageBox:destroy()

		messageBox = nil
	end

	return 
end

function sendAction(action, data)
	if not g_game.getFeature(GameExtendedOpcode) then
		return 
	end

	local protocolGame = g_game.getProtocolGame()

	if data == nil then
		data = {}
	end

	if protocolGame then
		protocolGame.sendExtendedJSONOpcode(protocolGame, CODE_SKILLTREE, {
			action = action,
			data = data
		})
	end

	return 
end

function presets()
	if window.presets:isVisible() then
		window.presets:hide()
	else
		window.presets:show()
	end

	return 
end

function refund()
	sendAction("refund")
	return 
end

function exportBuild()
    if not window then
        return
    end

    local nodes = {}
    for nodeId in pairs(allocNodes) do
        table.insert(nodes, tonumber(nodeId))
    end
    table.sort(nodes)

    local build = json.encode({
        type = "exodus-passive-tree",
        v = 1,
        name = window.presets.presetsSave.presetName:getText(),
        nodes = nodes
    })

    g_window.setClipboardText(build)
    sendMessageBox("Build Exported", "Passive tree build copied to your clipboard.\n\nSend it to another player so they can import it.")
end

function importBuild()
    if not window then
        return
    end

    modules.client_textedit.show("", {
        title = "Import Passive Tree",
        description = "Paste a passive tree export here. It will be imported into the first empty preset slot available.",
        multiline = true,
        width = 520
    }, function(text)
        local preview, errorMessage = decodeImportPreview(text)
        if not preview then
            sendMessageBox("Import Failed", errorMessage)
            return
        end

        showImportPreview(text, preview)
    end)
end

function renamePreset()
    if not window then
        return
    end

    sendAction("renamePreset", {
        preset = currentSelected > 0 and currentSelected or currentPreset,
        name = window.presets.presetsSave.presetName:getText()
    })
end

function setPoints(value)
	pointsOwned = value
	window.pWindow.points:setText(pointsOwned .. " points")
end


SCALE_CHANGE = 0.70
SCALE_MAX = 0.7
SCALE_MIN = 0.4
SCALE = SCALE_MAX

-- function zoomLess()
-- 	if SCALE <= SCALE_MIN then
-- 		window.zoomLess:setEnabled(false)
-- 		return 
-- 	end

-- 	window.zoomLess:setEnabled(true)
-- 	SCALE = SCALE * SCALE_CHANGE

-- 	updateZoom()
-- end

-- function zoomPlus()
-- 	if SCALE_MAX <= SCALE then
-- 		window.zoomPlus:setEnabled(false)
-- 		return 
-- 	end

-- 	window.zoomPlus:setEnabled(true)
-- 	SCALE = SCALE / SCALE_CHANGE

-- 	updateZoom()
-- end

function updateZoom()
  for _, child in pairs(nodesView:getChildren()) do
    child:setHeight(child:getHeight() * SCALE)
    child:setWidth(child:getWidth() * SCALE)
    child:setImageHeight(child:getImageHeight() * SCALE)
    child:setImageWidth(child:getImageWidth() * SCALE)
    child:setIconWidth(child:getIconWidth() * SCALE)
    child:setIconHeight(child:getIconHeight() * SCALE)
  end

  for _, child in pairs(decoView:getChildren()) do
    child:setHeight(child:getHeight() * SCALE)
    child:setWidth(child:getWidth() * SCALE)
    child:setImageHeight(child:getImageHeight() * SCALE)
    child:setImageWidth(child:getImageWidth() * SCALE)
  end

  updateAllConnectors()
end


function reset()
    if messageBox then
        messageBox:destroy()
        messageBox = nil
    end

    if confirmationDialog then
        confirmationDialog:destroy()
        confirmationDialog = nil
    end

    local player = g_game.getLocalPlayer()
    local level  = player and player:getLevel() or 1
    local cost   = level * 250

    local text = string.format(
        "You are about to reset your passive tree for %d gold coins (Level: %d x 250 gold per level).\n\nThis will refund all your allocated passive points. Proceed?",
        cost, level
    )

    local function okFunc()
        sendAction("refund")
        sendAction("requestPoints")
        messageBox:destroy()
        messageBox = nil
    end

    local function cancelFunc()
        messageBox:destroy()
        messageBox = nil
    end

    messageBox = displayGeneralBox(
        "Reset Warning",
        text,
        {
            { text = tr("Ok"),     callback = okFunc },
            { text = tr("Cancel"), callback = cancelFunc },
            anchor = AnchorHorizontalCenter
        },
        okFunc
    )
end

function sendMessageBox(title, message)
	if messageBox then
		messageBox:destroy()

		messageBox = nil
	end

	local function okFunc()
		messageBox:destroy()

		messageBox = nil

		return 
	end

	messageBox = displayGeneralBox(title, message, {
		{
			text = tr("Ok"),
			callback = okFunc
		},
		anchor = AnchorHorizontalCenter
	}, okFunc)

	return 
end

function getCustomStatString(t)
	local texts = {}

	if t.strength then
		table.insert(texts, string.format("+%.1f strength.", t.strength/1))
	end

	if t.dexterity then
		table.insert(texts, string.format("+%.1f dexterity.", t.dexterity/1))
	end

	if t.spirit then
		table.insert(texts, string.format("+%.1f spirit.", t.spirit/1))
	end

	if t.wisdom then
		table.insert(texts, string.format("+%.1f wisdom.", t.wisdom/1))
	end

	if t.vitality then
		table.insert(texts, string.format("+%.1f vitality.", t.vitality/1))
	end

	if t.intelligence then
		table.insert(texts, string.format("+%.1f intelligence.", t.intelligence/1))
	end

	if t.incrementWater then
		table.insert(texts, string.format("+%.1f Water Damage.", t.incrementWater/1))
	end

	if t.incrementHoly then
		table.insert(texts, string.format("+%.1f Holy Damage.", t.incrementHoly/1))
	end

	if t.incrementPhysical then
		table.insert(texts, string.format("+%.1f Physical Damage.", t.incrementPhysical/1))
	end

	if t.incrementEarth then
		table.insert(texts, string.format("+%.1f Earth Damage.", t.incrementEarth/1))
	end

	if t.incrementFire then
		table.insert(texts, string.format("+%.1f Fire Damage.", t.incrementFire/1))
	end

	if t.incrementDeath then
		table.insert(texts, string.format("+%.1f Death Damage.", t.incrementDeath/1))
	end

	if t.incrementHealth then
		table.insert(texts, string.format("+%.1f Health Spells.", t.incrementHealth/1))
	end

	if t.incrementIce then
		table.insert(texts, string.format("+%.1f Ice Damage.", t.incrementIce/1))
	end

	if t.incrementEnergy then
		table.insert(texts, string.format("+%.1f Energy Damage.", t.incrementEnergy/1))
	end

	if t.incrementArcane then
		table.insert(texts, string.format("+%.1f Arcane Damage.", t.incrementArcane/1))
	end

	if t.incrementLifeDrain then
		table.insert(texts, string.format("+%.1f Life Drain Damage.", t.incrementLifeDrain/1))
	end

	if t.incrementManaDrain then
		table.insert(texts, string.format("+%.1f Mana Drain Damage.", t.incrementManaDrain/1))
	end

	if t.incrementDrown then
		table.insert(texts, string.format("+%.1f Drown Damage.", t.incrementDrown/1))
	end

	if t.absorbFire then
		table.insert(texts, string.format("+%.1f Fire Absorption.", t.absorbFire/1))
	end

	if t.absorbDeath then
		table.insert(texts, string.format("+%.1f Death Absorption.", t.absorbDeath/1))
	end

	if t.absorbEnergy then
		table.insert(texts, string.format("+%.1f Energy Absorption.", t.absorbEnergy/1))
	end

	if t.absorbIce then
		table.insert(texts, string.format("+%.1f Ice Absorption.", t.absorbIce/1))
	end

	if t.absorbArcane then
		table.insert(texts, string.format("+%.1f Arcane Absorption.", t.absorbArcane/1))
	end

	if t.absorbWater then
		table.insert(texts, string.format("+%.1f Water Absorption.", t.absorbWater/1))
	end

	if t.absorbPhysical then
		table.insert(texts, string.format("+%.1f Physical Absorption.", t.absorbPhysical/1))
	end

	if t.absorbDrown then
		table.insert(texts, string.format("+%.1f Drown Absorption.", t.absorbDrown/1))
	end

	if t.absorbLife then
		table.insert(texts, string.format("+%.1f Life Drain Absorption.", t.absorbLife/1))
	end

	if t.absorbMana then
		table.insert(texts, string.format("+%.1f Mana Drain Absorption.", t.absorbMana/1))
	end

	if t.absorbHoly then
		table.insert(texts, string.format("+%.1f Holy Absorption.", t.absorbHoly/1))
	end

	if t.absorbEarth then
		table.insert(texts, string.format("+%.1f Earth Absorption.", t.absorbEarth/1))
	end

	if t.experience then
		table.insert(texts, string.format("+%.1f Experience Gained.", t.experience/100))
	end

	if t.loot then
		table.insert(texts, string.format("+%.1f Loot Increased.", t.loot/100))
	end

	if t.rarityLoot then
		table.insert(texts, string.format("+%.1f Rarity Loot Increased.", t.rarityLoot/2))
	end

	if t.speed then
		table.insert(texts, string.format("+%.1f Increased Speed.", t.speed/2))
	end

	if t.swordSkill then
		table.insert(texts, string.format("+%.1f Sword Skill.", t.swordSkill/1))
	end

	if t.axeSkill then
		table.insert(texts, string.format("+%.1f Axe Skill.", t.axeSkill/1))
	end

	if t.fistSkill then
		table.insert(texts, string.format("+%.1f Fist Skill.", t.fistSkill/1))
	end

	if t.clubSkill then
		table.insert(texts, string.format("+%.1f Club Skill.", t.clubSkill/1))
	end

	if t.distanceSkill then
		table.insert(texts, string.format("+%.1f Distance Skill.", t.distanceSkill/1))
	end

	if t.magicSkill then
		table.insert(texts, string.format("+%.1f Magic Level.", t.magicSkill/1))
	end

	if t.shieldingSkill then
		table.insert(texts, string.format("+%.1f Shielding Skill.", t.shieldingSkill/1))
	end

	if t.craftingSkill then
		table.insert(texts, string.format("+%.1f Crafting Skill.", t.craftingSkill/1))
	end

	if t.herbalistSkill then
		table.insert(texts, string.format("+%.1f Herbalist Skill.", t.herbalistSkill/1))
	end

	if t.woodcuttingSkill then
		table.insert(texts, string.format("+%.1f Woodcutting Skill.", t.woodcuttingSkill/1))
	end

	if t.miningSkill then
		table.insert(texts, string.format("+%.1f Mining Skill.", t.miningSkill/1))
	end

	if t.armorsmithSkill then
		table.insert(texts, string.format("+%.1f Armorsmith Skill.", t.armorsmithSkill/1))
	end

	if t.jewelsmithSkill then
		table.insert(texts, string.format("+%.1f Jewelsmith Skill.", t.jewelsmithSkill/1))
	end

	if t.weaponsmithSkill then
		table.insert(texts, string.format("+%.1f Weaponsmith Skill.", t.weaponsmithSkill/1))
	end

	if t.criticalHitChance then
		table.insert(texts, string.format("+%.1f Critical Hit Chance.", t.criticalHitChance/1))
	end

	if t.criticalHitAmount then
		table.insert(texts, string.format("+%.1f Critical Hit Amount.", t.criticalHitAmount/1))
	end

	if t.lifeLeechChance then
		table.insert(texts, string.format("+%.1f Life Leech Chance.", t.lifeLeechChance/1))
	end

	if t.lifeLeechAmount then
		table.insert(texts, string.format("+%.1f Life Leech Amount.", t.lifeLeechAmount/1))
	end

	if t.manaLeechChance then
		table.insert(texts, string.format("+%.1f Mana Leech Chance.", t.manaLeechChance/1))
	end

	if t.manaLeechAmount then
		table.insert(texts, string.format("+%.1f Mana Leech Amount.", t.manaLeechAmount/1))
	end

	if t.multiIncrement then
		table.insert(texts, string.format("+%.1f Increase all damage elements.", t.multiIncrement/1))
	end

	if t.absorbAllElements then
		table.insert(texts, string.format("+%.1f Absorb all Elements.", t.absorbAllElements/1))
	end


	return texts
end

return
