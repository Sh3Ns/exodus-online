local config = MakeBelieveQuestConfig
if not config then
    error("[Phosphorus challenge] 00_make_believe_config.lua was not loaded, verify if you edited the file!")
end

local function incomingDamage(value, combatType)
    if combatType == COMBAT_HEALING or value >= 0 then
        return 0
    end
    return math.abs(value)
end

local function changeForm(creature, formName)
    if not MakeBelieveChangeForm then
        return
    end
    MakeBelieveChangeForm(creature, formName)
end

local function shouldChangeForm(creature, primaryDamage, primaryType, secondaryDamage, secondaryType, bossConfig)
    if not creature or creature:getName() ~= bossConfig.name then
        return false
    end

    local damage = incomingDamage(primaryDamage, primaryType) + incomingDamage(secondaryDamage, secondaryType)
    return damage > 0 and creature:getHealth() - damage <= bossConfig.transformAtHealth
end

local maiorDomusChange = CreatureEvent("maiordomuschange")
function maiorDomusChange.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
    local bossConfig = config.rooms.domus.boss
    if shouldChangeForm(creature, primaryDamage, primaryType, secondaryDamage, secondaryType, bossConfig) then
        changeForm(creature, bossConfig.transformInto)
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end
maiorDomusChange:register()

local phosphorusChange = CreatureEvent("phosphoruschange")
function phosphorusChange.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
    local bossConfig = config.rooms.phosphorus.boss
    if shouldChangeForm(creature, primaryDamage, primaryType, secondaryDamage, secondaryType, bossConfig) then
        changeForm(creature, bossConfig.transformInto)
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end
phosphorusChange:register()
