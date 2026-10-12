local checkCPL = Action()

function checkCPL.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local total = 0
    local slots = {
        CONST_SLOT_HEAD,
        CONST_SLOT_NECKLACE,
        CONST_SLOT_ARMOR,
        CONST_SLOT_RIGHT,
        CONST_SLOT_LEFT,
        CONST_SLOT_LEGS,
        CONST_SLOT_FEET,
        CONST_SLOT_RING,
        CONST_SLOT_AMMO,
        CONST_SLOT_BADGE,
        CONST_SLOT_BELT,
        CONST_SLOT_GLOVES
    }

    for _, slot in ipairs(slots) do
        local equipped = player:getSlotItem(slot)
        if equipped then
            local lvl = equipped:getCustomAttribute("combatPowerLevel") or 0
            total = total + lvl
        end
    end

    player:sendTextMessage(MESSAGE_INFO_DESCR, "All your equipped items have a Combat Power Level = " .. total)
    return true
end

checkCPL:id(999999) --- Item ID to check Combat Power Level from all items - Not Implemented Yet
checkCPL:register()


-- IMPORTANT: values are PERCENTS (100 = 100%, 150 = 150%, 0.5 = 0.5%, etc.)
local CombatPowerTable = {
    default = { -- Default means all monsters in game if not specified here on the table
        [0]   = 100,     -- 100% Normal Damage
        [5000] = 100  ---- Dont touch this until you know what you are doing, this is global for all monsters/bosses
        -- [50]  = 50,    -- 50% only 50% damage done
        -- [100] = 100,   -- 100% (normal damage)
        -- [150] = 150,   -- 150% 50% more damage
        -- [200] = 200,   -- 200% (double damage)
        -- [380] = 380,   -- 380% (3.8x damage)
    },
    -- ["Ferumbras"] = {  --- Example of a Specified Monster/boss table, 10 CPL = 150% damage on starting
    --     [10]  = 150,
    --     [110]  = 100,
    --     [120]  = 180,
    --     [130]  = 250,
    --     [1200] = 300,
    -- },
}

local function getInfoTable(monster)
    return CombatPowerTable[monster:getName()] or CombatPowerTable.default
end

local function getEquippedLevel(player)
    local total = 0
    local slots = {
        CONST_SLOT_HEAD, CONST_SLOT_NECKLACE, CONST_SLOT_ARMOR,
        CONST_SLOT_RIGHT, CONST_SLOT_LEFT, CONST_SLOT_LEGS,
        CONST_SLOT_FEET, CONST_SLOT_RING, CONST_SLOT_AMMO,
        CONST_SLOT_BADGE, CONST_SLOT_BELT, CONST_SLOT_GLOVES
    }
    for _, slot in ipairs(slots) do
        local it = player:getSlotItem(slot)
        if it then
            local lvl = it:getCustomAttribute("combatPowerLevel") or 0
            total = total + (tonumber(lvl) or 0)
        end
    end
    return total
end

local function getPercentFromTable(ruleTable, cpl)
    local keys = {}
    for k, _ in pairs(ruleTable) do
        if type(k) == "number" then
            keys[#keys + 1] = k
        end
    end

    if #keys == 0 then
        return cpl
    end

    table.sort(keys)

    if #keys == 1 then
        local k1, v1 = keys[1], ruleTable[keys[1]]
        if k1 == 0 then
            return cpl
        end
        local slope = v1 / k1
        return cpl * slope
    end

    if keys[1] > 0 then
        table.insert(keys, 1, 0)
        if ruleTable[0] == nil then
            ruleTable[0] = 0
        end
    end

    for i = 1, #keys do
        local k = keys[i]
        if cpl == k then
            return ruleTable[k]
        end
    end

    if cpl < keys[2] then
        local k1, k2 = keys[1], keys[2]
        local v1, v2 = ruleTable[k1], ruleTable[k2]
        local t = (cpl - k1) / (k2 - k1)
        return v1 + t * (v2 - v1)
    end

    for i = 2, #keys - 1 do
        local k1, k2 = keys[i], keys[i + 1]
        if cpl < k2 then
            local v1, v2 = ruleTable[k1], ruleTable[k2]
            local t = (cpl - k1) / (k2 - k1)
            return v1 + t * (v2 - v1)
        end
    end

    local k1, k2 = keys[#keys - 1], keys[#keys]
    local v1, v2 = ruleTable[k1], ruleTable[k2]
    local slope = (v2 - v1) / (k2 - k1)
    return v2 + (cpl - k2) * slope
end

local function scaleDamage(d, percent)
    local mult = percent / 100.0
    local x = d * mult
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

local combatPowerLevel = CreatureEvent("combatPowerLevel_Damage")

function combatPowerLevel.onHealthChange(creature, attacker, pdmg, ptype, sdmg, stype, origin)
    if not creature:isMonster() or not attacker then
        return pdmg, ptype, sdmg, stype
    end

    local player = attacker:isPlayer() and attacker or nil
    if not player and attacker:isMonster() then
        local m = attacker:getMaster()
        if m and m:isPlayer() then player = m end
    end
    if not player then
        return pdmg, ptype, sdmg, stype
    end

    local cpl     = getEquippedLevel(player)
    local rules   = getInfoTable(creature)
    local percent = getPercentFromTable(rules, cpl)
    -- print("CPL: " .. cpl .. " => " .. percent .. "% damage to " .. creature:getName()) -- Check Damage Done to monsters
    if pdmg ~= 0 then pdmg = scaleDamage(pdmg, percent) end
    if sdmg ~= 0 then sdmg = scaleDamage(sdmg, percent) end
    return pdmg, ptype, sdmg, stype
end

combatPowerLevel:register()


local combatPowerLevelMana = CreatureEvent("combatPowerLevel_ManaDamage")

function combatPowerLevelMana.onManaChange(creature, attacker, manaChange, combatType, origin)
    if not creature:isMonster() or not attacker then
        return manaChange, combatType
    end

    local player = attacker:isPlayer() and attacker or nil
    if not player and attacker:isMonster() then
        local m = attacker:getMaster()
        if m and m:isPlayer() then player = m end
    end
    if not player then
        return manaChange, combatType
    end

    local cpl     = getEquippedLevel(player)
    local rules   = getInfoTable(creature)
    local percent = getPercentFromTable(rules, cpl)

    if manaChange ~= 0 then
        manaChange = scaleDamage(manaChange, percent)
    end

    return manaChange, combatType
end

combatPowerLevelMana:register()