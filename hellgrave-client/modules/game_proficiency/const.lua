-- Weapon Perk Types
WEAPON_NONE = WEAPON_NONE or 0
WEAPON_SWORD = WEAPON_SWORD or 1
WEAPON_CLUB = WEAPON_CLUB or 2
WEAPON_AXE = WEAPON_AXE or 3
WEAPON_FIST = WEAPON_FIST or 4
WEAPON_SHIELD = WEAPON_SHIELD or 5
WEAPON_DISTANCE = WEAPON_DISTANCE or 6
WEAPON_WAND = WEAPON_WAND or 7

WEAPON_BOW = WEAPON_BOW or WEAPON_DISTANCE
WEAPON_THROW = WEAPON_THROW or WEAPON_DISTANCE
WEAPON_CROSSBOW = WEAPON_CROSSBOW or WEAPON_DISTANCE
WEAPON_WANDROD = WEAPON_WANDROD or WEAPON_WAND

PERK_WEAPON_ATTACK = 0
PERK_SHIELD_DEFENSE = 1
PERK_WEAPON_DEFENSE = 2
PERK_SKILL_BONUS = 3
PERK_MAGIC_BONUS = 4
PERK_SPELL_AUGMENT = 5
PERK_BESTIARY_DAMAGE = 6
PERK_POWERFUL_FOE_DAMAGE = 7
PERK_CRITICAL_CHANCE = 8
PERK_ELEMENTAL_CRITICAL_CHANCE = 9
PERK_RUNE_CRITICAL_CHANCE = 10
PERK_MELEE_CRITICAL_CHANCE = 11
PERK_CRITICAL_DAMAGE = 12
PERK_ELEMENTAL_CRITICAL_DAMAGE = 13
PERK_RUNE_CRITICAL_DAMAGE = 14
PERK_MELEE_CRITICAL_DAMAGE = 15
PERK_MANA_LEECH = 16
PERK_LIFE_LEECH = 17
PERK_MANA_ON_HIT = 18
PERK_LIFE_ON_HIT = 19
PERK_MANA_ON_KILL = 20
PERK_LIFE_ON_KILL = 21
PERK_PERFECT_SHOT = 22
PERK_HIT_CHANCE = 23
PERK_ATTACK_RANGE = 24
PERK_MELEE_SKILL_FLAT_DAMAGE = 25
PERK_SPELL_SKILL_FLAT_DAMAGE = 26
PERK_HEALING_SKILL_FLAT_DAMAGE = 27
PERK_ALPHA_STRIKE_DAMAGE = 28
PERK_OMEGA_STRIKE_DAMAGE = 29
PERK_ARMOR_PENETRATION = 30
PERK_ELEMENTAL_PIERCE = 31
PERK_HOMING_MISSILE = 32

-- Perk Augment Types
AUGMENT_NONE = 0
AUGMENT_BASE_BASE = 2
AUGMENT_HEALING = 3
AUGMENT_COOLDOWN = 6
AUGMENT_LIFE_LEECH = 14
AUGMENT_MANA_LEECH = 15
AUGMENT_CRITICAL_DAMAGE = 16
AUGMENT_CRITICAL_CHANCE = 17

ExperienceTable = {}

ElementalMask = {
	[1]       = {name = "Physical", imageOffset = "0 0"},
	[4]       = {name = "Physical", imageOffset = "0 0"},
	[8]       = {name = "Fire", imageOffset = "64 0"},
	[16]      = {name = "Earth", imageOffset = "192 0"},
	[32]      = {name = "Energy", imageOffset = "128 0"},
	[64]      = {name = "Ice", imageOffset = "256 0"},
	[128]     = {name = "Holy", imageOffset = "384 0"},
	[256]     = {name = "Death", imageOffset = "320 0"},
	[4096]    = {name = "Water", imageOffset = "448 0"},
	[8192]    = {name = "Arcane", imageOffset = "512 0"}
}

