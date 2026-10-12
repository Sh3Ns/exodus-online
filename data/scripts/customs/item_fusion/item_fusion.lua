local itemFusionOpcode = 67

print(">> Item Fusion Loaded")

local clientToServerMapping = {
  -- ClientID = ServerID
  --- Item to Infuse Client ID = Item to Infuse Item ID (3 same items)
  [3079] = 2195, -- Boots of Haste
  [3281]  = 2393, -- Giant Sword
  [3296]  = 2408, -- Warlord Sword
  [3302]  = 2414, -- Dragon Lance
  [3313]  = 2425, -- Obsidian Lance
  [3318]  = 2430, -- Knight Axe
  [3320]  = 2432, -- Fire Axe
  [3334]  = 2446, -- Pharaoh Sword
  [3335]  = 2447, -- Twin Axe
  [3339]  = 2451, -- Djin Blade
  [3360]  = 2466, -- Golden Armor
  [3364]  = 2470, -- Golden Legs
  [3366]  = 2472, -- Magic Plate Armor
  [3369]  = 2475, -- Warrior Helmet
  [3370]  = 2476, -- Knight Armor
  [3371]  = 2477, -- Knight Legs
  [3381]  = 2487, -- Crown Armor
  [3382]  = 2488, -- Crown Legs
  [3385]  = 2491, -- Crown Helmet
  [3386]  = 2492, -- Dragon Scale Mail
  [3391]  = 2497, -- Crusader Helmet
  [3392]  = 2498, -- Royal Helmet
  [3414]  = 2514, -- Mastermind Shield
  [3416]  = 2516, -- Dragon Shield
  [3418]  = 2518, -- Bonelord Shield
  [3419]  = 2519, -- Crown Shield
  [3420]  = 2520, -- Demon Shield
  [3422]  = 2522, -- Great Shield
  [3428]  = 2523, -- Tower Shield
  [3434]  = 2534, -- Vampire Shield
  [3436]  = 2536, -- Medusa Shield
  [3554]  = 2645, -- Steel Boots
  [3555]  = 2646, -- Golden Boots
  [3567]  = 2656, -- Blue Robe
  [5741]  = 5741, -- Skull helmet
  [6553]  = 6553, -- Ruthless Axe
  [7382]  = 7382, -- Demonrage Sword
  [7383]  = 7383, -- Relic Sword
  [7384]  = 7384, -- Mustic Blade
  [7386]  = 7386, -- Mercenary Sword
  [7388]  = 7388, -- Vile Axe
  [7389]  = 7389, -- Heroic Axe
  [7390]  = 7390, -- Justice Seeker
  [7391]  = 7391, -- Thaian Sword
  [7392]  = 7392, -- Orcish Maul
  [7402]  = 7402, -- Dragon Slayer
  [7403]  = 7403, -- Berserker
  [7404]  = 7404, -- Assassin Dagger
  [7405]  = 7405, -- Havoc Blade
  [7406]  = 7406, -- Blacksteel Sword
  [7407]  = 7407, -- Haunted Blade
  [7408]  = 7408, -- Wyvern Fang
  [7409]  = 7409, -- Northern Star
  [7411]  = 7411, -- Ornamented Axe
  [7412]  = 7412, -- Butchers Axe
  [7413]  = 7413, -- Titan Axe
  [7414]  = 7414, -- Abyss Hammer
  [7415]  = 7415, -- Cranial Basher
  [7416]  = 7416, -- Bloody Edge
  [7417]  = 7417, -- Runed Sword
  [7418]  = 7418, -- Nightmare Blade
  [7419]  = 7419, -- Dreaded cleaver
  [7420]  = 7420, -- Reaper's Axe
  [7421]  = 7421, -- Onyx Flail
  [7422]  = 7422, -- Jade Hammer
  [7423]  = 7423, -- Skullcrusher
  [7424]  = 7424, -- Lunar Staff
  [7426]  = 7426, -- Amber Staff
  [7427]  = 7427, -- Chaos Mace
  [7428]  = 7428, -- Bonebreaker
  [7429]  = 7429, -- Blessed Sceptre
  [7430]  = 7430, -- Dragonbone Staff
  [7431]  = 7431, -- Demonbone
  [7433]  = 7433, -- Ravenwing
  [7434]  = 7434, -- Royal Axe
  [7435]  = 7435, -- Impaler
  [7436]  = 7436, -- Angelic Axe
  [7437]  = 7437, -- Sapphire Hammer
  [7438]  = 7438, -- Elvish Bow
  [7451]  = 7451, -- Shadow Sceptre
  [7452]  = 7452, -- Spiked Squelcher
  [7454]  = 7454, -- Glorious Axe
  [7455]  = 7455, -- Mythril Axe
  [7456]  = 7456, -- Noble Axe
  [811]  = 7884, -- Terra Mantle
  [812]  = 7885, -- Terra Legs
  [813]  = 7886, -- Terra Boots
  [818]  = 7891, -- Magma Boots
  [819]  = 7892, -- Glacier Shoes
  [820]  = 7893, -- Lightning Boots
  [821]  = 7894, -- Magma Legs
  [822]  = 7895, -- Lightning Pants
  [823]  = 7896, -- Glacier Kilt
  [824]  = 7897, -- Glacier Robe
  [825]  = 7898, -- Lightning Robe
  [826]  = 7899, -- Magma Coat
  [827]  = 7900, -- Magma Monocle
  [828]  = 7901, -- Lightning Headband
  [829]  = 7902, -- Glacier Mask
  [830]  = 7903, -- Terra Hood
  [8026]  = 8854, -- Warsinger Bow
  [8027]  = 8855, -- Composite Bow
  [8029]  = 8857, -- Silkweaver bow
  [8037]  = 8865, -- Dark Lords cape
  [8038]  = 8866, -- Robe of the ice queen
  [8039]  = 8867, -- Dragon robe
  [8040]  = 8868, -- Velvet mantle
  [8041]  = 8869, -- Greenwood Coat
  [8043]  = 8871, -- Focus cape
  [8049]  = 8877, -- Lavos Armor
  [8050]  = 8878, -- Crystalline Armor
  [8051]  = 8879, -- Voltage Armor
  [8052]  = 8880, -- Swamplair Armor
  [8053]  = 8881, -- Fireborn giant armor
  [8054]  = 8882, -- Earthborn giant armor
  [8055]  = 8883, -- Windborn colossus armor
  [8056]  = 8884, -- Oceanborn leviathan armor
  [8057]  = 8885, -- Divine Plate
  [8058]  = 8886, -- Molten Plate
  [8059]  = 8887, -- Frozen Plate
  [8060]  = 8888, -- Master Archers Armor
  [8061]  = 8889, -- Skullcracker Armor
  [8062]  = 8890, -- Robe of the underworld
  [8063]  = 8891, -- Paladin armor
  [8072]  = 8900, -- Spellbook of enlightenment
  [8073]  = 8901, -- Spellbook of warding
  [8074]  = 8902, -- Spellbook of mind control
  [8075]  = 8903, -- Spellbook of lost souls
  [8098]  = 8926, -- Demonwing Axe
  [8099]  = 8927, -- Dark trinity mace
  [8100]  = 8928, -- Obsidian truncheon
  [8101]  = 8929, -- The Stomper
  [8862]  = 9776, -- Yalahari Armor
  [8863]  = 9777, -- Yalahari Legs
  [8864]  = 9778, -- Yalahari Mask
  [10200]  = 11117, -- Crystal Boots
  [10201]  = 11118, -- Dragon Scale Boots
  [10323]  = 11240, -- Guardian Boots
  [10384]  = 11301, -- Zaoan Armor
  [10385]  = 11302, -- Zaoan Helmet
  [10386]  = 11303, -- Zaoan Shoes
  [10387]  = 11304, -- Zaoan Legs
  [10388]  = 11305, -- Drakinata
  [10389]  = 11306, -- Sai
  [10390]  = 11307, -- Zaoan Sword
  [10391]  = 11308, -- Drachaku
  [10392]  = 11309, -- Twin Hooks
  [10438]  = 11355, -- Spellweavers robe
  [10439]  = 11356, -- Zaoan robe
  [11651]  = 12607, -- Elite Draken mail
  [11657]  = 12613, -- Twiceslicer
  [11686]  = 12642, -- Royal draken mail
  [11687]  = 12643, -- Royal Scale Robe
  [11688]  = 12644, -- Shield of Corruption
  [11689]  = 12645, -- Elite draken helmet
  [11693]  = 12649, -- Blade of Corruption
  [12731]  = 13871, -- Shimmer Sword
  [12733]  = 13873, -- Shimmer Bow
  [13991]  = 15404, -- Deepling Axe
  [13993]  = 15406, -- Ornate Chestplate
  [13994]  = 15407, -- Depth Lorica
  [13995]  = 15408, -- Depth Galea
  [13996]  = 15409, -- Depth Ocrea
  [13997]  = 15410, -- Depth Calcei
  [13999]  = 15412, -- Ornate Legs
  [14000]  = 15413, -- Ornate Shield
  [14001]  = 15414, -- Ornate Mace
  [14040]  = 15451, -- Warriors Axe
  [14042]  = 15452, -- Warriors Shield
  [14043]  = 15453, -- Guardian Axe
  [14086]  = 15489, -- Calopteryx Cape
  [14087]  = 15490, -- Grasshopper Legs
  [14088]  = 15491, -- Carapace Shield
  [14089]  = 15492, -- Hive Scythe
  [14246]  = 15643, -- Hive Bow
  [14247]  = 15644, -- Ornate Crossbow
  [14250]  = 15647, -- Deepling Squelcher
  [14769]  = 16112, -- Spellbook of ancient arcana
  [16107]  = 18401, -- Spellbook of vigilance
  [16160]  = 18450, -- Crystalline Sword
  [16161]  = 18451, -- Crystalline Axe
  [16162]  = 18452, -- Mycological mace
  [16163]  = 18453, -- Crystal Crossbow
  [16164]  = 18454, -- Mycological Bow
  [19358]  = 21692, -- Albino Plate
  [21981]  = 24637, -- Oriental Shoes
  [22726]  = 25382, -- Rift Shield
  [22727]  = 25383, -- Rift Lance
  [22866]  = 25522, -- Rift Bow
  [22867]  = 25523, -- Rift Crossbow
  [8094]  = 8922, -- Wand of Vodoo
  [3071]  = 2187, -- Wand of Inferno
  [8082]  = 8910, -- Underworld Rod
  [8084]  = 8912, -- Springsprout Rod

}

