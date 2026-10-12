local OPCODE_LEVELUP = 127

local levelUpEvent = CreatureEvent("LevelUpBanner")

local skillNames = {
    [SKILL_FIST] = "Fist Fighting",
    [SKILL_CLUB] = "Club Fighting",
    [SKILL_SWORD] = "Sword Fighting",
    [SKILL_AXE] = "Axe Fighting",
    [SKILL_DISTANCE] = "Distance Fighting",
    [SKILL_SHIELD] = "Shielding",
    [SKILL_FISHING] = "Fishing",
    [SKILL_MAGLEVEL] = "Magic Level",
    [SKILL_CRAFTING] = "Crafting",
    [SKILL_HERBALIST] = "Herbalism",
    [SKILL_WOODCUTTING] = "Woodcutting",
    [SKILL_MINING] = "Mining",
    [SKILL_JEWELSMITH] = "Jewelsmith",
    [SKILL_ARMORSMITH] = "Armorsmith",
    [SKILL_WEAPONSMITH] = "Weaponsmith",
    [SKILL_LEVEL] = "Level"
}

function levelUpEvent.onAdvance(player, skill, oldLevel, newLevel)
    if newLevel <= oldLevel then
        return true
    end

    local skillName = skillNames[skill] or "Skill"

    local payload = {
        action = "advance",
        name = skillName,
        level = newLevel
    }

    sendSoundToPlayer(player, "expedition_complete.ogg")
    player:getPosition():sendMagicEffect(375)
    player:sendExtendedOpcode(OPCODE_LEVELUP, json.encode(payload))
    return true
end

levelUpEvent:register()