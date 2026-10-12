--- Corruption System ---

print(">> [Professions: Corruption System] Loaded")

-- Corruption system is a new system that innovates the game in another way, giving players the chance to upgrade their items with special stats, that can be removed later if wanted or create a simple dream item corrupting it, but with a risk of failing and lose 20% of stats, or get 20% bonus stats more on the item getting an unique item. Each stat can be added once, a maximum of 9 stats per item is allowed.
-- In other words i extended the rarity system to be more flexible.
--- Stat , type Single / Pair ( pair is example crit amount + crit chance ), label is used for tooltip, allowedSlots is the item type that can receive the stat, maxvalue is the maximum value that can be obtained for that stat in a normal way, using a special item can go further than the max value and or corrupting the item.

local STATS = {
    -- ELEMENT ATTACK
    element_fire = { type="single", key="rarity_elementfire", label="Element Fire", allowedSlots={"weapon"}, maxValue=15 },
    element_energy = { type="single", key="rarity_elementenergy",label="Element Energy", allowedSlots={"weapon"}, maxValue=15 },
    element_ice  = { type="single", key="rarity_elementice", label="Element Ice", allowedSlots={"weapon"}, maxValue=15 },
    element_earth = { type="single", key="rarity_elementearth", label="Element Earth", allowedSlots={"weapon"}, maxValue=15 },
    element_death = { type="single", key="rarity_elementdeath", label="Element Death", allowedSlots={"weapon"}, maxValue=15 },
    element_holy = { type="single", key="rarity_elementholy", label="Element Holy", allowedSlots={"weapon"}, maxValue=15 },
    element_water = { type="single", key="rarity_elementwater", label="Element Water", allowedSlots={"weapon"}, maxValue=15 },
    element_arcane = { type="single", key="rarity_elementarcane", label="Element Arcane", allowedSlots={"weapon"}, maxValue=15 },

    --  ABSORB
    absorb_physical = { type="single", key="rarity_physicalAbsorb", label="Physical Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_energy = { type="single", key="rarity_energyAbsorb", label="Energy Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_earth = { type="single", key="rarity_earthAbsorb", label="Earth Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_fire = { type="single", key="rarity_fireAbsorb", label="Fire Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_drown = { type="single", key="rarity_drownAbsorb", label="Drown Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_ice = { type="single", key="rarity_iceAbsorb", label="Ice Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_holy = { type="single", key="rarity_holyAbsorb", label="Holy Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_death = { type="single", key="rarity_deathAbsorb", label="Death Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_water = { type="single", key="rarity_waterAbsorb", label="Water Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },
    absorb_arcane = { type="single", key="rarity_arcaneAbsorb", label="Arcane Absorb", allowedSlots={"helmet","armor","legs","boots","gloves","belt","ring","necklace","shield"}, maxValue=4 },

    -- SKILLS
    skill_fist = { type="single", key="rarity_fistSkill", label="Fist Fighting", allowedSlots={"wand","weapon","gloves","armor","ring","necklace","belt","legs"}, maxValue=4 },
    skill_club = { type="single", key="rarity_clubSkill", label="Club Fighting", allowedSlots={"wand","weapon","gloves","armor","ring","necklace","belt","legs"}, maxValue=4 },
    skill_sword = { type="single", key="rarity_swordSkill", label="Sword Fighting", allowedSlots={"wand","weapon","gloves","armor","ring","necklace","belt","legs"}, maxValue=4 },
    skill_axe = { type="single", key="rarity_axeSkill", label="Axe Fighting", allowedSlots={"wand","weapon","gloves","armor","ring","necklace","belt","legs"}, maxValue=4 },
    skill_distance = { type="single", key="rarity_distanceSkill", label="Distance Fighting", allowedSlots={"wand","weapon","gloves","armor","ring","necklace","belt","legs"}, maxValue=4 },
    skill_shield = { type="single", key="rarity_shieldSkill", label="Shielding", allowedSlots={"wand","weapon","shield","armor","ring","necklace","belt","gloves","legs"}, maxValue=4 },
    skill_fishing = { type="single", key="rarity_fishingSkill", label="Fishing", allowedSlots={"ring","necklace","belt","boots","legs","helmet"}, maxValue=4 },
    skill_crafting = { type="single", key="rarity_craftingSkill", label="Crafting", allowedSlots={"ring","necklace","belt","gloves","legs","helmet"}, maxValue=4 },
    skill_woodcutting = { type="single", key="rarity_woodcuttingSkill", label="Woodcutting", allowedSlots={"ring","necklace","belt","gloves","legs","helmet"}, maxValue=4 },
    skill_mining  = { type="single", key="rarity_miningSkill", label="Mining", allowedSlots={"ring","necklace","belt","gloves","legs","helmet"}, maxValue=4 },
    skill_herbalist = { type="single", key="rarity_herbalistSkill", label="Herbalist", allowedSlots={"ring","necklace","belt","gloves","legs","helmet"}, maxValue=4 },
    skill_armorsmith = { type="single", key="rarity_armorsmithSkill", label="Armorsmith", allowedSlots={"ring","necklace","belt","gloves","legs","helmet"}, maxValue=4 },
    skill_weaponsmith = { type="single", key="rarity_weaponsmithSkill", label="Weaponsmith", allowedSlots={"ring","necklace","belt","gloves","legs","helmet"}, maxValue=4 },
    skill_jewelsmith = { type="single", key="rarity_jewelsmithSkill", label="Jewelsmith", allowedSlots={"ring","necklace","belt","gloves","legs","helmet"}, maxValue=4 },
    skill_maglevel = { type="single", key="rarity_maglevelSkill", label="Magic Level", allowedSlots={"wand","weapon","ring","necklace","armor","legs"}, maxValue=4 },

    crit = {type="pair", key1="rarity_criticalHitChance", key2="rarity_criticalHitAmount", label1="Critical Hit", label2="Critical Chance",allowedSlots={"wand","weapon","ring","necklace","armor"}, maxValue=4},
    mana_leech = {type="pair", key1="rarity_manaLeechChance", key2="rarity_manaLeechAmount", label1="Mana Chance", label2="Mana Amount", allowedSlots={"wand","weapon","ring","necklace","armor"}, maxValue=4},
    life_leech = {type="pair", key1="rarity_lifeLeechChance", key2="rarity_lifeLeechAmount", label1="Life Chance", label2="Life Amount", allowedSlots={"wand","weapon","ring","necklace"}, maxValue=4},
}

--- 3 Firsts lines, are lines for catalyst upgrade stats, so 3 catalyst per stat.
--- 4th line is for adding the stat , the same, but with a special value higher than the 3 previous stats, so a rare stat that can be obtained.
--- 5th line is the remover of the stat, so an item that will remove the stat from the item, entirely means, normal and special stats added.
--- CORRUPTION TIERS:
--- After that, after reaching all stats maxed out, hardcoded to 7 stats max per item, you can corrupt the item that will give a "Corruption" tag on the item , you will get a chance of +5% bonus stats if sucessfully corrupting it or -5% if fails, it will lock the item, after this you can continue Corrupting it to Void Corruption +5% (70%), +10% (25%) or -10% (5%) to all stats, then upgrade to next corruption: Ancient Corruption, It doubles one stat, it adds a new stat bonus (From 9 stats it becomes 10) the 10th stat cannot be choicen it's random, or the item reinitialize. Then Upgrade to next corruption: Infernal Corruption, it doubles one stat again and adds a new stat from 10 to 11th, the 11th cannot be choicen it's random, it breaks the item if fail (protection item can be used to avoid breaking the item). Then last Corruption: Fractured , it's the last one, legendary corruption, it add a new Stat from 11 to 12th cannot be choicen, it's random, it adds also depending the weapon, if it's a weapon (only weapon) a new storage, unlocking a new spell, one spell per weapon class can be unlocked, but warning, only per vocation, means if a player wants to unlock rod (for druid) class then it can't use the spell, only illusionist can use druid/sorc spell. The spell will check if player has the item equipped with Fractured corruption, if it has not fractured, then spell won't work.
--- As RPG i didnt add a new line , but is possible, in order to create craft or anything else, a new item used to "remove the corruption" of the item, i didn't create it since doesnt make sense at this moment.
--- Is possible to extend this script.

local STAT_CATALYST = {
  -- ELEMENT ATTACK
  element_fire = {
    { itemId = 30286, min = 1, max = 10, consume = 1 },
    { itemId = 30355, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30322, remove = true, consume = 1 },
  },

  element_energy = {
    { itemId = 30285, min = 1, max = 10, consume = 1 },
    { itemId = 30354, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30320, remove = true, consume = 1 },
  },

  element_ice = {
    { itemId = 30288, min = 1, max = 10, consume = 1 },
    { itemId = 30357, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30328, remove = true, consume = 1 },
  },

  element_earth = {
    { itemId = 30284, min = 1, max = 10, consume = 1 },
    { itemId = 30353, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30318, remove = true, consume = 1 },
  },

  element_death = {
    { itemId = 30283, min = 1, max = 10, consume = 1 },
    { itemId = 30352, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30314, remove = true, consume = 1 },
  },

  element_holy = {
    { itemId = 30287, min = 1, max = 10, consume = 1 },
    { itemId = 30356, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30326, remove = true, consume = 1 },
  },

  element_water = {
    { itemId = 30289, min = 1, max = 10, consume = 1 },
    { itemId = 30358, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30338, remove = true, consume = 1 },
  },

  element_arcane = {
    { itemId = 30282, min = 1, max = 10, consume = 1 },
    { itemId = 30351, min = 11, max = 15, consume = 1, special = true },
    { itemId = 30307, remove = true, consume = 1 },
  },

  -- ABSORB
  absorb_physical = {
    { itemId = 30280, min = 1, max = 3, consume = 1 },
    { itemId = 30349, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30334, remove = true, consume = 1 },
  },

  absorb_energy = {
    { itemId = 30276, min = 1, max = 3, consume = 1 },
    { itemId = 30345, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30319, remove = true, consume = 1 },
  },

  absorb_earth = {
    { itemId = 30275, min = 1, max = 3, consume = 1 },
    { itemId = 30344, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30317, remove = true, consume = 1 },
  },

  absorb_fire = {
    { itemId = 30277, min = 1, max = 3, consume = 1 },
    { itemId = 30346, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30321, remove = true, consume = 1 },
  },

  absorb_drown = {
    { itemId = 30274, min = 1, max = 3, consume = 1 },
    { itemId = 30343, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30316, remove = true, consume = 1 },
  },

  absorb_ice = {
    { itemId = 30279, min = 1, max = 3, consume = 1 },
    { itemId = 30348, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30327, remove = true, consume = 1 },
  },

  absorb_holy = {
    { itemId = 30278, min = 1, max = 3, consume = 1 },
    { itemId = 30347, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30325, remove = true, consume = 1 },
  },

  absorb_death = {
    { itemId = 30273, min = 1, max = 3, consume = 1 },
    { itemId = 30342, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30313, remove = true, consume = 1 },
  },

  absorb_water = {
    { itemId = 30281, min = 1, max = 3, consume = 1 },
    { itemId = 30350, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30337, remove = true, consume = 1 },
  },

  absorb_arcane = {
    { itemId = 30272, min = 1, max = 3, consume = 1 },
    { itemId = 30341, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30306, remove = true, consume = 1 },
  },

  -- SKILLS
  skill_fist = {
    { itemId = 30296, min = 1, max = 3, consume = 1 },
    { itemId = 30365, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30323, remove = true, consume = 1 },
  },

  skill_club = {
    { itemId = 30292, min = 1, max = 3, consume = 1 },
    { itemId = 30361, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30310, remove = true, consume = 1 },
  },

  skill_sword = {
    { itemId = 30303, min = 1, max = 3, consume = 1 },
    { itemId = 30372, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30336, remove = true, consume = 1 },
  },

  skill_axe = {
    { itemId = 30291, min = 1, max = 3, consume = 1 },
    { itemId = 30360, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30309, remove = true, consume = 1 },
  },

  skill_distance = {
    { itemId = 30295, min = 1, max = 3, consume = 1 },
    { itemId = 30364, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30315, remove = true, consume = 1 },
  },

  skill_shield = {
    { itemId = 30397, min = 1, max = 3, consume = 1 },
    { itemId = 30399, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30335, remove = true, consume = 1 },
  },

  skill_fishing = {
    { itemId = 30398, min = 1, max = 3, consume = 1 },
    { itemId = 30400, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30401, remove = true, consume = 1 },
  },

  skill_crafting = {
    { itemId = 30293, min = 1, max = 3, consume = 1 },
    { itemId = 30362, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30311, remove = true, consume = 1 },
  },

  skill_woodcutting = {
    { itemId = 30305, min = 1, max = 3, consume = 1 },
    { itemId = 30374, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30340, remove = true, consume = 1 },
  },

  skill_mining = {
    { itemId = 30302, min = 1, max = 3, consume = 1 },
    { itemId = 30371, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30333, remove = true, consume = 1 },
  },

  skill_herbalist = {
    { itemId = 30297, min = 1, max = 3, consume = 1 },
    { itemId = 30366, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30324, remove = true, consume = 1 },
  },

  skill_armorsmith = {
    { itemId = 30290, min = 1, max = 3, consume = 1 },
    { itemId = 30359, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30308, remove = true, consume = 1 },
  },

  skill_weaponsmith = {
    { itemId = 30304, min = 1, max = 3, consume = 1 },
    { itemId = 30373, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30339, remove = true, consume = 1 },
  },

  skill_jewelsmith = {
    { itemId = 30298, min = 1, max = 3, consume = 1 },
    { itemId = 30367, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30329, remove = true, consume = 1 },
  },

  skill_maglevel = {
    { itemId = 30300, min = 1, max = 3, consume = 1 },
    { itemId = 30369, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30331, remove = true, consume = 1 },
  },

  -- SPECIAL
  crit = {
    { itemId = 30294, min = 1, max = 3, consume = 1 },
    { itemId = 30363, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30312, remove = true, consume = 1 },
  },

  mana_leech = {
    { itemId = 30301, min = 1, max = 3, consume = 1 },
    { itemId = 30370, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30332, remove = true, consume = 1 },
  },

  life_leech = {
    { itemId = 30299, min = 1, max = 3, consume = 1 },
    { itemId = 30368, min = 4, max = 6, consume = 1, special = true },
    { itemId = 30330, remove = true, consume = 1 },
  },
}


local EXCLUDED_ITEM_IDS = {
  -- Excluded specific items if needed, exodus is build without a limit of items, but using slots check
  -- for example you want to block let's say "magic longsword" so add it here and all Sword slots will check and skip it.
  -- [22222] = true,
}

local MaxStatsPerItem = 7 -- Max Stats on an item. Also required this max Stat to start corrupting
local CorruptionItemId = 30390 -- Corrupted item catalyst
local CorruptionChance = 0.5 -- Corrupted Chance
local VoidCatalystId = 30391 --- Void Corruption Item Id Chance 50/50
local AncientCatalystId = 30392 -- Ancient Corruption Item Id
local AncientChance = 0.5 -- Ancient Chance 50/50
local InfernalCatalystId = 30393 -- Infernal Corruption Item Id
local InfernalProtectionId = 30395 -- Infernal Protection Item Id -- If no item , item breaks on fail
local InfernalChance = 0.4 -- Infernal Chance 40/60 % fail
local FracturedCatalystId = 30394 -- Fractured Item Id  
local FracturedChance = 0.4 -- Fractured Chance 40% - 60% fail
local FracturedProtectionId = 30396 -- Fractured Protection Item Id -- If no item , item breaks on fail

local RarityTableLevels = {
  [1]  = { levelMin = 1,   levelMax = 10 },
  [2]  = { levelMin = 11,  levelMax = 20 },
  [3]  = { levelMin = 21,  levelMax = 30 },
  [4]  = { levelMin = 31,  levelMax = 40 },
  [5]  = { levelMin = 41,  levelMax = 50 },
  [6]  = { levelMin = 51,  levelMax = 60 },
  [7]  = { levelMin = 61,  levelMax = 70 },
  [8]  = { levelMin = 71,  levelMax = 80 },
  [9]  = { levelMin = 81,  levelMax = 90 },
  [10] = { levelMin = 91,  levelMax = 100 },
  [11] = { levelMin = 101, levelMax = 110 },
  [12] = { levelMin = 111, levelMax = 120 },
  [13] = { levelMin = 121, levelMax = 130 },
  [14] = { levelMin = 131, levelMax = 140 },
  [15] = { levelMin = 141, levelMax = 150 },
}

local EXCLUSIVE_GROUPS = {
  element_attack = {
    "element_fire",
    "element_energy",
    "element_ice",
    "element_earth",
    "element_death",
    "element_holy",
    "element_water",
    "element_arcane"
  }
}

local function getExclusiveGroup(statId)
  for groupName, statList in pairs(EXCLUSIVE_GROUPS) do
    for _, id in ipairs(statList) do
      if id == statId then
        return groupName, statList
      end
    end
  end
  return nil, nil
end

local function isElementAttackStat(statId)
  local _, groupStats = getExclusiveGroup(statId)
  return groupStats ~= nil
end

local function lockItem(item)
  item:setCustomAttribute("corrupted", true)
end

local function isItemCorrupted(item)
  return item:getCustomAttribute("corrupted") == true
end

local function hasBit(value, bit)
  return value % (bit * 2) >= bit
end

local function hasAnySlot(slotPos, slots)
  for _, bit in ipairs(slots) do
    if hasBit(slotPos, bit) then
      return true
    end
  end
  return false
end

local function bellRoll(min, max)
  local a = math.random()
  local b = math.random()
  local avg = (a + b) / 2

  return math.floor(min + avg * (max - min) + 0.5)
end

local function getAttrNumber(item, key)
  local v = item:getCustomAttribute(key)
  if v == nil then return nil end
  if type(v) == "number" then return v end
  if type(v) == "userdata" and v.value then
    local n = tonumber(v.value)
    return n
  end
  return tonumber(v)
end

local function addItemLevels(item, amount)
  local level = getAttrNumber(item, "combatPowerLevel")
  local rarityId = getAttrNumber(item, "rarity")

  if not level or not rarityId then return end

  local data = RarityTableLevels[rarityId]
  if not data then return end

  level = math.max(data.levelMin, math.min(level + amount, data.levelMax))

  item:setCustomAttribute("combatPowerLevel", level)
end

local function computeMaxItemPower()
  local maxStat = 0
  for _, stat in pairs(STATS) do
    if stat.maxValue > maxStat then
      maxStat = stat.maxValue
    end
  end

  return MaxStatsPerItem * maxStat
end

local VALID_EQUIP_SLOTS = {
  SLOTP_HEAD,
  SLOTP_NECKLACE,
  SLOTP_ARMOR,
  SLOTP_RIGHT,
  SLOTP_LEFT,
  SLOTP_LEGS,
  SLOTP_FEET,
  SLOTP_RING,
  SLOTP_BELT,
  SLOTP_GLOVES,
  SLOTP_DECK,
  SLOTP_BADGE
}

local function isEquipableItem(item)
  if not item or not item:isItem() then return false end
  if EXCLUDED_ITEM_IDS[item:getId()] then return false end

  local it = ItemType(item:getId())
  if not it then return false end
  if it:isContainer() or it:isStackable() then return false end

  local slotPos = it:getSlotPosition()
  return hasAnySlot(slotPos, VALID_EQUIP_SLOTS)
end

local function isInsideContainer(item)
  local parent = item:getParent()
  return parent and parent:isContainer()
end

local function getSlotType(it)
  if not it then return nil end

  local wt = it:getWeaponType()

  if wt == WEAPON_WAND then
    return "wand"
  end

  if wt ~= WEAPON_NONE then
    return "weapon"
  end

  local sp = it:getSlotPosition()
  if hasBit(sp, SLOTP_HEAD) then return "helmet" end
  if hasBit(sp, SLOTP_NECKLACE) then return "necklace" end
  if hasBit(sp, SLOTP_ARMOR) then return "armor" end
  if hasBit(sp, SLOTP_LEGS) then return "legs" end
  if hasBit(sp, SLOTP_FEET) then return "boots" end
  if hasBit(sp, SLOTP_RING) then return "ring" end
  if hasBit(sp, SLOTP_BELT) then return "belt" end
  if hasBit(sp, SLOTP_GLOVES) then return "gloves" end
  if hasBit(sp, SLOTP_DECK) then return "deck" end
  if hasBit(sp, SLOTP_BADGE) then return "badge" end
  if hasBit(sp, SLOTP_LEFT) or hasBit(sp, SLOTP_RIGHT) then return "weapon" end

  return nil
end

local function tableContains(t, v)
  for _, x in ipairs(t) do
    if x == v then return true end
  end
  return false
end

local CatalystLookup = {}
for statId, tiers in pairs(STAT_CATALYST) do
  for tierIndex, t in ipairs(tiers) do
    CatalystLookup[t.itemId] = {
      statId = statId,
      tier = tierIndex,
      min = t.min,
      max = t.max,
      consume = t.consume or 1,
      special = t.special,
      remove = t.remove
    }
  end
end

local function getSpecialFlagKey(statId)
  return "__special_used_" .. statId
end

local function countStats(item)
  local total = 0
  for _, stat in pairs(STATS) do
    if stat.type == "single" then
      local v = getAttrNumber(item, stat.key)
      if v and v > 0 then
        total = total + 1
      end
    else
      local v = getAttrNumber(item, stat.key1)
      if v and v > 0 then
        total = total + 1
      end
    end
  end
  return total
end

local function removeStat(item, statId)
  local stat = STATS[statId]
  if not stat then
    return false
  end

  if stat.type == "single" then
    item:removeCustomAttribute(stat.key)
  else
    item:removeCustomAttribute(stat.key1)
    item:removeCustomAttribute(stat.key2)
  end

  item:removeCustomAttribute(getSpecialFlagKey(statId))

  if countStats(item) == 0 then
    item:removeCustomAttribute("has_custom_stats")
    item:removeCustomAttribute("rarity")
    item:removeCustomAttribute("rarityLevelMin")
    item:removeCustomAttribute("rarityLevelMax")
    item:removeCustomAttribute("combatPowerLevel")
  end

  return true
end

local function getCurrentStatValue(item, statId)
  local stat = STATS[statId]
  if stat.type == "single" then
    return getAttrNumber(item, stat.key) or 0
  else
    return getAttrNumber(item, stat.key1) or 0
  end
end

local function computeCurrentPower(item)
  local current = 0

  for _, stat in pairs(STATS) do
    if stat.type == "single" then
      local v = getAttrNumber(item, stat.key)
      if v and v > 0 then
        current = current + v
      end
    else
      local v = getAttrNumber(item, stat.key1)
      if v and v > 0 then
        current = current + v
      end
    end
  end

  return current
end

local TotalMaxLevel = computeMaxItemPower()
local LevelPerTier = TotalMaxLevel / 15

local function rollItemLevel(rarityId)
  local data = RarityTableLevels[rarityId]
  if not data then return nil end
  return math.random(data.levelMin, data.levelMax)
end

local function levelToRarity(currentPower)
  if currentPower <= 0 then
    return 0
  end

  local tier = math.floor(currentPower / LevelPerTier) + 1
  if tier > 15 then tier = 15 end
  return tier
end

local function updateDerivedRarity(item)
  local currentPower = computeCurrentPower(item)
  local rarityId = levelToRarity(currentPower)

  if rarityId <= 0 then return end

  local data = RarityTableLevels[rarityId]
  if not data then return end

  local prevRarity = getAttrNumber(item, "rarity") or 0

  item:setCustomAttribute("rarity", rarityId)
  item:setCustomAttribute("rarityLevelMin", data.levelMin)
  item:setCustomAttribute("rarityLevelMax", data.levelMax)
  item:setActionId(63500 + rarityId)

  if rarityId ~= prevRarity then
    local level = rollItemLevel(rarityId)
    if level then
      item:setCustomAttribute("combatPowerLevel", level)
    end
  end
end

local function canApplyStatToItem(statId, item)
  local stat = STATS[statId]
  if not stat then return false, "Unknown stat." end

  local it = ItemType(item:getId())
  local slotType = getSlotType(it)
  if not slotType then
    return false, "This item has no valid equip slot."
  end

  if not tableContains(stat.allowedSlots, slotType) then
    return false, "This stat cannot be applied on this slot type."
  end

  return true
end

local function refreshRarityDescription(item)
  local base = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION) or ""
  local function trim(text)
    return text:match("^%s*(.-)%s*$") or ""
  end

  local function escapePattern(text)
    return text:gsub("([^%w%s])", "%%%1")
  end

  local statPatterns = {
    "^Level:%s*%d+$"
  }

  for _, stat in pairs(STATS) do
    if stat.type == "single" then
      table.insert(statPatterns, "^" .. escapePattern(stat.label) .. "%s+%+%d+" .. escapePattern(stat.suffix or "") .. "$")
    else
      table.insert(statPatterns, "^" .. escapePattern(stat.label1) .. "%s+%+%d+" .. escapePattern(stat.suffix or "") .. "$")
      table.insert(statPatterns, "^" .. escapePattern(stat.label2) .. "%s+%+%d+" .. escapePattern(stat.suffix or "") .. "$")
    end
  end

  local function isCorruptionStatText(text)
    for _, pattern in ipairs(statPatterns) do
      if text:match(pattern) then
        return true
      end
    end

    return false
  end

  local cleanedLines = {}

  for line in base:gmatch("[^\r\n]+") do
    local keptSegments = {}
    local removedSegment = false

    for segment in line:gmatch("[^,]+") do
      local cleanedSegment = trim(segment)
      if cleanedSegment ~= "" then
        if isCorruptionStatText(cleanedSegment) then
          removedSegment = true
        else
          table.insert(keptSegments, cleanedSegment)
        end
      end
    end

    if removedSegment then
      if #keptSegments > 0 then
        table.insert(cleanedLines, table.concat(keptSegments, ", "))
      end
    else
      local trimmedLine = trim(line)
      if trimmedLine ~= "" then
        table.insert(cleanedLines, trimmedLine)
      end
    end
  end

  local parts = {}

  local lvl = getAttrNumber(item, "combatPowerLevel")
  if lvl and lvl > 0 then
    table.insert(parts, "Level: " .. lvl)
  end

  for _, stat in pairs(STATS) do
    if stat.type == "single" then
      local v = getAttrNumber(item, stat.key)
      if v and v > 0 then
        table.insert(parts, string.format("%s +%d%s", stat.label, v, stat.suffix or ""))
      end
    else
      local v = getAttrNumber(item, stat.key1)
      if v and v > 0 then
        table.insert(parts, string.format("%s +%d%s", stat.label1, v, stat.suffix or ""))
        table.insert(parts, string.format("%s +%d%s", stat.label2, v, stat.suffix or ""))
      end
    end
  end

  local grouped = {}
  local temp = {}

  for _, text in ipairs(parts) do
    table.insert(temp, text)

    if #temp >= 7 then
      table.insert(grouped, table.concat(temp, ", "))
      temp = {}
    end
  end

  if #temp > 0 then
    table.insert(grouped, table.concat(temp, ", "))
  end

  for _, line in ipairs(grouped) do
    table.insert(cleanedLines, line)
  end

  item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, table.concat(cleanedLines, "\n"))
end

local function hasStat(item, statId)
  local stat = STATS[statId]
  if not stat then return false end

  if stat.type == "single" then
    local v = getAttrNumber(item, stat.key)
    return v ~= nil and v > 0
  else
    local v = getAttrNumber(item, stat.key1)
    return v ~= nil and v > 0
  end
end

local function applyOrRerollStat(item, statId, minVal, maxVal)
  local stat = STATS[statId]
  local rolled = bellRoll(minVal, maxVal)

  item:setCustomAttribute("has_custom_stats", true)

  if stat.type == "single" then
    item:setCustomAttribute(stat.key, rolled)
    return string.format("%s set to %d%s", stat.label, rolled, stat.suffix or "")
  else
    item:setCustomAttribute(stat.key1, rolled)
    item:setCustomAttribute(stat.key2, rolled)
    return string.format("%s + %s set to %d%s", stat.label1, stat.label2, rolled, stat.suffix or "")
  end
end

local function onUseCatalyst(player, catalystItem, targetItem)
  if not targetItem or not targetItem:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item.")
    return true
  end

  if isItemCorrupted(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item is corrupted and cannot be modified.")
    return true
  end

  if not isInsideContainer(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Move the item into your backpack first.")
    return true
  end

  if not isEquipableItem(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item is not eligible (equipables only).")
    return true
  end

  local catalystInfo = CatalystLookup[catalystItem:getId()]
  if not catalystInfo then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Unknown catalyst.")
    return true
  end

  local statId = catalystInfo.statId
  local currentStats = countStats(targetItem)
  local alreadyHas = hasStat(targetItem, statId)
  local _, groupStats = getExclusiveGroup(statId)

  if groupStats then
    for _, otherStatId in ipairs(groupStats) do
      if otherStatId ~= statId and hasStat(targetItem, otherStatId) then
        local otherStat = STATS[otherStatId]
        player:sendTextMessage(MESSAGE_INFO_DESCR,
          string.format("This item already has %s. Only one elemental attack can be applied.",
          otherStat.label))
        return true
      end
    end
  end
  if catalystInfo.remove then
    if not hasStat(targetItem, statId) then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "This item does not have this stat.")
      return true
    end

    removeStat(targetItem, statId)
    updateDerivedRarity(targetItem)
    refreshRarityDescription(targetItem)
    catalystItem:remove(catalystInfo.consume)

    local removedText

    if STATS[statId].type == "single" then
      removedText = STATS[statId].label
    else
      removedText = STATS[statId].label1 .. " / " .. STATS[statId].label2
    end

    player:sendTextMessage(MESSAGE_INFO_DESCR, removedText .. " has been removed.")
    return true
  end

  if not alreadyHas and currentStats >= MaxStatsPerItem then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "This item already has the maximum number of stats.")
      return true
  end

  local currentValue = getCurrentStatValue(targetItem, statId)

  if catalystInfo.special then
    local flagKey = getSpecialFlagKey(statId)
    local alreadyUsed = targetItem:getCustomAttribute(flagKey)

    if alreadyUsed then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "This item has already been empowered for this stat.")
      return true
    end
  end

  if not catalystInfo.special then
    local flagKey = getSpecialFlagKey(statId)
    if targetItem:getCustomAttribute(flagKey) then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "This stat has been empowered and can no longer be modified.")
      return true
    end
  end

  if not catalystInfo.special and currentValue >= catalystInfo.max then
    player:sendTextMessage(MESSAGE_INFO_DESCR,
    string.format("%s is already at the maximum value (%d) for this catalyst tier, use the next tier catalyst to increment stat if possible.", STATS[statId].label, catalystInfo.max))
    return true
  end

  local ok, err = canApplyStatToItem(statId, targetItem)
  if not ok then
    player:sendTextMessage(MESSAGE_INFO_DESCR, err)
    return true
  end

  local msg = applyOrRerollStat(targetItem, statId, catalystInfo.min, catalystInfo.max)

  if catalystInfo.special then
    targetItem:setCustomAttribute(getSpecialFlagKey(statId), 1)
  end

  updateDerivedRarity(targetItem)
  refreshRarityDescription(targetItem)
  catalystItem:remove(catalystInfo.consume)
  player:sendTextMessage(MESSAGE_INFO_DESCR, msg)
  return true
end

for catalystItemId, _ in pairs(CatalystLookup) do
  local a = Action()
  function a.onUse(player, catalystItem, fromPos, target, toPos, isHotkey)
    return onUseCatalyst(player, catalystItem, target)
  end
  a:id(catalystItemId)
  a:register()
end

local function hasMaxStats(item)
  return countStats(item) >= MaxStatsPerItem
end

local function applyCorruption(item)
  local isPositive = math.random() < CorruptionChance

  for _, stat in pairs(STATS) do
    local currentValue

    if stat.type == "single" then
      currentValue = getAttrNumber(item, stat.key)
    else
      currentValue = getAttrNumber(item, stat.key1)
    end

    if currentValue and currentValue > 0 then
      local multiplier = isPositive and 1.05 or 0.95
      local newValue = math.floor(currentValue * multiplier)

      if newValue < 1 then newValue = 1 end
      if stat.type == "single" then
        item:setCustomAttribute(stat.key, newValue)
      else
        item:setCustomAttribute(stat.key1, newValue)
        item:setCustomAttribute(stat.key2, newValue)
      end
    end
  end

  local rarityId = getAttrNumber(item, "rarity")
  local level = getAttrNumber(item, "combatPowerLevel")

  if rarityId and level then
    local data = RarityTableLevels[rarityId]
    if data then
      if isPositive then
        addItemLevels(item, 5)
      else
        addItemLevels(item, -5)
      end
    end
  end

  updateDerivedRarity(item)
  refreshRarityDescription(item)
end

local function onUseCorruptionItem(player, corruptionItem, targetItem)
  if not targetItem or not targetItem:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item.")
    return true
  end

  if not isEquipableItem(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item is not eligible for corruption (equipables only).")
    return true
  end

  if not hasMaxStats(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item does not have max stats and cannot be corrupted.")
    return true
  end

  if isItemCorrupted(targetItem)
  or targetItem:getCustomAttribute("void_corrupted")
  or targetItem:getCustomAttribute("ancient_corrupted")
  or targetItem:getCustomAttribute("infernal_corrupted") 
  or targetItem:getCustomAttribute("fractured") then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "This item has already undergone corruption.")
      return true
  end

  applyCorruption(targetItem)
  lockItem(targetItem)

  corruptionItem:remove(1)

  player:sendTextMessage(MESSAGE_INFO_DESCR, "This item has been corrupted and locked.")
  return true
end

local corruption = Action()
function corruption.onUse(player, corruptionItem, fromPos, target, toPos, isHotkey)
  return onUseCorruptionItem(player, corruptionItem, target)
end
corruption:id(CorruptionItemId)
corruption:register()

local function applyVoidCorruption(item)
  local roll = math.random(100)

  local multiplier

  if roll <= 70 then
    multiplier = 1.05
  elseif roll <= 95 then
    multiplier = 1.10
  else
    multiplier = 0.90
  end

  for _, stat in pairs(STATS) do
    local current

    if stat.type == "single" then
      current = getAttrNumber(item, stat.key)
    else
      current = getAttrNumber(item, stat.key1)
    end

    if current and current > 0 then
      local newVal = math.floor(current * multiplier)

      if newVal < 1 then newVal = 1 end

      if stat.type == "single" then
        item:setCustomAttribute(stat.key, newVal)
      else
        item:setCustomAttribute(stat.key1, newVal)
        item:setCustomAttribute(stat.key2, newVal)
      end
    end
  end

  updateDerivedRarity(item)
  addItemLevels(item, 15)
  refreshRarityDescription(item)
end

local function onUseVoidCatalyst(player, catalystItem, targetItem)
  if not targetItem then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item.")
    return true
  end

  if type(targetItem) ~= "userdata" or not targetItem.isItem or not targetItem:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item.")
    return true
  end

  if not isItemCorrupted(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Only corrupted items can undergo Void Corruption.")
    return true
  end

  if targetItem:getCustomAttribute("void_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item already endured Void Corruption.")
    return true
  end

  if targetItem:getCustomAttribute("ancient_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item already endured Ancient Corruption.")
    return true
  end

  if targetItem:getCustomAttribute("infernal_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item already endured Infernal Corruption.")
    return true
  end

  if targetItem:getCustomAttribute("fractured") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item is already Fractured.")
    return true
  end

  applyVoidCorruption(targetItem)

  targetItem:setCustomAttribute("void_corrupted", true)

  catalystItem:remove(1)

  player:sendTextMessage(MESSAGE_INFO_DESCR, "Void energy mutates the item...")
  return true
end

local void = Action()
function void.onUse(player, item, fromPos, target, toPos, isHotkey)
  return onUseVoidCatalyst(player, item, target)
end
void:id(VoidCatalystId)
void:register()

local function applyAncientCorruption(player, item)
  local win = math.random() < AncientChance

  if not win then
    local id = item:getId()
    local count = item:getCount()
    local parent = item:getParent()

    item:remove()

    if parent and parent:isContainer() then
        parent:addItem(id, count)
    else
        Game.createItem(id, count, player:getPosition())
    end

    player:sendTextMessage(MESSAGE_INFO_DESCR, "Ancient corruption failed... the item shattered and reset.")
    return
  end

  local existingStats = {}

  for statId, stat in pairs(STATS) do
    local value

    if stat.type == "single" then
      value = getAttrNumber(item, stat.key)
    else
      value = getAttrNumber(item, stat.key1)
    end

    if value and value > 0 then
      table.insert(existingStats, statId)
    end
  end

  if #existingStats == 0 then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item has no stats to empower.")
    return
  end

  local chosenId = existingStats[math.random(#existingStats)]
  local stat = STATS[chosenId]

  local current

  if stat.type == "single" then
    current = getAttrNumber(item, stat.key)
  else
    current = getAttrNumber(item, stat.key1)
  end

  local newVal = math.floor(current * 1.35)

  if stat.type == "single" then
    item:setCustomAttribute(stat.key, newVal)
  else
    item:setCustomAttribute(stat.key1, newVal)
    item:setCustomAttribute(stat.key2, newVal)
  end


  item:setCustomAttribute("ancient_corrupted", true)
  addItemLevels(item, 30)
  updateDerivedRarity(item)
  refreshRarityDescription(item)

  local statName

  if stat.type == "single" then
    statName = stat.label
  else
    statName = stat.label1 .. " & " .. stat.label2
  end

  player:sendTextMessage(MESSAGE_INFO_DESCR, "Ancient power surges! " .. statName .. " increased!")

end

local function onUseAncientCatalyst(player, catalystItem, targetItem)
  if not targetItem or not targetItem:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item.")
    return true
  end

  if not targetItem:getCustomAttribute("void_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Only Void Corrupted items can undergo Ancient Corruption.")
    return true
  end

  if targetItem:getCustomAttribute("ancient_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item already endured Ancient Corruption.")
    return true
  end

  applyAncientCorruption(player, targetItem)

  catalystItem:remove(1)
  return true
end

local ancient = Action()
function ancient.onUse(player, item, fromPos, target, toPos, isHotkey)
  return onUseAncientCatalyst(player, item, target)
end
ancient:id(AncientCatalystId)
ancient:register()

local function applyInfernalCorruption(player, item)
  local win = math.random() < InfernalChance

  if not win then
    local pos = item:getPosition()

    local protection = player:getItemById(InfernalProtectionId, true)

    if protection then
      protection:remove(1)

      player:sendTextMessage(MESSAGE_INFO_DESCR,
        "The Infernal seal shattered and saved the item!")

      return
    end

    item:remove()

    player:sendTextMessage(MESSAGE_INFO_DESCR,
      "Infernal corruption consumed the item completely...")

    return
  end

  local existingStats = {}
  local missingStats = {}

  for statId, stat in pairs(STATS) do
    local ok = canApplyStatToItem(statId, item)
      if ok then
        local v

        if stat.type == "single" then
          v = getAttrNumber(item, stat.key)
        else
          v = getAttrNumber(item, stat.key1)
        end

        if v and v > 0 then
          table.insert(existingStats, statId)
        else
          if not isElementAttackStat(statId) then
            table.insert(missingStats, statId)
          end
        end
      end
  end

  if #existingStats == 0 then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Item has no stats to empower.")
    return
  end

  local chosenExisting = existingStats[math.random(#existingStats)]
  local stat = STATS[chosenExisting]

  local current
  if stat.type == "single" then
    current = getAttrNumber(item, stat.key)
  else
    current = getAttrNumber(item, stat.key1)
  end

  local doubled = current * 2

  if stat.type == "single" then
    item:setCustomAttribute(stat.key, doubled)
  else
    item:setCustomAttribute(stat.key1, doubled)
    item:setCustomAttribute(stat.key2, doubled)
  end

  if #missingStats > 0 then
    local chosenNew = missingStats[math.random(#missingStats)]
    local newStat = STATS[chosenNew]

    local maxVal = newStat.maxValue

    if newStat.type == "single" then
      item:setCustomAttribute(newStat.key, maxVal)
    else
      item:setCustomAttribute(newStat.key1, maxVal)
      item:setCustomAttribute(newStat.key2, maxVal)
    end
  end


  item:setCustomAttribute("infernal_corrupted", true)
  addItemLevels(item, 50)
  updateDerivedRarity(item)
  refreshRarityDescription(item)


  player:sendTextMessage(MESSAGE_INFO_DESCR,"Infernal power erupts! One stat doubled and a new stat reached maximum!")

end

local function onUseInfernalCatalyst(player, catalystItem, targetItem)
  if not targetItem or not targetItem:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item.")
    return true
  end

  if not isEquipableItem(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item is not eligible (equipables only).")
    return true
  end

  if not targetItem:getCustomAttribute("ancient_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Only Ancient items can undergo Infernal Corruption.")
    return true
  end

  if targetItem:getCustomAttribute("infernal_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item already endured Infernal Corruption.")
    return true
  end

  applyInfernalCorruption(player, targetItem)

  catalystItem:remove(1)
  return true
end

local infernal = Action()
function infernal.onUse(player, item, fromPos, target, toPos, isHotkey)
  return onUseInfernalCatalyst(player, item, target)
end
infernal:id(InfernalCatalystId)
infernal:register()

local function getFractureAttribute(item)
  local it = ItemType(item:getId())
  if not it then return nil end

  local wt = it:getWeaponType()

  if wt == WEAPON_SWORD or wt == WEAPON_CLUB or wt == WEAPON_AXE then
    return "fractured_melee"

  elseif wt == WEAPON_DISTANCE then
    return "fractured_distance"

  elseif wt == WEAPON_WAND then
    return "fractured_magic"

  elseif wt == WEAPON_FIST then
    return "fractured_fist"
  end

  return nil
end

local function applyFracturedCorruption(player, item)

  local win = math.random() < FracturedChance

  if not win then

    local protection = player:getItemById(FracturedProtectionId, true)

    if protection then
      protection:remove(1)
      player:sendTextMessage(MESSAGE_INFO_DESCR, "Fracture failed! The protection seal shattered and saved the item!")
      return
    end

    item:remove()

    player:sendTextMessage(MESSAGE_INFO_DESCR, "Fracture failed... the item shattered into pieces!")
    return
  end

  if item:getCustomAttribute("fractured") then
    player:sendCancelMessage("This item is already Fractured.")
    return
  end

  local missingStats = {}

  for statId, stat in pairs(STATS) do
    local ok = canApplyStatToItem(statId, item)
      if ok then
        local v
        if stat.type == "single" then
          v = getAttrNumber(item, stat.key)
        else
          v = getAttrNumber(item, stat.key1)
        end

        if not v or v <= 0 then
          if not isElementAttackStat(statId) then
            table.insert(missingStats, statId)
          end
        end
      end
  end

  if #missingStats > 0 then
    local chosen = missingStats[math.random(#missingStats)]
    local stat = STATS[chosen]
    local maxVal = stat.maxValue

    if stat.type == "single" then
      item:setCustomAttribute(stat.key, maxVal)
    else
      item:setCustomAttribute(stat.key1, maxVal)
      item:setCustomAttribute(stat.key2, maxVal)
    end
  end

  item:setCustomAttribute("fractured", true)

  local attr = getFractureAttribute(item)
  if attr then
    item:setCustomAttribute(attr, true)
  end

  addItemLevels(item, 100)
  updateDerivedRarity(item)
  refreshRarityDescription(item)

  player:sendTextMessage(MESSAGE_INFO_DESCR, "Reality shatters... the item becomes Fractured!")
end

local function onUseFracturedCatalyst(player, catalystItem, targetItem)
  if not targetItem or not targetItem:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item.")
    return true
  end

  if not targetItem:getCustomAttribute("infernal_corrupted") then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Only Infernal items can be Fractured.")
    return true
  end

  if targetItem:getCustomAttribute("fractured") then
    player:sendCancelMessage("This item is already Fractured.")
    return true
  end

  applyFracturedCorruption(player, targetItem)

  catalystItem:remove(1)
  return true
end

local fractured = Action()
function fractured.onUse(player, item, fromPos, target, toPos, isHotkey)
  return onUseFracturedCatalyst(player, item, target)
end
fractured:id(FracturedCatalystId)
fractured:register()
