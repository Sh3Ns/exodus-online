WheelDestiny = WheelDestiny or {}
Gem_Atelier = Gem_Atelier or {}
Fragment_Workshop = Fragment_Workshop or {}

WDHit = 1
WDMana = 2
WDCap = 3
WDMit = 4

WheelDestiny.Dedications = {
    [WDHit] = { text = "Hit Points" },
    [WDMana] = { text = "Mana" },
    [WDCap] = { text = "Capacity" },
    [WDMit] = { text = "Mitigation Multiplier" }
}

WheelDestiny.MediumPerkInfos = {
    GeneralInfo = "The Conviction Perk is unlocked when the maximum number of promotion points for this slice has been assigned. Repeated perks stack.",
    AugGeneralInfo = "Spell augmentations have two stages. Complete either matching slice for stage I and both matching slices for stage II."
}

local slotDefinitions = {
    [1]  = { 200, 1, "lifemana", "special_1" },
    [2]  = { 150, 1, "mitigation", "manaleech" },
    [3]  = { 100, 1, "health", "vessel", 1 },
    [4]  = { 100, 2, "mana", "skill" },
    [5]  = { 150, 2, "health", "vessel", 2 },
    [6]  = { 200, 2, "lifemana", "spell_1" },
    [7]  = { 150, 1, "mitigation", "vessel", 2 },
    [8]  = { 100, 1, "health", "spell_2" },
    [9]  = { 75,  1, "mana", "lifeleech" },
    [10] = { 75,  2, "capacity", "vessel", 0 },
    [11] = { 100, 2, "mana", "spell_3" },
    [12] = { 150, 2, "health", "manaleech" },
    [13] = { 100, 1, "health", "spell_4" },
    [14] = { 75,  1, "mana", "skill" },
    [15] = { 50,  1, "capacity", "vessel", 0 },
    [16] = { 50,  2, "mitigation", "spell_5" },
    [17] = { 75,  2, "capacity", "lifeleech" },
    [18] = { 100, 2, "mana", "vessel", 1 },
    [19] = { 100, 3, "mitigation", "vessel", 1 },
    [20] = { 75,  3, "health", "manaleech" },
    [21] = { 50,  3, "mana", "spell_1" },
    [22] = { 50,  4, "health", "vessel", 0 },
    [23] = { 75,  4, "mitigation", "skill" },
    [24] = { 100, 4, "capacity", "spell_2" },
    [25] = { 150, 3, "capacity", "lifeleech" },
    [26] = { 100, 3, "mitigation", "spell_3" },
    [27] = { 75,  3, "health", "vessel", 0 },
    [28] = { 75,  4, "mitigation", "manaleech" },
    [29] = { 100, 4, "capacity", "spell_4" },
    [30] = { 150, 4, "mana", "vessel", 2 },
    [31] = { 200, 3, "lifemana", "spell_5" },
    [32] = { 150, 3, "capacity", "vessel", 2 },
    [33] = { 100, 3, "mitigation", "skill" },
    [34] = { 100, 4, "capacity", "vessel", 1 },
    [35] = { 150, 4, "mana", "lifeleech" },
    [36] = { 200, 4, "lifemana", "special_2" }
}

local slotLinks = {
    [1] = { 2, 7 },
    [2] = { 3, 8, 7, 1 },
    [3] = { 8, 9, 4, 2 },
    [4] = { 3, 10, 11, 5 },
    [5] = { 4, 11, 12, 6 },
    [6] = { 12, 5 },
    [7] = { 8, 13, 2, 1 },
    [8] = { 14, 9, 13, 3, 7, 2 },
    [9] = { 14, 15, 10, 3, 8 },
    [10] = { 9, 16, 17, 4, 11 },
    [11] = { 10, 17, 4, 18, 5, 12 },
    [12] = { 11, 18, 5, 6 },
    [13] = { 8, 14, 19, 7 },
    [14] = { 9, 15, 20, 13, 8 },
    [15] = {},
    [16] = {},
    [17] = { 10, 16, 23, 18, 11 },
    [18] = { 17, 11, 24, 12 },
    [19] = { 13, 20, 26, 25 },
    [20] = { 21, 14, 27, 19, 26 },
    [21] = {},
    [22] = {},
    [23] = { 22, 28, 17, 24, 29 },
    [24] = { 23, 18, 29, 30 },
    [25] = { 19, 26, 32, 31 },
    [26] = { 27, 20, 19, 25, 32, 33 },
    [27] = { 21, 28, 20, 26, 33 },
    [28] = { 22, 23, 27, 29, 34 },
    [29] = { 23, 28, 24, 34, 30, 35 },
    [30] = { 24, 29, 35, 36 },
    [31] = { 25, 32 },
    [32] = { 26, 25, 33, 31 },
    [33] = { 27, 34, 26, 32 },
    [34] = { 28, 33, 29, 35 },
    [35] = { 29, 34, 30, 36 },
    [36] = { 30, 35 }
}

