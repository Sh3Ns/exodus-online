local restrictedBelts = {29578,29591,29592,29593,29594,29595,29596,29597,29598,29914,29915,29916}
local storageKeyBeltEquipped = 249574

local function isRestricted(id)
  for _, bid in ipairs(restrictedBelts) do
    if bid == id then return true end
  end
  return false
end

function onEquip(player, item, slot, isCheck)
  local id = item:getId()
  if not isRestricted(id) then return true end

  if isCheck then
    if player:getStorageValue(storageKeyBeltEquipped) > 0 then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one belt at a time.")
      return false
    end
    return true
  end

  player:setStorageValue(storageKeyBeltEquipped, id)
  return true
end

function onDeEquip(player, item, slot, isCheck)
  local id = item:getId()
  if not isRestricted(id) then return true end
  if isCheck then return true end
  if player:getStorageValue(storageKeyBeltEquipped) == id then
    player:setStorageValue(storageKeyBeltEquipped, -1)
  end
  return true
end