MagicBoostMask = {
	[8]        = {name = "Fire", imageOffset = "0 0"},
	[16]       = {name = "Earth", imageOffset = "128 0"},
	[32]       = {name = "Energy", imageOffset = "192 0"},
	[64]       = {name = "Ice", imageOffset = "64 0"},
	[128]      = {name = "Holy", imageOffset = "320 0"},
	[256]      = {name = "Death", imageOffset = "256 0"},
	[4096]     = {name = "Water", imageOffset = "448 0"},
	[8192]     = {name = "Arcane", imageOffset = "512 0"},
	[1048576]  = {name = "Healing", imageOffset = "384 0"}
}

SkillTypes = {
	[1]  = {name = "Magic Level", imageOffset = "256 0"},
	[6]  = {name = "Shielding", imageOffset = "320 0"},
	[7]  = {name = "Distance Fighting", imageOffset = "384 0"},
	[8]  = {name = "Sword Fighting", imageOffset = "0 0"},
	[9]  = {name = "Club Fighting", imageOffset = "128 0"},
	[10] = {name = "Axe Fighting", imageOffset = "64 0"},
	[11] = {name = "Fist Fighting", imageOffset = "192 0"},
	[13] = {name = "Fishing", imageOffset = "448 0"},
	[14] = {name = "Crafting", imageOffset = "512 0"},
	[15] = {name = "Woodcutting", imageOffset = "576 0"},
	[16] = {name = "Mining", imageOffset = "640 0"},
	[17] = {name = "Herbalism", imageOffset = "704 0"},
	[18] = {name = "Armorsmithing", imageOffset = "768 0"},
	[19] = {name = "Weaponsmithing", imageOffset = "832 0"},
	[20] = {name = "Jewelsmithing", imageOffset = "896 0"}
}

BestiaryCategories = {
	["Amphibic"]           = {imageOffset = "0 0"},
	["Aquatic"]            = {imageOffset = "64 0"},
	["Bird"]               = {imageOffset = "128 0"},
	["Construct"]          = {imageOffset = "192 0"},
	["Demon"]              = {imageOffset = "256 0"},
	["Dragon"]             = {imageOffset = "320 0"},
	["Elemental"]          = {imageOffset = "384 0"},
	["Extra Dimensional"]  = {imageOffset = "1216 0"},
	["Fey"]                = {imageOffset = "448 0"},
	["Giant"]              = {imageOffset = "512 0"},
	["Human"]              = {imageOffset = "576 0"},
	["Humanoid"]           = {imageOffset = "640 0"},
	["Inkborn"]            = {imageOffset = "1280 0"},
	["Lycanthrope"]        = {imageOffset = "704 0"},
	["Magical"]            = {imageOffset = "768 0"},
	["Mammal"]             = {imageOffset = "832 0"},
	["Plant"]              = {imageOffset = "896 0"},
	["Reptile"]            = {imageOffset = "960 0"},
	["Slime"]              = {imageOffset = "1024 0"},
	["Undead"]             = {imageOffset = "1088 0"},
	["Vermin"]             = {imageOffset = "1152 0"},
	["Bane"]               = {imageOffset = "1344 0"},
	["Archfoe"]            = {imageOffset = "1408 0"},
	["Nemesis"]            = {imageOffset = "1472 0"},
	["Apex"]               = {imageOffset = "1536 0"}
}

