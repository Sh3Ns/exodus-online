local CODE_GAMEUPGRADES = 181
local GAME_UPGRADES = {
	upgradeCategories = {},
	upgradeOffers = {}
}

print(">> Character Upgrades System Loaded")

local STORAGE_TOTAL_POINTS = 716544
local STORAGE_SPENDABLE_POINTS = 716545
local STORAGE_POINTS_INITIALIZED = 716547

function getPlayerTotalPoints(player)
	return math.max(0, player:getStorageValue(STORAGE_TOTAL_POINTS))
end

function getPlayerSpendablePoints(player)
	return math.max(0, player:getStorageValue(STORAGE_SPENDABLE_POINTS))
end

function initializePlayerPoints(player)
	if player:getStorageValue(STORAGE_POINTS_INITIALIZED) ~= 1 then
		player:setStorageValue(STORAGE_TOTAL_POINTS, 0)
		player:setStorageValue(STORAGE_SPENDABLE_POINTS, 0)
		player:setStorageValue(STORAGE_POINTS_INITIALIZED, 1)
	end
end

local LoginEvent = CreatureEvent("GameUpgradesLogin")

function LoginEvent.onLogin(player)
  initializePlayerPoints(player)
  applyStoredUpgrades(player)
  gameUpgradesUpdatePoints(player)
  player:registerEvent("GameUpgradesExtended")
  return true
end

LoginEvent:type("login")
LoginEvent:register()

local itemsShop = {
  --- This part is the shop, you can add an item here, that will be bought with Required Item , quantity and Points. A max level is added, if you want infinity do a table of high levels
  pack_29892 = {
    category = "Shop",
    title = "Runescribed Parchment",
    description = "Purchase Runescribed Parchment.",
    iconItemId = 29892,
    defaultStorage = 141426,
    tiers = {
      { minLevel = 1, maxLevel = 3, rewardItemId = 29892, rewardCount = 1, pointsCost = 50, requiredItemId = 29851, requiredItemCount = 5 },
      { minLevel = 4, maxLevel = 6, rewardItemId = 29892, rewardCount = 1, pointsCost = 100, requiredItemId = 29852, requiredItemCount = 5 },
      { minLevel = 7, maxLevel = 10, rewardItemId = 29892, rewardCount = 1, pointsCost = 200, requiredItemId = 29853, requiredItemCount = 4 },
      { minLevel = 10, maxLevel = 20, rewardItemId = 29892, rewardCount = 1, pointsCost = 250, requiredItemId = 29854, requiredItemCount = 3 },
    }
  },
  pack_29894 = {
    category = "Shop",
    title = "Aethus Fragment",
    description = "Purchase Aethus Fragment.",
    iconItemId = 29894,
    defaultStorage = 141427,
    tiers = {
      { minLevel = 1, maxLevel = 3, rewardItemId = 29894, rewardCount = 1, pointsCost = 50, requiredItemId = 29851, requiredItemCount = 5 },
      { minLevel = 4, maxLevel = 6, rewardItemId = 29894, rewardCount = 1, pointsCost = 100, requiredItemId = 29852, requiredItemCount = 5 },
      { minLevel = 7, maxLevel = 10, rewardItemId = 29894, rewardCount = 1, pointsCost = 200, requiredItemId = 29853, requiredItemCount = 4 },
      { minLevel = 10, maxLevel = 20, rewardItemId = 29894, rewardCount = 1, pointsCost = 250, requiredItemId = 29854, requiredItemCount = 3 },
    }
  },
  pack_29896 = {
    category = "Shop",
    title = "Envenomed Heart",
    description = "Purchase Envenomed Heart.",
    iconItemId = 29896,
    defaultStorage = 141428,
    tiers = {
      { minLevel = 1, maxLevel = 3, rewardItemId = 29896, rewardCount = 1, pointsCost = 50, requiredItemId = 29851, requiredItemCount = 5 },
      { minLevel = 4, maxLevel = 6, rewardItemId = 29896, rewardCount = 1, pointsCost = 100, requiredItemId = 29852, requiredItemCount = 5 },
      { minLevel = 7, maxLevel = 10, rewardItemId = 29896, rewardCount = 1, pointsCost = 200, requiredItemId = 29853, requiredItemCount = 4 },
      { minLevel = 10, maxLevel = 20, rewardItemId = 29896, rewardCount = 1, pointsCost = 250, requiredItemId = 29854, requiredItemCount = 3 },
    }
  },
  pack_29897 = {
    category = "Shop",
    title = "Corrupted Skull",
    description = "Purchase Corrupted Skull.",
    iconItemId = 29897,
    defaultStorage = 141429,
    tiers = {
      { minLevel = 1, maxLevel = 3, rewardItemId = 29897, rewardCount = 1, pointsCost = 50, requiredItemId = 29851, requiredItemCount = 5 },
      { minLevel = 4, maxLevel = 6, rewardItemId = 29897, rewardCount = 1, pointsCost = 100, requiredItemId = 29852, requiredItemCount = 5 },
      { minLevel = 7, maxLevel = 10, rewardItemId = 29897, rewardCount = 1, pointsCost = 200, requiredItemId = 29853, requiredItemCount = 4 },
      { minLevel = 10, maxLevel = 20, rewardItemId = 29897, rewardCount = 1, pointsCost = 250, requiredItemId = 29854, requiredItemCount = 3 },
    }
  },
  pack_29898 = {
    category = "Shop",
    title = "Mystic Essence",
    description = "Purchase Mystic Essence.",
    iconItemId = 29898,
    defaultStorage = 141430,
    tiers = {
      { minLevel = 1, maxLevel = 3, rewardItemId = 29898, rewardCount = 1, pointsCost = 50, requiredItemId = 29851, requiredItemCount = 5 },
      { minLevel = 4, maxLevel = 6, rewardItemId = 29898, rewardCount = 1, pointsCost = 100, requiredItemId = 29852, requiredItemCount = 5 },
      { minLevel = 7, maxLevel = 10, rewardItemId = 29898, rewardCount = 1, pointsCost = 200, requiredItemId = 29853, requiredItemCount = 4 },
      { minLevel = 10, maxLevel = 20, rewardItemId = 29898, rewardCount = 1, pointsCost = 250, requiredItemId = 29854, requiredItemCount = 3 },
    }
  },
  pack_29899 = {
    category = "Shop",
    title = "Armor Shard",
    description = "Purchase Armor Shard.",
    iconItemId = 29899,
    defaultStorage = 141431,
    tiers = {
      { minLevel = 1, maxLevel = 3, rewardItemId = 29899, rewardCount = 1, pointsCost = 50, requiredItemId = 29851, requiredItemCount = 5 },
      { minLevel = 4, maxLevel = 6, rewardItemId = 29899, rewardCount = 1, pointsCost = 100, requiredItemId = 29852, requiredItemCount = 5 },
      { minLevel = 7, maxLevel = 10, rewardItemId = 29899, rewardCount = 1, pointsCost = 200, requiredItemId = 29853, requiredItemCount = 4 },
      { minLevel = 10, maxLevel = 20, rewardItemId = 29899, rewardCount = 1, pointsCost = 250, requiredItemId = 29854, requiredItemCount = 3 },
    }
  },
  pack_29900 = {
    category = "Shop",
    title = "Runic Stone Shard",
    description = "Purchase Runic Stone Shard.",
    iconItemId = 29900,
    defaultStorage = 141432,
    tiers = {
      { minLevel = 1, maxLevel = 3, rewardItemId = 29900, rewardCount = 1, pointsCost = 50, requiredItemId = 29851, requiredItemCount = 5 },
      { minLevel = 4, maxLevel = 6, rewardItemId = 29900, rewardCount = 1, pointsCost = 100, requiredItemId = 29852, requiredItemCount = 5 },
      { minLevel = 7, maxLevel = 10, rewardItemId = 29900, rewardCount = 1, pointsCost = 200, requiredItemId = 29853, requiredItemCount = 4 },
      { minLevel = 10, maxLevel = 20, rewardItemId = 29900, rewardCount = 1, pointsCost = 250, requiredItemId = 29854, requiredItemCount = 3 },
    }
  },
}

