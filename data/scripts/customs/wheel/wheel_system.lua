print(">> [Wheel of Destiny] Loaded")
local WHEEL_OPCODE = 194
local WHEEL_TABLE = "player_wheel_destiny"
local WHEEL_DATA_VERSION = 3
local WHEEL_SLOT_COUNT = 36
local WHEEL_MAX_POINTS = 4000
local WHEEL_PRESET_LIMIT = 30
local WHEEL_GEM_LIMIT = 225
local WHEEL_CONDITION_SUBID = 994194
local WHEEL_SPELL_CONDITION_SUBID = 994195
local WHEEL_AVATAR_CONDITION_SUBID = 994196
local WHEEL_AVATAR_OUTFIT_SUBID = 994197
local WHEEL_CAPACITY_STORAGE = 930090
local WHEEL_MAX_REQUEST_BYTES = 32768
local WHEEL_SPELL_CONTEXT_MS = 2000
local WHEEL_AVATAR_DURATION_MS = 15000

local WHEEL_RESOURCE_STORAGES = {
  [81] = 930081, -- Lesser gem 
  [82] = 930082, -- Regular gem 
  [83] = 930083, -- Greater gem 
  [84] = 930084, -- Lesser fragments
  [85] = 930085  -- Greater fragments
}

-- Client IDs: Knight, Paladin, Sorcerer, Druid, Monk.
-- Illusionist/Arch Illusionist uses the Sorcerer ID
local WHEEL_VOCATION_BY_SERVER_ID = {
  [1] = 3, [5] = 3, [9] = 3, [10] = 3,
  [2] = 4, [6] = 4,
  [3] = 2, [7] = 2,
  [4] = 1, [8] = 1,
  [11] = 5, [12] = 5
}

local WHEEL_PROMOTED_VOCATIONS = {
  [5] = true, [6] = true, [7] = true, [8] = true, [10] = true, [12] = true
}

-- Gem items.
local WHEEL_GEM_ITEMS = {
  [1] = {27150, 27151, 27152}, -- Guardian (Knight)
  [2] = {27153, 27154, 27155}, -- Marksman (Paladin)
  [3] = {27156, 27157, 27158}, -- Sage (Sorcerer & Illusionist)
  [4] = {27159, 27160, 27161}, -- Mystic (Druid)
  [5] = {30913, 30914, 30915}  -- Spiritualist (Monk)
}

local WHEEL_REVEAL_COSTS = {
  [0] = {gold = 125000, resourceType = 81},
  [1] = {gold = 1000000, resourceType = 82},
  [2] = {gold = 6000000, resourceType = 83}
}

local WHEEL_ROTATE_COSTS = {
  [0] = 125000,
  [1] = 250000,
  [2] = 500000
}

local WHEEL_CLOCKWISE_AFFINITY = {
  [0] = 1,
  [1] = 3,
  [3] = 2,
  [2] = 0
}

local WHEEL_ENHANCE_COSTS = {
  [2] = {
    [0] = {gold = 2000000, fragments = 5, resourceType = 84},
    [1] = {gold = 5000000, fragments = 15, resourceType = 84},
    [2] = {gold = 30000000, fragments = 30, resourceType = 84}
  },
  [3] = {
    [0] = {gold = 5000000, fragments = 5, resourceType = 85},
    [1] = {gold = 12500000, fragments = 15, resourceType = 85},
    [2] = {gold = 75000000, fragments = 30, resourceType = 85}
  }
}

local WHEEL_GRADE_MULTIPLIER = {
  [0] = 1.0,
  [1] = 1.1,
  [2] = 1.2,
  [3] = 1.5
}

local WHEEL_REVELATION_DAMAGE_HEALING = {
  [0] = 0,
  [1] = 4,
  [2] = 9,
  [3] = 20
}

local WHEEL_SLOT_MAX = {
  200, 150, 100, 100, 150, 200, 150, 100, 75,
  75, 100, 150, 100, 75, 50, 50, 75, 100,
  100, 75, 50, 50, 75, 100, 150, 100, 75,
  75, 100, 150, 200, 150, 100, 100, 150, 200
}

local WHEEL_SLOT_DOMAIN = {}
local WHEEL_DOMAIN_SLOTS = {
  [0] = {15, 14, 9, 13, 8, 3, 7, 2, 1},
  [1] = {16, 10, 17, 4, 11, 18, 5, 12, 6},
  [2] = {21, 20, 27, 19, 26, 33, 25, 32, 31},
  [3] = {22, 23, 28, 24, 29, 34, 30, 35, 36}
}

for domain = 0, 3 do
  for _, slotId in ipairs(WHEEL_DOMAIN_SLOTS[domain]) do
    WHEEL_SLOT_DOMAIN[slotId] = domain
  end
end

local WHEEL_SLOT_DEDICATION = {
  "lifemana", "mitigation", "health", "mana", "health", "lifemana",
  "mitigation", "health", "mana", "capacity", "mana", "health",
  "health", "mana", "capacity", "mitigation", "capacity", "mana",
  "mitigation", "health", "mana", "health", "mitigation", "capacity",
  "capacity", "mitigation", "health", "mitigation", "capacity", "mana",
  "lifemana", "capacity", "mitigation", "capacity", "mana", "lifemana"
}

local WHEEL_ROOT_SLOTS = {[15] = true, [16] = true, [21] = true, [22] = true}

local WHEEL_SLOT_CONNECTIONS = {
  [1] = {2, 7},
  [2] = {3, 8, 7, 1},
  [3] = {8, 9, 4, 2},
  [4] = {3, 10, 11, 5},
  [5] = {4, 11, 12, 6},
  [6] = {12, 5},
  [7] = {8, 13, 2, 1},
  [8] = {14, 9, 13, 3, 7, 2},
  [9] = {14, 15, 10, 3, 8},
  [10] = {9, 16, 17, 4, 11},
  [11] = {10, 17, 4, 18, 5, 12},
  [12] = {11, 18, 5, 6},
  [13] = {8, 14, 19, 7},
  [14] = {9, 15, 20, 13, 8},
  [15] = {14, 9},
  [16] = {17, 10},
  [17] = {10, 16, 23, 18, 11},
  [18] = {17, 11, 24, 12},
  [19] = {13, 20, 26, 25},
  [20] = {21, 14, 27, 19, 26},
  [21] = {20, 27},
  [22] = {23, 28},
  [23] = {22, 28, 17, 24, 29},
  [24] = {23, 18, 29, 30},
  [25] = {19, 26, 32, 31},
  [26] = {27, 20, 19, 25, 32, 33},
  [27] = {21, 28, 20, 26, 33},
  [28] = {22, 23, 27, 29, 34},
  [29] = {23, 28, 24, 34, 30, 35},
  [30] = {24, 29, 35, 36},
  [31] = {25, 32},
  [32] = {26, 25, 33, 31},
  [33] = {27, 34, 26, 32},
  [34] = {28, 33, 29, 35},
  [35] = {29, 34, 30, 36},
  [36] = {30, 35}
}

local WHEEL_SKILL_SLOTS = {[4] = true, [14] = true, [23] = true, [33] = true}
local WHEEL_LIFE_LEECH_SLOTS = {[9] = true, [17] = true, [25] = true, [35] = true}
local WHEEL_MANA_LEECH_SLOTS = {[2] = true, [12] = true, [20] = true, [28] = true}

local WHEEL_VESSEL_SLOTS = {
  [0] = {{id = 15, quality = 0}, {id = 3, quality = 1}, {id = 7, quality = 2}},
  [1] = {{id = 10, quality = 0}, {id = 18, quality = 1}, {id = 5, quality = 2}},
  [2] = {{id = 27, quality = 0}, {id = 19, quality = 1}, {id = 32, quality = 2}},
  [3] = {{id = 22, quality = 0}, {id = 34, quality = 1}, {id = 30, quality = 2}}
}

local WHEEL_VOCATION_STEP = {
  [1] = {health = 3, mana = 1, capacity = 5},
  [2] = {health = 2, mana = 3, capacity = 4},
  [3] = {health = 1, mana = 6, capacity = 2},
  [4] = {health = 1, mana = 6, capacity = 2},
  [5] = {health = 2, mana = 2, capacity = 5}
}

local WHEEL_BASIC_SLOT_ONE_POOL = {
  3, 5, 6, 4, 30, 31, 37, 48, 38, 41, 39, 40,
  33, 34, 35, 36, 44, 45, 46, 47
}