local healthPerPoint = { [1] = 3, [2] = 2, [3] = 1, [4] = 1, [5] = 2 }
local manaPerPoint = { [1] = 1, [2] = 3, [3] = 6, [4] = 6, [5] = 2 }
local capacityPerPoint = { [1] = 5, [2] = 4, [3] = 2, [4] = 2, [5] = 5 }
local gemCapacityStep = { [1] = 5, [2] = 4, [3] = 2, [4] = 2, [5] = 4 }

local specialPerks = {
    [1] = {
        [1] = { "Battle Instinct", "Gain shielding and melee skill while surrounded by creatures." },
        [2] = { "Positional Tactics", "Gain distance skill at range, or holy and healing magic while enemies are adjacent." },
        [3] = { "Runic Mastery", "Runes have a chance to temporarily increase your magic level." },
        [4] = { "Healing Link", "Healing another player with Nature's Embrace or Heal Friend also heals you." },
        [5] = { "Guiding Presence", "Share part of your mantra with nearby party members." }
    },
    [2] = {
        [1] = { "Battle Healing", "Challenging creatures heals you; the effect improves at low health." },
        [2] = { "Ballistic Mastery", "Improve crossbow critical damage and bow attacks against physical and holy sensitivity." },
        [3] = { "Focus Mastery", "A focus spell increases the damage of your next damage spell." },
        [4] = { "Runic Mastery", "Runes have a chance to temporarily increase your magic level." },
        [5] = { "Sanctuary", "Consuming Harmony creates a field that improves damage and healing." }
    }
}

local skillNames = {
    [1] = "Weapon Skill Boost",
    [2] = "Distance Skill Boost",
    [3] = "Magic Skill Boost",
    [4] = "Magic Skill Boost",
    [5] = "Fist Fighting Skill Boost"
}

local spellPerks = {
    [1] = {
        spell_1 = { "Augmented Front Sweep", "Adds 5% life leech to this spell", "+14% Base Damage" },
        spell_2 = { "Augmented Groundshaker", "+12.5% Base Damage", "-2s Cooldown" },
        spell_3 = { "Augmented Chivalrous Challenge", "-20 Mana Cost", "Jumps to one additional target" },
        spell_4 = { "Augmented Intense Wound Cleansing", "+125% Base Healing", "-300s Cooldown" },
        spell_5 = { "Augmented Fierce Berserk", "-30 Mana Cost", "+10% Base Damage" }
    },
    [2] = {
        spell_1 = { "Augmented Sharpshooter", "Support spells can be cast while active", "-6s Cooldown and +5% distance skill bonus" },
        spell_2 = { "Augmented Strong Ethereal Spear", "-2s Cooldown", "+380% Base Damage" },
        spell_3 = { "Augmented Divine Dazzle", "Jumps to one additional target", "Longer duration and -4s Cooldown" },
        spell_4 = { "Augmented Swift Foot", "Focus secondary cooldown -8s", "-6s Cooldown and no damage penalty" },
        spell_5 = { "Augmented Divine Caldera", "-20 Mana Cost", "+8.5% Base Damage" }
    },
    [3] = {
        spell_1 = { "Augmented Focus Spells", "+8% Base Damage for focus spells", "-4s Cooldown and reduced focus cooldown" },
        spell_2 = { "Augmented Magic Shield", "Enhanced effect", "-6s Cooldown" },
        spell_3 = { "Augmented Sap Strength", "Enlarged affected area", "Increased damage reduction" },
        spell_4 = { "Augmented Energy Wave", "+5% Base Damage", "Enlarged affected area" },
        spell_5 = { "Augmented Great Fire Wave", "Adds critical extra damage", "+5% Base Damage" }
    },
    [4] = {
        spell_1 = { "Augmented Strong Ice Wave", "Adds 3% mana leech to this spell", "+8% Base Damage" },
        spell_2 = { "Augmented Mass Healing", "+5% Base Healing", "Enlarged affected area" },
        spell_3 = { "Augmented Nature's Embrace", "+11% Base Healing", "-10s Cooldown" },
        spell_4 = { "Augmented Terra Wave", "+5% Base Damage", "Adds 5% life leech to this spell" },
        spell_5 = { "Augmented Heal Friend", "-10 Mana Cost", "+5% Base Healing" }
    },
    [5] = {
        spell_1 = { "Augmented Chained Penance", "Jumps to one additional target", "+18% Base Damage" },
        spell_2 = { "Augmented Mass Spirit Mend", "+8% Base Healing", "Enlarged affected area" },
        spell_3 = { "Augmented Mystic Repulse", "-4s Cooldown", "+40% Base Damage" },
        spell_4 = { "Augmented Flurry of Blows", "Adds 5% life leech to this spell", "+15% Base Damage" },
        spell_5 = { "Augmented Sweeping Takedown", "Adds 3% mana leech to this spell", "Adds critical extra damage" }
    }
}

