CorruptionGem = CorruptionGem or {}

local EQUIPPED_SLOTS = {
    CONST_SLOT_HEAD,
    CONST_SLOT_NECKLACE,
    CONST_SLOT_BACKPACK,
    CONST_SLOT_ARMOR,
    CONST_SLOT_RIGHT,
    CONST_SLOT_LEFT,
    CONST_SLOT_LEGS,
    CONST_SLOT_FEET,
    CONST_SLOT_RING,
    CONST_SLOT_AMMO,
    CONST_SLOT_DECK,
    CONST_SLOT_BADGE,
    CONST_SLOT_SHIP,
    CONST_SLOT_BELT,
    CONST_SLOT_GLOVES,
}

local WAYSTONE_MONSTERS = {
    ["aegis sentinel"] = true,
    ["armorcoil"] = true,
    ["ashfang wrym"] = true,
    ["blazefang"] = true,
    ["bloodshade reaper"] = true,
    ["bloodspark adept"] = true,
    ["duskhorn drake"] = true,
    ["embermaw archon"] = true,
    ["flarevein wyrm"] = true,
    ["fractalis the shardmaw"] = true,
    ["frostreaver the glacialblade"] = true,
    ["glacial hellcharger"] = true,
    ["gloomstinger"] = true,
    ["gorgulith"] = true,
    ["hellmaw brute"] = true,
    ["inferno juggernaut"] = true,
    ["mirethorn hexer"] = true,
    ["morgrath the umbral archmage"] = true,
    ["mossfang drake"] = true,
    ["nexlurith"] = true,
    ["nightfang widow"] = true,
    ["nightflare dreadknight"] = true,
    ["nyxdrath the midnight terror"] = true,
    ["pitlord incarnate"] = true,
    ["plague warbringer"] = true,
    ["pyroquill"] = true,
    ["rhazgor the crimson slayer"] = true,
    ["shadowcrystal widow"] = true,
    ["shadowvein wrym"] = true,
    ["stormvein wrym"] = true,
    ["toxic mauler"] = true,
    ["umbral arcanist"] = true,
    ["viridscale wrym"] = true,
    ["voidwagner"] = true,
    ["vorgrun of the jade fangs"] = true,
    ["waterglow conjurer"] = true,
}

local ORBS = {
    [29855] = { bonusKey = "socket_corruption_exalted_bonus" },
    [29856] = { bonusKey = "socket_corruption_chaos_bonus" },
    [29857] = { bonusKey = "socket_corruption_divine_bonus" },
    [29858] = { bonusKey = "socket_corruption_angel_bonus" },
    [29859] = { bonusKey = "socket_corruption_mirror_bonus", maxBonusCount = 1 },
}

local function getEquippedBonus(player, bonusKey)
    local total = 0
    local attributeKey = "socket_bonus_" .. bonusKey
    for _, slot in ipairs(EQUIPPED_SLOTS) do
        local item = player:getSlotItem(slot)
        if item then
            total = total + (tonumber(item:getCustomAttribute(attributeKey)) or 0)
        end
    end
    return math.max(0, total)
end

local function getBonusCount(lootData, maxBonusCount)
    local minCount = math.max(1, tonumber(lootData.minCount) or 1)
    local maxCount = math.max(minCount, tonumber(lootData.maxCount or lootData.count) or 1)
    local count = math.random(minCount, maxCount)
    if maxBonusCount then
        count = math.min(count, maxBonusCount)
    end
    return count
end

function CorruptionGem.isWaystoneMonster(monster)
    if not monster or not monster:isMonster() then
        return false
    end

    return WAYSTONE_MONSTERS[tostring(monster:getName() or ""):lower()] == true
end

function CorruptionGem.applyBonusLoot(player, monster, corpse)
    if not player or not player:isPlayer() or not corpse or not CorruptionGem.isWaystoneMonster(monster) then
        return false
    end

    local monsterType = monster:getType()
    local monsterLoot = monsterType and monsterType:getLoot() or nil
    if type(monsterLoot) ~= "table" then
        return false
    end

    local bonuses = {}
    local hasBonus = false
    for itemId, orbData in pairs(ORBS) do
        local bonus = getEquippedBonus(player, orbData.bonusKey)
        bonuses[itemId] = bonus
        hasBonus = hasBonus or bonus > 0
    end
    if not hasBonus then
        return false
    end

    local rewarded = false
    for _, lootData in ipairs(monsterLoot) do
        local itemId = tonumber(lootData.itemId) or 0
        local orbData = ORBS[itemId]
        local bonusPercent = bonuses[itemId] or 0
        local originalChance = math.max(0, tonumber(lootData.chance) or 0)
        if orbData and bonusPercent > 0 and originalChance > 0 then
            local bonusChance = math.min(MAX_LOOTCHANCE, math.floor(originalChance * (bonusPercent / 100) + 0.5))
            if bonusChance > 0 and getLootRandom() <= bonusChance then
                local count = getBonusCount(lootData, orbData.maxBonusCount)
                if corpse:addItem(itemId, count) then
                    rewarded = true
                end
            end
        end
    end

    if rewarded then
        player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
    end
    return rewarded
end