local WHEEL_BASIC_SLOT_TWO_POOL = {3, 5, 6, 4, 0, 1, 7, 8}
for modifierId = 9, 30 do
  WHEEL_BASIC_SLOT_TWO_POOL[#WHEEL_BASIC_SLOT_TWO_POOL + 1] = modifierId
end

local WHEEL_VALID_BASIC_IDS = {}
local WHEEL_VALID_BASIC_SET = {}
for modifierId = 0, 31 do
  WHEEL_VALID_BASIC_IDS[#WHEEL_VALID_BASIC_IDS + 1] = modifierId
  WHEEL_VALID_BASIC_SET[modifierId] = true
end
for modifierId = 33, 41 do
  WHEEL_VALID_BASIC_IDS[#WHEEL_VALID_BASIC_IDS + 1] = modifierId
  WHEEL_VALID_BASIC_SET[modifierId] = true
end
for modifierId = 44, 48 do
  WHEEL_VALID_BASIC_IDS[#WHEEL_VALID_BASIC_IDS + 1] = modifierId
  WHEEL_VALID_BASIC_SET[modifierId] = true
end

local WHEEL_SUPREME_RANGE = {
  [1] = {6, 23},
  [2] = {24, 41},
  [3] = {42, 58},
  [4] = {59, 75},
  [5] = {76, 93}
}

local WHEEL_BASIC_RESISTANCE_EFFECTS = {
  [0] = {{"physical", 1}},
  [1] = {{"holy", 1}},
  [2] = {{"death", 1}},
  [3] = {{"fire", 2}},
  [4] = {{"earth", 2}},
  [5] = {{"ice", 2}},
  [6] = {{"energy", 2}},
  [7] = {{"holy", 1.5}, {"death", -1}},
  [8] = {{"death", 1.5}, {"holy", -1}},
  [9] = {{"fire", 1}, {"earth", 1}},
  [10] = {{"fire", 1}, {"ice", 1}},
  [11] = {{"fire", 1}, {"energy", 1}},
  [12] = {{"earth", 1}, {"ice", 1}},
  [13] = {{"earth", 1}, {"energy", 1}},
  [14] = {{"ice", 1}, {"energy", 1}},
  [15] = {{"fire", 3}, {"earth", -2}},
  [16] = {{"fire", 3}, {"ice", -2}},
  [17] = {{"fire", 3}, {"energy", -2}},
  [18] = {{"earth", 3}, {"fire", -2}},
  [19] = {{"earth", 3}, {"ice", -2}},
  [20] = {{"earth", 3}, {"energy", -2}},
  [21] = {{"ice", 3}, {"earth", -2}},
  [22] = {{"ice", 3}, {"fire", -2}},
  [23] = {{"ice", 3}, {"energy", -2}},
  [24] = {{"energy", 3}, {"earth", -2}},
  [25] = {{"energy", 3}, {"ice", -2}},
  [26] = {{"energy", 3}, {"fire", -2}},
  [27] = {{"manaDrain", 3}},
  [28] = {{"lifeDrain", 3}},
  [29] = {{"manaDrain", 1.5}, {"lifeDrain", 1.5}}
}

local WHEEL_HYBRID_ELEMENTS = {
  [33] = "fire", [34] = "energy", [35] = "earth", [36] = "ice",
  [38] = "fire", [39] = "energy", [40] = "earth", [41] = "ice",
  [44] = "fire", [45] = "energy", [46] = "earth", [47] = "ice"
}

local WHEEL_SUPREME_COOLDOWNS = {
  [6] = {spell = "avatar of steel", milliseconds = 900000},
  [7] = {spell = "executioners throw", milliseconds = 2000},
  [24] = {spell = "avatar of light", milliseconds = 900000},
  [25] = {spell = "divine dazzle", milliseconds = 4000},
  [36] = {spell = "divine empowerment", milliseconds = 6000},
  [37] = {spell = "divine grenade", milliseconds = 2000},
  [42] = {spell = "avatar of storm", milliseconds = 900000},
  [43] = {spell = "energy wave", milliseconds = 1000},
  [59] = {spell = "avatar of nature", milliseconds = 900000},
  [60] = {spell = "natures embrace", milliseconds = 5000},
  [76] = {spell = "avatar of balance", milliseconds = 900000},
  [88] = {spell = "focus serenity", milliseconds = 300000},
  [89] = {spell = "focus harmony", milliseconds = 30000}
}

local WHEEL_AVATAR_STAGE = {
  [1] = {damageReduction = 5, criticalDamage = 5, cooldown = 120 * 60 * 1000},
  [2] = {damageReduction = 10, criticalDamage = 10, cooldown = 90 * 60 * 1000},
  [3] = {damageReduction = 15, criticalDamage = 15, cooldown = 60 * 60 * 1000}
}

local WHEEL_AVATAR_CONFIG = {
  ["avatar of steel"] = {
    vocation = 1,
    effect = CONST_ME_MAGIC_GREEN,
    outfit = {lookType = 1104, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
  },
  ["avatar of light"] = {
    vocation = 2,
    effect = CONST_ME_HOLYAREA or CONST_ME_MAGIC_GREEN,
    outfit = {lookType = 1105, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
  },
  ["avatar of storm"] = {
    vocation = 3,
    effect = CONST_ME_ENERGYAREA or CONST_ME_MAGIC_GREEN,
    outfit = {lookType = 1106, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
  },
  ["avatar of nature"] = {
    vocation = 4,
    effect = CONST_ME_GREEN_RINGS or CONST_ME_MAGIC_GREEN,
    outfit = {lookType = 1107, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
  },
  ["avatar of balance"] = {
    vocation = 5,
    effect = CONST_ME_MAGIC_BLUE or CONST_ME_MAGIC_GREEN,
    outfit = {lookType = 1397, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0, lookMount = 0}
  }
}

local WHEEL_SUPREME_SPELL_EFFECTS = {
  [4] = {spell = "ultimate healing", healing = 5},
  [8] = {spell = "executioners throw", damage = 6},
  [9] = {spell = "executioners throw", critical = 12},
  [10] = {spell = "fierce berserk", damage = 5},
  [11] = {spell = "fierce berserk", critical = 8},
  [12] = {spell = "berserk", damage = 5},
  [13] = {spell = "berserk", critical = 12},
  [14] = {spell = "front sweep", damage = 8},
  [15] = {spell = "front sweep", critical = 12},
  [16] = {spell = "groundshaker", damage = 6.5},
  [17] = {spell = "groundshaker", critical = 12},
  [18] = {spell = "annihilation", damage = 12},
  [19] = {spell = "annihilation", critical = 15},
  [20] = {spell = "fair wound cleansing", healing = 10},
  [26] = {spell = "divine grenade", damage = 6},
  [27] = {spell = "divine grenade", critical = 12},
  [28] = {spell = "divine caldera", damage = 5},
  [29] = {spell = "divine caldera", critical = 8},
  [30] = {spell = "divine missile", damage = 8},
  [31] = {spell = "divine missile", critical = 12},
  [32] = {spell = "ethereal spear", damage = 10},
  [33] = {spell = "ethereal spear", critical = 15},
  [34] = {spell = "strong ethereal spear", damage = 8},
  [35] = {spell = "strong ethereal spear", critical = 12},
  [38] = {spell = "salvation", healing = 6},
  [44] = {spell = "grand death beam", damage = 10},
  [45] = {spell = "grand death beam", critical = 15},
  [46] = {spell = "hells core", damage = 8},
  [47] = {spell = "hells core", critical = 12},
  [48] = {spell = "energy wave", damage = 5},
  [49] = {spell = "energy wave", critical = 12},
  [50] = {spell = "great fire wave", damage = 5},
  [51] = {spell = "great fire wave", critical = 8},
  [52] = {spell = "rage of the skies", damage = 8},
  [53] = {spell = "rage of the skies", critical = 12},
  [54] = {spell = "great energy beam", damage = 10},
  [55] = {spell = "great energy beam", critical = 15},
  [61] = {spell = "terra burst", damage = 7},
  [62] = {spell = "terra burst", critical = 12},
  [63] = {spell = "ice burst", damage = 7},
  [64] = {spell = "ice burst", critical = 12},
  [65] = {spell = "eternal winter", damage = 8},
  [66] = {spell = "eternal winter", critical = 12},
  [67] = {spell = "terra wave", damage = 5},
  [68] = {spell = "terra wave", critical = 12},
  [69] = {spell = "strong ice wave", damage = 8},
  [70] = {spell = "strong ice wave", critical = 15},
  [71] = {spell = "heal friend", healing = 5},
  [72] = {spell = "mass healing", healing = 5},
  [77] = {spell = "spirit mend", healing = 6},
  [78] = {spell = "spiritual outburst", damage = 5},
  [79] = {spell = "spiritual outburst", critical = 8},
  [80] = {spell = "forceful uppercut", damage = 10},
  [81] = {spell = "forceful uppercut", critical = 8},
  [82] = {spell = "furry of blows", damage = 6.5},
  [83] = {spell = "furry of blows", critical = 8},
  [84] = {spell = "greater furry of blows", damage = 5},
  [85] = {spell = "greater furry of blows", critical = 8},
  [86] = {spell = "sweeping takedown", damage = 5},
  [87] = {spell = "sweeping takedown", critical = 8},
  [90] = {spell = "mass spirit mend", healing = 5}
}

local WHEEL_RUNTIME = {}

local function clampInteger(value, minimum, maximum, fallback)
  local number = tonumber(value)
  if not number or number ~= number then
    return fallback
  end
  number = math.floor(number)
  if number < minimum then
    return minimum
  end
  if number > maximum then
    return maximum
  end
  return number
end

local function shallowArray(size, value)
  local array = {}
  for index = 1, size do
    array[index] = value
  end
  return array
end

local function copyArray(source, size, fallback)
  local target = {}
  for index = 1, size do
    target[index] = source[index]
    if target[index] == nil then
      target[index] = fallback
    end
  end
  return target
end

local function trimString(value)
  return tostring(value or ""):match("^%s*(.-)%s*$") or ""
end

local function sanitizePresetName(value, fallback)
  local name = trimString(value)
  if name == "" then
    name = fallback or "Preset"
  end
  name = name:gsub("[%c]", " ")
  return name:sub(1, 30)
end

local function randomFrom(list)
  return list[math.random(1, #list)]
end

local function listToSet(list)
  local set = {}
  for _, value in ipairs(list) do
    set[value] = true
  end
  return set
end

local WHEEL_SPELL_NAME_ALIASES = {
  ["great death beam"] = "grand death beam",
  ["flurry of blows"] = "furry of blows",
  ["greater flurry of blows"] = "greater furry of blows"
}

local function normalizeSpellName(value)
  local name = tostring(value or ""):lower()
  name = name:gsub("'", ""):gsub("’", "")
  name = name:gsub("[^%w%s]", " "):gsub("%s+", " ")
  name = name:match("^%s*(.-)%s*$") or ""
  return WHEEL_SPELL_NAME_ALIASES[name] or name
end

local function getNowMilliseconds()
  if os.mtime then
    return os.mtime()
  end
  return os.time() * 1000
end

local function getServerVocationId(player)
  local vocation = player and player:getVocation()
  if not vocation then
    return 0
  end
  return tonumber(vocation:getId()) or 0
end

local function getWheelVocation(player)
  return WHEEL_VOCATION_BY_SERVER_ID[getServerVocationId(player)] or 0
end

local function getSupremePool(vocation)
  local pool = {0, 1, 2, 3, 5}
  if vocation == 3 or vocation == 4 then
    pool[#pool + 1] = 4
  end
  local range = WHEEL_SUPREME_RANGE[vocation]
  if range then
    for modifierId = range[1], range[2] do
      pool[#pool + 1] = modifierId
    end
  end
  return pool
end

local function isWheelEligible(player)
  if getWheelVocation(player) == 0 then
    return false
  end
  if player:getLevel() <= 50 then
    return false
  end
  if not player:isPremium() then
    return false
  end
  return WHEEL_PROMOTED_VOCATIONS[getServerVocationId(player)] == true
end

local function isPlayerInsideTemple(player)
  local position = player:getPosition()
  local tile = Tile(position)
  if not tile or not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
    return false
  end

  local towns = nil
  if Game.getTowns then
    towns = Game.getTowns()
  end
  if type(towns) ~= "table" or next(towns) == nil then
    towns = {player:getTown()}
  end

  for _, town in pairs(towns) do
    if town then
      local temple = town:getTemplePosition()
      if temple and position.z == temple.z and math.abs(position.x - temple.x) <= 1 and math.abs(position.y - temple.y) <= 10 then
        return true
      end
    end
  end
  return false
end

local function getWheelState(player)
  if not isWheelEligible(player) then
    return 0
  end
  return isPlayerInsideTemple(player) and 1 or 2
end

local function getStorageCount(player, storageKey)
  local value = tonumber(player:getStorageValue(storageKey)) or -1
  return math.max(0, value)
end

local function setStorageCount(player, storageKey, value)
  player:setStorageValue(storageKey, math.max(0, math.floor(tonumber(value) or 0)))
end

local function getGemResourceItem(player, resourceType)
  if resourceType < 81 or resourceType > 83 then
    return nil
  end
  local vocationItems = WHEEL_GEM_ITEMS[getWheelVocation(player)]
  return vocationItems and vocationItems[resourceType - 80] or nil
end

local function getWheelResourceCount(player, resourceType)
  if resourceType == 0 then
    return math.max(0, tonumber(player:getTotalMoney()) or 0)
  end

  local itemId = getGemResourceItem(player, resourceType)
  if itemId then
    return math.max(0, tonumber(player:getItemCount(itemId)) or 0)
  end

  local storageKey = WHEEL_RESOURCE_STORAGES[resourceType]
  if storageKey then
    return getStorageCount(player, storageKey)
  end
  return 0
end

local function getWheelResources(player)
  local resources = {}
  local resourceTypes = {0, 81, 82, 83, 84, 85}
  for _, resourceType in ipairs(resourceTypes) do
    resources[#resources + 1] = {
      type = resourceType,
      value = getWheelResourceCount(player, resourceType)
    }
  end
  return resources
end

local function consumeWheelResource(player, resourceType, amount)
  amount = math.max(0, math.floor(tonumber(amount) or 0))
  if amount == 0 then
    return true
  end
  if getWheelResourceCount(player, resourceType) < amount then
    return false
  end

  if resourceType == 0 then
    return player:removeTotalMoney(amount)
  end

  local itemId = getGemResourceItem(player, resourceType)
  if itemId then
    return player:removeItem(itemId, amount)
  end

  local storageKey = WHEEL_RESOURCE_STORAGES[resourceType]
  if not storageKey then
    return false
  end
  setStorageCount(player, storageKey, getStorageCount(player, storageKey) - amount)
  return true
end

local function refundWheelResource(player, resourceType, amount)
  amount = math.max(0, math.floor(tonumber(amount) or 0))
  if amount == 0 then
    return true
  end

  if resourceType == 0 then
    player:setBankBalance(player:getBankBalance() + amount)
    return true
  end

  local itemId = getGemResourceItem(player, resourceType)
  if itemId then
    return player:addItem(itemId, amount, true) ~= nil
  end

  local storageKey = WHEEL_RESOURCE_STORAGES[resourceType]
  if not storageKey then
    return false
  end
  setStorageCount(player, storageKey, getStorageCount(player, storageKey) + amount)
  return true
end

local function newWheelData()
  return {
    version = WHEEL_DATA_VERSION,
    slots = shallowArray(WHEEL_SLOT_COUNT, 0),
    activeGems = shallowArray(4, -1),
    revealedGems = {},
    basicGrades = shallowArray(49, 0),
    supremeGrades = shallowArray(94, 0),
    presets = {},
    nextGemIndex = 1
  }
end

local function importGradeData(target, source, maximumId)
  if type(source) ~= "table" then
    return
  end

  local hasRecords = false
  for _, entry in pairs(source) do
    if type(entry) == "table" and entry.bonusId ~= nil then
      hasRecords = true
      local modifierId = clampInteger(entry.bonusId, 0, maximumId, -1)
      if modifierId >= 0 then
        target[modifierId + 1] = clampInteger(entry.grade, 0, 3, 0)
      end
    end
  end
  if hasRecords then
    return
  end

  for key, value in pairs(source) do
    local numericKey = tonumber(key)
    if numericKey then
      local modifierId = numericKey
      if source[1] ~= nil and source[0] == nil and numericKey >= 1 then
        modifierId = numericKey - 1
      end
      modifierId = clampInteger(modifierId, 0, maximumId, -1)
      if modifierId >= 0 then
        target[modifierId + 1] = clampInteger(value, 0, 3, 0)
      end
    end
  end
end

local function normalizeActiveGems(target, source)
  if type(source) ~= "table" then
    return
  end

  local foundRecords = false
  for key, entry in pairs(source) do
    if type(entry) == "table" and (entry.affinity ~= nil or entry.index ~= nil or entry.gemIndex ~= nil or entry.gemID ~= nil) then
      foundRecords = true
      local numericKey = tonumber(key)
      local fallbackAffinity = -1
      if numericKey then
        if numericKey >= 0 and numericKey <= 3 and source[0] ~= nil then
          fallbackAffinity = numericKey
        elseif numericKey >= 1 and numericKey <= 4 then
          fallbackAffinity = numericKey - 1
        end
      end
      local affinity = clampInteger(entry.affinity, 0, 3, fallbackAffinity)
      if affinity >= 0 then
        target[affinity + 1] = clampInteger(entry.index or entry.gemIndex or entry.gemID, -1, 2147483647, -1)
      end
    end
  end
  if foundRecords then
    return
  end

  local zeroBased = source[0] ~= nil or source["0"] ~= nil
  for affinity = 0, 3 do
    local value = nil
    if zeroBased then
      value = source[affinity]
      if value == nil then
        value = source[tostring(affinity)]
      end
    else
      value = source[affinity + 1]
      if value == nil then
        value = source[tostring(affinity + 1)]
      end
    end
    target[affinity + 1] = clampInteger(value, -1, 2147483647, -1)
  end
end

local function normalizePresetSlots(source)
  local slots = {}
  local used = 0
  source = type(source) == "table" and source or {}
  for slotId = 1, WHEEL_SLOT_COUNT do
    local value = source[slotId]
    if value == nil then
      value = source[tostring(slotId)]
    end
    value = clampInteger(value, 0, WHEEL_SLOT_MAX[slotId], 0)
    slots[slotId] = value
    used = used + value
  end
  return slots, used
end

local function normalizePresetGems(source)
  local gems = shallowArray(4, -1)
  normalizeActiveGems(gems, source)
  return gems
end

local function normalizeWheelPreset(source, fallbackName, vocation)
  if type(source) ~= "table" then
    return nil
  end

  local slots, usedPoints = normalizePresetSlots(source.slots or source.pointInvested)
  if usedPoints > WHEEL_MAX_POINTS then
    return nil
  end

  return {
    presetName = sanitizePresetName(source.presetName or source.name, fallbackName),
    vocation = clampInteger(source.vocation, 1, 5, vocation or 1),
    maxPoints = math.min(WHEEL_MAX_POINTS, math.max(usedPoints, clampInteger(source.maxPoints, 0, WHEEL_MAX_POINTS, usedPoints))),
    usedPoints = usedPoints,
    slots = slots,
    gems = normalizePresetGems(source.gems or source.equippedGems or source.equipedGems)
  }
end

local function normalizeWheelPresets(source, vocation)
  local presets = {}
  if type(source) ~= "table" then
    return presets
  end

  local seenNames = {}
  for _, rawPreset in pairs(source) do
    if #presets >= WHEEL_PRESET_LIMIT then
      break
    end
    local preset = normalizeWheelPreset(rawPreset, "Preset " .. (#presets + 1), vocation)
    if preset and preset.presetName ~= "" and preset.vocation == vocation then
      local loweredName = preset.presetName:lower()
      if not seenNames[loweredName] then
        seenNames[loweredName] = true
        presets[#presets + 1] = preset
      end
    end
  end
  table.sort(presets, function(left, right)
    return left.presetName:lower() < right.presetName:lower()
  end)
  return presets
end

local function serializeWheelPresets(presets)
  local serialized = {}
  for _, preset in ipairs(type(presets) == "table" and presets or {}) do
    serialized[#serialized + 1] = {
      presetName = sanitizePresetName(preset.presetName or preset.name, "Preset " .. (#serialized + 1)),
      vocation = clampInteger(preset.vocation, 1, 5, 1),
      maxPoints = clampInteger(preset.maxPoints, 0, WHEEL_MAX_POINTS, 0),
      usedPoints = clampInteger(preset.usedPoints, 0, WHEEL_MAX_POINTS, 0),
      slots = copyArray(preset.slots or {}, WHEEL_SLOT_COUNT, 0),
      gems = copyArray(preset.gems or {}, 4, -1)
    }
  end
  return serialized
end

local function getFirstDifferentBasicModifier(firstAttribute)
  for _, modifierId in ipairs(WHEEL_BASIC_SLOT_TWO_POOL) do
    if modifierId ~= firstAttribute then
      return modifierId
    end
  end
  return 3
end

local function normalizeWheelData(decoded, vocation)
  local data = newWheelData()
  if type(decoded) ~= "table" then
    return data, true
  end

  local changed = tonumber(decoded.version) ~= WHEEL_DATA_VERSION
  local slots = type(decoded.slots) == "table" and decoded.slots or {}
  for slotId = 1, WHEEL_SLOT_COUNT do
    local normalized = clampInteger(slots[slotId], 0, WHEEL_SLOT_MAX[slotId], 0)
    data.slots[slotId] = normalized
    if normalized ~= tonumber(slots[slotId]) then
      changed = true
    end
  end

  normalizeActiveGems(data.activeGems, decoded.activeGems)
  data.presets = normalizeWheelPresets(decoded.presets, vocation)
  importGradeData(data.basicGrades, decoded.basicGrades or decoded.lesserFragments, 48)
  importGradeData(data.supremeGrades, decoded.supremeGrades or decoded.greaterFragments, 93)

  for modifierId = 0, 48 do
    if not WHEEL_VALID_BASIC_SET[modifierId] then
      data.basicGrades[modifierId + 1] = 0
    end
  end

  local supremePool = getSupremePool(vocation)
  local supremeSet = listToSet(supremePool)
  local usedIndexes = {}
  local nextIndex = 1
  local revealed = type(decoded.revealedGems) == "table" and decoded.revealedGems or {}
  for _, sourceGem in ipairs(revealed) do
    if #data.revealedGems >= WHEEL_GEM_LIMIT then
      changed = true
      break
    end
    if type(sourceGem) == "table" then
      local quality = clampInteger(sourceGem.quality or sourceGem.gemType, 0, 2, 0)
      local index = clampInteger(sourceGem.index or sourceGem.gemID, 1, 2147483647, nextIndex)
      while usedIndexes[index] do
        index = index + 1
        changed = true
      end
      usedIndexes[index] = true
      nextIndex = math.max(nextIndex, index + 1)

      local firstAttribute = clampInteger(sourceGem.firstAttribute or sourceGem.lesserBonus, 0, 48, 3)
      if not listToSet(WHEEL_BASIC_SLOT_ONE_POOL)[firstAttribute] then
        firstAttribute = 3
        changed = true
      end

      local gem = {
        index = index,
        affinity = clampInteger(sourceGem.affinity or sourceGem.gemDomain, 0, 3, 0),
        quality = quality,
        locked = (sourceGem.locked == true or tonumber(sourceGem.locked) == 1) and 1 or 0,
        firstAttribute = firstAttribute
      }

      if quality >= 1 then
        local secondAttribute = clampInteger(sourceGem.secondAttribute or sourceGem.regularBonus, 0, 48, -1)
        local secondAllowed = listToSet(WHEEL_BASIC_SLOT_TWO_POOL)
        if secondAttribute < 0 or not secondAllowed[secondAttribute] or secondAttribute == firstAttribute then
          secondAttribute = getFirstDifferentBasicModifier(firstAttribute)
          changed = true
        end
        gem.secondAttribute = secondAttribute
      end

      if quality >= 2 then
        local thirdAttribute = clampInteger(sourceGem.thirdAttribute or sourceGem.supremeBonus, 0, 93, -1)
        if thirdAttribute < 0 or not supremeSet[thirdAttribute] then
          thirdAttribute = supremePool[1] or 0
          changed = true
        end
        gem.thirdAttribute = thirdAttribute
      end
      data.revealedGems[#data.revealedGems + 1] = gem
    end
  end

  data.nextGemIndex = math.max(nextIndex, clampInteger(decoded.nextGemIndex, 1, 2147483647, nextIndex))
  data.version = WHEEL_DATA_VERSION
  return data, changed
end

local function serializeWheelData(data)
  local serialized = {
    version = WHEEL_DATA_VERSION,
    slots = copyArray(data.slots, WHEEL_SLOT_COUNT, 0),
    activeGems = copyArray(data.activeGems, 4, -1),
    revealedGems = {},
    basicGrades = copyArray(data.basicGrades, 49, 0),
    supremeGrades = copyArray(data.supremeGrades, 94, 0),
    nextGemIndex = math.max(1, math.floor(tonumber(data.nextGemIndex) or 1))
  }

  for _, gem in ipairs(data.revealedGems or {}) do
    local copy = {
      index = gem.index,
      affinity = gem.affinity,
      quality = gem.quality,
      locked = gem.locked,
      firstAttribute = gem.firstAttribute
    }
    if gem.quality >= 1 then
      copy.secondAttribute = gem.secondAttribute
    end
    if gem.quality >= 2 then
      copy.thirdAttribute = gem.thirdAttribute
    end
    serialized.revealedGems[#serialized.revealedGems + 1] = copy
  end
  return serialized
end

local function savePlayerWheelData(player, data)
  local encodeOk, encoded = pcall(json.encode, serializeWheelData(data))
  if not encodeOk or type(encoded) ~= "string" then
    print(string.format("[Wheel] Could not encode data for player %d: %s", player:getGuid(), tostring(encoded)))
    return false
  end
  local presetsOk, encodedPresets = pcall(json.encode, serializeWheelPresets(data.presets))
  if not presetsOk or type(encodedPresets) ~= "string" then
    print(string.format("[Wheel] Could not encode presets for player %d: %s", player:getGuid(), tostring(encodedPresets)))
    return false
  end

  local escaped = db.escapeString(encoded)
  local escapedPresets = db.escapeString(encodedPresets)
  local query = string.format(
    "INSERT INTO `%s` (`player_id`, `data`, `presets`) VALUES (%d, %s, %s) ON DUPLICATE KEY UPDATE `data` = %s, `presets` = %s",
    WHEEL_TABLE, player:getGuid(), escaped, escapedPresets, escaped, escapedPresets
  )
  local ok, resultValue = pcall(db.query, query)
  if not ok or resultValue == false then
    print(string.format("[Wheel] Could not save data for player %d: %s", player:getGuid(), tostring(resultValue)))
    return false
  end
  return true
end

local function loadPlayerWheelData(player)
  local query = string.format("SELECT `data`, `presets` FROM `%s` WHERE `player_id` = %d", WHEEL_TABLE, player:getGuid())
  local queryOk, resultId = pcall(db.storeQuery, query)
  if not queryOk or not resultId then
    return newWheelData(), false
  end

  local raw = result.getDataString(resultId, "data")
  local rawPresets = result.getDataString(resultId, "presets")
  result.free(resultId)
  if not raw or raw == "" then
    return newWheelData(), false
  end

  local decodeOk, decoded = pcall(json.decode, raw)
  if not decodeOk or type(decoded) ~= "table" then
    print(string.format("[Wheel] Ignoring invalid JSON for player %d.", player:getGuid()))
    return newWheelData(), true
  end
  if rawPresets and rawPresets ~= "" then
    local presetsOk, decodedPresets = pcall(json.decode, rawPresets)
    if presetsOk and type(decodedPresets) == "table" then
      decoded.presets = decodedPresets
    end
  end
  return normalizeWheelData(decoded, getWheelVocation(player))
end

local function findGemByIndex(data, gemIndex)
  gemIndex = clampInteger(gemIndex, 1, 2147483647, -1)
  if gemIndex < 0 then
    return nil, nil
  end
  for position, gem in ipairs(data.revealedGems) do
    if gem.index == gemIndex then
      return gem, position
    end
  end
  return nil, nil
end

local function countGradeFourBonuses(data, vocation)
  local count = 0
  for _, modifierId in ipairs(WHEEL_VALID_BASIC_IDS) do
    if data.basicGrades[modifierId + 1] == 3 then
      count = count + 1
    end
  end
  for _, modifierId in ipairs(getSupremePool(vocation)) do
    if data.supremeGrades[modifierId + 1] == 3 then
      count = count + 1
    end
  end
  return math.min(69, count)
end

local function getWheelPoints(player, data)
  if not isWheelEligible(player) then
    return 0, 0, 0
  end
  local levelPoints = math.min(WHEEL_MAX_POINTS, math.max(0, player:getLevel() - 50))
  local extraPoints = math.min(
    countGradeFourBonuses(data, getWheelVocation(player)),
    math.max(0, WHEEL_MAX_POINTS - levelPoints)
  )
  return levelPoints + extraPoints, levelPoints, extraPoints
end

local function getUsedWheelPoints(slots)
  local used = 0
  for slotId = 1, WHEEL_SLOT_COUNT do
    used = used + (tonumber(slots[slotId]) or 0)
  end
  return used
end

local function validateWheelTopology(slots)
  local reachable = {}
  local queue = {}
  local queueIndex = 1

  for rootId in pairs(WHEEL_ROOT_SLOTS) do
    reachable[rootId] = true
    if slots[rootId] == WHEEL_SLOT_MAX[rootId] then
      queue[#queue + 1] = rootId
    end
  end

  while queueIndex <= #queue do
    local slotId = queue[queueIndex]
    queueIndex = queueIndex + 1
    for _, neighbourId in ipairs(WHEEL_SLOT_CONNECTIONS[slotId]) do
      if not reachable[neighbourId] then
        reachable[neighbourId] = true
        if slots[neighbourId] == WHEEL_SLOT_MAX[neighbourId] then
          queue[#queue + 1] = neighbourId
        end
      end
    end
  end

  for slotId = 1, WHEEL_SLOT_COUNT do
    if slots[slotId] > 0 and not reachable[slotId] then
      return false, string.format("Wheel slice %d is not connected to a root slice.", slotId)
    end
  end
  return true
end

local function normalizeRequestedSlots(source)
  if type(source) ~= "table" then
    return nil, "The wheel allocation is missing."
  end
  local slots = {}
  for slotId = 1, WHEEL_SLOT_COUNT do
    local value = tonumber(source[slotId])
    if not value or value ~= math.floor(value) or value < 0 or value > WHEEL_SLOT_MAX[slotId] then
      return nil, string.format("Invalid value for wheel slice %d.", slotId)
    end
    slots[slotId] = value
  end
  return slots
end

local function sanitizePersistedState(player, data)
  local changed = false
  local topologyOk = validateWheelTopology(data.slots)
  local points = getWheelPoints(player, data)
  if not topologyOk or getUsedWheelPoints(data.slots) > points then
    data.slots = shallowArray(WHEEL_SLOT_COUNT, 0)
    changed = true
  end

  local usedGemIndexes = {}
  for affinity = 0, 3 do
    local gemIndex = data.activeGems[affinity + 1]
    if gemIndex >= 0 then
      local gem = findGemByIndex(data, gemIndex)
      if not gem or gem.affinity ~= affinity or usedGemIndexes[gemIndex] then
        data.activeGems[affinity + 1] = -1
        changed = true
      else
        usedGemIndexes[gemIndex] = true
      end
    end
  end
  return changed
end

local function normalizeRequestedActiveGems(source)
  local active = shallowArray(4, -1)
  if type(source) ~= "table" then
    return active
  end
  normalizeActiveGems(active, source)
  return active
end

local function validateActiveGems(data, active)
  local used = {}
  for affinity = 0, 3 do
    local gemIndex = active[affinity + 1]
    if gemIndex >= 0 then
      local gem = findGemByIndex(data, gemIndex)
      if not gem then
        return false, "One of the selected gems no longer exists."
      end
      if gem.affinity ~= affinity then
        return false, "A gem can only be placed in a vessel of the same affinity."
      end
      if used[gemIndex] then
        return false, "The same gem cannot be placed in more than one vessel."
      end
      used[gemIndex] = true
    end
  end
  return true
end

local function isGemActive(data, gemIndex)
  for affinity = 0, 3 do
    if data.activeGems[affinity + 1] == gemIndex then
      return true
    end
  end
  return false
end

local function emptyRuntimeBonuses()
  return {
    health = 0,
    mana = 0,
    capacity = 0,
    mitigation = 0,
    melee = 0,
    distance = 0,
    magic = 0,
    fist = 0,
    lifeLeech = 0,
    manaLeech = 0,
    dodge = 0,
    criticalDamage = 0,
    damageHealing = 0,
    resistances = {
      physical = 0, holy = 0, death = 0, fire = 0, earth = 0,
      ice = 0, energy = 0, manaDrain = 0, lifeDrain = 0
    },
    vesselResonance = {0, 0, 0, 0},
    domainPoints = {0, 0, 0, 0},
    revelationStages = {0, 0, 0, 0},
    activeSupreme = {},
    avatar = nil,
    spellContext = nil,
    lifeLeechRemainder = 0,
    manaLeechRemainder = 0
  }
end

local function addResistance(bonuses, resistanceType, value)
  bonuses.resistances[resistanceType] = (bonuses.resistances[resistanceType] or 0) + value
end

local function applyBasicModifier(bonuses, modifierId, grade, vocation)
  local multiplier = WHEEL_GRADE_MULTIPLIER[grade] or 1.0
  local resistanceEffects = WHEEL_BASIC_RESISTANCE_EFFECTS[modifierId]
  if resistanceEffects then
    for _, effect in ipairs(resistanceEffects) do
      local value = effect[2]
      if value > 0 then
        value = value * multiplier
      end
      addResistance(bonuses, effect[1], value)
    end
    return
  end

  if modifierId == 30 then
    bonuses.mitigation = bonuses.mitigation + (5 * multiplier)
    return
  end

  local steps = WHEEL_VOCATION_STEP[vocation] or WHEEL_VOCATION_STEP[1]
  local pureHealth = steps.health * 100
  local pureMana = steps.mana * 100
  local pureCapacity = (vocation == 5 and 4 or steps.capacity) * 100

  if modifierId == 31 then
    bonuses.health = bonuses.health + math.floor(pureHealth * multiplier)
  elseif modifierId == 37 then
    bonuses.mana = bonuses.mana + math.floor(pureMana * multiplier)
  elseif modifierId == 48 then
    bonuses.capacity = bonuses.capacity + math.floor(pureCapacity * multiplier)
  elseif modifierId >= 33 and modifierId <= 36 then
    bonuses.mana = bonuses.mana + math.floor((pureMana / 2) * multiplier)
    addResistance(bonuses, WHEEL_HYBRID_ELEMENTS[modifierId], 1 * multiplier)
  elseif modifierId >= 38 and modifierId <= 41 then
    bonuses.health = bonuses.health + math.floor((pureHealth / 2) * multiplier)
    addResistance(bonuses, WHEEL_HYBRID_ELEMENTS[modifierId], 1 * multiplier)
  elseif modifierId >= 44 and modifierId <= 47 then
    bonuses.capacity = bonuses.capacity + math.floor((pureCapacity / 2) * multiplier)
    addResistance(bonuses, WHEEL_HYBRID_ELEMENTS[modifierId], 1 * multiplier)
  end
end

local WHEEL_REVELATION_SUPREME_DOMAIN = {
  [5] = 0,
  [21] = 3, [22] = 1, [23] = 2,
  [39] = 3, [40] = 1, [41] = 2,
  [56] = 3, [57] = 1, [58] = 2,
  [73] = 3, [74] = 1, [75] = 2,
  [91] = 3, [92] = 1, [93] = 2
}

local function applySupremeModifier(bonuses, modifierId, grade)
  local multiplier = WHEEL_GRADE_MULTIPLIER[grade] or 1.0
  bonuses.activeSupreme[modifierId] = grade
  if modifierId == 0 then
    bonuses.dodge = bonuses.dodge + (0.28 * multiplier)
  elseif modifierId == 1 then
    bonuses.criticalDamage = bonuses.criticalDamage + (2 * multiplier)
  elseif modifierId == 2 then
    bonuses.lifeLeech = bonuses.lifeLeech + (2 * multiplier)
  elseif modifierId == 3 then
    bonuses.manaLeech = bonuses.manaLeech + (0.8 * multiplier)
  end

  local revelationDomain = WHEEL_REVELATION_SUPREME_DOMAIN[modifierId]
  if revelationDomain ~= nil then
    bonuses.domainPoints[revelationDomain + 1] = bonuses.domainPoints[revelationDomain + 1] + math.floor(150 * multiplier)
  end
end

local function calculateWheelBonuses(player, data)
  local bonuses = emptyRuntimeBonuses()
  if not isWheelEligible(player) then
    return bonuses
  end

  local vocation = getWheelVocation(player)
  local steps = WHEEL_VOCATION_STEP[vocation]
  for slotId = 1, WHEEL_SLOT_COUNT do
    local points = data.slots[slotId]
    local dedication = WHEEL_SLOT_DEDICATION[slotId]
    local domain = WHEEL_SLOT_DOMAIN[slotId]
    bonuses.domainPoints[domain + 1] = bonuses.domainPoints[domain + 1] + points

    if dedication == "health" then
      bonuses.health = bonuses.health + (points * steps.health)
    elseif dedication == "mana" then
      bonuses.mana = bonuses.mana + (points * steps.mana)
    elseif dedication == "capacity" then
      bonuses.capacity = bonuses.capacity + (points * steps.capacity)
    elseif dedication == "mitigation" then
      bonuses.mitigation = bonuses.mitigation + (points * 0.03)
    elseif dedication == "lifemana" then
      bonuses.health = bonuses.health + (points * steps.health)
      bonuses.mana = bonuses.mana + (points * steps.mana)
    end

    if points == WHEEL_SLOT_MAX[slotId] then
      if WHEEL_SKILL_SLOTS[slotId] then
        if vocation == 1 then
          bonuses.melee = bonuses.melee + 1
        elseif vocation == 2 then
          bonuses.distance = bonuses.distance + 1
        elseif vocation == 3 or vocation == 4 then
          bonuses.magic = bonuses.magic + 1
        elseif vocation == 5 then
          bonuses.fist = bonuses.fist + 1
        end
      elseif WHEEL_LIFE_LEECH_SLOTS[slotId] then
        bonuses.lifeLeech = bonuses.lifeLeech + 0.75
      elseif WHEEL_MANA_LEECH_SLOTS[slotId] then
        bonuses.manaLeech = bonuses.manaLeech + 0.25
      end
    end
  end

  for affinity = 0, 3 do
    local resonance = 0
    for _, vessel in ipairs(WHEEL_VESSEL_SLOTS[affinity]) do
      if data.slots[vessel.id] == WHEEL_SLOT_MAX[vessel.id] then
        resonance = resonance + 1
      end
    end
    bonuses.vesselResonance[affinity + 1] = resonance

    local activeIndex = data.activeGems[affinity + 1]
    if activeIndex >= 0 then
      local gem = findGemByIndex(data, activeIndex)
      if gem and gem.affinity == affinity then
        local firstGrade = data.basicGrades[gem.firstAttribute + 1] or 0
        if resonance >= 1 then
          applyBasicModifier(bonuses, gem.firstAttribute, firstGrade, vocation)
        end
        if resonance >= 2 and gem.quality >= 1 then
          local secondGrade = math.min(data.basicGrades[gem.secondAttribute + 1] or 0, firstGrade)
          applyBasicModifier(bonuses, gem.secondAttribute, secondGrade, vocation)
        end
        if resonance >= 3 and gem.quality >= 2 then
          local secondGrade = math.min(data.basicGrades[gem.secondAttribute + 1] or 0, firstGrade)
          local supremeGrade = math.min(data.supremeGrades[gem.thirdAttribute + 1] or 0, firstGrade, secondGrade)
          applySupremeModifier(bonuses, gem.thirdAttribute, supremeGrade)
        end
        if resonance == gem.quality + 1 then
          bonuses.damageHealing = bonuses.damageHealing + (gem.quality == 2 and 2 or 1)
        end
      end
    end
  end

  for domain = 0, 3 do
    local points = bonuses.domainPoints[domain + 1]
    local stage = 0
    if points >= 1000 then
      stage = 3
    elseif points >= 500 then
      stage = 2
    elseif points >= 250 then
      stage = 1
    end
    bonuses.revelationStages[domain + 1] = stage
    bonuses.damageHealing = bonuses.damageHealing + WHEEL_REVELATION_DAMAGE_HEALING[stage]
  end
  return bonuses
end

local function applyWheelCapacity(player, capacityBonus)
  local oldApplied = getStorageCount(player, WHEEL_CAPACITY_STORAGE)
  local currentCapacity = tonumber(player:getCapacity()) or 0
  if currentCapacity >= 4294967295 then
    return
  end
  local baseCapacity = math.max(0, currentCapacity - (oldApplied * 100))
  local newApplied = math.max(0, math.floor(tonumber(capacityBonus) or 0))
  player:setCapacity(baseCapacity + (newApplied * 100))
  setStorageCount(player, WHEEL_CAPACITY_STORAGE, newApplied)
end

local function applyWheelCondition(player, bonuses)
  player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, WHEEL_CONDITION_SUBID, true)

  local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
  condition:setParameter(CONDITION_PARAM_SUBID, WHEEL_CONDITION_SUBID)
  condition:setParameter(CONDITION_PARAM_TICKS, -1)

  if bonuses.health ~= 0 then
    condition:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTS, math.floor(bonuses.health))
  end
  if bonuses.mana ~= 0 then
    condition:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTS, math.floor(bonuses.mana))
  end
  if bonuses.melee ~= 0 then
    condition:setParameter(CONDITION_PARAM_SKILL_SWORD, math.floor(bonuses.melee))
    condition:setParameter(CONDITION_PARAM_SKILL_AXE, math.floor(bonuses.melee))
    condition:setParameter(CONDITION_PARAM_SKILL_CLUB, math.floor(bonuses.melee))
  end
  if bonuses.distance ~= 0 then
    condition:setParameter(CONDITION_PARAM_SKILL_DISTANCE, math.floor(bonuses.distance))
  end
  if bonuses.magic ~= 0 then
    condition:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, math.floor(bonuses.magic))
  end
  if bonuses.fist ~= 0 then
    condition:setParameter(CONDITION_PARAM_SKILL_FIST, math.floor(bonuses.fist))
  end
  if bonuses.criticalDamage >= 1 then
    condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, math.floor(bonuses.criticalDamage))
  end
  player:addCondition(condition)
end

local function clearWheelSpellContext(player, bonuses)
  bonuses = bonuses or WHEEL_RUNTIME[player:getGuid()]
  if bonuses then
    bonuses.spellContext = nil
  end
  player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, WHEEL_SPELL_CONDITION_SUBID, true)
end

local function applyWheelSpellCriticalCondition(player, context)
  if not context or (context.criticalExtra or 0) < 1 then
    return
  end
  local remainingTicks = math.max(1, math.floor((context.expiresAt or 0) - getNowMilliseconds()))
  local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
  condition:setParameter(CONDITION_PARAM_SUBID, WHEEL_SPELL_CONDITION_SUBID)
  condition:setParameter(CONDITION_PARAM_TICKS, remainingTicks)
  condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, math.floor(context.criticalExtra + 0.5))
  player:addCondition(condition)
end

local getCachedBonuses
local function beginWheelSpellContext(player, spellName, force)
  local bonuses = getCachedBonuses(player)
  local normalizedName = normalizeSpellName(spellName)
  local now = getNowMilliseconds()
  local current = bonuses.spellContext

  if not force and current and current.pending and current.name == normalizedName and now <= (current.expiresAt or 0) then
    clearWheelSpellContext(player, bonuses)
    return false
  end

  clearWheelSpellContext(player, bonuses)
  local damagePercent = 0
  local healingPercent = 0
  local criticalExtra = 0
  for modifierId, grade in pairs(bonuses.activeSupreme) do
    local effect = WHEEL_SUPREME_SPELL_EFFECTS[modifierId]
    if effect and effect.spell == normalizedName then
      local multiplier = WHEEL_GRADE_MULTIPLIER[grade] or 1.0
      damagePercent = damagePercent + ((effect.damage or 0) * multiplier)
      healingPercent = healingPercent + ((effect.healing or 0) * multiplier)
      criticalExtra = criticalExtra + ((effect.critical or 0) * multiplier)
    end
  end

  bonuses.spellContext = {
    name = normalizedName,
    pending = true,
    startedAt = now,
    expiresAt = now + WHEEL_SPELL_CONTEXT_MS,
    damagePercent = damagePercent,
    healingPercent = healingPercent,
    criticalExtra = criticalExtra
  }

  applyWheelSpellCriticalCondition(player, bonuses.spellContext)
  return true
end

local function refreshWheelBonuses(player, data)
  data = data or loadPlayerWheelData(player)
  local bonuses = calculateWheelBonuses(player, data)
  local previous = WHEEL_RUNTIME[player:getGuid()]
  if previous then
    bonuses.spellContext = previous.spellContext
    bonuses.lifeLeechRemainder = previous.lifeLeechRemainder or 0
    bonuses.manaLeechRemainder = previous.manaLeechRemainder or 0
    if previous.avatar and getNowMilliseconds() <= (previous.avatar.expiresAt or 0) then
      bonuses.avatar = previous.avatar
    end
  end
  WHEEL_RUNTIME[player:getGuid()] = bonuses
  applyWheelCondition(player, bonuses)
  applyWheelCapacity(player, bonuses.capacity)
  return bonuses
end

getCachedBonuses = function(player)
  local bonuses = WHEEL_RUNTIME[player:getGuid()]
  if bonuses then
    return bonuses
  end
  local data = loadPlayerWheelData(player)
  return refreshWheelBonuses(player, data)
end

local WHEEL_COMBAT_RESISTANCE_NAMES = {}
local function registerCombatResistance(combatType, name)
  if combatType ~= nil then
    WHEEL_COMBAT_RESISTANCE_NAMES[combatType] = name
  end
end
registerCombatResistance(COMBAT_PHYSICALDAMAGE, "physical")
registerCombatResistance(COMBAT_HOLYDAMAGE, "holy")
registerCombatResistance(COMBAT_DEATHDAMAGE, "death")
registerCombatResistance(COMBAT_FIREDAMAGE, "fire")
registerCombatResistance(COMBAT_EARTHDAMAGE, "earth")
registerCombatResistance(COMBAT_ICEDAMAGE, "ice")
registerCombatResistance(COMBAT_ENERGYDAMAGE, "energy")
registerCombatResistance(COMBAT_MANADRAIN, "manaDrain")
registerCombatResistance(COMBAT_LIFEDRAIN, "lifeDrain")

local function applyPercentToSignedValue(value, percent)
  value = tonumber(value) or 0
  if value == 0 or percent == 0 then
    return value
  end
  local magnitude = math.abs(value) * math.max(0, 1 + (percent / 100))
  magnitude = math.floor(magnitude + 0.5)
  return value < 0 and -magnitude or magnitude
end

local function getActiveSpellContext(bonuses)
  local context = bonuses.spellContext
  if not context then
    return nil
  end
  if getNowMilliseconds() > (context.expiresAt or 0) then
    bonuses.spellContext = nil
    return nil
  end
  return context
end

local function getAvatarStage(bonuses)
  if not bonuses then
    return 0
  end
  local stage = tonumber(bonuses.revelationStages and bonuses.revelationStages[4]) or 0
  return clampInteger(stage, 0, 3, 0)
end

local function getActiveAvatar(bonuses)
  local avatar = bonuses and bonuses.avatar
  if not avatar then
    return nil
  end
  if getNowMilliseconds() > (avatar.expiresAt or 0) then
    bonuses.avatar = nil
    return nil
  end
  return avatar
end

local function applyFlatDamageHealing(primaryDamage, secondaryDamage, flatAmount)
  flatAmount = math.max(0, tonumber(flatAmount) or 0)
  if flatAmount == 0 then
    return primaryDamage, secondaryDamage
  end

  if primaryDamage < 0 then
    primaryDamage = primaryDamage - flatAmount
  elseif primaryDamage > 0 then
    primaryDamage = primaryDamage + flatAmount
  elseif secondaryDamage < 0 then
    secondaryDamage = secondaryDamage - flatAmount
  elseif secondaryDamage > 0 then
    secondaryDamage = secondaryDamage + flatAmount
  end
  return primaryDamage, secondaryDamage
end

local function applyWheelLeech(attacker, bonuses, primaryDamage, secondaryDamage, target, origin)
  if target and target == attacker then
    return
  end
  if ORIGIN_CONDITION ~= nil and origin == ORIGIN_CONDITION then
    return
  end
  local totalDamage = 0
  if primaryDamage < 0 then
    totalDamage = totalDamage + math.abs(primaryDamage)
  end
  if secondaryDamage < 0 then
    totalDamage = totalDamage + math.abs(secondaryDamage)
  end
  if totalDamage <= 0 then
    return
  end

  if bonuses.lifeLeech > 0 then
    local exact = (totalDamage * bonuses.lifeLeech / 100) + (bonuses.lifeLeechRemainder or 0)
    local amount = math.floor(exact)
    bonuses.lifeLeechRemainder = exact - amount
    if amount > 0 then
      attacker:addHealth("healing", amount)
    end
  end
  if bonuses.manaLeech > 0 then
    local exact = (totalDamage * bonuses.manaLeech / 100) + (bonuses.manaLeechRemainder or 0)
    local amount = math.floor(exact)
    bonuses.manaLeechRemainder = exact - amount
    if amount > 0 then
      attacker:addMana(amount)
    end
  end
end

local function applyOutgoingWheelCombat(attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, target, origin)
  if not attacker or not attacker:isPlayer() then
    return primaryDamage, primaryType, secondaryDamage, secondaryType
  end
  local bonuses = getCachedBonuses(attacker)
  local context = getActiveSpellContext(bonuses)
  if context then
    if context.damagePercent > 0 then
      if primaryDamage < 0 then
        primaryDamage = applyPercentToSignedValue(primaryDamage, context.damagePercent)
      end
      if secondaryDamage < 0 then
        secondaryDamage = applyPercentToSignedValue(secondaryDamage, context.damagePercent)
      end
    end
    if context.healingPercent > 0 then
      if primaryDamage > 0 then
        primaryDamage = applyPercentToSignedValue(primaryDamage, context.healingPercent)
      end
      if secondaryDamage > 0 then
        secondaryDamage = applyPercentToSignedValue(secondaryDamage, context.healingPercent)
      end
    end
  end

  primaryDamage, secondaryDamage = applyFlatDamageHealing(
    primaryDamage, secondaryDamage, bonuses.damageHealing or 0
  )
  applyWheelLeech(attacker, bonuses, primaryDamage, secondaryDamage, target, origin)
  return primaryDamage, primaryType, secondaryDamage, secondaryType
end

local function applyIncomingWheelMana(target, primaryDamage, primaryType, secondaryDamage, secondaryType)
  local bonuses = getCachedBonuses(target)
  local avatar = getActiveAvatar(bonuses)
  local function reduce(value, combatType)
    if value >= 0 then
      return value
    end
    local resistanceName = WHEEL_COMBAT_RESISTANCE_NAMES[combatType]
    local resistance = resistanceName and bonuses.resistances[resistanceName] or 0
    local afterResistance = applyPercentToSignedValue(value, -resistance)
    return applyPercentToSignedValue(afterResistance, -(avatar and avatar.damageReduction or 0))
  end
  return reduce(primaryDamage, primaryType), primaryType, reduce(secondaryDamage, secondaryType), secondaryType
end

local function applyIncomingWheelCombat(target, primaryDamage, primaryType, secondaryDamage, secondaryType)
  local bonuses = getCachedBonuses(target)
  local avatar = getActiveAvatar(bonuses)
  if (primaryDamage < 0 or secondaryDamage < 0) and bonuses.dodge > 0 and (math.random() * 100) < bonuses.dodge then
    return 0, primaryType, 0, secondaryType
  end

  local function reduce(value, combatType)
    if value >= 0 then
      return value
    end
    local resistanceName = WHEEL_COMBAT_RESISTANCE_NAMES[combatType]
    local resistance = resistanceName and bonuses.resistances[resistanceName] or 0
    local afterResistance = applyPercentToSignedValue(value, -resistance)
    local afterMitigation = applyPercentToSignedValue(afterResistance, -(bonuses.mitigation or 0))
    return applyPercentToSignedValue(afterMitigation, -(avatar and avatar.damageReduction or 0))
  end

  return reduce(primaryDamage, primaryType), primaryType, reduce(secondaryDamage, secondaryType), secondaryType
end

local function buildRuntimePayload(bonuses)
  local resistances = {}
  local resistanceOrder = {"physical", "holy", "death", "fire", "earth", "ice", "energy", "manaDrain", "lifeDrain"}
  for _, resistanceType in ipairs(resistanceOrder) do
    resistances[#resistances + 1] = {type = resistanceType, value = bonuses.resistances[resistanceType] or 0}
  end
  return {
    health = bonuses.health,
    mana = bonuses.mana,
    capacity = bonuses.capacity,
    mitigation = bonuses.mitigation,
    melee = bonuses.melee,
    distance = bonuses.distance,
    magic = bonuses.magic,
    fist = bonuses.fist,
    lifeLeech = bonuses.lifeLeech,
    manaLeech = bonuses.manaLeech,
    dodge = bonuses.dodge,
    criticalDamage = bonuses.criticalDamage,
    damageHealing = bonuses.damageHealing,
    resistances = resistances,
    vesselResonance = copyArray(bonuses.vesselResonance, 4, 0),
    domainPoints = copyArray(bonuses.domainPoints, 4, 0),
    revelationStages = copyArray(bonuses.revelationStages, 4, 0)
  }
end

local function buildFragmentPayload(data, vocation, supreme)
  local resultList = {}
  local source = supreme and data.supremeGrades or data.basicGrades
  local modifiers = supreme and getSupremePool(vocation) or WHEEL_VALID_BASIC_IDS
  for _, modifierId in ipairs(modifiers) do
    resultList[#resultList + 1] = {
      bonusId = modifierId,
      grade = source[modifierId + 1] or 0
    }
  end
  return resultList
end

local function buildActiveGemPayload(data)
  local list = {}
  for affinity = 0, 3 do
    list[#list + 1] = {affinity = affinity, index = data.activeGems[affinity + 1] or -1}
  end
  return list
end

local function buildCostPayload(costTable)
  local list = {}
  for quality = 0, 2 do
    local value = costTable[quality]
    list[#list + 1] = {quality = quality, gold = type(value) == "table" and value.gold or value}
  end
  return list
end

local function getItemClientId(serverItemId)
  serverItemId = tonumber(serverItemId) or 0
  if serverItemId <= 0 then
    return 0
  end

  local ok, clientId = pcall(function()
    local itemType = ItemType(serverItemId)
    return itemType and itemType:getClientId() or 0
  end)
  if not ok then
    return 0
  end
  return tonumber(clientId) or 0
end

local function applyAvatarConditions(player, config, stageConfig)
  player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, WHEEL_AVATAR_CONDITION_SUBID, true)
  player:removeCondition(CONDITION_OUTFIT, CONDITIONID_DEFAULT, WHEEL_AVATAR_OUTFIT_SUBID, true)

  local attributeCondition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
  attributeCondition:setParameter(CONDITION_PARAM_SUBID, WHEEL_AVATAR_CONDITION_SUBID)
  attributeCondition:setParameter(CONDITION_PARAM_TICKS, WHEEL_AVATAR_DURATION_MS)
  attributeCondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 100)
  attributeCondition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, stageConfig.criticalDamage)
  attributeCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
  player:addCondition(attributeCondition)

  local outfitCondition = Condition(CONDITION_OUTFIT, CONDITIONID_DEFAULT)
  outfitCondition:setParameter(CONDITION_PARAM_SUBID, WHEEL_AVATAR_OUTFIT_SUBID)
  outfitCondition:setParameter(CONDITION_PARAM_TICKS, WHEEL_AVATAR_DURATION_MS)
  outfitCondition:setOutfit(config.outfit)
  player:addCondition(outfitCondition)
end

local function castWheelAvatar(player, spellName)
  if not player or not player:isPlayer() then
    return false
  end

  local normalizedName = normalizeSpellName(spellName)
  local config = WHEEL_AVATAR_CONFIG[normalizedName]
  if not config then
    return false
  end

  local vocation = getWheelVocation(player)
  if vocation ~= config.vocation then
    player:sendCancelMessage("This avatar is not available for your vocation.")
    return false
  end

  local bonuses = getCachedBonuses(player)
  local stage = getAvatarStage(bonuses)
  local stageConfig = WHEEL_AVATAR_STAGE[stage]
  if not stageConfig then
    player:sendCancelMessage("You have not unlocked this Avatar Revelation Perk.")
    return false
  end

  bonuses.avatar = {
    name = normalizedName,
    stage = stage,
    expiresAt = getNowMilliseconds() + WHEEL_AVATAR_DURATION_MS,
    damageReduction = stageConfig.damageReduction,
    criticalDamage = stageConfig.criticalDamage
  }

  applyAvatarConditions(player, config, stageConfig)

  local position = player:getPosition()
  if position and position.sendMagicEffect then
    position:sendMagicEffect(config.effect or CONST_ME_MAGIC_GREEN)
  end
  if type(playSound) == "function" then
    playSound(player, "utito.ogg")
  end
  return true
end

local function buildGemItemPayload()
  local list = {}
  for vocation, items in pairs(WHEEL_GEM_ITEMS) do
    for quality = 0, 2 do
      local serverItemId = tonumber(items[quality + 1]) or 0
      list[#list + 1] = {
        vocation = vocation,
        quality = quality,
        serverId = serverItemId,
        clientId = getItemClientId(serverItemId)
      }
    end
  end
  return list
end

local function buildFullWheelPayload(player, data)
  data = data or loadPlayerWheelData(player)
  local totalPoints, levelPoints, extraPoints = getWheelPoints(player, data)
  local vocation = getWheelVocation(player)
  local bonuses = getCachedBonuses(player)
  return {
    base = {
      points = totalPoints,
      levelPoints = levelPoints,
      extraPoints = extraPoints,
      state = getWheelState(player),
      vocation = vocation
    },
    slots = copyArray(data.slots, WHEEL_SLOT_COUNT, 0),
    activeGems = buildActiveGemPayload(data),
    revealedGems = serializeWheelData(data).revealedGems,
    presets = serializeWheelPresets(data.presets),
    lesserFragments = buildFragmentPayload(data, vocation, false),
    greaterFragments = buildFragmentPayload(data, vocation, true),
    resources = getWheelResources(player),
    runtime = buildRuntimePayload(bonuses),
    config = {
      version = WHEEL_DATA_VERSION,
      gemLimit = WHEEL_GEM_LIMIT,
      gemItems = buildGemItemPayload(),
      revealCosts = buildCostPayload(WHEEL_REVEAL_COSTS),
      rotateCosts = buildCostPayload(WHEEL_ROTATE_COSTS)
    }
  }
end

local function sendWheelPayload(player, action, data)
  local ok, encoded = pcall(json.encode, {action = action, data = data or {}})
  if not ok or type(encoded) ~= "string" then
    print(string.format("[Wheel] Could not encode opcode payload for player %d: %s", player:getGuid(), tostring(encoded)))
    return false
  end
  if #encoded > 60000 then
    print(string.format("[Wheel] Refusing oversized response (%d bytes) for player %d.", #encoded, player:getGuid()))
    return false
  end
  player:sendExtendedOpcode(WHEEL_OPCODE, encoded)
  return true
end

local function sendWheelMessage(player, message, mode)
  sendWheelPayload(player, "msg", {message = tostring(message), mode = mode or "info"})
end

local function sendWheelFull(player, data)
  return sendWheelPayload(player, "full", buildFullWheelPayload(player, data))
end

local function requireTempleAction(player)
  if getWheelState(player) == 0 then
    sendWheelMessage(player, "The Wheel of Destiny requires level 51, Premium status, and a promoted supported vocation.", "error")
    return false
  end
  if getWheelState(player) ~= 1 then
    sendWheelMessage(player, "This Gem Atelier action can only be performed inside a temple.", "error")
    return false
  end
  return true
end

local function buildRandomGem(data, quality, vocation)
  local firstAttribute = randomFrom(WHEEL_BASIC_SLOT_ONE_POOL)
  local gem = {
    index = data.nextGemIndex,
    affinity = math.random(0, 3),
    quality = quality,
    locked = 0,
    firstAttribute = firstAttribute
  }
  data.nextGemIndex = data.nextGemIndex + 1

  if quality >= 1 then
    local secondAttribute = firstAttribute
    while secondAttribute == firstAttribute do
      secondAttribute = randomFrom(WHEEL_BASIC_SLOT_TWO_POOL)
    end
    gem.secondAttribute = secondAttribute
  end
  if quality >= 2 then
    gem.thirdAttribute = randomFrom(getSupremePool(vocation))
  end
  return gem
end

local function handleWheelFetch(player)
  local data, changed = loadPlayerWheelData(player)
  changed = sanitizePersistedState(player, data) or changed
  refreshWheelBonuses(player, data)
  if changed then
    savePlayerWheelData(player, data)
  end
  sendWheelFull(player, data)
end

local function handleWheelSave(player, payload)
  local state = getWheelState(player)
  if state == 0 then
    return sendWheelMessage(player, "You are not eligible to use the Wheel of Destiny.", "error")
  end

  local data = loadPlayerWheelData(player)
  sanitizePersistedState(player, data)
  local requestedSlots, slotError = normalizeRequestedSlots(payload.slots)
  if not requestedSlots then
    return sendWheelMessage(player, slotError, "error")
  end

  if state == 2 then
    for slotId = 1, WHEEL_SLOT_COUNT do
      if requestedSlots[slotId] < data.slots[slotId] then
        return sendWheelMessage(player, "Outside a temple you may spend new points, but you cannot remove or redistribute assigned points.", "error")
      end
    end
  end

  local topologyOk, topologyError = validateWheelTopology(requestedSlots)
  if not topologyOk then
    return sendWheelMessage(player, topologyError, "error")
  end
  local availablePoints = getWheelPoints(player, data)
  if getUsedWheelPoints(requestedSlots) > availablePoints then
    return sendWheelMessage(player, "This allocation uses more promotion points than are available.", "error")
  end

  local requestedActive = normalizeRequestedActiveGems(payload.gems)
  if state == 2 then
    for affinity = 0, 3 do
      if requestedActive[affinity + 1] ~= data.activeGems[affinity + 1] then
        return sendWheelMessage(player, "Gems can only be placed in or removed from vessels inside a temple.", "error")
      end
    end
  end
  local activeOk, activeError = validateActiveGems(data, requestedActive)
  if not activeOk then
    return sendWheelMessage(player, activeError, "error")
  end

  local previousSlots = data.slots
  local previousActive = data.activeGems
  data.slots = requestedSlots
  data.activeGems = requestedActive
  if not savePlayerWheelData(player, data) then
    data.slots = previousSlots
    data.activeGems = previousActive
    refreshWheelBonuses(player, data)
    return sendWheelMessage(player, "The wheel could not be saved. No changes were applied.", "error")
  end

  refreshWheelBonuses(player, data)
  sendWheelFull(player, data)
end

local function handleWheelPresets(player, payload)
  if getWheelState(player) == 0 then
    return sendWheelMessage(player, "You are not eligible to use the Wheel of Destiny.", "error")
  end

  local data = loadPlayerWheelData(player)
  data.presets = normalizeWheelPresets(payload.presets, getWheelVocation(player))
  if not savePlayerWheelData(player, data) then
    return sendWheelMessage(player, "Wheel presets could not be saved.", "error")
  end
  sendWheelFull(player, data)
end

local function handleRevealGem(player, payload)
  if not requireTempleAction(player) then
    return
  end
  local quality = clampInteger(payload.value, 0, 2, -1)
  local config = WHEEL_REVEAL_COSTS[quality]
  if not config then
    return sendWheelMessage(player, "Invalid gem reveal option.", "error")
  end

  local data = loadPlayerWheelData(player)
  if #data.revealedGems >= WHEEL_GEM_LIMIT then
    return sendWheelMessage(player, "You can carry a maximum of 225 revealed gems.", "error")
  end
  if getWheelResourceCount(player, 0) < config.gold or getWheelResourceCount(player, config.resourceType) < 1 then
    return sendWheelMessage(player, "Not enough resources to reveal this gem.", "error")
  end

  if not consumeWheelResource(player, 0, config.gold) then
    return sendWheelMessage(player, "The gold cost could not be paid.", "error")
  end
  if not consumeWheelResource(player, config.resourceType, 1) then
    refundWheelResource(player, 0, config.gold)
    return sendWheelMessage(player, "The unrevealed gem could not be consumed.", "error")
  end

  local gem = buildRandomGem(data, quality, getWheelVocation(player))
  data.revealedGems[#data.revealedGems + 1] = gem
  if not savePlayerWheelData(player, data) then
    table.remove(data.revealedGems)
    refundWheelResource(player, config.resourceType, 1)
    refundWheelResource(player, 0, config.gold)
    return sendWheelMessage(player, "The gem could not be saved; your resources were refunded.", "error")
  end
  sendWheelFull(player, data)
end

local function handleDismantleGem(player, payload)
  if not requireTempleAction(player) then
    return
  end
  local data = loadPlayerWheelData(player)
  local gem, position = findGemByIndex(data, payload.value)
  if not gem then
    return sendWheelMessage(player, "Gem not found.", "error")
  end
  if gem.locked == 1 then
    return sendWheelMessage(player, "Unlock this gem before dismantling it.", "error")
  end
  if isGemActive(data, gem.index) then
    return sendWheelMessage(player, "Remove this gem from its vessel before dismantling it.", "error")
  end
  local affinityCount = 0
  for _, revealedGem in ipairs(data.revealedGems) do
    if revealedGem.affinity == gem.affinity then
      affinityCount = affinityCount + 1
    end
  end
  if affinityCount <= 1 then
    return sendWheelMessage(player, "You cannot dismantle your last gem of this affinity.", "error")
  end

  local fragmentType = gem.quality == 2 and 85 or 84
  local fragmentAmount
  if gem.quality == 0 then
    fragmentAmount = math.random(1, 5)
  elseif gem.quality == 1 then
    fragmentAmount = math.random(2, 10)
  else
    fragmentAmount = math.random(1, 5)
  end

  local oldFragments = getWheelResourceCount(player, fragmentType)
  setStorageCount(player, WHEEL_RESOURCE_STORAGES[fragmentType], oldFragments + fragmentAmount)
  table.remove(data.revealedGems, position)
  if not savePlayerWheelData(player, data) then
    table.insert(data.revealedGems, position, gem)
    setStorageCount(player, WHEEL_RESOURCE_STORAGES[fragmentType], oldFragments)
    return sendWheelMessage(player, "The gem could not be dismantled.", "error")
  end
  sendWheelMessage(player, string.format("Gem dismantled into %d %s fragment%s.", fragmentAmount, fragmentType == 85 and "greater" or "lesser", fragmentAmount == 1 and "" or "s"), "success")
  sendWheelFull(player, data)
end

local function handleRotateGem(player, payload)
  if not requireTempleAction(player) then
    return
  end
  local data = loadPlayerWheelData(player)
  local gem = findGemByIndex(data, payload.value)
  if not gem then
    return sendWheelMessage(player, "Gem not found.", "error")
  end
  if gem.locked == 1 then
    return sendWheelMessage(player, "Unlock this gem before rotating its affinity.", "error")
  end
  if isGemActive(data, gem.index) then
    return sendWheelMessage(player, "Remove this gem from its vessel before rotating it.", "error")
  end

  local cost = WHEEL_ROTATE_COSTS[gem.quality]
  if not cost or getWheelResourceCount(player, 0) < cost then
    return sendWheelMessage(player, "Not enough gold to rotate this gem.", "error")
  end
  if not consumeWheelResource(player, 0, cost) then
    return sendWheelMessage(player, "The gold cost could not be paid.", "error")
  end

  local oldAffinity = gem.affinity
  gem.affinity = WHEEL_CLOCKWISE_AFFINITY[oldAffinity]
  if not savePlayerWheelData(player, data) then
    gem.affinity = oldAffinity
    refundWheelResource(player, 0, cost)
    return sendWheelMessage(player, "The gem could not be rotated; your gold was refunded.", "error")
  end
  sendWheelFull(player, data)
end

local function handleLockGem(player, payload)
  if not requireTempleAction(player) then
    return
  end
  local data = loadPlayerWheelData(player)
  local gem = findGemByIndex(data, payload.value)
  if not gem then
    return sendWheelMessage(player, "Gem not found.", "error")
  end
  local oldLocked = gem.locked
  gem.locked = oldLocked == 1 and 0 or 1
  if not savePlayerWheelData(player, data) then
    gem.locked = oldLocked
    return sendWheelMessage(player, "The gem lock could not be changed.", "error")
  end
  sendWheelFull(player, data)
end

local function handleEnhanceModifier(player, payload)
  if not requireTempleAction(player) then
    return
  end
  local extra = type(payload.extra) == "table" and payload.extra or {}
  local modifierId = clampInteger(extra.clip, 0, 93, -1)
  local filter = clampInteger(extra.filter, 2, 3, -1)
  if modifierId < 0 or not WHEEL_ENHANCE_COSTS[filter] then
    return sendWheelMessage(player, "Invalid modifier selection.", "error")
  end

  local data = loadPlayerWheelData(player)
  local gradeTable
  local validModifier = false
  if filter == 2 then
    validModifier = WHEEL_VALID_BASIC_SET[modifierId] == true
    gradeTable = data.basicGrades
  else
    validModifier = listToSet(getSupremePool(getWheelVocation(player)))[modifierId] == true
    gradeTable = data.supremeGrades
  end
  if not validModifier then
    return sendWheelMessage(player, "This modifier is not available to your vocation.", "error")
  end

  local currentGrade = gradeTable[modifierId + 1] or 0
  local cost = WHEEL_ENHANCE_COSTS[filter][currentGrade]
  if not cost then
    return sendWheelMessage(player, "This modifier is already Grade IV.", "error")
  end
  if getWheelResourceCount(player, 0) < cost.gold or getWheelResourceCount(player, cost.resourceType) < cost.fragments then
    return sendWheelMessage(player, "Not enough gold or fragments to enhance this modifier.", "error")
  end

  if not consumeWheelResource(player, 0, cost.gold) then
    return sendWheelMessage(player, "The gold cost could not be paid.", "error")
  end
  if not consumeWheelResource(player, cost.resourceType, cost.fragments) then
    refundWheelResource(player, 0, cost.gold)
    return sendWheelMessage(player, "The fragment cost could not be paid.", "error")
  end

  gradeTable[modifierId + 1] = currentGrade + 1
  if not savePlayerWheelData(player, data) then
    gradeTable[modifierId + 1] = currentGrade
    refundWheelResource(player, cost.resourceType, cost.fragments)
    refundWheelResource(player, 0, cost.gold)
    return sendWheelMessage(player, "The enhancement could not be saved; your resources were refunded.", "error")
  end

  refreshWheelBonuses(player, data)
  sendWheelFull(player, data)
end

local function handleWheelGemAction(player, payload)
  local mode = clampInteger(payload.mode, 0, 4, -1)
  if mode == 0 then
    return handleDismantleGem(player, payload)
  elseif mode == 1 then
    return handleRevealGem(player, payload)
  elseif mode == 2 then
    return handleRotateGem(player, payload)
  elseif mode == 3 then
    return handleLockGem(player, payload)
  elseif mode == 4 then
    return handleEnhanceModifier(player, payload)
  end
  sendWheelMessage(player, "Unknown Gem Atelier action.", "error")
end

-- Public integration API for shared combat/spell hooks outside this module.
_G.WheelDestiny_getBonuses = function(player)
  if not player or not player:isPlayer() then
    return nil
  end
  return getCachedBonuses(player)
end

_G.WheelDestiny_refreshPlayer = function(player)
  if not player or not player:isPlayer() then
    return false
  end
  local data = loadPlayerWheelData(player)
  sanitizePersistedState(player, data)
  refreshWheelBonuses(player, data)
  return true
end

_G.WheelDestiny_applyOutgoingCombat = function(attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, target, origin)
  return applyOutgoingWheelCombat(attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, target, origin)
end

_G.WheelDestiny_onPlayerSpellPreCast = function(player, spellName, spellGroup, aggressive, manaCost, healthCost)
  if not player or not player:isPlayer() then
    return false
  end
  return beginWheelSpellContext(player, spellName)
end

_G.WheelDestiny_withSpellContext = function(player, spellName, callback)
  if not player or not player:isPlayer() or type(callback) ~= "function" then
    return nil
  end
  local bonuses = getCachedBonuses(player)
  local previous = bonuses.spellContext
  beginWheelSpellContext(player, spellName, true)

  local function capture(...)
    return {n = select("#", ...), ...}
  end
  local values = capture(pcall(callback))
  clearWheelSpellContext(player, bonuses)
  if previous and getNowMilliseconds() <= (previous.expiresAt or 0) then
    bonuses.spellContext = previous
    applyWheelSpellCriticalCondition(player, previous)
  end

  if not values[1] then
    error(values[2], 0)
  end
  local unpackValues = table.unpack or unpack
  return unpackValues(values, 2, values.n)
end

_G.WheelDestiny_onPlayerSpellCast = function(player, spellName, spellGroup, aggressive, manaCost)
  if not player or not player:isPlayer() then
    return
  end
  clearWheelSpellContext(player, getCachedBonuses(player))
end

_G.WheelDestiny_getSpellCooldownMs = function(player, spellName, spellGroup, aggressive, cooldownType, currentCooldown)
  if not player or not player:isPlayer() then
    return currentCooldown
  end
  if tostring(cooldownType or ""):lower() ~= "spell" then
    return currentCooldown
  end
  local bonuses = getCachedBonuses(player)
  local normalizedName = normalizeSpellName(spellName)
  if WHEEL_AVATAR_CONFIG[normalizedName] then
    local stageConfig = WHEEL_AVATAR_STAGE[getAvatarStage(bonuses)]
    if stageConfig then
      return stageConfig.cooldown
    end
    return currentCooldown
  end

  local reduction = 0
  for modifierId, grade in pairs(bonuses.activeSupreme) do
    local config = WHEEL_SUPREME_COOLDOWNS[modifierId]
    if config and config.spell == normalizedName then
      reduction = reduction + config.milliseconds
    end
  end
  return math.max(0, math.floor((tonumber(currentCooldown) or 0) - reduction))
end

_G.WheelDestiny_getActiveSupremeGrade = function(player, modifierId)
  if not player or not player:isPlayer() then
    return nil
  end
  return getCachedBonuses(player).activeSupreme[tonumber(modifierId)]
end

_G.WheelDestiny_castAvatar = function(player, spellName)
  return castWheelAvatar(player, spellName)
end

local WheelCombat = CreatureEvent("WheelDestinyCombat")
WheelCombat:type("healthchange")

function WheelCombat.onHealthChange(target, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
  primaryDamage, primaryType, secondaryDamage, secondaryType = applyOutgoingWheelCombat(
    attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, target, origin
  )
  return applyIncomingWheelCombat(target, primaryDamage, primaryType, secondaryDamage, secondaryType)
end

WheelCombat:register()

local WheelManaCombat = CreatureEvent("WheelDestinyManaCombat")
WheelManaCombat:type("manachange")

function WheelManaCombat.onManaChange(target, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
  return applyIncomingWheelMana(target, primaryDamage, primaryType, secondaryDamage, secondaryType)
end

WheelManaCombat:register()

local WheelExtended = CreatureEvent("WheelExtendedOpcode")
WheelExtended:type("extendedopcode")

function WheelExtended.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= WHEEL_OPCODE then
    return false
  end
  if type(buffer) ~= "string" or #buffer > WHEEL_MAX_REQUEST_BYTES then
    sendWheelMessage(player, "Invalid or oversized Wheel request.", "error")
    return true
  end

  local decodeOk, payload = pcall(json.decode, buffer)
  if not decodeOk or type(payload) ~= "table" or type(payload.action) ~= "string" then
    sendWheelMessage(player, "Invalid Wheel request.", "error")
    return true
  end

  local action = payload.action
  local data = type(payload.data) == "table" and payload.data or {}
  local handler
  if action == "fetch" then
    handler = handleWheelFetch
  elseif action == "save" then
    handler = handleWheelSave
  elseif action == "presets" then
    handler = handleWheelPresets
  elseif action == "gemAction" then
    handler = handleWheelGemAction
  else
    sendWheelMessage(player, "Unknown Wheel request.", "error")
    return true
  end

  local dispatchOk, dispatchError = pcall(handler, player, data)
  if not dispatchOk then
    print(string.format("[Wheel] Request '%s' failed for player %d: %s", action, player:getGuid(), tostring(dispatchError)))
    sendWheelMessage(player, "The Wheel request could not be completed.", "error")
  end
  return true
end

WheelExtended:register()

local WheelLogin = CreatureEvent("WheelLogin")
WheelLogin:type("login")

function WheelLogin.onLogin(player)
  player:registerEvent("WheelExtendedOpcode")
  player:registerEvent("WheelDestinyCombat")
  player:registerEvent("WheelDestinyManaCombat")
  local data, changed = loadPlayerWheelData(player)
  changed = sanitizePersistedState(player, data) or changed
  refreshWheelBonuses(player, data)
  if changed then
    savePlayerWheelData(player, data)
  end
  return true
end

WheelLogin:register()

local WheelLogout = CreatureEvent("WheelLogout")
WheelLogout:type("logout")

function WheelLogout.onLogout(player)
  clearWheelSpellContext(player, WHEEL_RUNTIME[player:getGuid()])
  WHEEL_RUNTIME[player:getGuid()] = nil
  return true
end

WheelLogout:register()

-- Exported for GM talkactions / other scripts. Wheel points are not stored:
-- they are derived from the character level (level - 50), so the only reason
-- to ever show "0 points" is that the character is not eligible (level 51,
-- premium status and a promoted supported vocation).
WheelOfDestiny = WheelOfDestiny or {}

function WheelOfDestiny.isEligible(player)
  return isWheelEligible(player)
end

function WheelOfDestiny.getBlocks(player)
  local blocks = {}
  if getWheelVocation(player) == 0 then
    blocks[#blocks + 1] = "unsupported vocation"
  end
  if player:getLevel() <= 50 then
    blocks[#blocks + 1] = "requires level 51"
  end
  if not player:isPremium() then
    blocks[#blocks + 1] = "requires premium status"
  end
  if not WHEEL_PROMOTED_VOCATIONS[getServerVocationId(player)] then
    blocks[#blocks + 1] = "requires a promoted vocation"
  end
  return blocks
end

function WheelOfDestiny.getPoints(player)
  local data = loadPlayerWheelData(player)
  local total, levelPoints, extraPoints = getWheelPoints(player, data)
  local used = getUsedWheelPoints(data.slots)
  return total, levelPoints, extraPoints, used, WHEEL_MAX_POINTS
end

function WheelOfDestiny.getFragments(player, resourceType)
  if resourceType ~= 84 and resourceType ~= 85 then
    return 0
  end
  return getWheelResourceCount(player, resourceType)
end

function WheelOfDestiny.addFragments(player, resourceType, amount)
  if resourceType ~= 84 and resourceType ~= 85 then
    return -1
  end

  amount = math.floor(tonumber(amount) or 0)
  local current = getWheelResourceCount(player, resourceType)
  if amount == 0 then
    return current
  end

  local updated = math.max(0, current + amount)
  setStorageCount(player, WHEEL_RESOURCE_STORAGES[resourceType], updated)
  return updated
end

function WheelOfDestiny.refresh(player)
  sendWheelFull(player, loadPlayerWheelData(player))
  return true
end
