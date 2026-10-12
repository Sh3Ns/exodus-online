local ec = EventCallback

local function getSkillId(skillName)
    if skillName == "club" then
        return SKILL_CLUB
    elseif skillName == "sword" then
        return SKILL_SWORD
    elseif skillName == "axe" then
        return SKILL_AXE
    elseif skillName == "mining" then
        return SKILL_MINING
    elseif skillName == "crafting" then
        return SKILL_CRAFTING
    elseif skillName == "woodcutting" then
        return SKILL_WOODCUTTING
    elseif skillName == "herbalist" then
        return SKILL_HERBALIST
    elseif skillName == "armorsmith" then
        return SKILL_ARMORSMITH
    elseif skillName == "weaponsmith" then
        return SKILL_WEAPONSMITH
    elseif skillName == "jewelsmith" then
        return SKILL_JEWELSMITH
    elseif skillName:sub(1, 4) == "dist" then
        return SKILL_DISTANCE
    elseif skillName:sub(1, 6) == "shield" then
        return SKILL_SHIELD
    elseif skillName:sub(1, 4) == "fish" then
        return SKILL_FISHING
    elseif skillName:sub(1, 4) == "fist" then
        return SKILL_FIST
    elseif skillName:sub(1, 1) == "m" then
        return SKILL_MAGLEVEL
    end
    return nil
end

local function hasRelevantStats(item)
    if not item then
        return false
    end

    local itemType = type(item)

    if itemType ~= "userdata" then
        return false
    end

    local itType = ItemType(item:getId())
    if not itType then
        return false
    end
    
    local hasWeapon = (itType:getAttack() > 0 or itType:getDefense() > 0)
    local hasArmor  = (itType:getArmor() > 0)
    local hasHit    = (itType:getHitChance() > 0)
    local hasAbsorb = false
    local abilities = itType:getAbilities()


    if abilities and abilities.absorbPercent then
        for _, percent in pairs(abilities.absorbPercent) do
            if percent > 0 then
                hasAbsorb = true
                break
            end
        end
    end

    local hasSkill = false
    if abilities and abilities.skills then
        local skillTypes = {
            "fist", "club", "sword", "axe", "distance",
            "shield", "magic", "mining", "crafting",
            "woodcutting", "herbalist", "armorsmith",
            "weaponsmith", "jewelsmith"
        }
        for _, skillName in ipairs(skillTypes) do
            local skillId = getSkillId(skillName)
            if skillId then
                local skillValue = abilities.skills[skillId]
                if skillValue and skillValue > 0 then
                    hasSkill = true
                    break
                end
            end
        end
    end

    local hasSpecialSkill = false
    local specialSkillTypes = {
        "criticalHitChance", "criticalHitAmount",
        "manaLeechChance", "manaLeechAmount",
        "lifeLeechChance", "lifeLeechAmount"
    }
    if abilities and abilities.specialSkills then
        for _, spec in ipairs(specialSkillTypes) do
            if abilities.specialSkills[spec] and abilities.specialSkills[spec] > 0 then
                hasSpecialSkill = true
                break
            end
        end
    end

    local final = (hasWeapon or hasArmor or hasHit or hasAbsorb or hasSkill or hasSpecialSkill)
    return final
end

local rarities = {
    { id = 1,  chance = 15.0, name = "Common" },
    { id = 2,  chance = 14.0, name = "Uncommon" },
    { id = 3,  chance = 12.0, name = "Rare" },
    { id = 4,  chance = 10.0, name = "Epic" },
    { id = 5,  chance =  8.5, name = "Legendary" },
    { id = 6,  chance =  7.0, name = "Exotic" },
    { id = 7,  chance =  6.0, name = "Mythic" },
    { id = 8,  chance =  4.5, name = "Chaos" },
    { id = 9,  chance =  3.8, name = "Eternal" },
    { id = 10, chance =  3.0, name = "Divine" },
    { id = 11, chance =  2.3, name = "Phantasmal" },
    { id = 12, chance =  1.7, name = "Celestial" },
    { id = 13, chance =  1.2, name = "Cosmic" },
    { id = 14, chance =  0.8, name = "Abyssal" },
    { id = 15, chance =  0.5, name = "Transcendent" }
}

local LOOT_CHANCE_CAP = tonumber(MAX_LOOTCHANCE) or 100000

local function percentToLootChance(percent)
    return math.max(0, math.floor(((tonumber(percent) or 0) / 100) * LOOT_CHANCE_CAP + 0.5))
