local config = {
	monsterName = "Classic Caravan",
	opcode = 220,
	modalId = 902410,
	unlockStorage = 172545,
	visualStorage = 222223,
	enabledStorage = 222227,
	storageLevelStorage = 222229,
	trailLimit = 32,
	storage = 902410,
	activeStorage = 902411,
	checkInterval = 500,
	maxStepsPerTick = 4,
	teleportCatchupDistance = 12,
	spawnEffect = CONST_ME_TELEPORT,
	moveEffect = CONST_ME_NONE,
	removeEffect = CONST_ME_POFF
}

local storageUpgradeConfig = {
	baseCapacity = 5,
	capacityPerLevel = 5,
	maxLevel = 10,
	materials = {
		[2] = {{id = 29500, count = 5}}, -- Robus Scale 
		[3] = {{id = 29538, count = 10}}, -- Venerable Cloth
		[4] = {{id = 29541, count = 2}}, -- Titanium Bar
		[5] = {{id = 29910, count = 3}},  -- Runic Claw
		[6] = {{id = 30617, count = 1}},  -- Essence of Soul
		[7] = {{id = 30619, count = 1}},  -- Kraxxis device
		[8] = {{id = 30623, count = 20}},  -- Soul Leaf
		[9] = {{id = 30616, count = 1}},  -- Electrical Device
		[10] = {{id = 30621, count = 1}},  -- Rathmora head
	}
}

