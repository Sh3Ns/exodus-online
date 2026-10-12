local restrictedDecks = {27632, 27633, 27634}
local storageKeyDeckEquipped = 249576

local function isRestricted(itemId)
  for _, id in ipairs(restrictedDecks) do
    if id == itemId then return true end
  end
  return false
end

function onEquip(player, item, slot, isCheck)
  local id = item:getId()
  if not isRestricted(id) then
    return true
  end

  if isCheck then
    if player:getStorageValue(storageKeyDeckEquipped) > 0 then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one deck at a time.")
      return false
    end
    return true
  end
  player:setStorageValue(storageKeyDeckEquipped, id)
  return true
end


function onDeEquip(player, item, slot, isCheck)
  local id = item:getId()
  if not isRestricted(id) then
    return true
  end

  if isCheck then
    return true
  end

  if player:getStorageValue(storageKeyDeckEquipped) == id then
    player:setStorageValue(storageKeyDeckEquipped, -1)
  end
  return true
end