end

local customGemDropChancePercent = 3

local customGemLoot = {
    -- Examples:
    -- These values are direct chances after the base gem roll succeeds.
    -- Only one custom gem can drop per corpse.
    -- 0.001% = 1
    -- 0.10% = 100
    -- 0.20% = 200
    { itemId = 30658, chance = percentToLootChance(10.000) }, -- Gem Power
    { itemId = 30666, chance = percentToLootChance(0.500) }, -- Small Garnet
    { itemId = 30667, chance = percentToLootChance(0.500) }, -- Small Dodge
    { itemId = 30668, chance = percentToLootChance(1.500) }, -- Small Bloodstone
    { itemId = 30669, chance = percentToLootChance(1.500) }, -- Pyrestone
    { itemId = 30670, chance = percentToLootChance(1.500) }, -- Froststone
    { itemId = 30671, chance = percentToLootChance(1.500) }, -- Stormstone
    { itemId = 30672, chance = percentToLootChance(1.500) }, -- Earthstone
    { itemId = 30673, chance = percentToLootChance(1.500) }, -- Deathstone
    { itemId = 30674, chance = percentToLootChance(1.500) }, -- Holystone
    { itemId = 30675, chance = percentToLootChance(1.500) }, -- Waterstone
    { itemId = 30676, chance = percentToLootChance(1.500) }, -- Abyssstone
    { itemId = 30677, chance = percentToLootChance(1.500) }, -- Spellstone
    { itemId = 30678, chance = percentToLootChance(1.500) }, -- Ascendstone
    { itemId = 30679, chance = percentToLootChance(1.500) }, -- Voltstone
    { itemId = 30680, chance = percentToLootChance(1.500) }, -- Emberstone
    { itemId = 30681, chance = percentToLootChance(1.500) }, -- Bindstone
    { itemId = 30682, chance = percentToLootChance(1.500) }, -- Surgestone
    { itemId = 30683, chance = percentToLootChance(1.500) }, -- Warstone
    { itemId = 30684, chance = percentToLootChance(1.500) }, -- Boonstone
    { itemId = 30685, chance = percentToLootChance(1.500) }, -- Venomstone
    { itemId = 30686, chance = percentToLootChance(1.500) }, -- Dreadstone
    { itemId = 30687, chance = percentToLootChance(1.500) }, -- Spiritstone
    { itemId = 30688, chance = percentToLootChance(1.500) }, -- Voidstone
    { itemId = 30689, chance = percentToLootChance(1.500) }, -- Gravitystone
    { itemId = 30690, chance = percentToLootChance(1.500) }, -- Chronostone
    { itemId = 30691, chance = percentToLootChance(1.500) }, -- Marksmanstone
    { itemId = 30692, chance = percentToLootChance(1.500) }, -- Battlestone
    { itemId = 30693, chance = percentToLootChance(1.500) }, -- Arcanestone
    { itemId = 30694, chance = percentToLootChance(1.500) }, -- Mendstone
    { itemId = 30695, chance = percentToLootChance(0.150) }, -- Totem Gem
    { itemId = 30696, chance = percentToLootChance(0.150) }, -- Sacred Link Gem
    { itemId = 30697, chance = percentToLootChance(0.150) }, -- Gem of Reversal
    { itemId = 30698, chance = percentToLootChance(1.500) }, -- Revenant Stone
    { itemId = 30699, chance = percentToLootChance(1.500) }, -- Runeheart Stone
    { itemId = 30700, chance = percentToLootChance(1.500) }, -- Dreamcatcher Stone
    { itemId = 30701, chance = percentToLootChance(0.150) }, -- Mirrorgem
    { itemId = 30702, chance = percentToLootChance(0.100) }, -- Forge Stone
    { itemId = 30703, chance = percentToLootChance(0.100) }, -- Fortune Stone
    { itemId = 30704, chance = percentToLootChance(1.500) }, -- Shockwave Stone
    { itemId = 30705, chance = percentToLootChance(0.020) }, -- Treasury Gem
    { itemId = 30706, chance = percentToLootChance(0.100) }, -- Soulmark Gem
    { itemId = 30707, chance = percentToLootChance(0.100) }, -- Kingsguard Gem
    { itemId = 30708, chance = percentToLootChance(0.100) }, -- Mimic Gem
    { itemId = 30709, chance = percentToLootChance(0.100) }, -- Coward's Crown Gem
    { itemId = 30710, chance = percentToLootChance(0.100) }, -- Betrayal Gem
    { itemId = 30711, chance = percentToLootChance(0.005) }, -- The Gravedigger's Malachite
    { itemId = 30712, chance = percentToLootChance(0.150) }, -- Obsidian Grudge
    { itemId = 30713, chance = percentToLootChance(0.005) }, -- Gem of Bond
    { itemId = 30714, chance = percentToLootChance(0.005) }, -- Collector Gem
    { itemId = 30715, chance = percentToLootChance(0.020) }, -- Training Gem
    { itemId = 30716, chance = percentToLootChance(0.020) }, -- Formation Stone
    { itemId = 30717, chance = percentToLootChance(0.100) }, -- Hunter's Focus
    { itemId = 30718, chance = percentToLootChance(0.020) }, -- Pendulum Stone
    { itemId = 30719, chance = percentToLootChance(0.020) }, -- Anchor Stone
    { itemId = 30720, chance = percentToLootChance(0.150) }, -- Steady Hand Gem
    { itemId = 30721, chance = percentToLootChance(0.150) }, -- Quick Step Gem
    { itemId = 30722, chance = percentToLootChance(0.150) }, -- Guarded Breath Gem
    { itemId = 30864, chance = percentToLootChance(0.150) }, -- Revenge Spark Gem
    { itemId = 30865, chance = percentToLootChance(0.150) }, -- Brace Gem
    { itemId = 30723, chance = percentToLootChance(0.150) }, -- Last Stand Gem
    { itemId = 30724, chance = percentToLootChance(0.150) }, -- Desperate Focus Gem
    { itemId = 30725, chance = percentToLootChance(0.150) }, -- Empty Mind Gem
    { itemId = 30726, chance = percentToLootChance(0.150) }, -- Full Mind Gem
    { itemId = 30727, chance = percentToLootChance(0.150) }, -- Thick Skin Gem
    { itemId = 30738, chance = percentToLootChance(0.150) }, -- Battle Rhythm Gem
    { itemId = 30729, chance = percentToLootChance(0.150) }, -- Safety Rhythm Gem
    { itemId = 30730, chance = percentToLootChance(0.150) }, -- Clean Kill Gem
    { itemId = 30731, chance = percentToLootChance(0.150) }, -- Dirty Kill Gem
    { itemId = 30732, chance = percentToLootChance(0.150) }, -- Mercy Gem
    { itemId = 30733, chance = percentToLootChance(0.150) }, -- Blood Tithe Gem
    { itemId = 30734, chance = percentToLootChance(0.150) }, -- Mana Price Gem
    { itemId = 30735, chance = percentToLootChance(0.150) }, -- Potion Saver Gem
    { itemId = 30736, chance = percentToLootChance(0.150) }, -- Potion Echo Gem
    { itemId = 30737, chance = percentToLootChance(0.150) }, -- Dry Flask Gem
    { itemId = 30738, chance = percentToLootChance(0.150) }, -- Spell Pause Gem
    { itemId = 30739, chance = percentToLootChance(0.150) }, -- Spell Chain Gem
    { itemId = 30740, chance = percentToLootChance(0.150) }, -- Weapon Chain Gem
    { itemId = 30741, chance = percentToLootChance(0.150) }, -- Calm Recovery Gem
    { itemId = 30742, chance = percentToLootChance(0.150) }, -- Panic Recovery Gem
    { itemId = 30743, chance = percentToLootChance(0.150) }, -- Narrow Escape Gem
    { itemId = 30744, chance = percentToLootChance(0.150) }, -- Second Sip Gem
    { itemId = 30745, chance = percentToLootChance(0.150) }, -- Mirror Sip Gem
    { itemId = 30746, chance = percentToLootChance(0.150) }, -- Warmup Gem
    { itemId = 30747, chance = percentToLootChance(0.150) }, -- Cooldown Gem
    { itemId = 30748, chance = percentToLootChance(0.150) }, -- Lucky Scratch Gem
    { itemId = 30749, chance = percentToLootChance(0.150) }, -- Lucky Guard Gem
    { itemId = 30750, chance = percentToLootChance(0.150) }, -- Minor Feast Gem
    { itemId = 30751, chance = percentToLootChance(0.150) }, -- Minor Focus Gem
    { itemId = 30752, chance = percentToLootChance(0.150) }, -- Safe Hands Gem
    { itemId = 30753, chance = percentToLootChance(0.150) }, -- Sharp Hands Gem
    { itemId = 30754, chance = percentToLootChance(0.150) }, -- Soft Landing Gem
    { itemId = 30755, chance = percentToLootChance(0.150) }, -- Hard Landing Gem
    { itemId = 30756, chance = percentToLootChance(0.150) }, -- Low Flame Gem
    { itemId = 30757, chance = percentToLootChance(0.150) }, -- High Flame Gem
    { itemId = 30758, chance = percentToLootChance(0.150) }, -- Low Tide Gem
    { itemId = 30759, chance = percentToLootChance(0.150) }, -- High Tide Gem
    { itemId = 30760, chance = percentToLootChance(0.150) }, -- Short Fuse Gem
    { itemId = 30761, chance = percentToLootChance(0.150) }, -- Long Fuse Gem
    { itemId = 30762, chance = percentToLootChance(0.150) }, -- Quiet Armor Gem
    { itemId = 30763, chance = percentToLootChance(0.150) }, -- Loud Armor Gem
    { itemId = 30764, chance = percentToLootChance(0.150) }, -- Lucky Boots Gem
    { itemId = 30765, chance = percentToLootChance(0.150) }, -- Fighter's Mark Gem
    { itemId = 30766, chance = percentToLootChance(0.150) }, -- Stubborn Gem
    { itemId = 30767, chance = percentToLootChance(0.150) }, -- Fresh Start Gem
    { itemId = 30768, chance = percentToLootChance(0.150) }, -- Overheal Gem
    { itemId = 30769, chance = percentToLootChance(0.150) }, -- Barrier Sip Gem
    { itemId = 30770, chance = percentToLootChance(0.150) }, -- First Blood Gem
    { itemId = 30771, chance = percentToLootChance(0.150) }, -- Mana Battery Gem
    { itemId = 30772, chance = percentToLootChance(0.150) }, -- Cleanse Sip Gem
    { itemId = 30773, chance = percentToLootChance(0.150) }, -- Stability Gem
    { itemId = 30774, chance = percentToLootChance(0.150) }, -- Rune Saver Gem
    { itemId = 30775, chance = percentToLootChance(0.150) }, -- Serrated Edge Gem
    { itemId = 30776, chance = percentToLootChance(0.150) }, -- Hunter Compass Gem
    { itemId = 30777, chance = percentToLootChance(0.150) }, -- Recovery Window Gem
    { itemId = 30778, chance = percentToLootChance(0.020) }, -- Chronicle Gem
    { itemId = 30779, chance = percentToLootChance(0.020) }, -- Predator Eye
    { itemId = 30780, chance = percentToLootChance(0.020) }, -- Phoenix Gem
    { itemId = 30781, chance = percentToLootChance(0.020) }, -- Living Gem
    { itemId = 30782, chance = percentToLootChance(0.150) }, -- Alchemist Gem
    { itemId = 30783, chance = percentToLootChance(0.100) }, -- Warcry Gem
    { itemId = 30784, chance = percentToLootChance(0.100) }, -- Martyr Gem
    { itemId = 30785, chance = percentToLootChance(0.100) }, -- Herald Gem
    { itemId = 30786, chance = percentToLootChance(0.020) }, -- The Obituary Gem
    { itemId = 30787, chance = percentToLootChance(0.100) }, -- Last Breath Gem
    { itemId = 30788, chance = percentToLootChance(0.100) }, -- Overkill Gem
    { itemId = 30789, chance = percentToLootChance(0.005) }, -- Requiem Gem
    { itemId = 30790, chance = percentToLootChance(0.020) }, -- Momentum Gem
    { itemId = 30791, chance = percentToLootChance(0.005) }, -- Gambler's Soul
    { itemId = 30792, chance = percentToLootChance(0.100) }, -- Infection Gem
    { itemId = 30793, chance = percentToLootChance(0.100) }, -- Damage Gem
    { itemId = 30794, chance = percentToLootChance(0.020) }, -- Blood Price Gem
    { itemId = 30795, chance = percentToLootChance(0.150) }, -- Pacifist Gem
    { itemId = 30796, chance = percentToLootChance(0.020) }, -- Carrion Gem
    { itemId = 30797, chance = percentToLootChance(0.150) }, -- Executioner's Mercy Gem
    { itemId = 30798, chance = percentToLootChance(0.150) }, -- Echo Strike Gem
    { itemId = 30799, chance = percentToLootChance(0.150) }, -- Stoneblood Gem
    { itemId = 30800, chance = percentToLootChance(0.150) }, -- Rupture Gem
    { itemId = 30801, chance = percentToLootChance(0.150) }, -- Guardian Pulse Gem
    { itemId = 30802, chance = percentToLootChance(0.150) }, -- Second Skin Gem
    { itemId = 30803, chance = percentToLootChance(0.150) }, -- Panic Ward Gem
    { itemId = 30804, chance = percentToLootChance(0.100) }, -- Cartel Gem
    { itemId = 30805, chance = percentToLootChance(0.150) }, -- Memory Gem
    { itemId = 30806, chance = percentToLootChance(0.100) }, -- Cursed Fortune Gem
    { itemId = 30807, chance = percentToLootChance(0.150) }, -- Blood Echo Gem
    { itemId = 30808, chance = percentToLootChance(0.150) }, -- Sunder Gem
    { itemId = 30809, chance = percentToLootChance(0.150) }, -- Shared Grace Gem
    { itemId = 30810, chance = percentToLootChance(0.150) }, -- Beacon Gem
    { itemId = 30811, chance = percentToLootChance(0.150) }, -- Artisan's Luck Gem
    { itemId = 30812, chance = percentToLootChance(0.150) }, -- Glassheart Gem
    { itemId = 30813, chance = percentToLootChance(0.150) }, -- Bulwark Gem
    { itemId = 30814, chance = percentToLootChance(0.500) }, -- Vampiric Shard
    { itemId = 30815, chance = percentToLootChance(0.150) }, -- Mana Leech Gem
    { itemId = 30816, chance = percentToLootChance(0.150) }, -- Blood Pact Gem
    { itemId = 30817, chance = percentToLootChance(0.150) }, -- Titan Gem
    { itemId = 30818, chance = percentToLootChance(0.150) }, -- Stonefoot Gem
    { itemId = 30819, chance = percentToLootChance(0.150) }, -- Evasion Gem
    { itemId = 30820, chance = percentToLootChance(0.150) }, -- Counterspell Gem
    { itemId = 30821, chance = percentToLootChance(0.150) }, -- Lifeline Gem
    { itemId = 30822, chance = percentToLootChance(0.150) }, -- Spell Hunger Gem
    { itemId = 30823, chance = percentToLootChance(0.150) }, -- Last Ember Gem
    { itemId = 30824, chance = percentToLootChance(0.150) }, -- Armor Echo Gem
    { itemId = 30825, chance = percentToLootChance(0.150) }, -- Weak Point Gem
    { itemId = 30826, chance = percentToLootChance(0.150) }, -- Guard Break Gem
    { itemId = 30827, chance = percentToLootChance(0.150) }, -- Nullstep Gem
    { itemId = 30828, chance = percentToLootChance(0.150) }, -- Duelist Gem
    { itemId = 30829, chance = percentToLootChance(1.500) }, -- Phantomstone
    { itemId = 30830, chance = percentToLootChance(0.020) }, -- Wayfinder Gem
    { itemId = 30831, chance = percentToLootChance(0.150) }, -- Riftstep Gem
    { itemId = 30832, chance = percentToLootChance(0.500) }, -- Siphon Bloom
    { itemId = 30833, chance = percentToLootChance(0.150) }, -- Amplifier Gem
    { itemId = 30834, chance = percentToLootChance(0.150) }, -- Oathbound Gem
    { itemId = 30835, chance = percentToLootChance(0.150) }, -- Vowkeeper Gem
    { itemId = 30836, chance = percentToLootChance(0.005) }, -- Paradox Gem
    { itemId = 30837, chance = percentToLootChance(0.150) }, -- Mana Nova Gem
    { itemId = 30838, chance = percentToLootChance(0.150) }, -- Volley Chain Gem
    { itemId = 30839, chance = percentToLootChance(0.150) }, -- Hexmirror Gem
    { itemId = 30840, chance = percentToLootChance(0.150) }, -- Chameleon Gem
    { itemId = 30841, chance = percentToLootChance(0.150) }, -- Galvanic Gem
    { itemId = 30842, chance = percentToLootChance(0.005) }, -- Nemesis Brand Gem
    { itemId = 30843, chance = percentToLootChance(0.100) }, -- Madness Gem
    { itemId = 30844, chance = percentToLootChance(0.150) }, -- Potion Bloom Gem
    { itemId = 30845, chance = percentToLootChance(0.150) }, -- Boss Focus Gem
    { itemId = 30846, chance = percentToLootChance(0.005) }, -- Hive Stone
    { itemId = 30847, chance = percentToLootChance(0.005) }, -- Veilstone
    { itemId = 30848, chance = percentToLootChance(0.020) }, -- Nemesis Gem
    { itemId = 30849, chance = percentToLootChance(0.020) }, -- Haunted Hunt Gem
    { itemId = 30850, chance = percentToLootChance(0.020) }, -- Gem of Possession
    { itemId = 30851, chance = percentToLootChance(0.005) }, -- Abattoir Gem
    { itemId = 30852, chance = percentToLootChance(0.005) }, -- Tri-Craft Gem
    { itemId = 30853, chance = percentToLootChance(0.005) }, -- Treasure Goblin Gem
    { itemId = 30854, chance = percentToLootChance(0.005) }, -- Roll Gem
    { itemId = 30855, chance = percentToLootChance(0.005) }, -- Cartography Gem
    { itemId = 30856, chance = percentToLootChance(0.005) }, -- Profession Mastery Gem
    { itemId = 30857, chance = percentToLootChance(0.005) }, -- Gem of Corruption
    { itemId = 30858, chance = percentToLootChance(0.020) }, -- Gem of Purity
    { itemId = 30859, chance = percentToLootChance(0.005) }, -- Tide Gem
    { itemId = 30860, chance = percentToLootChance(0.005) }, -- Waystone Conqueror Gem
    { itemId = 30861, chance = percentToLootChance(0.020) }, -- Ambush Gem
    { itemId = 30862, chance = percentToLootChance(0.020) }, -- Treasure Echo Gem
    { itemId = 30863, chance = percentToLootChance(0.020) }, -- Lucky Hourglass Gem
}