function gameUpgradesInitialize()
	GAME_UPGRADES.upgradeCategories = {}
	GAME_UPGRADES.upgradeOffers = {}

	-- Skills Upgrades Category
	addUpgradeCategory("Skills", "Improve your character's skills and attributes.", "item", 29859)
	addUpgrade("Skills", "Sword Fighting", "Increases your sword fighting skill progress.", "sword", 141282)
	addUpgrade("Skills", "Axe Fighting", "Increases your axe fighting skill progress.", "axe", 141283)
	addUpgrade("Skills", "Club Fighting", "Increases your club fighting skill progress.", "club", 141284)
	addUpgrade("Skills", "Distance Fighting", "Increases your distance fighting skill progress.", "distance", 141285)
	addUpgrade("Skills", "Shielding", "Increases your shielding skill progress.", "shield", 141286)
	addUpgrade("Skills", "Magic Level", "Increases your magic level progress.", "magic", 141287)
	addUpgrade("Skills", "Fist Fighting", "Increases your fist fighting skill progress.", "fist", 141288)
	addUpgrade("Skills", "Fishing", "Increases your fishing skill progress.", "fishing", 141289)
	addUpgrade("Skills", "Crafting", "Increases your crafting skill progress.", "crafting", 141290)
	addUpgrade("Skills", "Herbalist", "Increases your herbalist skill progress.", "herbalist", 141291)
	addUpgrade("Skills", "Mining", "Increases your mining skill progress.", "mining", 141292)
	addUpgrade("Skills", "Woodcutting", "Increases your woodcutting skill progress.", "woodcutting", 141293)
	addUpgrade("Skills", "Armorsmith", "Increases your armorsmith skill progress.", "armorsmith", 141294)
	addUpgrade("Skills", "Weaponsmith", "Increases your weaponsmith skill progress.", "weaponsmith", 141295)
	addUpgrade("Skills", "Jewelsmith", "Increases your jewelsmith skill progress.", "jewelsmith", 141296)
	addUpgrade("Skills", "Critical Chance", "Increases your critical hit chance skill progress.", "criticalch", 141297)
	addUpgrade("Skills", "Critical Amount", "Increases your critical hit amount skill progress.", "criticalam", 141298)
	addUpgrade("Skills", "Life Chance", "Increases your life leech chance skill progress.", "lifech", 141299)
	addUpgrade("Skills", "Life Amount", "Increases your life leech amount skill progress.", "lifeam", 141300)
	addUpgrade("Skills", "Mana Chance", "Increases your mana leech chance skill progress.", "manach", 141301)
	addUpgrade("Skills", "Mana Amount", "Increases your mana leech amount skill progress.", "manaam", 141302)

	-- Elements Upgrades Category
	addUpgradeCategory("Elements", "Enhance your elements damage.", "item", 29558)
	addUpgrade("Elements", "Fire Damage", "Increases fire damage by 0.5%", "incrementFire", 141303)
	addUpgrade("Elements", "Physical Damage", "Increases physical damage by 0.5%", "incrementPhysical", 141304)
	addUpgrade("Elements", "Energy Damage", "Increases energy damage by 0.5%", "incrementEnergy", 141305)
	addUpgrade("Elements", "Earth Damage", "Increases earth damage by 0.5%", "incrementEarth", 141306)
	addUpgrade("Elements", "Health Damage", "Increases health damage by 0.5%", "incrementHealth", 141307)
	addUpgrade("Elements", "Ice Damage", "Increases ice damage by 0.5%", "incrementIce", 141308)
	addUpgrade("Elements", "Arcane Damage", "Increases arcane damage by 0.5%", "incrementArcane", 141309)
	addUpgrade("Elements", "Life Drain Damage", "Increases life drain damage by 0.5%", "incrementLifeDrain", 141310)
	addUpgrade("Elements", "Mana Drain Damage", "Increases mana drain damage by 0.5%", "incrementManaDrain", 141311)
	addUpgrade("Elements", "Drown Damage", "Increases drown damage by 0.5%", "incrementDrown", 141312)
	addUpgrade("Elements", "Holy Damage", "Increases holy damage by 0.5%", "incrementHoly", 141313)
	addUpgrade("Elements", "Death Damage", "Increases death damage by 0.5%", "incrementDeath", 141314)
	addUpgrade("Elements", "Water Damage", "Increases water damage by 0.5%", "incrementWater", 141315)

	-- Others Upgrades Category
	addUpgradeCategory("Others", "Enhance your others capabilities.", "item", 29858)
	addUpgrade("Others", "Experience", "Increases general experience", "experience", 141316)
	addUpgrade("Others", "Loot", "Increases general loot", "loot", 141317)
	addUpgrade("Others", "Rarity", "Increases general rarity loot", "rarity", 141318)


	-- Shop Category
	addUpgradeCategory("Shop", "Shop: You can buy here some ressources that will be added to your inventory.", "item", 29854)
	addItemShop("Shop", "Runescribed Parchment", "Purchase Runescribed Parchment.", "pack_29892", 141320)
	addItemShop("Shop", "Aethus Fragment", "Purchase Aethus Fragment.", "pack_29894", 141321)
  addItemShop("Shop", "Envenomed Heart", "Purchase Envenomed Heart.", "pack_29896", 141322)
  addItemShop("Shop", "Corrupted Skull", "Purchase Corrupted Skull.", "pack_29897", 141323)
  addItemShop("Shop", "Mystic Essence", "Purchase Mystic Essence.", "pack_29898", 141324)
  addItemShop("Shop", "Armor Shard", "Purchase Armor Shard.", "pack_29899", 141325)
  addItemShop("Shop", "Runic Stone Shard", "Purchase Runic Stone Shard.", "pack_29900", 141326)