local caravanVisuals = {
	[0] = {
		name = "Classic Caravan",
		unlockStorage = 172545,
		unlockHint = "Unlocked by completing Marek's quest: The Broken Road.",
		outfit = {lookType = 1507, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
	[1] = {
		name = "Royal Caravan",
		unlockStorage = 222230,
		unlockHint = "Unlocked by completing the Royal Caravan mission.",
		outfit = {lookType = 1504, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
	[2] = {
		name = "Merchant Caravan",
		unlockStorage = 222231,
		unlockHint = "Unlocked through a merchant-related mission.",
		outfit = {lookType = 1509, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
	[3] = {
		name = "War Caravan",
		unlockStorage = 222232,
		unlockHint = "Unlocked through Dwelva at North West of Darashia.",
		outfit = {lookType = 1506, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
	[4] = {
		name = "Dragon Caravan",
		unlockStorage = 222233,
		unlockHint = "Unlocked by defeating Vorondor The Eternal Flames for Marek.",
		outfit = {lookType = 1505, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
	[5] = {
		name = "Relic Caravan",
		unlockStorage = 222234,
		unlockHint = "Unlocked by following Garrick's relic trail at north of Edron.",
		outfit = {lookType = 1508, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
	[6] = {
		name = "Angelic Caravan",
		unlockStorage = 222235,
		unlockHint = "Unlocked by talking with Marek, completing Seraphina's holy trial and defeating Azazel the Infernal Seraph.",
		outfit = {lookType = 1510, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
	[7] = {
		name = "Sky Caravan",
		unlockStorage = 222236,
		unlockHint = "Unlocked by mastering all previous caravan designs and defeating Rathmora Ascendant Tyrant.",
		outfit = {lookType = 1511, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
	},
}

local oppositeDirections = {
	[DIRECTION_NORTH] = DIRECTION_SOUTH,
	[DIRECTION_EAST] = DIRECTION_WEST,
	[DIRECTION_SOUTH] = DIRECTION_NORTH,
	[DIRECTION_WEST] = DIRECTION_EAST,
	[DIRECTION_SOUTHWEST] = DIRECTION_NORTHEAST,
	[DIRECTION_SOUTHEAST] = DIRECTION_NORTHWEST,
	[DIRECTION_NORTHWEST] = DIRECTION_SOUTHEAST,
	[DIRECTION_NORTHEAST] = DIRECTION_SOUTHWEST
}

ChariotSystem = ChariotSystem or {}
local followState = {}

local equipmentSlotBits = bit.bor(
	SLOTP_HEAD,
	SLOTP_NECKLACE,
	SLOTP_ARMOR,
	SLOTP_LEGS,
	SLOTP_FEET,
	SLOTP_RING,
	SLOTP_AMMO,
	SLOTP_DECK,
	SLOTP_BADGE,
	SLOTP_SHIP,
	SLOTP_BELT,
	SLOTP_GLOVES
)

local function isMounted(player)
	local outfit = player:getOutfit()
	return outfit and outfit.lookMount and outfit.lookMount > 0
end

local function isFreePosition(position)
	local tile = Tile(position)
	return tile and tile:isWalkable() and tile:getCreatureCount() == 0
end

local function isSamePosition(first, second)
	return first.x == second.x and first.y == second.y and first.z == second.z
end

local function copyPosition(position)
	return Position(position.x, position.y, position.z)
end

local function getChebyshevDistance(first, second)
	if first.z ~= second.z then
		return 99
	end

	return math.max(math.abs(first.x - second.x), math.abs(first.y - second.y))
end

local function syncCaravanSpeed(player, chariot)
	if not player or not chariot then
		return
	end

	local playerSpeed = math.floor(player:getSpeed() * 0.75)
	local chariotSpeed = chariot:getSpeed()

	if chariotSpeed ~= playerSpeed then
		chariot:changeSpeed(playerSpeed - chariotSpeed)
	end
end

local function getStepDirection(fromPosition, toPosition)
	local dx = toPosition.x - fromPosition.x
	local dy = toPosition.y - fromPosition.y

	if dx == 0 and dy < 0 then
		return DIRECTION_NORTH
	elseif dx > 0 and dy == 0 then
		return DIRECTION_EAST
	elseif dx == 0 and dy > 0 then
		return DIRECTION_SOUTH
	elseif dx < 0 and dy == 0 then
		return DIRECTION_WEST
	elseif dx < 0 and dy < 0 then
		return DIRECTION_NORTHWEST
	elseif dx > 0 and dy < 0 then
		return DIRECTION_NORTHEAST
	elseif dx < 0 and dy > 0 then
		return DIRECTION_SOUTHWEST
	elseif dx > 0 and dy > 0 then
		return DIRECTION_SOUTHEAST
	elseif math.abs(dx) >= math.abs(dy) then
		return dx > 0 and DIRECTION_EAST or DIRECTION_WEST
	else
		return dy > 0 and DIRECTION_SOUTH or DIRECTION_NORTH
	end

	return nil
end

local function getPositionBehindPlayer(player)
	local position = Position(player:getPosition())
	local behindDirection = oppositeDirections[player:getDirection()] or DIRECTION_SOUTH
	position:getNextPosition(behindDirection)
	return position
end

local function getFallbackPosition(player, wantedPosition)
	if isFreePosition(wantedPosition) then
		return wantedPosition
	end

	local fallback = player:getClosestFreePosition(wantedPosition, 1, false)
	if fallback and fallback.x ~= 0 and isFreePosition(fallback) then
		return fallback
	end

	return nil
end

local function hasCaravanUnlocked(player)
	return player:getStorageValue(config.unlockStorage) == 1
end

local function isCaravanEnabled(player)
	return hasCaravanUnlocked(player) and player:getStorageValue(config.enabledStorage) == 1
end

local function isOwnedCaravan(player, chariot)
	local ownedChariot = player:getCaravan()
	return chariot and ownedChariot and ownedChariot:getId() == chariot:getId()
end

local function isVisualUnlocked(player, visual)
	return visual and player:getStorageValue(visual.unlockStorage) == 1
end

local function getVisualLabel(player, visualId, visual)
	local status = isVisualUnlocked(player, visual) and "Unlocked" or "Locked"
	return string.format("%s [%s]", visual.name, status)
end

local function getCaravanOutfit(player)
	local visualId = player:getStorageValue(config.visualStorage)
	local visual = caravanVisuals[visualId]
	if not isVisualUnlocked(player, visual) then
		visual = caravanVisuals[0]
	end
	return visual.outfit
end

local function getCaravanStorage(player)
	return player:getCaravanContainer()
end

local function getMaterialName(itemId)
	local itemType = ItemType(itemId)
	local name = itemType and itemType:getName() or ("item " .. itemId)
	return name ~= "" and name or ("item " .. itemId)
end

local function getMaterialsText(materials)
	local parts = {}
	for i = 1, #materials do
		local material = materials[i]
		parts[#parts + 1] = material.count .. "x " .. getMaterialName(material.id)
	end
	return table.concat(parts, ", ")
end

local function getCaravanRoot(container)
	if not container or not container.isContainer or not container:isContainer() then
		return nil
	end

	if container:getCustomAttribute("caravan_root") == true then
		return container
	end

	return nil
end

local function isCaravanContainer(container)
	return getCaravanRoot(container) ~= nil
end

local function isEquipmentItem(item)
	if not item then
		return false
	end

	local itemType = item:getType()
	if not itemType then
		return false
	end

	return itemType:getWeaponType() ~= WEAPON_NONE
		or itemType:getAmmoType() ~= AMMO_NONE
		or itemType:getAttack() ~= 0
		or itemType:getDefense() ~= 0
		or itemType:getExtraDefense() ~= 0
		or itemType:getArmor() ~= 0
		or bit.band(itemType:getSlotPosition(), equipmentSlotBits) ~= 0
end

local function getStorageLevel(player)
	local level = player:getStorageValue(config.storageLevelStorage)
	if level < 1 then
		level = 1
	elseif level > storageUpgradeConfig.maxLevel then
		level = storageUpgradeConfig.maxLevel
	end
	return level
end

local function getStorageCapacity(player)
	return storageUpgradeConfig.baseCapacity + ((getStorageLevel(player) - 1) * storageUpgradeConfig.capacityPerLevel)
end

local function updateStorageCapacity(player)
	local caravanStorage = getCaravanStorage(player)
	if caravanStorage and caravanStorage.setCapacity then
		caravanStorage:setCapacity(getStorageCapacity(player))
	end
end

local function getStorageUpgrade(player)
	local nextLevel = getStorageLevel(player) + 1
	if nextLevel > storageUpgradeConfig.maxLevel then
		return nil
	end

	return {
		level = nextLevel,
		upgrade = nextLevel - 1,
		capacity = storageUpgradeConfig.baseCapacity + ((nextLevel - 1) * storageUpgradeConfig.capacityPerLevel),
		materials = storageUpgradeConfig.materials[nextLevel] or {}
	}
end

local function getSelectedVisualId(player)
	local visualId = player:getStorageValue(config.visualStorage)
	local visual = caravanVisuals[visualId]

	if not visual or not isVisualUnlocked(player, visual) then
		return 0
	end

	return visualId
end

local function getMaterialData(player, materials)
	local result = {}

	for i = 1, #materials do
		local material = materials[i]
		local itemType = ItemType(material.id)

		result[#result + 1] = {
			id = material.id,
			clientId = itemType and itemType:getClientId() or 0,
			name = getMaterialName(material.id),
			count = material.count,
			playerCount = player:getItemCount(material.id)
		}
	end

	return result
end

function ChariotSystem.getModuleData(player)
	local unlocked = hasCaravanUnlocked(player)
	local enabled = isCaravanEnabled(player)
	local selectedVisualId = getSelectedVisualId(player)
	local storageLevel = getStorageLevel(player)
	local storageCapacity = getStorageCapacity(player)
	local maxCapacity = storageUpgradeConfig.baseCapacity + ((storageUpgradeConfig.maxLevel - 1) * storageUpgradeConfig.capacityPerLevel)
	local upgrade = getStorageUpgrade(player)

	local visuals = {}
	local visualId = 0

	while caravanVisuals[visualId] do
		local visual = caravanVisuals[visualId]

		visuals[#visuals + 1] = {
			id = visualId,
			name = visual.name,
			unlockHint = visual.unlockHint or "",
			lookType = visual.outfit.lookType,
			outfit = {
				type = visual.outfit.lookType,
				head = visual.outfit.lookHead or 0,
				body = visual.outfit.lookBody or 0,
				legs = visual.outfit.lookLegs or 0,
				feet = visual.outfit.lookFeet or 0,
				addons = visual.outfit.lookAddons or 0,
				mount = visual.outfit.lookMount or 0
			},
			unlocked = isVisualUnlocked(player, visual),
			selected = selectedVisualId == visualId,
			active = enabled and selectedVisualId == visualId
		}

		visualId = visualId + 1
	end

	local upgradeData = nil
	if upgrade then
		upgradeData = {
			level = upgrade.level,
			upgrade = upgrade.upgrade,
			capacity = upgrade.capacity,
			materials = getMaterialData(player, upgrade.materials)
		}
	end

	local chariot = ChariotSystem.get(player)

	return {
		unlocked = unlocked,
		enabled = enabled,
		mounted = isMounted(player),
		active = chariot ~= nil,
		selectedVisualId = selectedVisualId,
		storage = {
			level = storageLevel,
			maxLevel = storageUpgradeConfig.maxLevel,
			capacity = storageCapacity,
			maxCapacity = maxCapacity
		},
		nextUpgrade = upgradeData,
		visuals = visuals
	}
end

function ChariotSystem.sendModuleData(player, action)
	player:sendExtendedOpcode(config.opcode, json.encode({
		action = action or "state",
		data = ChariotSystem.getModuleData(player)
	}))
end

function ChariotSystem.sendModuleMessage(player, text, color)
	player:sendExtendedOpcode(config.opcode, json.encode({
		action = "message",
		text = text,
		color = color or "#b0b0b0"
	}))
end

function ChariotSystem.openModule(player)
	ChariotSystem.sendModuleData(player, "show")
end

local function hasUpgradeMaterials(player, materials)
	for i = 1, #materials do
		local material = materials[i]
		if player:getItemCount(material.id) < material.count then
			return false
		end
	end
	return true
end

local function removeUpgradeMaterials(player, materials)
	for i = 1, #materials do
		local material = materials[i]
		player:removeItem(material.id, material.count)
	end
end

local function getPlayerState(player)
	local playerId = player:getId()
	local state = followState[playerId]
	if not state then
		state = {
			lastPlayerPosition = copyPosition(player:getPosition()),
			trail = {},
		}
		followState[playerId] = state
	end
	return state
end

local function clearPlayerState(player)
	followState[player:getId()] = nil
end

local function addTrailPosition(state, position)
	local trail = state.trail
	local last = trail[#trail]
	if last and isSamePosition(last, position) then
		return
	end

	trail[#trail + 1] = copyPosition(position)
	while #trail > config.trailLimit do
		table.remove(trail, 1)
	end
end

local function updateTrail(player)
	local state = getPlayerState(player)
	local currentPosition = player:getPosition()
	local lastPosition = state.lastPlayerPosition

	if currentPosition.z ~= lastPosition.z then
		state.trail = {}
	elseif not isSamePosition(currentPosition, lastPosition) then
		addTrailPosition(state, lastPosition)
	end

	state.lastPlayerPosition = copyPosition(currentPosition)
	return state
end

local function getTrailTarget(player, chariot)
	local state = updateTrail(player)
	local trail = state.trail

	while #trail > 0 and isSamePosition(chariot:getPosition(), trail[1]) do
		table.remove(trail, 1)
	end

	if #trail > 0 then
		return trail[1]
	end

	return getPositionBehindPlayer(player)
end

function ChariotSystem.get(player)
	local chariotId = player:getStorageValue(config.storage)
	if chariotId <= 0 then
		return nil
	end

	local chariot = Monster(chariotId)
	if not chariot then
		player:setStorageValue(config.storage, -1)
		player:clearCaravan()
		return nil
	end

	if not isOwnedCaravan(player, chariot) then
		player:setStorageValue(config.storage, -1)
		player:setStorageValue(config.activeStorage, -1)
		player:clearCaravan()
		return nil
	end

	return chariot
end

function ChariotSystem.setVisual(player, visualId)
	local visual = caravanVisuals[visualId]
	if not isVisualUnlocked(player, visual) then
		return false
	end

	player:setStorageValue(config.visualStorage, visualId)

	local chariot = ChariotSystem.get(player)
	if chariot then
		chariot:setOutfit(visual.outfit)
	end
	return true
end

function ChariotSystem.openVisualModal(player)
	if not hasCaravanUnlocked(player) then
		player:sendTextMessage(MESSAGE_INFO_DESCR,"You have not unlocked a caravan.")
		return
	end
	updateStorageCapacity(player)

	player:registerEvent("ChariotVisualModal")

	local modeEnabled = isCaravanEnabled(player)
	local storageLevel = getStorageLevel(player)
	local storageCapacity = getStorageCapacity(player)
	local upgrade = getStorageUpgrade(player)
	local upgradeText = upgrade and ("Upgrade " .. upgrade.upgrade .. ": " .. getMaterialsText(upgrade.materials) .. "\nReward: " .. upgrade.capacity .. " storage slots") or "Storage fully upgraded."
	local modal = ModalWindow(
		config.modalId,
		"Caravan",
		"Choose your caravan option.\nCurrent mode: " .. (modeEnabled and "ON" or "OFF") ..
		"\nStorage: level " .. storageLevel .. " (" .. storageCapacity .. " slots)" ..
		"\n" .. upgradeText
	)
	modal:addChoice(1, "Caravan Mode [" .. (modeEnabled and "Activated" or "Deactivated") .. "]")
	modal:addChoice(2, " ")
	modal:addChoice(3, "Open Storage")
	modal:addChoice(4, upgrade and ("Upgrade " .. upgrade.upgrade .. " [" .. getMaterialsText(upgrade.materials) .. "]") or "Upgrade Storage [Max]")
	modal:addChoice(5, " ")
	modal:addChoice(6, "Caravan Visuals")

	local visualId = 0
	while caravanVisuals[visualId] do
		local visual = caravanVisuals[visualId]
		modal:addChoice(visualId + 7, getVisualLabel(player, visualId, visual))
		visualId = visualId + 1
	end

	modal:addButton(100, "Choose")
	modal:addButton(102, "Upgrade")
	modal:addButton(101, "Cancel")
	modal:setDefaultEnterButton(100)
	modal:setDefaultEscapeButton(101)
	modal:sendToPlayer(player)
end

function ChariotSystem.remove(player)
	local chariot = ChariotSystem.get(player)
	player:clearCaravan()
	player:setStorageValue(config.storage, -1)
	player:setStorageValue(config.activeStorage, -1)

	if chariot then
		chariot:getPosition():sendMagicEffect(config.removeEffect)
		chariot:remove()
	end
	clearPlayerState(player)
end

function ChariotSystem.setEnabled(player, enabled)
	player:setStorageValue(config.enabledStorage, enabled and 1 or 0)
	if enabled then
		ChariotSystem.sync(player)
	else
		ChariotSystem.remove(player)
	end
end

function ChariotSystem.syncDirection(player, chariot, direction)
	if not player then
		return
	end

	chariot = chariot or ChariotSystem.get(player)
	if not chariot or not isOwnedCaravan(player, chariot) then
		return
	end

	chariot:setDirection(direction or player:getDirection())
	chariot:setTarget(nil)
	chariot:setFollowCreature(nil)
end

function ChariotSystem.moveBehind(player, chariot, maxSteps)
	local wantedPosition = getTrailTarget(player, chariot)
	local chariotPosition = chariot:getPosition()
	local targetPosition = wantedPosition
	maxSteps = maxSteps or config.maxStepsPerTick
	if not isSamePosition(chariotPosition, wantedPosition) and not isFreePosition(wantedPosition) then
		targetPosition = getFallbackPosition(player, wantedPosition)
		if not targetPosition then
			return
		end
	end

	if isSamePosition(chariotPosition, targetPosition) then
		ChariotSystem.syncDirection(player, chariot)
		return
	end

	if chariotPosition.z ~= targetPosition.z or getChebyshevDistance(chariotPosition, targetPosition) > config.teleportCatchupDistance then
		chariot:teleportTo(targetPosition, true)
	else
		for _ = 1, maxSteps do
			chariotPosition = chariot:getPosition()
			if isSamePosition(chariotPosition, targetPosition) then
				break
			end

			local direction = getStepDirection(chariotPosition, targetPosition)
			if not direction then
				break
			end

			local beforeMove = chariot:getPosition()
			doMoveCreature(chariot:getId(), direction)

			local afterMove = chariot:getPosition()
			if isSamePosition(beforeMove, afterMove) then
				break
			end
		end
	end

	if config.moveEffect ~= CONST_ME_NONE then
		chariot:getPosition():sendMagicEffect(config.moveEffect)
	end

	ChariotSystem.syncDirection(player, chariot)
end

function ChariotSystem.follow(playerId)
	local player = Player(playerId)
	if not player or not isMounted(player) or not isCaravanEnabled(player) then
		if player then
			ChariotSystem.remove(player)
		end
		return
	end

	local chariot = ChariotSystem.get(player)
	if not chariot then
		ChariotSystem.create(player)
		return
	end

	if not isOwnedCaravan(player, chariot) then
		ChariotSystem.remove(player)
		return
	end

	player:setCaravan(chariot)
	syncCaravanSpeed(player, chariot)
	ChariotSystem.syncDirection(player, chariot)
end

function ChariotSystem.create(player)
	if not isMounted(player) or not isCaravanEnabled(player) then
		ChariotSystem.remove(player)
		return
	end

	local chariot = ChariotSystem.get(player)
	if chariot then
		if isOwnedCaravan(player, chariot) then
			player:setCaravan(chariot)
		else
			ChariotSystem.remove(player)
		end
		return
	end

	local spawnPosition = getFallbackPosition(player, getPositionBehindPlayer(player))
	if not spawnPosition then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Your caravan needs a free nearby tile to appear.")
		return
	end

	chariot = Game.createMonster(config.monsterName, spawnPosition, true, true)
	if not chariot then
		return
	end

	chariot:setDropLoot(false)
	chariot:setSkillLoss(false)
	chariot:setIdle(true)
	chariot:setTarget(nil)
	chariot:setFollowCreature(nil)
	chariot:setDirection(player:getDirection())
	chariot:setOutfit(getCaravanOutfit(player))
	syncCaravanSpeed(player, chariot)
	chariot:getPosition():sendMagicEffect(config.spawnEffect)

	if not player:setCaravan(chariot) then
		chariot:remove()
		return
	end

	player:setStorageValue(config.storage, chariot:getId())
	player:setStorageValue(config.activeStorage, 1)
end

function ChariotSystem.sync(player)
	if isMounted(player) and isCaravanEnabled(player) then
		local chariot = ChariotSystem.get(player)
		if player:getStorageValue(config.activeStorage) ~= 1 or not chariot then
			ChariotSystem.create(player)
		else
			if not isOwnedCaravan(player, chariot) then
				ChariotSystem.remove(player)
				return
			end

			player:setCaravan(chariot)
			syncCaravanSpeed(player, chariot)
			if getChebyshevDistance(player:getPosition(), chariot:getPosition()) > config.teleportCatchupDistance then
				local targetPosition = getFallbackPosition(player, getPositionBehindPlayer(player))
				if targetPosition then
					chariot:teleportTo(targetPosition, true)
				end
			else
				ChariotSystem.syncDirection(player, chariot)
			end
		end
	elseif player:getStorageValue(config.activeStorage) == 1 or ChariotSystem.get(player) then
		ChariotSystem.remove(player)
	end
end

local mountCallback = EventCallback
function mountCallback.onChangeMount(creature, mountId)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if mountId and mountId > 0 then
		addEvent(function(playerId)
			local eventPlayer = Player(playerId)
			if eventPlayer then
				ChariotSystem.create(eventPlayer)
			end
		end, 50, player:getId())
	else
		addEvent(function(playerId)
			local eventPlayer = Player(playerId)
			if eventPlayer then
				ChariotSystem.remove(eventPlayer)
			end
		end, 50, player:getId())
	end

	return true
end
mountCallback:register()

local loginEvent = CreatureEvent("ChariotLogin")
function loginEvent.onLogin(player)
	player:registerEvent("ChariotLogout")
	player:registerEvent("ChariotDeath")
	player:registerEvent("ChariotExtendedOpcode")
	player:registerEvent("ChariotVisualModal")
	player:setStorageValue(config.storage, -1)
	player:setStorageValue(config.activeStorage, -1)
	updateStorageCapacity(player)

	addEvent(function(playerId)
		local eventPlayer = Player(playerId)
		if eventPlayer then
			ChariotSystem.sync(eventPlayer)
		end
	end, 1000, player:getId())

	return true
end
loginEvent:type("login")
loginEvent:register()

local logoutEvent = CreatureEvent("ChariotLogout")
function logoutEvent.onLogout(player)
	ChariotSystem.remove(player)
	return true
end
logoutEvent:type("logout")
logoutEvent:register()

local deathEvent = CreatureEvent("ChariotDeath")
function deathEvent.onDeath(player)
	ChariotSystem.remove(player)
	return true
end
deathEvent:type("death")
deathEvent:register()

function ChariotSystem.openStorage(player, chariotId)
	if not hasCaravanUnlocked(player) then
		return false, "You have not unlocked a caravan."
	end

	local chariot = ChariotSystem.get(player)
	if not chariot or chariot:getId() ~= chariotId then
		return false, "This is not your caravan."
	end

	if getChebyshevDistance(player:getPosition(), chariot:getPosition()) > 2 then
		return false, "You are too far away from your caravan."
	end

	local caravanStorage = getCaravanStorage(player)
	if not caravanStorage then
		return false, "Your caravan storage could not be opened."
	end

	updateStorageCapacity(player)
	if not player:openContainer(caravanStorage, 0) then
		return false, "Your caravan storage could not be opened."
	end

	return true, "Caravan storage opened."
end

function ChariotSystem.openOwnStorage(player)
	local chariot = ChariotSystem.get(player)
	if not chariot then
		return false, "Your caravan is not active."
	end

	return ChariotSystem.openStorage(player, chariot:getId())
end

function ChariotSystem.upgradeStorage(player)
	if not hasCaravanUnlocked(player) then
		return false, "You have not unlocked a caravan."
	end

	local upgrade = getStorageUpgrade(player)
	if not upgrade then
		return false, "Your caravan storage is already fully upgraded."
	end

	if not hasUpgradeMaterials(player, upgrade.materials) then
		return false, "You don't have required materials."
	end

	removeUpgradeMaterials(player, upgrade.materials)
	player:setStorageValue(config.storageLevelStorage, upgrade.level)
	updateStorageCapacity(player)
	return true, "Your caravan storage is now level " .. upgrade.level .. " (" .. upgrade.capacity .. " slots)."
end

function ChariotSystem.canMoveItemToStorage(player, item, fromCylinder, toCylinder)
	if not isCaravanContainer(toCylinder) then
		return RETURNVALUE_NOERROR
	end

	if isCaravanContainer(fromCylinder) then
		return RETURNVALUE_NOERROR
	end

	if item:isContainer() then
		player:sendTextMessage(MESSAGE_INFO_DESCR,"You cannot store containers inside your caravan.")
		return RETURNVALUE_NOTENOUGHROOM
	end

	if isEquipmentItem(item) then
		player:sendTextMessage(MESSAGE_INFO_DESCR,"You cannot store equipment inside your caravan.")
		return RETURNVALUE_NOTENOUGHROOM
	end

	local root = getCaravanRoot(toCylinder)
	local currentSize = root and root:getSize() or 0
	local capacity = getStorageCapacity(player)
	if currentSize >= capacity then
		player:sendTextMessage(MESSAGE_INFO_DESCR,"Your caravan storage is full. Upgrade it with !caravan to unlock more slots.")
		return RETURNVALUE_NOTENOUGHROOM
	end

	return RETURNVALUE_NOERROR
end

local extendedEvent = CreatureEvent("ChariotExtendedOpcode")

function extendedEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= config.opcode then
		return true
	end

	local ok, data = pcall(json.decode, buffer)
	if not ok or not data or not data.action then
		return true
	end

	local action = data.action

	-- Existing behavior: opening storage by clicking own caravan creature
	if action == "open" then
		ChariotSystem.openStorage(player, tonumber(data.id) or 0)
		return true
	end

	-- New module actions
	if action == "requestOpen" then
		ChariotSystem.openModule(player)
		return true
	end

	if action == "toggle" then
		if not hasCaravanUnlocked(player) then
			ChariotSystem.sendModuleData(player)
			return true
		end

		local enabled = not isCaravanEnabled(player)
		ChariotSystem.setEnabled(player, enabled)

		ChariotSystem.sendModuleData(player)
		ChariotSystem.sendModuleMessage(player, "Caravan mode is now " .. (enabled and "enabled" or "disabled") .. ".", enabled and "#00ff00" or "#ff0000")
		return true
	end

	if action == "selectVisual" then
		if not hasCaravanUnlocked(player) then
			ChariotSystem.sendModuleData(player)
			return true
		end

		local visualId = tonumber(data.id)
		local visual = visualId and caravanVisuals[visualId]

		if not visual then
			ChariotSystem.sendModuleData(player)
			return true
		end

		if not ChariotSystem.setVisual(player, visualId) then
			ChariotSystem.sendModuleData(player)
			ChariotSystem.sendModuleMessage(player, "You have not unlocked this caravan visual.", "#ff0000")
			return true
		end

		ChariotSystem.sendModuleData(player)
		ChariotSystem.sendModuleMessage(player, "Your caravan visual is now " .. visual.name .. ".", "#00ff00")
		return true
	end

	if action == "upgrade" then
		if not hasCaravanUnlocked(player) then
			ChariotSystem.sendModuleData(player)
			return true
		end

		local success, message = ChariotSystem.upgradeStorage(player)
		ChariotSystem.sendModuleData(player)
		ChariotSystem.sendModuleMessage(player, message, success and "#00ff00" or "#ff0000")
		return true
	end

	if action == "openStorage" then
		local success, message = ChariotSystem.openOwnStorage(player)
		ChariotSystem.sendModuleData(player)
		ChariotSystem.sendModuleMessage(player, message, success and "#00ff00" or "#ff0000")
		return true
	end

	return true
end

extendedEvent:type("extendedopcode")
extendedEvent:register()

local checkEvent = GlobalEvent("ChariotMountStateCheck")
function checkEvent.onThink(interval, lastExecution)
	local players = Game.getPlayers()
	for i = 1, #players do
		ChariotSystem.sync(players[i])
	end
	return true
end
checkEvent:interval(config.checkInterval)
checkEvent:register()

local visualModal = CreatureEvent("ChariotVisualModal")
function visualModal.onModalWindow(player, modalWindowId, buttonId, choiceId)
	if modalWindowId ~= config.modalId then
		return true
	end

	if buttonId == 102 then
		if choiceId == 4 then
			ChariotSystem.upgradeStorage(player)
		end
		ChariotSystem.openVisualModal(player)
		return true
	end

	if buttonId ~= 100 then
		return true
	end

	if choiceId == 1 then
		local enabled = not isCaravanEnabled(player)
		ChariotSystem.setEnabled(player, enabled)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Caravan mode is now " .. (enabled and "enabled" or "disabled") .. ".")
		ChariotSystem.openVisualModal(player)
		return true
	end

	if choiceId == 2 or choiceId == 3 then
		if choiceId == 3 then
			ChariotSystem.openOwnStorage(player)
		end
		ChariotSystem.openVisualModal(player)
		return true
	end

	if choiceId == 4 then
		ChariotSystem.openVisualModal(player)
		return true
	end

	if choiceId == 5 or choiceId == 6 then
		ChariotSystem.openVisualModal(player)
		return true
	end

	local visualId = choiceId - 7
	local visual = caravanVisuals[visualId]
	if not visual then
		return true
	end

	if not ChariotSystem.setVisual(player, visualId) then
		player:sendTextMessage(MESSAGE_INFO_DESCR,"You have not unlocked this caravan visual.")
		ChariotSystem.openVisualModal(player)
		return true
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your caravan visual is now " .. visual.name .. ".")
	return true
end
visualModal:type("modalwindow")
visualModal:register()

local modalTalk = TalkAction("!caravan")

function modalTalk.onSay(player, words, param)
	ChariotSystem.openModule(player)
	return false
end

modalTalk:separator(" ")
modalTalk:register()