local function convertClientToServer(clientId)
  return clientToServerMapping[clientId] or clientId
end

--- Not Used ATM, it's for the all rest of items, so example: Ressources items and Rewards
local fusionRewardsDefault = {
  { id = 29623, chance = 50 },
}

local rewardEquipmentTable = {
  { id = 29619, chance = 35 }, --- Upgrade Rune v1
  { id = 29620, chance = 30 }, --- v2
  { id = 29621, chance = 20 }, --- v3
  { id = 29622, chance = 10 }, --- v4
}


local function weightedRandom(tableData)
  local totalChance = 0
  for _, entry in ipairs(tableData) do
    totalChance = totalChance + entry.chance
  end
  local rand = math.random() * totalChance
  local cumulative = 0
  for _, entry in ipairs(tableData) do
    cumulative = cumulative + entry.chance
    if rand <= cumulative then
      return entry.id
    end
  end
  return nil
end

local function isEquipment(clientId)
  local it = ItemType(clientId)
  if it then
    local weaponType = it:getWeaponType() or 0
    local armor = it:getArmor() or 0
    local defense = it:getDefense() or 0
    local extraDefense = it:getExtraDefense() or 0
    local attack = it:getAttack() or 0
    return (weaponType ~= 0) or (armor > 0) or (defense > 0) or (extraDefense > 0) or (attack > 0)
  end
  return false
