local treeData = dofile("data/scripts/customs/passive_tree/passive_skills.lua").getTreeData()

print(">> Loaded [PoE] Path of Exodus Passive Skill Tree")
local playerPassives = {}
local lastToggle = {}
local PASSIVE_PRESET_LIMIT = 3

for id, node in pairs(treeData.nodes) do
  if node.out then
    for _, outId in ipairs(node.out) do
      local target = treeData.nodes[outId]
      if target then
        target.inputs = target.inputs or {}
        table.insert(target.inputs, id)
      end
    end
  end
end

local function trimString(value)
    if type(value) ~= "string" then
        return ""
    end

    return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function sanitizePresetName(name, fallback)
    local clean = trimString(name)
    if clean == "" then
        clean = fallback
    end

    clean = clean:gsub("[%c]", " ")
    return clean:sub(1, 24)
end

local function normalizePresetNodes(nodes)
    local out = {}
    if type(nodes) ~= "table" then
        return out
    end

    if #nodes > 0 then
        for _, rawNodeId in ipairs(nodes) do
            local nodeId = tonumber(rawNodeId)
            if nodeId and treeData.nodes[nodeId] then
                table.insert(out, nodeId)
            end
        end
    else
        for rawNodeId, enabled in pairs(nodes) do
            local nodeId = tonumber(rawNodeId)
            if enabled and nodeId and treeData.nodes[nodeId] then
                table.insert(out, nodeId)
            end
        end
    end

    table.sort(out)
    return out
end

local function normalizePlayerPresets(data)
    data.presets = type(data.presets) == "table" and data.presets or {}

    local normalized = {}
    for i = 1, PASSIVE_PRESET_LIMIT do
        local preset = data.presets[i] or data.presets[tostring(i)] or {}
        local fallbackName = i == 1 and "Default" or ("Preset " .. i)

        normalized[i] = {
            name = sanitizePresetName(preset.name, fallbackName),
            nodes = normalizePresetNodes(preset.nodes)
        }
    end

    data.presets = normalized
    data.preset = tonumber(data.preset) or 1
    if data.preset < 1 or data.preset > PASSIVE_PRESET_LIMIT then
        data.preset = 1
    end
end

local function getPlayerData(player)
  local pid = player:getGuid()

  if not playerPassives[pid] then
    playerPassives[pid] = {
      points = 0,
      nodes = {},
      preset = 1,
      presets = {
        [1] = { name = "Default", nodes = {} },
        [2] = { name = "Preset 2", nodes = {} },
        [3] = { name = "Preset 3", nodes = {} }
      },
      bonuses = {},
      _loaded = false
    }
  end

  return playerPassives[pid]
end

local function loadPlayerPassiveTree(player)
    local playerId = player:getGuid()
    local query = "SELECT IFNULL(passivetree, '') AS passivetree FROM players WHERE id = " .. playerId
    local resultId = db.storeQuery(query)

    if resultId and resultId ~= 0 then
        local storedData = result.getDataString(resultId, "passivetree")
        if storedData and storedData ~= "" then
            local success, data = pcall(json.decode, storedData)
            if success and type(data) == "table" then
                data.points = tonumber(data.points) or 0
                normalizePlayerPresets(data)

                local nodeMap = {}

                if type(data.nodes) == "table" then
                    if #data.nodes > 0 then
                        for _, nodeId in ipairs(data.nodes) do
                            if treeData.nodes[nodeId] then
                                nodeMap[nodeId] = true
                            end
                        end
                    else
                        for nodeId, enabled in pairs(data.nodes) do
                            if enabled and treeData.nodes[nodeId] then
                                nodeMap[nodeId] = true
                            end
                        end
                    end
                end
                if not next(nodeMap) and data.presets[data.preset] then
                    local presetNodes = data.presets[data.preset].nodes
                    if type(presetNodes) == "table" then
                        for _, nodeId in ipairs(presetNodes) do
                            if treeData.nodes[nodeId] then
                                nodeMap[nodeId] = true
                            end
                        end
                    end
                end

                data.nodes = nodeMap
                data.bonuses = {}

                local base = getPlayerData(player)
                for k, v in pairs(data) do
                    base[k] = v
                end
                base._loaded = true
            end
        end
        result.free(resultId)
    end
    local base = getPlayerData(player)
    if not base._loaded then
        base.points = base.points or 0
        base.nodes = base.nodes or {}
        normalizePlayerPresets(base)
        base.bonuses = {}
        base._loaded = true
    end
    normalizePlayerPresets(base)
end

local function collectNodeIds(anyNodes)
    local out = {}
    if type(anyNodes) ~= "table" then
        return out
    end

    if #anyNodes > 0 then
        for _, nodeId in ipairs(anyNodes) do
            nodeId = tonumber(nodeId)
            if nodeId then
                table.insert(out, nodeId)
            end
        end
    else
        for nodeId, enabled in pairs(anyNodes) do
            nodeId = tonumber(nodeId)
            if enabled and nodeId then
                table.insert(out, nodeId)
            end
        end
    end
    table.sort(out)
    return out
end

local function serializeForDB(data)
    local clean = {
        points = data.points,
        preset = data.preset,
        presets = {},
        bonuses = {}
    }
    clean.nodes = {}
    for nodeId, enabled in pairs(data.nodes or {}) do
        if enabled and type(nodeId) == "number" then
            table.insert(clean.nodes, nodeId)
        end
    end
    table.sort(clean.nodes)
    for presetId, preset in pairs(data.presets or {}) do
        clean.presets[presetId] = {
            name = preset.name,
            nodes = collectNodeIds(preset.nodes)
        }
    end
    return clean
