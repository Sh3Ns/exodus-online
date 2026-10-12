local config = {
    [1] = { -- Sorcerer
    items = {
    {2190, 1}, -- Wand of Vortex
    {8870, 1}, -- spirit cloak
    {2323, 1}, -- hat of the mad
    {2468, 1}, -- studded legs
    {2643, 1}, -- leather boots
    {2661, 1} -- scarf
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7620, 10} -- mana potion
    }
    },
    [2] = { -- Druid
    items = {
    {2182, 1}, -- Snakebite Rod
    {8870, 1}, -- spirit cloak
    {2323, 1}, -- hat of the mad
    {2468, 1}, -- studded legs
    {2643, 1}, -- leather boots
    {2661, 1} -- scarf
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7620, 10} -- mana potion
    }
    },
    [3] = { -- Paladin
    items = {
    {2525, 1}, -- dwarven shield
    {2389, 5}, -- 5 spears
    {2660, 1}, -- ranger's cloak
    {8923, 1}, -- ranger legs
    {2643, 1}, -- leather boots
    {2661, 1}, -- scarf
    {2459, 1} -- iron helmet
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7618, 5}, -- health potion
    {2456, 1}, -- bow
    {2544, 50} -- 50 arrows
    }
    },
    [4] = { -- Knight
    items = {
    {2525, 1}, -- dwarven shield
    {8601, 1}, -- steel axe
    {2465, 1}, -- brass armor
    {2460, 1}, -- brass helmet
    {2478, 1}, -- brass legs
    {2643, 1}, -- leather boots
    {2661, 1}, -- scarf
    {2459, 1} -- iron helmet
    },
    container = {
    {8602, 1}, -- jagged sword
    {2439, 1}, -- daramanian mace
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7618, 10} -- health potion
    }
    },
    [5] = { -- Sorcerer
    items = {
    {2190, 1}, -- Wand of Vortex
    {8870, 1}, -- spirit cloak
    {2323, 1}, -- hat of the mad
    {2468, 1}, -- studded legs
    {2643, 1}, -- leather boots
    {2661, 1} -- scarf
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7620, 10} -- mana potion
    }
    },
    [6] = { -- Druid
    items = {
    {2182, 1}, -- Snakebite Rod
    {8870, 1}, -- spirit cloak
    {2323, 1}, -- hat of the mad
    {2468, 1}, -- studded legs
    {2643, 1}, -- leather boots
    {2661, 1} -- scarf
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7620, 10} -- mana potion
    }
    },
    [7] = { -- Paladin
    items = {
    {2525, 1}, -- dwarven shield
    {2389, 5}, -- 5 spears
    {2660, 1}, -- ranger's cloak
    {8923, 1}, -- ranger legs
    {2643, 1}, -- leather boots
    {2661, 1}, -- scarf
    {2459, 1} -- iron helmet
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7618, 5}, -- health potion
    {2456, 1}, -- bow
    {2544, 50} -- 50 arrows
    }
    },
    [8] = { -- Knight
    items = {
    {2525, 1}, -- dwarven shield
    {8601, 1}, -- steel axe
    {2465, 1}, -- brass armor
    {2460, 1}, -- brass helmet
    {2478, 1}, -- brass legs
    {2643, 1}, -- leather boots
    {2661, 1}, -- scarf
    {2459, 1} -- iron helmet
    },
    container = {
    {8602, 1}, -- jagged sword
    {2439, 1}, -- daramanian mace
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7618, 10} -- health potion
    }
    },
    [9] = { -- Illusionists
    items = {
    {2190, 1}, -- Wand of Vortex
    {8870, 1}, -- spirit cloak
    {2323, 1}, -- hat of the mad
    {2468, 1}, -- studded legs
    {2643, 1}, -- leather boots
    {2661, 1} -- scarf
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7620, 10} -- mana potion
    }
    },
    [10] = { -- Illusionists
    items = {
    {2190, 1}, -- Wand of Vortex
    {8870, 1}, -- spirit cloak
    {2323, 1}, -- hat of the mad
    {2468, 1}, -- studded legs
    {2643, 1}, -- leather boots
    {2661, 1} -- scarf
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7620, 10} -- mana potion
    }
    },
    [11] = { -- Monk
    items = {
    {29929, 1}, -- jo staff
    {2465, 1}, -- brass armor
    {2460, 1}, -- brass helmet
    {2478, 1}, -- brass legs
    {2643, 1}, -- leather boots
    {2661, 1}, -- scarf
    {2459, 1} -- iron helmet
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7618, 6}, -- health potion
    {7620, 6} -- mana potion
    }
    },
    [12] = { -- Monk
    items = {
    {29929, 1}, -- jo staff
    {2465, 1}, -- brass armor
    {2460, 1}, -- brass helmet
    {2478, 1}, -- brass legs
    {2643, 1}, -- leather boots
    {2661, 1}, -- scarf
    {2459, 1} -- iron helmet
    },
    container = {
    {2120, 1}, -- rope
    {2554, 1}, -- shovel
    {7618, 6}, -- health potion
    {7620, 6} -- mana potion
    }
    },
}

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

local firstItems = Action()

function firstItems.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local targetVocation = config[player:getVocation():getId()]
    if not targetVocation then
        return true
    end

    local storage = player:getStorageValue(337350)
    if storage > 0 then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "You already collected this chest.")
    return true
    end

    for i = 1, #targetVocation.items do
        local itemId  = targetVocation.items[i][1]
        local amount  = targetVocation.items[i][2]

        local rarityId = rollRarity()
        local createdItem

        if rarityId > 0 then
            createdItem = Game.createItemWithRarity(itemId, amount, rarityId)
        else
            createdItem = Game.createItem(itemId, amount)
        end

        if not createdItem then
            player:sendCancelMessage("One of the starter items could not be created.")
            return true
        end

        if player:addItemEx(createdItem) ~= RETURNVALUE_NOERROR then
            createdItem:remove()
            player:sendCancelMessage("You don't have enough space for the starter items.")
            return true
        end

        if rarityId > 0 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Your starter %s rolled rarity: %s!", ItemType(itemId):getName(), RarityNames[rarityId]))
        end
    end

    local backpack = player:addItem(1988)
    if not backpack then
        return true
    end

    for i = 1, #targetVocation.container do
        backpack:addItem(
            targetVocation.container[i][1],
            targetVocation.container[i][2]
        )
    end

    playSound(player, "open_chest.ogg")
    player:setStorageValue(337350, 1)
    return true
end

firstItems:aid(33735)
firstItems:register()