SpellAugmentIcons = {
  [1]   = {name = "Light Healing", imageOffset = "0 0"},
  [2]   = {name = "Intense Healing", imageOffset = "64 0"},
  [13]  = {name = "Energy Wave", imageOffset = "128 0"},
  [19]  = {name = "Fire Wave", imageOffset = "192 0"},
  [22]  = {name = "Energy Beam", imageOffset = "256 0"},
  [23]  = {name = "Great Energy Beam", imageOffset = "256 0"},
  [24]  = {name = "Hell's Core", imageOffset = "320 0"},
  [43]  = {name = "Strong Ice Wave", imageOffset = "384 0"},
  [56]  = {name = "Wrath of Nature", imageOffset = "192 64"},
  [57]  = {name = "Strong Ethereal Spear", imageOffset = "448 0"},
  [59]  = {name = "Front Sweep", imageOffset = "512 0"},
  [61]  = {name = "Brutal Strike", imageOffset = "576 0"},
  [62]  = {name = "Annihilation", imageOffset = "640 0"},
  [80]  = {name = "Berserk", imageOffset = "704 0"},
  [84]  = {name = "Heal Friend", imageOffset = "768 0"},
  [87]  = {name = "Death Strike", imageOffset = "832 0"},
  [88]  = {name = "Energy Strike", imageOffset = "896 0"},
  [89]  = {name = "Flame Strike", imageOffset = "960 0"},
  [105] = {name = "Fierce Berserk", imageOffset = "1024 0"},
  [106] = {name = "Groundshaker", imageOffset = "1088 0"},
  [107] = {name = "Whirlwind Throw", imageOffset = "1152 0"},
  [112] = {name = "Ice Strike", imageOffset = "1216 0"},
  [113] = {name = "Terra Strike", imageOffset = "0 64"},
  [118] = {name = "Eternal Winter", imageOffset = "64 64"},
  [119] = {name = "Rage of the Skies", imageOffset = "128 64"},
  [120] = {name = "Terra Wave", imageOffset = "192 64"},
  [121] = {name = "Ice Wave", imageOffset = "256 64"},
  [122] = {name = "Divine Missile", imageOffset = "320 64"},
  [123] = {name = "Wound Cleansing", imageOffset = "384 64"},
  [124] = {name = "Divine Caldera", imageOffset = "448 64"},
  [125] = {name = "Divine Healing", imageOffset = "512 64"},
  [141] = {name = "Inflict Wound", imageOffset = "576 64"},
  [148] = {name = "Physical Strike", imageOffset = "640 64"},
  [150] = {name = "Strong Flame Strike", imageOffset = "704 64"},
  [153] = {name = "Strong Terra Strike", imageOffset = "768 64"},
  [154] = {name = "Ultimate Flame Strike", imageOffset = "832 64"},
  [155] = {name = "Ultimate Energy Strike", imageOffset = "896 64"},
  [156] = {name = "Ultimate Ice Strike", imageOffset = "960 64"},
  [157] = {name = "Ultimate Terra Strike", imageOffset = "1024 64"},
  [158] = {name = "Intense Wound Cleansing", imageOffset = "1088 64"},
  [169] = {name = "Apprentice's Strike", imageOffset = "1152 64"},
  [173] = {name = "Chill Out", imageOffset = "1216 64"},
  [177] = {name = "Buzz", imageOffset = "0 128"},
  [178] = {name = "Scorch", imageOffset = "64 128"},
  [237] = {name = "Chivalrous Challenge", imageOffset = "128 128"},
  [238] = {name = "Divine Dazzle", imageOffset = "128 128"},
  [163] = {name = "Great Fire Wave", imageOffset = "192 128"},
  [258] = {name = "Divine Grenade", imageOffset = "256 128"},
  [260] = {name = "Grand Death Beam", imageOffset = "320 128"},
  [261] = {name = "Executioners Throw", imageOffset = "384 128"},
  [262] = {name = "Ice Burst", imageOffset = "448 128"},
  [422] = {name = "Avatar of Steel", imageOffset = "512 128"},
  [423] = {name = "Avatar of Light", imageOffset = "576 128"},
  [424] = {name = "Avatar of Storm", imageOffset = "640 128"},
  [425] = {name = "Avatar of Nature", imageOffset = "704 128"},
  [268] = {name = "Divine Empowerment", imageOffset = "768 128"},
  [426] = {name = "Avatar of Balance", imageOffset = "960 128"},
  [409] = {name = "Furry of Blows", imageOffset = "1024 128"},
  [414] = {name = "Chained Penance", imageOffset = "1088 128"},
  [412] = {name = "Greater Furry of Blows", imageOffset = "1152 128"},
  [407] = {name = "Mystic Repulse", imageOffset = "1216 128"},
  [402] = {name = "Greater Tiger Clash", imageOffset = "0 192"},
  [413] = {name = "Forceful Uppercut", imageOffset = "64 192"},
  [410] = {name = "Sweeping Takedown", imageOffset = "128 192"},
}