end

local function savePlayerPassiveTree(player)
  local playerId = player:getGuid()
  local data = playerPassives[playerId]

  if not data then
    return
  end

  if not data._loaded then
    return
  end

  local safeData = serializeForDB(data)
  local jsonData = json.encode(safeData)
  local escaped = db.escapeString(jsonData)
  local query = "UPDATE `players` SET `passivetree` = " .. escaped .. " WHERE id = " .. playerId

  db.query(query)
end

local PASSIVE_SUBID_START = 6000
local playerPassiveConditions = {}

local function addPassiveCondition(player, subId, cond)
  player:addCondition(cond)
  local pid = player:getGuid()
  playerPassiveConditions[pid] = playerPassiveConditions[pid] or {}
  table.insert(playerPassiveConditions[pid], subId)
end

local function removeAllPassiveConditions(player)
  local pid = player:getGuid()
  if not playerPassiveConditions[pid] then
    return
  end

  for _, subId in ipairs(playerPassiveConditions[pid]) do
    player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, subId, true)
    player:removeCondition(CONDITION_HASTE, CONDITIONID_DEFAULT, subId, true)
  end

  playerPassiveConditions[pid] = nil
end

local statIndexByName = {
  ["strength"] = CHARSTAT_STRENGTH,
  ["intelligence"] = CHARSTAT_INTELLIGENCE,
  ["dexterity"] = CHARSTAT_DEXTERITY,
  ["vitality"] = CHARSTAT_VITALITY,
  ["spirit"] = CHARSTAT_SPIRIT,
  ["wisdom"] = CHARSTAT_WISDOM
}