local function rollCustomGemLoot(entries)
    if not entries or #entries == 0 then
        return nil
    end

    local baseDropChance = percentToLootChance(customGemDropChancePercent)
    if baseDropChance <= 0 or getLootRandom() > baseDropChance then
        return nil
    end

    for _, entry in ipairs(entries) do
        local itemId = tonumber(entry.itemId)
        local chance = math.max(0, math.floor(tonumber(entry.chance) or 0))
        if itemId and chance > 0 and getLootRandom() <= chance then
            return itemId
        end
    end

    return nil
end

local function isGemSystemEnabled()
    if type(_G.GemsSocket_isEnabled) == "function" then
        return _G.GemsSocket_isEnabled()
    end
    return true
end

local rarityBonusStorages = {405790, 405793}

local function getTotalRarityBonus(player)
    local total = 0
    for _, storageId in ipairs(rarityBonusStorages) do
        local val = player:getStorageValue(storageId)
        if val > 0 then
            total = total + val
        end
    end
    if type(_G.GemsSocket_getEquippedSocketBonusTotal) == "function" then
        total = total + math.max(0, tonumber(_G.GemsSocket_getEquippedSocketBonusTotal(player, "socket_loot_rarity_chance")) or 0)
    end
    if type(_G.GemsSocket_advancedGetLootRarityBonus) == "function" then
        total = total + (tonumber(_G.GemsSocket_advancedGetLootRarityBonus(player)) or 0)
    end
    return total
