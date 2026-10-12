if not ProficiencyData then
	ProficiencyData = {}
	ProficiencyData.__index = ProficiencyData

	ProficiencyData.content = {}
end

function ProficiencyData:loadProficiencyJson()
	self.content = {}

	local candidateFiles = {
		"/json/proficiencies.json",
		"/data/json/proficiencies.json",
		"/modules/game_proficiency/proficiencies.json",
	}

	local file = nil
	for _, candidate in ipairs(candidateFiles) do
		if g_resources.fileExists(candidate) then
			file = candidate
			break
		end
	end

	if not file then
		g_logger.error("Weapon proficiency config file not found. Expected one of: " .. table.concat(candidateFiles, ", "))
		return
	end

	local status, result = pcall(function()
		return json.decode(g_resources.readFileContents(file))
	end)

	if not status then
		return g_logger.error("Error while reading weapon proficiency data. Details: " .. result)
	end

	for i, data in pairs(result) do
		local ProficiencyId = data["ProficiencyId"]
		self.content[ProficiencyId] = data
	end
	WeaponProficiency:createItemCache()
end

function ProficiencyData:isValidProfiencyId(id)
	return self.content[id] ~= nil
end

function ProficiencyData:getContentById(id)
	local content = self.content[id]
	return content and content or nil
end

function ProficiencyData:getPerkLaneCount(id)
	local content = self.content[id]
	if not content then
		return 0
	end

	return table.size(content.Levels)
end

function ProficiencyData:formatFloatValue(value, roundFloat, perkType)
	local function isPercentageType(perkType)
		for _, v in ipairs(PercentageTypes) do
			if v == perkType then
				return true
			end
		end
		return false
	end

	local isInteger = math.floor(value) == value
	if not isInteger or (isInteger and isPercentageType(perkType)) then
		local percentage = value * 100
		if roundFloat then
			local intPart = math.floor(percentage)
			local decimal1 = math.floor(percentage * 10 + 0.5) / 10
			if percentage == intPart then
				return tostring(intPart)
			elseif percentage == decimal1 then
				return string.format("%.1f", percentage)
			else
				return string.format("%.2f", percentage)
			end
		else
			return string.format("%.2f", percentage)
		end
	else
		return tostring(value)
	end
end

function ProficiencyData:getImageSourceAndClip(perkData)
	local perkType = perkData.Type
	local data = PerkVisualData[perkType]
	local source = (data and data.source) or "icons-0"
	local imagePath = string.format("/modules/game_proficiency/proficiency/%s", source)

	if not data then
		return imagePath, "0 0"
	end

	if perkType == PERK_SPELL_AUGMENT then
		local spellData = SpellAugmentIcons[perkData.SpellId]
			or {name = string.format("Spell %s", tostring(perkData.SpellId or "?")), imageOffset = "0 0"}
		return imagePath, spellData.imageOffset 
	end

	if perkType == PERK_BESTIARY_DAMAGE then
		local bestiaryType = BestiaryCategories[perkData.BestiaryName]
		return imagePath, bestiaryType.imageOffset or "0 0"
	end

	if perkType == PERK_MAGIC_BONUS then
		local elementData = MagicBoostMask[perkData.DamageType]
		return imagePath, elementData and elementData.imageOffset or "0 0"
	end

	if ElementalCritical_t[perkType] then
		local elementData = ElementalMask[perkData.ElementId]
		return imagePath, elementData.imageOffset or "0 0"
	end

	if perkType == PERK_ELEMENTAL_PIERCE then
		local elementData = ElementalMask[perkData.ElementId]
		return imagePath, elementData and elementData.imageOffset or "0 0"
	end

	if perkType == PERK_HOMING_MISSILE then
		local elementData = ElementalMask[perkData.ElementId]
		return imagePath, elementData and elementData.imageOffset or "0 0"
	end

	if FlatDamageBonus_t[perkType] then
		local skillData = SkillTypes[perkData.SkillId]
		return imagePath, skillData and skillData.imageOffset or "0 0"
	end

	return imagePath, data.offset or "0 0"