local function applyBonusesToPlayer(player, bonuses)
  if not player then
    return
  end

  if not bonuses then
    return
  end
  for _, index in pairs(statIndexByName) do
    player:setCharacterStat(index, 0)
  end

  removeAllPassiveConditions(player)

  local combats = {
    COMBAT_PHYSICALDAMAGE, COMBAT_FIREDAMAGE, COMBAT_ENERGYDAMAGE, COMBAT_EARTHDAMAGE,
    COMBAT_ICEDAMAGE, COMBAT_HOLYDAMAGE, COMBAT_DEATHDAMAGE, COMBAT_WATERDAMAGE,
    COMBAT_ARCANEDAMAGE, COMBAT_HEALING, COMBAT_LIFEDRAIN, COMBAT_MANADRAIN, COMBAT_DROWNDAMAGE
  }

  for _, c in ipairs(combats) do
    player:removeSpecializedMagicLevel(c, 0)
  end

  ---- Stats Bonus & Conditions ----
  --- Increase Health HP ---
  if bonuses.statVitality and bonuses.statVitality > 0 then
    player:addCharacterStat(statIndexByName["vitality"], bonuses.statVitality)
  else
    player:setCharacterStat(statIndexByName["vitality"], 0)
  end
  ---- Reduce Cooldown Time of Spells ----
  if bonuses.statWisdom and bonuses.statWisdom > 0 then
    player:addCharacterStat(statIndexByName["wisdom"], bonuses.statWisdom)
  else
    player:setCharacterStat(statIndexByName["wisdom"], 0)
  end
  ---- Increase Mana Points ---
  if bonuses.statSpirit and bonuses.statSpirit > 0 then
    player:addCharacterStat(statIndexByName["spirit"], bonuses.statSpirit)
  else
    player:setCharacterStat(statIndexByName["spirit"], 0)
  end
  ---- Increase overall elemental damage ----
  if bonuses.statIntelligence and bonuses.statIntelligence > 0 then
    player:addCharacterStat(statIndexByName["intelligence"], bonuses.statIntelligence)
  else
    player:setCharacterStat(statIndexByName["intelligence"], 0)
  end
  ---- Increase Strenght ( attack with weapons ) ----
  if bonuses.statStrength and bonuses.statStrength > 0 then
    player:addCharacterStat(statIndexByName["strength"], bonuses.statStrength)
  else
    player:setCharacterStat(statIndexByName["strength"], 0)
  end
  ---- Increase Fast Attack ----
  if bonuses.statDexterity and bonuses.statDexterity > 0 then
    player:addCharacterStat(statIndexByName["dexterity"], bonuses.statDexterity)
  else
    player:setCharacterStat(statIndexByName["dexterity"], 0)
  end
  
  ---- New Specialized Increments ----
  ---- Increase Fire Magic Level ----
  if bonuses.incrementFire and bonuses.incrementFire > 0 then
    player:addSpecializedMagicLevel(COMBAT_FIREDAMAGE, bonuses.incrementFire)
  else
    player:removeSpecializedMagicLevel(COMBAT_FIREDAMAGE, bonuses.incrementFire or 0)
  end
  --- Increase Physical Damage ---
  if bonuses.incrementPhysical and bonuses.incrementPhysical > 0 then
    player:addSpecializedMagicLevel(COMBAT_PHYSICALDAMAGE, bonuses.incrementPhysical)
  else
    player:removeSpecializedMagicLevel(COMBAT_PHYSICALDAMAGE, bonuses.incrementPhysical or 0)
  end
  --- Increase Energy Damage ---
  if bonuses.incrementEnergy and bonuses.incrementEnergy > 0 then
    player:addSpecializedMagicLevel(COMBAT_ENERGYDAMAGE, bonuses.incrementEnergy)
  else
    player:removeSpecializedMagicLevel(COMBAT_ENERGYDAMAGE, bonuses.incrementEnergy or 0)
  end
  --- Increase Earth Damage ---
  if bonuses.incrementEarth and bonuses.incrementEarth > 0 then
    player:addSpecializedMagicLevel(COMBAT_EARTHDAMAGE, bonuses.incrementEarth)
  else
    player:removeSpecializedMagicLevel(COMBAT_EARTHDAMAGE, bonuses.incrementEarth or 0)
  end
  --- Increase Health Magic  ---
  if bonuses.incrementHealth and bonuses.incrementHealth > 0 then
    player:addSpecializedMagicLevel(COMBAT_HEALING, bonuses.incrementHealth)
  else
    player:removeSpecializedMagicLevel(COMBAT_HEALING, bonuses.incrementHealth or 0)
  end
  --- Increase Ice Damage  ---
  if bonuses.incrementIce and bonuses.incrementIce > 0 then
    player:addSpecializedMagicLevel(COMBAT_ICEDAMAGE, bonuses.incrementIce)
  else
    player:removeSpecializedMagicLevel(COMBAT_ICEDAMAGE, bonuses.incrementIce or 0)
  end
  --- Increase Holy Damage  ---
  if bonuses.incrementHoly and bonuses.incrementHoly > 0 then
    player:addSpecializedMagicLevel(COMBAT_HOLYDAMAGE, bonuses.incrementHoly)
  else
    player:removeSpecializedMagicLevel(COMBAT_HOLYDAMAGE, bonuses.incrementHoly or 0)
  end
  --- Increase Death Damage  ---
  if bonuses.incrementDeath and bonuses.incrementDeath > 0 then
    player:addSpecializedMagicLevel(COMBAT_DEATHDAMAGE, bonuses.incrementDeath)
  else
    player:removeSpecializedMagicLevel(COMBAT_DEATHDAMAGE, bonuses.incrementDeath or 0)
  end
  --- Increase Water Damage  ---
  if bonuses.incrementWater and bonuses.incrementWater > 0 then
    player:addSpecializedMagicLevel(COMBAT_WATERDAMAGE, bonuses.incrementWater)
  else
    player:removeSpecializedMagicLevel(COMBAT_WATERDAMAGE, bonuses.incrementWater or 0)
  end
  --- Increase Arcane Damage  ---
  if bonuses.incrementArcane and bonuses.incrementArcane > 0 then
    player:addSpecializedMagicLevel(COMBAT_ARCANEDAMAGE, bonuses.incrementArcane)
  else
    player:removeSpecializedMagicLevel(COMBAT_ARCANEDAMAGE, bonuses.incrementArcane or 0)
  end
  ---- Not much Used since there is low or no any spell/weapon using this type of damage ----
  --- But has been added for further development ---
  --- Increase Life Drain Damage  ---
  if bonuses.incrementLifeDrain and bonuses.incrementLifeDrain > 0 then
    player:addSpecializedMagicLevel(COMBAT_LIFEDRAIN, bonuses.incrementLifeDrain)
  else
    player:removeSpecializedMagicLevel(COMBAT_LIFEDRAIN, bonuses.incrementLifeDrain or 0)
  end
  --- Increase Mana Drain Damage  ---
  if bonuses.incrementManaDrain and bonuses.incrementManaDrain > 0 then
    player:addSpecializedMagicLevel(COMBAT_MANADRAIN, bonuses.incrementManaDrain)
  else
    player:removeSpecializedMagicLevel(COMBAT_MANADRAIN, bonuses.incrementManaDrain or 0)
  end
  --- Increase Drown Damage  ---
  if bonuses.incrementDrown and bonuses.incrementDrown > 0 then
    player:addSpecializedMagicLevel(COMBAT_DROWNDAMAGE, bonuses.incrementDrown)
  else
    player:removeSpecializedMagicLevel(COMBAT_DROWNDAMAGE, bonuses.incrementDrown or 0)
  end
  -----------------------------------
  ---- Absorb Bonuses ----
  --- Absorb Fire ---
  if bonuses.absorbFire and bonuses.absorbFire > 0 then
    player:setStorageValue(977562, bonuses.absorbFire)
  else
    player:setStorageValue(977562, 0)
  end
  --- Absorb Physical ---
  if bonuses.absorbPhysical and bonuses.absorbPhysical > 0 then
    player:setStorageValue(977563, bonuses.absorbPhysical)
  else
    player:setStorageValue(977563, 0)
  end
  --- Absorb Energy ---
  if bonuses.absorbEnergy and bonuses.absorbEnergy > 0 then
    player:setStorageValue(977564, bonuses.absorbEnergy)
  else
    player:setStorageValue(977564, 0)
  end
  --- Absorb Earth ---
  if bonuses.absorbEarth and bonuses.absorbEarth > 0 then
    player:setStorageValue(977565, bonuses.absorbEarth)
  else
    player:setStorageValue(977565, 0)
  end
  --- Absorb Drown ---
  if bonuses.absorbDrown and bonuses.absorbDrown > 0 then
    player:setStorageValue(977566, bonuses.absorbDrown)
  else
    player:setStorageValue(977566, 0)
  end
  --- Absorb Ice ---
  if bonuses.absorbIce and bonuses.absorbIce > 0 then
    player:setStorageValue(977567, bonuses.absorbIce)
  else
    player:setStorageValue(977567, 0)
  end
  --- Absorb Holy ---
  if bonuses.absorbHoly and bonuses.absorbHoly > 0 then
    player:setStorageValue(977568, bonuses.absorbHoly)
  else
    player:setStorageValue(977568, 0)
  end
  --- Absorb Death ---
  if bonuses.absorbDeath and bonuses.absorbDeath > 0 then
    player:setStorageValue(977569, bonuses.absorbDeath)
  else
    player:setStorageValue(977569, 0)
  end
  --- Absorb Water ---
  if bonuses.absorbWater and bonuses.absorbWater > 0 then
    player:setStorageValue(977570, bonuses.absorbWater)
  else
    player:setStorageValue(977570, 0)
  end
  --- Absorb Arcane ---
  if bonuses.absorbArcane and bonuses.absorbArcane > 0 then
    player:setStorageValue(977571, bonuses.absorbArcane)
  else
    player:setStorageValue(977571, 0)
  end
  --- Absorb Life Drain ---
  if bonuses.absorbLifeDrain and bonuses.absorbLifeDrain > 0 then
    player:setStorageValue(977572, bonuses.absorbLifeDrain)
  else
    player:setStorageValue(977572, 0)
  end
  --- Absorb Mana Drain ---
  if bonuses.absorbManaDrain and bonuses.absorbManaDrain > 0 then
    player:setStorageValue(977574, bonuses.absorbManaDrain)
  else
    player:setStorageValue(977574, 0)
  end

  --- Stats Skills ---
  -- Sword skill
  if bonuses.swordSkill and bonuses.swordSkill > 0 then
    local subId = PASSIVE_SUBID_START + 3
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_SWORD, bonuses.swordSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Axe skill
  if bonuses.axeSkill and bonuses.axeSkill > 0 then
    local subId = PASSIVE_SUBID_START + 4
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_AXE, bonuses.axeSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Club skill
  if bonuses.clubSkill and bonuses.clubSkill > 0 then
    local subId = PASSIVE_SUBID_START + 5
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_CLUB, bonuses.clubSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Distance skill
  if bonuses.distanceSkill and bonuses.distanceSkill > 0 then
    local subId = PASSIVE_SUBID_START + 6
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_DISTANCE, bonuses.distanceSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Shield skill
  if bonuses.shieldSkill and bonuses.shieldSkill > 0 then
    local subId = PASSIVE_SUBID_START + 7
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_SHIELD, bonuses.shieldSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Magic Level
  if bonuses.maglevelSkill and bonuses.maglevelSkill > 0 then
    local subId = PASSIVE_SUBID_START + 14
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, bonuses.maglevelSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Crafting Level
  if bonuses.craftingSkill and bonuses.craftingSkill > 0 then
    local subId = PASSIVE_SUBID_START + 16
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_CRAFTING, bonuses.craftingSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Woodcutting Level
  if bonuses.woodcuttingSkill and bonuses.woodcuttingSkill > 0 then
    local subId = PASSIVE_SUBID_START + 17
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_WOODCUTTING, bonuses.woodcuttingSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Mining Level
  if bonuses.miningSkill and bonuses.miningSkill > 0 then
    local subId = PASSIVE_SUBID_START + 18
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_MINING, bonuses.miningSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Herbalist Level
  if bonuses.herbalistSkill and bonuses.herbalistSkill > 0 then
    local subId = PASSIVE_SUBID_START + 19
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_HERBALIST, bonuses.herbalistSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Armorsmith Level
  if bonuses.armorsmithSkill and bonuses.armorsmithSkill > 0 then
    local subId = PASSIVE_SUBID_START + 20
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_ARMORSMITH, bonuses.armorsmithSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Weaponsmith Level
  if bonuses.weaponsmithSkill and bonuses.weaponsmithSkill > 0 then
    local subId = PASSIVE_SUBID_START + 21
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_WEAPONSMITH, bonuses.weaponsmithSkill)
    addPassiveCondition(player, subId, cond)
  end
  -- Jewelsmith Level
  if bonuses.jewelsmithSkill and bonuses.jewelsmithSkill > 0 then
    local subId = PASSIVE_SUBID_START + 22
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SKILL_JEWELSMITH, bonuses.jewelsmithSkill)
    addPassiveCondition(player, subId, cond)
  end

  --- Special Skills: ---
  -- +Critical Hit Chance
  if bonuses.criticalHitChance and bonuses.criticalHitChance > 0 then
    local subId = PASSIVE_SUBID_START + 8
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, bonuses.criticalHitChance)
    addPassiveCondition(player, subId, cond)
  end

  -- +Critical Hit Amount
  if bonuses.criticalHitAmount and bonuses.criticalHitAmount > 0 then
    local subId = PASSIVE_SUBID_START + 9
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, bonuses.criticalHitAmount)
    addPassiveCondition(player, subId, cond)
  end

  -- +Life Leech Chance
  if bonuses.lifeLeechChance and bonuses.lifeLeechChance > 0 then
    local subId = PASSIVE_SUBID_START + 10
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE, bonuses.lifeLeechChance)
    addPassiveCondition(player, subId, cond)
  end

  -- +Life Leech Amount
  if bonuses.lifeLeechAmount and bonuses.lifeLeechAmount > 0 then
    local subId = PASSIVE_SUBID_START + 11
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT, bonuses.lifeLeechAmount)
    addPassiveCondition(player, subId, cond)
  end

  -- +Mana Leech Chance
  if bonuses.manaLeechChance and bonuses.manaLeechChance > 0 then
    local subId = PASSIVE_SUBID_START + 12
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE, bonuses.manaLeechChance)
    addPassiveCondition(player, subId, cond)
  end

  -- +Mana Leech Amount
  if bonuses.manaLeechAmount and bonuses.manaLeechAmount > 0 then
    local subId = PASSIVE_SUBID_START + 13
    local cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT, bonuses.manaLeechAmount)
    addPassiveCondition(player, subId, cond)
  end
  --- +Speed ----
  --- Speed is a bit different , example adding +500 on speed bonus it will apply /2 so 250 exactly ---
  --- Works as expected only number is not the number itself as scripted on bonus but divided by 2 ---
  if bonuses.speed and bonuses.speed > 0 then
    local subId = PASSIVE_SUBID_START + 15
    local cond = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
    cond:setParameter(CONDITION_PARAM_SUBID, subId)
    cond:setParameter(CONDITION_PARAM_TICKS, -1)
    cond:setParameter(CONDITION_PARAM_SPEED, bonuses.speed)
    addPassiveCondition(player, subId, cond)
  end

  --- Stats Differents ---
  --- Experience ----
  if bonuses.experience and bonuses.experience > 0 then
    player:setStorageValue(405788, bonuses.experience)
  else
    player:setStorageValue(405788, 0)
  end
  ---- Loot --- 
  if bonuses.loot and bonuses.loot > 0 then
    player:setStorageValue(405789, bonuses.loot)
  else
    player:setStorageValue(405789, 0)
  end
  --- Rarity Bonus ---
  if bonuses.rarityLoot and bonuses.rarityLoot > 0 then
    player:setStorageValue(405790, bonuses.rarityLoot)
  else
      player:setStorageValue(405790, 0)
  end

  player:updateClientStats()