local spellPairs = {
    spell_1 = { [6] = 21, [21] = 6 },
    spell_2 = { [8] = 24, [24] = 8 },
    spell_3 = { [11] = 26, [26] = 11 },
    spell_4 = { [13] = 29, [29] = 13 },
    spell_5 = { [16] = 31, [31] = 16 }
}

local mediumIcons = {
    [1] = { 8,5,37,7,38,12,37,13,6,38,14,5,11,7,37,10,6,38,39,5,12,40,7,13,6,14,39,5,11,40,10,39,7,40,6,9 },
    [2] = { 17,5,37,15,38,22,37,21,6,38,20,5,19,15,37,18,6,38,39,5,22,40,15,21,6,20,39,5,19,40,18,39,15,40,6,16 },
    [3] = { 35,5,37,34,38,27,37,36,6,38,26,5,25,34,37,24,6,38,39,5,27,40,34,36,6,26,39,5,25,40,24,39,34,40,6,27 },
    [4] = { 28,5,37,34,38,31,37,32,6,38,33,5,30,34,37,29,6,38,39,5,31,40,34,32,6,33,39,5,30,40,29,39,34,40,6,35 },
    [5] = { 42,5,37,43,38,47,37,45,6,38,46,5,48,43,37,44,6,38,39,5,47,40,43,45,6,46,39,5,48,40,44,39,43,40,6,41 }
}

local smallIcons = { 2,4,0,1,0,2,4,0,1,3,1,0,0,1,3,4,3,1,4,0,1,0,4,3,3,4,0,4,3,1,2,3,4,3,1,2 }

local function dedicationFor(vocation, dedication)
    if dedication == "health" then
        return { { text = WDHit, quantity = healthPerPoint[vocation] } }
    elseif dedication == "mana" then
        return { { text = WDMana, quantity = manaPerPoint[vocation] } }
    elseif dedication == "capacity" then
        return { { text = WDCap, quantity = capacityPerPoint[vocation] } }
    elseif dedication == "mitigation" then
        return { { text = WDMit, quantity = 0.03, percent = true } }
    end

    return {
        { text = WDHit, quantity = healthPerPoint[vocation] },
        { text = WDMana, quantity = manaPerPoint[vocation] }
    }
end

local domainNames = { "Top Left", "Top Right", "Bottom Left", "Bottom Right" }

local function convictionFor(vocation, slotId, domain, conviction)
    if conviction == "vessel" then
        return { { text = "Vessel Resonance " .. domainNames[domain], priority = 1 } }
    elseif conviction == "skill" then
        return { { text = skillNames[vocation], quantity = 1, priority = 1 } }
    elseif conviction == "lifeleech" then
        return { { text = "Life Leech", quantity = 0.75, percent = true, priority = 3 } }
    elseif conviction == "manaleech" then
        return { { text = "Mana Leech", quantity = 0.25, percent = true, priority = 3 } }
    elseif conviction == "special_1" or conviction == "special_2" then
        local specialIndex = conviction == "special_1" and 1 or 2
        local info = specialPerks[specialIndex][vocation]
        return { { text = info[1] .. "\n" .. info[2], priority = 1 } }
    end

    local info = spellPerks[vocation][conviction]
    local pairedSlot = spellPairs[conviction][slotId]
    return {
        { text = info[1], priority = 1 },
        { text = info[2], augmentation = 1, pairedSlot = pairedSlot },
        { text = info[3], augmentation = 2, pairedSlot = pairedSlot }
    }
end

WheelDestiny.Slots = {}
for slotId = 1, 36 do
    local definition = slotDefinitions[slotId]
    local slot = {
        max = definition[1],
        min = 0,
        domain = definition[2],
        brothers = slotLinks[slotId],
        depedency = slotLinks[slotId],
        perk = {}
    }

    for vocation = 1, 5 do
        slot.perk[vocation] = {
            dedications = dedicationFor(vocation, definition[3]),
            convictions = convictionFor(vocation, slotId, definition[2], definition[4]),
            mediumClip = mediumIcons[vocation][slotId],
            smallClip = smallIcons[slotId]
        }
    end
    WheelDestiny.Slots[slotId] = slot
end

for slotId = 1, 36 do
    WheelDestiny.Slots[slotId].adjacent = {}