end

function ProficiencyData:getBonusNameAndTooltip(perkData)
	local perkType = perkData.Type
	local data = PerkTextData[perkType]
	local value = self:formatFloatValue(perkData.Value, false, perkType)
	local bonusName = data and data.name or "Empty"

	if not data then
		return bonusName, "Empty"
	end

	if perkType == PERK_SPELL_AUGMENT then
		local spellData = SpellAugmentIcons[perkData.SpellId]
			or {name = string.format("Spell %s", tostring(perkData.SpellId or "?")), imageOffset = "0 0"}
		local augmentData = AugmentPerkIcons[perkData.AugmentType]
			or {desc = "+%s for %s", imageOffset = "0 0"}

		value = self:formatFloatValue(perkData.Value, true, perkType)
		if perkData.AugmentType == AUGMENT_COOLDOWN then
			value = value / 100
		end

		local description = string.format(augmentData.desc, value, spellData.name)
		return bonusName, description
	end

	if perkType == PERK_BESTIARY_DAMAGE then
		local description = string.format(data.desc, value, perkData.BestiaryName)
		return bonusName, description
	end

	if perkType == PERK_MAGIC_BONUS then
		local elementData = MagicBoostMask[perkData.DamageType]
		local description = string.format(data.desc, value, elementData.name)
		return bonusName, description
	end

	if perkType == PERK_PERFECT_SHOT then
		local description = string.format(data.desc, value, perkData.Range)
		return bonusName, description
	end

	if ElementalCritical_t[perkType] then
		local elementData = ElementalMask[perkData.ElementId]
		local description = string.format(data.desc, value, elementData.name)
		return bonusName, description
	end

	if perkType == PERK_ELEMENTAL_PIERCE then
		local elementData = ElementalMask[perkData.ElementId]
		local description = string.format(data.desc, value, elementData and elementData.name or "elemental")
		return bonusName, description
	end

	if perkType == PERK_HOMING_MISSILE then
		local elementData = ElementalMask[perkData.ElementId]
		local chance = self:formatFloatValue(tonumber(perkData.Chance) or 0, true, PERK_HIT_CHANCE)
		local levelMultiplier = self:formatFloatValue(tonumber(perkData.Value) or 0, true, perkType)
		local description = string.format(
			data.desc,
			chance,
			elementData and elementData.name or "elemental",
			levelMultiplier
		)
		return bonusName, description
	end

	if FlatDamageBonus_t[perkType] then
		local skillData = SkillTypes[perkData.SkillId]
		local description = string.format(data.desc, value, skillData.name)
		return bonusName, description
	end
	return bonusName, string.format(data.desc, value)
end

function ProficiencyData:getAugmentIconClip(perkData)
	local augmentData = AugmentPerkIcons[perkData.AugmentType]
	if not augmentData then
		g_logger.warning(string.format("Missing augmentId %d data", perkData.AugmentType))
		return "0 0"
	end
	return augmentData.imageOffset
end

