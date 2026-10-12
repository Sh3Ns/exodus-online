local function setStoredOutfit(player, storedLookType, storedLookAddons, storedLookWings, storedLookAura, storedLookShader)
    local playerOutfit = player:getOutfit()

    if storedLookType > 0 then
        playerOutfit.lookType = storedLookType
    end
    if storedLookAddons > 0 then
        playerOutfit.lookAddons = storedLookAddons
    end
    if storedLookWings > 0 then
        playerOutfit.lookWings = storedLookWings
    end
    if storedLookAura > 0 then
        playerOutfit.lookAura = storedLookAura
    end
    if storedLookShader > 0 then
        playerOutfit.lookShader = storedLookShader
    end

    player:setOutfit(playerOutfit)
end

local startupEvents = {
	'TutorialCockroach',
	'ElementalSpheresOverlords',
	'BigfootBurdenVersperoth',
	'BigfootBurdenWarzone',
	'BigfootBurdenWeeper',
	'BigfootBurdenWiggler',
	'SvargrondArenaKill',
	'NewFrontierShardOfCorruption',
	'NewFrontierTirecz',
	'ServiceOfYalaharDiseasedTrio',
	'ServiceOfYalaharAzerus',
	'ServiceOfYalaharQuaraLeaders',
	'InquisitionBosses',
	'InquisitionUngreez',
	'KillingInTheNameOfKills',
	'MastersVoiceServants',
	'SecretServiceBlackKnight',
	'ThievesGuildNomad',
	'WotELizardMagistratus',
	'WotELizardNoble',
	'WotEKeeper',
	'WotEBosses',
	'WotEZalamon',
	'PlayerDeath',
	'AdvanceSave',
	'AdvanceRookgaard',
	'PythiusTheRotten',
	'DropLoot',
	'GameStore',
	'GameExtendedOpcode',
	'ModalWindowHelper',
	'ancestralTask',
	'onDeath_randomTierDrops',
	'graveMiniBossesDeath',
	'BootedDailyCreature',
	'BootedDailyBoss',
	'BoostedCreatureKill',
	'AutoLoot',
	'terrorSpider',
	'deepNecromancer',
	'playerAttackSound',
	'lurskSpidersDeath',
	'frostsMonstersKill',
	'expeditionsMounts',
	'rarity_onHealthChangeAbsorb',
	'rarity_onHealthChangeDamage',
	'BossTimersExtended',
}

local trackedStorageRanges = {
	{110000, 110200, true},
	{343585, 343590, false},
	{48076, 48080, false},
	{222441, 222445, false},
	{977544, 977561, false},
}

local function initializeStorageRange(player, firstStorage, lastStorage, onlyWhenMissingAny)
	if onlyWhenMissingAny then
		for storageKey = firstStorage, lastStorage do
			if player:getStorageValue(storageKey) == -1 then
				for resetKey = firstStorage, lastStorage do
					player:setStorageValue(resetKey, 0)
				end
				return
			end
		end
		return
	end

	for storageKey = firstStorage, lastStorage do
		if player:getStorageValue(storageKey) == -1 then
			player:setStorageValue(storageKey, 0)
		end
	end
end

local function initializeTrackedStorages(player, includeFirstLoginRange)
	for i = 1, #trackedStorageRanges do
		local range = trackedStorageRanges[i]
		if includeFirstLoginRange or not range[3] then
			initializeStorageRange(player, range[1], range[2], range[3])
		end
	end
end

local function registerLoginEvents(player)
	for i = 1, #startupEvents do
		player:registerEvent(startupEvents[i])
	end
end

local furyGateMessages = {
	[1] = 'Fury Gate is on Venore Today.',
	[2] = 'Fury Gate is on Abdendriel Today.',
	[3] = 'Fury Gate is on Thais Today.',
	[4] = 'Fury Gate is on Carlin Today.',
	[5] = 'Fury Gate is on Edron Today.',
	[6] = 'Fury Gate is on Kazordoon Today.',
	[7] = 'Fury Gate is on Darashia Today.',
}

local furyGateStorageMap = {
	[9710] = 1,
	[9711] = 2,
	[9712] = 3,
	[9713] = 4,
	[9714] = 5,
	[9716] = 6,
	[9715] = 7,
}

local azurePortalMessages = {
	[1] = 'Azure Portal is at north of Thais Today.',
	[2] = 'Azure Portal is at north east of Roshamuul Today.',
	[3] = 'Azure Portal is at west of Darashia Today.',
	[4] = 'Azure Portal is at south west of Svargrond Today.',
}