AugmentPerkIcons = {
    [AUGMENT_HEALING]         = {desc = "+%s%% healing for %s", imageOffset = "192 0"},
    [AUGMENT_COOLDOWN]        = {desc = "%ds cooldown for %s", imageOffset = "160 0"},
    [AUGMENT_BASE_BASE]       = {desc = "+%s%% base damage for %s", imageOffset = "192 0"},
    [AUGMENT_LIFE_LEECH]      = {desc = "+%s%% life leech for %s", imageOffset = "352 0"},
    [AUGMENT_MANA_LEECH]      = {desc = "+%s%% mana leech for %s", imageOffset = "384 0"},
    [AUGMENT_CRITICAL_DAMAGE] = {desc = "+%s%% critical extra damage for %s", imageOffset = "224 0"},
    [AUGMENT_CRITICAL_CHANCE] = {desc = "+%s%% critical hit chance for %s", imageOffset = "224 0"}
}

PerkVisualData = {
	[PERK_WEAPON_ATTACK]             = {source = "icons-0", offset = "0 0"},
	[PERK_SHIELD_DEFENSE]            = {source = "icons-0", offset = "64 0"},
	[PERK_WEAPON_DEFENSE]            = {source = "icons-0", offset = "128 0"},
	[PERK_SKILL_BONUS]               = {source = "icons-7", offset = "0 0"},
	[PERK_MAGIC_BONUS]               = {source = "icons-8", offset = "0 0"},
	[PERK_SPELL_AUGMENT]             = {source = "icons-9", offset = "0 0"},
	[PERK_BESTIARY_DAMAGE]           = {source = "icons-3", offset = "0 0"},
	[PERK_POWERFUL_FOE_DAMAGE]       = {source = "icons-0", offset = "192 0"},
	[PERK_CRITICAL_CHANCE]           = {source = "icons-0", offset = "256 0"},
	[PERK_ELEMENTAL_CRITICAL_CHANCE] = {source = "icons-2", offset = "0 0"},
	[PERK_RUNE_CRITICAL_CHANCE]      = {source = "icons-0", offset = "320 0"},
	[PERK_MELEE_CRITICAL_CHANCE]     = {source = "icons-0", offset = "384 0"},
	[PERK_CRITICAL_DAMAGE]           = {source = "icons-0", offset = "448 0"},
	[PERK_ELEMENTAL_CRITICAL_DAMAGE] = {source = "icons-1", offset = "0 0"},
	[PERK_RUNE_CRITICAL_DAMAGE]      = {source = "icons-0", offset = "512 0"},
	[PERK_MELEE_CRITICAL_DAMAGE]     = {source = "icons-0", offset = "576 0"},
	[PERK_LIFE_LEECH]                = {source = "icons-0", offset = "640 0"},
	[PERK_MANA_LEECH]                = {source = "icons-0", offset = "704 0"},
	[PERK_LIFE_ON_HIT]               = {source = "icons-0", offset = "768 0"},
	[PERK_MANA_ON_HIT]               = {source = "icons-0", offset = "832 0"},
	[PERK_LIFE_ON_KILL]              = {source = "icons-0", offset = "896 0"},
	[PERK_MANA_ON_KILL]              = {source = "icons-0", offset = "960 0"},
	[PERK_PERFECT_SHOT]              = {source = "icons-0", offset = "1024 0"},
	[PERK_HIT_CHANCE]                = {source = "icons-0", offset = "1088 0"},
	[PERK_ATTACK_RANGE]              = {source = "icons-0", offset = "1152 0"},
	[PERK_MELEE_SKILL_FLAT_DAMAGE]   = {source = "icons-4", offset = "0 0"},
	[PERK_SPELL_SKILL_FLAT_DAMAGE]   = {source = "icons-5", offset = "0 0"},
	[PERK_HEALING_SKILL_FLAT_DAMAGE] = {source = "icons-6", offset = "0 0"},
	[PERK_ALPHA_STRIKE_DAMAGE]       = {source = "icons-0", offset = "192 0"},
	[PERK_OMEGA_STRIKE_DAMAGE]       = {source = "icons-0", offset = "256 0"},
	[PERK_ARMOR_PENETRATION]         = {source = "icons-0", offset = "128 0"},
	[PERK_ELEMENTAL_PIERCE]          = {source = "icons-2", offset = "0 0"},
	[PERK_HOMING_MISSILE]            = {source = "icons-2", offset = "0 0"}
}

