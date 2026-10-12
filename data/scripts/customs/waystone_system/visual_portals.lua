local FIRST_ITEM_ID   = 29642
local LAST_ITEM_ID    = 29654
local FIRST_STORAGE   = 139754

local portalVisuals = Action()
function portalVisuals.onUse(player, item, fromPosition, target, toPosition, isHotkey)
  local itemId = item:getId()
  local offset   = itemId - FIRST_ITEM_ID
  local storage  = FIRST_STORAGE + offset

  if player:getStorageValue(storage) == 1 then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "You already own this portal visual.")
    return true
  end

  player:setStorageValue(storage, 1)
  item:remove(1)
  player:sendTextMessage(MESSAGE_INFO_DESCR, "You have obtained this portal visual!")
  return true
end

for id = FIRST_ITEM_ID, LAST_ITEM_ID do
  portalVisuals:id(id)
end
portalVisuals:register()