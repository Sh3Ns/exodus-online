local rewards = {
    { id = 30619, name = "kraxxis device", count = 1},
    { id = 30624, name = "life leaf", count = 4},
    { id = 30626, name = "kraxxis skull", count = 1},
    { id = 30627, name = "decayed rune", count = 2},
    { id = 30623, name = "soul leaf", count = 4},
    { id = 30617, name = "essence of soul", count = 1}
}

local kraxxisBag = Action()

function kraxxisBag.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local rewardItem = rewards[math.random(#rewards)]

  local createdItem = Game.createItem(rewardItem.id, rewardItem.count)
  if not createdItem then
    player:sendCancelMessage("The reward could not be created.")
    return true
  end

  if player:addItemEx(createdItem) ~= RETURNVALUE_NOERROR then
    createdItem:remove()
    player:sendCancelMessage("You don't have enough space for the reward.")
    return true
  end

  item:remove(1)

  player:sendTextMessage(MESSAGE_INFO_DESCR, "You received " .. rewardItem.count .. "x " .. rewardItem.name .. ".")
  playSoundPlayer(player, "open_bag.ogg")
  return true
end
kraxxisBag:id(30629)
kraxxisBag:register()