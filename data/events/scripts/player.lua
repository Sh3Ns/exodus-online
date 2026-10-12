function Player:onBrowseField(position)
	if hasEventCallback(EVENT_CALLBACK_ONBROWSEFIELD) then
		return EventCallback(EVENT_CALLBACK_ONBROWSEFIELD, self, position)
	end
	return true
end

function Player:onLook(thing, position, distance)
    local description = ""
    
    if hasEventCallback(EVENT_CALLBACK_ONLOOK) then
        local callbackResult = EventCallback(EVENT_CALLBACK_ONLOOK, self, thing, position, distance, description)
        
        if callbackResult then
            description = callbackResult
        end
    end
    
    if thing:isCreature() then
        if thing:isPlayer() then
            local rankTask = getRankTask(thing)
            if rankTask then
                description = string.format("%s\n Ancestral Rank: %s", description, rankTask)
            end
        end
    end
    
    self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInBattleList(creature, distance)
	local description = ""
	if hasEventCallback(EVENT_CALLBACK_ONLOOKINBATTLELIST) then
		description = EventCallback(EVENT_CALLBACK_ONLOOKINBATTLELIST, self, creature, distance, description)
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInTrade(partner, item, distance)
	local description = "You see " .. item:getDescription(distance)
	if hasEventCallback(EVENT_CALLBACK_ONLOOKINTRADE) then
		description = EventCallback(EVENT_CALLBACK_ONLOOKINTRADE, self, partner, item, distance, description)
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInShop(itemType, count, description)
	local description = "You see " .. description
	if hasEventCallback(EVENT_CALLBACK_ONLOOKINSHOP) then
		description = EventCallback(EVENT_CALLBACK_ONLOOKINSHOP, self, itemType, count, description)
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onSpellCast(spellName, spellGroup, aggressive, manaCost)
	if type(_G.WeaponProficiencyExt) == "table" and type(_G.WeaponProficiencyExt.onSpellCast) == "function" then
		_G.WeaponProficiencyExt.onSpellCast(self, spellName, spellGroup, aggressive, manaCost)
	end
	if type(_G.WheelDestiny_onPlayerSpellCast) == "function" then
		_G.WheelDestiny_onPlayerSpellCast(self, spellName, spellGroup, aggressive, manaCost)
	end
	if type(_G.GemsSocket_onPlayerSpellCast) == "function" then
		_G.GemsSocket_onPlayerSpellCast(self, spellName, spellGroup, aggressive, manaCost)
	end
end

function Player:onSpellCost(spellName, spellGroup, aggressive, manaCost, missingMana)
	if type(_G.GemsSocket_getBloodPriceHealthCost) == "function" then
		return math.max(0, tonumber(_G.GemsSocket_getBloodPriceHealthCost(self, spellGroup, aggressive, manaCost, missingMana)) or 0)
	end
	return 0
end

function Player:onSpellPreCast(spellName, spellGroup, aggressive, manaCost, healthCost)
	if type(_G.GemsSocket_prepareBloodPriceCast) == "function" then
		_G.GemsSocket_prepareBloodPriceCast(self, spellGroup, aggressive, manaCost, healthCost)
	end
	if type(_G.WheelDestiny_onPlayerSpellPreCast) == "function" then
		_G.WheelDestiny_onPlayerSpellPreCast(self, spellName, spellGroup, aggressive, manaCost, healthCost)
	end
end

function Player:onSpellCooldown(spellName, spellGroup, aggressive, cooldownType, currentCooldown)
	local cooldown = math.max(0, tonumber(currentCooldown) or 0)
	if type(_G.WeaponProficiencyExt) == "table" and type(_G.WeaponProficiencyExt.getSpellCooldown) == "function" then
		cooldown = math.max(0, tonumber(_G.WeaponProficiencyExt.getSpellCooldown(self, spellName, cooldown)) or cooldown)
	end
	if type(_G.GemsSocket_getCarrionSpellCooldownMs) == "function" then
		local adjusted = _G.GemsSocket_getCarrionSpellCooldownMs(self, spellName, spellGroup, aggressive, cooldownType, cooldown)
		if adjusted ~= nil then
			cooldown = math.max(0, tonumber(adjusted) or 0)
		end
	end
	if type(_G.WheelDestiny_getSpellCooldownMs) == "function" then
		local adjusted = _G.WheelDestiny_getSpellCooldownMs(self, spellName, spellGroup, aggressive, cooldownType, cooldown)
		if adjusted ~= nil then
			cooldown = math.max(0, tonumber(adjusted) or 0)
		end
	end
	return cooldown