function ProficiencyData:getCurrentCeilExperience(exp, displayItem, maximumStage)
	if #ExperienceTable == 0 then
		local cached = WeaponProficiency and WeaponProficiency.cacheList[displayItem:getId()]
		return math.max(tonumber(exp) or 0, tonumber(cached and cached.maxExp) or 0)
	end

	local best = nil
	local vocation = self:getWeaponProfessionType(displayItem)
	local lastExp = nil
	maximumStage = math.max(1, math.min(tonumber(maximumStage) or #ExperienceTable, #ExperienceTable))
	for index = 1, maximumStage do
		local stage = ExperienceTable[index]
		local stageExp = stage[vocation]
		if stageExp then
			if stageExp > exp then
				if not best or stageExp < best then
					best = stageExp
				end
			end
			lastExp = stageExp
		end
	end
	return best or lastExp
end

function ProficiencyData:getMaxExperience(perkCount, displayItem)
	if #ExperienceTable == 0 then
		local cached = WeaponProficiency and WeaponProficiency.cacheList[displayItem:getId()]
		return tonumber(cached and cached.maxExp) or 0
	end

	local vocation = self:getWeaponProfessionType(displayItem)
	local maximumStage = math.max(1, math.min((tonumber(perkCount) or 0) + 2, #ExperienceTable))
	local lastLevel = ExperienceTable[maximumStage]
	return lastLevel[vocation] or 0
end

function ProficiencyData:getLevelPercent(currentExperience, level, displayItem)
	if #ExperienceTable == 0 then
		local cached = WeaponProficiency and WeaponProficiency.cacheList[displayItem:getId()]
		return (tonumber(cached and cached.level) or 0) >= level and 100 or 0
	end

	local vocation = self:getWeaponProfessionType(displayItem)
	local prevLevel = math.max(level - 1, 0)
	local xpMin = prevLevel == 0 and 0 or ExperienceTable[prevLevel][vocation]
	local xpMax = ExperienceTable[level][vocation] or xpMin + 1

	local progress = math.max(0, math.min(1, (currentExperience - xpMin) / (xpMax - xpMin)))
	return math.floor(progress * 100)
end

function ProficiencyData:getTotalPercent(currentExperience, perkCount, displayItem)
	if #ExperienceTable == 0 then
		local cached = WeaponProficiency and WeaponProficiency.cacheList[displayItem:getId()]
		local maximum = math.max(1, tonumber(cached and cached.maxExp) or 1)
		return math.floor(math.max(0, math.min(1, currentExperience / maximum)) * 100)
	end

	local vocation = self:getWeaponProfessionType(displayItem)
	local maximumStage = math.max(1, math.min((tonumber(perkCount) or 0) + 2, #ExperienceTable))
	local maxExperience = ExperienceTable[maximumStage][vocation] or 1
	local progress = math.max(0, math.min(1, currentExperience / maxExperience))
	return math.floor(progress * 100)
end

function ProficiencyData:getMaxExperienceByLevel(level, displayItem)
	if #ExperienceTable == 0 then
		local cached = WeaponProficiency and WeaponProficiency.cacheList[displayItem:getId()]
		return tonumber(cached and cached.maxExp) or 0
	end

	local vocation = self:getWeaponProfessionType(displayItem)
	return ExperienceTable[level][vocation] or 0
end

function ProficiencyData:getCurrentLevelByExp(displayItem, currentExperience, includeMastery)
	if #ExperienceTable == 0 then
		local cached = WeaponProficiency and WeaponProficiency.cacheList[displayItem:getId()]
		local currentLevel = tonumber(cached and cached.level) or 0
		return includeMastery and currentLevel or math.min(7, currentLevel)
	end

	local vocation = self:getWeaponProfessionType(displayItem)
	local currentLevel = 0

	for level, data in pairs(ExperienceTable) do
		local requiredExp = data[vocation]
		if requiredExp and currentExperience >= requiredExp then
			if level > currentLevel then
				currentLevel = level
			end
		end
	end

	local level = math.min(7, currentLevel)
	if includeMastery then
		level = currentLevel
	end

	return level
end

function ProficiencyData:getWeaponProfessionType(displayItem)
	local cached = WeaponProficiency and WeaponProficiency.cacheList[displayItem:getId()]
	if cached and cached.xpClass and ExperienceTable[1] and ExperienceTable[1][cached.xpClass] then
		return cached.xpClass
	end
	local marketData = displayItem:getMarketData()

	if marketData.restrictVocation and Bit.hasBit(marketData.restrictVocation, Bit.bit(1)) then
		return "knight"
	end

	local marketData = displayItem:getMarketData()
	local itemName = marketData and tostring(marketData.name or ""):lower() or ""
	if itemName:find("crossbow", 1, true) or itemName:find("arbalest", 1, true) or itemName:find("bolter", 1, true) then
		return "crossbow"
	end
	return "regular"
end