end
for slotId, links in pairs(slotLinks) do
    for _, otherId in ipairs(links) do
        local function addUnique(list, value)
            for _, current in ipairs(list) do
                if current == value then return end
            end
            table.insert(list, value)
        end
        addUnique(WheelDestiny.Slots[slotId].adjacent, otherId)
        addUnique(WheelDestiny.Slots[otherId].adjacent, slotId)
    end
end

local revelationNames = {
    [1] = { "Gift of Life", "Executioner's Throw", "Combat Mastery", "Avatar of Steel" },
    [2] = { "Gift of Life", "Divine Grenade", "Divine Empowerment", "Avatar of Light" },
    [3] = { "Gift of Life", "Beam Mastery", "Drain Body", "Avatar of Storm" },
    [4] = { "Gift of Life", "Blessing of the Grove", "Twin Bursts", "Avatar of Nature" },
    [5] = { "Gift of Life", "Spiritual Outburst", "Ascetic", "Avatar of Balance" }
}

local revelationDescriptions = {
    [1] = "Allows you to survive an otherwise fatal blow. Higher stages improve the trigger and reduce its cooldown.",
    [2] = "Unlocks and improves this vocation's offensive or healing Revelation Perk.",
    [3] = "Unlocks and improves this vocation's combat mastery Revelation Perk.",
    [4] = "Transforms you into a powerful avatar, reducing damage taken and increasing damage dealt."
}

local function makeSide(domain, child)
    local side = { child = child, perks = {} }
    for vocation = 1, 5 do
        local name = revelationNames[vocation][domain]
        side.perks[vocation] = {
            revelation = name,
            text = name .. "\n" .. revelationDescriptions[domain],
            largeClip = domain == 1 and 0 or (1 + ((vocation - 1) * 3) + (domain - 2))
        }
    end
    return side
end

WheelDestiny.Sides = {
    topLeft = makeSide(1, { 15,14,9,13,8,3,7,2,1 }),
    topRight = makeSide(2, { 16,10,17,4,11,18,5,12,6 }),
    bottomLeft = makeSide(3, { 21,20,27,19,26,33,25,32,31 }),
    bottomRight = makeSide(4, { 22,23,28,24,29,34,30,35,36 })
}

WheelDestiny.GemSlots = {
    [3] = { affinity = 0, position = 2 },
    [7] = { affinity = 0, position = 3 },
    [15] = { affinity = 0, position = 1 },
    [5] = { affinity = 1, position = 3 },
    [10] = { affinity = 1, position = 1 },
    [18] = { affinity = 1, position = 2 },
    [19] = { affinity = 2, position = 2 },
    [27] = { affinity = 2, position = 1 },
    [32] = { affinity = 2, position = 3 },
    [22] = { affinity = 3, position = 1 },
    [30] = { affinity = 3, position = 3 },
    [34] = { affinity = 3, position = 2 }
}

WheelDestiny.SocketsTier = {}
for affinity = 0, 3 do
    local firstClip = 1 + (affinity * 6)
    WheelDestiny.SocketsTier[affinity] = {
        [0] = { disabled = 0, enabled = 0 },
        [1] = { disabled = firstClip, enabled = firstClip + 1 },
        [2] = { disabled = firstClip + 2, enabled = firstClip + 3 },
        [3] = { disabled = firstClip + 4, enabled = firstClip + 5 }
    }
end

Gem_Atelier.SwitchPrice = {
    [0] = 125000,
    [1] = 250000,
    [2] = 500000
}

Gem_Atelier.VocationGems = {
    [1] = {
        { serverItem = 27150, item = 0, name = "Lesser Guardian" },
        { serverItem = 27151, item = 0, name = "Guardian" },
        { serverItem = 27152, item = 0, name = "Greater Guardian" }
    },
    [2] = {
        { serverItem = 27153, item = 0, name = "Lesser Marksman" },
        { serverItem = 27154, item = 0, name = "Marksman" },
        { serverItem = 27155, item = 0, name = "Greater Marksman" }
    },
    [3] = {
        { serverItem = 27156, item = 0, name = "Lesser Sage" },
        { serverItem = 27157, item = 0, name = "Sage" },
        { serverItem = 27158, item = 0, name = "Greater Sage" }
    },
    [4] = {
        { serverItem = 27159, item = 0, name = "Lesser Mystic" },
        { serverItem = 27160, item = 0, name = "Mystic" },
        { serverItem = 27161, item = 0, name = "Greater Mystic" }
    },
    [5] = {
        { serverItem = 27408, item = 0, name = "Lesser Spiritualist" },
        { serverItem = 27409, item = 0, name = "Spiritualist" },
        { serverItem = 27410, item = 0, name = "Greater Spiritualist" }
    }
}

local affinityNames = { "Top Left", "Top Right", "Bottom Left", "Bottom Right" }
local qualityNames = { [0] = "Lesser", [1] = "Regular", [2] = "Greater" }
local vocationGemNames = { "Guardian", "Marksman", "Sage", "Mystic", "Spiritualist" }

