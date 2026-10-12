

------ Events

local creatureEvent = CreatureEvent("MapTravel_onExtendedOpcode")
function creatureEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= MapTravel_OPCODE then
		return
	end

	local data = json.decode(buffer)
	if not data or not data.topic then
		return
	end

	if data.topic == "request-MapTravel-Cache" then
		local discovered = MapTravel.buildDiscoveredDataForPlayer(player)
		local reply = {
			topic = "full-MapTravel-Cache",
			discoveredNodes = discovered
		}
		player:sendExtendedOpcode(MapTravel_OPCODE, json.encode(reply))

	elseif data.topic == "travel" then
		MapTravel.handleTravel(player, data.nodeIndex, data.currentNode)
	end
end
creatureEvent:register()

local onLoginEvent = CreatureEvent("MapTravel_onLogin")
function onLoginEvent.onLogin(player)
	player:registerEvent("MapTravel_onExtendedOpcode")
	return true
end
onLoginEvent:register()




------ Initialization

function MapTravel.getNodeStorageId(nodeIndex)
	return MapTravel.baseStorage + nodeIndex
end

function MapTravel.buildDiscoveredDataForPlayer(player)
	local discoveredNodes = {}
	for index, nodeConfig in ipairs(MapTravel.mapNodesConfig) do
		if not nodeConfig.discoverable or (player:getStorageValue(MapTravel.getNodeStorageId(index)) == 1) then
			table.insert(discoveredNodes, nodeConfig.nameId)
		end
	end
	return discoveredNodes
end


------ Unlocking

function MapTravel.unlockNode(player, nodeIndex)
	local nodeConfig = MapTravel.mapNodesConfig[nodeIndex]
	if not nodeConfig then
		return false
	end

	local nodeStorage = MapTravel.getNodeStorageId(nodeIndex)
	if player:getStorageValue(nodeStorage) ~= 1 then
		player:setStorageValue(nodeStorage, 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have discovered: " .. nodeConfig.displayName)
	end

	local discovered = MapTravel.buildDiscoveredDataForPlayer(player)
	local message = {
		topic = "full-MapTravel-Cache",
		discoveredNodes = discovered
	}
	player:sendExtendedOpcode(MapTravel_OPCODE, json.encode(message))
	return true
end


------ Travel Management

function MapTravel.launchMapTravel(player, nodeNameId)
	local currentPos = player:getPosition()

	for i, nodeConfig in ipairs(MapTravel.mapNodesConfig) do
		if nodeConfig.nameId == nodeNameId then
			nodeIndex = i
			break
		end
	end

	if not nodeIndex then
		return
	end

	local nodeConfig = MapTravel.mapNodesConfig[nodeIndex]
	if not nodeConfig then
		return
	end

	local nodeWasLocked = nodeConfig.discoverable and (player:getStorageValue(MapTravel.getNodeStorageId(nodeIndex)) ~= 1)
	if nodeWasLocked then
		MapTravel.unlockNode(player, nodeIndex)
	end

	local message = {
		topic = "launch-MapTravel",
		currentNode = nodeConfig.nameId
	}
	player:sendExtendedOpcode(MapTravel_OPCODE, json.encode(message))
	-- player:registerEvent('closeMapTravelOnMove')
end

function MapTravel.handleTravel(player, destNodeIndex, currentNodeNameId)
	local destNodeConfig = MapTravel.mapNodesConfig[destNodeIndex]
	if not destNodeConfig then
		return
	end

	if not currentNodeNameId then
		return
	end

	local originNodeIndex = nil
	for i, nodeCfg in ipairs(MapTravel.mapNodesConfig) do
		if nodeCfg.nameId == currentNodeNameId then
			originNodeIndex = i
			break
		end
	end

	if not originNodeIndex then
		return
	end

	local originConfig = MapTravel.mapNodesConfig[originNodeIndex]
	if not originConfig then
		return
	end

	local playerPos = player:getPosition()
	local originPos = Position(originConfig.serverPos[1], originConfig.serverPos[2], originConfig.serverPos[3])
	local dist = playerPos:getDistance(originPos)

	local usageRange = MapTravel.usageRange or 7
	if dist > usageRange then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You must be within range (" .. usageRange .. ") of " ..
							   originConfig.displayName .. " node to travel!")
		player:popupFYI("You are not close enough to the node to travel!")
		return
	end

	local nodeStorage = MapTravel.getNodeStorageId(destNodeIndex)
	if destNodeConfig.discoverable and (player:getStorageValue(nodeStorage) ~= 1) then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You have not discovered this area yet!")
		player:popupFYI("You have not discovered this area yet!")
		return
	end

	if destNodeConfig.premium and not player:isPremium() then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "You need a Premium Account to travel here!")
		player:popupFYI("You need a Premium Account to travel here!")
		return
	end

    if destNodeConfig.pzLock and player:isPzLocked() then
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "You can not travel to destination when PZ locked!")
        player:popupFYI("You can not travel to destination when PZ locked!")
        return
    end

	if destNodeConfig.storagesReqs then
		if not MapTravel.checkStorageReqs(player, destNodeConfig.storagesReqs) then
			return
		end
	end

	if destNodeConfig.cost then
		local canTravel, errorMsg = MapTravel.checkTravelCost(player, destNodeConfig.cost)
		if not canTravel then
			player:sendTextMessage(MESSAGE_STATUS_WARNING, errorMsg)
			player:popupFYI(errorMsg)
			return
		end
	end

	if destNodeConfig.cost then
		MapTravel.removeTravelCost(player, destNodeConfig.cost)
	end

	local x, y, z = destNodeConfig.serverPos[1], destNodeConfig.serverPos[2], destNodeConfig.serverPos[3]

	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:say("Setting sails to " .. destNodeConfig.displayName .. "!", TALKTYPE_MONSTER_SAY)
	player:teleportTo(Position(x, y, z))
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
		"You have traveled to " .. destNodeConfig.displayName .. ".")

	local message = { topic = "close-MapTravel" }
	player:sendExtendedOpcode(MapTravel_OPCODE, json.encode(message))
