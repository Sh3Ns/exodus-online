local restrictedBadges        = {
  27803,27804,27805,27806,27807,27808,27809,27810,27811,27812,27813,
  27814,27815,27816,27817,27818,27819,27820,27821,27822,27823,27824,
  27825,27826,27827,27828,27829,27830,27831,27832,27833,27834,27835,
  27836,27837,27838,27839,27840,27841,27842
}
local storageKeyBadgeEquipped = 249578

local function isRestricted(id)
  for _, bid in ipairs(restrictedBadges) do
    if bid == id then return true end
  end
  return false
end

function onEquip(player, item, slot, isCheck)
  local id = item:getId()
  if not isRestricted(id) then
    return true
  end

  if isCheck then
    if player:getStorageValue(storageKeyBadgeEquipped) > 0 then
      player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one badge at a time.")
      return false
    end
    return true
  end

  player:setStorageValue(storageKeyBadgeEquipped, id)
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

  if player:getStorageValue(storageKeyBadgeEquipped) == id then
    player:setStorageValue(storageKeyBadgeEquipped, -1)
  end
  return true
end