Gem_Atelier.Gems = {}
for vocation = 1, 5 do
    Gem_Atelier.Gems[vocation] = {}
    for affinity = 0, 3 do
        Gem_Atelier.Gems[vocation][affinity] = {}
        for quality = 0, 2 do
            Gem_Atelier.Gems[vocation][affinity][quality] = {
                name = string.format("%s %s Gem - %s", qualityNames[quality], vocationGemNames[vocation], affinityNames[affinity + 1]),
                clip = ((vocation - 1) * 12) + (affinity * 3) + quality
            }
        end
    end
end

local function modifier(name, values, text)
    return {
        name = name,
        descriptions = {
            { values = values, text = text or name }
        }
    }
end

local gradeMultipliers = { [0] = 1, [1] = 1.1, [2] = 1.2, [3] = 1.5 }

local function formatModifierNumber(value)
    if value == math.floor(value) then
        return tostring(math.floor(value))
    end
    return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
end

local function scaledValues(base, suffix)
    local values = {}
    for grade = 0, 3 do
        values[grade] = "+" .. formatModifierNumber(base * gradeMultipliers[grade]) .. (suffix or "%")
    end
    return values
end

local function fixedValues(value)
    return { [0] = value, [1] = value, [2] = value, [3] = value }
end

local function vocationScaledValues(baseStep, attribute)
    local values = {}
    setmetatable(values, {
        __index = function(_, grade)
            local vocation = WheelDestiny.vocation or 1
            local factors = attribute == "health" and healthPerPoint or
                (attribute == "mana" and manaPerPoint or gemCapacityStep)
            local multiplier = gradeMultipliers[tonumber(grade) or 0] or 1
            return "+" .. formatModifierNumber(baseStep * (factors[vocation] or 1) * multiplier)
        end
    })
    return values
end

local function compositeModifier(name, descriptions)
    return { name = name, descriptions = descriptions }
end

local function description(values, text)
    return { values = values, text = text }
end

local basicOne = scaledValues(1)
local basicOneHalf = scaledValues(1.5)
local basicTwo = scaledValues(2)
local basicThree = scaledValues(3)