end

function MapTravel.checkStorageReqs(player, reqList)
	for _, req in ipairs(reqList) do
		local value = player:getStorageValue(req.id)
		if value < req.value then
			local errMsg = string.format("You do not meet the requirement: %s.", req.name)
			player:sendTextMessage(MESSAGE_STATUS_WARNING, errMsg)
			player:popupFYI(errMsg)
			return false
		end
	end
	return true
end

function MapTravel.checkTravelCost(player, cost)
	local missing = {}

	if cost.gold and cost.gold > 0 then
		if player:getTotalMoney() < cost.gold then
			table.insert(
				missing,
				"You need " .. cost.gold .. " gold, but you only have " .. player:getTotalMoney() .. "."
			)
		end
	end

	if cost.items then
		for _, itemInfo in ipairs(cost.items) do
			local haveCount = player:getItemCount(itemInfo.id)
			local itemName = ItemType(itemInfo.id):getName()
			if haveCount < itemInfo.amount then
				table.insert(
					missing,
					"You need " .. itemInfo.amount .. "x " .. itemName .. " (You have " .. haveCount .. ")."
				)
			end
		end
	end

	if cost.storage then
		for _, sInfo in ipairs(cost.storage) do
			local storedValue = player:getStorageValue(sInfo.value)
			if storedValue < sInfo.amount then
				table.insert(
					missing,
					"You need " .. sInfo.amount .. " " .. sInfo.name .. " (You have " .. storedValue .. ")."
				)
			end
		end
	end

	if #missing > 0 then
		return false, table.concat(missing, "\n")
	end

	return true
end

function MapTravel.removeTravelCost(player, cost)
	if cost.gold and cost.gold > 0 then
		player:removeTotalMoney(cost.gold)
	end

	if cost.items then
		for _, itemInfo in ipairs(cost.items) do
			player:removeItem(itemInfo.id, itemInfo.amount)
		end
	end

	if cost.storage then
		for _, sInfo in ipairs(cost.storage) do
			local currentValue = player:getStorageValue(sInfo.value)
			if currentValue < sInfo.amount then
				player:setStorageValue(sInfo.value, 0)
			else
				player:setStorageValue(sInfo.value, currentValue - sInfo.amount)
			end
		end
	end
end