end

local PAD_AID = 46201
local PAD_SINGLE = { [1387] = true }
local PAD_FIRST, PAD_LAST = 29629, 29641
local BLOCK_CARDS_AID = 37866
local SEA_TILE_IDS = {
	[27725] = true,
	[27728] = true,
	[27729] = true,
	[27730] = true,
	[27731] = true,
}
local BLOCKED_MOVE_CREATURE_AIDS = {
	[31768] = true,
}
local CONST_SLOT_SHIP = CONST_SLOT_SHIP or 14

local function isPadId(id)
  if PAD_SINGLE[id] then
    return true
  end
  if id >= PAD_FIRST and id <= PAD_LAST then
    return true
  end
  return false
end

local function isPadItem(it)
  return it and it:isItem() and isPadId(it:getId()) and it:getActionId() == PAD_AID
end

local function tileHasPad(tile)
	if not tile then
		return false
	end

	local g = tile:getGround()
	if isPadItem(g) then
		return true
	end

	if tile.getItems then
		local items = tile:getItems()

		if items then
			for _, it in ipairs(items) do
				if isPadItem(it) then
					return true
				end
			end
		end
	else
		local n = tile:getThingCount()
		for i = 0, n - 1 do
			local th = tile:getThing(i)
			if isPadItem(th) then
				return true
			end
		end
	end

	return false
end