end

local function getPlayerVocation(player)
  local cid = player:getVocation():getId()
  if cid == 4 or cid == 8 then
    return "knight"
  elseif cid == 3 or cid == 7 then
    return "paladin"
  elseif cid == 1 or cid == 5 then
    return "sorcerer"
  elseif cid == 2 or cid == 6 then
    return "druid"
  elseif cid == 9 or cid == 10 then
    return "illusionist"
  elseif cid == 11 or cid == 12 then
    return "monk"
  end
  return nil
end

local START_NODES = {
  [1] = true,
  [2] = true,
  [3] = true,
  [4] = true,
  [5] = true,
  [6] = true,
  [7] = true,
}

local function applyStartNodes(data)
  for nodeId in pairs(START_NODES) do
    data.nodes[nodeId] = true
  end
end

local function calculatePassiveBonuses(nodes, player)
  local bonuses = {}
  local vocation = getPlayerVocation(player)

  for nodeId, v in pairs(nodes or {}) do
    if type(nodeId) ~= "number" then
      if type(v) == "number" then
        nodeId = v
      else
        nodeId = nil
      end
    end

    if nodeId and treeData.nodes[nodeId] then

      local node = treeData.nodes[nodeId]
      local stats =
        (vocation and node[vocation] and (node[vocation].customStats or node[vocation].bonus))
        or node.customStats
        or node.bonus

      if stats then
        for statName, value in pairs(stats) do
          bonuses[statName] = (bonuses[statName] or 0) + value
        end
      end
    end
  end

  return bonuses