PerkTextData = {
	[PERK_WEAPON_ATTACK]             = {name = "Attack Damage", desc = "+%d attack"},
	[PERK_SHIELD_DEFENSE]            = {name = "Defence", desc = "+%d defence"},
	[PERK_WEAPON_DEFENSE]            = {name = "Weapon Shield Mod", desc = "+%d defence modifier"},
	[PERK_SKILL_BONUS]               = {name = "Skill Bonus", desc = "+%d %s"},
	[PERK_MAGIC_BONUS]               = {name = "Special Magic Boost", desc = "+%d %s Magic Level"},
	[PERK_SPELL_AUGMENT]             = {name = "Spell Augment", desc = "Variable..."},
	[PERK_BESTIARY_DAMAGE]           = {name = "Bestiary Damage", desc = "+%s%% damage against %s"},
	[PERK_POWERFUL_FOE_DAMAGE]       = {name = "Powerful Foe Bonus", desc = "+%s%% damage against bosses and Sinister Embraced"},
	[PERK_CRITICAL_CHANCE]           = {name = "Critical Hit Chance", desc = "+%s%% critical hit chance"},
	[PERK_ELEMENTAL_CRITICAL_CHANCE] = {name = "Element Critical Hit Chance", desc = "+%s%% critical hit chance for %s spells and runes"},
	[PERK_RUNE_CRITICAL_CHANCE]      = {name = "Rune Critical Hit Chance", desc = "+%s%% critical hit chance for offensive runes"},
	[PERK_MELEE_CRITICAL_CHANCE]     = {name = "Auto-Attack Critical Hit Chance", desc = "+%s%% critical hit chance for auto-attacks"},
	[PERK_CRITICAL_DAMAGE]           = {name = "Critical Extra Damage", desc = "+%s%% critical extra damage"},
	[PERK_ELEMENTAL_CRITICAL_DAMAGE] = {name = "Element Critical Extra Damage", desc = "+%s%% critical extra damage for %s spells and runes"},
	[PERK_RUNE_CRITICAL_DAMAGE]      = {name = "Rune Critical Extra Damage", desc = "+%s%% critical extra damage for offensive runes"},
	[PERK_MELEE_CRITICAL_DAMAGE]     = {name = "Auto-Attack Critical Extra Damage", desc = "+%s%% critical extra damage for auto-attacks"},
	[PERK_LIFE_LEECH]                = {name = "Life Leech", desc = "+%s%% life leech"},
	[PERK_MANA_LEECH]                = {name = "Mana Leech", desc = "+%s%% mana leech"},
	[PERK_LIFE_ON_HIT]               = {name = "Life Gain on Hit", desc = "+%d hit points on hit"},
	[PERK_MANA_ON_HIT]               = {name = "Mana Gain on Hit", desc = "+%d mana on hit"},
	[PERK_LIFE_ON_KILL]              = {name = "Life Gain on Kill", desc = "+%d hit points on kill"},
	[PERK_MANA_ON_KILL]              = {name = "Mana Gain on Kill", desc = "+%d mana on kill"},
	[PERK_PERFECT_SHOT]              = {name = "Perfect Shot Damage", desc = "+%d damage at range %d or farther"},
	[PERK_HIT_CHANCE]                = {name = "Ranged Hit Chance", desc = "+%s%% hit chance"},
	[PERK_ATTACK_RANGE]              = {name = "Attack Range", desc = "+%d range"},
	[PERK_MELEE_SKILL_FLAT_DAMAGE]   = {name = "Skill Percentage Auto-Attack Damage", desc = "+%s%% of your %s as extra damage for auto-attacks"},
	[PERK_SPELL_SKILL_FLAT_DAMAGE]   = {name = "Skill Percentage Spell Damage", desc = "+%s%% of your %s as extra damage for your spells"},
	[PERK_HEALING_SKILL_FLAT_DAMAGE] = {name = "Skill Percentage Spell Healing", desc = "+%s%% of your %s as extra healing for your spells"},
	[PERK_ALPHA_STRIKE_DAMAGE]       = {name = "Alpha Strike", desc = "+%s%% damage against targets above 95%% hit points"},
	[PERK_OMEGA_STRIKE_DAMAGE]       = {name = "Omega Strike", desc = "+%s%% damage against targets below 30%% hit points"},
	[PERK_ARMOR_PENETRATION]         = {name = "Armor Penetration", desc = "+%s%% armor penetration"},
	[PERK_ELEMENTAL_PIERCE]          = {name = "Elemental Pierce", desc = "+%s%% %s pierce"},
	[PERK_HOMING_MISSILE]            = {name = "Homing Missile", desc = "Offensive spells have a %s%% chance to fire a homing missile that deals %s damage equal to %s%% of your level"}
}