function Player:onMoveItem(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    if item:getActionId() == BLOCK_CARDS_AID then
        self:sendTextMessage(MESSAGE_INFO_DESCR, "You cannot move an activated card, first deactivate it.")
        return RETURNVALUE_NOTENOUGHROOM
    end

	if ChariotSystem and ChariotSystem.canMoveItemToStorage then
		local caravanMoveResult = ChariotSystem.canMoveItemToStorage(self, item, fromCylinder, toCylinder)
		if caravanMoveResult ~= RETURNVALUE_NOERROR then
			return caravanMoveResult
		end
	end

	if toPosition and toPosition.x > 0 and toPosition.y > 0 and toPosition.z >= 0 then
		local tile = Tile(toPosition)
		if tile then
			local ground = tile:getGround()
			if ground and SEA_TILE_IDS[ground:getId()] then
				toPosition:sendMagicEffect(2) -- Optional visual
				item:remove()
				return RETURNVALUE_NOERROR
			end
		end
	end

	if toPosition.x ~= CONTAINER_POSITION then
		local tile = (toCylinder and toCylinder.isTile and toCylinder:isTile()) and toCylinder or Tile(toPosition)
		if tile and tileHasPad(tile) then
		self:sendCancelMessage("You cannot drop items on a portal.")
		toPosition:sendMagicEffect(CONST_ME_POFF)
		return RETURNVALUE_NOTPOSSIBLE
		end
	end

	-- -- Restrict Gloves onEquip
	-- local restrictedGloves = {29577, 29582, 29583, 29584, 29586, 29587, 29588, 29589, 29590 }
	-- local storageKeyGloves = 249571
	-- local storageKeyEquippedGloves = 249572
	-- local CONST_SLOT_BELT = CONST_SLOT_BELT or 15
    -- local CONST_SLOT_GLOVES = CONST_SLOT_GLOVES or 16

	-- local itemId = item:getId()
	-- if table.contains(restrictedGloves, itemId) then
    --     if toPosition.y == CONST_SLOT_BELT or toPosition.y == CONST_SLOT_GLOVES then
    --         if self:getStorageValue(storageKeyGloves) == 1 then
    --             if self:getStorageValue(storageKeyEquippedGloves) ~= itemId then
    --                 self:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one glove at time.")
    --                 return RETURNVALUE_NOTENOUGHROOM
    --             end
    --             local slots = {CONST_SLOT_BELT, CONST_SLOT_GLOVES}
    --             for _, slot in ipairs(slots) do
    --                 local equippedItem = self:getSlotItem(slot)
    --                 if equippedItem and equippedItem:getId() == itemId then
    --                     self:sendTextMessage(MESSAGE_INFO_DESCR, "You cannot equip the same item twice.")
    --                     return RETURNVALUE_NOTENOUGHROOM
    --                 end
    --             end
    --         end
    --         self:setStorageValue(storageKeyGloves, 1)
    --         self:setStorageValue(storageKeyEquippedGloves, itemId)
    --         return RETURNVALUE_NOERROR
    --     end
    --     if fromPosition.y == CONST_SLOT_BELT or fromPosition.y == CONST_SLOT_GLOVES then
    --         if self:getStorageValue(storageKeyEquippedGloves) == itemId then
    --             self:setStorageValue(storageKeyGloves, 0)
    --             self:setStorageValue(storageKeyEquippedGloves, -1)
    --         end
    --         return RETURNVALUE_NOERROR
    --     end
    -- end

	-- -- Restrict Belts onEquip
	-- local restrictedBelts = {29578, 29591, 29592, 29593, 29594, 29595, 29596, 29597, 29598}
	-- local storageKeyBelt = 249573
	-- local storageKeyEquippedBelt = 249574
	-- local CONST_SLOT_BELT = CONST_SLOT_BELT or 15
    -- local CONST_SLOT_GLOVES = CONST_SLOT_GLOVES or 16

	-- local itemId = item:getId()
	-- if table.contains(restrictedBelts, itemId) then
    --     if toPosition.y == CONST_SLOT_BELT or toPosition.y == CONST_SLOT_GLOVES then
    --         if self:getStorageValue(storageKeyBelt) == 1 then
    --             if self:getStorageValue(storageKeyEquippedBelt) ~= itemId then
    --                 self:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one belt at time.")
    --                 return RETURNVALUE_NOTENOUGHROOM
    --             end
    --             local slots = {CONST_SLOT_BELT, CONST_SLOT_GLOVES}
    --             for _, slot in ipairs(slots) do
    --                 local equippedItem = self:getSlotItem(slot)
    --                 if equippedItem and equippedItem:getId() == itemId then
    --                     self:sendTextMessage(MESSAGE_INFO_DESCR, "You cannot equip the same item twice.")
    --                     return RETURNVALUE_NOTENOUGHROOM
    --                 end
    --             end
    --         end
    --         self:setStorageValue(storageKeyBelt, 1)
    --         self:setStorageValue(storageKeyEquippedBelt, itemId)
    --         return RETURNVALUE_NOERROR
    --     end
    --     if fromPosition.y == CONST_SLOT_BELT or fromPosition.y == CONST_SLOT_GLOVES then
    --         if self:getStorageValue(storageKeyEquippedBelt) == itemId then
    --             self:setStorageValue(storageKeyBelt, 0)
    --             self:setStorageValue(storageKeyEquippedBelt, -1)
    --         end
    --         return RETURNVALUE_NOERROR
    --     end
    -- end

	-- -- Restrict Decks onEquip
	-- local restrictedDeck = {27632, 27633, 27634}
	-- local storageKeyDeck = 249575
	-- local storageKeyEquippedDeck = 249576
	-- local CONST_SLOT_DECK = CONST_SLOT_DECK or 12
    -- local CONST_SLOT_BADGE = CONST_SLOT_BADGE or 13

	-- local itemId = item:getId()
	-- if table.contains(restrictedDeck, itemId) then
    --     if toPosition.y == CONST_SLOT_DECK or toPosition.y == CONST_SLOT_BADGE then
    --         if self:getStorageValue(storageKeyDeck) == 1 then
    --             if self:getStorageValue(storageKeyEquippedDeck) ~= itemId then
    --                 self:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one deck at time.")
    --                 return RETURNVALUE_NOTENOUGHROOM
    --             end
    --             local slots = {CONST_SLOT_DECK, CONST_SLOT_BADGE}
    --             for _, slot in ipairs(slots) do
    --                 local equippedItem = self:getSlotItem(slot)
    --                 if equippedItem and equippedItem:getId() == itemId then
    --                     self:sendTextMessage(MESSAGE_INFO_DESCR, "You cannot equip the same item twice.")
    --                     return RETURNVALUE_NOTENOUGHROOM
    --                 end
    --             end
    --         end
    --         self:setStorageValue(storageKeyDeck, 1)
    --         self:setStorageValue(storageKeyEquippedDeck, itemId)
    --         return RETURNVALUE_NOERROR
    --     end
    --     if fromPosition.y == CONST_SLOT_DECK or fromPosition.y == CONST_SLOT_BADGE then
    --         if self:getStorageValue(storageKeyEquippedDeck) == itemId then
    --             self:setStorageValue(storageKeyDeck, 0)
    --             self:setStorageValue(storageKeyEquippedDeck, -1)
    --         end
    --         return RETURNVALUE_NOERROR
    --     end
    -- end

	-- -- Restrict Badges onEquip
	-- local restrictedBadge = {27803, 27804, 27805, 27806, 27807, 27808, 27809, 27810, 27811, 27812, 27813, 27814, 27815, 27816, 27817, 27818, 27819, 27820, 27821, 27822, 27823, 27824, 27825, 27826, 27827, 27828, 27829, 27830, 27831, 27832, 27833, 27834, 27835, 27836, 27837, 27838, 27839, 27840, 27841, 27842}
	-- local storageKeyBadge = 249577
	-- local storageKeyEquippedBadge = 249578
	-- local CONST_SLOT_DECK = CONST_SLOT_DECK or 12
    -- local CONST_SLOT_BADGE = CONST_SLOT_BADGE or 13

	-- local itemId = item:getId()
	-- if table.contains(restrictedBadge, itemId) then
    --     if toPosition.y == CONST_SLOT_DECK or toPosition.y == CONST_SLOT_BADGE then
    --         if self:getStorageValue(storageKeyBadge) == 1 then
    --             if self:getStorageValue(storageKeyEquippedBadge) ~= itemId then
    --                 self:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one badge at time.")
    --                 return RETURNVALUE_NOTENOUGHROOM
    --             end
    --             local slots = {CONST_SLOT_DECK, CONST_SLOT_BADGE}
    --             for _, slot in ipairs(slots) do
    --                 local equippedItem = self:getSlotItem(slot)
    --                 if equippedItem and equippedItem:getId() == itemId then
    --                     self:sendTextMessage(MESSAGE_INFO_DESCR, "You cannot equip the same item twice.")
    --                     return RETURNVALUE_NOTENOUGHROOM
    --                 end
    --             end
    --         end
    --         self:setStorageValue(storageKeyBadge, 1)
    --         self:setStorageValue(storageKeyEquippedBadge, itemId)
    --         return RETURNVALUE_NOERROR
    --     end
    --     if fromPosition.y == CONST_SLOT_DECK or fromPosition.y == CONST_SLOT_BADGE then
    --         if self:getStorageValue(storageKeyEquippedBadge) == itemId then
    --             self:setStorageValue(storageKeyBadge, 0)
    --             self:setStorageValue(storageKeyEquippedBadge, -1)
    --         end
    --         return RETURNVALUE_NOERROR
    --     end
    -- end
	
	-- Restrict player de equip boat if navigating
	-- Prevent unequipping the boat while navigating
	if self:getStorageValue(109017) == 1 then
		-- Only block if player is trying to unequip something from the SHIP slot
		if fromPosition.y == CONST_SLOT_SHIP and toPosition.x > 0 and toPosition.y > 0 and toPosition.z >= 0 then
			local playerTile = self:getPosition():getTile()
			if playerTile then
				local ground = playerTile:getGround()
				if ground and SEA_TILE_IDS[ground:getId()] then
					self:sendTextMessage(MESSAGE_INFO_DESCR, "You cannot deequip the boat while navigating.")
					return RETURNVALUE_NOTENOUGHROOM
				end
			end
		end
	end

    if hasEventCallback(EVENT_CALLBACK_ONMOVEITEM) then
        return EventCallback(EVENT_CALLBACK_ONMOVEITEM, self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    end

    return RETURNVALUE_NOERROR
end

function Player:onItemMoved(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if hasEventCallback(EVENT_CALLBACK_ONITEMMOVED) then
		EventCallback(EVENT_CALLBACK_ONITEMMOVED, self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	end
	if type(_G.WeaponProficiencyExt) == "table" and type(_G.WeaponProficiencyExt.updatePlayerBonuses) == "function" then
		_G.WeaponProficiencyExt.updatePlayerBonuses(self)
	end
end

function Player:onMoveCreature(creature, fromPosition, toPosition)
	if creature == self and type(_G.ExtraSocketGems) == "table" and type(_G.ExtraSocketGems.onPlayerMove) == "function" then
		_G.ExtraSocketGems.onPlayerMove(self)
	end

	if hasEventCallback(EVENT_CALLBACK_ONMOVECREATURE) then
		return EventCallback(EVENT_CALLBACK_ONMOVECREATURE, self, creature, fromPosition, toPosition)
	end
	local fromTile = fromPosition and fromPosition:getTile()
	local ground = fromTile and fromTile:getGround()
	if ground and BLOCKED_MOVE_CREATURE_AIDS[ground:getActionId()] then
		return false
	end
	return true
end

function Player:onReportRuleViolation(targetName, reportType, reportReason, comment, translation)
	if hasEventCallback(EVENT_CALLBACK_ONREPORTRULEVIOLATION) then
		EventCallback(EVENT_CALLBACK_ONREPORTRULEVIOLATION, self, targetName, reportType, reportReason, comment, translation)
	end
end

function Player:onReportBug(message, position, category)
	if hasEventCallback(EVENT_CALLBACK_ONREPORTBUG) then
		return EventCallback(EVENT_CALLBACK_ONREPORTBUG, self, message, position, category)
	end
	return true
end

function Player:onTurn(direction)
	if hasEventCallback(EVENT_CALLBACK_ONTURN) then
		return EventCallback(EVENT_CALLBACK_ONTURN, self, direction)
	end
	return true
end

function Player:onTradeRequest(target, item)
    if item:getActionId() == BLOCK_CARDS_AID then
        self:sendTextMessage(MESSAGE_INFO_DESCR, "You cannot trade an activated card, first deactivate it.")
        return RETURNVALUE_NOTENOUGHROOM
    end
	TradeRarity_begin(self, target)
  	TradeRarity_setSideItems(self, 0, item)
	if hasEventCallback(EVENT_CALLBACK_ONTRADEREQUEST) then
		return EventCallback(EVENT_CALLBACK_ONTRADEREQUEST, self, target, item)
	end
	return true
end

function Player:onTradeAccept(target, item, targetItem)
	TradeRarity_setSideItems(self, 0, item)
  	TradeRarity_setSideItems(target, 0, targetItem)
	if hasEventCallback(EVENT_CALLBACK_ONTRADEACCEPT) then
		return EventCallback(EVENT_CALLBACK_ONTRADEACCEPT, self, target, item, targetItem)
	end
	return true
end

function Player:onTradeCompleted(target, item, targetItem, isSuccess)
	TradeRarity_clear(self)
  	TradeRarity_clear(target)
	if hasEventCallback(EVENT_CALLBACK_ONTRADECOMPLETED) then
		EventCallback(EVENT_CALLBACK_ONTRADECOMPLETED, self, target, item, targetItem, isSuccess)
	end
end

local soulCondition = Condition(CONDITION_SOUL, CONDITIONID_DEFAULT)
soulCondition:setTicks(4 * 60 * 1000)
soulCondition:setParameter(CONDITION_PARAM_SOULGAIN, 1)

local function useStamina(player)
	local staminaMinutes = player:getStamina()
	if staminaMinutes == 0 then
		return
	end

	local playerId = player:getId()
	if not nextUseStaminaTime[playerId] then
		nextUseStaminaTime[playerId] = 0
	end

	local currentTime = os.time()
	local timePassed = currentTime - nextUseStaminaTime[playerId]
	if timePassed <= 0 then
		return
	end

	if timePassed > 60 then
		if staminaMinutes > 2 then
			staminaMinutes = staminaMinutes - 2
		else
			staminaMinutes = 0
		end
		nextUseStaminaTime[playerId] = currentTime + 120
	else
		staminaMinutes = staminaMinutes - 1
		nextUseStaminaTime[playerId] = currentTime + 60
	end
	player:setStamina(staminaMinutes)
end

local pet_storage_experience = 633451
local pet_storage_level = 633452
local pet_id = 633453
local pet_name = 633454

if not dirtyPetProgress then
	dirtyPetProgress = {}
end

local function normalizePetProgress(petLevel, petExperience)
	petLevel = tonumber(petLevel) or 1
	petExperience = tonumber(petExperience) or 0

	if petLevel < 1 then
		petLevel = 1
	end

	if petExperience < 0 then
		petExperience = 0
	end

	local nextLevelExperience = calculateNextLevelExperience(petLevel)
	if nextLevelExperience <= 0 then
		return petLevel, 0
	end

	-- Old saved rows may contain cumulative pet EXP instead of the remainder for the current level.
	-- Clamp to the current-level remainder so kill-time progression does not loop through stale totals.
	if petExperience >= nextLevelExperience then
		petExperience = petExperience % nextLevelExperience
	end

	return petLevel, petExperience
end

local function setDirtyPetProgress(playerGuid, petExperience, petLevel)
	dirtyPetProgress[playerGuid] = {
		experience = petExperience,
		level = petLevel,
	}
end

function saveDirtyPetProgressByGuid(playerGuid)
	local dirtyEntry = dirtyPetProgress[playerGuid]
	if not dirtyEntry then
		return false
	end

	db.query(
		"UPDATE `players` SET `pet_experience` = " .. dirtyEntry.experience ..
		", `pet_level` = " .. dirtyEntry.level ..
		" WHERE `id` = " .. playerGuid
	)
	dirtyPetProgress[playerGuid] = nil
	return true
end

function saveDirtyPetProgress(player)
	if not player then
		return false
	end

	return saveDirtyPetProgressByGuid(player:getGuid())
end

function flushAllDirtyPetProgress()
	local flushedAny = false
	for playerGuid in pairs(dirtyPetProgress) do
		if saveDirtyPetProgressByGuid(playerGuid) then
			flushedAny = true
		end
	end
	return flushedAny
end

function Player:getPet()
    local petId = self:getStorageValue(pet_id)
    if petId > 0 then
        return Creature(petId)
    end
    return nil
end

local monsterExpBoosts = {
    ["bloated man-maggot"] = 876547,
    ["converter"] = 876548,
    ["darklight construct"] = 876549,
	["darklight emitter"] = 876550,
	["darklight matter"] = 876551,
	["darklight source"] = 876552,
	["darklight striker"] = 876553,
	["meandering mushroom"] = 876554,
	["mycobiontic beetle"] = 876555,
	["oozing carcass"] = 876556,
	["oozing corpus"] = 876557,
	["elder bloodjaw"] = 876558,
	["rotten man-maggot"] = 876559,
	["sopping carcass"] = 876560,
	["sopping corpus"] = 876561,
	["walking pillar"] = 876562,
	["wandering pillar"] = 876563,
	["bony sea devil"] = 876564,
	["brachiodemon"] = 876565,
	["branchy crawler"] = 876566,
	["capricious phantom"] = 876567,
	["cloak of terror"] = 876568,
	["courage leech"] = 876569,
	["distorted phantom"] = 876570,
	["druid's apparition"] = 876571,
	["hazardous phantom"] = 876572,
	["infernal demon"] = 876573,
	["infernal phantom"] = 876574,
	["knight's apparition"] = 876575,
	["many faces"] = 876576,
	["mould phantom"] = 876577,
	["paladin's apparition"] = 876578,
	["rotten golem"] = 876579,
	["sorcerer's apparition"] = 876580,
	["turbulent elemental"] = 876581,
	["vibrant phantom"] = 876582
}

function Player:onGainExperience(source, exp, rawExp)
	if not source or source:isPlayer() then
		return exp
	end
	local sourceName = source:getName():lower()
    local storageValue = monsterExpBoosts[sourceName]
    if storageValue then
        if self:getStorageValue(storageValue) >= 1 then
            exp = exp * 1.03 -- Gives 3% EXP Boost Permanent to the monster - 1.00 = Normal, 1.03 = 3%, 2.00 = 100% Plus
        end
	end
	if source:isMonster() then
        local monsterLevel = math.max(0, tonumber(source:getMonsterLevel()) or 0)
        if type(_G.GemsSocket_getExperienceMonsterLevel) == "function" then
            local ok, adjustedLevel = pcall(_G.GemsSocket_getExperienceMonsterLevel, source)
            if ok then
                monsterLevel = math.max(0, tonumber(adjustedLevel) or monsterLevel)
            end
        end
        local bonusExperience = monsterLevel * 0.03
        if monsterLevel > 0 and bonusExperience > 1 then
            exp = exp * bonusExperience
        end
    end

	-- Soul regeneration
	local vocation = self:getVocation()
	if self:getSoul() < vocation:getMaxSoul() and exp >= self:getLevel() then
		soulCondition:setParameter(CONDITION_PARAM_SOULTICKS, vocation:getSoulGainTicks() * 1000)
		self:addCondition(soulCondition)
	end

	if rawExp then
    	exp = exp * Game.getExperienceStage(self:getLevel())
	end

	-- Stamina modifier
	if configManager.getBoolean(configKeys.STAMINA_SYSTEM) then
		useStamina(self)
		local staminaMinutes = self:getStamina()
		if staminaMinutes > 2400 and self:isPremium() then
			exp = exp * 1.5
		elseif staminaMinutes <= 840 then
			exp = exp * 0.5
		end
	end
	if self:getStorageValue(6000) >= os.time() then
        exp = exp * 2.00
    end
	local bonusExpStorage = self:getStorageValue(405788)
	if bonusExpStorage and bonusExpStorage > 0 then
    local bonusMultiplier = math.min(3.00, 1 + bonusExpStorage * 0.01)
    	exp = exp * bonusMultiplier
	end
	local bonusExpStorage = self:getStorageValue(405791)
	if bonusExpStorage and bonusExpStorage > 0 then
    local bonusMultiplier = math.min(3.00, 1 + bonusExpStorage * 0.01)
    	exp = exp * bonusMultiplier
	end
	if _G.GuildDynastieEvents and _G.GuildDynastieEvents.getGuildExperienceBonusPercent then
		local dynastieExpBonusPercent = tonumber(_G.GuildDynastieEvents.getGuildExperienceBonusPercent(self, os.time())) or 0
		if dynastieExpBonusPercent > 0 then
			exp = exp * (1 + (dynastieExpBonusPercent / 100))
		end
	end
	if _G.GuildDynastieEvents and _G.GuildDynastieEvents.getBoostedCreatureBonusPercent then
		local boostedCreatureBonusPercent = tonumber(_G.GuildDynastieEvents.getBoostedCreatureBonusPercent(self, source, os.time())) or 0
		if boostedCreatureBonusPercent > 0 then
			exp = exp * (1 + (boostedCreatureBonusPercent / 100))
		end
	end
	if _G.GuildDynastieEvents and _G.GuildDynastieEvents.onGainExperience then
		_G.GuildDynastieEvents.onGainExperience(self, exp, source)
	end
	if _G.GemsSocket_advancedOnGainExperience then
		exp = _G.GemsSocket_advancedOnGainExperience(self, exp, source)
	end

	local pet = self:getPet()
    if not pet then
        return exp
    end

    local pet_experience = pet:getStorageValue(pet_storage_experience)
    local pet_level = pet:getStorageValue(pet_storage_level)
	pet_level, pet_experience = normalizePetProgress(pet_level, pet_experience)
    local petNextLevelExperience = calculateNextLevelExperience(pet_level)
    local petExp = exp * 0.2
	local basePetExp = petExp
	local dynastiePetMultiplier = 1
	if _G.GuildDynastieEvents and _G.GuildDynastieEvents.getPetExperienceMultiplier then
		dynastiePetMultiplier = tonumber(_G.GuildDynastieEvents.getPetExperienceMultiplier(self, os.time())) or 1
		if dynastiePetMultiplier > 1 then
			petExp = petExp * dynastiePetMultiplier
		end
	end
	print(string.format(
		"[PetExp] player=%s source=%s playerExp=%.2f basePetExp=%.2f dynastieMultiplier=%.2f finalPetExp=%.2f petLevel=%d petStoredBefore=%.2f",
		self:getName(),
		source and source:getName() or "unknown",
		tonumber(exp) or 0,
		tonumber(basePetExp) or 0,
		tonumber(dynastiePetMultiplier) or 1,
		tonumber(petExp) or 0,
		tonumber(pet_level) or 0,
		tonumber(pet_experience) or 0
	))

    pet_experience = pet_experience + petExp

    local leveledUp = false

	while pet_experience >= petNextLevelExperience do
		pet_level = pet_level + 1
		pet_experience = pet_experience - petNextLevelExperience
		petNextLevelExperience = calculateNextLevelExperience(pet_level)
		leveledUp = true

		if pet_level == 50 then
			self:setStorageValue(688110, 1)
		elseif pet_level == 100 then
			self:setStorageValue(688111, 1)
		elseif pet_level == 150 then
			self:setStorageValue(688112, 1)
		elseif pet_level == 200 then
			self:setStorageValue(688113, 1)
		elseif pet_level == 250 then
			self:setStorageValue(688114, 1)
		elseif pet_level == 300 then
			self:setStorageValue(688115, 1)
		end
	end

	pet:setStorageValue(pet_storage_experience, pet_experience)
	pet:setStorageValue(pet_storage_level, pet_level)

	local playerGuid = self:getGuid()
	setDirtyPetProgress(playerGuid, pet_experience, pet_level)

	if leveledUp then
		updatePetName(pet, self)
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your Familiar advanced to level " .. pet_level .. "!")
	end

    return exp
end


function Player:onLoseExperience(exp)
	return hasEventCallback(EVENT_CALLBACK_ONLOSEEXPERIENCE) and EventCallback(EVENT_CALLBACK_ONLOSEEXPERIENCE, self, exp) or exp
end

function Player:onGainSkillTries(skill, tries)
	if APPLY_SKILL_MULTIPLIER == false then
		return hasEventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES) and EventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES, self, skill, tries) or tries
	end

	if skill == SKILL_MAGLEVEL then
		tries = tries * configManager.getNumber(configKeys.RATE_MAGIC)
		return hasEventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES) and EventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES, self, skill, tries) or tries
	end
	tries = tries * configManager.getNumber(configKeys.RATE_SKILL)
	return hasEventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES) and EventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES, self, skill, tries) or tries
