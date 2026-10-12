local OPCODE_RARITY_INVENTORY = 210
local RARITY_BASE = 63500
local FORGE_TIER_ATTRIBUTE = "forge_tier"

local INV_SLOTS = {}
for _, c in ipairs({
  CONST_SLOT_HEAD, CONST_SLOT_NECKLACE, CONST_SLOT_BACKPACK, CONST_SLOT_ARMOR,
  CONST_SLOT_RIGHT, CONST_SLOT_LEFT, CONST_SLOT_LEGS, CONST_SLOT_FEET,
  CONST_SLOT_RING, CONST_SLOT_AMMO,
  CONST_SLOT_DECK, CONST_SLOT_BADGE, CONST_SLOT_BELT, CONST_SLOT_GLOVES
}) do
  if type(c) == "number" then table.insert(INV_SLOTS, c) end
end

local function getItemRarityId(item)
  if not item or (type(item.isRemoved) == "function" and item:isRemoved()) then
    return 0
  end
  local ok, rid = pcall(function() return item:getCustomAttribute("rarity") end)
  if not ok then return 0 end
  return (type(rid) == "number" and rid > 0) and rid or 0
end

local function getItemForgeTier(item)
  if not item or (type(item.isRemoved) == "function" and item:isRemoved()) then return 0 end
  local ok, tier = pcall(function() return item:getCustomAttribute(FORGE_TIER_ATTRIBUTE) end)
  tier = ok and tonumber(tier) or 0
  return (tier >= 1 and tier <= 10) and math.floor(tier) or 0
end

local function replyWholeInventory(player)
  local m = {}
  for _, slot in ipairs(INV_SLOTS) do
    local it  = player:getSlotItem(slot)
    local rid = getItemRarityId(it)
    local num = (rid > 0) and (RARITY_BASE + rid) or 0
    m[#m + 1] = { slot, num, getItemForgeTier(it) }
  end
  player:sendExtendedOpcode(OPCODE_RARITY_INVENTORY, json.encode({ a = "invR", m = m }))
end

local function replySingleSlot(player, slot)
  if type(slot) ~= "number" then return end
  local it  = player:getSlotItem(slot)    -- may be nil
  local rid = getItemRarityId(it)
  local num = (rid > 0) and (RARITY_BASE + rid) or 0
  player:sendExtendedOpcode(OPCODE_RARITY_INVENTORY, json.encode({
    a = "invRS", s = slot, n = num, t = getItemForgeTier(it)
  }))
end

local rarityInvEvt = CreatureEvent("rarityFramesInventory")
function rarityInvEvt.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= OPCODE_RARITY_INVENTORY then return true end
  local ok, data = pcall(function() return json.decode(buffer) end)
  if not ok or type(data) ~= "table" then return true end

  if data.a == "invReq" then
    replyWholeInventory(player)
  elseif data.a == "invReqS" then
    replySingleSlot(player, data.s)
  end
  return true
end
rarityInvEvt:type("extendedopcode")
rarityInvEvt:register()

local LoginEvent = CreatureEvent("rarityLoginInventory")
function LoginEvent.onLogin(player)
  player:registerEvent("rarityFramesInventory")
  return true
end
LoginEvent:type("login")
LoginEvent:register()