ElementalCritical_t = {
	[PERK_ELEMENTAL_CRITICAL_CHANCE] = true,
	[PERK_ELEMENTAL_CRITICAL_DAMAGE] = true
}

FlatDamageBonus_t = {
	[PERK_MELEE_SKILL_FLAT_DAMAGE] = true,
	[PERK_SPELL_SKILL_FLAT_DAMAGE] = true,
	[PERK_HEALING_SKILL_FLAT_DAMAGE] = true,
	[PERK_SKILL_BONUS] = true
}

WeaponStringToCategory = {
	["Weapons: Axes"] = 17,
	["Weapons: Clubs"] = 18,
	["Weapons: Distance"] = 19,
	["Weapons: Fist"] = 27,
	["Weapons: Swords"] = 20,
	["Weapons: Wands"] = 21,
	["Weapons: All"] = 32,
}

WeaponCategoryToString = {
	[17] = "Weapons: Axes",
	[18] = "Weapons: Clubs",
	[19] = "Weapons: Distance",
	[27] = "Weapons: Fist",
	[20] = "Weapons: Swords",
	[21] = "Weapons: Wands",
	[32] = "Weapons: All",
}

PercentageTypes = {
    PERK_HIT_CHANCE,
    PERK_SPELL_AUGMENT,
    PERK_MELEE_CRITICAL_DAMAGE,
	PERK_SPELL_SKILL_FLAT_DAMAGE,
    PERK_MELEE_SKILL_FLAT_DAMAGE,
    PERK_HEALING_SKILL_FLAT_DAMAGE,
	PERK_ALPHA_STRIKE_DAMAGE,
	PERK_OMEGA_STRIKE_DAMAGE,
	PERK_ARMOR_PENETRATION,
	PERK_ELEMENTAL_PIERCE,
	PERK_HOMING_MISSILE
}

UnknownCategories = {
	[WEAPON_AXE] 	  = 17,
	[WEAPON_BOW]      = 19,
	[WEAPON_CLUB]     = 18,
	[WEAPON_FIST]     = 27,
	[WEAPON_SWORD]    = 20,
	[WEAPON_THROW]    = 19,
	[WEAPON_WANDROD]  = 21,
	[WEAPON_CROSSBOW] = 19
}