Fragment_Workshop.Basic_Modifiers = {
    [0] = modifier("Physical Resistance", basicOne),
    [1] = modifier("Holy Resistance", basicOne),
    [2] = modifier("Death Resistance", basicOne),
    [3] = modifier("Fire Resistance", basicTwo),
    [4] = modifier("Earth Resistance", basicTwo),
    [5] = modifier("Ice Resistance", basicTwo),
    [6] = modifier("Energy Resistance", basicTwo),
    [7] = compositeModifier("Holy Resistance / Death Resistance", {
        description(basicOneHalf, "Holy Resistance"), description(fixedValues("-1%"), "Death Resistance")
    }),
    [8] = compositeModifier("Death Resistance / Holy Resistance", {
        description(basicOneHalf, "Death Resistance"), description(fixedValues("-1%"), "Holy Resistance")
    }),
    [9] = compositeModifier("Fire / Earth Resistance", { description(basicOne, "Fire Resistance"), description(basicOne, "Earth Resistance") }),
    [10] = compositeModifier("Fire / Ice Resistance", { description(basicOne, "Fire Resistance"), description(basicOne, "Ice Resistance") }),
    [11] = compositeModifier("Fire / Energy Resistance", { description(basicOne, "Fire Resistance"), description(basicOne, "Energy Resistance") }),
    [12] = compositeModifier("Earth / Ice Resistance", { description(basicOne, "Earth Resistance"), description(basicOne, "Ice Resistance") }),
    [13] = compositeModifier("Earth / Energy Resistance", { description(basicOne, "Earth Resistance"), description(basicOne, "Energy Resistance") }),
    [14] = compositeModifier("Ice / Energy Resistance", { description(basicOne, "Ice Resistance"), description(basicOne, "Energy Resistance") }),
    [15] = compositeModifier("Fire Resistance / Earth Weakness", { description(basicThree, "Fire Resistance"), description(fixedValues("-2%"), "Earth Resistance") }),
    [16] = compositeModifier("Fire Resistance / Ice Weakness", { description(basicThree, "Fire Resistance"), description(fixedValues("-2%"), "Ice Resistance") }),
    [17] = compositeModifier("Fire Resistance / Energy Weakness", { description(basicThree, "Fire Resistance"), description(fixedValues("-2%"), "Energy Resistance") }),
    [18] = compositeModifier("Earth Resistance / Fire Weakness", { description(basicThree, "Earth Resistance"), description(fixedValues("-2%"), "Fire Resistance") }),
    [19] = compositeModifier("Earth Resistance / Ice Weakness", { description(basicThree, "Earth Resistance"), description(fixedValues("-2%"), "Ice Resistance") }),
    [20] = compositeModifier("Earth Resistance / Energy Weakness", { description(basicThree, "Earth Resistance"), description(fixedValues("-2%"), "Energy Resistance") }),
    [21] = compositeModifier("Ice Resistance / Earth Weakness", { description(basicThree, "Ice Resistance"), description(fixedValues("-2%"), "Earth Resistance") }),
    [22] = compositeModifier("Ice Resistance / Fire Weakness", { description(basicThree, "Ice Resistance"), description(fixedValues("-2%"), "Fire Resistance") }),
    [23] = compositeModifier("Ice Resistance / Energy Weakness", { description(basicThree, "Ice Resistance"), description(fixedValues("-2%"), "Energy Resistance") }),
    [24] = compositeModifier("Energy Resistance / Earth Weakness", { description(basicThree, "Energy Resistance"), description(fixedValues("-2%"), "Earth Resistance") }),
    [25] = compositeModifier("Energy Resistance / Ice Weakness", { description(basicThree, "Energy Resistance"), description(fixedValues("-2%"), "Ice Resistance") }),
    [26] = compositeModifier("Energy Resistance / Fire Weakness", { description(basicThree, "Energy Resistance"), description(fixedValues("-2%"), "Fire Resistance") }),
    [27] = modifier("Mana Drain Resistance", basicThree),
    [28] = modifier("Life Drain Resistance", basicThree),
    [29] = compositeModifier("Mana / Life Drain Resistance", {
        description(basicOneHalf, "Mana Drain Resistance"), description(basicOneHalf, "Life Drain Resistance")
    }),
    [30] = modifier("Mitigation Multiplier", scaledValues(5)),
    [31] = modifier("Hit Points", vocationScaledValues(100, "health")),
    [32] = { disabled = true, name = "Unavailable", descriptions = {} },
    [33] = compositeModifier("Mana / Fire Resistance", { description(vocationScaledValues(50, "mana"), "Mana"), description(basicOne, "Fire Resistance") }),
    [34] = compositeModifier("Mana / Energy Resistance", { description(vocationScaledValues(50, "mana"), "Mana"), description(basicOne, "Energy Resistance") }),
    [35] = compositeModifier("Mana / Earth Resistance", { description(vocationScaledValues(50, "mana"), "Mana"), description(basicOne, "Earth Resistance") }),
    [36] = compositeModifier("Mana / Ice Resistance", { description(vocationScaledValues(50, "mana"), "Mana"), description(basicOne, "Ice Resistance") }),
    [37] = modifier("Mana", vocationScaledValues(100, "mana")),
    [38] = compositeModifier("Hit Points / Fire Resistance", { description(vocationScaledValues(50, "health"), "Hit Points"), description(basicOne, "Fire Resistance") }),
    [39] = compositeModifier("Hit Points / Energy Resistance", { description(vocationScaledValues(50, "health"), "Hit Points"), description(basicOne, "Energy Resistance") }),
    [40] = compositeModifier("Hit Points / Earth Resistance", { description(vocationScaledValues(50, "health"), "Hit Points"), description(basicOne, "Earth Resistance") }),
    [41] = compositeModifier("Hit Points / Ice Resistance", { description(vocationScaledValues(50, "health"), "Hit Points"), description(basicOne, "Ice Resistance") }),
    [42] = { disabled = true, name = "Unavailable", descriptions = {} },
    [43] = { disabled = true, name = "Unavailable", descriptions = {} },
    [44] = compositeModifier("Capacity / Fire Resistance", { description(vocationScaledValues(50, "capacity"), "Capacity"), description(basicOne, "Fire Resistance") }),
    [45] = compositeModifier("Capacity / Energy Resistance", { description(vocationScaledValues(50, "capacity"), "Capacity"), description(basicOne, "Energy Resistance") }),
    [46] = compositeModifier("Capacity / Earth Resistance", { description(vocationScaledValues(50, "capacity"), "Capacity"), description(basicOne, "Earth Resistance") }),
    [47] = compositeModifier("Capacity / Ice Resistance", { description(vocationScaledValues(50, "capacity"), "Capacity"), description(basicOne, "Ice Resistance") }),
    [48] = modifier("Capacity", vocationScaledValues(100, "capacity"))
}