end

local function setPlayerBonuses(player, bonuses)
  local data = getPlayerData(player)
  data.bonuses = bonuses
end

local function hasPathToStart(nodeId, nodes)
  local visited = {}

  local function dfs(id)
    if visited[id] then return false end
    visited[id] = true

    if START_NODES[id] then
      return true
    end

    local node = treeData.nodes[id]
    if not node then return false end

    for _, parentId in ipairs(node.inputs or {}) do
      if nodes[parentId] and dfs(parentId) then
        return true
      end
    end

    return false
  end

  return dfs(nodeId)
end

local function saveActivePresetNodes(data)
    if not data.presets or not data.presets[data.preset] then
        return
    end

    data.presets[data.preset].nodes = {}
    for nodeId in pairs(data.nodes or {}) do
        table.insert(data.presets[data.preset].nodes, nodeId)
    end
    table.sort(data.presets[data.preset].nodes)
end

local function applyChanges(player)
    local data = getPlayerData(player)
    if not data or not data._loaded then
        return
    end

    saveActivePresetNodes(data)

    local bonuses = calculatePassiveBonuses(data.nodes, player)
    setPlayerBonuses(player, bonuses)
    applyBonusesToPlayer(player, bonuses)
    savePlayerPassiveTree(player)
end

local function resetPlayerPreset(player, preset)
  local data = getPlayerData(player)
  if not data.presets[preset] then
    return false
  end

  removeAllPassiveConditions(player)
  data.nodes = {}
  applyStartNodes(data)
  data.preset = preset
  setPlayerBonuses(player, {})
  applyBonusesToPlayer(player, {})
  savePlayerPassiveTree(player)

  return true
end

local function countAllocatedWithoutStart(nodes)
    local c = 0
    for id, enabled in pairs(nodes) do
        if enabled and not START_NODES[id] then
            c = c + 1
        end
    end
    return c
end