end

function Player:onWrapItem(item)
	local topCylinder = item:getTopParent()
	if not topCylinder then return end

	local tile = Tile(topCylinder:getPosition())
	if not tile then return end

	local house = tile:getHouse()
	if not house then
		self:sendTextMessage(MESSAGE_INFO_DESCR,"You can only wrap and unwrap this item inside a house.")
		return
	end

	if house:getOwnerGuid() ~= self:getGuid() and not string.find(house:getAccessList(SUBOWNER_LIST):lower(), "%f[%a]" .. self:getName():lower() .. "%f[%A]") then
		self:sendTextMessage(MESSAGE_INFO_DESCR,"You cannot wrap or unwrap items from a house, which you are only guest to.")
		return
	end

	local wrapId = item:getAttribute("wrapid")
	if not wrapId or wrapId == 0 then
		wrapId = ItemType(item:getId()).wrapId
	end
	if wrapId and wrapId > 0 then
		if item:isContainer() and item:getSize() > 0 then
			self:sendTextMessage(MESSAGE_INFO_DESCR, "You must empty the container before wrapping it.")
			return
		end
		if not hasEventCallback(EVENT_CALLBACK_ONWRAPITEM) or EventCallback(EVENT_CALLBACK_ONWRAPITEM, self, item) then
			local oldId = item:getId()
			item:remove(1)
			local newItem = tile:addItem(wrapId)
			if newItem then
				newItem:setAttribute("unwrapid", oldId)
				newItem:setActionId(0)
			end
		end
		return
	end
	local unwrapId = item:getAttribute("unwrapid")
	if not unwrapId or unwrapId == 0 then
		unwrapId = ItemType(item:getId()).unwrapId
	end
	if unwrapId and unwrapId > 0 then
		if not hasEventCallback(EVENT_CALLBACK_ONWRAPITEM) or EventCallback(EVENT_CALLBACK_ONWRAPITEM, self, item) then
			local oldId = item:getId()
			item:remove(1)
			local newItem = tile:addItem(unwrapId)
			if newItem then
				newItem:setAttribute("wrapid", oldId)
				if unwrapId == 29624 then
					newItem:setActionId(42707)
				elseif unwrapId == 29626 then
					newItem:setActionId(42707)
				end
			end
		end
		return
	end

	self:sendTextMessage(MESSAGE_INFO_DESCR,"This item cannot be wrapped or unwrapped.")
end


function Player:onQueueLeave(queue)
	self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
	local dungeon = queue:getDungeon()
	local players = Game.getPlayers()
	local inQueue = queue:getPlayersNumber()
	for _, player in ipairs(players) do
		player:sendExtendedOpcode(
			ExtendedOPCodes.CODE_DUNGEONS,
			json.encode({action = "queueUpdate", data = {id = dungeon:getId(), queue = inQueue, estimated = dungeon:getEstimatedQueueTime(player)}})
		)
	end
end