end

local goldLootItems = {
    [2148] = true,
    [2152] = true,
    [2160] = true,
}

local function getGoldLootMultiplier(player, itemId)
    if not goldLootItems[itemId] or type(_G.GemsSocket_getGoldLootMultiplierBonus) ~= "function" then
        return 1
    end
    return 1 + math.max(0, tonumber(_G.GemsSocket_getGoldLootMultiplierBonus(player)) or 0)
end

local function rollRarity(player)
    local bonus = player and getTotalRarityBonus(player) or 0

    local baseChance = 5 + bonus
    if baseChance > 100 then
        baseChance = 100
    end

    if math.random(100) > baseChance then
        return 0
    end

    for _, r in ipairs(rarities) do
        local finalChance = r.chance + (bonus * 0.5)
        if finalChance > 100 then
            finalChance = 100
        end

        local roll = math.random(100)
        if roll <= finalChance then
            return r.id
        end
    end

    return 0
end

local function getRarityName(rarityId)
    for _, data in ipairs(rarities) do
        if data.id == rarityId then
            return data.name
        end
    end
    return "Common"
end

local function getCustomLootDescription(corpse)
    local parts = {}
    for slot = 0, corpse:getSize() - 1 do
        local item = corpse:getItem(slot)
        if type(item) == "userdata" and item:isItem() then
            local count = item:getCount()
            local baseName = ItemType(item:getId()):getName()
            local rarityId = item:getCustomAttribute("rarity")
            if rarityId and rarityId > 0 then
                local prefix = string.format("[%s] ", getRarityName(rarityId))
                baseName = prefix .. baseName
            end
            if count > 1 then
                baseName = string.format("%dx %s", count, baseName)
            end
            table.insert(parts, baseName)
        end
    end
    return table.concat(parts, ", ")
