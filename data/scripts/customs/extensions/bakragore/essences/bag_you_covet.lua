
local rarities = {
  { id = 1, chance = 10.0, minLevel = 1,   maxLevel = 10 },
  { id = 2, chance = 8.0, minLevel = 11,  maxLevel = 20 },
  { id = 3, chance = 7.0, minLevel = 21,  maxLevel = 30 },
  { id = 4, chance = 6.5, minLevel = 31,  maxLevel = 40 },
  { id = 5, chance = 6.0, minLevel = 41,  maxLevel = 50 },
  { id = 6, chance = 5.5, minLevel = 51,  maxLevel = 60 },
  { id = 7, chance = 5.0, minLevel = 61,  maxLevel = 70 },
  { id = 8, chance = 4.5, minLevel = 71,  maxLevel = 80 },
  { id = 9, chance = 4.0, minLevel = 81,  maxLevel = 90 },
  { id = 10, chance = 3.0, minLevel = 91,  maxLevel = 100 },
  { id = 11, chance = 2.5, minLevel = 101, maxLevel = 110 },
  { id = 12, chance = 2.0, minLevel = 111, maxLevel = 120 },
  { id = 13, chance = 1.5, minLevel = 121, maxLevel = 130 },
  { id = 14, chance = 1.0, minLevel = 131, maxLevel = 140 },
  { id = 15, chance = 0.5, minLevel = 141, maxLevel = 150 },
}

local RarityNames = {
  [1] = "Common",
  [2] = "Uncommon",
  [3] = "Rare",
  [4] = "Epic",
  [5] = "Legendary",
  [6] = "Exotic",
  [7] = "Mythic",
  [8] = "Chaos",
  [9] = "Eternal",
  [10] = "Divine",
  [11] = "Phantasmal",
  [12] = "Celestial",
  [13] = "Cosmic",
  [14] = "Abyssal",
  [15] = "Transcendent",
}

local function rollRarity()
  if math.random(100) > 5 then
      return 0
  end
  for _, r in ipairs(rarities) do
      if math.random(100) <= r.chance then
          return r.id
      end
  end
  return 0
end

local rewards = {
    { id = 27458, name = "Sanguine Blade" },
    { id = 27460, name = "Sanguine Cudgel" },
    { id = 27462, name = "Sanguine Hatchet" },
    { id = 27464, name = "Sanguine Razor" },
    { id = 27466, name = "Sanguine Bludgeon" },
    { id = 27468, name = "Sanguine Battleaxe" },
    { id = 27470, name = "Sanguine Legs" },
    { id = 27471, name = "Sanguine Bow" },
    { id = 29999, name = "Sanguine Trousers"},
    { id = 27473, name = "Sanguine Crossbow" },
    { id = 27475, name = "Sanguine Greaves" },
    { id = 27476, name = "Sanguine Coil" },
    { id = 27478, name = "Sanguine Boots" },
    { id = 27479, name = "Sanguine Rod"},
  	{ id = 27481, name = "Sanguine Galoshes"},
    { id = 29950, name = "Sanguine Claws"}
}

local bagYouCovet = Action()

function bagYouCovet.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local randId = math.random(1, #rewards)
	local rewardItem = rewards[randId]

	local rarityId = rollRarity()
	local createdItem
	if rarityId > 0 then
		createdItem = Game.createItemWithRarity(rewardItem.id, 1, rarityId)
	else
		createdItem = Game.createItem(rewardItem.id, 1)
	end

	if not createdItem then
		player:sendCancelMessage("The reward could not be created.")
		return true
	end

	if player:addItemEx(createdItem) ~= RETURNVALUE_NOERROR then
		player:sendCancelMessage("You don't have enough space for the reward.")
		return true
	end

	if rarityId > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			string.format("You received a %s with rarity: %s!", rewardItem.name, RarityNames[rarityId]))
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received a " .. rewardItem.name .. ".")
	end
  item:remove(1)

	playSoundPlayer(player, "open_bag.ogg")
	return true
end
bagYouCovet:id(27446)
bagYouCovet:register()