end

local upgradeCostRules = {
  --- Skills have been capped to 15 levels each one thinking it's a good balance.
  --- Price costs: 1000 / 10 = 100 pointsCost. 2^2 for the doublingInterval. doubleInterval means that the price will double.
  --- MinLevel = Minimum Level, maxLevel = Max Level, itemId = Item id required to buy, initialCount = count of itemID required, doublingiinterval = doubling price, basePrice = points costs.
  --- DoublingInterval = 99 means that the price will never double 99 means , reach level 99 then required items points will be doubled after this level, we disable it here.
  Skills = {
    sword = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    axe = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    club = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    distance = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    shield = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    magic = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    fist = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    fishing = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    crafting = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    herbalist = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    mining = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    woodcutting = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    armorsmith = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    weaponsmith = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    jewelsmith = {
      basePrice = 1000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 5, maxLevel = 7, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 8, maxLevel = 11, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 12, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    criticalch = {
      basePrice = 1200,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 3, maxLevel = 4, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 5, maxLevel = 7, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 8, maxLevel = 10, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    criticalam = {
      basePrice = 1200,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 3, maxLevel = 4, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 5, maxLevel = 7, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 8, maxLevel = 10, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    lifech = {
      basePrice = 1200,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 3, maxLevel = 4, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 5, maxLevel = 7, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 8, maxLevel = 10, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    lifeam = {
      basePrice = 1200,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 3, maxLevel = 4, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 5, maxLevel = 7, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 8, maxLevel = 10, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    manach = {
      basePrice = 1200,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 3, maxLevel = 4, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 5, maxLevel = 7, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 8, maxLevel = 10, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    manaam = {
      basePrice = 1200,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1200 },
        { minLevel = 3, maxLevel = 4, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 5, maxLevel = 7, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 8, maxLevel = 10, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
  },
  --- Increments have been adjusted to 20 increment of each element. You can adjust doing test, and later change the storage above to reset the counter level
  Elements = {
    incrementFire = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementPhysical = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementEnergy = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementEarth = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementHealth = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementIce = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementArcane = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementLifeDrain = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementManaDrain = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementDrown = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementHoly = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementDeath = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
    incrementWater = {
      basePrice = 1100,
      itemRules = {
        { minLevel = 1, maxLevel = 3, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 4, maxLevel = 6, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 1300 },
        { minLevel = 7, maxLevel = 10, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1500 },
        { minLevel = 11, maxLevel = 13, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 2000 },
        { minLevel = 14, maxLevel = 20, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 3000 },
      }
    },
  },
  --- Warning the following Exp, loot and rarity have been calculated to not break the game balance. 
  --- EXP is base 1.00 , so each level adds 0.01 to the multiplier, so 100 levels will be 2.00 multiplier.
  --- Loot is base 1.00, so each level adds 0.01 to the multiplier, so 50 levels will be 1.50 multiplier.
  --- Rarity is base 5.00% , each level adds 1.0% to the multiplier and 0.5% to the rarity internal tiers (1-15 tiers table chance), 15 levels will be 20% and 10% internal, example if rarity rare is 15% so it will become 25%.
  Others = {
    experience = {
      basePrice = 500,
      itemRules = {
        { minLevel = 1, maxLevel = 15, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 500 },
        { minLevel = 16, maxLevel = 30, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 600 },
        { minLevel = 31, maxLevel = 45, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 700 },
        { minLevel = 46, maxLevel = 60, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 800 },
        { minLevel = 61, maxLevel = 100, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 1000 },
      }
    },
    loot = {
      basePrice = 800,
      itemRules = {
        { minLevel = 1, maxLevel = 10, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 800 },
        { minLevel = 11, maxLevel = 20, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 900 },
        { minLevel = 21, maxLevel = 30, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 31, maxLevel = 40, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 41, maxLevel = 50, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 1200 },
      }
    },
    rarity = {
      basePrice = 2000,
      itemRules = {
        { minLevel = 1, maxLevel = 2, itemId = 29855, initialCount = 10, doublingInterval = 99, basePrice = 800 },
        { minLevel = 3, maxLevel = 4, itemId = 29856, initialCount = 8, doublingInterval = 99, basePrice = 900 },
        { minLevel = 5, maxLevel = 6, itemId = 29857, initialCount = 5, doublingInterval = 99, basePrice = 1000 },
        { minLevel = 7, maxLevel = 8, itemId = 29858, initialCount = 2, doublingInterval = 99, basePrice = 1100 },
        { minLevel = 9, maxLevel = 15, itemId = 29859, initialCount = 1, doublingInterval = 99, basePrice = 1200 },
      }
    },
  }
}

function findTier(def, level)
  if not def.tiers then
    return nil
  end
  for _, tier in ipairs(def.tiers) do
    if level >= tier.minLevel and level <= tier.maxLevel then
      return tier
    end
  end
  return nil
end

function getMaxDefinedLevel(cfg)
  local max = 0
  if cfg.itemRules then
    for _, rule in ipairs(cfg.itemRules) do
      if rule.maxLevel and rule.maxLevel > max then
        max = rule.maxLevel
      end
    end
  end
  return max
end

function getTierForNextLevel(tiers, nextLevel)
  for _, tier in ipairs(tiers) do
    if nextLevel >= tier.minLevel and nextLevel <= tier.maxLevel then
      return tier
    end
  end
  return nil
end

function addItemShop(category, title, description, upgradeType, storageKey)
  local def = itemsShop[upgradeType]
  if not def then
    print("Shop Item definition missing for:", upgradeType)
    return
  end

  local storage = storageKey or def.defaultStorage
  if not storage then
    print("No storage key provided for shop Item:", upgradeType)
    return
  end

  if not GAME_UPGRADES.upgradeOffers[category] then
    GAME_UPGRADES.upgradeOffers[category] = {}
  end

  table.insert(GAME_UPGRADES.upgradeOffers[category], {
    type        = "shopItem",
    title       = title or def.title,
    description = description or def.description,
    clientId    = ItemType(def.iconItemId):getClientId(),
    iconItemId  = def.iconItemId,
    upgradeType = upgradeType,
    storage     = storage,
    tiers       = def.tiers,
    category    = category,
  })
end


function findRule(cfg, level)
	if cfg.itemRules then
		for _, rule in ipairs(cfg.itemRules) do
			if level >= rule.minLevel and level <= rule.maxLevel then
				return rule
			end
		end
	end
	return nil
end

function calculatePointsCost(basePrice, level)
	return math.floor((basePrice / 10) + (level - 1) * 25)
end

function getUpgradeCosts(category, upgradeType, level)
	local cat = upgradeCostRules[category]
	if not cat then
		return { itemId = 0, count = 0, pointsCost = 0 }
	end
	local cfg = cat[upgradeType]
	if not cfg then
		return { itemId = 0, count = 0, pointsCost = 0 }
	end

	local maxLevel = getMaxDefinedLevel(cfg)
	if level > maxLevel then
		return { itemId = 0, count = 0, pointsCost = 0, maxed = true }
	end

	local itemId, count, basePriceForPoints

	if cfg.explicit and cfg.explicit[level] then
		local expl = cfg.explicit[level]
		itemId = expl.itemId or 0
		count = expl.count or 0
		basePriceForPoints = expl.basePrice or cfg.basePrice or 0
	else
		local rule = findRule(cfg, level)
		if rule then
			itemId = rule.itemId or 0
			local interval = rule.doublingInterval or 1
			local steps = math.floor((level - rule.minLevel) / interval)
			count = (rule.initialCount or 1) * (2 ^ steps)
			basePriceForPoints = rule.basePrice or cfg.basePrice or 0
		else
			itemId = 0
			count = 0
			basePriceForPoints = cfg.basePrice or 0
		end
	end

	local pointsCost = calculatePointsCost(basePriceForPoints, level)
	return { itemId = itemId, count = count, pointsCost = pointsCost }
end



local SUBID_ID = 13400

local incrementMagicMap = {
  incrementFire = COMBAT_FIREDAMAGE,
  incrementPhysical = COMBAT_PHYSICALDAMAGE,
  incrementEnergy = COMBAT_ENERGYDAMAGE,
  incrementEarth = COMBAT_EARTHDAMAGE,
  incrementHealth = COMBAT_HEALING,
  incrementIce = COMBAT_ICEDAMAGE,
  incrementHoly = COMBAT_HOLYDAMAGE,
  incrementDeath = COMBAT_DEATHDAMAGE,
  incrementWater = COMBAT_WATERDAMAGE,
  incrementArcane = COMBAT_ARCANEDAMAGE,
  incrementLifeDrain = COMBAT_LIFEDRAIN,
  incrementManaDrain = COMBAT_MANADRAIN,
  incrementDrown = COMBAT_DROWNDAMAGE,
}

local specialStorageMap = {
  experience = 405791,
  loot = 405792,
  rarity = 405790,
}

local skillConditionParamMap = {
  sword = CONDITION_PARAM_SKILL_SWORD,
  axe = CONDITION_PARAM_SKILL_AXE,
  club = CONDITION_PARAM_SKILL_CLUB,
  distance = CONDITION_PARAM_SKILL_DISTANCE,
  shield = CONDITION_PARAM_SKILL_SHIELD,
  magic = CONDITION_PARAM_STAT_MAGICPOINTS,
  fist = CONDITION_PARAM_SKILL_FIST,
  crafting = CONDITION_PARAM_SKILL_CRAFTING,
  woodcutting = CONDITION_PARAM_SKILL_WOODCUTTING,
  mining = CONDITION_PARAM_SKILL_MINING,
  herbalist = CONDITION_PARAM_SKILL_HERBALIST,
  armorsmith = CONDITION_PARAM_SKILL_ARMORSMITH,
  weaponsmith = CONDITION_PARAM_SKILL_WEAPONSMITH,
  jewelsmith = CONDITION_PARAM_SKILL_JEWELSMITH,
  criticalch = CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE,
  criticalam = CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT,
  lifech = CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE,
  lifeam = CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT,
  manach = CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE,
  manaam = CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT,
}

function applyStoredUpgrades(player)
  for _, offers in pairs(GAME_UPGRADES.upgradeOffers) do
    for _, offer in ipairs(offers) do
      local lvl = player:getStorageValue(offer.storage) or 0
      if lvl <= 0 then
      elseif incrementMagicMap[offer.upgradeType] then
        player:addSpecializedMagicLevel(incrementMagicMap[offer.upgradeType], lvl)
      elseif specialStorageMap[offer.upgradeType] then
        player:setStorageValue(specialStorageMap[offer.upgradeType], lvl)
      else
        local subId = SUBID_ID + offer.storage
        local cond

        if offer.upgradeType == "speed" then
          cond = Condition(CONDITION_HASTE, CONDITIONID_DEFAULT)
          cond:setParameter(CONDITION_PARAM_SPEED, lvl)
        else
          local param = skillConditionParamMap[offer.upgradeType]
          if not param then
          else
            cond = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
            cond:setParameter(param, lvl)
          end
        end

        if cond then
          cond:setParameter(CONDITION_PARAM_SUBID, subId)
          cond:setParameter(CONDITION_PARAM_TICKS, -1)
          player:addCondition(cond)
        end
      end
    end
  end
end

local permanentMessages = {
  experience = "Your experience gain has been increased permanently!",
  loot = "Your loot gain has been increased permanently!",
  rarity = "Your rarity gain has been increased permanently!",
}

local skillMessageNames = {
  sword = "Sword Fighting",
  axe = "Axe Fighting",
  club = "Club Fighting",
  distance = "Distance Fighting",
  shield = "Shielding",
  magic = "Magic Level",
  fist = "Fist Fighting",
  crafting = "Crafting",
  woodcutting = "Woodcutting",
  mining = "Mining",
  herbalist = "Herbalist",
  armorsmith = "Armorsmith",
  weaponsmith = "Weaponsmith",
  jewelsmith = "Jewelsmith",
  criticalch = "Critical Chance",
  criticalam = "Critical Amount",
  lifech = "Life Chance",
  lifeam = "Life Amount",
  manach = "Mana Chance",
  manaam = "Mana Amount",
}


function sendUpgradeMsg(player, msgType, msg, close)
  player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
    action = "msg",
    data = {
      type = msgType,
      msg = msg,
      close = close or false
    }
  })
end


local ExtendedEvent = CreatureEvent("GameUpgradesExtended")

function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode == CODE_GAMEUPGRADES then
		if not GAME_UPGRADES.upgradeCategories or #GAME_UPGRADES.upgradeCategories == 0 then
			gameUpgradesInitialize()
		end

		local status, json_data =
			pcall(
			function()
				return json.decode(buffer)
			end
		)
		if not status then
			return
		end

		local action = json_data.action
		local data = json_data.data
		if not action or not data then
			return
		end
		if action == "fetch" then
			gameUpgradesFetch(player)
		elseif action == "purchase" then
			gameUpgradesPurchase(player, data)
		elseif action == "fetch_category" then
			gameUpgradesFetchCategory(player, data.category)
		elseif action == "upgrade_points" or action == "points" then
  			onUpgradesUpdatePoints(data)
		end
	end
end

ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()

function gameUpgradesFetch(player)
	if not GAME_UPGRADES.upgradeCategories or #GAME_UPGRADES.upgradeCategories == 0 then
		gameUpgradesInitialize()
	end

	player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode({action = "fetchBase", data = {categories = GAME_UPGRADES.upgradeCategories}}))

	for category, offersTable in pairs(GAME_UPGRADES.upgradeOffers) do
		local offers = {}
		for i = 1, #offersTable do
			local offer = offersTable[i]
			local currentLevel = player:getStorageValue(offer.storage)
			if currentLevel < 0 then
				currentLevel = 0
			end

			if offer.type == "upgrade" then
				local nextLevel = currentLevel + 1
				local cost = getUpgradeCosts(category, offer.upgradeType, nextLevel)

				if cost and cost.maxed then
					local data = {
						type = "upgrade",
						title = offer.title,
						description = string.format("%s\nCurrent Level: %d\nMax level reached.", offer.description, currentLevel),
						price = 0,
						coinCost = { itemId = 0, count = 0 },
						coinText = "",
						clientId = offer.clientId,
						storageKey = offer.storage,
						upgradeType = offer.upgradeType,
						currentLevel = currentLevel,
						category = category,
						disabled = true,
            maxxed = true,
					}
					if offer.imageFile then
						data.imageFile = offer.imageFile
					end
					table.insert(offers, data)
				else
					local pointsCost, coinCost
					if cost and cost.pointsCost > 0 then
						pointsCost = cost.pointsCost
						coinCost = { itemId = cost.itemId, count = cost.count }
					else
						pointsCost = calculatePointsCost(offer.basePrice, nextLevel)
						coinCost = offer.coinCost or { itemId = 0, count = 0 }
					end

					local coinText = ""
					if coinCost.itemId and coinCost.itemId > 0 and coinCost.count and coinCost.count > 0 then
						local coinName = ItemType(coinCost.itemId):getName()
						coinText = string.format("%dx %s", coinCost.count, coinName)
					end

					local data = {
						type         = "upgrade",
						title        = ("%s (Level %d)"):format(offer.title, nextLevel),
						description  = string.format(
							"%s\nCurrent Level: %d\nCost: %d points + %s",
							offer.description, currentLevel, pointsCost, coinText
						),
						price        = pointsCost,
						coinCost     = coinCost,
						coinText     = coinText,
						clientId     = offer.clientId,
						storageKey   = offer.storage,
						upgradeType  = offer.upgradeType,
						currentLevel = currentLevel,
						category     = category
					}
					if offer.imageFile then
						data.imageFile = offer.imageFile
					end
					table.insert(offers, data)
				end
			elseif offer.type == "shopItem" then
				local currentLevel = player:getStorageValue(offer.storage)
        if currentLevel < 0 then currentLevel = 0 end
        local nextLevel = currentLevel + 1
        local tierCfg = findTier(offer, nextLevel)
				if tierCfg then
					local price = tierCfg.pointsCost or 0
					local rewardText = string.format("%dx %s", tierCfg.rewardCount, ItemType(tierCfg.rewardItemId):getName())
					local requiredText = ""
					if tierCfg.requiredItemId and tierCfg.requiredItemId > 0 and tierCfg.requiredItemCount and tierCfg.requiredItemCount > 0 then
						requiredText = string.format("%dx %s", tierCfg.requiredItemCount, ItemType(tierCfg.requiredItemId):getName())
					end

					local desc = string.format("%s\nCurrent Level: %d\nCost: %d points", offer.description, currentLevel, price)
					if requiredText ~= "" then
						desc = desc .. " + " .. requiredText
					end
					desc = desc .. "\nReward: " .. rewardText

					local data = {
						type         = "shopItem",
						title        = ("%s (Level %d)"):format(offer.title, nextLevel),
						description  = desc,
						price        = price,
						coinCost     = { itemId = tierCfg.requiredItemId or 0, count = tierCfg.requiredItemCount or 0 },
						coinText     = requiredText,
						clientId     = offer.clientId,
						storageKey   = offer.storage,
						upgradeType  = offer.upgradeType,
						currentLevel = currentLevel,
						category     = offer.category,
						reward = {
							itemId = tierCfg.rewardItemId,
							count  = tierCfg.rewardCount,
							name   = ItemType(tierCfg.rewardItemId):getName()
						},
						iconItemId = offer.iconItemId,
					}
					table.insert(offers, data)
				else
        local data = {
          type        = "shopItem",
          title       = ("%s (Max Level)"):format(offer.title),
          description = string.format("%s\nCurrent Level: %d\nMax level reached.", offer.description, currentLevel),
          price       = 0,
          coinCost    = { itemId = 0, count = 0 },
          coinText    = "",
          clientId    = offer.clientId,
          storageKey  = offer.storage,
          upgradeType = offer.upgradeType,
          currentLevel = currentLevel,
          category    = offer.category,
          disabled    = true,
          iconItemId  = offer.iconItemId,
        }
        table.insert(offers, data)
      end
			end
		end

		if #offers > 0 then
    		player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode({
    			action = "refresh_offers", 
    			data = {
    				category = category, 
    				offers = offers
    			}
    		}))
    	end
	end
	gameUpgradesUpdatePoints(player)
end

function spendPlayerPoints(player, amount)
  local total     = getPlayerTotalPoints(player)
  local spendable = getPlayerSpendablePoints(player)
  total     = math.max(0, total     - amount)
  spendable = math.max(0, spendable - amount)
  player:setStorageValue(STORAGE_TOTAL_POINTS,     total)
  player:setStorageValue(STORAGE_SPENDABLE_POINTS, spendable)
end

function gameUpgradesUpdatePoints(player)
  if type(player) == "number" then player = Player(player) end
  local total     = getPlayerTotalPoints(player)
  local spendable = getPlayerSpendablePoints(player)

  player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
    action = "upgrade_points",
    data = {
      total     = total,
      spendable = spendable
    }
  })
end

function gameUpgradesPurchase(player, offer)
	local offers = GAME_UPGRADES.upgradeOffers[offer.category]
	if not offers then
		player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
			action = "msg",
			data = {
				type  = "error",
				msg   = "Something went wrong, try again or contact server admin.",
				close = false
			}
		})
		addEvent(function() gameUpgradesFetchCategory(player, offer.category) end, 500)
		return
	end

	local purchaseCategory = offer.category
	if offer.type ~= "upgrade" and offer.type ~= "shopItem" then
		return
	end

	for i = 1, #offers do
		local def = offers[i]
		if def.storage == offer.storageKey and def.upgradeType == offer.upgradeType then
			if def.type == "upgrade" then
      local currentLevel = player:getStorageValue(def.storage)
      if currentLevel < 0 then currentLevel = 0 end
        local nextLevel = currentLevel + 1

        local cost = getUpgradeCosts(offer.category, offer.upgradeType, nextLevel)
        if cost and cost.maxed then
          sendUpgradeMsg(player, "error", "This upgrade is already at max level.", false)
          addEvent(function() gameUpgradesFetchCategory(player, purchaseCategory) end, 500)
          return
        end

        local pointsCost, requiredItem
        if cost and cost.pointsCost > 0 then
          pointsCost = cost.pointsCost
          requiredItem = { itemId = cost.itemId, count = cost.count }
        else
          pointsCost = calculatePointsCost(def.basePrice, nextLevel)
          requiredItem = def.coinCost or { itemId = 0, count = 0 }
        end
				if pointsCost ~= offer.price then
					player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
						action = "msg",
						data = {
							type  = "error",
							msg   = "Price mismatch. Please refresh the upgrades window.",
							close = false
						}
					})
					addEvent(function() gameUpgradesFetchCategory(player, offer.category) end, 500)
					return
				end

				local spendablePoints = getPlayerSpendablePoints(player)
				if pointsCost > spendablePoints then
					player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
						action = "msg",
						data = {
							type  = "error",
							msg   = "You don't have enough points!",
							close = false
						}
					})
					addEvent(function() gameUpgradesFetchCategory(player, offer.category) end, 500)
					return
				end

				if requiredItem.itemId and requiredItem.itemId > 0 and player:getItemCount(requiredItem.itemId) < requiredItem.count then
					player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
						action = "msg",
						data = {
							type  = "error",
							msg  = ("You need %dx %s to buy this upgrade."):format(
								requiredItem.count,
								ItemType(requiredItem.itemId):getName()
							),
							close = false
						}
					})
					addEvent(function() gameUpgradesFetchCategory(player, offer.category) end, 500)
					return
				end

				player:setStorageValue(def.storage, nextLevel)
				local skillType = def.upgradeType
				local msg = nil

				if permanentMessages[skillType] then
					msg = permanentMessages[skillType]
				elseif skillMessageNames[skillType] then
					msg = "Your " .. skillMessageNames[skillType] .. " gain has been increased permanently!"
				end

				if msg then
					sendUpgradeMsg(player, "info", msg, false)
				end

				spendPlayerPoints(player, pointsCost)
				if requiredItem.itemId and requiredItem.itemId > 0 then
					player:removeItem(requiredItem.itemId, requiredItem.count)
				end

				applyStoredUpgrades(player)
				sendUpgradeMsg(player, "info", "You've purchased " .. def.title .. "!", false)
				gameUpgradesUpdatePoints(player)

				addEvent(function()
					local onlinePlayer = Player(player:getId())
					if onlinePlayer then
						gameUpgradesFetchCategory(onlinePlayer, purchaseCategory)
					end
				end, 500)
				return
			elseif def.type == "shopItem" then
			local currentLevel = player:getStorageValue(def.storage)
			if currentLevel < 0 then currentLevel = 0 end
			local nextLevel = currentLevel + 1
			local tierCfg = findTier(def, nextLevel)
			if not tierCfg then
				sendUpgradeMsg(player, "error", "This upgrade is already at max level.", false)
				addEvent(function() gameUpgradesFetchCategory(player, purchaseCategory) end, 500)
				return
			end

			local pointsCost = tierCfg.pointsCost or 0
			if pointsCost ~= offer.price then
				sendUpgradeMsg(player, "error", "Price mismatch. Please refresh the upgrades window.", false)
				addEvent(function() gameUpgradesFetchCategory(player, purchaseCategory) end, 500)
				return
			end

			local spendablePoints = getPlayerSpendablePoints(player)
			if pointsCost > spendablePoints then
				sendUpgradeMsg(player, "error", "You don't have enough points!", false)
				addEvent(function() gameUpgradesFetchCategory(player, purchaseCategory) end, 500)
				return
			end

			if tierCfg.requiredItemId and tierCfg.requiredItemId > 0 and tierCfg.requiredItemCount and tierCfg.requiredItemCount > 0 then
				if player:getItemCount(tierCfg.requiredItemId) < tierCfg.requiredItemCount then
				player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
					action = "msg",
					data = {
					type = "error",
					msg  = ("You need %dx %s to buy this upgrade."):format(
						tierCfg.requiredItemCount,
						ItemType(tierCfg.requiredItemId):getName()
					),
					close = false
					}
				})
				addEvent(function() gameUpgradesFetchCategory(player, purchaseCategory) end, 500)
				return
				end
			end

			player:setStorageValue(def.storage, nextLevel)
			spendPlayerPoints(player, pointsCost)

			if tierCfg.requiredItemId and tierCfg.requiredItemId > 0 and tierCfg.requiredItemCount and tierCfg.requiredItemCount > 0 then
				player:removeItem(tierCfg.requiredItemId, tierCfg.requiredItemCount)
			end

			if tierCfg.rewardItemId and tierCfg.rewardCount and tierCfg.rewardCount > 0 then
				player:addItem(tierCfg.rewardItemId, tierCfg.rewardCount)
			end

			sendUpgradeMsg(player, "info", ("You've purchased %s (Level %d)!"):format(def.title, nextLevel), false)
			gameUpgradesUpdatePoints(player)

			addEvent(function()
				local onlinePlayer = Player(player:getId())
				if onlinePlayer then
				gameUpgradesFetchCategory(onlinePlayer, purchaseCategory)
				end
			end, 500)
			return
			end
		end
	end

	player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode{
		action = "msg",
		data = {
			type  = "error",
			msg   = "Something went wrong, try again or contact server admin!",
			close = false
		}
	})
	addEvent(function() gameUpgradesFetchCategory(player, offer.category) end, 500)