end

ec.onDropLoot = function(self, corpse)
    if configManager.getNumber(configKeys.RATE_LOOT) == 0 then
		return
	end
    local mType  = self:getType()
    local player = Player(corpse:getCorpseOwner())

    if not player then
        return
    end
    if player:getStamina() <= 840 then
        local text = ("Loot of %s: nothing (due to low stamina)")
            :format(mType:getNameDescription())
        local party = player:getParty()
        if party then
            party:broadcastPartyLoot(text)
        else
            player:sendTextMessage(MESSAGE_LOOT, text)
        end
        return
    end

    local monsterLevel = self:getMonsterLevel()
    local lootMultiplier = 1
    local bossLootGamble = nil

    if monsterLevel >= 5 and monsterLevel < 50 then
        lootMultiplier = 1.15
    elseif monsterLevel >= 50 and monsterLevel < 100 then
        lootMultiplier = 1.35
    elseif monsterLevel >= 100 and monsterLevel < 200 then
        lootMultiplier = 1.65
    elseif monsterLevel >= 200 and monsterLevel < 300 then
        lootMultiplier = 1.95
    elseif monsterLevel >= 300 and monsterLevel < 500 then
        lootMultiplier = 2.25
    elseif monsterLevel >= 500 then
        lootMultiplier = 2.70
    end

    if player:getStorageValue(76855) == 1 then
        lootMultiplier = lootMultiplier + 1.15
    elseif player:getStorageValue(76855) == 2 then
        lootMultiplier = lootMultiplier + 1.35
    elseif player:getStorageValue(76855) == 3 then
        lootMultiplier = lootMultiplier + 1.65
    elseif player:getStorageValue(76855) == 4 then
        lootMultiplier = lootMultiplier + 1.95
    elseif player:getStorageValue(76855) == 5 then
        lootMultiplier = lootMultiplier + 2.25
    elseif player:getStorageValue(76855) == 6 then
        lootMultiplier = lootMultiplier + 2.70
    end

    local bonusLootStorage = player:getStorageValue(405789)
    if bonusLootStorage and bonusLootStorage > 0 then
    local bonusMultiplier = math.min(3.00, 1.00 + bonusLootStorage * 0.01)
        lootMultiplier = lootMultiplier + (bonusMultiplier - 1.00)
    end
    local bonusLootStorage = player:getStorageValue(405792)
    if bonusLootStorage and bonusLootStorage > 0 then
    local bonusMultiplier = math.min(3.00, 1.00 + bonusLootStorage * 0.01)
        lootMultiplier = lootMultiplier + (bonusMultiplier - 1.00)
    end
    if type(_G.TaskBoard) == "table" and type(_G.TaskBoard.getBountyLootMultiplier) == "function" then
        local bountyLootMultiplier = tonumber(_G.TaskBoard.getBountyLootMultiplier(player, self)) or 1
        if bountyLootMultiplier > 1 then
            lootMultiplier = lootMultiplier + (bountyLootMultiplier - 1)
        end
    end

    local monsterLoot = mType:getLoot()
    if not monsterLoot then
        return
    end

    if next(monsterLoot) ~= nil and isGemSystemEnabled() and type(_G.GemsSocket_getBossLootGamble) == "function" then
        local ok, result = pcall(_G.GemsSocket_getBossLootGamble, player, self, corpse)
        if ok and type(result) == "table" then
            bossLootGamble = result
        elseif not ok then
            print(string.format("[GamblerSoul] Boss loot gamble failed for %s: %s", self:getName(), tostring(result)))
        end
    end

    local function addLootRoll(lootData, chancePercent)
        if type(lootData) ~= "table" or not lootData.itemId then
            return
        end
        local baseChance = math.max(0, tonumber(lootData.chance) or 0)
        local scaledChance = math.min(LOOT_CHANCE_CAP, math.floor(baseChance * (math.max(0, chancePercent) / 100)))
        if scaledChance <= 0 or getLootRandom() > scaledChance then
            return
        end
        local minCount = math.max(1, math.floor(tonumber(lootData.minCount) or 1))
        local maxCount = math.max(minCount, math.floor(tonumber(lootData.maxCount) or tonumber(lootData.count) or 1))
        local baseCount = math.random(minCount, maxCount)
        local finalCount = math.max(1, math.floor(baseCount * lootMultiplier * getGoldLootMultiplier(player, lootData.itemId)))
        local newItem = corpse:addItem(lootData.itemId, finalCount)
        if not newItem or not hasRelevantStats(newItem) then
            return
        end
        local itType = ItemType(newItem:getId())
        local isAmmo = itType and itType:getWeaponType() == WEAPON_AMMO
        if not isAmmo then
            local rarityId = rollRarity(player)
            if rarityId > 0 then
                newItem:setCustomAttribute("rarity", rarityId)
            end
        end
    end

    for _, lootData in ipairs(monsterLoot) do
        local normalChancePercent = bossLootGamble and bossLootGamble.outcome == "misfortune"
            and math.max(0, math.min(100, tonumber(bossLootGamble.misfortuneLootPercent) or 50)) or 100
        addLootRoll(lootData, normalChancePercent)
        if bossLootGamble and bossLootGamble.outcome == "fortune" then
            addLootRoll(lootData, math.max(0, math.min(100, tonumber(bossLootGamble.fortuneExtraRollPercent) or 50)))
        end
    end

    if math.random(1, 100) <= 2 then
        local quantity28343 = math.random(1, 5)
        local specialItem1 = corpse:addItem(28343, quantity28343)
        if not specialItem1 then
            print(string.format(
                "[3][Monster:onDropLoot] - Could not add special item 28343 to monster: %s, corpse id: %d.",
                self:getName(),
                corpse:getId()
            ))
        end

        local quantity28344 = math.random(1, 3)
        local specialItem2 = corpse:addItem(28344, quantity28344)
        if not specialItem2 then
            print(string.format(
                "[3][Monster:onDropLoot] - Could not add special item 28344 to monster: %s, corpse id: %d.",
                self:getName(),
                corpse:getId()
            ))
        end
    end
    if math.random(1, 100) <= 2 then
    local waystones = {
        {id=29845, chance=50},
        {id=29846, chance=40},
        {id=29847, chance=30},
        {id=29848, chance=20},
        {id=29849, chance=10},
        {id=29850, chance=5},
    }

    local total = 0
    for _, w in ipairs(waystones) do total = total + w.chance end
    local roll = math.random(1, total)
    local acc = 0
        for _, w in ipairs(waystones) do
            acc = acc + w.chance
            if roll <= acc then
                local it = corpse:addItem(w.id, 1)
                if not it then
                    print(("[3][Monster:onDropLoot] - Could not add waystone %d to %s, corpse id: %d.")
                        :format(w.id, self:getName(), corpse:getId()))
                end
                break
            end
        end
    end

    if isGemSystemEnabled() then
        local gemItemId = rollCustomGemLoot(customGemLoot)
        if gemItemId then
            local gemItem = corpse:addItem(gemItemId, 1)
            if not gemItem then
                print(string.format(
                    "[3][Monster:onDropLoot] - Could not add custom gem %d to monster: %s, corpse id: %d.",
                    gemItemId,
                    self:getName(),
                    corpse:getId()
                ))
            end
        end
    end

    if isGemSystemEnabled() and type(_G.GemsSocket_mimicOnDropLoot) == "function" then
        _G.GemsSocket_mimicOnDropLoot(player, self, corpse)
    end

    if isGemSystemEnabled() and type(_G.GemsSocket_advancedOnDropLoot) == "function" then
        _G.GemsSocket_advancedOnDropLoot(player, self, corpse)
    end

    if type(_G.TreasuryGem) == "table" and _G.TreasuryGem.recordCorpseLoot then
        _G.TreasuryGem.recordCorpseLoot(player, corpse)
    end

    local description = getCustomLootDescription(corpse)
    if description == "" then
        description = "nothing"
    end

    local text = ("Loot of %s: %s"):format(mType:getNameDescription(), description)
    local party = player:getParty()
    if party then
        for _, member in ipairs(party:getMembers()) do
            member:sendTextMessage(MESSAGE_LOOT, text)
        end
        party:getLeader():sendTextMessage(MESSAGE_LOOT, text)
    else
        player:sendTextMessage(MESSAGE_LOOT, text)
    end
end

ec:register()