local function refundPlayerPassive(player)
    local data = getPlayerData(player)
    if not data or not data._loaded then
        return
    end

    local spent = 0
    for nodeId, enabled in pairs(data.nodes) do
        if enabled and not START_NODES[nodeId] then
            spent = spent + 1
        end
    end

    data.points = data.points + spent
    data.nodes = {}
    applyStartNodes(data)

    setPlayerBonuses(player, {})
    applyChanges(player)

    player:sendTextMessage(
        MESSAGE_INFO_DESCR,
        string.format("Refunded %d passive skill points.", spent)
    )
end

local function canAllocateNode(player, nodeId)
  local data = getPlayerData(player)
  local node = treeData.nodes[nodeId]
  if not node then
    return false
  end

  if data.nodes[nodeId] then
    return true
  end

  if (data.points or 0) <= 0 then
    return false
  end

  data.nodes[nodeId] = true
  local ok = hasPathToStart(nodeId, data.nodes)
  data.nodes[nodeId] = nil

  return ok
end

local function sendPassiveMessage(player, action, msgData)
  local packet = json.encode({ action = action, data = msgData })
  player:sendExtendedOpcode(65, packet)
end

local function sendRemainingPoints(player)
  local pdata = getPlayerData(player)
  local remaining = pdata.points
  if remaining < 0 then remaining = 0 end
  sendPassiveMessage(player, "sendPoints", remaining)
end


local function serializeNodes(nodeMap)
  local list = {}
  for id, _ in pairs(nodeMap) do
    table.insert(list, id)
  end
  return list
end

local function sendSyncTree(player)
  local pdata = getPlayerData(player)
  sendPassiveMessage(player, "syncTree", {
    nodes = serializeNodes(pdata.nodes),
    preset = pdata.preset,
    presetsTable = pdata.presets
  })
end

local function decodeImportedBuild(rawBuild)
    local build = trimString(rawBuild)
    if build == "" or #build > 7000 then
        return nil, "Invalid or empty passive tree import."
    end

    local ok, decoded = pcall(json.decode, build)
    if not ok or type(decoded) ~= "table" then
        return nil, "Invalid passive tree import format."
    end

    local nodes = decoded.nodes or decoded.nodeIds or decoded
    if type(nodes) ~= "table" then
        return nil, "Imported passive tree does not contain nodes."
    end

    local nodeMap = {}
    local importedCount = 0
    for _, rawNodeId in ipairs(nodes) do
        local nodeId = tonumber(rawNodeId)
        if not nodeId or not treeData.nodes[nodeId] then
            return nil, "Imported passive tree contains an unknown node."
        end

        if not nodeMap[nodeId] then
            nodeMap[nodeId] = true
            importedCount = importedCount + 1
        end
    end

    if importedCount == 0 then
        return nil, "Imported passive tree is empty."
    end

    return nodeMap, nil, sanitizePresetName(decoded.name, "Imported Build")
end

local function validateImportedBuild(player, importedNodes)
    local data = getPlayerData(player)
    if not data or not data._loaded then
        return false, "Passive tree is not loaded yet."
    end

    local newNodes = {}
    for nodeId in pairs(importedNodes) do
        newNodes[nodeId] = true
    end
    applyStartNodes({ nodes = newNodes })

    for nodeId in pairs(newNodes) do
        if not START_NODES[nodeId] and not hasPathToStart(nodeId, newNodes) then
            return false, "Imported passive tree has disconnected nodes."
        end
    end

    local availablePoints = (data.points or 0) + countAllocatedWithoutStart(data.nodes or {})
    local requiredPoints = countAllocatedWithoutStart(newNodes)
    if requiredPoints > availablePoints then
        return false, string.format("This build requires %d passive points, but you only have %d.", requiredPoints, availablePoints)
    end

    return true, newNodes, availablePoints, requiredPoints
end

local function presetHasAllocatedNodes(preset)
    if type(preset) ~= "table" then
        return false
    end

    for _, nodeId in ipairs(collectNodeIds(preset.nodes)) do
        if not START_NODES[nodeId] then
            return true
        end
    end

    return false
end

local function findAvailableImportPreset(data)
    for i = 1, PASSIVE_PRESET_LIMIT do
        if data.presets[i] and not presetHasAllocatedNodes(data.presets[i]) then
            return i
        end
    end

    return nil
end

local function buildNodeMapFromPreset(preset)
    local nodes = {}
    for _, nodeId in ipairs(collectNodeIds(preset and preset.nodes)) do
        nodes[nodeId] = true
    end
    applyStartNodes({ nodes = nodes })
    return nodes
end

local function switchPreset(player, presetId)
    local data = getPlayerData(player)
    presetId = tonumber(presetId)

    if not presetId or presetId < 1 or presetId > PASSIVE_PRESET_LIMIT or not data.presets[presetId] then
        sendPassiveMessage(player, "sendMessage", {
            title = "Switch Failed",
            message = "Invalid preset slot."
        })
        return true
    end

    if presetId == data.preset then
        sendSyncTree(player)
        return true
    end

    saveActivePresetNodes(data)

    local newNodes = buildNodeMapFromPreset(data.presets[presetId])
    local totalPoints = (data.points or 0) + countAllocatedWithoutStart(data.nodes or {})
    local requiredPoints = countAllocatedWithoutStart(newNodes)

    if requiredPoints > totalPoints then
        sendPassiveMessage(player, "sendMessage", {
            title = "Switch Failed",
            message = string.format("Preset %d requires %d passive points, but you only have %d.", presetId, requiredPoints, totalPoints)
        })
        return true
    end

    data.preset = presetId
    data.nodes = newNodes
    data.points = totalPoints - requiredPoints

    applyChanges(player)
    sendSyncTree(player)
    sendRemainingPoints(player)

    sendPassiveMessage(player, "sendMessage", {
        title = "Preset Switched",
        message = "Switched to " .. data.presets[presetId].name .. "."
    })

    return true