end



function errorMsgUpgrades(player, msg)
	player:sendTextMessage(MESSAGE_INFO_DESCR, msg)
	player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode({action = "msg", data = {type = "error", msg = ""}}))
end

function infoMsgUpgrades(player, msg, close)
	if not close then
		close = false
	end
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)
	if close then
		player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode({action = "msg", data = {type = "info", msg = "", close = close}}))
	end
end

function addUpgradeCategory(title, description, iconType, iconData)
	if iconType == "item" then
		iconData = ItemType(iconData):getClientId()
	end

	table.insert(
		GAME_UPGRADES.upgradeCategories,
		{
			title = title,
			description = description,
			iconType = iconType,
			iconData = iconData
		}
	)
end

function gameUpgradesFetchCategory(player, categoryName)
  if not GAME_UPGRADES.upgradeCategories or #GAME_UPGRADES.upgradeCategories == 0 then
    gameUpgradesInitialize()
  end

  local offersTable = GAME_UPGRADES.upgradeOffers[categoryName]
  if not offersTable then
    gameUpgradesUpdatePoints(player)
    return
  end

  local offers = {}
  for i = 1, #offersTable do
    local offer = offersTable[i]
    local currentLevel = player:getStorageValue(offer.storage)
    if currentLevel < 0 then currentLevel = 0 end

    if offer.type == "upgrade" then
      local nextLevel = currentLevel + 1
      local cost = getUpgradeCosts(categoryName, offer.upgradeType, nextLevel)

      if cost and cost.maxed then
        local data = {
          type = "upgrade",
          title = offer.title,
          description = string.format("%s\nCurrent Level: %d\nMax level reached.", offer.description, currentLevel),
          price = 0,
          coinCost = { itemId = 0, count = 0 },
          coinText = "",
          clientId = offer.clientId,
          storageKey = offer.storage,
          upgradeType = offer.upgradeType,
          currentLevel = currentLevel,
          category = categoryName,
          disabled = true,
          maxed = true,
        }
        if offer.imageFile then
          data.imageFile = offer.imageFile
        end
        table.insert(offers, data)
      else
        local pointsCost, coinCost
        if cost and cost.pointsCost > 0 then
          pointsCost = cost.pointsCost
          coinCost = { itemId = cost.itemId, count = cost.count }
        else
          pointsCost = calculatePointsCost(offer.basePrice, nextLevel)
          coinCost = offer.coinCost or { itemId = 0, count = 0 }
        end

        local coinText = ""
        if coinCost.itemId and coinCost.itemId > 0 and coinCost.count and coinCost.count > 0 then
          local coinName = ItemType(coinCost.itemId):getName()
          coinText = string.format("%dx %s", coinCost.count, coinName)
        end

        local data = {
          type         = "upgrade",
          title        = ("%s (Level %d)"):format(offer.title, nextLevel),
          description  = string.format(
            "%s\nCurrent Level: %d\nCost: %d points + %s",
            offer.description, currentLevel, pointsCost, coinText
          ),
          price        = pointsCost,
          coinCost     = coinCost,
          coinText     = coinText,
          clientId     = offer.clientId,
          storageKey   = offer.storage,
          upgradeType  = offer.upgradeType,
          currentLevel = currentLevel,
          category     = categoryName
        }
        if offer.imageFile then
          data.imageFile = offer.imageFile
        end
        table.insert(offers, data)
      end
    end

    if offer.type == "shopItem" then
      local currentLevel = player:getStorageValue(offer.storage)
      if currentLevel < 0 then currentLevel = 0 end
      local nextLevel = currentLevel + 1
      local tierCfg = findTier(offer, nextLevel)
      if tierCfg then
        local price = tierCfg.pointsCost or 0
        local rewardText = string.format("%dx %s", tierCfg.rewardCount, ItemType(tierCfg.rewardItemId):getName())
        local requiredText = ""
        if tierCfg.requiredItemId and tierCfg.requiredItemId > 0 and tierCfg.requiredItemCount and tierCfg.requiredItemCount > 0 then
          requiredText = string.format("%dx %s", tierCfg.requiredItemCount, ItemType(tierCfg.requiredItemId):getName())
        end

        local desc = string.format("%s\nCurrent Level: %d\nCost: %d points", offer.description, currentLevel, price)
        if requiredText ~= "" then
          desc = desc .. " + " .. requiredText
        end
        desc = desc .. "\nReward: " .. rewardText

        local data = {
          type         = "shopItem",
          title        = ("%s (Level %d)"):format(offer.title, nextLevel),
          description  = desc,
          price        = price,
          coinCost     = { itemId = tierCfg.requiredItemId or 0, count = tierCfg.requiredItemCount or 0 },
          coinText     = requiredText,
          clientId     = offer.clientId,
          storageKey   = offer.storage,
          upgradeType  = offer.upgradeType,
          currentLevel = currentLevel,
          category     = offer.category,
          reward = {
            itemId = tierCfg.rewardItemId,
            count  = tierCfg.rewardCount,
            name   = ItemType(tierCfg.rewardItemId):getName()
          },
          iconItemId = offer.iconItemId,
        }
        table.insert(offers, data)
      else
      local data = {
        type        = "shopItem",
        title       = ("%s (Max Level)"):format(offer.title),
        description = string.format("%s\nCurrent Level: %d\nMax level reached.", offer.description, currentLevel),
        price       = 0,
        coinCost    = { itemId = 0, count = 0 },
        coinText    = "",
        clientId    = offer.clientId,
        storageKey  = offer.storage,
        upgradeType = offer.upgradeType,
        currentLevel = currentLevel,
        category    = offer.category,
        disabled    = true,
        iconItemId  = offer.iconItemId,
      }
      table.insert(offers, data)
    end
    end
  end

  if #offers > 0 then
    player:sendExtendedOpcode(CODE_GAMEUPGRADES, json.encode({
      action = "refresh_offers",
      data   = {
        category = categoryName,
        offers   = offers
      }
    }))
  end

  gameUpgradesUpdatePoints(player)
end


function addUpgrade(category, title, description, upgradeType, storageKey, imageFile)
	if not GAME_UPGRADES.upgradeOffers[category] then
		GAME_UPGRADES.upgradeOffers[category] = {}
	end

	table.insert(GAME_UPGRADES.upgradeOffers[category], {
		type = "upgrade",
		title = title,
		description = description,
		imageFile = imageFile or upgradeType,
		clientId = 0,
		upgradeType = upgradeType,
		storage = storageKey,
		basePrice = 0,
		coinCost = {
			itemId = 0,
			count = 0
		}
	})
end


gameUpgradesInitialize()