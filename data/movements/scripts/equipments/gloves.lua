local restrictedGloves = {29577,29582,29583,29584,29586,29587,29588,29589,29590,29917,29918,29919}
local storageKeyGloveEquipped = 249572

local function isRestricted(id)
  for _, gid in ipairs(restrictedGloves) do
    if gid == id then return true end
  end
  return false
end

function onEquip(player, item, slot, isCheck)
  local id = item:getId()
  if not isRestricted(id) then return true end

  if isCheck then
    if player:getStorageValue(storageKeyGloveEquipped) > 0 then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one glove at a time.")
      return false
    end
    return true
  end

  player:setStorageValue(storageKeyGloveEquipped, id)
  return true
end

function onDeEquip(player, item, slot, isCheck)
  local id = item:getId()
  if not isRestricted(id) then return true end
  if isCheck then return true end
  if player:getStorageValue(storageKeyGloveEquipped) == id then
    player:setStorageValue(storageKeyGloveEquipped, -1)
  end
  return true
end