end

local function importPassiveBuild(player, rawBuild)
    local importedNodes, decodeError, buildName = decodeImportedBuild(rawBuild)
    if not importedNodes then
        sendPassiveMessage(player, "sendMessage", {
            title = "Import Failed",
            message = decodeError
        })
        return true
    end

    local data = getPlayerData(player)
    local targetPreset = findAvailableImportPreset(data)
    if not targetPreset then
        sendPassiveMessage(player, "sendMessage", {
            title = "Import Failed",
            message = "No empty preset slot is available. Reset or clear a preset before importing a new build."
        })
        return true
    end

    local ok, newNodes, availablePoints, requiredPoints = validateImportedBuild(player, importedNodes)
    if not ok then
        sendPassiveMessage(player, "sendMessage", {
            title = "Import Failed",
            message = newNodes
        })
        return true
    end

    saveActivePresetNodes(data)
    data.preset = targetPreset
    data.presets[targetPreset].name = buildName
    data.nodes = newNodes
    data.points = availablePoints - requiredPoints

    applyChanges(player)
    sendSyncTree(player)
    sendRemainingPoints(player)

    sendPassiveMessage(player, "sendMessage", {
        title = "Build Imported",
        message = string.format("Passive tree imported into preset %d and saved. Used %d passive points.", targetPreset, requiredPoints)
    })

    return true
end

local function renamePreset(player, presetId, name)
    local data = getPlayerData(player)
    presetId = tonumber(presetId) or data.preset

    if presetId < 1 or presetId > PASSIVE_PRESET_LIMIT or not data.presets[presetId] then
        sendPassiveMessage(player, "sendMessage", {
            title = "Rename Failed",
            message = "Invalid preset slot."
        })
        return true
    end

    data.presets[presetId].name = sanitizePresetName(name, "Preset " .. presetId)
    savePlayerPassiveTree(player)
    sendSyncTree(player)

    sendPassiveMessage(player, "sendMessage", {
        title = "Preset Renamed",
        message = "Preset " .. presetId .. " renamed to \"" .. data.presets[presetId].name .. "\"."
    })

    return true
end

local passiveTree = CreatureEvent("PassiveTreeSkillExtended")

function passiveTree.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= 65 then
    return false
  end

  local data = json.decode(buffer)
  if not data then
    print("Passive Tree Server: JSON error on buffer: " .. buffer)
    return false
  end

  local action = data.action
  local d = data.data

  if action == "requestPoints" then
    local pdata = getPlayerData(player)
    sendPassiveMessage(player, "sendPoints", pdata.points)
  elseif action == "requestNodesUnlocked" then
    local pdata = getPlayerData(player)
    sendPassiveMessage(player, "sendNodes", {
      nodes = serializeNodes(pdata.nodes),
      preset = pdata.preset,
      presetsTable = pdata.presets
    })
  elseif action == "toggleNode" then
    local nodeId = tonumber(d.nodeId)
    local pid = player:getGuid()
    local now = os.clock()
    if nodeId == 1 then
        return true
    end
    if lastToggle[pid] and (now - lastToggle[pid] < 0.2) then
        return true
    end
    lastToggle[pid] = now

    if not nodeId then
        return true
    end

    local pdata = getPlayerData(player)
    if not pdata._loaded then
        return true
    end

    if pdata.nodes[nodeId] then
        sendPassiveMessage(player, "sendMessage", {
            title = "Cannot Deallocate",
            message = "Nodes cannot be individually deallocated. Use the Reset button to reset your entire tree."
        })
        sendSyncTree(player)
        return true
    else
        if not canAllocateNode(player, nodeId) then
            sendSyncTree(player)
            return true
        end

        sendPassiveMessage(player, "requestConfirmation", {
            nodeId = nodeId,
            message = "This node allocation is permanent until you reset your entire tree. Continue?",
            cost = "1 passive point"
        })
    end
  elseif action == "refund" then
    local level = player:getLevel()
    local cost = level * 250

    local pdata = getPlayerData(player)
    local used = countAllocatedWithoutStart(pdata.nodes)

    if used == 0 then
        sendPassiveMessage(player, "sendMessage", {
            title = "No Nodes Allocated",
            message = "You haven't allocated any nodes to reset."
        })
        return true
    end

    if player:getMoney() < cost then
        sendPassiveMessage(player, "sendMessage", {
            title = "Reset Failed",
            message = "You need " .. cost .. " gold to reset your tree."
        })
    else
        player:removeMoney(cost)
        refundPlayerPassive(player)
  
        sendPassiveMessage(player, "sendMessage", {
            title = "Tree Reset",
            message = "Your tree was reset and you spent " .. cost .. " gold. Refunded " .. used .. " passive points."
        })
        sendSyncTree(player)
        sendRemainingPoints(player)
    end
  elseif action == "confirmAllocate" then
    local nodeId = tonumber(d.nodeId)
    local pid = player:getGuid()

    local pdata = getPlayerData(player)
    if not pdata or not pdata._loaded then
        return true
    end

    if pdata.nodes[nodeId] then
        return true
    end

    if not canAllocateNode(player, nodeId) then
        sendSyncTree(player)
        return true
    end

    pdata.nodes[nodeId] = true
    pdata.points = pdata.points - 1
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Node permanently allocated. -1 passive point.")

    applyChanges(player)
    sendSyncTree(player)
    sendRemainingPoints(player)
  elseif action == "importBuild" then
    return importPassiveBuild(player, d and d.build)
  elseif action == "renamePreset" then
    return renamePreset(player, d and d.preset, d and d.name)
  elseif action == "switchPreset" then
    return switchPreset(player, d and d.preset)
  elseif action == "resetPreset" then
    local level = player:getLevel()
    local cost = level * 250
    local pdata = getPlayerData(player)
    local used = countAllocatedWithoutStart(pdata.nodes)

    if used == 0 then
        local presetId = tonumber(d) or tonumber(d.preset)
        resetPlayerPreset(player, presetId)
        sendPassiveMessage(player, "sendMessage", {
            title = "Preset Switched",
            message = "Switched to preset " .. presetId .. "."
        })
    else
        if player:getMoney() < cost then
            sendPassiveMessage(player, "sendMessage", {
                title = "Reset Failed",
                message = "You need " .. cost .. " gold to reset your current tree before switching presets."
            })
        else
            player:removeMoney(cost)
            local presetId = tonumber(d) or tonumber(d.preset)
            resetPlayerPreset(player, presetId)
            sendPassiveMessage(player, "sendMessage", {
                title = "Preset Reset",
                message = "Your tree was reset and you spent " .. cost .. " gold. Switched to preset " .. presetId .. "."
            })
        end
    end
    sendSyncTree(player)
    sendRemainingPoints(player)
  else
    print("Passive Tree Server: Unknown action: " .. tostring(action))
  end

  return true