local supremeDefinitions = {
    [0] = { 0, "Dodge", 0.28, "Dodge" },
    [1] = { 0, "Critical Extra Damage", 2, "Critical Extra Damage" },
    [2] = { 0, "Life Leech", 2, "Life Leech" },
    [3] = { 0, "Mana Leech", 0.8, "Mana Leech" },
    [4] = { -1, "Aug. Ultimate Healing", 5, "Base Healing" },
    [5] = { 0, "Revelation Mastery", 150, "Gift of Life", noPercent = true, domain = 0 },
    [6] = { 1, "Aug. Avatar of Steel", cooldown = "-900s" },
    [7] = { 1, "Aug. Executioner's Throw", cooldown = "-2s" },
    [8] = { 1, "Aug. Executioner's Throw", 6, "Base Damage" },
    [9] = { 1, "Aug. Executioner's Throw", 12, "Critical Extra Damage" },
    [10] = { 1, "Aug. Fierce Berserk", 5, "Base Damage" },
    [11] = { 1, "Aug. Fierce Berserk", 8, "Critical Extra Damage" },
    [12] = { 1, "Aug. Berserk", 5, "Base Damage" },
    [13] = { 1, "Aug. Berserk", 12, "Critical Extra Damage" },
    [14] = { 1, "Aug. Front Sweep", 8, "Base Damage" },
    [15] = { 1, "Aug. Front Sweep", 12, "Critical Extra Damage" },
    [16] = { 1, "Aug. Groundshaker", 6.5, "Base Damage" },
    [17] = { 1, "Aug. Groundshaker", 12, "Critical Extra Damage" },
    [18] = { 1, "Aug. Annihilation", 12, "Base Damage" },
    [19] = { 1, "Aug. Annihilation", 15, "Critical Extra Damage" },
    [20] = { 1, "Aug. Fair Wound Cleansing", 10, "Base Healing" },
    [21] = { 1, "Revelation Mastery", 150, "Avatar of Steel", noPercent = true, domain = 3 },
    [22] = { 1, "Revelation Mastery", 150, "Executioner's Throw", noPercent = true, domain = 1 },
    [23] = { 1, "Revelation Mastery", 150, "Combat Mastery", noPercent = true, domain = 2 },
    [24] = { 2, "Aug. Avatar of Light", cooldown = "-900s" },
    [25] = { 2, "Aug. Divine Dazzle", cooldown = "-4s" },
    [26] = { 2, "Aug. Divine Grenade", 6, "Base Damage" },
    [27] = { 2, "Aug. Divine Grenade", 12, "Critical Extra Damage" },
    [28] = { 2, "Aug. Divine Caldera", 5, "Base Damage" },
    [29] = { 2, "Aug. Divine Caldera", 8, "Critical Extra Damage" },
    [30] = { 2, "Aug. Divine Missile", 8, "Base Damage" },
    [31] = { 2, "Aug. Divine Missile", 12, "Critical Extra Damage" },
    [32] = { 2, "Aug. Ethereal Spear", 10, "Base Damage" },
    [33] = { 2, "Aug. Ethereal Spear", 15, "Critical Extra Damage" },
    [34] = { 2, "Aug. Strong Ethereal Spear", 8, "Base Damage" },
    [35] = { 2, "Aug. Strong Ethereal Spear", 12, "Critical Extra Damage" },
    [36] = { 2, "Aug. Divine Empowerment", cooldown = "-6s" },
    [37] = { 2, "Aug. Divine Grenade", cooldown = "-2s" },
    [38] = { 2, "Aug. Salvation", 6, "Base Healing" },
    [39] = { 2, "Revelation Mastery", 150, "Avatar of Light", noPercent = true, domain = 3 },
    [40] = { 2, "Revelation Mastery", 150, "Divine Grenade", noPercent = true, domain = 1 },
    [41] = { 2, "Revelation Mastery", 150, "Divine Empowerment", noPercent = true, domain = 2 },
    [42] = { 3, "Aug. Avatar of Storm", cooldown = "-900s" },
    [43] = { 3, "Aug. Energy Wave", cooldown = "-1s" },
    [44] = { 3, "Aug. Great Death Beam", 10, "Base Damage" },
    [45] = { 3, "Aug. Great Death Beam", 15, "Critical Extra Damage" },
    [46] = { 3, "Aug. Hell's Core", 8, "Base Damage" },
    [47] = { 3, "Aug. Hell's Core", 12, "Critical Extra Damage" },
    [48] = { 3, "Aug. Energy Wave", 5, "Base Damage" },
    [49] = { 3, "Aug. Energy Wave", 12, "Critical Extra Damage" },
    [50] = { 3, "Aug. Great Fire Wave", 5, "Base Damage" },
    [51] = { 3, "Aug. Great Fire Wave", 8, "Critical Extra Damage" },
    [52] = { 3, "Aug. Rage of the Skies", 8, "Base Damage" },
    [53] = { 3, "Aug. Rage of the Skies", 12, "Critical Extra Damage" },
    [54] = { 3, "Aug. Great Energy Beam", 10, "Base Damage" },
    [55] = { 3, "Aug. Great Energy Beam", 15, "Critical Extra Damage" },
    [56] = { 3, "Revelation Mastery", 150, "Avatar of Storm", noPercent = true, domain = 3 },
    [57] = { 3, "Revelation Mastery", 150, "Beam Mastery", noPercent = true, domain = 1 },
    [58] = { 3, "Revelation Mastery", 150, "Drain Body", noPercent = true, domain = 2 },
    [59] = { 4, "Aug. Avatar of Nature", cooldown = "-900s" },
    [60] = { 4, "Aug. Nature's Embrace", cooldown = "-10s" },
    [61] = { 4, "Aug. Terra Burst", 7, "Base Damage" },
    [62] = { 4, "Aug. Terra Burst", 12, "Critical Extra Damage" },
    [63] = { 4, "Aug. Ice Burst", 7, "Base Damage" },
    [64] = { 4, "Aug. Ice Burst", 12, "Critical Extra Damage" },
    [65] = { 4, "Aug. Eternal Winter", 8, "Base Damage" },
    [66] = { 4, "Aug. Eternal Winter", 12, "Critical Extra Damage" },
    [67] = { 4, "Aug. Terra Wave", 5, "Base Damage" },
    [68] = { 4, "Aug. Terra Wave", 12, "Critical Extra Damage" },
    [69] = { 4, "Aug. Strong Ice Wave", 8, "Base Damage" },
    [70] = { 4, "Aug. Strong Ice Wave", 15, "Critical Extra Damage" },
    [71] = { 4, "Aug. Heal Friend", 5, "Base Healing" },
    [72] = { 4, "Aug. Mass Healing", 5, "Base Healing" },
    [73] = { 4, "Revelation Mastery", 150, "Avatar of Nature", noPercent = true, domain = 3 },
    [74] = { 4, "Revelation Mastery", 150, "Blessing of the Grove", noPercent = true, domain = 1 },
    [75] = { 4, "Revelation Mastery", 150, "Twin Bursts", noPercent = true, domain = 2 },
    [76] = { 5, "Aug. Avatar of Balance", cooldown = "-900s" },
    [77] = { 5, "Aug. Spirit Mend", 6, "Base Healing" },
    [78] = { 5, "Aug. Spiritual Outburst", 5, "Base Damage" },
    [79] = { 5, "Aug. Spiritual Outburst", 8, "Critical Extra Damage" },
    [80] = { 5, "Aug. Forceful Uppercut", 10, "Base Damage" },
    [81] = { 5, "Aug. Forceful Uppercut", 8, "Critical Extra Damage" },
    [82] = { 5, "Aug. Flurry of Blows", 6.5, "Base Damage" },
    [83] = { 5, "Aug. Flurry of Blows", 8, "Critical Extra Damage" },
    [84] = { 5, "Aug. Greater Flurry of Blows", 5, "Base Damage" },
    [85] = { 5, "Aug. Greater Flurry of Blows", 8, "Critical Extra Damage" },
    [86] = { 5, "Aug. Sweeping Takedown", 5, "Base Damage" },
    [87] = { 5, "Aug. Sweeping Takedown", 8, "Critical Extra Damage" },
    [88] = { 5, "Aug. Focus Serenity", cooldown = "-150s" },
    [89] = { 5, "Aug. Focus Harmony", cooldown = "-30s" },
    [90] = { 5, "Aug. Mass Spirit Mend", 5, "Base Healing" },
    [91] = { 5, "Revelation Mastery", 150, "Avatar of Balance", noPercent = true, domain = 3 },
    [92] = { 5, "Revelation Mastery", 150, "Spiritual Outburst", noPercent = true, domain = 1 },
    [93] = { 5, "Revelation Mastery", 150, "Ascetic", noPercent = true, domain = 2 }
}

local allVocations = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true }
Fragment_Workshop.Supreme_Modifiers = {}
for id = 0, 93 do
    local definition = supremeDefinitions[id]
    local vocation = definition[1]
    local vocations = allVocations
    if vocation == -1 then
        vocations = { [3] = true, [4] = true }
    elseif vocation > 0 then
        vocations = { [vocation] = true }
    end

    local descriptions
    if definition.cooldown then
        descriptions = {
            description(fixedValues(definition.cooldown), "Cooldown"),
            description({ [0] = "+0%", [1] = "+0.33%", [2] = "+0.66%", [3] = "+1%" }, "Momentum")
        }
    else
        descriptions = {
            description(scaledValues(definition[3], definition.noPercent and "" or "%"), definition[4])
        }
    end

    Fragment_Workshop.Supreme_Modifiers[id] = {
        name = definition[2],
        descriptions = descriptions,
        vocations = vocations,
        revelationDomain = definition.domain
    }
end
