local DIVINE_ORB   = 29857 -- roll a rarity on a item
local ORB_OF_CHAOS = 29856 -- keep rarity, reroll stats


local EXCLUDED_RARITY_IDS = {
    --- Boats Excluded ----
  [27797] = true, -- The Awakener
  [27798] = true, -- The Counterspell
  [27799] = true, -- The Explorer
  [27800] = true, -- Whisperwind
  [27801] = true, -- Menethil March
  [27802] = true, -- Shadowmeld
}

local function isExcludedRarityId(itemId)
  return EXCLUDED_RARITY_IDS[itemId] == true
end

local function rollRarityForReroll(player)
  local rarities = {
    { id = 1, chance = 25.0 }, { id = 2, chance = 18.0 }, { id = 3, chance = 15.0 },
    { id = 4, chance = 12.0 },  { id = 5, chance = 10.0 }, { id = 6, chance = 8.0 },
    { id = 7, chance = 7.0 },  { id = 8, chance = 6.0 }, { id = 9, chance = 5.0 },
    { id = 10, chance = 4.0 }, { id = 11, chance = 3.5 },{ id = 12, chance = 3.0 },
    { id = 13, chance = 2.5 }, { id = 14, chance = 2.0 },{ id = 15, chance = 1.0 },
  }
  --- Chance is 15 base ---
  if math.random(100) > 15 then return 0 end
  for _, r in ipairs(rarities) do
    if math.random(100) <= r.chance then
      return r.id
    end
  end
  return 0
end

local function isRerollable(item)
  if not item or type(item) ~= "userdata" or not item:isItem() then return false end
  if isExcludedRarityId(item:getId()) then return false end
  local it = ItemType(item:getId())
  if not it then return false end
  if it:isContainer() or it:isStackable() then return false end
  if it:getWeaponType() ~= WEAPON_NONE then return true end
  if it:getArmor() > 0 or it:getAttack() > 0 or it:getDefense() > 0 then return true end
  if it:getHitChance() > 0 then return true end
  local ab = it:getAbilities()
  if ab then
    if ab.skills or ab.absorbPercent or ab.specialSkills then return true end
  end
  return false
end

local function replaceItemInContainer(targetItem, newItem)
  local parent = targetItem:getParent()
  if not parent or not parent:isContainer() then
    return false, "Target must be in a container (not equipped/on ground)."
  end

  local ANY_INDEX = _G.INDEX_WHEREEVER or -1

  local ret = parent:addItemEx(newItem, ANY_INDEX)
  if ret ~= RETURNVALUE_NOERROR then
    return false, "Not enough space in container."
  end

  targetItem:remove(1)
  return true
end

local function doReroll(player, orbItem, targetItem, mode)
  if not isRerollable(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item cannot be rerolled.")
    return true
  end

  local parent = targetItem:getParent()
  if not parent or not parent:isContainer() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Move the item into a backpack first.")
    return true
  end

  if isItemLocked(targetItem) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Corrupted or Fractured items cannot be rerolled.")
    return true
  end

  if hasAnyCustomStat(targetItem) then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "Items with custom stats cannot be rerolled.")
      return true
  end

  local targetType = targetItem:getId()
  if isExcludedRarityId(targetType) then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "This item cannot receive rarity.")
    return true
  end
  local count = math.max(1, targetItem:getCount())

  local keepRarity = (mode == "sanctum")
  local currentRarity = 0
  local attr = targetItem:getCustomAttribute("rarity")
  if attr and type(attr) == "number" then
    currentRarity = attr
  elseif attr and type(attr) == "userdata" and attr.value then
    local ok, num = pcall(function() return tonumber(attr.value) end)
    if ok and num then currentRarity = num end
  end

  local rarityId
  if keepRarity then
    if currentRarity == 0 then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "This item has no rarity to reroll stats.")
      return true
    end
    rarityId = currentRarity
  else
    rarityId = rollRarityForReroll(player)
  end

  local newItem
  if rarityId > 0 then
    newItem = Game.createItemWithRarity(targetType, count, rarityId)
  else
    newItem = Game.createItem(targetType, count)
  end

  if not newItem then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Reroll failed: could not create new item.")
    return true
  end

  local ok, err = replaceItemInContainer(targetItem, newItem)
  if not ok then
    newItem:remove()
    player:sendTextMessage(MESSAGE_INFO_DESCR, err or "Reroll failed.")
    return true
  end

  orbItem:remove(1)

  local itName = ItemType(targetType):getName()
  if rarityId > 0 then
    player:sendTextMessage(MESSAGE_INFO_DESCR,
      string.format("%s rerolled: new %s rarity applied.", itName, (getRarityName and getRarityName(rarityId) or ("ID "..rarityId))))
  else
    player:sendTextMessage(MESSAGE_INFO_DESCR,
      string.format("%s rerolled with no rarity.", itName))
  end
  return true
end

local chaos = Action()
function chaos.onUse(player, orbItem, fromPos, target, toPos, isHotkey)
  if not target or not target:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item inside your backpack.")
    return true
  end
  return doReroll(player, orbItem, target, "chaos")
end
chaos:id(DIVINE_ORB)
chaos:register()

local sanctum = Action()
function sanctum.onUse(player, orbItem, fromPos, target, toPos, isHotkey)
  if not target or not target:isItem() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Use this on an item inside your backpack.")
    return true
  end
  return doReroll(player, orbItem, target, "sanctum")
end
sanctum:id(ORB_OF_CHAOS)
sanctum:register()