end


local itemFusionExtended = CreatureEvent("ItemFusionExtended")

function itemFusionExtended.onExtendedOpcode(player, opcode, buffer)

  if opcode ~= itemFusionOpcode then
    return false
  end

  local data = json.decode(buffer)
  if not data or type(data) ~= "table" then
    return false
  end

  if data.action == "clear_items" then
    return true
  elseif data.action == "added_item" then
    if not data.item then
      return true
    end
    local clientId = data.item.clientId
    local convertedServerId = convertClientToServer(clientId)
    return true  
  elseif data.action == "fuse" then
    if not data.items or #data.items < 3 then
      local response = {
        action = "invalid_item",
        message = "You need 3 identical items to fuse."
      }
      player:sendExtendedOpcode(itemFusionOpcode, json.encode(response))
      return true
    end
    local firstClientId = data.items[1].clientId
    local convertedFirstId = convertClientToServer(firstClientId)
    local allIdentical = true
    for i = 2, #data.items do
      if convertClientToServer(data.items[i].clientId) ~= convertedFirstId then
        allIdentical = false
        break
      end
    end

    if not allIdentical then
      local response = {
        action = "invalid_item",
        message = "All items must be identical to fuse."
      }
      player:sendExtendedOpcode(itemFusionOpcode, json.encode(response))
      return true
    end

    local outputId = nil
    if isEquipment(convertedFirstId) then
      outputId = weightedRandom(rewardEquipmentTable)
    else
      outputId = weightedRandom(fusionRewardsDefault)
    end

    if not outputId then
      local response = {
        action = "invalid_item",
        message = "Fusion failed due to internal error."
      }
      player:sendExtendedOpcode(itemFusionOpcode, json.encode(response))
      return true
    end
 
    if player:removeItem(convertedFirstId, 3, -1, true) then
      player:addItem(outputId, 1)
      player:sendExtendedOpcode(itemFusionOpcode, json.encode({ action = "fused_success", outputId = outputId }))
    else
      player:sendExtendedOpcode(itemFusionOpcode, json.encode({ action = "invalid_item", message = "You do not have enough items or you have added an item that is equipped, first de equip the item and try again." }))
    end
    return true
  elseif data.action == "show" then
    return true
  end
  return true
end

itemFusionExtended:type("extendedopcode")
itemFusionExtended:register()

local LoginEvent = CreatureEvent("ItemFusionLogin")

function LoginEvent.onLogin(player)
  player:registerEvent("ItemFusionExtended")
  return true
end

LoginEvent:type("login")
LoginEvent:register()