local function sendDailyPortalMessages(player)
	for storageKey, expectedValue in pairs(furyGateStorageMap) do
		if Game.getStorageValue(GlobalStorage.FuryGates, storageKey) == expectedValue then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, furyGateMessages[expectedValue])
			break
		end
	end

	local azurePortalValue = Game.getStorageValue(30048)
	local azurePortalMessage = azurePortalMessages[azurePortalValue]
	if azurePortalMessage then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, azurePortalMessage)
	end
end

local function sendBlessingStatus(player)
	local blessings = {"Spiritual Shielding", "Embrace of Tibia", "Fire of the Suns", "Spark of the Phoenix", "Wisdom of Solitude"}
	local blessingIds = {1, 2, 3, 4, 5}
	local amount = 0
	local missing = {}

	for i = 1, #blessingIds do
		if player:hasBlessing(blessingIds[i]) then
			amount = amount + 1
		else
			missing[#missing + 1] = blessings[i]
		end
	end

	local suffix = amount == 1 and '' or 's'
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You have " .. amount .. " blessing" .. suffix .. " (" .. amount * 20 .. "%).\nMissing blessings: " .. table.concat(missing, ", "))
end

local function applySavedVisualsFromDatabase(player, playerId)
	local resultId = db.storeQuery("SELECT wings_id, shader_id, aura_id FROM players WHERE id = " .. playerId)
    if resultId ~= false then
        local wingsId = result.getDataInt(resultId, "wings_id")
        local shaderId = result.getDataInt(resultId, "shader_id")
        local auraId = result.getDataInt(resultId, "aura_id")
        result.free(resultId)

        local outfit = player:getOutfit()
        outfit.lookWings = wingsId or outfit.lookWings
        outfit.lookShader = shaderId or outfit.lookShader
        outfit.lookAura = auraId or outfit.lookAura
        player:setOutfit(outfit)
    end
end

local function notifyRewardChest(player)
	local rewardChest = player:getRewardChest()
	local rewardContainerCount = 0
	for _, item in ipairs(rewardChest:getItems()) do
		if item:getId() == ITEM_REWARD_CONTAINER then
			rewardContainerCount = rewardContainerCount + 1
		end
	end

	if rewardContainerCount > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You have %d reward%s in your reward chest.", rewardContainerCount, rewardContainerCount > 1 and "s" or ""))
	end
end

local function applyPromotionState(player)
	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	if player:isPremium() then
		local value = player:getStorageValue(PlayerStorageKeys.promotion)
		if value == 1 then
			player:setVocation(promotion)
		end
	elseif not promotion then
		player:setVocation(vocation:getDemotion())
	end
end

local function onMovementRemoveProtection(cid, oldPosition, time)
	local player = Player(cid)
	if not player then
		return true
	end

	local playerPosition = player:getPosition()
	if (playerPosition.x ~= oldPosition.x or playerPosition.y ~= oldPosition.y or playerPosition.z ~= oldPosition.z) or player:getTarget() or time <= 0 then
		player:setStorageValue(Storage.combatProtectionStorage, 0)
		return true
	end

	addEvent(onMovementRemoveProtection, 1000, cid, oldPosition, time - 1)
end

function onLogin(player)
	local playerId = player:getGuid()
	local serverName = configManager.getString(configKeys.SERVER_NAME)
	local loginStr = "Welcome to " .. serverName .. "!"
	local isFirstLogin = player:getLastLoginSaved() <= 0

	if isFirstLogin then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
		initializeTrackedStorages(player, true)
	else
		loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end

	initializeTrackedStorages(player, false)
	sendReputationToPlayer(player)
	BossTimers.send(player)
	playSoundPlayer(player, "login.ogg")
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
	player:setStorageValue(Exercise_Training.isTraining, 0)

	sendBlessingStatus(player)
	applySavedVisualsFromDatabase(player, playerId)

	local storedLookType = player:getStorageValue(709919)
	local storedLookAddons = player:getStorageValue(709920)
	local storedLookWings = player:getStorageValue(709921)
	local storedLookAura = player:getStorageValue(709922)
	local storedLookShader = player:getStorageValue(709923)

	if storedLookType > 0 or storedLookAddons > 0 or storedLookWings > 0 or storedLookAura > 0 or storedLookShader > 0 then
		setStoredOutfit(player, storedLookType, storedLookAddons, storedLookWings, storedLookAura, storedLookShader)
	end

	registerLoginEvents(player)
	sendDailyPortalMessages(player)

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, 'See commands: !commands. Familiar: To summon a familiar use: !summonfamiliar, for choose a familiar use: !choosefamiliar. To configure the autoloot, right click on your backpack.')

	applyPromotionState(player)
	notifyRewardChest(player)

	if player:getStorageValue(Storage.combatProtectionStorage) <= os.time() then
		player:setStorageValue(Storage.combatProtectionStorage, os.time() + 10)
		onMovementRemoveProtection(playerId, player:getPosition(), 10)
	end

	return true
end