end

passiveTree:type("extendedopcode")
passiveTree:register()

local LoginEvent = CreatureEvent("PassiveTreeSkill")

function LoginEvent.onLogin(player)
  loadPlayerPassiveTree(player)
  player:registerEvent("PassiveTreeSkillExtended")
  player:registerEvent("PassiveTreeSkillLogout")
  addEvent(function() 
    local data = getPlayerData(player)
    local bonuses = calculatePassiveBonuses(data.nodes, player)
    applyStartNodes(data)
    setPlayerBonuses(player, bonuses)
    sendRemainingPoints(player)
    applyBonusesToPlayer(player, bonuses)
  end, 500)
  return true
end


LoginEvent:type("login")
LoginEvent:register()

--- ONLOGIN EVENT for SERVERS that are already started with players above level 100 and players are missing passive points, remove the login above and uncomment this one (SHIFT+ALT+A)
--[[ local LoginEvent = CreatureEvent("PassiveTreeSkill")

local PASSIVE_TREE_POINTS_GRANTED = 977600

function LoginEvent.onLogin(player)
  loadPlayerPassiveTree(player)
  player:registerEvent("PassiveTreeSkillExtended")

  addEvent(function()
    local level = player:getLevel()
    local data = getPlayerData(player)

    if player:getStorageValue(PASSIVE_TREE_POINTS_GRANTED) < 1 then
      if level >= 100 then
        local expectedPoints = math.min(250, level) - 100
        local actualPoints = data.points + (#data.nodes or 0)
        local missing = expectedPoints - actualPoints
        if missing > 0 then
          data.points = data.points + missing
          player:sendTextMessage(MESSAGE_INFO_DESCR,
            string.format("You were granted %d missing passive point%s based on your current level.",
              missing, missing > 1 and "s" or ""))
        end
      end
      player:setStorageValue(PASSIVE_TREE_POINTS_GRANTED, 1)
    end
    local bonuses = calculatePassiveBonuses(data.nodes, player)
    setPlayerBonuses(player, bonuses)
    applyBonusesToPlayer(player, bonuses)
  end, 500)
  return true
end

LoginEvent:type("login")
LoginEvent:register() ]]

local LogoutEvent = CreatureEvent("PassiveTreeSkillLogout")

function LogoutEvent.onLogout(player)
  savePlayerPassiveTree(player)
  return true
end

LogoutEvent:type("logout")
LogoutEvent:register()

---- Give 1 point on level 100, until level 250, for a total of 150 points, that is really good for a RPG server.
local levelAdvancePassive = CreatureEvent("PassiveAdvanceLevel")

function levelAdvancePassive.onAdvance(player, skill, oldLevel, newLevel)
  if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
    return true
  end

  if newLevel < 100 or oldLevel >= 250 then
    return true
  end

  local fromLvl = math.max(oldLevel + 1, 100)
  local toLvl   = math.min(newLevel, 250)
  local gained  = toLvl - fromLvl + 1

  if gained <= 0 then
    return true
  end

  local data = getPlayerData(player)
  if not data or not data.nodes then
    return true
  end

  data.points = data.points + gained

  sendRemainingPoints(player)
  sendSyncTree(player)

  player:sendTextMessage(MESSAGE_INFO_DESCR,
    string.format("You received %d passive skill point%s for leveling from %d to %d.",
      gained, gained > 1 and "s" or "", oldLevel, newLevel)
  )

  addEvent(function()
    applyChanges(player)
    savePlayerPassiveTree(player)
  end, 150)

  return true
end

levelAdvancePassive:register()
